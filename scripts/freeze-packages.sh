#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCLUDE_AUR=("noctalia-git" "noctalia-greeter-git")
# Pinned into pacman.txt even when not explicitly installed live: this
# machine runs the AUR -git equivalents above (excluded from aur.txt), but
# a fresh "No Desktop" install should pull the stable CachyOS repo packages
# instead of building the -git versions from AUR.
EXTRA_PACMAN=("noctalia" "noctalia-greeter")

mkdir -p "$REPO_ROOT/pkglist"

{ pacman -Qqen; printf '%s\n' "${EXTRA_PACMAN[@]}"; } | sort -u > "$REPO_ROOT/pkglist/pacman.txt"

aur_pkgs="$(pacman -Qqem | sort)"
printf '%s\n' "$aur_pkgs" | grep -vxF -f <(printf '%s\n' "${EXCLUDE_AUR[@]}") \
  > "$REPO_ROOT/pkglist/aur.txt" || true

echo "Wrote $(wc -l < "$REPO_ROOT/pkglist/pacman.txt") packages to pkglist/pacman.txt (pinned: ${EXTRA_PACMAN[*]})"
echo "Wrote $(wc -l < "$REPO_ROOT/pkglist/aur.txt") packages to pkglist/aur.txt (excluding: ${EXCLUDE_AUR[*]})"
