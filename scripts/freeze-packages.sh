#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCLUDE_AUR=("noctalia-git" "noctalia-greeter-git")

mkdir -p "$REPO_ROOT/pkglist"

pacman -Qqen | sort > "$REPO_ROOT/pkglist/pacman.txt"

aur_pkgs="$(pacman -Qqem | sort)"
printf '%s\n' "$aur_pkgs" | grep -vxF -f <(printf '%s\n' "${EXCLUDE_AUR[@]}") \
  > "$REPO_ROOT/pkglist/aur.txt" || true

echo "Wrote $(wc -l < "$REPO_ROOT/pkglist/pacman.txt") packages to pkglist/pacman.txt"
echo "Wrote $(wc -l < "$REPO_ROOT/pkglist/aur.txt") packages to pkglist/aur.txt (excluding: ${EXCLUDE_AUR[*]})"
