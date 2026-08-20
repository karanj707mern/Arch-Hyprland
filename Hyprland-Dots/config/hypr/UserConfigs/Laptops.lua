-- /* ---- 💫 https://github.com/Karran-JaKooLit 💫 ---- */  --
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
-- See https://wiki.hypr.land/Configuring/Basics/Variables/ for more variable settings
-- These configs are mostly for laptops. This is addemdum to Keybinds.lua

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserConfigs = os.getenv("HOME") .. "/.config/hypr/UserConfigs"

-- Below are useful when you are connecting your laptop in external display
-- Suggest you edit below for your laptop display
-- From WIKI This is to disable laptop monitor when lid is closed.
-- consult https://wiki.hypr.land/Configuring/Basics/Binds/#switches
-- hl.bind("", "switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl keyword monitor \"eDP-1, preferred, auto, 1\""), { description = "Lid closed" })
-- hl.bind("", "switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl keyword monitor \"eDP-1, disable\""), { description = "Lid opened" })

-- WARNING! Using this method has some caveats!! USE THIS PART WITH SOME CAUTION!
-- CONS of doing this, is that you need to set up your wallpaper (SUPER W) and choose wallpaper.
-- CAVEATS! Sometimes the Main Laptop Monitor DOES NOT have display that it needs to re-connect your external monitor
-- One work around is to ensure that before shutting down laptop, MAKE SURE your laptop lid is OPEN!!
-- Make sure to comment (put # on the both the bindl = , switch ......) above
-- NOTE: Display for laptop are being generated into LaptopDisplay.lua
-- This part is to be use if you do not want your main laptop monitor to wake up during say wallpaper change etc

-- hl.bind("", "switch:off:Lid Switch", hl.dsp.exec_cmd("echo \"monitor = eDP-1, preferred, auto, 1\" > " .. UserConfigs .. "/LaptopDisplay.lua"), { description = "Lid closed" })
-- hl.bind("", "switch:on:Lid Switch", hl.dsp.exec_cmd("echo \"monitor = eDP-1, disable\" > " .. UserConfigs .. "/LaptopDisplay.lua"), { description = "Lid opened" })

-- for laptop-lid action (to erase the last entry)
-- hl.exec_once("echo \"monitor = eDP-1, preferred, auto, 1\" > " .. os.getenv("HOME") .. "/.config/hypr/UserConfigs/LaptopDisplay.lua")
