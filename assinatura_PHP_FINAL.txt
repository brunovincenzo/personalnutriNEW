<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PersonalNutriApp - Assinaturas</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: white;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 40px;
            max-width: 500px;
            width: 90%;
            text-align: center;
        }

        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #00bfff, #1e90ff);
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            color: white;
            font-weight: bold;
        }

        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 24px;
        }

        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 16px;
        }

        .plans {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 30px;
        }

        .plan {
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }

        .plan:hover {
            border-color: #00bfff;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 191, 255, 0.3);
        }

        .plan.popular {
            border-color: #00bfff;
            background: linear-gradient(135deg, #f0f8ff, #e6f3ff);
        }

        .popular-badge {
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: #00bfff;
            color: white;
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }

        .plan-name {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }

        .plan-price {
            font-size: 24px;
            font-weight: bold;
            color: #00bfff;
            margin-bottom: 5px;
        }

        .plan-period {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }

        .plan-savings {
            background: #ff4444;
            color: white;
            padding: 5px 10px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: bold;
        }

        .purchase-btn {
            background: linear-gradient(135deg, #00bfff, #1e90ff);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 25px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            margin: 10px 0;
            transition: all 0.3s ease;
        }

        .purchase-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 191, 255, 0.4);
        }

        .purchase-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .restore-btn {
            background: linear-gradient(135deg, #666, #888);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            width: 100%;
            margin: 10px 0;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }

        .restore-btn:hover {
            background: linear-gradient(135deg, #555, #777);
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.3);
        }

        .restore-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .benefits {
            text-align: left;
            margin-top: 20px;
        }

        .benefits h3 {
            color: #333;
            margin-bottom: 15px;
            text-align: center;
        }

        .benefit-item {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            padding: 8px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .benefit-icon {
            color: #00bfff;
            margin-right: 10px;
            font-weight: bold;
        }

        /* ✅ BOTÃO RESTAURAR COMPRAS */
        .restore-section {
            text-align: center;
            margin: 30px 0 20px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 15px;
            border: 1px dashed #ccc;
        }

        .restore-btn {
            background: linear-gradient(135deg, #6c757d, #495057);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 8px;
        }

        .restore-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(108, 117, 125, 0.4);
        }

        .restore-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .restore-info {
            color: #666;
            font-size: 12px;
            margin: 0;
            line-height: 1.4;
        }

        /* Debug Console */
        .debug-console {
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 350px;
            max-height: 400px;
            background: rgba(0, 0, 0, 0.9);
            color: #00ff00;
            border-radius: 10px;
            padding: 15px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            overflow-y: auto;
            z-index: 1000;
            border: 2px solid #333;
        }

        .debug-header {
            color: #00ffff;
            font-weight: bold;
            margin-bottom: 10px;
            text-align: center;
            border-bottom: 1px solid #333;
            padding-bottom: 5px;
        }

        .debug-log {
            margin: 5px 0;
            padding: 3px 0;
        }

        .debug-success {
            color: #00ff00;
        }

        .debug-error {
            color: #ff6666;
        }

        .debug-info {
            color: #66ccff;
        }

        .debug-warning {
            color: #ffaa00;
        }

        .toggle-debug {
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: #333;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            z-index: 1001;
        }

        @media (max-width: 480px) {
            .container {
                padding: 20px;
                margin: 20px;
            }
            
            .debug-console {
                width: 280px;
                bottom: 10px;
                right: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">PN</div>
        <h1>PersonalNutriApp</h1>
        <p class="subtitle">Desbloqueie todo o potencial da IA para sua jornada profissional</p>

        <div class="plans">
            <div class="plan" onclick="selectPlan('mensal')">
                <div class="plan-name">Plano Mensal</div>
                <div class="plan-price" id="price-mensal">Carregando...</div>
                <div class="plan-period">por mês</div>
                <button class="purchase-btn" onclick="purchaseProduct('mensal', event)">
                    Assinar Mensal
                </button>
            </div>

            <div class="plan" onclick="selectPlan('semestral')">
                <div class="plan-name">Plano Semestral</div>
                <div class="plan-price" id="price-semestral">Carregando...</div>
                <div class="plan-period">6 meses</div>
                <div class="plan-savings">ECONOMIZE 11%</div>
                <button class="purchase-btn" onclick="purchaseProduct('semestral', event)">
                    Assinar Semestral
                </button>
            </div>

            <div class="plan" onclick="selectPlan('anual')">
                <div class="plan-name">Plano Anual</div>
                <div class="plan-price" id="price-anual">Carregando...</div>
                <div class="plan-period">12 meses</div>
                <div class="plan-savings">ECONOMIZE 17%</div>
                <button class="purchase-btn" onclick="purchaseProduct('anual', event)">
                    Assinar Anual
                </button>
            </div>
        </div>

        <!-- ✅ BOTÃO RESTAURAR COMPRAS (EXIGIDO PELA APPLE) -->
        <div class="restore-section">
            <button class="restore-btn" id="restoreBtn" onclick="restorePurchases()">
                ♻️ Restaurar Compras
            </button>
            <p class="restore-info">Já possui uma assinatura? Restaure suas compras anteriores</p>
        </div>

        <div class="benefits">
            <h3>✨ Benefícios do PersonalNutriApp</h3>
            <div class="benefit-item">
                <span class="benefit-icon">✓</span>
                <span>Programações de treino personalizadas pra seus alunos</span>
            </div>
            <div class="benefit-item">
                <span class="benefit-icon">✓</span>
                <span>Planos alimentares personalizados pra seus alunos</span>
            </div>
            <div class="benefit-item">
                <span class="benefit-icon">✓</span>
                <span>Acompanhamento individualizado</span>
            </div>
            <div class="benefit-item">
                <span class="benefit-icon">✓</span>
                <span>Cadastro de Alunos</span>
            </div>
            <div class="benefit-item">
                <span class="benefit-icon">✓</span>
                <span>App para seus alunos</span>
            </div>
        </div>
    </div>

    <!-- Debug Console -->
    <button class="toggle-debug" onclick="toggleDebug()">Debug</button>
    <div id="debugConsole" class="debug-console" style="display: none;">
        <div class="debug-header">🔧 DEBUG CONSOLE - IAP BRIDGE</div>
        <div id="debugLogs"></div>
    </div>

    <script>
        let debugVisible = false;
        let logCount = 0;
        const maxLogs = 50;
        let productsInfo = {}; // ✅ Armazenar informações dos produtos do StoreKit

        // Debug functions
        function toggleDebug() {
            debugVisible = !debugVisible;
            const console = document.getElementById('debugConsole');
            console.style.display = debugVisible ? 'block' : 'none';
            if (debugVisible) {
                addDebugLog('🟢 Debug console ativado', 'success');
                checkBridgeStatus();
            }
        }

        function addDebugLog(message, type = 'info') {
            const logs = document.getElementById('debugLogs');
            const timestamp = new Date().toLocaleTimeString();
            const logElement = document.createElement('div');
            logElement.className = `debug-log debug-${type}`;
            logElement.innerHTML = `[${timestamp}] ${message}`;
            
            logs.appendChild(logElement);
            logCount++;
            
            // Limit logs to prevent memory issues
            if (logCount > maxLogs) {
                logs.removeChild(logs.firstChild);
                logCount--;
            }
            
            // Auto scroll to bottom
            logs.scrollTop = logs.scrollHeight;
        }

        function checkBridgeStatus() {
            addDebugLog('🔍 Verificando status da bridge...', 'info');
            
            // Check if we're in WKWebView
            const isWKWebView = window.webkit && 
                               window.webkit.messageHandlers && 
                               window.webkit.messageHandlers.iap;
            
            if (isWKWebView) {
                addDebugLog('✅ WKWebView bridge detectada!', 'success');
                addDebugLog('✅ window.webkit.messageHandlers.iap: OK', 'success');
                
                // Test bridge connectivity
                testBridgeConnectivity();
            } else {
                addDebugLog('❌ WKWebView bridge NÃO encontrada', 'error');
                addDebugLog('ℹ️ Verificando componentes...', 'info');
                addDebugLog(`window.webkit: ${window.webkit ? 'OK' : 'MISSING'}`, 'warning');
                addDebugLog(`messageHandlers: ${window.webkit?.messageHandlers ? 'OK' : 'MISSING'}`, 'warning');
                addDebugLog(`iap handler: ${window.webkit?.messageHandlers?.iap ? 'OK' : 'MISSING'}`, 'warning');
            }
        }

        function testBridgeConnectivity() {
            try {
                addDebugLog('🧪 Testando conectividade da bridge...', 'info');
                
                window.webkit.messageHandlers.iap.postMessage({
                    action: 'test',
                    data: {
                        timestamp: new Date().toISOString(),
                        testId: Math.random().toString(36).substr(2, 9)
                    }
                });
                
                addDebugLog('📤 Mensagem de teste enviada para iOS', 'success');
            } catch (error) {
                addDebugLog(`❌ Erro ao testar bridge: ${error.message}`, 'error');
            }
        }

        // IAP Functions
        function selectPlan(planType) {
            addDebugLog(`📋 Plano selecionado: ${planType}`, 'info');
            
            // Remove previous selections
            document.querySelectorAll('.plan').forEach(plan => {
                plan.classList.remove('selected');
            });
            
            // Add selection to clicked plan
            event.currentTarget.classList.add('selected');
            addDebugLog(`✅ Interface atualizada para plano: ${planType}`, 'success');
        }

        function purchaseProduct(productType, event) {
            // Prevent event bubbling
            if (event) {
                event.stopPropagation();
            }

            addDebugLog(`🛒 Iniciando compra: ${productType}`, 'info');
            
            // Product ID mapping
            const productIds = {
                'mensal': 'com.t800solucoes.personalnutri.mensal.1',
                'semestral': 'com.t800solucoes.personalnutri.semestral.1', 
                'anual': 'com.t800solucoes.personalnutri.anual.1'
            };

            const productId = productIds[productType];
            
            if (!productId) {
                addDebugLog(`❌ Product ID não encontrado para: ${productType}`, 'error');
                return;
            }

            addDebugLog(`🆔 Product ID: ${productId}`, 'info');

            // Check if bridge is available
            if (!window.webkit || !window.webkit.messageHandlers || !window.webkit.messageHandlers.iap) {
                addDebugLog('❌ Bridge não disponível - executando em browser?', 'error');
                alert('Esta funcionalidade está disponível apenas no app móvel.');
                return;
            }

            try {
                // Disable all buttons during purchase
                const buttons = document.querySelectorAll('.purchase-btn, .restore-btn');
                buttons.forEach(btn => {
                    btn.disabled = true;
                });
                
                // Update purchase buttons text
                document.querySelectorAll('.purchase-btn').forEach(btn => {
                    btn.textContent = 'Processando...';
                });
                
                // Update restore button text
                const restoreBtn = document.querySelector('.restore-btn');
                if (restoreBtn) {
                    restoreBtn.textContent = '🔄 Aguarde...';
                }

                addDebugLog('🔒 Todos os botões desabilitados durante compra', 'info');

                // Send purchase request to native iOS
                const purchaseData = {
                    action: 'purchase',
                    productId: productId,
                    productType: productType,
                    timestamp: new Date().toISOString(),
                    requestId: Math.random().toString(36).substr(2, 9)
                };

                addDebugLog('📤 Enviando dados de compra para iOS:', 'info');
                addDebugLog(JSON.stringify(purchaseData, null, 2), 'info');

                window.webkit.messageHandlers.iap.postMessage(purchaseData);
                
                addDebugLog('✅ Solicitação de compra enviada com sucesso!', 'success');
                addDebugLog('⏳ Aguardando resposta do iOS StoreKit...', 'warning');

            } catch (error) {
                addDebugLog(`❌ Erro ao enviar compra: ${error.message}`, 'error');
                console.error('Purchase error:', error);
                
                // Re-enable buttons on error
                enablePurchaseButtons();
                alert('Erro ao processar compra. Tente novamente.');
            }
        }

        function enablePurchaseButtons() {
            const buttons = document.querySelectorAll('.purchase-btn, .restore-btn');
            const purchaseButtons = document.querySelectorAll('.purchase-btn');
            const restoreButton = document.querySelector('.restore-btn');
            
            purchaseButtons.forEach((btn, index) => {
                btn.disabled = false;
                const texts = ['Assinar Mensal', 'Assinar Semestral', 'Assinar Anual'];
                btn.textContent = texts[index] || 'Assinar';
            });
            
            if (restoreButton) {
                restoreButton.disabled = false;
                restoreButton.textContent = '🔄 Restaurar Compras';
            }
            
            addDebugLog('🔓 Botões reabilitados', 'info');
        }

        // ✅ FUNÇÃO PARA RESTAURAR COMPRAS (EXIGIDA PELA APPLE)
        function restorePurchases() {
            addDebugLog('♻️ Iniciando restauração de compras...', 'info');
            
            // Check if bridge is available
            if (!window.webkit || !window.webkit.messageHandlers || !window.webkit.messageHandlers.iap) {
                addDebugLog('❌ Bridge não disponível para restore', 'error');
                alert('Esta funcionalidade está disponível apenas no app móvel.');
                return;
            }

            try {
                // Disable buttons during restore
                const buttons = document.querySelectorAll('.purchase-btn, .restore-btn');
                buttons.forEach(btn => {
                    btn.disabled = true;
                });
                
                const restoreButton = document.querySelector('.restore-btn');
                if (restoreButton) {
                    restoreButton.textContent = '🔄 Restaurando...';
                }

                addDebugLog('🔒 Botões desabilitados durante restore', 'info');

                // Send restore request to native iOS
                const restoreData = {
                    action: 'restore',
                    timestamp: new Date().toISOString(),
                    requestId: Math.random().toString(36).substr(2, 9)
                };

                addDebugLog('📤 Enviando solicitação de restore para iOS:', 'info');
                addDebugLog(JSON.stringify(restoreData, null, 2), 'info');

                window.webkit.messageHandlers.iap.postMessage(restoreData);
                
                addDebugLog('✅ Solicitação de restore enviada!', 'success');
                addDebugLog('⏳ Aguardando resposta do iOS...', 'warning');

            } catch (error) {
                addDebugLog(`❌ Erro ao solicitar restore: ${error.message}`, 'error');
                console.error('Restore error:', error);
                
                // Re-enable buttons on error
                enablePurchaseButtons();
                alert('Erro ao restaurar compras. Tente novamente.');
            }
        }

        // ✅ FUNÇÃO PARA BUSCAR INFORMAÇÕES DOS PRODUTOS
        function loadProductsInfo() {
            addDebugLog('📦 Solicitando informações de produtos...', 'info');
            
            if (!window.webkit || !window.webkit.messageHandlers || !window.webkit.messageHandlers.iap) {
                addDebugLog('⚠️ Bridge não disponível - usando preços padrão', 'warning');
                setDefaultPrices();
                return;
            }

            try {
                const requestData = {
                    action: 'getProducts',
                    timestamp: new Date().toISOString(),
                    requestId: Math.random().toString(36).substr(2, 9)
                };

                window.webkit.messageHandlers.iap.postMessage(requestData);
                addDebugLog('📤 Solicitação de produtos enviada', 'success');

            } catch (error) {
                addDebugLog(`❌ Erro ao solicitar produtos: ${error.message}`, 'error');
                setDefaultPrices();
            }
        }

        function setDefaultPrices() {
            document.getElementById('price-mensal').textContent = 'R$ 35,90';
            document.getElementById('price-semestral').textContent = 'R$ 149,90';
            document.getElementById('price-anual').textContent = 'R$ 239,90';
            addDebugLog('💰 Preços padrão definidos', 'info');
        }

        // ✅ CONTROLE DE POPUP ÚNICO PARA RESTORE
        let restoreCallbackCalled = false;

        // Callback function for iOS to call when IAP completes
        window.iapResult = function(result) {
            addDebugLog('📥 Resposta recebida do iOS:', 'info');
            addDebugLog(JSON.stringify(result, null, 2), 'info');

            try {
                // ✅ CORREÇÃO: Verificar result.status em vez de result.success
                if (result.status === "success") {
                    // Detectar se é restore baseado na mensagem
                    const isRestore = result.message && result.message.includes('restaurada');
                    
                    if (isRestore) {
                        addDebugLog('♻️ COMPRA RESTAURADA COM SUCESSO!', 'success');
                        addDebugLog(`💳 Transaction ID: ${result.transactionId}`, 'success');
                        addDebugLog(`📦 Product ID: ${result.productId}`, 'success');
                        
                        // ✅ MOSTRAR POPUP APENAS UMA VEZ POR RESTORE
                        if (!restoreCallbackCalled) {
                            restoreCallbackCalled = true;
                            alert(`♻️ Compras restauradas com sucesso!\n\n💳 Transaction ID: ${result.transactionId}\n📦 Produto: ${result.productId}\n\n✅ Sua assinatura está ativa!`);
                            
                            // Reset flag after 3 seconds
                            setTimeout(() => {
                                restoreCallbackCalled = false;
                            }, 3000);
                        } else {
                            addDebugLog('⚠️ Popup de restore já foi exibido, ignorando duplicata', 'warning');
                        }
                    } else {
                        addDebugLog('🎉 COMPRA BEM-SUCEDIDA!', 'success');
                        addDebugLog(`💳 Transaction ID: ${result.transactionId}`, 'success');
                        addDebugLog(`📦 Product ID: ${result.productId}`, 'success');
                        addDebugLog(`📋 Mensagem: ${result.message}`, 'success');
                        
                        // Show success message for new purchase
                        alert(`🎉 Compra realizada com sucesso!\n\n💳 Transaction ID: ${result.transactionId}\n📦 Produto: ${result.productId}\n\n✅ Sua assinatura está ativa!`);
                    }
                    
                } else if (result.status === "cancelled") {
                    addDebugLog('👤 OPERAÇÃO CANCELADA pelo usuário', 'warning');
                    addDebugLog(`📋 Mensagem: ${result.message}`, 'warning');
                    alert('⚠️ Operação cancelada pelo usuário.');
                    
                } else {
                    // Error case
                    addDebugLog('❌ OPERAÇÃO FALHOU', 'error');
                    addDebugLog(`Status: ${result.status}`, 'error');
                    addDebugLog(`Erro: ${result.message || 'Erro desconhecido'}`, 'error');
                    
                    // Handle specific error cases
                    if (result.message && result.message.includes('assinante')) {
                        alert('ℹ️ Você já possui uma assinatura ativa!\n\nSe desejar alterar o plano, cancele a assinatura atual primeiro.');
                    } else if (result.message && result.message.includes('Nenhuma compra para restaurar')) {
                        alert('ℹ️ Nenhuma compra encontrada para restaurar.\n\nSe você já fez uma compra, verifique se está usando a mesma conta Apple ID.');
                    } else {
                        alert(`❌ Erro: ${result.message || 'Tente novamente mais tarde'}`);
                    }
                }
            } catch (error) {
                addDebugLog(`❌ Erro ao processar resultado: ${error.message}`, 'error');
                alert(`❌ Erro interno: ${error.message}`);
            } finally {
                // Always re-enable buttons
                setTimeout(enablePurchaseButtons, 500); // Small delay to prevent double-click
            }
        };

        // Bridge test callback
        window.bridgeTestResult = function(result) {
            addDebugLog('📥 Teste de bridge completado:', 'success');
            addDebugLog(`✅ Bridge funcionando corretamente!`, 'success');
            addDebugLog(`Response: ${JSON.stringify(result)}`, 'info');
        };

        // ✅ FUNÇÃO PARA BUSCAR PREÇOS DO STOREKIT
        function loadProductPrices() {
            addDebugLog('💰 Carregando preços dos produtos do StoreKit...', 'info');
            
            // Check if bridge is available
            if (!window.webkit || !window.webkit.messageHandlers || !window.webkit.messageHandlers.iap) {
                addDebugLog('❌ Bridge não disponível - usando preços padrão', 'warning');
                setDefaultPrices();
                return;
            }

            try {
                // Send get products request to native iOS
                const getProductsData = {
                    action: 'getProducts',
                    timestamp: new Date().toISOString(),
                    requestId: Math.random().toString(36).substr(2, 9)
                };

                addDebugLog('📤 Solicitando informações de produtos do iOS:', 'info');
                window.webkit.messageHandlers.iap.postMessage(getProductsData);
                
                addDebugLog('✅ Solicitação de produtos enviada!', 'success');

            } catch (error) {
                addDebugLog(`❌ Erro ao buscar produtos: ${error.message}`, 'error');
                setDefaultPrices();
            }
        }

        // ✅ PREÇOS PADRÃO CASO STOREKIT NÃO ESTEJA DISPONÍVEL
        function setDefaultPrices() {
            addDebugLog('💰 Definindo preços padrão (fallback)', 'warning');
            
            const fallbackPrices = {
                'mensal': 'R$ 35,90',
                'semestral': 'R$ 149,90', 
                'anual': 'R$ 239,90'
            };

            Object.keys(fallbackPrices).forEach(plan => {
                const priceElement = document.getElementById(`price-${plan}`);
                if (priceElement) {
                    priceElement.textContent = fallbackPrices[plan];
                    addDebugLog(`💵 Preço ${plan} definido: ${fallbackPrices[plan]}`, 'info');
                }
            });
        }

        // ✅ CALLBACK PARA RECEBER INFORMAÇÕES DOS PRODUTOS
        window.productsInfoReceived = function(products) {
            addDebugLog('📥 Informações de produtos recebidas:', 'success');
            addDebugLog(JSON.stringify(products, null, 2), 'info');
            
            try {
                productsInfo = products;
                
                // Atualizar preços na interface
                if (products.mensal) {
                    document.getElementById('price-mensal').textContent = products.mensal.price;
                    addDebugLog(`💰 Preço mensal: ${products.mensal.price}`, 'success');
                }
                
                if (products.semestral) {
                    document.getElementById('price-semestral').textContent = products.semestral.price;
                    addDebugLog(`💰 Preço semestral: ${products.semestral.price}`, 'success');
                }
                
                if (products.anual) {
                    document.getElementById('price-anual').textContent = products.anual.price;
                    addDebugLog(`💰 Preço anual: ${products.anual.price}`, 'success');
                }
                
                addDebugLog('✅ Preços atualizados com dados do StoreKit', 'success');
                
            } catch (error) {
                addDebugLog(`❌ Erro ao processar produtos: ${error.message}`, 'error');
                setDefaultPrices();
            }
        };

        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            addDebugLog('🚀 Página carregada - Personal Nutri IAP', 'success');
            addDebugLog('📱 Versão: 1.1 - Com Preços Dinâmicos e Restore', 'info');
            
            // ✅ Carregar informações dos produtos automaticamente
            setTimeout(() => {
                loadProductPrices();
            }, 1000); // Aguardar 1 segundo para o StoreKit estar pronto
            
            // Auto-check bridge on load if debug is visible
            if (debugVisible) {
                checkBridgeStatus();
            }
        });

        // Global error handler
        window.addEventListener('error', function(e) {
            addDebugLog(`🚨 JavaScript Error: ${e.message}`, 'error');
            addDebugLog(`📍 Line: ${e.lineno}, Column: ${e.colno}`, 'error');
        });

        // Log all bridge messages for debugging
        const originalPostMessage = window.webkit?.messageHandlers?.iap?.postMessage;
        if (originalPostMessage) {
            window.webkit.messageHandlers.iap.postMessage = function(message) {
                addDebugLog('📤 Bridge Message Sent:', 'info');
                addDebugLog(JSON.stringify(message, null, 2), 'info');
                return originalPostMessage.call(this, message);
            };
        }
    </script>
</body>
</html>