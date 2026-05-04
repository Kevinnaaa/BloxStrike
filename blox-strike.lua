--[[
    UNIVERSAL FPS - AUTO AIMBOT + ESP (No key needed)
    Always aims at nearest enemy + ESP
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

local ESPBoxes = {}
local ESPColor = Color3.fromRGB(255, 50, 50)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 260)
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
Title.Text = "🎯 AUTO AIM + ESP"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 20)
Status.Position = UDim2.new(0, 10, 0, 35)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.Text = "● Auto Aim Active"
Status.Font = Enum.Font.SourceSans
Status.TextSize = 11
Status.Parent = Frame

local Div1 = Instance.new("Frame")
Div1.Size = UDim2.new(1, 0, 0, 1)
Div1.Position = UDim2.new(0, 0, 0, 58)
Div1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Div1.BorderSizePixel = 0
Div1.Parent = Frame

-- Aimbot Toggle
local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(1, -20, 0, 28)
AimToggle.Position = UDim2.new(0, 10, 0, 65)
AimToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
AimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimToggle.Text = "🎯 Aimbot: ON"
AimToggle.Font = Enum.Font.SourceSansBold
AimToggle.TextSize = 12
AimToggle.Parent = Frame

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(1, -20, 0, 28)
ESPToggle.Position = UDim2.new(0, 10, 0, 98)
ESPToggle.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Text = "👁️ ESP: ON"
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

-- Info
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 40)
Info.Position = UDim2.new(0, 10, 0, 168)
Info.BackgroundTransparency = 1
Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.Text = "Auto aims at nearest enemy\nFOV: " .. FOVRadius .. " | Smooth: " .. Smoothness
Info.Font = Enum.Font.SourceSans
Info.TextSize = 11
Info.Parent = Frame

-- Terminate
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 25)
CloseBtn.Position = UDim2.new(0, 10, 0, 220)
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

-- =============================================
-- ESP FUNCTIONS
-- =============================================
local function createESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthFill = Drawing.new("Square")
    }
    
    esp.Box.Color = Color3.fromRGB(255, 50, 50)
    esp.Box.Thickness = 1
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Visible = false
    
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Size = 13
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Visible = false
    
    esp.HealthBar.Color = Color3.fromRGB(50, 50, 50)
    esp.HealthBar.Thickness = 1
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false
    
    esp.HealthFill.Color = Color3.fromRGB(50, 255, 50)
    esp.HealthFill.Thickness = 1
    esp.HealthFill.Filled = true
    esp.HealthFill.Visible = false
    
    ESPBoxes[player] = esp
    return esp
end

local function updateESP()
    for player, esp in pairs(ESPBoxes) do
        pcall(function()
            if not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthFill.Visible = false
                return
            end
            
            if TeamCheck and player.Team == LocalPlayer.Team then return end
            
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
            local head = char:FindFirstChild("Head")
            if not root or not head then return end
            
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            
            if rootOnScreen then
                local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                local boxHeight = (headPos.Y - rootPos.Y) * 0.6
                local boxWidth = boxHeight * 0.5
                local boxX = rootPos.X - boxWidth / 2
                local boxY = rootPos.Y - boxHeight * 0.2
                
                esp.Box.Visible = true
                esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                esp.Box.Position = Vector2.new(boxX, boxY)
                
                esp.Name.Visible = true
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(rootPos.X, boxY - 15)
                
                esp.Distance.Visible = true
                esp.Distance.Text = math.floor(distance) .. "s"
                esp.Distance.Position = Vector2.new(rootPos.X, boxY + boxHeight + 5)
                
                local health = char.Humanoid.Health / char.Humanoid.MaxHealth
                esp.HealthBar.Visible = true
                esp.HealthBar.Size = Vector2.new(2, boxHeight)
                esp.HealthBar.Position = Vector2.new(boxX - 4, boxY)
                
                esp.HealthFill.Visible = true
                esp.HealthFill.Size = Vector2.new(2, boxHeight * health)
                esp.HealthFill.Position = Vector2.new(boxX - 4, boxY + boxHeight * (1 - health))
                esp.HealthFill.Color = health > 0.5 and Color3.fromRGB(50, 255, 50) or (health > 0.25 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.Distance.Visible = false
                esp.HealthBar.Visible = false
                esp.HealthFill.Visible = false
            end
        end)
    end
end

local function removeESP(player)
    if ESPBoxes[player] then
        ESPBoxes[player].Box:Remove()
        ESPBoxes[player].Name:Remove()
        ESPBoxes[player].Distance:Remove()
        ESPBoxes[player].HealthBar:Remove()
        ESPBoxes[player].HealthFill:Remove()
        ESPBoxes[player] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then createESP(player) end
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

-- =============================================
-- BUTTONS
-- =============================================
AimToggle.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimToggle.Text = "🎯 Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
    AimToggle.BackgroundColor3 = AimbotEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(60, 60, 60)
    Status.Text = AimbotEnabled and "● Auto Aim Active" or "● Disabled"
end)

ESPToggle.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPToggle.Text = "👁️ ESP: " .. (ESPEnabled and "ON" or "OFF")
    ESPToggle.BackgroundColor3 = ESPEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(60, 60, 60)
end)

FOVToggleBtn.MouseButton1Click:Connect(function()
    FOVCircle.Visible = not FOVCircle.Visible
    FOVToggleBtn.Text = "⭕ FOV Circle: " .. (FOVCircle.Visible and "ON" or "OFF")
    FOVToggleBtn.BackgroundColor3 = FOVCircle.Visible and Color3.fromRGB(30, 100, 150) or Color3.fromRGB(50, 50, 50)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScriptActive = false
    for player, esp in pairs(ESPBoxes) do removeESP(player) end
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

-- FOV Circle
task.spawn(function()
    while ScriptActive do
        if FOVCircle.Visible then
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        task.wait(0.1)
    end
end)

-- Get closest enemy
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
                        closest = {player = player, screenPos = screenPos}
                    end
                end
            end
        end
    end
    return closest
end

-- Auto Aimbot (always active - no key needed)
task.spawn(function()
    while ScriptActive do
        if AimbotEnabled then
            local target = getClosestEnemy()
            if target then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local moveX = (target.screenPos.X - center.X) * Smoothness
                local moveY = (target.screenPos.Y - center.Y) * Smoothness
                mousemoverel(moveX, moveY)
                Status.Text = "● Aiming: " .. target.player.Name
                Status.TextColor3 = Color3.fromRGB(255, 200, 0)
            else
                Status.Text = "● No target"
                Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
        task.wait()
    end
end)

-- ESP loop
task.spawn(function()
    while ScriptActive do
        if ESPEnabled then updateESP() end
        task.wait()
    end
end)

print("Auto Aimbot + ESP Ready! No key needed.")
