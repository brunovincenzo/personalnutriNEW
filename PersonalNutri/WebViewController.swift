import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 WebViewController.viewDidLoad")

        let contentController = WKUserContentController()
        contentController.add(self, name: "iap")
        print("✅ Handler 'iap' registrado")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        // Carregar a página de assinatura (com cache-busting)
        let timestamp = Int(Date().timeIntervalSince1970)
        if let url = URL(string: "https://t800robodetreinos.com.br/in-app.php?v=\(timestamp)") {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            webView.load(request)
            print("🔵 Carregando: \(url)")
        }
    }

    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ Página carregada com sucesso")
        
        // Testar se o handler está acessível
        let testJS = """
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iap) {
            console.log('✅ Bridge disponível');
            true;
        } else {
            console.log('❌ Bridge NÃO disponível');
            false;
        }
        """
        
        webView.evaluateJavaScript(testJS) { result, error in
            if let result = result as? Bool {
                print(result ? "✅ JS confirma: bridge disponível" : "❌ JS confirma: bridge NÃO disponível")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Erro ao carregar página: \(error.localizedDescription)")
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {

        print("🟢 MENSAGEM RECEBIDA DO JS!")
        print("   Name: \(message.name)")
        print("   Body: \(message.body)")

        guard message.name == "iap" else {
            print("⚠️ Ignorando mensagem de handler diferente")
            return
        }

        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            print("❌ Body inválido ou sem action")
            return
        }

        print("🎯 Action: \(action)")

        switch action {

        case "purchase":
            guard let productId = body["productId"] as? String else {
                print("❌ ProductId não encontrado")
                return
            }
            let appAccountToken = body["appAccountToken"] as? String
            print("🛒 Iniciando compra: \(productId)")
            print("   Token: \(appAccountToken ?? "nil")")

            IAPManager.shared.purchase(productId: productId, appAccountToken: appAccountToken) { result in
                print("💰 Resultado da compra: \(result.status)")
                self.sendIAPResultToJS(result: result)
            }

        case "restore":
            print("♻️ Iniciando restore")
            IAPManager.shared.restorePurchases { result in
                print("♻️ Resultado do restore: \(result.status)")
                self.sendIAPResultToJS(result: result)
            }

        case "debug":
            print("🐞 Debug test OK - bridge funcionando!")
            let testResult = IAPResult(status: "success", productId: nil, transactionId: nil, message: "Bridge teste OK")
            sendIAPResultToJS(result: testResult)

        default:
            print("⚠️ Action desconhecida: \(action)")
        }
    }

    func sendIAPResultToJS(result: IAPResult) {
        let dict: [String: Any] = [
            "status": result.status,
            "productId": result.productId ?? "",
            "transactionId": result.transactionId ?? "",
            "message": result.message ?? ""
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Erro ao gerar JSON")
            return
        }

        let js = "if(window.iapResult){window.iapResult(\(jsonString));}"
        print("📤 Enviando resultado para JS: \(js)")

        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("❌ Erro ao executar JS: \(error.localizedDescription)")
                } else {
                    print("✅ Resultado enviado para JS com sucesso")
                }
            }
        }
    }
    
    deinit {
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: "iap")
        print("🔴 WebViewController deinit - handler removido")
    }
}
