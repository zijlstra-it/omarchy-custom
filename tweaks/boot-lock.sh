#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Boot Lock Screen (Hyprland)        "
echo "===================================================="

# This tweak sets up a lock screen that appears immediately at boot
# It works with Hyprland and SDDM autologin

# Create the Hyprland config directory
HYPR_CONFIG_DIR="$HOME/.config/hypr"
mkdir -p "$HYPR_CONFIG_DIR"

# Copy/create the bootlock.lua configuration
# This file will be loaded by Hyprland's pcall loader
cat > "$HYPR_CONFIG_DIR/bootlock.lua" << 'EOF'
-- Boot lock screen for Hyprland
-- Shows lock screen immediately at boot (password on login)

local function lockScreen()
    -- Use omarchy-shell to lock (same as Super+Esc)
    os.execute("omarchy-shell lock lock")
end

-- Call lockScreen when Hyprland starts
lockScreen()
EOF

echo "✅ Installed: session locks immediately when Hyprland starts"
echo "ℹ️ SDDM keeps autologging you in; the lock screen covers the session instantly."
echo "ℹ️ Requires the hyprland module's pcall loader to activate."

echo "===================================================="
echo "     ✅ Boot lock screen configured successfully    "
echo "===================================================="
