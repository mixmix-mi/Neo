local Tabs = {}

Tabs.Main = Window:Tab({
    Title = "Main",
    Icon = "flame",
    Locked = false,
})


local MainTab = Tabs.Main:Section({ Title = "Player", Side = "Left" })


local Section = MainTab:Section({ 
    Title = "Player modifications",
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

local speed = MainTab:Input({
    Title = " Speed",

    Placeholder = " 1500",
    Value = "1500",
    Callback = createValidatedInput({
        field = "Speed",
        min = 1450,
        max = 100000000
    })
})

local jumpc = MainTab:Input({
    Title = "Jump Cap",

    Placeholder = " 1",
    Value = "1",
    Callback = createValidatedInput({
        field = "JumpCap",
        min = 0.1,
        max = 5000000
    })
})

local strafes = MainTab:Input({
    Title = "Strafe speed",
 
    Placeholder = "187",
    Value = "187",
    Callback = createValidatedInput({
        field = "AirStrafeAcceleration",
        min = 1,
        max = 1000000000
    })
})

MainTab:Dropdown({
    Title = "Select Apply Method",
    Values = {"Unoptimized", "Optimized" },
    Multi = false,
    Default = "Unoptimized",
    Callback = function(value)
        getgenv().ApplyMode = value
    end,
})

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

-- RESET
MainTab:Button({
    Title = "Reset Emote Speed",
    Description = "Restore default emote speed",
    Callback = function()
        restoreOriginal()
    end
})

local Section = MainTab:Section({ 
    Title = "Moviment modifications",
})
-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- =======================
-- AutoTrimp
-- =======================
getgenv().AutoTrimpEnabled = false
getgenv().AutoTrimpSpeed = 50
getgenv().AutoTrimpPosition = getgenv().AutoTrimpPosition or UDim2.new(0.5, -110, 0, 10)

local maxExtraSpeed = 100
local minSpeedOffset = 0
local lastTick = tick()
local airAccumulator = 0
local airTotalTime = 0
local wasAir = false
local activeBV = nil
local currentSpeed = getgenv().AutoTrimpSpeed
local countingEnabled = false
local speedometer = nil

local function truncate1Decimal(val)
    return math.floor(val * 10) / 10
end

local function getSpeedometer()
    local ok, spd = pcall(function()
        return Player.PlayerGui.Shared.HUD.Overlay.Default.CharacterInfo.Item.Speedometer.Players
    end)
    if ok then return spd end
    return nil
end

-- Hook para não permitir que o speedometer seja sobrescrito
local oldNewIndex
if not oldNewIndex then
    oldNewIndex = hookmetamethod(game, "__newindex", function(self, idx, val)
        if not checkcaller() and countingEnabled and speedometer and self == speedometer and idx == "Text" then
            return
        end
        return oldNewIndex(self, idx, val)
    end)
end

RunService.RenderStepped:Connect(function()
    local deltaTime = tick() - lastTick
    lastTick = tick()

    local char = Player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if root and humanoid then
            speedometer = getSpeedometer()
            local isAir = humanoid.FloorMaterial == Enum.Material.Air

            -- Ao tocar o chão
            if wasAir and not isAir then
                currentSpeed = math.max(getgenv().AutoTrimpSpeed - minSpeedOffset, currentSpeed - 10)
                if speedometer then speedometer.Text = tostring(truncate1Decimal(currentSpeed)) end
                airTotalTime = 0
            end
            wasAir = isAir

            if getgenv().AutoTrimpEnabled then
                if isAir then
                    airAccumulator = airAccumulator + deltaTime
                    airTotalTime = airTotalTime + deltaTime
                    while airAccumulator >= 0.04 do
                        airAccumulator = airAccumulator - 0.04
                        local increment = math.max(0.1, 2.5 * (0.04 / 1))
                        currentSpeed = math.min(getgenv().AutoTrimpSpeed + maxExtraSpeed, currentSpeed + increment)
                    end
                else
                    airAccumulator = 0
                    currentSpeed = math.max(getgenv().AutoTrimpSpeed - minSpeedOffset, currentSpeed - 2.5 * deltaTime)
                    airTotalTime = 0
                end

                -- Remove BV antigo
                if activeBV then activeBV:Destroy() end

                -- Cria BV horizontal ignorando Y
                local lookDir = camera.CFrame.LookVector
                lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
                if lookDir.Magnitude ~= 0 then
                    lookDir = lookDir.Unit
                end

                local bv = Instance.new("BodyVelocity")
                bv.Velocity = lookDir * currentSpeed
                bv.MaxForce = Vector3.new(4e5, 0, 4e5)
                bv.P = 1250
                bv.Parent = root
                Debris:AddItem(bv, 0.1)
                activeBV = bv

                countingEnabled = true
                if speedometer then speedometer.Text = tostring(truncate1Decimal(currentSpeed)) end
            else
                if activeBV then activeBV:Destroy() end
                activeBV = nil
                currentSpeed = getgenv().AutoTrimpSpeed
                countingEnabled = false
                airAccumulator = 0
                airTotalTime = 0
                wasAir = false
            
            end
        end
    end
end)

local function createAutoTrimpGUI()
    -- Remove antiga
    if PlayerGui:FindFirstChild("AutoTrimpGUI") then
        PlayerGui.AutoTrimpGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoTrimpGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0,220,0,44)
    Container.Position = getgenv().AutoTrimpPosition
    Container.AnchorPoint = Vector2.new(0.5,0)
    Container.BackgroundTransparency = 1
    Container.Parent = screenGui

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,1,0)
    Button.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Button.BackgroundTransparency = 0.25
    Button.Text = "AutoTrimp [OFF]"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 20
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.AutoButtonColor = false
    Button.Parent = Container

    local UICorner = Instance.new("UICorner", Button)
    UICorner.CornerRadius = UDim.new(1,0)
    local UIStroke = Instance.new("UIStroke", Button)
    UIStroke.Thickness = 2
    local UIGradient = Instance.new("UIGradient", UIStroke)
    UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("40c9ff")), ColorSequenceKeypoint.new(1, Color3.fromHex("e81cff"))})
    UIGradient.Rotation = 45

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
    end)

    Button.MouseButton1Click:Connect(function()
        getgenv().AutoTrimpEnabled = not getgenv().AutoTrimpEnabled
        Button.Text = "AutoTrimp ["..(getgenv().AutoTrimpEnabled and "ON" or "OFF").."]"
    end)

    -- Drag
    local dragging, dragInput, dragStart, startPos = false, nil, Vector2.new(), Container.Position
    local function update(input)
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = Container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    getgenv().AutoTrimpPosition = Container.Position
                end
            end)
        end
    end)

    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    screenGui.Enabled = false
    return screenGui
