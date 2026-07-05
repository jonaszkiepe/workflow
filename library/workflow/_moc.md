---
project: workflow
type: moc
audience: both
updated: 2026-07-05
summary: Map of content for workflow.
---

# workflow

Personal workflow + machine-config repo. `dotfiles/` holds every config file (nvim,
tmux, alacritty, i3, polybar, picom, bash, scripts) mirroring the `$HOME` layout;
`dotfiles/install.sh` symlinks them into place (idempotent, backs up originals).
New machine = clone this repo + run `dotfiles/install.sh`. The library (this vault)
is the knowledge layer on top.

## Notes
- [[architecture]] — **how it works** (to write). The technical source of truth.
- [[tmux-resurrect]] — autosave fix (status-off broke continuum's hook → systemd timer).
- [[dir-symlink-tracking]] — idea (backlog): whole-dir symlinks so new config auto-tracks.
- [[board]] — the plan (big features) · [[log]] — full history (everything, dated).

## Status (2026-07-05)
- Dotfiles migrated from the old bare repo and symlinked live; `~/.dotfiles` bare repo
  retained as read-only archive (history not imported). Repo now has its first commit
  (local only — not pushed).

## Key decisions
- Plain directory + symlink script over bare-repo/chezmoi/stow: scoped repo an AI agent
  can safely work in, trivial bootstrap, lowest lock-in (easy later move to Dotbot/chezmoi).
- `~/.ai` stays a separate sibling repo (different lifecycle + sensitivity); combined at
  bootstrap level only, symlinked into `library/_meta`.
- `.Xauthority` excluded from tracking (machine-specific X session cookie, effectively a secret).
- `kanagawa.nvim` (a customized fork carrying real patches) is **vendored as a git
  submodule** at `dotfiles/.config/nvim/vendor/kanagawa.nvim`, loaded via lazy `dir=`
  — repo is self-contained, not dependent on the GitHub fork surviving. Plugins in
  `vendor/` are loaded in place, never file-symlinked (install.sh skips `vendor/`).
