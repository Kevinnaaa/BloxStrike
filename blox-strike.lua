-- free no soo bad
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/twistedk1d/BloxStrike/refs/heads/main/Source/UI/source.lua"))()

--// Window creation
local Window = Rayfield:CreateWindow({
    Name = "Pirno.ccx",
    Icon = 0,
    LoadingTitle = "loading pirno.ccx (Blox Strike)",
    LoadingSubtitle = "by .Sparky9971",
    ShowText = "Menu",
    Theme = "Amethyst",
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Pirno.ccx",
        FileName = "Pirno.ccx"
    }
})

--// Services & Globals
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local CharactersFolder = Workspace:WaitForChild("Characters", 10)

--// ==========================================
--// TABS
--// ==========================================
local Tab_Combat  = Window:CreateTab("Combat", "crosshair")
local Tab_Skins   = Window:CreateTab("Skins", "swords")
local Tab_Visuals = Window:CreateTab("Visuals", "eye")

Tab_Skins:CreateLabel("this skin changer script by twistedk1d (not made me)", "code", Color3.fromRGB(80,80,80), false)

--// ==========================================
--// SHARED LOGIC (TEAM CHECK)
--// ==========================================
local function getTFolder() return CharactersFolder:FindFirstChild("Terrorists") end
local function getCTFolder() return CharactersFolder:FindFirstChild("Counter-Terrorists") end

local function isAlive()
    local t, ct = getTFolder(), getCTFolder()
    return (t and t:FindFirstChild(player.Name)) or (ct and ct:FindFirstChild(player.Name))
end

local function getEnemyFolder()
    if not isAlive() then return nil end
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(player.Name) then return ct end
    if ct and ct:FindFirstChild(player.Name) then return t end
    return nil
end

--// ==========================================
--// SILENT AIM IMPLEMENTATION
--// ==========================================
local SilentAimEnabled = false
local SilentAimFOV = 100
local SilentAimPart = "Head"

-- Silent aim using hook
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if not SilentAimEnabled or not isAlive() then return oldIndex(self, key) end
    
    if key == "Hit" or key == "Position" then
        local enemyFolder = getEnemyFolder()
        if not enemyFolder then return oldIndex(self, key) end
        
        local closestTarget = nil
        local closestDist = SilentAimFOV
        
        for _, enemy in ipairs(enemyFolder:GetChildren()) do
            local targetPart = enemy:FindFirstChild(SilentAimPart) or enemy:FindFirstChild("Head")
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            
            if targetPart and hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = targetPart
                    end
                end
            end
        end
        
        if closestTarget then
            return key == "Position" and closestTarget.Position or closestTarget
        end
    end
    
    return oldIndex(self, key)
end)

Tab_Combat:CreateSection("Silent Aim Settings")
Tab_Combat:CreateToggle({
    Name = "Enable Silent Aim (Bullets to Head)",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(Value) SilentAimEnabled = Value end
})

Tab_Combat:CreateSlider({
    Name = "Silent Aim FOV",
    Range = {10, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Flag = "SilentAimFOV",
    Callback = function(Value) SilentAimFOV = Value end
})

Tab_Combat:CreateDropdown({
    Name = "Aim Target Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Flag = "SilentAimPart",
    Callback = function(Options) SilentAimPart = Options[1] end
})

--// ==========================================
--// REGULAR AIMBOT & FOV LOGIC
--// ==========================================
local AimbotEnabled = false
local ShowFOV = false
local FOV_Radius = 100
local Smoothing = 3
local AimKey = Enum.UserInputType.MouseButton2
local isAiming = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
FOVCircle.Radius = FOV_Radius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Thickness = 1

-- Target lock indicator
local LockIndicator = Drawing.new("Circle")
LockIndicator.Color = Color3.fromRGB(0, 255, 0)
LockIndicator.Thickness = 1
LockIndicator.Transparency = 0.7
LockIndicator.Visible = false
LockIndicator.Radius = 8
LockIndicator.Filled = true

local function getClosestEnemyToMouse()
    local closestEnemy = nil
    local shortestDistance = FOV_Radius
    local enemyFolder = getEnemyFolder()
    
    if not enemyFolder or not AimbotEnabled then return nil end
    
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local head = enemy:FindFirstChild("Head")
        
        if hum and hum.Health > 0 and head then
            local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = head
                end
            end
        end
    end
    return closestEnemy
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == AimKey then isAiming = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimKey then isAiming = false end
end)

