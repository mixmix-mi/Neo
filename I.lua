

-- ============================================
-- INFINITE SLIDE MODULE
-- مع حماية Errors
-- ============================================

local function LoadInfiniteSlide()
    -- حماية: لو حصل أي خطأ، يكتب في الكونسول ويخرج
    local success, err = pcall(function()
        print("[Infinite Slide] Loading module...")
        
        -- البحث عن تبويب Misc
        local MiscTab = nil
        if Tabs and Tabs.Misc then
            MiscTab = Tabs.Misc
        elseif Window and Window.Tabs then
            for _, tab in pairs(Window.Tabs) do
                if tab and (tab.Title == "Misc" or tab.Title == "Miscellaneous") then
                    MiscTab = tab
                    break
                end
            end
        end
        
        -- لو مش لاقي تبويب Misc، اخرج
        if not MiscTab then
            print("[Infinite Slide] Error: Misc tab not found, skipping...")
            return
        end
        
        -- إنشاء القسم
        local SlideSection = MiscTab:Section({
            Title = "Infinite Slide",
            Side = "Left",
            Collapsed = true,
        })
        
        if not SlideSection then
            print("[Infinite Slide] Error: Failed to create section, skipping...")
            return
        end
        
        -- متغيرات Infinite Slide
        local infiniteSlideEnabled = false
        local slideFrictionValue = -8
        local movementTables = {}
        local infiniteSlideHeartbeat = nil
        local infiniteSlideCharacterConn = nil
        local slideLastAppliedFriction = nil
        local slideRefreshScheduled = false
        
        -- الكيز المطلوبة للجداول
        local requiredKeys = {
            "Friction", "AirStrafeAcceleration", "JumpHeight", "RunDeaccel",
            "JumpSpeedMultiplier", "JumpCap", "SprintCap", "WalkSpeedMultiplier",
            "BhopEnabled", "Speed", "AirAcceleration", "RunAccel", "SprintAcceleration"
        }
        
        -- التحقق من وجود الحقول
        local function hasRequiredFields(tbl)
            if type(tbl) ~= "table" then return false end
            for _, key in ipairs(requiredKeys) do
                if rawget(tbl, key) == nil then return false end
            end
            return true
        end
        
        -- البحث عن جداول الحركة
        local function findMovementTables()
            movementTables = {}
            for _, obj in pairs(getgc(true)) do
                if hasRequiredFields(obj) then
                    table.insert(movementTables, obj)
                end
            end
            return #movementTables > 0
        end
        
        -- تطبيق الاحتكاك
        local function setSlideFriction(value)
            pcall(function()
                if #movementTables > 0 and slideLastAppliedFriction == value then
                    return
                end
                local appliedCount = 0
                for _, tbl in ipairs(movementTables) do
                    pcall(function()
                        tbl.Friction = value
                        appliedCount = appliedCount + 1
                    end)
                end
                if appliedCount == 0 then
                    slideLastAppliedFriction = nil
                    if slideRefreshScheduled then return end
                    slideRefreshScheduled = true
                    task.defer(function()
                        slideRefreshScheduled = false
                        findMovementTables()
                        slideLastAppliedFriction = nil
                        if infiniteSlideEnabled then
                            setSlideFriction(value)
                        end
                    end)
                    return
                end
                slideLastAppliedFriction = value
            end)
        end
        
        -- الحصول على موديل اللاعب
        local function getPlayerModel()
            local gameFolder = workspace:FindFirstChild("Game")
            if not gameFolder then return nil end
            local playersFolder = gameFolder:FindFirstChild("Players")
            if not playersFolder then return nil end
            return playersFolder:FindFirstChild(LP.Name)
        end
        
        -- Heartbeat للتحكم
        local function infiniteSlideHeartbeatFunc()
            if not infiniteSlideEnabled then return end
            
            local playerModel = getPlayerModel()
            if not playerModel then return end
            
            local state = playerModel:GetAttribute("State")
            
            if state == "Slide" then
                pcall(function()
                    playerModel:SetAttribute("State", "EmotingSlide")
                end)
            elseif state == "EmotingSlide" then
                setSlideFriction(slideFrictionValue)
            else
                setSlideFriction(5)
            end
        end
        
        -- عند إضافة شخصية
        local function onCharacterAdded()
            if not infiniteSlideEnabled then return end
            
            for i = 1, 5 do
                task.wait(0.5)
                if getPlayerModel() then break end
            end
            
            task.wait(0.5)
            movementTables = {}
            slideLastAppliedFriction = nil
            slideRefreshScheduled = false
            task.defer(function()
                if not infiniteSlideEnabled then return end
                findMovementTables()
                slideLastAppliedFriction = nil
            end)
        end
        
        -- تشغيل/إيقاف
        local function setInfiniteSlide(enabled)
            pcall(function()
                infiniteSlideEnabled = enabled
        
                if enabled then
                    movementTables = {}
                    slideLastAppliedFriction = nil
                    slideRefreshScheduled = false
                    task.defer(function()
                        if not infiniteSlideEnabled then return end
                        findMovementTables()
                        slideLastAppliedFriction = nil
                    end)
                    getPlayerModel()
                    
                    if not infiniteSlideCharacterConn then
                        infiniteSlideCharacterConn = LP.CharacterAdded:Connect(onCharacterAdded)
                    end
                    
                    if LP.Character then
                        task.spawn(onCharacterAdded)
                    end
                    
                    if infiniteSlideHeartbeat then infiniteSlideHeartbeat:Disconnect() end
                    infiniteSlideHeartbeat = RunService.Heartbeat:Connect(infiniteSlideHeartbeatFunc)
                    
                    if WindUI and WindUI.Notify then
                        WindUI:Notify({
                            Title = "Infinite Slide",
                            Content = "Enabled | Friction: " .. slideFrictionValue,
                            Duration = 2
                        })
                    end
                else
                    if infiniteSlideHeartbeat then
                        infiniteSlideHeartbeat:Disconnect()
                        infiniteSlideHeartbeat = nil
                    end
                    
                    if infiniteSlideCharacterConn then
                        infiniteSlideCharacterConn:Disconnect()
                        infiniteSlideCharacterConn = nil
                    end
                    
                    local savedTables = movementTables
                    movementTables = {}
                    slideLastAppliedFriction = nil
                    slideRefreshScheduled = false
                    task.defer(function()
                        for _, tbl in ipairs(savedTables) do
                            pcall(function() tbl.Friction = 5 end)
                        end
                    end)
                    
                    if WindUI and WindUI.Notify then
                        WindUI:Notify({
                            Title = "Infinite Slide",
                            Content = "Disabled",
                            Duration = 2
                        })
                    end
                end
            end)
        end
        
        -- تحديث قيمة الاحتكاك
        local function updateSlideFriction(newValue)
            slideFrictionValue = newValue
            if infiniteSlideEnabled then
                setSlideFriction(slideFrictionValue)
            end
        end
        
        -- إعادة تشغيل بعد الموت
        pcall(function()
            LP.CharacterAdded:Connect(function()
                task.wait(1)
                if infiniteSlideEnabled then
                    movementTables = {}
                    slideLastAppliedFriction = nil
                    slideRefreshScheduled = false
                    task.defer(function()
                        findMovementTables()
                        slideLastAppliedFriction = nil
                    end)
                end
            end)
        end)
        
        -- إضافة عناصر الواجهة
        local slideToggle = false
        SlideSection:Toggle({
            Title = "Infinite Slide",
            Value = false,
            Callback = function(state)
                pcall(function()
                    slideToggle = state
                    setInfiniteSlide(state)
                end)
            end
        })
        
        SlideSection:Slider({
            Title = "Slide Friction",
            Desc = "Negative = faster slide | Positive = slower",
            Value = { Min = -20, Max = 20, Default = -8 },
            Step = 0.5,
            Callback = function(value)
                pcall(function()
                    updateSlideFriction(value)
                end)
            end
        })
        
        SlideSection:Button({
            Title = "Reset Settings",
            Desc = "Disable slide and reset friction",
            Callback = function()
                pcall(function()
                    if infiniteSlideEnabled then
                        setInfiniteSlide(false)
                        slideToggle = false
                    end
                    updateSlideFriction(-8)
                    if WindUI and WindUI.Notify then
                        WindUI:Notify({ Title = "Reset", Content = "Slide reset to default", Duration = 2 })
                    end
                end)
            end
        })
        
        print("[Infinite Slide] Module loaded successfully in Misc tab")
    end)
    
    if not success then
        print("[Infinite Slide] Error: " .. tostring(err))
        print("[Infinite Slide] Skipping module...")
    end
