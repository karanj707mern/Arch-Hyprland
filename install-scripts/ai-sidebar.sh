#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# AI Sidebar - KiloCode Integration with AGS #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

LOG="Install-Logs/install-$(date +%d-%H%M%S)_ai-sidebar.log"

# Check for AUR helper
ISAUR=$(command -v yay || command -v paru)
if [ -z "$ISAUR" ]; then
  echo "AUR helper (yay or paru) not found. Please install an AUR helper first."
  exit 1
fi

# Install AGS dependencies if AGS is not installed
if ! command -v ags &> /dev/null; then
    printf "\n%s - Installing ${SKY_BLUE}AGS dependencies${RESET}\n" "${NOTE}"
    
    ags_deps=(
        typescript
        npm
        meson
        glib2-devel
        gjs
        gtk3
        gtk-layer-shell
        upower
        networkmanager
        gobject-introspection
        libdbusmenu-gtk3
        libsoup3
    )
    
    for PKG in "${ags_deps[@]}"; do
        install_package "$PKG" "$LOG"
    done
    
    printf "\n%s - Installing ${SKY_BLUE}Aylur's GTK Shell${RESET}\n" "${NOTE}"
    
    # Clone and install AGS
    if [ -d "ags_v1.9.0" ]; then
        rm -rf "ags_v1.9.0"
    fi
    
    if git clone --depth=1 https://github.com/JaKooLit/ags_v1.9.0.git; then
        cd ags_v1.9.0 || exit 1
        
        # Patch tsconfig
        if [ -f tsconfig.json ]; then
            if ! grep -q '"ignoreDeprecations"' tsconfig.json; then
                sed -i 's/"compilerOptions":[[:space:]]*{/"compilerOptions": {\n    "ignoreDeprecations": "6.0",/' tsconfig.json
            fi
            if grep -q '"moduleResolution"[[:space:]]*:[[:space:]]*"node10"' tsconfig.json; then
                sed -i 's/"moduleResolution"[[:space:]]*:[[:space:]]*"node10"/"moduleResolution": "node16"/' tsconfig.json
            fi
        fi
        
        # Replace pam.ts with stub
        if [ -f src/utils/pam.ts ]; then
            cat > src/utils/pam.ts <<'PAM_STUB'
export function authenticate(password: string): Promise<number> {
    return Promise.reject(new Error("PAM authentication disabled on this system (no GUtils)"));
}
export function authenticateUser(username: string, password: string): Promise<number> {
    return Promise.reject(new Error("PAM authentication disabled on this system (no GUtils)"));
}
PAM_STUB
        fi
        
        npm install
        meson setup build
        sudo meson install -C build 2>&1 | tee -a "$LOG"
        
        # Install launcher
        LAUNCHER_DIR="/usr/local/share/com.github.Aylur.ags"
        LAUNCHER_PATH="$LAUNCHER_DIR/com.github.Aylur.ags"
        sudo mkdir -p "$LAUNCHER_DIR"
        
        if [ -f "$SCRIPT_DIR/ags.launcher.com.github.Aylur.ags" ]; then
            sudo install -m 755 "$SCRIPT_DIR/ags.launcher.com.github.Aylur.ags" "$LAUNCHER_PATH"
        fi
        
        sudo mkdir -p /usr/local/bin
        sudo ln -srf "$LAUNCHER_PATH" /usr/local/bin/ags
        
        cd ..
        rm -rf ags_v1.9.0
        
        printf "\n%s - ${SKY_BLUE}AGS${RESET} installed successfully\n" "${OK}"
    else
        printf "\n%s - ${YELLOW}Warning:${RESET} AGS installation failed. Falling back to waybar-only mode.\n" "${WARN}"
    fi
else
    printf "\n%s - ${SKY_BLUE}AGS${RESET} already installed\n" "${OK}"
fi

# Install KiloCode CLI from AUR
printf "\n%s - Installing ${SKY_BLUE}KiloCode CLI${RESET} from AUR\n" "${NOTE}"
$ISAUR -S --noconfirm kilo-bin 2>&1 | tee -a "$LOG"

# Verify installations
if command -v kilo &> /dev/null; then
    printf "\n%s - ${SKY_BLUE}KiloCode CLI${RESET} installed successfully\n" "${OK}"
else
    printf "\n%s - ${YELLOW}Warning:${RESET} KiloCode CLI installation may have failed.\n" "${WARN}"
fi

printf "\n%.0s" {1..2}
