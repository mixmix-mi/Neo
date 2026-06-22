local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "solar:info-circle-outline",
    Collapsed = true,
    Locked = false,
})

-- ================================
-- Section 1: Script Header
-- ================================
local HeaderSection = InfoTab:Section({
    Title = "HYPER V1.0",
    Side = "Left",
    Collapsed = false,
})

HeaderSection:Paragraph({
    Title = "Premium Roblox Script",
    Content = "Advanced features | High performance | Regular updates",
})

HeaderSection:Paragraph({
    Title = "Status",
    Content = "✓ Stable Release\n✓ All features working\n✓ Optimized for all executors",
})

-- ================================
-- Section 2: Developers
-- ================================
local DevSection = InfoTab:Section({
    Title = "Development Team",
    Side = "Left",
    Collapsed = true,
})

DevSection:Paragraph({
    Title = "M4X",
    Content = "Lead Developer & Founder\nExperience: 5+ Years\nRole: Full-stack development",
})

DevSection:Paragraph({
    Title = "EVA",
    Content = "Co-Developer & Designer\nExperience: 3+ Years\nRole: UI/UX & Optimization",
})

-- ================================
-- Section 3: Discord Server
-- ================================
local DiscordSection = InfoTab:Section({
    Title = "Discord Community",
    Side = "Left",
    Collapsed = true,
})

DiscordSection:Paragraph({
    Title = "Join our Discord Server",
    Content = "• Get instant support\n• Report bugs\n• Suggest features\n• Get updates first\n• Chat with the community",
})

DiscordSection:Button({
    Title = "Copy Discord Link",
    Desc = "Click to copy invite link",
    Callback = function()
        local link = "https://discord.gg/z8Cej9Zg"
        setclipboard(link)
        WindUI:Notify({ Title = "Discord", Content = "Link copied to clipboard!", Duration = 2 })
    end,
})

-- ================================
-- Section 4: Social Media
-- ================================
local SocialSection = InfoTab:Section({
    Title = "Social Media",
    Side = "Left",
    Collapsed = true,
})

SocialSection:Paragraph({
    Title = "Connect With Us",
    Content = "Follow us for updates and news",
})

SocialSection:Button({
    Title = "Copy Discord ID",
    Desc = "M4X's Discord: m4x_mix",
    Callback = function()
        setclipboard("m4x_mix")
        WindUI:Notify({ Title = "Discord", Content = "ID copied: m4x_mix", Duration = 2 })
    end,
})

SocialSection:Button({
    Title = "Copy TikTok (M4X)",
    Desc = "@m4x__4x1",
    Callback = function()
        setclipboard("m4x__4x1")
        WindUI:Notify({ Title = "TikTok", Content = "Username copied: m4x__4x1", Duration = 2 })
    end,
})

SocialSection:Button({
    Title = "Copy TikTok (EVA)",
    Desc = "@s__4x1",
    Callback = function()
        setclipboard("s__4x1")
        WindUI:Notify({ Title = "TikTok", Content = "Username copied: s__4x1", Duration = 2 })
    end,
})

-- ================================
-- Section 5: Version & Credits
-- ================================
local VersionSection = InfoTab:Section({
    Title = "Version Info",
    Side = "Left",
    Collapsed = true,
})

VersionSection:Paragraph({
    Title = "Current Version",
    Content = "Hyper v1.0.0 (Stable)\nRelease Date: 2025\nFramework: WindUI",
})

VersionSection:Paragraph({
    Title = "Credits",
    Content = "UI Framework: WindUI\nDesign Inspiration: Ocean Deep Theme\nSpecial Thanks: All beta testers",
})

VersionSection:Button({
    Title = "Check for Updates",
    Desc = "Verify if a new version is available",
    Callback = function()
        WindUI:Notify({ Title = "Version", Content = "You're using the latest version (v1.0.0)", Duration = 3 })
    end,
})

-- ================================
-- Section 6: Support
-- ================================
local SupportSection = InfoTab:Section({
    Title = "Support & Help",
    Side = "Left",
    Collapsed = true,
})

SupportSection:Paragraph({
    Title = "How to Use",
    Content = "1. Execute the script\n2. Use the WindUI menu (press Insert)\n3. Navigate through tabs\n4. Toggle features on/off\n5. Enjoy!",
})

SupportSection:Paragraph({
    Title = "Troubleshooting",
    Content = "• If features don't work: Re-execute script\n• If GUI doesn't appear: Press Insert\n• If buttons lag: Disable unnecessary ESP features\n• For other issues: Contact Discord support",
})

SupportSection:Button({
    Title = "Get Support",
    Desc = "Join Discord for help",
    Callback = function()
        setclipboard("https://discord.gg/z8Cej9Zg")
        WindUI:Notify({ Title = "Support", Content = "Discord link copied! Join for help", Duration = 2 })
    end,
})

-- ================================
-- Section 7: Legal
-- ================================
local LegalSection = InfoTab:Section({
    Title = "Legal",
    Side = "Left",
    Collapsed = true,
})

LegalSection:Paragraph({
    Title = "Disclaimer",
    Content = "This script is for educational purposes only.\nUse at your own risk.\nWe are not responsible for any bans or account issues.",
})

LegalSection:Paragraph({
    Title = "© 2027 Hyper v1.0",
    Content = "Developed by M4X & EVA\nAll rights reserved.",
})

print("[Info Tab] Loaded successfully!")