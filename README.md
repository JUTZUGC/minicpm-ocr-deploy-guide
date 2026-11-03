# MiniCPM-OCR 一键部署指南

> 第三方部署指南 · 非 MiniCPM-OCR 官方仓库。官方项目：[OpenBMB/MiniCPM-OCR](https://github.com/OpenBMB/MiniCPM-OCR)
> 内容来自官方文档（2026-11-03）。项目迭代快，请以[官方文档](https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md)为准。

[![⚡ 一键部署](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E9%83%A8%E7%BD%B2-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键部署推荐用百度搭子)

## 一键部署（推荐：用百度搭子）

> [!TIP]
> 把一页扫描件变成可检索的 Markdown，比再买一个 OCR 套餐更实在。

⚠️ 走 Ollama 需要 0.40.12 或更高版本，三个 GGUF 合计约 2 GB。识别质量与速度取决于显卡，纯 CPU 会明显变慢。vLLM 路线只支持 Linux x86_64 + NVIDIA，编译约 40 分钟、磁盘预留 40 GB。Windows 可以用 Ollama 路线，但没有官方一键脚本。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/minicpm-ocr-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会下载三个 GGUF 模型、生成 Modelfile，再用 Ollama 建库并起本地服务，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Git；构建依赖以官方文档为准。）

4. **打开管理面板**
   浏览器访问 [http://127.0.0.1:18499](http://127.0.0.1:18499)，按官方引导完成初始化配置。

## MiniCPM-OCR 是什么？

MiniCPM-OCR 是开源的扫描件、弯曲页面、拍照文档都能转成 Markdown，还能给解析结果打分（协议：Apache-2.0，<img src="https://img.shields.io/github/stars/OpenBMB/MiniCPM-OCR?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

本地文档解析与 OCR：把中文、英文的 PDF 与图片转成 Markdown 或 JSON，覆盖表格、公式、图表与印章，并提供 Jev 模型给解析结果打 0–1 的质量分。

- SOTA 文档解析，覆盖扫描与拍照畸变
- 中文表格、公式与印章都能处理
- Jev 质量分，标出需要人工复核的区域
- Ollama / vLLM / SGLang / llama.cpp 多后端
- 提供 pip SDK 与 API
- Apache-2.0，可商用可微调

（来源：[官方仓库](https://github.com/OpenBMB/MiniCPM-OCR)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 773 stars | 名称搜索仅 9 条结果 |
| 中文文档解析能力强 | 表格公式都覆盖 |
| Ollama 路线跨平台 | 模型仅约 2 GB |
| 带 Jev 质量分 | 便于人工复核 |
| 推理后端选择多 | — |
| Apache-2.0 | 可商用可微调 |

| 需要注意 | 说明 |
|---|---|
| Ollama 版本要求较新 | — |
| 三个模型文件要分别下载 | — |
| 纯 CPU 速度慢 | — |
| vLLM 路线只支持 Linux + NVIDIA | — |
| 首次加载等待明显 | — |

> 以上基于官方文档与社区反馈整理（2026-11-03），以官方最新文档为准。

## 快速部署（官方方式）

```bash
git clone https://github.com/OpenBMB/MiniCPM-OCR.git
cd MiniCPM-OCR && mkdir -p ./models/MiniCPM-OCR-1.0-gguf
curl -fL -o ./models/MiniCPM-OCR-1.0-gguf/MiniCPM-OCR-1_0-Q8_0.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/main/MiniCPM-OCR-1_0-Q8_0.gguf
curl -fL -o ./models/MiniCPM-OCR-1.0-gguf/mmproj-model-f16-4x.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-gguf/resolve/main/mmproj-model-f16-4x.gguf
curl -fL -o ./models/MiniCPM-OCR-1.0-gguf/dspark-MiniCPM-OCR-1_0-Q8_0.gguf https://huggingface.co/openbmb/MiniCPM-OCR-1.0-DSpark-gguf/resolve/main/dspark-MiniCPM-OCR-1_0-Q8_0.gguf
printf 'FROM ./MiniCPM-OCR-1_0-Q8_0.gguf\nFROM ./mmproj-model-f16-4x.gguf\nDRAFT ./dspark-MiniCPM-OCR-1_0-Q8_0.gguf\nREQUIRES 0.40.12\nPARAMETER num_ctx 8192\nPARAMETER temperature 0\nPARAMETER draft_num_predict 15\n' > ./models/MiniCPM-OCR-1.0-gguf/Modelfile
ollama create minicpm-ocr -f ./models/MiniCPM-OCR-1.0-gguf/Modelfile
OLLAMA_HOST=127.0.0.1:18499 ollama serve
```

启动后浏览器访问 [http://127.0.0.1:18499](http://127.0.0.1:18499)（管理面板）。（来源：[https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md](https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md)）

## 验证状态

| 场景 | 状态 |
|---|---|
| README 确认 1.3B 模型、Ollama/vLLM/SGLang/llama.cpp 支持 | 已核对 2026-11-03 |
| Ollama 文档确认三个 GGUF 文件、Modelfile 与 18499 端口 | 已核对 2026-11-03 |
| 未实测下载模型与识别 | 说明 2026-11-03 |
| MCP 冒烟：initialize / tools/list 返回 get_guide、search_guide、get_project_info | 已验证 2026-11-03 |
| 非目标宿主调用 get_guide 被拦截（HOST_NOT_ALLOWED） | 已验证 2026-11-03 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

项目本身不含 MCP；本仓库的 MCP 只提供部署步骤、端口与常见问题。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-11-03）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\minicpm-ocr-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 先装 Ollama

Windows 与 macOS 从官网下载安装包；Linux 用安装脚本。版本必须 0.40.12 或更高。

## 三个文件缺一不可

| 文件 | 大小 | 作用 |
|---|---|---|
| `MiniCPM-OCR-1_0-Q8_0.gguf` | 约 0.81 GB | 主模型 |
| `mmproj-model-f16-4x.gguf` | 约 0.90 GB | 视觉投影，图片输入必需 |
| `dspark-MiniCPM-OCR-1_0-Q8_0.gguf` | 约 0.33 GB | DSpark 草稿，加速用 |

## 验证

```bash
ollama show minicpm-ocr
curl --noproxy 127.0.0.1 -f http://127.0.0.1:18499/api/tags
```

`api/tags` 里应出现 `minicpm-ocr:latest`。

## 其他后端

| 后端 | 说明 |
|---|---|
| vLLM | Linux x86_64 + NVIDIA，约 40 分钟编译 |
| SGLang | 见仓库对应文档 |
| llama.cpp | 轻量，适合低显存 |
| pip SDK | `pip install "minicpm-ocr[all]"` |

## 注意

- 下载走 Hugging Face，国内可用 ModelScope 镜像
- 首次推理才加载模型，第一页会慢
- 纯 CPU 能用但很慢
- Jev 是质量分模型，不是另一个 OCR
- 表格与公式输出建议人工抽查

## 常见坑

- `ollama create` 报错：确认三个文件在同一目录且文件名没改
- 识别不了图片：漏了 `mmproj` 视觉投影
- 服务端口不对：自定义实例用 18499，不是默认 11434
- 下载很慢：改用 ModelScope 的对应仓库
- 显存不足：换更小的量化档，或走 llama.cpp
- 结果缺表格：确认输入分辨率与页面方向
- 质量分很低：先用 Jev 标出区域，再人工复核

## 免责声明

本仓库为第三方指南，与 MiniCPM-OCR 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-11-03），项目迭代快，请以[官方文档](https://github.com/OpenBMB/MiniCPM-OCR/blob/main/docs/ollama_deploy.md)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
