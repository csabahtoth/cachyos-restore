#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=""

if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN="--dry-run"
  echo "==> Running in --dry-run mode: no changes will be made"
fi

# shellcheck source=lib/packages.sh
source "$REPO_ROOT/lib/packages.sh"
# shellcheck source=lib/dotfiles.sh
source "$REPO_ROOT/lib/dotfiles.sh"
# shellcheck source=lib/fixups.sh
source "$REPO_ROOT/lib/fixups.sh"

install_packages "$REPO_ROOT" "$DRY_RUN"
overlay_dotfiles "$REPO_ROOT" "$DRY_RUN"
apply_fixups "$DRY_RUN"

cat <<'EOF'

==> Done. Things this script did NOT restore — handle these manually:
  - Documents/Downloads/Pictures (restore from your own backup)
  - SSH keys, GPG keys, other credentials (restore from your own backup)
  - Browser logins/bookmarks/extensions (log in and let each browser's
    account sync restore them)
  - systemd user units owned by other ai_projects subprojects, e.g.
    stock-checker — re-run that project's own install steps

A reboot is recommended before your first Hyprland session with the new
configs applied.
EOF
