import UIKit
import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔵 WebViewController.viewDidLoad")
        
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        // ✅ 1. HABILITAR JAVASCRIPT E POP-UPS
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        contentController.add(self, name: "iap")
        print("✅ Handler 'iap' registrado")
        
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self // ✅ Para suporte a pop-ups
        
        // ✅ 4. HABILITAR NAVEGAÇÃO BACK/FORWARD COM GESTOS
        webView.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // ✅ 3. HABILITAR SCROLL HORIZONTAL
        webView.scrollView.alwaysBounceHorizontal = true
        webView.scrollView.bounces = true
        webView.scrollView.showsHorizontalScrollIndicator = true
        
        // Carregar página inicial do sistema (usuário navega normalmente)
        if let url = URL(string: "https://t800robodetreinos.com.br/") {
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            print("🔵 Carregando: \(url.absoluteString)")
            webView.load(request)
        }
        
        // ✅ LOG DAS FUNCIONALIDADES ATIVADAS
        print("✅ WebView configurada com:")
        print("   🪟 Pop-ups JavaScript: ATIVADO")
        print("   📥 Downloads PDF/Word/Excel: ATIVADO")
        print("   🔄 Scroll horizontal: ATIVADO")
        print("   ◀️ Navegação back/forward: ATIVADO")
        print("   💳 Bridge IAP: ATIVADO")
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ Página carregada: \(webView.url?.absoluteString ?? "desconhecida")")
        
        // ✅ 3. GARANTIR SCROLL HORIZONTAL VIA JAVASCRIPT (caso CSS bloqueie)
        let enableHorizontalScrollJS = """
            document.documentElement.style.overflowX = 'auto';
            document.body.style.overflowX = 'auto';
        """
        webView.evaluateJavaScript(enableHorizontalScrollJS)
        
        // Detecta se está na página de assinaturas (in-app.php)
        if let currentUrl = webView.url?.absoluteString, currentUrl.contains("in-app.php") {
            print("💳 Página de assinaturas detectada - Ativando bridge IAP")
            
            // Testa o bridge JavaScript
            let testJS = "(function() { return window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iap ? 'bridge OK' : 'bridge NÃO OK'; })();"
            
            webView.evaluateJavaScript(testJS) { result, error in
                if let result = result {
                    print("✅ IAP Bridge: \(result)")
                }
            }
        } else {
            print("📄 Navegação normal - Bridge IAP ficará disponível quando acessar in-app.php")
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ Erro: \(error.localizedDescription)")
    }
    
    // ✅ 2. SUPORTE A DOWNLOADS DE PDF, WORD, EXCEL
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let mimeType = navigationResponse.response.mimeType ?? ""
        let allowedDownloadTypes = [
            "application/pdf",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // .docx
            "application/msword", // .doc
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // .xlsx
            "application/vnd.ms-excel", // .xls
            "application/vnd.openxmlformats-officedocument.presentationml.presentation", // .pptx
            "application/vnd.ms-powerpoint", // .ppt
            "application/zip",
            "application/x-zip-compressed",
            "text/csv"
        ]

        if allowedDownloadTypes.contains(mimeType),
           let url = navigationResponse.response.url {
            print("📥 Iniciando download: \(url.absoluteString) (MIME: \(mimeType))")
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
    
    // MARK: - WKUIDelegate (Suporte a Pop-ups JavaScript)
    
    // ✅ Suporte a window.open() - Pop-ups
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        print("🪟 Pop-up solicitado: \(navigationAction.request.url?.absoluteString ?? "URL desconhecida")")
        
        // Se for uma nova janela, abrir no mesmo webView (comportamento simples)
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    // ✅ Suporte a window.alert()
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    // ✅ Suporte a window.confirm()
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: "Confirmação", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        present(alert, animated: true)
    }
    
    // ✅ Suporte a window.prompt()
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        
        let alert = UIAlertController(title: "Entrada", message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(nil)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        present(alert, animated: true)
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
        case "getProducts":
            print("📦 Buscando informações de produtos")
            let productsInfo = IAPManager.shared.getProductsInfo()
            self.sendProductsInfoToJS(productsInfo: productsInfo)
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
    
    func sendProductsInfoToJS(productsInfo: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: productsInfo),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        let js = "window.productsInfoReceived && window.productsInfoReceived(\(jsonString));"
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
    
    // MARK: - Métodos de Navegação Utilitários
    
    // ✅ 4. NAVEGAÇÃO PROGRAMÁTICA (caso necessário)
    @objc func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func reload() {
        webView.reload()
    }
    
    func loadURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
