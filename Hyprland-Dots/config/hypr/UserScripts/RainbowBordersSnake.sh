#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorders - Border animation
# Modes: snake | neon | boomerang | galaxy | rainbow

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/rainbow-snake.lock"
exec 200>"$lock_file"
# Retry briefly instead of exiting silently: when relaunching right after
# killing an old instance, the dying one may still hold the lock for a moment
_flock_ok=0
for _ in {1..30}; do
    flock -n 200 && { _flock_ok=1; break; }
    sleep 0.1
done
(( _flock_ok )) || exit 0

# ---------- CONFIG ----------
EFFECT_TYPE="${1:-snake}"
# Per-mode frame delay (seconds). Neon is intentionally slower/calm.
case "$EFFECT_TYPE" in
    neon) ANIMATION_DELAY=0.32 ;;
    *)    ANIMATION_DELAY=0.22 ;;
esac
SNAKE_TRAIL=4   # longer smooth trail

SNAKE_HEAD=0
SNAKE_PHASE=0
BOOMERANG_POS=0

# ---------- BRIGHT RGB PALETTE ----------
# Used by neon & boomerang modes (was missing -> neon silently failed)
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

# ---------- SNAKE MODE ----------
# Bright purple head with a short fading tail. Rest is deep black-purple.
# Visible "snake walking" effect: small bright spot moving, not a full gradient.
function get_snake_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local dist=$(( (SNAKE_HEAD - i + 10) % 10 ))
        if (( dist >= SNAKE_TRAIL )); then
            colors[$i]="0xff472064"   # visible deep-purple fill (~18% luma)
        else
            local fade=$(( SNAKE_TRAIL - dist ))
            # Head (dist=0) = 100% bright, tail tip = 45% (violet needs the
            # extra headroom - blue hues have very low perceived luminance)
            local intensity=$(( 45 + fade * 55 / SNAKE_TRAIL ))
            # Hue: head=310 (magenta), tail=270 (violet)
            local hue=$(( 310 - dist * 10 ))
            (( hue < 270 )) && hue=270
            local saturation=$(( 85 + fade * 15 / SNAKE_TRAIL ))
            colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
        fi
    done
    echo "${colors[@]}"
}

# ---------- NEON MODE (edge lighting) ----------
# All 10 segments use bright RGB colors from the palette,
# rotating together. Brightness pulses 50%-100% (never dim).
function get_neon_colors() {
    local colors=()
    local phase=$(( SNAKE_PHASE % 10 ))
    # Pulse 70%..100% - never dim, even on palette blues
    local brightness=$(( phase <= 3 ? 7 + phase : 10 ))
    for (( i = 0; i < 10; i++ )); do
        local idx=$(( (SNAKE_PHASE + i) % 10 ))
        local hex="${PALETTE[$idx]#0xff}"
        local r=$((16#${hex:0:2}))
        local g=$((16#${hex:2:2}))
        local b=$((16#${hex:4:2}))
        r=$(( r * brightness / 10 ))
        g=$(( g * brightness / 10 ))
        b=$(( b * brightness / 10 ))
        (( r > 255 )) && r=255
        (( g > 255 )) && g=255
        (( b > 255 )) && b=255
        colors[$i]=$(printf "0xff%02x%02x%02x" "$r" "$g" "$b")
    done
    echo "${colors[@]}"
}

# ---------- BOOMERANG MODE ----------
# 5 bright particles evenly spaced, circulating clockwise.
# Rest of border is dark. Much more visible than 3 particles.
function get_boomerang_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local dist=$(( (i - BOOMERANG_POS + 10) % 10 ))
        if (( dist == 0 )); then
            colors[$i]="${PALETTE[0]}"   # cyan
        elif (( dist == 2 )); then
            colors[$i]="${PALETTE[2]}"   # yellow
        elif (( dist == 4 )); then
            colors[$i]="${PALETTE[4]}"   # green
        elif (( dist == 6 )); then
            colors[$i]="${PALETTE[6]}"   # orange
        elif (( dist == 8 )); then
            colors[$i]="${PALETTE[8]}"   # lime
        else
            colors[$i]="0xff7a2038"  # visible dark-ember fill (~21% luma)
        fi
    done
    echo "${colors[@]}"
}

# ---------- HSV TO RGB (proper floating point via awk) ----------
function hsv_to_color() {
    local h=$1 s=$2 v=$3
    local r g b
    read r g b <<< $(awk -v h="$h" -v s="$s" -v v="$v" 'function abs(x) {return (x < 0 ? -x : x)} BEGIN {
        s = s / 100; v = v / 100;
        c = v * s; x = c * (1 - abs((h / 60) % 2 - 1)); m = v - c;
        if (h < 60) { r=c; g=x; b=0 } else if (h < 120) { r=x; g=c; b=0 }
        else if (h < 180) { r=0; g=c; b=x } else if (h < 240) { r=0; g=x; b=c }
        else if (h < 300) { r=x; g=0; b=c } else { r=c; g=0; b=x }
        R = int((r+m)*255); G = int((g+m)*255); B = int((b+m)*255);
        if (R < 0) R = 0; if (R > 255) R = 255;
        if (G < 0) G = 0; if (G > 255) G = 255;
        if (B < 0) B = 0; if (B > 255) B = 255;
        printf "%d %d %d", R, G, B
    }')
    printf "0xff%02x%02x%02x" "$r" "$g" "$b"
}

function get_rainbow_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local hue=$(( (SNAKE_PHASE * 3 + i * 36) % 360 ))
        colors[$i]=$(hsv_to_color "$hue" 100 100)
    done
    echo "${colors[@]}"
}

# ---------- GALAXY MODE ----------
# All 10 segments use bright gradient colors from the full 0-359
# spectrum, rotating together as one smooth wave.
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
        snake)     colors=($(get_snake_colors)) ;;
        neon)      colors=($(get_neon_colors)) ;;
        boomerang) colors=($(get_boomerang_colors)) ;;
        rainbow)   colors=($(get_rainbow_colors)) ;;
        galaxy)    colors=($(get_galaxy_colors)) ;;
        *)         colors=($(get_snake_colors)) ;;
    esac

    hyprctl eval "hl.config({general = {col = {active_border = {colors = {${colors[0]}, ${colors[1]}, ${colors[2]}, ${colors[3]}, ${colors[4]}, ${colors[5]}, ${colors[6]}, ${colors[7]}, ${colors[8]}, ${colors[9]}}, angle = 270}}}})"

    SNAKE_HEAD=$(( (SNAKE_HEAD + 1) % 10 ))
    SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 10 ))
    BOOMERANG_POS=$(( (BOOMERANG_POS + 1) % 10 ))

    sleep "$ANIMATION_DELAY"
done