-- ============================================
-- Home Tab - الطريقة الجديدة
-- ============================================
local Main = Window:Tab({
    Title = "Home",
    Icon = "solar:magic-stick-linear",
    Locked = false
})

-- اختيار تبويب Home تلقائياً
Main:Select()

-- ============================================
-- About Section (مفتوحة تلقائياً)
-- ============================================
local AboutSection = Main:Section({
    Title = "About",
    Side = "Left",
    Collapsed = false,
})

AboutSection:Paragraph({    
    Title = "About Neo Hyper",    
    Desc = "Made By : M4X EVA,  Special thanks: Amal Jana ",
    Thumbnail = "rbxassetid://125307920527809",
    ThumbnailSize = 60,
})

-- ============================================
-- فتح القسم تلقائياً
-- ============================================
task.wait(0.1)
pcall(function()
    AboutSection:Open()
end)

print("✅ About section loaded in Home tab!")

-- ====================================================================
-- 🦅 HYPER V1.0 - FLY ENGINE & UI MODIFICATION (WINDUI VERSION)
-- ====================================================================

pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ====================================================================
    -- 🛑 إخفاء واجهة التايمر (Timer Hider)
    -- ====================================================================
    local function HideTimerUI()
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if not pg then return end
            
            local shared = pg:FindFirstChild("Shared")
            local hud = shared and shared:FindFirstChild("HUD")
            local overlay = hud and hud:FindFirstChild("Overlay")
            local default = overlay and overlay:FindFirstChild("Default")
            local ro = default and default:FindFirstChild("RoundOverlay")
            local round = ro and ro:FindFirstChild("Round")
            local timer = round and round:FindFirstChild("RoundTimer")
            
            if timer then
                timer.Visible = false
            end
            
            local main = pg:FindFirstChild("MainInterface")
            if main then
                local container = main:FindFirstChild("TimerContainer")
                if container then
                    container.Visible = false
                end
            end
        end)
    end

    -- تنفيذ الإخفاء فوراً
    HideTimerUI()
    
    -- ====================================================================
    -- 🦅 ميزة الطيران (Fly System)
    -- ====================================================================
    if not Tabs or not Tabs.Main then return end
    local HomeTab = Tabs.Main

    -- ✅ التصحيح: استخدم HomeTab بدلاً من Main
    local PlayerModSection = HomeTab:Section({
        Title = "Fly",
        Side = "Left",
    })

    -- المتغيرات الخاصة بالطيران
    local featureStates = { FlySpeed = 50 }
    local flying = false
    local bodyVelocity = nil
    local bodyGyro = nil
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    local flyLoop = nil
    local characterAddedConnection = nil

    local function startFlying()
        character = LocalPlayer.Character
        if not character then return end
        humanoid = character:WaitForChild("Humanoid", 3)
        rootPart = character:WaitForChild("HumanoidRootPart", 3)
        if not humanoid or not rootPart then return end
        
        flying = true
        
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        humanoid.PlatformStand = true
    end

    local function stopFlying()
        flying = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function updateFly()
        if not flying or not bodyVelocity or not bodyGyro then return end
        if not humanoid or not humanoid.Parent then return end

        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local direction = Vector3.new(0, 0, 0)
        local moveDirection = humanoid.MoveDirection
        
        if moveDirection.Magnitude > 0 then
            local forwardVector = cameraCFrame.LookVector
            local rightVector = cameraCFrame.RightVector
            local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
            local rightComponent = moveDirection:Dot(rightVector) * rightVector
            direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        local speed = featureStates.FlySpeed or 50
        bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * (speed * 2) or Vector3.new(0, 0, 0)
        bodyGyro.CFrame = cameraCFrame
    end

    -- زر تفعيل الطيران (Toggle)
    PlayerModSection:Toggle({
        Title = "Fly",
        Value = false,
        Callback = function(state)
            if state then
                if characterAddedConnection then characterAddedConnection:Disconnect() end
                
                characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    character = newChar
                    task.wait(0.5)
                    humanoid = character:WaitForChild("Humanoid", 3)
                    rootPart = character:WaitForChild("HumanoidRootPart", 3)
                    
                    if flying == false then
                        startFlying()
                    end
                end)
                
                character = LocalPlayer.Character
                if character then
                    humanoid = character:FindFirstChild("Humanoid")
                    rootPart = character:FindFirstChild("HumanoidRootPart")
                end
                
                startFlying()
                
                if not flyLoop then
                    flyLoop = RunService.RenderStepped:Connect(function()
                        updateFly()
                    end)
                end
            else
                stopFlying()
                
                if flyLoop then
                    flyLoop:Disconnect()
                    flyLoop = nil
                end
                
                if characterAddedConnection then
                    characterAddedConnection:Disconnect()
                    characterAddedConnection = nil
                end
            end
        end,
    })

    -- إدخال سرعة الطيران (Input)
    PlayerModSection:Input({
        Title = "Fly Speed",
        Default = "50",
        Placeholder = "50",
        Callback = function(value)
            if value and tonumber(value) then
                featureStates.FlySpeed = tonumber(value)
            end
        end,
    }) 
    
    -- إيقاف الطيران عند الموت أو إزالة الشخصية
    LocalPlayer.CharacterRemoving:Connect(function()
        if flying then
            stopFlying()
            if flyLoop then
                flyLoop:Disconnect()
                flyLoop = nil
            end
        end
    end)

    -- إعادة تفعيل الطيران تلقائياً بعد الرسبون إذا كان الزرار مفعل
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if flying then
            task.wait(0.5) 
            stopFlying()
            task.wait(0.1)
            startFlying()
            
            if not flyLoop then
                flyLoop = RunService.RenderStepped:Connect(function()
                    updateFly()
                end)
            end
        end
    end)
