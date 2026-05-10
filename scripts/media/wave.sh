#!/usr/bin/env bash
# Devvychrome — wave.sh
#
# Streams a calm, fixed-width monochrome cava meter for the Media
# Rail. Each line is one frame written to stdout for Waybar's custom
# module reader. The Rail's progress ribbon is produced by
# now-playing.sh; this script contributes the optional audio-reactive
# layer.
#
# Stability notes (vs v1):
#   - Output width is fixed at exactly BARS characters per frame, so
#     the rail capsule never resizes between frames.
#   - Level 0 renders as the lowest visible block (▁), not a space, so
#     bar spacing reads stable even during silence.
#   - framerate is intentionally low (8 fps) and gravity tuned down so
#     bar motion reads as instrument metering, not equalizer rave.
#   - monstercat horizontal smoothing is disabled — it visibly couples
#     neighbouring bars into a wave that perceptually changes the
#     cluster's width.
#   - If cava exits unexpectedly, the script restarts it after a
#     short delay; an idle baseline is emitted in the meantime so
#     Waybar doesn't hold the last live frame indefinitely.
#
# Fallback: if cava is missing, exit silently and the module
# disappears. The Rail's progress ribbon remains.

set -u

if ! command -v cava >/dev/null 2>&1; then
    exit 0
fi

BARS=8

CONF=$(mktemp -t devvychrome-cava.conf.XXXXXX)
trap 'rm -f "$CONF"' EXIT

cat > "$CONF" <<CONF_EOF
[general]
bars = ${BARS}
framerate = 8
sensitivity = 100
autosens = 1
overshoot = 0

[smoothing]
noise_reduction = 95
monstercat = 0
waves = 0
gravity = 30
integral = 90

[output]
method = raw
data_format = ascii
ascii_max_range = 7
channels = mono
CONF_EOF

# Index 0 is the silence baseline. Using ▁ instead of a literal space
# keeps the meter visually stable — there are always BARS visible
# glyphs on every frame, so Waybar never reflows the capsule.
glyphs=( '▁' '▁' '▂' '▃' '▄' '▅' '▆' '▇' )

baseline=""
for ((i=0; i<BARS; i++)); do baseline+="${glyphs[0]}"; done

# Restart cava if it dies (e.g. PipeWire restart, sink change). One
# baseline frame is emitted in the gap so the rail visibly settles
# rather than freezing on the last live frame.
while :; do
    cava -p "$CONF" 2>/dev/null | while IFS= read -r frame; do
        frame=${frame%;}
        # Defensive: pad or truncate to BARS so the output width is
        # always exactly BARS characters.
        while (( ${#frame} < BARS )); do frame+="0"; done
        frame=${frame:0:BARS}

        out=""
        for ((i=0; i<BARS; i++)); do
            ch=${frame:i:1}
            case "$ch" in
                0) out+="${glyphs[0]}" ;;
                1) out+="${glyphs[1]}" ;;
                2) out+="${glyphs[2]}" ;;
                3) out+="${glyphs[3]}" ;;
                4) out+="${glyphs[4]}" ;;
                5) out+="${glyphs[5]}" ;;
                6) out+="${glyphs[6]}" ;;
                7) out+="${glyphs[7]}" ;;
                *) out+="${glyphs[0]}" ;;
            esac
        done
        printf '%s\n' "$out"
    done

    printf '%s\n' "$baseline"
    sleep 2
done
