---@meta
-------------------------------------------------------------------------------
-- OXWM Configuration File
-------------------------------------------------------------------------------

---Load type definitions for LSP
---@module 'oxwm'

-- from https://codeberg.org/justaguylinux/oxwm-setup

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
-- Define your variables here for easy customization throughout the config.
-- This makes it simple to change keybindings, colors, and settings in one place.

-- Modifier key: "Mod4" is the Super/Windows key, "Mod1" is Alt
local modkey = "Mod4"

-- Terminal emulator command (defualts to alacritty)
local terminal = "alacritty"

-- Color palette - customize these to match your theme
-- Alternatively you can import other files in here, such as
-- local colors = require("colors.lua") and make colors.lua a file
-- in the ~/.config/oxwm directory
-- local colors = require("tokyonight");
--------------------------------------------------------------------------------
-- Palette
--------------------------------------------------------------------------------
-- Loaded from the active theme (swapped by scripts/thememenu);
-- falls back to GitHub Dark.
local ok, theme = pcall(dofile, os.getenv("HOME") .. "/.config/oxwm/colors.lua")
local colors = (ok and type(theme) == "table") and theme or {
    background     = 0x0d1117,
    background_alt = 0x2f363d,
    foreground     = 0xd0d7de,
    primary        = 0xd29922,
    secondary      = 0xb3e5fc,
    alert          = 0xd29922,
    disabled       = 0x4e5b55,
    border         = 0x0f2923,
}

local tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
-- local tags = { "", "󰊯", "", "󰰏", "󰟿", "󱇤", "", "󱘶", "󰧮" } -- Example of nerd font icon tags

local bar_font = "JetBrainsMono Nerd Font Propo:style=Bold:size=12"

local function pipe()
    return oxwm.bar.block.static({
        text = " | ", format = "", interval = 999999999,
        color = colors.disabled, underline = false,
    })
end

-- gon = require("get_os_name")
-- os_name, arch_name = gon.get_os_name()

local blocks = {
    oxwm.bar.block.shell({
        format = " {}",
        command = "uname -r",
        interval = 600,
        color = colors.foreground,
        underline = false,
    }),
    -- oxwm.bar.block.static({
    --     text = os_name .. " (" .. arch_name .. ")",
    --     format = "",
    --     interval = 999999999,
    --     color = colors.alert,
    --     underline = false
    -- }),
    pipe(),
    oxwm.bar.block.shell({
        command = "pamixer --get-volume 2>/dev/null || echo 0",
        format = "{}%",
        interval = 2,
        color = colors.foreground,
        underline = false,
        click = { command = "alacritty -e pulsemixer", floating = true },
    }),
    pipe(),
    oxwm.bar.block.ram({
        format = "󰍛 Ram: {used}/{total} GB",
        interval = 5,
        color = colors.foreground,
        underline = false,
    }),
    pipe(),
    oxwm.bar.block.datetime({
        format = "󰸘 {}",
        date_format = "%a, %b %d - %-I:%M %P",
        interval = 1,
        color = colors.primary,
        underline = false,
    }),
    pipe(),
    oxwm.bar.block.static({
        text = "󰐥 ",
        format = "",
        interval = 999999999,
        color = colors.alert,
        underline = false,
        click = os.getenv("HOME") .. "/.config/oxwm/scripts/power.sh",
    }),
    oxwm.bar.block.static({
        text = "󰻛", format = "",
        interval = 999999999,
        color = colors.secondary,
        underline = false,
        click = "flameshot gui",
    }),
    pipe(),
    -- Uncomment to add battery status (useful for laptops)
    oxwm.bar.block.battery({
        format = "Bat: {}%",
        charging = "⚡ Bat: {}%",
        discharging = "- Bat: {}%",
        full = "✓ Bat: {}%",
        interval = 30,
        color = colors.alert,
        underline = false,
    }),
    oxwm.bar.block.systray({}),
};

-------------------------------------------------------------------------------
-- Basic Settings
-------------------------------------------------------------------------------
oxwm.set_terminal(terminal)
oxwm.set_modkey(modkey)
oxwm.set_tags(tags)

oxwm.auto_tile(true)
local default_layout = "dwindle" -- Mod+Alt+R resets to this
oxwm.set_layout(default_layout)
oxwm.bar.set_hide_vacant_tags(false)
oxwm.set_floating_position("center")

-------------------------------------------------------------------------------
-- Layouts
-------------------------------------------------------------------------------
-- oxwm.set_layout_symbol("tiling", "[T]")
-- oxwm.set_layout_symbol("normie", "[F]")
-- oxwm.set_layout_symbol("tabbed", "[=]")

oxwm.set_layout_symbol("tiling", "󰙀")
oxwm.set_layout_symbol("monocle", "󰕮")
oxwm.set_layout_symbol("normie", "󰕰") -- floating layout
oxwm.set_layout_symbol("grid", "󰝘")
oxwm.set_layout_symbol("dwindle", "󰕴")
oxwm.set_layout_symbol("scrolling", "󰓡")

