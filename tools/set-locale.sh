#!/usr/bin/env bash
# 设置 Claude Desktop 主进程（菜单栏、托盘、系统对话框）使用的语言。
#
# 用法：tools/set-locale.sh [locale]   默认 zh-CN；恢复英文用 en-US
#
# 需要先完全退出 Claude（官方版和中文版都要退出），否则退出时配置会被覆盖。
# 只有中文副本带 zh-CN.json；官方应用读到 zh-CN 时会自动回退到英文。
set -euo pipefail

LOCALE="${1:-zh-CN}"
CONFIG="${CLAUDE_CONFIG:-$HOME/Library/Application Support/Claude/config.json}"

die() { echo "错误：$*" >&2; exit 1; }

[ -f "$CONFIG" ] || die "找不到 $CONFIG"
# 先取进程列表再匹配：在 pipefail 下 grep -q 提前退出会让 ps 收到 SIGPIPE，导致检测失效
PROCS="$(ps -axo comm=)"
if grep -qE '/Contents/MacOS/Claude$' <<<"$PROCS"; then
  die "Claude 仍在运行，请先按 Cmd+Q 完全退出后再运行"
fi

PY=""
for c in "${PYTHON:-}" python3 /opt/homebrew/bin/python3 /usr/local/bin/python3; do
  [ -n "$c" ] && "$c" -c 'import sys' >/dev/null 2>&1 && { PY="$c"; break; }
done
[ -n "$PY" ] || die "找不到可用的 python3，可用 PYTHON=/路径/python3 指定"

BACKUP="$CONFIG.bak-$(date +%Y%m%d%H%M%S)"
cp "$CONFIG" "$BACKUP"

"$PY" - "$CONFIG" "$LOCALE" <<'EOF'
import json, sys
path, locale = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
old = data.get("locale")
data["locale"] = locale
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
print(f"locale：{old} → {locale}")
EOF

echo "已备份原配置：$BACKUP"
