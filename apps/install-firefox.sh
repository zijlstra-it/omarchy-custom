#!/usr/bin/env bash

set -euo pipefail

echo "===================================================="
echo "       Omarchy: Installing Firefox Browser          "
echo "===================================================="

omarchy install browser firefox

echo "Making Firefox as a Default Browser"
omarchy default browser firefox

echo "===================================================="
echo "        ✅ Firefox installed successfully!         "
echo "===================================================="
