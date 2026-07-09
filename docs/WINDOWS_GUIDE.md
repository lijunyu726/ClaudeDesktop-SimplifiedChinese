# Claude Desktop Windows 中文汉化技术文档

> 目标读者：另一台 Windows 电脑上的 Claude Code（AI 助手）。
> 请按本文档步骤为本机的 Claude Desktop 完成中文汉化。
> 翻译文件在用户的 `~/codes/claude-desktop-zh/patches/` 目录下（macOS），
> 需要从 GitHub 获取或由用户传输到本机。

---

## 一、准备工作

### 1.1 获取翻译文件

翻译文件是标准 JSON 格式，跨平台通用。文件位于 GitHub 仓库 `patches/` 目录：

- `zh-CN-layer-b.json` — Electron 主进程翻译 (~435 条)
- `zh-CN-layer-c.json` — Web 渲染器翻译 (~18,000 条)
- `zh-CN-layer-c-dynamic.json` — 动态内容翻译 (~46 条)

从 GitHub 获取：
```powershell
git clone --depth 1 https://github.com/lijunyu726/claude-desktop-zh-localization.git $env:TEMP\claude-zh
$PATCHES = "$env:TEMP\claude-zh\patches"
```

或如果用户已将翻译文件放在本机某目录下：
```powershell
$PATCHES = "用户提供的翻译文件目录路径"
```

### 1.2 查找 Claude Desktop 安装路径

```powershell
# 方法 1：搜索 claude.exe（排除 CLI 和第三方）
Get-ChildItem "$env:LOCALAPPDATA" -Filter "claude.exe" -Recurse -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch "claude-code|Claude-3p|node_modules" } |
  Select-Object FullName

# 方法 2：从注册表查找
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -like "*Claude*" } |
  Select-Object DisplayName, InstallLocation

# 方法 3：检查常见路径
@(
  "$env:LOCALAPPDATA\Claude",
  "$env:LOCALAPPDATA\Programs\Claude",
  "$env:LOCALAPPDATA\ClaudeDesktop",
  "$env:LOCALAPPDATA\Anthropic\Claude",
  "$env:PROGRAMFILES\Claude",
  "$env:LOCALAPPDATA\ClaudeZhCN\Claude"
) | ForEach-Object {
  if (Test-Path "$_\claude.exe") { Write-Output "找到: $_" }
}
```

**将找到的路径赋值给变量：**
```powershell
$CLAUDE_DIR = "找到的Claude安装目录路径"  # 例如 C:\Users\19697\AppData\Local\ClaudeZhCN\Claude
```

### 1.3 确认 i18n 目录存在

```powershell
$I18N = "$CLAUDE_DIR\resources\ion-dist\i18n"
$DYNAMIC = "$I18N\dynamic"

# 检查目录结构
Test-Path $I18N           # 应该为 True
Test-Path "$I18N\en-US.json"  # 应该为 True
Test-Path $DYNAMIC        # 应该为 True
```

如果 `ion-dist` 不在 `resources` 下，尝试：
```powershell
Get-ChildItem "$CLAUDE_DIR\resources" -Recurse -Filter "en-US.json" -ErrorAction SilentlyContinue
```

---

## 二、汉化步骤

### 步骤 1：关闭 Claude

```powershell
Stop-Process -Name "Claude" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
```

### 步骤 2：备份原始文件（可选）

```powershell
$BACKUP = "$env:USERPROFILE\ClaudeBackup"
New-Item -ItemType Directory -Path $BACKUP -Force -ErrorAction SilentlyContinue

# 备份可能存在的原版文件
if (Test-Path "$I18N\zh-CN.json") { Copy-Item "$I18N\zh-CN.json" "$BACKUP\" }
if (Test-Path "$CLAUDE_DIR\resources\zh-CN.json") { Copy-Item "$CLAUDE_DIR\resources\zh-CN.json" "$BACKUP\" }
```

### 步骤 3：注入翻译文件

