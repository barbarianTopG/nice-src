local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Fluent:CreateWindow({
    Title = "Goiaba.lua Hub",
    SubTitle = "Dig to Earth's CORE! Menu",
    TabWidth = 100,
    Size = UDim2.fromOffset(670, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local function safeFire(eventPath, ...)
    local args = {...}
    local success, err = pcall(function()
        if eventPath then
            local event = eventPath()
            if event then
                local realArgs = {}
                for _, v in ipairs(args) do
                    table.insert(realArgs, (type(v) == "function") and v() or v)
                end
                event:FireServer(unpack(realArgs))
            else
                error("Event not found")
            end
        else
            local realArgs = {}
            for _, v in ipairs(args) do
                if type(v) == "function" then
                    table.insert(realArgs, v())
                else
                    table.insert(realArgs, v)
                end
            end
        end
    end)
    if not success then
        Fluent:Notify({ Title = "Error", Content = tostring(err), Duration = 3 })
    end
end

local function safeExecute(func)
    local success, err = pcall(func)
    if not success then
        Fluent:Notify({ Title = "Error", Content = tostring(err), Duration = 3 })
    end
end

-- local function capitalize(name)
--     return name and name:gsub("(%a)(%w*)", function(a,b) return a:upper()..b:lower() end) or ""
-- end

local function createInput(tab, id, title, description, placeholder, default, isNumeric)
    tab:AddInput(id, {
        Title = title,
        Description = description,
        Default = default,
        Placeholder = placeholder,
        Numeric = isNumeric or false,
        Callback = function() end
    })
end

local function createButton(tab, title, eventName, argsFunc)
    tab:AddButton({
        Title = title,
        Callback = function()
            safeFire(eventName, unpack(argsFunc()))
        end
    })
end

local function autoFire(tab, toggleName, desc, interval, eventName, argsFunc)
    local running = false
    tab:AddToggle(toggleName, {
        Title = toggleName,
        Description = desc,
        Default = false,
        Callback = function(state)
            running = state
            if state then
                task.spawn(function()
                    while running do
                        safeFire(eventName, unpack(argsFunc()))
                        task.wait(interval)
                    end
                end)
            end
        end
    })
end

local PetSection = Tabs.Main:AddSection("Pets")

-- Pets
createInput(Tabs.Main, "PetInput", "Pet Name", "Add a pet by name.\nExample: 'Star Cat'.\nUse the pet index to find out the names of pets.\nNormal pets only; gold and diamond only via crafting.", "Enter pet name.", "Star Cat")
createButton(Tabs.Main, "Add Pet", function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("PetCageEvent")
end, function() return {Options.PetInput.Value} end)

autoFire(Tabs.Main, "Auto Add Pet", "Add pet every 0s.", 0, function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("PetCageEvent")
end, function() return {Options.PetInput.Value} end)

autoFire(Tabs.Main, "Craft Gold Pet", "Craft gold pet every 0.5s.", 0.5, function()
    return ReplicatedStorage:WaitForChild("PetRemotes",5):FindFirstChild("GoldPetCraftEvent")
end, function() return {Options.PetInput.Value, 100} end)

autoFire(Tabs.Main, "Craft Diamond Pet", "Craft diamond pet every 0.5s.", 0.5, function()
    return ReplicatedStorage:WaitForChild("PetRemotes",5):FindFirstChild("DiamondPetCraftEvent")
end, function() return {"Gold " .. Options.PetInput.Value, 100} end)

autoFire(Tabs.Main, "Craft Void Pet", "Craft void pet every 0.5s.", 0.5, function()
    return ReplicatedStorage:WaitForChild("PetRemotes",5):FindFirstChild("VoidPetCraftEvent")
end, function() return {"Diamond " .. Options.PetInput.Value, 100} end)

Tabs.Main:AddButton({
    Title = "Delete All Pets",
    Description = "Deletes all your pets automatically.",
    Callback = function()
        local petsFolder = game:GetService("Players").LocalPlayer:FindFirstChild("Pets")

        if petsFolder then
            for _, pet in ipairs(petsFolder:GetChildren()) do
                local petName = pet.Name
                safeFire(function()
                    return ReplicatedStorage:WaitForChild("PetRemotes"):FindFirstChild("DeleteAllPets")
                end, petName)
                task.wait(0.1)
            end
            Fluent:Notify({
                Title = "Delete All Pets",
                Content = "All pets deleted successfully!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find pets folder.",
                Duration = 3
            })
        end
    end
})

local CashSection = Tabs.Main:AddSection("Cash")

-- Cash & Gems
createInput(Tabs.Main, "CashInput", "Cash Amount", "It's not working as it should.", "Enter cash amount.", "1500", true)
createButton(Tabs.Main, "Add Cash", function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("AddRewardEvent")
end, function() return {"Cash", tonumber(Options.CashInput.Value)} end)

autoFire(Tabs.Main, "Auto Cash", "Auto add cash every 0s.", 0, function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("TreasureEvent")
end, function() return {"Blackhole1"} end)

local function claimAllCodes(tab, title, callback)
    tab:AddButton({
        Title = title,
        Callback = callback
    })
end

claimAllCodes(Tabs.Main, "Claim All Codes", function()
    local codes = { "NEWBIE", "DOMINUSSS", "DIGGEM5000", "TROPHIES", "MONEYMONEYMONEY", "LUCKYWHEEL" }
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("ClaimRedeemCode")

    for _, code in ipairs(codes) do
        remote:FireServer(code)
        task.wait(0.1) -- Pequeno delay pra não bugar
    end

    Fluent:Notify({
        Title = "Claim Codes",
        Content = "All codes claimed!",
        Duration = 3
    })
end)

local GemsSection = Tabs.Main:AddSection("Gems")

createInput(Tabs.Main, "GemsInput", "Gems Amount", "It's not working as it should.", "Enter gems amount.", "1500", true)
createButton(Tabs.Main, "Add Gems", function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("AddRewardEvent")
end, function() return {"Gems", tonumber(Options.GemsInput.Value)} end)

autoFire(Tabs.Main, "Auto Gems", "Auto add gems every 0s.", 0, function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("TreasureEvent")
end, function() return {"Blackhole2"} end)

local TierGemsSection = Tabs.Main:AddSection("Void Cash")

autoFire(Tabs.Main, "Auto Void Cash", "Auto add void cash every 0s.", 0, function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("DigEvent")
end, function() return {"hello"} end)

-- autoFire(Tabs.Main, "Auto Tier1 Gems", "Auto add tier1 gems every 0s.", 0, function()
--     return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("TreasureEvent")
-- end, function() return {"GemTier1"} end)

createInput(Tabs.Main, "Tier2Input", "Tier2 Gems Amount", "Amount of T2 Gems to receive.\nYou automatically receive 9k t1 gems because of the\nexchange system that resets the gems.", "Enter T2 Gems amount.", "1500", true)
createButton(Tabs.Main, "Add Tier2 Gems", function()
    return ReplicatedStorage:WaitForChild("VoidWorld"):WaitForChild("Remotes"):FindFirstChild("GemsChangerEvent")
end, function()
    return {9999, tonumber(Options.Tier2Input.Value), "GetT2Gems"}
end)

createInput(Tabs.Main, "Tier3Input", "Tier3 Gems Amount", "Amount of T3 Gems to receive.\nYou automatically receive 9k t2 gems because of the\nexchange system that resets the gems.", "Enter T3 Gems amount.", "1500", true)
createButton(Tabs.Main, "Add Tier3 Gems", function()
    return ReplicatedStorage:WaitForChild("VoidWorld"):WaitForChild("Remotes"):FindFirstChild("GemsChangerEvent")
end, function()
    return {9999, tonumber(Options.Tier3Input.Value), "GetT3Gems"}
end)

createInput(Tabs.Main, "Tier4Input", "Tier4 Gems Amount", "Amount of T4 Gems to receive.\nYou automatically receive 9k t3 gems because of the\nexchange system that resets the gems.", "Enter T4 Gems amount.", "1500", true)
createButton(Tabs.Main, "Add Tier4 Gems", function()
    return ReplicatedStorage:WaitForChild("VoidWorld"):WaitForChild("Remotes"):FindFirstChild("GemsChangerEvent")
end, function()
    return {9999, tonumber(Options.Tier4Input.Value), "GetT4Gems"}
end)

local voidWorldCoords = {
    VoidWorld = Vector3.new(7, -902, 2)
}

autoFire(Tabs.Main, "Auto Shards", "Teleport every 12s to shards\nTP every 12 seconds, as the game does not accept winnings in less time.", 12, nil, function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(voidWorldCoords.VoidWorld)
    return {}
end)

local GemsSection = Tabs.Main:AddSection("Gold")

autoFire(Tabs.Main, "Auto Gold", "Auto add gold every 0s.", 0, function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("TreasureEvent")
end, function()
    local objects = {
        "GoldenRushFirstObject10",
        "GoldenRushSecondObject10",
        "GoldenRushThirdObject10",
        "GoldenRushForthObject10"
    }

    for _, obj in ipairs(objects) do
        safeFire(function()
            return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("TreasureEvent")
        end, obj)
        task.wait(0) -- Delay mínimo entre eles
    end

    return {} -- Obrigatório retornar algo pro autoFire, mas vazio
end)

local SpinsSection = Tabs.Main:AddSection("Spins")

-- Spins
createInput(Tabs.Main, "SpinInput", "Spin Amount", "It's not working as it should.", "Enter spin amount.", "10", true)
createButton(Tabs.Main, "Add Spins", function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("AddRewardEvent")
end, function() return {"Spins", tonumber(Options.SpinInput.Value)} end)

createInput(Tabs.Main, "SpinValueInput", "Spin Value", "(Each reward on the roulette has a specific number from 1 to 10.\nJust type the corresponding number to receive the reward.\nExample: 8 (you earn 10 times the money you currently have))", "Enter spin value.", "2", true)
createButton(Tabs.Main, "Spin", function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("SpinPrizeEvent")
end, function() return {tonumber(Options.SpinValueInput.Value)} end)

local WinsSection = Tabs.Main:AddSection("Wins")

-- Wins
local worlds = {"World1","World2","World3","World4","World5","World6","World7","World8","World9","World10", "World11", "World12", "World13", "World14", "World15"}
local worldCoords = {
    World1 = Vector3.new(4, -201, 3),
    World2 = Vector3.new(11, -201, -1007),
    World3 = Vector3.new(7, -200, -2006),
    World4 = Vector3.new(40, -200, -2990),
    World5 = Vector3.new(0, -201, -3975),
    World6 = Vector3.new(19, -202, -5003),
    World7 = Vector3.new(9, -201, -5991),
    World8 = Vector3.new(-1, -201, -6992),
    World9 = Vector3.new(-54, -201, -7988),
    World10 = Vector3.new(3, -350, -9011),
    World11 = Vector3.new(-0, -202, -10007),
    World12 = Vector3.new(5, -199, -11019),
    World13 = Vector3.new(-4, -199, -11997),
    World14 = Vector3.new(11, -213, -13005),
    World15 = Vector3.new(12, -201, -14013)
}

local selectedWorld = "World1"
local dropdown = Tabs.Main:AddDropdown("WorldDropdown", {
    Title = "World teleport",
    Description = "Teleport to a world.",
    Values = worlds,
    Default = "Select World",
    Multi = false
})

dropdown:OnChanged(function(value)
    selectedWorld = value
    local worldNumber = tonumber(string.match(value, "%d+"))
    if worldNumber then
        safeFire(function()
            return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("WorldTeleportEvent")
        end, worldNumber)
        task.wait(0)
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = 0
        end
    end
end)

autoFire(Tabs.Main, "Auto Teleport Wins", "Teleport every 12s to win\nTP every 12 seconds, as the game does not accept winnings in less time.", 12, nil, function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(worldCoords[selectedWorld])
    return {}
end)

autoFire(Tabs.Main, "Auto Wins", "Auto add wins every 0s.", 0, function()
    return ReplicatedStorage:WaitForChild("Remotes",5):FindFirstChild("TreasureEvent")
end, function() return {"Cup15"} end)

local PlayerSection = Tabs.Movement:AddSection("Movement")

local WalkspeedSlider = Tabs.Movement:AddSlider("Walkspeed", {
    Title = "Walkspeed",
    Description = "Adjust your player's walkspeed.",
    Default = 30,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
        end
    end
})

local JumpPowerSlider = Tabs.Movement:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your player's jump power.",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = v
        end
    end
})

local defaultGravity = workspace.Gravity
local GravitySlider = Tabs.Movement:AddSlider("Gravity", {
    Title = "Gravity",
    Description = "Adjust the game gravity.",
    Default = workspace.Gravity,
    Min = 0,
    Max = 999,
    Rounding = 0,
    Callback = function(v)
        workspace.Gravity = v
    end
})

local defaultFOV = Camera.FieldOfView
local FOVSlider = Tabs.Movement:AddSlider("FOV", {
    Title = "FOV",
    Description = "Adjust the camera's field of view.",
    Default = Camera.FieldOfView,
    Min = 20,
    Max = 120,
    Rounding = 0,
    Callback = function(v)
        Camera.FieldOfView = v
    end
})

local infJump = false
Tabs.Movement:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Description = "Enable infinite jump.",
    Default = false,
    Callback = function(v)
        infJump = v
    end
})
UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local noclip = false
Tabs.Movement:AddToggle("Noclip", {
    Title = "Noclip",
    Description = "Enable noclip (walk through walls).",
    Default = false,
    Callback = function(v)
        noclip = v
    end
})
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local fly = false
local flySpeed = 50
Tabs.Movement:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Adjust your fly speed.",
    Default = 50,
    Min = 10,
    Max = 999,
    Rounding = 0,
    Callback = function(v)
        flySpeed = v
    end
})
Tabs.Movement:AddToggle("Fly", {
    Title = "Fly",
    Description = "Enable flying mode.",
    Default = false,
    Callback = function(v)
        fly = v
    end
})
RunService.RenderStepped:Connect(function()
    if fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then direction += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then direction -= Vector3.new(0, 1, 0) end

        hrp.Velocity = direction * flySpeed
    end
end)

