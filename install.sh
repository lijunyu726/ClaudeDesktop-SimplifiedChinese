#!/bin/bash
#
# Claude Desktop 中文汉化 - 一键安装脚本
# https://github.com/user/claude-desktop-zh
#
# 使用方法:
#   curl -fsSL https://raw.githubusercontent.com/user/claude-desktop-zh/main/install.sh | bash
#   或者下载后运行: bash install.sh
#

set -e

# ==================== 配置 ====================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/patches"
CLAUDE_APP="/Applications/Claude.app"
CLAUDE_R="$CLAUDE_APP/Contents/Resources"
CLAUDE_I18N="$CLAUDE_R/ion-dist/i18n"
CLAUDE_DYNAMIC="$CLAUDE_I18N/dynamic"
LOCALE_DIR="$HOME/.claude-locale"
BACKUP_DIR="$LOCALE_DIR/backup"
LOG_FILE="$LOCALE_DIR/install.log"

# 确保日志目录存在
mkdir -p "$LOCALE_DIR"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[信息]${NC} $1"; }
ok()    { echo -e "${GREEN}[完成]${NC} $1"; }
warn()  { echo -e "${YELLOW}[警告]${NC} $1"; }
err()   { echo -e "${RED}[错误]${NC} $1"; }

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null; }

# ==================== 检查 ====================
check_prerequisites() {
    info "检查环境..."

    # 检查 macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        err "此脚本仅支持 macOS"
        exit 1
    fi

    # 检查 Claude.app
    if [ ! -d "$CLAUDE_APP" ]; then
        err "未找到 Claude.app，请先安装 Claude 桌面版"
        err "下载地址: https://claude.ai/download"
        exit 1
    fi

    # 检查翻译文件
    local missing=0
    for f in "zh-CN-layer-b.json" "zh-CN-layer-c.json" "zh-CN-layer-c-dynamic.json"; do
        if [ ! -f "$PATCHES_DIR/$f" ]; then
            err "缺少翻译文件: $f"
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        err "翻译文件不完整，请重新下载项目"
        exit 1
    fi

    # 预验证 sudo 权限
    info "需要管理员权限来修改 Claude.app"
    sudo -v 2>/dev/null || { err "需要管理员权限，请重新运行并输入密码"; exit 1; }

    ok "环境检查通过"
}

# ==================== 备份 ====================
backup_originals() {
    info "备份原始文件..."
    mkdir -p "$BACKUP_DIR"

    local files_to_backup=(
        "$CLAUDE_R/zh-CN.json"
        "$CLAUDE_R/ion-dist/i18n/zh-CN.json"
        "$CLAUDE_R/ion-dist/i18n/dynamic/zh-CN.json"
        "$CLAUDE_R/zh_CN.lproj/Localizable.strings"
    )

    for f in "${files_to_backup[@]}"; do
        if [ -f "$f" ]; then
            local backup_name=$(echo "$f" | sed "s|$CLAUDE_R/||" | tr '/' '_')
            cp "$f" "$BACKUP_DIR/$backup_name" 2>/dev/null || true
        fi
    done

    ok "原始文件已备份到 $BACKUP_DIR"
}

# ==================== 注入翻译 ====================
inject_translations() {
    info "注入中文翻译文件..."

    # Layer B: Electron 主进程 (菜单、对话框)
    sudo cp "$PATCHES_DIR/zh-CN-layer-b.json" "$CLAUDE_R/zh-CN.json"
    sudo cp "$PATCHES_DIR/zh-CN-layer-b.json" "$CLAUDE_R/zh.json"  # alias for locale mapping
    ok "Layer B (Electron 主进程) - $(python3 -c "import json; print(len(json.load(open('$PATCHES_DIR/zh-CN-layer-b.json'))))" 2>/dev/null || echo "?") 条翻译"

    # Layer C: Web 渲染器主文件 (主聊天界面)
    sudo mkdir -p "$CLAUDE_I18N"
    sudo cp "$PATCHES_DIR/zh-CN-layer-c.json" "$CLAUDE_I18N/zh-CN.json"
    ok "Layer C (Web 渲染器) - $(python3 -c "import json; print(len(json.load(open('$PATCHES_DIR/zh-CN-layer-c.json'))))" 2>/dev/null || echo "?") 条翻译"

    # Layer C: 动态文件 (模型描述)
    sudo mkdir -p "$CLAUDE_DYNAMIC"
    sudo cp "$PATCHES_DIR/zh-CN-layer-c-dynamic.json" "$CLAUDE_DYNAMIC/zh-CN.json"
    ok "Layer C Dynamic (动态内容) - $(python3 -c "import json; print(len(json.load(open('$PATCHES_DIR/zh-CN-layer-c-dynamic.json'))))" 2>/dev/null || echo "?") 条翻译"

    # Layer A: macOS 原生层
    if [ -f "$PATCHES_DIR/zh_CN.lproj.strings" ]; then
        sudo mkdir -p "$CLAUDE_R/zh_CN.lproj"
        sudo cp "$PATCHES_DIR/zh_CN.lproj.strings" "$CLAUDE_R/zh_CN.lproj/Localizable.strings"
        ok "Layer A (macOS 原生层)"
    fi
}

