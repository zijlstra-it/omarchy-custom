#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "   Omarchy: Installing Proton Authenticator         "
echo "===================================================="

# Install Proton Authenticator (proton-pass or proton-authenticator)
# Check if proton-pass is available (newer version)
if omarchy pkg add proton-pass 2>/dev/null; then
  echo "✅ Installed proton-pass"
elif omarchy pkg add proton-authenticator 2>/dev/null; then
  echo "✅ Installed proton-authenticator"
else
  # Try AUR
  omarchy pkg aur add proton-authenticator 2>/dev/null || \
  omarchy pkg aur add proton-pass 2>/dev/null || \
  echo "⚠️ Could not install Proton Authenticator from any source"
fi

# Alternatively, install via flatpak if available
# flatpak install flathub com.protonmail.protonpass

echo "===================================================="
echo "   ✅ Proton Authenticator installed successfully!   "
echo "===================================================="
