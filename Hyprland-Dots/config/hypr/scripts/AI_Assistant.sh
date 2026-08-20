#!/usr/bin/env bash
# /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  ##
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
# AI Assistant Script - KiloCode Integration
# Provides system-wide bug fixes, daily task help, and AI assistance
# Uses only FREE models

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/hypr"
KILO_CMD="kilo"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Skills / Modes
SKILL_LINUX="Linux Expert"
SKILL_SOFTWARE="Software Expert"
SKILL_DEBUG="Debug Expert"
SKILL_AUTO="Auto Detection"

# Free models only
FREE_MODELS=(
    "kilo/openrouter/free"
    "kilo/stepfun/step-3.7-flash:free"
    "kilo/liquid/lfm-2.5-2.6b:free"
    "kilo/nvidia/nemotron-3.5-lightning:free"
    "kilo/nvidia/nemotron-3-super-120b-a12b:free"
    "kilo/poolside/laguna-s-2.1:free"
    "kilo/tencent/hy3:free"
)
DEFAULT_FREE_MODEL="kilo/openrouter/free"

check_kilocode() {
    if ! command -v "$KILO_CMD" &> /dev/null; then
        echo -e "${RED}Error: KiloCode CLI not found${NC}"
        echo -e "${YELLOW}Install with: yay -S kilo-bin${NC}"
        rofi -e "KiloCode CLI not found.\nInstall with: yay -S kilo-bin" -title "AI Assistant Error"
        exit 1
    fi
}

# Run KiloCode with a selected skill/mode and free model
run_with_skill() {
    local skill="$1"
    local query="$2"
    local system_prompt=""

    case "$skill" in
        "$SKILL_LINUX")
            system_prompt="You are a Linux system expert specializing in Arch Linux, Hyprland, and system administration. Provide concise, safe, and executable commands. Explain risks before suggesting destructive operations."
            ;;
        "$SKILL_SOFTWARE")
            system_prompt="You are a software engineering expert. Help with coding, debugging, refactoring, and design. Provide clean, idiomatic code with explanations. Prioritize best practices and security."
            ;;
        "$SKILL_DEBUG")
            system_prompt="You are a debugging expert. Analyze logs, stack traces, and system behavior. Identify root causes and provide step-by-step fixes. Be methodical and thorough."
            ;;
        "$SKILL_AUTO")
            system_prompt="You are an autonomous system assistant. Automatically detect and fix issues on this Arch Linux + Hyprland system. Check logs, services, packages, and configs. Apply safe fixes automatically and report what was done."
            ;;
        *)
            system_prompt="You are a helpful AI assistant."
            ;;
    esac

    echo -e "${BLUE}Running [${MAGENTA}$skill${BLUE}]...${NC}"

    local full_prompt="$system_prompt\n\nTask: $query"
    local response
    response=$(timeout 120 $KILO_CMD run --format default --auto -m "$DEFAULT_FREE_MODEL" "$full_prompt" 2>/dev/null || echo "Error: KiloCode timed out or failed")
    response=$(echo "$response" | jq -r '.data.message // .message // .error.message // . // empty' 2>/dev/null || echo "$response")
    show_response "$skill" "$response" "$skill"
}

show_skill_menu() {
    local choice
    choice=$(rofi -dmenu -p "Select AI Skill" \
        -mesg "Choose an expert mode:" \
        -lines 4 \
        -width 35 \
    <<EOF
$SKILL_LINUX
$SKILL_SOFTWARE
$SKILL_DEBUG
$SKILL_AUTO
EOF
    )
    echo "$choice"
}

ask_with_skill() {
    local skill
    skill=$(show_skill_menu)
    [[ -z "$skill" ]] && exit 0

    local query
    query=$(rofi -dmenu -p "Ask [$skill]:" \
        -lines 0 \
        -width 45 \
        -mesg "Describe your question or task" \
    )
    [[ -z "$query" ]] && exit 0

    run_with_skill "$skill" "$query"
}

show_menu() {
    local choice
    choice=$(rofi -dmenu -p "AI Assistant (KiloCode)" \
        -mesg "Select an option:" \
        -lines 5 \
        -width 30 \
    <<EOF
Ask AI (Custom Query)
System Diagnostics
Bug Fix Helper
Daily Task Helper
Settings
EOF
    )
    echo "$choice"
}

ask_ai() {
    ask_with_skill
}

run_diagnostics() {
    check_kilocode
    echo -e "${BLUE}Running system diagnostics with KiloCode...${NC}"
    local prompt="Perform a comprehensive system diagnostic check on this Arch Linux + Hyprland system. Analyze:
1. System logs (journalctl --since '1 hour ago' --priority=err)
2. Failed services (systemctl --failed)
3. Disk usage (df -h)
4. Memory usage (free -h)
5. CPU load (uptime)
6. Recent pacman/yay transactions

For each issue, suggest a fix. Be concise and actionable."
    local response
    response=$(timeout 120 $KILO_CMD run --format default --auto -m "$DEFAULT_FREE_MODEL" "$prompt" 2>/dev/null || echo "Error: KiloCode timed out or failed")
    response=$(echo "$response" | jq -r '.data.message // .message // .error.message // . // empty' 2>/dev/null || echo "$response")
    show_response "System Diagnostics" "$response"
}

