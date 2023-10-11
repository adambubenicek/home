#!/usr/bin/env bash

set -e

SCRIPT_FILE=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_FILE")

sudo dnf install \
	neovim \
	git \
	gcc \
	make \
	fish \
	ripgrep \
	fd-find \
	util-linux-user \
	blackbox-terminal \
	seahorse \
	dconf-editor \
	distrobox \
	rclone

if ! command -v keyd; then
	git clone https://github.com/rvaiya/keyd /tmp/keyd
	cd /tmp/keyd
	make
	sudo make install
fi

sudo mkdir -p /etc/keyd
sudo cp "$SCRIPT_DIR/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd

mkdir -p ~/.config/fish
ln -sf "$SCRIPT_DIR/fish/config.fish" ~/.config/fish/config.fish
sudo chsh -s /bin/fish adam

ln -sf "$SCRIPT_DIR/neovim" ~/.config/nvim

mkdir -p ~/.config/git
ln -sf "$SCRIPT_DIR/git/config" ~/.config/git/config

ln -sf "$SCRIPT_DIR/gpg/gpg.conf" ~/.gnupg/gpg.conf
ln -sf "$SCRIPT_DIR/gpg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf

if ! rclone config show storagebox-crypt; then
	host=$(gpg -q -d "$SCRIPT_DIR/rclone/storagebox-crypt-host.gpg")
	user=$(gpg -q -d "$SCRIPT_DIR/rclone/storagebox-crypt-user.gpg")
	password=$(gpg -q -d "$SCRIPT_DIR/rclone/storagebox-crypt-password.gpg")
	rclone config create storagebox-crypt sftp \
		host=$host \
		user=$user \
		pass=$(rclone obscure $password)
fi

if ! rclone config show storagebox; then
	password=$(gpg -q -d "$SCRIPT_DIR/rclone/storagebox-password.gpg")
	password2=$(gpg -q -d "$SCRIPT_DIR/rclone/storagebox-password2.gpg")
	rclone config create storagebox crypt \
		remote=storagebox-crypt: \
		password=$(rclone obscure $password) \
		password2=$(rclone obscure $password2)
fi

if ! rclone config show seedbox; then
	host=$(gpg -q -d "$SCRIPT_DIR/rclone/seedbox-host.gpg")
	user=$(gpg -q -d "$SCRIPT_DIR/rclone/seedbox-user.gpg")
	password=$(gpg -q -d "$SCRIPT_DIR/rclone/seedbox-password.gpg")
	rclone config create seedbox sftp \
		host=$host \
		user=$user \
		pass=$(rclone obscure $password)
fi

mkdir -p ~/.config/systemd/user
mkdir -p ~/Storage\ Box
ln -sf "$SCRIPT_DIR/rclone/systemd/storagebox.service" ~/.config/systemd/user/storagebox.service
systemctl enable --user storagebox

mkdir -p ~/Seed\ Box
ln -sf "$SCRIPT_DIR/rclone/systemd/seedbox.service" ~/.config/systemd/user/seedbox.service
systemctl enable --user seedbox

find ~/.mozilla/firefox -regex '.*\.default\(-release\)?' | while read dir; do
	ln -sf "$SCRIPT_DIR/firefox/user.js" "$dir/user.js"
done

if [ ! -f ~/.local/share/fonts/IosevkaTermNerdFont-Regular.ttf ]; then
	cd /tmp
	curl -O -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/IosevkaTerm.zip
	mkdir -p IosevkaTerm
	unzip IosevkaTerm.zip -d IosevkaTerm
	mv IosevkaTerm/*.ttf ~/.local/share/fonts/
fi

mkdir -p ~/.local/share/blackbox/schemes
ln -sf "$SCRIPT_DIR/blackbox/tokyonight.json" ~/.local/share/blackbox/schemes/tokyonight.json
dconf write /com/raggesilver/BlackBox/terminal-padding "(uint32 8, uint32 8, uint32 8, uint32 8)"
dconf write /com/raggesilver/BlackBox/theme-dark "'Tokyonight'"
dconf write /com/raggesilver/BlackBox/font "'IosevkaTerm Nerd Font Mono 12'"

sudo cp "$SCRIPT_DIR/gdm/custom.conf" /etc/gdm/custom.conf
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/settings-daemon/plugins/color/night-light-enabled true
dconf write /org/gnome/desktop/peripherals/mouse/natural-scroll true
dconf write /org/gnome/desktop/background/picture-options "'none'"
dconf write /org/gnome/desktop/background/primary-color "'#000000'"
dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click true
