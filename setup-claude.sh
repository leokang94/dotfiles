#!/bin/bash

# Claude Code 설정 & 플러그인 자동 설치 스크립트

# color variables
GREEN=$(printf '\033[0;32m')
MAGENTA=$(printf '\033[0;35m')
CIAN=$(printf '\033[0;36m')
CLEAR=$(printf '\033[0m')

LEO_PREFIX="${MAGENTA}[LEO]${CLEAR}"
DONE_POSTFIX="${GREEN}Done${CLEAR}"

SETTINGS_FILE="$HOME/.claude/settings.json"

# section separator (same as bootstrap.sh)
print_section() {
  printf '\n%s\n' "${CIAN}══════════════════════════════════════════════════════${CLEAR}"
  printf '%s\n' "${LEO_PREFIX} $1"
  printf '%s\n' "${CIAN}══════════════════════════════════════════════════════${CLEAR}"
}

print_section "Setting up ${CIAN}Claude Code${CLEAR}"

##########################################################
# Configure settings.json
##########################################################

printf '%s\n' "${LEO_PREFIX} Configuring ${CIAN}settings${CLEAR}..."

mkdir -p "$HOME/.claude"

# Read existing settings or start with empty object
if [ -f "$SETTINGS_FILE" ]; then
  BASE_SETTINGS=$(cat "$SETTINGS_FILE")
else
  BASE_SETTINGS="{}"
fi

# Worktree notification hook command
WORKTREE_HOOK_CMD='if [[ "$PWD" == *"worktree"* ]] || [[ "$PWD" == *"worktrees"* ]]; then WORKTREE_NAME=$(basename "$PWD"); terminal-notifier -title "Claude Code - Worktree" -message "답변 완료: $WORKTREE_NAME" -sound default -group "claude-code-worktree" -sender com.apple.Terminal; fi'

# Merge managed settings into existing (preserves unmanaged keys like statusLine, other hooks)
echo "$BASE_SETTINGS" | jq --arg hook_cmd "$WORKTREE_HOOK_CMD" '
  .includeCoAuthoredBy = false |
  .alwaysThinkingEnabled = true |
  .permissions.allow = [
    "Bash(*)",
    "Edit(*)",
    "Write(*)",
    "Read(*)",
    "Glob(*)",
    "Grep(*)",
    "Search(*)",
    "WebFetch(*)",
    "WebSearch(*)",
    "Task(*)",
    "Skill(*)",
    "mcp__*"
  ] |
  .permissions.deny = [
    "Read(./.env)",
    "Read(./.env.*)",
    "Read(./secrets.*)",
    "Read(~/Library/Keychains/**)"
  ] |
  # Worktree notification hook: set as first element, preserve other Notification hooks
  .hooks.Notification = (
    [{"hooks": [{"type": "command", "command": $hook_cmd, "async": true}]}]
    + [(.hooks.Notification // [])[] | select(
        ((.hooks // [])[0].command // "") | test("worktree") | not
      )]
  )
' > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"

printf '%s\n' "${LEO_PREFIX} Configuring ${CIAN}settings${CLEAR}... ${DONE_POSTFIX}"

##########################################################
# Add marketplaces
##########################################################

printf '%s\n' "${LEO_PREFIX} Adding ${CIAN}marketplaces${CLEAR}..."

add_marketplace() {
  local name="$1"
  local repo="$2"

  if ! claude plugin marketplace list 2>/dev/null | grep -q "$name"; then
    printf '%s\n' "${LEO_PREFIX} Adding ${CIAN}$name${CLEAR} marketplace..."
    claude plugin marketplace add "$repo"
    printf '%s\n' "${LEO_PREFIX} Adding ${CIAN}$name${CLEAR} marketplace... ${DONE_POSTFIX}"
  else
    printf '%s\n' "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: $name marketplace already exists"
  fi
}

add_marketplace "claude-hud" "jarrodwatts/claude-hud"
add_marketplace "team-attention-plugins" "team-attention/plugins-for-claude-natives"

printf '%s\n' "${LEO_PREFIX} Adding ${CIAN}marketplaces${CLEAR}... ${DONE_POSTFIX}"

##########################################################
# Install plugins (adds to enabledPlugins automatically)
##########################################################

printf '%s\n' "${LEO_PREFIX} Installing ${CIAN}plugins${CLEAR}..."

install_plugin() {
  local plugin="$1"
  local marketplace="$2"

  if ! claude plugin list 2>/dev/null | grep -q "$plugin@$marketplace"; then
    printf '%s\n' "${LEO_PREFIX} Installing ${CIAN}$plugin${CLEAR} from ${CIAN}$marketplace${CLEAR}..."
    claude plugin install "$plugin@$marketplace"
    printf '%s\n' "${LEO_PREFIX} Installing ${CIAN}$plugin${CLEAR} from ${CIAN}$marketplace${CLEAR}... ${DONE_POSTFIX}"
  else
    printf '%s\n' "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: $plugin already installed"
  fi
}

install_plugin "claude-hud" "claude-hud"
install_plugin "session-wrap" "team-attention-plugins"

printf '%s\n' "${LEO_PREFIX} Installing ${CIAN}plugins${CLEAR}... ${DONE_POSTFIX}"
printf '%s\n' "${LEO_PREFIX} Setting up ${CIAN}Claude Code${CLEAR}... ${DONE_POSTFIX}"
