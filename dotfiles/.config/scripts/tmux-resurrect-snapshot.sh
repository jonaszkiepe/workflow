#!/usr/bin/env bash
# Snapshot the newest tmux-resurrect save into the dotfiles repo and commit it,
# so a fresh machine can restore this machine's session layout (install.sh
# seeds ~/.local/share/tmux/resurrect/last from the tracked snapshot).
# Run daily by tmux-resurrect-snapshot.timer (Persistent=true: a missed run
# fires at next boot).
set -euo pipefail

REPO="$HOME/workflow"
SNAP_REL="dotfiles/.local/share/tmux/resurrect/tmux_resurrect_snapshot.txt"
SNAP="$REPO/$SNAP_REL"
LAST="$HOME/.local/share/tmux/resurrect/last"

[ -e "$LAST" ] || exit 0            # no saves on this machine yet
src="$(readlink -f "$LAST")"

# Nothing new since the last snapshot -> no commit noise.
cmp -s "$src" "$SNAP" && exit 0

mkdir -p "$(dirname "$SNAP")"
cp "$src" "$SNAP"
git -C "$REPO" add "$SNAP_REL"
# Pathspec keeps unrelated dirty files out of the commit.
git -C "$REPO" commit -q -m "tmux: resurrect snapshot $(date +%F)" -- "$SNAP_REL"
