local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/contadeep/9M0AK5CRI/refs/heads/main/Fluent.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/contadeep/9M0AK5CRI/refs/heads/main/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/contadeep/9M0AK5CRI/refs/heads/main/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")

local Window = Fluent:CreateWindow({
    Title = "Goiaba.lua Hub",
    SubTitle = "Prospecting! 💎 Menu",
    TabWidth = 100,
    Size = UDim2.fromOffset(670, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Pan", Icon = "chef-hat" }),
    Buy = Window:AddTab({ Title = "Shopping", Icon = "shopping-cart" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "navigation" }),
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

local AutoFarmSection = Tabs.Main:AddSection("🌾 ‣ Auto Farm")

local holdTime = 10
local holdingPan = false
local shaking = false
local savedPositionDC = nil
local savedPositionW = nil
local holdingPanAutoFarm = false
local holdTimeAutoFarm = 10
local shakeAutoFarmTime = 10
local shakingAutoFarm = false

Tabs.Main:AddButton({
    Title = "Save Sand Position",
    Description = "Save your position in the sand",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            savedPositionDC = hrp.CFrame
            Fluent:Notify({
                Title = "Saved Position",
                Content = "Your position has been saved.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Unable to save position.",
                Duration = 3
            })
        end
    end
})

Tabs.Main:AddButton({
    Title = "Save Water Position",
    Description = "Save your position in the water",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            savedPositionW = hrp.CFrame
            Fluent:Notify({
                Title = "Saved Position",
                Content = "Your water position has been saved.",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Unable to save position.",
                Duration = 3
            })
        end
    end
})

Tabs.Main:AddToggle("AutoHoldClickCollect", {
    Title = "Auto Farm",
    Description = "",
    Default = false,
    Callback = function(state)
        holdingPanAutoFarm = state

        if state then
            task.spawn(function()
                while holdingPanAutoFarm do
                    -- Teleporta para o local de coleta
                    if savedPositionDC and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = savedPositionDC
                        task.wait(0.2)
                    end

                    -- Segura o clique
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)

                    local startTime = tick()
                    while holdingPanAutoFarm and tick() - startTime <= holdTimeAutoFarm do
                        local character = LocalPlayer.Character
                        local tool = character and character:FindFirstChildOfClass("Tool")

                        if tool then
                            local collectScript = tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Collect")
                            if collectScript then
                                pcall(function()
                                    collectScript:InvokeServer(1)
                                end)
                            end
                        end

                        task.wait(0)
                    end

                    -- Solta o clique
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    task.wait(1.5)

                    -- Teleporta para a água
                    if savedPositionW and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = savedPositionW
                        task.wait(0.2)
                    end

                    local character = LocalPlayer.Character
                    local tool = character and character:FindFirstChildOfClass("Tool")

                    -- Inicia o pan
                    if tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Pan") then
                        pcall(function()
                            tool.Scripts.Pan:InvokeServer()
                        end)
                    end

                    -- Faz o shake
                    local shakeStart = tick()
                    while holdingPanAutoFarm and (tick() - shakeStart <= shakeAutoFarmTime) do
                        character = LocalPlayer.Character
                        tool = character and character:FindFirstChildOfClass("Tool")

                        if tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Shake") then
                            pcall(function()
                                tool.Scripts.Shake:FireServer()
                            end)
                        end

                        task.wait(0)
                    end
                end
            end)
        end
    end
})

Tabs.Main:AddSlider("HoldAutoFarmTimeSlider", {
    Title = "Hold Time (seconds)",
    Description = "How long the mouse will be held down.",
    Default = 10,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        holdTimeAutoFarm = value
    end
})

Tabs.Main:AddSlider("ShakeTimeSlider", {
    Title = "Shake Time (seconds)",
    Description = "How long to shake after collecting.",
    Default = 10,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        shakeAutoFarmTime = value
    end
})

local sellAllSection = Tabs.Main:AddSection("💰 ‣ Sell")

local sellAllStep = 10 -- valor padrão do tamanho do passo

local function getClosestMerchant()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local merchants = {
        workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("StarterTown") and workspace.NPCs.StarterTown:FindFirstChild("Merchant"),
        workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("RiverTown") and workspace.NPCs.RiverTown:FindFirstChild("Merchant"),
        workspace:FindFirstChild("NPCs") and workspace.NPCs:FindFirstChild("Cavern") and workspace.NPCs.Cavern:FindFirstChild("Merchant"),
    }

    local closest, minDist = nil, math.huge
    for _, merchant in ipairs(merchants) do
        if merchant and merchant:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - merchant.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = merchant
            end
        end
    end
    return closest
end

Tabs.Main:AddButton({
    Title = "Sell All",
    Description = "Sells all items in inventory to the nearest merchant.",
    Callback = function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Salva a posição original
        local originalCFrame = hrp.CFrame

        -- Merchant destino (mais próximo)
        local merchant = getClosestMerchant()
        if merchant and merchant:FindFirstChild("HumanoidRootPart") then
            local dest = merchant.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
            local step = sellAllStep -- usa o valor do slider
            local pos = hrp.Position
            local direction = (dest - pos).Unit
            local distance = (dest - pos).Magnitude

            -- Pequenos TPs até o destino
            while distance > step do
                pos = pos + direction * step
                hrp.CFrame = CFrame.new(pos, dest)
                task.wait(0.05)
                distance = (dest - pos).Magnitude
            end
            -- TP final
            hrp.CFrame = CFrame.new(dest)
            task.wait(0.3)
        end

        -- Executa o SellAll
        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("SellAll"):InvokeServer()

        -- Volta para a posição original em pequenos TPs
        local dest = originalCFrame.Position
        local step = sellAllStep
        local pos = hrp.Position
        local direction = (dest - pos).Unit
        local distance = (dest - pos).Magnitude

        while distance > step do
            pos = pos + direction * step
            hrp.CFrame = CFrame.new(pos, dest)
            task.wait(0.05)
            distance = (dest - pos).Magnitude
        end
        hrp.CFrame = originalCFrame
    end
})

Tabs.Main:AddSlider("SellAllStepSlider", {
    Title = "Sell All (Steps)",
    Description = "Adjust the step size (studs) for Sell All teleport.",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(value)
        sellAllStep = value
    end
})

local PanSection = Tabs.Main:AddSection("🍲 ‣ Pan")

-- Toggle para ativar o auto collect
Tabs.Main:AddToggle("AutoHoldClickCollect", {
    Title = "Fill Pan",
    Description = "Hold mouse click and collect every 1s",
    Default = false,
    Callback = function(state)
        holdingPan = state

        if state then
            task.spawn(function()
                -- Segura o clique do mouse
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)

                local startTime = tick()
                while holdingPan and tick() - startTime <= holdTime do
                    local character = game:GetService("Players").LocalPlayer.Character
                    local tool = character and character:FindFirstChildOfClass("Tool")

                    if tool then
                        local collectScript = tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Collect")
                        if collectScript then
                            pcall(function()
                                collectScript:InvokeServer(1)
                            end)
                        end
                    end

                    task.wait(0)
                end

                -- Solta o clique
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
        end
    end
})

-- Slider para escolher o tempo de segurar o clique
Tabs.Main:AddSlider("HoldTimeSlider", {
    Title = "Hold Time (seconds)",
    Description = "How long the mouse will be held down.",
    Default = 10,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        holdTime = value
    end
})

local shakeTime = 10 -- valor padrão para o tempo de shake

Tabs.Main:AddToggle("AutoShake", {
    Title = "Shake Pan",
    Description = "Auto shake the pan in the water.",
    Default = false,
    Callback = function(state)
        shaking = state

        if state then
            task.spawn(function()
                local character = game:GetService("Players").LocalPlayer.Character
                local tool = character and character:FindFirstChildOfClass("Tool")

                -- Inicia o pan (caso exista)
                if tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Pan") then
                    pcall(function()
                        tool.Scripts.Pan:InvokeServer()
                    end)
                end

                -- Loop de shake por shakeTime segundos
                local startTime = tick()
                while shaking and (tick() - startTime <= shakeTime) do
                    character = game:GetService("Players").LocalPlayer.Character
                    tool = character and character:FindFirstChildOfClass("Tool")

                    if tool and tool:FindFirstChild("Scripts") and tool.Scripts:FindFirstChild("Shake") then
                        pcall(function()
                            tool.Scripts.Shake:FireServer()
                        end)
                    end

                    task.wait(0)
                end
                shaking = false
            end)
        end
    end
})

Tabs.Main:AddSlider("ShakeTimeSlider", {
    Title = "Shake Time (seconds)",
    Description = "How long the auto shake.",
    Default = 10,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        shakeTime = value
    end
})

local PanSection = Tabs.Main:AddSection("📬 ‣ Collection")

Tabs.Main:AddButton({
    Title = "Claim All Collection",
    Description = "",
    Callback = function()
        local Valuables = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Valuables")
        local ClaimRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Info"):WaitForChild("ClaimCollectionReward")

        local count = 0
        for _, item in ipairs(Valuables:GetChildren()) do
            local ok, err = pcall(function()
                ClaimRemote:FireServer(item)
            end)
            if ok then
                count += 1
            end
        end

        Fluent:Notify({
            Title = "Rescued Collection",
            Content = "Total: " .. count,
            Duration = 3
        })
        print("[✅] Rescued Journals: " .. count)
    end
})

local BuySection = Tabs.Buy:AddSection("🛒 ‣ Shopping")

local panDisplayNames = {
    "Rusty Pan [Initial Pan, No Buy]",
    "Plastic Pan [$ 500]",
    "Metal Pan [$ 12,000]",
    "Silver Pan [$ 50,000]",
    "Golden Pan [$ 333,000]",
    "Magnetic Pan [$ 1,000,000]",
    "Meteoric Pan [$ 3,500,000]",
    "Diamond Pan [$ 10,000,000]"
}

local panNameMap = {
    ["Rusty Pan [Initial Pan, No Buy]"] = "Rusty Pan",
    ["Plastic Pan [$ 500]"] = "Plastic Pan",
    ["Metal Pan [$ 12,000]"] = "Metal Pan",
    ["Silver Pan [$ 50,000]"] = "Silver Pan",
    ["Golden Pan [$ 333,000]"] = "Golden Pan",
    ["Magnetic Pan [$ 1,000,000]"] = "Magnetic Pan",
    ["Meteoric Pan [$ 3,500,000]"] = "Meteoric Pan",
    ["Diamond Pan [$ 10,000,000]"] = "Diamond Pan"
}

Tabs.Buy:AddDropdown("BuyPanDropdown", {
    Title = "Buy Pan",
    Description = "Select a pan to buy",
    Values = panDisplayNames,
    Multi = false,
    Default = "Select Pan",
    Callback = function(selectedDisplay)
        local panName = panNameMap[selectedDisplay]
        if panName == "Rusty Pan" then
            Fluent:Notify({
                Title = "Info",
                Content = "Rusty Pan is the initial pan and cannot be bought.",
                Duration = 3
            })
            return
        end
        local panPath = workspace:FindFirstChild("Purchasable")
        local panItem
        if panPath then
            for _, area in pairs(panPath:GetChildren()) do
                panItem = area:FindFirstChild(panName)
                if panItem and panItem:FindFirstChild("ShopItem") then
                    break
                end
            end
        end
        if panItem and panItem:FindFirstChild("ShopItem") then
            local args = { panItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedDisplay,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedDisplay),
                Duration = 3
            })
        end
    end
})

