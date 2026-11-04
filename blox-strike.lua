--============================================================
-- RAYFIELD HEAD TARGETING (AGGRESSIVE INSTANT SNAP)
--============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--============================================================
-- CONFIGURATION & STATE
--============================================================
local TargetingEnabled = true
local FOVEnabled = true
local CrosshairEnabled = true
local GUIOpen = false
local ScriptRunning = true

local FOVRadius = 150
local MaxDistance = 500
local WallCheck = true
local TapLockDuration = 0.15 -- Very short lock for "tap" mode

local CrosshairSize = 6
local CrosshairColor = Color3.fromRGB(255, 0, 0)

local IsAiming = false
local CurrentTarget = nil
local LastTapTime = 0

local camera = Workspace.CurrentCamera
local function getCamera()
    camera = Workspace.CurrentCamera
    return camera
end

--============================================================
-- TEAM IDENTIFICATION (Blox Strike / BRM5 Support)
--============================================================
local function getMyTeam()
    if player.Team then return player.Team end
    local Characters = Workspace:FindFirstChild("Characters")
    if Characters then
        for _, folder in pairs(Characters:GetChildren()) do
            if folder:FindFirstChild(player.Name) then
                return folder.Name
            end
        end
    end
    return nil
end

local function getEnemyPlayers()
    local enemies = {}
    local myTeamName = getMyTeam()
    
    if player.Team then
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and other.Team and other.Team ~= player.Team then
                table.insert(enemies, other)
            end
        end
        return enemies
    end
    
    local Characters = Workspace:FindFirstChild("Characters")
    if Characters then
        for _, folder in pairs(Characters:GetChildren()) do
            if folder.Name ~= myTeamName then
                for _, char in pairs(folder:GetChildren()) do
                    local p = Players:GetPlayerFromCharacter(char)
                    if p then table.insert(enemies, p) end
                end
            end
        end
    end
    return enemies
end

local function isAlive()
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

--============================================================
-- CROSSHAIR & FOV (CoreGui)
--============================================================
local CoreGui = game:GetService("CoreGui")
local CrosshairGui = Instance.new("ScreenGui")
CrosshairGui.Name = "BRM5_AimbotVisuals"
CrosshairGui.ResetOnSpawn = false
CrosshairGui.IgnoreGuiInset = true
CrosshairGui.DisplayOrder = 100
CrosshairGui.Parent = CoreGui

-- RED DOT
local Dot = Instance.new("Frame")
Dot.Name = "RedDot"
Dot.Size = UDim2.fromOffset(CrosshairSize, CrosshairSize)
Dot.AnchorPoint = Vector2.new(0.5, 0.5)
Dot.Position = UDim2.fromScale(0.5, 0.5)
Dot.BackgroundColor3 = CrosshairColor
Dot.BorderSizePixel = 1
Dot.BorderColor3 = Color3.new(0, 0, 0)
Dot.ZIndex = 10
Dot.Parent = CrosshairGui

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = Dot

-- FOV CIRCLE
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = CrosshairGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.new(1, 1, 1)
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.5
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

--============================================================
-- RAYFIELD WINDOW CREATION
--============================================================
local Window = Rayfield:CreateWindow({
    Name = "BRM5 Aimbot",
    LoadingTitle = "Loading Aggressive Aimbot...",
    LoadingSubtitle = "Instant Snap",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", nil)
CombatTab:CreateSection("Aimbot Settings")

CombatTab:CreateToggle({
    Name = "Enable Head Targeting",
    CurrentValue = true,
    Flag = "AimbotToggle",
    Callback = function(Value) TargetingEnabled = Value end,
})

CombatTab:CreateToggle({
    Name = "Wall Check (Visible Only)",
    CurrentValue = true,
    Flag = "WallCheckToggle",
    Callback = function(Value) WallCheck = Value end,
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = FOVRadius,
    Flag = "FOVRadius",
    Callback = function(Value) FOVRadius = Value end,
})

CombatTab:CreateSlider({
    Name = "Tap Lock Duration",
    Range = {0, 100},
    Increment = 10,
    Suffix = "ms",
    CurrentValue = 150,
    Flag = "TapDuration",
    Callback = function(Value) TapLockDuration = Value / 1000 end,
})

-- Visuals Tab
local VisualTab = Window:CreateTab("Visuals", nil)
VisualTab:CreateSection("Crosshair Settings")

VisualTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Flag = "FOVToggle",
    Callback = function(Value) FOVEnabled = Value end,
})

VisualTab:CreateToggle({
    Name = "Show Red Dot",
    CurrentValue = true,
    Flag = "DotToggle",
    Callback = function(Value) CrosshairEnabled = Value end,
})

VisualTab:CreateSlider({
    Name = "Dot Size",
    Range = {2, 20},
    Increment = 1,
    Suffix = "px",
    CurrentValue = CrosshairSize,
    Flag = "DotSize",
    Callback = function(Value) 
        CrosshairSize = Value
        Dot.Size = UDim2.fromOffset(CrosshairSize, CrosshairSize)
    end,
})

