-- ================================
-- Chat Message - Neo Hyper
-- ================================
--[[
task.spawn(function()
    task.wait(1)
    
    local player = game:GetService("Players").LocalPlayer
    local chatService = game:GetService("TextChatService")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    local function sendChatMessage(message)
        pcall(function()
            -- طريقة 1: TextChatService
            if chatService and chatService.TextChannels then
                local channel = chatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then
                    channel:SendAsync(message)
                    return
                end
            end
            
            -- طريقة 2: ReplicatedStorage (الطريقة القديمة)
            local event = replicatedStorage:FindFirstChild("Events") and 
                         replicatedStorage.Events:FindFirstChild("Chat") and
                         replicatedStorage.Events.Chat:FindFirstChild("Send")
            if event then
                event:FireServer(message)
                return
            end
            
            -- طريقة 3: Chat Service القديم
            local chat = game:GetService("Chat")
            if chat and chat:FindFirstChild("Chat") then
                chat.Chat:FireServer(message)
                return
            end
        end)
    end
    
    sendChatMessage("Welcome Owner Of Neo Hyper")
end)
--]]
-- ===== تعطيل المخرجات أولاً =====
--print = function() end
--pcall(function() end)

-- ===== تحميل WindUI =====
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end

WindUI.TransparencyValue = 0.15
WindUI:SetTheme("Dark")
WindUI.Notify = function() end

