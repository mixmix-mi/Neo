
-- ============================================
-- قسم FPS, Ping & Timer مع fallback
-- ============================================

-- تعريف SettingsTab (لو مش معرف)
local SettingsTab = nil
if not SettingsTab then
    -- البحث عن التاب في Window
    if Window and Window.Tabs then
        for _, tab in pairs(Window.Tabs) do
            if tab and (tab.Title == "Settings" or tab.Title == "الإعدادات") then
                SettingsTab = tab
                break
            end
        end
    end
    
    -- لو لسه مش موجود، اعمل تاب جديد
    if not SettingsTab then
        SettingsTab = Window:Tab({
            Title = "Settings",
            Icon = "settings",
            Locked = false
        })
    end
end

-- تعريف FPSSection (لو مش معرف)
local FPSSection = nil
if SettingsTab then
    -- البحث عن القسم في التاب
    for _, section in pairs(SettingsTab.Sections or {}) do
        if section and section.Title == "FPS, Ping & Timer" then
            FPSSection = section
            break
        end
    end
    
    -- لو مش موجود، اعمل قسم جديد
    if not FPSSection then
        FPSSection = SettingsTab:Section({
            Title = "FPS, Ping & Timer",
            Side = "Left",
            Collapsed = true,
        })
    end
end

-- ============================================
-- المتغيرات الخاصة بـ FPS, Ping & Timer
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local fpsTimerEnabled = false
local fpsTimerGui = nil
local fpsUpdateConnection = nil
local fpsGradientAnimation = nil

-- ============================================
-- دالة إنشاء البانل (Blood Moon Theme)
-- ============================================
local function CreateFPSPanel()
    local playerGui = LP:WaitForChild("PlayerGui")
    
    if fpsTimerGui then
        fpsTimerGui:Destroy()
        fpsTimerGui = nil
    end
    
    if fpsUpdateConnection then
        fpsUpdateConnection:Disconnect()
        fpsUpdateConnection = nil
    end
    if fpsGradientAnimation then
        fpsGradientAnimation:Disconnect()
        fpsGradientAnimation = nil
    end
    
    fpsTimerGui = Instance.new("ScreenGui")
    fpsTimerGui.Name = "HyperFPSPanel"
    fpsTimerGui.ResetOnSpawn = false
    fpsTimerGui.Parent = playerGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 180, 0, 55)
    container.Position = UDim2.new(0.01, 0, 0.01, 0)
    
    -- 🩸 Blood Moon Colors
    container.BackgroundColor3 = Color3.fromHex("#1a0000")      -- خلفية حمراء داكنة
    container.BackgroundTransparency = 0.1
    container.Parent = fpsTimerGui
    container.Active = true
    container.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")                    -- إطار أحمر داكن
    stroke.Thickness = 2
    stroke.Parent = container
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
    fpsLabel.Position = UDim2.new(0, 0, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: -- | Ping: --ms"
    fpsLabel.TextColor3 = Color3.fromHex("#ffcccc")             -- نص أحمر فاتح
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 12
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
    fpsLabel.Parent = container
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
    timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Text = "Time: 0h 0m 0s"
    timerLabel.TextColor3 = Color3.fromHex("#ffcccc")           -- نص أحمر فاتح
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
            stroke.Color = Color3.fromHex("#ff4444")             -- أحمر ناري عند السحب
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
        stroke.Color = Color3.fromHex("#660000")                 -- نرجع اللون الأصلي
    end)
    
    container.Destroying:Connect(function()
        if fpsUpdateConnection then
            fpsUpdateConnection:Disconnect()
            fpsUpdateConnection = nil
        end
        if fpsGradientAnimation then
            fpsGradientAnimation:Disconnect()
            fpsGradientAnimation = nil
        end
    end)
    
    return fpsTimerGui
end

-- ============================================
-- زر التحكم (مع fallback لو مش موجود)
-- ============================================
if FPSSection then
    FPSSection:Toggle({
        Title = "Show FPS, Ping & Timer",
        Icon = "activity",
        Value = false,
        Callback = function(state)
            fpsTimerEnabled = state
            if state then
                fpsTimerGui = CreateFPSPanel()
                if WindUI and WindUI.Notify then
                    WindUI:Notify({ Title = "FPS Panel", Content = "Panel shown", Duration = 2 })
                end
            else
                if fpsTimerGui then
                    if fpsUpdateConnection then
                        fpsUpdateConnection:Disconnect()
                        fpsUpdateConnection = nil
                    end
                    if fpsGradientAnimation then
                        fpsGradientAnimation:Disconnect()
                        fpsGradientAnimation = nil
                    end
                    fpsTimerGui:Destroy()
                    fpsTimerGui = nil
                end
                if WindUI and WindUI.Notify then
                    WindUI:Notify({ Title = "FPS Panel", Content = "Panel hidden", Duration = 2 })
                end
            end
        end,
    })