end

local autoTrimpGUI = createAutoTrimpGUI()
getgenv().LagSwitchTime = 0.5
local function createLagSwitchGUI()
    -- Remove antiga
    if PlayerGui:FindFirstChild("LagSwitchGUI") then
        PlayerGui.LagSwitchGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LagSwitchGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 220, 0, 44)
    container.Position = UDim2.new(0.5, -110, 0, 100)
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = 0.25
    button.Text = "LagSwitch"
    button.Font = Enum.Font.Gotham
    button.TextSize = 20
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.AutoButtonColor = false
    button.Parent = container

    local UICorner = Instance.new("UICorner", button)
    UICorner.CornerRadius = UDim.new(1,0)
    local UIStroke = Instance.new("UIStroke", button)
    UIStroke.Thickness = 2
    local UIGradient = Instance.new("UIGradient", UIStroke)
    UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHex("40c9ff")), ColorSequenceKeypoint.new(1, Color3.fromHex("e81cff"))})
    UIGradient.Rotation = 45

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        -- Executa lag switch
        local duration = getgenv().LagSwitchTime or 0.5
        local start = tick()
        while tick() - start < duration do
            for i = 1, 1e5 do local _ = i*i end
        end
    end)

    -- Drag
    local dragging, dragInput, dragStart, startPos = false, nil, Vector2.new(), container.Position
    local function update(input)
        local delta = input.Position - dragStart
        container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    return screenGui
end


-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variáveis globais
getgenv().GravityEnabled = false
getgenv().GravityValue = workspace.Gravity -- pega gravidade atual do jogo
getgenv().GravityPosition = UDim2.new(0.5, -110, 0, 50)
getgenv().GravityButtonConnection = nil

-- Função para criar GUI flutuante estilo AutoTrimp
local function CreateGravityGUI()
    -- Remove GUI antiga
    if PlayerGui:FindFirstChild("GravityGUI") then
        PlayerGui.GravityGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GravityGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 220, 0, 44)
    Container.Position = getgenv().GravityPosition
    Container.AnchorPoint = Vector2.new(0.5,0)
    Container.BackgroundTransparency = 1
    Container.Parent = screenGui

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,1,0)
    Button.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Button.BackgroundTransparency = 0.25
    Button.Text = "Gravity [OFF]"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 20
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.AutoButtonColor = false
    Button.Parent = Container

    local UICorner = Instance.new("UICorner", Button)
    UICorner.CornerRadius = UDim.new(1,0)
    local UIStroke = Instance.new("UIStroke", Button)
    UIStroke.Thickness = 2
    local UIGradient = Instance.new("UIGradient", UIStroke)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("40c9ff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("e81cff"))
    })
    UIGradient.Rotation = 45

    -- Hover Tween
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
    end)

    -- Toggle gravidade (conexão única)
    if getgenv().GravityButtonConnection then
        getgenv().GravityButtonConnection:Disconnect()
    end

    getgenv().GravityButtonConnection = Button.MouseButton1Click:Connect(function()
        getgenv().GravityEnabled = not getgenv().GravityEnabled
        Button.Text = "Gravity ["..(getgenv().GravityEnabled and "ON" or "OFF").."]"

        if getgenv().GravityEnabled then
            workspace.Gravity = getgenv().GravityValue
        else
            workspace.Gravity = getgenv().GravityValue -- mantém o valor original do workspace
            -- força pulo curto para resetar física do personagem
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Jump = true
                end
            end
        end
    end)

    -- Drag
    local dragging, dragInput, dragStart, startPos = false, nil, Vector2.new(), Container.Position
    local function update(input)
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = Container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    getgenv().GravityPosition = Container.Position
                end
            end)
        end
    end)

    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    screenGui.Enabled = false
    return screenGui