# ==================== 修改前端语言列表 ====================
patch_frontend() {
    info "修补前端语言列表..."

    # 查找包含语言列表的 JS 文件
    local js_files=$(find "$CLAUDE_R/ion-dist/assets/" -name "*.js" -type f 2>/dev/null)

    local patched=0
    for js_file in $js_files; do
        # 检查是否包含语言列表
        if grep -q '"id-ID"' "$js_file" 2>/dev/null && ! grep -q '"zh-CN"' "$js_file" 2>/dev/null; then
            # 添加 zh-CN 到语言列表
            sudo sed -i '' 's/"id-ID"/"id-ID","zh-CN"/' "$js_file" 2>/dev/null && patched=1

            # 添加 switch case
            sudo sed -i '' 's/case"id-ID":return\["language","id"\]/case"id-ID":return["language","id"];case"zh-CN":return["language","zh"]/' "$js_file" 2>/dev/null

            # 添加 locale 映射
            sudo sed -i '' 's/"id-ID":"id"/"id-ID":"id","zh-CN":"zh_CN"/' "$js_file" 2>/dev/null

            ok "已修补: $(basename "$js_file")"
            break
        fi
    done

    if [ $patched -eq 0 ]; then
        warn "未找到需要修补的前端文件（可能已修补过或版本不同）"
    fi
}

# ==================== 设置 locale ====================
set_locale() {
    info "设置 locale 为 zh-CN..."
    local config_file="$HOME/Library/Application Support/Claude/config.json"

    if [ -f "$config_file" ]; then
        python3 -c "
import json
with open('$config_file', 'r') as f:
    config = json.load(f)
config['locale'] = 'zh-CN'
with open('$config_file', 'w') as f:
    json.dump(config, f, indent=4, ensure_ascii=False)
" 2>/dev/null && ok "locale 已设置为 zh-CN" || warn "无法修改 config.json"
    else
        warn "config.json 不存在，跳过"
    fi
}

# ==================== 重启 Claude ====================
restart_claude() {
    info "重启 Claude..."
    if pgrep -x "Claude" > /dev/null 2>&1; then
        pkill -9 -f "Claude" 2>/dev/null || osascript -e 'quit app "Claude"' 2>/dev/null
        sleep 2
    fi
    open -a "Claude"
    ok "Claude 已重启"
}

# ==================== 主流程 ====================
main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║   Claude Desktop 中文汉化 安装程序   ║"
    echo "╚══════════════════════════════════════╝"
    echo ""

    log "=== 开始安装 ==="

    check_prerequisites
    backup_originals
    inject_translations
    patch_frontend
    set_locale

    echo ""
    info "请在 Claude 中操作："
    echo "  1. 打开 Claude"
    echo "  2. 进入 设置 (Settings)"
    echo "  3. 在 Language 中选择 中文 (zh-CN)"
    echo "  4. 重启 Claude 即可看到中文界面"
    echo ""

    read -p "是否现在重启 Claude？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_claude
    fi

    echo ""
    ok "安装完成！"
    log "=== 安装完成 ==="
    echo ""
    echo "如需卸载，运行: bash $SCRIPT_DIR/uninstall.sh"
    echo ""
}

main "$@"
