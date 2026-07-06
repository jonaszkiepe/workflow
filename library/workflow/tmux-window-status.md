---
project: workflow
type: reference
audience: both
updated: 2026-07-06
summary: tmux window labels + a Claude-aware status bar — the @claude_state scheme wiring tmux to Claude Code hooks.
---

# tmux window status + Claude integration

The tmux status bar ([[dotfiles-approach|dotfiles]] `.tmux.conf`) doubles as a
Claude-session dashboard. Two independent pieces:

## Window labels
- Window name = **basename of the pane's cwd** (`automatic-rename-format
  "#{b:pane_current_path}"`), so unlabeled windows read as their directory, not
  the running process.
- **`prefix t`** renames the current window (overrides the rarely-used default
  clock-mode). A manual rename turns `automatic-rename` off *for that window*, so
  the label sticks and [[tmux-resurrect]] restores it across restarts.
- Format is just `#W`, **bold** when current — no index/`*`/separators.

## Status bar auto-show
Visible only when a session has **>1 window**. Kept live by `window-linked` /
`window-unlinked` hooks, **and** re-evaluated by a top-level `if-shell` at the end
of the config. The end-of-file eval is the fix for the "bar vanishes on reload"
bug: sourcing no longer force-sets `status off` (the old unconditional line 1 was
removed), so every `source-file` — startup or `prefix r` — leaves the bar correct.
Rule of thumb: **the show/hide decision must run after the hooks are defined, on
every source.**

## Claude marker — `@claude_state`
A per-window tmux user option, set by **Claude Code hooks**
(`~/.claude/settings.json`, untracked — see the version-control suggestion in
`~/.ai/suggestions.md`). Hooks target the window via `$TMUX_PANE`:
`tmux set -w -t "$TMUX_PANE" @claude_state <value>`.

| Value | Shown | Meaning | Set by (hook) |
|---|---|---|---|
| *(unset)* | plain name | no Claude here | `SessionEnd` (unset) |
| `active` | grey ` (c)` | Claude working | `SessionStart`, `UserPromptSubmit`, `PreToolUse` |
| `pending` | **green** name + `(c)` | Claude waiting on you | `Notification`, `PermissionRequest`, `Stop` |

The status format reads the option per-window:
`#{?#{==:#{@claude_state},pending},#[fg=green],}#W#{?@claude_state, (c),}#[default]`.

**Why these hooks:** `PreToolUse` fires *before* `PermissionRequest`, so it can't
prematurely clear the green — but it *does* flip green→grey the instant Claude
resumes after you approve, so multiple edits in one cycle each read grey→green→grey.
`Stop`→pending makes green the resting "your turn" state; the next
`UserPromptSubmit` clears it. Only affects sessions started **after** the hooks
were added (settings.json is read at session start).

**Caveats:** window-level option → last writer wins if two Claude panes share a
window. A crash without `SessionEnd` leaves a stale `(c)`.