end

-- Cria GUI
local GravityGUI = CreateGravityGUI()

-- Toggle no tab principal
MainTab:Toggle({
    Title = "Gravity GUI",
    Value = false,
    Callback = function(state)
        GravityGUI.Enabled = state
        if not state then
            getgenv().GravityEnabled = false
            workspace.Gravity = getgenv().GravityValue
            -- reset curto de pulo
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Jump = true
                end
            end
        end
    end
})

-- Input para definir valor da gravidade
MainTab:Input({
    Title = "Gravity Value",
    Placeholder = tostring(getgenv().GravityValue),
    Value = tostring(getgenv().GravityValue),
    Callback = function(val)
        local n = tonumber(val)
        if n and n > 0 then
            getgenv().GravityValue = n
            if getgenv().GravityEnabled then
                workspace.Gravity = n
            end
        end
    end
})
MainTab:Space()
-- AutoTrimp GUI Toggle
MainTab:Toggle({
    Title = "AutoTrimp",
    Value = false,
    Callback = function(state)
        autoTrimpGUI.Enabled = state
        if not state then
            getgenv().AutoTrimpEnabled = false
            if activeBV then activeBV:Destroy() activeBV = nil end
            airAccumulator = 0
            airTotalTime = 0
            currentSpeed = getgenv().AutoTrimpSpeed
            countingEnabled = false
            if speedometer then pcall(function() speedometer.Text = "0" end) end
        end
    end
})

-- AutoTrimp Speed Input
MainTab:Input({
    Title = "AutoTrimp Speed",
    Value = tostring(getgenv().AutoTrimpSpeed),
    Placeholder = "Digite a velocidade",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            getgenv().AutoTrimpSpeed = num
            currentSpeed = num
        end
    end
})

MainTab:Space()
-- LagSwitch GUI Toggle
local lagSwitchGUI -- só declara, sem criar ainda
MainTab:Toggle({
    Title = "Lag Switch",
    Value = false,
    Callback = function(state)
        if state then
            if not lagSwitchGUI then
                lagSwitchGUI = createLagSwitchGUI()
            end
            lagSwitchGUI.Enabled = true
        else
            if lagSwitchGUI then
                lagSwitchGUI.Enabled = false
            end
        end
    end
})
-- LagSwitch Time Input
MainTab:Input({
    Title = "LagSwitch delay",
    Value = tostring(getgenv().LagSwitchTime),
    Placeholder = "0.5",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            getgenv().LagSwitchTime = 0.5
        else
            getgenv().LagSwitchTime = 0.5
        end
    end
})
MainTab:Space()
local infiniteSlideEnabled = false
local slideFrictionValue = -8

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local keys = {
    "Friction","AirStrafeAcceleration","JumpHeight","RunDeaccel",
    "JumpSpeedMultiplier","JumpCap","SprintCap","WalkSpeedMultiplier",
    "BhopEnabled","Speed","AirAcceleration","RunAccel","SprintAcceleration"
}

local cachedTables = nil
local plrModel = nil
local slideConnection = nil

-- Checa se uma tabela tem todas as propriedades necessárias
local function hasAll(tbl)
	if type(tbl) ~= "table" then return false end
	for _, k in ipairs(keys) do
		if rawget(tbl, k) == nil then return false end
	end
	return true
end

-- Pega todas as tabelas que tem essas propriedades
local function getConfigTables()
	local tables = {}
	for _, obj in ipairs(getgc(true)) do
		local success, result = pcall(function()
			if hasAll(obj) then return obj end
		end)
		if success and result then
			table.insert(tables, obj)
		end
	end
	return tables
end

-- Atualiza referência do player model
local function updatePlayerModel()
	local GameFolder = workspace:FindFirstChild("Game")
	local PlayersFolder = GameFolder and GameFolder:FindFirstChild("Players")
	if PlayersFolder then
		plrModel = PlayersFolder:FindFirstChild(LocalPlayer.Name)
	else
		plrModel = nil
	end
end

