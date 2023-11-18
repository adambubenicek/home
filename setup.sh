#!/usr/bin/env bash

set -e

SCRIPT_FILE=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_FILE")

git remote set-url origin git@github.com:adambubenicek/home.git

sudo dnf remove -y firefox

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y \
	org.mozilla.firefox \
	org.qbittorrent.qBittorrent \
	org.videolan.VLC \
	com.valvesoftware.Steam \
	com.dropbox.Client \
	org.cryptomator.Cryptomator

flatpak override --user --socket=fallback-x11

sudo dnf install -y \
	podman \
	gcc \
	make \
	distrobox \
	keepassxc

if [ -z "$(hostnamectl --static)" ]; then
	read -p 'Choose a hostname: ' hostname
	sudo hostnamectl set-hostname --static $hostname
fi

if ! command -v mullvad; then
	mkdir /tmp/mullvad
	cd /tmp/mullvad
	wget -O mullvad.rpm --content-disposition https://mullvad.net/download/app/rpm/latest
	sudo dnf install -y mullvad.rpm
fi

mullvad lan set allow
mullvad dns set default --block-ads --block-trackers --block-malware --block-gambling

if ! command -v keyd; then
	git clone https://github.com/rvaiya/keyd /tmp/keyd
	cd /tmp/keyd
	make
	sudo make install
fi

sudo mkdir -p /etc/keyd
sudo cp "$SCRIPT_DIR/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd

mkdir -p ~/.config/helix
ln -sf "$SCRIPT_DIR/helix/config.toml" ~/.config/helix/config.toml

mkdir -p ~/.config/lazygit
ln -sf "$SCRIPT_DIR/lazygit/config.yml" ~/.config/lazygit/config.yml

mkdir -p ~/.local/share/konsole
ln -sf "$SCRIPT_DIR/konsole/Distrobox.profile" ~/.local/share/konsole/Distrobox.profile

mkdir -p ~/.config/git
ln -sf "$SCRIPT_DIR/git/config" ~/.config/git/config

find ~/.var/app/org.mozilla.firefox/.mozilla/firefox -regex '.*\.default\(-release\)?' | while read dir; do
	cp "$SCRIPT_DIR/firefox/user.js" "$dir/user.js"
done

ln -sf "$SCRIPT_DIR/zsh/zshrc.zsh" ~/.zshrc
ln -sf "$SCRIPT_DIR/zsh/p10k.zsh" ~/.p10k.zsh
ln -sf "$SCRIPT_DIR/asdf/tool-versions" ~/.tool-versions

distrobox assemble create --file "$SCRIPT_DIR/distrobox/distrobox.ini"

plasma-apply-colorscheme BreezeDark

kwriteconfig5 --file kwinrc --group NightColor --key Active --type bool true

kwriteconfig5 --file kcminputrc --group Libinput --group 4012 --group 6878 --group keyd\ virtual\ pointer --key NaturalScroll --type bool true
kwriteconfig5 --file kcminputrc --group Libinput --group 1267 --group 12926 --group ELAN06FA:00\ 04F3:327E\ Touchpad --key NaturalScroll --type bool true
kwriteconfig5 --file kcminputrc --group Libinput --group 1267 --group 12926 --group ELAN06FA:00\ 04F3:327E\ Touchpad --key TapToClick --type bool true

kwriteconfig5 --file kwalletrc --group Wallet --key Enabled --type bool false
kwriteconfig5 --file kwalletrc --group org.freedesktop.secrets --key apiEnabled --type bool false

kwriteconfig5 --file keepassxc/keepassxc.ini --group GUI --key ApplicationTheme classic
kwriteconfig5 --file keepassxc/keepassxc.ini --group FdoSecrets --key Enabled --type bool true
kwriteconfig5 --file keepassxc/keepassxc.ini --group SSHAgent --key Enabled --type bool true
