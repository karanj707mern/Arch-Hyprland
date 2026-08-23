#!/bin/bash
# Toggle OpenCode agent terminal for Hyprland
# Auto-approve mode enabled by default for non-denied permissions

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Resolve opencode binary without pinning a node version
OPENCODE_BIN="$(command -v opencode 2>/dev/null)"
if [ -z "$OPENCODE_BIN" ]; then
    OPENCODE_BIN="$(ls -t "$NVM_DIR"/versions/node/*/bin/opencode 2>/dev/null | head -n1)"
fi
if [ -z "$OPENCODE_BIN" ]; then
    notify-send -u critical "OpenCode" "opencode not found — run: npm install -g opencode-ai" 2>/dev/null
    exit 1
fi
WINDOW_TITLE="OpenCode Agent"

# If opencode is already running, close it
if pgrep -x "opencode" > /dev/null 2>&1; then
    pkill -x "opencode" 2>/dev/null
    exit 0
fi

# Launch opencode with auto-approve for non-denied permissions
# In TUI shortcuts:
#   /models        - list/switch Kilo free models
#   F2             - cycle recent models
#   ctrl+x         - command palette
#   /agent         - list/switch agents
#   ?              - help
kitty -T "$WINDOW_TITLE" -- $OPENCODE_BIN --auto
