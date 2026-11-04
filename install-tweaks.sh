#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"

banner "Omarchy: Installing Tweaks..."

# Define the order of tweak scripts
tweaks=(
  "./tweaks/00_plugins.sh"
  "./tweaks/01_themes.sh"
  "./tweaks/plymouth-bgrt.sh"
)

section "Running tweak scripts..."

# Validate every tweak before making changes
for script in "${tweaks[@]}"; do
  if [[ ! -f "$script" ]]; then
    err "Error: Required tweak not found: $script"
  fi
done

# Execute each tweak in an isolated Bash process
for script in "${tweaks[@]}"; do
  step "Executing: $(basename "$script")"
  bash "$script"
done

ok "🎉 All tweaks installed successfully!"
