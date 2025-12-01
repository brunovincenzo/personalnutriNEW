import UIKit
import WebKit
import UniformTypeIdentifiers

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    var webView: WKWebView!
    var fileUploadCompletionHandler: ((URL?) -> Void)?

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
            print("💳 Página de assinaturas detectada - Bridge IAP disponível")
            
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
    
    // ✅ Suporte a upload de arquivos e câmera (input type="file")
    @available(iOS 15.0, *)
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        
        print("📸 Upload de arquivo solicitado")
        
        // Salvar o completion handler
        self.fileUploadCompletionHandler = { url in
            if let url = url {
                completionHandler([url])
            } else {
                completionHandler(nil)
            }
        }
        
        let alert = UIAlertController(title: "Selecionar Imagem", message: nil, preferredStyle: .actionSheet)
        
        // Opção: Tirar Foto
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "📷 Tirar Foto", style: .default) { _ in
                self.openCamera()
            })
        }
        
        // Opção: Escolher da Galeria
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "🖼️ Galeria de Fotos", style: .default) { _ in
                self.openPhotoLibrary()
            })
        }
        
        // Opção: Escolher Arquivo de Imagem (iCloud, Arquivos, etc.)
        alert.addAction(UIAlertAction(title: "📁 Escolher Arquivo", style: .default) { _ in
            self.openDocumentPicker()
        })
        
        // Cancelar
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(nil)
            self.fileUploadCompletionHandler = nil
        })
        
        // Para iPad (apresentar como popover)
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Camera, Galeria e Arquivos
    
    private func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    private func openDocumentPicker() {
        // Apenas imagens: JPEG, PNG, HEIC, GIF, TIFF, BMP, WebP
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [
            .image,           // Todas as imagens
            .jpeg,            // JPEG
            .png,             // PNG
            .heic,            // HEIC (iPhone)
            .gif,             // GIF
            .tiff,            // TIFF
            .bmp,             // BMP
            .webP             // WebP
        ])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            fileUploadCompletionHandler?(nil)
            fileUploadCompletionHandler = nil
            return
        }
        
        // Salvar temporariamente e retornar URL
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "upload_\(UUID().uuidString).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
                print("✅ Foto salva: \(fileURL.path)")
                fileUploadCompletionHandler?(fileURL)
            } catch {
                print("❌ Erro ao salvar foto: \(error)")
                fileUploadCompletionHandler?(nil)
            }
        } else {
            fileUploadCompletionHandler?(nil)
        }
        
        fileUploadCompletionHandler = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        fileUploadCompletionHandler?(nil)
        fileUploadCompletionHandler = nil
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        
        guard let pickedURL = urls.first else {
            fileUploadCompletionHandler?(nil)
            fileUploadCompletionHandler = nil
            return
        }
        
        // Copiar arquivo para diretório temporário (necessário para upload)
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = pickedURL.lastPathComponent
        let tempURL = tempDir.appendingPathComponent(fileName)
        
        do {
            // Remover arquivo temporário anterior se existir
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(at: tempURL)
            }
            
            // Copiar arquivo selecionado
            try FileManager.default.copyItem(at: pickedURL, to: tempURL)
            print("✅ Arquivo copiado: \(tempURL.path)")
            fileUploadCompletionHandler?(tempURL)
        } catch {
            print("❌ Erro ao copiar arquivo: \(error)")
            fileUploadCompletionHandler?(nil)
        }
        
        fileUploadCompletionHandler = nil
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
        fileUploadCompletionHandler?(nil)
        fileUploadCompletionHandler = nil
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
            IAPManager.shared.getProductsInfo { productsInfo in
                self.sendProductsInfoToJS(productsInfo: productsInfo)
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

