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
      hyprcursor-util --create "$tmp" -o "$HOME/.local/share/icons" -n capitaine-cursors-hypr
      rm -rf "$tmp"
    fi
  fi

  echo "==> Re-applying GTK theme (materia-dark)"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would symlink gtk-4.0 theme assets and run gsettings set for gtk-theme/icon-theme"
  else
    mkdir -p "$HOME/.config/gtk-4.0"
    ln -sf /usr/share/themes/Materia-dark/gtk-4.0/gtk.css "$HOME/.config/gtk-4.0/"
    ln -sf /usr/share/themes/Materia-dark/gtk-4.0/assets/ "$HOME/.config/gtk-4.0/"
    gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark"
    gsettings set org.gnome.desktop.interface icon-theme "breeze-dark"
  fi
}
