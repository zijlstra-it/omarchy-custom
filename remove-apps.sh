#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Removing Web Apps & Packages        "
echo "===================================================="

# --------------------------------------------------
# 1. Removing Webapps
# --------------------------------------------------
echo -e "\nExecuting: Removing Webapps..."

webapps=(
  "Basecamp"
  "ChatGPT"
  "Discord"
  "Figma"
  "Fizzy"
  "GitHub"
  "Google Contacts"
  "Google Maps"
  "Google Messages"
  "Google Photos"
  "HEY"
  "MoonLight"
  "X"
  "YouTube"
  "Zoom"
)

for app in "${webapps[@]}"; do
  echo "Removing web app: $app"
  omarchy webapp remove "$app"
done

# Skipped webapps: WhatsApp

# --------------------------------------------------
# 2. Removing Packages
# --------------------------------------------------
echo -e "\nExecuting: Removing Packages..."

omarchy pkg drop \
  1password-beta \
  1password-cli \
  aether \
  chromium \
  kdenlive \
  obs-studio \
  obsidian \
  omawrite \
  pinta \
  signal-desktop \
  tensaku \
  typora \
  xournalpp

# Skipped packages: lazydocker, opencode, claude-code

omarchy remove security fido2
omarchy remove security fingerprint

# --------------------------------------------------
# Completion
# --------------------------------------------------
echo "===================================================="
echo "         🎉 All apps removed successfully           "
echo "===================================================="
