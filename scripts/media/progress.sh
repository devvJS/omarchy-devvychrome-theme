#!/usr/bin/env bash
# Devvychrome — progress.sh
#
# Reports current playback progress for the eww popup.
#
# Usage:
#   progress.sh        → integer 0–100 (percent), default mode
#   progress.sh pct    → integer 0–100 (percent), explicit
#   progress.sh time   → "MM:SS / MM:SS" (or "—" when unknown)
#
# Defensive: emits a benign default ("0" / "—") on any failure path
# so eww's polling never receives an error string.

set -u

cmd=${1:-pct}

emit_default() {
    if [[ "$cmd" == "time" ]]; then
        echo "—"
    else
        echo 0
    fi
}

if ! command -v playerctl >/dev/null 2>&1; then
    emit_default
    exit 0
fi

pos=$(playerctl position 2>/dev/null || true)
len=$(playerctl metadata --format '{{ mpris:length }}' 2>/dev/null || true)

if [[ -z "$pos" || -z "$len" || ! "$len" =~ ^[0-9]+$ ]] || (( len == 0 )); then
    emit_default
    exit 0
fi

case "$cmd" in
    pct)
        pos_us=$(awk -v p="$pos" 'BEGIN { printf "%d", p * 1000000 }')
        pct=$(awk -v a="$pos_us" -v b="$len" 'BEGIN { printf "%d", (a*100)/b }')
        (( pct < 0 ))   && pct=0
        (( pct > 100 )) && pct=100
        echo "$pct"
        ;;
    time)
        pos_s=$(awk -v p="$pos" 'BEGIN { printf "%d", p }')
        len_s=$(awk -v l="$len" 'BEGIN { printf "%d", l/1000000 }')
        format_time() {
            local s=$1
            local m=$(( s / 60 ))
            local r=$(( s % 60 ))
            printf "%02d:%02d" "$m" "$r"
        }
        printf '%s / %s\n' "$(format_time "$pos_s")" "$(format_time "$len_s")"
        ;;
    *)
        emit_default
        ;;
esac
