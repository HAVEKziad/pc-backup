#!/usr/bin/bash

# --- CONFIG ---
THEMES_ROOT="$HOME/.config/themes"
IMAGE_PICKER_CONFIG="$HOME/.config/rofi-wallapaper-picker/image-picker.razi.rasinc"

# 1. SELECT THEME
SELECTED_THEME=$(ls "$THEMES_ROOT" | rofi -dmenu -p "Select Theme:")
[[ -z "$SELECTED_THEME" ]] && exit

THEME_DIR="$THEMES_ROOT/$SELECTED_THEME"
WALL_DIR="$THEME_DIR/wallpapers"

# 2. SELECT WALLPAPER
ROFI_MENU=""
while IFS= read -r WALL_PATH; do
    [[ -z "$WALL_PATH" ]] && continue
    WALL_NAME=$(basename "$WALL_PATH")
    ROFI_MENU+="${WALL_NAME}\0icon\x1f${WALL_PATH}\n"
done < <(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \))

SELECTED_FILE=$(echo -e "$ROFI_MENU" | rofi -dmenu -p "Wallpapers:" -theme "$IMAGE_PICKER_CONFIG" -markup-rows)
[[ -z "$SELECTED_FILE" ]] && exit

# 3. APPLY EVERYTHING
# Wallpaper
swww img "$WALL_DIR/$SELECTED_FILE" --transition-type any

# Symlinks (QUOTED for spaces)
ln -sf "$THEME_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
ln -sf "$THEME_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"
ln -sf "$THEME_DIR/ghostty/theme-colors" "$HOME/.config/ghostty/themes/active-theme"
ln -sf "$THEME_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ln -sf "$THEME_DIR/cava/config" "$HOME/.config/cava/config"
ln -sf "$THEME_DIR/hyprland/colors.conf" "$HOME/.config/hypr/colors.conf"

# SwayNC Config & Style
ln -sf "$THEME_DIR/swaync/config.json" "$HOME/.config/swaync/config.json"
ln -sf "$THEME_DIR/swaync/style.css" "$HOME/.config/swaync/style.css"

# Reload Services
pkill waybar && waybar &
swaync-client -R && swaync-client -rs
hyprctl reload

notify-send "Identity Swapped" "Theme: $SELECTED_THEME"
