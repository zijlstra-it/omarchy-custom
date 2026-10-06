# Omarchy custom setup

Customization of a fresh Omarchy setup, based on https://github.com/itsmzdev/omarchy-env-setup

## References

This repository incorporates configurations and modules from the following sources:

### Core Setup
- [itsmzdev/omarchy-env-setup](https://github.com/itsmzdev/omarchy-env-setup) - Base Omarchy environment setup

### Themes & Tweaks
- [thehumanx/omarchy-setup](https://github.com/thehumanx/omarchy-setup) - Additional Omarchy configurations (boot lock screen, restyled lock screen, etc.)
- [xpusostomos/wezterm-omarchy](https://github.com/xpusostomos/wezterm-omarchy) - WezTerm integration with Omarchy color schemes (live theme switching)

### Applications
- [bitwarden/clients](https://github.com/bitwarden/clients) - Bitwarden password manager
- [MistralAI/mistral-cli](https://github.com/MistralAI/mistral-cli) - Mistral CLI
- [ProtonMail/proton-pass](https://github.com/ProtonMail/proton-pass) - Proton Authenticator
- [wez/wezterm](https://github.com/wez/wezterm) - WezTerm terminal emulator

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/zijlstra-it/omarchy-custom/main/setup.sh | bash
```

The clone logic tries SSH first and falls back to HTTPS. SSH requires a working GitHub key; HTTPS works without one for publicly accessible repositories. This command runs the version currently on GitHub, so commit and push changes first.

## Repository Layout

- `setup.sh` — entry point, repository clone logic, and execution order.
- `install-apps.sh` — ordered selection of app installer scripts.
- `apps/` — individual `install-<app>.sh` scripts.
- `install-tweaks.sh` — ordered elections of tweaks to apply.
- `tweaks/` — individual `<tweak>.sh` scripts.
- `remove-apps.sh` — web app, package, and system component removal selections.
- Dotfiles and Stow packages are maintained in a separate `dotfiles` repository.
