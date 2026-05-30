-- free no soo bad
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kevinnaaa/BloxStrike/main/ref.lua"))()

-- Force enable minimize functionality in Rayfield
-- This patches the UI to ensure the minimize button works correctly
local oldCreateWindow = Rayfield.CreateWindow
Rayfield.CreateWindow = function(self, Settings)
    -- Ensure the window will have minimize functionality
    Settings = Settings or {}
    Settings.DisableRayfieldPrompts = Settings.DisableRayfieldPrompts or false
    
    local window = oldCreateWindow(self, Settings)
    
    -- Add a global function to minimize the UI from anywhere
    _G.MinimizeRayfield = function()
        -- Try to find and click the minimize button
        task.wait(0.1)
        local mainGui = nil
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if gui.Name == "Rayfield" then
                mainGui = gui
                break
            end
        end
        if mainGui and mainGui:FindFirstChild("Main") and mainGui.Main:FindFirstChild("Topbar") then
            local minimizeBtn = mainGui.Main.Topbar:FindFirstChild("ChangeSize")
            if minimizeBtn and minimizeBtn:IsA("ImageButton") then
                minimizeBtn:Fire()
            end
        end
    end
    
    -- Also add keyboard shortcut (M key) to minimize
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.M and input.UserInputType == Enum.UserInputType.Keyboard then
            _G.MinimizeRayfield()
        end
    end)
    
    return window
end

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

-- Add a custom minimize button using a Button element in the Visuals tab
local VisualsTab = Window:CreateTab("Visuals", "eye")

VisualsTab:CreateSection("Window Controls")

-- Create a minimize button in the UI
VisualsTab:CreateButton({
    Name = "➖ MINIMIZE WINDOW",
    Callback = function()
        -- Find the Rayfield GUI and click the minimize button
        local success, mainGui = pcall(function()
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui.Name == "Rayfield" then
                    return gui
                end
            end
        end)
        
        if success and mainGui then
            local minimizeBtn = mainGui:FindFirstChild("Main") and 
                               mainGui.Main:FindFirstChild("Topbar") and 
                               mainGui.Main.Topbar:FindFirstChild("ChangeSize")
            if minimizeBtn and minimizeBtn:IsA("ImageButton") then
                minimizeBtn:Fire()
                -- Show notification
                Rayfield:Notify({
                    Title = "Window Minimized",
                    Content = "Click the [ ] button or press M to restore",
                    Duration = 2,
                    Image = 4483362458
                })
            end
        end
    end
})

-- Add a restore button as well
VisualsTab:CreateButton({
    Name = "🔲 RESTORE WINDOW",
    Callback = function()
        local success, mainGui = pcall(function()
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui.Name == "Rayfield" then
                    return gui
                end
            end
        end)
        
        if success and mainGui then
            local minimizeBtn = mainGui:FindFirstChild("Main") and 
                               mainGui.Main:FindFirstChild("Topbar") and 
                               mainGui.Main.Topbar:FindFirstChild("ChangeSize")
            if minimizeBtn and minimizeBtn:IsA("ImageButton") then
                -- Click it again to restore
                minimizeBtn:Fire()
            end
        end
    end
})

VisualsTab:CreateLabel("Press M to minimize/restore", nil, Color3.fromRGB(150, 150, 150), true)

-- Add minimize notification when using keybind
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.M then
        task.wait(0.1)
        local success, mainGui = pcall(function()
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui.Name == "Rayfield" then
                    return gui
                end
            end
        end)
        if success and mainGui then
            local mainFrame = mainGui:FindFirstChild("Main")
            if mainFrame and mainFrame.Size.Y.Scale == 0 then
                -- It's minimized
                Rayfield:Notify({
                    Title = "Window Restored",
                    Content = "Press M again to minimize",
                    Duration = 1.5,
                    Image = 4483362458
                })
            end
        end
    end
end)

-- Rest of your original code continues here...
--// Services & Globals
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local CharactersFolder = workspace:WaitForChild("Characters", 10)

--// ==========================================
--// TABS
--// ==========================================
local Tab_Combat  = Window:CreateTab("Combat", "crosshair")
local Tab_Skins   = Window:CreateTab("Skins", "swords")
-- Note: Visuals tab already created above

Tab_Skins:CreateLabel("this skin changer script by twistedk1d (not made me)", "code", Color3.fromRGB(80,80,80), false)

-- Continue with the rest of your original script here...
-- (All the aimbot, triggerbot, hitbox, bhop, skins, and ESP code remains exactly the same)

-- IMPORTANT: Add this at the very end to ensure the minimize button works
task.spawn(function()
    -- Make sure the minimize button is visible and functional
    task.wait(1)
    local success, mainGui = pcall(function()
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            if gui.Name == "Rayfield" then
                return gui
            end
        end
    end)
    
    if success and mainGui then
        local topbar = mainGui:FindFirstChild("Main") and mainGui.Main:FindFirstChild("Topbar")
        if topbar then
            local changeSizeBtn = topbar:FindFirstChild("ChangeSize")
            if changeSizeBtn then
                -- Ensure the button is visible and interactive
                changeSizeBtn.ImageTransparency = 0.8
                changeSizeBtn.Active = true
                changeSizeBtn.Visible = true
            end
        end
    end
end)
