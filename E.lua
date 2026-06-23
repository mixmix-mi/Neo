-- ============================================
-- تعريف الخدمات (في بداية الكود)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- ============================================
-- تعريف التابات
-- ============================================
local Tabs = {
    ESP = Window:Tab({ Title = "ESP", Icon = "eye", Locked = false }),
}
-- ================================
-- تبويب ESP
-- ================================
local ESPTab = Tabs.ESP

-- ================================
-- Player ESP & Highlight (في نفس القسم)
-- ================================
local PlayerESPSection = ESPTab:Section({
    Title = "Player ESP & Highlight",
    Side = "Left",
    Collapsed = true,
})

-- ================================
-- المتغيرات العامة
-- ================================
local PlayerESPEnabled = false
local PlayerESPInstances = {}
local PlayerESPConnection = nil
local HighlightsEnabled = false
local HighlightsConnection = nil
local PlayerHighlights = {}
-- الألوان المثالية لـ 
local normalColor = Color3.fromRGB(255, 255, 255)    -- أبيض
local downedColor = Color3.fromRGB(255, 0, 0)        -- أحمر
-- ================================
-- دوال مشتركة
-- ================================

local function GetTargetPart(character)
    if not character then return nil end
    return character:FindFirstChild("Head")
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("HumanoidRootPart")
        or character:FindFirstChildWhichIsA("BasePart")
end

local function IsPlayerDowned(player)
    if not player or not player.Character then return false end
    local char = player.Character
    if char:GetAttribute("Downed") == true then return true end
    local hum = char:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then return true end
    return false
end

-- ================================
-- 1. ESP اللاعبين
-- ================================

local function CreatePlayerESP(player)
    if player == LP then return end
    local character = player.Character
    if not character then return end
    
    local targetPart = GetTargetPart(character)
    if not targetPart then return end
    
    -- إخفاء الاسم الأصلي
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    
    if PlayerESPInstances[player] then
        PlayerESPInstances[player]:Destroy()
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP_Hyper"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 140, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1500
    billboard.Parent = targetPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name
    label.TextColor3 = normalColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = billboard
    
    PlayerESPInstances[player] = billboard
    return billboard
end

local function ClearPlayerESP()
    for player, gui in pairs(PlayerESPInstances) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    PlayerESPInstances = {}
end

local function UpdateAllPlayerESP()
    if not PlayerESPEnabled then return end
    
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    for player, gui in pairs(PlayerESPInstances) do
        if not player or not player.Parent or not player.Character then
            if gui then gui:Destroy() end
            PlayerESPInstances[player] = nil
        else
            local character = player.Character
            local targetPart = GetTargetPart(character)
            local label = gui:FindFirstChildOfClass("TextLabel")
            
            if targetPart and gui.Adornee ~= targetPart then
                gui.Adornee = targetPart
                gui.Parent = targetPart
            end
            
            if targetPart and label then
                local isDowned = IsPlayerDowned(player)
                local color = isDowned and downedColor or normalColor
                
                local suffix = ""
                if isDowned then
                    suffix = " [DOWNED]"
                elseif character:FindFirstChild("Revives") then
                    suffix = " [REVIVES]"
                end
                
                local distance = ""
                if myRoot then
                    local dist = math.floor((targetPart.Position - myRoot.Position).Magnitude)
                    distance = string.format(" [%dm]", dist)
                end
                
                local newText = player.Name .. distance .. suffix
                if label.Text ~= newText then
                    label.Text = newText
                end
                if label.TextColor3 ~= color then
                    label.TextColor3 = color
                end
            end
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and not PlayerESPInstances[player] then
            CreatePlayerESP(player)
        end
    end
end

-- ================================
-- 2. هايلايت اللاعبين (بنفس ألوان ESP)
-- ================================

local function UpdatePlayerHighlight(player)
    if not player or player == LP then return end
    if not HighlightsEnabled then return end
    
    local character = player.Character
    if not character then return end
    
    local isDowned = IsPlayerDowned(player)
    local color = isDowned and downedColor or normalColor
    
    if PlayerHighlights[player] then
        local highlight = PlayerHighlights[player]
        if highlight and highlight.Parent then
            highlight.FillColor = color
            highlight.OutlineColor = color
            return
        else
            PlayerHighlights[player] = nil
        end
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "HyperHighlight_" .. player.Name
    highlight.Parent = character
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.OutlineColor = color
    
    PlayerHighlights[player] = highlight
