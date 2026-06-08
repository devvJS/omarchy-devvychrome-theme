#!/usr/bin/env bash
# Devvychrome full installer
#
# Installs all Devvychrome theme assets into the correct Omarchy and user
# config paths. Safe to re-run: existing files are backed up before any
# change is made. Does not modify ~/.local/share/omarchy/.
#
# Usage:
#   bash scripts/install-devvychrome-full.sh
#
# Rollback:
#   Backups land in ~/.config/devvychrome-backups/<timestamp>/
#   To undo: cp -a <backup>/<path> <original-path>
#   For tmux source line: manually remove the
#     source-file ~/.config/tmux/devvychrome.conf
#   line from ~/.config/tmux/tmux.conf

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="$HOME/.config/devvychrome-backups/$(date +%Y%m%d-%H%M%S)"
THEME_DIR="$HOME/.config/omarchy/themes/devvychrome"

mkdir -p "$BACKUP"

# ── Helpers ──────────────────────────────────────────────────────────

backup() {
  local path="$1"
  if [ -e "$path" ] || [ -L "$path" ]; then
    local rel="${path#$HOME/}"
    mkdir -p "$BACKUP/$(dirname "$rel")"
    cp -a "$path" "$BACKUP/$rel"
  fi
}

install_file() {
  local src="$1" dst="$2"
  backup "$dst"
  cp "$src" "$dst"
}

info()  { echo "  [ok] $*"; }
warn()  { echo "  [!!] $*"; }

# ── Directories ───────────────────────────────────────────────────────

mkdir -p \
  "$THEME_DIR/backgrounds" \
  "$HOME/.config/mako" \
  "$HOME/.config/wlogout" \
  "$HOME/.config/eww" \
  "$HOME/.config/walker/themes/devvychrome" \
  "$HOME/.config/waybar" \
  "$HOME/.config/gtk-3.0" \
  "$HOME/.config/gtk-4.0" \
  "$HOME/.config/nvim/colors" \
  "$HOME/.config/tmux" \
  "$HOME/.config/yazi"

# ── 1. Omarchy theme directory ────────────────────────────────────────
# The theme dir is a plain directory (NOT a symlink to the repo).
# Only recognised Omarchy theme assets live here.
# Remove the stray repo-symlink if a previous install created it.
if [ -L "$THEME_DIR/omarchy-devvychrome-theme" ]; then
  rm "$THEME_DIR/omarchy-devvychrome-theme"
  info "Removed stale repo symlink from theme dir"
fi

install_file "$REPO/colors.toml"  "$THEME_DIR/colors.toml"
install_file "$REPO/mako.ini"     "$THEME_DIR/mako.ini"
install_file "$REPO/neovim.lua"   "$THEME_DIR/neovim.lua"
install_file "$REPO/icons.theme"  "$THEME_DIR/icons.theme"
install_file "$REPO/vscode.json"  "$THEME_DIR/vscode.json"

# Backgrounds: sync png files; skip .gitkeep
for bg in "$REPO/backgrounds/"*.png; do
  [ -f "$bg" ] || continue
  cp "$bg" "$THEME_DIR/backgrounds/$(basename "$bg")"
done

info "Omarchy theme dir: $THEME_DIR"

# ── 2. Neovim colorscheme ─────────────────────────────────────────────
# Installed to ~/.config/nvim/colors/ so `colorscheme devvychrome` works.
# The neovim.lua above points LazyVim at this file by name.
install_file "$REPO/colors/devvychrome.lua" "$HOME/.config/nvim/colors/devvychrome.lua"
info "Neovim colorscheme: ~/.config/nvim/colors/devvychrome.lua"

# ── 3. Mako ──────────────────────────────────────────────────────────
install_file "$REPO/mako.ini" "$HOME/.config/mako/config"
info "Mako: ~/.config/mako/config"

# ── 4. Wlogout ───────────────────────────────────────────────────────
install_file "$REPO/wlogout/layout"    "$HOME/.config/wlogout/layout"
install_file "$REPO/wlogout/style.css" "$HOME/.config/wlogout/style.css"
info "Wlogout: ~/.config/wlogout/{layout,style.css}"

# ── 5. Eww ───────────────────────────────────────────────────────────
install_file "$REPO/eww/eww.yuck"           "$HOME/.config/eww/eww.yuck"
install_file "$REPO/eww/eww.scss"           "$HOME/.config/eww/eww.scss"
install_file "$REPO/eww/art-placeholder.png" "$HOME/.config/eww/art-placeholder.png"
info "Eww: ~/.config/eww/"

