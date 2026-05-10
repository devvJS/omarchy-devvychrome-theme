#!/usr/bin/env bash
# Devvychrome — now-playing.sh
#
# Emits Waybar JSON for the Media Rail metadata module. Polled at
# 1 Hz; output is pango-marked-up text so the rail can carry an
# internal luminance hierarchy:
#
#   - status glyph     → active beacon (brightest in Playing state)
#   - track label      → muted metadata, recedes
#   - progress ribbon  → discrete-step meter, the readout the eye
#                        actually tracks during playback
#
# The module config in waybar/config.jsonc.fragment sets
# "escape": false because of this; dynamic content is pango-escaped
# in-script so no markup injection is possible from MPRIS metadata.
#
# Defensive: any missing dependency or absent player resolves to a
# benign idle payload. The Rail is never allowed to crash the bar.

set -u

GLYPH_PLAYING=''   # nf-fa-play
GLYPH_PAUSED=''    # nf-fa-pause
GLYPH_STOPPED=''   # nf-fa-stop
GLYPH_IDLE='·'      # quiet dot
MAX_LABEL=36
RIBBON_CELLS=8

pango_escape() {
    local s=$1
    s=${s//&/&amp;}
    s=${s//</&lt;}
    s=${s//>/&gt;}
    printf '%s' "$s"
}

json_escape() {
    local s=$1
    s=${s//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    s=${s//$'\r'/}
    s=${s//$'\t'/\\t}
    printf '%s' "$s"
}

emit() {
    # emit <text> <tooltip> <class> <percentage>
    printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%d}\n' \
        "$(json_escape "$1")" \
        "$(json_escape "$2")" \
        "$3" \
        "$4"
}

emit_idle() {
    # Recessed dot at deep-muted luminance. Reads as "rail standing by"
    # without occupying foreground attention.
    local glyph=$1 tooltip=$2 class=$3
    local html
    html="<span foreground=\"#5a5a5a\">${glyph}</span>"
    emit "$html" "$tooltip" "$class" 0
    exit 0
}

if ! command -v playerctl >/dev/null 2>&1; then
    emit "" "" "unavailable" 0
    exit 0
fi

# Single playerctl invocation pinned to one player. Splitting status
# and metadata across multiple calls let playerctl land on different
# players between calls (especially during track transitions or with
# multiple active MPRIS clients), which is the most common cause of
# the artist field flickering empty. ASCII unit-separator (\x1F) is
# used to delimit fields so any natural punctuation in titles or
# album names passes through cleanly.
SEP=$'\x1f'
fmt="{{status}}${SEP}{{xesam:artist}}${SEP}{{xesam:albumArtist}}${SEP}{{xesam:title}}${SEP}{{xesam:album}}${SEP}{{mpris:length}}"
data=$(playerctl metadata --format "$fmt" 2>/dev/null || true)

if [[ -z "$data" ]]; then
    emit_idle "$GLYPH_IDLE" "No active player" "idle"
fi

IFS=$'\x1f' read -r status artist album_artist title album len <<< "$data"
status=${status:-}
artist=${artist:-}
album_artist=${album_artist:-}
title=${title:-}
album=${album:-}
len=${len:-}

# Artist fallback chain. Spotify always populates xesam:artist, but
# during the brief metadata-refresh window on track changes it can
# return empty while xesam:albumArtist is still set. Some other
# players (notably web browser MPRIS) also leave xesam:artist empty
# but populate xesam:albumArtist. Falling back keeps the rail stable.
if [[ -z "$artist" ]]; then
    artist="$album_artist"
fi

# Position is a runtime property, not metadata; fetched separately.
# Slight race versus the metadata block is acceptable — it only
# affects the progress percentage by a tick.
pos=$(playerctl position 2>/dev/null || true)

# Luminance bands per playback state. Playing carries one bright
# beacon (the glyph) and one prominent readout (the progress fill);
# everything else recedes. Paused drops every band by one notch so
# the entire rail dims in concert.
case "$status" in
    Playing)
        glyph="$GLYPH_PLAYING"
        class="playing"
        c_glyph='#e0e0e0'           # text.primary — active beacon
        c_label='#c8c8c8'           # text.secondary — quieter metadata
        c_progress_fill='#c8c8c8'   # text.secondary — visually present
        c_progress_empty='#3a3a3a'  # one step above the rail interior
        ;;
    Paused)
        glyph="$GLYPH_PAUSED"
        class="paused"
        c_glyph='#9a9a9a'           # text.muted
        c_label='#9a9a9a'
        c_progress_fill='#6f6f6f'   # text.disabled — meter still visible
        c_progress_empty='#2b2b2b'
        ;;
    Stopped)
        emit_idle "$GLYPH_STOPPED" "Stopped" "stopped"
        ;;
    *)
        emit_idle "$GLYPH_IDLE" "${status}" "idle"
        ;;
