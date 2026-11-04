#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Installing Applications"

packages=(
  stow
  yazi
)

for pkg in "${packages[@]}"; do
  step "Installing package: $pkg"
  omarchy pkg add "$pkg"
done

ok "Applications installed successfully!"
