#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# RainbowBorders - Border animation with wallust or rainbow colors
# Modes: snake | neon | boomerang | galaxy | rainbow | wallust_random | gradient_flow | aurora | plasma | breathing | neon_flicker | purple_wave | orbit

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/rainbow-borders.lock"
exec 200>"$lock_file"
# Retry briefly instead of exiting silently (see RainbowBordersSnake.sh)
_flock_ok=0
for _ in {1..30}; do
    flock -n 200 && { _flock_ok=1; break; }
    sleep 0.1
done
(( _flock_ok )) || exit 0

# ---------- CONFIG ----------
EFFECT_TYPE="${1:-snake}"

# ---------- PER-MODE SPEEDS (ms) ----------
case "$EFFECT_TYPE" in
    snake)          ANIMATION_DELAY=0.22 ;;
    neon)           ANIMATION_DELAY=0.12 ;;
    boomerang)      ANIMATION_DELAY=0.15 ;;
    galaxy)         ANIMATION_DELAY=0.18 ;;
    rainbow)        ANIMATION_DELAY=0.15 ;;
    wallust_random) ANIMATION_DELAY=0.20 ;;
    gradient_flow)  ANIMATION_DELAY=0.23 ;;
    aurora)         ANIMATION_DELAY=0.20 ;;
    plasma)         ANIMATION_DELAY=0.16 ;;
    breathing)      ANIMATION_DELAY=0.30 ;;
    neon_flicker)   ANIMATION_DELAY=0.08 ;;
    purple_wave)    ANIMATION_DELAY=0.15 ;;
    orbit)          ANIMATION_DELAY=0.12 ;;
    *)              ANIMATION_DELAY=0.22 ;;
esac

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

# ---------- STATE ----------
SNAKE_PHASE=0
SNAKE_HEAD=0
BOOMERANG_POS=0
AURORA_PHASE=0
PLASMA_PHASE=0
BREATH_PHASE=0
FLICKER_PHASE=0

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

# ---------- BOOMERANG MODE ----------
function get_boomerang_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local dist=$(( (i - BOOMERANG_POS + 10) % 10 ))
        if (( dist == 0 )); then
            colors[$i]="${PALETTE[0]}"
        elif (( dist == 3 )); then
            colors[$i]="${PALETTE[3]}"
        elif (( dist == 6 )); then
            colors[$i]="${PALETTE[6]}"
        else
            colors[$i]="0xff7a2038"  # visible dark-ember fill (~21% luma)
        fi
    done
    echo "${colors[@]}"
}

# ---------- NEON MODE ----------
function get_neon_colors() {
    local colors=()
    local palette=(
        "0xff00f0ff" "0xfff000ff" "0xffffff00" "0xffff0000"
        "0xff00ff00" "0xff0000ff" "0xffff7f00" "0xffff007f"
        "0xff7fff00" "0xff8b00ff"
    )
    local phase=$(( SNAKE_PHASE % 20 ))
    local tri=$(( phase <= 10 ? phase : 20 - phase ))   # 0..10 triangle
    # Brightness pulse 70%..100% - never lets the border fade to black
    local brightness=$(( 7 + tri * 3 / 10 ))  # 7..10 = 70%..100% multiplier
    for (( i = 0; i < 10; i++ )); do
        local idx=$(( (SNAKE_PHASE / 2 + i) % 10 ))
        local hex="${palette[$idx]#0xff}"
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

# ---------- SNAKE MODE (unchanged) ----------
function get_snake_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        if (( i == SNAKE_HEAD )); then
            colors[$i]="${PALETTE[$((SNAKE_HEAD % 10))]}"
        else
            colors[$i]="0xff5a387c"  # visible dark-purple fill (~27% luma)
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

# ---------- AURORA MODE ----------
# Northern lights: green/teal/purple waves with smooth oscillation
function get_aurora_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local wave_idx=$(( (i * 36 + AURORA_PHASE) % 360 ))
        local sin_val=${wave_sin[$wave_idx]}
        # Smooth 45..100, never dips into invisibility
        local intensity=$(awk "BEGIN {printf \"%.0f\", 45 + 55 * (1 + $sin_val) / 2}")
        (( intensity > 100 )) && intensity=100
        (( intensity < 45 )) && intensity=45
        # Aurora hue range: 120-300 (green -> teal -> blue -> purple)
        local hue=$(( 120 + (AURORA_PHASE + i * 18) % 180 ))
        local saturation=$(( 70 + intensity * 30 / 100 ))
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- PLASMA MODE ----------
# Hot plasma: red/orange/yellow/white heat gradient
function get_plasma_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local wave_idx=$(( (i * 36 + PLASMA_PHASE) % 360 ))
        local sin_val=${wave_sin[$wave_idx]}
        # Smooth 35..100
        local intensity=$(awk "BEGIN {printf \"%.0f\", 35 + 65 * (1 + $sin_val) / 2}")
        (( intensity > 100 )) && intensity=100
        (( intensity < 35 )) && intensity=35
        # Plasma hue range: 0-60 (red -> orange -> yellow)
        local hue=$(( (PLASMA_PHASE * 2 + i * 6) % 60 ))
        local saturation=$(( 80 + intensity * 20 / 100 ))
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- BREATHING MODE ----------
# Slow single-color breathing pulse
function get_breathing_colors() {
    local colors=()
    local sin_val=${wave_sin[$((BREATH_PHASE % 360))]}
    # Smooth 35..100
    local intensity=$(awk "BEGIN {printf \"%.0f\", 35 + 65 * (1 + $sin_val) / 2}")
    (( intensity > 100 )) && intensity=100
    (( intensity < 35 )) && intensity=35
    # Purple breathing
    local hue=$(( 270 + intensity / 5 ))
    (( hue > 310 )) && hue=310
    for (( i = 0; i < 10; i++ )); do
        colors[$i]=$(hsv_to_color "$hue" 90 "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- NEON FLICKER MODE ----------
# Neon sign flicker: bright flash then decay (classic neon CYAN)
function get_neon_flicker_colors() {
    local colors=()
    local flicker=$(( FLICKER_PHASE % 40 ))
    local brightness
    if (( flicker < 2 )); then
        brightness=$(( 40 + flicker * 30 ))  # Quick ramp up
    elif (( flicker < 5 )); then
        brightness=100  # Full brightness
    elif (( flicker < 10 )); then
        brightness=$(( 100 - (flicker - 5) * 12 ))  # Decay (never below 52)
    elif (( flicker < 15 )); then
        brightness=$(( 40 + flicker * 2 ))  # Secondary flicker
    else
        brightness=$(( 38 + (flicker % 5) * 7 ))  # Dim glow (still clearly visible)
    fi
    (( brightness > 100 )) && brightness=100
    (( brightness < 35 )) && brightness=35
    # Neon cyan (matches palette 0xff00f0ff)
    for (( i = 0; i < 10; i++ )); do
        colors[$i]=$(hsv_to_color 185 100 "$brightness")
    done
    echo "${colors[@]}"
}

# ---------- PURPLE WAVE MODE ----------
# Smooth purple bright-to-dark wave
function get_purple_wave_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local wave_idx=$(( (i * 36 + PLASMA_PHASE) % 360 ))
        local sin_val=${wave_sin[$wave_idx]}
        # Smooth 55..100
        local intensity=$(awk "BEGIN {printf \"%.0f\", 55 + 45 * (1 + $sin_val) / 2}")
        (( intensity > 100 )) && intensity=100
        (( intensity < 55 )) && intensity=55
        local hue=$(( 285 + (intensity - 50) / 2 ))
        (( hue < 260 )) && hue=260
        (( hue > 310 )) && hue=310
        local saturation=$(( 80 + intensity / 5 ))
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- ORBIT MODE ----------
# 4 comet heads chasing around the border like a circle.
#
# How it works: Hyprland borders use a LINEAR gradient, and every bright
# band in it crosses the frame as a "rod" whose two ends are glowing dashes.
# We light TWO bands (stops 0-1 and 5-6 = perpendicular rods), which yields
# 4 comet heads spaced ~90 degrees apart, then steadily rotate the gradient
# ANGLE so all 4 heads orbit the window (clockwise: TL -> TR -> BR -> BL).
ORBIT_ANGLE=270

function get_orbit_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local v
        case "$i" in
            0|5) v=100 ;;  # head cores
            1|6) v=60 ;;   # comet tails
            *)   v=22 ;;   # visible dark base
        esac
        colors[$i]=$(hsv_to_color 185 100 "$v")   # neon cyan comets
    done
    echo "${colors[@]}"
}