-------------------------------------------------------------------------------
-- Appearance
-------------------------------------------------------------------------------
oxwm.border.set_width(2)
oxwm.border.set_focused_color(colors.secondary)
oxwm.border.set_unfocused_color(colors.background_alt)

oxwm.gaps.set_enabled(true)
-- Smart Enabled = No border if 1 window
oxwm.gaps.set_smart(false)
-- Inner gaps (horizontal, vertical) in pixels
oxwm.gaps.set_inner(5, 5)
-- Outer gaps (horizontal, vertical) in pixels
oxwm.gaps.set_outer(5, 5)

-------------------------------------------------------------------------------
-- Window Rules
-------------------------------------------------------------------------------
-- Rules allow you to automatically configure windows based on their properties
-- You can match windows by class, instance, title, or role
-- Available properties: floating, tag, fullscreen, etc.
--
-- Common use cases:
-- - Force floating for certain applications (dialogs, utilities)
-- - Send specific applications to specific workspaces
-- - Configure window behavior based on title or class

-- Examples (uncomment to use):
--oxwm.rule.add({ instance = "gimp", floating = true })
oxwm.rule.add({ instance = "brave-browser", tag = 2 })
--oxwm.rule.add({ class = "firefox", tag = 3 })
oxwm.rule.add({ instance = "slack", tag = 4 })
oxwm.rule.add({ instance = "discord", tag = 5 })
oxwm.rule.add({ class = "Pavucontrol", floating = true, focus = true })

-- To find window properties, use xprop and click on the window
-- WM_CLASS(STRING) shows both instance and class (instance, class)

-------------------------------------------------------------------------------
-- Status Bar Configuration
-------------------------------------------------------------------------------
-- Font configuration
oxwm.bar.set_font(bar_font)

-- Set your blocks here (defined above)
oxwm.bar.set_blocks(blocks)

-- Bar color schemes (for workspace tag display)
-- Parameters: foreground, background, border

-- Unoccupied tags
oxwm.bar.set_scheme_normal(colors.disabled, colors.background, colors.background)
-- Occupied tags
oxwm.bar.set_scheme_occupied(colors.foreground, colors.background, colors.background)
-- Currently selected tag
oxwm.bar.set_scheme_selected(colors.foreground, colors.background_alt, colors.primary)
oxwm.bar.set_scheme_urgent(colors.background, colors.alert, colors.alert)

-------------------------------------------------------------------------------
-- Keybindings
-------------------------------------------------------------------------------
-- Basic window management

