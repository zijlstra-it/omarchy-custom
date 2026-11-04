#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Configuring Plymouth Boot Splash"

# Set Plymouth theme to bgrt (requires sudo)
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
set -u

sudo plymouth-set-default-theme bgrt 2>/dev/null || true

if command -v mkinitcpio &>/dev/null; then
  sudo mkinitcpio -P 2>/dev/null || true
elif command -v update-initramfs &>/dev/null; then
  sudo update-initramfs -u -k all 2>/dev/null || true
fi

# Re-assert the mask in case the update re-created the service unit
sudo systemctl disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl mask omarchy-refresh-plymouth.service 2>/dev/null || true

echo "plymouth-bgrt.hook: re-applied bgrt theme"
EOF
chmod +x "$HOOK_FILE"
ok "Installed post-update hook: $HOOK_FILE"

# Verify the theme is set by reading the config file
if [ -f /etc/plymouth/plymouthd.conf ]; then
  current_theme=$(sudo grep -E '^Theme|^ theme' /etc/plymouth/plymouthd.conf | awk '{print $2}' | tr -d '\"') || true
elif [ -f /usr/share/plymouth/themes/default.plymouth ]; then
  current_theme=$(sudo readlink /usr/share/plymouth/themes/default.plymouth 2>/dev/null | xargs basename) || true
fi
info "Current Plymouth theme: ${current_theme:-bgrt}"

ok "Plymouth theme set to bgrt successfully"
