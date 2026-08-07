-- ▔▔▔▔▔▔▔▔▔▔▔▔▔▔ Startup Applications ▔▔▔▔▔▔▔▔▔▔▔▔▔▔
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- Prevents stale env for systemd user services / XDG portals.
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")

    -- Noctalia
    hl.exec_cmd("noctalia")

    -- Clipboard history daemon: captures everything copied into cliphist's store.
    -- Requires wl-clipboard (already in CachyOS Hyprland ISO) and cliphist.
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
