#!/bin/bash

PLAYER=$(playerctl --list-all 2>/dev/null | head -n 1)
if [ -z "$PLAYER" ]; then
    echo "false|No Music|Paused||0.0" > /tmp/island_music
    exit 0
fi

STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)
if [ "$STATUS" = "Playing" ]; then
    PLAYING="true"
else
    PLAYING="false"
fi

TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)
[ -z "$TITLE" ] && TITLE="No Music"

ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
[ -z "$ARTIST" ] && ARTIST="Paused"

ART_URL=$(playerctl --player="$PLAYER" metadata mpris:artUrl 2>/dev/null)

POSITION=$(playerctl --player="$PLAYER" position 2>/dev/null || echo "0")
LENGTH=$(playerctl --player="$PLAYER" metadata mpris:length 2>/dev/null || echo "1")
if [ "$LENGTH" -gt 0 ]; then
    PROGRESS=$(awk "BEGIN {print $POSITION * 1000000 / $LENGTH}")
else
    PROGRESS="0.0"
fi

echo "$PLAYING|$TITLE|$ARTIST|$ART_URL|$PROGRESS" > /tmp/island_music