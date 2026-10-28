#!/usr/bin/env bash
# Wrapper to run disk cleanup from Hyprland keybind (SUPER+SHIFT+C)
# Threshold-based: only cleans if disk >= 60% full

CLEAN_SCRIPT="/usr/local/bin/clean-disk.sh"

if ! command -v notify-send >/dev/null 2>&1; then
    exec "$CLEAN_SCRIPT" "$@"
fi

# Run in background, notify when done
"$CLEAN_SCRIPT" "$@" &
PID=$!

# Show a quick notification that cleanup started
notify-send -u low "Disk Cleanup" "Running threshold-based cleanup..." 2>/dev/null

# Wait for it and show summary
wait $PID
SUMMARY=$(tail -1 /var/log/clean-disk.log 2>/dev/null || echo "Cleanup complete")
notify-send -u normal "Disk Cleanup" "$SUMMARY" 2>/dev/null
