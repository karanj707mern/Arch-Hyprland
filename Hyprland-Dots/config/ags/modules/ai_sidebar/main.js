import Widget from 'resource:///com/github/Aylur/ags/widget.js';
import { App, GLib } from 'resource:///com/github/Aylur/ags/app.js';
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const { Box, Button, Entry, Label, Scrollable, Separator, Window } = Widget;
const { execAsync } = Utils;

const HISTORY_FILE = `${GLib.get_home_dir()}/.config/ags/ai_sidebar_history.json`;
const MAX_HISTORY = 50;

function loadHistory() {
    try {
        const [exists, contents] = GLib.file_get_contents(HISTORY_FILE);
        if (exists) {
            return JSON.parse(contents) || [];
        }
    } catch (e) {
        console.log('[AI Sidebar] Failed to load history:', e);
    }
    return [];
}

function saveHistory(history) {
    try {
        GLib.mkdir_with_parents(`${GLib.get_home_dir()}/.config/ags`, 0700);
        const data = JSON.stringify(history.slice(-MAX_HISTORY));
        GLib.file_set_contents(HISTORY_FILE, data);
    } catch (e) {
        console.log('[AI Sidebar] Failed to save history:', e);
    }
}

function runKiloCode(query) {
    // Pass the prompt as an argv item; never interpolate it into a shell command.
    return execAsync(['timeout', '120', 'kilo', 'run', '--format', 'default', '--auto', query])
        .then(result => result.trim() || 'No response')
        .catch(error => `KiloCode command failed: ${error}`);
}

function createMessageBubble(text, isUser) {
    const bubble = Box({
        vertical: true,
        className: isUser ? 'ai-message-user' : 'ai-message-bot',
        children: [
            Label({
                label: isUser ? 'You' : 'KiloCode',
                className: 'ai-message-label',
            }),
            Label({
                label: text,
                wrap: true,
                xalign: 0,
                className: 'ai-message-text',
            }),
        ],
    });
    return bubble;
}

function AISidebar() {
    let history = loadHistory();
    let historyBox = Box({
        vertical: true,
        spacing: 8,
        children: history.map(msg => createMessageBubble(msg.text, msg.role === 'user')),
    });

    const scrollable = Scrollable({
        hscroll: 'never',
        vexpand: true,
        child: Box({
            vertical: true,
            spacing: 8,
            children: [historyBox],
        }),
    });

    const inputEntry = Entry({
        placeholder_text: 'Ask KiloCode anything...',
        onAccept: (self) => {
            const query = self.text.trim();
            if (!query) return;
            
            self.text = '';
            
            history.push({ role: 'user', text: query, timestamp: Date.now() });
            historyBox.add(createMessageBubble(query, true));
            scrollable.scrollToEnd();
            
            const loadingLabel = Label({
                label: 'Thinking...',
                className: 'ai-loading',
            });
            historyBox.add(loadingLabel);
            scrollable.scrollToEnd();
            
            runKiloCode(query).then(response => {
                historyBox.remove(loadingLabel);
                history.push({ role: 'assistant', text: response, timestamp: Date.now() });
                historyBox.add(createMessageBubble(response, false));
                saveHistory(history);
                scrollable.scrollToEnd();
            });
        },
    });

    const quickActions = Box({
        spacing: 4,
        children: [
            Button({
                label: 'Diagnostics',
                onClicked: () => {
                    inputEntry.text = 'Run comprehensive system diagnostics on this Arch Linux + Hyprland system. Check logs, services, disk, memory, and packages.';
                    inputEntry.emit('activate');
                },
            }),
            Button({
                label: 'Bug Fix',
                onClicked: () => {
                    inputEntry.text = 'Analyze this Arch Linux system for bugs. CRITICAL: Only check SYSTEM packages installed via pacman, NOT home directory or user folders. Run these exact commands: journalctl -p 3 -xb for errors, pacman -Dk for package database issues, pacman -Qm for broken deps, pacman -Qtdq for ORPHANED SYSTEM PACKAGES ONLY. Do NOT scan ~/.cache, ~/.local, ~/.config, or any home folder for packages. Provide safe fix commands for system-level issues only.';
                    inputEntry.emit('activate');
                },
            }),
            Button({
                label: 'Update',
                onClicked: () => {
                    inputEntry.text = 'Check for system updates and provide a summary of what needs updating. Include any important notes about the updates.';
                    inputEntry.emit('activate');
                },
            }),
            Button({
                label: 'Clear',
                onClicked: () => {
                    history = [];
                    saveHistory([]);
                    historyBox.children = [];
                },
            }),
        ],
    });

    const sidebarContent = Box({
        vertical: true,
        spacing: 8,
        children: [
            Box({
                children: [
                    Label({
                        label: '󰍩 AI Assistant',
                        className: 'ai-title',
                    }),
                    Button({
                        label: '✕',
                        className: 'ai-close-btn',
                        onClicked: () => App.closeWindow('ai_sidebar'),
                    }),
                ],
            }),
            Separator(),
            quickActions,
            Separator(),
            scrollable,
            Box({
                children: [
                    inputEntry,
                    Button({
                        label: 'Send',
                        className: 'ai-send-btn',
                        onClicked: () => inputEntry.emit('activate'),
                    }),
                ],
            }),
        ],
    });

    return Window({
        name: 'ai_sidebar',
        visible: false,
        layer: 'overlay',
        anchor: ['left', 'top', 'bottom'],
        marginTop: 8,
        marginBottom: 8,
        marginLeft: 3,
        width: 380,
        child: Box({
            className: 'ai-sidebar-container',
            children: [sidebarContent],
        }),
    });
}

export default AISidebar;
