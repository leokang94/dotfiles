#!/bin/bash

sketchybar --add item vpn right \
  --set vpn icon= \
  update_freq=5 \
  script="$PLUGIN_DIR/vpn.sh"
