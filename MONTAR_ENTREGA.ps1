$ErrorActionPreference = "Stop"
$Pasta = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Pasta

function Selecionar-Arquivo($Titulo, $Filtro) {
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = $Titulo
    $dlg.Filter = $Filtro
    $dlg.Multiselect = $false
    if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        throw "Seleção cancelada. Nenhum pacote final foi criado."
    }
    return $dlg.FileName
}

# O utilizador já tem os arquivos executados; o script apenas os copia, sem executar código.
$NotebookFinal = Join-Path $Pasta "1_Notebook_GS2026_2.ipynb"
$RagasFinal = Join-Path $Pasta "3_avaliacao_ragas.json"

if (-not (Test-Path $NotebookFinal)) {
    Write-Host "Selecione o notebook .ipynb que você já executou no Colab." -ForegroundColor Cyan
    $origem = Selecionar-Arquivo "Selecione o notebook executado" "Notebook Jupyter (*.ipynb)|*.ipynb|Todos os arquivos (*.*)|*.*"
    Copy-Item -LiteralPath $origem -Destination $NotebookFinal -Force
}
if (-not (Test-Path $RagasFinal)) {
    Write-Host "Selecione o JSON RAGAS original que você já baixou do Colab." -ForegroundColor Cyan
    $origem = Selecionar-Arquivo "Selecione 3_avaliacao_ragas.json" "Arquivo JSON (*.json)|*.json|Todos os arquivos (*.*)|*.*"
    Copy-Item -LiteralPath $origem -Destination $RagasFinal -Force
}

# Validar JSON do notebook e presença de execução/outputs.
$nb = Get-Content -LiteralPath $NotebookFinal -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $nb.cells) { throw "O notebook selecionado não contém a estrutura esperada de células Jupyter." }
$codigos = @($nb.cells | Where-Object { $_.cell_type -eq "code" })
$executadas = @($codigos | Where-Object { $null -ne $_.execution_count })
$comSaida = @($codigos | Where-Object { $_.outputs -and $_.outputs.Count -gt 0 })
if ($executadas.Count -eq 0 -or $comSaida.Count -eq 0) {
    throw "O notebook selecionado parece não conter outputs de execução. Selecione a cópia exportada do Colab depois de executar e salvar as células."
}
# Não permitir uma chave Google comum em texto puro no notebook.
$nbTexto = Get-Content -LiteralPath $NotebookFinal -Raw -Encoding UTF8
if ($nbTexto -match 'AIza[0-9A-Za-z_-]{30,}') {
    throw "Foi encontrada uma possível chave Google no notebook. Remova o segredo, exporte novamente e execute o script."
}

# Validar JSON RAGAS, sem reconstruir ou alterar scores.
$ragas = Get-Content -LiteralPath $RagasFinal -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $ragas) { throw "O JSON RAGAS está vazio ou inválido." }
if ($ragas.PSObject.Properties.Name -contains "perguntas_processadas") {
    Write-Host ("Perguntas registradas no JSON: " + $ragas.perguntas_processadas + "/" + $ragas.perguntas_exigidas)
    if ([int]$ragas.perguntas_processadas -ne 8) {
        throw "O JSON não registra 8 perguntas concluídas. Confira se selecionou o arquivo final exportado do Colab."
    }
}
if ($ragas.PSObject.Properties.Name -contains "status") {
    Write-Host ("Status RAGAS: " + $ragas.status)
    if ([string]$ragas.status -notmatch "MEDIDO_COMPLETO_8_DE_8") {
        throw "O status do JSON não indica MEDIDO_COMPLETO_8_DE_8. O ZIP final não será montado com uma avaliação parcial."
    }
}

# Não gerar submissão oficial com links fictícios ou vazios.
$certPath = Join-Path $Pasta "5_certificacao.txt"
$videoPath = Join-Path $Pasta "7_demo_video_url.txt"
$cert = Get-Content -LiteralPath $certPath -Raw -Encoding UTF8
$video = Get-Content -LiteralPath $videoPath -Raw -Encoding UTF8
if ($cert -match '\[INSERIR URL REAL DO REPOSITÓRIO\]' -or $cert -notmatch 'https?://') {
    throw "Preencha o link público real do repositório em 5_certificacao.txt e rode novamente."
}
if ($video -match '\[INSERIR URL REAL' -or $video -notmatch 'https?://') {
    throw "Preencha o link real do vídeo em 7_demo_video_url.txt e rode novamente."
}

$arquivos = @(
    "1_Notebook_GS2026_2.ipynb",
    "2_base_documental",
    "3_avaliacao_ragas.json",
    "4_README.md",
    "5_certificacao.txt",
    "6_Chat_Log.txt",
    "7_demo_video_url.txt"
)
foreach ($item in $arquivos) {
    if (-not (Test-Path (Join-Path $Pasta $item))) { throw "Entregável ausente: $item" }
}

$Destino = Join-Path $Pasta "GS2026_2_1CCPJ_TRAMA_CIVICA.zip"
if (Test-Path $Destino) { Remove-Item -LiteralPath $Destino -Force }
$paths = $arquivos | ForEach-Object { Join-Path $Pasta $_ }
Compress-Archive -Path $paths -DestinationPath $Destino -CompressionLevel Optimal
Write-Host ""
Write-Host "ZIP FINAL CRIADO: $Destino" -ForegroundColor Green
Write-Host "Contém os sete entregáveis oficiais. O notebook e o JSON foram apenas copiados/validados, não modificados nem reexecutados."
Write-Host "Confirme também a autorização do professor para a mudança de provedor e as assinaturas dos integrantes."
