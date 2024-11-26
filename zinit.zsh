declare -A ZINIT
ZINIT[NO_ALIASES]=1

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz compinit
compinit

zinit ice wait lucid atinit"zicompinit; zicdreplay"
# import snippet from oh-my-zsh
zinit snippet OMZL::async_prompt.zsh
zinit snippet OMZL::cli.zsh
zinit snippet OMZL::clipboard.zsh
zinit snippet OMZL::compfix.zsh
zinit snippet OMZL::completion.zsh
zinit snippet OMZL::directories.zsh
zinit snippet OMZL::git.zsh
zinit snippet OMZL::grep.zsh
zinit snippet OMZL::history.zsh
zinit snippet OMZL::key-bindings.zsh

zinit light zsh-users/zsh-history-substring-search

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait lucid '!0'
zinit light dracula/zsh-syntax-highlighting

# zsh-vi-mode
ZVM_VI_SURROUND_BINDKEY="s-prefix"

zinit light jeffreytse/zsh-vi-mode


# zsh-nvm
# nvm ~ 할 때 ~를 자동완성 시켜주는 옵션. 활성화 해 두는게 좋음. (brew로 설치할 때에도 기본 활성화 되어 있다.)
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
# lazy load가 적용되었을 때, nvm/node 말고도 extra command 로 오는 커맨드들을 입력할 때에 nvm load가 되도록 한다.
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('nvim' 'git')
# .nvmrc 가 있는 경우, nvm load가 되는 순간 자동으로 .nvmrc 버전으로 맞춰준다.
export NVM_AUTO_USE=true

zinit light leokang94/zsh-nvm

