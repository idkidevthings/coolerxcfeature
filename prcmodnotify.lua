-- Wait for the ERX environment to be fully ready
repeat task.wait() until _G.WindUI and _G.Window and _G.ERXStructure and _G.Connections

local WindUI = _G.WindUI
local Window = _G.Window
local Tabs = _G.Tabs
local Connections = _G.Connections
local structure = _G.ERXStructure
local LocalPlayer = game:GetService("Players").LocalPlayer

-- // CONFIG SETUP // --
-- Creates a separate config file for this module
local StaffConfig = Window.ConfigManager:CreateConfig("AntiStaffModule")
local antiStaffMode = "Kick" -- Default fallback

-- // UI SETUP // --
Tabs.Main:Section({
    Title = "Anti-Staff Protection"
})

local antiStaffDropdown = Tabs.Main:Dropdown({
    Title = "Staff Join Action",
    Desc = "What happens when a PRC Mod is detected?",
    Values = {"Kick", "Notify", "Respawn and Notify"},
    Value = "Kick",
    Callback = function(Selected)
        antiStaffMode = Selected
    end,
})

-- Register the dropdown so it saves/loads automatically
StaffConfig:Register("StaffActionValue", antiStaffDropdown)

-- Add a button to save specifically for this module
Tabs.Main:Button({
    Title = "Save Anti-Staff Config",
    Desc = "Saves your current protection choice",
    Callback = function()
        StaffConfig:Save()
        WindUI:Notify({
            Title = "Config Saved",
            Content = "Anti-Staff settings have been updated.",
            Duration = 3
        })
    end
})

-- // LOGIC // --
Connections.OnPRCStaffJoin.Event:Connect(function(Info)
    local modName = Info.Player and Info.Player.Name or "Unknown"
    local alertMsg = "PRC Mod Detected: " .. modName

    if antiStaffMode == "Kick" then
        LocalPlayer:Kick(alertMsg)

    elseif antiStaffMode == "Notify" then
        WindUI:Notify({
            Title = "STAFF JOINED",
            Content = alertMsg,
            Duration = 10,
        })

    elseif antiStaffMode == "Respawn and Notify" then
        WindUI:Notify({
            Title = "STAFF JOINED",
            Content = "Respawning to avoid detection: " .. modName,
            Duration = 10,
        })
        
        if structure.main and structure.main.Respawn then
            structure.main.Respawn.Callback()
        else
            if LocalPlayer.Character then
                LocalPlayer.Character:BreakJoints()
            end
        end
    end
end)

-- Load the saved config immediately on script run
StaffConfig:Load()

WindUI:Notify({
    Title = "System Active",
    Content = "Anti-Staff module loaded with Config Support.",
    Duration = 3,
})
