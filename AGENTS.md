# Coding Guidelines for Omarchy custom setup

This document defines the coding standards and conventions for the omarchy-custom repository based on existing patterns.

## Repository Overview

This repository automates the setup of a fresh Omarchy installation through modular Bash scripts:

- **`setup.sh`**: Main entry point, requests sudo once (`sudo -v`), orchestrates repository cloning and execution order
- **`install-apps.sh`**: Manages ordered execution of individual app installers
- **`install-tweaks.sh`**: Manages ordered execution of system tweak scripts
- **`remove-apps.sh`**: Handles removal of unwanted web apps and packages
- **`install-dotfiles.sh`**: Backs up conflicting files and stows dotfiles into the target directory
- **`apps/install-<app>.sh`**: Individual installer scripts for each application
- **`tweaks/<tweak>.sh`**: System tweak scripts (plugins, themes, plymouth, etc.)
- **`lib/output.sh`**: Shared output helpers (`banner`, `section`, `step`, `ok`, `warn`, `err`, `info`) sourced by every script
- **`dotfiles/config/`**: Stowed to `~/.config/` (e.g. `dotfiles/config/hypr` → `~/.config/hypr`)
- **`dotfiles/home/`**: Stowed to `$HOME/` (e.g. `dotfiles/home/.pi` → `~/.pi`); `auth.json` and other secrets are git-ignored here

## Script Conventions

### 1. Shebang

Use `#!/usr/bin/env bash` for portability. While the codebase currently mixes `#!/bin/bash` and `#!/usr/bin/env bash`, the latter is preferred for cross-platform compatibility.

```bash
#!/usr/bin/env bash
```

### 2. Error Handling

All scripts MUST start with strict error handling:

```bash
set -euo pipefail
```

- `-e`: Exit immediately if a command fails
- `-u`: Treat unset variables as an error
- `-o pipefail`: Pipeline fails if any command in the pipeline fails

### 3. Script Structure

All scripts follow a consistent structure and use the shared output helpers
from `lib/output.sh`:

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"      # root scripts
# source "$SCRIPT_DIR/../lib/output.sh" # for apps/ and tweaks/ scripts

# Optional: Configuration variables (UPPER_CASE)

# Opening banner (printed once per script)
banner "Omarchy: Doing Something"

# Main execution logic using the helpers below

# Single success line (no closing banner)
ok "Something done successfully!"
```

Output helpers (icons are part of the convention):

- `banner "Title"` — opening banner: 51 `=` chars, title centered, 51 `=` chars
- `section "Header"` — bold section header on its own line
- `step "▶ text"` — step in progress (use an icon, e.g. `step "🛠️ ..."`)
- `ok "✅ ..."` — success (green ✅)
- `warn "⚠️ ..."` — warning (yellow ⚠️)
- `err "❌ ..."` — error (red ❌, always to stderr)
- `info "ℹ️ ..."` — informational note

Parent scripts (`setup.sh`, `install-apps.sh`, `install-tweaks.sh`) print one
`step "Executing: <script>"` line per child instead of extra banners or dashed
separators. Child scripts print one opening `banner` and finish with a single
`ok` line — never a closing banner.

### 4. Naming Conventions

- **Files**: `install-<app>.sh` for app installers (lowercase, hyphen-separated)
- **Variables**: `UPPER_CASE_WITH_UNDERSCORES` for configuration and constants
- **Functions**: `lowercase_with_underscores()` for helper functions
- **Arrays**: Plural descriptive names (e.g., `installers`, `webapps`)

### 5. Indentation

Use **2 spaces** for indentation. No tabs.

```bash
for script in "${installers[@]}"; do
  if [[ ! -f "$script" ]]; then
    err "Error: $script not found"
    exit 1
  fi
done
```

### 6. String Quoting

Always quote variables and strings that may contain spaces or special characters:

```bash
step "Removing web app: $app"
omarchy webapp remove "$app" || true  # idempotent: already-removed apps must not abort
```

### 7. Arrays

Define arrays with one element per line for readability. **Sort entries alphabetically**, with entries starting with numbers listed first in numerical order (e.g., `1password` before `aether`).

```bash
installers=(
  "./apps/install-apps.sh"
  "./apps/install-firefox.sh"
  "./apps/install-mistral-cli.sh"
  "./apps/install-zsh.sh"
)
```

For tweaks, use a separate `install-tweaks.sh` script:

```bash
tweaks=(
  "./tweaks/00_plugins.sh"
  "./tweaks/01_themes.sh"
  "./tweaks/plymouth-bgrt.sh"
)
```

Iterate with proper quoting:

```bash
for script in "${installers[@]}"; do
  bash "$script"