end

-- تشغيل الموديول
LoadInfiniteSlide()

-- ============================================
-- AutoTrimp (Air Acceleration) - Hyper v1.0
-- مع زر عائم بدون حدود
-- ============================================
pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local Debris = game:GetService("Debris")
    local CoreGui = game:GetService("CoreGui")
    local LP = Players.LocalPlayer
    local camera = workspace.CurrentCamera
    
    local autoTrimpEnabled = false
    local baseSpeed = 40
    local maxExtraSpeed = 40
    local accelerationRate = 1.2
    local decelerationRate = 8
    local currentSpeed = 40
    local airAccumulator = 0
    local activeBV = nil
    local lastTick = tick()
    local floatingButton = nil
    
   -- ============================================
-- إنشاء الزر العائم (Blood Moon Theme)
-- ============================================
local function CreateFloatingButton()
    local oldGui = CoreGui:FindFirstChild("AutoTrimpFloatingButton")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoTrimpFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 170, 0, 50)
    button.Position = UDim2.new(0.5, -85, 0, 100)
    button.Text = "AUTO TRIMP: OFF"
    
    -- 🩸 Blood Moon Colors
    button.BackgroundColor3 = Color3.fromHex("#1a0000")      -- خلفية حمراء داكنة
    button.TextColor3 = Color3.fromHex("#ffcccc")            -- نص أحمر فاتح
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")                 -- إطار أحمر داكن
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- تأثيرات التمرير (Blood Moon)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        stroke.Color = Color3.fromHex("#ff4444")             -- أحمر ناري عند التمرير
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            TextColor3 = Color3.fromHex("#ffcccc")
        }):Play()
        stroke.Color = autoTrimpEnabled and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
    end)
    
    -- نظام السحب (بدون حدود)
    local dragging = false
    local dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            stroke.Color = Color3.fromHex("#ff4444")
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
            stroke.Color = autoTrimpEnabled and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
            button.Text = autoTrimpEnabled and "AUTO TRIMP: ON" or "AUTO TRIMP: OFF"
        end
    end)
    
    -- الضغط على الزر
    local function handleTap()
        if not dragging then
            autoTrimpEnabled = not autoTrimpEnabled
            
            button.Text = autoTrimpEnabled and "AUTO TRIMP: ON" or "AUTO TRIMP: OFF"
            button.BackgroundColor3 = autoTrimpEnabled and Color3.fromHex("#3d0000") or Color3.fromHex("#1a0000")
            stroke.Color = autoTrimpEnabled and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
            
            pcall(function()
                if AutoTrimpToggle then AutoTrimpToggle:SetValue(autoTrimpEnabled) end
            end)
            
            if WindUI and WindUI.Notify then
                WindUI:Notify({ Title = "Auto Trimp", Content = autoTrimpEnabled and "Enabled ✅" or "Disabled ❌", Duration = 2 })
            end
        end
    end
    
    button.MouseButton1Click:Connect(handleTap)
    button.TouchTap:Connect(handleTap)
    
    return screenGui
end

-- ============================================
-- تحديث الزر العائم (Blood Moon)
-- ============================================
local function UpdateFloatingButton()
    pcall(function()
        if floatingButton then
            local btn = floatingButton:FindFirstChildOfClass("TextButton")
            if btn then
                btn.Text = autoTrimpEnabled and "AUTO TRIMP: ON" or "AUTO TRIMP: OFF"
                btn.BackgroundColor3 = autoTrimpEnabled and Color3.fromHex("#3d0000") or Color3.fromHex("#1a0000")
            end
        end
    end)
