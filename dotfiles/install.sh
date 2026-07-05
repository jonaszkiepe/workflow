#!/usr/bin/env bash
# Symlink every file in this directory into $HOME, mirroring the layout.
# Idempotent: re-running only fixes links that are missing or wrong.
# Existing real files are moved to a timestamped backup dir, never deleted.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
backed_up=0

while IFS= read -r rel; do
    src="$SRC/$rel"
    target="$HOME/$rel"

    # already correctly linked
    [ "$(readlink -f "$target" 2>/dev/null)" = "$src" ] && continue

    mkdir -p "$(dirname "$target")"

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$target" "$BACKUP/$rel"
        backed_up=1
        echo "backed up: $rel"
    fi

    ln -s "$src" "$target"
    echo "linked:    $rel -> $src"
# vendor/ holds git submodules (e.g. the kanagawa.nvim fork) — loaded in place
# from the repo, never symlinked file-by-file into $HOME.
done < <(find "$SRC" -type f ! -name 'install.sh' -not -path '*/vendor/*' -printf '%P\n' | sort)

# ssh is picky about permissions
[ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh"

[ "$backed_up" = 1 ] && echo "originals saved in $BACKUP"
echo "done."
