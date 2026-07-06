# packages — machine reproduction

Manifests of everything explicitly installed, so a fresh machine can be rebuilt
to match this one. Generated from the live system by [`sync.sh`](./sync.sh);
reinstalled by [`restore.sh`](./restore.sh).

| File | What | Source of truth |
|---|---|---|
| `pacman-native.txt` | official-repo packages, explicitly installed | `pacman -Qqen` |
| `aur.txt` | AUR / manually-built packages (`-debug` companions dropped) | `pacman -Qqem` |
| `snap.txt` | snap packages (incl. runtimes) | `snap list` |
| `flatpak.txt` | flatpak apps (currently none) | `flatpak list --app` |

Only *explicitly* installed packages are stored — dependencies are pulled back in
automatically on reinstall, so the list stays small and meaningful (the things
**you** chose, not the thousands of transitive deps).

## Maintaining this machine

After installing or removing anything you care about:

```sh
packages/sync.sh          # regenerate the manifests
git add packages/ && git commit -m "packages: sync"   # commit the diff
```

`git diff packages/` shows exactly what changed since last time — a nice audit of
what you've added/removed.

**Optional — automate it.** Drop a pacman hook so the native/AUR lists refresh on
every `pacman`/`yay` transaction (you still commit manually):

```
# /etc/pacman.d/hooks/sync-pkglist.hook
[Trigger]
Operation = Install
Operation = Remove
Type = Package
Target = *

[Action]
Description = Refreshing package manifests...
When = PostTransaction
Exec = /usr/bin/su - jonasz -c '/home/jonasz/workflow/packages/sync.sh'
```

Not installed by default — it makes the repo tree dirty on every package change,
which some prefer to do by hand. Enable it if you'd rather never forget.

## Reproducing on a new machine

Full new-machine sequence (this repo does both dotfiles **and** packages):

```sh
git clone <this-repo> ~/workflow
~/workflow/dotfiles/install.sh     # symlink configs into $HOME
~/workflow/packages/restore.sh     # reinstall packages
```

`restore.sh` runs `pacman -Syu` for the native list, bootstraps `yay` if missing,
installs the AUR list, then snaps/flatpaks. It's idempotent (`--needed`), so
re-running only fills gaps.

### Before you run restore.sh
- **Enable `[multilib]`** in `/etc/pacman.conf` if you use 32-bit packages
  (Steam, `steamcmd`, `lib32-*`) — uncomment the two `[multilib]` lines first.
- Have `sudo` and a network connection.

### Known caveats
- **AUR drift** — packages can be renamed or removed from the AUR over time
  (e.g. `*-bin` forks). `yay` reports any it can't find; install replacements by
  hand, then `sync.sh` to record them.
- **`qt5-*` modules** in `aur.txt` are foreign because they're no longer in the
  official repos on this install — they'll build from AUR/source, which is slow.
  Prune any you don't actually need before restoring.
- **Snap runtimes** (`core24`, `gnome-*`, `mesa-*`, `bare`, `gtk-common-themes`)
  are listed but get pulled automatically when their app installs — harmless to
  keep, and installing them explicitly is a no-op.
- This captures package *selection*, not their *config* — user config lives in
  `../dotfiles/`, system config (`/etc`) is not tracked here.
