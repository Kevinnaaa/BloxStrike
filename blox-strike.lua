--[[
    UNIVERSAL FPS - BLOCK STRIKE STYLE ESP + SILENT AIM
    Adapted ESP boxes & team detection for any FPS
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
local SilentAimEnabled = true
local ShowFOV = false
local TargetLocked = false

-- ESP Options (Blox Strike style)
local EspBox = true
local EspName = true
local EspHealth = true
local EspDistance = true
local EspTracers = false

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

-- ESP Sub-toggles
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

local ESPTracerToggle = Instance.new("TextButton")
ESPTracerToggle.Size = UDim2.new(1, -20, 0, 22)
ESPTracerToggle.Position = UDim2.new(0, 10, 0, 224)
ESPTracerToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ESPTracerToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTracerToggle.Text = "➖ Tracers: OFF"
ESPTracerToggle.Font = Enum.Font.SourceSans
ESPTracerToggle.TextSize = 11
ESPTracerToggle.Parent = Frame

-- FOV Toggle
local FOVToggleBtn = Instance.new("TextButton")
FOVToggleBtn.Size = UDim2.new(1, -20, 0, 28)
FOVToggleBtn.Position = UDim2.new(0, 10, 0, 251)
FOVToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggleBtn.Text = "⭕ FOV Circle: OFF"
FOVToggleBtn.Font = Enum.Font.SourceSans
FOVToggleBtn.TextSize = 12
FOVToggleBtn.Parent = Frame

-- Info
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 30)
Info.Position = UDim2.new(0, 10, 0, 284)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.Text = "FOV: " .. FOVRadius .. " | Smooth: " .. Smoothness
Info.Font = Enum.Font.SourceSans
Info.TextSize = 10
Info.Parent = Frame

-- Terminate
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 25)
CloseBtn.Position = UDim2.new(0, 10, 0, 320)
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
-- TEAM DETECTION (Blox Strike style)
-- =============================================
local function getEnemyTeam()
    -- Try common team properties
    if LocalPlayer.Team then
        local playerTeam = LocalPlayer.Team
        local teams = game:GetService("Teams"):GetTeams()
        for _, team in pairs(teams) do
            if team ~= playerTeam then
                return team
            end
        end
    end
    
    -- Try team color detection
    if LocalPlayer.TeamColor then
        local playerColor = LocalPlayer.TeamColor
        -- Return opposite team color logic
        return nil -- Will fall through to no team check
    end
    
    return nil
end

local function isEnemy(player)
    if not TeamCheck then return true end
    if player == LocalPlayer then return false end
    
    -- Check team property
    if LocalPlayer.Team and player.Team then
        return player.Team ~= LocalPlayer.Team
    end
    
    -- Check team color
    if LocalPlayer.TeamColor and player.TeamColor then
        return player.TeamColor ~= LocalPlayer.TeamColor
    end
    
    return true -- Default to enemy if no team system
end

local function isEnemyAlive(player)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

-- =============================================
-- BLOX STRIKE STYLE ESP
-- =============================================
local function createESP(player)
    local esp = {
        -- Main box (Blox Strike style)
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        
        -- Player info
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        
        -- Health bar (vertical)
        HealthOutline = Drawing.new("Line"),
        HealthBar = Drawing.new("Line"),
        
        -- Tracer line
        Tracer = Drawing.new("Line")
    }
    
    -- Box outline (thick black border)
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.BoxOutline.Visible = false
    
    -- Box inner (colored)
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255, 50, 50)
    esp.Box.Visible = false
    
    -- Name
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 16
    esp.Name.Visible = false
    
    -- Distance
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 13
    esp.Distance.Visible = false
    
    -- Health bar outline
    esp.HealthOutline.Thickness = 3
    esp.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
    esp.HealthOutline.Visible = false
    
    -- Health bar fill
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Visible = false
    
    -- Tracer
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.5
    esp.Tracer.Color = Color3.fromRGB(255, 50, 50)
    esp.Tracer.Visible = false
    
    ESPBoxes[player] = esp
    return esp
end

local function updateESP()
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    
    for player, esp in pairs(ESPBoxes) do
        pcall(function()
            if not isEnemyAlive(player) then
                for _, drawing in pairs(esp) do
                    if drawing then drawing.Visible = false end
                end
                return
            end
            
            if not isEnemy(player) then
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
            
            -- Distance calculation
            local distance = localRoot and math.floor((localRoot.Position - root.Position).Magnitude) or 0
            
            -- Health calculation
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local healthColor = Color3.fromRGB(1 - healthPercent, healthPercent, 0)
            
            -- Update box
            if EspBox then
                esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                esp.BoxOutline.Visible = true
                
                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box.Position = Vector2.new(boxX, boxY)
                esp.Box.Color = healthColor
                esp.Box.Visible = true
            else
                esp.BoxOutline.Visible = false
                esp.Box.Visible = false
            end
            
            -- Update health bar
            if EspHealth then
                local barX = boxX - 6
                esp.HealthOutline.From = Vector2.new(barX, boxY - 1)
                esp.HealthOutline.To = Vector2.new(barX, boxY + boxHeight + 1)
                esp.HealthOutline.Visible = true
                
                esp.HealthBar.From = Vector2.new(barX, boxY + boxHeight)
                esp.HealthBar.To = Vector2.new(barX, boxY + boxHeight - (boxHeight * healthPercent))
                esp.HealthBar.Color = healthColor
                esp.HealthBar.Visible = true
            else
                esp.HealthOutline.Visible = false
                esp.HealthBar.Visible = false
            end
            
            -- Update name
            if EspName then
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(rootPos.X, boxY - 20)
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            -- Update distance
            if EspDistance then
                esp.Distance.Text = "[" .. distance .. "m]"
                esp.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 2)
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
            
            -- Update tracer
            if EspTracers and localRoot then
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                esp.Tracer.To = Vector2.new(rootPos.X, legPos.Y)
                esp.Tracer.Color = healthColor
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
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

ESPTracerToggle.MouseButton1Click:Connect(function()
    EspTracers = not EspTracers
    ESPTracerToggle.Text = "➖ Tracers: " .. (EspTracers and "ON" or "OFF")
    ESPTracerToggle.BackgroundColor3 = EspTracers and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(50, 50, 50)
end)

FOVToggleBtn.MouseButton1Click:Connect(function()
    ShowFOV = not ShowFOV
    FOVCircle.Visible = ShowFOV
    FOVToggleBtn.Text = "⭕ FOV Circle: " .. (ShowFOV and "ON" or "OFF")
    FOVToggleBtn.BackgroundColor3 = ShowFOV and Color3.fromRGB(30, 100, 150) or Color3.fromRGB(50, 50, 50)
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
-- SILENT AIM & TARGET DETECTION
-- =============================================
local function getClosestEnemy()
    local closest = nil
    local closestDist = FOVRadius
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isEnemy(player) then
            local char = player.Character
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health <= 0 then continue end
            
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
            return target.part.Position
        end
    end
    
    return oldIndex(self, key)
end)

-- Target status updater
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

-- FOV Circle updater
task.spawn(function()
    while ScriptActive do
        if ShowFOV then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        task.wait(0.1)
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

-- Cleanup
LocalPlayer.OnTeleport:Connect(function()
    ScriptActive = false
end)

print("╔══════════════════════════════════════╗")
print("║  BLOX STRIKE STYLE ESP + SILENT AIM║")
print("║  - Team detection adapted          ║")
print("║  - Box, Health, Name, Distance    ║")
print("║  - Tracers option available        ║")
print("║  - Silent aim redirects to head   ║")
print("╚══════════════════════════════════════╝")
