# when use my own zshrc, copy following line to ~/.zshrc
# [ -f ~/.dotfiles/.zshrc ] && source ~/.dotfiles/.zshrc

zmodload zsh/zprof

alias resh="exec zsh"

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"

# setup Editor & Terminal
export EDITOR=nvim
export TERM=wezterm

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
export PATH="$HOME/.tmuxifier/bin:$PATH"
eval "$(tmuxifier init -)"

alias tmf='tmuxifier'
alias tmux='tmux -u'


# fastfetch
alias fetch='fastfetch'

# for AI Keys
export OPENAI_API_KEY=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


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
