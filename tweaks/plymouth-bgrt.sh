#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "     Omarchy: Configuring Plymouth Boot Splash       "
echo "===================================================="

# Set Plymouth theme to bgrt (requires sudo)
sudo plymouth-set-default-theme bgrt

# Rebuild initramfs to apply the theme change (requires sudo)
# Use update-initramfs or mkinitcpio depending on the system
if command -v mkinitcpio &>/dev/null; then
  echo "Rebuilding initramfs with mkinitcpio..."
  sudo mkinitcpio -P
elif command -v update-initramfs &>/dev/null; then
  echo "Rebuilding initramfs with update-initramfs..."
  sudo update-initramfs -u -k all
fi

# Disable omarchy-refresh-plymouth.service to prevent it from overriding the theme
# Try both system and user level, ignore errors if service doesn't exist
sudo systemctl disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl mask omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl --user disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl --user mask omarchy-refresh-plymouth.service 2>/dev/null || true

# Verify the theme is set by reading the config file
if [ -f /etc/plymouth/plymouthd.conf ]; then
  current_theme=$(sudo grep -E '^Theme|^ theme' /etc/plymouth/plymouthd.conf | awk '{print $2}' | tr -d '\"') || true
elif [ -f /usr/share/plymouth/themes/default.plymouth ]; then
  current_theme=$(sudo readlink /usr/share/plymouth/themes/default.plymouth 2>/dev/null | xargs basename) || true
fi
echo "Current Plymouth theme: ${current_theme:-bgrt}"

echo "===================================================="
echo "     ✅ Plymouth theme set to bgrt successfully      "
echo "===================================================="
