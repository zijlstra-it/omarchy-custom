#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Installing Mistral CLI              "
echo "===================================================="

# Install Mistral CLI
omarchy pkg add mistral-cli

# Set Mistral CLI as the default agent
omarchy default agent mistral-cli

echo "===================================================="
echo "       ✅ Mistral CLI installed successfully!       "
echo "===================================================="
