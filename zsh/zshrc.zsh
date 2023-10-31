PLUGINS_DIR="$HOME/.local/share/zsh"

if [[ ! -d "$PLUGINS_DIR" ]]; then
  mkdir -p "$PLUGINS_DIR"
fi

if [[ ! -d "$PLUGINS_DIR/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$PLUGINS_DIR/powerlevel10k"
fi

source "$PLUGINS_DIR/powerlevel10k/powerlevel10k.zsh-theme"
source ~/.p10k.zsh

if [[ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]]; then
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi

source "$PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

export ASDF_DATA_DIR="$PLUGINS_DIR/asdf"
if [[ ! -d "$PLUGINS_DIR/asdf" ]]; then
  git clone --depth=1 https://github.com/asdf-vm/asdf.git "$PLUGINS_DIR/asdf"

  source "$PLUGINS_DIR/asdf/asdf.sh"

  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
else
  source "$PLUGINS_DIR/asdf/asdf.sh"
fi


HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -v
zstyle :compinstall filename '/home/adam/.config/zsh/.zshrc'

autoload -Uz compinit
compinit

export EDITOR=hx
