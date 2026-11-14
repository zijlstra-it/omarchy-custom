# Omarchy custom setup

Customization of a fresh Omarchy setup, based on https://github.com/itsmzdev/omarchy-env-setup

## References

This repository incorporates configurations and modules from the following sources:

### Core Setup
- [itsmzdev/omarchy-env-setup](https://github.com/itsmzdev/omarchy-env-setup) - Base Omarchy environment setup

### Themes & Tweaks
- [zijlstra-it/omarchy-tokyo-daybreak-theme](https://github.com/zijlstra-it/omarchy-tokyo-daybreak-theme) - Tokyo Daybreak theme, fork of Nous (`tweaks/01_themes.sh`)
- [kris-1/omarchy-monitor-layout](https://github.com/kris-1/omarchy-monitor-layout) - Monitor layout plugin
- [ParvvOK/equalizer](https://github.com/ParvvOK/equalizer) - Equalizer plugin
- [BibekBhusal0/omarchy-better-lock](https://github.com/BibekBhusal0/omarchy-better-lock) - Better lock plugin
- [PixDevsApps/omarchy-hertz-radio](https://github.com/PixDevsApps/omarchy-hertz-radio) - Hertz Radio plugin
- [zijlstra-it/omarchy-spotify-player](https://github.com/zijlstra-it/omarchy-spotify-player) - Spotify player plugin

### Applications
- [MistralAI/mistral-cli](https://github.com/MistralAI/mistral-cli) - Mistral CLI (Vibe), optional; Pi uses the Mistral API directly via `MISTRAL_API_KEY`

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/zijlstra-it/omarchy-custom/main/setup.sh | bash
```

The clone logic tries SSH first and falls back to HTTPS. SSH requires a working GitHub key; HTTPS works without one for publicly accessible repositories. This command runs the version currently on GitHub, so commit and push changes first.

## Mistral API Key (Pi)

Pi reads the Mistral API key from the `MISTRAL_API_KEY` environment variable or
from `~/.pi/agent/auth.json` — both live outside this repository, so the key is
never committed to git.

```bash
# Option 1: export it in your shell before running the setup
export MISTRAL_API_KEY="your-key-here"

# Option 2: let the installer store it in ~/.pi/agent/auth.json (chmod 600)
MISTRAL_API_KEY="your-key-here" ./install-apps.sh

# Option 3: store it manually at any time
pi  # then use /login and pick Mistral
```

## Repository Layout

- `setup.sh` — entry point; asks for sudo once (`sudo -v`), clone logic, and execution order.
- `install-apps.sh` — ordered selection of app installer scripts.
- `apps/` — individual `install-<app>.sh` scripts.
- `install-tweaks.sh` — ordered selection of tweaks to apply.
- `tweaks/` — individual `<tweak>.sh` scripts (plugins, themes, plymouth).
- `remove-apps.sh` — web app, package, and system component removal selections.
- `install-dotfiles.sh` — backs up conflicting files and stows dotfiles into the target directory.
- `dotfiles/config/` — stowed to `~/.config/` (e.g. `hypr/` → `~/.config/hypr/`).
- `dotfiles/home/` — stowed to `$HOME/` (e.g. `.pi/` → `~/.pi/`); secrets like `auth.json` are git-ignored.
- `lib/output.sh` — shared output helpers (`banner`, `step`, `ok`, `warn`, `err`, `info`) used by all scripts.
- `bin/` — helper binaries.

All scripts are idempotent: running `setup.sh` multiple times is safe. The plymouth `bgrt` theme is re-applied automatically after each `omarchy update` via a post-update hook installed by `tweaks/plymouth-bgrt.sh`.
