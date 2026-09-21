o.window(".*", { suppress_event = "maximize" })

-- Tag all windows for default opacity (apps can override with -default-opacity tag).
o.window(".*", { tag = "+default-opacity" })


hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

-- hl.window_rule({
--   name  = "move-hyprland-run",
--   match = { class = "hyprland-run" },
--   move  = "20 monitor_h-120",
--   float = true,
-- })

-- Smart Gaps (commented out - uncomment if desired)
-- hl.window_rule({
--   name  = "no-gaps-wtv1",
--   match = { float = false, workspace = "w[tv1]" },
--   border_size = 0,
--   rounding    = 0,
-- })
-- hl.window_rule({
--   name  = "no-gaps-f1",
--   match = { float = false, workspace = "f[1]" },
--   border_size = 0,
--   rounding    = 0,
-- })

-- system window rules
o.window("xdg-desktop-portal-gtk", { tag = "+floating-window" })

-- define terminal tag so themes and bindings can single terminals out. Omarchy
-- launches TUIs and its own terminal windows under dedicated app-ids
-- (org.omarchy.btop, org.omarchy.terminal, TUI.float, ...), so match those too.
-- the class is matched in full, so foot's other app-id needs spelling out.
o.window(
  "(Alacritty|kitty|com.mitchellh.ghostty|foot|org\\.codeberg\\.dnkl\\.foot|wezterm|org\\.omarchy\\..*|TUI\\..*)",
  { tag = "+terminal" }
)

-- browser tags and styling.
o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })
o.window({ tag = "chromium-based-browser" }, { tag = "-default-opacity", tile = true, opacity = "1.0 0.985" })
o.window({ tag = "firefox-based-browser" }, { tag = "-default-opacity", opacity = "1.0 0.985" })

-- video apps: remove chromium browser tag so they don't get opacity applied.
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-default-opacity" })

-- hide screen sharing notification windows.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })

-- steam windows
o.window("steam", { float = true, idle_inhibit = "fullscreen" })
o.window({ class = "steam", title = "Steam" }, { center = true, size = { 1100, 700 } })
o.window("steam.*", { tag = "-default-opacity", opacity = "1 1" })
o.window({ class = "steam", title = "Friends List" }, { size = { 460, 800 } })

o.window({ tag = "brave-browser" }, { workspace = "1" })
o.window({ tag = "terminal*" }, { workspace = "2" })
o.window({ class = "^brave-youtube.com__(.*)" }, { workspace = "3" })
o.window({ class = "^brave-x.com__(.*)" }, { workspace = "3" })
o.window({ class = "^brave-discord.com__(.*)" }, { workspace = "4" })
o.window("steam", { workspace = "5" })

-- floating windows
o.window({ tag = "floating-window" }, { float = true })
o.window({ tag = "floating-window" }, { center = true })
o.window({ tag = "floating-window" }, { size = { 875, 600 } })
