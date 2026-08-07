# cachyos-restore Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `cachyos-restore`, a script-driven repo that, when cloned onto a freshly-installed CachyOS machine (Hyprland desktop environment already chosen in the installer), restores all extra packages and app dotfiles to match the current machine's state.

**Architecture:** A single `install.sh` orchestrator sources three small library scripts (`lib/packages.sh`, `lib/dotfiles.sh`, `lib/fixups.sh`), each responsible for one stage. Two standalone `scripts/` tools regenerate the frozen package lists and dotfile snapshot from the live system before future reinstalls — they are not run by `install.sh`, only by hand, ahead of a reinstall. `home/` is a plain data tree, not code.

**Tech Stack:** Bash (targeting the `bash` shipped by CachyOS, no bashisms requiring bash 5+ beyond what's already default), `pacman`, `paru`, `hyprcursor-util`, `gsettings`. No external test framework — `shellcheck` (installed as an OS package) plus explicit manual verification commands with documented expected output serve as this project's test suite, since there's no runtime here that unit tests can safely exercise (the actual `pacman -S`/`cp` operations are inherently host-mutating and are only meant to run once, on a fresh machine).

## Global Constraints

- Repo root: `/home/csaba/ai_projects/cachyos-restore` (already git-initialized; the design spec is already committed there at `docs/superpowers/specs/2026-08-07-cachyos-restore-design.md` — read it if anything below is ambiguous).
- `install.sh` and all `lib/*.sh` must be idempotent / safe to re-run (per the spec): package installs use `--needed`, dotfile copies use `-i` (interactive, never silently overwrite).
- `pkglist/aur.txt` excludes `noctalia-git` and `noctalia-greeter-git` (installer already provides them).
- `home/.config/systemd/user/` is explicitly out of scope — do not add it anywhere in this plan.
- Browser profile directories and secrets (SSH/GPG/credentials) are explicitly out of scope — do not add them anywhere in this plan.
- Every shell script must pass `shellcheck` with zero warnings before being committed.
- Target shebang for all scripts: `#!/usr/bin/env bash`, with `set -euo pipefail` at the top.

---

### Task 1: Repo scaffolding and shellcheck tooling

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/.gitignore`
- Create: `/home/csaba/ai_projects/cachyos-restore/README.md` (stub, filled in fully by Task 8)

**Interfaces:**
- Produces: nothing consumed by other tasks — this is pure scaffolding.

- [ ] **Step 1: Confirm `shellcheck` is available, install if missing**

Run: `shellcheck --version || sudo pacman -S --needed shellcheck`

Expected: a version banner printed (either immediately, or after the install completes).

- [ ] **Step 2: Create `.gitignore`**

```gitignore
*.bak
*.orig
.DS_Store
```

- [ ] **Step 3: Create a stub `README.md`**

```markdown
# cachyos-restore

Restores this machine's packages and app dotfiles after a fresh CachyOS
install. See `docs/superpowers/specs/2026-08-07-cachyos-restore-design.md`
for the full design.

(Full usage instructions land in a later commit.)
```

- [ ] **Step 4: Commit**

```bash
cd /home/csaba/ai_projects/cachyos-restore
git add .gitignore README.md
git commit -m "Scaffold repo: gitignore and README stub"
```

---

### Task 2: Package snapshot script + frozen pkglists

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/scripts/freeze-packages.sh`
- Create: `/home/csaba/ai_projects/cachyos-restore/pkglist/pacman.txt`
- Create: `/home/csaba/ai_projects/cachyos-restore/pkglist/aur.txt`

**Interfaces:**
- Produces: `pkglist/pacman.txt` (one package name per line, sorted), `pkglist/aur.txt` (same format, excludes `noctalia-git`/`noctalia-greeter-git`). Task 4's `lib/packages.sh` consumes both files by path, relative to repo root.

- [ ] **Step 1: Write `scripts/freeze-packages.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXCLUDE_AUR=("noctalia-git" "noctalia-greeter-git")

mkdir -p "$REPO_ROOT/pkglist"

pacman -Qqe | sort > "$REPO_ROOT/pkglist/pacman.txt"

pacman -Qqem | sort | grep -vxF -f <(printf '%s\n' "${EXCLUDE_AUR[@]}") \
  > "$REPO_ROOT/pkglist/aur.txt" || true

echo "Wrote $(wc -l < "$REPO_ROOT/pkglist/pacman.txt") packages to pkglist/pacman.txt"
echo "Wrote $(wc -l < "$REPO_ROOT/pkglist/aur.txt") packages to pkglist/aur.txt (excluding: ${EXCLUDE_AUR[*]})"
```

- [ ] **Step 2: Make it executable and run it**

```bash
chmod +x /home/csaba/ai_projects/cachyos-restore/scripts/freeze-packages.sh
/home/csaba/ai_projects/cachyos-restore/scripts/freeze-packages.sh
```

Expected output:
```
Wrote 199 packages to pkglist/pacman.txt
Wrote 2 packages to pkglist/aur.txt (excluding: noctalia-git noctalia-greeter-git)
```

(The exact count may differ slightly if packages were installed/removed since this plan was written — that's fine, the script is meant to reflect whatever the live system currently has. What must hold is: `pkglist/aur.txt` contains `hyprmon-bin` and `twingate`, and does NOT contain `noctalia-git` or `noctalia-greeter-git`.)

- [ ] **Step 3: Verify the exclusion held**

Run: `grep -c noctalia /home/csaba/ai_projects/cachyos-restore/pkglist/aur.txt || true`

Expected: `0` (grep finds no matches, so with `set -e` off for this check the `|| true` keeps the command from failing the shell — the printed count is `0`).

- [ ] **Step 4: Run shellcheck**

Run: `shellcheck /home/csaba/ai_projects/cachyos-restore/scripts/freeze-packages.sh`

Expected: no output, exit code 0.

- [ ] **Step 5: Commit**

```bash
cd /home/csaba/ai_projects/cachyos-restore
git add scripts/freeze-packages.sh pkglist/pacman.txt pkglist/aur.txt
git commit -m "Add package freeze script and initial frozen pkglists"
```

---

### Task 3: Dotfile collection script + populate `home/` tree

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/scripts/collect-dotfiles.sh`
- Create: `/home/csaba/ai_projects/cachyos-restore/home/.zshrc`
- Create: `/home/csaba/ai_projects/cachyos-restore/home/.bashrc`
- Create: `/home/csaba/ai_projects/cachyos-restore/home/.config/{hypr,noctalia,ghostty,kitty,btop,micro,yazi,zed,git,gtk-3.0,gtk-4.0,flameshot,superfile}/...` (whole directory trees, copied)
- Create: `/home/csaba/ai_projects/cachyos-restore/home/.config/mimeapps.list`
- Create: `/home/csaba/ai_projects/cachyos-restore/home/.config/dolphinrc`

**Interfaces:**
- Produces: `home/` tree, mirroring `$HOME`. Task 5's `lib/dotfiles.sh` consumes this by overlaying `home/.` onto `$HOME` with `cp -riv`.

- [ ] **Step 1: Write `scripts/collect-dotfiles.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$REPO_ROOT/home"

CONFIG_DIRS=(hypr noctalia ghostty kitty btop micro yazi zed git gtk-3.0 gtk-4.0 flameshot superfile)
CONFIG_FILES=(mimeapps.list dolphinrc)
HOME_FILES=(.zshrc .bashrc)

mkdir -p "$DEST/.config"

for d in "${CONFIG_DIRS[@]}"; do
  if [ -d "$HOME/.config/$d" ]; then
    rsync -a --delete --exclude='.git' "$HOME/.config/$d/" "$DEST/.config/$d/"
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
```

- [ ] **Step 2: Confirm `rsync` is available (used for directory sync)**

Run: `rsync --version >/dev/null && echo ok || sudo pacman -S --needed rsync`

Expected: `ok` printed, or rsync gets installed then rerun succeeds.

- [ ] **Step 3: Make it executable and run it**

```bash
chmod +x /home/csaba/ai_projects/cachyos-restore/scripts/collect-dotfiles.sh
/home/csaba/ai_projects/cachyos-restore/scripts/collect-dotfiles.sh
```

Expected: one "Collected ..." line per directory/file that exists on this machine (all 12 `CONFIG_DIRS`, both `CONFIG_FILES`, both `HOME_FILES` should print "Collected", since Task exploration confirmed all of them exist on this machine — no "Skipping" lines expected).

- [ ] **Step 4: Verify `~/.config/hypr`'s git history was NOT copied (per spec: flatten, no history)**

Run: `find /home/csaba/ai_projects/cachyos-restore/home/.config/hypr -maxdepth 1 -name .git`

Expected: no output (the `--exclude='.git'` in the rsync command keeps it out).

- [ ] **Step 5: Verify no browser profile directories leaked in**

Run: `ls /home/csaba/ai_projects/cachyos-restore/home/.config/ | grep -iE 'brave|chromium|chrome|edge|opera|vivaldi|zen|helium' || echo "none found"`

Expected: `none found`.

- [ ] **Step 6: Run shellcheck**

Run: `shellcheck /home/csaba/ai_projects/cachyos-restore/scripts/collect-dotfiles.sh`

Expected: no output, exit code 0.

- [ ] **Step 7: Commit**

```bash
cd /home/csaba/ai_projects/cachyos-restore
git add scripts/collect-dotfiles.sh home/
git commit -m "Add dotfile collection script and populate home/ tree from live system"
```

Note: this commit is expected to be large (it's a full snapshot of ~12 config directories). That's normal for this task.

---

### Task 4: `lib/packages.sh` — package install stage

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/lib/packages.sh`

**Interfaces:**
- Consumes: `pkglist/pacman.txt`, `pkglist/aur.txt` (from Task 2), located via `$REPO_ROOT` passed in as `$1`.
- Produces: function `install_packages "$REPO_ROOT" [--dry-run]`, called by Task 7's `install.sh`.

- [ ] **Step 1: Write `lib/packages.sh`**

```bash
#!/usr/bin/env bash
# Sourced by install.sh — not meant to be run standalone.

install_packages() {
  local repo_root="$1"
  local dry_run="${2:-}"

  if ! command -v paru >/dev/null 2>&1; then
    echo "==> paru not found, installing it first"
    if [ "$dry_run" = "--dry-run" ]; then
      echo "[dry-run] would install paru from AUR (git clone + makepkg)"
    else
      sudo pacman -S --needed --noconfirm base-devel git
      local tmp
      tmp="$(mktemp -d)"
      git clone https://aur.archlinux.org/paru.git "$tmp/paru"
      (cd "$tmp/paru" && makepkg -si --noconfirm)
      rm -rf "$tmp"
    fi
  fi

  echo "==> Installing pacman packages from pkglist/pacman.txt"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: sudo pacman -S --needed - < $repo_root/pkglist/pacman.txt"
  else
    sudo pacman -S --needed - < "$repo_root/pkglist/pacman.txt"
  fi

  echo "==> Installing AUR packages from pkglist/aur.txt"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: paru -S --needed - < $repo_root/pkglist/aur.txt"
  else
    paru -S --needed - < "$repo_root/pkglist/aur.txt"
  fi
}
```

- [ ] **Step 2: Run shellcheck (source-mode, since this file isn't directly executable)**

Run: `shellcheck --shell=bash /home/csaba/ai_projects/cachyos-restore/lib/packages.sh`

Expected: no output, exit code 0.

- [ ] **Step 3: Smoke-test the function in isolation via `--dry-run`**

```bash
cd /home/csaba/ai_projects/cachyos-restore
bash -c 'source lib/packages.sh && install_packages "$(pwd)" --dry-run'
```

Expected output includes these three lines (paru is already installed on this machine, so the "installing paru" branch is skipped):
```
==> Installing pacman packages from pkglist/pacman.txt
[dry-run] would run: sudo pacman -S --needed - < /home/csaba/ai_projects/cachyos-restore/pkglist/pacman.txt
==> Installing AUR packages from pkglist/aur.txt
[dry-run] would run: paru -S --needed - < /home/csaba/ai_projects/cachyos-restore/pkglist/aur.txt
```

No `sudo` prompt should appear (dry-run never calls `sudo pacman`/`paru` for real).

- [ ] **Step 4: Commit**

```bash
git add lib/packages.sh
git commit -m "Add package install stage (lib/packages.sh) with dry-run support"
```

---

### Task 5: `lib/dotfiles.sh` — dotfile overlay stage

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/lib/dotfiles.sh`

**Interfaces:**
- Consumes: `home/` tree (from Task 3), located via `$REPO_ROOT` passed in as `$1`.
- Produces: function `overlay_dotfiles "$REPO_ROOT" [--dry-run]`, called by Task 7's `install.sh`.

- [ ] **Step 1: Write `lib/dotfiles.sh`**

```bash
#!/usr/bin/env bash
# Sourced by install.sh — not meant to be run standalone.

overlay_dotfiles() {
  local repo_root="$1"
  local dry_run="${2:-}"

  echo "==> Overlaying dotfiles from home/ onto \$HOME"
  if [ "$dry_run" = "--dry-run" ]; then
    echo "[dry-run] would run: cp -riv $repo_root/home/. $HOME/"
  else
    cp -riv "$repo_root/home/." "$HOME/"
  fi
}
```

- [ ] **Step 2: Run shellcheck**

Run: `shellcheck --shell=bash /home/csaba/ai_projects/cachyos-restore/lib/dotfiles.sh`

Expected: no output, exit code 0.

- [ ] **Step 3: Smoke-test via `--dry-run`**

```bash
cd /home/csaba/ai_projects/cachyos-restore
bash -c 'source lib/dotfiles.sh && overlay_dotfiles "$(pwd)" --dry-run'
```

Expected output:
```
==> Overlaying dotfiles from home/ onto $HOME
[dry-run] would run: cp -riv /home/csaba/ai_projects/cachyos-restore/home/. /home/csaba/
```

- [ ] **Step 4: Smoke-test a real (non-destructive) run into a scratch `$HOME`**

This verifies the real `cp -riv` branch actually copies files, without touching the real home directory.

```bash
cd /home/csaba/ai_projects/cachyos-restore
SCRATCH="$(mktemp -d)"
bash -c "source lib/dotfiles.sh && HOME='$SCRATCH' overlay_dotfiles '$(pwd)'" | tail -5
ls "$SCRATCH/.config" | head -5
rm -rf "$SCRATCH"
```

Expected: the `ls` shows config directories like `hypr`, `noctalia`, etc. copied into the scratch dir.

- [ ] **Step 5: Commit**

```bash
git add lib/dotfiles.sh
git commit -m "Add dotfile overlay stage (lib/dotfiles.sh) with dry-run support"
```

---

### Task 6: `lib/fixups.sh` — post-copy fixups stage

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/lib/fixups.sh`

**Interfaces:**
- Consumes: nothing from other tasks (operates on system state directly).
- Produces: function `apply_fixups [--dry-run]`, called by Task 7's `install.sh`.

- [ ] **Step 1: Write `lib/fixups.sh`**

```bash
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
```

- [ ] **Step 2: Run shellcheck**

Run: `shellcheck --shell=bash /home/csaba/ai_projects/cachyos-restore/lib/fixups.sh`

Expected: no output, exit code 0.

- [ ] **Step 3: Smoke-test via `--dry-run`**

```bash
cd /home/csaba/ai_projects/cachyos-restore
bash -c 'source lib/fixups.sh && apply_fixups --dry-run'
```

Expected output:
```
==> Regenerating capitaine-cursors hyprcursor theme
[dry-run] would run hyprcursor-util --extract and --create for capitaine-cursors (needs xcur2png)
==> Re-applying GTK theme (materia-dark)
[dry-run] would symlink gtk-4.0 theme assets and run gsettings set for gtk-theme/icon-theme
```

No filesystem changes, no `gsettings` calls made (verify by running `gsettings get org.gnome.desktop.interface gtk-theme` before and after the dry-run and confirming it's unchanged).

- [ ] **Step 4: Commit**

```bash
git add lib/fixups.sh
git commit -m "Add post-copy fixups stage (lib/fixups.sh) with dry-run support"
```

---

### Task 7: `install.sh` orchestrator

**Files:**
- Create: `/home/csaba/ai_projects/cachyos-restore/install.sh`

**Interfaces:**
- Consumes: `install_packages()` from `lib/packages.sh` (Task 4), `overlay_dotfiles()` from `lib/dotfiles.sh` (Task 5), `apply_fixups()` from `lib/fixups.sh` (Task 6).
- Produces: the top-level entry point a user runs after cloning the repo.

- [ ] **Step 1: Write `install.sh`**

```bash
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
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x /home/csaba/ai_projects/cachyos-restore/install.sh`

- [ ] **Step 3: Run shellcheck**

Run: `shellcheck /home/csaba/ai_projects/cachyos-restore/install.sh /home/csaba/ai_projects/cachyos-restore/lib/*.sh`

Expected: no output, exit code 0. (This also re-checks the lib files together with the orchestrator, catching any sourcing-related warnings shellcheck can only see in context.)

- [ ] **Step 4: End-to-end dry-run test**

```bash
cd /home/csaba/ai_projects/cachyos-restore
./install.sh --dry-run
```

Expected: all four stage banners print in order (`==> Running in --dry-run mode`, `==> Installing pacman packages...`, `==> Installing AUR packages...`, `==> Overlaying dotfiles...`, `==> Regenerating capitaine-cursors...`, `==> Re-applying GTK theme...`), followed by the "Done. Things this script did NOT restore" block. No `sudo` prompt, no actual file changes (spot-check: `gsettings get org.gnome.desktop.interface gtk-theme` unchanged from before the run).

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "Add install.sh orchestrator wiring all stages together"
```

---

### Task 8: Full README

**Files:**
- Modify: `/home/csaba/ai_projects/cachyos-restore/README.md` (replace the Task 1 stub)

**Interfaces:**
- Consumes: nothing (documentation only).

- [ ] **Step 1: Replace `README.md` with full documentation**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
cd /home/csaba/ai_projects/cachyos-restore
git add README.md
git commit -m "Write full README covering usage, scope, and snapshot regeneration"
```

---

## Post-plan: push to GitHub (not automated by this plan)

This plan builds and commits everything locally. Creating the GitHub repo
and pushing (`gh repo create csabahtoth/cachyos-restore --public --source=. --push`
or the manual `git remote add` + `git push` equivalent) is a separate,
explicit step to take with the user's confirmation once all 8 tasks are
reviewed — not something to do unprompted mid-plan.
