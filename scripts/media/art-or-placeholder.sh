#!/usr/bin/env bash
# Devvychrome — art-or-placeholder.sh
#
# eww-friendly album-art resolver. Always emits a usable image path:
# the desaturated cached art when art.sh succeeds, otherwise the
# repo's placeholder PNG. The eww image widget never receives an
# empty path, so the popup's art slot reads identically whether art
# is available or not.
#
# Usage:
#   art-or-placeholder.sh
#
# Stdout: a single line containing the absolute path to a PNG.

set -u

self_dir=$(cd -- "$(dirname -- "$0")" && pwd)
repo_dir=$(cd -- "$self_dir/../.." && pwd)
placeholder="$repo_dir/eww/art-placeholder.png"

# Ensure the placeholder exists. It is normally generated once at
# scaffolding time; regenerate transparently if it has gone missing.
if [[ ! -f "$placeholder" ]]; then
    if   command -v magick  >/dev/null 2>&1; then
        magick  -size 80x80 xc:'#2b2b2b' "$placeholder" 2>/dev/null || true
    elif command -v convert >/dev/null 2>&1; then
        convert -size 80x80 xc:'#2b2b2b' "$placeholder" 2>/dev/null || true
    fi
fi

art=$("$self_dir/art.sh" 2>/dev/null || true)

if [[ -n "$art" && -f "$art" ]]; then
    printf '%s\n' "$art"
elif [[ -f "$placeholder" ]]; then
    printf '%s\n' "$placeholder"
fi
