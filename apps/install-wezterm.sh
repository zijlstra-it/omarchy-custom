#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "           Omarchy: Installing WezTerm               "
echo "===================================================="

# Install WezTerm terminal emulator
omarchy install terminal wezterm

# Install wezterm-omarchy integration to follow Omarchy color schemes
# This clones the wezterm-omarchy repository and runs make install
WEZTERM_OMARCHY_REPO="https://github.com/xpusostomos/wezterm-omarchy.git"
WEZTERM_OMARCHY_DIR="$HOME/.local/share/omarchy/wezterm-omarchy"

if [ ! -d "$WEZTERM_OMARCHY_DIR" ]; then
  echo "Installing wezterm-omarchy integration..."
  git clone "$WEZTERM_OMARCHY_REPO" "$WEZTERM_OMARCHY_DIR"
  cd "$WEZTERM_OMARCHY_DIR"
  # Install locally (recommended - no root needed, survives Omarchy updates)
  make install MODE=local
  cd -
else
  echo "✅ wezterm-omarchy already installed"
fi

# Set WezTerm as the Default Terminal
# omarchy default terminal wezterm

echo "===================================================="
echo "          ✅ WezTerm installed successfully!        "
echo "===================================================="
