#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"

# Ask for sudo credentials once; sudo caches them for the rest of this run
# (default timestamp_timeout, usually 15 minutes), so sub-scripts that call
# sudo (e.g. tweaks/plymouth-bgrt.sh, apps/install-zsh.sh) don't re-prompt.
step "🔑 Requesting sudo credentials once for this run..."
sudo -v

# Configuration
REPOS_DIR="$HOME/git"
OMARCHY_REPO_SSH="git@github.com:zijlstra-it/omarchy-custom.git"
OMARCHY_REPO_HTTPS="https://github.com/zijlstra-it/omarchy-custom.git"
DOTFILES_REPO_SSH="git@github.com:zijlstra-it/dotfiles.git"
DOTFILES_REPO_HTTPS="https://github.com/zijlstra-it/dotfiles.git"

clone_repo() {
  local repo_name="$1"
  local ssh_url="$2"
  local https_url="$3"
  local destination="$4"
  local clone_tmp

  clone_tmp=$(mktemp -d "$REPOS_DIR/.${repo_name}.clone.XXXXXX")

  step "📥 Trying to clone $repo_name over SSH..."
  if GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=5' \
    git clone "$ssh_url" "$clone_tmp" 2>/dev/null; then
    mv "$clone_tmp" "$destination"
    return
  fi

  rm -rf -- "$clone_tmp"
  clone_tmp=$(mktemp -d "$REPOS_DIR/.${repo_name}.clone.XXXXXX")

  info "SSH clone unavailable; trying HTTPS..."
  if git clone "$https_url" "$clone_tmp"; then
    mv "$clone_tmp" "$destination"
    return
  fi

  rm -rf -- "$clone_tmp"
  err "Could not clone $repo_name using SSH or HTTPS."
  return 1
}

banner "Omarchy: Setting Up Environments..."

# --------------------------------------------------
# Phase 1: Repository Checks
# --------------------------------------------------
section "📦 Checking structural environment..."
mkdir -p "$REPOS_DIR"

# Check & Clone omarchy-custom
if [ ! -d "$REPOS_DIR/omarchy-custom" ]; then
  clone_repo "omarchy-custom" "$OMARCHY_REPO_SSH" "$OMARCHY_REPO_HTTPS" \
    "$REPOS_DIR/omarchy-custom"
else
  ok "omarchy-custom directory detected."
fi

# Move into the omarchy-custom folder where the sub-scripts live
cd "$REPOS_DIR/omarchy-custom"

# --------------------------------------------------
# Phase 2: Sequential Execution
# --------------------------------------------------
section "🚀 Starting execution pipeline..."

# 1. Install preferred system applications
if [ -f "./install-apps.sh" ]; then
  step "🛠️ Step 1: Installing applications..."
  chmod +x ./install-apps.sh
  ./install-apps.sh
fi

# 1.5. Install system tweaks
if [ -f "./install-tweaks.sh" ]; then
  step "🔧 Step 2: Applying system tweaks..."
  chmod +x ./install-tweaks.sh
  ./install-tweaks.sh
fi

# 2. Remove unwanted apps/bloat
if [ -f "./remove-apps.sh" ]; then
  step "🔥 Step 3: Removing unwanted packages..."
  chmod +x ./remove-apps.sh
  ./remove-apps.sh
fi

# 3. Back up existing configs and stow every discovered dotfiles package
if [ -f "./install-dotfiles.sh" ]; then
  step "🔗 Step 4: Backing up and stowing user environment configurations..."
  chmod +x ./install-dotfiles.sh
  # XDG config: dotfiles/config/<pkg> -> ~/.config/<pkg>
  ./install-dotfiles.sh -s ./dotfiles/config
  # Home dotfiles: dotfiles/home/<path> -> ~/<path> (e.g. pi/agent -> ~/.pi/agent)
  ./install-dotfiles.sh -s ./dotfiles/home -t "$HOME"
fi

ok "🎉 System environment Setup completed successfully!"