```powershell
# Layer B: Electron 主进程（菜单栏、系统对话框）
Copy-Item "$PATCHES\zh-CN-layer-b.json" "$CLAUDE_DIR\resources\zh-CN.json" -Force
Copy-Item "$PATCHES\zh-CN-layer-b.json" "$CLAUDE_DIR\resources\zh.json" -Force

# Layer C: Web 渲染器（主聊天界面）
New-Item -ItemType Directory -Path $I18N -Force -ErrorAction SilentlyContinue
Copy-Item "$PATCHES\zh-CN-layer-c.json" "$I18N\zh-CN.json" -Force

# Layer C: 动态内容（模型描述）
New-Item -ItemType Directory -Path $DYNAMIC -Force -ErrorAction SilentlyContinue
Copy-Item "$PATCHES\zh-CN-layer-c-dynamic.json" "$DYNAMIC\zh-CN.json" -Force

Write-Host "✓ 翻译文件注入完成"
```

### 步骤 4：修补前端语言列表

```powershell
# 查找包含语言列表的 JS 文件
$JS_FILE = Get-ChildItem "$CLAUDE_DIR\resources\ion-dist\assets" -Filter "*.js" -Recurse |
  Where-Object { (Get-Content $_.FullName -Raw) -match '"id-ID"' -and (Get-Content $_.FullName -Raw) -notmatch '"zh-CN"' } |
  Select-Object -First 1 -ExpandProperty FullName

if ($JS_FILE) {
    Write-Host "找到需要修补的文件: $JS_FILE"

    # 读取内容
    $content = Get-Content $JS_FILE -Raw

    # 1. 添加 zh-CN 到语言列表
    $content = $content -replace '"id-ID"', '"id-ID","zh-CN"'

    # 2. 添加 switch case
    $content = $content -replace 'case"id-ID":return\["language","id"\]',
      'case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]'

    # 3. 添加 locale 映射
    $content = $content -replace '"id-ID":"id"', '"id-ID":"id","zh-CN":"zh_CN"'

    # 写回文件
    Set-Content -Path $JS_FILE -Value $content -NoNewline
    Write-Host "✓ 前端语言列表修补完成"
} else {
    Write-Host "⚠ 未找到需要修补的 JS 文件（可能已修补过或版本不同）"
}
```

### 步骤 5：设置 locale

```powershell
$configPath = "$env:APPDATA\Claude\config.json"

if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $config.locale = "zh-CN"
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -NoNewline
    Write-Host "✓ locale 已设置为 zh-CN"
} else {
    Write-Host "⚠ config.json 不存在于 $configPath"
    Write-Host "  尝试搜索..."
    Get-ChildItem "$env:APPDATA" -Filter "config.json" -Recurse -ErrorAction SilentlyContinue |
      Where-Object { $_.DirectoryName -match "Claude" } | Select-Object FullName
}
```

> **注意：** config.json 的位置可能因版本而异。可能在：
> - `$env:APPDATA\Claude\config.json`
> - `$env:LOCALAPPDATA\Claude\config.json`
> - `$CLAUDE_DIR\config.json`

### 步骤 6：启动 Claude

```powershell
Start-Process "$CLAUDE_DIR\claude.exe"
Write-Host "✓ Claude 已启动"
Write-Host "  请在设置 → Language 中选择 中文 (zh-CN)"
```

---

## 三、验证

```powershell
# 检查翻译文件是否注入成功
$files = @(
    "$CLAUDE_DIR\resources\zh-CN.json",
    "$CLAUDE_DIR\resources\zh.json",
    "$I18N\zh-CN.json",
    "$DYNAMIC\zh-CN.json"
)
foreach ($f in $files) {
    if (Test-Path $f) {
        $count = (Get-Content $f -Raw | ConvertFrom-Json).PSObject.Properties.Count
        Write-Host "✓ $(Split-Path $f -Leaf): $count 条"
    } else {
        Write-Host "✗ $(Split-Path $f -Leaf): 不存在"
    }
}

# 检查前端语言列表
$hasZhCN = Get-ChildItem "$CLAUDE_DIR\resources\ion-dist\assets" -Filter "*.js" -Recurse |
  Where-Object { (Get-Content $_.FullName -Raw) -match '"zh-CN"' }
if ($hasZhCN) { Write-Host "✓ 前端语言列表已包含 zh-CN" } else { Write-Host "✗ 前端语言列表缺少 zh-CN" }
```

---

## 四、Windows 特有问题

### 4.1 文件占用

