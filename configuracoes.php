<?php
	# Includes iniciais
	include('template/header.php'); 

	if($_SESSION['USER']['tipo_user'] == "A" && $_SESSION['USER']['flg_compl'] == 0) {
		if (headers_sent()) {
			echo ("<script>location.href='home.php'</script>");
		} else {
			header("Location: home.php");
		}
	}

	$currentPage = 'configuracoes'; 
	include('template/menu.php');

	$formUtils = new formUtils();
	$strUtils = new StringUtils();
	$trainHistDAO = new TrainHistoryDAO();
	$instructorDAO = new InstructorDAO();
	$userDAO = new UserDAO();

	$log = "";

	$messageCodes = [
		0 => __('invalid_mail'),
		1 => __('invalid_req'),
		2 => __('file_success'),
		3 => __('file_error'),
		4 => __('file_invalid'),
		5 => __('obrigs_field'),
		6 => __('file_big')
	];

	// Variáveis para feedback
	$uploadSuccess = false;
	$uploadError = false;
	$messageCode = null;

	// Processar o formulário se foi enviado
	if (isset($_POST['enviado'])) {
		$log = $log."Entrou no post"."\n";
		$description = trim($_POST['description'] ?? '');
		
		// Validar se a descrição foi preenchida
		if (empty($description)) {
			$uploadError = true;
			$messageCode = 5;
		} else {
			$log = $log."Descricao OK"."\n";
			// Verificar se um arquivo foi enviado
			if (isset($_FILES['image_file']) && $_FILES['image_file']['error'] === UPLOAD_ERR_OK) {
				$uploadedFile = $_FILES['image_file'];
				$fileName = $uploadedFile['name'];
				$fileTmpName = $uploadedFile['tmp_name'];
				$fileSize = $uploadedFile['size'];
				$fileError = $uploadedFile['error'];
				$log = $log."Definiu infos do arquivo"."\n";
				
				// Validar limite de peso (500KB = 512000 bytes)
				// Limite aumentado em 1000KB anteriormente
				// Em 01/12/2025, Bruno solicitou o aumento para 1.5Mb
				// Em 01/12/2025, Bruno solicitou um novo aumento para 2.5Mn
				$maxFileSize = 2560 * 1024; // 1500KB em bytes
				if ($fileSize > $maxFileSize) {
					$uploadError = true;
					$messageCode = 6; // Novo código para erro de tamanho
				} else {
					$log = $log."Tamanho OK"."\n";
					// Obter a extensão do arquivo
					$fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
					
					// Extensões permitidas
					$allowedExtensions = ['png', 'jpg', 'jpeg'];
					
					// Validar extensão
					if (in_array($fileExtension, $allowedExtensions)) {
						// Validar tipo MIME
						$fileMimeType = mime_content_type($fileTmpName);
						$allowedMimeTypes = ['image/png', 'image/jpeg', 'image/jpg'];
						
						$log = $log."Extensão OK"."\n";

						if (in_array($fileMimeType, $allowedMimeTypes)) {
							// Definir diretório de upload
							$uploadDir = 'images/instructor/';
							$log = $log."Diretorio definido"."\n";
							
							// Criar diretório se não existir
							if (!is_dir($uploadDir)) {
								mkdir($uploadDir, 0755, true);
							}
							
							// Gerar nome único para o arquivo usando o user_id
							$userId = $_SESSION['USER']['id_user'];
							$newFileName = $userId . '.' . $fileExtension;
							$uploadPath =  $_SERVER['DOCUMENT_ROOT']."/".$uploadDir . $newFileName;
							$oldFile = $_SERVER['DOCUMENT_ROOT']."/".$uploadDir.$userId.".".$_SESSION['USER']['instructor_mime'];

							$log = $log."Infos de usuário definida"."\n";
							$log = $log."BOF - Tentando Deletar imagem antiga"."\n";
							$log = $log."------------------------------------"."\n";
							$log = $log."Imagem Antiga = ".$oldFile."\n";
							
							$log = $log."Is file? ".is_file($oldFile)."\n";

							// Verificar se já existe uma imagem com o mesmo nome e removê-la
							if (file_exists($oldFile)) {
								$log = $log."Tentando Deletar img antiga"."\n";
								if (!unlink($oldFile)) {
									$log = $log."!!! NÃO DELETOU IMAGEM ANTIGA"."\n";
									// Se não conseguir deletar o arquivo existente, definir erro
									// $uploadError = true;
									$messageCode = 5; // Novo código para erro ao deletar arquivo existente
								}
							} else {
								$log = $log."!!!! NÃO ACHOU A IMG ANTIGA"."\n";
							}

							$log = $log."------------------------------------"."\n";
							$log = $log."EOF - DEletada imagem antiga"."\n";
							$log = $log."Status UpLoad Error = ".(int)$uploadError."\n";
							
							// Verificar se não houve erro na remoção antes de continuar
							if ($uploadError === false) {
								error_log("\n------------------------\n".$fileTmpName."\n------------------------\n");
								$log = $log."sE NÃO DEU erro no upload, tenta movera a imagem"."\n";
								// $log = $log."Pausa de 15 segundos para achar os bagulhos"."\n";
								// sleep(15);

								// Mover arquivo para o diretório de destino
								if (move_uploaded_file($fileTmpName, $uploadPath)) {
									$log = $log."moveu a imge"."\n";
									$data["id"] = $userId;
									$data["campo"] = "instructor_text";
									$data["valor"] = $description;
						
									$userDAO->updateUser($data);
						
									$data["id"] = $userId;
									$data["campo"] = "instructor_mime";
									$data["valor"] = $fileExtension;
						
									$userDAO->updateUser($data);
									
									$uploadSuccess = true;
									$messageCode = 2;
								} else {
									$log = $log."!!! NÃO MOVEU A IMG"."\n";
									$uploadError = true;
									$messageCode = 3;
								}
							}
						} else {
							$uploadError = true;
							$messageCode = 4;
						}
					} else {
						$uploadError = true;
						$messageCode = 4;
					}
				}
			} else {
				$uploadError = true;
				$messageCode = 3;
			}
		}
	}

	$log = "";
	// $log = $log;

