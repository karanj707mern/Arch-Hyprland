-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
-- Default Keybinds
-- visit https://wiki.hypr.land/Configuring/Basics/Binds/ for more info

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserScripts = os.getenv("HOME") .. "/.config/hypr/UserScripts"
local UserConfigs = os.getenv("HOME") .. "/.config/hypr/UserConfigs"

local term = "kitty"
local files = "thunar"

-- STANDARD
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"), { description = "app launcher" })
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("xdg-open \"https://\""), { description = "open default browser" })
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(scriptsDir .. "/OverviewToggle.sh"), { description = "desktop overview" })
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term), { description = "Open terminal" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(files), { description = "file manager" })

-- FEATURES / EXTRAS
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(scriptsDir .. "/ThemeChanger.sh"), { description = "Global theme switcher using Wallust" })
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(scriptsDir .. "/KeyHints.sh"), { description = "help / cheat sheet" })
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"), { description = "refresh bar and menus" })
hl.bind(mainMod .. " + ALT + E", hl.dsp.exec_cmd(scriptsDir .. "/RofiEmoji.sh"), { description = "emoji menu" })
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(scriptsDir .. "/RofiSearch.sh"), { description = "web search" })
hl.bind(mainMod .. " + CTRL + S", hl.dsp.exec_cmd("rofi -show window"), { description = "window switcher" })
hl.bind(mainMod .. " + ALT + O", hl.dsp.exec_cmd(scriptsDir .. "/ChangeBlur.sh"), { description = "toggle blur" })
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(scriptsDir .. "/GameMode.sh"), { description = "toggle game mode" })
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/ChangeLayout.sh"), { description = "toggle master/dwindle layout" })
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"), { description = "clipboard manager" })
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd(scriptsDir .. "/RofiThemeSelector.sh"), { description = "rofi theme selector" })
hl.bind(mainMod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("pkill rofi || true && " .. scriptsDir .. "/RofiThemeSelector-modified.sh"), { description = "rofi theme selector (modified)" })

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen(0), { description = "fullscreen" })
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen(1), { description = "maximize window" })
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Float current window" })
hl.bind(mainMod .. " + ALT + Space", hl.dsp.exec_cmd("hyprctl dispatch workspaceopt allfloat"), { description = "Float all windows" })
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(scriptsDir .. "/Dropterminal.sh " .. term), { description = "DropDown terminal" })

-- Desktop zooming or magnifier
hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')\""), { description = "zoom in" })
hl.bind(mainMod .. " + ALT + mouse_up", hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')\""), { description = "zoom out" })

-- Waybar / Bar related
hl.bind(mainMod .. " + CTRL + ALT + B", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "toggle waybar on/off" })
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd(scriptsDir .. "/WaybarStyles.sh"), { description = "waybar styles menu" })
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(scriptsDir .. "/WaybarLayout.sh"), { description = "waybar layout menu" })

-- Night light toggle (Hyprsunset)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(scriptsDir .. "/Hyprsunset.sh toggle"), { description = "toggle night light" })

-- FEATURES / EXTRAS (UserScripts)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(UserScripts .. "/RofiBeats.sh"), { description = "online music" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperSelect.sh"), { description = "select wallpaper" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperEffects.sh"), { description = "wallpaper effects" })
hl.bind("CTRL + ALT + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperRandom.sh"), { description = "random wallpaper" })
hl.bind(mainMod .. " + CTRL + O", hl.dsp.window.set_prop({ prop = "forcergbx", value = "toggle" }), { description = "toggle active window opaque/transparent" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd(scriptsDir .. "/KeyBinds.sh"), { description = "search keybinds" })
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(scriptsDir .. "/Animations.sh"), { description = "animations menu" })
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd(UserScripts .. "/ZshChangeTheme.sh"), { description = "change oh-my-zsh theme" })
hl.bind("ALT_L + SHIFT_L", hl.dsp.exec_cmd(scriptsDir .. "/KeyboardLayout.sh switch"), { description = "switch keyboard layout globally" })
hl.bind("SHIFT_L + ALT_L", hl.dsp.exec_cmd(scriptsDir .. "/Tak0-Per-Window-Switch.sh"), { description = "switch keyboard layout per-window" })
hl.bind(mainMod .. " + ALT + C", hl.dsp.exec_cmd(UserScripts .. "/RofiCalc.sh"), { description = "calculator" })

-- Move current workspaces to monitors
hl.bind(mainMod .. " + CTRL + F9", hl.dsp.exec_cmd("movecurrentworkspacetomonitor l"), { description = "move workspace to left monitor" })
hl.bind(mainMod .. " + CTRL + F10", hl.dsp.exec_cmd("movecurrentworkspacetomonitor r"), { description = "move workspace to right monitor" })
hl.bind(mainMod .. " + CTRL + F11", hl.dsp.exec_cmd("movecurrentworkspacetomonitor u"), { description = "move workspace to up monitor" })
hl.bind(mainMod .. " + CTRL + F12", hl.dsp.exec_cmd("movecurrentworkspacetomonitor d"), { description = "move workspace to down monitor" })

-- SYSTEM
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("hyprctl dispatch exit 0"), { description = "exit Hyprland" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "close active window" })
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(scriptsDir .. "/KillActiveProcess.sh"), { description = "Terminate active process" })
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"), { description = "lock screen" })
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(scriptsDir .. "/Wlogout.sh"), { description = "powermenu" })
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "notification panel" })
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(scriptsDir .. "/RainbowBordersMenu.sh"), { description = "Rainbow borders mode menu" })

