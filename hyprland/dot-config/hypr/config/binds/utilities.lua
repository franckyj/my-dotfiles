local mainMod = "SUPER"

-- Application and top-level menus
-- hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("rofi -show drun"))
-- hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("rofi -show window"))

-- System and session utilities
-- hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))
-- hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd("wlogout"))

-- Notification / tray related actions
-- hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("dunstctl close"))
-- hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.exec_cmd("dunstctl close-all"))

-- Monitor and layout toggles
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Theme / background helpers
-- hl.bind(mainMod .. " + CTRL + SPACE", hl.dsp.exec_cmd("~/.config/hypr/scripts/background-switcher.sh"))
-- hl.bind(mainMod .. " + SHIFT + CTRL + SPACE", hl.dsp.exec_cmd("~/.config/hypr/scripts/theme-switcher.sh"))

-- Generic utility commands without Omarchy wrapper
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
