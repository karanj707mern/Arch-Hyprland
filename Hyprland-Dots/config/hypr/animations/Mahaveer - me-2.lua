-- /* ---- 💫 https://github.com/karanj707mern 💫 ---- */  --
-- JaKooLit-Arch-Dots-Luafied-by-Karran-Patel

hl.config({
    animations = {
        enabled = true,
    }
})

hl.curve("wind", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn", { type = "bezier", points = { {0.1, 1.1}, {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("liner", { type = "bezier", points = { {1, 1}, {1, 1} } })
hl.curve("overshot", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("smoothOut", { type = "bezier", points = { {0.5, 0}, {0.99, 0.99} } })
hl.curve("smoothIn", { type = "bezier", points = { {0.5, -0.5}, {0.68, 1.5} } })
hl.animation({ leaf = "windows", enabled = true, speed = 1, bezier = "wind", delay = 6, style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, bezier = "winIn", delay = 5, style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "smoothOut", delay = 3, style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "wind", delay = 5, style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 1, bezier = "liner", delay = 180, loop = true })
hl.animation({ leaf = "fade", enabled = true, speed = 1, bezier = "smoothOut", delay = 3 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "overshot", delay = 5 })
            -- animations for -git or version >0.42.0
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1, bezier = "winIn", delay = 5, style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1, bezier = "winOut", delay = 5, style = "slide" })