end

local function ClearAllHighlights()
    for player, highlight in pairs(PlayerHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    PlayerHighlights = {}
end

local function UpdateAllHighlights()
    if not HighlightsEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            UpdatePlayerHighlight(player)
        end
    end
end

-- ================================
-- عناصر التحكم في الواجهة
-- ================================

-- Toggle ESP
PlayerESPSection:Toggle({
    Title = "ESP Players",
    Desc = "Display player names with distance and status",
    Value = false,
    Callback = function(state)
        PlayerESPEnabled = state
        if state then
            ClearPlayerESP()
            UpdateAllPlayerESP()
            if PlayerESPConnection then PlayerESPConnection:Disconnect() end
            PlayerESPConnection = RunService.Heartbeat:Connect(UpdateAllPlayerESP)
            WindUI:Notify({ Title = "ESP", Content = "Players ESP Enabled", Duration = 2 })
        else
            if PlayerESPConnection then
                PlayerESPConnection:Disconnect()
                PlayerESPConnection = nil
            end
            ClearPlayerESP()
            WindUI:Notify({ Title = "ESP", Content = "Players ESP Disabled", Duration = 2 })
        end
    end,
})

-- لون ESP العادي (Blood Moon)
PlayerESPSection:Dropdown({
    Title = "Normal Color",
    Values = { "Blood Red", "Ocean Deep", "White", "Red", "Green", "Blue", "Yellow", "Cyan", "Purple" },
    Default = "Blood Red",
    Callback = function(value)
        local colors = {
            ["Blood Red"] = Color3.fromHex("#ff2222"),
            ["Ocean Deep"] = Color3.fromRGB(0, 68, 170),
            White = Color3.fromRGB(255, 255, 255),
            Red = Color3.fromRGB(255, 0, 0),
            Green = Color3.fromRGB(0, 255, 0),
            Blue = Color3.fromRGB(0, 0, 255),
            Yellow = Color3.fromRGB(255, 255, 0),
            Cyan = Color3.fromRGB(0, 255, 255),
            Purple = Color3.fromRGB(255, 0, 255),
        }
        normalColor = colors[value] or Color3.fromHex("#ff2222")
        if PlayerESPEnabled then
            UpdateAllPlayerESP()
        end
        if HighlightsEnabled then
            UpdateAllHighlights()
        end
    end,
})

-- لون ESP للميتين (Blood Moon)
PlayerESPSection:Dropdown({
    Title = "Downed Color",
    Values = { "Golden Orange", "Red", "Ocean Deep", "White", "Green", "Blue", "Yellow", "Cyan", "Purple" },
    Default = "Golden Orange",
    Callback = function(value)
        local colors = {
            ["Golden Orange"] = Color3.fromHex("#ffaa00"),
            Red = Color3.fromRGB(255, 0, 0),
            ["Ocean Deep"] = Color3.fromRGB(0, 68, 170),
            White = Color3.fromRGB(255, 255, 255),
            Green = Color3.fromRGB(0, 255, 0),
            Blue = Color3.fromRGB(0, 0, 255),
            Yellow = Color3.fromRGB(255, 255, 0),
            Cyan = Color3.fromRGB(0, 255, 255),
            Purple = Color3.fromRGB(255, 0, 255),
        }
        downedColor = colors[value] or Color3.fromHex("#ffaa00")
        if PlayerESPEnabled then
            UpdateAllPlayerESP()
        end
        if HighlightsEnabled then
            UpdateAllHighlights()
        end
    end,
})

-- زر Refresh
PlayerESPSection:Button({
    Title = "Refresh ESP",
    Desc = "Manually refresh all player ESP",
    Callback = function()
        if PlayerESPEnabled then
            ClearPlayerESP()
            UpdateAllPlayerESP()
            WindUI:Notify({ Title = "ESP", Content = "Refreshed", Duration = 1 })
        else
            WindUI:Notify({ Title = "ESP", Content = "Enable ESP first", Duration = 1 })
        end
    end,
})
-- Toggle Highlight (Blood Moon)
PlayerESPSection:Toggle({
    Title = "Player Highlight",
    Desc = "Highlight players with Blood Moon colors",
    Value = false,
    Callback = function(state)
        HighlightsEnabled = state
        if state then
            ClearAllHighlights()
            UpdateAllHighlights()
            if HighlightsConnection then HighlightsConnection:Disconnect() end
            HighlightsConnection = RunService.Heartbeat:Connect(UpdateAllHighlights)
            WindUI:Notify({ Title = "Highlight", Content = "Enabled (Blood Moon Colors)", Duration = 2 })
        else
            if HighlightsConnection then
                HighlightsConnection:Disconnect()
                HighlightsConnection = nil
            end
            ClearAllHighlights()
            WindUI:Notify({ Title = "Highlight", Content = "Disabled", Duration = 2 })
        end
    end,
})

-- ============================================
-- 🛠️ Services & Player Definition
-- ============================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Wait for the character to exist for the first time
if LP.Character then
    task.wait(1)
    if PlayerESPEnabled then UpdateAllPlayerESP() end
    if HighlightsEnabled then UpdateAllHighlights() end
end

-- ============================================
-- 🔄 Character Added Event
-- ============================================
LP.CharacterAdded:Connect(function()
    task.wait(1)
    
    -- We use pcall to prevent errors if these functions are not loaded yet
    pcall(function()
        if PlayerESPEnabled then
            ClearPlayerESP()
            UpdateAllPlayerESP()
        end
    end)
    
    pcall(function()
        if HighlightsEnabled then
            ClearAllHighlights()
            UpdateAllHighlights()
        end
    end)
end)




-- ================================
-- Nextbot ESP & Highlight
-- ===============================
local NextbotSection = Tabs.ESP:Section({  -- غير من ESPTab إلى Tabs.ESP
    Title = "Nextbot ESP & Highlight",
    Side = "Left",
    Collapsed = true,
})

-- ================================
-- متغيرات الألوان لـ Nextbot
-- ================================
local nextbotESPColor = Color3.fromRGB(255, 0, 0)
local nextbotHighlightColor = Color3.fromRGB(255, 0, 0)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================================
-- متغيرات Nextbot ESP
-- ================================
local nextbotESPEnabled = false
local nextbotHighlightEnabled = false
local nextbotBillboards = {}
local nextbotHighlights = {}
local nextbotConnection = nil

-- قائمة أسماء الـ Nextbots من ReplicatedStorage
local nextBotNames = {}
local npcsFolder = ReplicatedStorage:FindFirstChild("NPCs")
if npcsFolder then
    for _, npc in ipairs(npcsFolder:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

-- ================================
-- دالة التحقق من Nextbot
-- ================================
local function IsNextbotModel(model)
    if not model or not model.Name then return false end
    
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    
    local nameLower = model.Name:lower()
    return nameLower:find("nextbot") or 
           nameLower:find("scp") or 
           nameLower:find("monster") or
           nameLower:find("creep") or
           nameLower:find("enemy") or
           nameLower:find("zombie") or
           nameLower:find("ghost") or
           nameLower:find("demon")
end

-- ================================
-- دالة للحصول على أفضل جزء للـ ESP
-- ================================
local function GetNextbotTargetPart(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Head")
        or model:FindFirstChild("Torso")
        or model:FindFirstChildWhichIsA("BasePart")
end
-- ================================
-- متغيرات الألوان لـ Nextbot (بنفسجي)
-- ================================
local nextbotESPColor = Color3.fromHex("#cc44ff")        -- بنفسجي ناري ساطع
local nextbotHighlightColor = Color3.fromHex("#8800cc")  -- بنفسجي غامق
-- ================================
-- متغيرات Nextbot ESP
-- ================================
local nextbotESPEnabled = false
local nextbotHighlightEnabled = false
local nextbotBillboards = {}
local nextbotHighlights = {}
local nextbotConnection = nil
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- قائمة أسماء الـ Nextbots من ReplicatedStorage
local nextBotNames = {}
local npcsFolder = ReplicatedStorage:FindFirstChild("NPCs")
if npcsFolder then
    for _, npc in ipairs(npcsFolder:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end
-- ================================
-- دالة التحقق من Nextbot
-- ================================
local function IsNextbotModel(model)
    if not model or not model.Name then return false end
    
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    
    local nameLower = model.Name:lower()
    return nameLower:find("nextbot") or 
           nameLower:find("scp") or 
           nameLower:find("monster") or
           nameLower:find("creep") or
           nameLower:find("enemy") or
           nameLower:find("zombie") or
           nameLower:find("ghost") or
           nameLower:find("demon")
end
-- ================================
-- دالة للحصول على أفضل جزء للـ ESP
-- ================================
local function GetNextbotTargetPart(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Head")
        or model:FindFirstChild("Torso")
        or model:FindFirstChildWhichIsA("BasePart")
end

-- ================================
-- 1. ESP للـ Nextbots (بنفسجي)
-- ================================
local function CreateNextbotESP(model)
    if not model then return end
    
    local targetPart = GetNextbotTargetPart(model)
    if not targetPart then return end
    
    if nextbotBillboards[model] then
        pcall(function() nextbotBillboards[model]:Destroy() end)
    end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NextbotESP_Hyper"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 140, 0, 45)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1500
    billboard.Parent = targetPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚠️ " .. model.Name
    label.TextColor3 = nextbotESPColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Parent = billboard
    
    nextbotBillboards[model] = billboard
    return billboard
end

local function ClearNextbotESP()
    for model, gui in pairs(nextbotBillboards) do
        pcall(function() if gui then gui:Destroy() end end)
    end
    nextbotBillboards = {}
end

local function UpdateAllNextbotESP()
    if not nextbotESPEnabled then return end
    
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local candidates = {}
    
    -- البحث عن الـ Nextbots في Game/Players
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if gamePlayers then
        for _, model in pairs(gamePlayers:GetChildren()) do
            if model:IsA("Model") and IsNextbotModel(model) then
                candidates[model] = true
            end
        end
    end
    
    -- البحث عن الـ Nextbots في NPCs
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, model in pairs(npcs:GetChildren()) do
            if model:IsA("Model") and IsNextbotModel(model) then
                candidates[model] = true
            end
        end
    end
    
    -- تحديث المسافات وإنشاء الـ ESP الجديد
    for model in pairs(candidates) do
        local targetPart = GetNextbotTargetPart(model)
        if targetPart then
            if not nextbotBillboards[model] then
                CreateNextbotESP(model)
            end
            
            local gui = nextbotBillboards[model]
            if gui then
                local label = gui:FindFirstChildOfClass("TextLabel")
                if label then
                    if gui.Adornee ~= targetPart then
                        gui.Adornee = targetPart
                        gui.Parent = targetPart
                    end
                    
                    local distance = ""
                    if myRoot then
                        local dist = math.floor((targetPart.Position - myRoot.Position).Magnitude)
                        distance = string.format(" [%dm]", dist)
                    end
                    
                    local newText = "⚠️ " .. model.Name .. distance
                    if label.Text ~= newText then
                        label.Text = newText
                    end
                    if label.TextColor3 ~= nextbotESPColor then
                        label.TextColor3 = nextbotESPColor
                    end
                end
            end
        end
    end
    
    -- إزالة الـ ESP للـ Nextbots اللي اختفت
    for model, gui in pairs(nextbotBillboards) do
        if not candidates[model] or not model.Parent then
            pcall(function() if gui then gui:Destroy() end end)
            nextbotBillboards[model] = nil
        end
    end
end

-- ================================
-- 2. هايلايت الـ Nextbots (بنفسجي)
-- ================================
local function UpdateNextbotHighlight(model)
    if not nextbotHighlightEnabled then return end
    if not model or not model.Parent then return end
    
    if nextbotHighlights[model] then
        local highlight = nextbotHighlights[model]
        if highlight and highlight.Parent then
            highlight.FillColor = nextbotHighlightColor
            highlight.OutlineColor = nextbotHighlightColor
            return
        else
            nextbotHighlights[model] = nil
        end
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NextbotHighlight_Hyper"
    highlight.Parent = model
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = nextbotHighlightColor
    highlight.OutlineColor = nextbotHighlightColor
    
    nextbotHighlights[model] = highlight
end

local function ClearAllNextbotHighlights()
    for model, highlight in pairs(nextbotHighlights) do
        pcall(function() if highlight then highlight:Destroy() end end)
    end
    nextbotHighlights = {}
end

local function UpdateAllNextbotHighlights()
    if not nextbotHighlightEnabled then return end
    
    local currentBots = {}
    
    local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if gamePlayers then
        for _, model in pairs(gamePlayers:GetChildren()) do
            if model:IsA("Model") and IsNextbotModel(model) then
                currentBots[model] = true
                UpdateNextbotHighlight(model)
            end
        end
    end
    
    local npcs = workspace:FindFirstChild("NPCs")
    if npcs then
        for _, model in pairs(npcs:GetChildren()) do
            if model:IsA("Model") and IsNextbotModel(model) then
                currentBots[model] = true
                UpdateNextbotHighlight(model)
            end
        end
    end
    
    for model in pairs(nextbotHighlights) do
        if not currentBots[model] or not model.Parent then
            pcall(function() if nextbotHighlights[model] then nextbotHighlights[model]:Destroy() end end)
            nextbotHighlights[model] = nil
        end
    end
end

-- ================================
-- الحلقة الرئيسية
-- ================================
local function StartNextbotLoop()
    if nextbotConnection then return end
    
    nextbotConnection = RunService.Heartbeat:Connect(function()
        if nextbotESPEnabled then
            UpdateAllNextbotESP()
        end
        if nextbotHighlightEnabled then
            UpdateAllNextbotHighlights()
        end
    end)
end

local function StopNextbotLoop()
    if nextbotConnection then
        nextbotConnection:Disconnect()
        nextbotConnection = nil
    end
    ClearNextbotESP()
    ClearAllNextbotHighlights()
end

-- ================================
-- عناصر التحكم (بنفسجي)
-- ================================

-- Toggle Nextbot ESP
NextbotSection:Toggle({
    Title = "Nextbot ESP",
    Desc = "Display Nextbot names with distance (Purple Theme)",
    Value = false,
    Callback = function(state)
        nextbotESPEnabled = state
        if nextbotESPEnabled or nextbotHighlightEnabled then
            StartNextbotLoop()
        else
            StopNextbotLoop()
        end
        WindUI:Notify({ Title = "Nextbot ESP", Content = state and "Enabled ✅" or "Disabled ❌", Duration = 2 })
    end,
})

-- Toggle Nextbot Highlight
NextbotSection:Toggle({
    Title = "Nextbot Highlight",
    Desc = "Highlight Nextbots with Purple color",
    Value = false,
    Callback = function(state)
        nextbotHighlightEnabled = state
        if nextbotESPEnabled or nextbotHighlightEnabled then
            StartNextbotLoop()
        else
            StopNextbotLoop()
        end
        WindUI:Notify({ Title = "Nextbot Highlight", Content = state and "Enabled ✅" or "Disabled ❌", Duration = 2 })
    end,
})

-- لون ESP للـ Nextbots (بنفسجي)
NextbotSection:Dropdown({
    Title = "Nextbot ESP Color",
    Values = { "Purple Neon", "Purple", "Red", "Green", "Blue", "Yellow", "Cyan", "White" },
    Default = "Purple Neon",
    Callback = function(value)
        local colors = {
            ["Purple Neon"] = Color3.fromHex("#cc44ff"),
            ["Purple"] = Color3.fromRGB(128, 0, 255),
            Red = Color3.fromRGB(255, 0, 0),
            Green = Color3.fromRGB(0, 255, 0),
            Blue = Color3.fromRGB(0, 0, 255),
            Yellow = Color3.fromRGB(255, 255, 0),
            Cyan = Color3.fromRGB(0, 255, 255),
            White = Color3.fromRGB(255, 255, 255),
        }
        nextbotESPColor = colors[value] or Color3.fromHex("#cc44ff")
        if nextbotESPEnabled then
            for model, gui in pairs(nextbotBillboards) do
                local label = gui and gui:FindFirstChildOfClass("TextLabel")
                if label then
                    label.TextColor3 = nextbotESPColor
                end
            end
        end
    end,
})

-- لون Highlight للـ Nextbots (بنفسجي)
NextbotSection:Dropdown({
    Title = "Nextbot Highlight Color",
    Values = { "Purple Dark", "Purple", "Red", "Green", "Blue", "Yellow", "Cyan", "White" },
    Default = "Purple Dark",
    Callback = function(value)
        local colors = {
            ["Purple Dark"] = Color3.fromHex("#8800cc"),
            ["Purple"] = Color3.fromRGB(128, 0, 255),
            Red = Color3.fromRGB(255, 0, 0),
            Green = Color3.fromRGB(0, 255, 0),
            Blue = Color3.fromRGB(0, 0, 255),
            Yellow = Color3.fromRGB(255, 255, 0),
            Cyan = Color3.fromRGB(0, 255, 255),
            White = Color3.fromRGB(255, 255, 255),
        }
        nextbotHighlightColor = colors[value] or Color3.fromHex("#8800cc")
        if nextbotHighlightEnabled then
            for model, highlight in pairs(nextbotHighlights) do
                if highlight then
                    highlight.FillColor = nextbotHighlightColor
                    highlight.OutlineColor = nextbotHighlightColor
                end
            end
        end
    end,
})
-- ================================
-- تنظيف عند إعادة الظهور
-- ================================
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if nextbotESPEnabled or nextbotHighlightEnabled then
        StopNextbotLoop()
        StartNextbotLoop()
    end
end)

print("[ESP] Nextbot features loaded!")     

-- ================================
-- Performance & Visuals (في تبويب ESP)
-- ================================

local PerfVisualSection = ESPTab:Section({
    Title = "Performance & Visuals",
    Side = "Left",
    Collapsed = true,
})

-- ================================
-- متغيرات الحالة
-- ================================
local noFogEnabled = false
local originalFogEnd = nil
local fullBrightEnabled = false
local originalBrightness = nil
local originalAmbient = nil

-- ================================
-- 1. Anti Lag Buttons
-- ================================

-- Anti Lag 1 (أساسي)
PerfVisualSection:Button({
    Title = "Anti Lag 1 - Basic Clean",
    Desc = "Removes heavy shadows and effects",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000
        Lighting.Brightness = 1
        
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end
        
        WindUI:Notify({ Title = "Anti Lag", Content = "Performance improved (Level 1)", Duration = 2 })
    end,
})

-- Anti Lag 2 (متوسط)
PerfVisualSection:Button({
    Title = "Anti Lag 2 - Medium Clean",
    Desc = "It removes visual effects and particles.",
    Callback = function()
        for _, v in next, game:GetDescendants() do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
            end
            if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then
                v.Enabled = false
            end
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Texture = ""
            end
            if v:IsA("Sky") then
                v.Parent = nil
            end
        end
        
        WindUI:Notify({ Title = "Anti Lag", Content = "Performance improved (Level 2)", Duration = 2 })
    end,
})

-- Anti Lag 3 (إزالة التكستشرز)
PerfVisualSection:Button({
    Title = "Anti Lag 3 - Remove Textures",
    Desc = "Removes all textures from the game",
    Callback = function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
                if part:IsA("Part") then
                    part.Material = Enum.Material.SmoothPlastic
                end
                for _, texture in ipairs(part:GetChildren()) do
                    if texture:IsA("Texture") or texture:IsA("Decal") then
                        texture.Texture = "rbxassetid://0"
                    end
                end
            end
        end
        
        WindUI:Notify({ Title = "Anti Lag", Content = "Textures removed", Duration = 2 })
    end,
})

-- ================================
-- 2. No Fog (إزالة الضباب)
-- ================================
PerfVisualSection:Toggle({
    Title = "No Fog",
    Desc = "Removes fog from the game",
    Icon = "cloud",
    Value = false,
    Type = "Toggle",
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            originalFogEnd = Lighting.FogEnd
            Lighting.FogEnd = 1000000
            WindUI:Notify({ Title = "No Fog", Content = "Fog removed", Duration = 2 })
        else
            Lighting.FogEnd = originalFogEnd or 100000
            WindUI:Notify({ Title = "No Fog", Content = "Fog restored", Duration = 2 })
        end
        noFogEnabled = state
    end,
})

-- ================================
-- 3. Full Bright (إضاءة كاملة)
-- ================================
PerfVisualSection:Toggle({
    Title = "Full Bright",
    Desc = "The entire game lights up",
    Icon = "sun",
    Value = false,
    Type = "Toggle",
    Callback = function(state)
        local Lighting = game:GetService("Lighting")
        if state then
            originalBrightness = Lighting.Brightness
            originalAmbient = Lighting.Ambient
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            WindUI:Notify({ Title = "Full Bright", Content = "Full bright enabled", Duration = 2 })
        else
            Lighting.Brightness = originalBrightness or 0.5
            Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            WindUI:Notify({ Title = "Full Bright", Content = "Full bright disabled", Duration = 2 })
        end
        fullBrightEnabled = state
    end,
})

-- ================================
-- 4. Reset All Settings
-- ================================
PerfVisualSection:Button({
    Title = "Reset All Performance Settings",
    Desc = "All performance settings are restored to normal.",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        
        Lighting.GlobalShadows = true
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.FogEnd = 100000
        
        if noFogEnabled then
            noFogEnabled = false
        end
        
        if fullBrightEnabled then
            fullBrightEnabled = false
        end
        
        WindUI:Notify({ Title = "Reset", Content = "All settings reset to default", Duration = 3 })
    end,
})
-- ================================
-- Barriers Section (في تبويب ESP)
-- ================================

local BarriersSection = ESPTab:Section({
    Title = "Barriers",
    Side = "Left",
    Collapsed = true,
})

-- متغيرات الحواجز
local barriersRemoved = false
local barriersVisible = false

-- وظيفة البحث عن InvisParts
local function GetInvisParts()
    local gameFolder = workspace:FindFirstChild("Game")
    if not gameFolder then return nil end
    
    local mapFolder = gameFolder:FindFirstChild("Map")
    if not mapFolder then return nil end
    
    return mapFolder:FindFirstChild("InvisParts")
end

-- وظيفة Remove Barriers (تعطيل التصادم)
local function ToggleBarriers(state)
    local invisParts = GetInvisParts()
    if not invisParts then
        WindUI:Notify({ Title = "Barriers", Content = "InvisParts not found", Duration = 2 })
        return false
    end
    
    local changed = 0
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = not state
            obj.CanQuery = not state
            changed = changed + 1
        end
    end
    
    WindUI:Notify({ Title = "Barriers", Content = string.format("%s collision occurred for %d part", state and "Disable" or "activation", changed), Duration = 2 })
    return true
end

-- وظيفة Barriers Visible (إظهار الحواجز الشفافة)
local function ToggleBarriersVisible(state)
    local invisParts = GetInvisParts()
    if not invisParts then
        WindUI:Notify({ Title = "Barriers", Content = "InvisParts not found", Duration = 2 })
        return false
    end
    
    local changed = 0
    local transparency = state and 0 or 1
    
    for _, obj in ipairs(invisParts:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Decal") then
            obj.Transparency = transparency
            changed = changed + 1
        end
    end
    
    -- ✅ التصحيح هنا
    WindUI:Notify({ Title = "Barriers", Content = string.format("Visibility %s for %d objects", state and "enabled" or "disabled", changed), Duration = 2 })
    return true
end
-- زر Remove Barriers
BarriersSection:Toggle({
    Title = "Remove Barriers",
    Desc = "Disable barriers (pass through them)",
    Icon = "shield-off",
    Value = false,
    Type = "Toggle",
    Callback = function(state)
        barriersRemoved = state
        ToggleBarriers(state)
    end,
})

-- زر Barriers Visible
BarriersSection:Toggle({
    Title = "Barriers Visible",
    Desc = "Show transparent barriers (make them visible)",
    Icon = "eye",
    Value = false,
    Type = "Toggle",
    Callback = function(state)
        barriersVisible = state
        ToggleBarriersVisible(state)
        
        -- مراقبة إضافة أجزاء جديدة
        if state then
            local invisParts = GetInvisParts()
            if invisParts then
                invisParts.DescendantAdded:Connect(function(obj)
                    if barriersVisible then
                        task.wait(0.05)
                        if obj:IsA("BasePart") or obj:IsA("Decal") then
                            obj.Transparency = 0
                        end
                    end
                end)
            end
        end
    end,
})