else
    warn("[FPS Panel] SettingsTab or FPSSection not found")
end

local PerfSection = SettingsTab:Section({
    Title = "Performance & Visuals",
    Side = "Left",
    Collapsed = false,
})
-- ============================================
-- 1. Invis Walls (Clear Invis Walls)
-- ============================================
local invisPartsEnabled = false

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

local function toggleInvisWalls(state)
    local folder = getInvisPartsFolder()
    if not folder then
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Invis Walls", Content = "InvisParts not found", Duration = 2 })
        end
        return
    end
    
    local changed = 0
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = not state
            changed = changed + 1
        end
    end
    if WindUI and WindUI.Notify then
        WindUI:Notify({ Title = "Invis Walls", Content = string.format("%s for %d objects", state and "Disabled" or "Enabled", changed), Duration = 2 })
    end
end

PerfSection:Toggle({
    Title = "Clear Invis Walls",
    Value = false,
    Callback = function(state)
        toggleInvisWalls(state)
    end
})

-- ============================================
-- 2. Streaming
-- ============================================
PerfSection:Button({
    Title = "Lower Chunks",
    Callback = function()
        workspace.StreamingMinRadius = 200
        workspace.StreamingTargetRadius = 500
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Streaming", Content = "Chunks lowered", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Hide Useless Chunks",
    Callback = function()
        workspace.StreamingMinRadius = 0
        workspace.StreamingTargetRadius = 500
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Streaming", Content = "Useless chunks hidden", Duration = 2 })
        end
    end
})

-- ============================================
-- 3. FPS & VSync & Graphics
-- ============================================
PerfSection:Button({
    Title = "Disable VSync",
    Callback = function()
        pcall(function() setfpscap(9999) end)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "VSync", Content = "Disabled", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Set FPS Cap Max",
    Callback = function()
        pcall(function() setfpscap(99999) end)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "FPS", Content = "Cap set to max", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Low Graphics",
    Desc = "Sets rendering quality to low",
    Callback = function()
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Graphics", Content = "Set to low", Duration = 2 })
        end
    end
})

-- ============================================
-- 4. Visual Effects
-- ============================================
PerfSection:Button({
    Title = "Hide Skybox",
    Desc = "Removes skybox for performance",
    Callback = function()
        pcall(function() game.Lighting.Sky = nil end)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Skybox", Content = "Hidden", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Disable Shadows",
    Desc = "Disables all shadows in workspace",
    Callback = function()
        local count = 0
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                count = count + 1
            end
        end
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Shadows", Content = "Disabled for " .. count .. " objects", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Disable Particles",
    Desc = "Removes all particle effects",
    Callback = function()
        local count = 0
        for _, particle in pairs(workspace:GetDescendants()) do
            if particle:IsA("ParticleEmitter") then
                particle:Destroy()
                count = count + 1
            end
        end
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Particles", Content = "Removed " .. count .. " emitters", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Low Poly Mode",
    Desc = "Converts meshes to low-poly for performance",
    Callback = function()
        local count = 0
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("UnionOperation") then
                part.Material = Enum.Material.Plastic
                part.RenderFidelity = Enum.RenderFidelity.Performance
                count = count + 1
            end
        end
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Low Poly", Content = "Applied to " .. count .. " objects", Duration = 2 })
        end
    end
})

-- ============================================
-- 5. Lighting & Time
-- ============================================
PerfSection:Button({
    Title = "Night",
    Desc = "Sets time to midnight",
    Callback = function()
        game.Lighting.TimeOfDay = "00:00:00"
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Time", Content = "Night mode", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Day",
    Desc = "Sets time to morning",
    Callback = function()
        game.Lighting.TimeOfDay = "08:00:00"
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Time", Content = "Day mode", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Anti Fog",
    Desc = "Removes fog for better visibility",
    Callback = function()
        local L = game.Lighting
        L.FogStart = 100000
        L.FogEnd = 1000000
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Fog", Content = "Removed", Duration = 2 })
        end
    end
})

PerfSection:Button({
    Title = "Disable Simplify Lighting",
    Desc = "Disables lighting simplifications",
    Callback = function()
        local L = game.Lighting
        L.Technology = Enum.Technology.Compatibility
        L.ShadowSoftness = 0
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Lighting", Content = "Simplified", Duration = 2 })
        end
    end
})

