
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# 플러그인 설치 함수 정의
install_plugin() {
  local PLUGIN_NAME="$1"
  local REPO_URL="https://github.com/$PLUGIN_NAME.git"
  local PLUGIN_DIR="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$PLUGIN_NAME"

  if [ ! -d "$PLUGIN_DIR" ] || [ -z "$(ls -A $PLUGIN_DIR)" ]; then
    git clone "$REPO_URL" "$PLUGIN_DIR" > /dev/null 2>&1
  fi
}

install_plugin "zsh-users/zsh-autosuggestions"
install_plugin "zsh-users/zsh-syntax-highlighting"


# if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
#   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# fi
#
# if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# fi


# zsh-vi-mode
ZVM_VI_SURROUND_BINDKEY="s-prefix"

install_plugin "jeffreytse/zsh-vi-mode"
# if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode" ]; then
#   git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode
# fi

# zsh-nvm
# nvm ~ 할 때 ~를 자동완성 시켜주는 옵션. 활성화 해 두는게 좋음. (brew로 설치할 때에도 기본 활성화 되어 있다.)
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true
# lazy load가 적용되었을 때, nvm/node 말고도 extra command 로 오는 커맨드들을 입력할 때에 nvm load가 되도록 한다.
export NVM_LAZY_LOAD_EXTRA_COMMANDS=('nvim' 'git')
# .nvmrc 가 있는 경우, nvm load가 되는 순간 자동으로 .nvmrc 버전으로 맞춰준다.
export NVM_AUTO_USE=true
# if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm" ]; then
#   git clone https://github.com/leokang94/zsh-nvm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm
# fi

install_plugin "leokang94/zsh-nvm"



plugins=(
	git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
  zsh-nvm
)

source $ZSH/oh-my-zsh.sh
