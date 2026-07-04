# Claude Desktop macOS 中文汉化技术文档

> 本文档详细记录了汉化 Claude Desktop macOS 版的完整过程、技术原理和所有注意事项。
> 目标读者：其他 Claude（AI助手）或有技术背景的开发者。

---

## 一、背景

Claude Desktop 是 Anthropic 公司的 macOS 桌面客户端，基于 Electron 构建。
官方支持 11 种语言（英语、德语、法语、日语、韩语等），**但不支持中文**。
本文档记录了如何完整汉化该应用。

---

## 二、应用架构分析

### 2.1 安装位置

```
/Applications/Claude.app/Contents/
├── Resources/                    # 资源目录（重点）
│   ├── en-US.json                # Layer B: Electron 主进程翻译
│   ├── ja-JP.json                # 日文翻译（参考模板）
│   ├── ko-KR.json                # 韩文翻译
│   ├── zh_CN.lproj/             # macOS 原生层（空目录，无文件）
│   ├── app.asar                  # 主进程代码（37MB，含 locale 映射逻辑）
│   └── ion-dist/
│       └── i18n/
│           ├── en-US.json        # Layer C: Web 渲染器翻译（18,000+ 条）
│           ├── ja-JP.json        # 日文翻译（参考模板）
│           ├── ja-JP.overrides.json
│           └── dynamic/
│               └── en-US.json    # Layer C: 动态内容（模型描述等）
├── MacOS/
│   └── Claude                    # 主进程二进制
└── Info.plist
```

### 2.2 三层本地化架构

| 层级 | 位置 | 内容 | 字符串数 | 重要性 |
|------|------|------|---------|-------|
| A - macOS 原生层 | `zh_CN.lproj/Localizable.strings` | 快捷入口、截屏、辅助功能弹窗 | ~50 | 低 |
| B - Electron 主进程 | `Resources/zh-CN.json` | 菜单栏、系统对话框、设置 | ~435 | 中 |
| C - Web 渲染器 | `ion-dist/i18n/zh-CN.json` | 主聊天界面、所有 React UI | ~18,000 | 高 |

### 2.3 Locale 映射机制

在 `app.asar` 中找到的映射表：

```javascript
// locale 映射函数（从 app.asar 反编译）
const localeMap = {
  "zh-cn": "zh",
  "zh-hans": "zh",
  "zh-tw": "zh-TW",
  "zh-hant": "zh-TW",
  "zh-hk": "zh-HK",
  "en": "en",
  "en-us": "en-US",
  "ja": "ja",
  "ja-jp": "ja-JP",
  // ... 其他语言
};
```

关键逻辑：
1. 系统语言 `zh-Hans-CN` → 映射为 `zh`
2. `Mii()` 函数扫描 `Resources/` 下符合 `/[a-z]{2}-[A-Z]{2}/` 正则的 JSON 文件
3. 生成可用 locale 列表：`{"zh-CN": true, "en-US": true, ...}`
4. `Nii()` 函数精确匹配 `zh-CN` → 加载 `zh-CN.json`

### 2.4 前端语言列表（硬编码）

在 `ion-dist/assets/v1/c4b350ac1-BTR_0NaM.js` 中：

```javascript
// 原始代码
S1 = ["en-US","de-DE","fr-FR","ko-KR","ja-JP","es-419","es-ES","it-IT","hi-IN","pt-BR","id-ID"];

// 需要修改为
S1 = ["en-US","de-DE","fr-FR","ko-KR","ja-JP","es-419","es-ES","it-IT","hi-IN","pt-BR","id-ID","zh-CN"];
```

在 `ion-dist/assets/v1/c5bfbf000-DfhVshYa.js` 中的 switch 语句：

```javascript
// 原始代码
case"id-ID":return["language","id"]

// 需要修改为
case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]
```

还有 locale 映射表：

```javascript
// 原始代码
"id-ID":"id"

// 需要修改为
"id-ID":"id","zh-CN":"zh_CN"
```

> **注意：** JS 文件名中的哈希值（如 `c4b350ac1-BTR_0NaM.js`）会随 Claude 版本更新而变化。
> 需要通过 `grep -rl '"id-ID"' /Applications/Claude.app/Contents/Resources/ion-dist/assets/` 动态查找。

