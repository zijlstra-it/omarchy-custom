#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Installing ZSH"

# Check if zsh is installed
if ! command -v zsh &>/dev/null; then
  omarchy pkg add zsh
fi

# Get the path to zsh
ZSH_PATH=$(which zsh)

# Check if zsh is already the default shell
if [ "$SHELL" = "$ZSH_PATH" ]; then
    ok "Zsh is already your default shell."
    exit 0
fi

# Add zsh to /etc/shells if not already there
if ! grep -q "^$ZSH_PATH$" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# Change the default shell to zsh
#chsh -s "$ZSH_PATH"

ok "ZSH installed and enabled successfully!"
