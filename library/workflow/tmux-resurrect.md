---
project: workflow
type: reference
audience: both
updated: 2026-07-06
tags: [tmux, systemd, dotfiles]
summary: "Why tmux-resurrect autosave silently died (status off blocks continuum's hook), the systemd --user timer fix, and the daily tracked snapshot that makes session layout portable. Units live in dotfiles/.config/systemd/user/."
---

# tmux-resurrect interval save fix

## Problem

tmux-resurrect wasn't being auto-saved on an interval. Last save was from
Jun 16, three weeks stale.

## Root cause

tmux-continuum (the plugin responsible for interval autosave) has no
background daemon. It triggers a save by embedding a shell command inside
the `status-right` string:

```
status-right "#(/home/jonasz/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)"
```

tmux only re-evaluates `#(...)` commands in the status line when the status
bar actually redraws, on each `status-interval` tick. `~/.tmux.conf` sets:

```
set-option -g status off
```

so the status bar never redraws, the save script never runs, and autosave
silently does nothing — no error, just never fires.

## Fix

Replaced continuum's status-bar-hook save with a systemd `--user` timer that
runs independent of the status bar or tmux UI state.

**`~/.config/systemd/user/tmux-resurrect-save.service`**
```ini
[Unit]
Description=tmux-resurrect interval save

[Service]
Type=oneshot
ExecCondition=/bin/sh -c '/usr/bin/tmux info >/dev/null 2>&1'
ExecStart=%h/.tmux/plugins/tmux-resurrect/scripts/save.sh quiet
```

`ExecCondition` makes the service silently no-op (not a failure) when no
tmux server is running, e.g. right after boot before tmux has started.

**`~/.config/systemd/user/tmux-resurrect-save.timer`**
```ini
[Unit]
Description=Run tmux-resurrect save every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=tmux-resurrect-save.service

[Install]
WantedBy=timers.target
```

Enabled with:
```
systemctl --user daemon-reload
systemctl --user enable --now tmux-resurrect-save.timer
```

**`~/.tmux.conf`** — added after `@continuum-restore 'on'`:
```
# Interval saving is handled by a systemd --user timer (tmux-resurrect-save.timer)
# instead of continuum's status-bar hook, since `status off` prevents that hook
# from ever firing. This just disables continuum's own periodic save.
set -g @continuum-save-interval '0'
```

`@continuum-restore 'on'` was left untouched, so restore-on-tmux-start still
works. Only the interval-save mechanism changed.

## Portability — daily snapshot into the repo (2026-07-06)

Save files are machine state (`~/.local/share/tmux/resurrect/`, one per 5 min)
and are **not** tracked wholesale. Instead, one file is:

- `dotfiles/.local/share/tmux/resurrect/tmux_resurrect_snapshot.txt` — a copy of
  the newest save, refreshed daily by `tmux-resurrect-snapshot.timer`
  (`OnCalendar=daily`, `Persistent=true` → a run missed while powered off fires
  at next boot). The service runs
  `.config/scripts/tmux-resurrect-snapshot.sh`, which copies `last`'s target
  into the repo and **auto-commits just that file** (pathspec-limited; skips
  when unchanged, so no daily noise).
- **New machine:** `install.sh` now does the whole deploy — clones TPM +
  runs `bin/install_plugins` (without this, `.tmux.conf`'s `run tpm` fails
  silently and resurrect never exists), symlinks the snapshot into the
  resurrect dir, points `last` at it when no local saves exist (so the first
  tmux start restores the snapshotted layout via continuum), and
  `daemon-reload` + `enable --now` both timers.

## Notes
- Resurrect's save files live at `~/.local/share/tmux/resurrect/` (XDG data
  dir), not `~/.tmux/resurrect/` — this version of the plugin defaults to
  XDG.
- The existing `prefix + b` bind that toggles the status bar on/off for
  aesthetics is unaffected — autosave no longer depends on that bar's state
  at all.
- Verified: `systemctl --user list-timers tmux-resurrect-save.timer` shows
  it scheduled every 15 min, and a fresh save file
  (`tmux_resurrect_20260705T110829.txt`) was written immediately after
  enabling the timer.
- 2026-07-06: interval tightened 15min → 5min (`OnUnitActiveSec=5min`).