---

## 三、汉化步骤

### 步骤 1：准备翻译文件

需要创建以下翻译文件：

| 文件 | 格式 | 内容 |
|------|------|------|
| `zh-CN.json` (Layer B) | JSON `{"hashKey": "翻译文本"}` | ~435 条，菜单和系统对话框 |
| `zh-CN.json` (Layer C) | JSON `{"hashKey": "翻译文本"}` | ~18,000 条，主聊天界面 |
| `dynamic/zh-CN.json` | JSON `{"hashKey": "翻译文本"}` | ~46 条，模型描述 |
| `Localizable.strings` (Layer A) | Apple strings 格式 | ~50 条，原生 UI |

**翻译文件格式示例：**

```json
{
  "075Zq8hhWT": "取消",
  "1Gc0Drz87C": "打开",
  "dKX0bpR+a2": "退出",
  "4KjH9o80Fc": "正在检查更新...",
  "sS5kY5l/lE": "忽略",
  "S3MXlbjkax": "今天我能帮你做什么？",
  "{count, plural, one {# 个会话} other {# 个会话}}": "{count, plural, one {# 个会话} other {# 个会话}}"
}
```

**翻译规则：**
1. 保持所有 JSON key 不变，只翻译 value
2. 保持格式参数不变：`{name}`, `{count}`, `{error}`, `{pct}`
3. 保持 HTML 标签不变：`<link>`, `<b>`, `<a>`, `<learnMoreLink>`
4. 保持 ICU MessageFormat 语法不变：`{count, plural, one {...} other {...}}`
5. 技术术语保留英文：MCP, Claude, Cowork, Slack, GitHub, API, SSO, SCIM, OAuth, JWT, PR, CI/CD
6. 套餐名翻译：Free=免费版, Pro=Pro, Team=团队版, Enterprise=企业版

**参考文件：** 可以参考 `/Applications/Claude.app/Contents/Resources/ja-JP.json`（日文翻译）的格式和翻译风格。

### 步骤 2：关闭 Claude

```bash
pkill -9 -f "Claude"
sleep 2
```

### 步骤 3：确定操作方式

由于 macOS 的 SIP（系统完整性保护）会阻止修改 `/Applications/` 下的已签名应用，有两种方案：

**方案 A：不关 SIP，使用应用副本（推荐）**

不需要关闭 SIP，但每次 Claude 更新后需要重新操作。

```bash
# 复制 Claude.app 到用户目录（桌面、文档、任意位置均可）
cp -r /Applications/Claude.app ~/Documents/Claude.app

# 后续所有操作都针对 ~/Documents/Claude.app
APP_DIR="$HOME/Documents/Claude.app"
```

**方式 B：关闭 SIP，直接修改原应用（一劳永逸）**

关闭 SIP 后可直接修改 `/Applications/Claude.app`，Claude 更新后只需重新执行步骤 4-6。

1. 关机
2. 按住电源键进入恢复模式
3. 实用工具 → 终端 → 输入 `csrutil disable`
4. 重启后执行汉化

```bash
# 后续所有操作针对 /Applications/Claude.app
APP_DIR="/Applications/Claude.app"
```

> **判断方法：** 先尝试 `sudo cp test.txt /Applications/Claude.app/Contents/Resources/test.txt`，如果报 `Operation not permitted` 就用方案 A，否则用方案 B。

### 步骤 4：注入翻译文件

```bash
# 以方案 A 为例（APP_DIR=~/Documents/Claude.app），方案 B 同理替换路径

# Layer B: Electron 主进程
cp ~/claude-desktop-zh/patches/zh-CN-layer-b.json "$APP_DIR/Contents/Resources/zh-CN.json"
cp ~/claude-desktop-zh/patches/zh-CN-layer-b.json "$APP_DIR/Contents/Resources/zh.json"

# Layer C: Web 渲染器
mkdir -p "$APP_DIR/Contents/Resources/ion-dist/i18n"
cp ~/claude-desktop-zh/patches/zh-CN-layer-c.json "$APP_DIR/Contents/Resources/ion-dist/i18n/zh-CN.json"

# Layer C: 动态内容
mkdir -p "$APP_DIR/Contents/Resources/ion-dist/i18n/dynamic"
cp ~/claude-desktop-zh/patches/zh-CN-layer-c-dynamic.json "$APP_DIR/Contents/Resources/ion-dist/i18n/dynamic/zh-CN.json"

# Layer A: macOS 原生层（可选）
mkdir -p "$APP_DIR/Contents/Resources/zh_CN.lproj"
cp ~/claude-desktop-zh/patches/zh_CN.lproj.strings "$APP_DIR/Contents/Resources/zh_CN.lproj/Localizable.strings"
```

