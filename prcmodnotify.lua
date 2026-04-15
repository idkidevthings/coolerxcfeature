if _G.ERXQoL then
	warn("QoL already loaded or is loading!")
	return
end

_G.ERXQoL = true

loadstring(game:HttpGet("https://raw.githubusercontent.com/adamMasMusic/ERX/refs/heads/main/structure.lua"))()

repeat
	task.wait()
until _G.ERXStructure

local userInputService = game:GetService("UserInputService")

local WindUI = _G.WindUI
local Window = _G.Window
local ConfigManager = Window.ConfigManager
local Tabs = _G.Tabs
local structure = _G.ERXStructure
local QoLConfig = ConfigManager:CreateConfig("ERXQoL")

local QoLTab = Window:Tab({
	Title = "QoL",
	Icon = "settings",
	Locked = false,
})

-- // Flinging Section // --
local Section = QoLTab:Section({
	Title = "Flinging",
})

local originalWalkFling = nil
local originalCarFling = nil

local autoNoclipToggle = QoLTab:Toggle({
	Title = "Auto noclip",
	Desc = "Auto toggles noclip for walk fling and car fling",
	Value = false,
	Callback = function(state)
		if state then
			originalWalkFling = hookfunction(structure.trolling.WalkFling.Callback, function(toggleState)
				structure.localPlayer.Noclip:Set(toggleState)
				return originalWalkFling(toggleState)
			end)
			originalCarFling = hookfunction(structure.trolling.CarFling.Callback, function(toggleState)
				structure.vehicleMods.NoCollision:Set(toggleState)
				return originalCarFling(toggleState)
			end)
		else
			if originalWalkFling then
				hookfunction(structure.trolling.WalkFling.Callback, originalWalkFling)
			end
			if originalCarFling then
				hookfunction(structure.trolling.CarFling.Callback, originalCarFling)
			end
		end
	end,
})
QoLConfig:Register("autoNoclipToggle", autoNoclipToggle)

local flingKeybindEnabled = true
local flingKeybindToggle = QoLTab:Toggle({
	Title = "Enable Fling Keybind",
	Desc = "Choose if you want the fling keybind enabled",
	Value = true,
	Callback = function(state)
		flingKeybindEnabled = state
	end,
})
QoLConfig:Register("flingKeybindToggle", flingKeybindToggle)

local currentFlingKeybind = Enum.KeyCode.V
local flingKeybind = QoLTab:Keybind({
	Title = "Fling Keybind",
	Desc = "Toggle fling with a single press of a button",
	Value = "V",
	Callback = function(v)
		currentFlingKeybind = Enum.KeyCode[v]
	end,
})
QoLConfig:Register("flingKeybind", flingKeybind)

-- // Noclip Section // --
local Section = QoLTab:Section({
	Title = "Noclip",
})

local noclipKeybindEnabled = true
local noclipKeybindToggle = QoLTab:Toggle({
	Title = "Enable Noclip Keybind",
	Desc = "Choose if you want the noclip keybind enabled",
	Value = true,
	Callback = function(state)
		noclipKeybindEnabled = state
	end,
})
QoLConfig:Register("noclipKeybindToggle", noclipKeybindToggle)

local currentNoclipKeybind = Enum.KeyCode.C
local noclipKeybind = QoLTab:Keybind({
	Title = "Noclip Keybind",
	Desc = "Toggle noclip with a single press of a button",
	Value = "C",
	Callback = function(v)
		currentNoclipKeybind = Enum.KeyCode[v]
	end,
})

-- // Anti-Staff Protection Section // --
local Section = QoLTab:Section({
	Title = "Anti-Staff Protection",
})

local antiStaffAction = "Kick" -- Default
local antiStaffDropdown = QoLTab:Dropdown({
	Title = "Action on PRC Mod Join",
	Desc = "Choose what happens when a moderator is detected",
	Values = {"Kick", "Notify", "Respawn and Notify"},
	Value = "Kick",
	Callback = function(v)
		antiStaffAction = v
	end,
})
QoLConfig:Register("antiStaffAction", antiStaffDropdown)

-- Handle Staff Detection Logic
_G.Connections.OnPRCStaffJoin.Event:Connect(function(Info)
    local modName = Info.Player and Info.Player.Name or "Unknown"
    local alertText = "PRC Mod Detected: " .. modName

    if antiStaffAction == "Kick" then
        game:GetService("Players").LocalPlayer:Kick(alertText)
    elseif antiStaffAction == "Notify" then
        WindUI:Notify({
            Title = "STAFF ALERT",
            Content = alertText,
            Duration = 10,
        })
    elseif antiStaffAction == "Respawn and Notify" then
        WindUI:Notify({
            Title = "STAFF ALERT",
            Content = "Respawning to avoid detection: " .. modName,
            Duration = 10,
        })
        if structure.main and structure.main.Respawn then
            structure.main.Respawn.Callback()
        else
            game.Players.LocalPlayer.Character:BreakJoints() -- Fallback
        end
    end
end)

-- // Respawn Keybind Section // --
local Section = QoLTab:Section({
	Title = "Respawn",
})

local respawnKeybindEnabled = true
local respawnKeybindToggle = QoLTab:Toggle({
	Title = "Enable Respawn Keybind",
	Desc = "Choose if you want the respawn keybind enabled",
	Value = true,
	Callback = function(state)
		respawnKeybindEnabled = state
	end,
})
QoLConfig:Register("respawnKeybindToggle", respawnKeybindToggle)