end
    
    -- ============================================
    -- حلقة التشغيل الرئيسية
    -- ============================================
    local function OnRenderStep()
        if not autoTrimpEnabled then
            if activeBV then activeBV:Destroy() end
            currentSpeed = baseSpeed
            return
        end
        
        local char = LP.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not (hrp and humanoid) then return end
        
        local isAir = humanoid.FloorMaterial == Enum.Material.Air
        local deltaTime = math.min(0.05, tick() - lastTick)
        lastTick = tick()
        
        if isAir then
            airAccumulator = airAccumulator + deltaTime
            while airAccumulator >= 0.1 do
                airAccumulator = airAccumulator - 0.1
                currentSpeed = math.min(baseSpeed + maxExtraSpeed, currentSpeed + accelerationRate)
            end
        else
            airAccumulator = 0
            currentSpeed = math.max(baseSpeed, currentSpeed - decelerationRate * deltaTime)
        end
        
        if activeBV then activeBV:Destroy() end
        
        local lookDir = camera.CFrame.LookVector
        lookDir = Vector3.new(lookDir.X, 0, lookDir.Z)
        if lookDir.Magnitude > 0 then lookDir = lookDir.Unit end
        
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = lookDir * currentSpeed
        bv.MaxForce = Vector3.new(400000, 0, 400000)
        bv.Parent = hrp
        Debris:AddItem(bv, 0.1)
        activeBV = bv
    end
    
    RunService.RenderStepped:Connect(OnRenderStep)
    
    -- ============================================
    -- التأكد من وجود تبويب Misc
    -- ============================================
    local MiscTab = nil
    if Tabs and Tabs.Misc then
        MiscTab = Tabs.Misc
    elseif Window and Window.Tabs then
        for _, tab in pairs(Window.Tabs) do
            if tab and (tab.Title == "Misc" or tab.Title == "Miscellaneous") then
                MiscTab = tab
                break
            end
        end
    end
      if MiscTab then
        local AutoTrimpSection = MiscTab:Section({
            Title = "AutoTrimp",
            Side = "Left",
            Collapsed = false,
        })
        
        -- زر تفعيل السكربت نفسه من المنيو
        local AutoTrimpToggle = AutoTrimpSection:Toggle({
            Title = "Enable AutoTrimp",
            Value = autoTrimpEnabled,
            Callback = function(value)
                autoTrimpEnabled = value
                UpdateFloatingButton()
            end
        })

        -- زر إظهار/إخفاء الزر العائم
        AutoTrimpSection:Toggle({
            Title = "Show AutoTrimp GUI",
            Value = false,
            Callback = function(state)
                if state then
                    if floatingButton then
                        floatingButton:Destroy()
                    end
                    floatingButton = CreateFloatingButton()
                    if WindUI and WindUI.Notify then
                        WindUI:Notify({ Title = "Auto Trimp", Content = "Floating button shown", Duration = 2 })
                    end
                else
                    if floatingButton then
                        floatingButton:Destroy()
                        floatingButton = nil
                    end
                end
            end
        })
        
        AutoTrimpSection:Slider({
            Title = "Base Speed",
            Desc = "Normal speed on ground",
            Value = { Min = 20, Max = 80, Default = 40 },
            Callback = function(value)
                baseSpeed = value
                currentSpeed = value
            end
        })
        
        AutoTrimpSection:Slider({
            Title = "Max Extra Speed",
            Desc = "Maximum additional speed in air",
            Value = { Min = 0, Max = 60, Default = 0 },
            Callback = function(value)
                maxExtraSpeed = value
            end
        })
        
        AutoTrimpSection:Slider({
            Title = "Acceleration Rate",
            Desc = "How fast speed increases in air",
            Value = { Min = 0.5, Max = 3, Default = 1.2, Step = 0.1 },
            Callback = function(value)
                accelerationRate = value
            end
        })
        
        AutoTrimpSection:Button({
            Title = "Reset Speed",
            Callback = function()
                currentSpeed = baseSpeed
                if WindUI and WindUI.Notify then
                    WindUI:Notify({ Title = "AutoTrimp", Content = "Speed reset to " .. baseSpeed, Duration = 2 })
                end
            end
        })
    else
        warn("[AutoTrimp] Misc tab not found, UI not created")
    end
    
    print("[AutoTrimp] Loaded successfully!")
end)
  
-- ============================================
-- Emote Speed Module - Misc Tab
-- مستخرج من Draconic Hub Remake
-- ============================================

-- ========== إعدادات المتغيرات ==========
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- تخزين السرعات الأصلية للإيموشنات
local originalEmoteSpeeds = {}

-- جلب مجلد الإيموشنات
local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
if itemsFolder then
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if emotesFolder then
        for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
            if emoteModule:IsA("ModuleScript") then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo then
                    originalEmoteSpeeds[emoteModule.Name] = emoteData.EmoteInfo.SpeedMult
                end
            end
        end
    end
end

-- ========== دالة تطبيق سرعة الإيموشنات ==========
local function applyEmoteSpeed(speedValue)
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local success, emoteData = pcall(require, emoteModule)
            if success and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult ~= 0 then
                emoteData.EmoteInfo.SpeedMult = speedValue
            end
        end
    end
end

-- ========== دالة استعادة السرعات الأصلية ==========
local function restoreOriginalEmoteSpeeds()
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local originalSpeed = originalEmoteSpeeds[emoteModule.Name]
            if originalSpeed then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo then
                    emoteData.EmoteInfo.SpeedMult = originalSpeed
                end
            end
        end
    end
end

-- ========== جداول الحركة لـ Multiplier Speed ==========
local requiredFields = {
    Friction = true, AirStrafeAcceleration = true, JumpHeight = true,
    RunDeaccel = true, JumpSpeedMultiplier = true, JumpCap = true,
    SprintCap = true, WalkSpeedMultiplier = true, BhopEnabled = true,
    Speed = true, AirAcceleration = true, RunAccel = true, SprintAcceleration = true
}

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

local function applySpeedMultiplier(speedMultiplier)
    local targets = getMatchingTables()
    for _, tableObj in ipairs(targets) do
        if tableObj and typeof(tableObj) == "table" then
            pcall(function()
                tableObj.WalkSpeedMultiplier = speedMultiplier
            end)
        end
    end
end

-- ========== الحصول على موديل اللاعب ==========
local function getPlayerObj()
    local gamePlayers = workspace.Game and workspace.Game.Players
    if not gamePlayers then return nil end
    return gamePlayers:FindFirstChild(LP.Name)
end

-- ========== متغيرات Multiplier Speed ==========
local playerObj = nil
local connection = nil
local emotingSpeed = 1.5

local function setupConnection(obj)
    if connection then 
        connection:Disconnect() 
        connection = nil
    end
    playerObj = obj
    if not obj then return end
    
    local function onStateChanged()
        local state = obj:GetAttribute("State")
        local targetSpeed = (state == "Emoting") and emotingSpeed or 1.5
        applySpeedMultiplier(targetSpeed)
    end
    
    onStateChanged()
    connection = obj:GetAttributeChangedSignal("State"):Connect(onStateChanged)
end

local function resetMultiplierSpeed()
    emotingSpeed = 1.5
    applySpeedMultiplier(1.5)
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

-- ========== زر تطبيق على الإيموشنات غير القابلة للمشي ==========
local function ApplyToUnwalkableEmotes(speedValue)
    if not itemsFolder then return end
    
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local success, emoteData = pcall(require, emoteModule)
            if success and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult == 0 then
                emoteData.EmoteInfo.SpeedMult = speedValue
            end
        end
    end
end

-- ========== إعادة تعيين كل شيء ==========
local function ResetAllEmoteSpeeds()
    restoreOriginalEmoteSpeeds()
    resetMultiplierSpeed()
    if connection then 
        connection:Disconnect() 
        connection = nil
    end
end

-- ============================================
-- البحث عن تبويب Misc
-- ============================================
local MiscTab = nil

if Tabs and Tabs.Misc then
    MiscTab = Tabs.Misc
