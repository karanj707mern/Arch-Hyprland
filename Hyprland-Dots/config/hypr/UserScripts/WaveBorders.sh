#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# WaveBorders - Purple bright-to-dark wave border animation
# Modes: wave | wave_dual | wave_pulse | tide

# ---------- PREVENT DUPLICATES ----------
lock_file="$XDG_RUNTIME_DIR/wave-borders.lock"
exec 200>"$lock_file"
# Retry briefly instead of exiting silently (see RainbowBordersSnake.sh)
_flock_ok=0
for _ in {1..30}; do
    flock -n 200 && { _flock_ok=1; break; }
    sleep 0.1
done
(( _flock_ok )) || exit 0

# ---------- CONFIG ----------
EFFECT_TYPE="${1:-wave}"
WAVE_SPEED=0.12
WAVE_PHASE=0

# ---------- PRE-COMPUTE SIN TABLE (0-359) ----------
declare -a wave_sin
for (( deg = 0; deg < 360; deg++ )); do
    rad=$(echo "$deg * 3.14159265359 / 180" | bc -l)
    sin_val=$(echo "s($rad)" | bc -l)
    wave_sin[$deg]=$(printf "%.4f" "$sin_val" 2>/dev/null || echo 0)
done

# ---------- HSV TO RGB (proper floating point via awk) ----------
function hsv_to_color() {
    local h=$1 s=$2 v=$3
    local r g b
    read r g b <<< $(awk -v h="$h" -v s="$s" -v v="$v" 'function abs(x) {return (x < 0 ? -x : x)} BEGIN {
        s = s / 100; v = v / 100;
        c = v * s;
        x = c * (1 - abs((h / 60) % 2 - 1));
        m = v - c;
        if (h < 60) { r=c; g=x; b=0 }
        else if (h < 120) { r=x; g=c; b=0 }
        else if (h < 180) { r=0; g=c; b=x }
        else if (h < 240) { r=0; g=x; b=c }
        else if (h < 300) { r=x; g=0; b=c }
        else { r=c; g=0; b=x }
        R = int((r+m)*255); G = int((g+m)*255); B = int((b+m)*255);
        if (R < 0) R = 0; if (R > 255) R = 255;
        if (G < 0) G = 0; if (G > 255) G = 255;
        if (B < 0) B = 0; if (B > 255) B = 255;
        printf "%d %d %d", R, G, B
    }')
    printf "0xff%02x%02x%02x" "$r" "$g" "$b"
}

# ---------- WAVE MODE ----------
# Purple bright-to-dark wave rippling across segments
function get_wave_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local wave_idx=$(( (i * 36 + WAVE_PHASE) % 360 ))
        local sin_val=${wave_sin[$wave_idx]}
        local intensity=$(awk "BEGIN {printf \"%.0f\", 38 + 62 * (1 + $sin_val) / 2}")
        (( intensity > 100 )) && intensity=100
        (( intensity < 38 )) && intensity=38

        # Purple range: hue 260-310
        local base_hue=285
        local hue_shift=$(awk "BEGIN {printf \"%d\", ($intensity - 50) * 0.4}")
        local hue=$(( base_hue + hue_shift ))
        (( hue < 260 )) && hue=260
        (( hue > 320 )) && hue=320

        local saturation=$(( 80 + intensity / 5 ))
        (( saturation > 100 )) && saturation=100
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- WAVE DUAL MODE ----------
# Two counter-traveling purple waves. The second wave runs at 1.5x phase
# speed so the interference beats DRIFT around the border instead of forming
# a static standing wave (old behavior looked like steady solid pink).
function get_wave_dual_colors() {
    local colors=()
    local fast_phase=$(( (WAVE_PHASE * 3) % 360 ))
    for (( i = 0; i < 10; i++ )); do
        local wave1_idx=$(( (i * 36 + WAVE_PHASE) % 360 ))
        local wave2_idx=$(( ((9 - i) * 36 + fast_phase) % 360 ))
        local sin1=${wave_sin[$wave1_idx]}
        local sin2=${wave_sin[$wave2_idx]}
        # Range 38..100 -> strong visible contrast between crests/troughs
        local combined=$(awk "BEGIN {printf \"%.0f\", 69 + 31 * (($sin1 + $sin2) / 2)}")
        (( combined > 100 )) && combined=100
        (( combined < 38 )) && combined=38

        local base_hue=285
        local hue_shift=$(awk "BEGIN {printf \"%d\", ($combined - 55) * 0.6}")
        local hue=$(( base_hue + hue_shift ))
        (( hue < 260 )) && hue=260
        (( hue > 320 )) && hue=320

        local saturation=$(( 80 + combined / 5 ))
        (( saturation > 100 )) && saturation=100
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$combined")
    done
    echo "${colors[@]}"
}

# ---------- WAVE PULSE MODE ----------
# Bright purple pulse from center, fading outward
function get_wave_pulse_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local dist=$(( i - 4 ))
        (( dist < 0 )) && dist=$(( -dist ))
        local wave_idx=$(( (dist * 60 - WAVE_PHASE) % 360 ))
        (( wave_idx < 0 )) && wave_idx=$(( wave_idx + 360 ))
        local sin_val=${wave_sin[$wave_idx]}
        local intensity=$(awk "BEGIN {printf \"%.0f\", 35 + 65 * (1 + $sin_val) / 2}")
        (( intensity > 100 )) && intensity=100
        (( intensity < 35 )) && intensity=35

        # Closer to center = brighter, more magenta (lower hue)
        local hue=$(( 310 - dist * 8 ))
        (( hue < 260 )) && hue=260
        local saturation=$(( 85 + intensity / 6 ))
        (( saturation > 100 )) && saturation=100
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- TIDE MODE ----------
# Slow purple tide
function get_tide_colors() {
    local colors=()
    for (( i = 0; i < 10; i++ )); do
        local wave_idx=$(( (WAVE_PHASE + i * 20) % 360 ))
        local sin_val=${wave_sin[$wave_idx]}
        local intensity=$(awk "BEGIN {printf \"%.0f\", 38 + 62 * (1 + $sin_val) / 2}")
        (( intensity > 100 )) && intensity=100
        (( intensity < 38 )) && intensity=38

        local hue=$(( 280 + (WAVE_PHASE + i * 4) % 40 ))
        (( hue < 260 )) && hue=260
        (( hue > 320 )) && hue=320
        local saturation=$(( 75 + intensity / 4 ))
        (( saturation > 100 )) && saturation=100
        colors[$i]=$(hsv_to_color "$hue" "$saturation" "$intensity")
    done
    echo "${colors[@]}"
}

# ---------- MAIN LOOP ----------
while true; do
    case "$EFFECT_TYPE" in
        wave)        colors=($(get_wave_colors)) ;;
        wave_dual)   colors=($(get_wave_dual_colors)) ;;
        wave_pulse)  colors=($(get_wave_pulse_colors)) ;;
        tide)        colors=($(get_tide_colors)) ;;
        *)           colors=($(get_wave_colors)) ;;
    esac

    # Build hyprctl eval command
    cmd="hl.config({general = {col = {active_border = {colors = {"
    for (( j = 0; j < 10; j++ )); do
        (( j > 0 )) && cmd+=", "
        cmd+="${colors[$j]}"
    done
    cmd+="}, angle = 270}}}})"

    hyprctl eval "$cmd" 2>/dev/null || true

    WAVE_PHASE=$(( WAVE_PHASE + 1 ))
    (( WAVE_PHASE >= 360 )) && WAVE_PHASE=0

    sleep "$WAVE_SPEED"
done
