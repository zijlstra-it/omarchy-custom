#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "     Omarchy: Configuring Keybindings               "
echo "===================================================="

# Omarchy keybindings configuration
# Use 'omarchy keybindings' commands to manage keybindings

# Example: Add a new keybinding
# Syntax: omarchy keybindings add <action> <keys>
# This binds Ctrl+Alt+T to open a new terminal
omarchy keybindings add terminal:new "Ctrl+Alt+T"

# Example: Add another keybinding
# Bind Super+E to open the editor
omarchy keybindings add editor:open "Super+E"

# Example: Update an existing keybinding
# First remove the old binding, then add the new one
# omarchy keybindings remove <action> <old-keys>
omarchy keybindings remove browser:new "Ctrl+Alt+B"
omarchy keybindings add browser:new "Super+B"

# Example: Add keybinding for application launcher
omarchy keybindings add app-launcher:open "Super+A"

# Example: Add keybinding for file manager
omarchy keybindings add file-manager:open "Super+F"

# Example: Add keybinding for screenshot
omarchy keybindings add screenshot:full "Print"
omarchy keybindings add screenshot:region "Shift+Print"

# Example: Add keybinding for window management
omarchy keybindings add window:close "Super+Q"
omarchy keybindings add window:maximize "Super+Up"
omarchy keybindings add window:minimize "Super+Down"

# Example: Add keybinding for workspace management
omarchy keybindings add workspace:next "Super+Right"
omarchy keybindings add workspace:prev "Super+Left"

# Example: Add keybinding for volume control
omarchy keybindings add volume:up "Ctrl+Alt+Up"
omarchy keybindings add volume:down "Ctrl+Alt+Down"
omarchy keybindings add volume:mute "Ctrl+Alt+M"

# Example: Remove a keybinding
# omarchy keybindings remove <action> <keys>
# omarchy keybindings remove some-action:old "Old+Key"

# Example: List all current keybindings (for debugging)
# omarchy keybindings list

# Example: Reset all keybindings to defaults
# omarchy keybindings reset

echo "===================================================="
echo "     ✅ Omarchy keybindings configured successfully   "
echo "===================================================="
