#!/usr/bin/env bash
# Devvychrome — wave.sh
#
# Streams a compact, monochrome cava waveform for the Media Rail.
# Continuous output: each line is one frame, written to stdout for
# Waybar's custom-module reader. The Rail's progress ribbon is
# produced by now-playing.sh; this script only contributes the
# optional audio-reactive layer.
#
# Fallback: if cava is missing, exit silently and the module
# disappears. The Rail's progress ribbon remains.

set -u

if ! command -v cava >/dev/null 2>&1; then
    exit 0
fi

CONF=$(mktemp -t devvychrome-cava.conf.XXXXXX)
trap 'rm -f "$CONF"' EXIT

# Tuned for restraint: low framerate, six bars, heavy smoothing.
# ASCII raw mode emits per-bar digits 0..7 followed by ';'. The
# digits map onto Devvychrome's grayscale block glyphs below.
cat > "$CONF" <<'CONF_EOF'
[general]
bars = 6
framerate = 20
sensitivity = 100
autosens = 1
overshoot = 0

[smoothing]
noise_reduction = 88
monstercat = 1
waves = 0

[output]
method = raw
data_format = ascii
ascii_max_range = 7
channels = mono
CONF_EOF

glyphs=( ' ' '▁' '▂' '▃' '▄' '▅' '▆' '▇' )

cava -p "$CONF" 2>/dev/null | while IFS= read -r frame; do
    frame=${frame%;}
    out=""
    for ((i=0; i<${#frame}; i++)); do
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
            *) out+=" " ;;
        esac
    done
    printf '%s\n' "$out"
done
