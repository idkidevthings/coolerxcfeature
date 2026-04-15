repeat task.wait() until _G.WindUI and _G.Window

local WindUI = _G.WindUI
local Window = _G.Window

local Players    = cloneref(game:GetService("Players"))
local WorkSpace  = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer
local Vehicles   = WorkSpace:WaitForChild("Vehicles", 9e9)

local function GetDrivenVehicle()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum and hum.Sit and hum.SeatPart and hum.SeatPart.Name == "DriverSeat" then
        return hum.SeatPart.Parent
    end
end

local function GetLocalPlayerCar()
    for _, v in ipairs(Vehicles:GetChildren()) do
        if v:GetAttribute("Owner") == LocalPlayer.Name then
            return v
        end
    end
end

local function GetVehicle()
    return GetDrivenVehicle() or GetLocalPlayerCar()
end

local function GetDrive(vehicle)
    if not vehicle or not vehicle:FindFirstChild("Drive Controller") then
        return false, nil
    end
    local ok, Drive = pcall(require, vehicle:FindFirstChild("Drive Controller"))
    return ok and Drive ~= nil, ok and Drive or nil
end

local CustomTab = Window:Tab({
    Title = "suspention mods",
    Icon = "wrench"
})

local rideHeight     = 2.0
local springStrength = 80
local dampingVal     = 180
local travelDist     = 4.0
local antiRoll       = 3.0
local cgHeight       = 0.5
local targetTires    = "All"
local antiTirePop    = false 

CustomTab:Section({ Title = "Target Settings" })

CustomTab:Dropdown({
    Title    = "Target Tires",
    Desc     = "Apply settings to All, Front, or Back tires",
    Values   = {"All", "Front", "Back"},
    Value    = "All",
    Callback = function(v) targetTires = v end,
})

CustomTab:Section({ Title = "Extras" })

CustomTab:Toggle({
    Title    = "Anti Tire Pop",
    Desc     = "Forces CanCollide on ONLY the main wheel parts.",
    Value    = false,
    Callback = function(state)
        antiTirePop = state
    end,
})

CustomTab:Section({ Title = "Suspension" })

CustomTab:Slider({
    Title    = "Ride Height",
    Desc     = "How high the body sits",
    Value    = { Min = 0.5, Max = 80.0, Default = 2.0 },
    Step     = 0.5,
    Callback = function(v) rideHeight = tonumber(v) or 2.0 end,
})

CustomTab:Slider({
    Title    = "Spring Strength",
    Desc     = "Higher = stiffer, more stable",
    Value    = { Min = 5, Max = 300, Default = 80 },
    Step     = 5,
    Callback = function(v) springStrength = tonumber(v) or 80 end,
})

CustomTab:Slider({
    Title    = "Damping",
    Desc     = "Higher = less bouncy, more planted",
    Value    = { Min = 10, Max = 500, Default = 180 },
    Step     = 10,
    Callback = function(v) dampingVal = tonumber(v) or 180 end,
})

CustomTab:Slider({
    Title    = "Wheel Travel",
    Desc     = "How far wheels move up/down",
    Value    = { Min = 0.05, Max = 12.0, Default = 4.0 },
    Step     = 0.5,
    Callback = function(v) travelDist = tonumber(v) or 4.0 end,
})

CustomTab:Section({ Title = "Stability" })

CustomTab:Slider({
    Title    = "Anti-Roll Strength",
    Desc     = "Stops the car leaning/tipping on corners. Higher = flatter.",
    Value    = { Min = 0.5, Max = 20.0, Default = 3.0 },
    Step     = 0.5,
    Callback = function(v) antiRoll = tonumber(v) or 3.0 end,
})

CustomTab:Slider({
    Title    = "Center of Gravity",
    Desc     = "Lower = more stable. Keep under 1.0 for best results.",
    Value    = { Min = 0.1, Max = 3.0, Default = 0.5 },
    Step     = 0.1,
    Callback = function(v) cgHeight = tonumber(v) or 0.5 end,
})

local function ApplySuspension(car)
    if not car or not car:FindFirstChild("Wheels") then
        WindUI:Notify({ Title = "Suspension", Content = "No vehicle found!", Duration = 3 })
        return
    end

    local ok, Drive = GetDrive(car)
    if ok and Drive then
        rawset(Drive, "FAntiRoll", antiRoll)
        rawset(Drive, "RAntiRoll", antiRoll)
        rawset(Drive, "CGHeight", cgHeight)
        rawset(Drive, "WeightDist", 0.5)
        rawset(Drive, "FGyroDamp", 200)
        rawset(Drive, "RGyroDamp", 200)
        rawset(Drive, "TCSThreshold", 0.08)
        rawset(Drive, "TCSGradient",  0.5)
    end

    xpcall(function()
        for _, v in ipairs(car.Wheels:GetChildren()) do
            local isFront = (v.Name == "FL" or v.Name == "FR")
            local isBack  = (v.Name == "RL" or v.Name == "RR")

            local applyToWheel = false
            if targetTires == "All" and (isFront or isBack) then
                applyToWheel = true
            elseif targetTires == "Front" and isFront then
                applyToWheel = true
            elseif targetTires == "Back" and isBack then
                applyToWheel = true
            end

            if applyToWheel then
                local spring = v:FindFirstChild("Spring")
                if spring then
                    spring.Stiffness  = springStrength
                    spring.Damping    = dampingVal
                    spring.FreeLength = rideHeight
                    spring.MaxLength  = rideHeight + travelDist
                    spring.MinLength  = math.max(0.05, rideHeight - (travelDist * 0.5))
                end

                local sb = v:FindFirstChild("#SB")
                if sb then
                    if sb:FindFirstChild("Stabilizer") then
                        sb.Stabilizer.D = antiRoll * 150
                    end
                    if sb:FindFirstChild("Attach_SB") then
                        sb.Attach_SB.CFrame = CFrame.new(0, rideHeight * 0.5, -1)
                    end
                end

                local sa = v:FindFirstChild("#SA")
                if sa and sa:FindFirstChild("Attach_SA") then
                    sa.Attach_SA.CFrame = CFrame.new(0, -(rideHeight * 0.5), 1)
                end

                local cyl = v:FindFirstChild("Cylindrical")
                if cyl then
                    cyl.LimitsEnabled = true
                    cyl.UpperLimit    =  travelDist
                    cyl.LowerLimit    = -travelDist
                end
            end
        end
    end, function(err)
        print("Suspension Error: " .. err)
    end)

    WindUI:Notify({
        Title   = "Suspension",
        Content = "Applied to " .. targetTires .. " tires.",
        Duration = 3,
    })
end

CustomTab:Button({
    Title    = "Apply",
    Desc     = "Apply suspension settings",
    Callback = function()
        ApplySuspension(GetVehicle())
    end,
})

RunService.Heartbeat:Connect(function()
    if not antiTirePop then return end

    local car = GetVehicle()
    if car and car:FindFirstChild("Wheels") then
        for _, v in ipairs(car.Wheels:GetChildren()) do
            -- Filter by selection
            local isFront = (v.Name == "FL" or v.Name == "FR")
            local isBack  = (v.Name == "RL" or v.Name == "RR")

            local applyToWheel = false
            if targetTires == "All" and (isFront or isBack) then
                applyToWheel = true
            elseif targetTires == "Front" and isFront then
                applyToWheel = true
            elseif targetTires == "Back" and isBack then
                applyToWheel = true
            end

            -- Only set CanCollide on the Part itself if it matches the name
            if applyToWheel and v:IsA("BasePart") then
                if v.CanCollide == false then
                    v.CanCollide = true
                end
            end
        end
    end
end)
