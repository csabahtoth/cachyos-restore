#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/home"

CONFIG_DIRS=(hypr noctalia ghostty kitty btop micro yazi zed git gtk-3.0 gtk-4.0 superfile)
CONFIG_FILES=(mimeapps.list)
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

# Noctalia's authoritative runtime settings (plugins enabled/sources, hooks,
# templates) live in the state dir, not .config — .config/noctalia/settings.json
# is a stale, non-authoritative duplicate. Only the settings.toml file itself is
# captured; plugins/sources, plugins/materialized, and plugin-cache are
# regenerable clone/build caches Noctalia rebuilds from the source URLs on
# first launch, so they're deliberately left out.
if [ -e "$HOME/.local/state/noctalia/settings.toml" ]; then
  mkdir -p "$DEST/.local/state/noctalia"
  # Strip [plugin_settings."pozzoo/hassio"] — holds a live Home Assistant
  # long-lived access token, not safe to commit. Re-enter it manually in
  # Noctalia's plugin settings after a restore.
  awk '
    /^\[plugin_settings\."pozzoo\/hassio"\]/ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip
  ' "$HOME/.local/state/noctalia/settings.toml" > "$DEST/.local/state/noctalia/settings.toml"
  echo "Collected .local/state/noctalia/settings.toml (hassio token redacted)"
fi
