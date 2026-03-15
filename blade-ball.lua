-- Blade Ball | Rayfield UI Script
-- Features: Auto Parry, Auto Spam, Manual Spam, Anti-Miss, Anti-Die

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    AutoParry = false,
    AutoSpam = false,
    ManualSpam = false,
    AntiMiss = false,
    AntiDie = false,
    AutoParryDelay = 0.1,
    AutoSpamDelay = 0.05,
    ManualSpamKey = Enum.KeyCode.E,
    AntiDieThreshold = 10,
}

-- Connections table for cleanup
local Connections = {}

-- Utility: Find ball in workspace
local function FindBall()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name == "Ball" or obj.Name == "blade_ball") then
            return obj
        end
    end
    return nil
end

-- Utility: Get parry remote
local function GetParryRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        or ReplicatedStorage:FindFirstChild("Events")
        or ReplicatedStorage
    for _, v in ipairs(remotes:GetDescendants()) do
        if v:IsA("RemoteEvent") and (
            v.Name:lower():find("parry") or
            v.Name:lower():find("block") or
            v.Name:lower():find("deflect")
        ) then
            return v
        end
    end
    return nil
end

-- Auto Parry Logic
local function DoParry()
    local parryRemote = GetParryRemote()
    if parryRemote then
        parryRemote:FireServer()
    end
end

-- Auto Spam Loop
local autoSpamConnection
local function StartAutoSpam()
    if autoSpamConnection then
        autoSpamConnection:Disconnect()
        autoSpamConnection = nil
    end
    autoSpamConnection = RunService.Heartbeat:Connect(function()
        if Settings.AutoSpam then
            task.wait(Settings.AutoSpamDelay)
            DoParry()
        end
    end)
end

-- Anti Miss: fire parry when ball is close
local antiMissConnection
local function StartAntiMiss()
    if antiMissConnection then
        antiMissConnection:Disconnect()
        antiMissConnection = nil
    end
    antiMissConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AntiMiss then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ball = FindBall()
        if ball then
            local dist = (hrp.Position - ball.Position).Magnitude
            if dist <= 20 then
                DoParry()
            end
        end
    end)
end

-- Auto Parry Loop (direction + timing based)
local autoParryConnection
local function StartAutoParry()
    if autoParryConnection then
        autoParryConnection:Disconnect()
        autoParryConnection = nil
    end
    autoParryConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AutoParry then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local ball = FindBall()
        if ball then
            local dist = (hrp.Position - ball.Position).Magnitude
            local velocity = ball.Velocity
            local toPlayer = (hrp.Position - ball.Position).Unit
            local dotProduct = velocity.Unit:Dot(toPlayer)
            -- Ball is heading toward player and within 30 studs
            if dist <= 30 and dotProduct > 0.5 then
                task.wait(Settings.AutoParryDelay)
                DoParry()
            end
        end
    end)
end

-- Anti-Die: keeps health up using regen or blocks lethal hits
local antiDieConnection
local function StartAntiDie()
    if antiDieConnection then
        antiDieConnection:Disconnect()
        antiDieConnection = nil
    end
    antiDieConnection = RunService.Heartbeat:Connect(function()
        if not Settings.AntiDie then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= Settings.AntiDieThreshold and hum.Health > 0 then
            -- Force parry when near death to block lethal hit
            DoParry()
        end
    end)
end

-- Manual Spam Input
local manualSpamActive = false
local manualSpamConn
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.ManualSpamKey and Settings.ManualSpam then
        manualSpamActive = true
        manualSpamConn = RunService.Heartbeat:Connect(function()
            if manualSpamActive and Settings.ManualSpam then
                DoParry()
                task.wait(Settings.AutoSpamDelay)
            end
        end)
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Settings.ManualSpamKey then
        manualSpamActive = false
        if manualSpamConn then
            manualSpamConn:Disconnect()
            manualSpamConn = nil
        end
    end
end)

