#!/usr/bin/env bash
# CPU temp + fan speed for waybar
CPU_TEMP_PATH="/sys/class/hwmon/hwmon4/temp1_input"
FAN_PATH="/sys/class/hwmon/hwmon3/fan1_input"

temp="N/A"
fan="N/A"

if [ -f "$CPU_TEMP_PATH" ]; then
    temp="$(( $(cat "$CPU_TEMP_PATH") / 1000 ))°C"
fi
if [ -f "$FAN_PATH" ]; then
    fan="$(cat "$FAN_PATH") RPM"
fi

# Color class based on temp only
class="temp-cool"
if [ -f "$CPU_TEMP_PATH" ]; then
    c=$(( $(cat "$CPU_TEMP_PATH") / 1000 ))
    if [ "$c" -ge 85 ]; then
        class="temp-hot"
    elif [ "$c" -ge 65 ]; then
        class="temp-warm"
    fi
fi

printf '{"text": "%s | %s", "class": "%s"}\n' "$temp" "$fan" "$class"