?>
<style>
	table td:last-child, table th:last-child {
		display: table-cell;
	}
</style>
<!-- Conteúdo principal -->
<main>
    <div class="container">
		<?php if ($_SESSION['USER']['tipo_user'] == "A") { ?>

        <div class="row">
			<div class="col s12">
				<h4><?php echo __('config_title'); ?></h4>
			</div>
			<?php #echo '<br><br><br><br><pre>'; print_r($_FILES['image_file']); echo '<br>--------------------<br>'; print_r($log); var_dump($messageCode); echo '</pre>';?>
		</div> <!-- EOF TILE -->

		<!-- Mensagens de feedback -->
		<?php if ($uploadSuccess): ?>
			<div class="row">
				<div class="col s12">
					<div class="card-panel green lighten-4 green-text text-darken-2">
						<i class="material-icons left">check_circle</i>
						<?php echo $messageCodes[$messageCode]; ?>
					</div>
				</div>
			</div>
			<script>
				setTimeout(function() {
					window.location.href = 'home.php';
				}, 1000);
			</script>
		<?php endif; ?>

		<?php if ($uploadError): ?>
			<div class="row">
				<div class="col s12">
					<div class="card-panel red lighten-4 red-text text-darken-2">
						<i class="material-icons left">error</i>
						<?php echo $messageCodes[$messageCode]; ?>
					</div>
				</div>
			</div>
		<?php endif; ?>

		<div class="row">
			<div class="col s12">
			<form class="col s12" id="mainForm" method="post" action="configuracoes.php" enctype="multipart/form-data">
				<label for="upload_submit"><?php echo __('image_placeholder'); ?></label>
				<input type="file" id="image_file" name="image_file" accept=".png,.jpg,image/png, image/jpg, image/jpeg" capture="none" required><br><br>
				<label for="description"><?php echo __('info_teacher_placeholder'); ?></label><br>
				<input type="text" name="description" id="description" placeholder="" maxlength='110'><br>
				<input type="hidden" name="enviado" value="true">
				<input type="submit" id="enviado" value="<?php echo __('save_student'); ?>" class="btn btn-large red" style="margin-top: 20px; color: white !important;">
			</form>
			</div>
		</div>
	<?php } ?>
	</div>
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
