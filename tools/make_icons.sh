#!/usr/bin/env bash
#
# The spawn menu's icons (addons/zz_mutants/icons/<id>.png): every monster whole, three-quarter view, idle, as
# Zombie Zone's own zombie view draws it (tools/render_icons.gd), transparent, 128 px. Deterministic: same seed,
# same pose, same camera. Needs a Zombie Zone checkout that mounts this pack (ZZ_GAME, default ../game-zombie-zone)
# and xvfb. Then look at every PNG (tools/contact_sheet.sh).
#
#   tools/make_icons.sh [kind ...]
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
game="${ZZ_GAME:-$here/../game-zombie-zone}"
out="$here/addons/zz_mutants/icons"
args=("--out=$out")
[ "$#" -gt 0 ] && args+=("--kinds=$(IFS=,; echo "$*")")
exec xvfb-run -a -s "-screen 0 1280x720x24" "${GODOT:-godot}" --path "$game" --rendering-method gl_compatibility \
    --rendering-driver opengl3 --script "$here/tools/render_icons.gd" -- "${args[@]}"
