-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  --
-- Hyprland Lua Configuration
-- Refer to the wiki for more information: https://wiki.hypr.land/Configuring/Start/

-- Load wallust colors
local colors = require("wallust.colors")

-- Variables
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserScripts = os.getenv("HOME") .. "/.config/hypr/UserScripts"
local UserConfigs = os.getenv("HOME") .. "/.config/hypr/UserConfigs"
local mainMod = "SUPER"
local term = "kitty"
local files = "thunar"

-- Environment Variables
hl.env("DOTS_VERSION", "2.3.20")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Editor
hl.env("EDITOR", "nano")
local edit = os.getenv("EDITOR") or "nano"

-- Search Engine
local Search_Engine = "https://www.google.com/search?q={}"

-- Monitors
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- Initial boot script
hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/initial-boot.sh")
end)

-- Source external configs
require("configs.Keybinds")
require("configs.Startup_Apps")
require("configs.ENVariables")
require("configs.Laptops")
require("configs.WindowRules")
require("configs.SystemSettings")
require("application-style")
require("UserConfigs.UserDecorations")
require("UserConfigs.UserAnimations")
require("animations.00-default")
require("UserConfigs.UserKeybinds")
require("UserConfigs.UserSettings")
require("UserConfigs.01-UserDefaults")
require("UserConfigs.Startup_Apps")
require("UserConfigs.ENVariables")
require("UserConfigs.Laptops")
require("UserConfigs.LaptopDisplay")
require("UserConfigs.WindowRules")
require("monitors")
require("workspaces")

-- Load user animation preset if present (written by Animations.sh)
hl.exec_cmd("source = " .. UserConfigs .. "/UserAnimations.conf")