-- Master Layout
hl.bind(mainMod .. " + CTRL + D", hl.dsp.layout("removemaster"), { description = "remove master" })
hl.bind(mainMod .. " + I", hl.dsp.layout("addmaster"), { description = "add master" })
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.layout("swapwithmaster"), { description = "swap with master" })

-- Dwindle Layout
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.layout("togglesplit"), { description = "toggle split (dwindle)" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "toggle pseudo (dwindle)" })

-- Works on either layout
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl dispatch splitratio 0.3"), { description = "set split ratio 0.3" })

-- Cycle windows
hl.bind("ALT + Tab", hl.dsp.window.cycle_next(), { description = "cycle next window" })
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top(), { description = "bring active to top" })

-- Special Keys / Hot Keys
hl.bind("", "XF86AudioRaiseVolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --inc"), { description = "volume up", locked = true, repeating = true })
hl.bind("", "XF86AudioLowerVolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --dec"), { description = "volume down", locked = true, repeating = true })
hl.bind("ALT", "XF86AudioRaiseVolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --inc-precise"), { description = "volume up precise", locked = true, repeating = true })
hl.bind("ALT", "XF86AudioLowerVolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --dec-precise"), { description = "volume down precise", locked = true, repeating = true })
hl.bind("", "XF86AudioMicMute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle-mic"), { description = "toggle mic mute", locked = true, repeating = true })
hl.bind("", "XF86AudioMute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle"), { description = "toggle mute", locked = true, repeating = true })
hl.bind("", "XF86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { description = "sleep", locked = true, repeating = true })
hl.bind("", "XF86Rfkill", hl.dsp.exec_cmd(scriptsDir .. "/AirplaneMode.sh"), { description = "airplane mode", locked = true, repeating = true })

-- Media controls
hl.bind("", "XF86AudioPlayPause", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { description = "play/pause", locked = true, repeating = true })
hl.bind("", "XF86AudioPause", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { description = "pause", locked = true, repeating = true })
hl.bind("", "XF86AudioPlay", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { description = "play", locked = true, repeating = true })
hl.bind("", "XF86AudioNext", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --nxt"), { description = "next track", locked = true, repeating = true })
hl.bind("", "XF86AudioPrev", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --prv"), { description = "previous track", locked = true, repeating = true })
hl.bind("", "XF86AudioStop", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --stop"), { description = "stop", locked = true, repeating = true })

-- Screenshot keybindings
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"), { description = "screenshot now" })
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"), { description = "screenshot (area)" })
hl.bind(mainMod .. " + CTRL + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"), { description = "screenshot in 5s" })
hl.bind(mainMod .. " + CTRL + SHIFT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"), { description = "screenshot in 10s" })
hl.bind("ALT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"), { description = "screenshot active window" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --swappy"), { description = "screenshot (swappy)" })

-- Resize windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { description = "resize left (-50)" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { description = "resize right (+50)" })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { description = "resize up (-50)" })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { description = "resize down (+50)" })

-- Move windows
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.move({ direction = "l" }), { description = "move window left" })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "r" }), { description = "move window right" })
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.move({ direction = "u" }), { description = "move window up" })
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.move({ direction = "d" }), { description = "move window down" })

-- Swap windows
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.swap({ direction = "l" }), { description = "swap window left" })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.swap({ direction = "r" }), { description = "swap window right" })
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.swap({ direction = "u" }), { description = "swap window up" })
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.swap({ direction = "d" }), { description = "swap window down" })

-- Group
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "toggle group" })

-- Navigate within a group
hl.bind(mainMod .. " + Tab", hl.dsp.group.next(), { description = "Change Group Forward" })
hl.bind(mainMod .. " + CTRL + tab", hl.dsp.group.next(), { description = "change active in group" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.group.prev(), { description = "Change Group Back" })

-- Move window into/out of group
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ into_group = "l" }), { description = "Move left into group" })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ into_group = "r" }), { description = "Move Right into group" })
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ out_of_group = true }), { description = "Move active out of group" })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "focus right" })
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "focus up" })
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "focus down" })

-- Workspaces related
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }), { description = "next workspace" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), { description = "previous workspace" })

-- Special workspace
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special" }), { description = "move to special workspace" })
hl.bind(mainMod .. " + U", hl.dsp.workspace.toggle_special(), { description = "toggle special workspace" })

-- Switch workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i == 10 and "0" or tostring(i)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "move to workspace " .. i })
    hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = false }), { description = "move silently to workspace " .. i })
end

-- Move active window to a workspace silently
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "-1" }), { description = "move to previous workspace" })
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1" }), { description = "move to next workspace" })
hl.bind(mainMod .. " + CTRL + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = false }), { description = "move silently to previous workspace" })
hl.bind(mainMod .. " + CTRL + bracketright", hl.dsp.window.move({ workspace = "+1", follow = false }), { description = "move silently to next workspace" })

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "next workspace" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "previous workspace" })
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }), { description = "next workspace" })
hl.bind(mainMod .. " + comma", hl.dsp.focus({ workspace = "e-1" }), { description = "previous workspace" })

-- Move/resize windows with mouse dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "move window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "resize window" })
