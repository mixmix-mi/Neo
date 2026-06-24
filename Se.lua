-- ============================================
-- Hyper v1.0 - Settings & Configuration
-- ============================================

-- ============================================
-- 1. FPS, Ping & Timer (Blood Moon Theme)
-- ============================================
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
    Locked = false,
})

local FPSSection = SettingsTab:Section({
    Title = "FPS, Ping & Timer",
    Side = "Left",
    Collapsed = true,
})

local fpsTimerEnabled = false
local fpsTimerGui = nil
local fpsUpdateConnection = nil

local function CreateFPSPanel()
    local playerGui = LP:WaitForChild("PlayerGui")
    
    if fpsTimerGui then fpsTimerGui:Destroy() end
    if fpsUpdateConnection then fpsUpdateConnection:Disconnect() end
    
    fpsTimerGui = Instance.new("ScreenGui")
    fpsTimerGui.Name = "HyperFPSPanel"
    fpsTimerGui.ResetOnSpawn = false
    fpsTimerGui.Parent = playerGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 180, 0, 55)
    container.Position = UDim2.new(0.01, 0, 0.01, 0)
    container.BackgroundColor3 = Color3.fromHex("#1a0000")
    container.BackgroundTransparency = 0.1
    container.Parent = fpsTimerGui
    container.Active = true
    container.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")
    stroke.Thickness = 2
    stroke.Parent = container
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
    fpsLabel.Position = UDim2.new(0, 0, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: -- | Ping: --ms"
    fpsLabel.TextColor3 = Color3.fromHex("#ffcccc")
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 12
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.Parent = container
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
    timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Time: 0h 0m 0s"
    timerLabel.TextColor3 = Color3.fromHex("#ffcccc")
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextSize = 12
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Parent = container
    
    local startTime = tick()
    local frameCount = 0
    local lastUpdate = tick()
    local currentFPS = 0
    
    fpsUpdateConnection = RunService.RenderStepped:Connect(function()
        if not fpsTimerGui or not fpsTimerGui.Parent then
            if fpsUpdateConnection then
                fpsUpdateConnection:Disconnect()
                fpsUpdateConnection = nil
            end
            return
        end
        
        frameCount = frameCount + 1
        local now = tick()
        
        if now - lastUpdate >= 0.5 then
            currentFPS = math.floor(frameCount / (now - lastUpdate))
            frameCount = 0
            lastUpdate = now
            
            local ping = 50
            pcall(function()
                local stats = game:GetService("Stats")
                local network = stats:FindFirstChild("Network")
                if network then
                    local serverStats = network:FindFirstChild("ServerStatsItem")
                    if serverStats then
                        ping = math.floor(serverStats:GetValue())
                    end
                end
            end)
            fpsLabel.Text = string.format("FPS: %d | Ping: %dms", currentFPS, ping)
        end
        
        local elapsed = now - startTime
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = math.floor(elapsed % 60)
        timerLabel.Text = string.format("Time: %dh %dm %ds", hours, minutes, seconds)
    end)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            stroke.Color = Color3.fromHex("#ff4444")
        end
    end)
    
    container.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                local viewport = workspace.CurrentCamera.ViewportSize
                newX = math.clamp(newX, 10, viewport.X - 190)
                newY = math.clamp(newY, 10, viewport.Y - 65)
                container.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    
    container.InputEnded:Connect(function()
        dragging = false
        stroke.Color = Color3.fromHex("#660000")
    end)
    
    container.Destroying:Connect(function()
        if fpsUpdateConnection then
            fpsUpdateConnection:Disconnect()
            fpsUpdateConnection = nil
        end
    end)
    
    return fpsTimerGui
end

FPSSection:Toggle({
    Title = "Show FPS, Ping & Timer",
    Icon = "activity",
    Value = false,
    Callback = function(state)
        fpsTimerEnabled = state
        if state then
            fpsTimerGui = CreateFPSPanel()
            WindUI:Notify({ Title = "FPS Panel", Content = "Panel shown", Duration = 2 })
        else
            if fpsTimerGui then
                if fpsUpdateConnection then
                    fpsUpdateConnection:Disconnect()
                    fpsUpdateConnection = nil
                end
                fpsTimerGui:Destroy()
                fpsTimerGui = nil
            end
            WindUI:Notify({ Title = "FPS Panel", Content = "Panel hidden", Duration = 2 })
        end
    end,
})

