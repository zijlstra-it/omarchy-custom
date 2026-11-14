#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

# --------------------------------------------------
# Configuration
# --------------------------------------------------

# Set to false to skip installing the standalone Vibe CLI binary.
# Not needed when using Mistral models through Pi: Pi talks to the Mistral
# API directly via MISTRAL_API_KEY, and Omarchy can only default to Pi.
INSTALL_VIBE_CLI=false

# Install the standalone Mistral CLI (Vibe) if requested and missing.
# Optional: only needed to run `vibe` directly, not for Mistral via Pi.
if [ "$INSTALL_VIBE_CLI" = true ]; then
  step "Installing Mistral CLI"
  if ! command -v vibe &>/dev/null; then
    curl -LsSf https://mistral.ai/vibe/install.sh | bash
    ok "Mistral CLI installed successfully!"
  else
    info "Mistral CLI (vibe) is already installed."
  fi
else
  info "Skipping standalone Vibe CLI install (INSTALL_VIBE_CLI=false)."
fi

# --------------------------------------------------
# Make OMP the default coding agent for Omarchy
# --------------------------------------------------
# Write the default directly instead of `omarchy default agent pi`:
# that command also launches the agent (exec omarchy-agent), which we
# don't want during an unattended install.
OMARCHY_DEFAULT_AGENT_FILE="$HOME/.config/omarchy/defaults/agent"
if [ -f "$OMARCHY_DEFAULT_AGENT_FILE" ] && [ "$(cat "$OMARCHY_DEFAULT_AGENT_FILE")" = "omp" ]; then
  info "OMP is already the default coding agent."
else
  step "Setting OMP as the default coding agent..."
  mkdir -p "$(dirname "$OMARCHY_DEFAULT_AGENT_FILE")"
  printf 'omp\n' > "$OMARCHY_DEFAULT_AGENT_FILE"
  ok "OMP is now the default coding agent (not launched)."
fi