# ---------- PRE-COMPUTE SIN TABLE ----------
# Full float precision - the wave modes do their math in awk,
# so bash integer-only arithmetic is never involved here.
declare -a wave_sin
for (( deg = 0; deg < 360; deg++ )); do
    rad=$(echo "$deg * 3.14159265359 / 180" | bc -l)
    sin_val=$(echo "s($rad)" | bc -l)
    wave_sin[$deg]=$(printf "%.4f" "$sin_val" 2>/dev/null || echo 0)
done

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
        neon)           colors=($(get_neon_colors)) ;;
        boomerang)      colors=($(get_boomerang_colors)) ;;
        galaxy)         colors=($(get_galaxy_colors)) ;;
        rainbow)        colors=($(get_rainbow_colors)) ;;
        wallust_random) colors=($(get_wallust_random_colors)) ;;
        gradient_flow)  colors=($(get_gradient_flow_colors)) ;;
        aurora)         colors=($(get_aurora_colors)) ;;
        plasma)         colors=($(get_plasma_colors)) ;;
        breathing)      colors=($(get_breathing_colors)) ;;
        neon_flicker)   colors=($(get_neon_flicker_colors)) ;;
        purple_wave)    colors=($(get_purple_wave_colors)) ;;
        orbit)
            colors=($(get_orbit_colors))
            # Decrease angle => heads orbit CLOCKWISE (TL -> TR -> BR -> BL)
            ORBIT_ANGLE=$(( (ORBIT_ANGLE - 6 + 3600) % 360 ))
            ;;
        *)              colors=($(get_rainbow_colors)) ;;
    esac

    hyprctl eval "hl.config({general = {col = {active_border = {colors = {${colors[0]}, ${colors[1]}, ${colors[2]}, ${colors[3]}, ${colors[4]}, ${colors[5]}, ${colors[6]}, ${colors[7]}, ${colors[8]}, ${colors[9]}}, angle = ${ORBIT_ANGLE:-270}}}}})"

    SNAKE_PHASE=$(( (SNAKE_PHASE + 1) % 20 ))
    SNAKE_HEAD=$(( (SNAKE_HEAD + 1) % 10 ))
    BOOMERANG_POS=$(( (BOOMERANG_POS + 1) % 10 ))
    AURORA_PHASE=$(( (AURORA_PHASE + 1) % 360 ))
    PLASMA_PHASE=$(( (PLASMA_PHASE + 2) % 360 ))
    BREATH_PHASE=$(( (BREATH_PHASE + 1) % 360 ))
    FLICKER_PHASE=$(( (FLICKER_PHASE + 1) % 40 ))

    sleep "$ANIMATION_DELAY"
done