-- ============================================
-- 6. Anti-Aliasing
-- ============================================
PerfSection:Button({
    Title = "Reduce Anti-Aliasing",
    Desc = "Reduces anti-aliasing for performance",
    Callback = function()
        pcall(function()
            game:GetService("Rendering"):SetCore("AntiAliasing", Enum.AntiAliasingLevel.Two)
        end)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Anti-Aliasing", Content = "Reduced", Duration = 2 })
        end
    end
})

print("[Settings] Performance & Visuals section loaded!")
-- ================================
-- 2. Button Sizes (حجم الأزرار الطافية - Ocean Deep Style)
-- ================================
local SizesSection = SettingsTab:Section({
    Title = "Button Sizes",
    Side = "Left",
    Collapsed = true,
})

-- دالة مساعدة لتغيير حجم الزر
local function UpdateButtonSize(buttonName, size)
    local coreGui = game:GetService("CoreGui")
    local gui = coreGui:FindFirstChild(buttonName)
    if gui then
        local btn = gui:FindFirstChildOfClass("TextButton")
        if btn then
            local newWidth = math.max(120, math.min(size, 350))
            local newHeight = math.max(40, math.min(size * 0.35, 130))
            btn.Size = UDim2.new(0, newWidth, 0, newHeight)
            
            -- تحديث موقع الزر عشان يفضل في منتصف الشاشة تقريباً بعد تغيير الحجم
            local viewport = workspace.CurrentCamera.ViewportSize
            local newX = (viewport.X / 2) - (newWidth / 2)
            local newY = (viewport.Y / 2) - (newHeight / 2)
            btn.Position = UDim2.new(0, newX, 0, newY)
        end
    end
end

-- Bhop Button Size
SizesSection:Slider({
    Title = "Bhop Button Size",
    Desc = "Bunny Hop button size (120-350)",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("BhopFloatingButton", value)
        WindUI:Notify({ Title = "Button Size", Content = "Size: " .. value, Duration = 1 })
    end,
})

-- Lag Switch Button Size
SizesSection:Slider({
    Title = "Lag Switch Button Size",
    Desc = "Lag button size (120-350)",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("LagSwitchFloatingButtonGUI", value)
        WindUI:Notify({ Title = "Button Size", Content = "Size: " .. value, Duration = 1 })
    end,
})

-- Carry Button Size
SizesSection:Slider({
    Title = "Carry Button Size",
    Desc = "Carry button size (120-350)",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("CarryFloatingButton", value)
        WindUI:Notify({ Title = "Button Size", Content = "Size: " .. value, Duration = 1 })
    end,
})

-- Demon Mode Button Size
SizesSection:Slider({
    Title = "Demon Mode Button Size",
    Desc = "Demon mode button size (120-350)",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("DemonFloatingButton", value)
        WindUI:Notify({ Title = "Button Size", Content = "Size: " .. value, Duration = 1 })
    end,
})

-- Gravity Button Size
SizesSection:Slider({
    Title = "Gravity Button Size",
    Desc = "Gravity button size (120-350)",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("GravityFloatingButton", value)
        WindUI:Notify({ Title = "Button Size", Content = "Size: " .. value, Duration = 1 })
    end,
})

-- Instant Revive Button Size
SizesSection:Slider({
    Title = "Instant Revive Button Size",
    Desc = "Instant revive button size (120-350)",
    Value = { Min = 120, Max = 350, Default = 160 },
    Callback = function(value)
        UpdateButtonSize("InstantReviveFloatingButton", value)
        WindUI:Notify({ Title = "Button Size", Content = "Size: " .. value, Duration = 1 })
    end,
})
-- ================================
-- 3. Button Positions (حفظ/تحميل مواقع الأزرار)
-- ================================
local PositionsSection = SettingsTab:Section({
    Title = "Button Positions",
    Side = "Left",
    Collapsed = true,
})

-- قائمة الأزرار اللي هنحفظ مواقعها
local floatingButtons = {
    "BhopFloatingButton",
    "LagSwitchFloatingButtonGUI",
    "CarryFloatingButton",
    "DemonFloatingButton",
    "GravityFloatingButton",
    "InstantReviveFloatingButton"
}

-- حفظ مواقع الأزرار
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
    
    -- حفظ في ملف
    local success, err = pcall(function()
        writefile("Hyper_ButtonPositions.txt", game:GetService("HttpService"):JSONEncode(positions))
    end)
    
    if success then
        WindUI:Notify({ Title = "Positions", Content = "Button locations saved", Duration = 2 })
    else
        WindUI:Notify({ Title = "Positions", Content = "Save failed - writefile not supported", Duration = 2 })
    end
