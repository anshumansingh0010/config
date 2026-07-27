hl.config({
    animations = {
        enabled = true,
    },
})

-- Animation curves (matching old bezier names and points)
hl.curve("linear",       { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_decel",    { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("md3_accel",    { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("overshot",     { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("cuzin",        { type = "bezier", points = { { 0.27, 0.06 }, { 0.12, 0.9 } } })
hl.curve("hyprermia",    { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("fluid",        { type = "bezier", points = { { 0, 0.5 }, { 0, 1 } } })
hl.curve("snip",         { type = "bezier", points = { { 0.1, 1 }, { 1, 0.1 } } })

-- Animation configs
hl.animation({ leaf = "windows",      enabled = true, speed = 3, bezier = "overshot",     style = "slide" })
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 3, bezier = "md3_decel",    style = "slide" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 3, bezier = "md3_accel",    style = "slide" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 3, bezier = "md3_standard", style = "slide" })

hl.animation({ leaf = "layers",       enabled = true, speed = 3, bezier = "md3_decel",    style = "slide" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 3, bezier = "cuzin",        style = "slide" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 3, bezier = "cuzin",        style = "slide" })

hl.animation({ leaf = "fade",         enabled = true, speed = 3, bezier = "md3_decel" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3, bezier = "cuzin" })
hl.animation({ leaf = "fadeLayersOut",enabled = true, speed = 3, bezier = "cuzin" })
hl.animation({ leaf = "fadeDim",      enabled = true, speed = 3, bezier = "md3_decel" })

hl.animation({ leaf = "workspaces",   enabled = true, speed = 4, bezier = "hyprermia",   style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 4, bezier = "hyprermia",   style = "slide" })
hl.animation({ leaf = "workspacesOut",enabled = true, speed = 4, bezier = "hyprermia",   style = "slide" })

hl.animation({
    leaf    = "specialWorkspace",
    enabled = true,
    speed   = 4,
    bezier  = "hyprermia",
    style   = "slidefadevert 15%"
})

hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "md3_standard" })