-- Aplica Friction
local function setFriction(value)
	if not cachedTables then return end
	for _, t in ipairs(cachedTables) do
		pcall(function() t.Friction = value end)
	end
end

-- Lógica do Heartbeat
local function onHeartbeat()
	if not plrModel then
		setFriction(5)
		return
	end

	local success, currentState = pcall(function()
		return plrModel:GetAttribute("State")
	end)

	if success and currentState then
		if currentState == "Slide" then
			pcall(function()
				plrModel:SetAttribute("State", "EmotingSlide")
			end)
		elseif currentState == "EmotingSlide" then
			setFriction(slideFrictionValue)
		else
			setFriction(5)
		end
	else
		setFriction(5)
	end
end

-- Reaplica tabelas e model
local function applyInfiniteSlide()
	cachedTables = getConfigTables()
	updatePlayerModel()
end

-- Reinicia o Infinite Slide: desliga e liga com delay
local function restartInfiniteSlide()
	if infiniteSlideEnabled then
		infiniteSlideEnabled = false
		setFriction(5)
		task.wait(0.3)
		infiniteSlideEnabled = true
		applyInfiniteSlide()
	end
end

-- Toggle Infinite Slide
MainTab:Toggle({
	Title = "Infinite Slide",
	Value = false,
	Callback = function(state)
		infiniteSlideEnabled = state

		if slideConnection then
			slideConnection:Disconnect()
			slideConnection = nil
		end

		if state then
			applyInfiniteSlide()
			slideConnection = RunService.Heartbeat:Connect(onHeartbeat)
		else
			cachedTables = nil
			plrModel = nil
			setFriction(5)
		end
	end,
})

MainTab:Space()

-- Detecta CharacterAdded e reinicia se necessário
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.1)
	restartInfiniteSlide()
end)

-- Detecta Remote ChangePlayerMode
local EventsFolder = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player")
local ChangePlayerMode = EventsFolder:WaitForChild("ChangePlayerMode")
if ChangePlayerMode and ChangePlayerMode:IsA("RemoteEvent") then
	ChangePlayerMode.OnClientEvent:Connect(function()
		task.wait(0.1)
		restartInfiniteSlide()
	end)
end


-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer    

-- Estados das features
local featureStates = { AutoSelfRevive = false, SelfReviveMethod = "Spawnpoint" }    

local lastSavedPosition = nil
local AutoSelfReviveConnection = nil
local respawnConnection = nil
local hasRevived = false    

-- Função de revive
local function doRevive(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local isDowned = char:GetAttribute("Downed")
    if not isDowned then return end

    if featureStates.SelfReviveMethod == "Spawnpoint" then
        if not hasRevived then
            hasRevived = true
            pcall(function()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end)
            task.delay(10, function() hasRevived = false end)
        end
    elseif featureStates.SelfReviveMethod == "Revive" then
        if hrp then lastSavedPosition = hrp.Position end
        task.spawn(function()
            task.wait(3)
            local startTime = tick()
            repeat
                pcall(function()
                    ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                end)
                task.wait(1)
            until not char:GetAttribute("Downed") or (tick() - startTime > 1)

            local newChar
            repeat
                newChar = player.Character
                task.wait()
            until newChar and newChar:FindFirstChild("HumanoidRootPart")

            local newHRP = newChar:FindFirstChild("HumanoidRootPart")
            if lastSavedPosition and newHRP then
                newHRP.CFrame = CFrame.new(lastSavedPosition)
                task.wait(0.5)
                if (newHRP.Position - lastSavedPosition).Magnitude > 1 then
                    lastSavedPosition = nil
                end
            end
        end)
    end    
end    

-- Setup AutoRevive
local function setupAutoRevive(char)
    if AutoSelfReviveConnection then AutoSelfReviveConnection:Disconnect() end
    AutoSelfReviveConnection = char:GetAttributeChangedSignal("Downed"):Connect(function()
        if char:GetAttribute("Downed") then doRevive(char) end
    end)
end    

-- Monitor respawn
if respawnConnection then respawnConnection:Disconnect() end
respawnConnection = player.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if featureStates.AutoSelfRevive then setupAutoRevive(newChar) end
end)    


MainTab:Space()

local Section = MainTab:Section({ 
    Title = "Yourself",
})

MainTab:Space()
-- Dropdown SelfReviveMethod
MainTab:Dropdown({
    Title = "Respawn Method",
    Values = {"Spawnpoint", "Revive"},
    Value = "Spawnpoint",
    Callback = function(value)
        featureStates.SelfReviveMethod = value
    end
})    

-- Botão Manual Revive
MainTab:Button({
    Title = "Respawn",
    Callback = function()
        doRevive(player.Character)
    end
})    

-- Inicializa AutoSelfRevive caso já esteja ativo
if player.Character and featureStates.AutoSelfRevive then
    setupAutoRevive(player.Character)
