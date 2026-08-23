#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorderStart - Single source of truth for starting border effects.
# Reads the mode from ~/.config/hypr/.rainbow_borders_enabled and launches
# the matching script. Used by Refresh.sh, RefreshNoWaybar.sh and boot.
#
# Usage: RainbowBorderStart.sh [state_file]
#        (defaults to ~/.config/hypr/.rainbow_borders_enabled)

state_file="${1:-$HOME/.config/hypr/.rainbow_borders_enabled}"
UserScripts="$HOME/.config/hypr/UserScripts"

# ---------- SERIALIZE CONCURRENT INVOCATIONS ----------
# Two overlapping Refresh runs would otherwise both kill+relaunch and race.
exec 220>"$XDG_RUNTIME_DIR/rainbow-border-start.lock"
flock -w 5 220 || exit 0

# Launch an effect script, releasing our lock first (fd would otherwise be
# inherited by the long-running effect process and block future launches)
launch() {
    exec 220>&-
    exec bash "$@"
}

# No state file / disabled / empty -> nothing to do
[[ -f "$state_file" ]] || exit 0
mode=$(tr -d '[:space:]' < "$state_file")
[[ -z "$mode" || "$mode" == "disabled" ]] && exit 0

# Kill any running border effects first (prevents duplicates and
# two different modes fighting over hyprctl eval)
pkill -f "RainbowBorders.sh" 2>/dev/null
pkill -f "RainbowBordersSnake.sh" 2>/dev/null
pkill -f "RainbowBordersSmooth.sh" 2>/dev/null
pkill -f "WaveBorders.sh" 2>/dev/null

# Wait until they are fully dead, otherwise flock in the new instance
# can lose the race against the dying one and exit silently
for _ in {1..20}; do
    pgrep -f "RainbowBorders|WaveBorders" >/dev/null 2>&1 || break
    sleep 0.05
done

case "$mode" in
    wave|wave_dual|wave_pulse|tide)
        if [[ -x "$UserScripts/WaveBorders.sh" ]]; then
            launch "$UserScripts/WaveBorders.sh" "$mode"
        fi
        ;;
    wallust)
        # Wallust Gradient: smooth interpolated cycling preferred
        if [[ -f "$UserScripts/RainbowBordersSmooth.sh" ]]; then
            launch "$UserScripts/RainbowBordersSmooth.sh"
        elif [[ -f "$UserScripts/RainbowBorders.sh" ]]; then
            launch "$UserScripts/RainbowBorders.sh" gradient_flow
        fi
        ;;
    aurora|plasma|breathing|neon_flicker|purple_wave|orbit)
        # Only the classic script implements these modes
        if [[ -f "$UserScripts/RainbowBorders.sh" ]]; then
            launch "$UserScripts/RainbowBorders.sh" "$mode"
        fi
        ;;
    snake|neon|boomerang|galaxy|rainbow)
        # Snake-family modes (menu parity)
        if [[ -f "$UserScripts/RainbowBordersSnake.sh" ]]; then
            launch "$UserScripts/RainbowBordersSnake.sh" "$mode"
        elif [[ -f "$UserScripts/RainbowBorders.sh" ]]; then
            launch "$UserScripts/RainbowBorders.sh" "$mode"
        fi
        ;;
    *)
        # Unknown saved mode -> fall back to snake on whichever exists
        if [[ -f "$UserScripts/RainbowBordersSnake.sh" ]]; then
            launch "$UserScripts/RainbowBordersSnake.sh" snake
        elif [[ -f "$UserScripts/RainbowBorders.sh" ]]; then
            launch "$UserScripts/RainbowBorders.sh"
        fi
        ;;
esac

exit 0
