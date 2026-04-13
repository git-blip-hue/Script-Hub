-- Untitled Tag Game
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

    KeySystem = false,
    KeySettings = {
        Title = "Untitled Tag Game - Key System",
        Subtitle = "Key Required",
        Note = "Join our Discord to get the key!",
        FileName = "UntitledTagKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"UntitledTag2024", "FreeKey123", "TagGameVIP"}
    }
})

local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = PlayersService.LocalPlayer

local isESPEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)
local taggerEspColor = Color3.fromRGB(255, 0, 0)
local runnerEspColor = Color3.fromRGB(0, 255, 0)
local isSpeedEnabled = false
local speedMultiplier = 16
local isJumpEnabled = false
local jumpPowerMultiplier = 50
local isNoClipEnabled = false
local isAutoTagEnabled = false
local isAutoEvadeEnabled = false

local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_Folder"
espFolder.Parent = game.CoreGui

local function createESP(targetPlayer)
    if targetPlayer == LocalPlayer then 
        return 
    end
    
    local function setupESP()
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            return 
        end
        
        local existingHighlight = espFolder:FindFirstChild(targetPlayer.Name .. "_ESP")
        if existingHighlight then 
            existingHighlight:Destroy() 
        end
        
        local highlightBox = Instance.new("Highlight")
        highlightBox.Name = targetPlayer.Name .. "_ESP"
        highlightBox.Adornee = targetPlayer.Character
        highlightBox.FillTransparency = 0.5
        highlightBox.OutlineTransparency = 0
        highlightBox.Parent = espFolder
        
        local infoGui = Instance.new("BillboardGui")
        infoGui.Name = targetPlayer.Name .. "_NameESP"
        infoGui.Adornee = targetPlayer.Character:FindFirstChild("Head")
        infoGui.Size = UDim2.new(0, 100, 0, 40)
        infoGui.StudsOffset = Vector3.new(0, 2, 0)
        infoGui.AlwaysOnTop = true
        infoGui.Parent = espFolder
        
        local nameText = Instance.new("TextLabel")
        nameText.Name = "NameLabel"
        nameText.Size = UDim2.new(1, 0, 0.5, 0)
        nameText.BackgroundTransparency = 1
        nameText.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameText.TextStrokeTransparency = 0
        nameText.Font = Enum.Font.GothamBold
        nameText.TextSize = 14
        nameText.Text = targetPlayer.Name
        nameText.Parent = infoGui
        
        local distanceText = Instance.new("TextLabel")
        distanceText.Name = "DistanceLabel"
        distanceText.Size = UDim2.new(1, 0, 0.5, 0)
        distanceText.Position = UDim2.new(0, 0, 0.5, 0)
        distanceText.BackgroundTransparency = 1
        distanceText.TextColor3 = Color3.fromRGB(200, 200, 200)
        distanceText.TextStrokeTransparency = 0
        distanceText.Font = Enum.Font.Gotham
        distanceText.TextSize = 12
        distanceText.Text = "0 studs"
        distanceText.Parent = infoGui
        
        highlightBox.FillColor = espColor
        highlightBox.OutlineColor = espColor
    end
    
    setupESP()
    targetPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupESP()
    end)
end

local function updateESP()
    if not isESPEnabled then
        for _, object in pairs(espFolder:GetChildren()) do
            object:Destroy()
        end
        return
    end
    
    local allPlayers = PlayersService:GetPlayers()
    local iterationCount = math.ceil(#allPlayers * 0.15)
    
    for i = 1, iterationCount do
        local player = allPlayers[i]
        if player ~= LocalPlayer and player.Character then
            local highlight = espFolder:FindFirstChild(player.Name .. "_ESP")
            local gui = espFolder:FindFirstChild(player.Name .. "_NameESP")
            
            if not highlight then
                createESP(player)
            end
            
            if gui and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distLabel = gui:FindFirstChild("DistanceLabel")
                if distLabel and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    distLabel.Text = math.floor(distance) .. " studs"
                end
            end
        end
    end
end

local function toggleNoClip(isEnabled)
    if isEnabled then
        RunService.Stepped:Connect(function()
            if isNoClipEnabled and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function getClosestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end
    
    local allPlayers = PlayersService:GetPlayers()
    for _, player in pairs(allPlayers) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end
    
    return nearestPlayer, shortestDistance
end

local function teleportToPlayer(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
end

local mainTab = Window:CreateTab("Main", "home")
local espTab = Window:CreateTab("ESP", "eye")
local movementTab = Window:CreateTab("Movement", "zap")
local teleportTab = Window:CreateTab("Teleport", "map-pin")
local miscTab = Window:CreateTab("Misc", "settings")

mainTab:CreateSection("Auto Features")

mainTab:CreateToggle({
    Name = "Auto Tag (When Tagger)",
    CurrentValue = false,
    Flag = "AutoTag",
    Callback = function(state)
        isAutoTagEnabled = state
    end,
})

mainTab:CreateToggle({
    Name = "Auto Evade (When Runner)",
    CurrentValue = false,
    Flag = "AutoEvade",
    Callback = function(state)
        isAutoEvadeEnabled = state
    end,
})

mainTab:CreateSection("Quick Actions")

mainTab:CreateButton({
    Name = "Teleport to Closest Player",
    Callback = function()
        local closest = getClosestPlayer()
        if closest then
            teleportToPlayer(closest)
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

mainTab:CreateButton({
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

espTab:CreateSection("Player ESP")

espTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(state)
        isESPEnabled = state
        updateESP()
    end,
})

espTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        espColor = color
        for _, object in pairs(espFolder:GetChildren()) do
            if object:IsA("Highlight") then
                object.FillColor = color
                object.OutlineColor = color
            end
        end
    end,
})

espTab:CreateSection("ESP Settings")

espTab:CreateColorPicker({
    Name = "Tagger Color",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "TaggerColor",
    Callback = function(color)
        taggerEspColor = color
    end,
})

espTab:CreateColorPicker({
    Name = "Runner Color",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "RunnerColor",
    Callback = function(color)
        runnerEspColor = color
    end,
})

movementTab:CreateSection("Speed")

movementTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Flag = "Speed",
    Callback = function(state)
        isSpeedEnabled = state
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = state and speedMultiplier or 16
        end
    end,
})

movementTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(value)
        speedMultiplier = value
        if isSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end,
})

