#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="$HOME/.config/devvychrome-backups/$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP"

backup() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    mkdir -p "$BACKUP/$(dirname "${path#$HOME/.config/}")"
    cp -a "$path" "$BACKUP/${path#$HOME/.config/}"
  fi
}

mkdir -p \
  "$HOME/.config/omarchy/themes" \
  "$HOME/.config/mako" \
  "$HOME/.config/wlogout" \
  "$HOME/.config/eww" \
  "$HOME/.config/walker/themes/devvychrome" \
  "$HOME/.config/waybar"

ln -sfn "$REPO" "$HOME/.config/omarchy/themes/devvychrome"

backup "$HOME/.config/mako/config"
backup "$HOME/.config/wlogout/layout"
backup "$HOME/.config/wlogout/style.css"
backup "$HOME/.config/eww/eww.yuck"
backup "$HOME/.config/eww/eww.scss"
backup "$HOME/.config/walker/themes/devvychrome"
backup "$HOME/.config/waybar/config.jsonc"
backup "$HOME/.config/waybar/style.css"

cp "$REPO/mako.ini" "$HOME/.config/mako/config"

cp "$REPO/wlogout/layout" "$HOME/.config/wlogout/layout"
cp "$REPO/wlogout/style.css" "$HOME/.config/wlogout/style.css"

cp "$REPO/eww/eww.yuck" "$HOME/.config/eww/eww.yuck"
cp "$REPO/eww/eww.scss" "$HOME/.config/eww/eww.scss"
cp "$REPO/eww/art-placeholder.png" "$HOME/.config/eww/art-placeholder.png"

cp "$REPO/walker/themes/devvychrome/layout.xml" "$HOME/.config/walker/themes/devvychrome/layout.xml"
cp "$REPO/walker/themes/devvychrome/style.css" "$HOME/.config/walker/themes/devvychrome/style.css"

cp "$REPO/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp "$REPO/waybar/style.css" "$HOME/.config/waybar/style.css"

chmod +x "$REPO"/scripts/media/*.sh
chmod +x "$REPO"/scripts/media/lib/*.sh

echo "Installed Devvychrome assets."
echo "Backup saved to: $BACKUP"
echo
echo "Restart Waybar with: omarchy-restart-waybar"
