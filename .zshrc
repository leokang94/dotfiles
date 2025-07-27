# when use my own zshrc, copy following line to ~/.zshrc
# [ -f ~/.dotfiles/.zshrc ] && source ~/.dotfiles/.zshrc

zmodload zsh/zprof


###############################
# AI API KEY SETTING
###############################

# Source API key management functions
source ~/.dotfiles/api_keys.zsh

# Load API keys
load_api_keys

# Function to handle shell restart with optional cache invalidation
resh() {
  if [ "$1" = "--cache-invalidate" ]; then
    echo "Invalidating API keys cache..."
    # Force update all API keys
    load_api_keys true
  fi
  exec zsh
}

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:~/.local/bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"

# setup Editor & Terminal
export EDITOR=nvim

# setup zinit (zsh plugin manager)
source ~/.dotfiles/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# setup zoxide
eval "$(zoxide init --cmd cd zsh)"

# setup Startship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# setup Eza
alias ls='eza --icons --time-style=+"%Y-%m-%d %H:%M:%S" --color=auto'
alias lsa='ls -al'

alias vim="nvim"
alias vi="nvim"
alias vimdiff="nvim -d"
export EDITOR=nvim

# setup git
export PATH="$PATH:$HOME/.git-custom-commands"
alias g='git'

# tmuxifier setting
# export PATH="$HOME/.tmuxifier/bin:$PATH"
# eval "$(tmuxifier init -)"

# alias tmf='tmuxifier'
# alias tmux='tmux -u'

# fastfetch
alias fetch='fastfetch'


###############################
# Custom Functions
###############################


# fcd - cd into the selected directory with fzf (in Root(~) Directory)
fcd() {
  local dir
  dir=$(\
    fd --absolute-path --type d --hidden --follow --exclude .git --exclude node_modules "$1" ~ | \
    fzf --height 50% --preview 'ls -l {}')

  echo $dir
  if [ -n "$dir" ]; then
    cd "$dir" || return
  fi
}

fvi() {
  local file
  file=$(fd --absolute-path --type f --hidden --follow --exclude .git --exclude node_modules "$1" ~ | \
         fzf --height 50% --preview 'bat --style=numbers --color=always --line-range :500 {}')

  echo $file
  if [ -n "$file" ]; then
    vi "$file" || return
  fi
}
