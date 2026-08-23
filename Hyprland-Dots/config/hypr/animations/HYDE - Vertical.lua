-- /* ---- 💫 https://github.com/Karran-JaKooLit 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("fluent_decel", { type = "bezier", points = { {0, 0.2}, {0.4, 1} } })
hl.curve("easeOutCirc", { type = "bezier", points = { {0, 0.55}, {0.45, 1} } })
hl.curve("easeOutCubic", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })
hl.curve("easeinoutsine", { type = "bezier", points = { {0.37, 0}, {0.63, 1} } })
            -- Windows
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "easeinoutsine", delay = 1.5, style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "easeOutCubic", delay = 1.5, style = "popin 60%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "easeinoutsine", delay = 1.5, style = "slide" })
            -- Fading
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "fluent_decel", delay = 2.5 })
            -- Layers
hl.animation({ leaf = "layers", enabled = true, speed = 1, bezier = "easeinoutsine", delay = 1.5, style = "popin" })
            -- Workspaces
            -- animation = workspaces, 1, 3, fluent_decel, slidefade 30% # styles: slide, slidevert, fade, slidefade, slidefadevert
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "fluent_decel", delay = 3, style = "slidefadevert 30%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, bezier = "fluent_decel", delay = 2, style = "slidefade 10%" })
