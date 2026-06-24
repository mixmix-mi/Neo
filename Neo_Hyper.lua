-- ================================
-- Chat Message - Neo Hyper
-- ================================

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



