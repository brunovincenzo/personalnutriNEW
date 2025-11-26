import Foundation
import StoreKit

struct IAPResult {
    var status: String          // "success", "error", "cancelled"
    var productId: String?
    var transactionId: String?
    var message: String?
    var appAccountToken: String?  // UUID do usuário
}

@available(iOS 15.0, *)
class IAPManager: NSObject {
    
    static let shared = IAPManager()
    
    private var lastUsedUUID: String?
    
    private let productIdentifiers: Set<String> = [
        "com.t800solucoes.personalnutri.mensal.1",
        "com.t800solucoes.personalnutri.semestral.1",
        "com.t800solucoes.personalnutri.anual.1"
    ]
    
    func start() {
        print("🚀 IAPManager.start() chamado!")
        Task {
            await observeTransactionUpdates()
        }
    }
    
    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                print("🔄 Transação atualizada: \(transaction.productID)")
                await transaction.finish()
            } catch {
                print("❌ Erro ao verificar transação: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe): return safe
        case .unverified: throw NSError(domain: "StoreKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transação não verificada"])
        }
    }
    
    // MARK: - Compra
    
    func purchase(productId: String, appAccountToken: String? = nil, completion: @escaping (IAPResult) -> Void) {
        guard let uuidString = appAccountToken, let uuid = UUID(uuidString: uuidString) else {
            print("❌ UUID inválido ou não fornecido")
            completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Identificador de usuário inválido"))
            return
        }
        
        let currentUUID = uuid.uuidString
        let shouldReset = (lastUsedUUID == nil) || (lastUsedUUID != currentUUID)
        if shouldReset {
            if let lastUUID = lastUsedUUID {
                print("🔄 MUDANÇA DE USUÁRIO DETECTADA: '\(lastUUID)' → '\(currentUUID)'")
            } else {
                print("🎯 PRIMEIRA COMPRA DETECTADA: '\(currentUUID)'")
            }
        }
        lastUsedUUID = currentUUID
        
        Task {
            guard !Task.isCancelled else {
                print("⚠️ Task cancelada antes da execução")
                return
            }
            
            do {
                print("🔍 Buscando produto: \(productId)")
                let products = try await Product.products(for: [productId])
                guard let product = products.first else {
                    await MainActor.run {
                        completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Produto não encontrado"))
                    }
                    return
                }
                
                print("🛒 Iniciando compra: \(productId)")
                print("🔑 AppAccountToken: \(uuid.uuidString)")
                
                let result = try await product.purchase(options: [.appAccountToken(uuid)])
                
                switch result {
                case .success(let verificationResult):
                    let transaction = try checkVerified(verificationResult)
                    
                    print("✅ Compra verificada!")
                    print("🧾 Transação: \(transaction.id)")
                    print("🔗 UUID no webhook: \(transaction.appAccountToken?.uuidString ?? "NENHUM")")
                    
                    await transaction.finish()
                    
                    await MainActor.run {
                        completion(IAPResult(status: "success",
                                             productId: transaction.productID,
                                             transactionId: String(transaction.id),
                                             message: "Compra concluída",
                                             appAccountToken: transaction.appAccountToken?.uuidString))
                    }
                    
                case .userCancelled:
                    print("🚫 Compra cancelada pelo usuário")
                    await MainActor.run {
                        completion(IAPResult(status: "cancelled", productId: productId, transactionId: nil, message: "Compra cancelada pelo usuário"))
                    }
                    
                case .pending:
                    print("⏳ Compra pendente")
                    await MainActor.run {
                        completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Compra aguardando aprovação"))
                    }
                    
                @unknown default:
                    await MainActor.run {
                        completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: "Erro desconhecido"))
                    }
                }
                
            } catch StoreKitError.userCancelled {
                print("🚫 Cancelamento detectado")
                await MainActor.run {
                    completion(IAPResult(status: "cancelled", productId: productId, transactionId: nil, message: "Compra cancelada pelo usuário"))
                }
            } catch {
                print("❌ Erro: \(error.localizedDescription)")
                let errorMessage: String
                let desc = error.localizedDescription.lowercased()
                if desc.contains("already") || desc.contains("assinante") {
                    errorMessage = "Você já possui esta assinatura ativa"
                } else {
                    errorMessage = desc.contains("unknown") ? "Compra não efetuada - tente novamente" : error.localizedDescription
                }
                await MainActor.run {
                    completion(IAPResult(status: "error", productId: productId, transactionId: nil, message: errorMessage))
                }
            }
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases(completion: @escaping (IAPResult) -> Void) {
        Task {
            do {
                print("♻️ Restaurando compras...")
                var restored: [Transaction] = []
                
                for await result in Transaction.currentEntitlements {
                    do {
                        let transaction = try checkVerified(result)
                        restored.append(transaction)
                    } catch {
                        print("⚠️ Ignorando transação não verificada")
                    }
                }
                
                guard let latest = restored.max(by: { $0.purchaseDate < $1.purchaseDate }) else {
                    await MainActor.run {
                        completion(IAPResult(status: "error", productId: nil, transactionId: nil, message: "Nenhuma compra para restaurar"))
                    }
                    return
                }
                
                print("✅ Restaurado: \(latest.productID)")
                await MainActor.run {
                    completion(IAPResult(status: "success",
                                         productId: latest.productID,
                                         transactionId: String(latest.id),
                                         message: "Compras restauradas com sucesso",
                                         appAccountToken: latest.appAccountToken?.uuidString))
                }
            } catch {
                print("❌ Erro ao restaurar: \(error.localizedDescription)")
                await MainActor.run {
                    completion(IAPResult(status: "error", productId: nil, transactionId: nil, message: "Erro ao restaurar compras"))
                }
            }
        }
    }
    
    // MARK: - Métodos utilitários
    
    func getProductsInfo(completion: @escaping ([String: Any]) -> Void) {
        Task {
            do {
                let products = try await Product.products(for: productIdentifiers)
                var info: [String: Any] = [:]
                
                for product in products {
                    let tipo =
                        product.id.contains("mensal") ? "mensal" :
                        product.id.contains("semestral") ? "semestral" :
                        product.id.contains("anual") ? "anual" : "outro"
                    
                    info[tipo] = [
                        "productId": product.id,
                        "title": product.displayName,
                        "description": product.description,
                        "price": product.displayPrice,
                        "priceValue": NSDecimalNumber(decimal: product.price).doubleValue,
                        "currencyCode": product.priceFormatStyle.currencyCode
                    ]
                }
                
                await MainActor.run {
                    completion(info)
                }
            } catch {
                await MainActor.run {
                    completion([:])
                }
            }
        }
    }
}

