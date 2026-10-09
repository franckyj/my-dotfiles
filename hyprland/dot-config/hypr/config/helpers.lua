-- Shared helpers for Hyprland Lua configuration.
-- taken from omarchy's /usr/share/omarchy/default/hypr/helpers.lua

o = o or {}

function o.window(match, rules)
  rules.match = rules.match or {}

  if type(match) == "string" then
    rules.match.class = match
  else
    for key, value in pairs(match) do
      rules.match[key] = value
    end
  end

  hl.window_rule(rules)
end
