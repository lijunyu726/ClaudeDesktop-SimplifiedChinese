# 贡献翻译指南

欢迎改进 Claude Desktop 简体中文翻译的质量！

## 工作流概览

```
1. 提取源 strings（从 Claude Desktop 安装目录取出 en-US.json）
2. 对比本仓库 zh-CN-*.json，找出缺失或可改进的 key
3. 编辑对应 JSON，遵守格式规则
4. 校验 JSON 合法性 + key 不变 + 占位符保留
5. 提交 PR
```

## 1. 准备源文件

从已安装的 Claude Desktop 中提取英文源 i18n 文件做对照：

```bash
# macOS 示例
cp /Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json ./en-US.json

# 不同平台路径不同，请按你所用系统调整
```

> ⚠️ `en-US.json` 已加入 `.gitignore`，请勿提交。

## 2. 翻译规则

### 必须保留

- **JSON 的 key** —— 哪怕翻译成完全不同的中文，key 也不能动
- **占位符**：`{name}`、`{count}`、`{error}`、`{pct}`、`{minutes}`、`{seconds}` 等
- **HTML/React 标签**：`<link>...</link>`、`<b>...</b>`、`<a>...</a>`、`<learnMoreLink>...</learnMoreLink>`
- **ICU MessageFormat 语法**：
  - 复数：`{count, plural, one {# item} other {# items}}`
  - 选择：`{gender, select, male {他} female {她} other {他/她}}`
  - 数字：`{pct, number, percent}`
  - 嵌套：`{n, plural, one {# minute} other {{n, plural, one {...} other {...}}}}`

### 推荐做法

- 中文标点使用全角：，。！？""''
- 保留英文专有名词：MCP、API、Artifacts、Cowork、Pro、Team、Enterprise
- 保持简洁，符合中文阅读习惯（避免生硬的直译）
- 一致性：同义词在整份文件中统一（"对话" / "聊天" 二选一）

### 反例

```json
// ❌ 错误：改了 key（这个 key 是源字符串的哈希）
"F12FA90": "设置"

// ✅ 正确：value 是中文，key 是源哈希
"f12fa90a...": "设置"
```

```json
// ❌ 错误：把 <link> 改成了 [链接]
"欢迎 [链接] 阅读文档"

// ✅ 正确：保留 <link> 标签
"欢迎 <link>阅读文档</link>"
```

```json
// ❌ 错误：拍平了 ICU 复数
"count_message": "{count} 条消息"

// ✅ 正确：保留 ICU 语法
"count_message": "{count, plural, other {# 条消息}}"
```

```json
// ❌ 错误：把中文转成 \uXXXX
"+abcd": "设置"

// ✅ 正确：保留 UTF-8 原字符
"+abcd": "设置"
```

## 3. 校对流程

### 校验 JSON 合法性

```bash
for f in patches/*.json; do
  python3 -m json.tool "$f" > /dev/null && echo "✓ $f"
done
```

### 检查未翻译的条目

```bash
python3 -c "
import json, re
for f in ['patches/zh-CN-layer-b.json', 'patches/zh-CN-layer-c.json']:
    data = json.load(open(f))
    misses = [(k, v) for k, v in data.items() if not re.search(r'[一-鿿]', v)]
    print(f'{f}: {len(misses)} 条未翻译 / 共 {len(data)} 条')
    if misses:
        for k, v in misses[:10]:
            print(f'  {k} = {v[:60]}')
"
```

### 占位符一致性检查

```bash
# 提取 en-US 和 zh-CN 的所有占位符，对比是否一致
python3 -c "
import json, re
en = json.load(open('en-US.json'))
zh = json.load(open('patches/zh-CN-layer-c.json'))
for k in en:
    if k in zh:
        en_ph = set(re.findall(r'\{\w+\}', en[k]))
        zh_ph = set(re.findall(r'\{\w+\}', zh[k]))
        if en_ph != zh_ph:
            print(f'占位符不一致: {k}')
"
```

## 4. 提交 PR

1. Fork 本仓库
2. 创建分支：`git checkout -b i18n/fix-xxx`
3. 修改翻译文件
4. 校验（见上文）
5. Commit：`git commit -m "i18n(zh-CN): 改进 xxx 的翻译"`
6. Push 并创建 Pull Request

### 报告问题

如果发现翻译错误或 key 缺失，请在 Issues 中报告，并附上：

- Claude Desktop 版本号
- 相关的英文原文（如果能从 `en-US.json` 找到）
- 建议的中文翻译
- 复现路径（在哪个菜单/界面看到）

## 5. 术语表

| 英文 | 中文 | 备注 |
|------|------|------|
| app | 应用 | 通用 |
| settings | 设置 | 通用 |
| chat / conversation | 对话 / 聊天 | 二选一，整份文件统一 |
| artifact | 制品 | Claude 生成的交互式页面 |
| connector | 连接器 | 数据源集成 |
| MCP | MCP | 保留英文缩写 |
| API | API | 保留英文缩写 |
| Pro | Pro | 套餐名保留 |
| Team | 团队版 | 套餐名 |
| Enterprise | 企业版 | 套餐名 |
| Free | 免费版 | 套餐名 |
| Cowork | Cowork | 协作功能保留 |
| Skills | 技能 | Claude 的技能系统 |
