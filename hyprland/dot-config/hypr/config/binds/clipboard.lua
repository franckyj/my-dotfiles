local mainMod = "SUPER"

-- Clipboard bindings are often desktop- or tool-specific; this keeps the direct Hyprland equivalent
-- when a matching raw command exists, and leaves the more Omarchy-specific helpers commented out.
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

-- Omarchy-specific clipboard helpers that do not map directly to a generic Hyprland primitive:
-- hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("omarchy-clipboard-history"))
-- hl.bind(mainMod .. " + CTRL + V", hl.dsp.exec_cmd("omarchy-clipboard-paste"))
