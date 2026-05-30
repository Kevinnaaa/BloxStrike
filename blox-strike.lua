--[[
    UNIVERSAL FPS - SILENT AIMBOT + BLOX STRIKE STYLE ESP
    Silent aim redirects bullets to enemy head + Box ESP
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local AimbotEnabled = true
local ESPEnabled = true
local ScriptActive = true
local FOVRadius = 100
local Smoothness = 0.3
local TeamCheck = true
local AimPart = "Head"
local SilentAimEnabled = true -- Silent aim toggle
local ShowFOV = false
local TargetLocked = false

-- ESP Sub-toggles (Blox Strike style)
local EspBox = true
local EspHealth = true
local EspName = true
local EspDistance = true

local ESPBoxes = {}
local ESPColor = Color3.fromRGB(255, 50, 50)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 370)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.Text = "🎯 SILENT AIM + ESP"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.Text = "● Ready - Silent Aim Active"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 11
Status.Parent = Frame

local Div1 = Instance.new("Frame")
Div1.Size = UDim2.new(1, 0, 0, 1)
Div1.Position = UDim2.new(0, 0, 0, 58)
Div1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Div1.BorderSizePixel = 0
Div1.Parent = Frame

-- Silent Aim Toggle
local SilentAimToggle = Instance.new("TextButton")
SilentAimToggle.Size = UDim2.new(1, -20, 0, 28)
SilentAimToggle.Position = UDim2.new(0, 10, 0, 65)
SilentAimToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
SilentAimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimToggle.Text = "🤫 Silent Aim: ON"
SilentAimToggle.Font = Enum.Font.SourceSansBold
SilentAimToggle.TextSize = 12
SilentAimToggle.Parent = Frame

-- ESP Master Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, -20, 0, 28)
ESPToggle.Position = UDim2.new(0, 10, 0, 98)
ESPToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Text = "👁️ ESP: ON"
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.TextSize = 12
ESPToggle.Parent = Frame

-- ESP Sub-toggles (Blox Strike style)
local ESPBoxToggle = Instance.new("TextButton")
ESPBoxToggle.Size = UDim2.new(1, -20, 0, 22)
ESPBoxToggle.Position = UDim2.new(0, 10, 0, 128)
ESPBoxToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPBoxToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBoxToggle.Text = "📦 Box: ON"
ESPBoxToggle.Font = Enum.Font.SourceSans
ESPBoxToggle.TextSize = 11
ESPBoxToggle.Parent = Frame

local ESPHealthToggle = Instance.new("TextButton")
ESPHealthToggle.Size = UDim2.new(1, -20, 0, 22)
ESPHealthToggle.Position = UDim2.new(0, 10, 0, 152)
ESPHealthToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPHealthToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPHealthToggle.Text = "💚 Health: ON"
ESPHealthToggle.Font = Enum.Font.SourceSans
ESPHealthToggle.TextSize = 11
ESPHealthToggle.Parent = Frame

local ESPNameToggle = Instance.new("TextButton")
ESPNameToggle.Size = UDim2.new(1, -20, 0, 22)
ESPNameToggle.Position = UDim2.new(0, 10, 0, 176)
ESPNameToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPNameToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPNameToggle.Text = "📝 Name: ON"
ESPNameToggle.Font = Enum.Font.SourceSans
ESPNameToggle.TextSize = 11
ESPNameToggle.Parent = Frame

local ESPDistToggle = Instance.new("TextButton")
ESPDistToggle.Size = UDim2.new(1, -20, 0, 22)
ESPDistToggle.Position = UDim2.new(0, 10, 0, 200)
ESPDistToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPDistToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPDistToggle.Text = "📏 Distance: ON"
ESPDistToggle.Font = Enum.Font.SourceSans
ESPDistToggle.TextSize = 11
ESPDistToggle.Parent = Frame

-- FOV Toggle
local FOVToggleBtn = Instance.new("TextButton")
FOVToggleBtn.Size = UDim2.new(1, -20, 0, 28)
FOVToggleBtn.Position = UDim2.new(0, 10, 0, 227)
FOVToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggleBtn.Text = "⭕ FOV Circle: OFF"
FOVToggleBtn.Font = Enum.Font.SourceSans
FOVToggleBtn.TextSize = 12
FOVToggleBtn.Parent = Frame

-- FOV Size Controls
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.3, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 10, 0, 260)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.Text = "FOV: " .. FOVRadius
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.TextSize = 11
FOVLabel.Parent = Frame