done
```

### 8. Functions

Define functions with `local` variables for parameters:

```bash
clone_repo() {
  local repo_name="$1"
  local ssh_url="$2"
  local https_url="$3"
  local destination="$4"
  local clone_tmp

  # Function body
}
```

### 9. Comments

Use `#` for comments with a single space after the hash:

```bash
# This is a comment

# --------------------------------------------------
# Section Header
# --------------------------------------------------
```

Section headers use hyphens and are centered within the 51-character width.

### 10. Omarchy Commands

Use the `omarchy` CLI with appropriate categories:

- **Package installation**: `omarchy pkg add <package>`
- **AUR packages**: `omarchy pkg aur add <package>`
- **Browser installation**: `omarchy install browser <name>`
- **Terminal installation**: `omarchy install terminal <name>`
- **Editor installation**: `omarchy install editor <name>`
- **Gaming**: `omarchy install gaming <name>`
- **Docker databases**: `omarchy install docker dbs <name>`
- **Set defaults**: `omarchy default <type> <name>` — note: `omarchy default agent <name>` also *launches* the agent; to only set the default (e.g. Pi) during installs, write `~/.config/omarchy/defaults/agent` directly
- **Plugins**: `omarchy plugin add <git-url> --yes`, `omarchy plugin enable <id>`, `omarchy plugin list --json`
- **Themes**: `omarchy theme install <git-url>`, `omarchy theme set <name>`, `omarchy theme list`
- **Webapp removal**: `omarchy webapp remove <name>`
- **Package removal**: `omarchy pkg drop <package>`
- **System removal**: `omarchy remove <category> <name>`
- **Config set**: `omarchy config set <section>/<key> <value>`
- **Config get**: `omarchy config get <section>/<key>`
- **Config apply**: `omarchy config apply <section>`
- **Keybindings add**: `omarchy keybindings add <action> <keys>`
- **Keybindings remove**: `omarchy keybindings remove <action> <keys>`
- **Keybindings list**: `omarchy keybindings list`
- **Keybindings reset**: `omarchy keybindings reset`

### 11. Systemctl Commands

For system service management:

- **Disable service**: `systemctl --user disable <service>`
- **Mask service**: `systemctl --user mask <service>`
- **Enable service**: `systemctl --user enable <service>`
- **Unmask service**: `systemctl --user unmask <service>`

### 12. Plymouth Configuration

Use these commands to configure Plymouth boot splash (requires sudo/root):

- **Set theme**: `sudo plymouth-set-default-theme <theme-name>`
- **List available themes**: `plymouth-set-default-theme --list` or `ls /usr/share/plymouth/themes/`
- **Rebuild initramfs (Arch/mkinitcpio)**: `sudo mkinitcpio -P`
- **Rebuild initramfs (Debian/update-initramfs)**: `sudo update-initramfs -u -k all`
- **Check current theme**: `sudo grep Theme /etc/plymouth/plymouthd.conf` or `sudo readlink /usr/share/plymouth/themes/default.plymouth`

To prevent Omarchy from overriding your Plymouth theme, disable and mask the refresh service:

```bash
# Try both system and user level (with sudo, as in tweaks/plymouth-bgrt.sh)
sudo systemctl disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl mask omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl --user disable omarchy-refresh-plymouth.service 2>/dev/null || true
sudo systemctl --user mask omarchy-refresh-plymouth.service 2>/dev/null || true
```

Note: the `omarchy-settings` package also destructively restores its own
`/etc/plymouth/plymouthd.conf` (`Theme=omarchy`) on every upgrade, so
`tweaks/plymouth-bgrt.sh` additionally installs a post-update hook at
`~/.config/omarchy/hooks/post-update.d/plymouth-bgrt.hook` that re-applies the
theme and rebuilds the initramfs after each `omarchy update`.

Popular Plymouth themes:

- `bgrt` - Boot Graphics Runtime theme
- `spinner` - Simple spinner animation
- `text` - Text-based boot

### 13. Keybindings Configuration

Use the `omarchy keybindings` commands to configure system keybindings in keybinding scripts:

