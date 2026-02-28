#!/bin/zsh

# Path to your wallpaper folder (space handled by quotes)
WALL_DIR="$HOME/.config/themes/csm theme/livewall/"

# 1. List video files only
# 2. Pipe to Rofi with Gold accent styling
selected=$(ls "$WALL_DIR" | grep -E ".mp4$|.mkv$|.webm$" | rofi -dmenu -p "󰐊 Contract Select" \
    -theme-str 'window {width: 400px; border: 2px; border-color: #ffb800; background-color: rgba(13, 13, 13, 0.9);}')

if [ -n "$selected" ]; then
    # Kill existing mpvpaper instances
    killall mpvpaper 2>/dev/null
    
    # Launch new wallpaper
    # Note: we use "${WALL_DIR}/${selected}" to ensure the full path is quoted
    mpvpaper -o "no-audio --loop-playlist --hwdec=auto" "*" "${WALL_DIR}/${selected}" &
    
    notify-send "Contract Renewed" "Playing: $selected" -i "video-x-generic"
fi