> 注意：方案 A 使用 `cp`（不需要 sudo），方案 B 需要在前面加 `sudo`。

### 步骤 5：修补前端语言列表

```bash
# 查找包含语言列表的 JS 文件
JS_FILE=$(grep -rl '"id-ID"' "$APP_DIR/Contents/Resources/ion-dist/assets/"*.js | head -1)

# 添加 zh-CN 到语言列表
sed -i '' 's/"id-ID"/"id-ID","zh-CN"/' "$JS_FILE"

# 添加 switch case
sed -i '' 's/case"id-ID":return\["language","id"\]/case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]/' "$JS_FILE"

# 添加 locale 映射
sed -i '' 's/"id-ID":"id"/"id-ID":"id","zh-CN":"zh_CN"/' "$JS_FILE"
```

> 方案 B 需要在 sed 命令前加 `sudo`。

### 步骤 6：设置 locale

```bash
python3 -c "
import json, os
config_path = os.path.expanduser('~/Library/Application Support/Claude/config.json')
with open(config_path, 'r') as f:
    config = json.load(f)
config['locale'] = 'zh-CN'
with open(config_path, 'w') as f:
    json.dump(config, f, indent=4, ensure_ascii=False)
"
```

### 步骤 7：启动 Claude

```bash
# 方案 A：从文档目录启动
open ~/Documents/Claude.app

# 方案 B：正常启动
open -a "Claude"
```

在 Claude 设置 → Language 中选择 **中文 (zh-CN)**。

---

## 四、macOS 安全限制说明

### 4.1 为什么 `sudo cp` 会失败？

macOS 有三层安全机制：

1. **Gatekeeper** — 验证应用签名
2. **TCC（透明度、同意和控制）** — 控制应用对文件系统的访问
3. **SIP（系统完整性保护）** — 保护系统文件不被修改，包括 `/Applications/` 下的已签名应用

即使使用 `sudo`，SIP 仍然会阻止对已签名 `.app` 包的修改。

### 4.2 如何解决？

| 方案 | 操作 | 风险 | 推荐 |
|------|------|------|------|
| 关闭 SIP | 恢复模式执行 `csrutil disable` | 低（可随时恢复） | ✅ |
| 用应用副本 | `cp -r` 到用户目录后修改 | 无 | ✅ |
| 给终端完全磁盘访问 | 系统设置 → 隐私与安全性 | 不够，SIP 仍阻止 | ❌ |

### 4.3 关闭/恢复 SIP

```bash
# 关闭 SIP（需要在恢复模式下运行）
csrutil disable
reboot

# 恢复 SIP（同样在恢复模式下）
csrutil enable
reboot
```

---

## 五、自动更新处理

Claude 的 Squirrel 更新器会整体替换 `.app` 包，清除所有汉化修改。

### 解决方案

1. 更新后重新执行步骤 4-7
2. 或使用应用副本方案（方案 B），但需要在每次更新后重新复制

### 更新后的文件名变化

JS 文件名中的哈希值会变（如 `c4b350ac1-BTR_0NaM.js` → 新名称），但文件内容中的语言列表格式不变，`grep -rl` 能自动找到新文件。

---

## 六、验证汉化是否成功

### 6.1 检查翻译文件

