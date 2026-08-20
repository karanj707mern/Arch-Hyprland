-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  --
-- Commands and Apps to be executed at launch (vendor defaults)

local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserScripts = os.getenv("HOME") .. "/.config/hypr/UserScripts"
local lock = scriptsDir .. "/LockScreen.sh"
local SwwwRandom = UserScripts .. "/WallpaperAutoChange.sh"
local livewallpaper = ""
local wallDIR = os.getenv("HOME") .. "/Pictures/wallpapers"

hl.on("hyprland.start", function()
    -- Wallpaper stuff
    hl.exec_cmd("awww-daemon --format xrgb")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/WallustSwww.sh")

    -- Startup
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/Dropterminal.sh kitty &")
    hl.exec_cmd(scriptsDir .. "/Polkit.sh")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("nm-tray")
    hl.exec_cmd("swaync")
    hl.exec_cmd("waybar")
    hl.exec_cmd("qs -c overview")
    hl.exec_cmd("hypridle")
    hl.exec_cmd(scriptsDir .. "/Hyprsunset.sh init")

    -- Clipboard manager
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("rog-control-center")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("qs")
    hl.exec_cmd(scriptsDir .. "/KeybindsLayoutInit.sh")
end)