-- Dropdown para comprar Shovel (igual ao Buy Pan), com nomes na ordem e display customizado
local shovelDisplayNames = {
    "Rusty Shovel [Initial Shovel, No Buy]",
    "Iron Shovel [$ 3,000]",
    "Steel Shovel [$ 25,000]",
    "Silver Shovel [$ 75,000]",
    "Reinforced Shovel [$ 135,000]",
    "The Excavator [$ 320,000]",
    "Golden Shovel [$ 1,333,000]",
    "Meteoric Shovel [$ 4,000,000]",
    "Diamond Shovel [$ 12,500,000]"
}

-- Mapeamento display name -> nome real do item
local shovelNameMap = {
    ["Rusty Shovel [Initial Shovel, No Buy]"] = "Rusty Shovel",
    ["Iron Shovel [$ 3,000]"] = "Iron Shovel",
    ["Steel Shovel [$ 25,000]"] = "Steel Shovel",
    ["Silver Shovel [$ 75,000]"] = "Silver Shovel",
    ["Reinforced Shovel [$ 135,000]"] = "Reinforced Shovel",
    ["The Excavator [$ 320,000]"] = "The Excavator",
    ["Golden Shovel [$ 1,333,000]"] = "Golden Shovel",
    ["Meteoric Shovel [$ 4,000,000]"] = "Meteoric Shovel",
    ["Diamond Shovel [$ 12,500,000]"] = "Diamond Shovel"
}

