#!/usr/bin/env bash
# One picture of every icon on a grey ground, for looking at them: tools/contact_sheet.sh [out.png]
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
montage "$here"/addons/zz_mutants/icons/*.png -background '#6a6e74' -geometry 128x128+6+6 -tile 7x "${1:-/tmp/zz_mutants_icons.png}"