- **Add a new keybinding**: `omarchy keybindings add <action> <keys>`
- **Update a keybinding**: First remove the old one, then add the new: `omarchy keybindings remove <action> <old-keys>` followed by `omarchy keybindings add <action> <new-keys>`
- **Remove a keybinding**: `omarchy keybindings remove <action> <keys>`
- **List all keybindings**: `omarchy keybindings list`
- **Reset to defaults**: `omarchy keybindings reset`

Example keybinding actions:

- `terminal:new` - Open a new terminal
- `editor:open` - Open the editor
- `browser:new` - Open a new browser window
- `app-launcher:open` - Open application launcher
- `file-manager:open` - Open file manager
- `screenshot:full` - Take a full screenshot
- `screenshot:region` - Take a regional screenshot
- `window:close` - Close the current window
- `window:maximize` - Maximize the current window
- `window:minimize` - Minimize the current window
- `workspace:next` - Switch to the next workspace
- `workspace:prev` - Switch to the previous workspace
- `volume:up` - Increase volume
- `volume:down` - Decrease volume
- `volume:mute` - Mute volume

### 14. Execution Flow

The main `setup.sh` orchestrates execution in this order:

1. **Phase 1**: `sudo -v` (ask for sudo credentials once), repository checks and cloning
2. **Step 1**: App installation via `install-apps.sh`
3. **Step 2**: System tweaks via `install-tweaks.sh`
4. **Step 3**: App removal via `remove-apps.sh`
5. **Step 4**: Dotfiles backup and stow via `install-dotfiles.sh` — twice: `dotfiles/config` → `~/.config` and `dotfiles/home` → `$HOME`

Each phase must validate preconditions before execution.

### 15. Validation

Validate all prerequisites before making changes:

```bash
# Validate every module before making changes
for script in "${installers[@]}"; do
  if [[ ! -f "$script" ]]; then
    err "Error: Required installer not found: $script"
    exit 1
  fi
done
```

### 16. Error Messages

Error messages must be written to stderr with clear descriptions, using the `err` helper (which writes to stderr and prefixes ❌):

```bash
err "Error: <description>"
exit 1
```

### 17. Success Messages

Finish every script with a single `ok` line (see the helpers in section 3):

```bash
ok "<App/Task> installed/removed successfully!"
```

### 18. Banner Formatting

Banners are printed via `banner "Title"` from `lib/output.sh`: exactly 51 `=`
characters with the title centered between them. Do not print raw `echo "==="`
banners or dashed `----` separators; use `banner`, `section`, and `step`.

### 19. File Permissions

All executable scripts must have execute permissions. Use `chmod +x` in the orchestration scripts:

```bash
chmod +x ./install-apps.sh
./install-apps.sh
```

### 20. Idempotency

**All scripts MUST be idempotent: running `setup.sh` (or any sub-script) multiple times must be safe and produce the same end state.** Concretely:

