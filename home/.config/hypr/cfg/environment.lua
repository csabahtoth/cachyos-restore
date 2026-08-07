-- ━━━━━━━━━━━━━━━━ Environment Variables ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- ━━━━━ Wayland toolkit backends ━━━━━
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM",                    "wayland;xcb")
-- gtk3: Qt apps follow the adw-gtk3-dark GTK theme set in dconf,
-- matching the original Niri config and keeping all apps visually consistent.
hl.env("QT_QPA_PLATFORMTHEME",               "gtk3")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- ━━━━━ XDG session ━━━━━
hl.env("XDG_CURRENT_DESKTOP",  "Hyprland")
hl.env("XDG_SESSION_TYPE",     "wayland")
hl.env("XDG_SESSION_DESKTOP",  "Hyprland")

-- ━━━━━ Cursor ━━━━━
-- XCURSOR_* covers X11/XWayland apps and anything not hyprcursor-aware.
hl.env("XCURSOR_THEME", "capitaine-cursors")
hl.env("XCURSOR_SIZE",  "24")
-- HYPRCURSOR_* is read by native hyprcursor-aware apps (Hyprland itself,
-- GTK4/Qt6 apps built against recent hyprcursor support). capitaine-cursors
-- ships no native .hlc theme, so it was being raster-upscaled under the
-- laptop panel's 1.5x scale; capitaine-cursors-hypr is a converted copy
-- (via hyprcursor-util --extract/--create from the capitaine-cursors
-- XCursor theme) installed at ~/.local/share/icons/capitaine-cursors-hypr.
hl.env("HYPRCURSOR_THEME", "capitaine-cursors-hypr")
hl.env("HYPRCURSOR_SIZE",  "24")
