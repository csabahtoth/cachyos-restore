#!/usr/bin/env bash
# Sourced by install.sh — not meant to be run standalone.

install_packages() {
  local repo_root="$1"
  local dry_run="${2:-}"

  if ! command -v paru >/dev/null 2>&1; then
    echo "==> paru not found, installing it first"
    if [ "$dry_run" = "--dry-run" ]; then
      echo "[dry-run] would install paru from AUR (git clone + makepkg)"
    else
      sudo pacman -S --needed --noconfirm base-devel git
      local tmp
      tmp="$(mktemp -d)"
      git clone https://aur.archlinux.org/paru.git "$tmp/paru"
      (cd "$tmp/paru" && makepkg -si --noconfirm)
      rm -rf "$tmp"
    fi
  fi

  echo "==> Installing pacman packages from pkglist/pacman.txt"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: sudo pacman -S --needed - < $repo_root/pkglist/pacman.txt"
  else
    cat "$repo_root/pkglist/pacman.txt" | sudo pacman -S --needed -
  fi

  echo "==> Installing AUR packages from pkglist/aur.txt"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: paru -S --needed - < $repo_root/pkglist/aur.txt"
  else
    cat "$repo_root/pkglist/aur.txt" | paru -S --needed -
  fi
}
