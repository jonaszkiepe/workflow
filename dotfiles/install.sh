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

# --- tmux: plugins + resurrect state -----------------------------------------
# TPM + plugins (resurrect/continuum) so save/restore works on a fresh machine;
# .tmux.conf's `run tpm` fails silently without this.
if command -v git >/dev/null && command -v tmux >/dev/null; then
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || echo "warn: tpm install_plugins failed"
fi

# First run on a machine with no saves yet: point resurrect's restore file at
# the tracked snapshot (linked into place above) so the first tmux start
# restores the snapshotted session layout.
RESDIR="$HOME/.local/share/tmux/resurrect"
if [ ! -e "$RESDIR/last" ] && [ -f "$RESDIR/tmux_resurrect_snapshot.txt" ]; then
    ln -s tmux_resurrect_snapshot.txt "$RESDIR/last"
    echo "seeded resurrect restore point from tracked snapshot"
fi

# Enable the resurrect timers (5-min interval save + daily repo snapshot).
if command -v systemctl >/dev/null; then
    systemctl --user daemon-reload
    systemctl --user enable --now tmux-resurrect-save.timer tmux-resurrect-snapshot.timer || true
fi

[ "$backed_up" = 1 ] && echo "originals saved in $BACKUP"
echo "done."
