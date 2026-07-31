# Claude Desktop 简体中文语言包 — 架构说明

## 概述

本仓库是 Claude Desktop 的简体中文 (zh-CN) 翻译文件集合。Claude Desktop 在运行时会按 locale 加载对应的 i18n JSON 文件，本仓库的文件名、路径与原始文件保持一致，方便各平台工具直接复制使用。

## 文件层级

```
patches/
├── zh-CN-layer-b.json           # Layer B — Electron 主进程
├── zh-CN-layer-c.json           # Layer C — Web 渲染器（主聊天界面）
└── zh-CN-layer-c-dynamic.json   # Layer C Dynamic — 动态内容
```

| 层级 | 文件 | 内容 | 条目数 |
|------|------|------|--------|
| Layer B | `zh-CN-layer-b.json` | 菜单栏、应用菜单、剪贴板、快捷键、托盘菜单、原生对话框 | ~435 |
| Layer C | `zh-CN-layer-c.json` | 聊天界面、设置面板、连接器、扩展、Artifacts、Skills、Cowork UI | ~18,000 |
| Layer C Dynamic | `zh-CN-layer-c-dynamic.json` | 模型描述（Opus/Sonnet/Haiku 等）、功能提示 | ~46 |

> **注意**：macOS 原生层（`zh_CN.lproj/Localizable.strings`）已被本仓库移除 —— 该格式仅适用于 macOS 菜单栏快速输入等系统级 UI，且非 JSON 格式。本仓库聚焦跨平台通用的 JSON 翻译。

## 加载路径

Claude Desktop 加载 zh-CN 时的查找路径：

```
Resources/
  ├── zh-CN.json                    ← zh-CN-layer-b.json
  ├── zh.json                       ← zh-CN-layer-b.json 的别名
  └── ion-dist/
      └── i18n/
          ├── zh-CN.json            ← zh-CN-layer-c.json
          └── dynamic/
              └── zh-CN.json        ← zh-CN-layer-c-dynamic.json
```

实际将本仓库文件注入到 Claude Desktop 的步骤，因操作系统和安装方式而异，本仓库不维护具体脚本。

## JSON 格式规范

### 顶层结构

```json
{
  "hashKey1": "翻译文本 1",
  "hashKey2": "包含 {name} 的翻译",
  "hashKey3": "{count, plural, one {# 条} other {# 条}}"
}
```

### Key 生成规则

- key 是源英文字符串经过 `@formatjs/intl` 算法生成的稳定哈希
- 同一句话在所有 locale 文件中应共享同一个 key
- **绝对不能修改 key**，否则会回退为英文（或完全找不到）

### Value 必须保留的不变量

| 类型 | 例子 | 说明 |
|------|------|------|
| 简单占位符 | `{name}` `{count}` `{error}` `{pct}` | 与 React `useIntl` 的 `values` prop 对应 |
| 富文本标签 | `<link>...</link>` `<b>...</b>` `<a>...</a>` `<learnMoreLink>...</learnMoreLink>` | 通过 `values={{...}}` 的 ReactElement 注入 |
| ICU 复数 | `{count, plural, one {# item} other {# items}}` | 标准 ICU MessageFormat 语法 |
| ICU 选择 | `{gender, select, male {他} female {她} other {他/她}}` | 标准 ICU select 语法 |
| ICU 数字 | `{pct, number, percent}` | 数字格式化指令 |

### 不允许的操作

- ❌ 修改 key（哪怕只是大小写）
- ❌ 删除占位符或标签
- ❌ 把 `<link>` 改成 `[链接]`
- ❌ 把 ICU 语法拍平成简单字符串
- ❌ 用 `\n` 替换真实换行（JSON 中应保留 `\n` 转义符）
- ❌ 把中文转义成 `\uXXXX`（应保持 UTF-8 原字符，`ensure_ascii=False`）

## 提交流程

```bash
# 1. 校验 JSON 合法性
for f in patches/*.json; do
  python3 -m json.tool "$f" > /dev/null && echo "✓ $f"
done

# 2. 对比英文源文件提取新增 key（可选）
diff <(jq 'keys' patches/zh-CN-layer-c.json) <(jq 'keys' en-US.json)

# 3. 检查是否漏译 / 仍是英文
python3 -c "
import json, re
data = json.load(open('patches/zh-CN-layer-c.json'))
for k, v in data.items():
    if not re.search(r'[一-鿿]', v):
        print(f'未翻译或可疑: {k} = {v[:50]}')
"

# 4. 提交
git add patches/
git commit -m "i18n(zh-CN): improve xxx 翻译"
```

## 已知边界

- Claude Desktop 升级可能新增 key —— 需从新的 `en-US.json` 提取并补译
- 部分 UI 文案可能由前端硬编码（不在 i18n 文件中），本仓库无法覆盖
- 模型相关的英文专有名词（MCP、API、Artifacts、Cowork）按惯例保留
