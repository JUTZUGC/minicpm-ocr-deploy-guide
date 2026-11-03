#!/usr/bin/env bash
set -euo pipefail
# MiniCPM-OCR 一键部署脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md
# 更新日期：2026-11-03
# 类型：script
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v git >/dev/null 2>&1 || { echo "需要先安装 Git"; exit 1; }

mkdir -p .download
cd .download

git clone https://github.com/OpenBMB/MiniCPM-OCR.git
cd MiniCPM-OCR && mkdir -p ./models/MiniCPM-OCR-1.0-gguf
curl -fL -o ./models/MiniCPM-OCR-1.0-gguf/MiniCPM-OCR-1_0-Q8_0.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/main/MiniCPM-OCR-1_0-Q8_0.gguf
curl -fL -o ./models/MiniCPM-OCR-1.0-gguf/mmproj-model-f16-4x.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/main/mmproj-model-f16-4x.gguf
curl -fL -o ./models/MiniCPM-OCR-1.0-gguf/dspark-MiniCPM-OCR-1_0-Q8_0.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-DSpark-gguf/resolve/main/dspark-MiniCPM-OCR-1_0-Q8_0.gguf
printf 'FROM ./MiniCPM-OCR-1_0-Q8_0.gguf\nFROM ./mmproj-model-f16-4x.gguf\nDRAFT ./dspark-MiniCPM-OCR-1_0-Q8_0.gguf\nREQUIRES 0.40.12\nPARAMETER num_ctx 8192\nPARAMETER temperature 0\nPARAMETER draft_num_predict 15\n' > ./models/MiniCPM-OCR-1.0-gguf/Modelfile
ollama create minicpm-ocr -f ./models/MiniCPM-OCR-1.0-gguf/Modelfile
OLLAMA_HOST=127.0.0.1:18499 ollama serve

echo ""
if command -v curl >/dev/null 2>&1; then
  echo "等待服务启动：http://127.0.0.1:18499"
  ready=0
  for _ in $(seq 1 30); do
    if curl -sS -o /dev/null "http://127.0.0.1:18499" 2>/dev/null; then ready=1; break; fi
    sleep 2
  done
  if [ "$ready" = "1" ]; then
    echo "服务已就绪"
  else
    echo "警告：60 秒内未探测到 http://127.0.0.1:18499，请手动打开确认或查看日志"
    exit 1
  fi
else
  echo "未检测到 curl，跳过启动探测；请手动访问 http://127.0.0.1:18499 确认"
fi
echo "部署完成，浏览器访问 http://127.0.0.1:18499"
echo "若结果异常或需要改配置，请参考官方文档：https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md"
