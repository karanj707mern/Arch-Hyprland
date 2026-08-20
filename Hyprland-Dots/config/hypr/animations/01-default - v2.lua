-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("linear", { type = "bezier", points = { {0.0, 0.0}, {1.0, 1.0} } })
hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("slow", { type = "bezier", points = { {0, 0.85}, {0.3, 1} } })
hl.curve("overshot", { type = "bezier", points = { {0.7, 0.6}, {0.1, 1.1} } })
hl.curve("bounce", { type = "bezier", points = { {1.1, 1.6}, {0.1, 0.85} } })
hl.curve("sligshot", { type = "bezier", points = { {1, -1}, {0.15, 1.25} } })
hl.curve("nice", { type = "bezier", points = { {0, 6.9}, {0.5, -4.20} } })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "slow", delay = 5, style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "winOut", delay = 5, style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "wind", delay = 5, style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "linear", delay = 10 })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "linear", delay = 180, loop = true })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "overshot", delay = 5 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "wind", delay = 5 })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "bounce", delay = 5, style = "popin" })