end

-- تحميل مواقع الأزرار
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
        WindUI:Notify({ Title = "Positions", Content = "Button locations loaded", Duration = 2 })
    else
        WindUI:Notify({ Title = "Positions", Content = "No saved file found", Duration = 2 })
    end
end

-- إعادة تعيين مواقع الأزرار (للمنتصف)
local function ResetButtonPositions()
    local coreGui = game:GetService("CoreGui")
    local viewport = workspace.CurrentCamera.ViewportSize
    
    for _, btnName in ipairs(floatingButtons) do
        local gui = coreGui:FindFirstChild(btnName)
        if gui then
            local btn = gui:FindFirstChildOfClass("TextButton")
            if btn then
                local newX = (viewport.X / 2) - (btn.AbsoluteSize.X / 2)
                local newY = (viewport.Y / 2) - (btn.AbsoluteSize.Y / 2)
                btn.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end
    
    WindUI:Notify({ Title = "Positions", Content = "Buttons reset to center", Duration = 2 })
end

PositionsSection:Button({
    Title = "Save Button Positions",
    Desc = "Saves current positions of all floating buttons",
    Callback = SaveButtonPositions,
})

PositionsSection:Button({
    Title = "Load Button Positions",
    Desc = "Loads last saved positions",
    Callback = LoadButtonPositions,
})

PositionsSection:Button({
    Title = "Reset Button Positions",
    Desc = "Resets all buttons to center of screen",
    Callback = ResetButtonPositions,
})
-- ================================
-- 4. زر إعادة تعيين الكل
-- ================================
local ResetSection = SettingsTab:Section({
    Title = "Reset All",
    Side = "Left",
    Collapsed = true,
})

ResetSection:Button({
    Title = "Reset All Settings",
    Desc = "Resets all script settings and closes floating buttons",
    Callback = function()
        -- إعادة تعيين الميزات
        if flying then
            stopFlying()
            flying = false
        end
        
        if autoJumpEnabled then
            autoJumpEnabled = false
            StopBhop()
        end
        
        if bhopHoldEnabled then
            bhopHoldEnabled = false
            bhopHoldActive = false
        end
        
        if rotationEnabled then
            rotationEnabled = false
            StopRotation()
        end
        
        if gravityEnabled then
            gravityEnabled = false
            workspace.Gravity = originalGravity or 196.2
        end
        
        if reviveEnabled then
            reviveEnabled = false
            stopRevive()
        end
        
        if autoCarryEnabled then
            autoCarryEnabled = false
            StopAutoCarry()
        end
        
        if lagSwitchEnabled then
            lagSwitchEnabled = false
        end
        
        if demonEnabled then
            demonEnabled = false
        end
        
        -- إخفاء كل الأزرار العائمة
        local coreGui = game:GetService("CoreGui")
        local floatingButtonsList = {
            "BhopFloatingButton",
            "LagSwitchFloatingButtonGUI",
            "CarryFloatingButton",
            "DemonFloatingButton",
            "GravityFloatingButton",
            "InstantReviveFloatingButton"
        }
        
        for _, btnName in ipairs(floatingButtonsList) do
            local gui = coreGui:FindFirstChild(btnName)
            if gui then
                gui:Destroy()
            end
        end
        
        -- إخفاء FPS Panel
        if fpsTimerGui then
            fpsTimerGui:Destroy()
            fpsTimerGui = nil
        end
        
        WindUI:Notify({ Title = "Reset", Content = "All settings have been reset", Duration = 3 })
    end,
})

-- ================================
-- Themes Manager - Custom Themes
-- ================================

local ThemesSection = SettingsTab:Section({
    Title = "Themes",
    Side = "Left",
    Collapsed = true,
})

-- ================================
-- Create Custom Theme Function
-- ================================
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

