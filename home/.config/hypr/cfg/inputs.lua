-- ━━━━━━━━━━━━━━━━ Input Configuration ━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    input = {
        kb_layout = "gb",

        numlock_by_default = true,

        -- 1 = cursor movement always changes focus (focus-follows-mouse)
        follow_mouse = 1,

        touchpad = {
            tap_to_click = true,
            natural_scroll = true,

            -- If you want to disable touchpad acceleration, uncomment:
            -- disable_while_typing = true,
        },

        -- If you want to disable mouse acceleration, uncomment:
        -- accel_profile = "flat",
        -- sensitivity = 0.0,
    },
    cursor = {
        no_hardware_cursors = 1,
    },
})
