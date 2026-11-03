# MiniCPM-OCR 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md
# 更新日期：2026-11-03
# 类型：script
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '需要先安装 Git' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

git clone https://github.com/OpenBMB/MiniCPM-OCR.git
Set-Location MiniCPM-OCR; New-Item -ItemType Directory -Force .\models\MiniCPM-OCR-1.0-gguf | Out-Null
curl.exe -fL -o .\models\MiniCPM-OCR-1.0-gguf\MiniCPM-OCR-1_0-Q8_0.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/main/MiniCPM-OCR-1_0-Q8_0.gguf
curl.exe -fL -o .\models\MiniCPM-OCR-1.0-gguf\mmproj-model-f16-4x.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/main/mmproj-model-f16-4x.gguf
curl.exe -fL -o .\models\MiniCPM-OCR-1.0-gguf\dspark-MiniCPM-OCR-1_0-Q8_0.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-DSpark-gguf/resolve/main/dspark-MiniCPM-OCR-1_0-Q8_0.gguf
@('FROM ./MiniCPM-OCR-1_0-Q8_0.gguf','FROM ./mmproj-model-f16-4x.gguf','DRAFT ./dspark-MiniCPM-OCR-1_0-Q8_0.gguf','REQUIRES 0.40.12','PARAMETER num_ctx 8192','PARAMETER temperature 0','PARAMETER draft_num_predict 15') | Set-Content .\models\MiniCPM-OCR-1.0-gguf\Modelfile
ollama create minicpm-ocr -f .\models\MiniCPM-OCR-1.0-gguf\Modelfile
$env:OLLAMA_HOST='127.0.0.1:18499'; ollama serve

Write-Host ''
$url = 'http://127.0.0.1:18499'
Write-Host "等待服务启动：$url"
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
  try {
    Invoke-WebRequest -UseBasicParsing -Uri $url -TimeoutSec 3 | Out-Null
    $ready = $true
    break
  } catch {
    Start-Sleep -Seconds 2
  }
}
if (-not $ready) { throw "60 秒内未探测到 $url，请手动打开确认或查看日志" }
Write-Host '服务已就绪'
Write-Host '部署完成，浏览器访问 http://127.0.0.1:18499'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md'
