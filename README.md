# cachyos-restore

Restores this machine's extra packages and app dotfiles after a fresh,
encrypted CachyOS install. Full design rationale is in
`docs/superpowers/specs/2026-08-07-cachyos-restore-design.md`.

## Usage

1. Run the CachyOS installer with disk encryption enabled.
2. In the desktop environment selector, choose **Hyprland**. This installs
   the base `cachyos-hypr-noctalia` package/config bundle
   (https://github.com/CachyOS/cachyos-hypr-noctalia) and the greeter for
   you — do not select "No Desktop".
3. Reboot to the greeter, log in.
4. Clone this repo and run the installer:
   ```
   git clone https://github.com/csabahtoth/cachyos-restore.git
   cd cachyos-restore
   ./install.sh
   ```
   Add `--dry-run` first if you want to preview what it will do without
   changing anything.
5. Reboot.

## What it restores

- All extra pacman packages (`pkglist/pacman.txt`) and AUR packages
  (`pkglist/aur.txt` — deliberately excludes `noctalia-git` and
  `noctalia-greeter-git`, since step 2 above already installs those).
- Dotfiles for: Hyprland, Noctalia, Ghostty, Kitty, btop, micro, yazi, Zed,
  git, GTK 3/4 theming, Flameshot, Superfile, plus `mimeapps.list`,
  `dolphinrc`, `.zshrc`, `.bashrc`.
- The `capitaine-cursors` hyprcursor theme (regenerated, since it lives
  outside any tracked config directory).
- The Materia-dark GTK/icon theme symlinks and `gsettings` values.

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
./scripts/freeze-packages.sh    # rewrites pkglist/pacman.txt and pkglist/aur.txt
./scripts/collect-dotfiles.sh   # rewrites home/ from the live ~/.config
```

Review the resulting `git diff` before committing — these scripts overwrite
their target files unconditionally.
