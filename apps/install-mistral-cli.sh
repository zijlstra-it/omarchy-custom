#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

# --------------------------------------------------
# Configuration
# --------------------------------------------------
PI_AGENT_DIR="$HOME/.pi/agent"
PI_SETTINGS_FILE="$PI_AGENT_DIR/settings.json"
# Local credential store (outside this repo, never committed to git)
PI_AUTH_FILE="$PI_AGENT_DIR/auth.json"
MISTRAL_PROVIDER="mistral"
# Mistral Large 4 (built-in Pi model id "mistral-large-4")
MISTRAL_MODEL="mistral-large-4"

# Set to false to skip writing the Mistral defaults into Pi's settings
ADD_PI_CONFIG=true

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
  else
    info "Mistral CLI (vibe) is already installed."
  fi
else
  info "Skipping standalone Vibe CLI install (INSTALL_VIBE_CLI=false)."
fi

# --------------------------------------------------
# Make Pi the default coding agent for Omarchy
# --------------------------------------------------
# Write the default directly instead of `omarchy default agent pi`:
# that command also launches the agent (exec omarchy-agent), which we
# don't want during an unattended install.
OMARCHY_DEFAULT_AGENT_FILE="$HOME/.config/omarchy/defaults/agent"
if [ -f "$OMARCHY_DEFAULT_AGENT_FILE" ] && [ "$(cat "$OMARCHY_DEFAULT_AGENT_FILE")" = "pi" ]; then
  info "Pi is already the default coding agent."
else
  step "Setting Pi as the default coding agent..."
  mkdir -p "$(dirname "$OMARCHY_DEFAULT_AGENT_FILE")"
  printf 'pi\n' > "$OMARCHY_DEFAULT_AGENT_FILE"
  ok "Pi is now the default coding agent (not launched)."
fi

# --------------------------------------------------
# Enable Mistral as the default agent for Pi
# --------------------------------------------------
if [ "$ADD_PI_CONFIG" = true ]; then
  step "Configuring Pi to use Mistral as the default provider/model..."
  mkdir -p "$PI_AGENT_DIR"

  # Merge the Mistral defaults into existing settings when possible,
  # otherwise create a fresh settings file.
  if command -v jq &>/dev/null && [ -f "$PI_SETTINGS_FILE" ]; then
    jq --arg provider "$MISTRAL_PROVIDER" --arg model "$MISTRAL_MODEL" \
      '.defaultProvider = $provider | .defaultModel = $model | .enabledModels = (["mistral/mistral-large-4"] + (.enabledModels // [] | map(select(. != "mistral/mistral-large-4"))) | unique)' \
      "$PI_SETTINGS_FILE" > "$PI_SETTINGS_FILE.tmp"
    mv "$PI_SETTINGS_FILE.tmp" "$PI_SETTINGS_FILE"
  else
    cat > "$PI_SETTINGS_FILE" <<EOF
{
  "defaultProvider": "$MISTRAL_PROVIDER",
  "defaultModel": "$MISTRAL_MODEL",
  "enabledModels": ["mistral/$MISTRAL_MODEL"]
}
EOF
  fi

  ok "Pi configured: provider '$MISTRAL_PROVIDER', model '$MISTRAL_MODEL'."
else
  info "Skipping Pi configuration (ADD_PI_CONFIG=false)."
fi

# --------------------------------------------------
# Store the Mistral API key for Pi (local only, never in git)
# --------------------------------------------------
# The key is read from the MISTRAL_API_KEY environment variable and written
# to ~/.pi/agent/auth.json, which lives outside this repository. Alternatively,
# just export MISTRAL_API_KEY in your shell profile; Pi picks it up at runtime.
if [ -n "${MISTRAL_API_KEY:-}" ]; then
  step "Storing Mistral API key in $PI_AUTH_FILE (chmod 600)..."
  mkdir -p "$PI_AGENT_DIR"

  if command -v jq &>/dev/null && [ -f "$PI_AUTH_FILE" ]; then
    jq --arg key "$MISTRAL_API_KEY" \
      '.mistral = {type: "api_key", key: $key}' \
      "$PI_AUTH_FILE" > "$PI_AUTH_FILE.tmp"
    mv "$PI_AUTH_FILE.tmp" "$PI_AUTH_FILE"
  else
    cat > "$PI_AUTH_FILE" <<EOF
{
  "mistral": {
    "type": "api_key",
    "key": "$MISTRAL_API_KEY"
  }
}
EOF
  fi
  chmod 600 "$PI_AUTH_FILE"

  ok "Mistral API key stored locally in $PI_AUTH_FILE."
else
  warn "MISTRAL_API_KEY is not set; skipping API key storage."
  info "Either export MISTRAL_API_KEY before running this script, or run"
  info "'pi' and use /login to store the key in $PI_AUTH_FILE."
fi

ok "Mistral CLI installed successfully!"
