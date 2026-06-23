local Tabs = {
    Misc = Window:Tab({ Title = "Misc", Icon = "solar:box-minimalistic-outline", Locked = false })
}

if not Tabs.Misc then
    Tabs.Misc = Window:Tab({ Title = "Misc", Icon = "shapes", Locked = false })
end
