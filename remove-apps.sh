#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"

banner "Omarchy: Removing Web Apps & Packages"

# --------------------------------------------------
# 1. Removing Webapps
# --------------------------------------------------
section "Executing: Removing Webapps..."

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
  "Zoom"
)

for app in "${webapps[@]}"; do
  step "Removing web app: $app"
  omarchy webapp remove "$app" || true
done

# Skipped webapps: WhatsApp

# --------------------------------------------------
# 2. Removing Packages
# --------------------------------------------------
section "Executing: Removing Packages..."

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
  xournalpp || true

# Skipped packages: lazydocker, opencode, claude-code

omarchy remove security fido2 || true
omarchy remove security fingerprint || true

# --------------------------------------------------
# Completion
# --------------------------------------------------
ok "🎉 All apps removed successfully"
