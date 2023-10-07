#!/usr/bin/env bash

set -e

sudo dnf install \
	neovim \
	git \
	gcc \
	make \
	fish \
	util-linux-user \
	gnome-console \
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
sudo cp keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd

mkdir -p ~/.config/fish
ln -sf "$(pwd)/fish/config.fish" ~/.config/fish/config.fish
sudo chsh -s /bin/fish

mkdir -p ~/.config/nvim
ln -sf "$(pwd)/neovim/init.lua" ~/.config/nvim/init.lua

mkdir -p ~/.config/git
ln -sf "$(pwd)/git/config" ~/.config/git/config

ln -sf "$(pwd)/gpg/gpg.conf" ~/.gnupg/gpg.conf
ln -sf "$(pwd)/gpg/gpg-agent.conf" ~/.gnupg/gpg-agent.conf
ln -sf "$(pwd)/gpg/sshcontrol" ~/.gnupg/sshcontrol

if ! rclone config show storagebox-crypt; then
	host=$(gpg -q -d rclone/storagebox-crypt-host.gpg)
	user=$(gpg -q -d rclone/storagebox-crypt-user.gpg)
	password=$(gpg -q -d rclone/storagebox-crypt-password.gpg)
	rclone config create storagebox-crypt sftp \
		host=$host \
		user=$user \
		pass=$(rclone obscure $password)
fi

if ! rclone config show storagebox; then
	password=$(gpg -q -d rclone/storagebox-password.gpg)
	password2=$(gpg -q -d rclone/storagebox-password2.gpg)
	rclone config create storagebox crypt \
		remote=storagebox-crypt: \
		password=$(rclone obscure $password) \
		password2=$(rclone obscure $password2)
fi

mkdir -p ~/.config/systemd/user
mkdir -p ~/Storage\ Box
ln -sf "$(pwd)/rclone/systemd/storagebox.service" ~/.config/systemd/user/storagebox.service
systemctl enable --user storagebox

find ~/.mozilla/firefox -regex '.*\.default\(-release\)?' | while read dir; do
ln -sf "$(pwd)/firefox/user.js" "$dir/user.js"
done

sudo cp gdm/custom.conf /etc/gdm/custom.conf
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/settings-daemon/plugins/color/night-light-enabled true
dconf write /org/gnome/desktop/peripherals/mouse/natural-scroll true
dconf write /org/gnome/desktop/background/picture-options "'none'"
dconf write /org/gnome/desktop/background/primary-color "'#000000'"

