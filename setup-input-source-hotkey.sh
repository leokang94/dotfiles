#!/bin/bash

# color variables
GREEN=$(printf '\033[0;32m')
MAGENTA=$(printf '\033[0;35m')
CIAN=$(printf '\033[0;36m')
CLEAR=$(printf '\033[0m')

# echo prefix, postfix
LEO_PREFIX="${MAGENTA}[LEO]${CLEAR}"
DONE_POSTFIX="${GREEN}Done${CLEAR}"

##########################################################
# Setup Input Source Hotkey (F17)
##########################################################

printf '%s\n' "${LEO_PREFIX} Setting up ${CIAN}Input Source${CLEAR} hotkey to F17..."

# 61 = "입력 메뉴에서 다음 소스 선택" (Select next source in Input menu)
# parameters: [65535, 64, 8388608]
#   - 65535: special key flag
#   - 64: F17 keycode
#   - 8388608: Fn modifier (0x800000)

PLIST_DOMAIN="com.apple.symbolichotkeys"
HOTKEY_ID="61"

# Check current setting
CURRENT_ENABLED=$(defaults read ${PLIST_DOMAIN} AppleSymbolicHotKeys -dict-info 2>/dev/null |
  plutil -convert json -r -o - -- - 2>/dev/null |
  python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('${HOTKEY_ID}', {}).get('enabled', '0'))" 2>/dev/null)

CURRENT_KEYCODE=$(defaults read ${PLIST_DOMAIN} AppleSymbolicHotKeys -dict-info 2>/dev/null |
  plutil -convert json -r -o - -- - 2>/dev/null |
  python3 -c "import sys, json; data=json.load(sys.stdin); params=data.get('${HOTKEY_ID}', {}).get('value', {}).get('parameters', []); print(params[1] if len(params) > 1 else '0')" 2>/dev/null)

# Check if already configured correctly
if [ "$CURRENT_ENABLED" = "1" ] && [ "$CURRENT_KEYCODE" = "64" ]; then
  printf '%s\n' "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: Input source hotkey already set to F17"
else
  # Configure the hotkey
  printf '%s\n' "${LEO_PREFIX} Configuring input source hotkey..."

  defaults write ${PLIST_DOMAIN} AppleSymbolicHotKeys -dict-add ${HOTKEY_ID} "
    <dict>
      <key>enabled</key>
      <true/>
      <key>value</key>
      <dict>
        <key>parameters</key>
        <array>
          <integer>65535</integer>
          <integer>64</integer>
          <integer>8388608</integer>
        </array>
        <key>type</key>
        <string>standard</string>
      </dict>
    </dict>
  "

  if [ $? -eq 0 ]; then
    printf '%s\n' "${LEO_PREFIX} ${CIAN}Note${CLEAR} :: You may need to log out and log back in for changes to take effect"
    printf '%s\n' "${LEO_PREFIX} Setting up ${CIAN}Input Source${CLEAR} hotkey to F17... ${DONE_POSTFIX}"
  else
    printf '%s\n' "${LEO_PREFIX} ${CIAN}Failed${CLEAR} :: Could not configure input source hotkey"
    exit 1
  fi
fi
