# cachyos-restore: self-sufficient install (no desktop-environment dependency) — design

## Purpose

Today `install.sh` assumes the CachyOS installer's "Hyprland" desktop
environment selection already provides `hyprland`, `noctalia`, the greeter,
and greetd setup, and it only restores packages/dotfiles on top of that.
Investigation showed this assumption doesn't even hold for this machine:
`cachyos-hypr-noctalia` (the meta-package the installer's "Hyprland" option
pulls in) is not installed here. This laptop actually runs plain `hyprland`
+ `uwsm` (pacman) plus `noctalia-git` + `noctalia-greeter-git` (AUR), with a
hand-edited `/etc/greetd/config.toml` that nothing in this repo tracks.

Goal: make `install.sh` fully self-sufficient, so it works starting from a
CachyOS install with **"No Desktop"** selected in the installer — no
desktop-environment package group required at all.

## Manual steps (updated)

1. Run the CachyOS installer with disk encryption enabled.
2. In the desktop environment selector, choose **"No Desktop"** (minimal/base
   install — no DE, no greeter).
3. Reboot. Since no greeter exists yet, log in at the TTY console.
4. Clone this repo and run `./install.sh` (`--dry-run` first to preview).
5. Reboot into the `greetd` → Noctalia greeter that `install.sh` configured.

Documents/Downloads/Pictures and SSH/GPG/credentials are still restored
manually, same as today — out of scope for this change.

## Package list changes

- `pkglist/pacman.txt` gains two explicit, manually-pinned entries:
  `noctalia` and `noctalia-greeter` (CachyOS repo packages, installed via
  `pacman -S --needed`). These substitute for the AUR `-git` equivalents
  this specific laptop runs live — deliberate, not an oversight.
- `pkglist/aur.txt` is unaffected: `scripts/freeze-packages.sh` already
  permanently excludes `noctalia-git`/`noctalia-greeter-git` via its
  `EXCLUDE_AUR` array, regardless of what's installed live.
- `scripts/freeze-packages.sh` currently overwrites `pacman.txt` unconditionally
  from `pacman -Qqen`, which would silently drop the two manually-pinned
  lines on the next re-freeze (this machine will never show `noctalia`/
  `noctalia-greeter` as explicitly-installed via pacman, since it runs the
  AUR versions). Fix: add an `EXTRA_PACMAN=("noctalia" "noctalia-greeter")`
  array, merged and sorted into the `pacman.txt` output alongside the live
  `pacman -Qqen` dump, with a comment explaining why.
- No other package changes: `hyprland`, `uwsm`, `xdg-desktop-portal-hyprland`
  are already explicit in `pkglist/pacman.txt`. `pacman -S --needed -`
  resolves the full dependency graph starting from a bare "No Desktop"
  system same as it does today.

## Greeter setup (new)

`/etc/greetd/config.toml` lives outside `$HOME`, so the existing `home/`
overlay (which does `cp -riv home/. ~/`) can't reach it — nothing in the
repo currently configures the greeter.

- New tracked file: `etc/greetd/config.toml`, mirroring this machine's
  current hand-edited config:
  ```toml
  [terminal]
  vt = 1

  [default_session]
  command = "/usr/bin/noctalia-greeter-session -- --session Hyprland"
  user = "greeter"
  ```
- New module `lib/greeter.sh` (mirrors the existing one-file-per-concern
  pattern: `packages.sh`, `dotfiles.sh`, `fixups.sh`), exposing
  `setup_greeter <repo_root> <dry_run>`:
  - `sudo install -Dm644 "$repo_root/etc/greetd/config.toml" /etc/greetd/config.toml`
  - `sudo systemctl enable --now greetd`
  - Respects `--dry-run` the same way the other stages do (print what would
    run, no changes).
- `install.sh` sources `lib/greeter.sh` and calls `setup_greeter` as a new
  stage, after `overlay_dotfiles` and before (or alongside) `apply_fixups`.
- Nothing else is needed for the greeter itself:
  - `noctalia-greeter`'s own package post-install already runs its system
    setup script automatically (PAM patch, greeter data paths, appearance
    sync) — no scripting needed here.
  - `greetd`'s own package creates the `greeter` system user automatically
    on install — no scripting needed here.
- No competing display manager needs disabling: a "No Desktop" install has
  none pre-installed or pre-enabled.

## Explicitly out of scope

- Removing/archiving the old `cachyos-hyprland` repo — untouched, as before.
- Reconciling `sddm` being present-but-disabled in the current frozen
  `pacman.txt` — pre-existing, unrelated to this change, not touched here.
- Anything about Documents/Downloads/Pictures, SSH/GPG/credentials, browser
  profiles, or other projects' systemd units — unchanged from the existing
  design.
