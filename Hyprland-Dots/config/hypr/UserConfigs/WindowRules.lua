-- /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  --
-- For window rules and layerrules
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more

-- Power profile notification overlay
hl.window_rule({
    match = { title = "^power-profile-notify$", class = "^power-profile-notify$" },
    float = true,
    pin = true,
    size = { "320px", "48px" },
})

hl.layer_rule({
    match = { namespace = "^power-profile-notify$" },
    blur = true,
})

-- Glass effect for waybar bars (matches "SummitSplit-glass" theme)
hl.layer_rule({
    match = { namespace = "^top-bar$" },
    blur = true,
})

hl.layer_rule({
    match = { namespace = "^bottom-bar$" },
    blur = true,
})

