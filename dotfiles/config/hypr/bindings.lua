-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

---@diagnostic disable: undefined-global

-- Cmd+Tab cycles windows on a Mac, not Spaces.
-- NOTE: this replaces Omarchy's SUPER+TAB, which was "Next workspace".
-- Spaces move to SUPER+CTRL+LEFT/RIGHT below, almost the same as on macOS.
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Focus next window (Cmd+Tab)", hl.dsp.window.cycle_next())

-- SUPER+Ctrl+Left/Right: cycle slots 1-5 of the CURRENT monitor, wrapping,
-- creating empty workspaces as needed. Uses Omarchy's own o.workspaces.focus,
-- which resolves the monitor's block correctly with laptop + external screen.
local WORKSPACE_SLOTS = 5
local function cycle_workspace(step)
  return function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local slot = (ws.id - 1) % WORKSPACE_SLOTS + 1
    o.workspaces.focus((slot - 1 + step + WORKSPACE_SLOTS) % WORKSPACE_SLOTS + 1)()
  end
end
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")
o.bind("SUPER + CTRL + LEFT", "Previous workspace (wraps 1-5, same monitor)", cycle_workspace(-1))
o.bind("SUPER + CTRL + RIGHT", "Next workspace (wraps 1-5, same monitor)", cycle_workspace(1))

-- Rebind Agent from SUPER+SHIFT+CTRL+A to SUPER+A
hl.unbind("SUPER + SHIFT + CTRL + A")
hl.unbind("SUPER + A")
o.bind("SUPER + A", "Agent", "omarchy-agent --pick")

-- Unbind SUPER+W as I'm so used to use it to close tabs but now it closes my window :(
hl.unbind("SUPER+W")

-- Unbind SUPER+L as I'm so used to using it but it adjust the layout which I don't need
hl.unbind("SUPER+L")

-- Extra mouse buttons -> browser back/forward via XF86Back/XF86Forward.
-- The Logitech M650 sends BTN_FORWARD/BTN_BACK (= mouse:277/278):
o.bind("mouse:278", "Browser back", "wtype -k XF86Back")
o.bind("mouse:277", "Browser forward", "wtype -k XF86Forward")
-- Also cover mice that send BTN_SIDE/BTN_EXTRA (= mouse:275/276):
o.bind("mouse:275", "Browser back", "wtype -k XF86Back")
o.bind("mouse:276", "Browser forward", "wtype -k XF86Forward")

