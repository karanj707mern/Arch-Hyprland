#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorders - Border animation
# Modes: snake | neon | boomerang | galaxy

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/rainbow-snake.lock"
exec 200>"$lock_file"
flock -n 200 || exit 0

# ---------- CONFIG ----------
STATE_FILE="$HOME/.config/hypr/.rainbow_borders_enabled"
if [[ -n "${1:-}" ]]; then
    EFFECT_TYPE="$1"
elif [[ -f "$STATE_FILE" ]]; then
    saved_mode=$(cat "$STATE_FILE" 2>/dev/null)
    case "$saved_mode" in
        snake|neon|boomerang|galaxy)
            EFFECT_TYPE="$saved_mode"
            ;;
        *)
            EFFECT_TYPE="snake"
            ;;
    esac
else
    EFFECT_TYPE="snake"
fi
ANIMATION_DELAY=0.3

# ---------- HSV TO COLOR ----------
function hsv_to_color() {
    local h=$1 s=$2 v=$3
    local region=$(( h / 60 ))
    local remainder=$(( h % 60 ))
    local c=$(( v * s / 10000 ))
    local x=$(( c * (60 - remainder) / 60 ))
    local m=$(( v - c ))
    local r=0 g=0 b=0
    case $(( region % 6 )) in
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

# ---------- BRIGHT RGB PALETTE ----------
PALETTE=(
    "0xff00f0ff"  # cyan
    "0xfff000ff"  # magenta
    "0xffffff00"  # yellow
    "0xffff0000"  # red
    "0xff00ff00"  # green
    "0xff0000ff"  # blue
    "0xffff7f00"  # orange
    "0xffff007f"  # pink
    "0xff7fff00"  # lime
    "0xff8b00ff"  # violet
)

SNAKE_HEAD=0
SNAKE_PHASE=0
BOOMERANG_POS=0

# ---------- SNAKE MODE ----------
function get_snake_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        if (( i == SNAKE_HEAD )); then
            colors[$i]="${PALETTE[$((SNAKE_HEAD % 10))]}"
        else
            colors[$i]="0xff201030"
        fi
    done
    echo "${colors[@]}"
}

# ---------- NEON MODE ----------
function get_neon_colors() {
    local colors=()
    local phase=$(( (SNAKE_PHASE % 20 + 20) % 20 ))
    local brightness
    if (( phase < 10 )); then
        brightness=$(( phase + 1 ))
    else
        brightness=$(( 20 - phase ))
    fi
    for (( i = 0; i < 10; i++ )); do
        local idx=$(( (SNAKE_PHASE / 2 + i) % 10 ))
        local hex="${PALETTE[$idx]#0xff}"
        local r=$((16#${hex:0:2}))
        local g=$((16#${hex:2:2}))
        local b=$((16#${hex:4:2}))
        r=$(( r * brightness / 10 ))
        g=$(( g * brightness / 10 ))
        b=$(( b * brightness / 10 ))
        colors[$i]=$(printf "0xff%02x%02x%02x" "$r" "$g" "$b")
    done
    echo "${colors[@]}"
}

# ---------- BOOMERANG MODE ----------
function get_boomerang_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local dist=$(( (i - BOOMERANG_POS + 10) % 10 ))
        if (( dist == 0 )); then
            colors[$i]="${PALETTE[0]}"   # cyan
        elif (( dist == 3 )); then
            colors[$i]="${PALETTE[3]}"   # red
        elif (( dist == 6 )); then
            colors[$i]="${PALETTE[6]}"   # orange
        else
            colors[$i]="0xff110000"
        fi
    done
    echo "${colors[@]}"
}

# ---------- GALAXY MODE ----------
function get_galaxy_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local hue=$(( (SNAKE_PHASE * 18 + i * 36) % 360 ))
        colors[$i]=$(hsv_to_color "$hue" 100 100)
    done
    echo "${colors[@]}"
}

# ---------- MAIN LOOP ----------
while true; do
    case "$EFFECT_TYPE" in
        snake)     colors=($(get_snake_colors)); SNAKE_HEAD=$(( (SNAKE_HEAD + 1) % 10 )) ;;
        neon)      colors=($(get_neon_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
        boomerang) colors=($(get_boomerang_colors)); BOOMERANG_POS=$(( (BOOMERANG_POS + 1) % 10 )) ;;
        galaxy)    colors=($(get_galaxy_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
        *)         colors=($(get_snake_colors)); SNAKE_HEAD=$(( (SNAKE_HEAD + 1) % 10 )) ;;
    esac

    hyprctl eval "hl.config({general = {col = {active_border = {colors = {${colors[0]}, ${colors[1]}, ${colors[2]}, ${colors[3]}, ${colors[4]}, ${colors[5]}, ${colors[6]}, ${colors[7]}, ${colors[8]}, ${colors[9]}}, angle = 270}}}})"

    sleep "$ANIMATION_DELAY"
done
