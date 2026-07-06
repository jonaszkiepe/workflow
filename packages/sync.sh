#!/usr/bin/env bash
# Regenerate the package manifests from what's installed RIGHT NOW.
# Run after you install/remove anything you want reproduced, then commit the diff.
set -euo pipefail
cd "$(dirname "$0")"

# Official-repo packages, explicitly installed (their deps are pulled automatically).
pacman -Qqen > pacman-native.txt

# AUR / manually-built packages, explicitly installed.
# Drop *-debug companions — they're auto-generated at build time, not installable on their own.
pacman -Qqem | grep -v -- '-debug$' > aur.txt

# Snap packages (runtimes like core24/gnome-*/mesa-* get pulled when their app installs).
if command -v snap >/dev/null 2>&1; then
  snap list | awk 'NR>1 {print $1}' > snap.txt
fi

# Flatpak apps (none currently, but keep the manifest honest).
if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application > flatpak.txt
fi

echo "Updated manifests:"
printf '  pacman-native.txt  %s\n' "$(wc -l < pacman-native.txt)"
printf '  aur.txt            %s\n' "$(wc -l < aur.txt)"
[ -f snap.txt ]    && printf '  snap.txt           %s\n' "$(wc -l < snap.txt)"
[ -f flatpak.txt ] && printf '  flatpak.txt        %s\n' "$(wc -l < flatpak.txt)"
echo "Review with: git diff packages/"
