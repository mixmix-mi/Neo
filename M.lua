-- ============================================
-- Player Modifications
-- ============================================

-- تعريف الخدمات
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- ============================================
-- إنشاء التبويب الرئيسي
-- ============================================
local Tabs = {
    Misc = Window:Tab({ Title = "Misc", Icon = "solar:box-minimalistic-outline", Locked = false })
}

if not Tabs.Misc then
    Tabs.Misc = Window:Tab({ Title = "Misc", Icon = "shapes", Locked = false })
end

-- ============================================
-- Section Player Modifications داخل تبويب Misc
-- ============================================
local Section = Tabs.Misc:Section({ 
    Title = "Player modifications",
    Side = "Left",
    Collapsed = false,
})

local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true,
}

getgenv().ApplyMode = "Unoptimized"
local appliedOnce = false
local gameStatsPath = workspace.Game.Stats
local playersPath = workspace.Game.Players
local playerModelPresent = false

local currentSettings = {
    Speed = "1500",
    JumpCap = "1",
    AirStrafeAcceleration = "187"
}

local function isPlayerModelPresent()
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    for _, model in pairs(playersPath:GetChildren()) do
        if model.Name == player.Name then
            return true
        end
    end
    return false
end

local function shouldApplySettings()
    if not gameStatsPath then return false end
    
    local roundStarted = gameStatsPath:GetAttribute("RoundStarted")
    local timer = gameStatsPath:GetAttribute("Timer")
    
    return roundStarted == false and timer == 3
end

local function getMatchingTables()
    local matched = {}
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "table" then
            local ok = true
            for field in pairs(requiredFields) do
                if rawget(obj, field) == nil then
                    ok = false
                    break
                end
            end
            if ok then
                table.insert(matched, obj)
            end
        end
    end
    return matched
end

local function applyToTables(callback)
    if not isPlayerModelPresent() then
        return
    end
    
    local targets = getMatchingTables()
    
    if #targets == 0 then
        return
    end
    
    if getgenv().ApplyMode == "Optimized" then
        task.spawn(function()
            for i, tableObj in ipairs(targets) do
                if tableObj and typeof(tableObj) == "table" then
                    pcall(callback, tableObj)
                end
                
                if i % 3 == 0 then
                    task.wait()
                end
            end
        end)
    else
        for i, tableObj in ipairs(targets) do
            if tableObj and typeof(tableObj) == "table" then
                pcall(callback, tableObj)
            end
        end
    end
end

local function applyStoredSettings()
    local settings = {
        {field = "Speed", value = tonumber(currentSettings.Speed)},
        {field = "JumpCap", value = tonumber(currentSettings.JumpCap)},
        {field = "AirStrafeAcceleration", value = tonumber(currentSettings.AirStrafeAcceleration)}
    }
    
    for _, setting in ipairs(settings) do
        if setting.value and tostring(setting.value) ~= "1500" and tostring(setting.value) ~= "1" and tostring(setting.value) ~= "187" then
            applyToTables(function(obj)
                obj[setting.field] = setting.value
            end)
        end
    end
end

local function applySettingsWithDelay()
    if not shouldApplySettings() or appliedOnce then
        return
    end
    
    appliedOnce = true
    
    local settings = {
        {field = "Speed", value = tonumber(currentSettings.Speed), delay = math.random(1, 14)},
        {field = "JumpCap", value = tonumber(currentSettings.JumpCap), delay = math.random(1, 14)},
        {field = "AirStrafeAcceleration", value = tonumber(currentSettings.AirStrafeAcceleration), delay = math.random(1, 14)}
    }
    
    for _, setting in ipairs(settings) do
        if setting.value and tostring(setting.value) ~= "1500" and tostring(setting.value) ~= "1" and tostring(setting.value) ~= "187" then
            task.spawn(function()
                task.wait(setting.delay)
                applyToTables(function(obj)
                    obj[setting.field] = setting.value
                end)
            end)
        end
    end
end

local roundStartedConnection
local timerConnection