local currentRespawnKeybind = Enum.KeyCode.Z
local respawnKeybind = QoLTab:Keybind({
	Title = "Respawn Keybind",
	Desc = "Respawn yourself with a single press of a key.",
	Value = "Z",
	Callback = function(v)
		currentRespawnKeybind = Enum.KeyCode[v]
	end,
})
QoLConfig:Register("respawnKeybind", respawnKeybind)

-- // Invisibility Section // --
local Section = QoLTab:Section({
	Title = "Invisibility",
})

local invisibilityKeybindEnabled = true
local invisibilityKeybindToggle = QoLTab:Toggle({
	Title = "Enable Invisibility Keybind",
	Desc = "Choose if you want the invisibility keybind enabled",
	Value = true,
	Callback = function(state)
		invisibilityKeybindEnabled = state
	end,
})
QoLConfig:Register("invisibilityKeybindToggle", invisibilityKeybindToggle)

local currentInvisibilityKeybind = Enum.KeyCode.X
local invisibilityKeybind = QoLTab:Keybind({
	Title = "Invisibility Keybind",
	Desc = "Toggle your invisibility with a single press of a key.",
	Value = "X",
	Callback = function(v)
		currentInvisibilityKeybind = Enum.KeyCode[v]
	end,
})
QoLConfig:Register("invisibilityKeybind", invisibilityKeybind)

-- // Tire Pop Section // --
local Section = QoLTab:Section({
	Title = "Pop all tires",
})

local popAllKeybindEnabled = true
local popAllKeybindToggle = QoLTab:Toggle({
	Title = "Enable Pop All Keybind",
	Desc = "Choose if you want the pop all keybind enabled",
	Value = true,
	Callback = function(state)
		popAllKeybindEnabled = state
	end,
})
QoLConfig:Register("popAllKeybindToggle", popAllKeybindToggle)

local currentPopAllKeybind = Enum.KeyCode.K
local popAllKeybind = QoLTab:Keybind({
	Title = "Pop All Tires Keybind",
	Desc = "Pop all tires with a single press of a key.",
	Value = "K",
	Callback = function(v)
		currentPopAllKeybind = Enum.KeyCode[v]
	end,
})
QoLConfig:Register("popAllKeybind", popAllKeybind)

-- // Random / Utils Section // --
local Section = QoLTab:Section({
	Title = "Random",
})

local saveConfig = QoLTab:Button({
	Title = "Save Config",
	Desc = "Saves your config so it can be loaded next time",
	Callback = function()
		QoLConfig:Save()
	end,
})

local customFeaturesAdd = QoLTab:Button({
	Title = "Add to custom features",
	Desc = "Adds this script to custom features",
	Callback = function()
		local customFeatures = "WindUI/CustomFeatures/CustomFeatures.lua"
		local s = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/adamMasMusic/ERX/refs/heads/main/QoL.lua"))()]]
		appendfile(customFeatures, s)
	end,
})

local liveryTakerLoaded = false
local assetTakerLoader = QoLTab:Button({
	Title = "Loadup asset taker",
	Desc = "Loads asset taker script",
	Callback = function()
		if not liveryTakerLoaded then
			liveryTakerLoaded = true
			loadstring(game:HttpGet("https://raw.githubusercontent.com/adamMasMusic/ERX/refs/heads/main/asset_taker.lua"))()
		end
	end,
})

-- Initialize Config and Notify
QoLConfig:Load()

WindUI:Notify({
	Title = "QoL loaded",
	Content = "Anti-Staff and Keybinds Active!",
	Duration = 3,
})

-- // Keybind Listener // --
task.spawn(function()
	userInputService.InputBegan:Connect(function(input, proc)
		if proc or not _G.WindUI then return end

		-- Fling Bind Logic
		if flingKeybindEnabled and input.KeyCode == currentFlingKeybind then
			local char = game.Players.LocalPlayer.Character
			local isSeated = char and char.Humanoid and char.Humanoid.SeatPart and char.Humanoid.SeatPart:IsDescendantOf(workspace.Vehicles)
			if isSeated then
				structure.trolling.CarFling:Set(not structure.trolling.CarFling.Value)
			else
				structure.trolling.WalkFling:Set(not structure.trolling.WalkFling.Value)
			end
		end

		-- Noclip Bind Logic
		if noclipKeybindEnabled and input.KeyCode == currentNoclipKeybind then
			local char = game.Players.LocalPlayer.Character
			local isSeated = char and char.Humanoid and char.Humanoid.SeatPart and char.Humanoid.SeatPart:IsDescendantOf(workspace.Vehicles)
			if isSeated then
				structure.vehicleMods.NoCollision:Set(not structure.vehicleMods.NoCollision.Value)
			else
				structure.localPlayer.Noclip:Set(not structure.localPlayer.Noclip.Value)
			end
		end

		-- Utility Binds
		if invisibilityKeybindEnabled and input.KeyCode == currentInvisibilityKeybind then
			structure.trolling.Invisibility:Set(not structure.trolling.Invisibility.Value)
		end
		if respawnKeybindEnabled and input.KeyCode == currentRespawnKeybind then
			structure.main.Respawn.Callback()
		end
		if popAllKeybindEnabled and input.KeyCode == currentPopAllKeybind then
			structure.trolling.PopAllTires.Callback()
		end
	end)
end)
