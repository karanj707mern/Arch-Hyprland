-- /* ---- 💫 https://github.com/Karran-JaKooLit 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

            -- Animation curves
hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })
            -- bezier = linear, 0, 0, 1, 1
hl.curve("md3_standard", { type = "bezier", points = { {0.2, 0}, {0, 1} } })
hl.curve("md3_decel", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("md3_accel", { type = "bezier", points = { {0.3, 0}, {0.8, 0.15} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.1} } })
hl.curve("crazyshot", { type = "bezier", points = { {0.1, 1.5}, {0.76, 0.92} } })
hl.curve("hyprnostretch", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.0} } })
hl.curve("menu_decel", { type = "bezier", points = { {0.1, 1}, {0, 1} } })
hl.curve("menu_accel", { type = "bezier", points = { {0.38, 0.04}, {1, 0.07} } })
hl.curve("easeInOutCirc", { type = "bezier", points = { {0.85, 0}, {0.15, 1} } })
hl.curve("easeOutCirc", { type = "bezier", points = { {0, 0.55}, {0.45, 1} } })
hl.curve("easeOutExpo", { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })
hl.curve("softAcDecel", { type = "bezier", points = { {0.26, 0.26}, {0.15, 1} } })
hl.curve("md2", { type = "bezier", points = { {0.4, 0}, {0.2, 1} } })
            -- Animation configs
            -- animation = windows, 1, 3, md3_decel, popin 60%
            -- animation = windowsIn, 1, 3, md3_decel, popin 60%
            -- animation = windowsOut, 1, 3, md3_accel, popin 60%
            -- animation = windows, 1, 6, wind, slide
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "liner", delay = 30, loop = false })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "wind", delay = 6, style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "winIn", delay = 6, style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "winOut", delay = 5, style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "wind", delay = 5, style = "slide" })
            -- animation = border, 1, 10, default
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "md3_decel", delay = 3 })
            -- animation = layers, 1, 2, md3_decel, slide
hl.animation({ leaf = "layersIn", enabled = true, speed = 1, bezier = "menu_decel", delay = 3, style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "menu_accel", delay = 1.6 })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1, bezier = "menu_decel", delay = 2 })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "menu_accel", delay = 4.5 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "menu_decel", delay = 7, style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "wind", delay = 5 })
            -- animation = workspaces, 1, 2.5, softAcDecel, slide
            -- animation = workspaces, 1, 7, menu_decel, slidefade 15%
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, bezier = "md3_decel", delay = 3, style = "slidefadevert 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, bezier = "md3_decel", delay = 3, style = "slidevert" })
