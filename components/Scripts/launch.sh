#!/bin/bash
export QSG_RENDER_LOOP=basic
export __GL_SYNC_TO_VBLANK=1
export __GL_MaxFramesAllowed=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

killall quickshell
exec quickshell
