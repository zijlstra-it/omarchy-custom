#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Installing Bitwarden                 "
echo "===================================================="

# Install Bitwarden browser extension and desktop app
omarchy install browser bitwarden

# Alternatively, install via package manager
# omarchy pkg add bitwarden

# Set Bitwarden as default password manager if applicable
# omarchy default password-manager bitwarden

echo "===================================================="
echo "        ✅ Bitwarden installed successfully!        "
echo "===================================================="
