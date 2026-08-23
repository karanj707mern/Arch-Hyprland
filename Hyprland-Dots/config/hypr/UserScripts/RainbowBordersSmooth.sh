#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Smooth border color cycling with gradual transitions
# Interpolates between wallust colors for a smooth flow effect

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/rainbow-smooth.lock"
exec 200>"$lock_file"
# Retry briefly instead of exiting silently (see RainbowBordersSnake.sh)
_flock_ok=0
for _ in {1..30}; do
    flock -n 200 && { _flock_ok=1; break; }
    sleep 0.1
done
(( _flock_ok )) || exit 0

EFFECT_TYPE="gradient_flow"
WALLUST_COLORS_SOURCE="$HOME/.config/hypr/wallust/wallust-hyprland.conf"
WALLUST_COLORS=()

# ---------- LOAD WALLUST COLORS ----------
if [[ "$EFFECT_TYPE" == "wallust_random" || "$EFFECT_TYPE" == "gradient_flow" ]]; then
    mapfile -t WALLUST_COLORS < <(
        grep -E '^\$color[0-9]+' "$WALLUST_COLORS_SOURCE" | awk '
        function hex2(s){ return (length(s)==6 ? "0xff"s : ""); }
        function rgb2(r,g,b){ return sprintf("0xff%02x%02x%02x", r, g, b); }
        {
            if (match($0, /0x([0-9a-fA-F]{8})/, m)) { print "0x" m[1]; next }
            if (match($0, /#([0-9a-fA-F]{6})/, m))  { print hex2(m[1]); next }
            if (match($0, /rgb\(([0-9a-fA-F]{6})\)/, m)) {
                print hex2(m[1]); next
            }
            if (match($0, /rgb\(([0-9]+),[ ]*([0-9]+),[ ]*([0-9]+)\)/, m)) {
                print rgb2(m[1], m[2], m[3]); next
            }
        }'
    )

    if (( ${#WALLUST_COLORS[@]} == 0 )); then
        EFFECT_TYPE="rainbow"
    fi
fi

# ---------- COLOR HELPERS ----------
function hex_to_rgb() {
    local hex="${1#0xff}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    echo "$r $g $b"
}

function rgb_to_hex() {
    printf "0xff%02x%02x%02x" "$1" "$2" "$3"
}

function lerp_color() {
    # lerp_color <hex1> <hex2> <t> where t is 0..1
    local rgb1=($(hex_to_rgb "$1"))
    local rgb2=($(hex_to_rgb "$2"))
    local t="$3"
    local r=$(( ${rgb1[0]} + (${rgb2[0]} - ${rgb1[0]}) * t / 100 ))
    local g=$(( ${rgb1[1]} + (${rgb2[1]} - ${rgb1[1]}) * t / 100 ))
    local b=$(( ${rgb1[2]} + (${rgb2[2]} - ${rgb1[2]}) * t / 100 ))
    rgb_to_hex "$r" "$g" "$b"
}

function lerp_angle() {
    local a1="$1"
    local a2="$2"
    local t="$3"
    # shortest path interpolation around the circle
    local diff=$(( a2 - a1 ))
    if (( diff > 180 )); then diff=$(( diff - 360 )); fi
    if (( diff < -180 )); then diff=$(( diff + 360 )); fi
    local new=$(( a1 + diff * t / 100 ))
    (( new < 0 )) && new=$(( new + 360 ))
    (( new >= 360 )) && new=$(( new - 360 ))
    echo "${new}"
}

# ---------- GRADIENT FLOW MODE ----------
BASE_COLOR="${WALLUST_COLORS[10]}"
GRAD1_COLOR="${WALLUST_COLORS[14]}"
GRAD2_COLOR="${WALLUST_COLORS[13]}"
GLOW_COLOR="${WALLUST_COLORS[15]}"

STOPS=(
    "${WALLUST_COLORS[0]}"
    "${WALLUST_COLORS[1]}"
    "${WALLUST_COLORS[2]}"
    "${WALLUST_COLORS[3]}"
    "${WALLUST_COLORS[4]}"
    "${WALLUST_COLORS[5]}"
    "${WALLUST_COLORS[6]}"
    "${WALLUST_COLORS[7]}"
    "${WALLUST_COLORS[8]}"
    "${WALLUST_COLORS[9]}"
)

MAX_POS=10
GLOW_POS=0

function gradient_flow_color() {
    local pos=$1
    local d=$(( pos - GLOW_POS ))
    (( d > MAX_POS/2 )) && d=$(( d - MAX_POS ))
    (( d < -MAX_POS/2 )) && d=$(( d + MAX_POS ))
    case "${d#-}" in
        0) echo "$GLOW_COLOR" ;;
        1) echo "$GRAD1_COLOR" ;;
        2) echo "$GRAD2_COLOR" ;;
        *) echo "$BASE_COLOR" ;;
    esac
}

# ---------- STATE ----------
current_angle=0
current_stops=()
for i in "${!STOPS[@]}"; do current_stops[$i]="${STOPS[$i]}"; done

# ---------- SMOOTH UPDATE LOOP ----------
STEP_MS=180
TRANSITION_STEPS=35
ANGLE_STEP=9
SLEEP_DURATION=$(awk "BEGIN {printf \"%.3f\", ${STEP_MS}/1000}")

while true; do
    # Shift gradient window
    GLOW_POS=$(( (GLOW_POS + 1) % MAX_POS ))

    # Build target colors
    target_stops=()
    for i in 0 1 2 3 4 5 6 7 8 9; do
        target_stops[$i]=$(gradient_flow_color "$i")
    done

    target_angle=$(( current_angle + ANGLE_STEP ))
    (( target_angle >= 360 )) && target_angle=$(( target_angle - 360 ))

    # Smooth transition
    for ((step=1; step<=TRANSITION_STEPS; step++)); do
        t=$(( step * 100 / TRANSITION_STEPS ))
        new_angle=$(lerp_angle "$current_angle" "$target_angle" "$t")

        new_stops=()
        for i in "${!current_stops[@]}"; do
            new_stops[$i]=$(lerp_color "${current_stops[$i]}" "${target_stops[$i]}" "$t")
        done

        colors_csv=$(IFS=, ; echo "${new_stops[*]}")

        hyprctl eval "hl.config({general = {col = {active_border = {colors = {${colors_csv}}, angle = ${new_angle}}}}})"

        sleep "$SLEEP_DURATION"
    done

    current_angle="$target_angle"
    for i in "${!current_stops[@]}"; do current_stops[$i]="${target_stops[$i]}"; done
done
