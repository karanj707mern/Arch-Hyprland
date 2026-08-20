-- /* ---- 💫 https://github.com/Karran-JaKooLit 💫 ---- */  --
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
-- default Monitor config

-- *********************************************************** --
--
-- NOTE: This will be overwritten by NWG-Displays
-- once you use and click apply. You can still find this
-- default at ~/.config/hypr/Monitor_Profiles/default.lua
--
-- *********************************************************** --

-- Monitor Configuration
-- See Hyprland wiki for more details
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.

-- Monitors
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

-- High Refresh Rate
-- hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1 })

-- High Resolution
-- hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })

-- NOTE: for laptop, kindly check notes in Laptops.lua regarding display
-- Created this inorder for the monitor display to not wake up if not intended.
-- See here: https://github.com/hyprwm/Hyprland/issues/4090

-- Some examples to set your own monitor
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })
-- hl.monitor({ output = "DP-3", mode = "1920x1080@240", position = "auto", scale = 1 })
-- hl.monitor({ output = "DP-1", mode = "preferred", position = "auto", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })

-- QEMU-KVM, virtual box or vmware
-- hl.monitor({ output = "Virtual-1", mode = "1920x1080@60", position = "auto", scale = 1 })

-- to disable a monitor
-- hl.monitor({ output = "name", mode = "disable" })

-- Mirror samples
hl.monitor({ output = "DP-3", mode = "1920x1080@60", position = "0x0", scale = 1, mirror = "DP-2" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

-- 10 bit monitor support
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, bitdepth = 10 })

-- hl.monitor({ output = "eDP-1", transform = 0 })
-- hl.monitor({ output = "eDP-1", addreserved = { 10, 10, 10, 49 } })

-- workspaces - Monitor rules
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- SUPER E - Workspace-Rules
-- See ~/.config/hypr/UserConfigs/WorkSpaceRules.lua
