#!/bin/bash
# 💫 https://github.com/karanj707mern 💫 #
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# Hyprland-Dots to download from main #


## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Check if Hyprland-Dots exists
printf "${NOTE} Cloning and Installing ${SKY_BLUE}KooL's Hyprland Dots${RESET}....\n"

if [ -d Hyprland-Dots ]; then
  cd Hyprland-Dots
  git stash push -u || echo "Warning: git stash failed, proceeding with pull"
  if ! git pull; then
    echo "${ERROR} git pull failed for Hyprland-Dots."
    exit 1
  fi
  chmod +x copy.sh
  ./copy.sh 
else
  if git clone --depth=1 https://github.com/karanj707mern/Hyprland-Dots; then
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
    cd Hyprland-Dots || exit 1
    chmod +x copy.sh
    ./copy.sh 
  else
    echo -e "$ERROR Can't download ${YELLOW}KooL's Hyprland-Dots${RESET} . Check your internet connection"
    exit 1
  fi
fi

printf "\n%.0s" {1..2}