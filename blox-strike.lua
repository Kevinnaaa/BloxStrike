--[[
    UNIVERSAL FPS - SILENT AIMBOT + ENHANCED ESP
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

local ESPBoxes = {}
local ESPColor = Color3.fromRGB(255, 50, 50)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 320)
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

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, -20, 0, 28)
ESPToggle.Position = UDim2.new(0, 10, 0, 98)
ESPToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Text = "👁️ ESP Box: ON"
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.TextSize = 12
ESPToggle.Parent = Frame

-- FOV Toggle
local FOVToggleBtn = Instance.new("TextButton")
FOVToggleBtn.Size = UDim2.new(1, -20, 0, 28)
FOVToggleBtn.Position = UDim2.new(0, 10, 0, 131)
FOVToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggleBtn.Text = "⭕ FOV Circle: OFF"
FOVToggleBtn.Font = Enum.Font.SourceSans
FOVToggleBtn.TextSize = 12
FOVToggleBtn.Parent = Frame

-- FOV Size Controls
local FOVLabel = Instance.new("TextLabel")
FOVLabel.Size = UDim2.new(0.3, 0, 0, 20)
FOVLabel.Position = UDim2.new(0, 10, 0, 164)
FOVLabel.BackgroundTransparency = 1
FOVLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FOVLabel.Text = "FOV: " .. FOVRadius
FOVLabel.Font = Enum.Font.SourceSans
FOVLabel.TextSize = 11
FOVLabel.Parent = Frame

local FOVIncrease = Instance.new("TextButton")
FOVIncrease.Size = UDim2.new(0, 30, 0, 20)
FOVIncrease.Position = UDim2.new(0.35, 0, 0, 164)
FOVIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVIncrease.Text = "+"
FOVIncrease.Font = Enum.Font.SourceSansBold
FOVIncrease.TextSize = 14
FOVIncrease.Parent = Frame

local FOVDecrease = Instance.new("TextButton")
FOVDecrease.Size = UDim2.new(0, 30, 0, 20)
FOVDecrease.Position = UDim2.new(0.52, 0, 0, 164)
FOVDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FOVDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVDecrease.Text = "-"
FOVDecrease.Font = Enum.Font.SourceSansBold
FOVDecrease.TextSize = 14
FOVDecrease.Parent = Frame

-- Smoothness Slider
local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Size = UDim2.new(0.3, 0, 0, 20)
SmoothLabel.Position = UDim2.new(0, 10, 0, 189)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SmoothLabel.Text = "Smooth: " .. Smoothness
SmoothLabel.Font = Enum.Font.SourceSans
SmoothLabel.TextSize = 11
SmoothLabel.Parent = Frame

local SmoothIncrease = Instance.new("TextButton")
SmoothIncrease.Size = UDim2.new(0, 30, 0, 20)
SmoothIncrease.Position = UDim2.new(0.35, 0, 0, 189)
SmoothIncrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SmoothIncrease.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothIncrease.Text = "+"
SmoothIncrease.Font = Enum.Font.SourceSansBold
SmoothIncrease.TextSize = 14
SmoothIncrease.Parent = Frame

local SmoothDecrease = Instance.new("TextButton")
SmoothDecrease.Size = UDim2.new(0, 30, 0, 20)
SmoothDecrease.Position = UDim2.new(0.52, 0, 0, 189)
SmoothDecrease.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SmoothDecrease.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothDecrease.Text = "-"
SmoothDecrease.Font = Enum.Font.SourceSansBold
SmoothDecrease.TextSize = 14
SmoothDecrease.Parent = Frame

-- Info
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 50)
Info.Position = UDim2.new(0, 10, 0, 218)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.Text = "Silent Aim: Bullets redirect to head\nAuto locks nearest enemy in FOV"
Info.Font = Enum.Font.SourceSans
Info.TextSize = 10
Info.Parent = Frame

