--//====================================================
--// IKONNED goofy aah UI
--// Rayfield / Sirius
--//====================================================

--// Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

if not Rayfield then
    error("Failed to load Rayfield.")
end

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

--// Player
local LocalPlayer = Players.LocalPlayer

--//====================================================
--// WINDOW
--//====================================================

local Window = Rayfield:CreateWindow({
    Name = "Ikonned Premium UI",
    Icon = 0,

    LoadingTitle = "Ikonned UI",
    LoadingSubtitle = "By @Ikonned",

    ShowText = "Ikonned",
    Theme = "Default",

    ToggleUIKeybind = "K",

    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "IkonnedUI",
        FileName = "Settings"
    },

    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },

    KeySystem = false
})

--======================================================
-- CREATE ALL TABS TOGETHER
--======================================================

local Home = Window:CreateTab("Home", 0)
local Visuals = Window:CreateTab("Visuals", 0)
local Exploits = Window:CreateTab("Exploits", 0)
local Items = Window:CreateTab("Items", 0)
local Tools = Window:CreateTab("Tools", 0)

--======================================================
-- HELPERS
--======================================================

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local Character = GetCharacter()

    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local Character = GetCharacter()

    if not Character then
        return nil
    end

    return Character:FindFirstChild("HumanoidRootPart")
end

--======================================================
-- HOME
--======================================================

Home:CreateSection("Movement")

local InfiniteJumpEnabled = false
local NoclipEnabled = false
local FloatEnabled = false
local WalkSpeed = 16

-- Walk Speed
Home:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",

    Callback = function(Value)
        WalkSpeed = Value

        local Humanoid = GetHumanoid()

        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

-- Infinite Jump
Home:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",

    Callback = function(Value)
        InfiniteJumpEnabled = Value
    end
})

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpEnabled then
        return
    end

    local Humanoid = GetHumanoid()

    if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
Home:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",

    Callback = function(Value)
        NoclipEnabled = Value

        if not Value then
            local Character = GetCharacter()

            if Character then
                for _, Object in ipairs(Character:GetDescendants()) do
                    if Object:IsA("BasePart") then
                        Object.CanCollide = true
                    end
                end
            end
        end
    end
})

RunService.Stepped:Connect(function()
    if not NoclipEnabled then
        return
    end

    local Character = GetCharacter()

    if not Character then
        return
    end

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("BasePart") then
            Object.CanCollide = false
        end
    end
end)

-- Float
Home:CreateToggle({
    Name = "Float",
    CurrentValue = false,
    Flag = "Float",

    Callback = function(Value)
        FloatEnabled = Value
    end
})

RunService.Heartbeat:Connect(function()
    if not FloatEnabled then
        return
    end

    local RootPart = GetRootPart()

    if not RootPart then
        return
    end

    local Velocity = RootPart.AssemblyLinearVelocity

    RootPart.AssemblyLinearVelocity = Vector3.new(
        Velocity.X,
        0,
        Velocity.Z
    )
end)

-- Respawn handling
LocalPlayer.CharacterAdded:Connect(function(Character)
    local Humanoid = Character:WaitForChild("Humanoid")

    Humanoid.WalkSpeed = WalkSpeed

    if NoclipEnabled then
        for _, Object in ipairs(Character:GetDescendants()) do
            if Object:IsA("BasePart") then
                Object.CanCollide = false
            end
        end
    end
end)

--======================================================
-- VISUALS
--======================================================

Visuals:CreateSection("Player ESP")

local ESPEnabled = false
local ESPObjects = {}

local function RemoveESP(Player)
    local Object = ESPObjects[Player]

    if Object then
        Object:Destroy()
        ESPObjects[Player] = nil
    end
end

local function AddESP(Player)
    if Player == LocalPlayer then
        return
    end

    if not ESPEnabled then
        return
    end

    local Character = Player.Character

    if not Character then
        return
    end

    local RootPart = Character:FindFirstChild("HumanoidRootPart")

    if not RootPart then
        return
    end

    RemoveESP(Player)

    local Box = Instance.new("BoxHandleAdornment")

    Box.Name = "IkonnedESP"
    Box.Adornee = RootPart
    Box.Size = Vector3.new(4, 6, 2)
    Box.Color3 = Color3.fromRGB(255, 255, 255)
    Box.Transparency = 0.35
    Box.AlwaysOnTop = true
    Box.ZIndex = 5
    Box.Parent = RootPart

    ESPObjects[Player] = Box
end

local function UpdateAllESP()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            AddESP(Player)
        end
    end
end

Visuals:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",

    Callback = function(Value)
        ESPEnabled = Value

        if Value then
            UpdateAllESP()
        else
            for Player in pairs(ESPObjects) do
                RemoveESP(Player)
            end
        end
    end
})

