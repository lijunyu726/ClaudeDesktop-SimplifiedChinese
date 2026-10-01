<div align="center">

# Claude Desktop 简体中文

**Claude Desktop 全部 33,034 条界面文案的简体中文翻译。**

![coverage](https://img.shields.io/badge/翻译覆盖-100%25-brightgreen?style=flat-square)
![version](https://img.shields.io/badge/适配版本-2.16120.0-blue?style=flat-square)
![status](https://img.shields.io/badge/主界面加载-暂不可用-orange?style=flat-square)
![license](https://img.shields.io/badge/许可-MIT-yellow?style=flat-square)

</div>

---

> [!WARNING]
> **当前状态：翻译文件已完整，但主界面暂时无法显示中文。**
>
> 在 2.16120.0 中，使用 Anthropic 账号登录时，Claude Desktop 的主界面（聊天、设置、语言选择等）直接从 `https://claude.ai` 在线加载，不读取应用内的本地前端和翻译文件。因此 `tools/install-macos.sh` 生成的副本**不会让主界面变成中文**，语言列表里也不会出现“简体中文”。
>
> 由本地主进程加载的菜单栏、托盘、系统对话框（742 条）不受此影响。让主界面加载中文的方案仍在评估中，进展会更新在这里。

## ✨ 特点

- **完整覆盖**：菜单、聊天、设置、Code 标签页、Cowork、连接器、技能、模型描述，与当前版本英文逐条对齐。
- **译文可靠**：每一条都经过占位符、ICU 复数/选择语法、标签结构的自动校验，避免界面显示错乱。
- **用语统一**：大陆简体用语，产品名和技术名词（Claude Code、MCP、Git、Pro、Max、Team 等）保留英文。

## 🚀 安装脚本（实验性）

> 受上方“当前状态”限制，脚本目前只对应用内置的本地前端生效，使用 Anthropic 账号登录时主界面仍是英文。

> 需要：macOS、已安装官方 Claude Desktop（位于 `/Applications/Claude.app`）、Python 3（可用 `PYTHON=/路径/python3` 指定）。

```bash
git clone https://github.com/lijunyu726/ClaudeDesktop-SimplifiedChinese.git
cd ClaudeDesktop-SimplifiedChinese
tools/install-macos.sh
```

脚本几秒钟就能完成，会生成 `~/Applications/Claude-zh.app`。然后：

1. **完全退出官方 Claude**（Cmd+Q）。
2. 打开 `~/Applications/Claude-zh.app`。
3. 如果弹出钥匙串“Claude Safe Storage”的访问请求，输入 Mac 登录密码并选择 **始终允许**。
4. 进入 **设置 → 语言**，选择 **简体中文**（仅在主界面由本地前端加载时可见，见页首“当前状态”）。

自定义路径：`tools/install-macos.sh <官方应用路径> <中文版路径>`。

### 卸载

删除 `~/Applications/Claude-zh.app`，重新打开官方 Claude 即可。账号、会话、设置都保留在原处。

## ❓ 常见问题

**为什么不能和官方 Claude 同时打开？**
两者共用同一份账号数据（会话、登录状态、设置），同一时间只能运行一个。在中文版里能看到并继续官方版里的所有会话。

**为什么会弹出钥匙串授权？**
中文版用的是本机临时签名，系统把它当成另一个应用，所以第一次读取 Claude 保存的登录凭据时需要你确认。

**屏幕录制、辅助功能等权限还要重新给吗？**
要。这些系统权限绑定在应用签名上，需要在“系统设置 → 隐私与安全性”里为中文版重新授权一次。

**中文版会自动更新吗？**
不会。官方应用更新后，重新运行一次 `tools/install-macos.sh` 即可，见下一节。

**为什么语言列表里没有“简体中文”？**
见页首“当前状态”：主界面从 claude.ai 在线加载，语言列表由网站决定，本地修改无法影响。

## 🔄 官方更新后

1. 拉取本仓库最新翻译：`git pull`
2. 重新生成中文版：`tools/install-macos.sh`

如果仓库还没适配你的新版本，新出现的文案会显示英文。欢迎按 [贡献指南](CONTRIBUTING.md#适配新版本) 补译，流程是：`build_patches.py extract` 提取缺失条目 → 翻译 → `icu_check.py` 校验 → `build_patches.py merge` 合并。

## 🖥 其他平台

Windows / Linux 暂无安装脚本。翻译文件与 Claude Desktop 资源目录的对应关系：

| 仓库文件 | 放到 Claude 的 `Resources/` 下 |
|:--|:--|
| `patches/zh-CN-layer-b.json` | `zh-CN.json` |
| `patches/zh-CN-layer-c.json` | `ion-dist/i18n/zh-CN.json` |
| `patches/zh-CN-layer-c-dynamic.json` | `ion-dist/i18n/dynamic/zh-CN.json` |

此外前端代码里写死了支持的语言列表，需要用 `tools/patch_frontend.py <应用目录>` 追加 zh-CN（脚本按 macOS 的 `.app` 目录结构查找文件，其他平台需调整路径）。原理见 [AGENTS.md](AGENTS.md#加载机制关键设计决策)。

## 📦 仓库内容

| 路径 | 说明 |
|:--|:--|
| `patches/zh-CN-layer-b.json` | 主进程：菜单、托盘、系统对话框（742 条） |
| `patches/zh-CN-layer-c.json` | 前端界面（32,243 条） |
| `patches/zh-CN-layer-c-dynamic.json` | 模型描述等动态文案（49 条） |
| `tools/install-macos.sh` | 生成中文版应用 |
| `tools/patch_frontend.py` | 让前端识别 zh-CN |
| `tools/build_patches.py` | 提取待译条目 / 合并翻译 |
| `tools/icu_check.py` | 校验译文结构 |
| `CONTRIBUTING.md` | 翻译规范与术语表 |
| `AGENTS.md` | 维护说明与设计决策 |

## 🤝 参与贡献

发现译得不好的地方，或想帮忙适配新版本，请看 [贡献指南](CONTRIBUTING.md)，也欢迎直接提 Issue，附上版本号、出现位置和建议译法。

## 📄 许可证

[MIT](LICENSE)

<sub>本项目是非官方社区翻译，与 Anthropic 无关。中文版应用由你在本机基于官方应用生成，使用风险自负。</sub>
