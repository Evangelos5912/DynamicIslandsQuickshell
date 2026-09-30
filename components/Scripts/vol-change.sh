#!/bin/bash

wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$1"

VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' 2>/dev/null)
[ -z "$VOL" ] && VOL=0

echo "$VOL" > /tmp/island_vol
echo "volume" > /tmp/island_mode