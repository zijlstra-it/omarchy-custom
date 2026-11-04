#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

step "Installing Firefox..."
omarchy install browser firefox

step "Making Firefox the default browser..."
omarchy default browser firefox

ok "Firefox installed successfully!"