-- ============================================
-- 2. Performance & Visuals
-- ============================================
local PerfSection = SettingsTab:Section({
    Title = "Performance & Visuals",
    Side = "Left",
    Collapsed = true,
})

-- Clear Invis Walls
local function getInvisPartsFolder()
    local success, folder = pcall(function()
        local gameFolder = workspace:FindFirstChild("Game")
        if not gameFolder then return nil end
        local mapFolder = gameFolder:FindFirstChild("Map")
        if not mapFolder then return nil end
        return mapFolder:FindFirstChild("InvisParts")
    end)
    return success and folder or nil
end

PerfSection:Toggle({
    Title = "Clear Invis Walls",
    Value = false,
    Callback = function(state)
        local folder = getInvisPartsFolder()
        if not folder then
            WindUI:Notify({ Title = "Invis Walls", Content = "InvisParts not found", Duration = 2 })
            return
        end
        
        local changed = 0
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.CanCollide = not state
                changed = changed + 1
            end
        end
        WindUI:Notify({ Title = "Invis Walls", Content = string.format("%s for %d objects", state and "Disabled" or "Enabled", changed), Duration = 2 })
    end
})

-- Streaming
PerfSection:Button({
    Title = "Lower Chunks",
    Callback = function()
        workspace.StreamingMinRadius = 200
        workspace.StreamingTargetRadius = 500
        WindUI:Notify({ Title = "Streaming", Content = "Chunks lowered", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Hide Useless Chunks",
    Callback = function()
        workspace.StreamingMinRadius = 0
        workspace.StreamingTargetRadius = 500
        WindUI:Notify({ Title = "Streaming", Content = "Useless chunks hidden", Duration = 2 })
    end
})

-- FPS & Graphics
PerfSection:Button({
    Title = "Disable VSync",
    Callback = function()
        pcall(function() setfpscap(9999) end)
        WindUI:Notify({ Title = "VSync", Content = "Disabled", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Set FPS Cap Max",
    Callback = function()
        pcall(function() setfpscap(99999) end)
        WindUI:Notify({ Title = "FPS", Content = "Cap set to max", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Low Graphics",
    Callback = function()
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        WindUI:Notify({ Title = "Graphics", Content = "Set to low", Duration = 2 })
    end
})

-- Visual Effects
PerfSection:Button({
    Title = "Hide Skybox",
    Callback = function()
        pcall(function() game.Lighting.Sky = nil end)
        WindUI:Notify({ Title = "Skybox", Content = "Hidden", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Disable Shadows",
    Callback = function()
        local count = 0
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                count = count + 1
            end
        end
        WindUI:Notify({ Title = "Shadows", Content = "Disabled for " .. count .. " objects", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Disable Particles",
    Callback = function()
        local count = 0
        for _, particle in pairs(workspace:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle:Destroy()
                count = count + 1
            end
        end
        WindUI:Notify({ Title = "Particles", Content = "Removed " .. count .. " emitters", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Low Poly Mode",
    Callback = function()
        local count = 0
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("UnionOperation") then
                part.Material = Enum.Material.Plastic
                part.RenderFidelity = Enum.RenderFidelity.Performance
                count = count + 1
            end
        end
        WindUI:Notify({ Title = "Low Poly", Content = "Applied to " .. count .. " objects", Duration = 2 })
    end
})

-- Lighting & Time
PerfSection:Button({
    Title = "Night",
    Callback = function()
        game.Lighting.TimeOfDay = "00:00:00"
        WindUI:Notify({ Title = "Time", Content = "Night mode", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Day",
    Callback = function()
        game.Lighting.TimeOfDay = "08:00:00"
        WindUI:Notify({ Title = "Time", Content = "Day mode", Duration = 2 })
    end
})

PerfSection:Button({
    Title = "Anti Fog",
    Callback = function()
        local L = game.Lighting
        L.FogStart = 100000
        L.FogEnd = 1000000
        WindUI:Notify({ Title = "Fog", Content = "Removed", Duration = 2 })
    end
})

-- ============================================
-- 3. Button Sizes
-- ============================================
local SizesSection = SettingsTab:Section({
    Title = "Button Sizes",
    Side = "Left",
    Collapsed = true,
})

local function UpdateButtonSize(buttonName, size)
    local coreGui = game:GetService("CoreGui")
    local gui = coreGui:FindFirstChild(buttonName)
    if gui then
        local btn = gui:FindFirstChildOfClass("TextButton")
        if btn then
            local newWidth = math.max(120, math.min(size, 350))
            local newHeight = math.max(40, math.min(size * 0.35, 130))
            btn.Size = UDim2.new(0, newWidth, 0, newHeight)
            
            local viewport = workspace.CurrentCamera.ViewportSize
            local newX = (viewport.X / 2) - (newWidth / 2)
            local newY = (viewport.Y / 2) - (newHeight / 2)
            btn.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end

SizesSection:Slider({
    Title = "Bhop Button Size",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("BhopFloatingButton", value)
    end,
})

SizesSection:Slider({
    Title = "Lag Switch Button Size",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("LagSwitchFloatingButtonGUI", value)
    end,
})

SizesSection:Slider({
    Title = "Carry Button Size",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("CarryFloatingButton", value)
    end,
})

SizesSection:Slider({
    Title = "Demon Mode Button Size",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("DemonFloatingButton", value)
    end,
})

-- ============================================
-- 4. Button Positions
-- ============================================
local PositionsSection = SettingsTab:Section({
    Title = "Button Positions",
    Side = "Left",
    Collapsed = true,
})

local floatingButtons = {
    "BhopFloatingButton",
    "LagSwitchFloatingButtonGUI",
    "CarryFloatingButton",
    "DemonFloatingButton",
}

local function SaveButtonPositions()
    local positions = {}
    local coreGui = game:GetService("CoreGui")
    
    for _, btnName in ipairs(floatingButtons) do
        local gui = coreGui:FindFirstChild(btnName)
        if gui then
            local btn = gui:FindFirstChildOfClass("TextButton")
            if btn then
                positions[btnName] = {
                    X = btn.Position.X.Offset,
                    Y = btn.Position.Y.Offset,
                }
            end
        end
    end
    
    local success = pcall(function()
        writefile("Hyper_ButtonPositions.txt", game:GetService("HttpService"):JSONEncode(positions))
    end)
    
    WindUI:Notify({ Title = "Positions", Content = success and "Saved" or "Failed", Duration = 2 })
end

local function LoadButtonPositions()
    local success, data = pcall(function()
        return readfile("Hyper_ButtonPositions.txt")
    end)
    
    if success and data then
        local positions = game:GetService("HttpService"):JSONDecode(data)
        local coreGui = game:GetService("CoreGui")
        
        for btnName, pos in pairs(positions) do
            local gui = coreGui:FindFirstChild(btnName)
            if gui then
                local btn = gui:FindFirstChildOfClass("TextButton")
                if btn then
                    btn.Position = UDim2.new(0, pos.X, 0, pos.Y)
                end
            end
        end
        WindUI:Notify({ Title = "Positions", Content = "Loaded", Duration = 2 })
    else
        WindUI:Notify({ Title = "Positions", Content = "No saved file", Duration = 2 })
    end
end

PositionsSection:Button({
    Title = "Save Button Positions",
    Callback = SaveButtonPositions,
})

PositionsSection:Button({
    Title = "Load Button Positions",
    Callback = LoadButtonPositions,
})

-- ============================================
-- 5. Reset All
-- ============================================
local ResetSection = SettingsTab:Section({
    Title = "Reset All",
    Side = "Left",
    Collapsed = true,
})

ResetSection:Button({
    Title = "Reset All Settings",
    Callback = function()
        if flying then stopFlying() flying = false end
        if autoJumpEnabled then autoJumpEnabled = false StopBhop() end
        if bhopHoldEnabled then bhopHoldEnabled = false bhopHoldActive = false end
        if rotationEnabled then rotationEnabled = false StopRotation() end
        if gravityEnabled then gravityEnabled = false workspace.Gravity = originalGravity or 196.2 end
        if reviveEnabled then reviveEnabled = false stopRevive() end
        if autoCarryEnabled then autoCarryEnabled = false StopAutoCarry() end
        if lagSwitchEnabled then lagSwitchEnabled = false end
        if demonEnabled then demonEnabled = false end
        
        local coreGui = game:GetService("CoreGui")
        local buttons = {
            "BhopFloatingButton",
            "LagSwitchFloatingButtonGUI",
            "CarryFloatingButton",
            "DemonFloatingButton",
        }
        
        for _, btnName in ipairs(buttons) do
            local gui = coreGui:FindFirstChild(btnName)
            if gui then gui:Destroy() end
        end
        
        if fpsTimerGui then fpsTimerGui:Destroy() fpsTimerGui = nil end
        
        WindUI:Notify({ Title = "Reset", Content = "All settings have been reset", Duration = 3 })
    end,
})

-- ============================================
-- 6. Themes Manager
-- ============================================
local ThemesSection = SettingsTab:Section({
    Title = "Themes",
    Side = "Left",
    Collapsed = true,
})

local function CreateCustomTheme(name, colors)
    pcall(function()
        WindUI:AddTheme({
            Name = name,
            Accent = colors.accent,
            Background = colors.background,
            Button = colors.button,
            Text = colors.text,
            Outline = colors.outline,
            Dialog = colors.dialog,
            Icon = colors.icon,
        })
    end)
end

local CustomThemes = {
    {
        Name = "Blood Moon",
        Colors = {
            accent = Color3.fromHex("#8B0000"),
            background = Color3.fromHex("#1a0000"),
            button = Color3.fromHex("#3d0000"),
            text = Color3.fromRGB(255, 255, 255),
            outline = Color3.fromHex("#660000"),
            dialog = Color3.fromHex("#2a0000"),
            icon = Color3.fromHex("#ff4444"),
        }
    },
    {
        Name = "Midnight Blue",
        Colors = {
            accent = Color3.fromHex("#1a2a6c"),
            background = Color3.fromHex("#0a0a1a"),
            button = Color3.fromHex("#1a1a3d"),
            text = Color3.fromRGB(200, 210, 255),
            outline = Color3.fromHex("#2a3a8c"),
            dialog = Color3.fromHex("#12122a"),
            icon = Color3.fromHex("#5a7aff"),
        }
    },
    {
        Name = "Neon Green",
        Colors = {
            accent = Color3.fromHex("#00ff88"),
            background = Color3.fromHex("#0a1a0a"),
            button = Color3.fromHex("#1a3d1a"),
            text = Color3.fromRGB(200, 255, 200),
            outline = Color3.fromHex("#00cc66"),
            dialog = Color3.fromHex("#0f2a0f"),
            icon = Color3.fromHex("#44ffaa"),
        }
    },
    {
        Name = "Ocean Deep",
        Colors = {
            accent = Color3.fromHex("#0044aa"),
            background = Color3.fromHex("#00081a"),
            button = Color3.fromHex("#001a3d"),
            text = Color3.fromRGB(180, 210, 255),
            outline = Color3.fromHex("#003388"),
            dialog = Color3.fromHex("#000d2a"),
            icon = Color3.fromHex("#3377ff"),
        }
    },
}

for _, theme in ipairs(CustomThemes) do
    CreateCustomTheme(theme.Name, theme.Colors)
end

local function LoadSavedTheme()
    local success, data = pcall(function() return readfile("Hyper_CustomTheme.txt") end)
    return success and data or "Blood Moon"
end

local function SaveTheme(themeName)
    pcall(function() writefile("Hyper_CustomTheme.txt", themeName) end)
end

local function ApplyTheme(themeName)
    pcall(function() WindUI:SetTheme(themeName) end)
end

local themeNames = {}
for _, theme in ipairs(CustomThemes) do
    table.insert(themeNames, theme.Name)
end
table.insert(themeNames, 1, "Crimson")
table.insert(themeNames, 2, "Dark")

local currentTheme = LoadSavedTheme()
ApplyTheme(currentTheme)

ThemesSection:Dropdown({
    Title = "Select Theme",
    Values = themeNames,
    Default = currentTheme,
    Callback = function(value)
        currentTheme = value
        ApplyTheme(value)
        SaveTheme(value)
        WindUI:Notify({ Title = "Theme", Content = "Theme changed to: " .. value, Duration = 2 })
    end,
})

ThemesSection:Button({
    Title = "Reset Theme",
    Callback = function()
        currentTheme = "Blood Moon"
        ApplyTheme("Blood Moon")
        SaveTheme("Blood Moon")
        WindUI:Notify({ Title = "Theme", Content = "Theme reset to Blood Moon", Duration = 2 })
    end,
})

print("[Settings] Loaded successfully!")
