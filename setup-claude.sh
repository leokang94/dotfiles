#!/bin/bash

# Claude Code 플러그인 자동 설치 스크립트

# color variables
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CIAN='\033[0;36m'
CLEAR='\033[0m'

LEO_PREFIX="${MAGENTA}[LEO]${CLEAR}"
DONE_POSTFIX="${GREEN}Done${CLEAR}"

echo "${LEO_PREFIX} 🤖 Setting up ${CIAN}Claude Code plugins${CLEAR}..."

##########################################################
# Add marketplaces
##########################################################

echo "${LEO_PREFIX} Adding ${CIAN}marketplaces${CLEAR}..."

# Marketplace 추가 함수
add_marketplace() {
  local name="$1"
  local repo="$2"

  if ! claude plugin marketplace list 2>/dev/null | grep -q "$name"; then
    echo "${LEO_PREFIX} Adding ${CIAN}$name${CLEAR} marketplace..."
    claude plugin marketplace add "$repo"
    echo "${LEO_PREFIX} Adding ${CIAN}$name${CLEAR} marketplace... ${DONE_POSTFIX}"
  else
    echo "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: $name marketplace already exists"
  fi
}

add_marketplace "claude-hud" "jarrodwatts/claude-hud"
add_marketplace "team-attention-plugins" "team-attention/plugins-for-claude-natives"

echo "${LEO_PREFIX} Adding ${CIAN}marketplaces${CLEAR}... ${DONE_POSTFIX}"

##########################################################
# Install plugins
##########################################################

echo "${LEO_PREFIX} Installing ${CIAN}plugins${CLEAR}..."

# Plugin 설치 함수
install_plugin() {
  local plugin="$1"
  local marketplace="$2"

  if ! claude plugin list 2>/dev/null | grep -q "$plugin@$marketplace"; then
    echo "${LEO_PREFIX} Installing ${CIAN}$plugin${CLEAR} from ${CIAN}$marketplace${CLEAR}..."
    claude plugin install "$plugin@$marketplace"
    echo "${LEO_PREFIX} Installing ${CIAN}$plugin${CLEAR} from ${CIAN}$marketplace${CLEAR}... ${DONE_POSTFIX}"
  else
    echo "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: $plugin already installed"
  fi
}

install_plugin "claude-hud" "claude-hud"
install_plugin "session-wrap" "team-attention-plugins"

echo "${LEO_PREFIX} Installing ${CIAN}plugins${CLEAR}... ${DONE_POSTFIX}"
echo "${LEO_PREFIX} 🤖 Setting up ${CIAN}Claude Code plugins${CLEAR}... ${DONE_POSTFIX}"