- Guard state-changing operations: skip when the desired state already exists (e.g. check a config file's content before writing it, check `command -v` before installing).
- Never fail under `set -euo pipefail` because a target is already done — append `|| true` to removal/reset commands that error on missing items.
- Prefer overwriting with identical content over appending; never create duplicate `.bak` files for symlinks that already point into the repo.

Example:

```bash
if [ -f "$FILE" ] && [ "$(cat "$FILE")" = "desired" ]; then
  info "Already configured."
else
  printf 'desired\n' > "$FILE"
fi
```

### 21. Temporaries

Use `mktemp` for temporary directories with descriptive prefixes:

```bash
clone_tmp=$(mktemp -d "$REPOS_DIR/.${repo_name}.clone.XXXXXX")
```

Always clean up temporaries on error paths:

```bash
rm -rf -- "$clone_tmp"
```

## App Installer Script Template

```bash
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/../lib/output.sh"

banner "Omarchy: Installing <App Name>"

# Installation commands here
# Use appropriate omarchy command for the app category

# Optional: Set as default if applicable
# omarchy default <type> <name>

ok "<App Name> installed successfully!"
```

## Adding New Apps

To add a new application installer:

1. Create a new file in `apps/` named `install-<app>.sh`
2. Follow the template above with appropriate omarchy commands
3. Add the script path to the `installers` array in `install-apps.sh`
4. Test the installer independently before committing

## Arrays in Main Scripts

**Sort all array entries alphabetically, with numbered entries (e.g., `1password`) listed first in numerical order.**

### install-apps.sh

The `installers` array controls the installation order. Active installers are uncommented, inactive ones are commented out. Maintain alphabetical order with numbered entries first:

```bash
installers=(
  "./apps/install-apps.sh"
  "./apps/install-firefox.sh"
  "./apps/install-mistral-cli.sh"
  "./apps/install-zsh.sh"
)
```

### install-tweaks.sh

The `tweaks` array controls the tweak execution order. Maintain alphabetical order with numbered entries first:

```bash
tweaks=(
  "./tweaks/00_plugins.sh"
  "./tweaks/01_themes.sh"
  "./tweaks/plymouth-bgrt.sh"
)
```

### remove-apps.sh

The `webapps` array lists web apps to remove. Maintain alphabetical order with numbered entries first:

```bash
webapps=(
  "Basecamp"
  "ChatGPT"
  "Discord"
  "Figma"
  "Fizzy"
  "GitHub"
  "Google Contacts"
  "Google Maps"
  "Google Messages"
  "Google Photos"
  "HEY"
  "MoonLight"
  "X"
  "Zoom"
)
```

Package removal uses an inline list with `omarchy pkg drop ... || true` (idempotent). Sort packages alphabetically with numbered entries first:

```bash
omarchy pkg drop \
  1password-beta \
  1password-cli \
  aether \
  chromium \
  kdenlive \
  obs-studio \
  obsidian \
  omawrite \
  pinta \
  signal-desktop \
  tensaku \
  typora \
  xournalpp || true
```

## Tweaks Scripts

The `tweaks/` directory contains system customization scripts that configure system-level settings. Tweak scripts use the naming convention `<tweak-name>.sh` (without the `install-` prefix).

- **`00_plugins.sh`**: Installs and enables Omarchy shell plugins (`omarchy plugin add` / `enable`), skipping plugins that are already installed
- **`01_themes.sh`**: Installs the Nous theme if missing and sets it via `omarchy theme set`
- **`plymouth-bgrt.sh`**: Sets the Plymouth boot splash theme to `bgrt`, rebuilds the initramfs, masks `omarchy-refresh-plymouth.service`, and installs a post-update hook that re-applies `bgrt` after every `omarchy update` (the `omarchy-settings` package resets the theme on upgrade)

The Hyprland boot-lock config (`bootlock.lua`) is no longer a tweak script — it lives in `dotfiles/config/hypr/bootlock.lua` and is stowed to `~/.config/hypr/`.

To add a new tweak script:

1. Create a new file in `tweaks/` named `<tweak-name>.sh`
2. Follow the same structure as app installer scripts
3. Add the script path to the `tweaks` array in `install-tweaks.sh`
4. Test the tweak script independently before committing

## Configuration Variables

Configuration variables in `setup.sh` use UPPER_CASE and are defined at the top:

```bash
REPOS_DIR="$HOME/git"
OMARCHY_REPO_SSH="git@github.com:zijlstra-it/omarchy-custom.git"
OMARCHY_REPO_HTTPS="https://github.com/zijlstra-it/omarchy-custom.git"
DOTFILES_REPO_SSH="git@github.com:zijlstra-it/dotfiles.git"
DOTFILES_REPO_HTTPS="https://github.com/zijlstra-it/dotfiles.git"
```

## Git Cloning Logic

The `clone_repo()` function attempts SSH first, then falls back to HTTPS:

```bash
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
```

## Testing

Before committing changes:

1. Test each installer script independently
2. Test the full execution flow with `bash ./setup.sh` — **run it twice** to verify idempotency (see section 20)
3. Verify error handling by testing with missing dependencies
4. Ensure all scripts have execute permissions

## Reference Attribution

**Always add a reference to the README when incorporating configurations, modules, or integrations from other Git repositories.** When adding new apps, tweaks, or improvements that are based on or inspired by external repositories, update the References section in README.md with the appropriate source link under the relevant category (Core Setup, Themes & Tweaks, or Applications). This ensures proper attribution and helps users understand the provenance of the configurations.

## Commit Message Format

```
feat: add <app> installer

Generated by Mistral Vibe.
Co-Authored-By: Mistral Vibe <vibe@mistral.ai>
```

Or for multiple changes:

```
feat: organize app installers under apps/

Generated by Mistral Vibe.
Co-Authored-By: Mistral Vibe <vibe@mistral.ai>
```