elseif Window and Window.Tabs then
    for _, tab in pairs(Window.Tabs) do
        if tab and (tab.Title == "Misc" or tab.Title == "Miscellaneous") then
            MiscTab = tab
            break
        end
    end
end

-- ============================================
-- إضافة القسم إلى تبويب Misc
-- ============================================
if MiscTab then
    local EmoteSpeedSection = MiscTab:Section({
        Title = "Emote Speed",
        Side = "Left"
    })
    
    if EmoteSpeedSection then
        -- متغيرات الحالة
        local currentMode = "Nah"
        local emoteSpeedValue = 1.5
        
        -- دالة تبديل الوضع
        local function SetMode(mode)
            currentMode = mode
            
            if mode == "Nah" then
                ResetAllEmoteSpeeds()
            elseif mode == "Legit" then
                resetMultiplierSpeed()
                if connection then 
                    connection:Disconnect() 
                    connection = nil
                end
                applyEmoteSpeed(emoteSpeedValue)
            elseif mode == "Multiplier speed" then
                restoreOriginalEmoteSpeeds()
                resetMultiplierSpeed()
                setupConnection(getPlayerObj())
                task.spawn(function()
                    while currentMode == "Multiplier speed" do
                        task.wait(2)
                        local current = getPlayerObj()
                        if current ~= playerObj then
                            setupConnection(current)
                        elseif playerObj then
                            local state = playerObj:GetAttribute("State")
                            local targetSpeed = (state == "Emoting") and emotingSpeed or 1.5
                            applySpeedMultiplier(targetSpeed)
                        end
                    end
                end)
            end
        end
        
        -- دالة تحديث السرعة
        local function UpdateSpeedValue(newValue)
            emoteSpeedValue = newValue
            if currentMode == "Legit" then
                applyEmoteSpeed(newValue)
            elseif currentMode == "Multiplier speed" then
                emotingSpeed = newValue
            end
        end
        
        -- ========== إضافة العناصر ==========
        
        -- Dropdown لاختيار الوضع
        EmoteSpeedSection:Dropdown({
            Title = "Emote Speed Mode",
            Values = { "Nah", "Legit", "Multiplier speed" },
            Default = "Nah",
            Callback = function(value)
                SetMode(value)
                if WindUI and WindUI.Notify then
                    WindUI:Notify({
                        Title = "Emote Speed",
                        Content = "Mode: " .. value,
                        Duration = 2
                    })
                end
            end
        })
        
        -- Slider للسرعة
        EmoteSpeedSection:Slider({
            Title = "Speed Multiplier",
            Desc = "1x = Normal | 1.5x = Faster | 20x = Max",
            Value = { Min = 0.1, Max = 20, Default = 1.5 },
            Step = 0.1,
            Callback = function(value)
                UpdateSpeedValue(value)
                if WindUI and WindUI.Notify then
                    WindUI:Notify({
                        Title = "Speed",
                        Content = string.format("%.1fx", value),
                        Duration = 1
                    })
                end
            end
        })
        
        -- زر تطبيق على الإيموشنات غير القابلة للمشي
        EmoteSpeedSection:Button({
            Title = "Apply to Unwalkable Emotes",
            Desc = "Applies speed to emotes that normally can't move",
            Callback = function()
                ApplyToUnwalkableEmotes(emoteSpeedValue)
                if WindUI and WindUI.Notify then
                    WindUI:Notify({
                        Title = "Emote Speed",
                        Content = "Applied to unwalkable emotes",
                        Duration = 2
                    })
                end
            end
        })
        
        -- زر إعادة تعيين
        EmoteSpeedSection:Button({
            Title = "Reset All Emote Speeds",
            Desc = "Restores all emote speeds to original values",
            Callback = function()
                ResetAllEmoteSpeeds()
                currentMode = "Nah"
                if WindUI and WindUI.Notify then
                    WindUI:Notify({
                        Title = "Emote Speed",
                        Content = "All speeds reset to original",
                        Duration = 2
                    })
                end
            end
        })
    end
else
    -- لو مش لاقي تبويب Misc، نطبع رسالة في الكونسول
    print("[Emote Speed] Misc tab not found, skipping UI creation")
end

-- ========== إشعار التحميل ==========
if WindUI and WindUI.Notify then
    WindUI:Notify({
        Title = "Emote Speed",
        Content = "Loaded in Misc tab | Speed: 0.1x to 20x",
        Duration = 3
    })
end

print("[Emote Speed] Module loaded successfully in Misc tab!")
-- ============================================
-- M.lua - Interactions & Revive
-- ============================================

-- تعريف الخدمات
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- Revive System
-- ============================================
local featureStates = { AutoSelfRevive = false, SelfReviveMethod = "Spawnpoint" }
local lastSavedPosition = nil
local AutoSelfReviveConnection = nil
local respawnConnection = nil
local hasRevived = false

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
                newChar = LocalPlayer.Character
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

local function setupAutoRevive(char)
    if AutoSelfReviveConnection then AutoSelfReviveConnection:Disconnect() end
    AutoSelfReviveConnection = char:GetAttributeChangedSignal("Downed"):Connect(function()
        if char:GetAttribute("Downed") then doRevive(char) end
    end)
end

if respawnConnection then respawnConnection:Disconnect() end
respawnConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if featureStates.AutoSelfRevive then setupAutoRevive(newChar) end
end)

if LocalPlayer.Character and featureStates.AutoSelfRevive then
    setupAutoRevive(LocalPlayer.Character)
end

-- ============================================
-- Interactions (Auto Carry & Auto Revive)
-- ============================================
local INTERACT_REMOTE = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

getgenv().AutoCarryEnabled = false
getgenv().AutoReviveEnabled = false
getgenv().AutoCarryDelay = 1
getgenv().AutoReviveDelay = 1
getgenv().AutoCarryPosition = UDim2.new(0.5, -110, 0, 50)
getgenv().AutoRevivePosition = UDim2.new(0.5, -110, 0, 120)

local lastCarryTime = 0
local lastReviveTime = 0

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

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
    end)

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

local AutoCarryGUI = CreateFloatingButton("AutoCarry", "AutoCarryEnabled", "AutoCarryPosition", 50)
local AutoReviveGUI = CreateFloatingButton("AutoRevive", "AutoReviveEnabled", "AutoRevivePosition", 120)

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

print("✅ M.lua - Interactions & Revive loaded!")

-- ====================================================================
-- 🌐 HYPER V1.0 - PURE CLIENT LAG SWITCH (OCEAN DEEP STYLE)
-- ====================================================================

