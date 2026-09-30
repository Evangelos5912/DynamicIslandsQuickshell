#!/bin/bash

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)
[ -z "$CPU" ] && CPU=0

RAM=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')

SWAP_TOTAL=$(free | grep Swap | awk '{print $2}')
if [ "$SWAP_TOTAL" -eq 0 ]; then
    SWAP=0
else
    SWAP=$(free | grep Swap | awk '{printf "%.0f", $3/$2 * 100}')
fi

BAT_PATH="/sys/class/power_supply/BAT1"
[ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT0"

if [ -d "$BAT_PATH" ]; then
    BAT=$(cat "$BAT_PATH/capacity")
else
    BAT=100
fi

echo "$CPU|$RAM|$SWAP|$BAT" > /tmp/island_sys