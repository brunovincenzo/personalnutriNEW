
import Foundation
import StoreKit

struct IAPResult {
    var status: String          // "success", "error", "cancelled"
    var productId: String?
    var transactionId: String?
    var message: String?
}

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    static let shared = IAPManager()

    private var products: [String: SKProduct] = [:]
    private var onPurchaseCompletion: ((IAPResult) -> Void)?
    private var onRestoreCompletion: ((IAPResult) -> Void)?
    private var productsRequest: SKProductsRequest? // MANTER REFERÊNCIA FORTE

    // SEUS PRODUCT IDs REAIS:
    private let productIdentifiers: Set<String> = [
        "com.t800solucoes.personalnutri.mensal.1",
        "com.t800solucoes.personalnutri.semestral.1",
        "com.t800solucoes.personalnutri.anual.1"
    ]

    func start() {
        print("🚀 IAPManager.start() chamado!")
        print("📋 Bundle ID: \(Bundle.main.bundleIdentifier ?? "NENHUM")")
        print("💳 Pagamentos disponíveis: \(SKPaymentQueue.canMakePayments())")
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    private func fetchProducts() {
        print("🔍 Buscando produtos IAP:", productIdentifiers)
        print("🎧 SANDBOX: iPhone vai buscar produtos nos servidores da Apple")
        print("📱 Bundle ID:", Bundle.main.bundleIdentifier ?? "ERRO")
        
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest = request  // MANTER REFERÊNCIA FORTE
        request.delegate = self
        print("🌐 StoreKit request criado, iniciando...")
        request.start()
        print("🚀 StoreKit request.start() chamado!")
        print("📋 Se não responder: Bundle ID deve ser EXATO no App Store Connect")
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("🎉 RESPOSTA STOREKIT RECEBIDA!")
        print("🛍️ StoreKit Response - Produtos disponíveis:", response.products.count)
        print("🚫 Produtos inválidos:", response.invalidProductIdentifiers)
        
        if response.invalidProductIdentifiers.count > 0 {
            print("⚠️ IDs inválidos detectados:", response.invalidProductIdentifiers)
        }
        
        for product in response.products {
            products[product.productIdentifier] = product
            print("✅ Produto carregado: \(product.productIdentifier) - \(product.localizedTitle)")
        }
        print("📦 Total produtos IAP carregados:", products.keys)
        
        if products.isEmpty {
            print("🚨 NENHUM PRODUTO FOI CARREGADO! Verifique StoreKit Configuration")
        }
        
        // Limpar referência após receber resposta
        productsRequest = nil
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ ERRO StoreKit:", error.localizedDescription)
        print("❌ Erro detalhado:", error)
        print("📱 Bundle atual:", Bundle.main.bundleIdentifier ?? "ERRO")
        print("💡 SANDBOX: Bundle ID deve ser EXATO no App Store Connect")
        print("💡 Produtos devem estar 'Ready to Submit' com screenshot")
        print("💡 Aguarde até 6h após configurar no App Store Connect")
        
        // Limpar referência após erro
        productsRequest = nil
    }

    // MARK: - Public

    func purchase(productId: String, appAccountToken: String? = nil, completion: @escaping (IAPResult) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Compras desativadas"))
            return
        }

        guard let product = products[productId] else {
            print("❌ SANDBOX: Produto \(productId) não encontrado!")
            print("📦 Produtos disponíveis:", products.keys)
            print("🔍 Bundle ID atual:", Bundle.main.bundleIdentifier ?? "ERRO")
            print("💡 CRUCIAL: Bundle ID deve ser EXATO no App Store Connect")
            print("💡 Produtos devem ter status 'Ready to Submit'")
            completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Produto não encontrado - Verifique Bundle ID no App Store Connect"))
            return
        }
        
        executePurchase(product: product, appAccountToken: appAccountToken, completion: completion)
    }
    
    private func executePurchase(product: SKProduct, appAccountToken: String?, completion: @escaping (IAPResult) -> Void) {

        onPurchaseCompletion = completion

        let payment = SKPayment(product: product)
        // Aplicar appAccountToken para auxiliar na identificação do usuário no Server-side validation
        if let token = appAccountToken, !token.isEmpty {
            payment.setValue(token, forKey: "applicationUsername")
        }
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases(completion: @escaping (IAPResult) -> Void) {
        onRestoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - SKPaymentTransactionObserver

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            handle(transaction: transaction)
        }
    }

    private func handle(transaction: SKPaymentTransaction) {
        let productId = transaction.payment.productIdentifier
        let transactionId = transaction.transactionIdentifier

        switch transaction.transactionState {
        case .purchased:
            let result = IAPResult(status: "success", productId: productId, transactionId: transactionId, message: "Compra concluída")
            onPurchaseCompletion?(result)
            SKPaymentQueue.default().finishTransaction(transaction)

        case .restored:
            let result = IAPResult(status: "success", productId: productId, transactionId: transactionId, message: "Compra restaurada")
            onRestoreCompletion?(result)
            SKPaymentQueue.default().finishTransaction(transaction)

        case .failed:
            let nsError = transaction.error as NSError?
            let isCancelled = nsError?.code == SKError.paymentCancelled.rawValue

            let result = IAPResult(
                status: isCancelled ? "cancelled" : "error",
                productId: productId,
                transactionId: transactionId,
                message: nsError?.localizedDescription ?? "Falha na compra"
            )
            onPurchaseCompletion?(result)
            SKPaymentQueue.default().finishTransaction(transaction)

        case .purchasing, .deferred:
            break

        @unknown default:
            break
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.isEmpty {
            onRestoreCompletion?(IAPResult(
                status: "error",
                productId: nil,
                transactionId: nil,
                message: "Nenhuma compra para restaurar"
            ))
        }
    }
}
