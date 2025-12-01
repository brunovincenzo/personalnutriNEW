<?php
	session_start();
	# Includes iniciais
	include('template/header.php'); 

	$currentPage = 'home';
	include('template/menu.php');

	if(isset($_GET['accept']) && $_GET['accept'] == 1) {
		$userDAOTemp = new UserDAO();

		$data = [
			'campo' => "compl_date",
			'valor' => date('Y-m-d'),
			'id' => $_SESSION['USER']['id_user']
		];
		$userDAOTemp->updateUser($data);

		$data = [
			'campo' => "flg_compl",
			'valor' => "1",
			'id' => $_SESSION['USER']['id_user']
		];
		$userDAOTemp->updateUser($data);

		if (headers_sent()) {
			echo ("<script>location.href='home.php'</script>");
		} else {
			header("Location: home.php");
		}
	}

	// ✅ FUNÇÃO PARA PEGAR EMAIL DO USUÁRIO LOGADO (para appAccountToken)
	function getUserEmailFromSession() 
	{
		// Verificar se existe email na sessão do usuário
		if (isset($_SESSION['USER']['email']) && !empty($_SESSION['USER']['email'])) {
			return $_SESSION['USER']['email'];
		}
		
		// Verificar outros campos possíveis na sessão
		if (isset($_SESSION['USER']['user_email']) && !empty($_SESSION['USER']['user_email'])) {
			return $_SESSION['USER']['user_email'];
		}
		
		// Se não encontrar email na sessão, usar email padrão para debug
		return 'usuario@personalnutri.com';
	}

	function uuid5_from_email(string $email): string 
	{
		if (!$email) return '';

		$ns = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // namespace DNS
		$ns_hex = str_replace('-', '', $ns);
		$ns_bin = pack('H*', $ns_hex);
		$hash = sha1($ns_bin . strtolower(trim($email)));

		return sprintf('%08s-%04s-%04x-%04x-%12s',
			substr($hash,0,8), substr($hash,8,4),
			(hexdec(substr($hash,12,4)) & 0x0fff) | 0x5000,
			(hexdec(substr($hash,16,4)) & 0x3fff) | 0x8000,
			substr($hash,20,12)
		);
	}