pcall(function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

if not Tabs or not Tabs.Misc then
    warn("[Lag Switch] Misc Tab not found!")
    return
end

local MiscTab = Tabs.Misc

-- ====================================================================
-- ⚙️ المتغيرات والتحكم
-- ====================================================================
local lagSwitchEnabled = false
local lagKeybind = "F12"
local isLagActive = false
local floatingButtonGui = nil

local lagDuration = 1.5
local lagIntensity = 1000000

-- ====================================================================
-- 🛠️ دالة الـ Lag الصافي (أسلوب دراكونيك اكس)
-- ====================================================================
local function TriggerLagAction()
    if not lagSwitchEnabled or isLagActive then return end
    isLagActive = true
    
    local startTime = tick()
    while tick() - startTime < lagDuration do
        for i = 1, lagIntensity do
            local a = math.random(1, 1000000) * math.random(1, 1000000)
            local b = math.sqrt(math.random(1, 1000000))
            local c = a / math.random(1, 10000)
        end
    end
    
    isLagActive = false
end

-- ====================================================================
-- 🕹️ بناء الزرار العائم (Blood Moon)
-- ====================================================================
local function CreateLagFloatingButton()
    local CoreGui = game:GetService("CoreGui")
    
    local oldGui = CoreGui:FindFirstChild("LagSwitchFloatingButtonGUI")
    if oldGui then pcall(function() oldGui:Destroy() end) end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LagSwitchFloatingButtonGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 55)
    local startX = (workspace.CurrentCamera.ViewportSize.X / 2) - 80
    local startY = (workspace.CurrentCamera.ViewportSize.Y / 2) - 27
    button.Position = UDim2.new(0, startX, 0, startY)
    button.Text = "LAG: OFF"
    
    -- 🩸 Blood Moon Colors
    button.BackgroundColor3 = Color3.fromHex("#1a0000")      -- خلفية حمراء داكنة
    button.TextColor3 = Color3.fromHex("#ffcccc")            -- نص أحمر فاتح
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")                 -- إطار أحمر داكن
    stroke.Thickness = 2
    stroke.Parent = button
    
    local dragging = false
    local dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            stroke.Color = Color3.fromHex("#ff4444")          -- أحمر ناري عند السحب
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
            stroke.Color = Color3.fromHex("#660000")
            button.Text = "LAG: OFF"
        end
    end)
    
    local function handleTap()
        if not dragging and lagSwitchEnabled then
            button.Text = "LAG: ACTIVE"
            button.BackgroundColor3 = Color3.fromHex("#3d0000")      -- أحمر متوسط عند التفعيل
            stroke.Color = Color3.fromHex("#ff4444")
            
            TriggerLagAction()
            
            button.Text = "LAG: OFF"
            button.BackgroundColor3 = Color3.fromHex("#1a0000")
            stroke.Color = Color3.fromHex("#660000")
        end
    end
    
    button.MouseButton1Click:Connect(handleTap)
    button.TouchTap:Connect(handleTap)
    
    return screenGui
end

-- ====================================================================
-- ⚙️ دمج عناصر التحكم داخل لوحة WindUI
-- ====================================================================
local LagSection = MiscTab:Section({
    Title = "Lag Switch",
    Side = "Left",
})

LagSection:Toggle({
    Title = "Enable Lag Switch",
    Value = false,
    Callback = function(state)
        lagSwitchEnabled = state
    end,
})

LagSection:Slider({
    Title = "Lag Duration (seconds)",
    Value = { Min = 0.1, Max = 5, Default = 1.5 },
    Step = 0.1,
    Callback = function(value) lagDuration = value end,
})

LagSection:Slider({
    Title = "Lag Intensity",
    Value = { Min = 100000, Max = 5000000, Default = 1000000 },
    Callback = function(value) lagIntensity = value end,
})

LagSection:Toggle({
    Title = "Show Floating Button",
    Value = false,
    Callback = function(state)
        if state then
            floatingButtonGui = CreateLagFloatingButton()
        else
            if floatingButtonGui then
                pcall(function() floatingButtonGui:Destroy() end)
                floatingButtonGui = nil
            end
        end
    end,
})

LagSection:Keybind({
    Title = "Lag Keybind",
    Default = "F12",
    Mode = "Press",
    Callback = TriggerLagAction,
    ChangedCallback = function(newKey) lagKeybind = newKey end,
})

LagSection:Button({
    Title = "Trigger Lag Now",
    Callback = TriggerLagAction,
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[lagKeybind] then
        TriggerLagAction()
    end
end)

print("[Hyper Pure Lag Switch] Loaded successfully without extras!")

end)
-- ============================================
-- Auto Carry System - Floating Button (Blood Moon)
-- ============================================

-- البحث عن تبويب Misc
local MiscTab = nil
if Tabs and Tabs.Misc then
    MiscTab = Tabs.Misc
elseif Window and Window.Tabs then
    for _, tab in pairs(Window.Tabs) do
        if tab and (tab.Title == "Misc" or tab.Title == "Miscellaneous") then
            MiscTab = tab
            break
        end
    end
end

if not MiscTab then
    MiscTab = Window:Tab({
        Title = "Misc",
        Icon = "box",
        Locked = false
    })
end

-- ============================================
-- قسم Carry Players
-- ============================================
local CarrySection = MiscTab:Section({
    Title = "Carry Players",
    Side = "Left",
    Collapsed = false,
})

-- ============================================
-- متغيرات النظام
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local featureStates = featureStates or {}
featureStates.AutoCarry = false

local AutoCarryConnection = nil
local carryFloatingGui = nil

-- ============================================
-- 1. Toggle Auto Carry
-- ============================================
local AutoCarryToggle = CarrySection:Toggle({
    Title = "Auto Carry",
    Desc = "Automatically carry nearby players",
    Value = false,
    Callback = function(state)
        featureStates.AutoCarry = state
        
        if state then
            StartAutoCarry()
        else
            StopAutoCarry()
        end
        
        UpdateCarryFloatingButton()
    end
})

-- ============================================
-- 2. Toggle Carry Floating Button
-- ============================================
CarrySection:Toggle({
    Title = "Show Carry Button",
    Desc = "Show/hide floating carry button",
    Value = false,
    Callback = function(state)
        if state then
            carryFloatingGui = CreateCarryFloatingButton()
        else
            if carryFloatingGui then
                carryFloatingGui:Destroy()
                carryFloatingGui = nil
            end
        end
    end
})

-- ============================================
-- 3. Carry Button Size
-- ============================================
CarrySection:Input({
    Title = "Carry Button Size",
    Desc = "Adjust floating button size (150-400)",
    Placeholder = "190",
    Numeric = true,
    Callback = function(value)
        if value and tonumber(value) then
            local size = tonumber(value)
            UpdateCarryButtonSize(size)
        end
    end
})

