<?php
session_start();
if (!isset($_SESSION['USER'])) {
    header('Location: login.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IN APP | Personal Nutri</title>
    
    <!-- Cache control -->
    <meta http-equiv='cache-control' content='no-cache'>
    <meta http-equiv='expires' content='0'>
    <meta http-equiv='pragma' content='no-cache'>
    
    <!-- Material Design -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
</head>
<body>
    <div class="container" style="margin-top: 50px;">
        <div class="row">
            <div class="col s12">
                <h4>Escolha um dos nossos planos</h4>
                <p>Temos três modalidades de assinatura - Mensal, Semestral e Anual.</p>
            </div>
        </div>
        
        <div class="row">
            <div class="col s12 center-align">
                <button id="btnMensal" class="btn waves-effect waves-light blue">
                    Assinatura Mensal
                </button><br><br>
                <button id="btnSemestral" class="btn waves-effect waves-light orange">
                    Assinatura Semestral
                </button><br><br>
                <button id="btnAnual" class="btn waves-effect waves-light green">
                    Assinatura Anual
                </button><br><br>
                <button id="btnRestore" class="btn waves-effect waves-light grey">
                    Restaurar Compras
                </button>
            </div>
        </div>
    </div>

    <script>
    // Produtos IAP
    const PRODUCTS = {
      mensal: 'com.t800solucoes.personalnutri.mensal.1',
      semestral: 'com.t800solucoes.personalnutri.semestral.1',
      anual: 'com.t800solucoes.personalnutri.anual.1'
    };

    // Console de debug visível
    function ensureDebugConsole() {
      let el = document.getElementById('debug-console');
      if (!el) {
        el = document.createElement('div');
        el.id = 'debug-console';
        el.style.cssText = 'position:fixed;bottom:0;left:0;right:0;max-height:35%;overflow:auto;background:#111;color:#0f0;font:12px/1.4 monospace;padding:8px;z-index:99999;border-top:1px solid #333';
        el.innerHTML = '<b>DEBUG CONSOLE</b><br>';
        document.body.appendChild(el);
      }
      return el;
    }

    function debugLog(msg, obj) {
      const el = ensureDebugConsole();
      const t = new Date().toLocaleTimeString();
      const line = document.createElement('div');
      line.textContent = '[' + t + '] ' + msg;
      el.appendChild(line);
      if (obj !== undefined) {
        const pre = document.createElement('pre');
        pre.textContent = (typeof obj === 'string') ? obj : JSON.stringify(obj, null, 2);
        el.appendChild(pre);
      }
      el.scrollTop = el.scrollHeight;
      try { 
        console.log(msg, obj || ''); 
      } catch(e) {}
    }

    // UUID persistente para appAccountToken
    function getAppUUID() {
      try {
        const key = 'APP_UUID';
        let v = localStorage.getItem(key);
        if (!v) {
          v = (crypto && crypto.randomUUID) ? crypto.randomUUID() :
              'xxxxxxxxyxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                const r = Math.random() * 16 | 0;
                const d = c === 'x' ? r : (r & 0x3 | 0x8);
                return d.toString(16);
              });
          localStorage.setItem(key, v);
        }
        return v;
      } catch(e) {
        return 'uuid-fallback';
      }
    }

    // Detecta se está no app iOS (WKWebView)
    function isIOSApp() {
      return !!(window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.iap);
    }

    // Envia mensagem para o app iOS
    function sendToApp(action, productId) {
      if (!isIOSApp()) {
        debugLog('⚠️ Não está no app iOS. Abra pelo app.');
        alert('Esta assinatura funciona somente dentro do app iOS.');
        return;
      }
      
      const msg = {
        action: action,
        productId: productId || null,
        appAccountToken: getAppUUID()
      };
      
      try {
        window.webkit.messageHandlers.iap.postMessage(msg);
        debugLog('📤 Enviado para o app', msg);
      } catch (e) {
        debugLog('❌ Erro ao enviar para o app', String(e));
        alert('Erro ao comunicar com o app.');
      }
    }

    // Callback que o app iOS chamará de volta
    window.iapResult = function(result) {
      debugLog('📥 iapResult recebido', result);
      try { 
        alert('Resultado IAP: ' + JSON.stringify(result)); 
      } catch(e) {}
    };

    // Liga os botões quando página carregar
    document.addEventListener('DOMContentLoaded', function() {
      ensureDebugConsole();
      debugLog('📱 Página carregada');
      debugLog(isIOSApp() ? '✅ Rodando no app iOS (bridge OK)' : '❌ Não está no app iOS');

      const btnMensal = document.getElementById('btnMensal');
      const btnSemestral = document.getElementById('btnSemestral');
      const btnAnual = document.getElementById('btnAnual');
      const btnRestore = document.getElementById('btnRestore');

      if (btnMensal) {
        btnMensal.onclick = function() { 
          debugLog('🖱️ Clique no botão Mensal');
          sendToApp('purchase', PRODUCTS.mensal); 
        };
      }
      if (btnSemestral) {
        btnSemestral.onclick = function() { 
          debugLog('🖱️ Clique no botão Semestral');
          sendToApp('purchase', PRODUCTS.semestral); 
        };
      }
      if (btnAnual) {
        btnAnual.onclick = function() { 
          debugLog('🖱️ Clique no botão Anual');
          sendToApp('purchase', PRODUCTS.anual); 
        };
      }
      if (btnRestore) {
        btnRestore.onclick = function() { 
          debugLog('🖱️ Clique no botão Restore');
          sendToApp('restore'); 
        };
      }

      debugLog('✅ Event listeners prontos');
      debugLog('🆔 APP_UUID: ' + getAppUUID());
    });
    </script>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>
</body>
</html>