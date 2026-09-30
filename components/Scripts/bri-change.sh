#!/bin/bash

if [ "$1" = "toggle" ]; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
else
    wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$1"
fi

VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100 + 0.5)}')
[ -z "$VOL" ] && VOL=0

echo "$VOL" > /tmp/island_vol
echo "volume" > /tmp/island_mode