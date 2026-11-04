#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Configuring Plymouth Boot Splash"

# Read the current theme first so the initramfs is only rebuilt when the
# theme actually changes (idempotent: no rebuild when already bgrt).
current_theme=""
if [ -f /etc/plymouth/plymouthd.conf ]; then
  # Accept both "Theme=bgrt" and "Theme bgrt" formats
  current_theme=$(sudo sed -n 's/^[[:space:]]*Theme[[:space:]]*[=:]*[[:space:]]*//p' /etc/plymouth/plymouthd.conf 2>/dev/null | head -1 | tr -d '"') || true
elif [ -f /usr/share/plymouth/themes/default.plymouth ]; then
  current_theme=$(sudo readlink /usr/share/plymouth/themes/default.plymouth 2>/dev/null | xargs basename) || true
fi

if [ "$current_theme" = "bgrt" ]; then
  info "Plymouth theme is already bgrt, skipping theme change and initramfs rebuild."
else
  step "Setting Plymouth theme to bgrt (was: ${current_theme:-unknown})..."
  sudo plymouth-set-default-theme bgrt

  # Rebuild initramfs to apply the theme change (requires sudo)
  # Use update-initramfs or mkinitcpio depending on the system
  if command -v mkinitcpio &>/dev/null; then
    step "Rebuilding initramfs with mkinitcpio..."
    sudo mkinitcpio -P
  elif command -v update-initramfs &>/dev/null; then
    step "Rebuilding initramfs with update-initramfs..."
    sudo update-initramfs -u -k all
  fi
fi

# Disable omarchy-refresh-plymouth.service to prevent it from overriding the theme
# Try both system and user level, ignore errors if service doesn't exist
sudo systemctl disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl mask omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl --user disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl --user mask omarchy-refresh-plymouth.service 2>/dev/null || true

# --------------------------------------------------
# Re-apply bgrt after every `omarchy update`
# --------------------------------------------------
# The omarchy-settings package install script destructively copies its
# etc-override (Theme=omarchy) over /etc/plymouth/plymouthd.conf on every
# upgrade, so the theme must be re-applied afterwards. Omarchy runs
# `omarchy-hook post-update` at the end of each update, executing every
# hook in ~/.config/omarchy/hooks/post-update.d/.
HOOK_DIR="$HOME/.config/omarchy/hooks/post-update.d"
HOOK_FILE="$HOOK_DIR/plymouth-bgrt.hook"
mkdir -p "$HOOK_DIR"
cat > "$HOOK_FILE" <<'EOF'
#!/usr/bin/env bash
# Re-apply the bgrt Plymouth theme after an Omarchy update reset it.
# Only rebuilds the initramfs when the theme actually changed.
set -u

current_theme=""
if [ -f /etc/plymouth/plymouthd.conf ]; then
  # Accept both "Theme=bgrt" and "Theme bgrt" formats
  current_theme=$(sudo sed -n 's/^[[:space:]]*Theme[[:space:]]*[=:]*[[:space:]]*//p' /etc/plymouth/plymouthd.conf 2>/dev/null | head -1 | tr -d '"') || true
elif [ -f /usr/share/plymouth/themes/default.plymouth ]; then
  current_theme=$(sudo readlink /usr/share/plymouth/themes/default.plymouth 2>/dev/null | xargs basename) || true
fi

if [ "$current_theme" != "bgrt" ]; then
  sudo plymouth-set-default-theme bgrt 2>/dev/null || true

  if command -v mkinitcpio &>/dev/null; then
    sudo mkinitcpio -P 2>/dev/null || true
  elif command -v update-initramfs &>/dev/null; then
    sudo update-initramfs -u -k all 2>/dev/null || true
  fi
  echo "plymouth-bgrt.hook: re-applied bgrt theme"
else
  echo "plymouth-bgrt.hook: theme already bgrt, nothing to do"
fi

# Re-assert the mask in case the update re-created the service unit
sudo systemctl disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl mask omarchy-refresh-plymouth.service 2>/dev/null || true
EOF
chmod +x "$HOOK_FILE"
ok "Installed post-update hook: $HOOK_FILE"

info "Current Plymouth theme: ${current_theme:-bgrt}"

ok "Plymouth theme is bgrt"
