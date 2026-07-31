# Claude Desktop 简体中文语言包

Claude Desktop 的简体中文 (zh-CN) 语言包，提供完整的界面翻译 JSON 文件。

> **本仓库仅提供翻译文件本身，不包含安装/卸载脚本。**
> 加载方式（如何把 JSON 注入到 Claude Desktop）由各平台、各版本的桌面端自行处理，本项目不绑定任何操作系统。

![coverage](https://img.shields.io/badge/coverage-100%25-brightgreen) ![locale](https://img.shields.io/badge/locale-zh--CN-blue) ![format](https://img.shields.io/badge/format-JSON-lightgrey)

## 📦 包含的翻译文件

| 文件 | 层级 | 条目数 | 说明 |
|------|------|--------|------|
| `patches/zh-CN-layer-b.json` | Layer B — Electron 主进程 | ~435 | 菜单栏、系统对话框、快捷键 |
| `patches/zh-CN-layer-c.json` | Layer C — Web 渲染器 | ~18,000 | 主聊天界面、设置、连接器、扩展等 |
| `patches/zh-CN-layer-c-dynamic.json` | Layer C Dynamic | ~46 | 模型描述、功能说明等动态内容 |

合计 **约 18,500 条**翻译条目。

## 🚀 使用方式

Claude Desktop 使用 `@formatjs/intl` 的哈希键格式，i18n 文件按以下路径加载：

```
zh-CN-layer-b.json          → Resources/zh-CN.json
zh-CN-layer-c.json          → ion-dist/i18n/zh-CN.json
zh-CN-layer-c-dynamic.json  → ion-dist/i18n/dynamic/zh-CN.json
```

在 Claude Desktop 中加载完成后，进入 **Settings → Language → 中文 (zh-CN)** 即可切换界面。

> ⚠️ **加载步骤因平台和版本而异** —— 不同操作系统（macOS / Windows / Linux）的安装位置和包结构不同，Claude Desktop 的自动更新也会覆盖修改。请参考你所用平台对应的工具或文档完成加载；本仓库不维护加载脚本。

## 📐 JSON 格式约定

```json
{
  "hashKey": "翻译后的文本",
  "paramKey": "包含 {name} 的文本",
  "htmlKey": "包含 <link>标签</link> 的文本",
  "pluralKey": "{count, plural, one {# 条} other {# 条}}"
}
```

- **键由源字符串哈希生成**，绝对不能修改，只能修改 value
- 占位符 `{name}` `{count}` `{error}` 等必须保留
- HTML 标签 `<link>` `<b>` `<a>` `<learnMoreLink>` 等必须保留
- ICU 复数语法 `{count, plural, ...}` 必须完整保留

详细规范见 [ARCHITECTURE.md](ARCHITECTURE.md)。

## 🤝 贡献翻译

欢迎改进翻译质量！请阅读 [贡献指南](CONTRIBUTING.md)。

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 🔗 相关链接

- [Claude Desktop 下载](https://claude.ai/download)
- [Claude 官方文档](https://docs.anthropic.com)

---

**免责声明：** 本项目是非官方的社区翻译项目，与 Anthropic 无关。翻译文件以原样提供，作者不对因使用本仓库内容导致的任何问题负责。