RunService.RenderStepped:Connect(function()
    if ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = FOV_Radius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- Update target lock indicator
    local targetHead = getClosestEnemyToMouse()
    if targetHead and isAiming and isAlive() and AimbotEnabled then
        local headPos = camera:WorldToViewportPoint(targetHead.Position)
        LockIndicator.Visible = true
        LockIndicator.Position = Vector2.new(headPos.X, headPos.Y)
    else
        LockIndicator.Visible = false
    end

    if not isAiming or not isAlive() or not AimbotEnabled then return end
    
    if targetHead then
        local headPos = camera:WorldToViewportPoint(targetHead.Position)
        local mousePos = UserInputService:GetMouseLocation()
        
        local moveX = (headPos.X - mousePos.X) / Smoothing
        local moveY = (headPos.Y - mousePos.Y) / Smoothing
        
        if mousemoverel then
            mousemoverel(moveX, moveY)
        end
    end
end)

Tab_Combat:CreateSection("Regular Aimbot Settings")
Tab_Combat:CreateToggle({
    Name = "Enable Aimbot (Hold Right Click)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value) AimbotEnabled = Value end
})

Tab_Combat:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "FOVToggle",
    Callback = function(Value) ShowFOV = Value end
})

Tab_Combat:CreateSlider({
    Name = "FOV Radius",
    Range = {10, 500},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 100,
    Flag = "FOVSlider",
    Callback = function(Value) FOV_Radius = Value end
})

Tab_Combat:CreateSlider({
    Name = "Aimbot Smoothing",
    Range = {1, 10},
    Increment = 1,
    Suffix = " (Lower is faster)",
    CurrentValue = 3,
    Flag = "AimbotSmoothing",
    Callback = function(Value) Smoothing = Value end
})

--// ==========================================
--// TRIGGERBOT LOGIC
--// ==========================================
local TriggerBotEnabled = false
local TriggerBotDelay = 0

Tab_Combat:CreateSection("TriggerBot Settings")
Tab_Combat:CreateToggle({
    Name = "Enable TriggerBot",
    CurrentValue = false,
    Flag = "TriggerBotToggle",
    Callback = function(Value) TriggerBotEnabled = Value end
})

Tab_Combat:CreateSlider({
    Name = "Shot Delay",
    Range = {0, 500},
    Increment = 10,
    Suffix = "ms",
    CurrentValue = 0,
    Flag = "TriggerBotDelay",
    Callback = function(Value) TriggerBotDelay = Value end
})

task.spawn(function()
    while task.wait(0.01) do
        if TriggerBotEnabled and isAlive() then
            local viewportSize = camera.ViewportSize
            local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local ignoreList = {camera}
            if player.Character then table.insert(ignoreList, player.Character) end
            raycastParams.FilterDescendantsInstances = ignoreList
            
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if result and result.Instance then
                local hitPart = result.Instance
                local model = hitPart:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") then
                    local enemyFolder = getEnemyFolder()
                    if enemyFolder and model.Parent == enemyFolder then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if TriggerBotDelay > 0 then task.wait(TriggerBotDelay / 1000) end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// SIMPLE HITBOX LOGIC (NO HOOKS)
--// ==========================================
local HitboxEnabled = false
local HitboxSize = 3
local originalHeadSizes = {}

Tab_Combat:CreateSection("Simple Hitbox (Max 3)")
Tab_Combat:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value) 
        HitboxEnabled = Value 
    end
})

Tab_Combat:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 3},
    Increment = 0.1,
    Suffix = " Studs",
    CurrentValue = 3,
    Flag = "HitboxSize",
    Callback = function(Value) 
        HitboxSize = Value 
    end
})

task.spawn(function()
    while task.wait(0.5) do
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local head = enemy:FindFirstChild("Head")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    if not originalHeadSizes[head] then
                        originalHeadSizes[head] = head.Size
                    end
                    
                    if HitboxEnabled then
                        head.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        head.CanCollide = false
                        head.Transparency = 0.5
                    else
                        if originalHeadSizes[head] and head.Size ~= originalHeadSizes[head] then
                            head.Size = originalHeadSizes[head]
                            head.Transparency = 0
                        end
                    end
                end
            end
        end
    end
end)

