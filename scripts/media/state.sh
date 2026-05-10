#!/usr/bin/env bash
# Devvychrome — state.sh
#
# Single-field state probe for the eww Media Controls popup. Each
# invocation resolves the same active MPRIS player as the Waybar
# rail (via lib/player.sh) and prints exactly one field's value.
#
# Without this wrapper, the popup's defpolls would call `playerctl`
# directly and select the first player alphabetically — letting a
# stopped Chromium tab make the popup show a Play icon while
# Spotify is actually playing.
#
# Usage:
#   state.sh status   → Playing | Paused | Stopped (defaults to Stopped)
#   state.sh title    → xesam:title or empty
#   state.sh artist   → xesam:artist, falling back to xesam:albumArtist
#   state.sh album    → xesam:album or empty
#
# Defensive: every failure path emits a benign default so the popup
# never receives an error string.

set -u

cmd=${1:-status}
default_for() {
    case "$1" in
        status) printf 'Stopped\n' ;;
        *)      printf '\n' ;;
    esac
}

if ! command -v playerctl >/dev/null 2>&1; then
    default_for "$cmd"
    exit 0
fi

SELF_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck disable=SC1091
source "$SELF_DIR/lib/player.sh"

if ! devvychrome_pick_player; then
    default_for "$cmd"
    exit 0
fi

case "$cmd" in
    status)
        s=$(playerctl --player="$DEVVYCHROME_PLAYER" status 2>/dev/null || true)
        printf '%s\n' "${s:-Stopped}"
        ;;
    title)
        t=$(playerctl --player="$DEVVYCHROME_PLAYER" metadata --format '{{ xesam:title }}' 2>/dev/null || true)
        printf '%s\n' "$t"
        ;;
    artist)
        a=$(playerctl --player="$DEVVYCHROME_PLAYER" metadata --format '{{ xesam:artist }}' 2>/dev/null || true)
        if [[ -z "$a" ]]; then
            a=$(playerctl --player="$DEVVYCHROME_PLAYER" metadata --format '{{ xesam:albumArtist }}' 2>/dev/null || true)
        fi
        printf '%s\n' "$a"
        ;;
    album)
        b=$(playerctl --player="$DEVVYCHROME_PLAYER" metadata --format '{{ xesam:album }}' 2>/dev/null || true)
        printf '%s\n' "$b"
        ;;
    *)
        default_for "$cmd"
        ;;
esac