?>
	<style>
        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #039be5, #1e90ff);
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
            border: 2px solid #039be5;
            border-radius: 15px;
            padding: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
        }

        .plan:hover {
            border-color: #039be5;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 191, 255, 0.3);
        }

        .plan.popular {
            border-color: #039be5;
            background: linear-gradient(135deg, #f0f8ff, #e6f3ff);
        }

        .popular-badge {
            position: absolute;
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: #039be5;
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
            color: #039be5;
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
            background: linear-gradient(135deg, #039be5, #1e90ff);
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
            color: #039be5;
            margin-right: 10px;
            font-weight: bold;
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
    <!-- Conteúdo principal -->
    <main>
	<?php #var_dump($_SESSION['USER']);?>
		<?php
			if($_SESSION['USER']['tipo_user'] == "A" && $_SESSION['USER']['flg_compl'] == 0) { ?>
				<div class="container">
					<div class="row">
						<div class="col s12">
							<h4><?php echo __('welcome_message'); ?></h4>
							<p><?php echo __('conduct_act'); ?></p>

						</div>
					</div>
				</div>
			<?php } else { ?>
        <div class="container">
			<h4>PersonalNutriApp</h4>
			<p class="subtitle"><?php echo __('desblock'); ?></p>

			<div class="plans">
				<div class="plan" onclick="selectPlan('mensal')">
					<div class="plan-name"><?php echo __('signature_monthly'); ?></div>
					<div class="plan-price" id="price-mensal">Carregando...</div>
					<div class="plan-period"><?php echo __('monthly'); ?></div>
					<button class="purchase-btn" onclick="purchaseProduct('mensal', event)">
						<?php echo __('assine_monthly'); ?>
					</button>
				</div>

				<div class="plan" onclick="selectPlan('semestral')">
					<div class="plan-name"><?php echo __('signature_semestral'); ?></div>
					<div class="plan-price" id="price-semestral">Carregando...</div>
					<div class="plan-period">6 <?php echo __('months'); ?></div>
					<div class="plan-savings"><?php echo __('save'); ?> 11%</div>
					<button class="purchase-btn" onclick="purchaseProduct('semestral', event)">
					<?php echo __('assine_semestral'); ?>
					</button>
				</div>

				<div class="plan" onclick="selectPlan('anual')">
					<div class="plan-name"><?php echo __('signature_anual'); ?></div>
					<div class="plan-price" id="price-anual">Carregando...</div>
					<div class="plan-period">12 <?php echo __('months'); ?></div>
					<div class="plan-savings"><?php echo __('save'); ?> 17%</div>
					<button class="purchase-btn" onclick="purchaseProduct('anual', event)">
					<?php echo __('assine_anual'); ?>
					</button>
				</div>
			</div>

			<!-- ✅ BOTÃO RESTAURAR COMPRAS (EXIGIDO PELA APPLE) -->
			<div class="restore-section">
				<button class="restore-btn" id="restoreBtn" onclick="restorePurchases()">
				<?php echo __('signature_restore'); ?>
				</button>
				<p class="restore-info"><?php echo __('signature_restore_info'); ?></p>
			</div>
			<br><br>
			<div class="benefits">
				<h3><?php echo __('benefits'); ?></h3>
				<div class="benefit-item">
					<span class="benefit-icon">✓</span>
					<span><?php echo __('benefits_item1'); ?></span>
				</div>
				<div class="benefit-item">
					<span class="benefit-icon">✓</span>
					<span><?php echo __('benefits_item2'); ?></span>
				</div>
				<div class="benefit-item">
					<span class="benefit-icon">✓</span>
					<span><?php echo __('benefits_item3'); ?></span>
				</div>
				<div class="benefit-item">
					<span class="benefit-icon">✓</span>
					<span><?php echo __('benefits_item4'); ?></span>
				</div>
				<div class="benefit-item">
					<span class="benefit-icon">✓</span>
					<span><?php echo __('benefits_item5'); ?></span>
				</div>
			</div>
			<br><br>
        </div>
		 <!-- Debug Console -->
		<!-- <button class="toggle-debug" onclick="toggleDebug()">Debug</button> -->
		<div id="debugConsole" class="debug-console" style="display: none;">
			<div class="debug-header">🔧 DEBUG CONSOLE - IAP BRIDGE</div>
			<div id="debugLogs"></div>
			</div>
	
		<?php } ?>
    </main>
    
    <!-- Scripts do Material Design -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Inicializa o menu lateral para dispositivos móveis
            var elems = document.querySelectorAll('.sidenav');
            var instances = M.Sidenav.init(elems);
            
            // Inicializa tooltips
            var tooltipElems = document.querySelectorAll('.tooltipped');
            var tooltipInstances = M.Tooltip.init(tooltipElems);
        });
    </script>

	<!-- In App Purchase Scripts -->
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

        // ✅ FUNÇÃO PARA PEGAR EMAIL DO USUÁRIO (para appAccountToken)
        function getUserEmail() {
            // 🎯 PEGAR EMAIL DA SESSÃO PHP
            const userEmail = '<?php echo uuid5_from_email(getUserEmailFromSession()); ?>';
            
            // 🧪 DEBUG TEMPORÁRIO - REMOVER DEPOIS
            const debugInfo = {
                uuid: userEmail,
                sessionEmail: '<?php echo $_SESSION["USER"]["email"] ?? "VAZIO"; ?>',
                sessionUserId: '<?php echo $_SESSION["USER"]["id_user"] ?? "VAZIO"; ?>',
                pageLoadTime: new Date().toISOString()
            };
            console.log('🧪 DEBUG SESSION:', debugInfo);
            addDebugLog(`📧 Email obtido da sessão: ${userEmail}`, 'success');
            addDebugLog(`🧪 Session Debug: ${JSON.stringify(debugInfo)}`, 'info');
            
            return userEmail;
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

            // ✅ PEGAR EMAIL DO USUÁRIO PARA appAccountToken
            const userEmail = getUserEmail();
            addDebugLog(`👤 Email do usuário: ${userEmail}`, 'success');
            
            // 🧪 TESTE: Alertar email para confirmar
           // alert(`🧪 DEBUG: Email que será enviado = ${userEmail}`);

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

                // ✅ Send purchase request with appAccountToken (email)
                const purchaseData = {
                    action: 'purchase',
                    productId: productId,
                    productType: productType,
                    appAccountToken: userEmail, // ✅ EMAIL DO USUÁRIO AQUI!
                    timestamp: new Date().toISOString(),
                    requestId: Math.random().toString(36).substr(2, 9)
                };

                addDebugLog('📤 Enviando dados de compra para iOS:', 'info');
                addDebugLog(`🎯 appAccountToken (email): ${userEmail}`, 'success');
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
			<?php
				$generatedUUID = uuid5_from_email(getUserEmailFromSession());
				$info = array(
					'uuid' => $generatedUUID,
					'email' => $_SESSION['USER']['email'],
					'id_user' => $_SESSION['USER']['id_user']
				);

				$userUUID = new UserUUIDDAO();

				try {
					$userUUID->registerUUID($info);
				} catch (\Throwable $th) { }
				
			?>
        }

        function enablePurchaseButtons() {
            const buttons = document.querySelectorAll('.purchase-btn, .restore-btn');
            const purchaseButtons = document.querySelectorAll('.purchase-btn');
            const restoreButton = document.querySelector('.restore-btn');
            
            purchaseButtons.forEach((btn, index) => {
                btn.disabled = false;
				const texts = [<?="'".__('assine_monthly')."'";?>, <?="'".__('assine_semestral')."'";?>, <?="'".__('assine_anual')."'";?>];
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

        // ✅ FUNÇÃO PARA FORÇAR RELOAD DA WEBVIEW (SE NECESSÁRIO)
        function forceWebViewReload() {
            addDebugLog('🔄 Forçando reload da WebView...', 'info');
            
            if (!window.webkit?.messageHandlers?.iap) {
                addDebugLog('⚠️ Bridge não disponível - usando reload local', 'warning');
                window.location.reload();
                return;
            }

            try {
                const reloadData = {
                    action: 'forceReload',
                    reason: 'uuid_update',
                    timestamp: new Date().toISOString()
                };

                window.webkit.messageHandlers.iap.postMessage(reloadData);
                addDebugLog('✅ Solicitação de reload enviada para iOS', 'success');
                
            } catch (error) {
                addDebugLog(`❌ Erro ao solicitar reload: ${error.message}`, 'error');
                // Fallback para reload local
                window.location.reload();
            }
        }

        // 📋 API PARA CONTROLE MANUAL (SE NECESSÁRIO)
        window.personalNutriSessionControl = {
            forceReload: function() {
                addDebugLog('🔔 Reload manual solicitado', 'success');
                forceWebViewReload();
            }
        };

        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            addDebugLog('🚀 Página carregada - Personal Nutri IAP', 'success');
            addDebugLog('📱 Versão: 2.0 - Com Cache Management Automático', 'info');
            
            // ✅ Teste de obtenção de email
            const testEmail = getUserEmail();
            addDebugLog(`🧪 TESTE: Email obtido = ${testEmail}`, testEmail.includes('@') ? 'success' : 'warning');
            
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

<p style="font-size: 13px; color: #666; text-align: center; margin-top: 30px;">
  By subscribing, you agree to our
  <a href="https://www.t800solucoes.com.br/termos-us" target="_blank" style="color: #007aff; text-decoration: none;">Terms of Use</a>
  and
  <a href="https://www.t800solucoes.com.br/privacidade-us" target="_blank" style="color: #007aff; text-decoration: none;">Privacy Policy</a>.
</p>

</body>
</html>