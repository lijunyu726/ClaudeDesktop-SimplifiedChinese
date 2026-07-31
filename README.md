<div align="center">

# Claude Desktop 简体中文语言包

### 让 Claude Desktop 说中文 —— 完整 18,500 条界面翻译

> 把 Claude Desktop 的英文界面完整汉化为简体中文的**纯语言包**项目。
> 仓库只包含 JSON 翻译文件，不绑定任何操作系统，不提供安装脚本。

---

![coverage](https://img.shields.io/badge/翻译覆盖-100%25-brightgreen?style=flat-square)
![locale](https://img.shields.io/badge/locale-zh--CN-blue?style=flat-square)
![format](https://img.shields.io/badge/格式-JSON-lightgrey?style=flat-square)
![license](https://img.shields.io/badge/许可-MIT-yellow?style=flat-square)
![platform](https://img.shields.io/badge/支持-macOS%20%7C%20Windows%20%7C%20Linux-lightgrey?style=flat-square)

[📦 查看文件](#-包含的文件) · [🚀 使用方式](#-使用方式) · [📐 格式规范](#-json-格式规范) · [🤝 贡献翻译](#-贡献翻译) · [📄 许可证](#-许可证)

[💡 查看 AI 一键安装 Prompt →](INSTALL_PROMPT.md)

</div>

---

## ✨ 这是什么

本仓库提供 **Claude Desktop** 桌面端的简体中文 (`zh-CN`) 翻译文件，覆盖从菜单栏到主聊天界面、从设置面板到动态模型描述的**全部用户可见文案**。

仓库的核心承诺：

- ✅ **纯翻译文件** —— 仅 3 个 JSON，无 `install.sh`、无 Python、无依赖
- ✅ **跨平台** —— 文件路径与 Claude Desktop 的 i18n 加载机制一致，适用于 macOS / Windows / Linux
- ✅ **可审计** —— 所有 JSON 都是 UTF-8 明文，可逐条对照英文源校对
- ✅ **可复用** —— 不绑死任何加载工具，你可以写自己的脚本，或用现成的第三方注入工具

---

## 📦 包含的文件

```
patches/
├── zh-CN-layer-b.json            →  Layer B — Electron 主进程（菜单、对话框）
├── zh-CN-layer-c.json            →  Layer C — Web 渲染器（主聊天界面）
└── zh-CN-layer-c-dynamic.json    →  Layer C Dynamic（模型描述等动态内容）
```

| 文件 | 层级 | 条目数 | 涵盖内容 |
|:-----|:-----|------:|:---------|
| `patches/zh-CN-layer-b.json` | Electron 主进程 | **435** | 应用菜单、剪贴板、托盘菜单、快捷键、系统对话框 |
| `patches/zh-CN-layer-c.json` | Web 渲染器 | **18,000+** | 聊天界面、设置、连接器、扩展、Artifacts、Skills、Cowork UI |
| `patches/zh-CN-layer-c-dynamic.json` | Dynamic | **46** | Opus / Sonnet / Haiku 等模型描述、功能提示 |
| | **合计** | **≈ 18,500** | |

---

## 🚀 使用方式

### 1. 克隆仓库

```bash
git clone https://github.com/lijunyu726/ClaudeDesktop-SimplifiedChinese.git
cd ClaudeDesktop-SimplifiedChinese
```

### 2. 对应路径复制

将翻译文件复制到 Claude Desktop 安装目录的对应位置：

| 仓库文件 | → | Claude Desktop 加载路径 |
|:---------|:-:|:------------------------|
| `patches/zh-CN-layer-b.json` | → | `Resources/zh-CN.json` |
| `patches/zh-CN-layer-b.json` | → | `Resources/zh.json` （别名） |
| `patches/zh-CN-layer-c.json` | → | `Resources/ion-dist/i18n/zh-CN.json` |
| `patches/zh-CN-layer-c-dynamic.json` | → | `Resources/ion-dist/i18n/dynamic/zh-CN.json` |

### 3. 切换语言

重启 Claude Desktop，进入 **Settings → Language → 中文 (zh-CN)** 即可看到中文界面。

> ⚠️ **关于加载步骤**
> 不同操作系统的安装路径和包结构不同（例如 macOS 的 `.app`、Windows 的 `.exe` 目录），Claude 自动更新也会覆盖修改。
> 因此本仓库**不维护加载脚本**——你可以使用第三方注入工具，或自行根据上表路径复制。
>
> 💡 **推荐**：把 [INSTALL_PROMPT.md](INSTALL_PROMPT.md) 中的整段粘贴到 Claude Code，让 AI 自动完成跨平台注入、JS bundle 修补、locale 设置。

---

## 📐 JSON 格式规范

### 顶层结构

```json
{
  "hashKey1": "翻译后的中文文本",
  "hashKey2": "欢迎 {name}，{count} 条新消息",
  "hashKey3": "请阅读 <link>使用文档</link>",
  "hashKey4": "{count, plural, one {# 条消息} other {# 条消息}}"
}
```

### ⚠️ 必须保留的不变量

| 类型 | 例子 | 说明 |
|:-----|:------|:-----|
| **简单占位符** | `{name}`、`{count}`、`{error}`、`{pct}` | React `useIntl` 的 `values` prop |
| **富文本标签** | `<link>...</link>`、`<b>...</b>`、`<learnMoreLink>...</learnMoreLink>` | 通过 ReactElement 注入 |
| **ICU 复数** | `{count, plural, one {# item} other {# items}}` | 标准 ICU MessageFormat |
| **ICU 选择** | `{gender, select, male {他} female {她} other {他/她}}` | select 语法 |
| **ICU 数字** | `{pct, number, percent}` | 数字格式化指令 |

### 🚫 绝对禁止

```jsonc
// ❌ 改了 key（key 是源字符串的哈希，改了就失效）
"F12FA90": "设置"

// ❌ 把 <link> 标签改成 [链接]
"欢迎 [链接] 阅读文档"

// ❌ 把 ICU 复数语法拍平
"count_message": "{count} 条消息"

// ❌ 把中文转成 \uXXXX 转义符（应 ensure_ascii=False）
"+abcd": "设置"
```

完整规范见 [ARCHITECTURE.md](ARCHITECTURE.md)。

---

## 🤝 贡献翻译

发现翻译错误、某个文案有更好的译法、或新增 key 需要补译？欢迎贡献！

**快速上手：**

1. Fork 本仓库
2. 从 Claude Desktop 安装目录提取 `en-US.json` 作为对照源
3. 编辑 `patches/` 下对应的 JSON 文件
4. 按 README 顶部规范检查：不变量保留、占位符对齐、JSON 合法
5. 提交 Pull Request

**校对脚本**（在 [CONTRIBUTING.md](CONTRIBUTING.md) 完整版中提供）：

```bash
# 校验 JSON 合法性
for f in patches/*.json; do
  python3 -m json.tool "$f" > /dev/null && echo "✓ $f"
done
```

详见 [贡献指南](CONTRIBUTING.md) 和 [架构文档](ARCHITECTURE.md)。

---

## 🗂 仓库结构

```
claude-desktop-zh/
├── patches/                       # 翻译 JSON 文件（核心）
│   ├── zh-CN-layer-b.json
│   ├── zh-CN-layer-c.json
│   └── zh-CN-layer-c-dynamic.json
├── README.md                      # 本文件
├── CLAUDE.md                      # LLM 协作说明
├── ARCHITECTURE.md                # 翻译格式技术规范
├── CONTRIBUTING.md                # 翻译贡献指南
└── LICENSE                        # MIT 许可证
```

---

## 📋 已知边界

- Claude Desktop 升级可能新增 key —— 需从新版 `en-US.json` 提取并补译
- 部分 UI 文案可能由前端硬编码，不在 i18n 文件中
- 自动更新会覆盖已汉化的安装目录 —— 需重新注入

---

## 🔗 相关链接

- [Claude Desktop 下载](https://claude.ai/download)
- [Claude 官方文档](https://docs.anthropic.com)

---

## 📄 许可证

本项目以 [MIT License](LICENSE) 开源发布。

---

<div align="center">

<sub>⚠️ 本项目是非官方的社区翻译项目，与 Anthropic 无任何关联。翻译文件按原样提供，使用风险自负。</sub>

</div>
