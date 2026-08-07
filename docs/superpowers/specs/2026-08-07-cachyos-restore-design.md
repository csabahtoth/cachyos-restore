# cachyos-restore: full-machine restore script — design

## Purpose

After a fresh, encrypted CachyOS install (selecting "Hyprland" as the desktop
environment in the installer), restore the machine to its current state:
all packages, all Hyprland/Noctalia and app dotfiles, minus a few things
handled manually.

Public repo: `github.com/csabahtoth/cachyos-restore`.

## Manual steps (out of scope for the script)

1. Run the CachyOS installer with disk encryption enabled.
2. In the desktop environment selector, choose **"Hyprland"**. This pulls in
   the base `cachyos-hypr-noctalia` package/config bundle
   (https://github.com/CachyOS/cachyos-hypr-noctalia) and the greeter
   automatically — no manual hyprland/greetd install needed.
3. Reboot to the greeter, log in.
4. Restore Documents/Downloads/Pictures and SSH/GPG keys/credentials from
   wherever they're backed up separately. Not tracked by this repo.
5. Clone `cachyos-restore` and run `./install.sh`.

## Repo layout

```
cachyos-restore/
├── install.sh              # orchestrator, idempotent, safe to re-run
├── pkglist/
│   ├── pacman.txt           # frozen `pacman -Qqe` snapshot
│   └── aur.txt               # frozen paru-only package snapshot
├── home/                     # overlay tree, mirrors $HOME structure
│   ├── .zshrc
│   ├── .bashrc
│   └── .config/
│       ├── hypr/              # flattened copy of current ~/.config/hypr
│       ├── noctalia/
│       ├── ghostty/ kitty/ btop/ micro/ yazi/ zed/ git/
│       ├── gtk-3.0/ gtk-4.0/ mimeapps.list dolphinrc flameshot/ superfile/
│       └── systemd/user/      # user units (e.g. stock-checker timer)
└── README.md                 # what's included, what's excluded and why
```

## install.sh stages

1. **Packages.** Install `paru` if missing. `pacman -S --needed -` from
   `pkglist/pacman.txt`, then `paru -S --needed -` from `pkglist/aur.txt`
   (which excludes `noctalia-git`/`noctalia-greeter-git` — see below).
   `--needed` skips already-installed packages, making this safe to re-run;
   if the installer's Hyprland bundle ever ships non-`-git` `noctalia`
   packages instead, `--needed` combined with the exclusion means nothing
   auto-corrects that mismatch, so a quick `pacman -Qe | grep noctalia`
   sanity check after install is worth doing once.
2. **Dotfiles overlay.** `cp -riv home/. ~/` — interactive, won't silently
   clobber existing files on a re-run.
3. **Known post-copy fixups.**
   - Regenerate the `capitaine-cursors` hyprcursor theme via
     `hyprcursor-util` — it lives at
     `~/.local/share/icons/capitaine-cursors-hypr/`, outside
     `~/.config/hypr`, and isn't tracked by any repo. Exact commands
     documented in the `hypr-noctalia-migration` project's memory/CLAUDE.md.
   - Re-apply GTK theme symlink + `gsettings` calls (materia-dark GTK/icon
     theme), carried over from the old `cachyos-hyprland` install script.
4. **Reminder output.** Print what was *not* automated: Documents/Downloads/
   Pictures, SSH/GPG keys/credentials, browser logins/bookmarks (each
   browser has its own account sync).

## Explicit exclusions

- **All browser profile directories** (Brave, Chromium, Edge, Opera,
  Vivaldi, Zen, Helium, google-chrome) under `~/.config/` — large, contain
  cache/cookies/login data, restored via each browser's own account sync
  rather than dotfiles.
- **Secrets** — SSH keys, GPG keys, any credentials. Manual restore, same
  bucket as the documents backup.
- **`~/.config/hypr`'s prior local-only git history.** That repo was never
  pushed anywhere; it gets flattened to its current state when copied into
  `home/.config/hypr/`. The migration reasoning behind that config stays
  documented in the `hypr-noctalia-migration` project (see its `CLAUDE.md`
  and the `hypr_noctalia_migration_project` memory entry).

## Not touched by this project

- The existing `cachyos-hyprland` repo (old generic starter script,
  superseded by this one) is left as-is for now — no archiving, no
  deletion.

## Data sources for the frozen snapshots

- `pkglist/pacman.txt` ← `pacman -Qqe` (199 packages as of 2026-08-07)
- `pkglist/aur.txt` ← `pacman -Qqem`, **minus `noctalia-git` and
  `noctalia-greeter-git`**. Those two are already installed by the CachyOS
  installer's "Hyprland" desktop environment selection (part of the
  `cachyos-hypr-noctalia` bundle) — reinstalling them from AUR would be
  redundant. The remaining AUR packages (`hyprmon-bin`, `twingate`) are
  genuinely extra and belong in the frozen list.
- `home/.config/*` ← copied directly from the live `~/.config/` tree,
  restricted to the whitelist above.

These are point-in-time snapshots, not auto-synced. Regenerate them before
the next reinstall if the system has drifted (new packages installed,
configs changed) — this repo does not attempt to stay continuously in sync
with the live system.