-- Existing players
for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then

        Player.CharacterAdded:Connect(function(Character)
            local RootPart = Character:WaitForChild(
                "HumanoidRootPart",
                10
            )

            if RootPart then
                task.wait(0.1)
                AddESP(Player)
            end
        end)

        if Player.Character then
            task.defer(function()
                AddESP(Player)
            end)
        end
    end
end

-- New players
Players.PlayerAdded:Connect(function(Player)

    Player.CharacterAdded:Connect(function(Character)
        local RootPart = Character:WaitForChild(
            "HumanoidRootPart",
            10
        )

        if RootPart then
            task.wait(0.1)
            AddESP(Player)
        end
    end)

end)

Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
end)

-- Camera
Visuals:CreateSection("Camera")

Visuals:CreateSlider({
    Name = "FOV",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 90,
    Flag = "FOV",

    Callback = function(Value)
        local Camera = workspace.CurrentCamera

        if Camera then
            Camera.FieldOfView = Value
        end
    end
})

--======================================================
-- EXPLOITS
--======================================================

Exploits:CreateSection("Hot/Fun Stuff")

Exploits:CreateButton({
    Name = "Neko [WARNING]",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet(
                "https://raw.githubusercontent.com/ikonned/NikoV5/refs/heads/main/haha.lua"
            )

            local Script = loadstring(Source)

            if not Script then
                error("Neko V5 could not be compiled.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Neko V5",
                Content = "Loaded successfully.",
                Duration = 5
            })
        else
            warn("Neko V5 Error:", Result)

            Rayfield:Notify({
                Title = "Neko V5 Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Exploits:CreateButton({
    Name = "Emotes",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet("https://gist.githubusercontent.com/lolidkwhy678/6d44b8fa28f70a4269231f11e5749474/raw/0dc4da5a8f49236bac1f3ea01f83226c2ea3dc20/emote%2520script%2520%25F0%259F%2598%2582")

            local Script = loadstring(Source)

            if not Script then
                error("Emotes script could not be compiled.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Emotes",
                Content = "Emotes loaded successfully.",
                Duration = 5
            })
        else
            warn("Emotes Error:", Result)

            Rayfield:Notify({
                Title = "Emotes Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Exploits:CreateButton({
    Name = "Rainbow Trail",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet(
                "https://raw.githubusercontent.com/ikonned/RainbowTrail/refs/heads/main/FE"
            )

            local Script = loadstring(Source)

            if not Script then
                error("Rainbow Trail could not be compiled.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Rainbow Trail",
                Content = "Loaded successfully.",
                Duration = 5
            })
        else
            warn("Rainbow Trail Error:", Result)

            Rayfield:Notify({
                Title = "Rainbow Trail Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Exploits:CreateToggle({
    Name = "Rainbow Star Particles",
    CurrentValue = false,

    Callback = function(Value)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        local Player = Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Root = Character:WaitForChild("HumanoidRootPart")

        if Value then
            if _G.RainbowStars then
                return
            end

            _G.RainbowStars = true

            local Attachment = Instance.new("Attachment")
            Attachment.Name = "RainbowStarAttachment"
            Attachment.Parent = Root

            local Particle = Instance.new("ParticleEmitter")
            Particle.Name = "RainbowStars"
            Particle.Parent = Attachment

            -- Star texture
            Particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"

            Particle.Rate = 20
            Particle.Lifetime = NumberRange.new(1.5, 2.5)
            Particle.Speed = NumberRange.new(2, 5)
            Particle.SpreadAngle = Vector2.new(180, 180)

            Particle.Rotation = NumberRange.new(0, 360)
            Particle.RotSpeed = NumberRange.new(-120, 120)

            Particle.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(0.5, 0.8),
                NumberSequenceKeypoint.new(1, 0)
            })

            Particle.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.8, 0.2),
                NumberSequenceKeypoint.new(1, 1)
            })

            local Hue = 0

            _G.RainbowStarsConnection = RunService.Heartbeat:Connect(function(DeltaTime)
                if not _G.RainbowStars then
                    return
                end

                Hue = (Hue + DeltaTime * 0.15) % 1

                local Color1 = Color3.fromHSV(Hue, 1, 1)
                local Color2 = Color3.fromHSV((Hue + 0.15) % 1, 1, 1)

                Particle.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color1),
                    ColorSequenceKeypoint.new(1, Color2)
                })
            end)

            Rayfield:Notify({
                Title = "Rainbow Stars",
                Content = "Rainbow star particles enabled.",
                Duration = 3
            })

        else
            _G.RainbowStars = false

            if _G.RainbowStarsConnection then
                _G.RainbowStarsConnection:Disconnect()
                _G.RainbowStarsConnection = nil
            end

            if Root then
                local Attachment = Root:FindFirstChild("RainbowStarAttachment")

                if Attachment then
                    Attachment:Destroy()
                end
            end

            Rayfield:Notify({
                Title = "Rainbow Stars",
                Content = "Rainbow star particles disabled.",
                Duration = 3
            })
        end
    end
})

