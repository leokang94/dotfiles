#!/bin/bash

# color variables
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CIAN='\033[0;36m'
CLEAR='\033[0m'

# echo prefix, postfix
LEO_PREFIX="${MAGENTA}[LEO]${CLEAR}"
DONE_POSTFIX="${GREEN}Done${CLEAR}"

# directory variables
DOT_FILES_DIR_NAME=".dotfiles"
CONFIG_DIR_NAME=".config"
GIT_CUSTOM_COMMANDS_DIR_NAME=".git-custom-commands"

##########################################################
# Install packages using brew bundle
##########################################################

echo "${LEO_PREFIX} Installing packages from ${CIAN}Brewfile${CLEAR}..."
brew bundle install --no-upgrade --file="$HOME/${DOT_FILES_DIR_NAME}/Brewfile"
echo "${LEO_PREFIX} Installing packages from ${CIAN}Brewfile${CLEAR}... ${DONE_POSTFIX}"

# services start
brew services restart borders

##########################################################
# Install lsp server that not included in Mason
##########################################################

# cssls
npm i -g vscode-langservers-extracted

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
  multiple)
    mkdir -p "${to}"
    ln -sf ${from}/* ${to}/
    ;;
  single)
    ln -sf ${from} ${to}
    ;;
  *)
    echo "${LEO_PREFIX} Invalid type specified. Use --type=files or --type=dir.${CLEAR}"
    return 1
    ;;
  esac

  echo "${LEO_PREFIX} Create ${CIAN}symlink${CLEAR} :: ${CIAN}from${CLEAR}:${from}, ${CIAN}to${CLEAR}:${to}... ${DONE_POSTFIX}"
}

# 함수를 호출하면서 인자로 dotfiles 디렉토리와 타겟 디렉토리를 전달하세요.
create_symlink --type=multiple "$HOME/${DOT_FILES_DIR_NAME}/.config" "$HOME/${CONFIG_DIR_NAME}"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.git-custom-commands" "$HOME"
create_symlink --type=multiple "$HOME/${DOT_FILES_DIR_NAME}/.claude" "$HOME/.claude"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.hammerspoon" "$HOME"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.config/mouseless/config.yaml" "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.config/flashspace/settings.json" "$HOME/${CONFIG_DIR_NAME}/flashspace/settings.json"

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
# Extends my .zprofile, .zshrc to ~/.zprofile, ~/.zshrc
##########################################################

echo "${LEO_PREFIX} Extends source code to .zprofile, .zshrc..."

ZPROFILE_EXTENDS_STRING="# use my own .zprofile
  [ -f ~/${DOT_FILES_DIR_NAME}/.zprofile ] && source ~/${DOT_FILES_DIR_NAME}/.zprofile
  "

ZSHRC_EXTENDS_STRING="# use my own .zshrc
  [ -f ~/${DOT_FILES_DIR_NAME}/.zshrc ] && source ~/${DOT_FILES_DIR_NAME}/.zshrc
  "

# Create files if they don't exist
[ ! -f ~/.zprofile ] && touch ~/.zprofile
[ ! -f ~/.zshrc ] && touch ~/.zshrc

if ! grep -Fxq "${ZPROFILE_EXTENDS_STRING}" ~/.zprofile; then
  echo "${ZPROFILE_EXTENDS_STRING}" | cat - ~/.zprofile >temp && mv temp ~/.zprofile
fi

if ! grep -Fxq "${ZSHRC_EXTENDS_STRING}" ~/.zshrc; then
  echo "${ZSHRC_EXTENDS_STRING}" | cat - ~/.zshrc >temp && mv temp ~/.zshrc
fi

echo "${LEO_PREFIX} Extends source code to .zprofile, .zshrc... ${DONE_POSTFIX}"

##########################################################
# Set GX_JIRA_HOST environment variable
##########################################################

echo "${LEO_PREFIX} Setting ${CIAN}GX_JIRA_HOST${CLEAR} environment variable..."

GX_JIRA_HOST_PATTERN="export GX_JIRA_HOST="

if ! grep -q "${GX_JIRA_HOST_PATTERN}" ~/.zshrc; then
  read -p "Enter your Jira host (e.g., jira.company.com): " JIRA_HOST
  if [ -n "$JIRA_HOST" ]; then
    echo "\n# GX_JIRA_HOST for gx.nvim\nexport GX_JIRA_HOST=\"${JIRA_HOST}\"" >>~/.zshrc
    echo "${LEO_PREFIX} Added GX_JIRA_HOST=${JIRA_HOST} to ~/.zshrc... ${DONE_POSTFIX}"
  else
    echo "${LEO_PREFIX} Skipped (no value provided)... ${DONE_POSTFIX}"
  fi
else
  echo "${LEO_PREFIX} GX_JIRA_HOST already exists in ~/.zshrc... ${DONE_POSTFIX}"
fi
