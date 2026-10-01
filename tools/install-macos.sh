#!/usr/bin/env bash
# 基于官方 Claude.app 生成一份简体中文副本，官方应用本身不做任何修改。
#
# 用法：tools/install-macos.sh [官方应用路径] [中文副本路径]
#   默认：/Applications/Claude.app → ~/Applications/Claude-zh.app
#
# Claude Desktop 每次更新后重新运行一次即可。
set -euo pipefail

SRC="${1:-/Applications/Claude.app}"
DST="${2:-$HOME/Applications/Claude-zh.app}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKER="Contents/Resources/.claude-zh"

die() { echo "错误：$*" >&2; exit 1; }

# /usr/bin/python3 在未同意 Xcode 许可时无法运行，依次尝试可用的解释器
PY=""
for c in "${PYTHON:-}" python3 /opt/homebrew/bin/python3 /usr/local/bin/python3; do
  [ -n "$c" ] && "$c" -c 'import sys' >/dev/null 2>&1 && { PY="$c"; break; }
done
[ -n "$PY" ] || die "找不到可用的 python3，可用 PYTHON=/路径/python3 指定"

[ -d "$SRC/Contents/Resources/ion-dist" ] || die "找不到官方应用：$SRC"
# 先取进程列表再匹配：在 pipefail 下 grep -q 提前退出会让 ps 收到 SIGPIPE，导致检测失效
PROCS="$(ps -axo comm=)"
if grep -qF "$DST/Contents/MacOS/Claude" <<<"$PROCS"; then
  die "中文版正在运行，请先退出再安装"
fi
if [ -e "$DST" ]; then
  # 只覆盖本脚本生成过的副本，避免误删其他应用
  [ -f "$DST/$MARKER" ] || die "$DST 已存在且不是本脚本生成的，请换一个路径"
  rm -rf "$DST"
fi

mkdir -p "$(dirname "$DST")"
echo "复制 $SRC → $DST"
ditto "$SRC" "$DST"

RES="$DST/Contents/Resources"
cp "$ROOT/patches/zh-CN-layer-b.json" "$RES/zh-CN.json"
cp "$ROOT/patches/zh-CN-layer-c.json" "$RES/ion-dist/i18n/zh-CN.json"
cp "$ROOT/patches/zh-CN-layer-c-dynamic.json" "$RES/ion-dist/i18n/dynamic/zh-CN.json"
"$PY" "$ROOT/tools/patch_frontend.py" "$DST"

defaults read "$SRC/Contents/Info.plist" CFBundleShortVersionString > "$DST/$MARKER"

echo "重新签名（本机临时签名）"
codesign --force --deep --sign - "$DST"
codesign --verify --deep "$DST"

cat <<EOF

完成：$DST（基于 Claude $(cat "$DST/$MARKER")）

使用方法：
1. 完全退出官方 Claude（Cmd+Q）。两者共用同一份账号数据，不能同时运行。
2. 打开 $DST
3. 首次启动如果弹出钥匙串“Claude Safe Storage”访问请求，输入你的 Mac 登录密码并选“始终允许”。
4. 在 设置 → 语言 中选择“简体中文”。

说明：屏幕录制、辅助功能等系统权限需要为这个副本重新授权；副本不会自动更新，
官方应用更新后重新运行本脚本即可。
EOF
