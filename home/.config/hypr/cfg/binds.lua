-- ━━━━━━━━━━━━━━━━━━━━ Keybindings ━━━━━━━━━━━━━━━━━━━━
-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- https://docs.noctalia.dev/v5/ipc/

local ipc = "noctalia msg"

-- 1. Applications

hl.bind("SUPER + Space", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"), { description = "Toggle App Launcher" })
hl.bind("SUPER + T", hl.dsp.exec_cmd(TERMINAL), { description = "Open Terminal: Ghostty" })
hl.bind("SUPER + B", hl.dsp.exec_cmd(BROWSER), { description = "Open Browser: Helium" })
hl.bind("SUPER + F", hl.dsp.exec_cmd(FILE_MANAGER), { description = "File Manager: Nautilus" })

-- 2. System / Shell UI

hl.bind("SUPER + S", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"), { description = "Toggle Control Center" })
hl.bind("SUPER + comma", hl.dsp.exec_cmd(ipc .. " settings-toggle"), { description = "Toggle Settings" })
hl.bind("SUPER + N", hl.dsp.exec_cmd(ipc .. " panel-toggle noctalia/notes:panel"), { description = "Toggle Notes Panel" })
hl.bind("SUPER + V", hl.dsp.exec_cmd(ipc .. " panel-toggle clipboard"), { description = "Toggle Clipboard History" })
hl.bind("SUPER + XF86AudioMute", hl.dsp.exec_cmd(ipc .. " panel-toggle blackbartblues/keymap:panel"), { description = "Keybinds Cheatsheet" })

-- 3. Session / Power

hl.bind("SUPER + Escape", hl.dsp.exec_cmd(ipc .. " session lock"), { description = "Lock Session" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.exec_cmd(ipc .. " panel-toggle session"), { description = "Session Menu: Noctalia" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exit(), { description = "Exit Hyprland" })
-- uwsm users: replace exit() with exec_cmd("loginctl terminate-user \"\"")

-- hl.bind("SUPER + SHIFT + P", hl.dsp.dpms({ action = "disable" }))

-- 4. Media & Volume

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"), { description = "Volume Up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"), { description = "Volume Down" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"), { description = "Mute Volume" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. " mic-mute"), { description = "Mute/Unmute Microphone" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. " media next"), { description = "Next Track" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. " media previous"), { description = "Previous Track" })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. " media toggle"), { description = "Play/Pause Media" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. " media toggle"), { description = "Play/Pause Media" })

-- 5. Display

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"), { description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"), { description = "Brightness Down" })

-- 6. Window Focus

hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close Window" })

hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }), { description = "Focus Window Left (Arrow Keys)" })
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }), { description = "Focus Window Right (Arrow Keys)" })
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }), { description = "Focus Window Up (Arrow Keys)" })
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }), { description = "Focus Window Down (Arrow Keys)" })

-- 7. Window Movement

hl.bind("SUPER + CTRL + Left", hl.dsp.window.move({ direction = "l" }), { description = "Move Window Left (Arrow Keys)" })
hl.bind("SUPER + CTRL + Right", hl.dsp.window.move({ direction = "r" }), { description = "Move Window Right (Arrow Keys)" })
hl.bind("SUPER + CTRL + Up", hl.dsp.window.move({ direction = "u" }), { description = "Move Window Up (Arrow Keys)" })
hl.bind("SUPER + CTRL + Down", hl.dsp.window.move({ direction = "d" }), { description = "Move Window Down (Arrow Keys)" })

-- 8. Monitor Focus

hl.bind("SUPER + SHIFT + Left", hl.dsp.focus({ monitor = "l" }), { description = "Focus Monitor Left" })
hl.bind("SUPER + SHIFT + Right", hl.dsp.focus({ monitor = "r" }), { description = "Focus Monitor Right" })
hl.bind("SUPER + SHIFT + Up", hl.dsp.focus({ monitor = "u" }), { description = "Focus Monitor Up" })
hl.bind("SUPER + SHIFT + Down", hl.dsp.focus({ monitor = "d" }), { description = "Focus Monitor Down" })

-- 9. Move Window to Monitor

hl.bind("SUPER + SHIFT + CTRL + Left", hl.dsp.window.move({ monitor = "l", follow = true }), { description = "Move Window to Monitor Left" })
hl.bind("SUPER + SHIFT + CTRL + Right", hl.dsp.window.move({ monitor = "r", follow = true }), { description = "Move Window to Monitor Right" })
hl.bind("SUPER + SHIFT + CTRL + Up", hl.dsp.window.move({ monitor = "u", follow = true }), { description = "Move Window to Monitor Up" })
hl.bind("SUPER + SHIFT + CTRL + Down", hl.dsp.window.move({ monitor = "d", follow = true }), { description = "Move Window to Monitor Down" })

-- 10. Workspace Switching

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "+1" }), { description = "Next Workspace" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "-1" }), { description = "Previous Workspace" })

hl.bind("SUPER + CTRL + mouse_down", hl.dsp.window.move({ workspace = "+1", follow = true }), { description = "Move Window to Next Workspace" })
hl.bind("SUPER + CTRL + mouse_up", hl.dsp.window.move({ workspace = "-1", follow = true }), { description = "Move Window to Previous Workspace" })

for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }), { description = "Switch to Workspace " .. i })
    hl.bind("SUPER + CTRL + " .. i, hl.dsp.window.move({ workspace = i, follow = true }), { description = "Move Window to Workspace " .. i })
end

hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }), { description = "Switch to Previous Workspace" })

-- 11. Layout Controls

-- Expand to full width (closest Hyprland equivalent: maximize toggle)
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Toggle Maximize Window" })

-- Center floating window
hl.bind("SUPER + C", hl.dsp.window.center(), { description = "Center Floating Window" })

-- Resize active window (Niri: set-column-width / set-window-height ±10%)
hl.bind("SUPER + MINUS", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true, description = "Shrink Window Width" })
hl.bind("SUPER + EQUAL", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true, description = "Grow Window Width" })
hl.bind("SUPER + SHIFT + MINUS", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true, description = "Shrink Window Height" })
hl.bind("SUPER + SHIFT + EQUAL", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true, description = "Grow Window Height" })

-- 12. Window Modes

hl.bind("SUPER + O", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating Mode" })
hl.bind("SUPER + I", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Toggle Fullscreen" })
hl.bind("SUPER + W", hl.dsp.group.toggle(), { description = "Toggle Window Group (Tabbed)" }) -- tabbed/grouped display (Niri: toggle-column-tabbed-display)

-- 13. Screenshots & Color Picker

hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Pick Color (Copy to Clipboard)" })
hl.bind("Print", hl.dsp.exec_cmd(ipc .. " screenshot-region"), { description = "Screenshot: Region" })
hl.bind("SUPER + Print", hl.dsp.exec_cmd(ipc .. " screenshot-fullscreen"), { description = "Screenshot: Fullscreen" })

-- 14. Mouse Binds for Floating Windows

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Drag Floating Window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize Floating Window" })
