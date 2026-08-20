# OpenCode + Kilo Free Models Setup

## What this gives you
- Free LLM access via Kilo's `kilo-auto/free` model (no API key required)
- Terminal AI agent that can run shell commands, edit files, and execute system tasks
- Hyprland keybind: `SUPER + G` to toggle the agent

## Step 1: Install OpenCode
Run this in your terminal:
```bash
sudo pacman -S opencode
```

Or for the latest version from AUR:
```bash
paru -S opencode-bin
```

## Step 2: Verify the plugin is installed
The `openkilo` plugin is already installed globally via npm:
```bash
npm list -g openkilo
```

## Step 3: Reload Hyprland
```bash
hyprctl reload
```

## Step 4: Use it
Press `SUPER + G` to toggle the OpenCode agent.
On first launch, OpenCode will automatically discover free models from Kilo.
Use `/model` to cycle through available providers.

## How it works
- OpenCode is a terminal-based AI agent
- It can execute shell commands, read/write files, and run system tasks
- The `openkilo` plugin connects it to Kilo's free model gateway
- No API key needed for free models
- Rate limit: ~200 requests/hour per IP for anonymous access

## If you want to use your local Ollama model instead
Edit `~/.config/opencode/opencode.json`:
```json
{
  "provider": {
    "name": "Ollama",
    "type": "ollama",
    "baseURL": "http://localhost:11434"
  },
  "model": "qwen2.5-coder:7b"
}
```

## Troubleshooting
- If OpenCode doesn't appear, run `which opencode` to verify installation
- If models don't load, run `/kilo_refresh` inside OpenCode
- If the keybind doesn't work, check `~/.config/hypr/UserConfigs/UserKeybinds.lua`
