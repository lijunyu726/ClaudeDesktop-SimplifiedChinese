# Claude Desktop 简体中文安装 Prompt

> 把本文件中的 **「安装 Prompt」** 整段复制粘贴到 Claude Code（或其他 AI 助手）的输入框，由 AI 自动完成汉化注入。

---

## 安装 Prompt

复制以下整段（包括 `请将...` 到 `###END###` 之间的所有内容），粘贴到 Claude Code：

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

---

## 使用说明

1. 复制 `请将...` 到 `###END###` 之间的整段内容（包括 markdown 围栏）
2. 在 Claude Code 中粘贴，按回车发送
3. AI 会按 7 步流程自动完成注入，期间会询问你确认 sudo 密码

## 卸载

如需恢复英文，参考 prompt 中的「回滚（卸载汉化）」章节手动执行，或删除 `~/.claude-locale/` 并恢复到 Claude 原始安装即可。

## 何时需要重新运行

- Claude Desktop 自动更新后（覆盖了 `.app`）
- 切换 macOS 用户后
- 切换电脑后