end)

-- ============================================
-- More Features - في تاب Main
-- ============================================
local MainSection = Main:Section({
    Title = "More Features",
    Side = "Left",
    Collapsed = false,
})

-- زر إعادة الظهور
MainSection:Button({
    Title = "Respawn",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end)
    end,
})

-- زر Anti AFK
local antiAFKEnabled = false
local antiAFKConnection = nil

local function StopAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

local function StartAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    antiAFKConnection = LP.Idled:Connect(function()
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end)
end

MainSection:Toggle({
    Title = "Anti AFK",
    Default = false,
    Callback = function(state)
        antiAFKEnabled = state
        if state then
            StartAntiAFK()
        else
            StopAntiAFK()
        end
    end,
})

-- ================================
-- Custom Top Bar (Leaderboard, Zoom, Front View)
-- Hold to Enable Style
-- ================================
pcall(function()
    local player = game.Players.LocalPlayer
    local starterGui = game:GetService("StarterGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    
    MainSection:Button({
        Title = "Custom Top Bar",
        Desc = "Hold buttons: Leaderboard, Zoom, Front View",
        Callback = function()
            local playerGui = player:WaitForChild("PlayerGui")
            
            -- حذف القديم لو موجود
            if playerGui:FindFirstChild("CustomTopGui") then
                playerGui.CustomTopGui:Destroy()
                WindUI:Notify({ Title = "Custom Bar", Content = "Bar removed", Duration = 2 })
                starterGui:SetCore("TopbarEnabled", true)
                return
            end
            
            starterGui:SetCore("TopbarEnabled", false)
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "CustomTopGui"
            screenGui.IgnoreGuiInset = false
            screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
            screenGui.DisplayOrder = 100
            screenGui.ResetOnSpawn = false
            screenGui.Parent = playerGui
            
            local frame = Instance.new("Frame")
            frame.Parent = screenGui
            frame.BackgroundTransparency = 1
            frame.BorderSizePixel = 0
            frame.Position = UDim2.new(0, 0, 0, 0)
            frame.Size = UDim2.new(1, 0, 1, -2)
            
            local scrollingFrame = Instance.new("ScrollingFrame")
            scrollingFrame.Name = "Right"
            scrollingFrame.Parent = frame
            scrollingFrame.BackgroundTransparency = 1
            scrollingFrame.BorderSizePixel = 0
            scrollingFrame.Position = UDim2.new(0, 12, 0, 0)
            scrollingFrame.Size = UDim2.new(1, -24, 1, 0)
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
            scrollingFrame.ScrollBarThickness = 0
            scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.X
            scrollingFrame.ScrollingEnabled = false
            
            local uiListLayout = Instance.new("UIListLayout")
            uiListLayout.Parent = scrollingFrame
            uiListLayout.Padding = UDim.new(0, 12)
            uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            uiListLayout.FillDirection = Enum.FillDirection.Horizontal
            uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            
            local buttonsConfig = {
                {
                    name = "ZoomButton",
                    layoutOrder = 999,
                    icon = "rbxassetid://126943351764139",
                    label = "Zoom",
                    width = 100,
                    labelWidth = 45,
                    key = "Secondary"
                },
                {
                    name = "FrontViewButton",
                    layoutOrder = 997,
                    icon = "rbxassetid://78648212535999",
                    label = "Front View",
                    width = 173,
                    labelWidth = 118,
                    key = "Reload"
                },
                {
                    name = "LeaderboardButton",
                    layoutOrder = 998,
                    icon = "rbxassetid://5107166345",
                    label = "Leaderboard",
                    width = 143,
                    labelWidth = 88,
                    key = "Leaderboard"
                }
            }
            
            local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            for _, config in ipairs(buttonsConfig) do
                local Button = Instance.new("Frame")
                Button.Name = config.name
                Button.Parent = scrollingFrame
                Button.BackgroundTransparency = 1
                Button.ClipsDescendants = true
                Button.LayoutOrder = config.layoutOrder
                Button.Size = UDim2.new(0, 44, 0, 44)
                Button.ZIndex = 20
                
                local IconButton = Instance.new("Frame")
                IconButton.Name = "IconButton"
                IconButton.Parent = Button
                IconButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                IconButton.BackgroundTransparency = 0.3
                IconButton.BorderSizePixel = 0
                IconButton.ClipsDescendants = true
                IconButton.Size = UDim2.new(1, 0, 1, 0)
                IconButton.ZIndex = 2
                
                local UICorner = Instance.new("UICorner")
                UICorner.CornerRadius = UDim.new(1, 0)
                UICorner.Parent = IconButton
                
                local Menu = Instance.new("ScrollingFrame")
                Menu.Name = "Menu"
                Menu.Parent = IconButton
                Menu.BackgroundTransparency = 1
                Menu.BorderSizePixel = 0
                Menu.Position = UDim2.new(0, 4, 0, 0)
                Menu.Selectable = false
                Menu.Size = UDim2.new(1, 0, 1, 0)
                Menu.ZIndex = 20
                Menu.BottomImage = ""
                Menu.CanvasSize = UDim2.new(0, 0, 1, -1)
                Menu.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
                Menu.ScrollBarThickness = 3
                Menu.TopImage = ""
                
                local MenuUIListLayout = Instance.new("UIListLayout")
                MenuUIListLayout.Name = "MenuUIListLayout"
                MenuUIListLayout.Parent = Menu
                MenuUIListLayout.FillDirection = Enum.FillDirection.Horizontal
                MenuUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                MenuUIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                
                local IconSpot = Instance.new("Frame")
                IconSpot.Name = "IconSpot"
                IconSpot.Parent = Menu
                IconSpot.AnchorPoint = Vector2.new(0, 0.5)
                IconSpot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                IconSpot.BackgroundTransparency = 1
                IconSpot.Position = UDim2.new(0, 4, 0.5, 0)
                IconSpot.Size = UDim2.new(0, 36, 1, -8)
                IconSpot.ZIndex = 5
                
                local UICorner_2 = Instance.new("UICorner")
                UICorner_2.CornerRadius = UDim.new(1, 0)
                UICorner_2.Parent = IconSpot
                
                local IconOverlay = Instance.new("Frame")
                IconOverlay.Name = "IconOverlay"
                IconOverlay.Parent = IconSpot
                IconOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                IconOverlay.BackgroundTransparency = 0.925
                IconOverlay.Size = UDim2.new(1, 0, 1, 0)
                IconOverlay.Visible = false
                IconOverlay.ZIndex = 6
                
                local UICorner_3 = Instance.new("UICorner")
                UICorner_3.CornerRadius = UDim.new(1, 0)
                UICorner_3.Parent = IconOverlay
                
                local ClickRegion = Instance.new("TextButton")
                ClickRegion.Name = "ClickRegion"
                ClickRegion.Parent = IconSpot
                ClickRegion.BackgroundTransparency = 1
                ClickRegion.Size = UDim2.new(1, 0, 1, 0)
                ClickRegion.ZIndex = 20
                ClickRegion.Text = ""
                
                local Contents = Instance.new("Frame")
                Contents.Name = "Contents"
                Contents.Parent = IconSpot
                Contents.BackgroundTransparency = 1
                Contents.Size = UDim2.new(1, 0, 1, 0)
                
                local ContentsList = Instance.new("UIListLayout")
                ContentsList.Name = "ContentsList"
                ContentsList.Parent = Contents
                ContentsList.FillDirection = Enum.FillDirection.Horizontal
                ContentsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
                ContentsList.SortOrder = Enum.SortOrder.LayoutOrder
                ContentsList.VerticalAlignment = Enum.VerticalAlignment.Center
                ContentsList.Padding = UDim.new(0, 3)
                
                local IconLabelContainer = Instance.new("Frame")
                IconLabelContainer.Name = "IconLabelContainer"
                IconLabelContainer.Parent = Contents
                IconLabelContainer.AnchorPoint = Vector2.new(0, 0.5)
                IconLabelContainer.BackgroundTransparency = 1
                IconLabelContainer.LayoutOrder = 4
                IconLabelContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
                IconLabelContainer.Size = UDim2.new(0, 0, 1, 0)
                IconLabelContainer.Visible = false
                IconLabelContainer.ZIndex = 3
                
                local IconLabel = Instance.new("TextLabel")
                IconLabel.Name = "IconLabel"
                IconLabel.Parent = IconLabelContainer
                IconLabel.BackgroundTransparency = 1
                IconLabel.LayoutOrder = 4
                IconLabel.Size = UDim2.new(0, 1306, 1, 0)
                IconLabel.ZIndex = 15
                IconLabel.Font = Enum.Font.GothamMedium
                IconLabel.Text = config.label
                IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                IconLabel.TextSize = 16
                IconLabel.TextWrapped = true
                IconLabel.TextXAlignment = Enum.TextXAlignment.Left
                IconLabel.Visible = false
                
                local IconImage = Instance.new("ImageLabel")
                IconImage.Name = "IconImage"
                IconImage.Parent = Contents
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.BackgroundTransparency = 1
                IconImage.LayoutOrder = 2
                IconImage.Position = UDim2.new(0, 11, 0.5, 0)
                IconImage.Size = UDim2.new(0.7, 0, 0.7, 0)
                IconImage.ZIndex = 15
                IconImage.Image = config.icon
                
                local IconImageRatio = Instance.new("UIAspectRatioConstraint")
                IconImageRatio.Name = "IconImageRatio"
                IconImageRatio.Parent = IconImage
                IconImageRatio.DominantAxis = Enum.DominantAxis.Height
                
                local IconSpotGradient = Instance.new("UIGradient")
                IconSpotGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(96, 98, 100)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(77, 78, 80))
                }
                IconSpotGradient.Rotation = 45
                IconSpotGradient.Name = "IconSpotGradient"
                IconSpotGradient.Parent = IconSpot
                
                local IconGradient = Instance.new("UIGradient")
                IconGradient.Name = "IconGradient"
                IconGradient.Parent = IconButton
                
                local isHovering = false
                local currentTween = nil
                local hideDelay = 0.3
                
                local smallButtonSize = UDim2.new(0, 44, 0, 44)
                local largeButtonSize = UDim2.new(0, config.width, 0, 44)
                local smallIconSpotSize = UDim2.new(0, 36, 1, -8)
                local largeIconSpotSize = UDim2.new(0, config.width - 8, 1, -8)
                local smallLabelSize = UDim2.new(0, 0, 1, 0)
                local largeLabelSize = UDim2.new(0, config.labelWidth, 1, 0)
                
                local function hideTextWithDelay()
                    task.wait(hideDelay)
                    if not isHovering then
                        IconLabel.Visible = false
                        IconLabelContainer.Visible = false
                        IconOverlay.Visible = false
                    end
                end
                
                local function expand()
                    isHovering = true
                    if currentTween then currentTween:Cancel() end
                    
                    IconLabel.Visible = true
                    IconLabelContainer.Visible = true
                    IconOverlay.Visible = true
                    
                    currentTween = TweenService:Create(Button, tweenInfo, {Size = largeButtonSize})
                    currentTween:Play()
                    TweenService:Create(IconSpot, tweenInfo, {Size = largeIconSpotSize}):Play()
                    TweenService:Create(IconLabelContainer, tweenInfo, {Size = largeLabelSize}):Play()
                end
                
                local function contract()
                    isHovering = false
                    if currentTween then currentTween:Cancel() end
                    
                    currentTween = TweenService:Create(Button, tweenInfo, {Size = smallButtonSize})
                    currentTween:Play()
                    TweenService:Create(IconSpot, tweenInfo, {Size = smallIconSpotSize}):Play()
                    TweenService:Create(IconLabelContainer, tweenInfo, {Size = smallLabelSize}):Play()
                    hideTextWithDelay()
                end
                
                -- Hold to Enable Logic
                local isHolding = false
                local holdConnection = nil
                
                ClickRegion.MouseEnter:Connect(expand)
                
                ClickRegion.MouseLeave:Connect(function()
                    contract()
                    if isHolding then
                        isHolding = false
                        if holdConnection then
                            holdConnection:Disconnect()
                            holdConnection = nil
                        end
                        pcall(function()
                            local events = player.PlayerScripts:FindFirstChild("Events")
                            if events then
                                local tempEvents = events:FindFirstChild("temporary_events")
                                if tempEvents then
                                    local useKeybind = tempEvents:FindFirstChild("UseKeybind")
                                    if useKeybind then
                                        useKeybind:Fire({Key = config.key, Down = false})
                                    end
                                end
                            end
                        end)
                    end
                end)
                
                ClickRegion.MouseButton1Down:Connect(function()
                    if isHolding then return end
                    isHolding = true
                    
                    pcall(function()
                        local events = player.PlayerScripts:FindFirstChild("Events")
                        if events then
                            local tempEvents = events:FindFirstChild("temporary_events")
                            if tempEvents then
                                local useKeybind = tempEvents:FindFirstChild("UseKeybind")
                                if useKeybind then
                                    useKeybind:Fire({Key = config.key, Down = true})
                                end
                            end
                        end
                    end)
                end)
                
                ClickRegion.MouseButton1Up:Connect(function()
                    if not isHolding then return end
                    isHolding = false
                    
                    if holdConnection then
                        holdConnection:Disconnect()
                        holdConnection = nil
                    end
                    
                    pcall(function()
                        local events = player.PlayerScripts:FindFirstChild("Events")
                        if events then
                            local tempEvents = events:FindFirstChild("temporary_events")
                            if tempEvents then
                                local useKeybind = tempEvents:FindFirstChild("UseKeybind")
                                if useKeybind then
                                    useKeybind:Fire({Key = config.key, Down = false})
                                end
                            end
                        end
                    end)
                end)
            end
            
            WindUI:Notify({ Title = "Custom Bar", Content = "Hold buttons to use (release to stop)", Duration = 3 })
        end
    })