```bash
# 验证 JSON 格式
python3 -c "import json; json.load(open('/Applications/Claude.app/Contents/Resources/zh-CN.json')); print('✓ Layer B 有效')"
python3 -c "import json; json.load(open('/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json')); print('✓ Layer C 有效')"

# 检查翻译覆盖率
python3 -c "
import json
en = json.load(open('/Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json'))
zh = json.load(open('/Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json'))
print(f'覆盖率: {len(zh)}/{len(en)} = {len(zh)/len(en)*100:.0f}%')
"
```

### 6.2 检查语言列表

```bash
grep -o '"zh-CN"' /Applications/Claude.app/Contents/Resources/ion-dist/assets/v1/*.js | head -3
```

应该看到至少 2-3 处 `zh-CN` 引用。

### 6.3 检查 locale 设置

```bash
python3 -c "
import json
config = json.load(open('$HOME/Library/Application Support/Claude/config.json'))
print(f'locale: {config.get(\"locale\")}')
"
```

---

## 七、翻译文件生成方法

### 7.1 从英文源文件提取

```bash
# 提取英文翻译文件作为源
cp /Applications/Claude.app/Contents/Resources/en-US.json ./en-US-layer-b.json
cp /Applications/Claude.app/Contents/Resources/ion-dist/i18n/en-US.json ./en-US-layer-c.json
cp /Applications/Claude.app/Contents/Resources/ion-dist/i18n/dynamic/en-US.json ./en-US-dynamic.json
```

### 7.2 AI 翻译建议

- 将文件分成小批（每批 500 条）翻译，避免超时
- 用 `json.dump(merged, f, ensure_ascii=False, indent=2)` 输出确保格式正确
- 翻译后检查是否有未转义的双引号导致 JSON 解析失败
- 修复方法：将字符串内的 ASCII `"` 替换为 `「` 或 `\"`

### 7.3 质量检查

```bash
# 验证所有翻译文件的 JSON 格式
for f in zh-CN-layer-b.json zh-CN-layer-c.json; do
    python3 -c "import json; json.load(open('$f')); print('✓ $f')" 2>&1 || echo "✗ $f 有格式错误"
done
```

---

## 八、已知问题和限制

1. **仅支持 macOS** — Windows/Linux 的文件路径和打包方式不同
2. **自动更新覆盖** — 更新后需重新汉化
3. **SIP 限制** — 某些 Mac 需要关闭 SIP 才能修改应用
4. **JS 文件名变化** — 每次 Claude 更新，前端 JS 文件名中的哈希值会变
5. **代码签名破坏** — 修改后会触发 Gatekeeper 警告
6. **部分术语保留英文** — MCP, API 等技术术语不适合翻译

---

## 九、快速参考卡

```
# 汉化 Claude Desktop 完整流程

# 1. 关闭 Claude
pkill -9 -f "Claude"

# 2. 注入翻译（需要 sudo 或关闭 SIP）
sudo cp zh-CN-layer-b.json /Applications/Claude.app/Contents/Resources/zh-CN.json
sudo cp zh-CN-layer-b.json /Applications/Claude.app/Contents/Resources/zh.json
sudo mkdir -p /Applications/Claude.app/Contents/Resources/ion-dist/i18n/dynamic
sudo cp zh-CN-layer-c.json /Applications/Claude.app/Contents/Resources/ion-dist/i18n/zh-CN.json
sudo cp zh-CN-layer-c-dynamic.json /Applications/Claude.app/Contents/Resources/ion-dist/i18n/dynamic/zh-CN.json

# 3. 修补前端语言列表
JS_FILE=$(grep -rl '"id-ID"' /Applications/Claude.app/Contents/Resources/ion-dist/assets/*.js | head -1)
sudo sed -i '' 's/"id-ID"/"id-ID","zh-CN"/' "$JS_FILE"
sudo sed -i '' 's/case"id-ID":return\["language","id"\]/case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]/' "$JS_FILE"
sudo sed -i '' 's/"id-ID":"id"/"id-ID":"id","zh-CN":"zh_CN"/' "$JS_FILE"

# 4. 设置 locale
python3 -c "
import json, os
p = os.path.expanduser('~/Library/Application Support/Claude/config.json')
c = json.load(open(p)); c['locale'] = 'zh-CN'
json.dump(c, open(p,'w'), indent=4, ensure_ascii=False)
"

# 5. 重启 Claude
open -a "Claude"
```
