git clone git@gitlab.com:personal3012503/other.git /home/jonasz/Other

# installing applications
sudo pacman -Syu i3 alacritty ttf-jetbrains-mono-nerd fuse pulseaudio xorg brightnessctl xclip python tmux xdotool feh gnupg dmenu ripgrep fd calcurse pass flameshot passmenu wget

# pass 
git clone git@gitlab.com:personal3012503/passwords.git /home/jonasz/.password-store
gpg --import private.pgp
gpg --import public.pgp
pass init ~/.password-store

# nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# librewolf
git clone https://aur.archlinux.org/librewolf-bin.git ~/librewolf
makepkg -si ~/librewolf

# zoom
curl -LO https://zoom.us/client/6.0.12.5501/zoom_x86_64.pkg.tar.xz ~/zoom
sudo pacman -U ~/zoom/zoom_x86_64.pkg.tar.xz

# keyboard
setxkbmap -option "caps:swapescape"