esac

# Compose the label.
#
# The separator is a middle dot (U+00B7), not an em-dash (U+2014).
# The em-dash falls outside Latin-1 and is missing from many fixed-
# pitch / Nerd Font fallback chains, which can cause pango to render
# a tofu and clip subsequent characters. The middle dot is in every
# Latin-1 font, renders consistently, and matches the dashboard tone
# of the Rail. Both artist and title are always rendered when both
# are present, including in the paused state.
label=""
if [[ -n "$artist" && -n "$title" ]]; then
    label="$artist · $title"
elif [[ -n "$title" ]]; then
    label="$title"
elif [[ -n "$artist" ]]; then
    label="$artist"
fi

if (( ${#label} > MAX_LABEL )); then
    label="${label:0:MAX_LABEL-1}…"
fi

# Compute progress percentage. pos is seconds.fraction; len is
# microseconds (per the MPRIS spec).
percentage=0
if [[ -n "$pos" && -n "$len" && "$len" =~ ^[0-9]+$ ]] && (( len > 0 )); then
    pos_us=$(awk -v p="$pos" 'BEGIN { printf "%d", p * 1000000 }')
    pct=$(awk -v a="$pos_us" -v b="$len" 'BEGIN { printf "%d", (a*100)/b }')
    (( pct < 0 ))   && pct=0
    (( pct > 100 )) && pct=100
    percentage=$pct
fi

# 8-cell discrete-step meter using vertical-rectangle glyphs.
# Reads as instrument ticks rather than a continuous bar.
filled=$(( (percentage * RIBBON_CELLS + 50) / 100 ))
(( filled > RIBBON_CELLS )) && filled=$RIBBON_CELLS
empty=$(( RIBBON_CELLS - filled ))

fill_str=""
for ((i=0; i<filled; i++)); do fill_str+="▮"; done
empty_str=""
for ((i=0; i<empty; i++)); do empty_str+="▯"; done

ribbon_html=""
[[ -n "$fill_str"  ]] && ribbon_html+="<span foreground=\"$c_progress_fill\">$fill_str</span>"
[[ -n "$empty_str" ]] && ribbon_html+="<span foreground=\"$c_progress_empty\">$empty_str</span>"

# Assemble the marked-up text. Pango spans carry the per-element
# luminance; single spaces give a tight visual rhythm inside the
# capsule. Capsule-edge breathing room is owned by CSS, not text.
glyph_html="<span foreground=\"$c_glyph\">$glyph</span>"

label_html=""
if [[ -n "$label" ]]; then
    label_html="<span foreground=\"$c_label\">$(pango_escape "$label")</span>"
fi

text="$glyph_html"
[[ -n "$label_html"  ]] && text+=" $label_html"
[[ -n "$ribbon_html" ]] && text+=" $ribbon_html"

# Tooltip — pango-marked, three-line readout. Bold title, normal
# artist, italic album, then the literal status word.
title_p=$(pango_escape "${title:-}")
artist_p=$(pango_escape "${artist:-}")
album_p=$(pango_escape "${album:-}")

tooltip=""
if [[ -n "$title" ]]; then
    tooltip+="<b>${title_p}</b>"
fi
if [[ -n "$artist" ]]; then
    [[ -n "$tooltip" ]] && tooltip+=$'\n'
    tooltip+="${artist_p}"
fi
if [[ -n "$album" ]]; then
    [[ -n "$tooltip" ]] && tooltip+=$'\n'
    tooltip+="<i>${album_p}</i>"
fi
[[ -n "$tooltip" ]] && tooltip+=$'\n'
tooltip+="${status}"

emit "$text" "$tooltip" "$class" "$percentage"
