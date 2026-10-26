-- Hyprland default apps

local TERMINAL     = "foot"
local FILE_MANAGER = "thunar"
local BROWSER      = "brave-browser"
local EDITOR       = "hx"

local mainMod       = "SUPER"
local noctCall      = "noctalia msg "
local launchPrefix  = "uwsm app -- " -- if you are not using UWSM, make this empty (e.g. "")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + S",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }))
-- hl.bind(mainMod .. " + M",           hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + X",   hl.dsp.exec_cmd(noctCall .. "session lock"))

-- Change focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
-- Focus (vim-style)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))

hl.bind("ALT + Tab",           hl.dsp.window.cycle_next())

-- Move active window around current workspace
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CONTROL + SHIFT + left",  hl.dsp.window.move({ workspace = "r-1" }))

-- hl.bind(mainMod .. " + CONTROL + right",       hl.dsp.focus({ workspace = "r+1" }))
-- hl.bind(mainMod .. " + CONTROL + left",        hl.dsp.focus({ workspace = "r-1" }))
-- hl.bind(mainMod .. " + CONTROL + down",        hl.dsp.focus({ workspace = "empty" }))

-- Resize (super+alt+h/j/k/l)
hl.bind(mainMod .. " + ALT + h", hl.dsp.layout("colresize -conf"), { repeating = true })
-- hl.bind(mainMod .. " + ALT + j", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 20"), { repeating = true })
-- hl.bind(mainMod .. " + ALT + k", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -20"), { repeating = true })
hl.bind(mainMod .. " + ALT + l", hl.dsp.layout("colresize +conf"), { repeating = true })
hl.bind(mainMod .. " + ALT + left", hl.dsp.layout("colresize -conf"), { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.layout("colresize +conf"), { repeating = true })

-- -- Move floating window (super+shift+arrows)
-- hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.exec_cmd("hyprctl dispatch moveactive -20 0"), { repeating = true })
-- hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 20"), { repeating = true })
-- hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.exec_cmd("hyprctl dispatch moveactive 0 -20"), { repeating = true })
-- hl.bind(mainMod .. " + SHIFT + right", hl.dsp.exec_cmd("hyprctl dispatch moveactive 20 0"), { repeating = true })

-- Move & Resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Special workspace (scratchpad)
--hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special" }))
--hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special())

--------------------
---- WORKSPACES ----
--------------------

-- Focus workspaces by number (1-9, 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }))
    hl.bind(mainMod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Cycle workspaces (previous/next)
hl.bind(mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { mouse = true })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { mouse = true })

-- Focus last workspace
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

------------------
---- LAUNCHER ----
------------------

hl.bind(mainMod .. " + return",     hl.dsp.exec_cmd(launchPrefix .. TERMINAL))
hl.bind(mainMod .. " + e",          hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER))
hl.bind(mainMod .. " + t",          hl.dsp.exec_cmd(launchPrefix .. EDITOR))
-- hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(launchPrefix .. CALCULATOR))
hl.bind(mainMod .. " + w",          hl.dsp.exec_cmd(launchPrefix .. BROWSER))
hl.bind("CONTROL + SHIFT + escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"))

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"),    { locked = true, repeating = true })

-- Media
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctCall .. "media next"),   { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctCall .. "brightness-up"),     { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"),   { repeating = true })

------------------
---- PANELS ----
------------------

-- Control Center
hl.bind(mainMod .. " + SHIFT + c", hl.dsp.exec_cmd(noctCall .. "panel-toggle session"))
hl.bind(mainMod .. " + x",         hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"))
hl.bind(mainMod .. " + a",         hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center notifications"))

-- Launcher
hl.bind(mainMod .. " + space",     hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"))
hl.bind(mainMod .. " + period",    hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher /emo"))

-- Clipboard
hl.bind(mainMod .. " + v", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"))

-- Wallpaper
hl.bind(mainMod .. " + SHIFT + w", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"))

-- Settings
hl.bind(mainMod .. " + z", hl.dsp.exec_cmd(noctCall .. "settings-toggle"))

-------------------
---- UTILITIES ----
-------------------

-- Screen Capture (Noctalia built-in — settings in [shell.screenshot])
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(noctCall .. "screenshot-region"))
hl.bind("Print",                   hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"))
hl.bind(mainMod .. " + Print",     hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen pick"))

-----------------------
---- NOTIFICATIONS ----
-----------------------
-- Note: Notifications are accessed via SUPER + A (see Panel section above)
