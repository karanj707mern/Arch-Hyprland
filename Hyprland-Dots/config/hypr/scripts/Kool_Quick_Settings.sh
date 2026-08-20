#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Rofi menu for KooL Hyprland Quick Settings (SUPER SHIFT E)
# Updated for UserConfigs/configs separation and Lua configs

# Modify this config file for default terminal and EDITOR
config_file="$HOME/.config/hypr/UserConfigs/01-UserDefaults.lua"

# Parse Lua config for shell variables
eval "$(grep -E '^local (term|files|Search_Engine) ' "$config_file" | sed -E 's/^local ([a-zA-Z_][a-zA-Z0-9_]*) = "([^"]*)".*/\1="\2"/')"
: "${edit:=${EDITOR:-nano}}"

# ##################################### #

# variables
configs="$HOME/.config/hypr/configs"
UserConfigs="$HOME/.config/hypr/UserConfigs"
rofi_theme="$HOME/.config/rofi/config-edit.rasi"
msg=' ⁉️ Choose what to do ⁉️'
iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"

# Function to show info notification
show_info() {
    if [[ -f "$iDIR/info.png" ]]; then
        notify-send -i "$iDIR/info.png" "Info" "$1"
    else
        notify-send "Info" "$1"
    fi
}

# Function to kill all rainbow border processes
kill_rainbow_borders() {
    pkill -f "RainbowBorders.sh" 2>/dev/null || true
    pkill -f "RainbowBordersSnake.sh" 2>/dev/null || true
    pkill -f "RainbowBordersSmooth.sh" 2>/dev/null || true
}

# Function to reset active border to default static color
reset_active_border() {
    if command -v hyprctl &>/dev/null; then
        # Read default border color from decorations config
        local default_border=""
        if [[ -f "$UserConfigs/UserDecorations.lua" ]]; then
            default_border=$(grep -oE 'active_border\s*=\s*"[^"]+"' "$UserConfigs/UserDecorations.lua" 2>/dev/null | head -1 | sed 's/.*=\s*"\([^"]*\)".*/\1/')
        fi
        if [[ -z "$default_border" && -f "$configs/UserDecorations.conf" ]]; then
            default_border=$(grep -oE '\$color[0-9]+' "$configs/UserDecorations.conf" 2>/dev/null | head -1)
        fi
        # Fallback to a neutral gray
        [[ -z "$default_border" ]] && default_border="0xff888888"
        hyprctl keyword general:col.active_border "$default_border" 2>/dev/null || true
    fi
}

# Function to toggle Rainbow Borders script availability and refresh UI components
toggle_rainbow_borders() {
    local rainbow_script="$UserScripts/RainbowBorders.sh"
    local disabled_sh_bak="${rainbow_script}.bak"           # RainbowBorders.sh.bak
    local disabled_bak_sh="$UserScripts/RainbowBorders.bak.sh" # RainbowBorders.bak.sh (created by copy.sh when disabled)
    local refresh_script="$scriptsDir/Refresh.sh"
    local state_file="$HOME/.config/hypr/.rainbow_borders_enabled"
    local status=""

    # If both disabled variants exist, keep the newer one to avoid ambiguity
    if [[ -f "$disabled_sh_bak" && -f "$disabled_bak_sh" ]]; then
        if [[ "$disabled_sh_bak" -nt "$disabled_bak_sh" ]]; then
            rm -f "$disabled_bak_sh"
        else
            rm -f "$disabled_sh_bak"
        fi
    fi

    if [[ -f "$rainbow_script" ]]; then
        # Currently enabled -> disable to canonical .sh.bak
        if mv "$rainbow_script" "$disabled_sh_bak"; then
            status="disabled"
            rm -f "$state_file"
            kill_rainbow_borders
            reset_active_border
            if command -v hyprctl &>/dev/null; then
                hyprctl reload >/dev/null 2>&1 || true
            fi
        fi
    elif [[ -f "$disabled_sh_bak" ]]; then
        # Disabled (.sh.bak) -> enable
        if mv "$disabled_sh_bak" "$rainbow_script"; then
            status="enabled"
            touch "$state_file"
        fi
    elif [[ -f "$disabled_bak_sh" ]]; then
        # Disabled (.bak.sh) -> enable (normalize to .sh)
        if mv "$disabled_bak_sh" "$rainbow_script"; then
            status="enabled"
            touch "$state_file"
        fi
    else
        show_info "RainbowBorders script not found in $UserScripts (checked .sh, .sh.bak, .bak.sh)."
        return
    fi

    # Run refresh if available, otherwise apply borders directly
    if [[ -x "$refresh_script" ]]; then
        "$refresh_script" >/dev/null 2>&1 &
    elif [[ "$current" != "disabled" && -x "$rainbow_script" ]]; then
        "$rainbow_script" >/dev/null 2>&1 &
    fi

    if [[ -n "$status" ]]; then
        show_info "Rainbow Borders ${status}."
    fi
}

# Submenu to choose Rainbow Borders mode (disable, wallust, rainbow, snake)
rainbow_borders_menu() {
    local snake_script="$UserScripts/RainbowBordersSnake.sh"
    local old_script="$UserScripts/RainbowBorders.sh"
    local disabled_snake_sh="${snake_script}.bak"
    local disabled_old_sh="${old_script}.bak"
    local refresh_script="$scriptsDir/Refresh.sh"
    local state_file="$HOME/.config/hypr/.rainbow_borders_enabled"

    # Determine current mode from state file
    local current="disabled"
    if [[ -f "$state_file" ]]; then
        current=$(cat "$state_file" 2>/dev/null)
        [[ -z "$current" ]] && current="disabled"
    fi

    # Map internal mode to friendly display
    local current_display="$current"
    case "$current" in
        wallust) current_display="Wallust Gradient" ;;
        rainbow) current_display="Fixed Rainbow" ;;
        snake) current_display="Snake Walking" ;;
        disabled) current_display="Disabled" ;;
    esac

    # Build options and prompt
    local options="Disable Rainbow Borders\nWallust Gradient\nFixed Rainbow\nSnake Walking"
    local choice
    choice=$(printf "%b" "$options" | rofi -i -dmenu -config "$rofi_theme" -mesg "Rainbow Borders: current = $current_display")

    [[ -z "$choice" ]] && return

    # Kill any existing border scripts
    kill_rainbow_borders

    local mode=""
    case "$choice" in
        "Disable Rainbow Borders")
            current="disabled"
            rm -f "$state_file"
            reset_active_border
            if command -v hyprctl &>/dev/null; then
                hyprctl reload >/dev/null 2>&1 || true
            fi
            ;;
        "Wallust Gradient")
            mode="wallust"
            current="wallust"
            echo "$mode" > "$state_file"
            ;;
        "Fixed Rainbow")
            mode="rainbow"
            current="rainbow"
            echo "$mode" > "$state_file"
            ;;
        "Snake Walking")
            mode="snake"
            current="snake"
            echo "$mode" > "$state_file"
            ;;
        *)
            return ;;
    esac

    # Start the chosen mode
    if [[ "$current" != "disabled" ]]; then
        case "$choice" in
            "Wallust Gradient")
                if [[ -f "$UserScripts/RainbowBordersSmooth.sh" ]]; then
                    bash "$UserScripts/RainbowBordersSmooth.sh" >/dev/null 2>&1 &
                elif [[ -f "$old_script" ]]; then
                    sed -i 's/^EFFECT_TYPE=.*/EFFECT_TYPE="gradient_flow"/' "$old_script"
                    bash "$old_script" >/dev/null 2>&1 &
                fi
                ;;
            "Fixed Rainbow")
                if [[ -f "$snake_script" ]]; then
                    bash "$snake_script" "rainbow" >/dev/null 2>&1 &
                elif [[ -f "$old_script" ]]; then
                    sed -i 's/^EFFECT_TYPE=.*/EFFECT_TYPE="rainbow"/' "$old_script"
                    bash "$old_script" >/dev/null 2>&1 &
                fi
                ;;
            "Snake Walking")
                if [[ -f "$snake_script" ]]; then
                    bash "$snake_script" "snake" >/dev/null 2>&1 &
                elif [[ -f "$old_script" ]]; then
                    sed -i 's/^EFFECT_TYPE=.*/EFFECT_TYPE="snake"/' "$old_script"
                    bash "$old_script" >/dev/null 2>&1 &
                fi
                ;;
        esac
    fi

    # Run refresh if available
    if [[ -x "$refresh_script" ]]; then
        "$refresh_script" >/dev/null 2>&1 &
    fi

    show_info "Rainbow Borders: $choice"
}

