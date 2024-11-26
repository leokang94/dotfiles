#!/bin/bash

fields=(
  icon=󰸘
  update_freq=1
  script="$PLUGIN_DIR/calendar.sh"
)

sketchybar \
  --add item calendar right \
  --set calendar "${fields[@]}"