--======================================================
-- ITEMS
--======================================================

Items:CreateSection("Items")

Items:CreateButton({
    Name = "Laser Gun",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet(
                "https://raw.githubusercontent.com/ikonned/LaserGun/refs/heads/main/ClientSided"
            )

            local Script = loadstring(Source)

            if not Script then
                error("Could not compile Laser Gun.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Laser Gun",
                Content = "Laser Gun loaded successfully.",
                Duration = 5
            })
        else
            warn("Laser Gun Error:", Result)

            Rayfield:Notify({
                Title = "Laser Gun Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Items:CreateButton({
    Name = "Classical AK 47",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet(
                "https://raw.githubusercontent.com/ikonned/AK47/refs/heads/main/Classical.skid"
            )

            local Script = loadstring(Source)

            if not Script then
                error("AK 47 script could not be compiled.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Classical AK 47",
                Content = "Classical AK 47 loaded successfully.",
                Duration = 5
            })
        else
            warn("Ban Sword Error:", Result)

            Rayfield:Notify({
                Title = "Classical AK 47 Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Items:CreateButton({
    Name = "Lightning Cannon",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet(
                "https://raw.githubusercontent.com/bayly098764321/Exire-Reanimate/refs/heads/main/Scripts/LightningCannon.lua"
            )

            local Script = loadstring(Source)

            if not Script then
                error("Lightning Cannon script could not be compiled.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Lightning Cannon",
                Content = "Lightning Cannon loaded successfully.",
                Duration = 5
            })
        else
            warn("Lightning Cannon Error:", Result)

            Rayfield:Notify({
                Title = "Lightning Cannon Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Items:CreateButton({
    Name = "Rainbow MM2 Knife",

    Callback = function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")

        local Player = Players.LocalPlayer
        local Backpack = Player:WaitForChild("Backpack")

        local Success, Result = pcall(function()
            local Objects = game:GetObjects("rbxassetid://121946387")

            if not Objects or not Objects[1] then
                error("Bombo's Survival Knife could not be loaded.")
            end

            local Knife = Objects[1]
            Knife.Parent = Backpack

            -- Stop an old rainbow loop
            if _G.BombosRainbowConnection then
                _G.BombosRainbowConnection:Disconnect()
                _G.BombosRainbowConnection = nil
            end

            local Hue = 0

            _G.BombosRainbowConnection = RunService.RenderStepped:Connect(function(DeltaTime)
                if not Knife or not Knife.Parent then
                    _G.BombosRainbowConnection:Disconnect()
                    _G.BombosRainbowConnection = nil
                    return
                end

                -- Slow + smooth rainbow
                Hue = (Hue + DeltaTime * 0.035) % 1

                local Rainbow = Color3.fromHSV(Hue, 1, 1)

                for _, Object in ipairs(Knife:GetDescendants()) do
                    if Object:IsA("BasePart") then
                        Object.Color = Rainbow

                    elseif Object:IsA("Trail") then
                        Object.Color = ColorSequence.new(Rainbow)

                    elseif Object:IsA("ParticleEmitter") then
                        Object.Color = ColorSequence.new(Rainbow)
                    end
                end
            end)
        end)

        if Success then
            Rayfield:Notify({
                Title = "MM2 Knife",
                Content = "Rainbow knife loaded successfully.",
                Duration = 5
            })
        else
            warn("MM2 Knife Error:", Result)

            Rayfield:Notify({
                Title = "MM2 Knife Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Items:CreateButton({
    Name = "Spec Zeta Biograft Energy Sword",

    Callback = function()
        local Success, Result = pcall(function()
            local Objects = game:GetObjects("rbxassetid://66416579")

            if not Objects or not Objects[1] then
                error("Spec Zeta Biograft Energy Sword could not be loaded.")
            end

            local Item = Objects[1]
            Item.Parent = game:GetService("Players").LocalPlayer.Backpack

            local RunService = game:GetService("RunService")
            local Hue = 0

            if _G.ZetaRainbowConnection then
                _G.ZetaRainbowConnection:Disconnect()
            end

            _G.ZetaRainbowConnection = RunService.Heartbeat:Connect(function(DeltaTime)
                if not Item or not Item.Parent then
                    _G.ZetaRainbowConnection:Disconnect()
                    _G.ZetaRainbowConnection = nil
                    return
                end

                -- Slow rainbow cycle
                Hue = (Hue + DeltaTime * 0.035) % 1
                local RainbowColor = Color3.fromHSV(Hue, 1, 1)

                for _, Object in ipairs(Item:GetDescendants()) do
                    if Object:IsA("BasePart") then
                        Object.Color = RainbowColor

                    elseif Object:IsA("Trail") then
                        Object.Color = ColorSequence.new(RainbowColor)

                    elseif Object:IsA("ParticleEmitter") then
                        Object.Color = ColorSequence.new(RainbowColor)
                    end
                end
            end)
        end)

        if Success then
            Rayfield:Notify({
                Title = "Spec Zeta Biograft Energy Sword",
                Content = "Sword loaded with slow rainbow effect.",
                Duration = 5
            })
        else
            warn("Zeta Sword Error:", Result)

            Rayfield:Notify({
                Title = "Zeta Sword Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

Items:CreateButton({
    Name = "Magic Carpet",

    Callback = function()
        local Success, Result = pcall(function()
            local Object = game:GetObjects("rbxassetid:/225921000/")[1]

            if not Object then
                error("Magic Carpet asset could not be loaded.")
            end

            local Source = Object.Source

            if not Source then
                error("Magic Carpet source could not be found.")
            end

            local Script = loadstring(Source)

            if not Script then
                error("Magic Carpet script could not be compiled.")
            end

            Script()
        end)

        if Success then
            Rayfield:Notify({
                Title = "Magic Carpet",
                Content = "Magic Carpet loaded successfully.",
                Duration = 5
            })
        else
            warn("Magic Carpet Error:", Result)

            Rayfield:Notify({
                Title = "Magic Carpet Error",
                Content = tostring(Result),
                Duration = 5
            })
        end
    end
})

--======================================================
-- TOOLS
--======================================================

Tools:CreateSection("Developer Tools")

Tools:CreateButton({
    Name = "Infinite Yield",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
            local Script = loadstring(Source)

            if not Script then
                error("Infinite Yield could not be compiled.")
            end

            Script()
        end)

        Rayfield:Notify({
            Title = Success and "Infinite Yield" or "Infinite Yield Error",
            Content = Success
                and "Loaded successfully."
                or tostring(Result),
            Duration = 5
        })
    end
})

Tools:CreateButton({
    Name = "Dex Explorer ++",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua") 
")
            local Script = loadstring(Source)

            if not Script then
                error("Dex Explorer ++ could not be compiled.")
            end

            Script()
        end)

        Rayfield:Notify({
            Title = Success and "Dex Explorer ++" or "Dex Explorer ++ Error",
            Content = Success
                and "Loaded successfully."
                or tostring(Result),
            Duration = 5
        })
    end
})

Tools:CreateButton({
    Name = "SimpleSpy",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua")
            local Script = loadstring(Source)

            if not Script then
                error("SimpleSpy could not be compiled.")
            end

            Script()
        end)

        Rayfield:Notify({
            Title = Success and "SimpleSpy" or "SimpleSpy Error",
            Content = Success
                and "Loaded successfully."
                or tostring(Result),
            Duration = 5
        })
    end
})

Tools:CreateButton({
    Name = "RemoteSpy",

    Callback = function()
        local Success, Result = pcall(function()
            local Source = game:HttpGet("https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua")
            local Script = loadstring(Source)

            if not Script then
                error("RemoteSpy could not be compiled.")
            end

            Script()
        end)

        Rayfield:Notify({
            Title = Success and "RemoteSpy" or "RemoteSpy Error",
            Content = Success
                and "Loaded successfully."
                or tostring(Result),
            Duration = 5
        })
    end
})

Tools:CreateButton({
    Name = "Reset Character",

    Callback = function()

        local Character = GetCharacter()

        local Humanoid = Character
            and Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            Humanoid.Health = 0
        end
    end
})

Tools:CreateButton({
    Name = "Rejoin Server",

    Callback = function()

        TeleportService:Teleport(
            game.PlaceId,
            LocalPlayer
        )
    end
})

Tools:CreateButton({
    Name = "Open Developer Console",

    Callback = function()

        pcall(function()
            StarterGui:SetCore(
                "DevConsoleVisible",
                true
            )
        end)
    end
})

--======================================================
-- DEBUG
--======================================================

Tools:CreateSection("Debug")

Tools:CreateToggle({
    Name = "Show Debug Info",
    CurrentValue = false,
    Flag = "DebugInfo",

    Callback = function(Value)
        print("Ikonned UI Debug:", Value)
    end
})

--======================================================
-- LOAD
--======================================================

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Ikonned UI",
    Content = "Loaded successfully.",
    Duration = 5
})