run_bugfix() {
    check_kilocode
    echo -e "${BLUE}Running bug fix analysis...${NC}"
    local prompt="Analyze this Arch Linux system for bugs. CRITICAL: Only check SYSTEM packages installed via pacman, NOT home directory or user folders. Run these exact commands: journalctl -p 3 -xb for errors, pacman -Dk for package database issues, pacman -Qm for broken deps, pacman -Qtdq for ORPHANED SYSTEM PACKAGES ONLY. Do NOT scan ~/.cache, ~/.local, ~/.config, or any home folder for packages. Provide safe fix commands for system-level issues only."
    local response
    response=$(timeout 120 $KILO_CMD run --format default --auto -m "$DEFAULT_FREE_MODEL" "$prompt" 2>/dev/null || echo "Error: KiloCode timed out or failed")
    response=$(echo "$response" | jq -r '.data.message // .message // .error.message // . // empty' 2>/dev/null || echo "$response")
    show_response "Bug Fix Analysis" "$response"
}

daily_tasks() {
    check_kilocode
    local task
    task=$(rofi -dmenu -p "Daily Task Helper" \
        -lines 0 \
        -width 40 \
        -mesg "Describe your task or ask for help with planning" \
    )
    [[ -z "$task" ]] && exit 0
    echo -e "${BLUE}Processing with KiloCode...${NC}"
    local prompt="Help me with this daily task: $task\n\nProvide a clear, actionable plan or solution. Break it down into steps if needed."
    local response
    response=$(timeout 60 $KILO_CMD run --format default --auto -m "$DEFAULT_FREE_MODEL" "$prompt" 2>/dev/null || echo "Error: KiloCode timed out or failed")
    response=$(echo "$response" | jq -r '.data.message // .message // .error.message // . // empty' 2>/dev/null || echo "$response")
    show_response "Task Helper" "$response" "daily"
}

show_response() {
    local title="$1"
    local content="$2"
    local skill="${3:-}"

    local buttons="--button=Close:0"
    [[ -n "$skill" ]] && buttons="$buttons --button=Follow-up:2"

    echo "$content" | yad --text-info \
        --title="$title" \
        --width=700 \
        --height=500 \
        --fontname="Sans 10" \
        --wrap \
        --center \
        --buttons-layout=spread \
        $buttons \
        --button="Copy":1
    local rc=$?
    if [[ $rc -eq 1 ]]; then
        echo "$content" | wl-copy
        rofi -e "Response copied to clipboard" -title "Copied" -timeout 2
    elif [[ $rc -eq 2 && -n "$skill" ]]; then
        follow_up "$skill"
    fi
}

follow_up() {
    local skill="$1"
    local query
    query=$(rofi -dmenu -p "Follow-up [$skill]:" \
        -lines 0 \
        -width 45 \
        -mesg "Ask a follow-up question" \
    )
    [[ -z "$query" ]] && return
    run_with_skill "$skill" "$query"
}

show_settings() {
    local info="KiloCode AI Sidebar Settings

Provider: KiloCode CLI
Command: $KILO_CMD
Status: $(command -v "$KILO_CMD" &> /dev/null && echo "Installed" || echo "Not Installed")

Model (Free): $DEFAULT_FREE_MODEL

Skills Available:
  - $SKILL_LINUX
  - $SKILL_SOFTWARE
  - $SKILL_DEBUG
  - $SKILL_AUTO

Installation:
  yay -S kilo-bin

Usage:
  Left Click: Ask AI (with skill selection)
  Right Click: This menu
  Scroll Up: System Diagnostics
  Scroll Down: Bug Fix Helper

Config:
  $CONFIG_DIR/hypr/scripts/AI_Assistant.sh"
    rofi -e "$info" -title "AI Assistant Settings" -width 40 -lines 18
}

main() {
    check_kilocode
    case "${1:-}" in
        --ask)
            ask_ai
            ;;
        --menu)
            local choice
            choice=$(show_menu)
            case "$choice" in
                "Ask AI (Custom Query)")
                    ask_ai
                    ;;
                "System Diagnostics")
                    run_diagnostics
                    ;;
                "Bug Fix Helper")
                    run_bugfix
                    ;;
                "Daily Task Helper")
                    daily_tasks
                    ;;
                "Settings")
                    show_settings
                    ;;
            esac
            ;;
        --diagnostics)
            run_diagnostics
            ;;
        --bugfix)
            run_bugfix
            ;;
        *)
            echo "Usage: $0 {--ask|--menu|--diagnostics|--bugfix}"
            exit 1
            ;;
    esac
}

main "$@"
