# cachyos-restore

Restores this machine's extra packages and app dotfiles after a fresh,
encrypted CachyOS install — including the Hyprland/Noctalia desktop stack
itself. Full design rationale is in
`docs/superpowers/specs/2026-08-07-cachyos-restore-design.md` and
`docs/superpowers/specs/2026-08-07-no-desktop-install-design.md`.

## Usage

1. Run the CachyOS installer with disk encryption enabled.
2. In the desktop environment selector, choose **"No Desktop"** (minimal/
   base install — no DE, no greeter). `install.sh` sets up Hyprland,
   Noctalia, and the greeter itself; nothing needs to be pre-selected.
3. Reboot. There's no greeter yet at this point, so log in at the TTY
   console.
4. Clone this repo and run the installer:
   ```
   git clone https://github.com/csabahtoth/cachyos-restore.git
   cd cachyos-restore
   ./install.sh
   ```
   Add `--dry-run` first if you want to preview what it will do without
   changing anything.
5. Reboot into the `greetd` → Noctalia greeter that `install.sh` configured.

## What it restores

- All extra pacman packages (`pkglist/pacman.txt` — including `hyprland`,
  `uwsm`, `noctalia`, and `noctalia-greeter`, the CachyOS repo packages,
  pinned deliberately even though this machine itself runs the AUR `-git`
  equivalents) and AUR packages (`pkglist/aur.txt` — permanently excludes
  `noctalia-git`/`noctalia-greeter-git` in favor of the repo versions
  above); the dotfiles config was captured from the `-git` build, so check
  Noctalia's settings after first boot in case the stable release's config
  schema has drifted.
- `/etc/greetd/config.toml` and an enabled `greetd` service, so a fresh
  machine boots straight into the Noctalia greeter after the reboot in
  step 5.
- Dotfiles for: Hyprland, Noctalia, Ghostty, Kitty, btop, micro, yazi, Zed,
  git, GTK 3/4 theming, Flameshot, Superfile, plus `mimeapps.list`,
  `dolphinrc`, `.zshrc`, `.bashrc`, `.gitconfig`.
- `~/.local/state/noctalia/settings.toml` — Noctalia's authoritative runtime
  config (`~/.config/noctalia/settings.json` is a stale, non-authoritative
  duplicate). This is what carries the enabled plugin list and plugin source
  URLs (`noctalia-dev/official-plugins`, `noctalia-dev/community-plugins`);
  Noctalia clones and materializes the plugins itself from those URLs on
  first launch after reboot, so no separate plugin-install step is needed —
  the regenerable clone/build caches (`plugins/sources`,
  `plugins/materialized`, `plugin-cache`) are deliberately not backed up.
- The `capitaine-cursors` hyprcursor theme (regenerated, since it lives
  outside any tracked config directory).

## What it deliberately does NOT restore

- **Documents/Downloads/Pictures** — restore from your own backup.
- **SSH keys, GPG keys, credentials** — restore from your own backup.
- **Browser profiles** (Brave, Chromium, Edge, Opera, Vivaldi, Zen, Helium,
  Chrome) — log in and let each browser's own account sync restore
  bookmarks/logins/extensions.
- **systemd user units owned by other `ai_projects` subprojects** (e.g.
  `stock-checker`'s timer) — re-run that project's own install steps
  separately.

## Regenerating the frozen snapshots

Before your *next* reinstall, if packages or dotfiles have drifted since
the frozen snapshot was taken, regenerate them from the live system:

```
./scripts/freeze-packages.sh    # rewrites pkglist/pacman.txt (always keeps
                                 # noctalia/noctalia-greeter pinned in) and
                                 # pkglist/aur.txt
./scripts/collect-dotfiles.sh   # rewrites home/ from the live ~/.config
```

Review the resulting `git diff` before committing — these scripts overwrite
their target files unconditionally.
