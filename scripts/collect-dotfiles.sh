#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/home"

CONFIG_DIRS=(hypr noctalia ghostty kitty btop micro yazi zed git gtk-3.0 gtk-4.0 flameshot superfile)
CONFIG_FILES=(mimeapps.list dolphinrc)
HOME_FILES=(.zshrc .bashrc .gitconfig)

mkdir -p "$DEST/.config"

for d in "${CONFIG_DIRS[@]}"; do
  if [ -d "$HOME/.config/$d" ]; then
    rsync_excludes=(--exclude='.git')
    case "$d" in
      yazi) rsync_excludes+=(--exclude='vfs.toml') ;;
      gtk-4.0) rsync_excludes+=(--exclude='servers') ;;
      noctalia) rsync_excludes+=(--exclude='plugins-v4-legacy-backup-*') ;;
    esac
    rsync -a --delete "${rsync_excludes[@]}" "$HOME/.config/$d/" "$DEST/.config/$d/"
    echo "Collected .config/$d"
  else
    echo "Skipping .config/$d (not present on this machine)"
  fi
done

for f in "${CONFIG_FILES[@]}"; do
  if [ -e "$HOME/.config/$f" ]; then
    cp "$HOME/.config/$f" "$DEST/.config/$f"
    echo "Collected .config/$f"
  fi
done

for f in "${HOME_FILES[@]}"; do
  if [ -e "$HOME/$f" ]; then
    cp "$HOME/$f" "$DEST/$f"
    echo "Collected $f"
  fi
done
