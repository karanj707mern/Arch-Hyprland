-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "myBezier", delay = 7 })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "default", delay = 7, style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "default", delay = 10 })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "default", delay = 8 })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "default", delay = 7 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "default", delay = 6 })
