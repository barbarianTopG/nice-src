local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Window = Fluent:CreateWindow({
    Title = "Goiaba.lua Hub",
    SubTitle = "DIG 💛",
    TabWidth = 100,
    Size = UDim2.fromOffset(670, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "shovel" }),
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

local AutoDigSection = Tabs.Main:AddSection("Dig")

-- Toggle: Auto Dig Rocks
local runningAutoDig = false
Tabs.Main:AddToggle("AutoDig", {
    Title = "Auto Dig",
    Description = "Automatically digs.\nEquip a shovel First.",
    Default = false,
    Callback = function(state)
        runningAutoDig = state
        if state then
            task.spawn(function()
                while runningAutoDig do
                    -- Clique LMB
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

                    -- -- Dig_Replicate x17
                    -- local replicateArgs = {
                    --     "Progress",
                    --     {
                    --         LocalPlayer.Character,
                    --         5.52,
                    --         "Strong",
                    --         {
                    --             Rarity = "Common",
                    --             Rock = false
                    --         }
                    --     }
                    -- }

                    -- for i = 1, 17 do
                    --     safeFire(function()
                    --         return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Dig_Replicate")
                    --     end, unpack(replicateArgs))
                    --     task.wait(0.3)
                    -- end

                    task.wait(1.5)

                    -- Dig_Finished
                    local vector = Vector3
                    local finishArgs = {
                        0,
                        {
                            {
                                Orientation = vector.zero,
                                Transparency = 1,
                                Name = "PositionPart",
                                Position = vector.new(2048.3315, 108.6206, -321.5524),
                                Color = Color3.fromRGB(163, 162, 165),
                                Material = Enum.Material.Plastic,
                                Shape = Enum.PartType.Block,
                                Size = vector.new(0.1, 0.1, 0.1)
                            },
                            {
                                Orientation = vector.new(0, 90, 90),
                                Transparency = 0,
                                Name = "CenterCylinder",
                                Position = vector.new(2048.3315, 108.5706, -321.5524),
                                Color = Color3.fromRGB(135, 114, 85),
                                Material = Enum.Material.Pebble,
                                Shape = Enum.PartType.Cylinder,
                                Size = vector.new(0.2, 6.4162, 5.5873)
                            }
                        }
                    }

                    safeFire(function()
                        return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Dig_Finished")
                    end, unpack(finishArgs))

                    --task.wait(1.5)

                    local player = game:GetService("Players").LocalPlayer
                    local backpack = player:WaitForChild("Backpack")
                    local character = player.Character or player.CharacterAdded:Wait()

                    local validShovelsFolder = ReplicatedStorage:WaitForChild("PlayerItems"):WaitForChild("Shovels")
                    local validShovelNames = {}
                    for _, shovel in ipairs(validShovelsFolder:GetChildren()) do
                        validShovelNames[shovel.Name] = true
                    end

                    -- 1. Desequipar qualquer Tool equipada
                    for _, tool in ipairs(character:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool.Parent = backpack
                        end
                    end

                    task.wait(0)

                    -- 2. Equipar a primeira Tool válida (shovel) encontrada
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and validShovelNames[tool.Name] then
                            tool.Parent = character
                            break
                        end
                    end

                    task.wait(0.5) -- tempo entre os ciclos
                end
            end)
        end
    end
})

-- Botão: Fix UI
-- Tabs.Main:AddButton({
--     Title = "Fix UI",
--     Description = "Fix the UI layout.\nWait 5 seconds after clicking.",
--     Callback = function()
--         task.spawn(function()
--             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
--             task.wait(0.05)
--             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)

--             task.wait(1.5)

--             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
--             task.wait(0.05)
--             VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
--         end)
--     end
-- })

local SellAllItemsSection = Tabs.Main:AddSection("Sell")

Tabs.Main:AddButton({
    Title = "Sell All Items",
    Description = "Sell all items in your inventory.",
    Callback = function()
        task.spawn(function()
            local args = {
            workspace:WaitForChild("World"):WaitForChild("NPCs"):WaitForChild("Rocky")
        }
        game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemotes"):WaitForChild("SellAllItems"):FireServer(unpack(args))
        end)
    end
})

local CharmsSection = Tabs.Main:AddSection("Charms")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DialogueRemotes = ReplicatedStorage:WaitForChild("DialogueRemotes")
local AttemptBuyCharm = DialogueRemotes:WaitForChild("AttemptBuyCharm")

local selectedCharm = nil

-- Nomes internos dos charms
local charmInternalNames = {
    "Controlled Glove",
    "Lucky Bell",
    "Blue Coil",
    "Rock Pounder",
    "Shoulder Bag",
    "Vision Goggles"
}

local charmDisplayToInternal = {}
local charmDisplayNames = {}

-- Referência principal
local purchaseablesFolder = workspace:WaitForChild("World"):WaitForChild("Interactive"):WaitForChild("Purchaseable")

-- Padrão: pegar ObjectText dos modelos em 'Purchaseable'
for _, model in ipairs(purchaseablesFolder:GetChildren()) do
    if model:IsA("Model") and model:FindFirstChild("PurchasePrompt") then
        local prompt = model:FindFirstChild("PurchasePrompt")
        local displayText = prompt and prompt.ObjectText
        local internalName = model.Name

        if displayText and table.find(charmInternalNames, internalName) then
            charmDisplayToInternal[displayText] = internalName
            table.insert(charmDisplayNames, displayText)
        end
    end
end

-- Exceções: charms que estão fora da pasta padrão
local exceptions = {
    ["Rock Pounder"] = workspace.World.Map["Cinder Isle"]["Fernhill Forest"]:FindFirstChild("Rock Pounder"),
    ["Shoulder Bag"] = workspace.World.Map["Cinder Isle"]["Fernhill Forest"]:FindFirstChild("Shoulder Bag")
}

for internalName, model in pairs(exceptions) do
    if model and model:FindFirstChild("PurchasePrompt") then
        local prompt = model.PurchasePrompt
        local displayText = prompt and prompt.ObjectText
        if displayText then
            charmDisplayToInternal[displayText] = internalName
            table.insert(charmDisplayNames, displayText)
        end
    end
end

-- Função de compra
local function buyCharm(charmName)
    local success, err = pcall(function()
        AttemptBuyCharm:InvokeServer(charmName)
    end)
end

-- Dropdown: mostra o nome visual (ObjectText) e envia o nome interno
Tabs.Main:AddDropdown("CharmBuyDropdown", {
    Title = "Buy Charm",
    Description = "Select and buy a charm.",
    Values = charmDisplayNames,
    Default = "Select Charm",
    Multi = false
}):OnChanged(function(displayName)
    selectedCharm = charmDisplayToInternal[displayName]
    if selectedCharm then
        buyCharm(selectedCharm)
    end
end)


-- Botão para repetir a compra
Tabs.Main:AddButton({
    Title = "Buy Again",
    Description = "Buys the last selected charm again.",
    Callback = function()
        if selectedCharm then
            buyCharm(selectedCharm)
        else
            Fluent:Notify({
                Title = "Select a Charm",
                Content = "You must choose a charm first.",
                Duration = 3
            })
        end
    end
})

local QuestsSection = Tabs.Main:AddSection("Quests")

local runningPenguinQuest = false
Tabs.Main:AddToggle("AutoPenguinPizzaQuest", {
    Title = "Auto Pizza Delivery Quest",
    Description = "New quests every 1 minute.",
    Default = false,
    Callback = function(state)
        runningPenguinQuest = state
        if state then
            task.spawn(function()
                while runningPenguinQuest do
                    -- Start Quest
                    local args = { "Pizza Penguin" }
                    game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemotes"):WaitForChild("StartInfiniteQuest"):InvokeServer(unpack(args))
                    task.wait(1)

                    -- Teleport to Penguin and deliver pizza
                    local penguin = workspace:FindFirstChild("Active") and workspace.Active:FindFirstChild("PizzaCustomers") and workspace.Active.PizzaCustomers:FindFirstChild("Valued Customer") and workspace.Active.PizzaCustomers["Valued Customer"]:FindFirstChild("Penguin")
                    if penguin and penguin:IsA("Model") and penguin.PrimaryPart then
                        local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
                        local hrp = char:WaitForChild("HumanoidRootPart")
                        hrp.CFrame = penguin.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
                        task.wait(1)
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Quest_DeliverPizza"):InvokeServer()
                    end
                    task.wait(1)

                    -- Complete Quest
                    game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemotes"):WaitForChild("CompleteInfiniteQuest"):InvokeServer(unpack(args))

                    -- Teleport back
                    local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
                    local hrp = char:WaitForChild("HumanoidRootPart")
                    hrp.CFrame = CFrame.new(4173, 1193, -4329)

                    -- Wait 1 minute before next loop
                    task.wait(60)
                end
            end)
        end
    end
})

local Teleport1Section = Tabs.Main:AddSection("Teleport")

Tabs.Main:AddButton({
    Title = "Teleport to Enchantment Altar",
    Description = "",
    Callback = function()
        local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(4148, -669, 2551)
    end
})

local TeleportFolder = workspace:WaitForChild("Spawns"):WaitForChild("TeleportSpawns")

-- Coletar os nomes e posições das parts
local teleportNames = {}
local teleportCoords = {}

for _, part in ipairs(TeleportFolder:GetChildren()) do
    if part:IsA("BasePart") then
        table.insert(teleportNames, part.Name)
        teleportCoords[part.Name] = part.Position
    end
end

-- Criar o dropdown
local dropdown = Tabs.Main:AddDropdown("SpawnsDropdown", {
    Title = "Teleport Spawns",
    Description = "Teleport to any available spawn location.",
    Values = teleportNames,
    Default = "Select Spawn",
    Multi = false
})

-- Teleporte ao mudar o valor
dropdown:OnChanged(function(selected)
    local pos = teleportCoords[selected]
    if pos then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
    end
end)

local purchaseablesFolder = workspace:WaitForChild("World"):WaitForChild("Interactive"):WaitForChild("Purchaseable")

local itemNamesSet = {}
local itemNames = {}
local itemPositions = {}

for _, model in ipairs(purchaseablesFolder:GetChildren()) do
	if model:IsA("Model") and model.PrimaryPart and not itemNamesSet[model.Name] then
		local prompt = model:FindFirstChild("PurchasePrompt")
		if prompt and prompt:IsA("ProximityPrompt") then
			local objectText = prompt.ObjectText
			if objectText and objectText ~= "" then
				table.insert(itemNames, objectText)
				itemPositions[objectText] = model.PrimaryPart.Position
				itemNamesSet[model.Name] = true
			end
		end
	end
end

-- Dropdown no Fluent GUI
local dropdown = Tabs.Main:AddDropdown("PurchaseableTP", {
	Title = "Teleport to Purchaseable",
	Description = "Teleport to a purchasable item.\nUse noclip in the 'Movement' tab if you get stuck.",
	Values = itemNames,
	Default = "Select Item",
	Multi = false
})

dropdown:OnChanged(function(selected)
	local pos = itemPositions[selected]
	if pos then
		local char = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		hrp.CFrame = CFrame.new(pos)
	end
end)

local bossesFolder = game:GetService("ReplicatedStorage").Resources.Gameplay.Bosses

-- workspace.Spawns.TeleportSpawns["Boss Arena (Molten Monstrosity)"]

local bossNames = {}
local bossPositions = {}

-- for _, boss in ipairs(bossesFolder:GetChildren()) do
--     if boss:IsA("Model") and boss.PrimaryPart then
--         table.insert(bossNames, boss.Name)
--         bossPositions[boss.Name] = boss.PrimaryPart.Position
--     end
-- end

local dropdown = Tabs.Main:AddDropdown("BossTP", {
    Title = "Teleport to Boss >>> COMING SOON <<<",
    Description = "Teleport to any boss model.",
    Values = bossNames,
    Default = "Select Boss",
    Multi = false
})

Tabs.Main:AddToggle("BossHit", {
    Title = "Boss Hit >>> COMING SOON <<<",
    Description = "Hit the boss with a shovel.",
    Default = false,
    Callback = function(v)
    end
})

-- workspace.World.Zones._Ambience["Giant Spider_791e8faa-440e-498b-b82f-a742f2a34f3b"]
-- workspace.World.Zones._Ambience["Candlelight Phantom_57affb02-5ab9-4e6f-99da-7c0c267ec633"]
-- workspace.World.Zones._Ambience["Candlelight Phantom_389b7294-82be-43d2-ad15-013cbbfd50ea"]
-- 4110, 226, -729

dropdown:OnChanged(function(selected)
    local pos = bossPositions[selected]
    if pos then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    end
end)

-- Dropdown: Teleport to NPCs
local npcsFolder = workspace:WaitForChild("World"):WaitForChild("NPCs")

local npcNames = {}
local npcPositions = {}

for _, npc in ipairs(npcsFolder:GetChildren()) do
    if npc:IsA("Model") and npc.PrimaryPart then
        table.insert(npcNames, npc.Name)
        npcPositions[npc.Name] = npc.PrimaryPart.Position
        itemNamesSet[npc.Name] = true -- Marca como já adicionado
    end
end

local dropdown = Tabs.Main:AddDropdown("NPCTP", {
    Title = "Teleport to NPC",
    Description = "Teleport to any NPC in the world.",
    Values = npcNames,
    Default = "Select NPC",
    Multi = false
})

dropdown:OnChanged(function(selected)
    local pos = npcPositions[selected]
    if pos then
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    end
end)

local PlayerSection = Tabs.Movement:AddSection("Movement")

local WalkspeedSlider = Tabs.Movement:AddSlider("Walkspeed", {
    Title = "Walkspeed",
    Description = "Adjust your player's walkspeed.",
    Default = 16,
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
    Title = "DIG 💛 Menu",
    Content = "Script loaded. Press LeftControl to toggle.",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
