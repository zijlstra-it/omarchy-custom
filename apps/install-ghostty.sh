#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Installing Ghostty Terminal         "
echo "===================================================="

omarchy install terminal ghostty

# Set Ghostty as the Default Terminal
omarchy default terminal ghostty

echo "===================================================="
echo "        ✅ Ghostty installed successfully!         "
echo "===================================================="
