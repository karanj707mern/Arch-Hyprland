-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  --
-- See https://wiki.hypr.land/Configuring/Basics/Variables/ for more variable settings
-- These configs are mostly for laptops. This is addemdum to Keybinds.lua

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserConfigs = os.getenv("HOME") .. "/.config/hypr/UserConfigs"

local Touchpad_Device = "asue1209:00-04f3:319f-touchpad"

-- for disabling Touchpad. hyprctl devices to get device name.
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --dec"), { description = "decrease keyboard brightness", repeating = true })
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd(scriptsDir .. "/BrightnessKbd.sh --inc"), { description = "increase keyboard brightness", repeating = true })
hl.bind("XF86Launch1", hl.dsp.exec_cmd("rog-control-center"), { description = "ASUS Armory crate button" })
hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl led-mode -n"), { description = "FN+F4 Switch keyboard RGB profile" })
hl.bind("XF86Launch4", hl.dsp.exec_cmd("asusctl profile -n"), { description = "FN+F5 change of fan profiles" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --dec"), { description = "decrease monitor brightness", repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(scriptsDir .. "/Brightness.sh --inc"), { description = "increase monitor brightness", repeating = true })
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd(scriptsDir .. "/TouchPad.sh"), { description = "disable touchpad" })

-- Screenshot keybindings using SUPER+SHIFT+S
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"), { description = "screenshot" })
hl.bind(mainMod .. " + CTRL + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"), { description = "screenshot (area)" })
hl.bind(mainMod .. " + ALT + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in5"), { description = "screenshot (5 secs delay)" })
hl.bind(mainMod .. " + CTRL + ALT + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --in10"), { description = "screenshot (10 secs delay)" })
hl.bind("ALT + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --active"), { description = "screenshot (active window only)" })

-- Device configuration
hl.device({
    name = Touchpad_Device,
    enabled = true,
})