end
-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local INTERACT_REMOTE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

-- Variáveis globais
getgenv().AutoCarryEnabled = false
getgenv().AutoReviveEnabled = false
getgenv().AutoCarryDelay = 1
getgenv().AutoReviveDelay = 1
getgenv().AutoCarryPosition = UDim2.new(0.5, -110, 0, 50)
getgenv().AutoRevivePosition = UDim2.new(0.5, -110, 0, 120)

local lastCarryTime = 0
local lastReviveTime = 0

-- Função genérica para criar GUI flutuante estilo AutoTrimp
local function CreateFloatingButton(name, enabledFlag, savedPosFlag, defaultPosY)
    if PlayerGui:FindFirstChild(name.."GUI") then
        PlayerGui[name.."GUI"]:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name.."GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 220, 0, 44)
    Container.Position = getgenv()[savedPosFlag] or UDim2.new(0.5, -110, 0, defaultPosY)
    Container.AnchorPoint = Vector2.new(0.5,0)
    Container.BackgroundTransparency = 1
    Container.Parent = screenGui

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,0,1,0)
    Button.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Button.BackgroundTransparency = 0.25
    Button.Text = name.." [OFF]"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 20
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.AutoButtonColor = false
    Button.Parent = Container

    local UICorner = Instance.new("UICorner", Button)
    UICorner.CornerRadius = UDim.new(1,0)
    local UIStroke = Instance.new("UIStroke", Button)
    UIStroke.Thickness = 2
    local UIGradient = Instance.new("UIGradient", UIStroke)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("40c9ff")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("e81cff"))
    })
    UIGradient.Rotation = 45

    -- Hover Tween
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
    end)

    -- Toggle da função
    Button.MouseButton1Click:Connect(function()
        getgenv()[enabledFlag] = not getgenv()[enabledFlag]
        Button.Text = name.." ["..(getgenv()[enabledFlag] and "ON" or "OFF").."]"
    end)

    -- Drag
    local dragging, dragInput, dragStart, startPos = false, nil, Vector2.new(), Container.Position
    local function update(input)
        local delta = input.Position - dragStart
        Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = Container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    getgenv()[savedPosFlag] = Container.Position
                end
            end)
        end
    end)

    Button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)

    screenGui.Enabled = false
    return screenGui
end

-- Criação das GUIs
local AutoCarryGUI = CreateFloatingButton("AutoCarry", "AutoCarryEnabled", "AutoCarryPosition", 50)
local AutoReviveGUI = CreateFloatingButton("AutoRevive", "AutoReviveEnabled", "AutoRevivePosition", 120)

-- Loop de execução das funções
RunService.RenderStepped:Connect(function()
    if getgenv().AutoCarryEnabled then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local targetHumanoid = player.Character.Humanoid
                    if (myHRP.Position - targetHRP.Position).Magnitude <= 10 and targetHumanoid.Health <= 0 then
                        if tick() - (getgenv().AutoCarryLast or 0) >= getgenv().AutoCarryDelay then
                            INTERACT_REMOTE:FireServer("Carry", nil, player.Name)
                            getgenv().AutoCarryLast = tick()
                        end
                    end
                end
            end
        end
    end

    if getgenv().AutoReviveEnabled then
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local targetHRP = player.Character.HumanoidRootPart
                    local targetHumanoid = player.Character.Humanoid
                    if (myHRP.Position - targetHRP.Position).Magnitude <= 10 and targetHumanoid.Health <= 0 then
                        if tick() - (getgenv().AutoReviveLast or 0) >= getgenv().AutoReviveDelay then
                            INTERACT_REMOTE:FireServer("Revive", true, player.Name)
                            getgenv().AutoReviveLast = tick()
                        end
                    end
                end
            end
        end
    end
end)

MainTab:Space()

local Section = MainTab:Section({ 
    Title = "Interactions",
})
MainTab:Space()
-- Toggle para abrir GUI flutuante
MainTab:Toggle({
    Title = "Auto Carry GUI",
    Value = false,
    Callback = function(state)
        AutoCarryGUI.Enabled = state
        if not state then
            getgenv().AutoCarryEnabled = false
        end
    end
})
-- Inputs de delay na aba WindUI
MainTab:Input({
    Title = "Carry Delay (s)",
    Placeholder = "1",
    Value = tostring(getgenv().AutoCarryDelay),
    Callback = function(val)
        local n = tonumber(val)
        if n and n > 0 then
            getgenv().AutoCarryDelay = n
        end
    end
})
MainTab:Space()

MainTab:Toggle({
    Title = "Auto Revive GUI",
    Value = false,
    Callback = function(state)
        AutoReviveGUI.Enabled = state
        if not state then
            getgenv().AutoReviveEnabled = false
        end
    end
})


