-- ━━━━━━━━━━━━━━━━ Decorations Configuration ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Variables/

hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 2,
        layout           = "dwindle",
        border_size      = 2,
        resize_on_border = true,
        col = {
            active_border = PRIMARY,
            inactive_border = SURFACE,
        },
    },
    group = {
        col = {
            border_active = SECONDARY,
            border_inactive = SURFACE,
            border_locked_active = ERROR,
            border_locked_inactive = SURFACE,
        },
        groupbar = {
            col = {
                active = SECONDARY,
                inactive = SURFACE,
                locked_active = ERROR,
                locked_inactive = SURFACE,
            },
        },
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },
})
