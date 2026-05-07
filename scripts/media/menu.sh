#!/usr/bin/env bash
# Devvychrome — menu.sh
#
# rofi-driven transport menu. Wired to the Media Rail's right-click
# handler as a keyboard-friendly fallback until the v1.5 eww popup
# lands.
#
# Defensive design (v1):
#   - rofi is launched with explicit flags that disable any
#     auto-select / accept-on-empty-input behaviour. The user must
#     pick an entry deliberately.
#   - Selections are returned as integer indices via -format i, then
#     mapped to actions through an explicit table. There is no string
#     matching path that could "fall through" to play-pause if rofi
#     misbehaves or returns unexpected output.
#   - The first menu entry is the currently-playing track shown as
#     a non-selectable header (-no-custom + the index check below
#     reject any attempt to confirm it). Even if rofi auto-confirms
#     the highlighted row, the result is a no-op rather than a
#     transport action.
#   - All exits are explicit `exit 0`; nothing in this script ever
#     invokes the play-pause path implicitly.
#
# Fallbacks:
#   - rofi missing       → exit silently (no notification, no action)
#   - playerctl missing  → exit silently
#   - cancelled / Esc    → exit silently
#   - selection on header → no-op

set -u

if ! command -v rofi      >/dev/null 2>&1; then exit 0; fi
if ! command -v playerctl >/dev/null 2>&1; then exit 0; fi

control="$(dirname -- "$0")/control.sh"

# Resolve a short context line for the menu header. If no track is
# loaded, the header reads "(no active player)"; the menu still
# opens so the user gets explicit feedback that right-click worked.
status=$(playerctl status 2>/dev/null || true)
title=$( playerctl metadata --format '{{ title }}'  2>/dev/null || true)
artist=$(playerctl metadata --format '{{ artist }}' 2>/dev/null || true)

if [[ -n "$title" || -n "$artist" ]]; then
    header="${title:-?} · ${artist:-?}"
else
    header="(no active player)"
fi

# Indexed action table. Index 0 is the non-selectable header; every
# real action lives at index ≥ 1. The dispatch below refuses to
# act on index 0.
labels=(
    "$header"
    "Play / Pause"
    "Next"
    "Previous"
    "Stop"
)
actions=(
    ""            # index 0 — header, no action
    "play-pause"
    "next"
    "previous"
    "stop"
)

# Build menu input. One entry per line; trailing newline included so
# rofi sees a clean EOF.
menu_input=""
for l in "${labels[@]}"; do
    menu_input+="${l}"$'\n'
done

# rofi flags:
#   -dmenu              read entries from stdin
#   -i                  case-insensitive match
#   -p 'media'          short prompt
#   -no-custom          reject text that does not match an entry
#   -format i           return the index of the chosen entry
#   -selected-row 0     start with the cursor on the header (a
#                       non-actionable row at index 0). If the user's
#                       rofi config has any auto-select / quick-accept
#                       behaviour, the highlighted row resolves to a
#                       no-op rather than to "Play / Pause". Users
#                       reach the actions with one arrow-down keypress.
#   -theme-str          minimal width override; everything else honours
#                       the user's rofi theme
choice_index=$(
    printf '%s' "$menu_input" \
    | rofi -dmenu -i -p 'media' \
           -no-custom \
           -format i \
           -selected-row 0 \
           -theme-str 'window {width: 22em;}' \
           2>/dev/null
) || exit 0

# Empty selection (Esc, no match, etc.) → no-op.
[[ -z "$choice_index" ]] && exit 0

# Reject anything that isn't a non-negative integer in range.
if ! [[ "$choice_index" =~ ^[0-9]+$ ]]; then
    exit 0
fi
if (( choice_index < 1 || choice_index >= ${#actions[@]} )); then
    exit 0
fi

action=${actions[$choice_index]}
[[ -z "$action" ]] && exit 0

"$control" "$action"
