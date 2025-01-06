#!/bin/bash

# color variables
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CIAN='\033[0;36m'
CLEAR='\033[0m'

# echo prefix, postfix
LEO_PREFIX="${MAGENTA}[LEO]${CLEAR}"
DONE_POSTFIX="${GREEN}Done${CLEAR}"

# 기본적으로 테스트 모드는 비활성화
TEST_MODE=false

# 인자 파싱
for arg in "$@"; do
  case $arg in
  --test)
    TEST_MODE=true
    shift # 인자를 제거
    ;;
  *) ;;
  esac
done

# 테스트 모드일 경우 메시지 출력
if [ "$TEST_MODE" = true ]; then
  echo "${LEO_PREFIX} Running in ${CIAN}test mode${CLEAR}..."
fi

##########################################################
# Install packages using brew
##########################################################

# Install Fonts
echo "${LEO_PREFIX} Download ${CIAN}font${CLEAR} from homebrew..."
brew install \
  font-monaspace-nerd-font \
  font-symbols-only-nerd-font
echo "${LEO_PREFIX} Download ${CIAN}font${CLEAR} from homebrew... ${DONE_POSTFIX}"

# Install progrmas
echo "${LEO_PREFIX} Download ${CIAN}programs${CLEAR} from homebrew..."
brew install \
  nvim \
  starship \
  fastfetch \
  bat \
  zoxide \
  eza \
  yazi \
  node

brew install --cask \
  google-chrome \
  raycast \
  discord \
  ghostty \
  obsidian \
  cleanmymac \
  karabiner-elements \
  aerospace \
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

if [ "$TEST_MODE" = true ]; then
  CONFIG_DIR_NAME=".config_test"
  GIT_CUSTOM_COMMANDS_DIR_NAME=".git-custom-commands_test"
else
  CONFIG_DIR_NAME=".config"
  GIT_CUSTOM_COMMANDS_DIR_NAME=".git-custom-commands"
fi

# 함수를 호출하면서 인자로 dotfiles 디렉토리와 타겟 디렉토리를 전달하세요.
create_symlink --type=files "$HOME/${DOT_FILES_DIR_NAME}/.config" "$HOME/${CONFIG_DIR_NAME}"
create_symlink --type=dir "$HOME/${DOT_FILES_DIR_NAME}/.git-custom-commands" "$HOME/${GIT_CUSTOM_COMMANDS_DIR_NAME}"

##########################################################
# Add my .zshrc to ~/.zshrc
##########################################################

# ~/.zshrc 최상단에 dotfiles의 .zshrc를 source 하는 코드를 추가
echo "${LEO_PREFIX} Add source code to .zshrc..."
if ! grep -Fxq "[ -f ~/${DOT_FILES_DIR_NAME}/.zshrc ] && source ~/${DOT_FILES_DIR_NAME}/.zshrc" ~/.zshrc; then
  echo "# use my own zshrc
[ -f ~/${DOT_FILES_DIR_NAME}/.zshrc ] && source ~/${DOT_FILES_DIR_NAME}/.zshrc" | cat - ~/.zshrc >temp && mv temp ~/.zshrc
fi
echo "${LEO_PREFIX} Add source code to .zshrc... ${DONE_POSTFIX}"

##########################################################
# open programs install page that need install at App Store
##########################################################

# In your face - Meeting Reminder
open -a "Safari" "https://apps.apple.com/us/app/in-your-face-meeting-reminder/id1476964367?mt=12"

# Cursor Pro - Mouse Pointer
open -a "Safari" "https://apps.apple.com/us/app/cursor-pro/id1447043133"

# RunCat - CPU Monitor
open -a "Safari" "https://apps.apple.com/us/app/runcat/id1429033973?mt=12"

# KakaoTalk -- Messenger
open -a "Safari" "https://apps.apple.com/kr/app/kakaotalk/id869223134?mt=12"

# iShot - Screenshot
open -a "Safari" "https://apps.apple.com/kr/app/ishot-screenshot-recording-ocr/id1485844094?mt=12"