-- ============================================
-- 4. Carry Keybind
-- ============================================
CarrySection:Keybind({
    Title = "Auto Carry Keybind",
    Mode = "Toggle",
    Default = "F3",
    Callback = function()
        featureStates.AutoCarry = not featureStates.AutoCarry
        AutoCarryToggle:SetValue(featureStates.AutoCarry)
        
        if featureStates.AutoCarry then
            StartAutoCarry()
        else
            StopAutoCarry()
        end
        
        UpdateCarryFloatingButton()
    end
})

-- ============================================
-- وظائف Auto Carry
-- ============================================
local function StartAutoCarry()
    if AutoCarryConnection then return end
    
    AutoCarryConnection = RunService.Heartbeat:Connect(function()
        if not featureStates.AutoCarry then return end
        
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= LP and other.Character then
                local otherHrp = other.Character:FindFirstChild("HumanoidRootPart")
                if otherHrp then
                    local dist = (hrp.Position - otherHrp.Position).Magnitude
                    if dist <= 20 then
                        local args = { "Carry", [3] = other.Name }
                        pcall(function()
                            local interact = ReplicatedStorage:FindFirstChild("Events")
                            if interact then
                                interact = interact:FindFirstChild("Character")
                                if interact then
                                    interact = interact:FindFirstChild("Interact")
                                    if interact then
                                        interact:FireServer(unpack(args))
                                    end
                                end
                            end
                        end)
                        task.wait(0.01)
                    end
                end
            end
        end
    end)
end

local function StopAutoCarry()
    if AutoCarryConnection then
        AutoCarryConnection:Disconnect()
        AutoCarryConnection = nil
    end
end

-- ============================================
-- تحديث حجم الزر
-- ============================================
local function UpdateCarryButtonSize(size)
    if carryFloatingGui then
        local btn = carryFloatingGui:FindFirstChildOfClass("TextButton")
        if btn then
            local newWidth = math.max(150, math.min(size or 190, 400))
            local newHeight = math.max(60, math.min((size or 190) * 0.4, 160))
            btn.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end
end

-- ============================================
-- تحديث الزر العائم
-- ============================================
local function UpdateCarryFloatingButton()
    if carryFloatingGui then
        local btn = carryFloatingGui:FindFirstChildOfClass("TextButton")
        if btn then
            btn.Text = featureStates.AutoCarry and "CARRY: ON" or "CARRY: OFF"
            btn.BackgroundColor3 = featureStates.AutoCarry and Color3.fromHex("#3d0000") or Color3.fromHex("#1a0000")
        end
    end
end

-- ============================================
-- إنشاء الزر العائم (Blood Moon Style)
-- ============================================
local function CreateCarryFloatingButton()
    local oldGui = CoreGui:FindFirstChild("CarryFloatingButton")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarryFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 55)
    local startX = (workspace.CurrentCamera.ViewportSize.X / 2) - 80
    local startY = (workspace.CurrentCamera.ViewportSize.Y / 2) - 27
    button.Position = UDim2.new(0, startX, 0, startY)
    button.Text = "CARRY: OFF"
    
    -- 🩸 Blood Moon Colors
    button.BackgroundColor3 = Color3.fromHex("#1a0000")
    button.TextColor3 = Color3.fromHex("#ffcccc")
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- تأثيرات التمرير
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.3
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        stroke.Color = Color3.fromHex("#ff4444")
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0
        button.TextColor3 = Color3.fromHex("#ffcccc")
        stroke.Color = featureStates.AutoCarry and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
    end)
    
    -- نظام السحب
    local dragging = false
    local dragStart, startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            stroke.Color = Color3.fromHex("#ff4444")
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
            stroke.Color = featureStates.AutoCarry and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
            button.Text = featureStates.AutoCarry and "CARRY: ON" or "CARRY: OFF"
        end
    end)
    
    -- الضغط على الزر
    local function handleTap()
        if not dragging then
            button.Text = "CARRY: ACTIVE"
            button.BackgroundColor3 = Color3.fromHex("#3d0000")
            stroke.Color = Color3.fromHex("#ff4444")
            
            featureStates.AutoCarry = not featureStates.AutoCarry
            
            if featureStates.AutoCarry then
                StartAutoCarry()
            else
                StopAutoCarry()
            end
            
            button.Text = featureStates.AutoCarry and "CARRY: ON" or "CARRY: OFF"
            button.BackgroundColor3 = featureStates.AutoCarry and Color3.fromHex("#3d0000") or Color3.fromHex("#1a0000")
            stroke.Color = featureStates.AutoCarry and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
            
            pcall(function()
                if AutoCarryToggle then AutoCarryToggle:SetValue(featureStates.AutoCarry) end
            end)
            
            if WindUI and WindUI.Notify then
                WindUI:Notify({ Title = "Auto Carry", Content = featureStates.AutoCarry and "Enabled" or "Disabled", Duration = 2 })
            end
        end
    end
    
    button.MouseButton1Click:Connect(handleTap)
    button.TouchTap:Connect(handleTap)
    
    return screenGui
end

-- ============================================
-- إشعار تحميل النظام
-- ============================================
print("Carry System loaded successfully!")            
-- ============================================
-- Demon Mode (Lag Switch + Character Rise)
-- For Misc Tab
-- ============================================
pcall(function()

-- الخدمات
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- التأكد من وجود Tabs و MiscTab
if not Tabs then
    warn("[Demon Mode] Tabs not found!")
    return
end

local MiscTab = Tabs.Misc
if not MiscTab then
    warn("[Demon Mode] MiscTab not found!")
    return
end

-- دالة الإشعارات الآمنة
local function SafeNotify(title, content, duration)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({ Title = title, Content = content, Duration = duration or 2 })
        else
            print("[" .. title .. "] " .. content)
        end
    end)
end

-- ============================================
-- المتغيرات
-- ============================================
local demonEnabled = false
local demonKeybind = "K"
local isActive = false
local floatingButtonGui = nil

-- إعدادات Demon Mode
local riseHeight = 100
local riseSpeed = 80
local lagDuration = 0.3
local lagIntensity = 1000000

-- ============================================
-- الدوال الأساسية
-- ============================================

-- 1. تنفيذ الـ Lag (عمليات حسابية ثقيلة)
local function PerformLag()
    local startTime = tick()
    while tick() - startTime < lagDuration do
        for i = 1, lagIntensity do
            local a = math.random(1, 1000000) * math.random(1, 1000000)
            local b = math.sqrt(math.random(1, 1000000))
            local c = a / math.random(1, 10000)
        end
    end
end

