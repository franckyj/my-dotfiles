local terminal    = "foot"
local fileManager = "thunar"
local menu        = "noctalia msg panel-toggle launcher"
local wallpaper   = "noctalia msg panel-toggle launcher /wall"
local mainMod     = "SUPER"

-- Applications
hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("brave-browser"))
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd("brave-browser"))
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd(menu))

-- Launchers
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(wallpaper))

-- Screenshots
hl.bind("Print",                   hl.dsp.exec_cmd("grim - | tee ~/stuff/screenshots/$(date +%s).png | wl-copy"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | tee ~/stuff/screenshots/$(date +%s).png | wl-copy"))

-- Lockscreen
hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))
