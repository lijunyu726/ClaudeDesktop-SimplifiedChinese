#!/bin/bash
#
# Claude Desktop 中文汉化 - 卸载脚本
#

set -e

CLAUDE_APP="/Applications/Claude.app"
CLAUDE_R="$CLAUDE_APP/Contents/Resources"
BACKUP_DIR="$HOME/.claude-locale/backup"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[信息]${NC} $1"; }
ok()   { echo -e "${GREEN}[完成]${NC} $1"; }
err()  { echo -e "${RED}[错误]${NC} $1"; }

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Claude Desktop 中文汉化 - 卸载     ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 关闭 Claude
info "关闭 Claude..."
pkill -9 -f "Claude" 2>/dev/null || true
sleep 2

# 删除汉化文件
info "删除汉化文件..."
sudo rm -f "$CLAUDE_R/zh-CN.json"
sudo rm -f "$CLAUDE_R/zh.json"
sudo rm -f "$CLAUDE_R/ion-dist/i18n/zh-CN.json"
sudo rm -f "$CLAUDE_R/ion-dist/i18n/dynamic/zh-CN.json"
sudo rm -rf "$CLAUDE_R/zh_CN.lproj"
ok "汉化文件已删除"

# 恢复备份（如果有的话）
if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    info "恢复原始文件..."
    [ -f "$BACKUP_DIR/zh-CN.json" ] && sudo cp "$BACKUP_DIR/zh-CN.json" "$CLAUDE_R/zh-CN.json"
    [ -f "$BACKUP_DIR/ion-dist_i18n_zh-CN.json" ] && sudo cp "$BACKUP_DIR/ion-dist_i18n_zh-CN.json" "$CLAUDE_R/ion-dist/i18n/zh-CN.json"
    [ -f "$BACKUP_DIR/ion-dist_i18n_dynamic_zh-CN.json" ] && sudo cp "$BACKUP_DIR/ion-dist_i18n_dynamic_zh-CN.json" "$CLAUDE_R/ion-dist/i18n/dynamic/zh-CN.json"
    ok "原始文件已恢复"
else
    info "无备份文件，跳过恢复"
fi

# 删除汉化备份目录
rm -rf "$HOME/.claude-locale"

echo ""
ok "卸载完成！Claude 已恢复为英文界面"
echo ""
