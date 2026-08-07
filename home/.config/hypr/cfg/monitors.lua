-- ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪ Output Configuration ▪▪▪▪▪▪▪▪▪▪▪▪▪▪▪
-- Run `hyprctl monitors all` to get the correct name for your displays.
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Fallback rule: auto-place any monitor not explicitly configured
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

--# hyprland monitor configuration

-- Only the laptop panel has a shipped ICC profile; MONITOR2/3 have none to reference.
hl.monitor({ output = MONITOR1, mode = "2880x1920@120", position = "0x0", scale = 1.5, icc = "/home/csaba/BOE0CB4.icm"})
hl.monitor({ output = MONITOR2, mode = "3840x2160@60", position = "1920x-320", scale = 1.5, transform = 1})
hl.monitor({ output = MONITOR3, mode = "1920x1080@60", position = "1920x-320", scale = 1, transform = 1})


-- Uncomment and edit to configure a specific display:
-- hl.monitor({
--     output = "DP-1",
--     mode = "2560x1440@360",
--     position = "0x0",
--     scale = 1,
-- })
