# Claude Desktop 简体中文语言包

本仓库仅维护 Claude Desktop 的简体中文 (zh-CN) 翻译 JSON 文件。

## 项目定位

- **纯语言包**：只提供 JSON 翻译文件，不含任何安装/加载脚本。
- **跨平台**：不绑定特定操作系统；如何把 JSON 注入 Claude Desktop 由各平台工具自行处理。
- **格式**：遵循 Claude Desktop 内置的 `@formatjs/intl` 哈希键格式。

## 文件结构

```
claude-desktop-zh/
├── patches/
│   ├── zh-CN-layer-b.json            # Electron 主进程层（菜单、对话框）~435 条
│   ├── zh-CN-layer-c.json            # Web 渲染器层（主聊天界面）~18,000 条
│   └── zh-CN-layer-c-dynamic.json    # 动态内容层（模型描述等）~46 条
├── README.md
├── ARCHITECTURE.md
├── CONTRIBUTING.md
└── LICENSE
```

## 修改翻译的规则

1. **只改 value，不改 key** — key 是源字符串的哈希，改了就对不上英文。
2. **保留占位符** — `{name}` `{count}` `{error}` `{pct}` 等。
3. **保留 HTML 标签** — `<link>` `<b>` `<a>` `<learnMoreLink>`。
4. **保留 ICU 语法** — `{count, plural, one {...} other {...}}`。
5. **保持 UTF-8、ensure_ascii=False** — 写 JSON 时不要把中文转成 `\uXXXX`。

## 验证清单

修改任一 JSON 后，确认：

- 文件仍是合法 JSON（`python3 -m json.tool patches/zh-CN-layer-c.json > /dev/null`）
- key 数量与修改前一致
- 没有引号、逗号、括号错位
- 占位符和标签没有破坏

## 关键决策

- 不维护 install/uninstall 脚本 —— 不同平台的注入路径不同，集中脚本会误导用户。
- 仅保留跨平台通用的 JSON 翻译 —— macOS 原生层 (`.strings`) 已被移除。
- 翻译条目来自 Claude Desktop 实际运行时加载的 `en-US.json`，确保键对齐。

## 注意事项

- 不要提交原始 `en-US.json` 源文件（已在 .gitignore 中忽略）。
- 大文件（`zh-CN-layer-c.json` ~1.1MB）变更建议拆分子集 PR，避免 diff 不可读。
- 模型相关动态文案（`zh-CN-layer-c-dynamic.json`）随 Claude 版本变化较快，注意版本匹配。
