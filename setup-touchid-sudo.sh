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
# Setup Touch ID for sudo
##########################################################

printf '%s\n' "${LEO_PREFIX} Setting up ${CIAN}Touch ID${CLEAR} for sudo..."

SUDO_LOCAL_PATH="/etc/pam.d/sudo_local"
PAM_TID_LINE="auth       sufficient     pam_tid.so"

# Check if sudo_local already exists and has Touch ID configured
if [ -f "$SUDO_LOCAL_PATH" ] && grep -q "pam_tid.so" "$SUDO_LOCAL_PATH"; then
  printf '%s\n' "${LEO_PREFIX} ${CIAN}Skipped${CLEAR} :: Touch ID already configured for sudo"
else
  # Create sudo_local with Touch ID configuration
  printf '%s\n' "${LEO_PREFIX} Creating ${CIAN}${SUDO_LOCAL_PATH}${CLEAR} with Touch ID support..."

  sudo tee "$SUDO_LOCAL_PATH" > /dev/null <<EOF
# Enable Touch ID for sudo
${PAM_TID_LINE}
EOF

  if [ $? -eq 0 ]; then
    printf '%s\n' "${LEO_PREFIX} Setting up ${CIAN}Touch ID${CLEAR} for sudo... ${DONE_POSTFIX}"
  else
    printf '%s\n' "${LEO_PREFIX} ${CIAN}Failed${CLEAR} :: Could not create ${SUDO_LOCAL_PATH}"
    exit 1
  fi
fi