end)

print("✅ More Features loaded!")
-- ====================================================================
-- 🦅 HYPER V1.0 - FLY ENGINE & UI MODIFICATION (WINDUI VERSION)
-- ====================================================================

pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ====================================================================
    -- 🛑 إخفاء واجهة التايمر (Timer Hider)
    -- ====================================================================
    local function HideTimerUI()
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if not pg then return end
            
            local shared = pg:FindFirstChild("Shared")
            local hud = shared and shared:FindFirstChild("HUD")
            local overlay = hud and hud:FindFirstChild("Overlay")
            local default = overlay and overlay:FindFirstChild("Default")
            local ro = default and default:FindFirstChild("RoundOverlay")
            local round = ro and ro:FindFirstChild("Round")
            local timer = round and round:FindFirstChild("RoundTimer")
            
            if timer then
                timer.Visible = false
            end
            
            local main = pg:FindFirstChild("MainInterface")
            if main then
                local container = main:FindFirstChild("TimerContainer")
                if container then
                    container.Visible = false
                end
            end
        end)
    end

    -- تنفيذ الإخفاء فوراً
    HideTimerUI()
  -- ====================================================================
-- 🦅 ميزة الطيران (Fly System)
-- ====================================================================

if not Tabs or not Tabs.Main then return end
local HomeTab = Tabs.Main