-- 2. رفع الشخصية للأعلى
local function RiseCharacter()
    local char = LP.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local startHeight = hrp.Position.Y
    local targetHeight = startHeight + riseHeight
    
    -- BodyVelocity للرفع
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, 1e9, 0)
    bodyVelocity.Velocity = Vector3.new(0, riseSpeed, 0)
    bodyVelocity.Parent = hrp
    
    -- الانتظار حتى الوصول للارتفاع المطلوب أو 3 ثواني
    local startTime = tick()
    while hrp and hrp.Position.Y < targetHeight and (tick() - startTime < 3) do
        task.wait()
    end
    
    bodyVelocity:Destroy()
    
    local finalHeight = hrp and hrp.Position.Y or startHeight
    local heightGained = finalHeight - startHeight
    
    SafeNotify("Demon Mode", "Rose " .. math.floor(heightGained) .. " meters", 2)
    return true
end

-- 3. تفعيل Demon Mode
local function ActivateDemonMode()
    if not demonEnabled then
        SafeNotify("Demon Mode", "Enable Demon Mode first", 2)
        return
    end
    if isActive then return end
    isActive = true
    
    SafeNotify("Demon Mode", "Activating...", 1)
    
    -- تنفيذ الـ Lag أولاً
    PerformLag()
    
    -- ثم رفع الشخصية
    RiseCharacter()
    
    isActive = false
end

-- 4. تفعيل/إلغاء الميزة
local function SetDemonEnabled(state)
    demonEnabled = state
    SafeNotify("Demon Mode", state and "Enabled" or "Disabled", 2)
end

-- ============================================
-- زر عائم متحرك (Blood Moon Style)
-- ============================================
local function CreateDemonFloatingButton()
    local CoreGui = game:GetService("CoreGui")
    
    local oldGui = CoreGui:FindFirstChild("DemonFloatingButton")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DemonFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 55)
    local startX = (workspace.CurrentCamera.ViewportSize.X / 2) - 80
    local startY = (workspace.CurrentCamera.ViewportSize.Y / 2) - 27
    button.Position = UDim2.new(0, startX, 0, startY)
    button.Text = "DEMON"
    
    -- 🩸 Blood Moon Colors
    button.BackgroundColor3 = Color3.fromHex("#1a0000")      -- خلفية حمراء داكنة
    button.TextColor3 = Color3.fromHex("#ffcccc")            -- نص أحمر فاتح
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.AutoButtonColor = false
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")                 -- إطار أحمر داكن
    stroke.Thickness = 2
    stroke.Parent = button
    
    -- نظام السحب
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            stroke.Color = Color3.fromHex("#ff4444")          -- أحمر ناري عند السحب
            button.Text = "DRAG..."
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.Touch or 
               input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                button.Position = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or 
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            stroke.Color = Color3.fromHex("#660000")
            button.Text = "DEMON"
        end
    end)
    
    -- تأثير الضغط على الزر
    local function DoDemon()
        button.BackgroundColor3 = Color3.fromHex("#3d0000")      -- أحمر متوسط عند التفعيل
        button.TextColor3 = Color3.fromRGB(255, 255, 255)        -- أبيض ناصع عند التفعيل
        stroke.Color = Color3.fromHex("#ff4444")                 -- أحمر ناري عند التفعيل
        
        ActivateDemonMode()
        
        button.BackgroundColor3 = Color3.fromHex("#1a0000")
        button.TextColor3 = Color3.fromHex("#ffcccc")
        stroke.Color = Color3.fromHex("#660000")
    end
    
    button.MouseButton1Click:Connect(function()
        if not dragging then DoDemon() end
    end)
    
    button.TouchTap:Connect(function()
        if not dragging then DoDemon() end
    end)
    
    return screenGui
end

-- تحديث واجهة الزر العائم (إن وجد)
local function UpdateFloatingButton()
    if floatingButtonGui then
        local btn = floatingButtonGui:FindFirstChildOfClass("TextButton")
        if btn then
            btn.Text = "DEMON"
            btn.BackgroundColor3 = Color3.fromHex("#1a0000")
            btn.TextColor3 = Color3.fromHex("#ffcccc")
        end
    end
end

-- ============================================
-- Keybind
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[demonKeybind] then
        ActivateDemonMode()
    end
end)

-- ============================================
-- إنشاء الـ Section والأزرار
-- ============================================
local DemonSection = MiscTab:Section({
    Title = "Demon Mode",
    Side = "Left",
    Collapsed = false,
})

-- Toggle تمكين الميزة
DemonSection:Toggle({
    Title = "Enable Demon Mode",
    Value = false,
    Callback = SetDemonEnabled,
})

-- ارتفاع الصعود
DemonSection:Slider({
    Title = "Rise Height (meters)",
    Value = { Min = 10, Max = 500, Default = 100 },
    Callback = function(value) riseHeight = value end,
})

-- سرعة الصعود
DemonSection:Slider({
    Title = "Rise Speed",
    Value = { Min = 20, Max = 200, Default = 80 },
    Callback = function(value) riseSpeed = value end,
})

-- مدة الـ Lag
DemonSection:Slider({
    Title = "Lag Duration (seconds)",
    Value = { Min = 0.1, Max = 2, Default = 0.3 },
    Step = 0.1,
    Callback = function(value) lagDuration = value end,
})

-- قوة الـ Lag
DemonSection:Slider({
    Title = "Lag Intensity",
    Value = { Min = 100000, Max = 5000000, Default = 1000000 },
    Callback = function(value) lagIntensity = value end,
})

-- زر عائم متحرك
DemonSection:Toggle({
    Title = "Show Floating Button",
    Value = false,
    Callback = function(state)
        if state then
            floatingButtonGui = CreateDemonFloatingButton()
        else
            if floatingButtonGui then
                pcall(function() floatingButtonGui:Destroy() end)
                floatingButtonGui = nil
            end
        end
    end,
})

-- Keybind
DemonSection:Keybind({
    Title = "Demon Keybind",
    Default = "K",
    Mode = "Press",
    Callback = ActivateDemonMode,
    ChangedCallback = function(newKey) demonKeybind = newKey end,
})

-- زر تشغيل يدوي
DemonSection:Button({
    Title = "Activate Demon Mode Now",
    Callback = ActivateDemonMode,
})

print("[Demon Mode] Loaded successfully!")
SafeNotify("Demon Mode", "Section Loaded Successfully!", 3)

end) -- نهاية pcall

-- ============================================
-- Gravity System (في تبويب Misc)
-- ============================================
pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    
    -- ============================================
    -- المتغيرات
    -- ============================================
    local gravityEnabled = false
    local originalGravity = workspace.Gravity
    local gravityValue = 10
    local gravityKeybind = "G"
    local gravityFloatingGui = nil
    
    -- ============================================
    -- دالة تبديل الجاذبية
    -- ============================================
    local function toggleGravity()
        gravityEnabled = not gravityEnabled
        if gravityEnabled then
            workspace.Gravity = gravityValue
        else
            workspace.Gravity = originalGravity
        end
        
        -- تحديث الزر العائم لو موجود
        if gravityFloatingGui then
            local btn = gravityFloatingGui:FindFirstChildOfClass("TextButton")
            if btn then
                btn.Text = gravityEnabled and "GRAVITY: ON" or "GRAVITY: OFF"
            end
        end
    end
    
