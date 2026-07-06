---
type: moc
audience: both
updated: 2026-07-06
summary: The index — every project and note with a one-line summary. Read this first.
---

# MAP — library index

Read this first; open only what a task needs. See [[_meta/workflow]] for the loop.
Scan every note's purpose at once: `grep -rh "^summary:" "/home/jonasz/workflow/library" --include=*.md`.

## Projects

| Project | Map | Board (plan) | Log (history) | What |
|---|---|---|---|---|
| workflow | [[workflow/_moc]] | [[workflow/board]] | [[workflow/log]] | Personal workflow + machine-config (dotfiles) repo, with this knowledge vault on top. |

**Board = big features only (the plan). Log = everything (one dated line per work item).**

## Notes

### workflow
- [[workflow/architecture]] — **how it works** (to write).
- [[workflow/tmux-resurrect]] — why autosave silently died + the systemd-timer fix.
- [[workflow/tmux-window-status]] — window labels + Claude-aware status bar (`@claude_state` via hooks).
- [[workflow/dir-symlink-tracking]] — idea: whole-dir symlinks so new config auto-tracks.
- [[workflow/dotfiles-approach]] — why off bare-repo + tool landscape (stow/dotbot/chezmoi/yadm/nix) for a later upgrade.

## Meta
- [[_meta/workflow]] · [[_meta/conventions]] · [[_meta/claude-efficiency]] · [[_meta/prompt-rules]] · [[_meta/suggestions]] · [[_meta/project-rules]] · [[_meta/claude-root]] (the repo-root `CLAUDE.md` — symlinked, auto-loads; start sessions at the repo root)
- General workflow env lives in the **`~/.ai`** repo, symlinked into `_meta/` + `_templates/`. Project-specific rules: [[_meta/project-rules]] (real file).
- `_meta/memories/` — Claude's auto-loaded general memories (shared across projects); project-only ones live in `_meta/project-memories/` (+ `_index.md`) — see scope-routing.