VisualTab:CreateColorPicker({
    Name = "Dot Color",
    Color = CrosshairColor,
    Flag = "DotColor",
    Callback = function(Value)
        CrosshairColor = Value
        Dot.BackgroundColor3 = CrosshairColor
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", nil)
SettingsTab:CreateSection("Script")

SettingsTab:CreateButton({
    Name = "Terminate Script",
    Callback = function()
        ScriptRunning = false
        pcall(function() CrosshairGui:Destroy() end)
        Rayfield:Destroy()
    end,
})

--============================================================
-- TARGET VALIDATION & FINDING
--============================================================
local function getTargetCharacter(part)
    if not part then return nil end
    return part:FindFirstAncestorOfClass("Model")
end

local function isVisible(part)
    if not WallCheck then return true end
    if not part or not part.Parent then return false end
    local currentCamera = getCamera()
    if not currentCamera then return false end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character, currentCamera }

    local origin = currentCamera.CFrame.Position
    local direction = part.Position - origin
    local result = Workspace:Raycast(origin, direction, params)

    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestEnemy()
    local currentCamera = getCamera()
    if not currentCamera then return nil end

    local mousePosition = UserInputService:GetMouseLocation()
    local closestHead = nil
    local shortestDistance = FOVRadius

    for _, enemy in ipairs(getEnemyPlayers()) do
        local character = enemy.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and head then
                local worldDistance = (head.Position - currentCamera.CFrame.Position).Magnitude
                if worldDistance <= MaxDistance then
                    local screenPosition, onScreen = currentCamera:WorldToViewportPoint(head.Position)
                    
                    if onScreen and screenPosition.Z > 0 then
                        local headPosition = Vector2.new(screenPosition.X, screenPosition.Y)
                        local distance = (headPosition - mousePosition).Magnitude

                        if distance < shortestDistance and isVisible(head) then
                            shortestDistance = distance
                            closestHead = head
                        end
                    end
                end
            end
        end
    end
    return closestHead
end

--============================================================
-- INPUT LOGIC (Tap & Hold)
--============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not ScriptRunning then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 and TargetingEnabled and isAlive() and not GUIOpen then
        IsAiming = true
        CurrentTarget = getClosestEnemy()
        LastTapTime = tick() 
    end
end)

--============================================================
-- MAIN RENDER LOOP (AGGRESSIVE AIM)
--============================================================
RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    local currentCamera = getCamera()
    if not currentCamera then return end

    -- Check if Rayfield is open (Hide visuals if so)
    if Rayfield and Rayfield.Flags and Rayfield.Flags.ToggleUI then
        GUIOpen = Rayfield.Flags.ToggleUI.Value
    else
        GUIOpen = UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    end

    local isHolding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    
    -- Tap lock timer logic
    if not isHolding then
        local timeSinceTap = tick() - LastTapTime
        if timeSinceTap > TapLockDuration then
            IsAiming = false
            CurrentTarget = nil
        end
    end

    local mousePosition = UserInputService:GetMouseLocation()

    -- Update UI Visuals
    if not GUIOpen then
        FOVCircle.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y)
    end
    FOVCircle.Size = UDim2.fromOffset(FOVRadius * 2, FOVRadius * 2)
    FOVCircle.Visible = FOVEnabled and not GUIOpen
    Dot.Visible = CrosshairEnabled and not GUIOpen

    if not IsAiming or GUIOpen then
        Dot.Position = UDim2.fromScale(0.5, 0.5)
        return
    end

    if not isAlive() then
        IsAiming = false
        CurrentTarget = nil
        return
    end

    -- Validate Target
    local targetCharacter = getTargetCharacter(CurrentTarget)
    local targetPlayer = targetCharacter and Players:GetPlayerFromCharacter(targetCharacter)

    if not CurrentTarget or not CurrentTarget.Parent or not targetPlayer 
       or not targetCharacter:FindFirstChildOfClass("Humanoid") 
       or targetCharacter:FindFirstChildOfClass("Humanoid").Health <= 0 
       or not isVisible(CurrentTarget) then
        CurrentTarget = getClosestEnemy()
        
        if not CurrentTarget and not isHolding then
            IsAiming = false
            return
        end
    end

    if not CurrentTarget then return end

    -- INSTANT SNAP TO HEAD (No Smoothing)
    local headPosition, onScreen = currentCamera:WorldToViewportPoint(CurrentTarget.Position)
    if onScreen and headPosition.Z > 0 then
        Dot.Position = UDim2.fromOffset(headPosition.X, headPosition.Y)

        if not GUIOpen then
            -- Instantly calculate the distance and move the mouse there
            local moveX = headPosition.X - mousePosition.X
            local moveY = headPosition.Y - mousePosition.Y

            if mousemoverel then
                mousemoverel(moveX, moveY)
            end
        end
    else
        CurrentTarget = getClosestEnemy()
    end
end)

print("Rayfield Aggressive Aimbot Loaded")
