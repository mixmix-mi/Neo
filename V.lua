-- ================================
-- تبويب VIP Server (مع Battlepass Modifications)
-- ================================

local VIPTab = Window:Tab({
    Title = "VIP ",
    Icon = "crown",
    Collapsed = true,
    Locked = false,
})

GrappleHookToggle = MiscTab:AddButton({
    Title = "Grapplehook",
    Callback = function()
        local success, result = pcall(function()
            local GrappleHook = require(game:GetService("ReplicatedStorage").Tools["GrappleHook"])

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
            Fluent:Notify({
                Title = "GrappleHook",
                Content = "GrappleHook успешно улучшен!",
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "GrappleHook Error",
                Content = "Ошибка: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

BreacherToggle = MiscTab:AddButton({
    Title = "Breacher (Portal Gun)",
    Callback = function()
        local success, result = pcall(function()
            local Breacher = require(game:GetService("ReplicatedStorage").Tools.Breacher)

            
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
            Fluent:Notify({
                Title = "Breacher (Portal Gun)",
                Content = "Portal Gun Successfully upgraded! \n✓ Infinite charges \n✓ Maximum range \n✓ Instant reload",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Breacher Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

SmokeGrenadeToggle = MiscTab:AddButton({
    Title = "Smoke Grenade",
    Callback = function()
        local success, result = pcall(function()
            local SmokeGrenade = require(game:GetService("ReplicatedStorage").Tools["SmokeGrenade"])

            
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

            
            local args = {
                [1] = 0,
                [2] = 20
            }
            
            game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(unpack(args))
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Smoke Grenade",
                Content = "Smoke Grenade Improved! \n✓ Infinite Grenades \n✓ Instant Reload",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Smoke Grenade Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

StunBatonToggle = MiscTab:AddButton({
    Title = "Stun Baton",
    Callback = function()
        local success, result = pcall(function()
            local StunBaton = require(game:GetService("ReplicatedStorage").Tools.StunBaton)

            
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
            Fluent:Notify({
                Title = "Stun Baton",
                Content = "Stun Baton Successfully upgraded!\n✓ Instant attacks\n✓ 999 damage\n✓ No self damage\n✓ Long stun",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Stun Baton Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})
