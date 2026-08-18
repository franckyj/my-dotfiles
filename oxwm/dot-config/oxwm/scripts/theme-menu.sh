# #!/usr/bin/env bash

# # thememenu — oxwm theme switcher (mirrors the bspwm thememenu).
# # Reads themes from ~/.config/oxwm/themes/<name>/ and swaps the active oxwm
# # palette, kitty theme, rofi colors, dunst colors, and wallpaper, then
# # reloads the affected programs.
# #
# # Usage: thememenu [theme-name]   (no arg = rofi picker)

# set -u

# OXWM_DIR="$HOME/.config/oxwm"
# THEMES_DIR="$OXWM_DIR/themes"
# ACTIVE_THEME_FILE="$HOME/.cache/oxwm/current_theme"

# ACTIVE_COLORS_LUA="$OXWM_DIR/colors.lua"     # oxwm bar/border palette (dofile'd by config.lua)
# # ACTIVE_ROFI_COLORS="$OXWM_DIR/rofi/colors.rasi"
# ACTIVE_ROFI_COLORS="$HOME/.config/rofi/colors.rasi"
# # DUNSTRC="$OXWM_DIR/dunst/dunstrc"
# DUNSTRC="$HOME/.config/dunst/dunstrc"
# OXWM_CONFIG="$OXWM_DIR/config.lua"           # holds the feh autostart line

# GTK3_CONF="$HOME/.config/gtk-3.0/settings.ini"
# XSETTINGSD_CONF="$HOME/.xsettingsd"
# # WALLPAPER_DIR="$OXWM_DIR/wallpaper"
# WALLPAPER_DIR="$HOME/walls"

# # ROFI_THEME="$OXWM_DIR/rofi/config.rasi"
# ROFI_THEME="$HOME/.config/rofi/config.rasi"

# mkdir -p "$(dirname "$ACTIVE_THEME_FILE")"

# # --- helpers ---

# # cfg_get FILE KEY — print the value of `key = value` lines (trims whitespace).
# cfg_get() {
#     awk -v k="$2" '
#         $0 !~ /^[[:space:]]*#/ {
#             n = index($0, "=")
#             if (n > 0) {
#                 key = substr($0, 1, n-1); val = substr($0, n+1)
#                 gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
#                 gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
#                 if (key == k) { print val; exit }
#             }
#         }' "$1"
# }

# notify() { notify-send -a "Theme" -u "${2:-normal}" -t "${3:-2000}" "Theme" "$1" 2>/dev/null; }

# # --- main ---

# current=$(cat "$ACTIVE_THEME_FILE" 2>/dev/null || echo "github_dark")

# if [ "${1:-}" ]; then
#     target="$1"
# else
#     target=$(ls -1 "$THEMES_DIR" 2>/dev/null | sort | \
#         rofi -dmenu -i -p "Theme ($current)" -theme "$ROFI_THEME")
# fi

# [ -z "$target" ] && exit 0

# THEME_DIR="$THEMES_DIR/$target"
# [ -d "$THEME_DIR" ] || { notify "Missing theme: $target" critical; exit 1; }

# CONF="$THEME_DIR/theme.conf"
# [ -r "$CONF" ] || { notify "Missing $CONF" critical; exit 1; }

# display_name=$(cfg_get "$CONF" name)
# display_name=${display_name:-$target}

# if [ "$current" = "$target" ]; then
#     notify "Already using $display_name" low 1500
#     exit 0
# fi

# # 1. Swap the color includes oxwm + rofi read.
# cp "$THEME_DIR/colors.lua"  "$ACTIVE_COLORS_LUA"
# cp "$THEME_DIR/colors.rasi" "$ACTIVE_ROFI_COLORS"

# # 2. Kitty — apply the named scheme from kitty's bundled iTerm2/kitty-themes
# #    collection (or a custom theme in ~/.config/kitty/themes/). The kitten writes
# #    current-theme.conf, updates kitty.conf's theme block, and reloads running
# #    windows. Falls back to the manifest's `ghostty` name (same iTerm2 naming).
# kitty_theme=$(cfg_get "$CONF" kitty)
# [ -z "$kitty_theme" ] && kitty_theme=$(cfg_get "$CONF" ghostty)
# if [ -n "$kitty_theme" ] && command -v kitty >/dev/null 2>&1; then
#     # cache-age must be non-negative: with no theme cache (fresh machine) a
#     # negative age errors out and the switch silently no-ops. A large positive
#     # age downloads the collection once if missing, then reuses it.
#     kitty +kitten themes --cache-age=1000 --reload-in=all "$kitty_theme" </dev/null >/dev/null 2>&1 || true
# fi

# # 3. GTK + icons across gtk-3.0/gtk-4.0; xsettingsd applies it live to running apps.
# gtk=$(cfg_get "$CONF" gtk)
# icons=$(cfg_get "$CONF" icons)
# for conf in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
#     [ -f "$conf" ] || continue
#     [ -n "$gtk" ]   && sed -i "s|^gtk-theme-name=.*|gtk-theme-name=${gtk}|"             "$conf"
#     [ -n "$icons" ] && sed -i "s|^gtk-icon-theme-name=.*|gtk-icon-theme-name=${icons}|" "$conf"
# done
# if [ -f "$XSETTINGSD_CONF" ]; then
#     [ -n "$gtk" ]   && sed -i "s|^Net/ThemeName .*|Net/ThemeName \"${gtk}\"|"           "$XSETTINGSD_CONF"
#     [ -n "$icons" ] && sed -i "s|^Net/IconThemeName .*|Net/IconThemeName \"${icons}\"|" "$XSETTINGSD_CONF"
#     if command -v xsettingsd >/dev/null 2>&1; then
#         killall xsettingsd 2>/dev/null; setsid xsettingsd >/dev/null 2>&1 &
#     fi
# fi

# # 4. Wallpaper — set now and persist in the feh autostart line.
# wp=$(cfg_get "$CONF" wallpaper)
# if [ -n "$wp" ] && [ -f "$WALLPAPER_DIR/$wp" ]; then
#     feh --bg-fill "$WALLPAPER_DIR/$wp"
#     sed -i "s|feh --bg-[a-z]* [^\"]*|feh --bg-fill ~/.config/oxwm/wallpaper/${wp}|" "$OXWM_CONFIG"
# fi

# # 5. Dunst — rewrite the quoted hex on each `# THEME: dunst_<key>` line, then restart.
# for k in frame_global bg_low fg_low frame_low highlight_low \
#          bg_normal fg_normal frame_normal highlight_normal \
#          bg_critical fg_critical frame_critical highlight_critical; do
#     v=$(cfg_get "$CONF" "dunst_$k")
#     [ -n "$v" ] && sed -i "/# THEME: dunst_$k\$/s/\"#[0-9a-fA-F]*\"/\"$v\"/" "$DUNSTRC"
# done
# pkill -x dunst 2>/dev/null
# setsid dunst -config "$DUNSTRC" >/dev/null 2>&1 &

# # 6. Reload oxwm so the bar + border colors pick up the new colors.lua.
# #    oxwm has no reload CLI, so we press its reload bind (Mod4+Shift+R).
# command -v xdotool >/dev/null 2>&1 && xdotool key super+shift+r

# # 7. Persist + notify.
# echo "$target" > "$ACTIVE_THEME_FILE"
# sleep 0.5
# notify "Switched to $display_name"