local purchasable = workspace:FindFirstChild("Purchasable")

Tabs.Buy:AddDropdown("BuyShovelDropdown", {
    Title = "Buy Shovel",
    Description = "Select a shovel to buy",
    Values = shovelDisplayNames,
    Multi = false,
    Default = "Select Shovel",
    Callback = function(selectedDisplay)
        local shovelName = shovelNameMap[selectedDisplay]
        if shovelName == "Rusty Shovel" then
            Fluent:Notify({
                Title = "Info",
                Content = "Rusty Shovel is the initial shovel and cannot be bought.",
                Duration = 3
            })
            return
        end
        local shovelItem
        if purchasable then
            for _, area in pairs(purchasable:GetChildren()) do
                shovelItem = area:FindFirstChild(shovelName)
                if shovelItem and shovelItem:FindFirstChild("ShopItem") then
                    break
                end
            end
        end
        if shovelItem and shovelItem:FindFirstChild("ShopItem") then
            local args = { shovelItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedDisplay,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedDisplay),
                Duration = 3
            })
        end
    end
})

-- Dropdown para comprar Sluice Box, com nomes na ordem e display customizado
local sluiceDisplayNames = {
    "Wood Sluice Box [$ 5,000]",
    "Steel Sluice Box [$100,000]",
    "Gold Sluice Box [$ 655,000]",
    "Obsidian Sluice Box [$ 4,000,000]",
    "Enchanted Sluice Box [$ 12,000,000]"
}

local sluiceNameMap = {
    ["Wood Sluice Box [$ 5,000]"] = "Wood Sluice Box",
    ["Steel Sluice Box [$100,000]"] = "Steel Sluice Box",
    ["Gold Sluice Box [$ 655,000]"] = "Gold Sluice Box",
    ["Obsidian Sluice Box [$ 4,000,000]"] = "Obsidian Sluice Box",
    ["Enchanted Sluice Box [$ 12,000,000]"] = "Enchanted Sluice Box"
}