如果 Claude 未完全退出，文件复制可能失败：
```powershell
# 确保 Claude 完全退出
Get-Process "Claude*" | Stop-Process -Force
Get-Process "*claude*" | Stop-Process -Force
Start-Sleep -Seconds 3
```

### 4.2 权限问题

如果遇到 "访问被拒绝"：
- 右键以管理员身份运行 PowerShell
- 或检查文件是否被只读锁定

### 4.3 路径中有空格或特殊字符

PowerShell 的变量路径如果有空格，需要加引号：
```powershell
Copy-Item "$PATCHES\zh-CN-layer-b.json" "$CLAUDE_DIR\resources\zh-CN.json"
# 注意双引号确保路径正确展开
```

### 4.4 编码问题

Windows 的 PowerShell 默认编码可能不同，读写 JSON 时指定 UTF-8：
```powershell
Get-Content $f -Raw -Encoding UTF8
Set-Content $path -Value $content -Encoding UTF8 -NoNewline
```

### 4.5 Windows Defender / 杀毒软件

修改应用文件可能触发杀毒软件警告，需要允许或添加白名单。

---

## 五、更新后重新汉化

Claude Desktop 更新后需要重新执行步骤 1-6。由于 Electron 应用更新会整体替换，所有修改都会被覆盖。

注意：更新后前端 JS 文件名可能变化，步骤 4 中的 `Get-ChildItem` 搜索会自动找到新文件。

---

## 六、快速参考（PowerShell 一键脚本）

将以下内容保存为 `install-claude-zh.ps1` 并以管理员身份运行：

```powershell
# 配置
$PATCHES = "翻译文件目录"  # 改为实际路径

# 查找 Claude
$CLAUDE_DIR = Get-ChildItem "$env:LOCALAPPDATA" -Filter "claude.exe" -Recurse -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch "claude-code|Claude-3p|node_modules" } |
  Select-Object -First 1 -ExpandProperty DirectoryName

if (-not $CLAUDE_DIR) { Write-Host "✗ 未找到 Claude Desktop"; exit 1 }
Write-Host "Claude 路径: $CLAUDE_DIR"

# 关闭 Claude
Stop-Process -Name "Claude" -Force -ErrorAction SilentlyContinue
Start-Sleep 2

# 注入翻译
$I18N = "$CLAUDE_DIR\resources\ion-dist\i18n"
Copy-Item "$PATCHES\zh-CN-layer-b.json" "$CLAUDE_DIR\resources\zh-CN.json" -Force
Copy-Item "$PATCHES\zh-CN-layer-b.json" "$CLAUDE_DIR\resources\zh.json" -Force
New-Item -ItemType Directory -Path "$I18N\dynamic" -Force -ErrorAction SilentlyContinue
Copy-Item "$PATCHES\zh-CN-layer-c.json" "$I18N\zh-CN.json" -Force
Copy-Item "$PATCHES\zh-CN-layer-c-dynamic.json" "$I18N\dynamic\zh-CN.json" -Force

# 修补前端
$JS = Get-ChildItem "$CLAUDE_DIR\resources\ion-dist\assets" -Filter "*.js" -Recurse |
  Where-Object { (Get-Content $_.FullName -Raw) -match '"id-ID"' -and (Get-Content $_.FullName -Raw) -notmatch '"zh-CN"' } |
  Select-Object -First 1 -ExpandProperty FullName
if ($JS) {
    $c = Get-Content $JS -Raw -Encoding UTF8
    $c = $c -replace '"id-ID"', '"id-ID","zh-CN"'
    $c = $c -replace 'case"id-ID":return\["language","id"\]', 'case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]'
    $c = $c -replace '"id-ID":"id"', '"id-ID":"id","zh-CN":"zh_CN"'
    Set-Content $JS -Value $c -Encoding UTF8 -NoNewline
}

# 设置 locale
$cfg = "$env:APPDATA\Claude\config.json"
if (Test-Path $cfg) {
    $j = Get-Content $cfg -Raw | ConvertFrom-Json
    $j.locale = "zh-CN"
    $j | ConvertTo-Json -Depth 10 | Set-Content $cfg -NoNewline
}

# 启动
Start-Process "$CLAUDE_DIR\claude.exe"
Write-Host "✓ 汉化完成！在设置 → Language 中选择中文"
```