# Function to display the menu options without numbers
menu() {
    cat <<EOF
--- USER CUSTOMIZATIONS ---
Edit User Defaults
Edit User Keybinds
Edit User ENV variables
Edit User Startup Apps (overlay)
Edit User Window Rules (overlay)
Edit User Settings
Edit User Decorations
Edit User Animations
Edit User Laptop Settings
--- SYSTEM DEFAULTS  ---
Edit System Default Keybinds
Edit System Default Startup Apps
Edit System Default Window Rules
Edit System Default Settings
--- UTILITIES ---
Set SDDM Wallpaper
Choose Kitty Terminal Theme
Configure Monitors (nwg-displays)
Configure Workspace Rules (nwg-displays)
GTK Settings (nwg-look)
QT Apps Settings (qt6ct)
QT Apps Settings (qt5ct)
Choose Hyprland Animations
Choose Monitor Profiles
Choose Rofi Themes
Search for Keybinds
Toggle Game Mode
Switch Dark-Light Theme
Rainbow Borders Mode
EOF
}

# Main function to handle menu selection
main() {
    choice=$(menu | rofi -i -dmenu -config $rofi_theme -mesg "$msg")
    
     # Map choices to corresponding files
     case "$choice" in
      	"Edit User Defaults") file="$UserConfigs/01-UserDefaults.lua" ;;
         "Edit User ENV variables") file="$UserConfigs/ENVariables.lua" ;;
         "Edit User Keybinds") file="$UserConfigs/UserKeybinds.lua" ;;
         "Edit User Startup Apps (overlay)") file="$UserConfigs/Startup_Apps.lua" ;;
         "Edit User Window Rules (overlay)") file="$UserConfigs/WindowRules.lua" ;;
         "Edit User Settings") file="$configs/SystemSettings.lua"; show_info "Editing default settings. Copy to UserConfigs/UserSettings.lua to override." ;;
         "Edit User Decorations") file="$UserConfigs/UserDecorations.lua" ;;
         "Edit User Animations") file="$UserConfigs/UserAnimations.lua" ;;
         "Edit User Laptop Settings") file="$UserConfigs/Laptops.lua" ;;
         "Edit System Default Keybinds") file="$configs/Keybinds.lua" ;;
         "Edit System Default Startup Apps") file="$configs/Startup_Apps.lua" ;;
         "Edit System Default Window Rules") file="$configs/WindowRules.lua" ;;
         "Edit System Default Settings") file="$configs/SystemSettings.lua" ;;
        "Set SDDM Wallpaper") $scriptsDir/sddm_wallpaper.sh --normal ;;
        "Choose Kitty Terminal Theme") $scriptsDir/Kitty_themes.sh ;;
        "Configure Monitors (nwg-displays)") 
            if ! command -v nwg-displays &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install nwg-displays first"
                exit 1
            fi
            nwg-displays ;;
        "Configure Workspace Rules (nwg-displays)") 
            if ! command -v nwg-displays &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install nwg-displays first"
                exit 1
            fi
            nwg-displays ;;
		"GTK Settings (nwg-look)") 
            if ! command -v nwg-look &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install nwg-look first"
                exit 1
            fi
            nwg-look ;;
		"QT Apps Settings (qt6ct)") 
            if ! command -v qt6ct &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install qt6ct first"
                exit 1
            fi
            qt6ct ;;
		"QT Apps Settings (qt5ct)") 
            if ! command -v qt5ct &>/dev/null; then
                notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install qt5ct first"
                exit 1
            fi
            qt5ct ;;
        "Choose Hyprland Animations") $scriptsDir/Animations.sh ;;
        "Choose Monitor Profiles") $scriptsDir/MonitorProfiles.sh ;;
        "Choose Rofi Themes") $scriptsDir/RofiThemeSelector.sh ;;
        "Search for Keybinds") $scriptsDir/KeyBinds.sh ;;
        "Toggle Game Mode") $scriptsDir/GameMode.sh ;;
        "Switch Dark-Light Theme") $scriptsDir/DarkLight.sh ;;
        "Rainbow Borders Mode") rainbow_borders_menu ;;
        *) return ;;  # Do nothing for invalid choices
    esac

    # Open the selected file in the terminal with the text editor
    if [ -n "$file" ]; then
        $term -e $edit "$file"
    fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

main
