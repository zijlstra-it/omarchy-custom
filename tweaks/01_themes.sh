#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Installing Themes"

# Install my preferred theme(s) — skip if already installed so re-runs are safe
if omarchy theme list 2>/dev/null | grep -qx "Nous"; then
  info "Theme 'Nous' already installed, skipping install."
else
  omarchy theme install https://github.com/notkisk/omarchy-nous-theme.git
fi

# Set preferred Theme
step "Setting theme to Nous..."
omarchy theme set Nous

ok "Themes installed successfully!"
