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
print = function() end
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
-- CONFIG SYSTEM - HYPER V1.0 (Custom List Method)
-- ============================================

-- 1. التأكد من وجود ConfigManager
local ConfigManager = Window.ConfigManager
if not ConfigManager then
    warn("[Config] ConfigManager not found!")
end

-- 2. إنشاء الكونفج الافتراضي
local ConfigName = "HyperConfig"
local myConfig = ConfigManager:CreateConfig(ConfigName)

-- 3. التحميل التلقائي عند بدء التشغيل
task.spawn(function()
    task.wait(1.5)
    local allConfigs = ConfigManager:AllConfigs()
    if #allConfigs > 0 then
        local firstConfig = allConfigs[1]
        ConfigName = firstConfig
        myConfig = ConfigManager:CreateConfig(firstConfig)
        myConfig:Load()
        print("[Config] Auto-loaded: " .. firstConfig)
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = "Config", Content = "Loaded: " .. firstConfig, Duration = 2 })
        end
    end
end)



local ConfigSection = SettingsTab:Section({
    Title = "Configuration",
    Side = "Left",
    Collapsed = false,
})

-- Input لاسم الكونفج
ConfigSection:Input({
    Title = "Config Name",
    Placeholder = "Enter config name...",
    Value = ConfigName,
    Callback = function(value)
        if value and value ~= "" then
            ConfigName = value
        end
    end
})

ConfigSection:Space()

-- Dropdown لكل الكونفجات
local AllConfigs = ConfigManager:AllConfigs()
local AllConfigsDropdown = ConfigSection:Dropdown({
    Title = "All Configs",
    Values = #AllConfigs > 0 and AllConfigs or {"No Configs"},
    Value = #AllConfigs > 0 and AllConfigs[1] or nil,
    Callback = function(value)
        if value and value ~= "No Configs" then
            ConfigName = value
        end
    end
})

ConfigSection:Space()

