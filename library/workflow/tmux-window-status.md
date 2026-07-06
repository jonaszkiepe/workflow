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
- Format is just `#W`, **bold + underline** when current — no index/`*`/separators.
- Splits (`M-o`/`M-p`) inherit the pane's cwd via `-c "#{pane_current_path}"`.

## Status bar auto-show
Visible only when a session has **>1 window**. Kept live by `window-linked` /
`window-unlinked` hooks, **and** re-evaluated by a top-level `if-shell` at the end
of the config. The end-of-file eval is the fix for the "bar vanishes on reload"
bug: sourcing no longer force-sets `status off` (the old unconditional line 1 was
removed), so every `source-file` — startup or `prefix r` — leaves the bar correct.
Rule of thumb: **the show/hide decision must run after the hooks are defined, on
every source.**

## Claude marker — `@claude_state` (read/unread)
A per-window tmux user option. When set, the window name gets a **`-c`** suffix
and the **whole label is coloured** by state. It works like a read/unread light:

| Value | Label colour | Meaning | Set by |
|---|---|---|---|
| *(unset)* | *(no marker)* | no Claude here | `SessionEnd` |
| `active` | grey | working, **or you've read it** | `SessionStart`, `UserPromptSubmit`, `PreToolUse`, **`pane-focus-in`** |
| `pending` | **yellow** | unread — Claude wants your input | `Notification`, `PermissionRequest` |
| `done` | **green** | unread — Claude finished its work | `Stop` |

Most transitions come from **Claude Code hooks** (`~/.claude/settings.json`,
untracked — see the version-control suggestion in `~/.ai/suggestions.md`), which
target the window via `$TMUX_PANE`: `tmux set -w -t "$TMUX_PANE" @claude_state
<value>`. The **read reset is a tmux hook**, not a Claude one:
`set-hook -g pane-focus-in 'if -F "#{@claude_state}" "set -w @claude_state active"'`
— focusing a Claude window clears its colour to grey (guarded so it never touches
non-Claude windows).

Status format (whole label coloured by state, `-c` suffix):
`#{?@claude_state,<colour>#W-c#[default],#W}` where `<colour>` is the nested
conditional `pending→#[fg=yellow] / done→#[fg=green] / else #[fg=colour244]` (grey).
The current-window format prepends `#[bold,underscore]`.

**Why these hooks:** `PreToolUse` fires *before* `PermissionRequest`, so it can't
prematurely clear yellow — but it *does* flip back to grey the instant Claude
resumes after you approve, so multiple edits in one cycle each read
grey→yellow→grey. `Stop`→`done` is the green "finished, unread" state; reading the
window (or the next `UserPromptSubmit`) clears it. Only affects sessions started
**after** the hooks were added (settings.json is read at session start).

**Caveats:** window-level option → last writer wins if two Claude panes share a
window. A crash without `SessionEnd` leaves a stale marker. If Claude finishes
(`Stop`) while you're **already on** that window, it still goes green — no
`pane-focus-in` fires without a focus change — until you switch away and back or
submit a prompt.
