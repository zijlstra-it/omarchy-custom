#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"

# Define the exact order of installation scripts
installers=(
  "./apps/install-apps.sh"
  "./apps/install-firefox.sh"
  "./apps/install-mistral-cli.sh"
  "./apps/install-zsh.sh"
)

section "Running individual application modules..."

# Validate every module before making changes, so an incomplete checkout
# cannot produce a partial install followed by a misleading success message.
for script in "${installers[@]}"; do
  if [[ ! -f "$script" ]]; then
    err "Error: Required installer not found: $script"
    exit 1
  fi
done

# Execute each installer in an isolated Bash process.
for script in "${installers[@]}"; do
  step "Executing: $(basename "$script")"
  bash "$script"
done

ok "🎉 All apps installed successfully!"
