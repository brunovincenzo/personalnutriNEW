import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔵 WebViewController.viewDidLoad")
        
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        contentController.add(self, name: "iap")
        print("✅ Handler 'iap' registrado")
        
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Carregar página com cache busting
        let timestamp = Int(Date().timeIntervalSince1970)
        if let url = URL(string: "https://t800robodetreinos.com.br/in-app.php?v=\(timestamp)") {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            print("🔵 Carregando: \(url.absoluteString)")
            webView.load(request)
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ Página carregada")
        
        let testJS = "(function() { return window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iap ? 'bridge OK' : 'bridge NÃO OK'; })();"
        
        webView.evaluateJavaScript(testJS) { result, error in
            if let result = result {
                print("✅ \(result)")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Erro: \(error.localizedDescription)")
    }
    
    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        print("🟢 MENSAGEM DO JS!")
        print("📩 \(message.body)")

        guard message.name == "iap" else { return }
        guard let body = message.body as? [String: Any], let action = body["action"] as? String else { return }

        switch action {
        case "purchase":
            guard let productId = body["productId"] as? String else { return }
            let appAccountToken = body["appAccountToken"] as? String
            print("🛒 Compra: \(productId)")
            IAPManager.shared.purchase(productId: productId, appAccountToken: appAccountToken) { result in
                self.sendIAPResultToJS(result: result)
            }
        case "restore":
            print("♻️ Restore")
            IAPManager.shared.restorePurchases { result in
                self.sendIAPResultToJS(result: result)
            }
        default:
            print("⚠️ Ação: \(action)")
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
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        let js = "window.iapResult && window.iapResult(\(jsonString));"
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