--// ==========================================
--// BHOP (BUNNY HOP) LOGIC
--// ==========================================
local BhopEnabled = false

Tab_Combat:CreateSection("Movement Settings")
Tab_Combat:CreateToggle({
    Name = "Enable Bunny Hop (Hold Space)",
    CurrentValue = false,
    Flag = "BhopToggle",
    Callback = function(Value) 
        BhopEnabled = Value 
    end
})

RunService.RenderStepped:Connect(function()
    if BhopEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) and isAlive() then
        if player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)

--// ==========================================
--// SKINS TAB LOGIC
--// ==========================================
local scriptRunning = false
local selectedKnife = "Butterfly Knife"
local spawned = false
local inspecting = false
local swinging = false
local lastAttackTime = 0

local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "InspectKnifeAction"
local ACTION_ATTACK  = "AttackKnifeAction"

pcall(function() RS.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

local knives = {
    ["Karambit"]       = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["Butterfly Knife"] = {Offset = CFrame.new(0, -1.5, 1.5)},
    ["M9 Bayonet"]     = {Offset = CFrame.new(0, -1.5, 1)},
    ["Flip Knife"]     = {Offset = CFrame.new(0, -1.5, 1.25)},
    ["Gut Knife"]      = {Offset = CFrame.new(0, -1.5, 0.5)},
}

local vm, animator
local equipAnim, idleAnim, inspectAnim, HeavySwingAnim, Swing1Anim, Swing2Anim

local function getKnifeInCamera() return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife") end

local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide, part.Anchored, part.CastShadow, part.CanTouch, part.CanQuery = false, false, false, false, false
end

local function disableCollisions(model)
    for _, part in model:GetDescendants() do cleanPart(part) end
end

local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Texture") then part.Transparency = 1 end
    end
end

local function playSound(folder, name)
    local weaponSounds = RS.Sounds:FindFirstChild(selectedKnife)
    if not weaponSounds then return end
    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end

local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end
    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm
    local motor = Instance.new("Motor6D")
    motor.Part0, motor.Part1, motor.C0, motor.Parent = targetArm, assetMesh, offset, targetArm
end

local function handleAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin or not spawned or not animator or not isAlive() then return Enum.ContextActionResult.Pass end

    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or inspecting or swinging then return Enum.ContextActionResult.Pass end
        inspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() inspecting = false end)
    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then return Enum.ContextActionResult.Pass end
        lastAttackTime = currentTime
        if inspecting then inspecting = false; if inspectAnim then inspectAnim:Stop() end end
        swinging = true
        if idleAnim then idleAnim:Stop() end
        local anims = {HeavySwingAnim, Swing1Anim, Swing2Anim}
        local chosenAnim = anims[math.random(1, #anims)]
        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"
        chosenAnim:Play()
        local s = playSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() swinging = false end)
    end
    return Enum.ContextActionResult.Pass
end

local function removeViewmodel()
    spawned = false
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy() vm = nil end
    animator, inspecting, swinging = nil, false, false
end

local function spawnViewmodel(knife)
    if spawned or not scriptRunning then return end
    local myModel = isAlive()
    if not myModel then return end
    spawned = true

    local knifeTemplate = RS.Assets.Weapons:WaitForChild(selectedKnife)
    local knifeOffset = knives[selectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = selectedKnife, camera

    disableCollisions(vm)
    hideOriginalKnife(knife)

    if myModel.Parent.Name == "Terrorists" then
        local tGloves = RS.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = RS.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = RS.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end

    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = RS.Assets.WeaponAnimations:WaitForChild(selectedKnife):WaitForChild("CameraAnimations")

    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))

    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = camera.CFrame * knifeOffset
    }):Play()

    equipAnim:Play()
    playSound("Equip", "1")

    CAS:BindAction(ACTION_INSPECT, handleAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleAction, false, Enum.UserInputType.MouseButton1)
end

RunService.RenderStepped:Connect(function()
    if not scriptRunning or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knives[selectedKnife].Offset
    if not (equipAnim and equipAnim.IsPlaying) and not inspecting and not swinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if scriptRunning and living and currentKnife and not spawned then
            spawnViewmodel(currentKnife)
        elseif (not scriptRunning or not currentKnife or not living) and spawned then
            removeViewmodel()
        end
    end
end)

