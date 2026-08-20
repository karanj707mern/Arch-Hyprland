#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# For applying Animations from different users (Lua presets)

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
animations_dir="$HOME/.config/hypr/animations"
UserConfigs="$HOME/.config/hypr/UserConfigs"
rofi_theme="$HOME/.config/rofi/config-Animations.rasi"
msg='❗NOTE:❗ This will apply selected animation preset'
# list of animation .lua files, sorted alphabetically with numbers first
animations_list=$(find -L "$animations_dir" -maxdepth 1 -type f -name '*.lua' | sed 's/.*\///' | sed 's/\.lua$//' | sort -V)

# Rofi Menu
chosen_file=$(echo "$animations_list" | rofi -i -dmenu -config $rofi_theme -mesg "$msg")

# Check if a file was selected
if [[ -n "$chosen_file" ]]; then
    full_path="$animations_dir/$chosen_file.lua"
    cp "$full_path" "$UserConfigs/UserAnimations.lua"
    notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Hyprland Animation Loaded"
    # Reload Hyprland to apply the new animation preset
    if command -v hyprctl &>/dev/null; then
        hyprctl reload &>/dev/null || true
    fi
fi

sleep 1
"$SCRIPTSDIR/RefreshNoWaybar.sh"
