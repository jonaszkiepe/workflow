---
project: workflow
type: reference
audience: both
updated: 2026-07-05
tags: [tmux, systemd, dotfiles]
summary: "Why tmux-resurrect autosave silently died (status off blocks continuum's hook) and the systemd --user timer fix. Units live in dotfiles/.config/systemd/user/."
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
Description=Run tmux-resurrect save every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min
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

## Notes

- **New machine:** the `.service`/`.timer` units are tracked in
  `dotfiles/.config/systemd/user/` and `install.sh` symlinks them into place, but
  it does **not** enable them. After bootstrapping a new machine, run
  `systemctl --user daemon-reload && systemctl --user enable --now tmux-resurrect-save.timer`.
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
