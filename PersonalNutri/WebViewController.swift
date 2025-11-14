import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 WebViewController.viewDidLoad")

        let contentController = WKUserContentController()
        contentController.add(self, name: "iap")

        let testEmail = "teste@local"
        let appUUID = UUID().uuidString
        let escapedEmail = testEmail.replacingOccurrences(of: "'", with: "\\'")
        let escapedUUID = appUUID.replacingOccurrences(of: "'", with: "\\'")
        let jsInit = "window.USER_EMAIL = '\(escapedEmail)'; window.APP_UUID = '\(escapedUUID)';"
        let userScript = WKUserScript(source: jsInit, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)

        let jsIapResult = "(function(){if (!window.iapResult) {window.iapResult = function(result) {try { console.log('iapResult', result); } catch(e){}};}})()"
        let iapResultScript = WKUserScript(source: jsIapResult, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(iapResultScript)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        // Carregar o site principal (com login)
        if let url = URL(string: "https://t800robodetreinos.com.br") {
            let request = URLRequest(url: url)
            webView.load(request)
            print("🔵 Carregando site principal")
        }
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {

        guard message.name == "iap" else { return }

        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            print("Erro: body inválido")
            return
        }

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

        case "debug":
            print("🐞 Debug OK")

        default:
            break
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
            return
        }

        let js = "window.iapResult && window.iapResult(\(jsonString));"

        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(js)
        }
    }
}
