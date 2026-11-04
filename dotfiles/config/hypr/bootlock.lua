-- Boot lock screen for Hyprland
-- Shows lock screen immediately at boot (password on login)
-- Managed via dotfiles (stowed to ~/.config/hypr/bootlock.lua)

local function lockScreen()
    -- Use omarchy-shell to lock (same as Super+Esc)
    os.execute("omarchy-shell lock lock")
end

-- Call lockScreen when Hyprland starts
lockScreen()
