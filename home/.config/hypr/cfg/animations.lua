-- ━━━━━━━━━━━━━━━━ Animations ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/

-- Spring curves — translated from Niri spring physics (damping-ratio=1.0 ≈ critically damped)
-- dampening ≈ 2*sqrt(stiffness) for damping-ratio=1.0
hl.curve("spring_stiff",  { type = "spring", mass = 1, stiffness = 1000, dampening = 63 })
hl.curve("spring_medium", { type = "spring", mass = 1, stiffness = 900,  dampening = 60 })
hl.curve("spring_soft",   { type = "spring", mass = 1, stiffness = 800,  dampening = 57 })
-- config-notification uses damping-ratio=0.6 (slight bounce): reduce dampening proportionally
hl.curve("spring_bouncy", { type = "spring", mass = 1, stiffness = 1200, dampening = 42 })

-- Bezier curves for duration-based animations
hl.curve("ease_out_quad",  { type = "bezier", points = { { 0.25, 0.46 }, { 0.45, 0.94 } } })
hl.curve("ease_out_cubic", { type = "bezier", points = { { 0.215, 0.61 }, { 0.355, 1.0 } } })
-- Upstream's default "quick" curve — used only as the global fallback below
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Global fallback base speed for any leaf not explicitly set above (upstream default)
hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "quick" })

-- Workspace switch — Niri: spring stiffness=1000
hl.animation({ leaf = "workspaces",    enabled = true, speed = 4, spring = "spring_stiff" })
-- Workspace entry/exit — Niri: horizontal-view-movement spring stiffness=900
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 4, spring = "spring_medium" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4, spring = "spring_medium" })

-- Window open/close — Niri: 200ms ease-out-quad / ease-out-cubic
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 2, bezier = "ease_out_quad",  style = "popin 80%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, bezier = "ease_out_cubic", style = "popin 80%" })

-- Window movement/resize — Niri: spring stiffness=800/1000
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, spring = "spring_soft" })

-- Layers (panels, notifications) — Niri config-notification: spring stiffness=1200 bouncy
hl.animation({ leaf = "layers",      enabled = true, speed = 3, spring = "spring_bouncy", style = "slide" })

-- Fade
hl.animation({ leaf = "fade",        enabled = true, speed = 2, bezier = "ease_out_quad" })

-- Border
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "ease_out_quad" })
