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
    OpenButton = {
        Title = "Neo Hyper",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.75,
    }
})

-- ============================================
-- Config System - المركزي
-- ============================================
local ConfigManager = Window.ConfigManager
local mainConfig = ConfigManager:CreateConfig("Neo_Hyper_Settings")

-- ============================================
-- GitHub Module Links Configuration (Ordered)
-- ============================================
local files = {
    {name = "Home",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/H.lua"},
    {name = "Auto",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/A.lua"},
    {name = "ESP",      url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/E.lua"},
    {name = "Misc",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/M.lua"},
    {name = "VIP",      url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/V.lua"},
    {name = "Se",       url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/Sssss.lua"},
    {name = "Info",     url = "https://raw.githubusercontent.com/mixmix-mi/Neo/refs/heads/main/I.lua"}
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
-- Config Controls in Settings
-- ============================================
task.wait(1)

local SettingsTab = nil
if Window.Tabs then
    for _, tab in pairs(Window.Tabs) do
        if tab and (tab.Title == "Settings" or tab.Title == "الإعدادات") then
            SettingsTab = tab
            break
        end
    end
end

if SettingsTab then
    local ConfigSection = SettingsTab:Section({
        Title = "Config System",
        Side = "Left",
        Collapsed = false,
    })
    
    ConfigSection:Button({
        Title = "Save All Settings",
        Desc = "Save all script settings to config",
        Callback = function()
            pcall(function()
                mainConfig:Save()
                WindUI:Notify({
                    Title = "Config",
                    Content = "All settings saved!",
                    Duration = 2
                })
            end)
        end
    })
    
    ConfigSection:Button({
        Title = "Load All Settings",
        Desc = "Load all settings from config",
        Callback = function()
            pcall(function()
                mainConfig:Load()
                WindUI:Notify({
                    Title = "Config",
                    Content = "All settings loaded!",
                    Duration = 2
                })
            end)
        end
    })
    
    ConfigSection:Button({
        Title = "Delete Config",
        Desc = "Delete the config file",
        Callback = function()
            WindUI:Popup({
                Title = "Delete Config",
                Icon = "trash",
                Content = "Are you sure you want to delete all settings?",
                Buttons = {
                    {
                        Title = "Cancel",
                        Callback = function() end,
                        Variant = "Tertiary",
                    },
                    {
                        Title = "Delete",
                        Icon = "trash",
                        Callback = function()
                            pcall(function()
                                mainConfig:Delete()
                                WindUI:Notify({
                                    Title = "Config",
                                    Content = "Config deleted!",
                                    Duration = 2
                                })
                            end)
                        end,
                        Variant = "Primary",
                    }
                }
            })
        end
    })
end

pcall(function()
    mainConfig:Load()
    print("[Config] Settings loaded automatically!")
end)

print("[Config] System loaded successfully!")

task.spawn(function()
    task.wait(1)
    WindUI:SetTheme("Default")
    task.wait()
    WindUI:SetTheme("Blood Moon")
end)