local FOVIncrease = Instance.new("TextButton")
FOVIncrease.Size = UDim2.new(0, 30, 0, 20)
FOVIncrease.Position = UDim2.new(0.35, 0, 0, 260)
FOVIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVIncrease.Text = "+"
FOVIncrease.Font = Enum.Font.SourceSansBold
FOVIncrease.TextSize = 14
FOVIncrease.Parent = Frame

local FOVDecrease = Instance.new("TextButton")
FOVDecrease.Size = UDim2.new(0, 30, 0, 20)
FOVDecrease.Position = UDim2.new(0.52, 0, 0, 260)
FOVDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVDecrease.Text = "-"
FOVDecrease.Font = Enum.Font.SourceSansBold
FOVDecrease.TextSize = 14
FOVDecrease.Parent = Frame

-- Smoothness Slider
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.3, 0, 0, 20)
SmoothLabel.Position = UDim2.new(0, 10, 0, 285)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SmoothLabel.Text = "Smooth: " .. Smoothness
SmoothLabel.Font = Enum.Font.SourceSans
SmoothLabel.TextSize = 11
SmoothLabel.Parent = Frame

local SmoothIncrease = Instance.new("TextButton")
SmoothIncrease.Size = UDim2.new(0, 30, 0, 20)
SmoothIncrease.Position = UDim2.new(0.35, 0, 0, 285)
SmoothIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SmoothIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothIncrease.Text = "+"
SmoothIncrease.Font = Enum.Font.SourceSansBold
SmoothIncrease.TextSize = 14
SmoothIncrease.Parent = Frame

local SmoothDecrease = Instance.new("TextButton")
SmoothDecrease.Size = UDim2.new(0, 30, 0, 20)
SmoothDecrease.Position = UDim2.new(0.52, 0, 0, 285)
SmoothDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SmoothDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothDecrease.Text = "-"
SmoothDecrease.Font = Enum.Font.SourceSansBold
SmoothDecrease.TextSize = 14
SmoothDecrease.Parent = Frame

-- Info
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 30)
Info.Position = UDim2.new(0, 10, 0, 312)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.Text = "Silent Aim: Bullets redirect to head"
Info.Font = Enum.Font.SourceSans
Info.TextSize = 10
Info.Parent = Frame

-- Terminate
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 25)
CloseBtn.Position = UDim2.new(0, 10, 0, 342)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 25, 25)
CloseBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
CloseBtn.Text = "TERMINATE"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 11
CloseBtn.Parent = Frame

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 100, 100)
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.5
FOVCircle.Visible = false
FOVCircle.Radius = FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Target lock indicator
local LockIndicator = Drawing.new("Circle")
LockIndicator.Color = Color3.fromRGB(0, 255, 0)
LockIndicator.Thickness = 2
LockIndicator.Transparency = 0.8
LockIndicator.Visible = false
LockIndicator.Radius = 10
LockIndicator.Filled = true

-- =============================================
-- BLOX STRIKE STYLE ESP
-- =============================================
local function createESP(player)
    local esp = {
        -- Box (Blox Strike style: thick outline + thin colored inner)
        boxOutline = Drawing.new("Square"),
        box = Drawing.new("Square"),
        
        -- Player info
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        
        -- Health bar (vertical line)
        healthOutline = Drawing.new("Line"),
        healthBar = Drawing.new("Line")
    }
    
    -- Thick black outline
    esp.boxOutline.Thickness = 3
    esp.boxOutline.Filled = false
    esp.boxOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.boxOutline.Visible = false
    
    -- Thin colored inner box
    esp.box.Thickness = 1
    esp.box.Filled = false
    esp.box.Color = Color3.fromRGB(255, 50, 50)
    esp.box.Visible = false
    
    -- Name (centered, white with outline)
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.Color = Color3.fromRGB(255, 255, 255)
    esp.name.Size = 16
    esp.name.Visible = false
    
    -- Distance (centered, gray with outline)
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.Color = Color3.fromRGB(200, 200, 200)
    esp.distance.Size = 13
    esp.distance.Visible = false
    
    -- Health bar outline (thick black line)
    esp.healthOutline.Thickness = 3
    esp.healthOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.healthOutline.Visible = false
    
    -- Health bar fill (colored based on health)
    esp.healthBar.Thickness = 1
    esp.healthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.healthBar.Visible = false
    
    ESPBoxes[player] = esp
    return esp
end