-- Start background loops
StartAutoParry()
StartAutoSpam()
StartAntiMiss()
StartAntiDie()

-- ================== RAYFIELD UI ==================

local Window = Rayfield:CreateWindow({
    Name = "Blade Ball | By Script Hub",
    Icon = 0,
    LoadingTitle = "Blade Ball Script",
    LoadingSubtitle = "by Script Hub",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BladeBallHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- ======== TAB: COMBAT ========
local CombatTab = Window:CreateTab("Combat", 4483362458)

-- Auto Parry
CombatTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = false,
    Flag = "AutoParry",
    Callback = function(val)
        Settings.AutoParry = val
    end,
})

CombatTab:CreateSlider({
    Name = "Auto Parry Delay",
    Range = {0, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "AutoParryDelay",
    Callback = function(val)
        Settings.AutoParryDelay = val
    end,
})

CombatTab:CreateDivider()

-- Auto Spam
CombatTab:CreateToggle({
    Name = "Auto Spam",
    CurrentValue = false,
    Flag = "AutoSpam",
    Callback = function(val)
        Settings.AutoSpam = val
    end,
})

CombatTab:CreateSlider({
    Name = "Auto Spam Delay",
    Range = {0.01, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.05,
    Flag = "AutoSpamDelay",
    Callback = function(val)
        Settings.AutoSpamDelay = val
    end,
})

CombatTab:CreateDivider()

-- Manual Spam
CombatTab:CreateToggle({
    Name = "Manual Spam (Hold Key)",
    CurrentValue = false,
    Flag = "ManualSpam",
    Callback = function(val)
        Settings.ManualSpam = val
    end,
})

CombatTab:CreateKeybind({
    Name = "Manual Spam Key",
    CurrentKeybind = "E",
    HoldToInteract = false,
    Flag = "ManualSpamKey",
    Callback = function(keybind)
        local key = Enum.KeyCode[keybind]
        if key then
            Settings.ManualSpamKey = key
        end
    end,
})

CombatTab:CreateDivider()

-- Anti-Miss
CombatTab:CreateToggle({
    Name = "Anti-Miss",
    CurrentValue = false,
    Flag = "AntiMiss",
    Callback = function(val)
        Settings.AntiMiss = val
    end,
})

-- ======== TAB: SURVIVAL ========
local SurvivalTab = Window:CreateTab("Survival", 4483362458)

-- Anti-Die
SurvivalTab:CreateToggle({
    Name = "Anti-Die",
    CurrentValue = false,
    Flag = "AntiDie",
    Callback = function(val)
        Settings.AntiDie = val
    end,
})

SurvivalTab:CreateSlider({
    Name = "Anti-Die HP Threshold",
    Range = {1, 50},
    Increment = 1,
    Suffix = " HP",
    CurrentValue = 10,
    Flag = "AntiDieThreshold",
    Callback = function(val)
        Settings.AntiDieThreshold = val
    end,
})

SurvivalTab:CreateDivider()

SurvivalTab:CreateParagraph({
    Title = "Anti-Die Info",
    Content = "Automatically spams parry when your HP drops below the threshold, helping you survive lethal hits."
})

-- ======== TAB: SETTINGS ========
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateParagraph({
    Title = "Blade Ball Script",
    Content = "Auto Parry: Automatically parries when the ball is heading toward you.\n\nAuto Spam: Continuously spams the parry action.\n\nManual Spam: Hold your keybind to spam parry.\n\nAnti-Miss: Fires parry when ball is within range.\n\nAnti-Die: Parries when HP is critically low."
})

SettingsTab:CreateDivider()

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
        for _, conn in ipairs(Connections) do
            conn:Disconnect()
        end
    end,
})

-- Notify on load
Rayfield:Notify({
    Title = "Blade Ball Script",
    Content = "Script loaded successfully! Use the Combat tab to enable features.",
    Duration = 5,
    Image = 4483362458,
})
