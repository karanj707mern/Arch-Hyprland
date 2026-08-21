#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorders - Border animation with wallust or rainbow colors
# Modes: snake | rainbow | wallust_random | gradient_flow | neon | boomerang | galaxy

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/rainbow-borders.lock"
exec 200>"$lock_file"
flock -n 200 || exit 0

# ---------- CONFIG ----------
EFFECT_TYPE="snake"
ANIMATION_DELAY=0.3

# ---------- RESTORE SAVED MODE ----------
STATE_FILE="$HOME/.config/hypr/.rainbow_borders_enabled"
if [[ -f "$STATE_FILE" ]]; then
    saved_mode=$(cat "$STATE_FILE" 2>/dev/null)
    case "$saved_mode" in
        snake|rainbow|wallust_random|gradient_flow|neon|boomerang|galaxy)
            EFFECT_TYPE="$saved_mode"
            ;;
    esac
fi

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
GLOW_POS=0

# ---------- BOOMERANG MODE ----------
function get_boomerang_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local dist=$(( (i - BOOMERANG_POS + 10) % 10 ))
        if (( dist == 0 )); then
            colors[$i]="${PALETTE[0]}"               # cyan
        elif (( dist == 3 )); then
            colors[$i]="${PALETTE[3]}"               # red
        elif (( dist == 6 )); then
            colors[$i]="${PALETTE[6]}"               # orange
        else
            colors[$i]="0xff110000"
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

# ---------- GALAXY MODE ----------
function get_galaxy_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local hue=$(( (SNAKE_PHASE * 18 + i * 36) % 360 ))
        colors[$i]=$(hsv_to_color "$hue" 100 100)
    done
    echo "${colors[@]}"
}

# ---------- RAINBOW MODE ----------
function get_rainbow_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local hue=$(( (SNAKE_PHASE + i * 36) % 360 ))
        colors[$i]=$(hsv_to_color "$hue" 100 100)
    done
    echo "${colors[@]}"
}

# ---------- WALLUST RANDOM MODE ----------
function get_wallust_random_colors() {
    local colors=()
    local count=${#WALLUST_COLORS[@]}
    if (( count > 0 )); then
        for (( i = 0; i < 10; i++ )); do
            local idx=$(( (SNAKE_PHASE + i) % count ))
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
        galaxy)         colors=($(get_galaxy_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
        snake)          colors=($(get_snake_colors)); SNAKE_HEAD=$(( (SNAKE_HEAD + 1) % 10 )) ;;
        neon)           colors=($(get_neon_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
        boomerang)      colors=($(get_boomerang_colors)); BOOMERANG_POS=$(( (BOOMERANG_POS + 1) % 10 )) ;;
        rainbow)        colors=($(get_rainbow_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
        wallust_random) colors=($(get_wallust_random_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
        gradient_flow)  colors=($(get_gradient_flow_colors)); GLOW_POS=$(( (GLOW_POS + 1) % 10 )) ;;
        *)              colors=($(get_rainbow_colors)); SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 )) ;;
    esac

    hyprctl eval "hl.config({general = {col = {active_border = {colors = {${colors[0]}, ${colors[1]}, ${colors[2]}, ${colors[3]}, ${colors[4]}, ${colors[5]}, ${colors[6]}, ${colors[7]}, ${colors[8]}, ${colors[9]}}, angle = 270}}}})"

    sleep "$ANIMATION_DELAY"
done
