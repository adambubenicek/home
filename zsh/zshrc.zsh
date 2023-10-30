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

HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -v
zstyle :compinstall filename '/home/adam/.config/zsh/.zshrc'

autoload -Uz compinit
compinit
