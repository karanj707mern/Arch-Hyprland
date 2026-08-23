-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  --
-- Decoration Settings

-- Hyprland Wiki Links
-- Animation - https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Decoration - https://wiki.hypr.land/Configuring/Basics/Variables/#decoration

-- Load wallust colors
local colors = require("wallust.colors")

-- Check if border animation is enabled (skip static active_border if so)
local border_state_file = os.getenv("HOME") .. "/.config/hypr/.rainbow_borders_enabled"
local border_anim_enabled = false
local border_file = io.open(border_state_file, "r")
if border_file then
    local mode = border_file:read("*all"):gsub("%s+", "")
    border_file:close()
    if mode ~= "disabled" and mode ~= "" then
        border_anim_enabled = true
    end
end

local active_border_color = colors.color12
if border_anim_enabled then
    active_border_color = "0xff8800ff"  -- placeholder, animation will override immediately
end

hl.config({
    general = {
        border_size = 3,
        gaps_in = 1,
        -- per-side gaps (top/right/bottom/left via named fields)
        -- top/bottom = distinct space between window borders and waybar pills
        gaps_out = { top = 8, bottom = 8 },
        col = {
            active_border = active_border_color,
            inactive_border = colors.color6,
        },
    },
})

hl.config({
    decoration = {
        rounding = 10,
        active_opacity = 0.9,
        inactive_opacity = 0.9,
        fullscreen_opacity = 0.9,
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special = 0.8,
        shadow = {
            enabled = true,
        },
        blur = {
            enabled = true,
            size = 5,
            passes=2,
            new_optimizations = true,
        },
    },
})

hl.config({
    group = {
        col = {
            border_active = colors.color15,
        },
        groupbar = {
            col = {
                active = colors.color0,
            },
        },
    },
})
