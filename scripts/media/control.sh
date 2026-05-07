#!/usr/bin/env bash
# Devvychrome — control.sh
#
# Thin, defensive wrapper around playerctl for the Media Rail's
# Waybar click handlers and the rofi fallback menu.
#
# Usage: control.sh {play-pause|toggle|play|pause|next|previous|prev|stop}

set -u

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

case "${1:-}" in
    play-pause|toggle) playerctl play-pause >/dev/null 2>&1 ;;
    play)              playerctl play       >/dev/null 2>&1 ;;
    pause)             playerctl pause      >/dev/null 2>&1 ;;
    next)              playerctl next       >/dev/null 2>&1 ;;
    previous|prev)     playerctl previous   >/dev/null 2>&1 ;;
    stop)              playerctl stop       >/dev/null 2>&1 ;;
    *) exit 0 ;;
esac

# Nudge Waybar to repaint the now-playing module immediately rather
# than wait for the next 1 Hz tick. Matches "signal": 11 in
# config.jsonc.fragment. Signal 11 was chosen because the upstream
# HANCORE V2.1c live config already uses signals 7, 8, 9, and 10
# (custom/update, custom/screenrecording-indicator,
# custom/idle-indicator, custom/notification-silencing-indicator).
pkill -RTMIN+11 waybar >/dev/null 2>&1 || true