MainTab:Input({
    Title = "Revive Delay (s)",
    Placeholder = "1",
    Value = tostring(getgenv().AutoReviveDelay),
    Callback = function(val)
        local n = tonumber(val)
        if n and n > 0 then
            getgenv().AutoReviveDelay = n
        end
    end
})
-- ============================================
-- Auto Jump System v2 - WindUI Version
-- ============================================
pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    
    -- ============================================
    -- المتغيرات الرئيسية
    -- ============================================
    local autoJumpEnabled = false
    local autoJumpType = "Bounce"  -- Bounce / Realistic
    local bhopMode = "Acceleration"  -- Acceleration / No Acceleration
    local bhopAccelValue = -0.5
    local bhopHoldEnabled = false
    local bhopHoldActive = false
    local rotationEnabled = false
    local rotationSpeed = 100000
    local jumpCooldown = 0.25
    local jumpPower = 50
    
    -- متغيرات التشغيل
    local bhopConnection = nil
    local rotationConnection = nil
    local bhopLoaded = false
    local frictionTables = {}
    
    -- مراجع الشخصية
    local Character = nil
    local Humanoid = nil
    local HumanoidRootPart = nil
    local LastJump = 0
    
    -- اتصالات الموبايل
    local mobileJumpConnections = { down = nil, up = nil }
    local floatingButtonGui = nil
    
    -- ============================================
    -- الدوال الأساسية
    -- ============================================
    
    -- تحديث مراجع الشخصية
    local function UpdateCharacterReferences()
        pcall(function()
            if LP and LP.Character then
                Character = LP.Character
                Humanoid = Character:FindFirstChildOfClass("Humanoid")
                HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
            end
        end)
    end
    
    -- فحص是否存在 على الأرض
    local function IsOnGround()
        if not (Character and Humanoid and HumanoidRootPart) then return false end
        
        local success, result = pcall(function()
            local state = Humanoid:GetState()
            if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
                return false
            end
            
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {Character}
            return workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -4, 0), rayParams) ~= nil
        end)
        
        return success and result or false
    end
    
    -- البحث عن جداول الاحتكاك
    local function FindFrictionTables()
        pcall(function()
            frictionTables = {}
            local success, gc = pcall(function() return getgc(true) end)
            if not success then return end
            
            for _, obj in pairs(gc) do
                if type(obj) == "table" and rawget(obj, "Friction") then
                    table.insert(frictionTables, { obj = obj, original = obj.Friction })
                end
            end
        end)
    end
    
    -- تطبيق الاحتكاك
    local function ApplyBhopFriction()
        pcall(function()
            local isActive = autoJumpEnabled or (bhopHoldEnabled and bhopHoldActive)
            
            if isActive and bhopMode == "Acceleration" then
                if #frictionTables == 0 then FindFrictionTables() end
                for _, t in ipairs(frictionTables) do
                    if t.obj then
                        pcall(function() t.obj.Friction = bhopAccelValue end)
                    end
                end
            else
                for _, t in ipairs(frictionTables) do
                    if t.obj and t.original then
                        pcall(function() t.obj.Friction = t.original end)
                    end
                end
            end
        end)
    end
    
    -- تحديث القفز
    local function UpdateBhop()
        if not bhopLoaded then return end
        
        local isActive = autoJumpEnabled or (bhopHoldEnabled and bhopHoldActive)
        if not isActive then return end
        
        if not Character or not Character.Parent then UpdateCharacterReferences() end
        if not (Humanoid and HumanoidRootPart) then return end
        
        local now = tick()
        
        if autoJumpType == "Realistic" then
            -- Realistic Mode (استخدام أحداث اللعبة)
            pcall(function()
                local ps = LP:FindFirstChild("PlayerScripts")
                if ps then
                    local ev = ps:FindFirstChild("Events")
                    if ev then
                        local temp = ev:FindFirstChild("temporary_events")
                        if temp then
                            if temp:FindFirstChild("JumpReact") then temp.JumpReact:Fire() end
                            if temp:FindFirstChild("EndJump") then temp.EndJump:Fire() end
                        end
                    end
                end
            end)
        else
            -- Bounce Mode
            if IsOnGround() and (now - LastJump) > jumpCooldown then
                pcall(function()
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    Humanoid.JumpPower = jumpPower
                end)
                LastJump = now
            end
        end
    end
    
    -- تشغيل/إيقاف Bhop
    local function StartBhop()
        if bhopConnection then return end
        bhopLoaded = true
        FindFrictionTables()
        ApplyBhopFriction()
        bhopConnection = RunService.Heartbeat:Connect(UpdateBhop)
    end
    
    local function StopBhop()
        if bhopConnection then
            bhopConnection:Disconnect()
            bhopConnection = nil
        end
        bhopLoaded = false
        bhopHoldActive = false
        ApplyBhopFriction()
    end
    
    -- Rotation 360
    local function StartRotation()
        if rotationConnection then rotationConnection:Disconnect() end
        rotationConnection = RunService.Heartbeat:Connect(function(dt)
            if not rotationEnabled or not autoJumpEnabled then return end
            pcall(function()
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local rot = hrp.Orientation
                    hrp.Orientation = Vector3.new(rot.X, rot.Y + (rotationSpeed * dt), rot.Z)
                end
            end)
        end)
    end
    
    local function StopRotation()
        if rotationConnection then
            rotationConnection:Disconnect()
            rotationConnection = nil
        end
    end
    
    local function UpdateRotationState()
        if rotationEnabled and autoJumpEnabled then
            StartRotation()
        else
            StopRotation()
        end
    end
    
    -- تنظيف اتصالات الموبايل
    local function CleanupMobileConnections()
        pcall(function()
            if mobileJumpConnections.down then
                mobileJumpConnections.down:Disconnect()
                mobileJumpConnections.down = nil
            end
            if mobileJumpConnections.up then
                mobileJumpConnections.up:Disconnect()
                mobileJumpConnections.up = nil
            end
        end)
    end
    
    -- إعدادات زر النط في الموبايل
    local function SetupMobileJumpButton()
        pcall(function()
            if not LP then return end
            
            CleanupMobileConnections()
            
            local playerGui = LP:FindFirstChild("PlayerGui")
            if not playerGui then return end
            
            local touchGui = playerGui:FindFirstChild("TouchGui")
            if not touchGui then return end
            
            local touchControlFrame = touchGui:FindFirstChild("TouchControlFrame")
            if not touchControlFrame then return end
            
            local jumpButton = touchControlFrame:FindFirstChild("JumpButton")
            if not jumpButton then return end
            
            mobileJumpConnections.down = jumpButton.MouseButton1Down:Connect(function()
                if bhopHoldEnabled then
                    bhopHoldActive = true
                    if not autoJumpEnabled then StartBhop() end
                end
            end)
            
            mobileJumpConnections.up = jumpButton.MouseButton1Up:Connect(function()
                if bhopHoldEnabled then
                    bhopHoldActive = false
                    if not autoJumpEnabled then StopBhop() end
                end
            end)
        end)
    end
    
