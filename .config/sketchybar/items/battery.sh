#!/bin/bash

fields=(
  update_freq=120
  script="$PLUGIN_DIR/battery.sh"
)

sketchybar \
  --add item battery right \
  --set battery "${fields[@]}" \
  --subscribe battery system_woke power_source_change
