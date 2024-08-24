if not LPH_OBFUSCATED then
    getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
    getfenv().LPH_JIT_MAX = function(f) return f end
end

if game.PlaceId == 8204899140 then
    LPH_JIT_MAX(function()
        local Hooks = {}
        local Targets = {}
        local Whitelisted = {
            {655, 775, 724, 633, 891},
            {760, 760, 771, 665, 898},
            {660, 759, 751, 863, 771},
        }

        local function TableEquality(x, y)
            if (#x ~= #y) then
                return false
            end
            for i, v in next, x do
                if (y[i] ~= v) then
                    return false
                end
            end
            return true
        end

        LPH_NO_VIRTUALIZE(function()
            for i, v in next, getgc(true) do
                if (type(v) == "function") then
                    local ScriptTrace, Line = debug.info(v, "sl")
                    if string.find(ScriptTrace, "PlayerModule.LocalScript") and table.find({42, 51, 61}, Line) then
                        table.insert(Targets, v)
                    end
                end
                if (type(v) == "table") and (rawlen(v) == 19) and getrawmetatable(v) then
                    Targets.call = rawget(getrawmetatable(v), "call")
                end
            end
        end)()

        if not (Targets[1] and Targets[2] and Targets[3] and Targets.call) then
            warn("Bypass failed to load properly")
            return
        end

        local ScriptPath = debug.info(Targets[1], "s")
        Hooks.debug_info = hookfunction(debug.info, LPH_NO_VIRTUALIZE(function(...)
            if not checkcaller() and TableEquality({...}, {2, "s"}) then
                return ScriptPath
            end
            return Hooks.debug_info(...)
        end))

        hookfunction(Targets[1], LPH_NO_VIRTUALIZE(function() end))
        hookfunction(Targets[2], LPH_NO_VIRTUALIZE(function() end))
        hookfunction(Targets[3], LPH_NO_VIRTUALIZE(function() end))

        Hooks.call = hookfunction(Targets.call, LPH_NO_VIRTUALIZE(function(self, ...)
            if TableEquality(Whitelisted[1], {...}) or
               TableEquality(Whitelisted[2], {...}) or
               TableEquality(Whitelisted[3], {...})
            then
                return Hooks.call(self, ...)
            end
        end))

        task.wait(3)
    end)()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Tyrant Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "TyrantHub"})

-- Catching Tab
local CatchingTab = Window:MakeTab({
    Name = "Catching",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CatchingTab:AddSection({Name = "Magnets"})

local magEnabled = false
local customDistance = 10
local magnetDelayEnabled = false
local magnetDelay = 0
local showTransparencyState = false
local hitboxIndicator = nil

CatchingTab:AddToggle({
    Name = "Magnets",
    Default = false,
    Callback = function(value)
        magEnabled = value
    end,
})

CatchingTab:AddSlider({
    Name = "Magnets Range",
    Min = 1,
    Max = 25,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "Range",
    Callback = function(value)
        customDistance = value
    end,
})

CatchingTab:AddToggle({
    Name = "Magnets Delay",
    Default = false,
    Callback = function(value)
        magnetDelayEnabled = value
    end,
})

CatchingTab:AddSlider({
    Name = "Magnets Delay",
    Min = 0,
    Max = 1,
    Default = 0,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "Delay",
    Callback = function(value)
        magnetDelay = value
    end,
})

CatchingTab:AddToggle({
    Name = "Show Hitbox",
    Default = false,
    Callback = function(value)
        showTransparencyState = value
        if hitboxIndicator then
            hitboxIndicator.Transparency = value and 0.5 or 1
        end
    end,
})

local function updateMagnetStatus()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character

    if character then
        local ball = workspace:FindFirstChild("Football") -- Assuming the ball is named "Football"
        
        if ball then
            if magEnabled then
                if magnetDelayEnabled then
                    wait(magnetDelay)
                end
                
                -- Make the ball magnet stronger
                ball.Size = Vector3.new(customDistance, customDistance, customDistance)
                ball.Transparency = showTransparencyState and 0.5 or 1 -- Adjust transparency to be more visible

                -- Adjusting the hitbox
                if showTransparencyState then
                    -- Create or update hitbox indicator part
                    if not hitboxIndicator then
                        hitboxIndicator = Instance.new("Part")
                        hitboxIndicator.Name = "HitboxIndicator"
                        hitboxIndicator.Size = ball.Size
                        hitboxIndicator.Position = ball.Position
                        hitboxIndicator.Anchored = true
                        hitboxIndicator.CanCollide = false
                        hitboxIndicator.BrickColor = BrickColor.new("Bright red")
                        hitboxIndicator.Material = Enum.Material.SmoothPlastic
                        hitboxIndicator.Transparency = 0.5
                        hitboxIndicator.Parent = workspace
                    else
                        hitboxIndicator.Size = ball.Size
                        hitboxIndicator.Position = ball.Position
                        hitboxIndicator.Transparency = 0.5
                    end
                else
                    if hitboxIndicator then
                        hitboxIndicator.Transparency = 1
                    end
                end
            else
                ball.Size = Vector3.new(1, 1, 1)
                ball.Transparency = 1
                if hitboxIndicator then
                    hitboxIndicator.Transparency = 1
                end
            end
        end
    end
end

spawn(function()
    while true do
        updateMagnetStatus()
        wait(1)
    end
end)

-- Player Tab
local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local walkspeedEnabled = false
local jumpPowerEnabled = false
local currentWalkspeed = 20
local currentJumpPower = 50

PlayerTab:AddToggle({
    Name = "Walkspeed",
    Default = false,
    Callback = function(value)
        walkspeedEnabled = value
        if not walkspeedEnabled then
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16 -- default walkspeed
                end
            end
        end
    end
})

PlayerTab:AddSlider({
    Name = "Walkspeed",
    Min = 20,
    Max = 25,
    Default = 20,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        currentWalkspeed = value
    end
})

PlayerTab:AddToggle({
    Name = "JumpPower",
    Default = false,
    Callback = function(value)
        jumpPowerEnabled = value
        if not jumpPowerEnabled then
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = 50 -- default jumppower
                end
            end
        end
    end
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 65,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(value)
        currentJumpPower = value
    end
})

local function applyPlayerSettings()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if walkspeedEnabled then
                humanoid.WalkSpeed = currentWalkspeed
            end
            if jumpPowerEnabled then
                humanoid.JumpPower = currentJumpPower
            end
        end
    end
end

spawn(function()
    while true do
        applyPlayerSettings()
        wait(1)
    end
end)

-- Info Tab
local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddParagraph("Owner", "Ozuya")
InfoTab:AddParagraph("Game", "Football Fusion 2")

OrionLib:Init()
