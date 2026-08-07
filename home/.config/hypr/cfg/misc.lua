-- ━━━━━━━━━━━━━━━━ Miscellaneous ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Variables/

hl.config({
    dwindle = {
        -- pseudotile     = false,
        preserve_split = true,
    },
    binds = {
        -- Niri: workspace-auto-back-and-forth
        -- Pressing the current workspace number again returns to the previous one.
        workspace_back_and_forth = true,
    },
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        -- Allows Noctalia notification actions to activate/raise windows.
        -- Closest equivalent to Niri's honor-xdg-activation-with-invalid-serial.
        focus_on_activate        = false,
        -- Swallow the launching terminal window when it spawns a GUI app.
        enable_swallow = true,
        swallow_regex  = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
    },
    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },
    xwayland = {
        -- Fixes blurry XWayland apps under the laptop panel's 1.5x scale.
        force_zero_scaling = true,
    },
})