-- إنشاء القسم
local PlayerModSection = HomeTab:Section({
    Title = "Fly",
    Side = "Left",
    Collapsed = false,
})

    -- المتغيرات الخاصة بالطيران
    local featureStates = { FlySpeed = 50 }
    local flying = false
    local bodyVelocity = nil
    local bodyGyro = nil
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    local flyLoop = nil
    local characterAddedConnection = nil

    local function startFlying()
        character = LocalPlayer.Character
        if not character then return end
        humanoid = character:WaitForChild("Humanoid", 3)
        rootPart = character:WaitForChild("HumanoidRootPart", 3)
        if not humanoid or not rootPart then return end
        
        flying = true
        
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.Parent = rootPart
        
        humanoid.PlatformStand = true
    end

    local function stopFlying()
        flying = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function updateFly()
        if not flying or not bodyVelocity or not bodyGyro then return end
        if not humanoid or not humanoid.Parent then return end

        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local direction = Vector3.new(0, 0, 0)
        local moveDirection = humanoid.MoveDirection
        
        if moveDirection.Magnitude > 0 then
            local forwardVector = cameraCFrame.LookVector
            local rightVector = cameraCFrame.RightVector
            local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
            local rightComponent = moveDirection:Dot(rightVector) * rightVector
            direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        local speed = featureStates.FlySpeed or 50
        bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * (speed * 2) or Vector3.new(0, 0, 0)
        bodyGyro.CFrame = cameraCFrame
    end

    -- زر تفعيل الطيران (Toggle)
    PlayerModSection:Toggle({
        Title = "Fly",
        Value = false,
        Callback = function(state)
            if state then
                if characterAddedConnection then characterAddedConnection:Disconnect() end
                
                characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                    character = newChar
                    task.wait(0.5)
                    humanoid = character:WaitForChild("Humanoid", 3)
                    rootPart = character:WaitForChild("HumanoidRootPart", 3)
                    
                    if flying == false then
                        startFlying()
                    end
                end)
                
                character = LocalPlayer.Character
                if character then
                    humanoid = character:FindFirstChild("Humanoid")
                    rootPart = character:FindFirstChild("HumanoidRootPart")
                end
                
                startFlying()
                
                if not flyLoop then
                    flyLoop = RunService.RenderStepped:Connect(function()
                        updateFly()
                    end)
                end
            else
                stopFlying()
                
                if flyLoop then
                    flyLoop:Disconnect()
                    flyLoop = nil
                end
                
                if characterAddedConnection then
                    characterAddedConnection:Disconnect()
                    characterAddedConnection = nil
                end
            end
        end,
    })

    -- إدخال سرعة الطيران (Input)
    PlayerModSection:Input({
        Title = "Fly Speed",
        Default = "50",
        Placeholder = "50",
        Callback = function(value)
            if value and tonumber(value) then
                featureStates.FlySpeed = tonumber(value)
            end
        end,
    }) 
        -- إيقاف الطيران عند الموت أو إزالة الشخصية
    LocalPlayer.CharacterRemoving:Connect(function()
        if flying then
            stopFlying()
            if flyLoop then
                flyLoop:Disconnect()
                flyLoop = nil
            end
        end
    end)

    -- إعادة تفعيل الطيران تلقائياً بعد الرسبون إذا كان الزرار مفعل
        -- إعادة تفعيل الطيران تلقائياً بعد الرسبون
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        if flying then
            task.wait(0.5) 
            stopFlying() -- بنوقف أي حاجة قديمة عشان نتجنب التعليق
            task.wait(0.1)
            startFlying() -- بنشغل الطيران الجديد
            
            -- نتأكد إن اللوب شغال
            if not flyLoop then
                flyLoop = RunService.RenderStepped:Connect(function()
                    updateFly()
                end)
            end
        end
    end)
end)
