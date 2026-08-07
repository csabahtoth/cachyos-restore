#!/usr/bin/env bash
# Sourced by install.sh — not meant to be run standalone.

overlay_dotfiles() {
  local repo_root="$1"
  local dry_run="${2:-}"

  echo "==> Overlaying dotfiles from home/ onto \$HOME"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: cp -riv $repo_root/home/. $HOME/"
  else
    cp -riv "$repo_root/home/." "$HOME/"
  fi
}
