# Omarchy custom setup

Customization of a fresh Omarchy setup, based on https://github.com/itsmzdev/omarchy-env-setup

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