-- ================================
-- Custom Themes List
-- ================================
local CustomThemes = {
    {
        Name = "Blood Moon",
        Description = "Dark Red",
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
        Description = "Dark Blue",
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
        Description = "Bright Green",
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
        Name = "Royal Purple",
        Description = "Purple",
        Colors = {
            accent = Color3.fromHex("#6a0dad"),
            background = Color3.fromHex("#1a0a2a"),
            button = Color3.fromHex("#3d1a6a"),
            text = Color3.fromRGB(220, 200, 255),
            outline = Color3.fromHex("#4a1a8c"),
            dialog = Color3.fromHex("#251240"),
            icon = Color3.fromHex("#aa66ff"),
        }
    },
    {
        Name = "Golden Sun",
        Description = "Gold",
        Colors = {
            accent = Color3.fromHex("#ffaa00"),
            background = Color3.fromHex("#1a1a0a"),
            button = Color3.fromHex("#3d3d1a"),
            text = Color3.fromRGB(255, 240, 200),
            outline = Color3.fromHex("#cc8800"),
            dialog = Color3.fromHex("#2a2a0f"),
            icon = Color3.fromHex("#ffcc44"),
        }
    },
    {
        Name = "Cyber Pink",
        Description = "Pink",
        Colors = {
            accent = Color3.fromHex("#ff00ff"),
            background = Color3.fromHex("#1a0a1a"),
            button = Color3.fromHex("#3d1a3d"),
            text = Color3.fromRGB(255, 200, 255),
            outline = Color3.fromHex("#cc00cc"),
            dialog = Color3.fromHex("#2a0f2a"),
            icon = Color3.fromHex("#ff66ff"),
        }
    },
    {
        Name = "Arctic Ice",
        Description = "Ice Blue",
        Colors = {
            accent = Color3.fromHex("#00ccff"),
            background = Color3.fromHex("#0a1a2a"),
            button = Color3.fromHex("#1a3d5a"),
            text = Color3.fromRGB(200, 230, 255),
            outline = Color3.fromHex("#0099cc"),
            dialog = Color3.fromHex("#0f2a40"),
            icon = Color3.fromHex("#66ddff"),
        }
    },
    {
        Name = "Halloween",
        Description = "Orange",
        Colors = {
            accent = Color3.fromHex("#ff6600"),
            background = Color3.fromHex("#1a0a00"),
            button = Color3.fromHex("#3d1a00"),
            text = Color3.fromRGB(255, 220, 180),
            outline = Color3.fromHex("#cc5500"),
            dialog = Color3.fromHex("#2a1200"),
            icon = Color3.fromHex("#ff8844"),
        }
    },
    {
        Name = "Emerald",
        Description = "Green",
        Colors = {
            accent = Color3.fromHex("#00cc66"),
            background = Color3.fromHex("#0a1a0a"),
            button = Color3.fromHex("#1a3d2a"),
            text = Color3.fromRGB(200, 255, 220),
            outline = Color3.fromHex("#009944"),
            dialog = Color3.fromHex("#0f2a1a"),
            icon = Color3.fromHex("#44ff88"),
        }
    },
    {
        Name = "Rose Gold",
        Description = "Pink Gold",
        Colors = {
            accent = Color3.fromHex("#ff66b5"),
            background = Color3.fromHex("#1a0a15"),
            button = Color3.fromHex("#3d1a30"),
            text = Color3.fromRGB(255, 220, 240),
            outline = Color3.fromHex("#cc4488"),
            dialog = Color3.fromHex("#2a0f20"),
            icon = Color3.fromHex("#ff99cc"),
        }
    },
    {
        Name = "Ocean Deep",
        Description = "Deep Blue",
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
    {
        Name = "Lava",
        Description = "Fire Red",
        Colors = {
            accent = Color3.fromHex("#ff3300"),
            background = Color3.fromHex("#1a0500"),
            button = Color3.fromHex("#3d1000"),
            text = Color3.fromRGB(255, 200, 150),
            outline = Color3.fromHex("#cc2200"),
            dialog = Color3.fromHex("#2a0800"),
            icon = Color3.fromHex("#ff6644"),
        }
    },
}

-- Create all custom themes
for _, theme in ipairs(CustomThemes) do
    CreateCustomTheme(theme.Name, theme.Colors)
end
end
Theme(value)
        WindUI:Notify({
            Title = "Theme",
            Content = "Theme changed to: " .. value,
            Duration = 2,
        })
    end,
})



local themesText = "Custom Themes:\n\n"
for _, theme in ipairs(CustomThemes) do
    themesText = themesText .. "- " .. theme.Name .. " : " .. theme.Description .. "\n"
end
themesText = themesText .. "\nDefault Themes:\n- Crimson\n- Dark\n- Darker\n- Amethyst\n- Blood Red"



-- Reset Button
ThemesSection:Button({
    Title = "Reset Theme",
    Callback = function()
        currentTheme = "Blood Moon"
        ApplyTheme("Blood Moon")
        SaveTheme("Blood Moon")
        WindUI:Notify({
            Title = "Theme",
            Content = "Theme reset to Ocean Deep",
            Duration = 2,
        })
    end,
})