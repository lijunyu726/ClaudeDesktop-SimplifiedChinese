# Claude Desktop 中文汉化

为 Claude 桌面版 (macOS) 提供完整的简体中文汉化支持。

![Claude Desktop 中文界面](https://img.shields.io/badge/coverage-100%25-brightgreen) ![macOS](https://img.shields.io/badge/platform-macOS-blue) ![Claude](https://img.shields.io/badge/Claude-1.17377-lightgrey)

## 📸 效果预览

汉化覆盖 Claude 桌面版的所有界面：

- ✅ 菜单栏（文件、编辑、视图、窗口、帮助）
- ✅ 设置界面（通用、隐私、能力、连接器等所有选项）
- ✅ 系统对话框（确认、取消、错误提示等）
- ✅ 主聊天界面（18,000+ 条翻译）
- ✅ 模型描述和功能说明

## 🧠 使用方式

本项目**不提供一键安装脚本**，而是提供翻译文件和技术文档，由你电脑上的 **Claude Code**（或其他 AI 助手）来完成汉化安装。

### 使用步骤

1. **克隆本仓库到你的电脑**

```bash
git clone https://github.com/lijunyu726/claude-desktop-zh-localization.git ~/claude-desktop-zh
```

2. **让 Claude Code 读取技术文档并执行汉化**

在 Claude Code 中输入：

> 请阅读 ~/claude-desktop-zh/docs/TECHNICAL_GUIDE.md，然后按照文档中的步骤对本机的 Claude Desktop 进行中文汉化。翻译文件在 ~/claude-desktop-zh/patches/ 目录下。

3. **Claude Code 会自动完成：**
   - 检测系统环境和安全权限
   - 注入翻译文件
   - 修补前端语言列表
   - 设置 locale
   - 重启 Claude

4. **在 Claude 设置中选择中文**

打开 Claude → Settings → Language → 中文 (zh-CN)

## 📦 项目结构

```
claude-desktop-zh/
├── patches/                          # 翻译补丁文件
│   ├── zh-CN-layer-b.json            # Electron 主进程翻译 (~435 条)
│   ├── zh-CN-layer-c.json            # Web 渲染器翻译 (~18,000 条)
│   ├── zh-CN-layer-c-dynamic.json    # 动态内容翻译 (~46 条)
│   └── zh_CN.lproj.strings           # macOS 原生层翻译 (~50 条)
├── docs/
│   └── TECHNICAL_GUIDE.md            # 完整汉化技术文档（供 AI 读取执行）
├── README.md                         # 本文件
├── ARCHITECTURE.md                   # 技术架构文档
├── CONTRIBUTING.md                   # 贡献指南
└── LICENSE                           # MIT 许可证
```

## 🔧 工作原理

Claude 桌面版是基于 Electron 的应用，本地化分为三层：

| 层级 | 文件 | 内容 | 字符串数 |
|------|------|------|---------|
| A - macOS 原生层 | `zh_CN.lproj/Localizable.strings` | 快捷入口、截屏弹窗 | ~50 |
| B - Electron 主进程 | `Resources/zh-CN.json` | 菜单栏、系统对话框 | ~435 |
| C - Web 渲染器 | `ion-dist/i18n/zh-CN.json` | 主聊天界面 | ~18,000 |

汉化需要：
1. 注入翻译 JSON 文件到各层
2. 修补前端 JS bundle，将 `zh-CN` 添加到支持的语言列表
3. 设置应用的 locale 为 `zh-CN`

完整技术细节请阅读 [技术文档](docs/TECHNICAL_GUIDE.md)。

## ⚠️ 已知限制

1. **仅支持 macOS** — Windows/Linux 的文件路径和打包方式不同
2. **自动更新覆盖** — Claude 更新后会清除汉化，需重新执行
3. **macOS 安全限制** — 部分 Mac 需要关闭 SIP（系统完整性保护）才能修改应用
4. **代码签名** — 修改应用文件后会触发 Gatekeeper 安全警告
5. **技术术语保留英文** — MCP, API 等专业术语不做翻译

## 🤝 贡献

欢迎翻译改进！请阅读 [贡献指南](CONTRIBUTING.md)。

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 🔗 相关链接

- [Claude 官方下载](https://claude.ai/download)
- [Claude 官方文档](https://docs.anthropic.com)

---

**免责声明：** 本项目是非官方的社区翻译项目，与 Anthropic 无关。
