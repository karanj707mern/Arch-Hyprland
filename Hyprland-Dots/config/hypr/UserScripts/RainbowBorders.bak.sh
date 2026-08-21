#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorders - Border animation with wallust or rainbow colors
# Modes: snake | rainbow | wallust_random | gradient_flow

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/rainbow-borders.lock"
exec 200>"$lock_file"
flock -n 200 || exit 0

# ---------- CONFIG ----------
EFFECT_TYPE="snake"
ANIMATION_DELAY=0.3

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

# ---------- RAINBOW PALETTE ----------
RAINBOW_COLORS=(
    "0xffff0000" "0xffff7f00" "0xffffff00" "0xff00ff00"
    "0xff00ffff" "0xff0000ff" "0xff8b00ff" "0xffff007f"
    "0xffff5500" "0xffffaa00"
)

# ---------- SNAKE MODE ----------
# One bright neon head segment moving clockwise.
# All other segments are dark purple. Head color is fixed neon.
SNAKE_HEAD=0
NEON_HEAD_COLOR="0xff00f0ff"  # neon cyan

function get_snake_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        if (( i == SNAKE_HEAD )); then
            colors[$i]="$NEON_HEAD_COLOR"
        else
            colors[$i]="0xff201030"
        fi
    done
    echo "${colors[@]}"
}

# ---------- NEON MODE (edge lighting) ----------
# Uniform neon glow that pulses in brightness. All 10 segments share
# the same neon color; brightness cycles up/down.
SNAKE_PHASE=0

function get_neon_colors() {
    local colors=()
    local phase=$(( SNAKE_PHASE % 20 ))
    local brightness
    if (( phase <= 10 )); then
        brightness=$phase
    else
        brightness=$(( 20 - phase ))
    fi
    local r=$(( 0x00 + (0xf0 - 0x00) * brightness / 10 ))
    local g=$(( 0x00 + (0xf0 - 0x00) * brightness / 10 ))
    local b=$(( 0xff + (0xff - 0xff) * brightness / 10 ))
    local dim_color=$(printf "0xff%02x%02x%02x" "$r" "$g" "$b")
    for (( i = 0; i < 10; i++ )); do
        colors[$i]="$dim_color"
    done
    echo "${colors[@]}"
}

# ---------- RAINBOW MODE ----------
# A true rainbow: each segment gets a different hue from the full
# 0-359 spectrum, evenly spaced. The whole border shifts as one
# smooth rainbow wave — no blinking, no color cycling.
function hsv_to_color() {
    local h=$1 s=$2 v=$3
    local c=$(( v * s / 10000 ))
    local x=$(( v * s / 10000 * (60 - ((h / 60) % 2) * (60 - ((h / 60) % 2) * 60) ) ))
    local m=$(( v - c ))
    local r=0 g=0 b=0
    case $(( (h / 60) % 6 )) in
        0) r=$c; g=$x; b=0 ;;
        1) r=$x; g=$c; b=0 ;;
        2) r=0; g=$c; b=$x ;;
        3) r=0; g=$x; b=$c ;;
        4) r=$x; g=0; b=$c ;;
        5) r=$c; g=0; b=$x ;;
    esac
    r=$(( r + m )); g=$(( g + m )); b=$(( b + m ))
    printf "0xff%02x%02x%02x" "$r" "$g" "$b"
}

function get_rainbow_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local hue=$(( (SNAKE_HEAD + i * 36) % 360 ))
        colors[$i]=$(hsv_to_color "$hue" 100 100)
    done
    echo "${colors[@]}"
}

# ---------- WALLUST RANDOM MODE ----------
# Uses wallust colors as a gradient palette, rotating through them.
# Each frame picks a new set of wallust colors and applies them
# as a gradient along the border — not christmas lights.
function get_wallust_random_colors() {
    local colors=()
    local count=${#WALLUST_COLORS[@]}
    if (( count > 0 )); then
        for (( i = 0; i < 10; i++ )); do
            local idx=$(( (SNAKE_HEAD + i) % count ))
            colors[$i]="${WALLUST_COLORS[$idx]}"
        done
    else
        for (( i = 0; i < 10; i++ )); do
            colors[$i]="0xff$(openssl rand -hex 3)"
        done
    fi
    echo "${colors[@]}"
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

function get_gradient_flow_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        colors[$i]=$(gradient_flow_color $i)
    done
    echo "${colors[@]}"
}

# ---------- INIT ----------
load_wallust_colors

if [[ "$EFFECT_TYPE" == "gradient_flow" && ${#WALLUST_COLORS[@]} -ge 16 ]]; then
    BASE_COLOR="${WALLUST_COLORS[10]}"
    GRAD1_COLOR="${WALLUST_COLORS[14]}"
    GRAD2_COLOR="${WALLUST_COLORS[13]}"
    GLOW_COLOR="${WALLUST_COLORS[15]}"
fi

# ---------- MAIN LOOP ----------
while true; do
    case "$EFFECT_TYPE" in
        snake)          colors=($(get_snake_colors)) ;;
        rainbow)        colors=($(get_rainbow_colors)) ;;
        wallust_random) colors=($(get_wallust_random_colors)) ;;
        gradient_flow)  colors=($(get_gradient_flow_colors)) ;;
        *)              colors=($(get_rainbow_colors)) ;;
    esac

    hyprctl eval "hl.config({general = {col = {active_border = {colors = {${colors[0]}, ${colors[1]}, ${colors[2]}, ${colors[3]}, ${colors[4]}, ${colors[5]}, ${colors[6]}, ${colors[7]}, ${colors[8]}, ${colors[9]}}, angle = 270}}}})"

    SNAKE_HEAD=$(( (SNAKE_HEAD + 1) % 10 ))

    sleep "$ANIMATION_DELAY"
done