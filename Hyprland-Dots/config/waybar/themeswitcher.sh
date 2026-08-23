#!/usr/bin/env bash
# -----------------------------------------------------
# Waybar theme switcher (repaired)
#
# The legacy ~/.config/waybar/themes layout is not used by
# this dotfiles setup anymore: the active bar always reads
#   ~/.config/waybar/config    -> configs/<LAYOUT>
#   ~/.config/waybar/style.css -> style/<THEME>.css
# Style switching is handled by the symlink-based switcher,
# which also restarts the bar cleanly.
# -----------------------------------------------------

exec "$HOME/.config/hypr/scripts/WaybarStyles.sh" "$@"
