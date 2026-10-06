#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "     Omarchy: Installing Neovim with LazyVim        "
echo "===================================================="

# Install Neovim
omarchy install editor nvim

# Set Neovim as default editor
omarchy default editor nvim

# LazyVim configuration will be handled by dotfiles
# The dotfiles repository should include the LazyVim setup

echo "===================================================="
echo "       ✅ Neovim installed successfully!            "
echo "===================================================="
