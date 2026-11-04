#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Installing Plugins"

# add_plugin <url> <slug>: skip the add if the plugin is already installed,
# so re-running setup.sh does not fail on existing plugins. IDs and names are
# compared normalized (lowercase, alphanumerics only) because slugs differ
# from real ids, e.g. "better-lock" vs id "bibek.lock" / name "Better Lock".
add_plugin() {
  local url="$1"
  local slug="$2"
  local norm
  norm="$(printf '%s' "$slug" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')"
  if command -v jq &>/dev/null; then
    if omarchy plugin list --json 2>/dev/null | jq -e --arg n "$norm" \
        '[.[] | select((.id | ascii_downcase | gsub("[^a-z0-9]"; "")) == $n
                    or (.name | ascii_downcase | gsub("[^a-z0-9]"; "")) == $n)] | length > 0' \
        >/dev/null 2>&1; then
      info "Plugin '$slug' already installed, skipping add."
      return 0
    fi
  elif omarchy plugin list 2>/dev/null | grep -qi "$slug"; then
    info "Plugin '$slug' already installed, skipping add."
    return 0
  fi
  step "Adding plugin: $slug"
  omarchy plugin add "$url" --yes
}

add_plugin https://github.com/kris-1/omarchy-monitor-layout.git monitor-layout
omarchy plugin enable monitor-layout --section right
add_plugin https://github.com/ParvvOK/equalizer.git equalizer
omarchy plugin enable equalizer --section right
add_plugin https://github.com/BibekBhusal0/omarchy-better-lock.git better-lock
add_plugin https://github.com/PixDevsApps/omarchy-hertz-radio.git hertz-radio
omarchy plugin enable hertz-radio --section right
add_plugin https://github.com/zijlstra-it/omarchy-spotify-player.git omarchy-spotify-player
omarchy plugin enable omarchy-spotify-player --right

ok "Plugins installed successfully!"
