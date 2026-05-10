#!/usr/bin/env bash
# Devvychrome — wave.sh (deterministic v4, in-place breathing)
#
# An 8-cell meter for the Media Rail. Each cell is anchored to its
# position; nothing ever travels left or right. While a player is
# Playing the row breathes vertically through a hand-tuned 16-frame
# cycle in which each frame differs from the previous by at most a
# couple of cells, each by a single level. The result is subtle
# in-place motion that reads as a quiet instrument meter, not as an
# equalizer.
#
# State patterns:
#   Playing  → 16-frame cycle, gentle central hill, edges quiet
#   Paused   → static low hump (dim, no motion)
#   else     → flat baseline (recessed)
#
# Width is exactly BARS glyphs every frame, so Waybar never reflows
# the capsule. Active player is resolved via lib/player.sh, the same
# selector the rail and the eww popup use.

set -u

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

SELF_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
# shellcheck disable=SC1091
source "$SELF_DIR/lib/player.sh"

BARS=8
TICK=0.5

# Index 0..7 → ▁▂▃▄▅▆▇█. Edge cells are kept at 0–1 across the cycle
# so the row's silhouette stays a soft central hump rather than a
# scrolling waveform.
GLYPHS=( '▁' '▂' '▃' '▄' '▅' '▆' '▇' '█' )

# 12 frames of the Playing pattern. Each entry is exactly BARS
# digits, mirror-symmetric (digit[i] == digit[7-i]) so the meter
# never appears to slide left or right; any change happens to a
# pair of cells equidistant from the center. Adjacent frames
# (including the wrap from last to first) move at most one
# symmetric pair at a time, each by a single level. Every cell
# varies across the cycle: outer pair (0, 7) ±1, inner pairs ±1,
# center pair ±2. The result is a soft hill that swells and recedes
# in place over a 6-second loop.
PLAY_FRAMES=(
    "01233210"
    "01244210"
    "02244220"
    "02255220"
    "12255221"
    "12355321"
    "12355321"
    "12344321"
    "12244221"
    "02244220"
    "02233220"
    "01233210"
)

PAUSED_FRAME="00122100"   # ▁▁▂▃▃▂▁▁ — static symmetric low hump
BASELINE_FRAME="00000000" # ▁▁▁▁▁▁▁▁ — recessed baseline

render() {
    local pattern=$1 out="" i d
    for ((i=0; i<BARS; i++)); do
        d="${pattern:i:1}"
        out+="${GLYPHS[d]}"
    done
    printf '%s\n' "$out"
}

phase=0
while :; do
    status=""
    if devvychrome_pick_player; then
        status=$(playerctl --player="$DEVVYCHROME_PLAYER" status 2>/dev/null || true)
    fi

    case "$status" in
        Playing)
            render "${PLAY_FRAMES[phase]}"
            phase=$(( (phase + 1) % ${#PLAY_FRAMES[@]} ))
            ;;
        Paused)
            render "$PAUSED_FRAME"
            ;;
        *)
            render "$BASELINE_FRAME"
            ;;
    esac

    sleep "$TICK"
done