Tabs.Buy:AddDropdown("BuySluiceDropdown", {
    Title = "Buy Sluice Box",
    Description = "Select a sluice box to buy",
    Values = sluiceDisplayNames,
    Multi = false,
    Default = "Select Sluice Box",
    Callback = function(selectedDisplay)
        local sluiceName = sluiceNameMap[selectedDisplay]
        local sluiceItem
        local purchasable = workspace:FindFirstChild("Purchasable")
        if purchasable then
            for _, area in pairs(purchasable:GetChildren()) do
                sluiceItem = area:FindFirstChild(sluiceName)
                if sluiceItem and sluiceItem:FindFirstChild("ShopItem") then
                    break
                end
            end
        end
        if sluiceItem and sluiceItem:FindFirstChild("ShopItem") then
            local args = { sluiceItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedDisplay,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedDisplay),
                Duration = 3
            })
        end
    end
})

-- Dropdown para comprar Potion (igual ao Buy Shovel/Pan), com nomes na ordem e display customizado
local potionDisplayNames = {
    "Basic Capacity Potion [$ 40,000]",
    "Basic Luck Potion [$ 50,000]",
    "Greater Capacity Potion [20 S]",
    "Greater Luck Potion [30 S]",
    "Merchant's Potion [200 S]"
}

-- Mapeamento display name -> nome real do item
local potionNameMap = {
    ["Basic Capacity Potion [$ 40,000]"] = "Basic Capacity Potion",
    ["Basic Luck Potion [$ 50,000]"] = "Basic Luck Potion",
    ["Greater Capacity Potion [20 S]"] = "Greater Capacity Potion",
    ["Greater Luck Potion [30 S]"] = "Greater Luck Potion",
    ["Merchant's Potion [200 S]"] = "Merchant's Potion"
}

local selectedPotionName = nil

Tabs.Buy:AddDropdown("BuyPotionDropdown", {
    Title = "Buy Potion",
    Description = "Select a potion to buy",
    Values = potionDisplayNames,
    Multi = false,
    Default = "Select Potion",
    Callback = function(selectedDisplay)
        local potionName = potionNameMap[selectedDisplay]
        selectedPotionName = potionName
        local potionItem
        local purchasable = workspace:FindFirstChild("Purchasable")
        if purchasable then
            for _, area in pairs(purchasable:GetChildren()) do
                potionItem = area:FindFirstChild(potionName)
                if potionItem and potionItem:FindFirstChild("ShopItem") then
                    break
                end
            end
        end
        if potionItem and potionItem:FindFirstChild("ShopItem") then
            local args = { potionItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedDisplay,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedDisplay),
                Duration = 3
            })
        end
    end
})

Tabs.Buy:AddButton({
    Title = "Buy Potion Again",
    Description = "Buys the last selected potion again.",
    Callback = function()
        if not selectedPotionName then
            Fluent:Notify({
                Title = "Select Potion",
                Content = "You must choose a potion first.",
                Duration = 3
            })
            return
        end
        local potionItem
        local purchasable = workspace:FindFirstChild("Purchasable")
        if purchasable then
            for _, area in pairs(purchasable:GetChildren()) do
                potionItem = area:FindFirstChild(selectedPotionName)
                if potionItem and potionItem:FindFirstChild("ShopItem") then
                    break
                end
            end
        end
        if potionItem and potionItem:FindFirstChild("ShopItem") then
            local args = { potionItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedPotionName,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedPotionName),
                Duration = 3
            })
        end
    end
})

-- Dropdown para comprar Totems (Strength/Luck)
local totemDisplayNames = {
    "Strength Totem [$ 180,000]",
    "Luck Totem [$ 300,000]"
}

local totemNameMap = {
    ["Strength Totem [$ 180,000]"] = "Strength Totem",
    ["Luck Totem [$ 300,000]"] = "Luck Totem"
}

local selectedTotemName = nil

Tabs.Buy:AddDropdown("BuyTotemDropdown", {
    Title = "Buy Totem",
    Description = "Select a totem to buy",
    Values = totemDisplayNames,
    Multi = false,
    Default = "Select Totem",
    Callback = function(selectedDisplay)
        local totemName = totemNameMap[selectedDisplay]
        selectedTotemName = totemName
        local totemItem
        local purchasable = workspace:FindFirstChild("Purchasable")
        if purchasable then
            -- Strength and Luck Totems are in RiverTown
            local riverTown = purchasable:FindFirstChild("RiverTown")
            if riverTown then
                totemItem = riverTown:FindFirstChild(totemName)
            end
        end
        if totemItem and totemItem:FindFirstChild("ShopItem") then
            local args = { totemItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedDisplay,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedDisplay),
                Duration = 3
            })
        end
    end
})

