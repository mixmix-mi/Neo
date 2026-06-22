local Tabs = {
    Auto = Window:Tab({ Title = "Auto Farm", Icon = "swords", Locked = false }),
}
if not Tabs.Auto then
    Tabs.Auto = Window:Tab({ Title = "Auto Farm", Icon = "swords", Locked = false })
end

local AutoTab = Tabs.Auto

pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LP = Players.LocalPlayer
    
    -- ============================================
    -- المتغيرات العامة
    -- ============================================
    local afkFarmActive = false
    local ticketFarmActive = false
    local cashFarmActive = false
    local farmHeight = 500
    local farmConnections = { afk = nil, ticket = nil, cash = nil }
    
    -- المنصة الثابتة لـ AFK Farm
    local farmPlatform = nil
    
    -- إنشاء المنصة
    local function CreateFarmPlatform()
        if farmPlatform and farmPlatform.Parent then return end
        farmPlatform = Instance.new("Part")
        farmPlatform.Name = "HyperFarmPlatform"
        farmPlatform.Anchored = true
        farmPlatform.CanCollide = true
        farmPlatform.Transparency = 0.5
        farmPlatform.Material = Enum.Material.Neon
        farmPlatform.Color = Color3.fromRGB(0, 68, 170)
        farmPlatform.Size = Vector3.new(10, 1, 10)
        farmPlatform.Position = Vector3.new(100, farmHeight, 100)
        farmPlatform.Parent = workspace
        
        -- توهج للمنصة
        local glow = Instance.new("SelectionBox")
        glow.Adornee = farmPlatform
        glow.Color3 = Color3.fromRGB(0, 68, 170)
        glow.Transparency = 0.5
        glow.LineThickness = 0.05
        glow.Parent = farmPlatform
    end
    
    local function DestroyFarmPlatform()
        if farmPlatform then
            farmPlatform:Destroy()
            farmPlatform = nil
        end
    end
    
    -- ============================================
    -- 1. AFK Farm (الوقوف في مكان آمن)
    -- ============================================
    local function StartAFKFarm()
        if farmConnections.afk then return end
        CreateFarmPlatform()
        
        farmConnections.afk = RunService.RenderStepped:Connect(function()
            if not afkFarmActive then return end
            
            local char = LP.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- إحياء إذا كان ميت
            if char:GetAttribute("Downed") then
                pcall(function()
                    local reviveEvent = ReplicatedStorage:FindFirstChild("Events") and
                                       ReplicatedStorage.Events:FindFirstChild("Player") and
                                       ReplicatedStorage.Events.Player:FindFirstChild("ChangePlayerMode")
                    if reviveEvent then
                        reviveEvent:FireServer(true)
                    end
                end)
                task.wait(0.5)
                return
            end
            
            hrp.CFrame = farmPlatform.CFrame + Vector3.new(0, 3, 0)
        end)
        
        WindUI:Notify({ Title = "AFK Farm", Content = "Started at height: " .. farmHeight, Duration = 2 })
    end
    
    local function StopAFKFarm()
        if farmConnections.afk then
            farmConnections.afk:Disconnect()
            farmConnections.afk = nil
        end
        if not ticketFarmActive and not cashFarmActive then
            DestroyFarmPlatform()
        end
        WindUI:Notify({ Title = "AFK Farm", Content = "Stopped", Duration = 2 })
    end
    
    -- ============================================
    -- 2. Ticket Farm (جمع التذاكر)
    -- ============================================
    local function StartTicketFarm()
        if farmConnections.ticket then return end
        
        farmConnections.ticket = RunService.RenderStepped:Connect(function()
            if not ticketFarmActive then return end
            
            local char = LP.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- إحياء إذا كان ميت
            if char:GetAttribute("Downed") then
                pcall(function()
                    local reviveEvent = ReplicatedStorage:FindFirstChild("Events") and
                                       ReplicatedStorage.Events:FindFirstChild("Player") and
                                       ReplicatedStorage.Events.Player:FindFirstChild("ChangePlayerMode")
                    if reviveEvent then
                        reviveEvent:FireServer(true)
                    end
                end)
                task.wait(0.5)
                return
            end
            
            -- البحث عن التذاكر
            local tickets = workspace:FindFirstChild("Game") and
                           workspace.Game:FindFirstChild("Effects") and
                           workspace.Game.Effects:FindFirstChild("Tickets")
            
            if tickets then
                local closestTicket = nil
                local closestDist = math.huge
                
                for _, ticket in pairs(tickets:GetChildren()) do
                    local targetPart = ticket:IsA("Model") and 
                                      (ticket:FindFirstChild("HumanoidRootPart") or ticket:FindFirstChildWhichIsA("BasePart")) or 
                                      ticket
                    if targetPart and targetPart:IsA("BasePart") then
                        local dist = (hrp.Position - targetPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestTicket = targetPart
                        end
                    end
                end
                
                if closestTicket then
                    hrp.CFrame = closestTicket.CFrame + Vector3.new(0, 5, 0)
                    task.wait(0.05)
                    return
                end
            end
            
            -- لو مفيش تذاكر، يروح للمنصة
            if farmPlatform and afkFarmActive then
                hrp.CFrame = farmPlatform.CFrame + Vector3.new(0, 3, 0)
            end
        end)
        
        WindUI:Notify({ Title = "Ticket Farm", Content = "Started collecting tickets!", Duration = 2 })
    end
    
    local function StopTicketFarm()
        if farmConnections.ticket then
            farmConnections.ticket:Disconnect()
            farmConnections.ticket = nil
        end
        WindUI:Notify({ Title = "Ticket Farm", Content = "Stopped", Duration = 2 })
    end
    
    -- ============================================
    -- 3. Cash Farm (إحياء اللاعبين الساقطين)
    -- ============================================
    local function StartCashFarm()
        if farmConnections.cash then return end
        
        farmConnections.cash = RunService.Stepped:Connect(function()
            if not cashFarmActive then return end
            
            local char = LP.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- البحث عن لاعبين ساقطين
            local gameFolder = workspace:FindFirstChild("Game")
            if not gameFolder then return end
            
            local playersFolder = gameFolder:FindFirstChild("Players")
            if not playersFolder then return end
            
            for _, playerModel in pairs(playersFolder:GetChildren()) do
                if playerModel:IsA("Model") and playerModel:GetAttribute("Downed") then
                    local playerHrp = playerModel:FindFirstChild("HumanoidRootPart")
                    if playerHrp then
                        -- التليفورت للاعب الساقط
                        hrp.CFrame = playerHrp.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.1)
                        
                        -- محاولة الإحياء
                        pcall(function()
                            local interactEvent = ReplicatedStorage:FindFirstChild("Events") and
                                                 ReplicatedStorage.Events:FindFirstChild("Character") and
                                                 ReplicatedStorage.Events.Character:FindFirstChild("Interact")
                            if interactEvent then
                                interactEvent:FireServer("Revive", true, playerModel.Name)
                            end
                        end)
                        task.wait(0.5)
                        return
                    end
                end
            end
        end)
        
        WindUI:Notify({ Title = "Cash Farm", Content = "Started reviving downed players!", Duration = 2 })
    end
    
    local function StopCashFarm()
        if farmConnections.cash then
            farmConnections.cash:Disconnect()
            farmConnections.cash = nil
        end
        WindUI:Notify({ Title = "Cash Farm", Content = "Stopped", Duration = 2 })
    end
    
    -- ============================================
    -- إنشاء القسم في Auto Farm Tab
    -- ============================================
    local FarmSystemsSection = AutoTab:Section({
        Title = "Farm Systems",
        Side = "Left",
        Collapsed = false,
    })
    
    -- ارتفاع المنصة
    FarmSystemsSection:Slider({
        Title = "AFK Platform Height",
        Desc = "Height of the AFK platform (500-3000)",
        Value = { Min = 500, Max = 3000, Default = 500 },
        Step = 50,
        Callback = function(value)
            farmHeight = value
            if farmPlatform then
                farmPlatform.Position = Vector3.new(100, farmHeight, 100)
            end
        end
    })
    
    -- AFK Farm Toggle
    FarmSystemsSection:Toggle({
        Title = "AFK Farm",
        Desc = "Stay on a safe platform away from danger",
        Value = false,
        Callback = function(state)
            afkFarmActive = state
            if state then
                StartAFKFarm()
            else
                StopAFKFarm()
            end
        end
    })
    
    -- Ticket Farm Toggle
    FarmSystemsSection:Toggle({
        Title = "Ticket Farm",
        Desc = "Automatically collect tickets from the map",
        Value = false,
        Callback = function(state)
            ticketFarmActive = state
            if state then
                StartTicketFarm()
            else
                StopTicketFarm()
            end
        end
    })
    
    -- Cash Farm Toggle
    FarmSystemsSection:Toggle({
        Title = "Cash Farm",
        Desc = "Revive downed players to earn money",
        Value = false,
        Callback = function(state)
            cashFarmActive = state
            if state then
                StartCashFarm()
            else
                StopCashFarm()
            end
        end
    })
    
    -- زر إيقاف الطوارئ
    FarmSystemsSection:Button({
        Title = "Stop All Farms",
        Desc = "Emergency stop all farming activities",
        Callback = function()
            if afkFarmActive then
                afkFarmActive = false
                StopAFKFarm()
            end
            if ticketFarmActive then
                ticketFarmActive = false
                StopTicketFarm()
            end
            if cashFarmActive then
                cashFarmActive = false
                StopCashFarm()
            end
            WindUI:Notify({ Title = "Emergency Stop", Content = "All farms stopped", Duration = 2 })
        end
    })
    
    -- ملاحظة مهمة
    FarmSystemsSection:Paragraph({
        Title = "Note",
        Content = "• AFK Farm: Teleports to a safe platform\n• Ticket Farm: Collects tickets automatically\n• Cash Farm: Revives downed players for money"
    })
    
    -- تنظيف عند إعادة الظهور
    LP.CharacterAdded:Connect(function()
        task.wait(1)
        if afkFarmActive then
            StopAFKFarm()
            StartAFKFarm()
        end
        if ticketFarmActive then
            StopTicketFarm()
            StartTicketFarm()
        end
        if cashFarmActive then
            StopCashFarm()
            StartCashFarm()
        end
    end)
    
    print("[Farm Systems] Loaded successfully!")
end)