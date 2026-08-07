#!/usr/bin/env bash
# Sourced by install.sh — not meant to be run standalone.

apply_fixups() {
  local dry_run="${1:-}"

  echo "==> Regenerating capitaine-cursors hyprcursor theme"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run hyprcursor-util --extract and --create for capitaine-cursors (needs xcur2png)"
  else
    if [ ! -d /usr/share/icons/capitaine-cursors ]; then
      echo "WARNING: /usr/share/icons/capitaine-cursors not found — is capitaine-cursors installed? Skipping cursor regen."
    else
      command -v xcur2png >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm xcur2png
      local tmp
      tmp="$(mktemp -d)"
      hyprcursor-util --extract /usr/share/icons/capitaine-cursors -o "$tmp"
      # hyprcursor-util has no flag to set the theme name; it's read from
      # manifest.hl, and --create prefixes the output dir with "theme_".
      sed -i 's/^name = .*/name = capitaine-cursors-hypr/' "$tmp/extracted_capitaine-cursors/manifest.hl"
      mkdir -p "$HOME/.local/share/icons"
      hyprcursor-util --create "$tmp/extracted_capitaine-cursors" -o "$HOME/.local/share/icons"
      rm -rf "$HOME/.local/share/icons/capitaine-cursors-hypr"
      mv "$HOME/.local/share/icons/theme_capitaine-cursors-hypr" "$HOME/.local/share/icons/capitaine-cursors-hypr"
      rm -rf "$tmp"
    fi
  fi
}
