-- ━━━━━━━━━━━━━━━━ Window & Layer Rules ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- ━━━━━ Generic ━━━━━

-- Generic floating position
hl.window_rule({ match = { float = true }, center = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    keep_aspect_ratio = true,
    size              = { "max(monitor_w, monitor_h)*0.25", "min(monitor_w, monitor_h)*0.25" },
    pin               = true,
})

-- Ignore maximize requests from all apps.
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- ━━━━━ Float Utility Windows ━━━━━
local floatApps = {
    { class = "^(org.pulseaudio.pavucontrol)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

-- ━━━━━ Float Common Modals ━━━━━
local modalMatches = {
    { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
    { initial_title = "^(Open File)$" },
    { class = "^([Xx]dg-desktop-portal-gtk)$" },
    { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
    { class = "^(.*dialog.*)$" },
    { title = "^(.*dialog.*)$" },
    { class = "^(hyprland-share-picker)$"},
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

-- ━━━━━ Noctalia settings window ━━━━━
hl.window_rule({ match = { class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, float = true, size = { "monitor_w*0.70", "monitor_h*0.70" } })

-- ━━━━━ Steam ━━━━━
-- Float all Steam windows except the main client
hl.window_rule({
    match = { class = "steam", title = "negative:^[Ss]team$" },
    float = true,
})

-- Steam notification toasts: float, no focus, bottom-right corner
hl.window_rule({
    match            = { class = "steam", title = "^notificationtoasts_[0-9]+_desktop$" },
    float            = true,
    no_initial_focus = true,
    move             = { "monitor_w-window_w-10", "monitor_h-window_h-10" },
})

-- ━━━━━ Noctalia layer rules ━━━━━
-- Wallpaper sits behind everything (Niri: place-within-backdrop true)
hl.layer_rule({
    match = { namespace = "^noctalia-wallpaper" },
    order = -999,
})

-- Bar, panels, and popups get blur (matches Noctalia Hyprland docs)
hl.layer_rule({
    match        = { namespace = "^noctalia-background-" },
    blur         = true,
    blur_popups  = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
    },
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})
