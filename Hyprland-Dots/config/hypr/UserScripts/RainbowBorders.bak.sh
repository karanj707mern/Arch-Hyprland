#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorders - Snake animation with wallust or rainbow colors
# Modes: snake | rainbow | wallust_random | gradient_flow

# ---------- CONFIG ----------
EFFECT_TYPE="snake"
ANIMATION_DELAY=0.23

# ---------- WALLUST COLORS ----------
WALLUST_COLORS_SOURCE="$HOME/.config/hypr/wallust/wallust-hyprland.conf"
WALLUST_COLORS=()

load_wallust_colors() {
    WALLUST_COLORS=()
    if [[ -f "$WALLUST_COLORS_SOURCE" ]]; then
        while IFS= read -r line; do
            val="${line#*=}"
            val="${val// /}"

            if echo "$val" | grep -qE '^rgb\([0-9a-fA-F]{6}\)$'; then
                hex=$(echo "$val" | grep -oE '[0-9a-fA-F]{6}')
                WALLUST_COLORS+=("0xff${hex}")
            elif echo "$val" | grep -qE '^0x[0-9a-fA-F]{6,8}$'; then
                hex=$(echo "$val" | grep -oE '[0-9a-fA-F]{6,8}')
                if [[ ${#hex} -eq 6 ]]; then
                    WALLUST_COLORS+=("0xff${hex}")
                else
                    WALLUST_COLORS+=("0xff${hex:0:6}")
                fi
            elif echo "$val" | grep -qE '^\#[0-9a-fA-F]{6}$'; then
                hex=$(echo "$val" | grep -oE '[0-9a-fA-F]{6}')
                WALLUST_COLORS+=("0xff${hex}")
            elif echo "$val" | grep -qE '^rgb\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+\)$'; then
                r=$(echo "$val" | grep -oE 'rgb\(([0-9]+),' | grep -oE '[0-9]+')
                g=$(echo "$val" | grep -oE ',([0-9]+),' | grep -oE '[0-9]+')
                b=$(echo "$val" | grep -oE ',([0-9]+)\)' | grep -oE '[0-9]+')
                r=$(printf "%02x" "$r")
                g=$(printf "%02x" "$g")
                b=$(printf "%02x" "$b")
                WALLUST_COLORS+=("0xff${r}${g}${b}")
            fi
        done < <(grep -E '^\$color[0-9]+' "$WALLUST_COLORS_SOURCE")
    fi
}

# ---------- RAINBOW COLORS ----------
RAINBOW_COLORS=(
    "0xffff0000" "0xffff7f00" "0xffffff00" "0xff00ff00"
    "0xff00ffff" "0xff0000ff" "0xff8b00ff" "0xffff007f"
    "0xffff5500" "0xffffaa00"
)

function rainbow_color() {
    local i=$(( $1 % 10 ))
    echo "${RAINBOW_COLORS[$i]}"
}

# ---------- WALLUST RANDOM ----------
function wallust_random() {
    if [[ ${#WALLUST_COLORS[@]} -gt 0 ]]; then
        echo "${WALLUST_COLORS[RANDOM % ${#WALLUST_COLORS[@]}]}"
    else
        echo "0xff$(openssl rand -hex 3)"
    fi
}

# ---------- GRADIENT FLOW ----------
BASE_COLOR=""
GRAD1_COLOR=""
GRAD2_COLOR=""
GLOW_COLOR=""
MAX_POS=10
GLOW_POS=0

function gradient_flow_color() {
    local pos=$1
    local d=$(( pos - GLOW_POS ))
    if (( d >  MAX_POS/2 )); then d=$((d - MAX_POS)); fi
    if (( d < -MAX_POS/2 )); then d=$((d + MAX_POS)); fi
    case "${d#-}" in
        0) echo "$GLOW_COLOR" ;;
        1) echo "$GRAD1_COLOR" ;;
        2) echo "$GRAD2_COLOR" ;;
        *) echo "$BASE_COLOR" ;;
    esac
}

# ---------- SNAKE ANIMATION ----------
SNAKE_POS=0

function snake_color() {
    local pos=$1
    local idx=$(( (SNAKE_POS + pos) % 10 ))
    echo "${RAINBOW_COLORS[$idx]}"
}

# ---------- INIT ----------
load_wallust_colors

if [[ "$EFFECT_TYPE" == "gradient_flow" && ${#WALLUST_COLORS[@]} -ge 16 ]]; then
    BASE_COLOR="${WALLUST_COLORS[10]}"
    GRAD1_COLOR="${WALLUST_COLORS[14]}"
    GRAD2_COLOR="${WALLUST_COLORS[13]}"
    GLOW_COLOR="${WALLUST_COLORS[15]}"
fi

function get_color() {
    case "$EFFECT_TYPE" in
        snake)        snake_color "$1" ;;
        rainbow)      rainbow_color "$1" ;;
        wallust_random) wallust_random ;;
        gradient_flow)
            if [[ ${#WALLUST_COLORS[@]} -ge 16 ]]; then
                gradient_flow_color "$1"
            else
                rainbow_color "$1"
            fi
            ;;
        *)            rainbow_color "$1" ;;
    esac
}

# ---------- MAIN LOOP ----------
while true; do
    hyprctl eval "hl.config({general = {col = {active_border = {colors = {$(get_color 0), $(get_color 1), $(get_color 2), $(get_color 3), $(get_color 4), $(get_color 5), $(get_color 6), $(get_color 7), $(get_color 8), $(get_color 9)}, angle = 270}}}})"

    if [[ "$EFFECT_TYPE" == "snake" ]]; then
        SNAKE_POS=$(( (SNAKE_POS + 1) % 10 ))
    fi

    sleep "$ANIMATION_DELAY"
done