-- ============================================
-- Gravity Floating Button (Blood Moon Style)
-- ============================================
local function CreateGravityFloatingButton()
    local CoreGui = game:GetService("CoreGui")
    
    local oldGui = CoreGui:FindFirstChild("GravityFloatingButton")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GravityFloatingButton"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 55)
    local startX = (workspace.CurrentCamera.ViewportSize.X / 2) - 80
    local startY = (workspace.CurrentCamera.ViewportSize.Y / 2) - 27
    button.Position = UDim2.new(0, startX, 0, startY)
    button.Text = "GRAVITY: OFF"
    
    -- 🩸 Blood Moon Colors
    button.BackgroundColor3 = Color3.fromHex("#1a0000")      -- خلفية حمراء داكنة
    button.TextColor3 = Color3.fromHex("#ffcccc")            -- نص أحمر فاتح
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromHex("#660000")                 -- إطار أحمر داكن
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
            stroke.Color = Color3.fromHex("#ff4444")          -- أحمر ناري عند السحب
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
            stroke.Color = gravityEnabled and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
            button.Text = gravityEnabled and "GRAVITY: ON" or "GRAVITY: OFF"
        end
    end)
    
    -- تأثير الضغط على الزر
    local function handleTap()
        if not dragging then
            button.Text = "GRAVITY: ACTIVE"
            button.BackgroundColor3 = Color3.fromHex("#3d0000")      -- أحمر متوسط عند التفعيل
            stroke.Color = Color3.fromHex("#ff4444")
            
            toggleGravity()
            
            button.Text = gravityEnabled and "GRAVITY: ON" or "GRAVITY: OFF"
            button.BackgroundColor3 = gravityEnabled and Color3.fromHex("#3d0000") or Color3.fromHex("#1a0000")
            stroke.Color = gravityEnabled and Color3.fromHex("#ff4444") or Color3.fromHex("#660000")
            
            -- تحديث الـ Toggle في الواجهة
            if GravityToggle then
                GravityToggle:SetValue(gravityEnabled)
            end
        end
    end
    
    button.MouseButton1Click:Connect(handleTap)
    button.TouchTap:Connect(handleTap)
    
    return screenGui
end
    
    -- ============================================
    -- Keybind للجاذبية
    -- ============================================
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[gravityKeybind] then
            toggleGravity()
            
            -- تحديث الـ Toggle في الواجهة
            if GravityToggle then
                GravityToggle:SetValue(gravityEnabled)
            end
        end
    end)
    
    -- ============================================
    -- إنشاء القسم في تبويب Misc
    -- ============================================
    local GravitySection = Tabs.Misc:Section({
        Title = "Gravity Control",
        Side = "Left",
        Collapsed = true,
    })
    
    -- Toggle التفعيل
    local GravityToggle = GravitySection:Toggle({
        Title = "Gravity",
        Desc = "Modify workspace gravity",
        Value = false,
        Callback = function(state)
            gravityEnabled = state
            if state then
                workspace.Gravity = gravityValue
            else
                workspace.Gravity = originalGravity
            end
            
            -- تحديث الزر العائم لو موجود
            if gravityFloatingGui then
                local btn = gravityFloatingGui:FindFirstChildOfClass("TextButton")
                if btn then
                    btn.Text = gravityEnabled and "GRAVITY: ON" or "GRAVITY: OFF"
                end
            end
        end
    })
    
    -- Input قيمة الجاذبية
    GravitySection:Input({
        Title = "Gravity Value",
        Desc = "Default: 10 (Lower = less gravity)",
        Default = "10",
        Placeholder = "10",
        Numeric = true,
        Callback = function(value)
            local num = tonumber(value)
            if num and num > 0 then
                gravityValue = num
                if gravityEnabled then
                    workspace.Gravity = gravityValue
                end
                WindUI:Notify({ Title = "Gravity", Content = "Set to: " .. num, Duration = 1 })
            elseif num and num <= 0 then
                WindUI:Notify({ Title = "Error", Content = "Gravity must be positive", Duration = 2 })
            end
        end
    })
    
    -- زر عرض الزر العائم
    GravitySection:Toggle({
        Title = "Show Floating Button",
        Desc = "Show/hide gravity floating button",
        Value = false,
        Callback = function(state)
            if state then
                gravityFloatingGui = CreateGravityFloatingButton()
            else
                if gravityFloatingGui then
                    gravityFloatingGui:Destroy()
                    gravityFloatingGui = nil
                end
            end
        end
    })
    
    -- Keybind للجاذبية
    GravitySection:Keybind({
        Title = "Gravity Keybind",
        Default = "G",
        Mode = "Toggle",
        Callback = function()
            toggleGravity()
            if GravityToggle then
                GravityToggle:SetValue(gravityEnabled)
            end
        end,
        ChangedCallback = function(newKey)
            gravityKeybind = newKey
        end
    })
    
    -- زر إعادة ضبط الجاذبية للأصل
    GravitySection:Button({
        Title = "Reset Gravity",
        Desc = "Reset to original game gravity",
        Callback = function()
            originalGravity = workspace.Gravity
            gravityValue = originalGravity
            if gravityEnabled then
                workspace.Gravity = gravityValue
            end
            WindUI:Notify({ Title = "Gravity", Content = "Reset to: " .. originalGravity, Duration = 2 })
        end
    })
    
    print("[Gravity System] Loaded successfully in Misc tab!")
end)
-- ============================================
-- Emote on Ctrl - المتغيرات الكاملة
-- ============================================

-- تعريف الخدمات
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- المتغيرات
local emoteOnCrouchEnabled = false

-- ============================================
-- دالة تشغيل الإيموت
-- ============================================
local function PlayEmote()
    pcall(function()
        local character = LP.Character
        if not character then 
            print("❌ No character found")
            return 
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then 
            print(" No humanoid found")
            return 
        end
        
        print("Emote played!")
        
        -- جرب تشغيل إيموت من ReplicatedStorage
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local emotesFolder = replicatedStorage:FindFirstChild("Emotes")
        if emotesFolder then
            local emote = emotesFolder:GetChildren()[math.random(1, #emotesFolder:GetChildren())]
            if emote then
                local animTrack = humanoid:LoadAnimation(emote)
                if animTrack then
                    animTrack:Play()
                    print(" Emote animation playing")
                end
            end
        end
    end)
end

-- ============================================
-- التحكم في الضغط على Ctrl
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        if emoteOnCrouchEnabled then
            PlayEmote()
        end
    end
end)

print(" Emote on Ctrl loaded successfully!")
