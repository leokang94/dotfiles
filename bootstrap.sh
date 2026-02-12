#!/bin/bash

# color variables
GREEN=$(printf '\033[0;32m')
MAGENTA=$(printf '\033[0;35m')
CIAN=$(printf '\033[0;36m')
CLEAR=$(printf '\033[0m')

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

printf '%s\n' "${LEO_PREFIX} Installing packages from ${CIAN}Brewfile${CLEAR}..."
brew bundle install --no-upgrade --file="$HOME/${DOT_FILES_DIR_NAME}/Brewfile"
printf '%s\n' "${LEO_PREFIX} Installing packages from ${CIAN}Brewfile${CLEAR}... ${DONE_POSTFIX}"

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

# 기존 타겟 처리 헬퍼 함수
# 반환값: 0 = 진행, 1 = 스킵
_handle_existing_target() {
  local target_path="$1"
  local expected_source="$2"

  # 타겟이 없으면 진행
  if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
    return 0
  fi

  # symlink인 경우
  if [ -L "$target_path" ]; then
    local current_link=$(readlink "$target_path")
    if [ "$current_link" = "$expected_source" ]; then
      printf '%s\n' "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: Already correct symlink at ${target_path}"
      return 1 # 스킵
    else
      rm "$target_path"
      return 0
    fi
  fi

  # 실제 파일/디렉토리 -> 백업
  local backup_path="${target_path}.bak"
  local counter=1
  while [ -e "$backup_path" ]; do
    backup_path="${target_path}.bak.${counter}"
    counter=$((counter + 1))
  done

  mv "$target_path" "$backup_path"
  printf '%s\n' "${LEO_PREFIX} ${CIAN}Backup${CLEAR} :: Moved ${target_path} to ${backup_path}"
  return 0
}

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

  printf '%s\n' "${LEO_PREFIX} Create ${CIAN}symlink${CLEAR} :: ${CIAN}from${CLEAR}:${from}, ${CIAN}to${CLEAR}:${to}..."

  case "$type" in
  multiple)
    mkdir -p "${to}"
    for source_file in ${from}/*; do
      local basename=$(basename "$source_file")
      local target_path="${to}/${basename}"
      if _handle_existing_target "$target_path" "$source_file"; then
        ln -s "$source_file" "$target_path"
        printf '%s\n' "${LEO_PREFIX} ${CIAN}Created${CLEAR} :: ${target_path} -> ${source_file}"
      fi
    done
    ;;
  single)
    # single 타입: to의 basename과 from의 basename이 같으면 to를 전체 경로로 사용
    # 다르면 to를 디렉토리로 간주하고 그 안에 from의 basename으로 생성
    local target_path
    local from_basename=$(basename "$from")
    local to_basename=$(basename "$to")

    if [ "$from_basename" = "$to_basename" ]; then
      # to가 전체 파일 경로 (예: .../config.yaml -> .../config.yaml)
      target_path="$to"
    else
      # to가 디렉토리 경로 (예: .../dir -> .../dir/.hammerspoon)
      target_path="${to}/${from_basename}"
    fi

    if _handle_existing_target "$target_path" "$from"; then
      mkdir -p "$(dirname "$target_path")"
      ln -s "$from" "$target_path"
      printf '%s\n' "${LEO_PREFIX} ${CIAN}Created${CLEAR} :: ${target_path} -> ${from}"
    fi
    ;;
  *)
    printf '%s\n' "${LEO_PREFIX} Invalid type specified. Use --type=files or --type=dir.${CLEAR}"
    return 1
    ;;
  esac

  printf '%s\n' "${LEO_PREFIX} Create ${CIAN}symlink${CLEAR} :: ${CIAN}from${CLEAR}:${from}, ${CIAN}to${CLEAR}:${to}... ${DONE_POSTFIX}"
}

# 함수를 호출하면서 인자로 dotfiles 디렉토리와 타겟 디렉토리를 전달하세요.
create_symlink --type=multiple "$HOME/${DOT_FILES_DIR_NAME}/.config" "$HOME/${CONFIG_DIR_NAME}"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.git-custom-commands" "$HOME"
create_symlink --type=multiple "$HOME/${DOT_FILES_DIR_NAME}/.claude" "$HOME/.claude"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.hammerspoon" "$HOME"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.config/mouseless/config.yaml" "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml"
create_symlink --type=single "$HOME/${DOT_FILES_DIR_NAME}/.serena" "$HOME"

##########################################################
# Extends my .gitconfig to ~/.gitconfig
##########################################################

printf '%s\n' "${LEO_PREFIX} Extends source code to .gitconfig..."

GIT_CONFIG_EXTENDS_STRING="[include]
  path = ~/.dotfiles/.gitconfig
  "

if ! grep -Fxq "${GIT_CONFIG_EXTENDS_STRING}" ~/.gitconfig; then
  echo "${GIT_CONFIG_EXTENDS_STRING}" | cat - ~/.gitconfig >temp && mv temp ~/.gitconfig
fi

printf '%s\n' "${LEO_PREFIX} Extends source code to .gitconfig... ${DONE_POSTFIX}"

##########################################################
# Extends my .zprofile, .zshrc to ~/.zprofile, ~/.zshrc
##########################################################

printf '%s\n' "${LEO_PREFIX} Extends source code to .zprofile, .zshrc..."

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

printf '%s\n' "${LEO_PREFIX} Extends source code to .zprofile, .zshrc... ${DONE_POSTFIX}"

##########################################################
# Set GX_JIRA_HOST environment variable
##########################################################

printf '%s\n' "${LEO_PREFIX} Setting ${CIAN}GX_JIRA_HOST${CLEAR} environment variable..."

GX_JIRA_HOST_PATTERN="export GX_JIRA_HOST="

if ! grep -q "${GX_JIRA_HOST_PATTERN}" ~/.zshrc; then
  read -p "Enter your Jira host (e.g., jira.company.com): " JIRA_HOST
  if [ -n "$JIRA_HOST" ]; then
    echo "\n# GX_JIRA_HOST for gx.nvim\nexport GX_JIRA_HOST=\"${JIRA_HOST}\"" >>~/.zshrc
    printf '%s\n' "${LEO_PREFIX} Added GX_JIRA_HOST=${JIRA_HOST} to ~/.zshrc... ${DONE_POSTFIX}"
  else
    printf '%s\n' "${LEO_PREFIX} Skipped (no value provided)... ${DONE_POSTFIX}"
  fi
else
  printf '%s\n' "${LEO_PREFIX} GX_JIRA_HOST already exists in ~/.zshrc... ${DONE_POSTFIX}"
fi

##########################################################
# Setup Claude Code plugins
##########################################################

if command -v claude &>/dev/null; then
  # 현재 스크립트의 디렉토리를 기준으로 setup-claude.sh 실행
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  "$SCRIPT_DIR/setup-claude.sh"
else
  printf '%s\n' "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: Claude Code not installed"
fi

##########################################################
# Setup Touch ID for sudo
##########################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/setup-touchid-sudo.sh"

##########################################################
# Setup Input Source Hotkey (F17)
##########################################################

"$SCRIPT_DIR/setup-input-source-hotkey.sh"
