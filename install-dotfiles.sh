#!/usr/bin/env bash
#
# install-dotfiles.sh — move files that 'stow' would overwrite to a '.bak'
# backup, then run "stow --target <TARGET> ." from the directory this script
# lives in.
#
# The script must sit in the root of the dotfiles repository. Every file in
# that repository is stowed relative to TARGET (default: ~/.config), so the
# repo layout mirrors the target:
#
#     <repo>/hypr/bindings.lua   ->  ~/.config/hypr/bindings.lua
#
# Files that would conflict are renamed to <name>.bak (numeric suffix if
# <name>.bak already exists). Real directories at the target are merged by
# stow without data loss, so only regular files and foreign symlinks are
# backed up. Entries in IGNORE_PATTERNS are neither backed up nor stowed.
#
# Usage:
#   $(basename "$0") [-s REPO_DIR] [-t TARGET_DIR] [-p] [-n]
#
#   -s REPO_DIR     root of the dotfiles repository (default: the directory
#                   this script lives in)
#   -t TARGET_DIR   target directory (default: ~/.config)
#   -p             pass --no-folding to stow (link files individually
#                   instead of whole directories where possible)
#   -n             dry run: show what would be backed up, then run
#                   "stow -n" (nothing is modified at all)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/output.sh
source "$SCRIPT_DIR/lib/output.sh"

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Entries matching these patterns are ignored by both the backup scan and
# stow itself (passed as --ignore). Extend as needed for your repo.
IGNORE_PATTERNS=(
    '.git'
    '.gitignore'
    'install-dotfiles.sh'
    'README*'
    # Never stow Pi credentials, even if present in the dotfiles tree
    'auth.json'
    '*/auth.json'
    '*/*/auth.json'
)

# ---------------------------------------------------------------------------
# Output helpers (ok/warn/err/section come from lib/output.sh)
# ---------------------------------------------------------------------------

have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
# Core routines
# ---------------------------------------------------------------------------

ensure_tools() {
    local tool
    for tool in stow find mv; do
        have "$tool" || { err "required tool not found: $tool"; exit 1; }
    done
}

# Build the --ignore arguments for stow from IGNORE_PATTERNS.
build_ignore_args() {
    local pattern re
    local -a args=()
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        re="${pattern//./\\.}"   # escape literal dots
        re="${re//\*/.*}"        # translate glob * to regex .*
        args+=(--ignore "^${re}$")
    done
    printf '%s\n' "${args[@]}"
}

# True if the given path is ignored by one of the IGNORE_PATTERNS.
is_ignored() {
    local path="$1"
    local pattern
    for pattern in "${IGNORE_PATTERNS[@]}"; do
        # shellcheck disable=SC2254
        case "$path" in
            $pattern) return 0 ;;
        esac
    done
    return 1
}

# Move one path to <path>.bak, adding -1, -2, ... if needed.
# Leaves pre-existing .bak files untouched.
backup_path() {
    local target="$1"
    local dry_run="$2"
    local dest="$target.bak"
    local n=1

    while [[ -e "$dest" || -L "$dest" ]]; do
        dest="$target.bak-$n"
        n=$((n + 1))
    done

    if [[ "$dry_run" == "true" ]]; then
        printf '    %s -> %s\n' "$target" "$dest"
    else
        mv "$target" "$dest"
        printf '    %s -> %s\n' "$target" "$dest"
    fi
}

# Walk every file/symlink in the repo and check whether the corresponding
# target path would block stow. If so, move it aside. Prints the number of
# backed-up files as the return value.
backup_conflicts() {
    local repo_dir="$1"
    local repo_dir_abs
    repo_dir_abs="$(readlink -f "$repo_dir")"
    local target_dir="$2"
    local dry_run="$3"
    local rel target backed_up=0

    # Only leaf entries (files and symlinks) can conflict. Real directories
    # are merged by stow and are therefore safe.
    while IFS= read -r -d '' rel; do
        is_ignored "$rel" && continue

        target="$target_dir/$rel"

        # Non-existing target: stow will simply create a symlink.
        [[ -e "$target" || -L "$target" ]] || continue

        # Symlink that already points into the repo: stow is happy.
        if [[ -L "$target" ]]; then
            local linkdest
            # Resolve the link (stow creates relative symlinks) so it can
            # be compared against the absolute repo path.
            linkdest="$(readlink -f "$target")"
            case "$linkdest" in
                "$repo_dir_abs"/*) continue ;;
            esac
            warn "foreign symlink at target, moving aside: $target"
        fi

        # Real directory at target: stow merges it, no backup needed.
        [[ -d "$target" && ! -L "$target" ]] && continue

        backup_path "$target" "$dry_run"
        backed_up=$((backed_up + 1))
    done < <(cd "$repo_dir" && find . \( -type f -o -type l \) -printf '%P\0')

    return "$backed_up"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local target_dir="$HOME/.config"
    local repo_dir=""
    local dry_run=false
    local -a stow_args=()
    local -a ignore_args=()
    local total_backups=0
    local line

    while getopts ":s:t:pn" opt; do
        case "$opt" in
            s) repo_dir="$OPTARG" ;;
            t) target_dir="$OPTARG" ;;
            p) stow_args+=(--no-folding) ;;
            n) dry_run=true ;;
            *) err "unknown option: -$OPTARG (usage: $(basename "$0") [-s dir] [-t dir] [-p] [-n])"; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    # Default: the repo root is the directory this script lives in.
    if [[ -z "$repo_dir" ]]; then
        repo_dir="$script_dir"
    fi
    [[ -d "$repo_dir" ]] || { err "dotfiles directory does not exist: $repo_dir"; exit 1; }

    [[ -d "$target_dir" ]] || { err "target directory does not exist: $target_dir"; exit 1; }

    ensure_tools

    while IFS= read -r line; do
        ignore_args+=("$line")
    done < <(build_ignore_args)
    # Always ignore the script itself, under its actual (possibly renamed) name.
    ignore_args+=(--ignore "^$(basename "$0")$")
    stow_args+=("${ignore_args[@]}")

    section "Backing up conflicting files (repo: $repo_dir, target: $target_dir)"
    backup_conflicts "$repo_dir" "$target_dir" "$dry_run" || total_backups=$?
    if [[ "$total_backups" -eq 0 ]]; then
        printf '    %s\n' "no conflicting files"
    else
        ok "$total_backups file(s) backed up with .bak suffix"
    fi

    section "Running stow"
    cd "$repo_dir"
    if [[ "$dry_run" == "true" ]]; then
        stow -n --target "$target_dir" "${stow_args[@]}" .
        ok "dry run finished — nothing was modified"
    else
        stow --target "$target_dir" "${stow_args[@]}" .
        ok "dotfiles installed into $target_dir"
    fi
}

main "$@"
