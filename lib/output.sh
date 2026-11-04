# lib/output.sh — shared output helpers for all omarchy-custom scripts.
# Source from a script with:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/lib/output.sh"      # for root-level scripts
#   source "$SCRIPT_DIR/../lib/output.sh"   # for apps/ and tweaks/ scripts
#
# Icons are part of the output convention: ✅ success, ⚠️ warning,
# ❌ error, ℹ️ info, ▶ step in progress.

BANNER_WIDTH=51

# Opening banner: dashed lines with the title centered between them.
banner() {
  local title="$1"
  local pad=$(( (BANNER_WIDTH - ${#title}) / 2 ))
  (( pad < 0 )) && pad=0
  printf '=%.0s' $(seq 1 "$BANNER_WIDTH"); echo
  printf '%*s%s\n' "$pad" "" "$title"
  printf '=%.0s' $(seq 1 "$BANNER_WIDTH"); echo
}

# Bold section header (no dashed lines).
section() {
  printf '\n\033[1m%s\033[0m\n' "$*"
}

# Step in progress.
step() {
  printf '▶ %s\n' "$*"
}

# Status lines (colors like install-dotfiles.sh used).
ok()   { printf '\033[32m✅\033[0m %s\n' "$*"; }
warn() { printf '\033[33m⚠️\033[0m %s\n' "$*"; }
err()  { printf '\033[31m❌\033[0m %s\n' "$*" >&2; }
info() { printf 'ℹ️ %s\n' "$*"; }
