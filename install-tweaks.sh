#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Installing Tweaks...                  "
echo "===================================================="

# Define the order of tweak scripts
tweaks=(
  "./tweaks/omarchy-keybindings.sh"
  "./tweaks/plymouth-bgrt.sh"
)

echo -e "\nRunning tweak scripts..."
echo "------------------------------------------------"

# Validate every tweak before making changes
for script in "${tweaks[@]}"; do
  if [[ ! -f "$script" ]]; then
    echo "❌ Error: Required tweak not found: $script" >&2
    exit 1
  fi
done

# Execute each tweak in an isolated Bash process
for script in "${tweaks[@]}"; do
  echo "Executing: $(basename "$script")"
  bash "$script"
done

echo "===================================================="
echo "       🎉 All tweaks installed successfully!         "
echo "===================================================="
