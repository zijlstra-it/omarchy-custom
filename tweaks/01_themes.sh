#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Installing Themes"

# Install my preferred theme(s) — skip if already installed so re-runs are safe
if omarchy theme list 2>/dev/null | grep -qx "Tokyo Daybreak"; then
  info "Theme 'Tokyo Daybreak' already installed, skipping install."
else
  omarchy theme install https://github.com/zijlstra-it/omarchy-tokyo-daybreak-theme.git
fi

# Set preferred Theme
step "Setting theme to Tokyo Daybreak..."
omarchy theme set tokyo-daybreak

ok "Themes installed successfully!"
