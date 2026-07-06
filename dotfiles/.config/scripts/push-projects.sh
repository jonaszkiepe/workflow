#!/usr/bin/env bash
# Push the current branch of each listed project repo.
# Usage: push-projects.sh [-n] [repo-dir...]
#   -n  dry run (git push --dry-run)
#   Repo dirs as args override the PROJECTS list below.
set -uo pipefail

PROJECTS=(
    "$HOME/workflow"
    "$HOME/ai-workflow"
    "$HOME/veloking"
    # "$HOME/sportking"
    # "$HOME/internalarts"
)

dry=()
[ "${1:-}" = "-n" ] && { dry=(--dry-run); shift; }
[ $# -gt 0 ] && PROJECTS=("$@")

failed=0
for p in "${PROJECTS[@]}"; do
    name=$(basename "$p")
    if ! git -C "$p" rev-parse --git-dir >/dev/null 2>&1; then
        echo "✗ $name: not a git repo ($p)"; failed=1; continue
    fi
    branch=$(git -C "$p" symbolic-ref --short HEAD 2>/dev/null || echo "?")
    if out=$(git -C "$p" push "${dry[@]}" 2>&1); then
        # "Everything up-to-date" vs an actual push
        case "$out" in
            *up-to-date*) echo "· $name ($branch): up to date" ;;
            *)            echo "✓ $name ($branch): pushed"; echo "$out" | sed 's/^/    /' ;;
        esac
    else
        echo "✗ $name ($branch): push failed"; echo "$out" | sed 's/^/    /'; failed=1
    fi
done
exit "$failed"
