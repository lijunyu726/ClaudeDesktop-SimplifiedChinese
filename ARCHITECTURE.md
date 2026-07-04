# Claude Desktop 中文汉化 - 技术架构

## 概述

Claude Desktop 是基于 Electron 构建的 macOS 应用。本项目通过注入翻译文件和修补前端代码实现中文汉化。

## 本地化架构

```
┌─────────────────────────────────────────────────────────┐
│                    Claude Desktop                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  Layer A     │  │  Layer B     │  │  Layer C      │  │
│  │  macOS 原生  │  │  Electron    │  │  Web 渲染器   │  │
│  │             │  │  主进程      │  │  (React SPA)  │  │
│  ├─────────────┤  ├──────────────┤  ├───────────────┤  │
│  │ .lproj/     │  │ Resources/   │  │ ion-dist/     │  │
│  │ Localizable │  │ zh-CN.json   │  │ i18n/         │  │
│  │ .strings    │  │ zh.json      │  │ zh-CN.json    │  │
│  │             │  │              │  │ dynamic/      │  │
│  ├─────────────┤  ├──────────────┤  ├───────────────┤  │
│  │ ~50 条      │  │ ~435 条      │  │ ~18,000 条    │  │
│  │ 快捷入口等  │  │ 菜单、对话框 │  │ 主聊天界面    │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │           Locale 检测与映射逻辑                    │   │
│  │                                                  │   │
│  │  系统语言 → 映射表 → 加载对应 .json 文件           │   │
│  │  zh-Hans-CN → "zh" → zh.json / zh-CN.json       │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │           前端语言列表 (需修补)                    │   │
│  │                                                  │   │
│  │  S1 = ["en-US","de-DE",...,"zh-CN"]              │   │
│  │  设置界面的 Language 下拉菜单                      │   │
│  └──────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Locale 解析流程

1. **Main 进程启动** → 加载 `config.json` 的 `locale` 字段
2. **系统语言检测** → `app.getPreferredSystemLanguages()` → `["zh-Hans-CN"]`
3. **映射** → `zh-hans` → `zh`（内部 ID）
4. **文件查找** → `Mii()` 扫描 `Resources/` 下的 `xx-XX.json` 文件
5. **精确匹配** → 系统 `zh-Hans-CN` → 匹配可用的 `zh-CN`
6. **加载** → `zh-CN.json` → 435 条 Electron 主进程翻译
7. **Renderer** → 通过 IPC 获取 `{messages, locale}` → 初始化 Web UI i18n
8. **Web i18n** → 从 `ion-dist/i18n/zh-CN.json` 加载 ~18,000 条翻译

## 翻译文件格式

```json
{
  "hashKey": "翻译后的文本",
  "paramKey": "包含 {name} 和 {count} 的文本",
  "htmlKey": "包含 <link>和<b>标签</link> 的文本",
  "pluralKey": "{count, plural, one {# 条} other {# 条}}"
}
```

- 使用 `@formatjs/intl` 的哈希键格式
- 键由英文源字符串通过 MD5/算法生成
- 值为翻译后的本地化文本

## 文件注入机制

```
install.sh
  ├── 检查 Claude.app 是否存在
  ├── 备份原始文件到 ~/.claude-locale/backup/
  ├── 注入翻译文件 (cp 命令)
  │   ├── zh-CN-layer-b.json → Resources/zh-CN.json
  │   ├── zh-CN-layer-b.json → Resources/zh.json (alias)
  │   ├── zh-CN-layer-c.json → ion-dist/i18n/zh-CN.json
  │   └── zh-CN-layer-c-dynamic.json → ion-dist/i18n/dynamic/zh-CN.json
  ├── 修补前端 JS bundle (sed 命令)
  │   ├── 添加 "zh-CN" 到语言列表数组
  │   ├── 添加 switch case 映射
  │   └── 添加 locale 映射表条目
  └── 设置 config.json locale 为 zh-CN
```

## 自动更新保护

Claude 的 Squirrel 更新器会整体替换 `.app` 包，清除所有修改。

维护策略：
- 保留 `~/.claude-locale/` 目录作为翻译文件的持久存储
- 更新后重新运行 `install.sh` 即可恢复
- launchd 守护进程可监控 Claude.app 变化并自动重注入

## 技术术语表

| 英文 | 中文 | 说明 |
|------|------|------|
| MCP | MCP (保留) | Model Context Protocol |
| Cowork | Cowork (保留) | Claude 协作功能 |
| Pro | Pro (保留) | Pro 套餐 |
| Team | 团队版 | Team 套餐 |
| Enterprise | 企业版 | Enterprise 套餐 |
| Free | 免费版 | Free 套餐 |
| extensions | 扩展 | Chrome 扩展 |
| connectors | 连接器 | 数据源连接 |
| artifacts | 制品 | 交互式页面 |
