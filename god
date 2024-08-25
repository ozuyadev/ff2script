-- Anti-Cheat Bypass for Solara
print('Initializing AC Bypass!')

--// Services
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Teams = cloneref(game:GetService("Teams"))
local TweenService = cloneref(game:GetService("TweenService"))
local Stats = cloneref(game:GetService("Stats"))

if game.PlaceId ~= 8206123457 or game.PlaceId == 8204899140 then
    -- Made by Unlimited, Modified/Updated by NG/Johan Peterson

    --// Variables
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
    local Hooks = {}
    local HandshakeArgs = nil
    local Remote = ReplicatedStorage:WaitForChild("Remotes").CharacterSoundEvent
    local ACString = nil
    
    -- os.clock hook
    local RandomNumber = math.random(1e3, 1e5)

    Hooks.Clock = hookfunction(os.clock, function(...)
        return Hooks.Clock(...) + RandomNumber
    end)

    -- namecall hook
    Hooks.Namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}

        if not checkcaller() and self == Remote and (Method == "FireServer" or Method == "fireServer") and string.find(Args[1], "AC") then
            if not HandshakeArgs then
                if type(Args[2]) == "table" and #Args[2] == 19 then
                    ACString = Args[1]
                    HandshakeArgs = Args[2]
                end
            else
                return coroutine.yield()
            end
        end

        return Hooks.Namecall(self, ...)
    end)

    while not ACString and not HandshakeArgs do
        task.wait()
    end

    print("Found handshake arguments.")

    task.wait(3)

    for _, v in pairs(getgc()) do
        if type(v) == "function" then
            if getinfo(v).source:find("PlayerModule.LocalScript") then
                hookfunction(v, function() end)
            end
        end
    end

    print("Hooked all anticheat functions.")

    local ReplicateHandshake = function()
        return Remote:FireServer(ACString, HandshakeArgs, nil)
    end

    task.spawn(function()
        while task.wait(0.4) do
            local Success, Error = pcall(ReplicateHandshake)

            if not Success then
                warn("Bypass timed out.")
                task.wait(20)
                Player:Kick("Bypass timed out.")
                return
            end
        end
    end)

    print("Replicated handshake.")
end

task.wait()

print('Done! Now Loading')

-- Orion UI Integration
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Tyrant Hub", HidePremium = false, SaveConfig = true, ConfigFolder = "TyrantHub"})

-- Catching Tab
local CatchingTab = Window:MakeTab({
    Name = "Catching",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local magEnabled = false
local customDistance = 10
local magnetDelayEnabled = false
local magnetDelay = 0
local showHitboxState = false
local hitboxIndicator = nil  -- Store hitbox indicator
local autoCatchEnabled = false
local autoCatchRadius = 10

CatchingTab:AddSection({Name = "Magnets"})

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
    Max = 50,
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
        showHitboxState = value
        if hitboxIndicator then
            hitboxIndicator.Transparency = showHitboxState and 0.5 or 1
        end
    end,
})

CatchingTab:AddToggle({
    Name = "Auto Catch",
    Default = false,
    Callback = function(value)
        autoCatchEnabled = value
    end,
})

CatchingTab:AddSlider({
    Name = "Auto Catch Radius",
    Min = 1,
    Max = 25,
    Default = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "Radius",
    Callback = function(value)
        autoCatchRadius = value
    end,
})

local function updateMagnetStatus()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character

    if character then
        local ball = workspace:FindFirstChild("Football")

        if ball then
            if magEnabled then
                if magnetDelayEnabled then
                    wait(magnetDelay)
                end
                ball.Size = Vector3.new(customDistance, customDistance, customDistance)

                -- Make the ball move towards the player's hands
                local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("LeftHand")
                if hand then
                    local direction = (hand.Position - ball.Position).Unit
                    local force = Instance.new("BodyVelocity")
                    force.Velocity = direction * 200  -- Increase this value to make the pull stronger
                    force.MaxForce = Vector3.new(10000, 10000, 10000)
                    force.Parent = ball
                    game:GetService("Debris"):AddItem(force, 0.1)
                end

                -- Show hitbox
                if showHitboxState then
                    if not hitboxIndicator then
                        hitboxIndicator = Instance.new("Part")
                        hitboxIndicator.Name = "HitboxIndicator"
                        hitboxIndicator.Size = Vector3.new(customDistance, customDistance, customDistance)
                        hitboxIndicator.Color = Color3.fromRGB(128, 128, 128)  -- Grey color
                        hitboxIndicator.Anchored = true
                        hitboxIndicator.CanCollide = false
                        hitboxIndicator.Transparency = 0.5
                        hitboxIndicator.Parent = ball
                    else
                        hitboxIndicator.Size = Vector3.new(customDistance, customDistance, customDistance)
                        hitboxIndicator.Transparency = 0.5
                    end
                elseif hitboxIndicator then
                    hitboxIndicator:Destroy()
                    hitboxIndicator = nil
                end
            else
                ball.Size = Vector3.new(1, 1, 1)
                ball.Transparency = 1
                if hitboxIndicator then
                    hitboxIndicator:Destroy()
                    hitboxIndicator = nil
                end
            end
        end

        -- Auto Catch
        if autoCatchEnabled then
            local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("LeftHand")
            if hand and ball then
                local distance = (ball.Position - hand.Position).magnitude
                if distance <= autoCatchRadius then
                    -- Click to catch the ball
                    UserInputService:SendInputObject({
                        InputType = Enum.InputType.MouseButton1,
                        UserInputType = Enum.UserInputType.MouseButton1,
                        Position = Vector2.new(mouse.X, mouse.Y)
                    })
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

PlayerTab:AddSection({Name = "Player Settings"})

PlayerTab:AddToggle({
    Name = "Walkspeed",
    Default = false,
    Callback = function(value)
        -- Implementation for Walkspeed Toggle
    end,
})

PlayerTab:AddSlider({
    Name = "Walkspeed",
    Min = 20,
    Max = 23,
    Default = 20,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        -- Implementation for Walkspeed Slider
    end,
})

PlayerTab:AddToggle({
    Name = "JumpPower",
    Default = false,
    Callback = function(value)
        -- Implementation for JumpPower Toggle
    end,
})

PlayerTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 60,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(value)
        -- Implementation for JumpPower Slider
    end,
})

-- Info Tab
local InfoTab = Window:MakeTab({
    Name = "Info",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

InfoTab:AddSection({Name = "Info"})

InfoTab:AddLabel({
    Name = "Owner",
    Text = "Ozuya"
})

InfoTab:AddLabel({
    Name = "Game Name",
    Text = "Football Fusion 2"
})

print("Script loaded successfully")