local SkinChangerEnabled = false
local SelectedSkins = {}
local DropdownObjects = {}
local SkinOptions = {}
local COOLDOWN = 0.1
local WEAR = "Factory New"

local CT_ONLY = {["USP-S"]=true, ["Five-SeveN"]=true, ["MP9"]=true, ["FAMAS"]=true, ["M4A1-S"]=true, ["M4A4"]=true, ["AUG"]=true}
local SHARED = {["P250"]=true, ["Desert Eagle"]=true, ["Dual Berettas"]=true, ["Negev"]=true, ["P90"]=true, ["Nova"]=true, ["XM1014"]=true, ["AWP"]=true, ["SSG 08"]=true}
local KNIVES = {["Karambit"]=true, ["Butterfly Knife"]=true, ["M9 Bayonet"]=true, ["Flip Knife"]=true, ["Gut Knife"]=true, ["T Knife"]=true, ["CT Knife"]=true}
local GLOVES = {["Sports Gloves"]=true}
local SkinsFolder = RS:WaitForChild("Assets"):WaitForChild("Skins")
local IgnoreFolders = {["HE Grenade"]=true, ["Incendiary Grenade"]=true, ["Molotov"]=true, ["Smoke Grenade"]=true, ["Flashbang"]=true, ["Decoy Grenade"]=true, ["C4"]=true, ["CT Glove"]=true, ["T Glove"]=true}

local function applyWeaponSkin(model)
    if not model or not SkinChangerEnabled or not isAlive() then return end
    local skinName = SelectedSkins[model.Name]
    if not skinName then return end

    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then return end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild(WEAR)
        if not sourceFolder then return end

        for _, obj in camera:GetChildren() do
            local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
            if left or right then
                local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild(WEAR)
                if gloveSource then
                    for _, side in {"Left Arm", "Right Arm"} do
                        local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                        if arm and src then
                            local gloveMesh = arm:FindFirstChild("Glove")
                            if gloveMesh then
                                local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = src:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                            end
                        end
                    end
                end
            end
        end

        if not GLOVES[model.Name] then
            local weaponFolder = model:FindFirstChild("Weapon")
            if weaponFolder then
                for _, part in weaponFolder:GetDescendants() do
                    if part:IsA("BasePart") then
                        local newSkin = sourceFolder:FindFirstChild(part.Name)
                        if newSkin then
                            local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                            if existing then existing:Destroy() end
                            local clone = newSkin:Clone()
                            clone.Name, clone.Parent = "SurfaceAppearance", part
                        end
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end

Tab_Skins:CreateToggle({
    Name = "Enable Skin Changer",
    CurrentValue = false,
    Flag = "SkinChangerToggle",
    Callback = function(Value)
        SkinChangerEnabled = Value
        if not Value then for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil) end end
    end
})