Tabs.Buy:AddButton({
    Title = "Buy Totem Again",
    Description = "Buys the last selected totem again.",
    Callback = function()
        if not selectedTotemName then
            Fluent:Notify({
                Title = "Select Totem",
                Content = "You must choose a totem first.",
                Duration = 3
            })
            return
        end
        local totemItem
        local purchasable = workspace:FindFirstChild("Purchasable")
        if purchasable then
            local riverTown = purchasable:FindFirstChild("RiverTown")
            if riverTown then
                totemItem = riverTown:FindFirstChild(selectedTotemName)
            end
        end
        if totemItem and totemItem:FindFirstChild("ShopItem") then
            local args = { totemItem.ShopItem }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("BuyItem"):InvokeServer(unpack(args))
            Fluent:Notify({
                Title = "Purchase",
                Content = "Purchased: " .. selectedTotemName,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Could not find: " .. tostring(selectedTotemName),
                Duration = 3
            })
        end
    end
})


-- Dropdown para Crafting de Equipamentos
local craftOptions = {
    ["Gold Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Gold Ring"),
            {
                Gold = {
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Amethyst Pendant"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Amethyst Pendant"),
            {
                Platinum = {
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum")
                },
                Amethyst = {
                    LocalPlayer.Backpack:FindFirstChild("Amethyst"),
                    LocalPlayer.Backpack:FindFirstChild("Amethyst")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Garden Glove"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Garden Glove"),
            {
                Pyrite = {
                    LocalPlayer.Backpack:FindFirstChild("Pyrite"),
                    LocalPlayer.Backpack:FindFirstChild("Pyrite"),
                    LocalPlayer.Backpack:FindFirstChild("Pyrite"),
                    LocalPlayer.Backpack:FindFirstChild("Pyrite"),
                    LocalPlayer.Backpack:FindFirstChild("Pyrite")
                },
                Titanium = {
                    LocalPlayer.Backpack:FindFirstChild("Titanium")
                },
                Gold = {
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Titanium Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Titanium Ring"),
            {
                Titanium = {
                    LocalPlayer.Backpack:FindFirstChild("Titanium"),
                    LocalPlayer.Backpack:FindFirstChild("Titanium"),
                    LocalPlayer.Backpack:FindFirstChild("Titanium"),
                    LocalPlayer.Backpack:FindFirstChild("Titanium"),
                    LocalPlayer.Backpack:FindFirstChild("Titanium")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Smoke Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Smoke Ring"),
            {
                ["Smoky Quartz"] = {
                    LocalPlayer.Backpack:FindFirstChild("Smoky Quartz"),
                    LocalPlayer.Backpack:FindFirstChild("Smoky Quartz"),
                    LocalPlayer.Backpack:FindFirstChild("Smoky Quartz"),
                    LocalPlayer.Backpack:FindFirstChild("Smoky Quartz")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Pearl Necklace"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Pearl Necklace"),
            {
                Pearl = {
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Pearl")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Jade Armband"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Jade Armband"),
            {
                Jade = {
                    LocalPlayer.Backpack:FindFirstChild("Jade"),
                    LocalPlayer.Backpack:FindFirstChild("Jade"),
                    LocalPlayer.Backpack:FindFirstChild("Jade"),
                    LocalPlayer.Backpack:FindFirstChild("Jade")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Topaz Necklace"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Topaz Necklace"),
            {
                Titanium = {
                    LocalPlayer.Backpack:FindFirstChild("Titanium"),
                    LocalPlayer.Backpack:FindFirstChild("Titanium"),
                    LocalPlayer.Backpack:FindFirstChild("Titanium")
                },
                Topaz = {
                    LocalPlayer.Backpack:FindFirstChild("Topaz")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Ruby Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Ruby Ring"),
            {
                Platinum = {
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum"),
                    LocalPlayer.Backpack:FindFirstChild("Platinum")
                },
                Ruby = {
                    LocalPlayer.Backpack:FindFirstChild("Ruby")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Lapiz Armband"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Lapiz Armband"),
            {
                ["Lapis Lazuli"] = {
                    LocalPlayer.Backpack:FindFirstChild("Lapis Lazuli"),
                    LocalPlayer.Backpack:FindFirstChild("Lapis Lazuli")
                },
                Gold = {
                    LocalPlayer.Backpack:FindFirstChild("Gold")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Speed Coil"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Speed Coil"),
            {
                ["Meteoric Iron"] = {
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron")
                },
                Neodymium = {
                    LocalPlayer.Backpack:FindFirstChild("Neodymium"),
                    LocalPlayer.Backpack:FindFirstChild("Neodymium"),
                    LocalPlayer.Backpack:FindFirstChild("Neodymium")
                },
                Titamium = {
                    LocalPlayer.Backpack:FindFirstChild("Titamium"),
                    LocalPlayer.Backpack:FindFirstChild("Titamium"),
                    LocalPlayer.Backpack:FindFirstChild("Titamium"),
                    LocalPlayer.Backpack:FindFirstChild("Titamium"),
                    LocalPlayer.Backpack:FindFirstChild("Titamium")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Meteor Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Meteor Ring"),
            {
                ["Meteoric Iron"] = {
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Opal Amulet"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Opal Amulet"),
            {
                Opal = {
                    LocalPlayer.Backpack:FindFirstChild("Opal")
                },
                Jade = {
                    LocalPlayer.Backpack:FindFirstChild("Jade"),
                    LocalPlayer.Backpack:FindFirstChild("Jade"),
                    LocalPlayer.Backpack:FindFirstChild("Jade")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Moon Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Moon Ring"),
            {
                Moonstone = {
                    LocalPlayer.Backpack:FindFirstChild("Moonstone")
                },
                Iridium = {
                    LocalPlayer.Backpack:FindFirstChild("Iridium")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Gravity Coil"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Gravity Coil"),
            {
                Aurorite = {
                    LocalPlayer.Backpack:FindFirstChild("Aurorite")
                },
                Moonstone = {
                    LocalPlayer.Backpack:FindFirstChild("Moonstone")
                },
                Osmium = {
                    LocalPlayer.Backpack:FindFirstChild("Osmium")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Heart of the Ocean"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Heart of the Ocean"),
            {
                Coral = {
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral"),
                    LocalPlayer.Backpack:FindFirstChild("Coral")
                },
                ["Silver Clamshell"] = {
                    LocalPlayer.Backpack:FindFirstChild("Silver Clamshell"),
                    LocalPlayer.Backpack:FindFirstChild("Silver Clamshell"),
                    LocalPlayer.Backpack:FindFirstChild("Silver Clamshell"),
                    LocalPlayer.Backpack:FindFirstChild("Silver Clamshell"),
                    LocalPlayer.Backpack:FindFirstChild("Silver Clamshell")
                },
                ["Golden Pearl"] = {
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Guiding Light"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Guiding Light"),
            {
                Catseye = {
                    LocalPlayer.Backpack:FindFirstChild("Catseye")
                },
                ["Golden Pearl"] = {
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Lightkeeper's Ring"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Lightkeeper's Ring"),
            {
                Opal = {
                    LocalPlayer.Backpack:FindFirstChild("Opal"),
                    LocalPlayer.Backpack:FindFirstChild("Opal")
                },
                Luminum = {
                    LocalPlayer.Backpack:FindFirstChild("Luminum")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Mass Accumulator"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Mass Accumulator"),
            {
                Aurorite = {
                    LocalPlayer.Backpack:FindFirstChild("Aurorite")
                },
                Uranium = {
                    LocalPlayer.Backpack:FindFirstChild("Uranium")
                },
                Osmium = {
                    LocalPlayer.Backpack:FindFirstChild("Osmium"),
                    LocalPlayer.Backpack:FindFirstChild("Osmium")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Crown"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Crown"),
            {
                Ruby = {
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby")
                },
                Gold = {
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Gold")
                },
                Emerald = {
                    LocalPlayer.Backpack:FindFirstChild("Emerald"),
                    LocalPlayer.Backpack:FindFirstChild("Emerald")
                },
                Diamond = {
                    LocalPlayer.Backpack:FindFirstChild("Diamond")
                },
                Sapphire = {
                    LocalPlayer.Backpack:FindFirstChild("Sapphire"),
                    LocalPlayer.Backpack:FindFirstChild("Sapphire"),
                    LocalPlayer.Backpack:FindFirstChild("Sapphire")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Royal Federation Crown"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Royal Federation Crown"),
            {
                ["Rose Gold"] = {
                    LocalPlayer.Backpack:FindFirstChild("Rose Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Rose Gold"),
                    LocalPlayer.Backpack:FindFirstChild("Rose Gold")
                },
                ["Golden Pearl"] = {
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl"),
                    LocalPlayer.Backpack:FindFirstChild("Golden Pearl")
                },
                ["Pink Diamond"] = {
                    LocalPlayer.Backpack:FindFirstChild("Pink Diamond")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Phoenix Heart"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Phoenix Heart"),
            {
                Uranium = {
                    LocalPlayer.Backpack:FindFirstChild("Uranium"),
                    LocalPlayer.Backpack:FindFirstChild("Uranium"),
                    LocalPlayer.Backpack:FindFirstChild("Uranium")
                },
                Inferlume = {
                    LocalPlayer.Backpack:FindFirstChild("Inferlume")
                },
                Starshine = {
                    LocalPlayer.Backpack:FindFirstChild("Starshine"),
                    LocalPlayer.Backpack:FindFirstChild("Starshine")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Celestial Rings"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Celestial Rings"),
            {
                Vortessence = {
                    LocalPlayer.Backpack:FindFirstChild("Vortessence")
                },
                ["Meteoric Iron"] = {
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron"),
                    LocalPlayer.Backpack:FindFirstChild("Meteoric Iron")
                },
                Moonstone = {
                    LocalPlayer.Backpack:FindFirstChild("Moonstone"),
                    LocalPlayer.Backpack:FindFirstChild("Moonstone"),
                    LocalPlayer.Backpack:FindFirstChild("Moonstone"),
                    LocalPlayer.Backpack:FindFirstChild("Moonstone"),
                    LocalPlayer.Backpack:FindFirstChild("Moonstone")
                },
                Catseye = {
                    LocalPlayer.Backpack:FindFirstChild("Catseye"),
                    LocalPlayer.Backpack:FindFirstChild("Catseye")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Apocalypse Bringer"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Apocalypse Bringer"),
            {
                Ashvein = {
                    LocalPlayer.Backpack:FindFirstChild("Ashvein"),
                    LocalPlayer.Backpack:FindFirstChild("Ashvein"),
                    LocalPlayer.Backpack:FindFirstChild("Ashvein"),
                    LocalPlayer.Backpack:FindFirstChild("Ashvein")
                },
                Ruby = {
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby"),
                    LocalPlayer.Backpack:FindFirstChild("Ruby")
                },
                Palladium = {
                    LocalPlayer.Backpack:FindFirstChild("Palladium"),
                    LocalPlayer.Backpack:FindFirstChild("Palladium")
                },
                Painite = {
                    LocalPlayer.Backpack:FindFirstChild("Painite")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
    ["Prismatic Star"] = function()
        local args = {
            ReplicatedStorage.Items.Equipment:WaitForChild("Prismatic Star"),
            {
                Diamond = {
                    LocalPlayer.Backpack:FindFirstChild("Diamond")
                },
                Prismara = {
                    LocalPlayer.Backpack:FindFirstChild("Prismara")
                },
                ["Pink Diamond"] = {
                    LocalPlayer.Backpack:FindFirstChild("Pink Diamond")
                },
                Borealite = {
                    LocalPlayer.Backpack:FindFirstChild("Borealite"),
                    LocalPlayer.Backpack:FindFirstChild("Borealite"),
                    LocalPlayer.Backpack:FindFirstChild("Borealite"),
                    LocalPlayer.Backpack:FindFirstChild("Borealite"),
                    LocalPlayer.Backpack:FindFirstChild("Borealite")
                },
                Luminum = {
                    LocalPlayer.Backpack:FindFirstChild("Luminum")
                },
                Starshine = {
                    LocalPlayer.Backpack:FindFirstChild("Starshine")
                }
            }
        }
        ReplicatedStorage.Remotes.Crafting.CraftEquipment:InvokeServer(unpack(args))
    end,
}

local craftNames = {
    "Gold Ring [$ 2,000]",
    "Amethyst Pendant [$ 10,000]",
    "Garden Glove [$ 10,000]",
    "Titanium Ring [$ 20,000]",
    "Smoke Ring [$ 20,000]",
    "Pearl Necklace [$ 22,000]",
    "Jade Armband [$ 50,000]",
    "Topaz Necklace [$ 60,000]",
    "Ruby Ring [$ 45,000]",
    "Lapis Armband [$ 111,000]",
    "Speed Coil [$ 120,000]",
    "Meteor Ring [$ 150,000]",
    "Opal Amulet [$ 400,000]",
    "Moon Ring [$ 500,000]",
    "Gravity Coil [$ 1,000,000]",
    "Heart of the Ocean [$ 1,000,000]",
    "Guiding Light [$ 1,500,000]",
    "Lightkeeper's Ring [$ 2,000,000]",
    "Mass Accumulator [$ 3,000,000]",
    "Crown [$ 5,000,000]",
    "Royal Federation Crown [$ 30,000,000]",
    "Phoenix Heart [$ 40,000,000]",
    "Celestial Rings [$ 50,000,000]",
    "Apocalypse Bringer [$ 50,000,000]",
    "Prismatic Star [$ 75,000,000]"
}

-- Map display names to craftOptions keys
local craftNameToKey = {
    ["Gold Ring [$ 2,000]"] = "Gold Ring",
    ["Amethyst Pendant [$ 10,000]"] = "Amethyst Pendant",
    ["Garden Glove [$ 10,000]"] = "Garden Glove",
    ["Titanium Ring [$ 20,000]"] = "Titanium Ring",
    ["Smoke Ring [$ 20,000]"] = "Smoke Ring",
    ["Pearl Necklace [$ 22,000]"] = "Pearl Necklace",
    ["Jade Armband [$ 50,000]"] = "Jade Armband",
    ["Topaz Necklace [$ 60,000]"] = "Topaz Necklace",
    ["Ruby Ring [$ 45,000]"] = "Ruby Ring",
    ["Lapis Armband [$ 111,000]"] = "Lapiz Armband",
    ["Speed Coil [$ 120,000]"] = "Speed Coil",
    ["Meteor Ring [$ 150,000]"] = "Meteor Ring",
    ["Opal Amulet [$ 400,000]"] = "Opal Amulet",
    ["Moon Ring [$ 500,000]"] = "Moon Ring",
    ["Gravity Coil [$ 1,000,000]"] = "Gravity Coil",
    ["Heart of the Ocean [$ 1,000,000]"] = "Heart of the Ocean",
    ["Guiding Light [$ 1,500,000]"] = "Guiding Light",
    ["Lightkeeper's Ring [$ 2,000,000]"] = "Lightkeeper's Ring",
    ["Mass Accumulator [$ 3,000,000]"] = "Mass Accumulator",
    ["Crown [$ 5,000,000]"] = "Crown",
    ["Royal Federation Crown [$ 30,000,000]"] = "Royal Federation Crown",
    ["Phoenix Heart [$ 40,000,000]"] = "Phoenix Heart",
    ["Celestial Rings [$ 50,000,000]"] = "Celestial Rings",
    ["Apocalypse Bringer [$ 50,000,000]"] = "Apocalypse Bringer",
    ["Prismatic Star [$ 75,000,000]"] = "Prismatic Star"
}

local selectedEquipmentKey = nil

Tabs.Buy:AddDropdown("CraftEquipmentDropdown", {
    Title = "Craft Equipment",
    Description = "Select an equipment to craft",
    Values = craftNames,
    Default = "Select Equipment",
    Multi = false,
    Callback = function(selected)
        local key = craftNameToKey[selected]
        selectedEquipmentKey = key
        local fn = key and craftOptions[key]
        if fn then
            fn()
            Fluent:Notify({
                Title = "Craft",
                Content = "You crafted: " .. selected,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Erro",
                Content = "Equipment not found.",
                Duration = 3
            })
        end
    end
})

Tabs.Buy:AddButton({
    Title = "Craft Again",
    Description = "Crafts the last selected equipment again.",
    Callback = function()
        if selectedEquipmentKey and craftOptions[selectedEquipmentKey] then
            craftOptions[selectedEquipmentKey]()
            Fluent:Notify({
                Title = "Craft",
                Content = "You crafted: " .. selectedEquipmentKey,
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "Select Equipment",
                Content = "You must choose an equipment first.",
                Duration = 3
            })
        end
    end
})

local TeleportDSection = Tabs.Teleport:AddSection("🌀 ‣ Teleport")

-- Teleport Section: Dropdown for DepositMarkers
local depositMarkers = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("DepositMarkers")
local markerNames = {}
local markerLookup = {}

if depositMarkers then
    local nameCount = {}
    for _, marker in ipairs(depositMarkers:GetChildren()) do
        local baseName = marker.Name
        nameCount[baseName] = (nameCount[baseName] or 0) + 1
        local displayName = baseName
        if nameCount[baseName] > 1 then
            displayName = baseName .. " " .. tostring(nameCount[baseName])
        end
        table.insert(markerNames, displayName)
        markerLookup[displayName] = marker
    end
end

local teleportStep = 1 -- default step size
local teleportStepDelay = 0 -- default delay in seconds
local teleportHeight = 200 -- how high to go up before moving horizontally

Tabs.Teleport:AddDropdown("DepositMarkerDropdown", {
    Title = "Teleport to Deposit Marker",
    Description = "Select a deposit marker to teleport to.",
    Values = markerNames,
    Default = "Select Marker",
    Multi = false,
    Callback = function(selected)
        local marker = markerLookup[selected]
        if marker then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local startPos = hrp.Position
            local dest = marker.Position + Vector3.new(0, 5, 0)
            local upPos = Vector3.new(startPos.X, startPos.Y + teleportHeight, startPos.Z)
            local destUp = Vector3.new(dest.X, upPos.Y, dest.Z)

            local function stepTeleport(fromPos, toPos)
                local pos = fromPos
                local dir = (toPos - pos).Unit
                local dist = (toPos - pos).Magnitude
                local lastFreeze = tick()
                while dist > teleportStep do
                    pos = pos + dir * teleportStep
                    hrp.CFrame = CFrame.new(pos)
                    task.wait(teleportStepDelay)
                    -- Congela a cada 2 segundos
                    if tick() - lastFreeze >= 0.5 then
                        hrp.Anchored = true
                        task.wait(0.5)
                        hrp.Anchored = false
                        lastFreeze = tick()
                    end
                    dist = (toPos - pos).Magnitude
                end
                hrp.CFrame = CFrame.new(toPos)
            end

            -- Step 1: Go up
            stepTeleport(startPos, upPos)
            task.wait(teleportStepDelay)

            -- Step 2: Go horizontally to above the marker
            stepTeleport(upPos, destUp)
            task.wait(teleportStepDelay)

            -- Step 3: Go down to the marker
            stepTeleport(destUp, dest)

            Fluent:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. selected,
                Duration = 2
            })
        end
    end
})

Tabs.Teleport:AddSlider("TeleportStepDelaySlider", {
    Title = "Teleport Step Delay (seconds)",
    Description = "Set the delay (seconds) between each teleport step.",
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 2,
    Callback = function(value)
        teleportStepDelay = value
    end
})

Tabs.Teleport:AddSlider("DepositMarkerStepSlider", {
    Title = "Teleport Steps",
    Description = "Adjust the step size (studs) for teleporting to deposit markers.",
    Default = 1,
    Min = 1,
    Max = 50,
    Rounding = 0,
    Callback = function(value)
        teleportStep = value
    end
})

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
    Title = "Prospecting! 💎 Menu",
    Content = "Script loaded. Press LeftControl to toggle.",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
