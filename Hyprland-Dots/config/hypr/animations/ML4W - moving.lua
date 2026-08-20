-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.5, 0}, {0.99, 0.99} } })
hl.curve("smoothIn", { type = "bezier", points = { {0.5, -0.5}, {0.68, 1.5} } })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "overshot", delay = 5, style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "smoothOut", delay = 3 })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "smoothOut", delay = 3 })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "smoothIn", delay = 4, style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "default", delay = 5 })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "smoothIn", delay = 5 })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1, bezier = "smoothIn", delay = 5 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "default", delay = 6 })
