#!/usr/bin/env bash

set -e

SCRIPT_FILE=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_FILE")

git remote set-url origin git@github.com:adambubenicek/home.git

sudo dnf remove -y firefox

flatpak install -y \
	org.mozilla.firefox \
	io.github.celluloid_player.Celluloid

flatpak override --user --socket=fallback-x11

sudo dnf install -y \
	gcc \
	make \
	blackbox-terminal \
	dconf-editor \
	distrobox \
	syncthing \
	qbittorrent-nox

systemctl enable qbittorrent-nox@adam

if [ -z "$(hostnamectl --static)" ]; then
	read -p 'Choose a hostname: ' hostname
	sudo hostnamectl set-hostname --static $hostname
fi

systemctl enable --user syncthing

if ! command -v keyd; then
	git clone https://github.com/rvaiya/keyd /tmp/keyd
	cd /tmp/keyd
	make
	sudo make install
fi

if ! command -v mullvad; then
	mkdir /tmp/mullvad
	cd /tmp/mullvad
	wget -O mullvad.rpm --content-disposition https://mullvad.net/download/app/rpm/latest
	sudo dnf install -y mullvad.rpm
fi

sudo mkdir -p /etc/keyd
sudo cp "$SCRIPT_DIR/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd

mkdir -p ~/.config/helix
ln -sf "$SCRIPT_DIR/helix/config.toml" ~/.config/helix/config.toml
mkdir -p ~/.config/qBittorrent
ln -sf "$SCRIPT_DIR/qBittorrent/qBittorrent.conf" ~/.config/qBittorrent/qBittorrent.conf

mkdir -p ~/.config/git
ln -sf "$SCRIPT_DIR/git/config" ~/.config/git/config

if [[ ! -f ~/.ssh/id_ed25519 ]]; then
	ssh-keygen -t ed25519
fi

find ~/.var/app/org.mozilla.firefox/.mozilla/firefox -regex '.*\.default\(-release\)?' | while read dir; do
	cp "$SCRIPT_DIR/firefox/user.js" "$dir/user.js"
done

ln -sf "$SCRIPT_DIR/zsh/zshrc.zsh" ~/.zshrc
ln -sf "$SCRIPT_DIR/zsh/p10k.zsh" ~/.p10k.zsh
ln -sf "$SCRIPT_DIR/asdf/tool-versions" ~/.tool-versions

if [ ! -f ~/.local/share/fonts/IosevkaTermNerdFont-Regular.ttf ]; then
	cd /tmp
	curl -O -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/IosevkaTerm.zip
	mkdir -p IosevkaTerm
	unzip IosevkaTerm.zip -d IosevkaTerm
	mkdir -p ~/.local/share/fonts
	mv IosevkaTerm/*.ttf ~/.local/share/fonts/
fi

distrobox assemble create --file "$SCRIPT_DIR/distrobox/distrobox.ini"

ln -sf "$SCRIPT_DIR/gnome/mimeapps.list" ~/.config/mimeapps.list

cat <<EOF > ~/.config/gtk-3.0/bookmarks
file://$HOME/Sync
EOF

dconf write /com/raggesilver/BlackBox/terminal-padding "(uint32 8, uint32 8, uint32 8, uint32 8)"
dconf write /com/raggesilver/BlackBox/theme-dark "'Adwaita Dark'"
dconf write /com/raggesilver/BlackBox/font "'IosevkaTerm Nerd Font Mono 12'"
dconf write /com/raggesilver/BlackBox/use-custom-command true
dconf write /com/raggesilver/BlackBox/custom-shell-command "'distrobox enter default'"

sudo cp "$SCRIPT_DIR/gdm/custom.conf" /etc/gdm/custom.conf
dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
dconf write /org/gnome/settings-daemon/plugins/color/night-light-enabled true
dconf write /org/gnome/desktop/peripherals/mouse/natural-scroll true
dconf write /org/gnome/desktop/background/picture-options "'none'"
dconf write /org/gnome/desktop/background/primary-color "'#000000'"
dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click true

dconf write /org/gnome/shell/favorite-apps "['org.mozilla.firefox.desktop', 'com.raggesilver.BlackBox.desktop', 'org.gnome.Nautilus.desktop']"