Tabs.Movement:AddButton({
    Title = "Reset Player",
    Description = "Reset to default values.",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            h.WalkSpeed = 16
            h.JumpPower = 50
            WalkspeedSlider:SetValue(16)
            JumpPowerSlider:SetValue(50)
            workspace.Gravity = defaultGravity
            GravitySlider:SetValue(defaultGravity)
            FOVSlider:SetValue(defaultFOV)
        end
    end
})

local function getPlayers()
    local t = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end

local TeleportSection = Tabs.Movement:AddSection("Player Teleport")

local tpDropdown = Tabs.Movement:AddDropdown("TeleportToPlayer", {
    Title = "Teleport to Player",
    Description = "Select a player to teleport to their position.",
    Values = getPlayers(),
    Default = "Select Player",
    Multi = false
})
tpDropdown:OnChanged(function(v)
    local target = Players:FindFirstChild(v)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        Fluent:Notify({
            Title = "Teleport",
            Content = "Teleported to " .. v,
            Duration = 3
        })
    else
        Fluent:Notify({
            Title = "Error",
            Content = "Player not found.",
            Duration = 3
        })
    end
end)
Tabs.Movement:AddButton({
    Title = "Refresh Player List",
    Description = "Update the teleport dropdown with current players.",
    Callback = function()
        tpDropdown:SetValues(getPlayers())
        Fluent:Notify({
            Title = "Player List.",
            Content = "Player list has been updated.",
            Duration = 2
        })
    end
})

InterfaceManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Dig to Earth's CORE! Menu",
    Content = "Script loaded. Press LeftControl to toggle.",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