# ── 6. Walker ────────────────────────────────────────────────────────
# Devvychrome ships a standalone Walker theme (not the omarchy-default
# @import hook). Install to both the user config path and the omarchy
# additional_theme_location so Walker finds it regardless of config.
install_file "$REPO/walker/themes/devvychrome/layout.xml" \
  "$HOME/.config/walker/themes/devvychrome/layout.xml"
install_file "$REPO/walker/themes/devvychrome/style.css" \
  "$HOME/.config/walker/themes/devvychrome/style.css"

WALKER_OMARCHY_DIR="$HOME/.local/share/omarchy/default/walker/themes/devvychrome"
if [ -d "$(dirname "$WALKER_OMARCHY_DIR")" ]; then
  mkdir -p "$WALKER_OMARCHY_DIR"
  cp "$REPO/walker/themes/devvychrome/layout.xml" "$WALKER_OMARCHY_DIR/layout.xml"
  cp "$REPO/walker/themes/devvychrome/style.css"  "$WALKER_OMARCHY_DIR/style.css"
  info "Walker theme: ~/.config/walker/themes/devvychrome/ + omarchy default path"
else
  info "Walker theme: ~/.config/walker/themes/devvychrome/"
fi

# Set walker config to use devvychrome theme
WALKER_CFG="$HOME/.config/walker/config.toml"
if [ -f "$WALKER_CFG" ] && ! grep -q 'theme = "devvychrome"' "$WALKER_CFG"; then
  backup "$WALKER_CFG"
  sed -i 's/^theme = .*/theme = "devvychrome"/' "$WALKER_CFG"
  info "Walker config: set theme = devvychrome"
fi

# ── 7. Waybar ────────────────────────────────────────────────────────
install_file "$REPO/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
install_file "$REPO/waybar/style.css"    "$HOME/.config/waybar/style.css"
info "Waybar: ~/.config/waybar/{config.jsonc,style.css}"

# ── 8. GTK3 / GTK4 ───────────────────────────────────────────────────
install_file "$REPO/gtk/gtk4.css" "$HOME/.config/gtk-4.0/gtk.css"
install_file "$REPO/gtk/gtk3.css" "$HOME/.config/gtk-3.0/gtk.css"
info "GTK4: ~/.config/gtk-4.0/gtk.css"
info "GTK3: ~/.config/gtk-3.0/gtk.css"

# ── 9. tmux ──────────────────────────────────────────────────────────
install_file "$REPO/tmux/devvychrome.conf" "$HOME/.config/tmux/devvychrome.conf"
info "tmux theme: ~/.config/tmux/devvychrome.conf"

TMUX_CONF="$HOME/.config/tmux/tmux.conf"
TMUX_SOURCE="source-file ~/.config/tmux/devvychrome.conf"
if [ -f "$TMUX_CONF" ]; then
  if ! grep -qF "$TMUX_SOURCE" "$TMUX_CONF"; then
    backup "$TMUX_CONF"
    echo "" >> "$TMUX_CONF"
    echo "# Devvychrome theme" >> "$TMUX_CONF"
    echo "$TMUX_SOURCE" >> "$TMUX_CONF"
    info "tmux.conf: appended source-file line"
  else
    info "tmux.conf: source-file line already present"
  fi
else
  warn "~/.config/tmux/tmux.conf not found — create it and add:"
  warn "  $TMUX_SOURCE"
fi

# ── 10. yazi ─────────────────────────────────────────────────────────
install_file "$REPO/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
info "yazi: ~/.config/yazi/theme.toml"

# ── 11. Media scripts ─────────────────────────────────────────────────
chmod +x "$REPO"/scripts/media/*.sh
chmod +x "$REPO"/scripts/media/lib/*.sh

# ── 12. Apply theme via Omarchy ───────────────────────────────────────
echo ""
echo "Devvychrome assets installed. Backup: $BACKUP"
echo ""
echo "Apply with:"
echo "  omarchy-theme-set devvychrome"
echo ""
echo "Or restart individual components:"
echo "  omarchy-restart-waybar"
echo "  omarchy-restart-mako"
echo "  tmux source ~/.config/tmux/tmux.conf    # in a running session"
