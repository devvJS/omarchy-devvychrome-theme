#!/usr/bin/env bash
# Devvychrome — art.sh
#
# Resolves the current track's MPRIS art URL and writes a desaturated
# copy to a stable cache path. v1 does NOT consume the result (no
# popup ships in v1), but the helper lands now so the data plane is
# in place for the v1.5 eww popup.
#
# Usage:
#   art.sh           → prints the path to the cached grayscale image
#                      on success; prints nothing on failure
#   art.sh --refresh → forces re-fetch even if the cache appears warm
#
# Fallbacks:
#   - playerctl missing                 → exit silently
#   - no art URL on the active track    → exit silently
#   - no fetcher (curl/wget) for http   → exit silently
#   - no desaturator (magick/ffmpeg)    → exit silently
#
# All failure modes leave the previous cache contents intact.

set -u

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/devvychrome"
OUT_PATH="$CACHE_DIR/album-art-gray.png"
META_PATH="$CACHE_DIR/album-art.url"

mkdir -p "$CACHE_DIR"

if ! command -v playerctl >/dev/null 2>&1; then
    exit 0
fi

art_url=$(playerctl metadata --format '{{ mpris:artUrl }}' 2>/dev/null || true)
[[ -z "$art_url" ]] && exit 0

force=0
[[ "${1:-}" == "--refresh" ]] && force=1

if (( ! force )) && [[ -f "$META_PATH" && -f "$OUT_PATH" ]]; then
    prev=$(<"$META_PATH")
    if [[ "$prev" == "$art_url" ]]; then
        printf '%s\n' "$OUT_PATH"
        exit 0
    fi
fi

tmp_src=$(mktemp -t devvychrome-art-src.XXXXXX)
trap 'rm -f "$tmp_src"' EXIT

case "$art_url" in
    file://*)
        src_path=${art_url#file://}
        cp -- "$src_path" "$tmp_src" 2>/dev/null || exit 0
        ;;
    http://*|https://*)
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL --max-time 6 "$art_url" -o "$tmp_src" 2>/dev/null || exit 0
        elif command -v wget >/dev/null 2>&1; then
            wget -q --timeout=6 -O "$tmp_src" "$art_url" 2>/dev/null || exit 0
        else
            exit 0
        fi
        ;;
    *)
        exit 0
        ;;
esac

[[ -s "$tmp_src" ]] || exit 0

desaturated=0
if   command -v magick  >/dev/null 2>&1; then
    magick "$tmp_src" -colorspace Gray "$OUT_PATH" 2>/dev/null && desaturated=1
elif command -v convert >/dev/null 2>&1; then
    convert "$tmp_src" -colorspace Gray "$OUT_PATH" 2>/dev/null && desaturated=1
elif command -v ffmpeg  >/dev/null 2>&1; then
    ffmpeg -y -loglevel error -i "$tmp_src" -vf hue=s=0 "$OUT_PATH" 2>/dev/null && desaturated=1
fi

if (( desaturated )); then
    printf '%s\n' "$art_url" > "$META_PATH"
    printf '%s\n' "$OUT_PATH"
fi
