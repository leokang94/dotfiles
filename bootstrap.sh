#!/bin/bash

# color variables
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CIAN='\033[0;36m'
CLEAR='\033[0m'

# echo prefix, postfix
LEO_PREFIX="${MAGENTA}[LEO]${CLEAR}"
DONE_POSTFIX="${GREEN}Done${CLEAR}"

##########################################################
# Install packages using brew
##########################################################

# Install Fonts
echo "${LEO_PREFIX} Download ${CIAN}font${CLEAR} from homebrew..."
brew install --cask \
  font-monaspace-nerd-font \
  font-symbols-only-nerd-font \
  font-d2coding \
  font-pretendard
echo "${LEO_PREFIX} Download ${CIAN}font${CLEAR} from homebrew... ${DONE_POSTFIX}"

# Install progrmas
echo "${LEO_PREFIX} Download ${CIAN}programs${CLEAR} from homebrew..."
brew install \
  nvim \
  fzf \
  starship \
  fastfetch \
  bat \
  bottom \
  zoxide \
  eza \
  yazi \
  hwatch \
  node

# felixkartz/formulae
brew tap FelixKratz/formulae
brew install \
  sketchybar \
  borders \


brew install --cask \
  google-chrome \
  raycast \
  discord \
  ghostty \
  obsidian \
  cleanmymac \
  karabiner-elements \
  nikitabobko/tap/aerospace \
  homerow \
  sf-symbols
echo "${LEO_PREFIX} Download ${CIAN}programs${CLEAR} from homebrew... ${DONE_POSTFIX}"

##########################################################
# Create a symbolic links
##########################################################

create_symlink() {
  local type=""
  local from=""
  local to=""

  # 인자 파싱
  while [ $# -gt 0 ]; do
    case "$1" in
    --type=*)
      type="${1#*=}"
      shift
      ;;
    *)
      if [ -z "$from" ]; then
        from="$1"
      elif [ -z "$to" ]; then
        to="$1"
      fi
      shift
      ;;
    esac
  done

  echo "${LEO_PREFIX} Create ${CIAN}symlink${CLEAR} :: ${CIAN}from${CLEAR}:${from}, ${CIAN}to${CLEAR}:${to}..."

  case "$type" in
  files)
    mkdir -p "${to}"
    ln -sf ${from}/* ${to}/
    ;;
  dir)
    ln -sf ${from} ${to}
    ;;
  *)
    echo "${LEO_PREFIX} Invalid type specified. Use --type=files or --type=dir.${CLEAR}"
    return 1
    ;;
  esac

  echo "${LEO_PREFIX} Create ${CIAN}symlink${CLEAR} :: ${CIAN}from${CLEAR}:${from}, ${CIAN}to${CLEAR}:${to}... ${DONE_POSTFIX}"
}

DOT_FILES_DIR_NAME=".dotfiles"
CONFIG_DIR_NAME=".config"
GIT_CUSTOM_COMMANDS_DIR_NAME=".git-custom-commands"

# 함수를 호출하면서 인자로 dotfiles 디렉토리와 타겟 디렉토리를 전달하세요.
create_symlink --type=files "$HOME/${DOT_FILES_DIR_NAME}/.config" "$HOME/${CONFIG_DIR_NAME}"
create_symlink --type=dir "$HOME/${DOT_FILES_DIR_NAME}/.git-custom-commands" "$HOME/${GIT_CUSTOM_COMMANDS_DIR_NAME}"

##########################################################
# Extends my .gitconfig to ~/.gitconfig
##########################################################

echo "${LEO_PREFIX} Extends source code to .gitconfig..."

GIT_CONFIG_EXTENDS_STRING="[include]
  path = ~/.dotfiles/.gitconfig
  "

if ! grep -Fxq "${GIT_CONFIG_EXTENDS_STRING}" ~/.gitconfig; then
  echo "${GIT_CONFIG_EXTENDS_STRING}" | cat - ~/.gitconfig >temp && mv temp ~/.gitconfig
fi

echo "${LEO_PREFIX} Extends source code to .gitconfig... ${DONE_POSTFIX}"

##########################################################
# Extends my .zshrc to ~/.zshrc
##########################################################

echo "${LEO_PREFIX} Extends source code to .zshrc..."

ZSHRC_EXTENDS_STRING="# use my own zshrc
  [ -f ~/${DOT_FILES_DIR_NAME}/.zshrc ] && source ~/${DOT_FILES_DIR_NAME}/.zshrc
  "

if ! grep -Fxq "${ZSHRC_EXTENDS_STRING}" ~/.zshrc; then
  echo "${ZSHRC_EXTENDS_STRING}" | cat - ~/.zshrc >temp && mv temp ~/.zshrc
fi

echo "${LEO_PREFIX} Extends source code to .zshrc... ${DONE_POSTFIX}"
