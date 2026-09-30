#!/bin/bash
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

if [ -z "$1" ]; then
    exit 1
fi

if command -v awww >/dev/null 2>&1; then
    awww img "$1" --transition-fps 60 --transition-duration 0.2
fi

if command -v wal >/dev/null 2>&1; then
    wal -q -s -i "$1"
    source "$HOME/.cache/wal/colors.sh"
    echo "$background|$color4" > "$HOME/.config/quickshell/island_colors"
    hyprctl reload

    if command -v kwriteconfig6 >/dev/null 2>&1; then
        HEX="${color4//\#/}"

        R=$((16#${HEX:0:2}))
        G=$((16#${HEX:2:2}))
        B=$((16#${HEX:4:2}))
        RGB="$R,$G,$B"

        kwriteconfig6 --file kdeglobals --group General --key AccentColor "$RGB"

        BG_R=$((R / 10 + 15))
        BG_G=$((G / 10 + 15))
        BG_B=$((B / 10 + 18))
        kwriteconfig6 --file kdeglobals --group "Colors:Window" --key BackgroundNormal "$BG_R,$BG_G,$BG_B"

        dbus-send --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:0 int32:0
    fi
fi