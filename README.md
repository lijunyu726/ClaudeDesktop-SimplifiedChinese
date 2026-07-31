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

[📦 查看文件](#-包含的文件) · [🚀 使用方式](#-使用方式) · [🤖 AI 安装 Prompt](#-ai-一键安装-prompt) · [📐 格式规范](#-json-格式规范) · [🤝 贡献翻译](#-贡献翻译) · [📄 许可证](#-许可证)

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
> 💡 **推荐**：把下方折叠框里的整段 Prompt 复制到 Claude Code，让 AI 自动完成跨平台注入、JS bundle 修补、locale 设置。

---

## 🤖 AI 一键安装 Prompt

<details>
<summary>📋 点击展开：跨平台 AI 安装 Prompt（macOS / Windows / Linux）</summary>

> **用法**：把下面 `请将...` 到 `###END###` 之间的整段内容（连同 markdown 围栏）复制粘贴到 Claude Code，AI 会按 7 步流程自动完成汉化注入。

````markdown
请将本机已安装的 Claude Desktop 桌面应用切换为简体中文界面。翻译文件位于当前目录的 `patches/` 子目录下（共 3 个 JSON）。

# 前置：先完整阅读本仓库
- `README.md` — 项目说明与 3 步上手流程
- `ARCHITECTURE.md` — i18n 技术架构、文件层级、JSON 规范

阅读完后再继续，不要凭直觉猜。

---

# 第 1 步：检测 Claude Desktop 安装位置

按操作系统分别处理：

## macOS
```
APP="/Applications/Claude.app"
RES="$APP/Contents/Resources"
```
如果 `/Applications/Claude.app` 不存在，则尝试 `~/Applications/Claude.app`。可用性检查：`[ -d "$APP" ] && echo found || echo missing`。

## Windows（PowerShell）
```powershell
$APP = "$env:LOCALAPPDATA\AnthropicClaude\Claude.exe"
$RES = (Get-Item $APP).DirectoryName + "\resources"
if (-not (Test-Path $APP)) {
  $APP = "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"
  $RES = (Get-Item $APP).DirectoryName + "\resources"
}
if (-not (Test-Path $RES)) {
  # 尝试找 Resources 目录
  $RES = (Get-ChildItem -Path (Get-Item $APP).DirectoryName -Recurse -Directory -Filter "resources" -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
```

## Linux
```bash
APP=$(find /opt /usr/local ~/.local -maxdepth 6 -type f \( -name "claude" -o -name "Claude" \) 2>/dev/null | head -1)
RES=$(dirname "$(dirname "$(readlink -f "$APP" 2>/dev/null)")")/resources
```

把检测到的 `$RES`（或 Windows 上的 `$RES`、macOS 上的 `RES`）记为 `RESOURCES`，后续步骤均使用此变量。

---

# 第 2 步：备份原始翻译文件（如果存在）

在 `~/.claude-locale/backup/` 下建立备份目录，仅备份**已存在**的原 zh-CN 相关文件：

## macOS / Linux
```bash
mkdir -p ~/.claude-locale/backup
for src in "$RESOURCES/zh-CN.json" "$RESOURCES/zh.json" "$RESOURCES/ion-dist/i18n/zh-CN.json" "$RESOURCES/ion-dist/i18n/dynamic/zh-CN.json"; do
  if [ -f "$src" ]; then
    name=$(echo "$src" | sed "s|$RESOURCES/||" | tr '/' '_')
    cp "$src" "$HOME/.claude-locale/backup/$name"
  fi
done
echo "备份完成 → $HOME/.claude-locale/backup/"
```

## Windows（PowerShell）
```powershell
$BackupDir = "$env:USERPROFILE\.claude-locale\backup"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
foreach ($src in @("$RESOURCES\zh-CN.json", "$RESOURCES\zh.json", "$RESOURCES\ion-dist\i18n\zh-CN.json", "$RESOURCES\ion-dist\i18n\dynamic\zh-CN.json")) {
  if (Test-Path $src) {
    $name = $src -replace [regex]::Escape($RESOURCES + '\'), '' -replace '\\','_'
    Copy-Item $src "$BackupDir\$name"
  }
}
```

---

# 第 3 步：注入翻译 JSON

## macOS / Linux
```bash
# Layer B：Electron 主进程
sudo cp patches/zh-CN-layer-b.json "$RESOURCES/zh-CN.json"
sudo cp patches/zh-CN-layer-b.json "$RESOURCES/zh.json"  # 别名

# Layer C：Web 渲染器
sudo mkdir -p "$RESOURCES/ion-dist/i18n"
sudo cp patches/zh-CN-layer-c.json "$RESOURCES/ion-dist/i18n/zh-CN.json"

# Layer C Dynamic：动态内容
sudo mkdir -p "$RESOURCES/ion-dist/i18n/dynamic"
sudo cp patches/zh-CN-layer-c-dynamic.json "$RESOURCES/ion-dist/i18n/dynamic/zh-CN.json"

echo "✓ 翻译 JSON 注入完成"
```

## Windows（PowerShell，需要管理员权限运行 PowerShell）
```powershell
# Layer B
Copy-Item -Force "patches\zh-CN-layer-b.json" "$RESOURCES\zh-CN.json"
Copy-Item -Force "patches\zh-CN-layer-b.json" "$RESOURCES\zh.json"

# Layer C
New-Item -ItemType Directory -Path "$RESOURCES\ion-dist\i18n" -Force | Out-Null
Copy-Item -Force "patches\zh-CN-layer-c.json" "$RESOURCES\ion-dist\i18n\zh-CN.json"

# Layer C Dynamic
New-Item -ItemType Directory -Path "$RESOURCES\ion-dist\i18n\dynamic" -Force | Out-Null
Copy-Item -Force "patches\zh-CN-layer-c-dynamic.json" "$RESOURCES\ion-dist\i18n\dynamic\zh-CN.json"
```

---

# 第 4 步：修补前端 JS bundle（关键！）

Claude Desktop 的 JS bundle 默认**不含 zh-CN**，必须修补语言列表。

## 通用模式
在 `$RESOURCES/ion-dist/assets/` 下找到所有 `.js` 文件，grep 出包含 `"id-ID"` 但不含 `"zh-CN"` 的：

### macOS / Linux
```bash
JS_FILE=$(grep -rl '"id-ID"' "$RESOURCES/ion-dist/assets/" 2>/dev/null | head -1)
if [ -z "$JS_FILE" ]; then
  echo "⚠️ 未找到 JS bundle，可能版本已修补或路径不同"
else
  # 1. 在语言列表数组中加入 zh-CN
  sudo sed -i 's/"id-ID"/"id-ID","zh-CN"/' "$JS_FILE"

  # 2. 在 switch case 中加入 zh-CN 映射
  sudo sed -i 's/case"id-ID":return\["language","id"\]/case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]/' "$JS_FILE"

  # 3. 在 locale 映射表加入 zh-CN → zh_CN
  sudo sed -i 's/"id-ID":"id"/"id-ID":"id","zh-CN":"zh_CN"/' "$JS_FILE"
  echo "✓ JS bundle 修补完成: $JS_FILE"
fi
```

### Windows（PowerShell）
```powershell
$js = Get-ChildItem -Path "$RESOURCES\ion-dist\assets\" -Recurse -Filter "*.js" -ErrorAction SilentlyContinue | Select-String -Pattern '"id-ID"' -List | Select-Object -First 1
if ($js) {
  $path = $js.Path
  $content = (Get-Content $path -Raw).Replace('"id-ID"', '"id-ID","zh-CN"')
  $content = $content.Replace('case"id-ID":return["language","id"]', 'case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]')
  $content = $content.Replace('"id-ID":"id"', '"id-ID":"id","zh-CN":"zh_CN"')
  Set-Content -Path $path -Value $content -Encoding UTF8 -Force
  Write-Host "✓ JS bundle 修补完成: $path"
} else {
  Write-Host "⚠️ 未找到 JS bundle，可能版本已修补或路径不同"
}
```

> **说明**：若 grep 不到匹配 `"id-ID"`，说明该版本已自带 zh-CN，跳过此步即可。

---

# 第 5 步：设置 locale（可选）

让 Claude 启动默认使用 zh-CN（用户在设置中可手动覆盖）：

## macOS
```bash
CONFIG="$HOME/Library/Application Support/Claude/config.json"
if [ -f "$CONFIG" ]; then
  python3 -c "
import json
with open(r'$CONFIG') as f: c = json.load(f)
c['locale'] = 'zh-CN'
json.dump(c, open(r'$CONFIG','w'), indent=4, ensure_ascii=False)
print('✓ locale 已设置为 zh-CN')
"
fi
```

## Windows
```powershell
$config = "$env:APPDATA\Claude\config.json"
if (Test-Path $config) {
  $c = Get-Content $config -Raw | ConvertFrom-Json
  $c.locale = "zh-CN"
  $c | ConvertTo-Json -Depth 10 | Set-Content $config -Encoding UTF8
}
```

> 若 `config.json` 不存在可跳过，用户在 Settings 中手动选择也可。

---

# 第 6 步：重启 Claude Desktop

## macOS
```bash
pkill -9 -f "Claude" 2>/dev/null; sleep 2
open -a "Claude"
```

## Windows
```powershell
Get-Process -Name "Claude" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process "$APP"
```

## Linux
```bash
pkill -9 -f "Claude" 2>/dev/null; sleep 2
nohup "$APP" >/dev/null 2>&1 &
```

---

# 第 7 步：引导用户切换语言

在 Claude Desktop 启动后，提示用户：

> 请进入 **Settings → Language → 中文 (zh-CN)**，然后重启 Claude 即可看到中文界面。

如果第 5 步已成功设置 locale，本步骤可以省略——Claude 会自动使用中文。

---

# 验证（必须执行）

按以下清单逐项验证：

| 验证项 | 通过标准 |
|:-------|:---------|
| 菜单栏 | 文件、编辑、视图、窗口、帮助 全部为中文 |
| 设置界面 | 通用、隐私、能力、连接器等所有选项中文 |
| 主聊天界面 | 输入框提示、按钮、空状态文案中文 |
| 模型描述 | Opus / Sonnet / Haiku 模型简介中文 |
| 错误提示 | "未连接到 claude.ai" 等系统提示中文 |
| 切换语言 | 能在 English ⇄ 中文 之间自由切换 |

---

# 常见问题处理

## 问题 1：sudo cp 报 `Operation not permitted`（macOS）
**原因**：SIP（系统完整性保护）阻止修改 `/Applications/` 下已签名应用。

**解决（方案 A：用副本）**：
```bash
cp -r /Applications/Claude.app ~/Documents/Claude.app
# 之后所有 $APP 改为 ~/Documents/Claude.app
open ~/Documents/Claude.app
```
之后从副本启动 Claude（双击 `~/Documents/Claude.app`）。

**解决（方案 B：关 SIP）**：重启进入恢复模式，运行 `csrutil disable`，重启后再注入。**不推荐**。

## 问题 2：JS bundle 文件名 hash 每次更新都变
**解决**：`grep -rl '"id-ID"' "$RESOURCES/ion-dist/assets/"` 会自动找到新文件名，无需手动跟踪。

## 问题 3：Claude 更新后丢失汉化
Claude 的自动更新会覆盖整个 `.app`，所有注入会丢失。

**应对**：重新执行本 Prompt 的第 3-6 步（无需重新备份）。

## 问题 4：报 "无法打开，因为开发者无法验证"（macOS Gatekeeper）
**原因**：修改后的 `.app` 未签名。

**解决**：右键点击 `~/Documents/Claude.app` → "打开方式" → "打开"。首次之后即可双击运行。

---

# 回滚（卸载汉化）

## macOS / Linux
```bash
BACKUP="$HOME/.claude-locale/backup"
[ -f "$BACKUP/zh-CN.json" ]          && sudo cp "$BACKUP/zh-CN.json"          "$RESOURCES/zh-CN.json"
[ -f "$BACKUP/zh.json" ]             && sudo cp "$BACKUP/zh.json"             "$RESOURCES/zh.json"
[ -f "$BACKUP/ion-dist_i18n_zh-CN.json" ] && sudo cp "$BACKUP/ion-dist_i18n_zh-CN.json" "$RESOURCES/ion-dist/i18n/zh-CN.json"
[ -f "$BACKUP/ion-dist_i18n_dynamic_zh-CN.json" ] && sudo cp "$BACKUP/ion-dist_i18n_dynamic_zh-CN.json" "$RESOURCES/ion-dist/i18n/dynamic/zh-CN.json"
echo "✓ 已从备份恢复原始状态"
```

## Windows
```powershell
$BackupDir = "$env:USERPROFILE\.claude-locale\backup"
foreach ($name in @("zh-CN.json", "zh.json", "ion-dist_i18n_zh-CN.json", "ion-dist_i18n_dynamic_zh-CN.json")) {
  $src = "$BackupDir\$name"
  if (Test-Path $src) {
    $dst = "$RESOURCES\$($name -replace '_', '\')"
    Copy-Item -Force $src $dst
  }
}
```

---

# 完成

执行完上述步骤后回报：
1. 操作系统与 Claude 版本
2. 检测到的 `RESOURCES` 路径
3. 第 3-6 步是否全部成功
4. 验证清单中哪几项通过 / 未通过
5. 任何异常情况

###END###
````

</details>

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
