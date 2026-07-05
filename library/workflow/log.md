---
project: workflow
type: log
audience: both
updated: 2026-07-05
summary: Append-only activity log — every piece of work, one dated line, newest first.
---

# workflow — log

Every completed piece of work gets one line (newest first). Big features also live
on [[board]]; this is the full history.

## 2026-07-05
- Recovered a session that died mid-migration (before its commit): completed the loose ends. Brought the tmux-resurrect **systemd units** (`.service`+`.timer`) under `dotfiles/.config/systemd/user/` — they were live in `$HOME` but untracked, so a fresh `install.sh` would've lost the autosave fix; re-ran install.sh to symlink them (timer still firing). Fixed `Claude.md` → `CLAUDE.md` (case-sensitive FS meant Claude Code never auto-loaded it). Folded the root `tmux-resurrect-fix.md` into the vault as [[tmux-resurrect]] with frontmatter + a new-machine `enable` caveat. Made the repo's first commit.
- Migrated dotfiles from the bare repo (`~/.dotfiles` + `$HOME` work-tree) into `dotfiles/` here: 27 tracked files (nvim, tmux, alacritty, i3, polybar, picom, bash, scripts, …), live uncommitted edits included; `.Xauthority` deliberately dropped. Added idempotent `dotfiles/install.sh` (symlinks into `$HOME`, backs up originals) and ran it — originals in `~/.dotfiles-backup-20260705-112508`. Retargeted `dotfiles` alias + `dfupdate()` in `.bashrc` at this repo. Bare repo kept untouched as archive.
- Project bootstrapped from `~/.ai` (vault skeleton, _meta symlinks, memory wiring).
