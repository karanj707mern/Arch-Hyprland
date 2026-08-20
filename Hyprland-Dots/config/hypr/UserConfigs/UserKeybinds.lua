-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
# JaKooLit-Arch-Dots-Luafied-by-Karran-Patel
-- This is where you put your own keybinds. Be Mindful to check as well ~/.config/hypr/configs/Keybinds.lua to avoid conflict
-- if you think I should replace the Pre-defined Keybinds in ~/.config/hypr/configs/Keybinds.lua , submit an issue or let me know in DC and present me a valid reason as to why, such as conflicting with global shortcuts, etc etc

-- See https://wiki.hypr.land/Configuring/Basics/Variables/ for more settings and variables
-- See also Laptops.lua for laptops keybinds

local mainMod = "SUPER"
local scriptsDir = os.getenv("HOME") .. "/.config/hypr/scripts"
local UserScripts = os.getenv("HOME") .. "/.config/hypr/UserScripts"
local UserConfigs = os.getenv("HOME") .. "/.config/hypr/UserConfigs"

--  IMPORTANT: If you want to remap and existing keybind you MUST unbind it first
-- The bindings are CASE SENSITIVE. We suggest you copy the existing binding here
-- Then change `bindd` to `unbind`

-- E.g.
-- hl.unbind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
-- hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ghostty"), { description = "Open terminal" })

-- If you are ADDING a bind, make sure you include the description
-- Other the keybind search menu might not show it properly

-- E.g.
-- hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("myapp"), { description = "My z app" })

-- For passthrough keyboard into a VM
-- hl.bind(mainMod .. " + ALT + P", hl.dsp.submap("passthru"), { description = "submap" })
-- hl.submap("passthru")
-- to unbind
-- hl.submap("reset")

-- AI Assistant Keybinds
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("code"), { description = "Open VS Code" })
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(scriptsDir .. "/AI_Assistant.sh --menu"), { description = "AI Assistant menu" })
hl.bind(mainMod .. " + SHIFT + Y", hl.dsp.exec_cmd(scriptsDir .. "/AI_Sidebar_Toggle.sh"), { description = "Toggle AI Sidebar" })