oxwm.key.bind({ modkey }, "Return", oxwm.spawn_terminal())
-- Launch Dmenu
oxwm.key.bind({ modkey }, "Space", oxwm.spawn({ "sh", "-c", "rofi -show drun -theme ~/.config/rofi/config.rasi" }))
-- Launch file manager
oxwm.key.bind({ modkey }, "F", oxwm.spawn({ "thunar" }))
-- Launch theme menu
oxwm.key.bind({ modkey, "Shift" }, "T", oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/theme-menu.sh" }))

-- Screenshots (saved to ~/screenshots/)
oxwm.key.bind({ modkey, "Shift" }, "S", oxwm.spawn({ "sh", "-c", "flameshot gui --path ~/screenshots/" }))
oxwm.key.bind({ modkey }, "S", oxwm.spawn({ "sh", "-c", "flameshot full --path ~/screenshots/" }))
oxwm.key.bind({ modkey, "Shift" }, "E", oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/power" }))

-- Quit
oxwm.key.bind({ modkey }, "Q", oxwm.client.kill())

-- Media keys
oxwm.key.bind({}, "XF86AudioRaiseVolume", oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/change-volume.sh up" }))
oxwm.key.bind({}, "XF86AudioLowerVolume", oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/change-volume.sh down" }))
oxwm.key.bind({}, "XF86AudioMute", oxwm.spawn({ "sh", "-c", "~/.config/oxwm/scripts/change-volume.sh mute" }))

-- Keybind overlay - Shows important keybindings on screen
oxwm.key.bind({ modkey, "Shift" }, "Slash", oxwm.show_keybinds())

-- Window state toggles
oxwm.key.bind({ modkey, "Shift" }, "F", oxwm.client.toggle_fullscreen())
oxwm.key.bind({ modkey, "Shift" }, "Space", oxwm.client.toggle_floating())

-- Layout management
oxwm.key.bind({ modkey }, "C", oxwm.layout.set("tiling"))
-- Cycle through layouts
oxwm.key.bind({ modkey }, "N", oxwm.layout.cycle())
oxwm.key.bind({ modkey, "Mod1" }, "R", oxwm.layout.set(default_layout))
oxwm.key.bind({ "Shift", "Control" }, "1", oxwm.layout.set("dwindle"))
oxwm.key.bind({ "Shift", "Control" }, "2", oxwm.layout.set("tiling"))
oxwm.key.bind({ "Shift", "Control" }, "3", oxwm.layout.set("scrolling"))
oxwm.key.bind({ "Shift", "Control" }, "4", oxwm.layout.set("grid"))
oxwm.key.bind({ "Shift", "Control" }, "5", oxwm.layout.set("monocle"))
oxwm.key.bind({ "Shift", "Control" }, "6", oxwm.layout.set("normie")) -- floating

-- Master area controls (tiling layout)

-- Decrease/Increase master area width
oxwm.key.bind({ modkey }, "H", oxwm.set_master_factor(-5))
oxwm.key.bind({ modkey }, "L", oxwm.set_master_factor(5))
-- Increment/Decrement number of master windows
oxwm.key.bind({ modkey }, "I", oxwm.inc_num_master(1))
oxwm.key.bind({ modkey }, "P", oxwm.inc_num_master(-1))

-- Gaps toggle
oxwm.key.bind({ modkey }, "A", oxwm.toggle_gaps())

-- Window manager controls
oxwm.key.bind({ modkey, "Shift" }, "Q", oxwm.quit())
oxwm.key.bind({ modkey, "Shift" }, "R", oxwm.restart())

-- Focus movement [1 for up in the stack, -1 for down]
oxwm.key.bind({ modkey }, "J", oxwm.client.focus_stack(1))
oxwm.key.bind({ modkey }, "K", oxwm.client.focus_stack(-1))

-- Window movement (swap position in stack)
oxwm.key.bind({ modkey, "Shift" }, "J", oxwm.client.move_stack(1))
oxwm.key.bind({ modkey, "Shift" }, "K", oxwm.client.move_stack(-1))

-- Multi-monitor support

-- Focus next/previous Monitors
oxwm.key.bind({ modkey }, "Comma", oxwm.monitor.focus(-1))
oxwm.key.bind({ modkey }, "Period", oxwm.monitor.focus(1))
-- Move window to next/previous Monitors
oxwm.key.bind({ modkey, "Shift" }, "Comma", oxwm.monitor.tag(-1))
oxwm.key.bind({ modkey, "Shift" }, "Period", oxwm.monitor.tag(1))

-- Workspace (tag) navigation
-- Per-tag keys (view / move / toggleview / toggletag)
local tag_keys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
for i, key in ipairs(tag_keys) do

    -- Switch to workspace N (tags are 0-indexed, so tag "1" is index 0)
    oxwm.key.bind({ modkey }, key, oxwm.tag.view(i - 1))

    -- Move focused window to workspace N
    oxwm.key.bind({ modkey, "Shift" }, key, oxwm.tag.move_to(i - 1))

    -- Combo view (view multiple tags at once) {argos_nothing}
    -- Example: Mod+Ctrl+2 while on tag 1 will show BOTH tags 1 and 2
    oxwm.key.bind({ modkey, "Control" }, key, oxwm.tag.toggleview(i - 1))

    -- Multi tag (window on multiple tags)
    -- Example: Mod+Ctrl+Shift+2 puts focused window on BOTH current tag and tag 2
    oxwm.key.bind({ modkey, "Control", "Shift" }, key, oxwm.tag.toggletag(i - 1))
end

-------------------------------------------------------------------------------
-- Advanced: Keychords
-------------------------------------------------------------------------------
-- Keychords allow you to bind multiple-key sequences (like Emacs or Vim)
-- Format: {{modifiers}, key1}, {{modifiers}, key2}, ...
-- Example: Press Mod4+Space, then release and press T to spawn a terminal
oxwm.key.chord({
    { { modkey }, "Space" },
    { {},         "T" }
}, oxwm.spawn_terminal())

oxwm.key.chord({
    { { modkey }, "F" },
    { {},         "B" }
}, oxwm.spawn({ "sh", "-c", "$HOME/.config/oxwm/scripts/dmenu/bookmarks-dmenu.sh" }))

oxwm.key.chord({
    { { modkey }, "F" },
    { {},         "F" }
}, oxwm.spawn({ "sh", "-c", "$HOME/.config/oxwm/scripts/dmenu/repos-dmenu.sh" }))

oxwm.key.chord({
    { { modkey }, "F" },
    { {},         "O" }
}, oxwm.spawn({ "sh", "-c", "$HOME/.config/oxwm/scripts/dmenu/tmux-dmenu.sh" }))

-------------------------------------------------------------------------------
-- Autostart
-------------------------------------------------------------------------------
-- Commands to run once when OXWM starts
-- Uncomment and modify these examples, or add your own

oxwm.autostart("lxqt-policykit-agent")
oxwm.autostart("picom --config ~/.config/oxwm/picom/picom.conf -b")
oxwm.autostart("dunst -config ~/.config/oxwm/dunst/dunstrc")
oxwm.autostart("~/.config/oxwm/scripts/feh-wallpaper-random.sh")