-- ============================================
-- Floating Button (نسخة سوداء)
-- ============================================
local function CreateBhopFloatingButton()
    local CoreGui = game:GetService("CoreGui")
    
    local oldGui = CoreGui:FindFirstChild("BhopFloatingButton")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BhopFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 55)
    local startX = (workspace.CurrentCamera.ViewportSize.X / 2) - 80
    local startY = (workspace.CurrentCamera.ViewportSize.Y / 2) - 27
    button.Position = UDim2.new(0, startX, 0, startY)
    button.Text = "BHOP: OFF"
    
    -- 🖤 ألوان سوداء
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)      -- خلفية رمادية داكنة
    button.TextColor3 = Color3.fromRGB(255, 255, 255)         -- نص أبيض
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 60)                 -- إطار رمادي
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- نظام السحب
    local dragging = false
    local dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            stroke.Color = Color3.fromRGB(150, 150, 150)       -- إطار أفتح عند السحب
            button.Text = "DRAG..."
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            stroke.Color = autoJumpEnabled and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 60)
            button.Text = autoJumpEnabled and "BHOP: ON" or "BHOP: OFF"
        end
    end)
    
    -- الضغط على الزر
    local function handleTap()
        if not dragging then
            button.Text = "BHOP: ACTIVE"
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)      -- أفتح قليلاً عند التفعيل
            stroke.Color = Color3.fromRGB(150, 150, 150)
            
            autoJumpEnabled = not autoJumpEnabled
            
            if autoJumpEnabled then
                StartBhop()
                SetupMobileJumpButton()
                UpdateRotationState()
            else
                StopBhop()
                StopRotation()
                bhopHoldActive = false
            end
            
            button.Text = autoJumpEnabled and "BHOP: ON" or "BHOP: OFF"
            button.BackgroundColor3 = autoJumpEnabled and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30)
            stroke.Color = autoJumpEnabled and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(60, 60, 60)
            
            -- تحديث Toggle في الواجهة
            pcall(function()
                if BunnyHopToggle then BunnyHopToggle:SetValue(autoJumpEnabled) end
            end)
        end
    end
    
    button.MouseButton1Click:Connect(handleTap)
    button.TouchTap:Connect(handleTap)
    
    return screenGui
end

-- تحديث نص الزر العائم
local function UpdateFloatingButtonText()
    pcall(function()
        if floatingButtonGui then
            local btn = floatingButtonGui:FindFirstChildOfClass("TextButton")
            if btn then
                btn.Text = autoJumpEnabled and "BHOP: ON" or "BHOP: OFF"
                btn.BackgroundColor3 = autoJumpEnabled and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(30, 30, 30)
            end
        end
    end)
