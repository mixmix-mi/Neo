-- ================================
-- تبويب VIP Server (مع Battlepass Modifications)
-- ================================

-- تعريف الخدمات
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================================
-- البحث عن تبويب VIP أو إنشاؤه
-- ================================
local VIPTab = nil
if Tabs and Tabs.VIP then
    VIPTab = Tabs.VIP
elseif Window and Window.Tabs then
    for _, tab in pairs(Window.Tabs) do
        if tab and (tab.Title == "VIP" or tab.Title == "VIP Server" or tab.Title == "Premium") then
            VIPTab = tab
            break
        end
    end
end

if not VIPTab then
    VIPTab = Window:Tab({
        Title = "VIP",
        Icon = "crown",
        Locked = false
    })
end

-- ================================
-- قسم VIP Tools
-- ================================
local VIPSections = VIPTab:Section({
    Title = "VIP Tools",
    Side = "Left",
    Collapsed = false,
})

-- ================================
-- 1. GrappleHook
-- ================================
VIPSections:Button({
    Title = "Grapplehook",
    Desc = "Upgrade GrappleHook with infinite range and speed",
    Callback = function()
        local success, result = pcall(function()
            local GrappleHook = require(ReplicatedStorage.Tools["GrappleHook"])

            local grappleTask = GrappleHook.Tasks[2]
            local shootMethod = grappleTask.Functions[1].Activations[1].Methods[1]

            shootMethod.Info.Speed = 10000
            shootMethod.Info.Lifetime = 10.0
            shootMethod.Info.Gravity = Vector3.new(0, 0, 0)
            shootMethod.Info.SpreadIncrease = 0
            shootMethod.Info.Cooldown = 0.1

            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MaxSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MinSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.ReductionRate = 100

            local checkMethod = grappleTask.AutomaticFunctions[1].Methods[1]
            checkMethod.Info.Cooldown = 0.1
            checkMethod.CooldownInfo.TestCooldown = 0.1

            grappleTask.ResourceInfo.Cap = 999999

            GrappleHook.Adjustments.ToolViewbob = false
            GrappleHook.Actions.LookBack.Enabled = true
            GrappleHook.Actions.ADS.Enabled = true
            GrappleHook.Actions.ADS.Zoom = 0.5

            shootMethod.GlobalPriority = 500

            return true
        end)

        if success then
            WindUI:Notify({
                Title = "GrappleHook",
                Content = "GrappleHook upgraded successfully!",
                Duration = 5
            })
        else
            WindUI:Notify({
                Title = "GrappleHook Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

-- ================================
-- 2. Breacher (Portal Gun)
-- ================================
VIPSections:Button({
    Title = "Breacher (Portal Gun)",
    Desc = "Upgrade Portal Gun with infinite range and charges",
    Callback = function()
        local success, result = pcall(function()
            local Breacher = require(ReplicatedStorage.Tools.Breacher)

            local portalTask
            for i, task in ipairs(Breacher.Tasks) do
                if task.ResourceInfo and task.ResourceInfo.Type == "Clip" then
                    portalTask = task
                    break
                end
            end

            if not portalTask then
                portalTask = Breacher.Tasks[2]
            end

            portalTask.ResourceInfo.Cap = 999999

            local blueShoot = portalTask.Functions[1].Activations[1].Methods[1]
            local yellowShoot = portalTask.Functions[2].Activations[1].Methods[1]

            blueShoot.Info.Range = 999999
            yellowShoot.Info.Range = 999999

            blueShoot.Info.SpreadIncrease = 0
            yellowShoot.Info.SpreadIncrease = 0

            portalTask.MethodReferences.Portal.Info.SpreadInfo.MaxSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.MinSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.ReductionRate = 100

            blueShoot.Info.Cooldown = 0.1
            yellowShoot.Info.Cooldown = 0.1

            blueShoot.CooldownInfo = {}
            yellowShoot.CooldownInfo = {}
            blueShoot.Requirements = {}
            yellowShoot.Requirements = {}

            Breacher.Actions.ADS.Enabled = false

            local unequipMethod = Breacher.Tasks[1].AutomaticFunctions[2].Methods[1]
            unequipMethod.CooldownInfo = {}

            if blueShoot.CooldownInfo and blueShoot.CooldownInfo.DisabledActions then
                local newDisabled = {}
                for _, action in ipairs(blueShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                blueShoot.CooldownInfo.DisabledActions = newDisabled
            end

            if yellowShoot.CooldownInfo and yellowShoot.CooldownInfo.DisabledActions then
                local newDisabled = {}
                for _, action in ipairs(yellowShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                yellowShoot.CooldownInfo.DisabledActions = newDisabled
            end

            blueShoot.GlobalPriority = 500
            yellowShoot.GlobalPriority = 500
            blueShoot.Priority = 1
            yellowShoot.Priority = 1

            blueShoot.ResourceAboveZero = false
            yellowShoot.ResourceAboveZero = false

            portalTask.Functions[1].Activations[1].CanHoldDown = true
            portalTask.Functions[2].Activations[1].CanHoldDown = true

            if not blueShoot.Info.Speed then
                blueShoot.Info.Speed = 5000
                yellowShoot.Info.Speed = 5000
            end

            local baseTask = Breacher.Tasks[1]
            baseTask.AutomaticFunctions[1].Methods[1].Info.Cooldown = 0.1
            baseTask.AutomaticFunctions[2].Methods[1].Info.Cooldown = 0.1

            Breacher.Actions.LookBack.Enabled = true

            Breacher.Adjustments.ToolViewbob = true
            Breacher.Adjustments.AnimationRootStraight = true
            Breacher.Adjustments.TurnWaist = true

            Breacher.HUD.CrosshairType = "Accurate"
            Breacher.HUD.Colored = true

            if Breacher.Actions.ADS.Zoom then
                Breacher.Actions.ADS.Zoom = nil
            end

            return true
        end)

        if success then
            WindUI:Notify({
                Title = "Breacher (Portal Gun)",
                Content = "Portal Gun upgraded!\nInfinite charges\nMaximum range\nInstant reload",
                Duration = 6
            })
        else
            WindUI:Notify({
                Title = "Breacher Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

-- ================================
-- 3. Smoke Grenade
-- ================================
VIPSections:Button({
    Title = "Smoke Grenade",
    Desc = "Upgrade Smoke Grenade with infinite uses",
    Callback = function()
        local success, result = pcall(function()
            local SmokeGrenade = require(ReplicatedStorage.Tools["SmokeGrenade"])

            SmokeGrenade.RequiresOwnedItem = false

            local throwMethod = SmokeGrenade.Tasks[1].Functions[1].Activations[1].Methods[1]

            throwMethod.ItemUseIncrement = {"SmokeGrenade", 0}

            throwMethod.Info.Cooldown = 0.1

            throwMethod.Info.ThrowVelocity = 200

            SmokeGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = true

            throwMethod.Info.SmokeDuration = 999
            throwMethod.Info.SmokeRadius = 100
            throwMethod.Info.FadeTime = 60

            local equipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[1].Methods[1]
            local unequipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[2].Methods[1]
            equipMethod.Info.Cooldown = 0.1
            unequipMethod.Info.Cooldown = 0.1

            throwMethod.GlobalPriority = 500

            throwMethod.CooldownInfo = {}

            SmokeGrenade.HUD.ShowAmount = false

            throwMethod.Info.Density = 0.9
            throwMethod.Info.Color = Color3.new(0.7, 0.7, 0.7)
            throwMethod.Info.ExplosionRadius = 20

            throwMethod.CooldownInfo.ActivatePhrase = nil

            throwMethod.Info.Cooldown = 0.05

            SmokeGrenade.KeybindInfo.UnequipKeybind = "Backspace"

            local args = { [1] = 0, [2] = 20 }
            ReplicatedStorage.Events.Character.ToolAction:FireServer(unpack(args))

            return true
        end)

        if success then
            WindUI:Notify({
                Title = "Smoke Grenade",
                Content = "Smoke Grenade upgraded!\nInfinite grenades\nInstant reload",
                Duration = 6
            })
        else
            WindUI:Notify({
                Title = "Smoke Grenade Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

-- ================================
-- 4. Stun Baton
-- ================================
VIPSections:Button({
    Title = "Stun Baton",
    Desc = "Upgrade Stun Baton with instant attacks and high damage",
    Callback = function()
        local success, result = pcall(function()
            local StunBaton = require(ReplicatedStorage.Tools.StunBaton)

            local task = StunBaton.Tasks[1]

            local meleeStart = task.Functions[1].Activations[2].Methods[1]
            meleeStart.Info.Cooldown = 0.05
            meleeStart.Info.LungeRange = 0
            meleeStart.Info.ImmortalLength = 5
            meleeStart.Info.SuccessStunLength = 5
            meleeStart.CooldownInfo = {}
            meleeStart.Requirements = {}

            local meleeStartFail = task.Functions[1].Activations[1].Methods[1]
            meleeStartFail.Info.Cooldown = 0.05
            meleeStartFail.Info.LungeRange = 0
            meleeStartFail.Info.ImmortalLength = 5
            meleeStartFail.CooldownInfo = {}

            local meleeEnd = task.AutomaticFunctions[2].Methods[1]
            meleeEnd.Info.Cooldown = 0.1
            meleeEnd.Info.Damage = 999
            meleeEnd.Info.Range = 0
            meleeEnd.CooldownInfo = {}

            local meleeEndFail = task.AutomaticFunctions[1].Methods[1]
            meleeEndFail.Info.Cooldown = 0.1
            meleeEndFail.Info.SelfDamage = 0
            meleeEndFail.Info.Range = 0
            meleeEndFail.CooldownInfo = {}

            local equip = task.AutomaticFunctions[3].Methods[1]
            local unequip = task.AutomaticFunctions[4].Methods[1]
            equip.Info.Cooldown = 0.1
            unequip.Info.Cooldown = 0.1
            unequip.CooldownInfo = {}

            StunBaton.Actions.ADS.Enabled = false
            StunBaton.Actions.LookBack.Enabled = true

            return true
        end)

        if success then
            WindUI:Notify({
                Title = "Stun Baton",
                Content = "Stun Baton upgraded!\nInstant attacks\n999 damage\nNo self damage\nLong stun",
                Duration = 6
            })
        else
            WindUI:Notify({
                Title = "Stun Baton Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

print("VIP Tools loaded successfully!")

-- ================================
-- Visuals Tab (في VIP Tab)
-- ================================

-- البحث عن تبويب VIP أو إنشاؤه


-- ================================
-- Visuals Section
-- ================================
local VisualTab = VIPTab:Section({
    Title = "Visuals",
    Side = "Left",
    Collapsed = false,
})

-- ================================
-- Headless & Korblox
-- ================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local HEADLESS_MESH_ID = "rbxassetid://1095708"
local KORBLOX_MESH_ID = "rbxassetid://101851696"
local KORBLOX_COLOR = Color3.fromRGB(50, 50, 50)

local headlessEnabled = false
local korbloxEnabled = false
local headlessMesh
local originalLegColor

-- Headless Functions
local function applyHeadless(head)
    if not head then return end
    head.Transparency = 1
    head.CanCollide = false

    local face = head:FindFirstChild("face")
    if face then face:Destroy() end

    headlessMesh = Instance.new("SpecialMesh")
    headlessMesh.MeshType = Enum.MeshType.FileMesh
    headlessMesh.MeshId = HEADLESS_MESH_ID
    headlessMesh.Scale = Vector3.new(0.001, 0.001, 0.001)
    headlessMesh.Parent = head
end

local function removeHeadless(head)
    if not head then return end
    if headlessMesh then
        headlessMesh:Destroy()
        headlessMesh = nil
    end
    head.Transparency = 0
    head.CanCollide = true
end

-- Korblox Functions
local function applyKorblox(character)
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    if not rightLeg then return end

    if not originalLegColor then
        originalLegColor = rightLeg.Color
    end

    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end

    rightLeg.Color = KORBLOX_COLOR
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KORBLOX_MESH_ID
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Parent = rightLeg
end

local function removeKorblox(character)
    local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
    if not rightLeg then return end

    for _, child in ipairs(rightLeg:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
            child:Destroy()
        end
    end

    if originalLegColor then
        rightLeg.Color = originalLegColor
        originalLegColor = nil
    end
end

-- Respawn Handler
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local head = char:FindFirstChild("Head")
    if headlessEnabled then
        applyHeadless(head)
    end
    if korbloxEnabled then
        applyKorblox(char)
    end
end)

-- Toggles
VisualTab:Toggle({
    Title = "Headless",
    Flag = "HeadlessToggle",
    Value = false,
    Callback = function(state)
        headlessEnabled = state
        local char = player.Character or player.CharacterAdded:Wait()
        local head = char:FindFirstChild("Head")
        if state then
            applyHeadless(head)
        else
            removeHeadless(head)
        end
    end
})

VisualTab:Toggle({
    Title = "Korblox",
    Flag = "KorbloxToggle",
    Value = false,
    Callback = function(state)
        korbloxEnabled = state
        local char = player.Character or player.CharacterAdded:Wait()
        if state then
            applyKorblox(char)
        else
            removeKorblox(char)
        end
    end
})

-- ================================
-- Cosmetic Swapper
-- ================================
VisualTab:Space()
VisualTab:Divider()

local cosmetic1, cosmetic2 = ""

VisualTab:Input({
    Title = "Cosmetic 1",
    Flag = "Cosmetic1Input",
    Placeholder = "Enter Current Cosmetic",
    Callback = function(v) cosmetic1 = v end
})

VisualTab:Input({
    Title = "Cosmetic 2",
    Flag = "Cosmetic2Input",
    Placeholder = "Enter Select Cosmetic",
    Callback = function(v) cosmetic2 = v end
})

VisualTab:Button({
    Title = "Apply Cosmetics",
    Callback = function()
        pcall(function()
            if cosmetic1 == "" or cosmetic2 == "" or cosmetic1 == cosmetic2 then return end

            local Cosmetics = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")

            local function normalize(str)
                return str:gsub("%s+", ""):lower()
            end

            local function levenshtein(s, t)
                local m, n = #s, #t
                local d = {}
                for i = 0, m do d[i] = {[0] = i} end
                for j = 0, n do d[0][j] = j end

                for i = 1, m do
                    for j = 1, n do
                        local cost = (s:sub(i,i) == t:sub(j,j)) and 0 or 1
                        d[i][j] = math.min(
                            d[i-1][j] + 1,
                            d[i][j-1] + 1,
                            d[i-1][j-1] + cost
                        )
                    end
                end
                return d[m][n]
            end

            local function similarity(s, t)
                local nS, nT = normalize(s), normalize(t)
                local dist = levenshtein(nS, nT)
                return 1 - dist / math.max(#nS, #nT)
            end

            local function findSimilar(name)
                local bestMatch = name
                local bestScore = 0.5
                for _, c in ipairs(Cosmetics:GetChildren()) do
                    local score = similarity(name, c.Name)
                    if score > bestScore then
                        bestScore = score
                        bestMatch = c.Name
                    end
                end
                return bestMatch
            end

            cosmetic1 = findSimilar(cosmetic1)
            cosmetic2 = findSimilar(cosmetic2)

            local a = Cosmetics:FindFirstChild(cosmetic1)
            local b = Cosmetics:FindFirstChild(cosmetic2)
            if not a or not b then return end

            local tempRoot = Instance.new("Folder", Cosmetics)
            tempRoot.Name = "__temp_swap_" .. tostring(tick()):gsub("%.", "_")

            local tempA = Instance.new("Folder", tempRoot)
            local tempB = Instance.new("Folder", tempRoot)

            for _, c in ipairs(a:GetChildren()) do c.Parent = tempA end
            for _, c in ipairs(b:GetChildren()) do c.Parent = tempB end

            for _, c in ipairs(tempA:GetChildren()) do c.Parent = b end
            for _, c in ipairs(tempB:GetChildren()) do c.Parent = a end

            tempRoot:Destroy()
        end)
    end
})

-- ================================
-- Zombie Stride Animation Randomizer
-- ================================
VisualTab:Divider()

local Items = ReplicatedStorage:FindFirstChild("Items")
local Emotes = Items and Items:FindFirstChild("Emotes")

if Emotes then
    local zombie = Emotes:FindFirstChild("ZombieStride")
    if zombie then
        local classicIDs = {
            "rbxassetid://73383479205643",
            "rbxassetid://84248734120911",
            "rbxassetid://125497596837433"
        }
        local normalIDs = {
            "rbxassetid://15221552726",
            "rbxassetid://15221548816",
            "rbxassetid://15221544236"
        }

        if zombie:FindFirstChild("EmoteModule") then
            zombie.EmoteModule:Destroy()
        end
        if zombie:FindFirstChild("EmoteModuleClassic") then
            zombie.EmoteModuleClassic:Destroy()
        end

        task.spawn(function()
            while true do
                pcall(function()
                    if zombie:FindFirstChild("Animation") then
                        zombie.Animation.AnimationId = normalIDs[math.random(1, #normalIDs)]
                    end
                    if zombie:FindFirstChild("AnimationClassic") then
                        zombie.AnimationClassic.AnimationId = classicIDs[math.random(1, #classicIDs)]
                    end
                end)
                task.wait(1)
            end
        end)

        print("[Zombie Stride] Animation randomizer started!")
    else
        warn("[Zombie Stride] ZombieStride not found in Emotes!")
    end
else
    warn("[Zombie Stride] Emotes folder not found!")
end

-- ================================
-- Emote Changer (12 Slots)
-- ================================
VisualTab:Divider()

local Events = ReplicatedStorage:WaitForChild("Events", 10)
local CharacterFolder = Events:WaitForChild("Character", 10)
local EmoteRemote = CharacterFolder:WaitForChild("Emote", 10)
local PassCharacterInfo = CharacterFolder:WaitForChild("PassCharacterInfo", 10)
local remoteSignal = PassCharacterInfo and PassCharacterInfo.OnClientEvent

local currentTag = nil
local currentEmotes = table.create(12, "")
local selectEmotes = table.create(12, "")
local emoteEnabled = table.create(12, false)
local pendingSlot = nil
local blockOriginalEmote = false

local function readTagFromFolder(f)
    if not f then return nil end
    local a = f:GetAttribute("Tag")
    if a ~= nil then return a end
    local o = f:FindFirstChild("Tag")
    if o and o:IsA("ValueBase") then return o.Value end
    return nil
end

local function onRespawn()
    currentTag = nil
    pendingSlot = nil
    task.spawn(function()
        local start = tick()
        while tick() - start < 10 do
            if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") then
                local pf = workspace.Game.Players:FindFirstChild(player.Name)
                if pf then
                    currentTag = readTagFromFolder(pf)
                    if currentTag then
                        local b = tonumber(currentTag)
                        if b and b >= 0 and b <= 255 then break else currentTag = nil end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

local function fireSelect(slot)
    if not currentTag then return end
    local b = tonumber(currentTag)
    if not b or b < 0 or b > 255 then return end
    if not selectEmotes[slot] or selectEmotes[slot] == "" then return end
    local buf = buffer.create(2)
    buffer.writeu8(buf, 0, b)
    buffer.writeu8(buf, 1, 17)
    if remoteSignal then
        firesignal(remoteSignal, buf, {selectEmotes[slot]})
    end
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and self == EmoteRemote and type(args[1]) == "string" then
        for i = 1, 12 do
            if emoteEnabled[i] and currentEmotes[i] ~= "" and args[1] == currentEmotes[i] then
                pendingSlot = i
                blockOriginalEmote = true

                task.spawn(function()
                    task.wait(0.1)
                    blockOriginalEmote = false
                    if pendingSlot == i then
                        pendingSlot = nil
                        fireSelect(i)
                    end
                end)

                if blockOriginalEmote then return nil end
            end
        end
    end

    return oldNamecall(self, ...)
end)

-- Respawn Events
if player.Character then task.spawn(onRespawn) end
player.CharacterAdded:Connect(function() task.wait(1) onRespawn() end)

if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players") then
    workspace.Game.Players.ChildAdded:Connect(function(child)
        if child.Name == player.Name then task.wait(0.5) onRespawn() end
    end)
    workspace.Game.Players.ChildRemoved:Connect(function(child)
        if child.Name == player.Name then currentTag = nil pendingSlot = nil end
    end)
end

-- Emote Slots UI
for i = 1, 12 do
    VisualTab:Input({
        Title = "Current Emote " .. i,
        Flag = "CurrentEmote" .. i,
        Placeholder = "Enter current emote name",
        Value = currentEmotes[i],
        Callback = function(v)
            local n = v:gsub("%s+", "")
            local best = nil
            for _, e in ipairs(ReplicatedStorage.Items.Emotes:GetChildren()) do
                if e.Name:lower():find(n:lower()) then best = e.Name break end
            end
            if best then currentEmotes[i] = best end
        end
    })
    VisualTab:Input({
        Title = "Select Emote " .. i,
        Flag = "SelectEmote" .. i,
        Placeholder = "Enter select emote name",
        Value = selectEmotes[i],
        Callback = function(v)
            local n = v:gsub("%s+", "")
            local best = nil
            for _, e in ipairs(ReplicatedStorage.Items.Emotes:GetChildren()) do
                if e.Name:lower():find(n:lower()) then best = e.Name break end
            end
            if best then selectEmotes[i] = best end
        end
    })
    VisualTab:Button({
        Title = "Apply Slot " .. i,
        Icon = "refresh-cw",
        Callback = function()
            emoteEnabled[i] = (currentEmotes[i] ~= "" and selectEmotes[i] ~= "")
            WindUI:Notify({ Title = "Emote Changer", Content = "Slot " .. i .. " applied!", Duration = 2 })
        end
    })
    VisualTab:Divider()
end

VisualTab:Button({
    Title = "Reset All Emotes",
    Icon = "trash-2",
    Callback = function()
        for i = 1, 12 do
            currentEmotes[i] = ""
            selectEmotes[i] = ""
            emoteEnabled[i] = false
        end
        WindUI:Notify({ Title = "Emote Changer", Content = "All emotes reset!", Duration = 2 })
    end
})