local function setupAttributeConnections()
    if roundStartedConnection then
        roundStartedConnection:Disconnect()
    end
    if timerConnection then
        timerConnection:Disconnect()
    end
    
    if gameStatsPath then
        roundStartedConnection = gameStatsPath:GetAttributeChangedSignal("RoundStarted"):Connect(function()
            local roundStarted = gameStatsPath:GetAttribute("RoundStarted")
            if roundStarted == true then
                appliedOnce = false
            end
        end)
        
        timerConnection = gameStatsPath:GetAttributeChangedSignal("Timer"):Connect(function()
            if shouldApplySettings() and not appliedOnce then
                applySettingsWithDelay()
            end
        end)
    end
end

setupAttributeConnections()

task.spawn(function()
    while true do
        task.wait(0.5)
        local currentlyPresent = isPlayerModelPresent()
        
        if currentlyPresent and not playerModelPresent then
            playerModelPresent = true
            applyStoredSettings()
        elseif not currentlyPresent and playerModelPresent then
            playerModelPresent = false
        end
    end
end)

local function createValidatedInput(config)
    return function(input)
        local val = tonumber(input)
        if not val then
            return
        end
        
        if config.min and val < config.min then
            return
        end
        
        if config.max and val > config.max then
            return
        end
        
        currentSettings[config.field] = input
        
        applyToTables(function(obj)
            obj[config.field] = val
        end)
    end
end

local speed = Section:Input({
    Title = "Speed",
    Placeholder = "1500",
    Value = "1500",
    Numeric = true,
    Callback = createValidatedInput({
        field = "Speed",
        min = 1450,
        max = 100000000
    })
})

local jumpc = Section:Input({
    Title = "Jump Cap",
    Placeholder = "1",
    Value = "1",
    Numeric = true,
    Callback = createValidatedInput({
        field = "JumpCap",
        min = 0.1,
        max = 5000000
    })
})

local strafes = Section:Input({
    Title = "Strafe speed",
    Placeholder = "187",
    Value = "187",
    Numeric = true,
    Callback = createValidatedInput({
        field = "AirStrafeAcceleration",
        min = 1,
        max = 1000000000
    })
})

Section:Dropdown({
    Title = "Select Apply Method",
    Values = {"Unoptimized", "Optimized"},
    Multi = false,
    Default = "Unoptimized",
    Callback = function(value)
        getgenv().ApplyMode = value
    end,
})

Section:Space()

local Section = MainTab:Section({ 
    Title = "Emote modifications",
})

-- salva velocidades originais
local originalEmoteSpeeds = {}
local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
if itemsFolder then
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if emotesFolder then
        for _, module in ipairs(emotesFolder:GetChildren()) do
            if module:IsA("ModuleScript") then
                local ok, data = pcall(require, module)
                if ok and data and data.EmoteInfo then
                    originalEmoteSpeeds[module.Name] = data.EmoteInfo.SpeedMult
                end
            end
        end
    end
end

-- define velocidade para todos os emotes
local function applyEmoteSpeed(v)
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, module in ipairs(emotesFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local ok, data = pcall(require, module)
            if ok and data and data.EmoteInfo and data.EmoteInfo.SpeedMult ~= 0 then
                data.EmoteInfo.SpeedMult = v
            end
        end
    end
end

-- restaura velocidades originais
local function restoreOriginal()
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, module in ipairs(emotesFolder:GetChildren()) do
        if module:IsA("ModuleScript") then
            local original = originalEmoteSpeeds[module.Name]
            if original then
                local ok, data = pcall(require, module)
                if ok and data and data.EmoteInfo then
                    data.EmoteInfo.SpeedMult = original
                end
            end
        end
    end
end

-- valor atual usado no modo legit
featureStates = featureStates or {}
featureStates.EmoteSpeedValue = 2

-- INPUT DE VELOCIDADE
local emotespeed = MainTab:Input({
    Title = "Emote Speed Value",
    Description = "Changes the animation speed of your emotes",
    Placeholder = "1500",
    NumbersOnly = true,
    Callback = function(value)
        local num = tonumber(value)
        if not num or num <= 0 then return end

        featureStates.EmoteSpeedValue = num
        local applied = num / 1000
        applyEmoteSpeed(applied)   -- modo sempre legit
    end
})

MainTab:Button({
    Title = "Reset Emote Speed",
    Description = "Restore default emote speed",
    Callback = function()
        restoreOriginal()
    end
})

MainTab:Space()
