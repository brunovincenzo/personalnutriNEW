import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔵 WebViewController.viewDidLoad")

        // Configura o bridge JS <-> iOS
        let contentController = WKUserContentController()
        contentController.add(self, name: "iap")

        // Injetar variáveis úteis para a página (USER_EMAIL e APP_UUID)
        // Essas variáveis podem ser usadas pela página local de testes ou pela página remota.
        let testEmail = "teste@local"
        let appUUID = UUID().uuidString
        let escapedEmail = testEmail.replacingOccurrences(of: "'", with: "\\'")
        let escapedUUID = appUUID.replacingOccurrences(of: "'", with: "\\'")
        let jsInit = "window.USER_EMAIL = '\(escapedEmail)'; window.APP_UUID = '\(escapedUUID)';"
        let userScript = WKUserScript(source: jsInit, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(userScript)

        // Garantir que exista um handler `window.iapResult(result)` para que o app possa enviar respostas
        // Caso a página já defina essa função, ela será preservada; caso contrário, usamos uma implementação básica.
        let jsIapResult = #"(function(){
            if (!window.iapResult) {
                window.iapResult = function(result) {
                    try { console.log('iapResult', result); } catch(e){}
                    if (window.onIAPResult) { try { window.onIAPResult(result); } catch(e){} }
                    try { if (typeof alert === 'function') alert('IAP result: ' + JSON.stringify(result)); } catch(e){}
                };
            }
        })();"#
        let iapResultScript = WKUserScript(source: jsIapResult, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        contentController.addUserScript(iapResultScript)

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        // Prioriza carregar a página remota (mais próxima da produção). Se a remota falhar, tenta carregar o HTML local.
        if let url = URL(string: "https://t800robodetreinos.com.br/appview/assinatura.php") {
            let request = URLRequest(url: url)
            webView.load(request)
            print("🔵 Carregando assinatura remota: \(url)")
        } else if let local = Bundle.main.url(forResource: "assinatura", withExtension: "html") {
            webView.loadFileURL(local, allowingReadAccessTo: local.deletingLastPathComponent())
            print("🔵 Carregando assinatura local: \(local)")
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {

        print("📩 Mensagem do JS recebida: name=\(message.name) body=\(message.body)")

        guard message.name == "iap" else {
            print("⚠️ Ignorado: handler não é 'iap'")
            return
        }

        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else {
            print("⚠️ Erro: body inválido")
            return
        }

        switch action {

        case "purchase":
            guard let productId = body["productId"] as? String else {
                print("❌ purchase sem productId")
                return
            }
            let appAccountToken = body["appAccountToken"] as? String
            print("🛒 Solicitação de compra: \(productId) appAccountToken=\(appAccountToken ?? "(nil)")")

            IAPManager.shared.purchase(productId: productId, appAccountToken: appAccountToken) { result in
                self.sendIAPResultToJS(result: result)
            }

        case "restore":
            print("♻️ Solicitação de restore")

            IAPManager.shared.restorePurchases { result in
                self.sendIAPResultToJS(result: result)
            }

        case "debug":
            print("🐞 DEBUG - ponte JS → iOS funcionando!")
            print("DEBUG body: \(body)")

        default:
            print("⚠️ Ação desconhecida: \(action)")
        }
    }

    // MARK: - Enviar resultado de IAP de volta pro JS

    func sendIAPResultToJS(result: IAPResult) {
        // Converte o IAPResult (struct) em dicionário para mandar pro JS
        let dict: [String: Any] = [
            "status": result.status,
            "productId": result.productId ?? "",
            "transactionId": result.transactionId ?? "",
            "message": result.message ?? ""
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Erro ao gerar JSON do resultado IAP")
            return
        }

        let js = "window.iapResult && window.iapResult(\(jsonString));"

        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(js) { (_, error) in
                if let error = error {
                    print("❌ Erro enviando resultado JS: \(error)")
                } else {
                    print("✅ Resultado IAP enviado ao JS")
                }
            }
        }
    }
}