-- زر حفظ
ConfigSection:Button({
    Title = "Save Config",
    Justify = "Center",
    Callback = function()
        if ConfigName and ConfigName ~= "" then
            myConfig = ConfigManager:Config(ConfigName)
            if myConfig:Save() then
                WindUI:Notify({ Title = "Saved", Content = "Config: " .. ConfigName, Duration = 2 })
                AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
            else
                WindUI:Notify({ Title = "Error", Content = "No elements with Flag found!", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Enter a config name", Duration = 2 })
        end
    end
})

ConfigSection:Space()

-- زر تحميل
ConfigSection:Button({
    Title = "Load Config",
    Justify = "Center",
    Callback = function()
        if ConfigName and ConfigName ~= "" and ConfigName ~= "No Configs" then
            myConfig = ConfigManager:CreateConfig(ConfigName)
            if myConfig:Load() then
                WindUI:Notify({ Title = "Loaded", Content = "Config: " .. ConfigName, Duration = 2 })
            else
                WindUI:Notify({ Title = "Error", Content = "Failed to load", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Select a config first", Duration = 2 })
        end
    end
})

ConfigSection:Space()

-- زر حذف
ConfigSection:Button({
    Title = "Delete Config",
    Justify = "Center",
    Callback = function()
        if ConfigName and ConfigName ~= "" and ConfigName ~= "No Configs" then
            myConfig = ConfigManager:CreateConfig(ConfigName)
            if myConfig:Delete() then
                WindUI:Notify({ Title = "Deleted", Content = "Config: " .. ConfigName, Duration = 2 })
                AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
                ConfigName = ""
            else
                WindUI:Notify({ Title = "Error", Content = "Failed to delete", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Select a config first", Duration = 2 })
        end
    end
})

ConfigSection:Space()

-- زر إنشاء
ConfigSection:Button({
    Title = "Create Config",
    Justify = "Center",
    Callback = function()
        if ConfigName and ConfigName ~= "" then
            myConfig = ConfigManager:CreateConfig(ConfigName)
            if myConfig:Save() then
                WindUI:Notify({ Title = "Created", Content = "Config: " .. ConfigName, Duration = 2 })
                AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
                AllConfigsDropdown:SetValue(ConfigName)
            else
                WindUI:Notify({ Title = "Error", Content = "Failed to create", Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Enter a name first", Duration = 2 })
        end
    end
})

ConfigSection:Space()

-- زر تحديث القائمة
ConfigSection:Button({
    Title = "Refresh List",
    Justify = "Center",
    Callback = function()
        AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
        WindUI:Notify({ Title = "Refreshed", Content = "List updated", Duration = 2 })
    end
})

-- ============================================
-- 🔵 تسجيل العناصر بقائمة مخصصة (الطريقة الرابعة)
-- ============================================
local elementsToRegister = {
    -- ===== من ملف H.lua (Home) =====
    "AntiAFKToggle",
    "FlyToggle",
    -- الأسماء الصحيحة للعناصر دي في elementsToRegister:
"NextbotESP",                     -- Toggle
"NextbotHighlight",               -- Toggle
"NextbotESPColorDropdown",        -- Dropdown
"NextbotHighlightColorDropdown",  -- Dropdown
-- الأسماء الصحيحة للعناصر دي في elementsToRegister:
"PlayerESP",               -- Toggle
"NormalColorDropdown",     -- Dropdown
"DownedColorDropdown",     -- Dropdown
"PlayerHighlight",         -- Toggle
-- "RefreshESPButton"      -- Button مش بيتسجل في الكونفج

    
    -- ===== من ملف M.lua (Misc) =====
    -- Player Modifications
    "SpeedInput",
    "JumpCapInput",
    "StrafeInput",
    "ApplyMethodDropdown",
    
    -- Yourself
    "AutoReviveToggle",
    "RespawnMethodDropdown",
    "ReviveFloatingButtonToggle",
    
    -- Interactions
    "CarryToggle",
    "CarryDelayInput",
    "ReviveToggle",
    "ReviveDelayInput",
    
    -- Infinite Slide
    "InfiniteSlideToggle",
    "SlideFrictionSlider",
    

    -- ===== من M.lua (AutoTrimp) =====
    "AutoTrimpToggle",
    "AutoTrimpGUIToggle",
    "AutoTrimpSpeedInput",
    -- Auto Jump
    "AutoJumpTypeDropdown",
    "RotationToggle",
    "BunnyHopToggle",
    "BhopHoldToggle",
    "BhopButtonToggle",
    "JumpPowerSlider",
    "BhopModeDropdown",
    "BhopAccelSlider",
    "JumpCooldownSlider",
    
    -- Emote Speed
    "EmoteSpeedModeDropdown",
    "EmoteSpeedValueInput",
    
    -- Lag Switch
    "LagSwitchToggle",
    "LagDurationSlider",
    "LagIntensitySlider",
    "LagFloatingButtonToggle",
    "LagKeybind",
    
    -- Demon Mode
    "DemonToggle",
    "DemonRiseHeightSlider",
    "DemonRiseSpeedSlider",
    "DemonLagDurationSlider",
    "DemonLagIntensitySlider",
    "DemonFloatingButtonToggle",
    "DemonKeybind",
    
    -- Gravity
    "GravityToggle",
    "GravityValueInput",
    "GravityFloatingButtonToggle",
    "GravityKeybind",
    
    -- ===== من ملف E.lua (ESP) =====
    "PlayerESP",
    "NormalColorDropdown",
    "DownedColorDropdown",
    "PlayerHighlight",
    "NextbotESP",
    "NextbotHighlight",
    "NextbotESPColorDropdown",
    "NextbotHighlightColorDropdown",
    "NoFogToggle",
    "FullBrightToggle",
    "RemoveBarriersToggle",
    "BarriersVisibleToggle",
    
    -- ===== من ملف A.lua (Auto Farm) =====
    "AFKFarmToggle",
    "TicketFarmToggle",
    "CashFarmToggle",
    "AFKPlatformHeightSlider",
    -- من V.lua (Visuals)
    "HeadlessToggle",
    "KorbloxToggle",
    "Cosmetic1Input",
    "Cosmetic2Input",
    
    -- Emote Slots (12 Slot)
    "CurrentEmote1", "SelectEmote1",
    "CurrentEmote2", "SelectEmote2",
    "CurrentEmote3", "SelectEmote3",
    "CurrentEmote4", "SelectEmote4",
    "CurrentEmote5", "SelectEmote5",
    "CurrentEmote6", "SelectEmote6",
    "CurrentEmote7", "SelectEmote7",
    "CurrentEmote8", "SelectEmote8",
    "CurrentEmote9", "SelectEmote9",
    "CurrentEmote10", "SelectEmote10",
    "CurrentEmote11", "SelectEmote11",
    "CurrentEmote12", "SelectEmote12",
    
    -- ... باقي الأسماء
}

-- قائمة الـ Flags لكل العناصر في كل الملفات

-- ============================================
-- تسجيل كل العناصر في القائمة
-- ============================================
local registeredCount = 0

for _, flag in ipairs(elementsToRegister) do
    local element = nil
    
    -- البحث في Tabs.Misc
    if Tabs and Tabs.Misc then
        if Tabs.Misc.Toggles and Tabs.Misc.Toggles[flag] then
            element = Tabs.Misc.Toggles[flag]
        elseif Tabs.Misc.Sliders and Tabs.Misc.Sliders[flag] then
            element = Tabs.Misc.Sliders[flag]
        elseif Tabs.Misc.Inputs and Tabs.Misc.Inputs[flag] then
            element = Tabs.Misc.Inputs[flag]
        elseif Tabs.Misc.Dropdowns and Tabs.Misc.Dropdowns[flag] then
            element = Tabs.Misc.Dropdowns[flag]
        elseif Tabs.Misc.Keybinds and Tabs.Misc.Keybinds[flag] then
            element = Tabs.Misc.Keybinds[flag]
        end
    end
    
    -- البحث في Tabs.ESP
    if not element and Tabs and Tabs.ESP then
        if Tabs.ESP.Toggles and Tabs.ESP.Toggles[flag] then
            element = Tabs.ESP.Toggles[flag]
        elseif Tabs.ESP.Sliders and Tabs.ESP.Sliders[flag] then
            element = Tabs.ESP.Sliders[flag]
        elseif Tabs.ESP.Dropdowns and Tabs.ESP.Dropdowns[flag] then
            element = Tabs.ESP.Dropdowns[flag]
        end
    end
    
    -- البحث في Tabs.Auto
    if not element and Tabs and Tabs.Auto then
        if Tabs.Auto.Toggles and Tabs.Auto.Toggles[flag] then
            element = Tabs.Auto.Toggles[flag]
        elseif Tabs.Auto.Sliders and Tabs.Auto.Sliders[flag] then
            element = Tabs.Auto.Sliders[flag]
        end
    end
    
    -- البحث في Tabs.Main (Home)
    if not element and Tabs and Tabs.Main then
        if Tabs.Main.Toggles and Tabs.Main.Toggles[flag] then
            element = Tabs.Main.Toggles[flag]
        elseif Tabs.Main.Inputs and Tabs.Main.Inputs[flag] then
            element = Tabs.Main.Inputs[flag]
        end
    end
    
    -- البحث في Tabs.VIP
    if not element and Tabs and Tabs.VIP then
        if Tabs.VIP.Toggles and Tabs.VIP.Toggles[flag] then
            element = Tabs.VIP.Toggles[flag]
        end
    end
    
    -- تسجيل العنصر لو اتوجد
    if element then
        myConfig:Register(flag, element)
        registeredCount = registeredCount + 1
    end
end

print("[Config] Registered " .. registeredCount .. " elements")
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
