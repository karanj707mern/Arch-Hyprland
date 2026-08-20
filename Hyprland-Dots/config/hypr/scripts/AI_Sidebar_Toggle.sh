#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Toggle AI Sidebar (Quickshell IPC), starting the configured shell if needed.

if command -v qs >/dev/null 2>&1; then
    if qs ipc -c overview call ai_sidebar toggle >/dev/null 2>&1; then
        exit 0
    fi

    # The startup command may not have run yet (for example, immediately after login).
    qs -c overview >/dev/null 2>&1 &
    for _ in 1 2 3 4 5; do
        sleep 0.2
        if qs ipc -c overview call ai_sidebar toggle >/dev/null 2>&1; then
            exit 0
        fi
    done
fi

notify-send "AI Sidebar" "Quickshell overview is not available" -i "dialog-error" 2>/dev/null || true
exit 1
