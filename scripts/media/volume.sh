#!/usr/bin/env bash
# Devvychrome — volume.sh
#
# Get/set the default audio sink volume. Prefers wpctl (PipeWire,
# the Omarchy default); falls back to pactl (PulseAudio).
#
# Usage:
#   volume.sh get        → integer 0–100
#   volume.sh set <num>  → set sink volume to <num> (clamped 0–100,
#                          accepts floats — eww's scale onchange
#                          passes a float)
#
# Defensive: any missing tool / unreadable sink yields a quiet "50"
# on get and a no-op on set. The eww popup never sees an error.

set -u

cmd=${1:-get}
val=${2:-}

clamp_int() {
    local v
    v=$(printf '%.0f' "${1:-0}" 2>/dev/null) || v=0
    (( v < 0 ))   && v=0
    (( v > 100 )) && v=100
    printf '%d' "$v"
}

if command -v wpctl >/dev/null 2>&1; then
    case "$cmd" in
        get)
            line=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
            if [[ -z "$line" ]]; then
                echo 50
                exit 0
            fi
            # Output looks like: "Volume: 0.50 [MUTED]" — pull field 2.
            awk '{printf "%d", $2*100}' <<<"$line"
            echo
            exit 0
            ;;
        set)
            [[ -z "$val" ]] && exit 0
            v=$(clamp_int "$val")
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "${v}%" >/dev/null 2>&1 || true
            exit 0
            ;;
    esac
fi

if command -v pactl >/dev/null 2>&1; then
    case "$cmd" in
        get)
            v=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null \
                | grep -oE '[0-9]+%' \
                | head -1 \
                | tr -d %)
            if [[ -z "$v" ]]; then
                echo 50
            else
                echo "$v"
            fi
            exit 0
            ;;
        set)
            [[ -z "$val" ]] && exit 0
            v=$(clamp_int "$val")
            pactl set-sink-volume @DEFAULT_SINK@ "${v}%" >/dev/null 2>&1 || true
            exit 0
            ;;
    esac
fi

# Neither wpctl nor pactl available.
[[ "$cmd" == "get" ]] && echo 50
exit 0
