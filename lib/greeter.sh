#!/usr/bin/env bash
# Sourced by install.sh — not meant to be run standalone.

setup_greeter() {
  local repo_root="$1"
  local dry_run="${2:-}"

  echo "==> Installing /etc/greetd/config.toml and enabling greetd"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: sudo install -Dm644 $repo_root/etc/greetd/config.toml /etc/greetd/config.toml"
    echo "[dry-run] would run: sudo systemctl enable greetd"
  else
    sudo install -Dm644 "$repo_root/etc/greetd/config.toml" /etc/greetd/config.toml
    sudo systemctl enable greetd
  fi
}
