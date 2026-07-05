---
project: workflow
type: reference
audience: both
updated: 2026-07-05
status: idea
tags: [dotfiles, install, design]
summary: "Enhance install.sh with directory-level symlinking (whole-dir link) so new files added to curated-safe config dirs auto-join the repo, instead of the current file-by-file allowlist."
---

# Directory-level symlink tracking

## Problem

`dotfiles/install.sh` links **file by file** (`find "$SRC" -type f`). The repo is
the source of truth; `$HOME` files are symlinks pointing *into* it. Consequence:
a config file you (or a tool) create **later** is born as a real file in `$HOME`,
*outside* the repo — so new files never auto-join version control. You must
manually move each one into `dotfiles/` and re-run install. High friction for
dirs that grow over time (adding nvim lua modules, a new `~/.config/git/config`,
git hooks, etc.).

## Idea

Support **whole-directory** symlinks for curated, safe dirs:

```
~/.config/git  ──symlink──>  dotfiles/.config/git   (the directory itself)
```

Then `~/.config/git/` *is* the repo folder — anything dropped in lands directly
in version control (the GNU Stow "directory folding" model). Zero friction for
future files.

## The tradeoff

Dir-level linking is only safe where you trust **everything** the app writes into
that folder. Safe: `~/.config/git/` (git writes `--global` to the tracked
`~/.gitconfig`, never secrets/cache here) and `~/.config/nvim/` (all hand-authored).
**Unsafe** for dirs where apps also drop tokens/state/cache (chromium, docker, …) —
those must stay file-level allowlists. So it's a per-directory judgment, never a
blanket switch.

## Proposed implementation

- Add a "link these dirs wholesale" list to `install.sh` (e.g. a `LINK_DIRS`
  array of repo-relative dirs).
- For each: back up any existing real dir/link in `$HOME`, then symlink the
  directory itself.
- In the existing per-file loop, **skip** any file that lives under a wholesale
  dir (so the two models don't fight over the same paths).
- Keep it idempotent (re-running only fixes wrong/missing links), matching the
  current script's contract.

~10 lines. First candidate: `~/.config/git/` (currently just holds `ignore`).
Follow-up candidate: convert `~/.config/nvim/` from file-level to dir-level.

## Related

- [[architecture]] (install.sh mechanics, once written).
- Decision context: chosen over bare-repo/stow at bootstrap — see [[_moc]] key decisions.