local function updateESP()
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    for player, esp in pairs(ESPBoxes) do
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                for _, drawing in pairs(esp) do
                    if drawing then drawing.Visible = false end
                end
                return
            end
            
            if TeamCheck and player.Team == LocalPlayer.Team then
                for _, drawing in pairs(esp) do
                    if drawing then drawing.Visible = false end
                end
                return
            end
            
            local char = player.Character
            local humanoid = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if not root or not head then return end
            
            -- Get screen positions
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if not rootOnScreen then
                for _, drawing in pairs(esp) do
                    if drawing then drawing.Visible = false end
                end
                return
            end
            
            -- Calculate box dimensions (Blox Strike method)
            local boxHeight = math.abs(headPos.Y - legPos.Y)
            local boxWidth = boxHeight / 2
            local boxX = rootPos.X - boxWidth / 2
            local boxY = headPos.Y
            
            -- Distance
            local distance = localRoot and math.floor((localRoot.Position - root.Position).Magnitude) or 0
            
            -- Health (Blox Strike color formula)
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local healthColor = Color3.fromRGB(1 - healthPercent, healthPercent, 0)
            
            -- Box
            if EspBox then
                esp.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
                esp.boxOutline.Position = Vector2.new(boxX, boxY)
                esp.boxOutline.Visible = true
                
                esp.box.Size = Vector2.new(boxWidth, boxHeight)
                esp.box.Position = Vector2.new(boxX, boxY)
                esp.box.Color = healthColor
                esp.box.Visible = true
            else
                esp.boxOutline.Visible = false
                esp.box.Visible = false
            end
            
            -- Health bar
            if EspHealth then
                local barX = boxX - 6
                esp.healthOutline.From = Vector2.new(barX, boxY - 1)
                esp.healthOutline.To = Vector2.new(barX, boxY + boxHeight + 1)
                esp.healthOutline.Visible = true
                
                esp.healthBar.From = Vector2.new(barX, boxY + boxHeight)
                esp.healthBar.To = Vector2.new(barX, boxY + boxHeight - (boxHeight * healthPercent))
                esp.healthBar.Color = healthColor
                esp.healthBar.Visible = true
            else
                esp.healthOutline.Visible = false
                esp.healthBar.Visible = false
            end
            
            -- Name
            if EspName then
                esp.name.Text = player.Name
                esp.name.Position = Vector2.new(rootPos.X, boxY - 20)
                esp.name.Visible = true
            else
                esp.name.Visible = false
            end
            
            -- Distance
            if EspDistance then
                esp.distance.Text = "[" .. distance .. "m]"
                esp.distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 2)
                esp.distance.Visible = true
            else
                esp.distance.Visible = false
            end
        end)
    end
end

local function removeESP(player)
    if ESPBoxes[player] then
        for _, drawing in pairs(ESPBoxes[player]) do
            if drawing then
                pcall(function() drawing:Remove() end)
            end
        end
        ESPBoxes[player] = nil
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- =============================================
-- BUTTON CONTROLS
-- =============================================
SilentAimToggle.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    SilentAimToggle.Text = "🤫 Silent Aim: " .. (SilentAimEnabled and "ON" or "OFF")
    SilentAimToggle.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(60, 60, 60)
end)

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = "👁️ ESP: " .. (ESPEnabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESPEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(60, 60, 60)
    if not ESPEnabled then
        for player, esp in pairs(ESPBoxes) do
            for _, drawing in pairs(esp) do
                if drawing then drawing.Visible = false end
            end
        end
    end
end)

ESPBoxToggle.MouseButton1Click:Connect(function()
    EspBox = not EspBox
    ESPBoxToggle.Text = "📦 Box: " .. (EspBox and "ON" or "OFF")
    ESPBoxToggle.BackgroundColor3 = EspBox and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(50, 50, 50)
end)

ESPHealthToggle.MouseButton1Click:Connect(function()
    EspHealth = not EspHealth
    ESPHealthToggle.Text = "💚 Health: " .. (EspHealth and "ON" or "OFF")
    ESPHealthToggle.BackgroundColor3 = EspHealth and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(50, 50, 50)
end)

ESPNameToggle.MouseButton1Click:Connect(function()
    EspName = not EspName
    ESPNameToggle.Text = "📝 Name: " .. (EspName and "ON" or "OFF")
    ESPNameToggle.BackgroundColor3 = EspName and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(50, 50, 50)
end)

ESPDistToggle.MouseButton1Click:Connect(function()
    EspDistance = not EspDistance
    ESPDistToggle.Text = "📏 Distance: " .. (EspDistance and "ON" or "OFF")
    ESPDistToggle.BackgroundColor3 = EspDistance and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(50, 50, 50)
end)

