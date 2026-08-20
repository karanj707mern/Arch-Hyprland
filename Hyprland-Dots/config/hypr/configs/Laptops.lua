-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  --
-- See https://wiki.hypr.land/Configuring/Basics/Variables/ for more variable settings
-- These configs are mostly for laptops. This is addemdum to Keybinds.lua

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserConfigs = os.getenv("HOME") .. "/.config/hypr/UserConfigs"

local Touchpad_Device = "asue1209:00-04f3:319f-touchpad"

-- for disabling Touchpad. hyprctl devices to get device name.
hl.bind("", "XF86KbdBrightnessDown", function() hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --dec")) end, { description = "decrease keyboard brightness", repeating = true })
hl.bind("", "XF86KbdBrightnessUp", function() hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --inc")) end, { description = "increase keyboard brightness", repeating = true })
hl.bind("", "XF86Launch1", function() hl.dispatch(hl.dsp.exec_cmd("rog-control-center")) end, { description = "ASUS Armory crate button" })
hl.bind("", "XF86Launch3", function() hl.dispatch(hl.dsp.exec_cmd("asusctl led-mode -n")) end, { description = "FN+F4 Switch keyboard RGB profile" })
hl.bind("", "XF86Launch4", function() hl.dispatch(hl.dsp.exec_cmd("asusctl profile -n")) end, { description = "FN+F5 change of fan profiles" })
hl.bind("", "XF86MonBrightnessDown", function() hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --dec")) end, { description = "decrease monitor brightness", repeating = true })
hl.bind("", "XF86MonBrightnessUp", function() hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --inc")) end, { description = "increase monitor brightness", repeating = true })
hl.bind("", "XF86TouchpadToggle", function() hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/TouchPad.sh")) end, { description = "disable touchpad" })

-- Screenshot keybindings using SUPER+SHIFT+S
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"), { description = "screenshot" })
hl.bind(mainMod .. " + CTRL + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"), { description = "screenshot (area)" })
hl.bind(mainMod .. " + ALT + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"), { description = "screenshot (5 secs delay)" })
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"), { description = "screenshot (10 secs delay)" })
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"), { description = "screenshot (active window only)" })

-- Screenshot keybindings using F6 (no PrintSrc button)
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"), { description = "screenshot" })
hl.bind(mainMod .. " + SHIFT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"), { description = "screenshot (area)" })
hl.bind(mainMod .. " + CTRL + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"), { description = "screenshot (5 secs delay)" })
hl.bind(mainMod .. " + ALT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"), { description = "screenshot (10 secs delay)" })
hl.bind("ALT + F6", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"), { description = "screenshot (active window only)" })

-- Device configuration
hl.device({
    name = Touchpad_Device,
    enabled = true,
})