movementTab:CreateSection("Jump")

movementTab:CreateToggle({
    Name = "Enable Jump Power",
    CurrentValue = false,
    Flag = "Jump",
    Callback = function(state)
        isJumpEnabled = state
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = state and jumpPowerMultiplier or 50
        end
    end,
})

movementTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpValue",
    Callback = function(value)
        jumpPowerMultiplier = value
        if isJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end,
})

movementTab:CreateSection("NoClip")

movementTab:CreateToggle({
    Name = "Enable NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(state)
        isNoClipEnabled = state
        if state then
            toggleNoClip(true)
        end
    end,
})

teleportTab:CreateSection("Player Teleport")

local playerNamesList = {}
for _, player in pairs(PlayersService:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerNamesList, player.Name)
    end
end

local selectedTargetPlayer = nil

local playerDropdown = teleportTab:CreateDropdown({
    Name = "Select Player",
    Options = playerNamesList,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "SelectedPlayer",
    Callback = function(option)
        selectedTargetPlayer = PlayersService:FindFirstChild(option[1])
    end,
})

PlayersService.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        table.insert(playerNamesList, player.Name)
        playerDropdown:Refresh(playerNamesList)
    end
end)

PlayersService.PlayerRemoving:Connect(function(player)
    for i, name in pairs(playerNamesList) do
        if name == player.Name then
            table.remove(playerNamesList, i)
            break
        end
    end
    playerDropdown:Refresh(playerNamesList)
end)

teleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if selectedTargetPlayer then
            teleportToPlayer(selectedTargetPlayer)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to " .. selectedTargetPlayer.Name,
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

teleportTab:CreateSection("Location Teleport")

teleportTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local spawnPoint = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChildOfClass("SpawnLocation")
        if spawnPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Teleported to spawn!",
                Duration = 3,
                Image = "check",
            })
        end
    end,
})

miscTab:CreateSection("Visuals")

miscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(state)
        local lighting = game:GetService("Lighting")
        if state then
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

miscTab:CreateSection("Character")

miscTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end,
})

miscTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerNamesList = {}
        for _, player in pairs(PlayersService:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerNamesList, player.Name)
            end
        end
        playerDropdown:Refresh(playerNamesList)
        Rayfield:Notify({
            Title = "Refreshed",
            Content = "Player list updated!",
            Duration = 3,
            Image = "refresh-cw",
        })
    end,
})

miscTab:CreateSection("Script Info")

miscTab:CreateLabel("Script Version: 1.0.0")
miscTab:CreateLabel("Game: Untitled Tag Game")

miscTab:CreateButton({
    Name = "Destroy Script",
    Callback = function()
        Rayfield:Destroy()
        espFolder:Destroy()
    end,
})

RunService.RenderStepped:Connect(function()
    if isESPEnabled then
        updateESP()
    end
    
    if isSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedMultiplier
    end
    
    if isJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = jumpPowerMultiplier
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if isSpeedEnabled then
        character:WaitForChild("Humanoid").WalkSpeed = speedMultiplier
    end
    if isJumpEnabled then
        character:WaitForChild("Humanoid").JumpPower = jumpPowerMultiplier
    end
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "Untitled Tag Game script loaded successfully!",
    Duration = 5,
    Image = "check",
})
