# when use my own zshrc, copy following line to ~/.zshrc
# [ -f ~/.dotfiles/.zshrc ] && source ~/.dotfiles/.zshrc

zmodload zsh/zprof

# Function to handle shell restart with optional cache invalidation
resh() {
  if [ "$1" = "--cache-invalidate" ]; then
    echo "Invalidating API keys cache..."
    if command -v op &> /dev/null; then
      # Force update OPENAI key
      local op_key=$(op item get OPENAI_API_KEY --reveal --vault ZSH --fields label=password)
      [ ! -z "$op_key" ] && set_cached_key "OPENAI_API_KEY" "$op_key"
      
      # Force update ANTHROPIC key
      op_key=$(op item get ANTHROPIC_API_KEY --reveal --vault ZSH --fields label=password)
      [ ! -z "$op_key" ] && set_cached_key "ANTHROPIC_API_KEY" "$op_key"
    fi
  fi
  exec zsh
}

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

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

###############################
# AI API KEY SETTING
###############################


# Setup AI API Keys with local caching
CACHE_DIR="$HOME/.cache"
AI_KEYS_CACHE="$CACHE_DIR/ai-api-keys.txt"
[ ! -d "$CACHE_DIR" ] && mkdir -p "$CACHE_DIR"
[ ! -f "$AI_KEYS_CACHE" ] && touch "$AI_KEYS_CACHE" && chmod 600 "$AI_KEYS_CACHE"

# Function to get key from cache file
get_cached_key() {
  local key_name="$1"
  grep "^${key_name}=" "$AI_KEYS_CACHE" | cut -d'=' -f2
}

# Function to set key in cache file
set_cached_key() {
  local key_name="$1"
  local key_value="$2"
  # Remove existing line if exists
  sed -i '' "/^${key_name}=/d" "$AI_KEYS_CACHE"
  # Append new key
  echo "${key_name}=${key_value}" >> "$AI_KEYS_CACHE"
}

# Setup API keys with caching
if command -v op &> /dev/null; then
  # Try to get OPENAI key from cache first
  OPENAI_KEY=$(get_cached_key "OPENAI_API_KEY")
  if [ -z "$OPENAI_KEY" ]; then
    OPENAI_KEY=$(op item get OPENAI_API_KEY --reveal --vault ZSH --fields label=password)
    [ ! -z "$OPENAI_KEY" ] && set_cached_key "OPENAI_API_KEY" "$OPENAI_KEY"
  fi
  export OPENAI_API_KEY="$OPENAI_KEY"

  # Try to get ANTHROPIC key from cache first
  ANTHROPIC_KEY=$(get_cached_key "ANTHROPIC_API_KEY")
  if [ -z "$ANTHROPIC_KEY" ]; then
    ANTHROPIC_KEY=$(op item get ANTHROPIC_API_KEY --reveal --vault ZSH --fields label=password)
    [ ! -z "$ANTHROPIC_KEY" ] && set_cached_key "ANTHROPIC_API_KEY" "$ANTHROPIC_KEY"
  fi
  export ANTHROPIC_API_KEY="$ANTHROPIC_KEY"
fi

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
