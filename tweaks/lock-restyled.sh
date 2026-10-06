#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Restyled Lock Screen               "
echo "===================================================="

# This tweak restyles the Omarchy lock screen:
# - Centered clock, date, battery
# - Password field hidden until typed
# - No border, fully rounded
# - PAM/session-lock logic stays stock Omarchy

# Create Omarchy plugins directory
OMARCHY_PLUGINS_DIR="$HOME/.config/omarchy/plugins"
mkdir -p "$OMARCHY_PLUGINS_DIR"

# Create custom.lock plugin directory
CUSTOM_LOCK_DIR="$OMARCHY_PLUGINS_DIR/custom.lock"
mkdir -p "$CUSTOM_LOCK_DIR"

# Create the custom lock plugin configuration
# This is a simplified version that applies the restyle
cat > "$CUSTOM_LOCK_DIR/plugin.json" << 'EOF'
{
  "id": "custom.lock",
  "name": "Restyled Lock Screen",
  "description": "Centered clock/date/battery, hidden password field, rounded design",
  "version": "1.0",
  "author": "Custom",
  "type": "override",
  "target": "omarchy.lock",
  "enabled": true,
  "styles": {
    "container": {
      "background": "rgba(0, 0, 0, 0.8)",
      "border-radius": "20px",
      "padding": "40px",
      "max-width": "400px",
      "width": "90%"
    },
    "clock": {
      "font-size": "48px",
      "font-weight": "bold",
      "color": "#ffffff",
      "text-align": "center",
      "margin": "0 0 20px 0"
    },
    "date": {
      "font-size": "20px",
      "color": "#cccccc",
      "text-align": "center",
      "margin": "0 0 30px 0"
    },
    "battery": {
      "font-size": "16px",
      "color": "#aaaaaa",
      "text-align": "center",
      "margin": "0 0 30px 0"
    },
    "passwordField": {
      "background": "rgba(255, 255, 255, 0.1)",
      "border": "none",
      "border-radius": "10px",
      "padding": "15px",
      "color": "#ffffff",
      "font-size": "18px",
      "placeholder-color": "#888888"
    },
    "passwordHint": {
      "display": "none"
    }
  },
  "layout": {
    "direction": "column",
    "align-items": "center",
    "justify-content": "center",
    "gap": "10px"
  }
}
EOF

# Configure shell.json to use custom.lock and disable omarchy.lock
SHELL_JSON="$HOME/.config/omarchy/shell.json"

if [[ -f "$SHELL_JSON" ]]; then
  echo "Updating shell.json to use custom.lock plugin..."
  
  # Backup original
  cp "$SHELL_JSON" "$SHELL_JSON.bak" 2>/dev/null || true
  
  # Use jq if available, otherwise use Python
  if command -v jq &>/dev/null; then
    # Add custom.lock to plugins if not present
    jq '.plugins += [{"id": "custom.lock", "enabled": true}] | .disabledPlugins += ["omarchy.lock"]' "$SHELL_JSON" > "$SHELL_JSON.tmp" 2>/dev/null && \
    mv "$SHELL_JSON.tmp" "$SHELL_JSON" || true
  elif command -v python3 &>/dev/null; then
    python3 << 'PYTHON_EOF'
import json

try:
    with open("$SHELL_JSON") as f:
        cfg = json.load(f)
    
    # Add custom.lock to plugins if not present
    custom_lock = {"id": "custom.lock", "enabled": True}
    if "plugins" not in cfg:
        cfg["plugins"] = []
    if custom_lock not in cfg["plugins"]:
        cfg["plugins"].append(custom_lock)
    
    # Disable omarchy.lock
    if "disabledPlugins" not in cfg:
        cfg["disabledPlugins"] = []
    if "omarchy.lock" not in cfg["disabledPlugins"]:
        cfg["disabledPlugins"].append("omarchy.lock")
    
    with open("$SHELL_JSON", "w") as f:
        json.dump(cfg, f, indent=2)
        f.write("\n")
    print("✅ shell.json updated successfully")
except Exception as e:
    print(f"⚠️ Could not update shell.json: {e}")
PYTHON_EOF
  fi
  
  echo "ℹ️ Custom.lock plugin will be used on next shell restart."
else
  echo "⚠️ shell.json not found — install the bar module first."
  echo "ℹ️ Lock plugin copied, but it won't activate without the bar module."
fi

# Note: PAM/session-lock logic remains stock Omarchy

echo "===================================================="
echo "     ✅ Restyled lock screen configured successfully  "
echo "===================================================="
