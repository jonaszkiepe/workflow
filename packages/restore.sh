#!/usr/bin/env bash
# Reinstall packages on a fresh Arch machine from the manifests in this dir.
#
# Prereqs:
#   - A working base Arch install with your user + sudo.
#   - If you use 32-bit packages (Steam, etc.): enable [multilib] in
#     /etc/pacman.conf BEFORE running (uncomment the two multilib lines).
#   - Network up.
#
# Idempotent: --needed skips anything already present, so it's safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"

echo ">> [1/4] Official-repo packages (pacman -Syu)..."
sudo pacman -Syu --needed - < pacman-native.txt

# yay must exist before the AUR list can be installed.
if ! command -v yay >/dev/null 2>&1; then
  echo ">> Bootstrapping yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmp/yay"
  ( cd "$tmp/yay" && makepkg -si --noconfirm )
  rm -rf "$tmp"
fi

echo ">> [2/4] AUR packages (yay)..."
# Some entries may have been dropped/renamed on the AUR since capture — yay will
# report those; install the rest and fix up by hand afterwards.
yay -S --needed - < aur.txt || echo "   (some AUR packages failed — see above)"

if [ -f snap.txt ] && command -v snap >/dev/null 2>&1; then
  echo ">> [3/4] Snaps..."
  while read -r p; do
    [ -n "$p" ] && sudo snap install "$p" 2>/dev/null || true
  done < snap.txt
else
  echo ">> [3/4] Snaps: skipped (no snap.txt or snapd not installed yet)."
fi

if [ -f flatpak.txt ] && [ -s flatpak.txt ] && command -v flatpak >/dev/null 2>&1; then
  echo ">> [4/4] Flatpaks..."
  xargs -r flatpak install -y flathub < flatpak.txt
else
  echo ">> [4/4] Flatpaks: nothing to do."
fi

echo ">> Done. Re-run any failed items by hand; then run ./sync.sh to re-sync."
