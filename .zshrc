# when use my own zshrc, copy following line to ~/.zshrc
# [ -f ~/.dotfiles/.zshrc ] && source ~/.dotfiles/.zshrc

zmodload zsh/zprof

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

# setup custom completions
fpath=(~/.dotfiles/.zsh/completions $fpath)
autoload -Uz compinit
compinit


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
alias c='claude'
alias cm='bunx ccmanager'

# tab title: always show current directory
precmd() { print -Pn "\e]2;%~\a" }

# tmuxifier setting
# export PATH="$HOME/.tmuxifier/bin:$PATH"
# eval "$(tmuxifier init -)"

# alias tmf='tmuxifier'
# alias tmux='tmux -u'

# fastfetch
alias fetch='fastfetch'

###############################
# Custom Commands Aliases
###############################
export PATH="$PATH:$HOME/.custom-commands"

alias pr="pull-request"
alias ci="open-ci"

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


# mhl - multi-highlight: highlight multiple keywords in different colors using grep

mhl() {
  local colors=(31 32 33 34 35 36)
  local i=1
  local args=()
  local next_regex=0
  for kw in "$@"; do
    if [[ "$kw" == "--regex" ]]; then
      next_regex=1
      continue
    fi
    if [[ $next_regex -eq 1 ]]; then
      args+=("regex:$kw:${colors[$i]}")
      next_regex=0
    else
      local escaped=$(printf '%s' "$kw" | sed 's/[.[\*^$(){}+?|]/\\&/g')
      args+=("regex:$escaped:${colors[$i]}")
    fi
    i=$(( (i % ${#colors[@]}) + 1 ))
  done

  python3 -c "
import sys, re
args = sys.argv[1:]
patterns = []
for a in args:
    _, pat, color = a.split(':', 2)
    patterns.append((re.compile(pat), '\033[00;' + color + 'm'))

for line in sys.stdin:
    line = line.rstrip('\n')
    # 각 문자 위치별로 색상 저장 (나중 키워드가 덮어씀)
    color_map = {}
    for rx, open_c in patterns:
        for m in rx.finditer(line):
            for pos in range(m.start(), m.end()):
                color_map[pos] = open_c

    # 연속된 같은 색상끼리 묶어서 출력
    result = ''
    pos = 0
    reset = '\033[0m'
    while pos < len(line):
        if pos in color_map:
            cur_color = color_map[pos]
            result += cur_color
            while pos < len(line) and color_map.get(pos) == cur_color:
                result += line[pos]
                pos += 1
            result += reset
        else:
            result += line[pos]
            pos += 1
    print(result)
" "${args[@]}"
}

# mhl() {
#   local colors=(31 32 33 34 35 36)
#   local cmd="cat"
#   local i=1
#   local next_regex=0
#   for kw in "$@"; do
#     if [[ "$kw" == "--regex" ]]; then
#       next_regex=1
#       continue
#     fi
#     local pattern
#     if [[ $next_regex -eq 1 ]]; then
#       pattern="$kw"
#       next_regex=0
#     else
#       pattern=$(printf '%s' "$kw" | sed 's/[.[\*^$(){}+?|]/\\&/g')
#     fi
#     cmd="$cmd | GREP_COLOR='00;${colors[$i]}' GREP_COLORS='ms=00;${colors[$i]}' grep --color=always -E \"$pattern|\$\""
#     i=$(( (i % ${#colors[@]}) + 1 ))
#   done
#   eval "$cmd"
# }

# mhl() {
#   local colors=(31 32 33 34 35 36)
#   local cmd="cat"
#   local i=1
#   for kw in "$@"; do
#     cmd="$cmd | GREP_COLOR='00;${colors[$i]}' GREP_COLORS='ms=00;${colors[$i]}' grep --color=always -E \"$kw|\$\""
#     i=$(( (i % ${#colors[@]}) + 1 ))
#   done
#   eval "$cmd"
# }