-- Terminate
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 25)
CloseBtn.Position = UDim2.new(0, 10, 0, 278)
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
-- ENHANCED ESP WITH PROPER BOXES
-- =============================================
local function createESP(player)
    local esp = {
        -- Main 3D Box
        BoxOutline = Drawing.new("Square"),
        BoxFill = Drawing.new("Square"),
        
        -- Corner boxes for better visibility
        CornerTopLeft = Drawing.new("Line"),
        CornerTopRight = Drawing.new("Line"),
        CornerBottomLeft = Drawing.new("Line"),
        CornerBottomRight = Drawing.new("Line"),
        
        -- Player info
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthText = Drawing.new("Text"),
        
        -- Health bar
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        
        -- Tracer line
        Tracer = Drawing.new("Line")
    }
    
    -- Main box
    esp.BoxOutline.Color = Color3.fromRGB(255, 50, 50)
    esp.BoxOutline.Thickness = 1.5
    esp.BoxOutline.Transparency = 1
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Visible = false
    
    esp.BoxFill.Color = Color3.fromRGB(255, 50, 50)
    esp.BoxFill.Thickness = 1
    esp.BoxFill.Transparency = 0.9
    esp.BoxFill.Filled = true
    esp.BoxFill.Visible = false
    
    -- Corner lines
    for _, corner in pairs({esp.CornerTopLeft, esp.CornerTopRight, esp.CornerBottomLeft, esp.CornerBottomRight}) do
        corner.Color = Color3.fromRGB(255, 255, 255)
        corner.Thickness = 2
        corner.Transparency = 1
        corner.Visible = false
    end
    
    -- Name
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Name.Visible = false
    
    -- Distance
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    esp.Distance.Visible = false
    
    -- Health text
    esp.HealthText.Color = Color3.fromRGB(255, 255, 255)
    esp.HealthText.Size = 11
    esp.HealthText.Center = true
    esp.HealthText.Outline = true
    esp.HealthText.Visible = false
    
    -- Health bar
    esp.HealthBarBG.Color = Color3.fromRGB(30, 30, 30)
    esp.HealthBarBG.Thickness = 1
    esp.HealthBarBG.Filled = true
    esp.HealthBarBG.Visible = false
    
    esp.HealthBar.Color = Color3.fromRGB(50, 255, 50)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false
    
    -- Tracer line
    esp.Tracer.Color = Color3.fromRGB(255, 50, 50)
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.7
    esp.Tracer.Visible = false
    
    ESPBoxes[player] = esp
    return esp
end

