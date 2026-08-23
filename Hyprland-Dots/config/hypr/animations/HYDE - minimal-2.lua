-- /* ---- 💫 https://github.com/Karran-JaKooLit 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("quart", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "quart", delay = 6, style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "quart", delay = 6 })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "quart", delay = 6 })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "quart", delay = 6 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "quart", delay = 6 })