Tab_Skins:CreateButton({
    Name = "🎲 Randomize All Skins",
    Callback = function()
        for weaponName, optionsList in pairs(SkinOptions) do
            if #optionsList > 0 then
                local randomSkin = optionsList[math.random(1, #optionsList)]
                if DropdownObjects[weaponName] then
                    for _, dropdown in ipairs(DropdownObjects[weaponName]) do dropdown:Set({randomSkin}) end
                end
            end
        end
    end,
})

local function CreateSkinDropdown(weaponName)
    local folder = SkinsFolder:FindFirstChild(weaponName)
    if not folder then return end
    
    local options = {}
    for _, skin in folder:GetChildren() do table.insert(options, skin.Name) end
    SkinOptions[weaponName] = options
    
    if not SelectedSkins[weaponName] then SelectedSkins[weaponName] = options[1] end

    local dp = Tab_Skins:CreateDropdown({
        Name = weaponName,
        Options = options,
        CurrentOption = {SelectedSkins[weaponName]},
        Flag = "Skin_" .. weaponName,
        Callback = function(opt)
            local newSkin = opt[1]
            SelectedSkins[weaponName] = newSkin
            if DropdownObjects[weaponName] then
                for _, other in DropdownObjects[weaponName] do
                    if other.CurrentOption[1] ~= newSkin then other:Set({newSkin}) end
                end
            end
            for _, obj in camera:GetChildren() do obj:SetAttribute("SkinApplied", nil); applyWeaponSkin(obj) end
        end
    })
    DropdownObjects[weaponName] = DropdownObjects[weaponName] or {}
    table.insert(DropdownObjects[weaponName], dp)
end

Tab_Skins:CreateToggle({
    Name = "Enable Custom Knife",
    CurrentValue = false,
    Flag = "KnifeToggle",
    Callback = function(Value)
        scriptRunning = Value; if not Value then removeViewmodel() end
    end
})

Tab_Skins:CreateDropdown({
    Name = "Selected Custom Knife",
    Options = {"Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife"},
    CurrentOption = {"Butterfly Knife"},
    MultipleOptions = false,
    Flag = "KnifeDropdown",
    Callback = function(Options)
        selectedKnife = Options[1]; if spawned then removeViewmodel() end
    end
})

Tab_Skins:CreateSection("Knives Skins")
for name in pairs(KNIVES) do CreateSkinDropdown(name) end
Tab_Skins:CreateSection("Gloves")
for name in pairs(GLOVES) do CreateSkinDropdown(name) end
Tab_Skins:CreateSection("CT Weapons")
for name in pairs(CT_ONLY) do CreateSkinDropdown(name) end
Tab_Skins:CreateSection("T Weapons")
for name in pairs(SHARED) do CreateSkinDropdown(name) end

for _, folder in SkinsFolder:GetChildren() do
    local n = folder.Name
    if not IgnoreFolders[n] and not KNIVES[n] and not GLOVES[n] and not CT_ONLY[n] and not SHARED[n] then CreateSkinDropdown(n) end
end

camera.ChildAdded:Connect(function(obj)
    if not SkinChangerEnabled or not isAlive() then return end
    task.wait(COOLDOWN); applyWeaponSkin(obj)
end)

task.spawn(function()
    while task.wait(0.5) do
        if SkinChangerEnabled and isAlive() then
            for _, obj in camera:GetChildren() do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then applyWeaponSkin(obj) end
            end
        end
    end
end)

--// ==========================================
--// ENHANCED VISUALS TAB LOGIC (ESP & WORLD)
--// ==========================================
local EspEnabled, EspBox, EspName, EspHealth, EspDistance, EspTracers, EspSkeleton = false, true, true, true, true, false, false
local espCache = {}

local function createESP()
    local esp = {
        -- Main box
        boxOutline = Drawing.new("Square"),
        boxFill = Drawing.new("Square"),
        
        -- Corner lines
        cornerTL = Drawing.new("Line"),
        cornerTR = Drawing.new("Line"),
        cornerBL = Drawing.new("Line"),
        cornerBR = Drawing.new("Line"),
        
        -- Text
        name = Drawing.new("Text"),
        distance = Drawing.new("Text"),
        healthText = Drawing.new("Text"),
        
        -- Health bar
        healthOutline = Drawing.new("Line"),
        healthBar = Drawing.new("Line"),
        
        -- Tracer
        tracer = Drawing.new("Line"),
        
        -- Skeleton lines
        skeletonLines = {}
    }
    
    -- Box setup
    esp.boxOutline.Thickness = 3
    esp.boxOutline.Filled = false
    esp.boxOutline.Color = Color3.new(0, 0, 0)
    
    esp.boxFill.Thickness = 1
    esp.boxFill.Filled = true
    esp.boxFill.Transparency = 0.8
    esp.boxFill.Color = Color3.fromRGB(255, 50, 50)
    
    -- Corner lines setup
    for _, corner in pairs({esp.cornerTL, esp.cornerTR, esp.cornerBL, esp.cornerBR}) do
        corner.Thickness = 2
        corner.Color = Color3.fromRGB(255, 255, 255)
        corner.Transparency = 1
    end
    
    -- Name setup
    esp.name.Center = true
    esp.name.Outline = true
    esp.name.OutlineColor = Color3.new(0, 0, 0)
    esp.name.Color = Color3.new(1, 1, 1)
    esp.name.Size = 14
    
    -- Distance setup
    esp.distance.Center = true
    esp.distance.Outline = true
    esp.distance.OutlineColor = Color3.new(0, 0, 0)
    esp.distance.Color = Color3.new(0.8, 0.8, 0.8)
    esp.distance.Size = 12
    
    -- Health text setup
    esp.healthText.Center = true
    esp.healthText.Outline = true
    esp.healthText.Color = Color3.new(1, 1, 1)
    esp.healthText.Size = 11
    
    -- Health bar setup
    esp.healthOutline.Thickness = 3
    esp.healthOutline.Color = Color3.new(0, 0, 0)
    esp.healthBar.Thickness = 1
    esp.healthBar.Color = Color3.new(0, 1, 0)
    
    -- Tracer setup
    esp.tracer.Thickness = 1
    esp.tracer.Transparency = 0.5
    esp.tracer.Color = Color3.fromRGB(255, 50, 50)
    
    return esp
end

RunService.RenderStepped:Connect(function()
    if not EspEnabled or not isAlive() then
        for _, e in pairs(espCache) do 
            for _, d in pairs(e) do 
                if d then 
                    if type(d) == "table" then
                        for _, line in pairs(d) do line.Visible = false end
                    else
                        d.Visible = false 
                    end
                end 
            end 
        end
        return
    end
    
    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end

    local currentAlive = {}
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum, root, head = enemy:FindFirstChildOfClass("Humanoid"), enemy:FindFirstChild("HumanoidRootPart"), enemy:FindFirstChild("Head")
        local upperTorso = enemy:FindFirstChild("UpperTorso")
        local lowerTorso = enemy:FindFirstChild("LowerTorso")
        local leftArm = enemy:FindFirstChild("Left Arm") or enemy:FindFirstChild("LeftUpperArm")
        local rightArm = enemy:FindFirstChild("Right Arm") or enemy:FindFirstChild("RightUpperArm")
        local leftLeg = enemy:FindFirstChild("Left Leg") or enemy:FindFirstChild("LeftUpperLeg")
        local rightLeg = enemy:FindFirstChild("Right Leg") or enemy:FindFirstChild("RightUpperLeg")

        if hum and hum.Health > 0 and root and head then
            currentAlive[enemy] = true
            if not espCache[enemy] then espCache[enemy] = createESP() end
            
            local esp = espCache[enemy]
            local rootPos, rootOnScreen = camera:WorldToViewportPoint(root.Position)
            local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

            if rootOnScreen then
                local boxH = math.abs(headPos.Y - legPos.Y)
                local boxW = boxH * 0.45
                local boxX = rootPos.X - boxW / 2
                local boxY = headPos.Y
                local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                local hpPct = hum.Health / hum.MaxHealth

                -- Health color
                local healthColor = hpPct > 0.7 and Color3.fromRGB(50, 255, 50) or 
                                   (hpPct > 0.3 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 50, 50))

                -- ESP Box
                if EspBox then
                    -- Main box
                    esp.boxOutline.Size = Vector2.new(boxW, boxH)
                    esp.boxOutline.Position = Vector2.new(boxX, boxY)
                    esp.boxOutline.Visible = true
                    
                    esp.boxFill.Size = Vector2.new(boxW, boxH)
                    esp.boxFill.Position = Vector2.new(boxX, boxY)
                    esp.boxFill.Color = healthColor
                    esp.boxFill.Visible = true
                    
                    -- Corner lines
                    local cornerLen = boxW * 0.2
                    
                    -- Top Left
                    esp.cornerTL.From = Vector2.new(boxX, boxY + cornerLen)
                    esp.cornerTL.To = Vector2.new(boxX, boxY)
                    esp.cornerTL.Visible = true
                    
                    -- Top horizontal line (TL corner)
                    local TLH = Drawing.new("Line")
                    TLH.From = Vector2.new(boxX, boxY)
                    TLH.To = Vector2.new(boxX + cornerLen, boxY)
                    TLH.Color = Color3.fromRGB(255, 255, 255)
                    TLH.Thickness = 2
                    TLH.Visible = true
                    
                    -- Top Right
                    esp.cornerTR.From = Vector2.new(boxX + boxW, boxY)
                    esp.cornerTR.To = Vector2.new(boxX + boxW - cornerLen, boxY)
                    esp.cornerTR.Visible = true
                    
                    local TRV = Drawing.new("Line")
                    TRV.From = Vector2.new(boxX + boxW, boxY)
                    TRV.To = Vector2.new(boxX + boxW, boxY + cornerLen)
                    TRV.Color = Color3.fromRGB(255, 255, 255)
                    TRV.Thickness = 2
                    TRV.Visible = true
                    
                    -- Bottom Left
                    esp.cornerBL.From = Vector2.new(boxX, boxY + boxH - cornerLen)
                    esp.cornerBL.To = Vector2.new(boxX, boxY + boxH)
                    esp.cornerBL.Visible = true
                    
                    local BLH = Drawing.new("Line")
                    BLH.From = Vector2.new(boxX, boxY + boxH)
                    BLH.To = Vector2.new(boxX + cornerLen, boxY + boxH)
                    BLH.Color = Color3.fromRGB(255, 255, 255)
                    BLH.Thickness = 2
                    BLH.Visible = true
                    
                    -- Bottom Right
                    esp.cornerBR.From = Vector2.new(boxX + boxW - cornerLen, boxY + boxH)
                    esp.cornerBR.To = Vector2.new(boxX + boxW, boxY + boxH)
                    esp.cornerBR.Visible = true
                    
                    local BRV = Drawing.new("Line")
                    BRV.From = Vector2.new(boxX + boxW, boxY + boxH - cornerLen)
                    BRV.To = Vector2.new(boxX + boxW, boxY + boxH)
                    BRV.Color = Color3.fromRGB(255, 255, 255)
                    BRV.Thickness = 2
                    BRV.Visible = true
                    
                    -- Cleanup temporary lines
                    task.delay(0.03, function()
                        if TLH then TLH:Remove() end
                        if TRV then TRV:Remove() end
                        if BLH then BLH:Remove() end
                        if BRV then BRV:Remove() end
                    end)
                else
                    esp.boxOutline.Visible = false
                    esp.boxFill.Visible = false
                    esp.cornerTL.Visible = false
                    esp.cornerTR.Visible = false
                    esp.cornerBL.Visible = false
                    esp.cornerBR.Visible = false
                end
                
                -- Health Bar
                if EspHealth then
                    local barX = boxX - 8
                    esp.healthOutline.From = Vector2.new(barX, boxY - 1)
                    esp.healthOutline.To = Vector2.new(barX, boxY + boxH + 1)
                    esp.healthOutline.Visible = true
                    
                    esp.healthBar.From = Vector2.new(barX, boxY + boxH)
                    esp.healthBar.To = Vector2.new(barX, boxY + boxH - (boxH * hpPct))
                    esp.healthBar.Color = healthColor
                    esp.healthBar.Visible = true
                    
                    -- Health percentage text
                    esp.healthText.Text = math.floor(hpPct * 100) .. "%"
                    esp.healthText.Position = Vector2.new(barX, boxY + boxH + 12)
                    esp.healthText.Color = healthColor
                    esp.healthText.Visible = true
                else
                    esp.healthOutline.Visible = false
                    esp.healthBar.Visible = false
                    esp.healthText.Visible = false
                end
                
                -- Name
                if EspName then
                    esp.name.Text = enemy.Name
                    esp.name.Position = Vector2.new(rootPos.X, boxY - 18)
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end

                -- Distance
                if EspDistance then
                    esp.distance.Text = "[" .. dist .. "m]"
                    esp.distance.Position = Vector2.new(rootPos.X, boxY + boxH + 2)
                    esp.distance.Visible = true
                else
                    esp.distance.Visible = false
                end
                
                -- Tracers
                if EspTracers then
                    esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(rootPos.X, legPos.Y)
                    esp.tracer.Color = healthColor
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
                
                -- Skeleton ESP
                if EspSkeleton and head and upperTorso and lowerTorso and leftArm and rightArm and leftLeg and rightLeg then
                    -- Create skeleton lines if they don't exist
                    local skeletonParts = {
                        {head, upperTorso}, {upperTorso, lowerTorso},
                        {upperTorso, leftArm}, {upperTorso, rightArm},
                        {lowerTorso, leftLeg}, {lowerTorso, rightLeg}
                    }
                    
                    -- Remove old skeleton lines
                    for _, line in pairs(esp.skeletonLines) do
                        line:Remove()
                    end
                    esp.skeletonLines = {}
                    
                    -- Create new skeleton lines
                    for _, partPair in pairs(skeletonParts) do
                        local part1Pos = camera:WorldToViewportPoint(partPair[1].Position)
                        local part2Pos = camera:WorldToViewportPoint(partPair[2].Position)
                        
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(part1Pos.X, part1Pos.Y)
                        line.To = Vector2.new(part2Pos.X, part2Pos.Y)
                        line.Color = Color3.fromRGB(255, 255, 255)
                        line.Thickness = 1
                        line.Transparency = 0.7
                        line.Visible = true
                        table.insert(esp.skeletonLines, line)
                    end
                else
                    -- Hide skeleton lines
                    for _, line in pairs(esp.skeletonLines) do
                        line.Visible = false
                    end
                end
            else
                -- Hide all elements if not on screen
                for _, drawing in pairs(esp) do
                    if drawing then
                        if type(drawing) == "table" then
                            for _, line in pairs(drawing) do line.Visible = false end
                        else
                            drawing.Visible = false
                        end
                    end
                end
            end
        end
    end
    
    -- Clean up dead enemies
    for cEnemy, esp in pairs(espCache) do
        if not currentAlive[cEnemy] then
            for _, drawing in pairs(esp) do
                if drawing then
                    if type(drawing) == "table" then
                        for _, line in pairs(drawing) do line:Remove() end
                    else
                        drawing:Remove()
                    end
                end
            end
            espCache[cEnemy] = nil
        end
    end
end)

Tab_Visuals:CreateSection("ESP Master Switch")
Tab_Visuals:CreateToggle({
    Name = "Enable Player ESP", 
    CurrentValue = false, 
    Flag = "ESPToggle", 
    Callback = function(Value) EspEnabled = Value end
})

Tab_Visuals:CreateSection("ESP Settings")
Tab_Visuals:CreateToggle({
    Name = "Show 2D Box", 
    CurrentValue = true, 
    Flag = "EspBoxToggle", 
    Callback = function(Value) EspBox = Value end
})
Tab_Visuals:CreateToggle({
    Name = "Show Health Bar", 
    CurrentValue = true, 
    Flag = "EspHealthToggle", 
    Callback = function(Value) EspHealth = Value end
})
Tab_Visuals:CreateToggle({
    Name = "Show Name", 
    CurrentValue = true, 
    Flag = "EspNameToggle", 
    Callback = function(Value) EspName = Value end
})
Tab_Visuals:CreateToggle({
    Name = "Show Distance", 
    CurrentValue = true, 
    Flag = "EspDistanceToggle", 
    Callback = function(Value) EspDistance = Value end
})
Tab_Visuals:CreateToggle({
    Name = "Show Tracers", 
    CurrentValue = false, 
    Flag = "EspTracersToggle", 
    Callback = function(Value) EspTracers = Value end
})
Tab_Visuals:CreateToggle({
    Name = "Show Skeleton", 
    CurrentValue = false, 
    Flag = "EspSkeletonToggle", 
    Callback = function(Value) EspSkeleton = Value end
})

local AntiFlashEnabled, AntiSmokeEnabled = false, false
Tab_Visuals:CreateSection("World & Effects")
Tab_Visuals:CreateToggle({
    Name = "Anti-Flashbang", 
    CurrentValue = false, 
    Flag = "AntiFlashToggle", 
    Callback = function(Value) AntiFlashEnabled = Value end
})
Tab_Visuals:CreateToggle({
    Name = "Anti-Smoke", 
    CurrentValue = false, 
    Flag = "AntiSmokeToggle", 
    Callback = function(Value) AntiSmokeEnabled = Value end
})

task.spawn(function()
    while task.wait(0.2) do
        if AntiFlashEnabled then
            local gui, effect = player.PlayerGui:FindFirstChild("FlashbangEffect"), game:GetService("Lighting"):FindFirstChild("FlashbangColorCorrection")
            if gui then gui:Destroy() end; if effect then effect:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if AntiSmokeEnabled then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if string.match(folder.Name, "Voxel") then folder:ClearAllChildren(); folder:Destroy() end
                end
            end
        end
    end
end)

Rayfield:LoadConfiguration()
