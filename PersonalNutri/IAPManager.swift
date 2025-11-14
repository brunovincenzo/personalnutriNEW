
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

    // SEUS PRODUCT IDs REAIS:
    private let productIdentifiers: Set<String> = [
        "com.t800solucoes.personalnutri.mensal.1",
        "com.t800solucoes.personalnutri.semestral.1",
        "com.t800solucoes.personalnutri.anual.1"
    ]

    func start() {
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    private func fetchProducts() {
        print("🔍 Buscando produtos IAP:", productIdentifiers)
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("🛍️ StoreKit Response - Produtos disponíveis:", response.products.count)
        print("🚫 Produtos inválidos:", response.invalidProductIdentifiers)
        
        for product in response.products {
            products[product.productIdentifier] = product
            print("✅ Produto carregado: \(product.productIdentifier) - \(product.localizedTitle)")
        }
        print("📦 Total produtos IAP carregados:", products.keys)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Erro ao carregar produtos IAP:", error.localizedDescription)
    }

    // MARK: - Public

    func purchase(productId: String, appAccountToken: String? = nil, completion: @escaping (IAPResult) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Compras desativadas"))
            return
        }

        guard let product = products[productId] else {
            completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Produto não encontrado"))
            return
        }

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