local function updateESP()
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    for player, esp in pairs(ESPBoxes) do
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                -- Hide all elements
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
            
            -- Get positions
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if not rootOnScreen then
                for _, drawing in pairs(esp) do
                    if drawing then drawing.Visible = false end
                end
                return
            end
            
            -- Calculate box dimensions
            local boxHeight = math.abs(headPos.Y - footPos.Y)
            local boxWidth = boxHeight * 0.4
            local boxX = rootPos.X - boxWidth / 2
            local boxY = headPos.Y
            
            -- Distance
            local distance = localRoot and (localRoot.Position - root.Position).Magnitude or 0
            
            -- Health
            local health = humanoid.Health / humanoid.MaxHealth
            local healthPercent = math.floor(health * 100)
            
            -- Color based on health
            local healthColor = health > 0.7 and Color3.fromRGB(50, 255, 50) or 
                              (health > 0.3 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
            
            -- Update main box
            esp.BoxOutline.Visible = true
            esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            esp.BoxOutline.Position = Vector2.new(boxX, boxY)
            esp.BoxOutline.Color = healthColor
            
            esp.BoxFill.Visible = true
            esp.BoxFill.Size = Vector2.new(boxWidth, boxHeight)
            esp.BoxFill.Position = Vector2.new(boxX, boxY)
            esp.BoxFill.Color = healthColor
            
            -- Corner lines (for premium look)
            local cornerLength = boxWidth * 0.25
            
            -- Top left corner
            esp.CornerTopLeft.Visible = true
            esp.CornerTopLeft.From = Vector2.new(boxX, boxY + cornerLength)
            esp.CornerTopLeft.To = Vector2.new(boxX, boxY)
            esp.CornerTopLeft.Color = Color3.fromRGB(255, 255, 255)
            
            local cornerTL2 = Drawing.new("Line")
            cornerTL2.Visible = true
            cornerTL2.From = Vector2.new(boxX, boxY)
            cornerTL2.To = Vector2.new(boxX + cornerLength, boxY)
            cornerTL2.Color = Color3.fromRGB(255, 255, 255)
            cornerTL2.Thickness = 2
            
            -- Top right corner
            esp.CornerTopRight.Visible = true
            esp.CornerTopRight.From = Vector2.new(boxX + boxWidth, boxY)
            esp.CornerTopRight.To = Vector2.new(boxX + boxWidth - cornerLength, boxY)
            esp.CornerTopRight.Color = Color3.fromRGB(255, 255, 255)
            
            local cornerTR2 = Drawing.new("Line")
            cornerTR2.Visible = true
            cornerTR2.From = Vector2.new(boxX + boxWidth, boxY)
            cornerTR2.To = Vector2.new(boxX + boxWidth, boxY + cornerLength)
            cornerTR2.Color = Color3.fromRGB(255, 255, 255)
            cornerTR2.Thickness = 2
            
            -- Bottom left corner
            esp.CornerBottomLeft.Visible = true
            esp.CornerBottomLeft.From = Vector2.new(boxX, boxY + boxHeight - cornerLength)
            esp.CornerBottomLeft.To = Vector2.new(boxX, boxY + boxHeight)
            esp.CornerBottomLeft.Color = Color3.fromRGB(255, 255, 255)
            
            local cornerBL2 = Drawing.new("Line")
            cornerBL2.Visible = true
            cornerBL2.From = Vector2.new(boxX, boxY + boxHeight)
            cornerBL2.To = Vector2.new(boxX + cornerLength, boxY + boxHeight)
            cornerBL2.Color = Color3.fromRGB(255, 255, 255)
            cornerBL2.Thickness = 2
            
            -- Bottom right corner
            esp.CornerBottomRight.Visible = true
            esp.CornerBottomRight.From = Vector2.new(boxX + boxWidth - cornerLength, boxY + boxHeight)
            esp.CornerBottomRight.To = Vector2.new(boxX + boxWidth, boxY + boxHeight)
            esp.CornerBottomRight.Color = Color3.fromRGB(255, 255, 255)
            
            local cornerBR2 = Drawing.new("Line")
            cornerBR2.Visible = true
            cornerBR2.From = Vector2.new(boxX + boxWidth, boxY + boxHeight - cornerLength)
            cornerBR2.To = Vector2.new(boxX + boxWidth, boxY + boxHeight)
            cornerBR2.Color = Color3.fromRGB(255, 255, 255)
            cornerBR2.Thickness = 2
            
            -- Name
            esp.Name.Visible = true
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(rootPos.X, boxY - 20)
            
            -- Distance
            esp.Distance.Visible = true
            esp.Distance.Text = math.floor(distance) .. "m"
            esp.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 15)
            
            -- Health text
            esp.HealthText.Visible = true
            esp.HealthText.Text = healthPercent .. "%"
            esp.HealthText.Position = Vector2.new(boxX + boxWidth + 15, boxY + boxHeight * (1 - health))
            esp.HealthText.Color = healthColor
            
            -- Health bar
            esp.HealthBarBG.Visible = true
            esp.HealthBarBG.Size = Vector2.new(3, boxHeight)
            esp.HealthBarBG.Position = Vector2.new(boxX + boxWidth + 3, boxY)
            
            esp.HealthBar.Visible = true
            esp.HealthBar.Size = Vector2.new(3, boxHeight * health)
            esp.HealthBar.Position = Vector2.new(boxX + boxWidth + 3, boxY + boxHeight * (1 - health))
            esp.HealthBar.Color = healthColor
            
            -- Tracer line
            if localRoot then
                esp.Tracer.Visible = true
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(rootPos.X, footPos.Y)
                esp.Tracer.Color = healthColor
            end
            
            -- Cleanup corner drawings after frame
            task.delay(0.03, function()
                if cornerTL2 then cornerTL2:Remove() end
                if cornerTR2 then cornerTR2:Remove() end
                if cornerBL2 then cornerBL2:Remove() end
                if cornerBR2 then cornerBR2:Remove() end
            end)
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
    ESPToggle.Text = "👁️ ESP Box: " .. (ESPEnabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESPEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(60, 60, 60)
    if not ESPEnabled then
        for player, esp in pairs(ESPBoxes) do
            for _, drawing in pairs(esp) do
                if drawing then drawing.Visible = false end
            end
        end
    end
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
print("║  SILENT AIM + ENHANCED ESP LOADED!  ║")
print("║  - Silent Aim: Bullets hit head    ║")
print("║  - Enhanced 3D Box ESP            ║")
print("║  - Health bars & tracers          ║")
print("║  - Adjustable FOV & Smoothness    ║")
print("╚══════════════════════════════════════╝")