FOVToggleBtn.MouseButton1Click:Connect(function()
    ShowFOV = not ShowFOV
    FOVCircle.Visible = ShowFOV
    FOVToggleBtn.Text = "⭕ FOV Circle: " .. (ShowFOV and "ON" or "OFF")
    FOVToggleBtn.BackgroundColor3 = ShowFOV and Color3.fromRGB(30, 100, 150) or Color3.fromRGB(50, 50, 50)
end)

FOVIncrease.MouseButton1Click:Connect(function()
    FOVRadius = math.min(FOVRadius + 25, 500)
    FOVCircle.Radius = FOVRadius
    FOVLabel.Text = "FOV: " .. FOVRadius
end)

FOVDecrease.MouseButton1Click:Connect(function()
    FOVRadius = math.max(FOVRadius - 25, 25)
    FOVCircle.Radius = FOVRadius
    FOVLabel.Text = "FOV: " .. FOVRadius
end)

SmoothIncrease.MouseButton1Click:Connect(function()
    Smoothness = math.min(Smoothness + 0.05, 1)
    SmoothLabel.Text = "Smooth: " .. string.format("%.2f", Smoothness)
end)

SmoothDecrease.MouseButton1Click:Connect(function()
    Smoothness = math.max(Smoothness - 0.05, 0.05)
    SmoothLabel.Text = "Smooth: " .. string.format("%.2f", Smoothness)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    for player, esp in pairs(ESPBoxes) do
        removeESP(player)
    end
    FOVCircle:Remove()
    LockIndicator:Remove()
    ScreenGui:Destroy()
end)

-- =============================================
-- FOV CIRCLE UPDATER
-- =============================================
task.spawn(function()
    while ScriptActive do
        if ShowFOV then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        task.wait(0.1)
    end
end)

-- =============================================
-- SILENT AIM & TARGET DETECTION
-- =============================================
local function getClosestEnemy()
    local closest = nil
    local closestDist = FOVRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health <= 0 then continue end
            if TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = char:FindFirstChild(AimPart) or char:FindFirstChild("Head")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = {
                            player = player, 
                            screenPos = screenPos, 
                            worldPos = targetPart.Position,
                            character = char,
                            part = targetPart
                        }
                    end
                end
            end
        end
    end
    return closest
end

-- Silent Aim Implementation
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not ScriptActive then return oldIndex(self, key) end
    
    if SilentAimEnabled and key == "Hit" then
        local target = getClosestEnemy()
        if target and target.part then
            -- Redirect bullet to head
            return target.part.Position
        end
    end
    
    return oldIndex(self, key)
end)

-- Mouse movement aim assist (as backup)
task.spawn(function()
    while ScriptActive do
        if AimbotEnabled and not SilentAimEnabled then
            local target = getClosestEnemy()
            if target then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local moveX = (target.screenPos.X - center.X) * Smoothness
                local moveY = (target.screenPos.Y - center.Y) * Smoothness
                mousemoverel(moveX, moveY)
                Status.Text = "● Aiming: " .. target.player.Name
                Status.TextColor3 = Color3.fromRGB(255, 200, 0)
                TargetLocked = true
            else
                Status.Text = "● No target"
                Status.TextColor3 = Color3.fromRGB(0, 255, 0)
                TargetLocked = false
            end
        elseif SilentAimEnabled then
            local target = getClosestEnemy()
            if target then
                Status.Text = "● Silent Aim: " .. target.player.Name
                Status.TextColor3 = Color3.fromRGB(0, 255, 100)
                TargetLocked = true
            else
                Status.Text = "● Ready"
                Status.TextColor3 = Color3.fromRGB(0, 255, 0)
                TargetLocked = false
            end
        end
        task.wait()
    end
end)

-- Target lock indicator
task.spawn(function()
    while ScriptActive do
        if TargetLocked then
            local target = getClosestEnemy()
            if target and target.screenPos then
                LockIndicator.Visible = true
                LockIndicator.Position = Vector2.new(target.screenPos.X, target.screenPos.Y)
            else
                LockIndicator.Visible = false
            end
        else
            LockIndicator.Visible = false
        end
        task.wait(0.05)
    end
end)

-- ESP update loop
task.spawn(function()
    while ScriptActive do
        if ESPEnabled then
            updateESP()
        end
        task.wait()
    end
end)

-- Cleanup on leave
LocalPlayer.OnTeleport:Connect(function()
    ScriptActive = false
end)

print("╔══════════════════════════════════════╗")
print("║  SILENT AIM + BLOX STRIKE ESP      ║")
print("║  - Silent Aim: Bullets hit head    ║")
print("║  - Blox Strike Style Box ESP       ║")
print("║  - Health bars & distance          ║")
print("║  - Adjustable FOV & Smoothness     ║")
print("╚══════════════════════════════════════╝")
