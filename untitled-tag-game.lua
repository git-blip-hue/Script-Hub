--[[
    Untitled Tag Game Script
    UI Library: Rayfield
    Features: Key System, ESP, Speed, Teleports, Auto Features
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Untitled Tag Game Hub",
    Icon = "tag",
    LoadingTitle = "Untitled Tag Game Script",
    LoadingSubtitle = "by Script Hub",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UntitledTagGame",
        FileName = "Config"
    },

    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },

    KeySystem = true,
    KeySettings = {
        Title = "Untitled Tag Game - Key System",
        Subtitle = "Key Required",
        Note = "Join our Discord to get the key!
            https://discord.gg/CG25rNP46X",
        FileName = "UntitledTagKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"UntitledTag2024", "FreeKey123", "TagGameVIP"}
    }
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local TaggerESPColor = Color3.fromRGB(255, 0, 0)
local RunnerESPColor = Color3.fromRGB(0, 255, 0)
local SpeedEnabled = false
local SpeedValue = 16
local JumpEnabled = false
local JumpValue = 50
local NoClipEnabled = false
local AutoTagEnabled = false
local AutoEvadeEnabled = false

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Folder"
ESPFolder.Parent = game.CoreGui

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local function SetupESP()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local existingESP = ESPFolder:FindFirstChild(player.Name .. "_ESP")
        if existingESP then existingESP:Destroy() end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_ESP"
        highlight.Adornee = player.Character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = ESPFolder
        
        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = player.Name .. "_NameESP"
        billboardGui.Adornee = player.Character:FindFirstChild("Head")
        billboardGui.Size = UDim2.new(0, 100, 0, 40)
        billboardGui.StudsOffset = Vector3.new(0, 2, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent = ESPFolder
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Text = player.Name
        nameLabel.Parent = billboardGui
        
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Name = "DistanceLabel"
        distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceLabel.TextStrokeTransparency = 0
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 12
        distanceLabel.Text = "0 studs"
        distanceLabel.Parent = billboardGui
        
        highlight.FillColor = ESPColor
        highlight.OutlineColor = ESPColor
    end
    
    SetupESP()
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        SetupESP()
    end)
end

local function UpdateESP()
    if not ESPEnabled then
        for _, esp in pairs(ESPFolder:GetChildren()) do
            esp:Destroy()
        end
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local esp = ESPFolder:FindFirstChild(player.Name .. "_ESP")
            local nameESP = ESPFolder:FindFirstChild(player.Name .. "_NameESP")
            
            if not esp then
                CreateESP(player)
            end
            
            if nameESP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distLabel = nameESP:FindFirstChild("DistanceLabel")
                if distLabel and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    distLabel.Text = math.floor(distance) .. " studs"
                end
            end
        end
    end
end

local function ToggleNoClip(enabled)
    if enabled then
        RunService.Stepped:Connect(function()
            if NoClipEnabled and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer, closestDistance
end

local function TeleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end

local MainTab = Window:CreateTab("Main", "home")
local ESPTab = Window:CreateTab("ESP", "eye")
local MovementTab = Window:CreateTab("Movement", "zap")
local TeleportTab = Window:CreateTab("Teleport", "map-pin")
local MiscTab = Window:CreateTab("Misc", "settings")

MainTab:CreateSection("Auto Features")

local AutoTagToggle = MainTab:CreateToggle({
    Name = "Auto Tag (When Tagger)",
    CurrentValue = false,
    Flag = "AutoTag",
    Callback = function(Value)
        AutoTagEnabled = Value
    end,
})

local AutoEvadeToggle = MainTab:CreateToggle({
    Name = "Auto Evade (When Runner)",
    CurrentValue = false,
    Flag = "AutoEvade",
    Callback = function(Value)
        AutoEvadeEnabled = Value
    end,
})

MainTab:CreateSection("Quick Actions")

MainTab:CreateButton({
    Name = "Teleport to Closest Player",
    Callback = function()
        local closest = GetClosestPlayer()
        if closest then
            TeleportToPlayer(closest)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to " .. closest.Name,
                Duration = 3,
                Image = "check",
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "No players found!",
                Duration = 3,
                Image = "x",
            })
        end
    end,
})

MainTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        Rayfield:Notify({
            Title = "Rejoining",
            Content = "Rejoining server...",
            Duration = 2,
            Image = "refresh-cw",
        })
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

ESPTab:CreateSection("Player ESP")

local ESPToggle = ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabled = Value
        UpdateESP()
    end,
})

local ESPColorPicker = ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Value)
        ESPColor = Value
        for _, esp in pairs(ESPFolder:GetChildren()) do
            if esp:IsA("Highlight") then
                esp.FillColor = Value
                esp.OutlineColor = Value
            end
        end
    end,
})

ESPTab:CreateSection("ESP Settings")

local TaggerColorPicker = ESPTab:CreateColorPicker({
    Name = "Tagger Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "TaggerColor",
    Callback = function(Value)
        TaggerESPColor = Value
    end,
})

local RunnerColorPicker = ESPTab:CreateColorPicker({
    Name = "Runner Color",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "RunnerColor",
    Callback = function(Value)
        RunnerESPColor = Value
    end,
})

MovementTab:CreateSection("Speed")

local SpeedToggle = MovementTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(Value)
        SpeedEnabled = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value and SpeedValue or 16
        end
    end,
})

local SpeedSlider = MovementTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(Value)
        SpeedValue = Value
        if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

MovementTab:CreateSection("Jump")

local JumpToggle = MovementTab:CreateToggle({
    Name = "Enable Jump Power",
    CurrentValue = false,
    Flag = "Jump",
    Callback = function(Value)
        JumpEnabled = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value and JumpValue or 50
        end
    end,
})

local JumpSlider = MovementTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpValue",
    Callback = function(Value)
        JumpValue = Value
        if JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end,
})

MovementTab:CreateSection("NoClip")

local NoClipToggle = MovementTab:CreateToggle({
    Name = "Enable NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        NoClipEnabled = Value
        if Value then
            ToggleNoClip(true)
        end
    end,
})

TeleportTab:CreateSection("Player Teleport")

local playerList = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerList, player.Name)
    end
end

local SelectedPlayer = nil

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SelectedPlayer",
    Callback = function(Option)
        SelectedPlayer = Players:FindFirstChild(Option[1])
    end,
})

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        table.insert(playerList, player.Name)
        PlayerDropdown:Refresh(playerList)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in pairs(playerList) do
        if name == player.Name then
            table.remove(playerList, i)
            break
        end
    end
    PlayerDropdown:Refresh(playerList)
end)

TeleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if SelectedPlayer then
            TeleportToPlayer(SelectedPlayer)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to " .. SelectedPlayer.Name,
                Duration = 3,
                Image = "check",
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Please select a player first!",
                Duration = 3,
                Image = "x",
            })
        end
    end,
})

TeleportTab:CreateSection("Location Teleport")

TeleportTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to spawn!",
                Duration = 3,
                Image = "check",
            })
        end
    end,
})

MiscTab:CreateSection("Visuals")

MiscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        local lighting = game:GetService("Lighting")
        if Value then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
            lighting.GlobalShadows = false
        else
            lighting.Brightness = 1
            lighting.GlobalShadows = true
        end
    end,
})

MiscTab:CreateSection("Character")

MiscTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end,
})

MiscTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerList = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerList, player.Name)
            end
        end
        PlayerDropdown:Refresh(playerList)
        Rayfield:Notify({
            Title = "Refreshed",
            Content = "Player list updated!",
            Duration = 3,
            Image = "refresh-cw",
        })
    end,
})

MiscTab:CreateSection("Script Info")

MiscTab:CreateLabel("Script Version: 1.0.0")
MiscTab:CreateLabel("Game: Untitled Tag Game")

MiscTab:CreateButton({
    Name = "Destroy Script",
    Callback = function()
        Rayfield:Destroy()
        ESPFolder:Destroy()
    end,
})

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
    
    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = SpeedValue
    end
    
    if JumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = JumpValue
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if SpeedEnabled then
        character:WaitForChild("Humanoid").WalkSpeed = SpeedValue
    end
    if JumpEnabled then
        character:WaitForChild("Humanoid").JumpPower = JumpValue
    end
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Untitled Tag Game script loaded successfully!",
    Duration = 5,
    Image = "check",
})
