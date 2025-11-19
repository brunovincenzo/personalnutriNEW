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
    
    // MARK: - Propriedades
    
    private var products: [String: SKProduct] = [:]
    
    // Mantém um callback por productId (mesma API que você já usa)
    private var purchaseCompletions: [String: (IAPResult) -> Void] = [:]
    private var onRestoreCompletion: ((IAPResult) -> Void)?
    
    private var productsRequest: SKProductsRequest?
    private var isProcessingPurchase = false
    
    // Apenas para debug / log (não é mais usado para bloquear compra)
    private var currentActiveProductId: String?
    
    // SEUS PRODUCT IDs REAIS:
    private let productIdentifiers: Set<String> = [
        "com.t800solucoes.personalnutri.mensal.1",
        "com.t800solucoes.personalnutri.semestral.1",
        "com.t800solucoes.personalnutri.anual.1"
    ]
    
    // MARK: - Inicialização
    
    func start() {
        print("🚀 IAPManager.start() chamado!")
        print("📋 Bundle ID: \(Bundle.main.bundleIdentifier ?? "NENHUM")")
        print("💳 Pagamentos disponíveis: \(SKPaymentQueue.canMakePayments())")
        
        // 🧹 Limpeza inicial de transações órfãs
        cleanupOrphanedTransactionsAtStart()
        
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }
    
    private func cleanupOrphanedTransactionsAtStart() {
        let queue = SKPaymentQueue.default()
        let orphanedCount = queue.transactions.count
        
        if orphanedCount > 0 {
            print("🧹 Limpando \(orphanedCount) transações órfãs na inicialização")
            for transaction in queue.transactions {
                if transaction.transactionState == .purchased ||
                    transaction.transactionState == .restored ||
                    transaction.transactionState == .failed {
                    print("🗑️ Finalizando órfã: \(transaction.payment.productIdentifier)")
                    queue.finishTransaction(transaction)
                }
            }
        } else {
            print("✅ Nenhuma transação órfã na inicialização")
        }
    }
    
    // MARK: - Carregar Produtos
    
    private func fetchProducts() {
        print("🔍 Buscando produtos IAP:", productIdentifiers)
        
        productsRequest?.cancel()
        
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest = request
        request.delegate = self
        
        print("🌐 StoreKit request criado, iniciando...")
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("🎉 RESPOSTA STOREKIT RECEBIDA!")
        print("🛍️ Produtos disponíveis:", response.products.count)
        print("🚫 Produtos inválidos:", response.invalidProductIdentifiers)
        
        var loaded: [String: SKProduct] = [:]
        for product in response.products {
            loaded[product.productIdentifier] = product
            print("✅ Produto carregado: \(product.productIdentifier) - \(product.localizedTitle)")
        }
        
        products = loaded
        productsRequest = nil
        
        if products.isEmpty {
            print("🚨 NENHUM PRODUTO FOI CARREGADO! Verifique App Store Connect / Bundle ID")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("❌ ERRO StoreKit:", error.localizedDescription)
        productsRequest = nil
    }
    
    // MARK: - Compra
    
    func purchase(productId: String, appAccountToken: String? = nil, completion: @escaping (IAPResult) -> Void) {
        
        // 🔍 Verificar se já tem o MESMO produto ativo (bloquear apenas duplicatas)
        if hasActiveSubscription(for: productId) {
            print("🚫 PRODUTO JÁ ATIVO: \(productId) - Bloqueando compra duplicada")
            completion(IAPResult(status: "error",
                                 productId: productId,
                                 transactionId: nil,
                                 message: "Você já possui uma assinatura ativa para este plano"))
            return
        }
        
        // 🔒 Evita múltiplas compras simultâneas
        if isProcessingPurchase {
            print("⚠️ COMPRA JÁ EM ANDAMENTO - Aguarde finalizar")
            completion(IAPResult(status: "error",
                                 productId: productId,
                                 transactionId: nil,
                                 message: "Aguarde finalizar a compra anterior antes de tentar novamente"))
            return
        }
        
        // Evita duas compras do MESMO produto ao mesmo tempo
        if purchaseCompletions[productId] != nil {
            print("⚠️ JÁ EXISTE COMPRA PENDENTE PARA: \(productId)")
            completion(IAPResult(status: "error",
                                 productId: productId,
                                 transactionId: nil,
                                 message: "Compra já está em andamento para este produto"))
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            completion(IAPResult(status: "error",
                                 productId: productId,
                                 transactionId: nil,
                                 message: "Compras desativadas neste dispositivo"))
            return
        }
        
        guard let product = products[productId] else {
            print("❌ Produto \(productId) não encontrado na memória!")
            print("📦 Produtos disponíveis:", products.keys)
            completion(IAPResult(status: "error",
                                 productId: productId,
                                 transactionId: nil,
                                 message: "Produto não encontrado. Tente novamente em alguns minutos."))
            return
        }
        
        // Armazena callback desse produto
        purchaseCompletions[productId] = completion
        isProcessingPurchase = true
        
        // Timeout mais generoso (caso StoreKit nunca responda)
        setupCallbackTimeout(for: productId)
        
        print("🛒 Iniciando compra: \(productId)")
        let payment = SKMutablePayment(product: product)
        if let token = appAccountToken, !token.isEmpty {
            payment.applicationUsername = token
        }
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - Restore
    
    func restorePurchases(completion: @escaping (IAPResult) -> Void) {
        onRestoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("🔚 Restauração concluída. Transações na fila: \(queue.transactions.count)")
        
        guard let completion = onRestoreCompletion else { return }
        defer { onRestoreCompletion = nil }
        
        let restored = queue.transactions.filter { $0.transactionState == .restored }
        
        if restored.isEmpty {
            print("📭 Nenhuma transação para restaurar")
            completion(IAPResult(status: "error",
                                 productId: nil,
                                 transactionId: nil,
                                 message: "Nenhuma compra para restaurar"))
            return
        }
        
        // Pega a transação restaurada mais recente
        let latest = restored.max { (a, b) -> Bool in
            (a.transactionDate ?? .distantPast) < (b.transactionDate ?? .distantPast)
        }
        
        let latestProductId = latest?.payment.productIdentifier ?? "N/A"
        print("✅ Restaurada assinatura mais recente:", latestProductId)
        
        // 🔑 Marca também essa assinatura como ativa (para debug)
        if let latestProductId = latest?.payment.productIdentifier {
            currentActiveProductId = latestProductId
            print("🏷️ Assinatura ativa após restore (debug): \(latestProductId)")
        }
        
        completion(IAPResult(status: "success",
                             productId: latest?.payment.productIdentifier,
                             transactionId: latest?.transactionIdentifier,
                             message: "Compras restauradas com sucesso"))
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
        
        // 🔍 Verificar se é transação órfã (sem callback ativo) e não é parte de restore
        let hasActiveCallback = purchaseCompletions[productId] != nil
        let isRestoreProcess = onRestoreCompletion != nil
        
        if !hasActiveCallback &&
            !isRestoreProcess &&
            transaction.transactionState == .purchased {
            print("🚨 TRANSAÇÃO ÓRFÃ DETECTADA: \(productId) - Finalizando sem processar")
            SKPaymentQueue.default().finishTransaction(transaction)
            return
        }
        
        switch transaction.transactionState {
        case .purchased:
            print("✅ Compra concluída: \(productId) - ID: \(transactionId ?? "N/A")")
            
            // 🔑 Marcar assinatura ativa como este productId (debug)
            currentActiveProductId = productId
            print("🏷️ Assinatura ativa agora (debug): \(currentActiveProductId ?? "nenhuma")")
            
            let result = IAPResult(status: "success",
                                   productId: productId,
                                   transactionId: transactionId,
                                   message: "Compra concluída")
            
            if let callback = purchaseCompletions[productId] {
                callback(result)
                purchaseCompletions.removeValue(forKey: productId)
            } else {
                print("⚠️ Nenhum callback pendente para: \(productId)")
            }
            
            if purchaseCompletions.isEmpty {
                isProcessingPurchase = false
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
            
        case .restored:
            print("♻️ Compra restaurada (passo interno): \(productId)")
            // O resultado final do restore é tratado em paymentQueueRestoreCompletedTransactionsFinished
            SKPaymentQueue.default().finishTransaction(transaction)
            
        case .failed:
            let nsError = transaction.error as NSError?
            let errorCode = nsError?.code ?? -1
            let errorDomain = nsError?.domain ?? "Unknown"
            let userInfo = nsError?.userInfo ?? [:]
            let failureReason = (userInfo[NSLocalizedFailureReasonErrorKey] as? String) ?? ""
            let serverCode = userInfo["AMSServerErrorCode"] as? Int
            
            print("❌ Falha na compra: \(productId) - Erro: \(nsError?.localizedDescription ?? "Desconhecido")")
            print("📊 Código do erro: \(errorCode) | Domain: \(errorDomain)")
            print("📎 FailureReason: \(failureReason)")
            print("📎 AMSServerErrorCode: \(serverCode ?? -1)")
            
            var message = nsError?.localizedDescription ?? "Falha na compra"
            var status = "error"
            
            // Cancelamento pelo usuário
            if errorDomain == SKErrorDomain,
               errorCode == SKError.paymentCancelled.rawValue {
                status = "cancelled"
                message = "Compra cancelada pelo usuário"
            }
            
            // 🔎 Tratamento especial para “Você já é assinante”
            if serverCode == 3532 ||
                failureReason.contains("Você já é assinante") ||
                failureReason.lowercased().contains("already") {
                
                status = "error"
                message = "Você já possui uma assinatura ativa para este plano"
                print("ℹ️ Servidor Apple indicou que já existe assinatura ativa (duplicada)")
            }
            
            let result = IAPResult(status: status,
                                   productId: productId,
                                   transactionId: transactionId,
                                   message: message)
            
            if let callback = purchaseCompletions[productId] {
                callback(result)
                purchaseCompletions.removeValue(forKey: productId)
            } else {
                print("⚠️ Nenhum callback pendente para erro: \(productId)")
            }
            
            if purchaseCompletions.isEmpty {
                isProcessingPurchase = false
            }
            
            SKPaymentQueue.default().finishTransaction(transaction)
            
        case .purchasing:
            print("🛒 Processando compra: \(productId)")
        case .deferred:
            print("⏳ Compra deferida: \(productId)")
        @unknown default:
            print("❓ Estado desconhecido: \(transaction.transactionState.rawValue)")
        }
    }
    
    // MARK: - Timeout simples (sem gambiarra pesada)
    
    private func setupCallbackTimeout(for productId: String) {
        // Timeout um pouco maior para conexões ruins
        DispatchQueue.main.asyncAfter(deadline: .now() + 40) { [weak self] in
            guard let self = self else { return }
            
            if let callback = self.purchaseCompletions[productId] {
                print("⏰ TIMEOUT: Removendo callback órfão para \(productId)")
                callback(IAPResult(
                    status: "error",
                    productId: productId,
                    transactionId: nil,
                    message: "Tempo esgotado na compra. Tente novamente."
                ))
                self.purchaseCompletions.removeValue(forKey: productId)
                if self.purchaseCompletions.isEmpty {
                    self.isProcessingPurchase = false
                }
            }
        }
    }
    
    // MARK: - Métodos auxiliares (mantidos para compatibilidade)
    
    func resetPurchaseState() {
        print("🧹 Limpando estado de compras (resetPurchaseState)")
        isProcessingPurchase = false
        purchaseCompletions.removeAll()
        currentActiveProductId = nil   // zera assinatura ativa (debug)
    }
    
    func getPurchaseState() -> (isProcessing: Bool, pendingCount: Int, processedCount: Int) {
        // processedCount não é mais usado, retornamos 0 para manter a assinatura
        return (isProcessingPurchase, purchaseCompletions.count, 0)
    }
    
    func cleanupOrphanedTransactions() {
        print("🧹 LIMPEZA AGRESSIVA de transações órfãs")
        let queue = SKPaymentQueue.default()
        let totalTransactions = queue.transactions.count
        
        if totalTransactions > 0 {
            print("🗑️ Limpando \(totalTransactions) transações órfãs")
            
            // Finalizar TODAS as transações órfãs
            for transaction in queue.transactions {
                print("🗑️ Órfã: \(transaction.payment.productIdentifier) - Estado: \(transaction.transactionState.rawValue)")
                queue.finishTransaction(transaction)
            }
            
            // Reset completo do estado
            resetPurchaseState()
            print("✅ Limpeza concluída - \(totalTransactions) transações removidas")
        } else {
            print("✅ Nenhuma transação órfã encontrada")
        }
    }
    
    /// ✅ Usa a FILA REAL do StoreKit para saber se esse productId já tem uma compra
    /// em estado purchased/restored para esse Apple ID.
    private func hasActiveSubscription(for productId: String) -> Bool {
        let queue = SKPaymentQueue.default()
        for t in queue.transactions {
            if t.payment.productIdentifier == productId &&
                (t.transactionState == .purchased || t.transactionState == .restored) {
                print("🔍 hasActiveSubscription → TRUE para \(productId) (estado=\(t.transactionState.rawValue))")
                return true
            }
        }
        print("🔍 hasActiveSubscription → FALSE para \(productId)")
        return false
    }
    
    private func getActiveSubscriptionInfo() -> (productId: String?, transactionId: String?) {
        let queue = SKPaymentQueue.default()
        var latest: SKPaymentTransaction?
        var latestDate: Date?
        
        for t in queue.transactions {
            if t.transactionState == .purchased || t.transactionState == .restored {
                let d = t.transactionDate ?? .distantPast
                if latestDate == nil || d > latestDate! {
                    latestDate = d
                    latest = t
                }
            }
        }
        return (latest?.payment.productIdentifier, latest?.transactionIdentifier)
    }
    
    // Mantido igual para o JS/WebView
    func getProductsInfo() -> [String: Any] {
        var productsInfo: [String: Any] = [:]
        
        for (productId, product) in products {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            let priceString = formatter.string(from: product.price) ?? "N/A"
            
            let productType =
                productId.contains("mensal") ? "mensal" :
                productId.contains("semestral") ? "semestral" :
                productId.contains("anual") ? "anual" : "unknown"
            
            productsInfo[productType] = [
                "productId": productId,
                "title": product.localizedTitle,
                "description": product.localizedDescription,
                "price": priceString,
                "priceValue": product.price.doubleValue,
                "currencyCode": product.priceLocale.currencyCode ?? "BRL"
            ]
        }
        
        print("📦 Informações de produtos preparadas para JS:", productsInfo)
        return productsInfo
    }
    
    // Stub para não quebrar se em algum lugar chamarem
    func startPeriodicCleanup() {
        print("ℹ️ startPeriodicCleanup() chamado, mas limpeza periódica foi desativada (não é mais necessária).")
    }
    
    // 🧪 MÉTODO DE DEBUG PARA SANDBOX - Reseta completamente o estado
    func resetSandboxState() {
        print("🧪 RESET COMPLETO DO SANDBOX - USE APENAS EM DESENVOLVIMENTO")
        
        // 1. Limpar todas as transações órfãs
        cleanupOrphanedTransactions()
        
        // 2. Reset completo do estado local
        resetPurchaseState()
        
        // 3. Cancelar requests pendentes
        productsRequest?.cancel()
        productsRequest = nil
        
        // 4. Recarregar produtos
        fetchProducts()
        
        print("✅ Reset do sandbox concluído")
    }
    
    // 📊 Método de debug para monitoramento
    func debugStatus() {
        let queue = SKPaymentQueue.default()
        let state = getPurchaseState()
        
        print("📊 DEBUG STATUS:")
        print("   🔄 Processing: \(state.isProcessing)")
        print("   📞 Callbacks pendentes: \(state.pendingCount)")
        print("   🏪 Transações na fila StoreKit: \(queue.transactions.count)")
        print("   📦 Produtos carregados: \(products.count)")
        
        if !queue.transactions.isEmpty {
            print("   🔍 Transações ativas:")
            for (index, transaction) in queue.transactions.enumerated() {
                print("     \(index + 1). \(transaction.payment.productIdentifier) - Estado: \(transaction.transactionState.rawValue)")
            }
        }
    }
}