-- ===== إنشاء النافذة =====
local Window = WindUI:CreateWindow({
    Title = "Neo Hyper v1.0",
    Icon = "solar:crown-minimalistic-outline",
    Author = "By M4X EVA",
    HideSearchBar = true,
    Theme = "Dark",
    Folder = "Hyper_V1",
    Size = UDim2.fromOffset(550, 450),
    KeySystem = {                                                   
        Note = "Example Key System. With platoboost.",              
        API = {                                                     
            { -- PlatoBoost
                Type = "platoboost",                                
                ServiceId = 26331,
                Secret = "83088530-751f-4d3c-9a51-97effbd2e826",
            },                                                      
        },                                                          
    },                                                              
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

Window:EditOpenButton({
    Title = "Neo Hyper",
    Icon = "solar:crown-minimalistic-outline",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 0,
    Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(200,50,0)),
    Enabled = true,
    Draggable = true,
})
-- ============================================
-- GitHub Module Links Configuration (Ordered)
-- ============================================
local files = {
    {name = "Home",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/H.lua"},
    {name = "Auto",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/A.lua"},
    {name = "ESP",      url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/E.lua"},
    {name = "Misc",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/M.lua"},
    {name = "VIP",      url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/V.lua"},
  --  {name = "Se",       url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/S.lua"},
    {name = "se",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/se.lua"}
}

-- ============================================
-- Loop to Fetch and Execute Modules
-- ============================================
for _, module in ipairs(files) do
    local moduleName = module.name
    local url = module.url

    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and content then
        local runCode, err = loadstring(content)
        if runCode then
            task.spawn(function()
                runCode(Window, ConfigManager, mainConfig)
            end)
        end
    end
    
    task.wait(0.1)
end


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
-- Configuration System - WindUI (في Settings Tab)
-- ============================================

-- ============================================
-- 1. Config Section في Settings Tab
-- ============================================
local ConfigSection = SettingsTab:Section({
    Title = "Configuration",
    Side = "Left",
    Collapsed = true,
})

-- متغيرات النظام
local ConfigSystem = {
    CurrentConfig = "",
    ConfigsList = {},
    ConfigFolder = "Hyper_Configs",
}

-- ============================================
-- 2. دوال النظام
-- ============================================

-- الحصول على قائمة الملفات
local function GetConfigFiles()
    local files = {}
    pcall(function()
        local items = listfiles(ConfigSystem.ConfigFolder)
        for _, item in ipairs(items) do
            if item:match("%.json$") then
                local name = item:match("([^/]+)%.json$")
                if name then
                    table.insert(files, name)
                end
            end
        end
    end)
    return files
end

-- تحديث قائمة الملفات
local function RefreshConfigList()
    ConfigSystem.ConfigsList = GetConfigFiles()
    return ConfigSystem.ConfigsList
end

-- حفظ الكونفج
local function SaveConfig(name)
    if not name or name == "" then
        WindUI:Notify({ Title = "Config", Content = "Please enter a config name", Duration = 2 })
        return false
    end
    
    -- تجميع الإعدادات
    local configData = {
        name = name,
        saved_at = os.date("%Y-%m-%d %H:%M:%S"),
        settings = {
            -- هنا هتضيف إعداداتك
            speed = getgenv().Speed or 1500,
            jumpCap = getgenv().JumpCap or 1,
            strafe = getgenv().AirStrafeAcceleration or 187,
            applyMode = getgenv().ApplyMode or "Unoptimized",
        }
    }
    
    local success = pcall(function()
        writefile(ConfigSystem.ConfigFolder .. "/" .. name .. ".json", 
                  game:GetService("HttpService"):JSONEncode(configData))
    end)
    
    if success then
        RefreshConfigList()
        ConfigSystem.CurrentConfig = name
        WindUI:Notify({ Title = "Config", Content = "Saved: " .. name, Duration = 2 })
        return true
    else
        WindUI:Notify({ Title = "Config", Content = "Failed to save", Duration = 2 })
        return false
    end
end

-- تحميل الكونفج
local function LoadConfig(name)
    if not name or name == "" then
        WindUI:Notify({ Title = "Config", Content = "Select a config", Duration = 2 })
        return false
    end
    
    local success, data = pcall(function()
        return readfile(ConfigSystem.ConfigFolder .. "/" .. name .. ".json")
    end)
    
    if success and data then
        local config = game:GetService("HttpService"):JSONDecode(data)
        if config and config.settings then
            -- تطبيق الإعدادات
            if config.settings.speed then
                getgenv().Speed = config.settings.speed
                -- تطبيق السرعة
            end
            if config.settings.jumpCap then
                getgenv().JumpCap = config.settings.jumpCap
                -- تطبيق Jump Cap
            end
            if config.settings.strafe then
                getgenv().AirStrafeAcceleration = config.settings.strafe
                -- تطبيق Strafe
            end
            if config.settings.applyMode then
                getgenv().ApplyMode = config.settings.applyMode
            end
            
            ConfigSystem.CurrentConfig = name
            WindUI:Notify({ Title = "Config", Content = "Loaded: " .. name, Duration = 2 })
            return true
        end
    end
    
    WindUI:Notify({ Title = "Config", Content = "Failed to load", Duration = 2 })
    return false
end

-- حذف الكونفج
local function DeleteConfig(name)
    if not name or name == "" then
        WindUI:Notify({ Title = "Config", Content = "Select a config", Duration = 2 })
        return false
    end
    
    local success = pcall(function()
        delfile(ConfigSystem.ConfigFolder .. "/" .. name .. ".json")
    end)
    
    if success then
        RefreshConfigList()
        if ConfigSystem.CurrentConfig == name then
            ConfigSystem.CurrentConfig = ""
        end
        WindUI:Notify({ Title = "Config", Content = "Deleted: " .. name, Duration = 2 })
        return true
    else
        WindUI:Notify({ Title = "Config", Content = "Failed to delete", Duration = 2 })
        return false
    end
end

-- إنشاء مجلد الإعدادات
pcall(function()
    makefolder(ConfigSystem.ConfigFolder)
end)

-- ============================================
-- 3. واجهة المستخدم
-- ============================================

-- Dropdown لاختيار الملف
local ConfigDropdown = ConfigSection:Dropdown({
    Title = "Select Config",
    Values = RefreshConfigList(),
    Default = "",
    Callback = function(value)
        ConfigSystem.CurrentConfig = value
    end
})

-- زر تحميل الملف
ConfigSection:Button({
    Title = "Load Config",
    Callback = function()
        if ConfigSystem.CurrentConfig and ConfigSystem.CurrentConfig ~= "" then
            LoadConfig(ConfigSystem.CurrentConfig)
        else
            WindUI:Notify({ Title = "Config", Content = "Select a config first", Duration = 2 })
        end
    end
})

-- زر حفظ الملف
ConfigSection:Button({
    Title = "Save Config",
    Callback = function()
        if ConfigSystem.CurrentConfig and ConfigSystem.CurrentConfig ~= "" then
            SaveConfig(ConfigSystem.CurrentConfig)
        else
            WindUI:Notify({ Title = "Config", Content = "Enter a config name first", Duration = 2 })
        end
    end
})

-- زر حذف الملف
ConfigSection:Button({
    Title = "Delete Config",
    Callback = function()
        if ConfigSystem.CurrentConfig and ConfigSystem.CurrentConfig ~= "" then
            DeleteConfig(ConfigSystem.CurrentConfig)
            ConfigSystem.CurrentConfig = ""
            ConfigDropdown:SetValues(RefreshConfigList())
        else
            WindUI:Notify({ Title = "Config", Content = "Select a config first", Duration = 2 })
        end
    end
})

-- Input لإدخال اسم الملف
ConfigSection:Input({
    Title = "Config Name",
    Placeholder = "Enter config name...",
    Callback = function(value)
        if value and value ~= "" then
            ConfigSystem.CurrentConfig = value
        end
    end
})

-- زر إنشاء ملف جديد
ConfigSection:Button({
    Title = "Create Config",
    Callback = function()
        if ConfigSystem.CurrentConfig and ConfigSystem.CurrentConfig ~= "" then
            SaveConfig(ConfigSystem.CurrentConfig)
            ConfigDropdown:SetValues(RefreshConfigList())
        else
            WindUI:Notify({ Title = "Config", Content = "Enter a config name", Duration = 2 })
        end
    end
})

-- ============================================
-- 4. Auto Load System
-- ============================================
local function AutoLoadLastConfig()
    local configs = RefreshConfigList()
    if #configs > 0 then
        -- تحميل آخر كونفج تم استخدامه
        local lastConfig = configs[#configs]
        LoadConfig(lastConfig)
        ConfigSystem.CurrentConfig = lastConfig
        ConfigDropdown:SetValue(lastConfig)
    end
end

-- تشغيل التحميل التلقائي
task.spawn(function()
    task.wait(2)
    AutoLoadLastConfig()
end)

-- ============================================
-- 5. زر تحديث القائمة
-- ============================================
ConfigSection:Button({
    Title = "Refresh List",
    Callback = function()
        ConfigDropdown:SetValues(RefreshConfigList())
        WindUI:Notify({ Title = "Config", Content = "List refreshed", Duration = 2 })
    end
})

-- ============================================
-- 6. إشعار التحميل
-- ============================================
print("[Config System] Loaded successfully in Settings tab!")
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
