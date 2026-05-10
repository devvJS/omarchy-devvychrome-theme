#!/usr/bin/env bash
# Devvychrome — lib/player.sh (sourceable)
#
# Helpers for picking the "right" MPRIS player when multiple are
# active. The Media Rail consumers source this and call
# `devvychrome_pick_player` to populate $DEVVYCHROME_PLAYER, then
# pass that as `--player="$DEVVYCHROME_PLAYER"` to every subsequent
# playerctl invocation.
#
# Without this layer, raw playerctl falls back to a fixed default
# (typically the first player alphabetically), which causes a stopped
# Chromium tab to suppress an actively-playing Spotify on this
# system.
#
# Selection priority:
#   1. Spotify with status=Playing
#   2. Any other player with status=Playing
#   3. Spotify with status=Paused (still has metadata)
#   4. Any other player with status=Paused
# Stopped / unknown / no-status players are ignored, so a stopped
# browser tab never wins over a paused Spotify track.
#
# Returns 0 on success ($DEVVYCHROME_PLAYER set to a non-empty name),
# returns 1 if nothing usable was found. Defensive: if playerctl is
# missing or returns no players, sets $DEVVYCHROME_PLAYER='' and
# returns 1; consumers handle the no-player path themselves.

devvychrome_pick_player() {
    DEVVYCHROME_PLAYER=""
    command -v playerctl >/dev/null 2>&1 || return 1

    local players=() p s
    local playing_spotify="" playing_other=""
    local paused_spotify=""  paused_other=""

    mapfile -t players < <(playerctl -l 2>/dev/null)
    [[ ${#players[@]} -eq 0 ]] && return 1

    for p in "${players[@]}"; do
        [[ -z "$p" ]] && continue
        s=$(playerctl --player="$p" status 2>/dev/null || true)
        case "$s" in
            Playing)
                if [[ "$p" == spotify* ]]; then
                    playing_spotify="$p"
                elif [[ -z "$playing_other" ]]; then
                    playing_other="$p"
                fi
                ;;
            Paused)
                if [[ "$p" == spotify* ]]; then
                    paused_spotify="$p"
                elif [[ -z "$paused_other" ]]; then
                    paused_other="$p"
                fi
                ;;
        esac
    done

    if   [[ -n "$playing_spotify" ]]; then DEVVYCHROME_PLAYER="$playing_spotify"
    elif [[ -n "$playing_other"   ]]; then DEVVYCHROME_PLAYER="$playing_other"
    elif [[ -n "$paused_spotify"  ]]; then DEVVYCHROME_PLAYER="$paused_spotify"
    elif [[ -n "$paused_other"    ]]; then DEVVYCHROME_PLAYER="$paused_other"
    else
        return 1
    fi
    return 0
}