end
    
    -- ============================================
    -- PC Space Bar (يدعم الضغط المستمر)
    -- ============================================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Space then
            if bhopHoldEnabled then
                bhopHoldActive = true
                if not autoJumpEnabled then StartBhop() end
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            if bhopHoldEnabled then
                bhopHoldActive = false
                if not autoJumpEnabled then StopBhop() end
            end
        end
    end)
    
    -- ============================================
    -- معالج إعادة الظهور
    -- ============================================
    local function OnCharacterAdded(char)
        task.wait(0.6)
        Character = char
        if char then
            pcall(function()
                Humanoid = char:WaitForChild("Humanoid", 3)
                HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 3)
            end)
        end
        if autoJumpEnabled then
            ApplyBhopFriction()
            UpdateRotationState()
        end
    end
    
    LP.CharacterAdded:Connect(OnCharacterAdded)
    if LP.Character then OnCharacterAdded(LP.Character) end
    
    -- ============================================
    -- إنشاء الـ Section في تبويب Misc
    -- ============================================
    local AutoJumpSection = Tabs.Main:Section({
        Title = "Auto Jump",
        Side = "Left",
        Collapsed = false,
    })
    
    -- Auto Jump Type
    AutoJumpSection:Dropdown({
        Title = "Auto Jump Type",
        Values = { "Bounce", "Realistic" },
        Default = "Bounce",
        Callback = function(value)
            autoJumpType = value
        end
    })
    
    -- Rotation 360
    AutoJumpSection:Toggle({
        Title = "Rotation 360",
        Value = false,
        Callback = function(state)
            rotationEnabled = state
            UpdateRotationState()
            WindUI:Notify({ Title = "Rotation", Content = state and "Enabled" or "Disabled", Duration = 2 })
        end
    })
    
    -- Bunny Hop
    local BunnyHopToggle = AutoJumpSection:Toggle({
        Title = "Bunny Hop",
        Value = false,
        Callback = function(state)
            autoJumpEnabled = state
            if state then
                StartBhop()
                SetupMobileJumpButton()
                UpdateRotationState()
                WindUI:Notify({ Title = "Bunny Hop", Content = "Enabled", Duration = 2 })
            else
                StopBhop()
                StopRotation()
                bhopHoldActive = false
                WindUI:Notify({ Title = "Bunny Hop", Content = "Disabled", Duration = 2 })
            end
            UpdateFloatingButtonText()
        end
    })
    
    -- Bhop Hold (مستقل)
    AutoJumpSection:Toggle({
        Title = "Bhop Hold (Hold Space/Jump)",
        Value = false,
        Callback = function(state)
            bhopHoldEnabled = state
            if state then
                SetupMobileJumpButton()
                WindUI:Notify({ Title = "Bhop Hold", Content = "Enabled - Hold jump button", Duration = 2 })
            else
                bhopHoldActive = false
                CleanupMobileConnections()
                if not autoJumpEnabled then
                    StopBhop()
                end
                WindUI:Notify({ Title = "Bhop Hold", Content = "Disabled", Duration = 2 })
            end
            UpdateFloatingButtonText()
        end
    })
    
    -- Jump Power
    AutoJumpSection:Slider({
        Title = "Jump Power",
        Value = { Min = 30, Max = 150, Default = 50 },
        Callback = function(value)
            jumpPower = value
        end
    })
    
    -- Bhop Mode
    AutoJumpSection:Dropdown({
        Title = "Bhop Mode",
        Values = { "Acceleration", "No Acceleration" },
        Default = "Acceleration",
        Callback = function(value)
            bhopMode = value
            if autoJumpEnabled or bhopHoldEnabled then ApplyBhopFriction() end
        end
    })
    
    -- Bhop Acceleration
    AutoJumpSection:Slider({
        Title = "Bhop Acceleration",
        Value = { Min = -10, Max = -0.1, Default = -0.5 },
        Step = 0.1,
        Callback = function(value)
            bhopAccelValue = value
            if (autoJumpEnabled or bhopHoldEnabled) and bhopMode == "Acceleration" then
                ApplyBhopFriction()
            end
        end
    })
    
    -- Jump Cooldown
    AutoJumpSection:Slider({
        Title = "Jump Cooldown (Seconds)",
        Value = { Min = 0.05, Max = 0.5, Default = 0.25 },
        Step = 0.01,
        Callback = function(value)
            jumpCooldown = value
        end
    })
    
    -- Floating Button GUI
    AutoJumpSection:Toggle({
        Title = "Bhop Button GUI",
        Value = false,
        Callback = function(state)
            if state then
                floatingButtonGui = CreateBhopFloatingButton()
            else
                if floatingButtonGui then
                    pcall(function() floatingButtonGui:Destroy() end)
                    floatingButtonGui = nil
                end
            end
        end
    })
    
    print("[Auto Jump] Loaded successfully in Misc tab!")
end)
