#!/usr/bin/env bash
# Waybar custom module: fan speed
FAN_PATH="/sys/class/hwmon/hwmon3/fan1_input"
if [ -f "$FAN_PATH" ]; then
    rpm=$(cat "$FAN_PATH")
    echo "${rpm} RPM"
else
    echo "N/A"
fi
