
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local RunService = Services.RunService
local MapFolder = Services.Workspace:WaitForChild("Map"):WaitForChild("Ingame")



local ESPSettings = {
    killerESP = false,
    playerESP = false,
    generatorESP = false,
    itemESP = false,
    pizzaEsp = false,
    pizzaDeliveryEsp = false,
    zombieEsp = false,
    taphTripwireEsp = false,
    tripMineEsp = false,
    twoTimeRespawnEsp = false,
    graffitiEsp = false,
    sukkarsEsp = false,
    killerTracers = false,
    survivorTracers = false,
    generatorTracers = false,
    itemTracers = false,
    pizzaTracers = false,
    pizzaDeliveryTracers = false,
    zombieTracers = false,
    taphTripwireTracers = false,
    tripMineTracers = false,
    twoTimeRespawnTracers = false,
    killerSkinESP = false,
    survivorSkinESP = false,
    killerNameESP = true,
    killerHealthESP = true,
    survivorNameESP = true,
    survivorHealthESP = true,
    killerFillTransparency = 0.7,
    killerOutlineTransparency = 0.3,
    survivorFillTransparency = 0.7,
    survivorOutlineTransparency = 0.3,
    killerColor = Color3.fromRGB(255, 100, 100),
    survivorColor = Color3.fromRGB(100, 255, 100),
    generatorColor = Color3.fromRGB(200, 100, 200),
    itemColor = Color3.fromRGB(200, 200, 0),
    pizzaColor = Color3.fromRGB(200, 150, 0),
    pizzaDeliveryColor = Color3.fromRGB(200, 100, 100),
    zombieColor = Color3.fromRGB(200, 100, 100),
    taphTripwireColor = Color3.fromRGB(100, 0, 100),
    tripMineColor = Color3.fromRGB(255, 0, 255),
    twoTimeRespawnColor = Color3.fromRGB(0, 150, 200),
    graffitiColor = Color3.fromRGB(255, 255, 255),
    sukkarsColor = Color3.fromRGB(200, 130, 0)
}

local DummyNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot",
    "ShedletskyCORRUPT", "ChancecORRUPT", "ChanceCORRUPT", "Mafia1", "Mafia2",
    "Mafia3", "Mafia4", "Mafia5", "Mafia6", "Mafia7", "Mafia8", "Mafia9",
    "GreenGuy", "RedGuy", "BlueGuy", "PurpleGuy", "PinkGuy", "YellowGuy",
    "OrangeGuy", "GreyGuy"
}

local PlayerESPData = {}
local ObjectESPData = {}
local TracerData = {}
local Highlights = {}
local Nametags = {}

local AdvancedSettings = {
    Enabled = false, 
    OutlineOnly = true, 
    ShowNametag = false, 
    Color = Color3.fromRGB(0, 255, 255)
}

local AdvancedNames = {
    "BuildermanDispenser","BuildermanSentry","HumanoidRootProjectile",
    "Swords","shockwave","Voidstar","Shadow"
}

local ESP = {}

local function IsRagdoll(model)
    local ragdolls = Services.Workspace:FindFirstChild("Ragdolls")
    if not ragdolls then return false end
    return model:IsDescendantOf(ragdolls) or (model.Parent == ragdolls)
end

local function IsSpectating(player)
    if not player then return false end
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    local spectating = playersFolder:FindFirstChild("Spectating")
    if not spectating then return false end
    return spectating:FindFirstChild(player.Name) ~= nil
end

local function GetGeneratorPart(model)
    if not model then return nil end
    local instances = model:FindFirstChild("Instances")
    if instances then
        local generator = instances:FindFirstChild("Generator")
        if generator then
            local cube = generator:FindFirstChild("Cube.003")
            if cube and cube:IsA("BasePart") then return cube end
            for _, v in ipairs(generator:GetDescendants()) do
                if v:IsA("BasePart") then return v end
            end
        end
        for _, v in ipairs(instances:GetDescendants()) do
            if v:IsA("BasePart") and tostring(v.Name):lower():find("cube") then
                return v
            end
        end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("cube") then
            return v
        end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

local function GetModelRootPart(model)
    if not model then return nil end
    if model:IsA("BasePart") then return model end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    local primary = model.PrimaryPart
    if primary then return primary end
    for _, v in ipairs(model:GetChildren()) do
        if v:IsA("BasePart") then return v end
    end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
    return nil
end

local function UpdatePlayerBillboardText(data)
    if not data or not data.model or not data.nameLabel then return end
    
    local model = data.model
    local isKiller = data.isKiller
    
    local actorText = model:GetAttribute("ActorDisplayName") or (isKiller and "Killer" or "Survivor")
    local skinText = model:GetAttribute("SkinNameDisplay")
    
    if actorText == "Noli" and model:GetAttribute("IsFakeNoli") == true then
        actorText = actorText .. " (Fake)"
    end
    
    local displayText = actorText
    
    local showSkin = (isKiller and ESPSettings.killerSkinESP) or (not isKiller and ESPSettings.survivorSkinESP)
    if showSkin and skinText and tostring(skinText) ~= "" then
        displayText = displayText .. " | " .. skinText
    end
    
    local showName = (isKiller and ESPSettings.killerNameESP) or (not isKiller and ESPSettings.survivorNameESP)
    data.nameLabel.Text = showName and displayText or ""
    data.nameLabel.Visible = showName
    
    if data.hpLabel then
        local humanoid = model:FindFirstChild("Humanoid")
        if humanoid then
            local hp = math.floor(humanoid.Health)
            local maxhp = math.floor(humanoid.MaxHealth)
            data.hpLabel.Text = string.format("Health: %d/%d", hp, maxhp)
        end
        local showHealth = (isKiller and ESPSettings.killerHealthESP) or (not isKiller and ESPSettings.survivorHealthESP)
        data.hpLabel.Visible = showHealth
    end
    
    local highlight = model:FindFirstChild("TAOWARE_Highlight")
    if highlight then
        if isKiller then
            highlight.FillTransparency = ESPSettings.killerFillTransparency
            highlight.OutlineTransparency = ESPSettings.killerOutlineTransparency
        else
            highlight.FillTransparency = ESPSettings.survivorFillTransparency
            highlight.OutlineTransparency = ESPSettings.survivorOutlineTransparency
        end
    end
end

local function UpdateGeneratorProgress(data)
    if not data or not data.model or not data.progressLabel then return end
    
    local model = data.model
    local progress = model:FindFirstChild("Progress")
    
    if progress then
        local progressValue = math.floor(progress.Value)
        data.progressLabel.Text = string.format("Bar: %d%%", progressValue)
    end
end

local function UpdateAllPlayerESPText()
    for _, data in ipairs(PlayerESPData) do
        UpdatePlayerBillboardText(data)
    end
end

local function CreateNametag(adornee, text, color)
    if Nametags[adornee] then 
        pcall(function()
            Nametags[adornee].Parent:Destroy()
        end)
        Nametags[adornee] = nil
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 6
    textLabel.Parent = billboard
    billboard.Parent = adornee
    Nametags[adornee] = textLabel
end

local function CreateESP(model, color, isGenerator, isItem, isPizza, isPizzaDelivery, isZombie, isKiller, isTaph, isTripMine, isRespawn, isGraffiti, isSukkars)
    if not model then return end
    if model:FindFirstChild("TAOWARE_Highlight") then return end
    if isGenerator and model:FindFirstChild("Progress") and model.Progress.Value == 100 then return end
    if IsRagdoll(model) then return end

    local targetPart
    if isGenerator then
        targetPart = GetGeneratorPart(model)
    elseif isItem then
        targetPart = model:FindFirstChild("ItemRoot")
    elseif isPizza or isPizzaDelivery or isZombie or isGraffiti or isSukkars then
        targetPart = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
    elseif isTaph or isTripMine or isRespawn then
        if model:IsA("Model") then
            targetPart = GetGeneratorPart(model) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        else
            targetPart = model
        end
    else
        targetPart = model:FindFirstChild("HumanoidRootPart")
    end

    if not targetPart then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TAOWARE_Highlight"
    highlight.Adornee = model
    highlight.FillColor = color
    highlight.OutlineColor = color
    
    if isKiller then
        highlight.FillTransparency = ESPSettings.killerFillTransparency
        highlight.OutlineTransparency = ESPSettings.killerOutlineTransparency
    elseif not isGenerator and not isItem and not isPizza and not isPizzaDelivery and not isZombie and not isTaph and not isTripMine and not isRespawn and not isGraffiti and not isSukkars then
        highlight.FillTransparency = ESPSettings.survivorFillTransparency
        highlight.OutlineTransparency = ESPSettings.survivorOutlineTransparency
    else
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
    end
    
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TAOWARE_Billboard"
    billboard.Adornee = targetPart
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    if not isGenerator and not isItem and not isPizza and not isPizzaDelivery and not isZombie and not isTaph and not isTripMine and not isRespawn and not isGraffiti and not isSukkars then
        local humanoid = model:FindFirstChild("Humanoid")
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.33, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Loading..."
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 8
        nameLabel.TextStrokeTransparency = 0.6
        nameLabel.Parent = billboard

        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.33, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.3, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.Text = "Health: " .. (humanoid and string.format("%.0f", humanoid.Health) or "N/A")
        hpLabel.Font = Enum.Font.GothamBlack
        hpLabel.TextColor3 = color
        hpLabel.TextSize = 8
        hpLabel.TextStrokeTransparency = 0.6
        hpLabel.Parent = billboard

        local espData = {
            model = model, 
            nameLabel = nameLabel, 
            hpLabel = hpLabel, 
            color = color,
            isKiller = isKiller
        }
        
        table.insert(PlayerESPData, espData)
        
        UpdatePlayerBillboardText(espData)
        
        model:GetAttributeChangedSignal("ActorDisplayName"):Connect(function()
            UpdatePlayerBillboardText(espData)
        end)
        
        model:GetAttributeChangedSignal("SkinNameDisplay"):Connect(function()
            UpdatePlayerBillboardText(espData)
        end)
        
        model:GetAttributeChangedSignal("IsFakeNoli"):Connect(function()
            UpdatePlayerBillboardText(espData)
        end)
        
        if humanoid then
            humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                UpdatePlayerBillboardText(espData)
            end)
            humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
                UpdatePlayerBillboardText(espData)
            end)
        end
    elseif isGenerator then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Generator"
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextColor3 = color
        nameLabel.TextSize = 8
        nameLabel.TextStrokeTransparency = 0.6
        nameLabel.Parent = billboard
        
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Size = UDim2.new(1, 0, 0.5, 0)
        progressLabel.Position = UDim2.new(0, 0, 0.5, 0)
        progressLabel.BackgroundTransparency = 1
        progressLabel.Text = "Progress: 0%"
        progressLabel.Font = Enum.Font.GothamBlack
        progressLabel.TextColor3 = color
        progressLabel.TextSize = 8
        progressLabel.TextStrokeTransparency = 0.6
        progressLabel.Parent = billboard
        
        local espData = {
            model = model,
            nameLabel = nameLabel,
            progressLabel = progressLabel,
            highlight = highlight,
            billboard = billboard
        }
        
        table.insert(ObjectESPData, espData)
        
        UpdateGeneratorProgress(espData)
        
        local progress = model:FindFirstChild("Progress")
        if progress then
            progress:GetPropertyChangedSignal("Value"):Connect(function()
                UpdateGeneratorProgress(espData)
            end)
        end
    else
        local displayName = model.Name
        if isPizza then displayName = "pizza" end
        if isPizzaDelivery then displayName = "pizza delivery" end
        if isZombie then displayName = "zombie" end
        if isTaph then displayName = "trip wire" end
        if isTripMine then displayName = "land mine" end
        if isRespawn then displayName = "respawn point" end
        if isGraffiti then displayName = "graffiti" end
        if isSukkars then displayName = "sukkar" end
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = displayName
        textLabel.Font = Enum.Font.GothamBlack
        textLabel.TextColor3 = color
        textLabel.TextSize = 8
        textLabel.TextStrokeTransparency = 0.6
        textLabel.Parent = billboard

        table.insert(ObjectESPData, {model = model, highlight = highlight, billboard = billboard, type = displayName})
    end
end

local function RemoveESP(model)
    if not model then return end
    for i = #PlayerESPData, 1, -1 do
        if PlayerESPData[i].model == model then
            table.remove(PlayerESPData, i)
        end
    end
    for i = #ObjectESPData, 1, -1 do
        if ObjectESPData[i].model == model then
            table.remove(ObjectESPData, i)
        end
    end
    pcall(function()
        if model:FindFirstChild("TAOWARE_Highlight") then
            model.TAOWARE_Highlight:Destroy()
        end
        if model:FindFirstChild("TAOWARE_Billboard") then
            model.TAOWARE_Billboard:Destroy()
        end
    end)
end

local function CreateTracer(model, part, color)
    if not model or not part or not part:IsA("BasePart") then return end
    if TracerData[model] then return end

    local line = Drawing.new("Line")
    line.Visible = true
    line.Color = color or Color3.fromRGB(255, 255, 255)
    line.Thickness = 2
    line.Transparency = 1

    TracerData[model] = {line = line, part = part}
end

local function RemoveTracer(model)
    if TracerData[model] then
        pcall(function()
            TracerData[model].line.Visible = false
            TracerData[model].line:Remove()
        end)
        TracerData[model] = nil
    end
end

local function UpdateTracers()
    for model, data in pairs(TracerData) do
        local line = data.line
        local part = data.part
        if line and part and part.Parent then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                line.Visible = true
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = Vector2.new(pos.X, pos.Y)
            else
                line.Visible = false
            end
        else
            RemoveTracer(model)
        end
    end
end

local noliByUsername = {}
local function clearFakeTags()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            killer:SetAttribute("IsFakeNoli", false)
        end
    end
end

local function scanNolis()
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if not playersFolder then return end
    local killers = playersFolder:FindFirstChild("Killers")
    if not killers then return end
    
    noliByUsername = {}
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:GetAttribute("ActorDisplayName") == "Noli" then
            local username = killer:GetAttribute("Username")
            if username then
                if not noliByUsername[username] then
                    noliByUsername[username] = {}
                end
                table.insert(noliByUsername[username], killer)
            end
        end
    end
    for username, models in pairs(noliByUsername) do
        if #models > 1 then
            for i = 2, #models do
                models[i]:SetAttribute("IsFakeNoli", true)
            end
            models[1]:SetAttribute("IsFakeNoli", false)
        else
            models[1]:SetAttribute("IsFakeNoli", false)
        end
    end
end

local function updateFakeNolis()
    clearFakeTags()
    scanNolis()
end

local function AddHighlightAdvanced(Obj, Config)
    if Highlights[Obj] then 
        pcall(function()
            Highlights[Obj]:Destroy()
        end)
        Highlights[Obj] = nil
    end
    local hl = Instance.new("Highlight")
    hl.Adornee = Obj
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = Config.Enabled
    hl.OutlineColor = Config.Color
    hl.FillColor = Config.Color
    hl.OutlineTransparency = 0
    local alwaysFill = table.find({"BuildermanDispenser","BuildermanSentry","PizzaDeliveryRig","HumanoidRootProjectile","Swords","shockwave","Voidstar","Shadow"}, Obj.Name)
    hl.FillTransparency = Config.OutlineOnly and 1 or (alwaysFill and 0.65 or 1)
    hl.Parent = Obj
    Highlights[Obj] = hl
    Obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if Highlights[Obj] then 
                pcall(function()
                    Highlights[Obj]:Destroy()
                end)
                Highlights[Obj] = nil
            end
            if Nametags[Obj] then 
                pcall(function()
                    Nametags[Obj].Parent:Destroy()
                end)
                Nametags[Obj] = nil
            end
        end
    end)
end

local function ApplyToTargetAdvanced(target, Config)
    if not target or not target.Parent then return end
    AddHighlightAdvanced(target, Config)
end

local function HandleAdvanced(obj)
    if table.find(AdvancedNames, obj.Name) or (obj.Name == "Shadow" and obj.Parent and obj.Parent.Name == "Shadows") then
        ApplyToTargetAdvanced(obj, AdvancedSettings)
    end
end

for _, v in ipairs(MapFolder:GetDescendants()) do HandleAdvanced(v) end
MapFolder.DescendantAdded:Connect(HandleAdvanced)

task.spawn(function()
    while task.wait(0.3) do
        for obj, hl in pairs(Highlights) do
            if not hl or not hl.Parent then continue end
            hl.Enabled = AdvancedSettings.Enabled
            hl.OutlineColor = AdvancedSettings.Color
            hl.FillColor = AdvancedSettings.Color
            hl.OutlineTransparency = 0
            hl.FillTransparency = AdvancedSettings.OutlineOnly and 1 or 0.65
            if AdvancedSettings.ShowNametag then
                local baseName = obj.Name
                local nameText = baseName
                if Nametags[obj] then
                    Nametags[obj].Text = nameText
                    Nametags[obj].TextColor3 = AdvancedSettings.Color
                else
                    CreateNametag(obj, nameText, AdvancedSettings.Color)
                end
            else
                if Nametags[obj] then
                    pcall(function()
                        Nametags[obj].Parent:Destroy()
                    end)
                    Nametags[obj] = nil
                end
            end
        end
    end
end)

local function UpdateESP()
    local mapFolder = Services.Workspace:FindFirstChild("Map")
    if not mapFolder or not mapFolder:FindFirstChild("Ingame") then
        for i = #PlayerESPData, 1, -1 do
            RemoveESP(PlayerESPData[i].model)
        end
        for i = #ObjectESPData, 1, -1 do
            RemoveESP(ObjectESPData[i].model)
        end
        for model in pairs(TracerData) do
            RemoveTracer(model)
        end
        return
    end

    local ingame = mapFolder.Ingame

    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if playersFolder then
        local killers = playersFolder:FindFirstChild("Killers")
        if killers then
            for _, killer in ipairs(killers:GetChildren()) do
                if killer == LocalPlayer.Character then continue end
                if IsRagdoll(killer) then
                    RemoveESP(killer)
                    RemoveTracer(killer)
                    continue
                end
                local player = Services.Players:GetPlayerFromCharacter(killer)
                if not player or IsSpectating(player) then
                    RemoveESP(killer)
                    RemoveTracer(killer)
                    continue
                end

                if ESPSettings.killerESP and not killer:FindFirstChild("TAOWARE_Highlight") and killer:FindFirstChild("HumanoidRootPart") then
                    CreateESP(killer, ESPSettings.killerColor, false, false, false, false, false, true)
                elseif not ESPSettings.killerESP then
                    RemoveESP(killer)
                end

                if ESPSettings.killerTracers and killer:FindFirstChild("HumanoidRootPart") then
                    CreateTracer(killer, killer.HumanoidRootPart, ESPSettings.killerColor)
                else
                    RemoveTracer(killer)
                end
            end
        end

        local survivors = playersFolder:FindFirstChild("Survivors")
        if survivors then
            for _, survivor in ipairs(survivors:GetChildren()) do
                if survivor == LocalPlayer.Character then continue end
                if IsRagdoll(survivor) then
                    RemoveESP(survivor)
                    RemoveTracer(survivor)
                    continue
                end
                local player = Services.Players:GetPlayerFromCharacter(survivor)
                if not player or IsSpectating(player) then
                    RemoveESP(survivor)
                    RemoveTracer(survivor)
                    continue
                end

                if ESPSettings.playerESP and not survivor:FindFirstChild("TAOWARE_Highlight") and survivor:FindFirstChild("HumanoidRootPart") then
                    CreateESP(survivor, ESPSettings.survivorColor, false, false, false, false, false, false)
                elseif not ESPSettings.playerESP then
                    RemoveESP(survivor)
                end

                if ESPSettings.survivorTracers and survivor:FindFirstChild("HumanoidRootPart") then
                    CreateTracer(survivor, survivor.HumanoidRootPart, ESPSettings.survivorColor)
                else
                    RemoveTracer(survivor)
                end
            end
        end
    end

    if ingame:FindFirstChild("Map") then
        for _, gen in ipairs(ingame.Map:GetChildren()) do
            if gen:IsA("Model") and gen.Name:lower():find("generator") and gen.Name ~= "FakeGenerator" then
                if IsRagdoll(gen) then
                    RemoveESP(gen)
                    RemoveTracer(gen)
                    continue
                end
                local progress = gen:FindFirstChild("Progress")
                if ESPSettings.generatorESP and progress and progress.Value < 100 and not gen:FindFirstChild("TAOWARE_Highlight") then
                    CreateESP(gen, ESPSettings.generatorColor, true, false, false, false, false, false)
                elseif not ESPSettings.generatorESP or (progress and progress.Value >= 100) then
                    RemoveESP(gen)
                end

                if ESPSettings.generatorTracers and progress and progress.Value < 100 then
                    local part = GetGeneratorPart(gen)
                    if part then
                        CreateTracer(gen, part, ESPSettings.generatorColor)
                    end
                else
                    RemoveTracer(gen)
                end
            end
        end
        
        for _, item in ipairs(ingame.Map:GetDescendants()) do
            if item.Name == "ItemRoot" and item.Parent and item.Parent:IsA("Model") then
                local itemModel = item.Parent
                if ESPSettings.itemESP and not itemModel:FindFirstChild("TAOWARE_Highlight") then
                    CreateESP(itemModel, ESPSettings.itemColor, false, true, false, false, false, false)
                elseif not ESPSettings.itemESP then
                    RemoveESP(itemModel)
                end
                
                if ESPSettings.itemTracers and item:IsA("BasePart") then
                    CreateTracer(itemModel, item, ESPSettings.itemColor)
                else
                    RemoveTracer(itemModel)
                end
            end
        end
    end
    
    for _, pizza in ipairs(ingame:GetChildren()) do
        if pizza.Name == "Pizza" and pizza:IsA("BasePart") then
            if ESPSettings.pizzaEsp and not pizza:FindFirstChild("TAOWARE_Highlight") then
                CreateESP(pizza, ESPSettings.pizzaColor, false, false, true, false, false, false)
            elseif not ESPSettings.pizzaEsp then
                RemoveESP(pizza)
            end
            
            if ESPSettings.pizzaTracers then
                CreateTracer(pizza, pizza, ESPSettings.pizzaColor)
            else
                RemoveTracer(pizza)
            end
        end
    end
    
    for _, delivery in ipairs(ingame:GetChildren()) do
        if delivery:IsA("Model") and table.find(DummyNames, delivery.Name) then
            if ESPSettings.pizzaDeliveryEsp and not delivery:FindFirstChild("TAOWARE_Highlight") then
                local hrp = delivery:FindFirstChild("HumanoidRootPart")
                if hrp then
                    CreateESP(delivery, ESPSettings.pizzaDeliveryColor, false, false, false, true, false, false)
                end
            elseif not ESPSettings.pizzaDeliveryEsp then
                RemoveESP(delivery)
            end
            
            if ESPSettings.pizzaDeliveryTracers then
                local hrp = delivery:FindFirstChild("HumanoidRootPart")
                if hrp then
                    CreateTracer(delivery, hrp, ESPSettings.pizzaDeliveryColor)
                end
            else
                RemoveTracer(delivery)
            end
        end
    end
    
    for _, zombie in ipairs(ingame:GetChildren()) do
        if zombie.Name == "1x1x1x1Zombie" and zombie:IsA("Model") then
            if ESPSettings.zombieEsp and not zombie:FindFirstChild("TAOWARE_Highlight") then
                local hrp = zombie:FindFirstChild("HumanoidRootPart")
                if hrp then
                    CreateESP(zombie, ESPSettings.zombieColor, false, false, false, false, true, false)
                end
            elseif not ESPSettings.zombieEsp then
                RemoveESP(zombie)
            end
            
            if ESPSettings.zombieTracers then
                local hrp = zombie:FindFirstChild("HumanoidRootPart")
                if hrp then
                    CreateTracer(zombie, hrp, ESPSettings.zombieColor)
                end
            else
                RemoveTracer(zombie)
            end
        end
    end
    
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name:match("TaphTripwire$") and obj:IsA("Model") then
            if ESPSettings.taphTripwireEsp and not obj:FindFirstChild("TAOWARE_Highlight") then
                CreateESP(obj, ESPSettings.taphTripwireColor, false, false, false, false, false, false, true)
            elseif not ESPSettings.taphTripwireEsp then
                RemoveESP(obj)
            end
            
            if ESPSettings.taphTripwireTracers then
                local part = GetGeneratorPart(obj) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    CreateTracer(obj, part, ESPSettings.taphTripwireColor)
                end
            else
                RemoveTracer(obj)
            end
        end
    end
    
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name == "SubspaceTripmine" and obj:IsA("Model") then
            if ESPSettings.tripMineEsp and not obj:FindFirstChild("TAOWARE_Highlight") then
                CreateESP(obj, ESPSettings.tripMineColor, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.tripMineEsp then
                RemoveESP(obj)
            end
            
            if ESPSettings.tripMineTracers then
                local part = GetGeneratorPart(obj) or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    CreateTracer(obj, part, ESPSettings.tripMineColor)
                end
            else
                RemoveTracer(obj)
            end
        end
    end
    
    for _, obj in ipairs(ingame:GetDescendants()) do
        if obj and obj.Name and tostring(obj.Name):lower():find("respawnlocation") then
            local target = obj
            if obj:IsA("Model") then
                target = obj
            elseif obj:IsA("BasePart") then
                target = obj
            else
                target = obj:FindFirstAncestorOfClass("Model") or (obj:IsA("BasePart") and obj)
            end
            
            if not target or IsRagdoll(target) then continue end
            
            if ESPSettings.twoTimeRespawnEsp and not target:FindFirstChild("TAOWARE_Highlight") then
                if target:IsA("Model") then
                    CreateESP(target, ESPSettings.twoTimeRespawnColor, false, false, false, false, false, false, false, false, true)
                else
                    CreateESP(target, ESPSettings.twoTimeRespawnColor, false, false, true, false, false, false, false, false, true)
                end
            elseif not ESPSettings.twoTimeRespawnEsp then
                RemoveESP(target)
            end
            
            if ESPSettings.twoTimeRespawnTracers then
                local part = nil
                if target:IsA("Model") then
                    part = GetGeneratorPart(target) or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
                elseif target:IsA("BasePart") then
                    part = target
                end
                if part then
                    CreateTracer(target, part, ESPSettings.twoTimeRespawnColor)
                end
            else
                RemoveTracer(target)
            end
        end
    end
    
    for _, obj in ipairs(ingame:GetChildren()) do
        if obj.Name == "GraffitiCL" and obj:IsA("BasePart") then
            if ESPSettings.graffitiEsp and not obj:FindFirstChild("TAOWARE_Highlight") then
                CreateESP(obj, ESPSettings.graffitiColor, false, false, false, false, false, false, false, false, false, true)
            elseif not ESPSettings.graffitiEsp then
                RemoveESP(obj)
            end
        end
    end
    
    local currencyLocations = ingame:FindFirstChild("CurrencyLocations")
    if currencyLocations then
        for _, sukkar in ipairs(currencyLocations:GetChildren()) do
            if sukkar:IsA("Model") then
                if ESPSettings.sukkarsEsp and not sukkar:FindFirstChild("TAOWARE_Highlight") then
                    CreateESP(sukkar, ESPSettings.sukkarsColor, false, false, false, false, false, false, false, false, false, false, true)
                elseif not ESPSettings.sukkarsEsp then
                    RemoveESP(sukkar)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        UpdateESP()
        updateFakeNolis()
        task.wait(0.5)
    end
end)

RunService.RenderStepped:Connect(function()
    UpdateTracers()
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _env = getgenv and getgenv() or {}
local _hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")


local isMobile = (game:GetService("UserInputService").TouchEnabled and not game:GetService("UserInputService").KeyboardEnabled)

local repo
if isMobile then
    repo = "https://raw.githubusercontent.com/Potato5466794/obsidian_NOLSAKENV2/refs/heads/main/"
else
    repo = 'https://raw.githubusercontent.com/Potato5466794/LinoriaLib/refs/heads/main/'
end


local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true


local Window = Library:CreateWindow({
	Title = ' NOLSAKEN V2',
	Footer = 'NOL SCRIPT｜Yuxingchen｜ LovelyCat_Meow',
    Icon = "rbxassetid://4483362748",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	NotifySide = "Right",
	TabPadding = 8,
	MenuFadeTime = 0
})



local Tabs = {
    new = Window:AddTab('Info', 'person-standing'),
    Esp = Window:AddTab('ESP','eye'),
    ani = Window:AddTab('Anti','cpu'),
	Main = Window:AddTab('Misc','house'),
	Bro = Window:AddTab('Combat','biohazard'),
    Block = Window:AddTab('Block','user'),
	zdx = Window:AddTab('Generator','printer'),
	Sat = Window:AddTab('Strength','zap'),
   ["UI Settings"] = Window:AddTab('UI Setting', 'settings')
	
}



local L = Tabs.Main:AddRightGroupbox('Misc','info')

local toggle1Running = false
local toggle1Connection = nil
L:AddToggle("MyToggle1", {
    Text = "Remove Head (Headless)",
    Default = false,
    Callback = function(Value)
        if Value then
            toggle1Running = true
            toggle1Connection = game:GetService("RunService").Heartbeat:Connect(function()
                if not toggle1Running then 
                    toggle1Connection:Disconnect()
                    return 
                end
                
                local character = game.Players.LocalPlayer.Character
                if character and character:FindFirstChild("Head") then
                    character.Head.Transparency = 1
                    for _, decal in pairs(character.Head:GetChildren()) do
                        if decal:IsA("Decal") then
                            decal.Transparency = 1
                        end
                    end
                end
            end)
        else
            toggle1Running = false
            if toggle1Connection then
                toggle1Connection:Disconnect()
                toggle1Connection = nil
            end
            
            local character = game.Players.LocalPlayer.Character
            if character and character:FindFirstChild("Head") then
                character.Head.Transparency = 0
                for _, decal in pairs(character.Head:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal.Transparency = 0
                    end
                end
            end
        end
    end,
})
L:AddToggle("MyToggle2", {
    Text = "Get Korblox",
    Default = false,
    Callback = function(Value)
        if Value then
            local character = game.Players.LocalPlayer.Character
            if character then
                if character:FindFirstChild("RightLowerLeg") then
                    character.RightLowerLeg.MeshId = "902942093"
                    character.RightLowerLeg.Transparency = 1
                end
                if character:FindFirstChild("RightUpperLeg") then
                    character.RightUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096"
                    character.RightUpperLeg.TextureID = "http://roblox.com/asset/?id=902843398"
                end
                if character:FindFirstChild("RightFoot") then
                    character.RightFoot.MeshId = "902942089"
                    character.RightFoot.Transparency = 1
                end
            end
        else
            local character = game.Players.LocalPlayer.Character
            if character then
                if character:FindFirstChild("RightLowerLeg") then
                    character.RightLowerLeg.MeshId = ""
                    character.RightLowerLeg.Transparency = 0
                end
                if character:FindFirstChild("RightUpperLeg") then
                    character.RightUpperLeg.MeshId = ""
                    character.RightUpperLeg.TextureID = ""
                end
                if character:FindFirstChild("RightFoot") then
                    character.RightFoot.MeshId = ""
                    character.RightFoot.Transparency = 0
                end
            end
        end
    end,
})



local information = Tabs.new:AddRightGroupbox('Player','info')

information:AddLabel("Executor : " ..identifyexecutor())
information:AddLabel("User : " ..game.Players.LocalPlayer.Name)
information:AddLabel("User Id : "..game.Players.LocalPlayer.UserId)
information:AddLabel("Nickname : "..game.Players.LocalPlayer.DisplayName)
information:AddLabel("Account days : "..game.Players.LocalPlayer.AccountAge.." days")

local load = Tabs.new:AddRightGroupbox('Load Submenu')

load:AddButton({
	Text = "Load Submenu",
	Func = function()
	



local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Potato5466794/Wind/refs/heads/main/Wind.luau"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

getgenv().TransparencyEnabled = getgenv().TransparencyEnabled or false

local function gradient(text, startColor, endColor)
    local result, chars = "", {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        chars[#chars + 1] = uchar
    end
    
    for i = 1, #chars do
        local t = (i - 1) / math.max(#chars - 1, 1)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', 
            math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255), 
            math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255), 
            math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255), 
            chars[i])
    end
    return result
end

local themes = {"Dark", "Light", "Mocha", "Aqua"}
local currentThemeIndex = 1

local Window = WindUI:CreateWindow({
    Title = "<font color='#FFB6C1'>N</font><font color='#FFA0B5'>O</font><font color='#FF8AA9'>L</font><font color='#FF749D'> </font><font color='#FF5E91'>S</font><font color='#FF4885'>C</font><font color='#FF3279'>R</font><font color='#FF66B2'>I</font><font color='#FF7EB8'>P</font><font color='#FF96BE'>T</font><font color='#FFAEC4'></font>",
    Icon = "rbxassetid://4483362748",
    IconTransparency = 1,
    Author = "Yuxingchen",
    Folder = "Forsaken",
    Size = UDim2.fromOffset(500, 100),
    Transparent = true,
    Theme = "Dark",
    UserEnabled = true,
    SideBarWidth = 200,
    HasOutline = true,
    Background = "video:https://raw.githubusercontent.com/Potato5466794/LUAUmisc/refs/heads/main/Video_1771590934859_662.mp4",
})

WindUI.Themes.Dark.Toggle = Color3.fromHex "#FF69B4"  -- 热粉色
-- 或者
WindUI.Themes.Dark.Toggle = Color3.fromHex "#FFB6C1"  -- 浅樱花粉
-- 或者
WindUI.Themes.Dark.Toggle = Color3.fromRGB(255, 105, 180)  -- RGB格式的热粉色



Window:EditOpenButton({
    Title = "NOLSAKEN",
    CornerRadius = UDim.new(16,16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 188, 217)),    -- 浅樱花粉
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 153, 204)),  -- 中樱花粉
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255, 105, 180)),  -- 热粉红
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 192, 203))      -- 浅粉红
    }),
    Draggable = true,
})


Window:SetToggleKey(Enum.KeyCode.F, true)

local Tabs = {
    XiProInfo = Window:Tab({ Title = "Info", Icon = "info" }),
    Player = Window:Tab({ Title = "Player", Icon = "bird" }),
    Misc = Window:Tab({ Title = "Ability", Icon = "gift" }),
    Auto_Stun = Window:Tab({ Title = "Survivor", Icon = "spline-pointer" }),
        kill = Window:Tab({ Title = "Killer", Icon = "skull" }),
    Random = Window:Tab({ Title = "Aimbot", Icon = "crosshair" }),
    Anti = Window:Tab({ Title = "Anti", Icon = "cpu" }),
    Teleport = Window:Tab({ Title = "Teleport", Icon = "cable" }),
    Actions = Window:Tab({ Title = "Animation", Icon = "activity" }),
    skin = Window:Tab({ Title = "Skin", Icon = "user" }),
    SilentAim = Window:Tab({ Title = "Slient Aim", Icon = "target" })
}


Tabs.XiProInfo:Paragraph({
    Title = "Welcome NOLSAKEN",
    Desc = "DEV：Yuxingchen",
    ImageSize = 50,
    Thumbnail = "https://raw.githubusercontent.com/Potato5466794/LUAUmisc/refs/heads/main/20260224_120008319.webp",
    ThumbnailSize = 170
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local ragingPaceSavedRange = LocalPlayer:FindFirstChild("RagingPaceRange")
if not ragingPaceSavedRange then
    ragingPaceSavedRange = Instance.new("NumberValue")
    ragingPaceSavedRange.Name = "RagingPaceRange"
    ragingPaceSavedRange.Value = 19
    ragingPaceSavedRange.Parent = LocalPlayer
end

local ragingPaceSavedEnabled = LocalPlayer:FindFirstChild("RagingPaceEnabled")
if not ragingPaceSavedEnabled then
    ragingPaceSavedEnabled = Instance.new("BoolValue")
    ragingPaceSavedEnabled.Name = "RagingPaceEnabled"
    ragingPaceSavedEnabled.Value = false
    ragingPaceSavedEnabled.Parent = LocalPlayer
end

local ragingPaceRange = ragingPaceSavedRange.Value
local ragingPaceSpamDuration = 3
local ragingPaceCooldownTime = 5
local ragingPaceActiveCooldowns = {}
local ragingPaceEnabled = ragingPaceSavedEnabled.Value

local ragingPaceAnimsToDetect = {
    ["116618003477002"] = true,
    ["119462383658044"] = true,
    ["131696603025265"] = true,
    ["121255898612475"] = true,
    ["133491532453922"] = true,
    ["103601716322988"] = true,
    ["86371356500204"] = true,
    ["72722244508749"] = true,
    ["87259391926321"] = true,
    ["96959123077498"] = true,
}

local function fireRagingPace()
    game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\n\0\0\0RagingPace") })
end

local function isRagingPaceAnimationMatching(anim)
    local id = tostring(anim.Animation and anim.Animation.AnimationId or "")
    local numId = id:match("%d+")
    return ragingPaceAnimsToDetect[numId] or false
end

RunService.Heartbeat:Connect(function()
    if not ragingPaceEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local dist = (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude
                if dist <= ragingPaceRange and (not ragingPaceActiveCooldowns[player] or tick() - ragingPaceActiveCooldowns[player] >= ragingPaceCooldownTime) then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if isRagingPaceAnimationMatching(track) then
                                ragingPaceActiveCooldowns[player] = tick()
                                task.spawn(function()
                                    local startTime = tick()
                                    while tick() - startTime < ragingPaceSpamDuration do
                                        fireRagingPace()
                                        task.wait(0.05)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

Tabs.Misc:Section({Title = "Auto Raging Pace"})
Tabs.Misc:Toggle({
    Title = "Auto Raging Pace(Slasher)",
    Default = ragingPaceEnabled,
    Callback = function(state)
        ragingPaceEnabled = state
        ragingPaceSavedEnabled.Value = state
    end
})

Tabs.Misc:Slider({
    Title = "Distance Range",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = ragingPaceRange},
    Suffix = "studs",
    Callback = function(val)
        ragingPaceRange = val
        ragingPaceSavedRange.Value = val
    end
})

Tabs.Misc:Section({Title = "Auto 404 Error"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local antiAnimSavedEnabled = LocalPlayer:FindFirstChild("AntiAnimEnabled")
if not antiAnimSavedEnabled then
    antiAnimSavedEnabled = Instance.new("BoolValue")
    antiAnimSavedEnabled.Name = "AntiAnimEnabled"
    antiAnimSavedEnabled.Value = false
    antiAnimSavedEnabled.Parent = LocalPlayer
end

local antiAnimSavedRange = LocalPlayer:FindFirstChild("AntiAnimRange")
if not antiAnimSavedRange then
    antiAnimSavedRange = Instance.new("NumberValue")
    antiAnimSavedRange.Name = "AntiAnimRange"
    antiAnimSavedRange.Value = 19
    antiAnimSavedRange.Parent = LocalPlayer
end

local antiAnimRange = antiAnimSavedRange.Value
local antiAnimSpamDuration = 3
local antiAnimCooldownTime = 5
local antiAnimActiveCooldowns = {}
local antiAnimEnabled = antiAnimSavedEnabled.Value

local antiAnimAnimsToDetect = {
    ["116618003477002"] = true,
    ["119462383658044"] = true,
    ["131696603025265"] = true,
    ["121255898612475"] = true,
    ["133491532453922"] = true,
    ["103601716322988"] = true,
    ["86371356500204"] = true,
    ["72722244508749"] = false,
    ["87259391926321"] = true,
    ["96959123077498"] = false,
    ["86709774283672"] = true,
    ["77448521277146"] = true,
}

local function fire404Error()
    game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\8\0\0\0404Error") })
end

local function isAntiAnimAnimationMatching(anim)
    local id = tostring(anim.Animation and anim.Animation.AnimationId or "")
    local numId = id:match("%d+")
    return antiAnimAnimsToDetect[numId] or false
end

RunService.Heartbeat:Connect(function()
    if not antiAnimEnabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = player.Character.HumanoidRootPart
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local dist = (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude
                if dist <= antiAnimRange and (not antiAnimActiveCooldowns[player] or tick() - antiAnimActiveCooldowns[player] >= antiAnimCooldownTime) then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if isAntiAnimAnimationMatching(track) then
                                antiAnimActiveCooldowns[player] = tick()
                                task.spawn(function()
                                    local startTime = tick()
                                    while tick() - startTime < antiAnimSpamDuration do
                                        fire404Error()
                                        task.wait(0.05)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

Tabs.Misc:Toggle({
    Title = "Auto 404 Error",
    Default = antiAnimEnabled,
    Callback = function(state)
        antiAnimEnabled = state
        antiAnimSavedEnabled.Value = state
    end
})

Tabs.Misc:Slider({
    Title = "Studs",
    Step = 1,
    Value = {Min = 1, Max = 50, Default = antiAnimRange},
    Suffix = "studs",
    Callback = function(val)
        antiAnimRange = val
        antiAnimSavedRange.Value = val
    end
})



local plr = game:GetService("Players").LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")

local evt = rs.Modules.Network.RemoteEvent

local function isk()
    local nos = ws.Players.Killers:FindFirstChild("Nosferatu")
    if nos then
        local un = nos:GetAttribute("Username")
        if un == plr.Name then
            return true
        end
    end
    return false
end

local function han(ani)
    return ani.Animation.AnimationId:match("(%d+)$")
end

-- 添加控制变量
local autoQTEEnabled = false
local qteLoop = nil

local function startQTELoop()
    if qteLoop then return end
    
    qteLoop = task.spawn(function()
        while autoQTEEnabled do
            task.wait(0.1)
            if isk() then
                local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
                if hum then
                    local ani = hum:GetPlayingAnimationTracks()
                    
                    for _, a in pairs(ani) do
                        local aid = han(a)
                        
                        if aid == "113403615979705" then
                            evt:FireServer(
                                plr.Name .. "NosHookQTE",
                                {buffer.fromstring("\x01\x01")}
                            )
                        end
                    end
                end
            end
        end
    end)
end

local function stopQTELoop()
    if qteLoop then
        task.cancel(qteLoop)
        qteLoop = nil
    end
end



Tabs.Misc:Section({Title = "Nosferatu pull"})


Tabs.Misc:Toggle({
    Title = "Auto QTE",
    Desc = "AUTO",
    Value = false,
    Callback = function(state)
        autoQTEEnabled = state
        if state then
            startQTELoop()
        else
            stopQTELoop()
        end
    end
})

local chanceAim = {
    active = false,
    duration = 1.7,
    prediction = 4,
    targets = {"Slasher", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli", "Sixer", "Nosferatu"},
    animations = {["103601716322988"] = true, ["133491532453922"] = true, ["86371356500204"] = true, ["76649505662612"] = true, ["81698196845041"] = true},
    humanoid = nil,
    hrp = nil,
    lastTrigger = 0,
    aiming = false,
    original = {}
}

local function setupChanceAimChar(char)
    chanceAim.humanoid = char:WaitForChild("Humanoid")
    chanceAim.hrp = char:WaitForChild("HumanoidRootPart")
end

local function getValidTarget()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        local targets = chanceAim.targets
        for i = 1, #targets do
            local target = killersFolder:FindFirstChild(targets[i])
            if target and target:FindFirstChild("HumanoidRootPart") then
                return target.HumanoidRootPart
            end
        end
    end
    return nil
end

local function getPlayingAnimationIds()
    local ids = {}
    if chanceAim.humanoid then
        local tracks = chanceAim.humanoid:GetPlayingAnimationTracks()
        for i = 1, #tracks do
            local track = tracks[i]
            local anim = track.Animation
            if anim and anim.AnimationId then
                local id = anim.AnimationId:match("%d+")
                if id then ids[id] = true end
            end
        end
    end
    return ids
end

if LocalPlayer.Character then setupChanceAimChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupChanceAimChar)

Tabs.Auto_Stun:Section({Title = "Chance Aimbot"})

RunService.Heartbeat:Connect(function()
    if not chanceAim.active or not chanceAim.humanoid or not chanceAim.hrp then return end

    local currentTime = tick()
    local targetHRP = getValidTarget()
    
    if not targetHRP then
        if chanceAim.aiming and chanceAim.original.ws then
            chanceAim.humanoid.WalkSpeed = chanceAim.original.ws
            chanceAim.humanoid.JumpPower = chanceAim.original.jp
            chanceAim.humanoid.AutoRotate = chanceAim.original.ar
            chanceAim.original = {}
        end
        chanceAim.aiming = false
        return
    end

    local playing = getPlayingAnimationIds()
    local triggered = false
    
    for id in pairs(chanceAim.animations) do
        if playing[id] then 
            triggered = true
            break 
        end
    end

    if triggered then
        chanceAim.lastTrigger = currentTime
        chanceAim.aiming = true
    end

    if chanceAim.aiming and currentTime - chanceAim.lastTrigger <= chanceAim.duration then
        if not chanceAim.original.ws then
            chanceAim.original = {
                ws = chanceAim.humanoid.WalkSpeed,
                jp = chanceAim.humanoid.JumpPower,
                ar = chanceAim.humanoid.AutoRotate
            }
            chanceAim.humanoid.AutoRotate = false
            chanceAim.hrp.AssemblyAngularVelocity = Vector3.zero
            chanceAim.hrp.AssemblyLinearVelocity = Vector3.zero
        end
        
        local ping = (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()):match("%d+")
        local pingSeconds = (tonumber(ping) or 50) / 1000
        
        local targetVelocity = targetHRP.Velocity
        local moveDir = targetVelocity.Magnitude > 0.1 and targetVelocity.Unit or targetHRP.CFrame.LookVector
        local pingOffset = moveDir * (pingSeconds * math.max(targetVelocity.Magnitude, 10))
        
        local predictedPos = targetHRP.Position + pingOffset + (targetHRP.CFrame.LookVector * chanceAim.prediction)
        
        local direction = (predictedPos - chanceAim.hrp.Position).Unit
        local yRot = math.atan2(-direction.X, -direction.Z)
        chanceAim.hrp.CFrame = CFrame.new(chanceAim.hrp.Position) * CFrame.Angles(0, yRot, 0)
        
        chanceAim.humanoid.WalkSpeed = 0.6
        chanceAim.humanoid.JumpPower = 0
    elseif chanceAim.aiming then
        chanceAim.aiming = false
        if chanceAim.original.ws then
            chanceAim.humanoid.WalkSpeed = chanceAim.original.ws
            chanceAim.humanoid.JumpPower = chanceAim.original.jp
            chanceAim.humanoid.AutoRotate = chanceAim.original.ar
            chanceAim.original = {}
        end
    end
end)

local function OnRemoteEvent(eventName, eventArg)
    if not chanceAim.active then return end
    if eventName == "UseActorAbility" and type(eventArg) == "table" and eventArg[1] and tostring(eventArg[1]) == buffer.fromstring("\3\5\0\0\0Shoot") then
        chanceAim.lastTrigger = tick()
        chanceAim.aiming = true
    end
end

Tabs.Auto_Stun:Toggle({
    Title = "Aimbot",
    Default = false,
    Callback = function(v) chanceAim.active = v end
})

Tabs.Auto_Stun:Slider({
    Title = "Prediction coefficient (high latency=>4)",
    Step = 1,
    Value = {Min = 1, Max = 10, Default = chanceAim.prediction},
    Suffix = "studs",
    Callback = function(val) chanceAim.prediction = val end
})

RunService.RenderStepped:Connect(OnRenderStep)

local AutoFlipCoins = false
local flipCoinsThread = nil

Tabs.Auto_Stun:Toggle({
    Title = "Automatically flip coins(3)",
    Default = false,
    Callback = function(state)
        AutoFlipCoins = state
        
        if AutoFlipCoins then
            flipCoinsThread = task.spawn(function()
                while AutoFlipCoins and task.wait() do
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    local chargesText = playerGui:FindFirstChild("MainUI") and 
                                       playerGui.MainUI:FindFirstChild("AbilityContainer") and
                                       playerGui.MainUI.AbilityContainer:FindFirstChild("Shoot") and
                                       playerGui.MainUI.AbilityContainer.Shoot:FindFirstChild("Charges")
                    
                    if chargesText and chargesText:IsA("TextLabel") and chargesText.Text == "3" then
                        break
                    else
                        game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\8\0\0\0CoinFlip") })
                    end
                end
            end)
        elseif flipCoinsThread then
            task.cancel(flipCoinsThread)
            flipCoinsThread = nil
        end
    end
})
Tabs.Auto_Stun:Toggle({
    Title = "Automatically flip coins(1)",
    Default = false,
    Callback = function(state)
        AutoFlipCoins = state
        
        if AutoFlipCoins then
            flipCoinsThread = task.spawn(function()
                while AutoFlipCoins and task.wait() do
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    local chargesText = playerGui:FindFirstChild("MainUI") and 
                                       playerGui.MainUI:FindFirstChild("AbilityContainer") and
                                       playerGui.MainUI.AbilityContainer:FindFirstChild("Shoot") and
                                       playerGui.MainUI.AbilityContainer.Shoot:FindFirstChild("Charges")
                    
                    if chargesText and chargesText:IsA("TextLabel") and chargesText.Text == "1" then
                        break
                    else
                                           game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer("UseActorAbility", { buffer.fromstring("\3\8\0\0\0CoinFlip") })
                    end
                end
            end)
        elseif flipCoinsThread then
            task.cancel(flipCoinsThread)
            flipCoinsThread = nil
        end
    end
})

game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent.OnClientEvent:Connect(OnRemoteEvent)







local plr = game:GetService("Players").LocalPlayer
local pg = plr.PlayerGui
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")

local evt = rs.Modules.Network.RemoteEvent
local tui = pg:WaitForChild("TemporaryUI")

local function gkn()
    local kls = ws.Players.Killers:GetChildren()
    for _, k in pairs(kls) do
        if k:IsA("Model") and k.Name == "Nosferatu" then
            local un = k:GetAttribute("Username")
            if un and un ~= plr.Name then
                return un
            end
        end
    end
    return nil
end

-- 添加控制变量
local autoQTEEnabled = false
local qteLoop = nil

local function startQTELoop()
    if qteLoop then return end
    
    qteLoop = task.spawn(function()
        while autoQTEEnabled do
            task.wait(0.1)
            if tui:FindFirstChild("QTE") then
                local kn = gkn()
                if kn then
                    evt:FireServer(
                        kn .. "NosHookQTE",
                        {buffer.fromstring("\x01\x01")}
                    )
                end
            end
        end
    end)
end

local function stopQTELoop()
    if qteLoop then
        task.cancel(qteLoop)
        qteLoop = nil
    end
end

Tabs.Auto_Stun:Section({Title = "Nosferatu break free"})


Tabs.Auto_Stun:Toggle({
    Title = "Auto QTE",
    Desc = "AUTO",
    Value = false,
    Callback = function(state)
        autoQTEEnabled = state
        if state then
            startQTELoop()
        else
            stopQTELoop()
        end
    end
})


Tabs.Auto_Stun:Section({Title = "Veeronica"})


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function getBehaviorFolder()
    return ReplicatedStorage:WaitForChild("Assets")
        :WaitForChild("Survivors")
        :WaitForChild("Veeronica")
        :WaitForChild("Behavior")
end

local function getSprintingButton()
    return player.PlayerGui:WaitForChild("MainUI"):WaitForChild("SprintingButton")
end

local behaviorFolder = getBehaviorFolder()
local monitored = {}
local isEnabled = false
local descendantAddedConn = nil
local device = "PC"

local function safeConnectPropertyChanged(instance, prop, fn)
    local ok, signal = pcall(function() return instance:GetPropertyChangedSignal(prop) end)
    if ok and signal then
        return signal:Connect(fn)
    end
    return nil
end

local function monitorHighlight(h)
    if not h or monitored[h] then return end

    local connections = {}
    local prevState = false

    local function cleanup()
        for _, conn in ipairs(connections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        monitored[h] = nil
    end

    local function adorneeIsPlayerCharacter(h)
        if not h then return false end
        local adornee = h.Adornee
        local char = player.Character
        if not adornee or not char then return false end
        if adornee == char then return true end
        if adornee:IsDescendantOf(char) then return true end
        return false
    end

    local function triggerSprint()
        if device == "Mobile" then
            local ok, btn = pcall(getSprintingButton)
            if ok and btn then
                for i, v in pairs(getconnections(btn.MouseButton1Down)) do
                    pcall(function() v:Fire() end)
                    pcall(function() if v.Function then v:Function() end end)
                end
            end
        else
            pcall(function()
                keypress(Enum.KeyCode.Space)
                task.wait(0.1)
                keyrelease(Enum.KeyCode.Space)
            end)
        end
    end

    local function onChanged()
        if not isEnabled then return end
        if not h or not h.Parent then
            cleanup()
            return
        end

        local currState = adorneeIsPlayerCharacter(h)
        if prevState ~= currState then
            if currState then
                triggerSprint()
            end
            prevState = currState
        end
    end

    local c = safeConnectPropertyChanged(h, "Adornee", onChanged)
    if c then table.insert(connections, c) end

    table.insert(connections, h.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
        else
            onChanged()
        end
    end))

    table.insert(connections, player.CharacterAdded:Connect(onChanged))
    table.insert(connections, player.CharacterRemoving:Connect(onChanged))

    monitored[h] = cleanup
    task.spawn(onChanged)
end

local function startMonitoring()
    if descendantAddedConn then return end
    
    for _, desc in ipairs(behaviorFolder:GetDescendants()) do
        if desc:IsA("Highlight") then
            monitorHighlight(desc)
        end
    end
    
    descendantAddedConn = behaviorFolder.DescendantAdded:Connect(function(child)
        if child:IsA("Highlight") then
            monitorHighlight(child)
        end
    end)
end

local function stopMonitoring()
    if descendantAddedConn and descendantAddedConn.Connected then
        descendantAddedConn:Disconnect()
    end
    descendantAddedConn = nil

    for h, cleanup in pairs(monitored) do
        if type(cleanup) == "function" then
            pcall(cleanup)
        end
    end
    monitored = {}
end

Tabs.Auto_Stun:Toggle({
    Title = "Auto jump",
    Desc = "auto",
    Value = false,
    Callback = function(enabled)
        isEnabled = enabled
        if enabled then
            startMonitoring()
        else
            stopMonitoring()
        end
    end
})

Tabs.Auto_Stun:Dropdown({
    Title = "type",
    Desc = "Choose your device type",
    Values = {"Mobile", "PC"},
    Value = "PC",
    Callback = function(value)
        device = (value == "Mobile") and "Mobile" or "PC"
    end
})

if not _G.VeeronicaData then
    _G.VeeronicaData = {
        characterConnection = nil
    }
end

local function setupVeeronicaCharacterConnection()
    local data = _G.VeeronicaData
    
    if data.characterConnection then
        data.characterConnection:Disconnect()
        data.characterConnection = nil
    end
    
    data.characterConnection = player.CharacterAdded:Connect(function()
        if isEnabled then
            task.wait(0.5)
            stopMonitoring()
            startMonitoring()
        end
    end)
end

setupVeeronicaCharacterConnection()

if isEnabled then
    startMonitoring()
end

local ControlCharge = {
    Enabled = false,
    Active = false,
    ShiftlockEnabled = false,
    Connection = nil,
    OverrideConnection = nil,
    ChargeAnimIds = {"117058860640843"},
    ORIGINAL_DASH_SPEED = 60,
    SavedHumanoidState = {}
}

ControlCharge.SetShiftlock = function(state)
    ControlCharge.ShiftlockEnabled = state

    if ControlCharge.Connection then
        ControlCharge.Connection:Disconnect()
        ControlCharge.Connection = nil
    end

    if ControlCharge.ShiftlockEnabled then
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

        ControlCharge.Connection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local camCF = camera.CFrame
                root.CFrame = CFrame.new(root.Position, Vector3.new(
                    camCF.LookVector.X + root.Position.X,
                    root.Position.Y,
                    camCF.LookVector.Z + root.Position.Z
                ))
            end
        end)
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
end

ControlCharge.GetHumanoid = function()
    if not player or not player.Character then return nil end
    return player.Character:FindFirstChildOfClass("Humanoid")
end

ControlCharge.SaveHumState = function(hum)
    if not hum then return end
    if ControlCharge.SavedHumanoidState[hum] then return end
    local s = {}
    pcall(function()
        s.WalkSpeed = hum.WalkSpeed
        local ok, _ = pcall(function() s.JumpPower = hum.JumpPower end)
        if not ok then
            pcall(function() s.JumpPower = hum.JumpHeight end)
        end
        local ok2, ar = pcall(function() return hum.AutoRotate end)
        if ok2 then s.AutoRotate = ar end
        s.PlatformStand = hum.PlatformStand
    end)
    ControlCharge.SavedHumanoidState[hum] = s
end

ControlCharge.RestoreHumState = function(hum)
    if not hum then return end
    local s = ControlCharge.SavedHumanoidState[hum]
    if not s then return end
    pcall(function()
        if s.WalkSpeed ~= nil then hum.WalkSpeed = s.WalkSpeed end
        if s.JumpPower ~= nil then
            local ok, _ = pcall(function() hum.JumpPower = s.JumpPower end)
            if not ok then pcall(function() hum.JumpHeight = s.JumpPower end) end
        end
        if s.AutoRotate ~= nil then pcall(function() hum.AutoRotate = s.AutoRotate end) end
        if s.PlatformStand ~= nil then hum.PlatformStand = s.PlatformStand end
    end)
    ControlCharge.SavedHumanoidState[hum] = nil
end

ControlCharge.StartOverride = function()
    if ControlCharge.Active then return end
    local hum = ControlCharge.GetHumanoid()
    if not hum then return end

    ControlCharge.Active = true
    ControlCharge.SaveHumState(hum)

    pcall(function()
        hum.WalkSpeed = ControlCharge.ORIGINAL_DASH_SPEED
        hum.AutoRotate = false
    end)
    
    ControlCharge.SetShiftlock(true)
    
    ControlCharge.OverrideConnection = RunService.RenderStepped:Connect(function()
        local humanoid = ControlCharge.GetHumanoid()
        local rootPart = humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end

        pcall(function()
            humanoid.WalkSpeed = ControlCharge.ORIGINAL_DASH_SPEED
            humanoid.AutoRotate = false
        end)

        local direction = rootPart.CFrame.LookVector
        local horizontal = Vector3.new(direction.X, 0, direction.Z)
        if horizontal.Magnitude > 0 then
            humanoid:Move(horizontal.Unit)
        else
            humanoid:Move(Vector3.new(0,0,0))
        end
    end)
end

ControlCharge.StopOverride = function()
    if not ControlCharge.Active then return end
    ControlCharge.Active = false

    if ControlCharge.OverrideConnection then
        pcall(function() ControlCharge.OverrideConnection:Disconnect() end)
        ControlCharge.OverrideConnection = nil
    end

    ControlCharge.SetShiftlock(false)

    local hum = ControlCharge.GetHumanoid()
    if hum then
        pcall(function()
            ControlCharge.RestoreHumState(hum)
            hum:Move(Vector3.new(0,0,0))
        end)
    end
end

ControlCharge.DetectChargeAnimation = function()
    local hum = ControlCharge.GetHumanoid()
    if not hum then return false end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local ok, animId = pcall(function()
            return tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
        end)
        if ok and animId and animId ~= "" then
            if ControlCharge.ChargeAnimIds and table.find(ControlCharge.ChargeAnimIds, animId) then
                return true
            end
        end
    end
    return false
end

ControlCharge.SetEnabled = function(val)
    ControlCharge.Enabled = val
    if not ControlCharge.Enabled and ControlCharge.Active then
        ControlCharge.StopOverride()
    end
end

ControlCharge.MainLoop = function()
    if not ControlCharge.Enabled then
        if ControlCharge.Active then ControlCharge.StopOverride() end
        return
    end

    local hum = ControlCharge.GetHumanoid()
    if not hum then
        if ControlCharge.Active then ControlCharge.StopOverride() end
        return
    end

    local isCharging = ControlCharge.DetectChargeAnimation()

    if isCharging then
        if not ControlCharge.Active then
            ControlCharge.StartOverride()
        end
    else
        if ControlCharge.Active then
            ControlCharge.StopOverride()
        end
    end
end

RunService.RenderStepped:Connect(function()
    ControlCharge.MainLoop()
end)

player.CharacterAdded:Connect(function(char)
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 2)
    end)
end)

player.CharacterAdded:Connect(function()
    if ControlCharge.Connection then
        ControlCharge.Connection:Disconnect()
        ControlCharge.Connection = nil
    end
end)

Tabs.Auto_Stun:Toggle({
    Title = "Skateboard Movement Control",
    Desc = "php",
    Value = false,
    Callback = function(state)
        ControlCharge.SetEnabled(state)
    end
})

if getgenv().ExistingConnections then
    for _, conn in ipairs(getgenv().ExistingConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
end


Tabs.Random:Section({Title = "Aimbot"})

Tabs.Random:Toggle({
    Title = "Aimbot",
    Default = false,
    Callback = function(state) aimbot.enabled = state end
})

local faceEnemy = {
    enabled = false,
    targetType = "killer",
    autoAim = false
}

local faceEnemyConnection

Tabs.Random:Toggle({
    Title = "Automatically face the enemy",
    Default = false,
    Callback = function(state)
        faceEnemy.enabled = state
        
        if state then
            faceEnemyConnection = RunService.RenderStepped:Connect(function()
                if not faceEnemy.enabled then return end
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local myRoot = char.HumanoidRootPart
                
                local targetFolder = faceEnemy.targetType == "杀手" 
                    and (Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers"))
                    or (Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors"))
                
                if not targetFolder then return end
                
                local closest, minDist = nil, math.huge
                for _, target in ipairs(targetFolder:GetChildren()) do
                    if target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") then
                        local dist = (target.HumanoidRootPart.Position - myRoot.Position).Magnitude
                        if dist < minDist then
                            closest, minDist = target, dist
                        end
                    end
                end
                
                if closest and closest:FindFirstChild("HumanoidRootPart") then
                    local targetPos = closest.HumanoidRootPart.Position
                    local lookPos = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)
                    myRoot.CFrame = CFrame.new(myRoot.Position, lookPos)
                end
            end)
        else
            if faceEnemyConnection then
                faceEnemyConnection:Disconnect()
                faceEnemyConnection = nil
            end
        end
    end
})

Tabs.Random:Dropdown({
    Title = "Towards the target type",
    Values = {"Killer", "Survivor"},
    Multi = false,
    AllowNone = false,
    Callback = function(choice) faceEnemy.targetType = choice end
})

local orbit = {
    active = false,
    distance = 10,
    speed = 5,
    angle = 0,
    targetPlayer = nil,
    heightOffset = 0
}

RunService.RenderStepped:Connect(function(dt)
    if not orbit.active or not orbit.targetPlayer then return end

    local targetChar = orbit.targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end

    orbit.angle = orbit.angle + orbit.speed * dt
    local offset = Vector3.new(
        math.cos(orbit.angle) * orbit.distance,
        orbit.heightOffset,
        math.sin(orbit.angle) * orbit.distance
    )
    myRoot.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
end)

Tabs.Random:Toggle({
    Title = "Orbit Player",
    Default = false,
    Callback = function(state) orbit.active = state end
})

Tabs.Random:Dropdown({
    Title = "Select Target",
    Values = (function()
        local names = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then names[#names + 1] = player.Name end
        end
        return names
    end)(),
    Multi = false,
    AllowNone = true,
    Callback = function(choice)
        orbit.targetPlayer = Players:FindFirstChild(choice)
    end
})

Tabs.Random:Slider({
    Title = "Rotation Speed",
    Step = 0.5,
    Value = {Min = 1, Max = 50, Default = orbit.speed},
    Suffix = " /sec",
    Callback = function(val) orbit.speed = val end
})

Tabs.Random:Slider({
    Title = "Orbit Distance",
    Step = 1,
    Value = {Min = 1, Max = 20, Default = orbit.distance},
    Suffix = " studs",
    Callback = function(val) orbit.distance = val end
})

Tabs.Random:Slider({
    Title = "height offset",
    Step = 0.5,
    Value = {Min = -10, Max = 10, Default = orbit.heightOffset},
    Suffix = " studs",
    Callback = function(val) orbit.heightOffset = val end
})





Tabs.Teleport:Section({Title = "Teleportatione"})

Tabs.Teleport:Button({
    Title = "Teleport to Killer",
    Callback = function()
        local folder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
        local killer = folder and folder:FindFirstChildWhichIsA("Model")
        if killer and killer.PrimaryPart then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = killer.PrimaryPart.CFrame
            end
        end
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to Nearest Survivor",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local folder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors")
        if not folder then return end
        
        local myPos = char.HumanoidRootPart.Position
        local nearest, minDist = nil, math.huge
        
        for _, survivor in ipairs(folder:GetChildren()) do
            if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") then
                local dist = (survivor.HumanoidRootPart.Position - myPos).Magnitude
                if dist < minDist then
                    nearest, minDist = survivor, dist
                end
            end
        end
        
        if nearest and nearest:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        end
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to generator",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "Generator" then
                local target = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
                if target then
                    char.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to Medkit",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "ItemRoot" and v.Parent and v.Parent.Name == "Medkit" then
                char.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                break
            end
        end
    end
})

Tabs.Teleport:Button({
    Title = "Teleport to BloxyCola",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "ItemRoot" and v.Parent and v.Parent.Name == "BloxyCola" then
                char.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                break
            end
        end
    end
})

-- 动作系统
local emoteSystem = {
    active = false,
    currentEmote = "Silly Billy",
    currentTrack = nil,
    currentSound = nil,
    bodyVel = nil,
    emotes = {
        ["Silly Billy"] = {
            animId = "rbxassetid://107464355830477",
            soundId = "rbxassetid://77601084987544",
            volume = 0.5,
            looped = false,
            remoteName = nil,
            cleanAssets = {"EmoteHatAsset", "EmoteLighting", "PlayerEmoteHand"}
        },
        ["Silly of it"] = {
            animId = "rbxassetid://107464355830477",
            soundId = "rbxassetid://120176009143091",
            volume = 0.5,
            looped = false,
            remoteName = nil,
            cleanAssets = {"EmoteHatAsset", "EmoteLighting", "PlayerEmoteHand"}
        },
        ["Subterfuge"] = {
            animId = "rbxassetid://87482480949358",
            soundId = "rbxassetid://132297506693854",
            volume = 2,
            looped = false,
            remoteName = "_Subterfuge",
            cleanAssets = {},
            hasEffect = false
        },
        ["VIP Dance"] = {
            animId = "rbxassetid://138019937280193",
            soundId = "rbxassetid://109474987384441",
            volume = 0.5,
            looped = true,
            remoteName = "HakariDance",
            cleanAssets = {},
            hasEffect = true
        },
        ["Oppan Gangnam style"] = {
            animId = "rbxassetid://108308837970067",
            soundId = "rbxassetid://86963552203595",
            volume = 0.5,
            looped = true,
            remoteName = nil,
            cleanAssets = {"EmoteHatAsset", "EmoteLighting", "PlayerEmoteHand"}
        }
    }
}

local function stopEmote()
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        humanoid.PlatformStand = false
        humanoid.JumpPower = 50
        
        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
    
    if rootPart then
        local bodyVel = rootPart:FindFirstChildOfClass("BodyVelocity")
        if bodyVel then bodyVel:Destroy() end
        
        for _, sound in ipairs(rootPart:GetChildren()) do
            if sound:IsA("Sound") then
                sound:Stop()
                sound:Destroy()
            end
        end
    end
    
    for _, assetName in ipairs({"EmoteHatAsset", "EmoteLighting", "PlayerEmoteHand", "PlayerEmoteVFX"}) do
        local asset = char:FindFirstChild(assetName)
        if asset then asset:Destroy() end
    end
    
    emoteSystem.currentTrack = nil
    emoteSystem.currentSound = nil
    emoteSystem.bodyVel = nil
end

local function playEmote()
    stopEmote()
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    local emoteData = emoteSystem.emotes[emoteSystem.currentEmote]
    if not emoteData then return end
    
    humanoid.PlatformStand = true
    humanoid.JumpPower = 0
    
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = rootPart
    emoteSystem.bodyVel = bodyVel
    
    local anim = Instance.new("Animation")
    anim.AnimationId = emoteData.animId
    local track = humanoid:LoadAnimation(anim)
    track:Play()
    emoteSystem.currentTrack = track
    
    local sound = Instance.new("Sound")
    sound.SoundId = emoteData.soundId
    sound.Volume = emoteData.volume
    sound.Looped = emoteData.looped
    sound.Parent = rootPart
    sound:Play()
    emoteSystem.currentSound = sound
    
    if emoteData.hasEffect then
        pcall(function()
            local effect = ReplicatedStorage.Assets.Emotes.HakariDance.HakariBeamEffect:Clone()
            effect.Name = "PlayerEmoteVFX"
            effect.CFrame = rootPart.CFrame * CFrame.new(0, -1, -0.3)
            effect.WeldConstraint.Part0 = rootPart
            effect.WeldConstraint.Part1 = effect
            effect.CanCollide = false
            effect.Parent = char
        end)
    end
    
    if emoteData.remoteName then
        pcall(function()
            remoteEvent:FireServer("PlayEmote", "Animations", emoteData.remoteName)
        end)
    end
    
    track.Stopped:Connect(function()
        if not emoteSystem.active then
            humanoid.PlatformStand = false
            if bodyVel and bodyVel.Parent then bodyVel:Destroy() end
            
            for _, assetName in ipairs(emoteData.cleanAssets) do
                local asset = char:FindFirstChild(assetName)
                if asset then asset:Destroy() end
            end
        end
    end)
end

Tabs.Actions:Section({Title = "Emote Actions"})

Tabs.Actions:Dropdown({
    Title = "Select Emote",
    Values = {"Silly Billy", "Silly of it", "Subterfuge", "VIP Dance", "江南风"},
    Multi = false,
    AllowNone = false,
    Callback = function(selected)
        emoteSystem.currentEmote = selected
        if emoteSystem.active then
            playEmote()
        end
    end
})

Tabs.Actions:Toggle({
    Title = "Start Emote",
    Default = false,
    Callback = function(state)
        emoteSystem.active = state
        if state then
            playEmote()
        else
            stopEmote()
        end
    end
})


local fakeDieEnabled = false
local fakeDieTrack = nil
local fakeDieConnection = nil

Tabs.Actions:Toggle({
    Title = "Fake Die",
    Default = false,
    Callback = function(state)
        fakeDieEnabled = state
        
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        
        local plr = Players.LocalPlayer
        local char = plr.Character
        if not char then return end
        
        local hum = char:WaitForChild("Humanoid")
        
        if state then
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://118795597134269"
            
            fakeDieTrack = hum:LoadAnimation(anim)
            fakeDieTrack:Play()
            
            if fakeDieTrack.Length > 0 then
                fakeDieTrack.TimePosition = fakeDieTrack.Length * 0.5
            end
            
            local stopped = false
            fakeDieConnection = RunService.Heartbeat:Connect(function()
                if fakeDieTrack.IsPlaying and not stopped and fakeDieTrack.Length > 0 then
                    local percent = fakeDieTrack.TimePosition / fakeDieTrack.Length
                    if percent >= 0.9 then
                        fakeDieTrack:AdjustSpeed(0)
                        stopped = true
                    end
                end
            end)
        else
            if fakeDieTrack then
                fakeDieTrack:Stop()
                fakeDieTrack = nil
            end
            
            if fakeDieConnection then
                fakeDieConnection:Disconnect()
                fakeDieConnection = nil
            end
            
            pcall(function()
                hum:PlayEmote("idle")
            end)
        end
    end
})





local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local invisAnimationId = "75804462760596"
local invisLoopRunning = false
local invisLoopThread
local invisCurrentAnim = nil

local function startInvisibility()
    invisLoopRunning = true
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end

    invisLoopThread = task.spawn(function()
        while invisLoopRunning do
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. invisAnimationId
            local loadedAnim = humanoid:LoadAnimation(anim)
            invisCurrentAnim = loadedAnim
            loadedAnim.Looped = false
            loadedAnim:Play()
            loadedAnim:AdjustSpeed(0)
            task.wait(0.000001)
        end
    end)
end

local function stopInvisibility()
    invisLoopRunning = false
    if invisLoopThread then
        task.cancel(invisLoopThread)
        invisLoopThread = nil
    end
    if invisCurrentAnim then
        invisCurrentAnim:Stop()
        invisCurrentAnim = nil
    end
    local humanoid = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character:FindFirstChildOfClass("AnimationController"))
    if humanoid then
        for _, v in pairs(humanoid:GetPlayingAnimationTracks()) do
            v:AdjustSpeed(100000)
        end
    end
    local animateScript = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Disabled = true
        animateScript.Disabled = false
    end
end

Tabs.Actions:Toggle({
    Title = "Invisibility",
    Value = false,
    Tooltip = "Crawl-style invisibility",
    Callback = function(Value)
        if Value then
            startInvisibility()
        else
            stopInvisibility()
        end
    end
})



local v1 = game:GetService("ReplicatedStorage")
local v2 = LocalPlayer
local v3 = v2.Character or v2.CharacterAdded:Wait()
local v4 = v3:WaitForChild("HumanoidRootPart")

v2.CharacterAdded:Connect(function(newChar)
    v3 = newChar
    v4 = v3:WaitForChild("HumanoidRootPart")
end)

local SilentAimEnabled = false
local WallCheckEnabled = false
local FilterKillersEnabled = false
local FilterSurvivorsEnabled = false

local function v5()
    if not SilentAimEnabled then return nil end
    
    local v6, v7 = nil, 100
    
    local function checkTarget(v8, v10)
        if WallCheckEnabled then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {v3, v8}
            rayParams.IgnoreWater = true
            
            local rayResult = workspace:Raycast(
                v4.Position,
                (v10.Position - v4.Position).Unit * (v10.Position - v4.Position).Magnitude,
                rayParams
            )
            
            if rayResult then
                local hitPart = rayResult.Instance
                if not hitPart:IsDescendantOf(v8) then
                    return false
                end
            end
        end
        
        if FilterKillersEnabled then
            local killersFolder = workspace.Players:FindFirstChild("Killers")
            if killersFolder and v8:IsDescendantOf(killersFolder) then
                return false
            end
        end
        
        if FilterSurvivorsEnabled then
            local survivorsFolder = workspace.Players:FindFirstChild("Survivors")
            if survivorsFolder and v8:IsDescendantOf(survivorsFolder) then
                return false
            end
        end
        
        return true
    end

    for _, v8 in workspace:GetDescendants() do
        if v8:IsA("Model") and v8 ~= v3 then
            local v9 = v8:FindFirstChild("Humanoid")
            local v10 = v8:FindFirstChild("HumanoidRootPart")
            if v9 and v10 and v9.Health > 0 then
                if checkTarget(v8, v10) then
                    local v11 = (v4.Position - v10.Position).Magnitude
                    if v11 < v7 then
                        v6, v7 = v10.Position, v11
                    end
                end
            end
        end
    end
    return v6
end





Tabs.SilentAim:Section({Title = "Silent Aim Settings"})

Tabs.SilentAim:Toggle({
    Title = "Silent Aim",
    Default = false,
    Callback = function(state)
        SilentAimEnabled = state
    end
})

Tabs.SilentAim:Toggle({
    Title = "WallCheck",
    Default = false,
    Callback = function(state)
        WallCheckEnabled = state
    end
})

Tabs.SilentAim:Toggle({
    Title = "Exclude Killers",
    Default = false,
    Callback = function(state)
        FilterKillersEnabled = state
    end
})

Tabs.SilentAim:Toggle({
    Title = "Exclude Survivors",
    Default = false,
    Callback = function(state)
        FilterSurvivorsEnabled = state
    end
})

Tabs.SilentAim:Button({
    Title = "Silent Aim",
    Callback = function()
        task.wait(1)
        
        local v12, v13 = pcall(require, v1.Systems.Player.Miscellaneous.GetPlayerMousePosition)
        
        if v12 then
            if typeof(v13) == "function" then
                local v14 = v13
                v1.Systems.Player.Miscellaneous.GetPlayerMousePosition = function(...)
                    return v5() or v14(...)
                end
            elseif typeof(v13) == "table" then
                for v15, v16 in pairs(v13) do
                    if typeof(v16) == "function" then
                        local v17 = v16
                        v13[v15] = function(...)
                            return v5() or v17(...)
                        end
                    end
                end
            end
        end
        
        WindUI:Notify({
            Title = "Silent Aim",
            Content = "Support creators: dusek, Coolkkid, Noli [Ranged Skill]",
            Duration = 3
        })
    end
})


local ff_connection = nil
local ff_enabled = false
local ff_cd = false
local jumpHeight = 72
local jumpDistance = 35

local function Flip()
    if ff_cd then
        return
    end
    ff_cd = true
    local character = game.Players.LocalPlayer.Character
    if not character then
        ff_cd = false
        return
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local Humanoid = character:FindFirstChildOfClass("Humanoid")
    local animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
    if not hrp or not Humanoid then
        ff_cd = false
        return
    end
    local savedTracks = {}
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            savedTracks[#savedTracks + 1] = { track = track, time = track.TimePosition }
            track:Stop(0)
        end
    end
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
    local duration = 0.45
    local steps = 120
    local startCFrame = hrp.CFrame
    local forwardVector = startCFrame.LookVector
    local upVector = Vector3.new(0, 1, 0)
    task.spawn(function()
        local startTime = tick()
        for i = 1, steps do
            local t = i / steps
            local height = jumpHeight * (t - t ^ 2)
            local nextPos = startCFrame.Position + forwardVector * (jumpDistance * t) + upVector * height    
            local rotation = startCFrame.Rotation * CFrame.Angles(-math.rad(i * (360 / steps)), 0, 0)

            hrp.CFrame = CFrame.new(nextPos) * rotation
            local elapsedTime = tick() - startTime
            local expectedTime = (duration / steps) * i
            local waitTime = expectedTime - elapsedTime
            if waitTime > 0 then
                task.wait(waitTime)
            end
        end

        hrp.CFrame = CFrame.new(startCFrame.Position + forwardVector * jumpDistance) * startCFrame.Rotation
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)

        if animator then
            for _, data in ipairs(savedTracks) do
                local track = data.track
                track:Play()
                track.TimePosition = data.time
            end
        end
        task.wait(0.25)
        ff_cd = false
    end)
end

local sausageHolder = nil
local originalSize = nil
local ff_button = nil

local function SetFrontFlip(bool)
    ff_enabled = bool
    if ff_enabled == true then
        pcall(function()
            sausageHolder = game.CoreGui.TopBarApp.TopBarApp.UnibarLeftFrame.UnibarMenu["2"]
            originalSize = sausageHolder.Size.X.Offset
            ff_button = Instance.new("Frame", sausageHolder)
            ff_button.Size = UDim2.new(0, 48, 0, 44)
            ff_button.BackgroundTransparency = 1
            ff_button.BorderSizePixel = 0
            ff_button.Position = UDim2.new(0, sausageHolder.Size.X.Offset - 48, 0, 0)
            
            local imageButton = Instance.new("ImageButton", ff_button)
            imageButton.BackgroundTransparency = 1
            imageButton.BorderSizePixel = 0
            imageButton.Size = UDim2.new(0, 36, 0, 36)
            imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
            imageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
            imageButton.Image = "rbxthumb://type=Asset&id=2714338264&w=150&h=150"
            
            ff_connection = imageButton.Activated:Connect(Flip)
            sausageHolder.Size = UDim2.new(0, originalSize + 48, 0, sausageHolder.Size.Y.Offset)
            task.wait()
            ff_button.Position = UDim2.new(0, sausageHolder.Size.X.Offset - 48, 0, 0)
            
            task.spawn(function()
                pcall(function()
                    repeat
                        sausageHolder.Size = UDim2.new(0, originalSize + 48, 0, sausageHolder.Size.Y.Offset)
                        task.wait()
                        ff_button.Position = UDim2.new(0, sausageHolder.Size.X.Offset - 48, 0, 0)
                    until ff_enabled == false
                end)
            end)
        end)
    elseif ff_enabled == false then
        if ff_connection then
            ff_connection:Disconnect()
            ff_connection = nil
        end
        if ff_button then
            ff_button:Destroy()
            ff_button = nil
        end
        if sausageHolder then
            sausageHolder.Size = UDim2.new(0, originalSize, 0, sausageHolder.Size.Y.Offset)
        end
    end
end

Tabs.Player:Section({Title = "Front Flip"})



Tabs.Player:Toggle({
    Title = "Show Front Flip Button",
    Default = false,
    Callback = function(state)
        SetFrontFlip(state)
    end
})

Tabs.Player:Slider({
    Title = "Jump Height",
    Step = 1,
    Value = {Min = 20, Max = 200, Default = jumpHeight},
    Suffix = "Unit",
    Callback = function(val)
        jumpHeight = val
    end
})

Tabs.Player:Slider({
    Title = "Jump Distance",
    Step = 1,
    Value = {Min = 10, Max = 100, Default = jumpDistance},
    Suffix = "Unit",
    Callback = function(val)
        jumpDistance = val
    end
})


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local voidrushcontrol = false
local DASH_SPEED = 80
local ATTACK_RANGE = 6
local ATTACK_INTERVAL = 0.2

-- 添加范围变量
local aimDistance = 50

local isOverrideActive = false
local connection
local Humanoid, RootPart
local lastState = nil
local attackingLoop = nil

local survivorsFolder = workspace:WaitForChild("Players"):WaitForChild("Survivors")

local function isPriorityTarget(p)
    if not p or not p.Character then return false end
    return survivorsFolder:FindFirstChild(p.Name) ~= nil
end

local function setupCharacter(character)
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    Humanoid.Died:Connect(function()
        isOverrideActive = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if attackingLoop then
            task.cancel(attackingLoop)
            attackingLoop = nil
        end
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

local function validTarget(p)
    if p == LocalPlayer then return false end
    local c = p.Character
    if not c then return false end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChild("Humanoid")
    return hrp and hum and hum.Health > 0
end

local function getClosestTarget()
    if not RootPart then return nil end

    local closestW, distW = nil, math.huge
    local closestA, distA = nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if validTarget(p) then
            local c = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - RootPart.Position).Magnitude
                -- 添加距离限制
                if d <= aimDistance then
                    if isPriorityTarget(p) and d < distW then
                        distW = d
                        closestW = p
                    end
                    if d < distA then
                        distA = d
                        closestA = p
                    end
                end
            end
        end
    end

    return closestW or closestA, distW < math.huge and distW or distA
end

local function attemptAttack()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool.Parent == char then
        pcall(function() tool:Activate() end)
    end
end

local function startOverride()
    if isOverrideActive or not Humanoid or not RootPart then return end
    isOverrideActive = true

    connection = RunService.RenderStepped:Connect(function()
        if not Humanoid or not RootPart or Humanoid.Health <= 0 then return end
        local target, dist = getClosestTarget()

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local dir = hrp.Position - RootPart.Position
            local horizontal = Vector3.new(dir.X, 0, dir.Z)

            if horizontal.Magnitude > 0.1 then
                RootPart.CFrame = CFrame.new(RootPart.Position, Vector3.new(hrp.Position.X, RootPart.Position.Y, hrp.Position.Z))
                RootPart.AssemblyLinearVelocity = horizontal.Unit * DASH_SPEED
            else
                RootPart.AssemblyLinearVelocity = Vector3.zero
            end
        else
            RootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    attackingLoop = task.spawn(function()
        while isOverrideActive do
            local target, dist = getClosestTarget()
            if target and dist and dist <= ATTACK_RANGE then
                attemptAttack()
            end
            task.wait(ATTACK_INTERVAL)
        end
    end)
end

local function stopOverride()
    if not isOverrideActive then return end
    isOverrideActive = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
    if attackingLoop then
        task.cancel(attackingLoop)
        attackingLoop = nil
    end
    if RootPart then
        RootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

RunService.RenderStepped:Connect(function()
    if not voidrushcontrol or not Humanoid then return end
    local state = Humanoid.Parent and Humanoid.Parent:GetAttribute("VoidRushState")
    if state ~= lastState then
        lastState = state
        if state == "Dashing" then
            startOverride()
        else
            stopOverride()
        end
    end
end)


Tabs.kill:Section({Title = "Noli"})

Tabs.kill:Toggle({
    Title = "Void Rush Aim",
    Default = false,
    Callback = function(state)
        voidrushcontrol = state
        if not state then
            stopOverride()
        end
    end
})

Tabs.kill:Slider({
    Title = "AimBot Range",
    Step = 5,
    Value = {Min = 10, Max = 100, Default = aimDistance},
    Suffix = "studs",
    Callback = function(val)
        aimDistance = val
    end
})





local toggleOn = false
local toggleFlag = Instance.new("BoolValue")
toggleFlag.Name = "1x1x1x1AutoAim_ToggleFlag"
toggleFlag.Value = false

local aimMode = "Single Target"
local predictMovement = false
-- 添加预测系数变量
local predictFactor = 3

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local workspacePlayers = workspace:WaitForChild("Players")
local survivorsFolder = workspacePlayers:WaitForChild("Survivors")

local dangerousAnimations = {
    ["131430497821198"] = true,
    ["100592913030351"] = true,
    ["70447634862911"]  = true,
    ["83685305553364"] = true
}

local killerModels = {["1x1x1x1"] = true}

local autoRotateDisabledByScript = false
local currentTarget, isLockedOn, wasPlayingAnimation = nil, false, false

local function isKiller()
    local char = localPlayer.Character
    return char and killerModels[char.Name] or false
end

local function getMyHumanoid()
    local char = localPlayer.Character
    return char and char:FindFirstChildWhichIsA("Humanoid")
end

local function restoreAutoRotate()
    local hum = getMyHumanoid()
    if hum and autoRotateDisabledByScript then
        hum.AutoRotate = true
        autoRotateDisabledByScript = false
    end
end

local function isPlayingDangerousAnimation()
    local humanoid = getMyHumanoid()
    if not humanoid then return false end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local animId = tostring(track.Animation.AnimationId):match("%d+")
        if animId and dangerousAnimations[animId] then
            return true
        end
    end
    return false
end

local function getClosestSurvivor()
    local myHumanoid = getMyHumanoid()
    if not myHumanoid then return nil end
    local myRoot = myHumanoid.Parent and myHumanoid.Parent:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closest, closestDist = nil, math.huge

    for _, obj in ipairs(survivorsFolder:GetChildren()) do
        if obj:IsA("Model") then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist < closestDist then
                    closest = obj
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

localPlayer.CharacterAdded:Connect(function()
    task.delay(0.1, function()
        autoRotateDisabledByScript = false
    end)
end)

RunService.RenderStepped:Connect(function()
    if not toggleFlag.Value then
        restoreAutoRotate()
        currentTarget, isLockedOn, wasPlayingAnimation = nil, false, false
        return
    end

    if not isKiller() then
        restoreAutoRotate()
        currentTarget, isLockedOn, wasPlayingAnimation = nil, false, false
        return
    end

    local myHumanoid = getMyHumanoid()
    if not myHumanoid then return end
    local myRoot = myHumanoid.Parent and myHumanoid.Parent:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local isPlaying = isPlayingDangerousAnimation()

    if isPlaying and not isLockedOn then
        currentTarget = getClosestSurvivor()
        if currentTarget then isLockedOn = true end
    end

    if isLockedOn and currentTarget then
        local tHum = currentTarget:FindFirstChildWhichIsA("Humanoid")
        local tHrp = currentTarget:FindFirstChild("HumanoidRootPart")
        if (not tHum) or (tHum and tHum.Health <= 0) or (not tHrp) then
            currentTarget, isLockedOn = nil, false
        end
    end

    if (not isPlaying) and wasPlayingAnimation then
        currentTarget, isLockedOn = nil, false
        restoreAutoRotate()
    end
    wasPlayingAnimation = isPlaying

    if isPlaying and isLockedOn and currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then
        local hrp = currentTarget.HumanoidRootPart
        local targetPos = hrp.Position

        if not autoRotateDisabledByScript then
            myHumanoid.AutoRotate = false
            autoRotateDisabledByScript = true
        end

        if predictMovement then
            local vel = hrp.Velocity
            if vel.Magnitude > 2 then
                -- 使用预测系数
                targetPos = targetPos + hrp.CFrame.LookVector * predictFactor
            end
        end

        local lookAt = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)

        if aimMode == "Single Target" then
            myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(myRoot.Position, lookAt), 0.99)

        elseif aimMode == "Multiple Targets" then
            local newTarget = getClosestSurvivor()
            if newTarget then currentTarget = newTarget end
            myRoot.CFrame = myRoot.CFrame:Lerp(CFrame.lookAt(myRoot.Position, lookAt), 0.99)

        elseif aimMode == "Teleport" then
            local behindPos = hrp.Position - hrp.CFrame.LookVector * 3
            myRoot.CFrame = CFrame.new(behindPos, targetPos)
        end
    end
end)

Tabs.kill:Section({Title = "1x1x1x1"})


Tabs.kill:Dropdown({
    Title = "Aim Mode",
    Values = {"Single Target", "Multiple Targets", "Teleport"},
    Multi = false,
    AllowNone = false,
    Callback = function(selected)
        aimMode = selected
    end
})

Tabs.kill:Toggle({
    Title = "Mass Infection Aim",
    Default = false,
    Callback = function(state)
        toggleOn = state
        toggleFlag.Value = state
    end
})

Tabs.kill:Toggle({
    Title = "Prediction Movement",
    Default = false,
    Callback = function(state)
        predictMovement = state
    end
})

Tabs.kill:Slider({
    Title = "Prediction Factor",
    Step = 0.5,
    Value = {Min = 1, Max = 10, Default = predictFactor},
    Suffix = "Factor",
    Callback = function(val)
        predictFactor = val
    end
})



Tabs.Anti:Section({Title = "Anti-Effects"})

local antiFeatures = {
    no1x = false,
    healthGlitch = false,
    stun = false,
    slow = false,
    blindness = false,
    subspace = false,
    footsteps = false,
    hiddenStats = false
}

-- 反1x1x1x1弹窗
Tabs.Anti:Toggle({
    Title = "Anti-1x1x1x1 Popup",
    Default = false,
    Callback = function(state)
        antiFeatures.no1x = state
        if state then
            task.spawn(function()
                while antiFeatures.no1x do
                    task.wait(0.5)
                    local temp = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
                    if temp and temp:FindFirstChild("1x1x1x1Popup") then
                        pcall(function()
                            if firesignal then
                                firesignal(temp["1x1x1x1Popup"].MouseButton1Click)
                            end
                        end)
                    end
                end
            end)
        end
    end
})

-- 反生命值错误
Tabs.Anti:Toggle({
    Title = "Anti-Health Glitch",
    Default = false,
    Callback = function(state)
        antiFeatures.healthGlitch = state
        if state then
            task.spawn(function()
                while antiFeatures.healthGlitch do
                    task.wait(1)
                    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
                    if tempUI then
                        for _, v in pairs(tempUI:GetChildren()) do
                            if v.Name == "Frame" and v:FindFirstChild("Glitched") then
                                v:Destroy()
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- 反眩晕
Tabs.Anti:Toggle({
    Title = "Anti-Stun",
    Default = false,
    Callback = function(state)
        antiFeatures.stun = state
        if state then
            task.spawn(function()
                while antiFeatures.stun do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("SpeedMultipliers") then
                        local stunned = char.SpeedMultipliers:FindFirstChild("Stunned")
                        if stunned and stunned.Value ~= 1 then
                            stunned.Value = 1
                        end
                    end
                end
            end)
        end
    end
})

-- 反减速
Tabs.Anti:Toggle({
    Title = "Anti-Slow",
    Default = false,
    Callback = function(state)
        antiFeatures.slow = state
        if state then
            task.spawn(function()
                while antiFeatures.slow do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("SpeedMultipliers") then
                        for _, v in pairs(char.SpeedMultipliers:GetChildren()) do
                            if v:IsA("NumberValue") and v.Value < 1 then
                                v.Value = 1
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- 反致盲
Tabs.Anti:Toggle({
    Title = "Anti-Blindness",
    Default = false,
    Callback = function(state)
        antiFeatures.blindness = state
        if state then
            task.spawn(function()
                while antiFeatures.blindness do
                    task.wait(0.5)
                    if Lighting:FindFirstChild("BlindnessBlur") then
                        Lighting.BlindnessBlur:Destroy()
                    end
                end
            end)
        end
    end
})

-- 反子空间
Tabs.Anti:Toggle({
    Title = "Anti-Subspace",
    Default = false,
    Callback = function(state)
        antiFeatures.subspace = state
        if state then
            task.spawn(function()
                while antiFeatures.subspace do
                    task.wait(0.5)
                    local subspaceEffects = {"SubspaceVFXBlur", "SubspaceVFXColorCorrection"}
                    for _, effectName in ipairs(subspaceEffects) do
                        if Lighting:FindFirstChild(effectName) then
                            Lighting[effectName]:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

-- 反脚步声（避免Hook，使用音量调整）
Tabs.Anti:Toggle({
    Title = "Anti-Footsteps",
    Default = false,
    Callback = function(state)
        antiFeatures.footsteps = state
        if state then
            task.spawn(function()
                while antiFeatures.footsteps do
                    task.wait(0.5)
                    for _, sound in ipairs(Workspace:GetDescendants()) do
                        if sound:IsA("Sound") and sound.Name:find("Footstep") then
                            sound.Volume = 0
                        end
                    end
                end
            end)
        end
    end
})


local originalPlayerValues = {}

Tabs.Anti:Toggle({
    Title = "Anti-HideStats",
    Default = false,
    Callback = function(state)
        antiFeatures.hiddenStats = state
        
        for _, player in ipairs(Players:GetPlayers()) do
            pcall(function()
                if not player.PlayerData or not player.PlayerData.Settings or not player.PlayerData.Settings.Privacy then return end
                
                if state then
                    -- 保存原始值
                    if not originalPlayerValues[player.UserId] then
                        originalPlayerValues[player.UserId] = {}
                    end
                    
                    local privacy = player.PlayerData.Settings.Privacy
                    for _, key in ipairs({"HideKillerWins", "HidePlaytime", "HideSurvivorWins"}) do
                        local value = privacy:FindFirstChild(key)
                        if value then
                            originalPlayerValues[player.UserId][key] = value.Value
                            value.Value = false
                        end
                    end
                else
                    -- 恢复原始值
                    if originalPlayerValues[player.UserId] then
                        local privacy = player.PlayerData.Settings.Privacy
                        for key, val in pairs(originalPlayerValues[player.UserId]) do
                            local value = privacy:FindFirstChild(key)
                            if value then value.Value = val end
                        end
                    end
                end
            end)
        end
        
        -- 监听新玩家加入
        if state then
            Players.PlayerAdded:Connect(function(player)
                if antiFeatures.hiddenStats then
                    task.wait(1)
                    pcall(function()
                        if player.PlayerData and player.PlayerData.Settings and player.PlayerData.Settings.Privacy then
                            local privacy = player.PlayerData.Settings.Privacy
                            for _, key in ipairs({"HideKillerWins", "HidePlaytime", "HideSurvivorWins"}) do
                                local value = privacy:FindFirstChild(key)
                                if value then value.Value = false end
                            end
                        end
                    end)
                end
            end)
        end
    end
})


Tabs.skin:Section({Title = "Killer Skins"})


Tabs.skin:Button({
    Title = "Slasher Skin",
    Icon = "brush",
    Callback = function()
        -- 显示开始处理的通知
        WindUI:Notify({
            Title = "Applying Outfit",
            Content = "Applying Black Outfit...",
            Icon = "brush",
            Duration = 2
        })
        
        -- 获取玩家角色
        local player = game.Players.LocalPlayer  
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- 设置身体颜色为黑色
        local bodyColors = character:FindFirstChild("Body Colors")
        if bodyColors then
            bodyColors.HeadColor = BrickColor.new("Really black")
            bodyColors.LeftArmColor = BrickColor.new("Really black")
            bodyColors.RightArmColor = BrickColor.new("Really black")
            bodyColors.LeftLegColor = BrickColor.new("Really black")
            bodyColors.RightLegColor = BrickColor.new("Really black")
            bodyColors.TorsoColor = BrickColor.new("Really black")
        end
        
        -- 删除原有的Mask
        for _, obj in pairs(character:GetDescendants()) do
            if obj.Name == "Mask" then
                obj:Destroy()
            end
        end
        
        -- 设置上衣
        local shirt = character:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", character)
        shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=130919586308395"
        
        -- 设置裤子
        local pants = character:FindFirstChildOfClass("Pants") or Instance.new("Pants", character)
        pants.PantsTemplate = "http://www.roblox.com/asset/?id=83940216283729"
        
        -- 添加配饰的函数
        local function addAccessory(name, meshId, textureId, parentPartName, handleSize, position, rotation, customWeldC0, customWeldC1, meshScale, meshOffset)
            local accessory = Instance.new("Accessory")
            accessory.Name = name
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(unpack(handleSize))
            handle.CanCollide = false
            handle.Anchored = false
            handle.Parent = accessory
            local mesh = Instance.new("SpecialMesh", handle)
            mesh.MeshId = meshId
            if textureId ~= "" then
                mesh.TextureId = textureId
            end
            if meshScale then
                mesh.Scale = Vector3.new(unpack(meshScale))
            else
                mesh.Scale = Vector3.new(1, 1, 1)
            end
            if meshOffset then
                mesh.Offset = Vector3.new(unpack(meshOffset))
            else
                mesh.Offset = Vector3.new(0, 0, 0)
            end
            local targetPart = character:FindFirstChild(parentPartName)
            if not targetPart then
                warn("Target part '" .. parentPartName .. "' not found in character!")
                return
            end
            local weld = Instance.new("Weld")
            weld.Part0 = targetPart
            weld.Part1 = handle
            if customWeldC0 and customWeldC1 then
                weld.C0 = CFrame.new(unpack(customWeldC0))
                weld.C1 = CFrame.new(unpack(customWeldC1))
            else
                weld.C0 = CFrame.new(unpack(position)) * CFrame.Angles(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))
            end
            weld.Parent = handle
            accessory.Parent = character
        end
        
        -- 添加围巾
        addAccessory(
            "Scarf", 
            "rbxassetid://131343945015522", 
            "rbxassetid://78916578261510", 
            "Torso",  -- 修改为正确的父部件名称
            {1, 0.5, 1},
            {0, 0, 0},
            {0, 0, 0}
        )
        
        -- 添加新面具
        addAccessory(
            "NewMask", 
            "rbxassetid://119998744532277", 
            "rbxassetid://85762572283089", 
            "Head", 
            {1, 1, 1},
            {0, 0, 0},
            {0, 260, 0}
        )
        
        -- 完成通知
        WindUI:Notify({
            Title = "Outfit Applied!",
            Content = "Black Outfit Applied",
            Icon = "check",
            Duration = 3
        })
    end
})

Tabs.skin:Button({
    Title = "JohnDoe mafia",
    Icon = "user-tie",  -- 穿西装的人图标，适合黑手党主题
    Callback = function()
        -- 开始处理通知
        WindUI:Notify({
            Title = "Applying Mafia Skin",
            Content = "Applying JohnDoe Mafia Skin...",
            Icon = "user-tie",
            Duration = 2
        })

        -- 获取玩家和角色
        local Player = game:GetService("Players").LocalPlayer
        local Rig = Player.Character 

        -- 加载必要的模块
        local Util = require(game:GetService("ReplicatedStorage").Modules.Util) 
        local C = require(game:GetService("ReplicatedStorage").Assets.Killers.JohnDoe.Config) 
        local B = require(game:GetService("ReplicatedStorage").Assets.Killers.JohnDoe.Behavior) 

        -- 替换动画
        C.Animations.Idle = "rbxassetid://114548717236087"
        C.Animations.Walk = "rbxassetid://113354445309383"
        C.Animations.Run = "rbxassetid://113833842285362"
        C.Animations.Slash = "rbxassetid://119062842291223"
        if not C.Animations.CE then
            C.Animations.CE = "rbxassetid://109589533330665"
        end

        -- 替换Slash能力回调
        B.Abilities.Slash.Callback = function(arg1) 
            local Slash = arg1.Animations.Slash
            Slash:Play()
            Slash:AdjustSpeed(0.7) 
        end

        -- 替换CorruptEnergy能力回调
        B.Abilities.CorruptEnergy.Callback = function(arg1) 
            Util:CreateSpeedMultiplier(arg1.Player, 0, "CorruptEnergy", 2) 
            local CE = arg1.Animations.CE
            CE:Play(1) 
            CE:AdjustSpeed(0.6) 
            task.delay(1.1, function() 
                CE:AdjustSpeed(0) 
            end) 
            task.delay(1.8, function() 
                CE:AdjustSpeed(1)
            end) 
            task.delay(2.1, function() 
                CE:Stop(1) 
            end) 
        end

        -- 配件创建函数
        local function Accs(AccsName, char, Mesh, Texture, Scale, CF, Welded, Angle) 
            local var_1 = Instance.new("Accessory", char) 
            var_1.Name = AccsName
            local var_2 = Instance.new("Part", var_1) 
            var_2.Anchored = false
            var_2.Massless = true
            var_2.CanCollide = false
            var_2.Size = Vector3.new(1, 1, 1) 
            var_2.Name = "Handle"
            local var_3 = Instance.new("SpecialMesh", var_2) 
            var_3.Name = "Mesh"
            var_3.MeshId = Mesh
            var_3.TextureId = Texture
            var_3.Scale = Scale
            local var_4 = Instance.new("Weld", var_2) 
            var_4.C0 = CF * Angle
            var_4.Part0 = var_2
            var_4.Part1 = char[Welded]
        end    

        -- 销毁函数
        local function D(...) 
            local vararg = {...}
            for _, v in pairs(vararg) do
                v:Destroy() 
            end
        end 

        -- 服装函数
        local function cloth(Id1, Id2, Parent) 
            local S = Instance.new("Shirt", Parent) 
            S.ShirtTemplate = Id1
            local P = Instance.new("Pants", Parent) 
            P.PantsTemplate = Id2
        end

        -- 黑手党皮肤加载函数
        local function LoadMafia(P) 
            if P.Name == "JohnDoe" and P:GetAttribute("SkinName") == "" then
                local TorsoIn = P.Torso:GetDescendants() 

                -- 删除原有的John模型
                local johnModel = P:FindFirstChild("John")
                if johnModel then
                    D(johnModel)
                end

                -- 删除粒子发射器
                for _, v in pairs(TorsoIn) do
                    if v:IsA("ParticleEmitter") then
                        v:Destroy() 
                    end
                end

                -- 设置身体部件属性
                local limbsTbl = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
                for _, v in pairs(limbsTbl) do
                    local limb = P:FindFirstChild(v)
                    if limb then
                        limb.Transparency = 0
                        limb.Color = Color3.fromRGB(245, 205, 48) 
                    end
                end
                
                -- 头部透明并添加网格
                local head = P:FindFirstChild("Head")
                if head then
                    head.Transparency = 1
                    local Mesh = Instance.new("SpecialMesh", head) 
                    Mesh.MeshId = "https://assetdelivery.roblox.com/v1/asset/?id=18446596298"
                    Mesh.TextureId = "rbxasset://textures/face.png"
                end

                -- 添加配件
                Accs("Fedora", P, "rbxassetid://15112856144", "rbxassetid://15112916520", Vector3.new(1.1, 1, 1.1), CFrame.new(-0.05, -0.67, 0), "Head", CFrame.Angles(-270, 0, 270)) 
                Accs("Tailcoat", P, "rbxassetid://122484146954331", "rbxassetid://126281090938430", Vector3.new(1, 1, 1.1), CFrame.new(0, 1.8, -0.3), "Torso", CFrame.Angles(0, 0, 0))
                Accs("CoolerFace", P, "rbxassetid://74184851529936", "http://www.roblox.com/asset/?id=135831086414021", Vector3.new(1, 1, 1), CFrame.new(0, 0, 0), "Head", CFrame.Angles(135, 0, 135)) 

                -- 添加服装
                cloth("http://www.roblox.com/asset/?id=12189004570", "http://www.roblox.com/asset/?id=93182020184041", P) 
            end
        end

        -- 应用皮肤
        if Rig then
            LoadMafia(Rig)
        end

        -- 角色重生时重新应用
        Player.CharacterAdded:Connect(function(Rig2) 
            LoadMafia(Rig2) 
        end)

        -- 完成通知
        WindUI:Notify({
            Title = "Skin Changed!",
            Content = "JohnDoe Mafia Skin applied",
            Icon = "check",
            Duration = 3
        })
    end,
    HoverText = "for JohnDoe Applying Mafia Skin…"
})


Tabs.skin:Section({Title = "Guest Skins"})

Tabs.skin:Button({
    Title = "Ninja Guest1337",
    Icon = "user-ninja",  -- 忍者图标
    Callback = function()
        -- 开始处理通知
        WindUI:Notify({
            Title = "Applying Ninja Outfit",
            Content = "Equipping Ninja Outfit...",
            Icon = "user-ninja",
            Duration = 2
        })
        
        -- 获取玩家
        local player = game:GetService("Players").LocalPlayer
        
        -- 删除现有的上衣和裤子
        for _, v in pairs(player.Character:GetChildren()) do
            if v:IsA("Shirt") then
                v:Destroy()
            end

            if v:IsA("Pants") then
                v:Destroy()
            end
        end

        -- 创建新的配件和服装
        local headband = Instance.new("Accessory")
        local scarf = Instance.new("Accessory")
        local shirt = Instance.new("Shirt")
        local pants = Instance.new("Pants")

        local headbandhandle = Instance.new("Part")
        local scarfhandle = Instance.new("Part")
        local headbandhandleattach = Instance.new("Attachment")
        local scarfhandleattach = Instance.new("Attachment")
        local headbandweld = Instance.new("Weld")
        local scarfweld = Instance.new("Weld")

        -- 设置手柄属性
        scarfhandle.Name = "Handle"
        headbandhandle.Name = "Handle"
        scarfhandle.CanCollide = false
        headbandhandle.CanCollide = false

        -- 创建网格
        local headbandmesh = Instance.new("SpecialMesh")
        local scarfmesh = Instance.new("SpecialMesh")

        -- 设置上衣和裤子
        shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=836903658"
        pants.PantsTemplate = "http://www.roblox.com/asset/?id=731578592"
        shirt.Parent = player.Character
        pants.Parent = player.Character

        -- 设置配件层级关系
        headband.Parent = player.Character
        scarf.Parent = player.Character
        scarfhandle.Parent = scarf
        headbandhandle.Parent = headband
        headbandhandleattach.Parent = headbandhandle
        scarfhandleattach.Parent = scarfhandle
        headbandmesh.Parent = headbandhandle
        scarfmesh.Parent = scarfhandle

        -- 设置颜色
        headbandhandle.Color = Color3.fromRGB(27, 42, 53)
        scarfhandle.Color = Color3.fromRGB(27, 42, 53)

        -- 头带焊接
        headbandweld.Parent = headbandhandle
        headbandweld.Name = "AccessoryWeld"
        headbandweld.Part0 = headbandhandle
        headbandweld.Part1 = player.Character.Head
        headbandweld.C0 = CFrame.new(0, 0, 0)
        headbandweld.C1 = CFrame.new(0, 0, 0)

        -- 围巾焊接
        scarfweld.Parent = scarfhandle
        scarfweld.Name = "AccessoryWeld"
        scarfweld.Part0 = scarfhandle
        scarfweld.Part1 = player.Character.Torso
        scarfweld.C0 = CFrame.new(0, -0.4, 0)
        scarfweld.C1 = CFrame.new(0, 0, 0)

        -- 设置网格属性
        headbandmesh.MeshId = "http://www.roblox.com/asset/?id=20407184"
        headbandmesh.Scale = Vector3.new(1.103, 1.071, 1.103)
        scarfmesh.MeshId = "http://www.roblox.com/asset/?id=99856331"
        scarfmesh.Scale = Vector3.new(1.071, 1.071, 1.071)
        scarfmesh.VertexColor = Vector3.new(1, 2, 1)

        -- 设置附件
        headbandhandleattach.Name = "HatAttachment"
        headbandhandleattach.CFrame = CFrame.new(0, 0.557, 0)
        scarfhandleattach.Name = "NeckAttachment"
        scarfhandleattach.CFrame = CFrame.new(0, 0.519, 0)

        -- 更新玩家图标
        local playergui = player.PlayerGui
        local playerinfo = playergui:FindFirstChild("TemporaryUI") and 
                          playergui.TemporaryUI:FindFirstChild("PlayerInfo")
        
        if playerinfo and playerinfo:FindFirstChild("PlayerIcon") then
            playerinfo.PlayerIcon.Image = "http://www.roblox.com/asset/?id=97047410245118"
        end

        -- 完成通知
        WindUI:Notify({
            Title = "Ninja Outfit Applied!",
            Content = "Ninja Skin applied!",
            Icon = "check",
            Duration = 3
        })
    end,
    HoverText = "Equips a ninja Skin for Guest1337"
})


Tabs.skin:Section({Title = "Skin Changer"})

Tabs.skin:Button({
    Title = "Shedletsky Artist",
    Icon = "paint-brush",
    Callback = function()
        -- 初始化服务和变量
        local plrs = game:GetService("Players")
        local lp = plrs.LocalPlayer
        local rs = game:GetService("RunService")
        local db = game:GetService("Debris")
        local tws = game:GetService("TweenService")
        local gui = game:GetService("StarterGui")

        -- 通知函数
        local function notif(t)
            gui:SetCore("SendNotification", {Title = t[1], Text = t[2], Duration = t[3]})
        end

        -- 检查是否正在被观察
        local spec = workspace.Players:FindFirstChild("Spectating")
        if spec and spec:FindFirstChild(lp.Name) then
            notif({"Skin Changer", "You are not the default Shedletsky", 5})
            return
        end

        -- 检查是否有Slash能力
        local ab = lp:WaitForChild("PlayerGui"):WaitForChild("MainUI"):WaitForChild("AbilityContainer")
        if not ab:FindFirstChild("Slash") then
            notif({"yeahh no", "ur not default Shedletsky buuuuddy", 5})
            return
        end

        -- 检查皮肤状态
        local skin = lp:WaitForChild("PlayerData"):WaitForChild("Equipped"):WaitForChild("Skins"):FindFirstChild("Shedletsky")
        if skin and skin.Value ~= "" then
            notif({"Skin Changer", "You are not the default Shedletsky", 5})
            return
        end

        -- 启动通知
        notif({"Skin Changer", "Yuxingchen NOLSAKEN", 5})

        -- 临时购买标记
        local buy = lp:WaitForChild("PlayerData"):WaitForChild("Purchased"):WaitForChild("Skins")
        local temp = Instance.new("IntValue")
        temp.Name = "ArtistShedletsky"
        temp.Value = 0
        temp.Parent = buy
        delay(.1, function() 
            if temp.Parent then 
                temp:Destroy() 
            end 
        end)

        -- 等待角色
        local ch = lp.Character or lp.CharacterAdded:Wait()

        -- 设置上衣
        local s = ch:FindFirstChildOfClass("Shirt")
        if s then s:Destroy() end
        s = Instance.new("Shirt")
        s.ShirtTemplate = "rbxassetid://118042344317053"
        s.Parent = ch

        -- 设置裤子
        local p = ch:FindFirstChildOfClass("Pants")
        if p then p:Destroy() end
        p = Instance.new("Pants")
        p.PantsTemplate = "rbxassetid://100561495134250"
        p.Parent = ch

        -- 头部配件
        local head = ch:FindFirstChild("Head")
        if not head then return end

        local hatoff = Vector3.new(.47, .97, 0)
        local hatrot = Vector3.new(0, -90, 0)
        
        local hat = Instance.new("Accessory")
        hat.Name = "CustomHat"
        hat.Parent = ch

        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.CanCollide = false
        handle.Anchored = false
        handle.Parent = hat

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://102770853506860"
        mesh.TextureId = "rbxassetid://117341189541689"
        mesh.Parent = handle

        handle.CFrame = head.CFrame * CFrame.new(hatoff) * CFrame.Angles(math.rad(hatrot.X), math.rad(hatrot.Y), math.rad(hatrot.Z))

        local weld = Instance.new("WeldConstraint")
        weld.Part0 = head
        weld.Part1 = handle
        weld.Parent = handle

        -- 身体配件
        local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
        if not torso then return end

        local toff = Vector3.new(0, -.34, 0)
        local trot = Vector3.new(0, -90, 0)

        local tacc = Instance.new("Accessory")
        tacc.Name = "CustomTorso"
        tacc.Parent = ch

        local th = Instance.new("Part")
        th.Name = "Handle"
        th.Size = Vector3.new(2, 2, 1)
        th.CanCollide = false
        th.Anchored = false
        th.Parent = tacc

        local tmesh = Instance.new("SpecialMesh")
        tmesh.MeshId = "rbxassetid://122893327645752"
        tmesh.TextureId = "rbxassetid://104104537744071"
        tmesh.Parent = th

        th.CFrame = torso.CFrame * CFrame.new(toff) * CFrame.Angles(math.rad(trot.X), math.rad(trot.Y), math.rad(trot.Z))

        local tw = Instance.new("WeldConstraint")
        tw.Part0 = torso
        tw.Part1 = th
        tw.Parent = th

        -- 脚印效果
        local decs = {
            "http://www.roblox.com/asset/?id=17364186013",
            "http://www.roblox.com/asset/?id=17364186013"
        }
        local cols = {
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(56, 56, 255),
            Color3.fromRGB(255, 30, 30),
            Color3.fromRGB(255, 255, 40),
            Color3.fromRGB(30, 255, 30)
        }

        local function pick(a) 
            return a[math.random(1, #a)] 
        end
        
        local t = 0
        local waitt = 4

        -- 脚印效果循环
        local heartbeatConn
        heartbeatConn = rs.Heartbeat:Connect(function(dt)
            if not ch.Parent then 
                heartbeatConn:Disconnect()
                return 
            end
            t = t + dt
            if t < waitt then return end
            t = 0
            local lf = ch:FindFirstChild("LeftFoot") or ch:FindFirstChild("Left Leg")
            local rf = ch:FindFirstChild("RightFoot") or ch:FindFirstChild("Right Leg")
            if not lf or not rf then return end
            local foot = math.random() < .5 and lf or rf
            local pos = foot.Position - Vector3.new(0, foot.Size.Y/2 + .05, 0)
            local spl = Instance.new("Part")
            spl.Size = Vector3.new(6, .05, 6)
            spl.Anchored = true
            spl.CanCollide = false
            spl.Position = pos
            spl.Parent = workspace
            spl.Transparency = 1
            local d = Instance.new("Decal")
            d.Face = Enum.NormalId.Top
            d.Texture = pick(decs)
            d.Color3 = pick(cols)
            d.Parent = spl
            local goal = {Transparency = 1, Size = Vector3.new(.2, .05, .2)}
            local info = TweenInfo.new(1, Enum.EasingStyle.Linear)
            local tw = tws:Create(spl, info, goal)
            tw:Play()
            db:AddItem(spl, 1.1)
        end)

        -- 动画替换
        local stopid = 116618003477002
        local playid = 77448521277146

        local animConn
        animConn = ch.Humanoid.AnimationPlayed:Connect(function(a)
            if a.Animation.AnimationId == "rbxassetid://" .. stopid then
                a:Stop()
                local newa = Instance.new("Animation")
                newa.AnimationId = "rbxassetid://" .. playid
                local play = ch.Humanoid:LoadAnimation(newa)
                play:Play()
            end
        end)

        -- 更新图标
        local icon = lp.PlayerGui:WaitForChild("TemporaryUI"):WaitForChild("PlayerInfo"):WaitForChild("CurrentSurvivors"):WaitForChild("Shedletsky")
        if icon and icon:FindFirstChild("Icon") and icon:FindFirstChild("Username") then
            local txt = icon.Username.Text
            if txt == lp.Name .. " (You)" then
                icon.Icon.Image = "rbxassetid://110965459998666"
            end
        end


        -- 完成通知
        notif({"Shedletsky Artist", "Skin applied successfully!", 3})
    end,
    HoverText = "Apply Shedletsky artist skin"
})


-- 创建选项卡按钮
Tabs.skin:Button({
    Title = "Shedletsky Armor",
    Icon = "sparkles",
    Callback = function()
        -- 检查是否已应用装扮
        if _G.ShedletskyDressed then
            cleanupDress()
            _G.ShedletskyDressed = false
        else
            dressCharacter()
            _G.ShedletskyDressed = true
        end
    end,
    HoverText = "Apply or remove Shedletsky avatar set"
})

-- 全局变量存储状态
_G.ShedletskyAccessories = _G.ShedletskyAccessories or {}
_G.ShedletskyOriginalFace = nil
_G.ShedletskyOriginalShirt = nil
_G.ShedletskyOriginalPants = nil

-- 应用装扮函数
local function dressCharacter()
    -- 开始通知
    WindUI:Notify({
        Title = "Apply Avatar",
        Content = "Applying Shedletsky avatar...",
        Icon = "sparkles",
        Duration = 2
    })
    
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- 保存原始装扮
    _G.ShedletskyOriginalFace = character:FindFirstChild("face")
    _G.ShedletskyOriginalShirt = character:FindFirstChildOfClass("Shirt")
    _G.ShedletskyOriginalPants = character:FindFirstChildOfClass("Pants")
    
    -- 设置上衣
    local shirt = character:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", character)
    shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=14248399102"
    
    -- 设置裤子
    local pants = character:FindFirstChildOfClass("Pants") or Instance.new("Pants", character)
    pants.PantsTemplate = "http://www.roblox.com/asset/?id=14248410313"
    
    -- 删除原有脸部
    local head = character:FindFirstChild("Head")
    if head then
        local face = head:FindFirstChild("face")
        if face then
            face:Destroy()
        end
    end
    
    -- 添加配饰的函数
    local function addAccessory(name, meshId, textureId, parentPartName, handleSize, position, rotation, meshScale, meshOffset)
        local accessory = Instance.new("Accessory")
        accessory.Name = name
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(unpack(handleSize))
        handle.CanCollide = false
        handle.Anchored = false
        handle.Parent = accessory
        
        local mesh = Instance.new("SpecialMesh", handle)
        mesh.MeshId = meshId
        if textureId ~= "" then
            mesh.TextureId = textureId
        end
        mesh.Scale = meshScale and Vector3.new(unpack(meshScale)) or Vector3.new(0.65, 0.65, 0.65)
        mesh.Offset = meshOffset and Vector3.new(unpack(meshOffset)) or Vector3.new(0, -0.55, 0)
        
        local targetPart = character:FindFirstChild(parentPartName)
        if not targetPart then return end
        
        local weld = Instance.new("Weld")
        weld.Part0 = targetPart
        weld.Part1 = handle
        weld.C0 = CFrame.new(unpack(position)) * CFrame.Angles(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))
        weld.Parent = handle
        
        table.insert(_G.ShedletskyAccessories, accessory)
        accessory.Parent = character
    end
    
    -- 添加所有配饰
    addAccessory("Face", "rbxassetid://110562243236643", "rbxassetid://92220809340639", "Head", {1,1,1}, {0,0.55,0}, {0,180,0}, {1,1,1})
    addAccessory("Blade", "rbxassetid://18116147526", "rbxassetid://18955600612", "Right Arm", {1,1,1}, {-0.5,-1.1,-3.3}, {180,-100,0}, {1,1,1})
    addAccessory("Helmet", "rbxassetid://13252936277", "rbxassetid://13252949489", "Head", {1,1,1}, {0,0.8,0}, {0,0,0}, {1.1,1,1})
    addAccessory("Scarf", "rbxassetid://7459110498", "rbxassetid://7543326394", "Torso", {1,1,1}, {0,1.4,0}, {0,0,0}, {1,1,1})
    addAccessory("LeftSleeve", "rbxassetid://14886992040", "rbxassetid://14887049482", "Left Arm", {1,1,1}, {0,1.2,0}, {0,0,0}, {0.15,0.15,0.15})
    addAccessory("Hair", "rbxassetid://7666931987", "rbxassetid://7066058408", "Head", {1,1,1}, {0,-1.3,1.3}, {0,0,0}, {1,1,1})
    addAccessory("RightSleeve", "rbxassetid://7265541707", "rbxassetid://7265983163", "Right Arm", {1,1,1}, {0.25,1.5,0}, {0,0,0}, {1,1,1})
    
    -- 清理Shedletsky模型
    local shedletsky = workspace.Players.Survivors:FindFirstChild("Shedletsky")
    if shedletsky then
        for _, child in ipairs({"ExpressionHolder", "ShedHair", "Sword"}) do
            local part = shedletsky:FindFirstChild(child)
            if part then part:Destroy() end
        end
    end
    
    -- 更新按钮标题
    Tabs.skin:UpdateButton("Shedletsky Changer", {
        Title = "Remove Shedletsky Changer",
        Icon = "brush"
    })
    
    -- 完成通知
    WindUI:Notify({
        Title = "Shedletsky Changer",
        Content = "Avatar applied!",
        Icon = "check",
        Duration = 3
    })
end

-- 移除装扮函数
local function cleanupDress()
    -- 删除所有配饰
    for _, accessory in ipairs(_G.ShedletskyAccessories) do
        if accessory and accessory.Parent then
            accessory:Destroy()
        end
    end
    _G.ShedletskyAccessories = {}
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        -- 恢复脸部
        local head = character:FindFirstChild("Head")
        if head and _G.ShedletskyOriginalFace then
            _G.ShedletskyOriginalFace:Clone().Parent = head
        end
        
        -- 恢复上衣
        if _G.ShedletskyOriginalShirt then
            _G.ShedletskyOriginalShirt:Clone().Parent = character
        else
            local shirt = character:FindFirstChildOfClass("Shirt")
            if shirt then shirt:Destroy() end
        end
        
        -- 恢复裤子
        if _G.ShedletskyOriginalPants then
            _G.ShedletskyOriginalPants:Clone().Parent = character
        else
            local pants = character:FindFirstChildOfClass("Pants")
            if pants then pants:Destroy() end
        end
    end
    
    -- 更新按钮标题
    Tabs.skin:UpdateButton("Shedletsky Changer", {
        Title = "Shedletsky Changer",
        Icon = "sparkles"
    })
    
    -- 完成通知
    WindUI:Notify({
        Title = "Shedletsky Changer",
        Content = "Avatar deleted!",
        Icon = "check",
        Duration = 3
    })
end

-- 初始化按钮状态
_G.ShedletskyDressed = false





Tabs.skin:Section({Title = "Avatar Changer"})

Tabs.skin:Button({
    Title = "Family-Guy Peter",
    Icon = "smile",
    Callback = function()
        -- 开始处理通知
        WindUI:Notify({
            Title = "Applying Petah Head",
            Content = "Applying Petah Avatar...",
            Icon = "smile",
            Duration = 2
        })

        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()

        -- 设置身体颜色为黑色
        local bodyColors = character:FindFirstChild("Body Colors")
        if bodyColors then
            local black = BrickColor.new("Really black")
            bodyColors.HeadColor = black
            bodyColors.LeftArmColor = black
            bodyColors.RightArmColor = black
            bodyColors.LeftLegColor = black
            bodyColors.RightLegColor = black
            bodyColors.TorsoColor = black
        end

        -- 应用上衣和裤子
        local shirt = character:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", character)
        shirt.ShirtTemplate = "http://www.roblox.com/asset/?id=15689522455"

        local pants = character:FindFirstChildOfClass("Pants") or Instance.new("Pants", character)
        pants.PantsTemplate = "http://www.roblox.com/asset/?id=4959593720"

        -- 添加配饰的函数
        local function addAccessory(name, meshId, textureId, parentPartName, handleSize, position, rotation, customWeldC0, customWeldC1, meshScale, meshOffset)
            local accessory = Instance.new("Accessory")
            accessory.Name = name

            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(unpack(handleSize))
            handle.CanCollide = false
            handle.Anchored = false
            handle.Parent = accessory

            local mesh = Instance.new("SpecialMesh", handle)
            mesh.MeshId = meshId
            mesh.TextureId = textureId
            mesh.Scale = meshScale and Vector3.new(unpack(meshScale)) or Vector3.new(1, 1, 1)
            mesh.Offset = meshOffset and Vector3.new(unpack(meshOffset)) or Vector3.new(0, 0, 0)

            local targetPart = character:FindFirstChild(parentPartName)
            if not targetPart then
                warn("Target part '" .. parentPartName .. "' not found in character!")
                return
            end

            local weld = Instance.new("Weld")
            weld.Part0 = targetPart
            weld.Part1 = handle

            if customWeldC0 and customWeldC1 then
                weld.C0 = CFrame.new(unpack(customWeldC0))
                weld.C1 = CFrame.new(unpack(customWeldC1))
            else
                weld.C0 = CFrame.new(unpack(position)) * CFrame.Angles(math.rad(rotation[1]), math.rad(rotation[2]), math.rad(rotation[3]))
            end

            weld.Parent = handle
            accessory.Parent = character
        end

        -- 添加Petah头套
        addAccessory(
            "Petah",
            "http://www.roblox.com/asset/?id=16059554270",  -- Mesh ID
            "http://www.roblox.com/asset/?id=16059557343", -- Texture ID
            "Head", -- Attach to Head
            {1.54557204246521, 1.6104363203048706, 1.7840479612350464}, -- Handle size
            {0, -0.1, -0.05}, -- Position offset
            {-177.0240020751953, -4.697999954223633, -179.7570037841797}, -- Rotation
            nil, nil,
            {1.1, 1.1, 1.1}, -- Mesh scale
            nil
        )

        -- 头部透明
        local head = character:FindFirstChild("Head")
        if head then
            head.Transparency = 1
        end
        
        -- 表情透明
        local ExpressionHolder = character:FindFirstChild("ExpressionHolder")
        if ExpressionHolder then
            local expression = ExpressionHolder:FindFirstChild("Expression")
            if expression then
                expression.Transparency = 1
            end
        end

        -- 删除头发
        local hair = character:FindFirstChild("CoolBoyHair")
        if hair then
            hair:Destroy()
        end

        -- 完成通知
        WindUI:Notify({
            Title = "Petah Avatar Applied!",
            Content = "Petah Avatar set applied",
            Icon = "check",
            Duration = 3
        })
    end,
    HoverText = "Apply Petah Avatar Set (Avatar Transparency + Black Clothing)"
})




Tabs.skin:Button({
    Title = "Yourself",
    Icon = "brush",
    Callback = function()
        -- 开始处理通知
        WindUI:Notify({
            Title = "Applying Skin",
            Content = "Applying skin effect...",
            Icon = "brush",
            Duration = 2
        })

        -- 原始代码开始 - 未做任何修改
        local P = game:GetService("Players").LocalPlayer.Character

        local Player = game:GetService("Players").LocalPlayer

        local desc = game.Players:GetHumanoidDescriptionFromUserId(Player.UserId) 

        local blankdesc = Instance.new("HumanoidDescription") 

        local Yourself = game.Players:CreateHumanoidModelFromDescription(blankdesc, Enum.HumanoidRigType.R6) 
        Yourself.Parent = workspace.Players
        Yourself.PrimaryPart.CFrame = P.PrimaryPart.CFrame
        Yourself.Humanoid:ApplyDescription(desc) 
        local function resetYourself() 
            if not Yourself then return end
            Yourself:Destroy() 
        end
        P.Humanoid.Died:Connect(function()
            delay(5, function() 
                resetYourself() 
            end) 
        end) 
        Player.CharacterAdded:Connect(resetYourself) 

        if P.Name == "Slasher" and P:GetAttribute("SkinName") == "" then
            P["Slasher Export"]:Destroy() 
            P.Mask:Destroy() 
        elseif P.Name == "c00lkidd" and P:GetAttribute("SkinName") == "" then
            P.coolkiddrblx:Destroy() 
        elseif P.Name == "1x1x1x1" and P:GetAttribute("SkinName") == "" then
            P.Highlight:Clone().Parent = Yourself
            P.Highlight.Adornee = P.ExtraModels
            P.Head.face:Destroy() 
            P.Head.face:Destroy()
            P.ExtraModels.GlowyTorso:Destroy() 
            Yourself.Highlight.FillColor = Color3.fromRGB(148, 148, 148) 

            local BillboardGui = Instance.new("BillboardGui", Yourself.Head)
            BillboardGui.Size = UDim2.new(0.7, 0, 0.7, 0)
            BillboardGui.Adornee = BillboardGui.Parent
            BillboardGui.Enabled = true
            BillboardGui.AlwaysOnTop = true
            BillboardGui.Active = true

            local Censor = Instance.new("TextLabel", BillboardGui)
            Censor.Text = ""
            Censor.Size = UDim2.new(2, 0, 2, 0)
            Censor.BackgroundColor3 = Color3.new(0, 0, 0)
            Censor.BorderColor3 = Color3.new(1, 1, 1)
            Censor.BorderSizePixel = 0
            Censor.Position = UDim2.new(-0.5, 0, -0.5, 0)
            Censor.TextColor3 =  Color3.new(0, 0, 0)
        elseif P.Name == "JohnDoe" and P:GetAttribute("SkinName") == "" then
            P.John["Left Arm"]["Left Claws"].Parent = P.John
            local weld = Instance.new("Weld", P.John["Left Claws"]) 
            weld.Part0 = P["Left Arm"]
            weld.Part1 = weld.Parent
            weld.C1 = CFrame.new(0, 1.5, 0) 
            P.John.Head:Destroy() 
            P.John.Torso:Destroy() 
            P.John["Left Arm"]:Destroy() 
            P.John["Left Leg"]:Destroy() 
            P.John["Right Leg"]:Destroy() 
            Yourself["Right Arm"].Transparency = 1
            P.John["Spike Arm"].SurfaceAppearance:Destroy() 
            P.John["Spike Arm"].Color = Yourself["Right Arm"].Color
            P.John["Left Claws"].SurfaceAppearance:Destroy() 
            P.John["Left Claws"].Color = Yourself["Left Arm"].Color
        elseif P.Name == "Nosferatu" and P:GetAttribute("SkinName") == "" then
            for _, v in pairs(P.Nos:GetChildren()) do
                if v:IsA("MeshPart") or v:IsA("Model") then
                    if v.Name ~= "Hair Base" then
                        v:Destroy() 
                    end
                end
            end

            for _, v in pairs(Yourself:GetDescendants()) do
                spawn(function() while wait() do
                    if not P.Parent then return end
                    if v:IsA("BasePart") then
                        v.Transparency = P.Nos["Hair Base"].Transparency
                    end
                end end) 
            end
        elseif P.Name == "Noli" and P:GetAttribute("SkinName") == "" then
            P.Noli:Destroy() 
        end

        Yourself.Humanoid.DisplayDistanceType = ("None") 
        Yourself.Humanoid.EvaluateStateMachine = false
        local JointHrp = Instance.new("Weld")
        JointHrp.Part0 = Yourself.PrimaryPart
        JointHrp.Part1 = P.PrimaryPart
        Yourself:WaitForChild("Animate"):Destroy() 
        for _, v in pairs(Yourself:GetDescendants()) do
            if v:IsA("BasePart") then
                spawn(function() while wait() do
                    if not v then return end
                    v.Massless = true
                    v.CanCollide = false
                end end) 
            elseif v:IsA("Motor6D") then
                v.Enabled = false
            end
        end

        local limbsTbl = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

        for _, limbs in pairs(limbsTbl) do
            local Joints = Instance.new("Weld", P[limbs]) 
            Joints.Name = limbs.. "JointForYourself"
            Joints.Part0 = P[limbs]
            Joints.Part1 = Yourself[limbs]
            spawn(function() while wait() do
                local suc = pcall(function() 
                if P[limbs].Transparency ~= 1 then
                    P[limbs].Transparency = 1
                end
                end) 
            end end) 
        end
        -- 原始代码结束

        -- 完成通知
        WindUI:Notify({
            Title = "Skin Applied!",
            Content = "Skin effect applied successfully",
            Icon = "check",
            Duration = 3
        })
    end,
    HoverText = "Apply Character Skin Effect"
})

	end,
	DoubleClick = true,
	Tooltip = "Load",
	DisabledTooltip = "disabled!",
	Disabled = false,
	Visible = true,
	Risky = false,
})





load:AddLabel("double click to load")



local new = Tabs.new:AddLeftGroupbox('Update🚀')

new:AddLabel("[+]New ESP,Fix ESP Johndoe Trap")

new:AddLabel("[+]Fix Auto Block")

new:AddLabel("[+]Add a replica of Fartsaken's Block")

new:AddLabel("[+]Fix HitBox Track")

new:AddLabel("[+]Fix TwoTime Backstab")

new:AddLabel("[+]Fix John doe Auto 404")

new:AddLabel("[+]Optimize Chance Aimbot")

new:AddLabel("[+]Fix FieldOfView")

new:AddLabel("[+]Dev Yuxingchen")




local KillerSurvival = Tabs.Main:AddRightGroupbox('Chat Visibility')

KillerSurvival:AddToggle('AlwaysShowChat', {
        Text = "Show Chat",
        Callback = function(state)
            if state then
                _G.showChat = true
                task.spawn(function()
                    while _G.showChat and task.wait() do
                        game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration").Enabled = true
                    end
                end)
            else
                _G.showChat = false
                if playingState ~= "Spectating" then
                    game:GetService("TextChatService"):FindFirstChildOfClass("ChatWindowConfiguration").Enabled = false
                end
            end
        end
    })

    function panic()
        for i, v in pairs(Toggles) do
            pcall(function()
                if v.Value == false then return end
                v:SetValue(false)
            end)
        end
    end

    Library:OnUnload(function()
        _G.VoidsakenExecuted = false
        panic()
        getgenv().FlipUI:Destroy()
        getgenv().AimbotUI:Destroy()
        getgenv().BlockUI:Destroy()
    end)




local ZZ = Tabs.Main:AddRightGroupbox('Auto Pickup Items')


ZZ:AddToggle('Auto Pickup Medkit', {
    Text = 'Auto Use Medkit',
    Default = false,
    Tooltip = 'Auto Interact with Medkit',
    
    Callback = function(state)
        autoMedkitEnabled = state
        
        if autoMedkitEnabled then
            medkitThread = task.spawn(function()
                while autoMedkitEnabled and task.wait(0.5) do
                    local medkit = workspace:FindFirstChild("Map", true)
                    if medkit then
                        medkit = medkit:FindFirstChild("Ingame", true)
                        if medkit then
                            medkit = medkit:FindFirstChild("Medkit", true)
                            if medkit then
                                local itemRoot = medkit:FindFirstChild("ItemRoot", true)
                                if itemRoot then
                                    local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                    if prompt then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        elseif medkitThread then
            task.cancel(medkitThread)
            medkitThread = nil
        end
    end
})


ZZ:AddToggle('Auto Pick Up Cola', {
    Text = 'Auto use Cola',
    Default = false,
    Tooltip = 'Auto Interact with Cola',
    
    Callback = function(state)
        autoColaEnabled = state
        
        if autoColaEnabled then
            colaThread = task.spawn(function()
                while autoColaEnabled and task.wait(0.5) do
                    local cola = workspace:FindFirstChild("Map", true)
                    if cola then
                        cola = cola:FindFirstChild("Ingame", true)
                        if cola then
                            cola = cola:FindFirstChild("BloxyCola", true)
                            if cola then
                                local itemRoot = cola:FindFirstChild("ItemRoot", true)
                                if itemRoot then
                                    local prompt = itemRoot:FindFirstChild("ProximityPrompt", true)
                                    if prompt then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        elseif colaThread then
            task.cancel(colaThread)
            colaThread = nil
        end
    end
})


local FPS = Tabs.Main:AddLeftGroupbox('FPS')



FPS:AddToggle("MyToggle1", {
    Text = "Unlock FPS",
    Default = false,
    Callback = function(Value)
        local function setfpscap(fps)
            if setfpscap then
                setfpscap(fps)
            else
                local RunService = game:GetService("RunService")
                RunService:SetRenderFPS(fps)
            end
        end
        
        if Value then
            setfpscap(1000000)
        else
            setfpscap(60)
        end
    end,
})


FPS:AddButton({
	Text = "Lower FPS",
	Func = function()
	
	local lighting = game:GetService("Lighting")
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 0
        end
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart")
                or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 0
                v.BlastRadius = 0
            end
        end
	
	
	

	end,
	DoubleClick = false,
	Tooltip = "Loading...",
	DisabledTooltip = "Disabled!",
	Disabled = false,
	Visible = true,
	Risky = false,
})






local MainTabbox = Tabs.Main:AddLeftTabbox()
local Lighting = MainTabbox:AddTab("Brightness Value")
local Camera = MainTabbox:AddTab("Fold of View")

local lightingConnection
local cameraConnection

Lighting:AddSlider("B", {
    Text = "Brightness Value",
    Min = 0,
    Default = 0,
    Max = 3,
    Rounding = 1,
    Compact = true,
    Callback = function(v)
        _env.Brightness = v
    end
})

Lighting:AddToggle("No Shadow", {
    Text = "No Shadow",
    Default = false,
    Callback = function(v)
        _env.GlobalShadows = v
    end
})

Lighting:AddToggle("no fog", {
    Text = "no fog",
    Default = false,
    Callback = function(v)
        _env.NoFog = v
    end
})

Lighting:AddDivider()

Lighting:AddToggle("Enable Feature", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(v)
        _env.Fullbright = v
        
        if lightingConnection then
            lightingConnection:Disconnect()
            lightingConnection = nil
        end
        
        if v then
            lightingConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not game.Lighting:GetAttribute("FogStart") then 
                    game.Lighting:SetAttribute("FogStart", game.Lighting.FogStart) 
                end
                if not game.Lighting:GetAttribute("FogEnd") then 
                    game.Lighting:SetAttribute("FogEnd", game.Lighting.FogEnd) 
                end
                
                game.Lighting.FogStart = _env.NoFog and 0 or game.Lighting:GetAttribute("FogStart")
                game.Lighting.FogEnd = _env.NoFog and math.huge or game.Lighting:GetAttribute("FogEnd")
                
                local fog = game.Lighting:FindFirstChildOfClass("Atmosphere")
                if fog then
                    if not fog:GetAttribute("Density") then 
                        fog:SetAttribute("Density", fog.Density) 
                    end
                    fog.Density = _env.NoFog and 0 or fog:GetAttribute("Density")
                end
                
                game.Lighting.OutdoorAmbient = Color3.new(1,1,1)
                game.Lighting.Brightness = _env.Brightness or 0
                game.Lighting.GlobalShadows = not _env.GlobalShadows
            end)
        else
            game.Lighting.OutdoorAmbient = Color3.fromRGB(55,55,55)
            game.Lighting.Brightness = 0
            game.Lighting.GlobalShadows = true
        end
    end
})

local FOVEnabled = true
local FOVValue = 80

Camera:AddToggle("FieldOfViewToggle", {
    Text = "Enable FOV Changer",
    Default = true,
    Callback = function(Enabled)
        FOVEnabled = Enabled
        local FieldOfView = game:GetService("Players").LocalPlayer.PlayerData.Settings.Game.FieldOfView
        if FieldOfView then
            if Enabled then
                FieldOfView.Value = FOVValue
            else
                FieldOfView.Value = 80
            end
        end
    end,
})

Camera:AddSlider("FieldOfView", {
    Text = "Field of View (FOV)",
    Default = 80,
    Min = 0,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        FOVValue = Value
        if FOVEnabled then
            local FieldOfView = game:GetService("Players").LocalPlayer.PlayerData.Settings.Game.FieldOfView
            if FieldOfView then
                FieldOfView.Value = Value
            end
        end
    end,
})

local LOL = Tabs.Bro:AddRightTabbox()
local SM = LOL:AddTab("HitBox Tracking")


local HitboxTrackingEnabled = false
local HeartbeatConnection = nil
local MaxDistance = 120
local FilterSurvivors = false
local FilterKillers = false
local WallCheckEnabled = false 
local TrackSubspaceTripmine = false
local TrackBuildermanDispenser = false
local TrackBuildermanSentry = false

local Killers = {
    ["Slasher"] = true, ["1x1x1x1"] = true, ["c00lkidd"] = true,
    ["Noli"] = true, ["JohnDoe"] = true, ["Guest 666"] = true,
    ["Sixer"] = true, ["Nosferatu"]=true
}
local Survivors = {
    ["Noob"] = true, ["Guest1337"] = true, ["Elliot"] = true,
    ["Shedletsky"] = true, ["TwoTime"] = true, ["007n7"] = true,
    ["Chance"] = true, ["Builderman"] = true, ["Taph"] = true,
    ["Dusekkar"] = true, ["Veeronica"] = true
}

local AttackAnimations = {
    'rbxassetid://131430497821198',
    'rbxassetid://83829782357897',
    'rbxassetid://126830014841198',
    'rbxassetid://126355327951215',
    'rbxassetid://121086746534252',
    'rbxassetid://105458270463374',
    'rbxassetid://18885909645',
    'rbxassetid://87259391926321',
    'rbxassetid://106014898528300',
    'rbxassetid://86545133269813',
    'rbxassetid://89448354637442',
    'rbxassetid://90499469533503',
    'rbxassetid://116618003477002',
    'rbxassetid://106086955212611',
    'rbxassetid://107640065977686',
    'rbxassetid://77124578197357',
    'rbxassetid://101771617803133',
    'rbxassetid://134958187822107',
    'rbxassetid://111313169447787',
    'rbxassetid://71685573690338',
    'rbxassetid://129843313690921',
    'rbxassetid://97623143664485',
    'rbxassetid://136007065400978',
    'rbxassetid://86096387000557',
    'rbxassetid://108807732150251',
    'rbxassetid://138040001965654',
    'rbxassetid://73502073176819',
    'rbxassetid://86709774283672',
    'rbxassetid://140703210927645',
    'rbxassetid://96173857867228',
    'rbxassetid://121255898612475',
    'rbxassetid://98031287364865',
    'rbxassetid://119462383658044',
    'rbxassetid://77448521277146',
    'rbxassetid://103741352379819',
    'rbxassetid://131696603025265',
    'rbxassetid://122503338277352',
    'rbxassetid://97648548303678',
    'rbxassetid://94162446513587',
    'rbxassetid://84426150435898',
    'rbxassetid://93069721274110',
    'rbxassetid://114620047310688',
    'rbxassetid://97433060861952',
    'rbxassetid://82183356141401',
    'rbxassetid://100592913030351',
    'rbxassetid://121293883585738',
    'rbxassetid://70447634862911',
    'rbxassetid://92173139187970',
    'rbxassetid://106847695270773',
    'rbxassetid://125403313786645',
    'rbxassetid://81639435858902',
    'rbxassetid://137314737492715',
    'rbxassetid://120112897026015',
    'rbxassetid://82113744478546',
    'rbxassetid://118298475669935',
    'rbxassetid://126681776859538',
    'rbxassetid://129976080405072',
    'rbxassetid://109667959938617',
    'rbxassetid://74707328554358',
    'rbxassetid://133336594357903',
    'rbxassetid://86204001129974',
    'rbxassetid://124243639579224',
    'rbxassetid://70371667919898',
    'rbxassetid://131543461321709',
    'rbxassetid://136323728355613',
    'rbxassetid://109230267448394',
    'rbxassetid://139835501033932',
    'rbxassetid://106538427162796',
    'rbxassetid://110400453990786',
    'rbxassetid://83685305553364',
    'rbxassetid://126171487400618',
    'rbxassetid://122709416391891',
    'rbxassetid://87989533095285',
    'rbxassetid://119326397274934',
    'rbxassetid://140365014326125',
    'rbxassetid://139309647473555',
    'rbxassetid://133363345661032',
    'rbxassetid://128414736976503',
    'rbxassetid://121808371053483',
    'rbxassetid://88451353906104',
    'rbxassetid://81299297965542',
    'rbxassetid://99829427721752',
    'rbxassetid://126896426760253',
    'rbxassetid://77375846492436',
    'rbxassetid://94634594529334',
    'rbxassetid://101031946095087',
    'rbxassetid://84069821282466',
    'rbxassetid://90620531468240',
    'rbxassetid://114506382930939',
    'rbxassetid://130958529065375',
    'rbxassetid://126727756047566',
    'rbxassetid://94958041603347',
    'rbxassetid://110702884830060',
    'rbxassetid://131642454238375',
    'rbxassetid://138938529389204',
    'rbxassetid://108018357044094',
    'rbxassetid://100725497418533',
    'rbxassetid://131082534135875',
    'rbxassetid://83251433279852',
    'rbxassetid://88970503168421',
    'rbxassetid://96571077893813',
    'rbxassetid://97167027849946',
    'rbxassetid://98456918873918',
    'rbxassetid://106776364623742',
    'rbxassetid://109700476007435',
    'rbxassetid://114356208094580',
    'rbxassetid://124705663396411',
    'rbxassetid://93366464803829',
    'rbxassetid://98590570796574',
    'rbxassetid://114152086302685',
    'rbxassetid://18885906143',
    'rbxassetid://73833636394121',
    'rbxassetid://92645737884601',
    'rbxassetid://86451881483688',
    'rbxassetid://119062842291223',
    'rbxassetid://124269076578545'
}
SM:AddSlider("DistanceSlider", {
    Text = "Tracking Range",
    Default = 120,
    Min = 1,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        MaxDistance = value
    end
})

SM:AddToggle("FilterSurvivorsToggle", {
    Text = "Filter [Non-Tracking] Survivors",
    Default = false,
    Callback = function(state)
        FilterSurvivors = state
    end
})

SM:AddToggle("FilterKillersToggle", {
    Text = "Filter [Non-Tracking] Killers",
    Default = false,
    Callback = function(state)
        FilterKillers = state
    end
})


SM:AddToggle("WallCheckToggle", {
    Text = "Wallcheck",
    Default = false,
    Callback = function(state)
        WallCheckEnabled = state
    end
})

SM:AddToggle("TrackSubspaceTripmine", {
    Text = "Track Subspace Tripmine",
    Default = false,
    Callback = function(state)
        TrackSubspaceTripmine = state
    end
})

SM:AddToggle("TrackBuildermanDispenser", {
    Text = "Track Builderman Dispenser",
    Default = false,
    Callback = function(state)
        TrackBuildermanDispenser = state
    end
})

SM:AddToggle("TrackBuildermanSentry", {
    Text = "Track Builderman Sentry",
    Default = false,
    Callback = function(state)
        TrackBuildermanSentry = state
    end
})

SM:AddToggle("HitboxTrackingToggle", {
    Text = "Hitbox Tracking",
    Default = false,
    Callback = function(state)
        HitboxTrackingEnabled = state
        
        if HeartbeatConnection then
            HeartbeatConnection:Disconnect()
            HeartbeatConnection = nil
        end
        
        if not state then return end
        
        repeat task.wait() until game:IsLoaded();

        local Players = game:GetService('Players');
        local Player = Players.LocalPlayer;
        local Character = Player.Character or Player.CharacterAdded:Wait();
        local Humanoid = Character:WaitForChild("Humanoid");
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");

        Player.CharacterAdded:Connect(function(NewCharacter)
            Character = NewCharacter;
            Humanoid = Character:WaitForChild("Humanoid");
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
        end);

        local RNG = Random.new();
        local RaycastParams = RaycastParams.new()  
        RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        RaycastParams.IgnoreWater = true
        
        
        local function isTargetVisible(targetCharacter)
            if not WallCheckEnabled or not targetCharacter or not targetCharacter:FindFirstChild("HumanoidRootPart") then
                return true
            end
            
            local targetHRP = targetCharacter.HumanoidRootPart
            local origin = HumanoidRootPart.Position
            local direction = (targetHRP.Position - origin).Unit
            local distance = (targetHRP.Position - origin).Magnitude
            
           
            local filterList = {Character, targetCharacter}
            RaycastParams.FilterDescendantsInstances = filterList
            
            local rayResult = workspace:Raycast(origin, direction * distance, RaycastParams)
            
           
            if not rayResult then
                return true
            end
            
        
            local hitInstance = rayResult.Instance
            if hitInstance and hitInstance:IsDescendantOf(targetCharacter) then
                return true
            end
            
            
            return false
        end
        
        local function getCharacterRole(character)
            local modelName = character.Name
            if Killers[modelName] then
                return "Killer"
            elseif Survivors[modelName] then
                return "Survivor"
            end
            return "Unknown"
        end
        
        local function findTrackableObjects()
            local objects = {}
            
            if TrackSubspaceTripmine then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "SubspaceTripmine" and obj:IsA("Model") and obj.PrimaryPart then
                        table.insert(objects, obj)
                    end
                end
            end
            
            if TrackBuildermanDispenser then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "BuildermanDispenser" and obj:IsA("Model") and obj.PrimaryPart then
                        table.insert(objects, obj)
                    end
                end
            end
            
            if TrackBuildermanSentry then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "BuildermanSentry" and obj:IsA("Model") and obj.PrimaryPart then
                        table.insert(objects, obj)
                    end
                end
            end
            
            return objects
        end
        
        HeartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
            if not HitboxTrackingEnabled or not HumanoidRootPart then
                return;
            end

            local Playing = false;
            for _,v in Humanoid:GetPlayingAnimationTracks() do
                if table.find(AttackAnimations, v.Animation.AnimationId) and (v.TimePosition / v.Length < 0.75) then
                    Playing = true;
                end
            end

            if not Playing then
                return;
            end

            local PlayerRole = getCharacterRole(Character)
            local OppositeTable = nil
            if PlayerRole == "Killer" then
                OppositeTable = Survivors
            elseif PlayerRole == "Survivor" then
                OppositeTable = Killers
            end

            local Target = nil
            local CurrentNearestDist = MaxDistance

            local OppTarget = nil
            local OppNearestDist = MaxDistance

            local function loopForOpp(t)
                for _,v in pairs(t) do
                    if v == Character or not v:FindFirstChild("HumanoidRootPart") or not v:FindFirstChild("Humanoid") then
                        continue
                    end
                    
                 
                    if WallCheckEnabled and not isTargetVisible(v) then
                        continue
                    end
                    
                    local modelName = v.Name
                    if OppositeTable and OppositeTable[modelName] then
                        local Dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                        if Dist < OppNearestDist then
                            OppNearestDist = Dist
                            OppTarget = v
                        end
                    end
                end
            end

            if OppositeTable then
                loopForOpp(workspace.Players:GetDescendants())
                local npcsFolder = workspace.Map:FindFirstChild("NPCs", true)
                if npcsFolder then
                    loopForOpp(npcsFolder:GetChildren())
                end
            end

            local function loopAll(t)
                for _,v in pairs(t) do
                    if v == Character or not v:FindFirstChild("HumanoidRootPart") or not v:FindFirstChild("Humanoid") then
                        continue
                    end
                    
                   
                    if WallCheckEnabled and not isTargetVisible(v) then
                        continue
                    end
                    
                    local characterRole = getCharacterRole(v)
                    
                    if FilterSurvivors and characterRole == "Survivor" then
                        continue
                    end
                    if FilterKillers and characterRole == "Killer" then
                        continue
                    end
                    
                    if PlayerRole == "Killer" and characterRole == "Killer" then
                        continue
                    end
                    if PlayerRole == "Survivor" and characterRole == "Survivor" then
                        continue
                    end
                    
                    local Dist = (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
                    if Dist < CurrentNearestDist then
                        CurrentNearestDist = Dist
                        Target = v
                    end
                end
            end

            local trackableObjects = findTrackableObjects()
            local NearestObject = nil
            local NearestObjectDist = MaxDistance
            
            for _, obj in ipairs(trackableObjects) do
                if obj.PrimaryPart then
                    local Dist = (obj.PrimaryPart.Position - HumanoidRootPart.Position).Magnitude
                    if Dist < NearestObjectDist then
                        NearestObjectDist = Dist
                        NearestObject = obj
                    end
                end
            end

            local FinalTarget = nil
            if OppTarget then
                FinalTarget = OppTarget
            elseif NearestObject and NearestObjectDist < CurrentNearestDist then
                FinalTarget = NearestObject
            else
                loopAll(workspace.Players:GetDescendants())
                local npcsFolder2 = workspace.Map:FindFirstChild("NPCs", true)
                if npcsFolder2 then
                    loopAll(npcsFolder2:GetChildren())
                end
                FinalTarget = Target
            end

            if not FinalTarget then
                return;
            end

            local targetPart = FinalTarget:FindFirstChild("HumanoidRootPart") or FinalTarget.PrimaryPart
            if not targetPart then
                return
            end

            local OldVelocity = HumanoidRootPart.Velocity;
            local NeededVelocity =
            (targetPart.Position + Vector3.new(
                RNG:NextNumber(-1.5, 1.5),
                0,
                RNG:NextNumber(-1.5, 1.5)
            ) + (targetPart.Velocity * (Player:GetNetworkPing() * 1.25))
                - HumanoidRootPart.Position
            ) / (Player:GetNetworkPing() * 2);

            HumanoidRootPart.Velocity = NeededVelocity;
            game:GetService('RunService').RenderStepped:Wait();
            HumanoidRootPart.Velocity = OldVelocity;
        end);
    end,
})

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MVP = Tabs.Sat:AddLeftGroupbox("Stamina")

local StaminaSettings = {
    MaxStamina = 100,
    StaminaGain = 25,
    StaminaLoss = 10,
    SprintSpeed = 28,
    InfiniteGain = 9999
}

local SettingToggles = {
    MaxStamina = false,
    StaminaGain = false,
    StaminaLoss = false,
    SprintSpeed = false
}

local SprintingModule = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Character"):WaitForChild("Game"):WaitForChild("Sprinting")
local GetModule = function() return require(SprintingModule) end

task.spawn(function()
    while true do
        local m = GetModule()
        for key, value in pairs(StaminaSettings) do
            if SettingToggles[key] then
                m[key] = value
            end
        end
        task.wait(0.5)
    end
end)

local bai = {Spr = false}
local connection

MVP:AddToggle('MyToggle', {
    Text = 'infinite stamina',
    Default = false,
    Tooltip = 'infinite stamina',
    Callback = function(state)
        bai.Spr = state
        local Sprinting = GetModule()

        if state then
            Sprinting.StaminaLoss = 0
            Sprinting.StaminaGain = StaminaSettings.InfiniteGain

            if connection then connection:Disconnect() end
            connection = RunService.Heartbeat:Connect(function()
                if not bai.Spr then return end
                Sprinting.StaminaLoss = 0
                Sprinting.StaminaGain = StaminaSettings.InfiniteGain
            end)
        else
            Sprinting.StaminaLoss = 10
            Sprinting.StaminaGain = 25

            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

MVP:AddToggle('MaxStaminaToggle', {
    Text = 'Enable Max Stamina',
    Default = false,
    Callback = function(Value)
        SettingToggles.MaxStamina = Value
    end
})

MVP:AddToggle('StaminaGainToggle', {
    Text = 'Enable Stamina Gain',
    Default = false,
    Callback = function(Value)
        SettingToggles.StaminaGain = Value
    end
})

MVP:AddToggle('StaminaLossToggle', {
    Text = 'Enable Stamina Loss',
    Default = false,
    Callback = function(Value)
        SettingToggles.StaminaLoss = Value
    end
})

MVP:AddToggle('SprintSpeedToggle', {
    Text = 'Enable Sprint Speed',
    Default = false,
    Callback = function(Value)
        SettingToggles.SprintSpeed = Value
    end
})

local MVP2 = Tabs.Sat:AddRightGroupbox("Setting")

MVP2:AddSlider('InfStaminaGainSlider', {
    Text = 'infinite stamina gain',
    Default = 9999,
    Min = 0,
    Max = 10000,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.InfiniteGain = Value
        if bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaGain = Value
        end
    end
})

MVP2:AddSlider('MySlider1', {
    Text = 'Max Stamina',
    Default = 100,
    Min = 0,
    Max = 9999,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.MaxStamina = Value
        if SettingToggles.MaxStamina then
            local Sprinting = GetModule()
            Sprinting.MaxStamina = Value
        end
    end
})

MVP2:AddSlider('MySlider2', {
    Text = 'Stamina Recovery Speed',
    Default = 25,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.StaminaGain = Value
        if SettingToggles.StaminaGain and not bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaGain = Value
        end
    end
})

MVP2:AddSlider('MySlider3', {
    Text = 'Stamina Loss Speed',
    Default = 10,
    Min = 0,
    Max = 800,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.StaminaLoss = Value
        if SettingToggles.StaminaLoss and not bai.Spr then
            local Sprinting = GetModule()
            Sprinting.StaminaLoss = Value
        end
    end
})

MVP2:AddSlider('MySlider4', {
    Text = 'Sprint Speed',
    Default = 28,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        StaminaSettings.SprintSpeed = Value
        if SettingToggles.SprintSpeed then
            local Sprinting = GetModule()
            Sprinting.SprintSpeed = Value
        end
    end
})





local Generator2 = Tabs.zdx:AddLeftGroupbox("Auto Fix Generators")



getgenv().AutoGenEnabled = false
getgenv().TimePerGenPhase = 1.25
getgenv().RunService = game:GetService("RunService")
getgenv().plr = game.Players.LocalPlayer

Generator2:AddSlider("TimePerGenPhase", {
    Text = "Repair Speed (s)",
    Default = 1.25,
    Min = 1,
    Max = 5,
    Rounding = 0.25,
    Compact = false,
    Callback = function(v)
        getgenv().TimePerGenPhase = v
    end
})

Generator2:AddToggle("AutoGenToggle", {
    Text = "auto fix generators",
    Default = false,
    Callback = function(v)
        getgenv().AutoGenEnabled = v
    end
})

getgenv().RunService.RenderStepped:Connect(function()
    if not getgenv().AutoGenEnabled then return end
    if not getgenv().plr.PlayerGui:FindFirstChild("PuzzleUI") then return end
    
    local char = getgenv().plr.Character or getgenv().plr.CharacterAdded:Wait()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local closest, dist = nil, math.huge
    local mapFolder = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Ingame")
        and workspace.Map.Ingame:FindFirstChild("Map")
    
    if mapFolder then
        for _, gen in ipairs(mapFolder:GetChildren()) do
            if gen:IsA("Model") and gen.Name == "Generator" and gen.PrimaryPart then
                local d = (root.Position - gen.PrimaryPart.Position).Magnitude
                if d < dist then
                    closest, dist = gen, d
                end
            end
        end
    end
    
    if closest and closest:FindFirstChild("Remotes") and closest.Remotes:FindFirstChild("RE") then
        if not getgenv()._lastFire or tick() - getgenv()._lastFire >= getgenv().TimePerGenPhase then
            getgenv()._lastFire = tick()
            pcall(function() 
                closest.Remotes.RE:FireServer() 
            end)
        end
    end
end)


local Generator = Tabs.zdx:AddLeftGroupbox("auto fix generators)")

Generator:AddSlider("RepairSpeed", {
    Text = "Repair Speed (s)",
    Default = 4,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(v)
        _G.CustomSpeed = v
    end
})

Generator:AddToggle("AutoGenerator",{
    Text = "Auto Fix Generators",
    Default = false,
    Callback = function(v)
        _G.AutoGen = v
        task.spawn(function()
            while _G.AutoGen do
                if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PuzzleUI") then
                    local delayTime = _G.CustomSpeed or 4
                    
                    wait(delayTime)
                    
                    for _,v in ipairs(workspace["Map"]["Ingame"]["Map"]:GetChildren()) do
                        if v.Name == "Generator" then
                            v["Remotes"]["RE"]:FireServer()
                        end
                    end
                end
                wait()
            end
        end)
    end
})


local RunService = game:GetService("RunService")

local function getDirection(currentRow, currentCol, otherRow, otherCol)
    if otherRow < currentRow then return "up" end
    if otherRow > currentRow then return "down" end
    if otherCol < currentCol then return "left" end
    if otherCol > currentCol then return "right" end
end

local function getConnections(prev, curr, nextnode)
    local connections = {}
    if prev and curr then
        local dir = getDirection(curr.row, curr.col, prev.row, prev.col)
        if dir == "up" then dir = "down"
        elseif dir == "down" then dir = "up"
        elseif dir == "left" then dir = "right"
        elseif dir == "right" then dir = "left" end
        if dir then connections[dir] = true end
    end
    if nextnode and curr then
        local dir = getDirection(curr.row, curr.col, nextnode.row, nextnode.col)
        if dir then connections[dir] = true end
    end
    return connections
end

local function isNeighbourLocal(r1, c1, r2, c2)
    if r2 == r1 - 1 and c2 == c1 then return "up" end
    if r2 == r1 + 1 and c2 == c1 then return "down" end
    if r2 == r1 and c2 == c1 - 1 then return "left" end
    if r2 == r1 and c2 == c1 + 1 then return "right" end
    return false
end

local function coordKey(node)
    return `{node.row}-{node.col}`
end

local function orderPathFromEndpoints(path, endpoints)
    if not path or #path == 0 then return path end
    
    local startEndpoint
    for _, ep in endpoints or {} do
        for _, n in path do
            if n.row == ep.row and n.col == ep.col then
                startEndpoint = { row = ep.row, col = ep.col }
                break
            end
        end
        if startEndpoint then break end
    end
    
    if not startEndpoint then
        local inPath = {}
        for _, n in path do inPath[coordKey(n)] = n end
        
        for _, n in path do
            local neighbours = 0
            local dirs = { { n.row - 1, n.col }, { n.row + 1, n.col }, { n.row, n.col - 1 }, { n.row, n.col + 1 } }
            for _, dir in dirs do
                local r, c = dir[1], dir[2]
                if inPath[`{r}-{c}`] then neighbours += 1 end
            end
            if neighbours == 1 then
                startEndpoint = { row = n.row, col = n.col }
                break
            end
        end
    end
    
    if not startEndpoint then
        startEndpoint = { row = path[1].row, col = path[1].col }
    end
    
    local remaining = {}
    for _, n in path do remaining[coordKey(n)] = { row = n.row, col = n.col } end
    
    local ordered = {}
    local current = { row = startEndpoint.row, col = startEndpoint.col }
    table.insert(ordered, table.clone(current))
    remaining[coordKey(current)] = nil
    
    while true do
        local _size = 0
        for _ in remaining do _size += 1 end
        if not (_size > 0) then break end
        
        local foundNext = false
        for key, node in remaining do
            local _value = isNeighbourLocal(current.row, current.col, node.row, node.col)
            if _value then
                table.insert(ordered, table.clone(node))
                remaining[key] = nil
                current = node
                foundNext = true
                break
            end
        end
        if not foundNext then return path end
    end
    return ordered
end

local HintSystem = {}
do
    function HintSystem:DrawSolutionOneByOne(puzzle, delayTime)
        delayTime = delayTime or 0.05
        if not puzzle or not puzzle.Solution then return end
        
        local lastUpdate = tick()
        local updateInterval = 0.1
        local batchSize = 3
        
        local totalPaths = #puzzle.Solution
        local indices = {}
        for i = 1, totalPaths do table.insert(indices, i) end
        
        for i = totalPaths, 2, -1 do
            local j = math.random(i)
            indices[i], indices[j] = indices[j], indices[i]
        end
        
        for _, colorIndex in indices do
            local path = puzzle.Solution[colorIndex]
            local endpoints = puzzle.targetPairs[colorIndex]
            local orderedPath = orderPathFromEndpoints(path, endpoints)
            puzzle.paths[colorIndex] = {}
            
            local batchNodes = {}
            
            for i = 0, #orderedPath - 1 do
                local node = orderedPath[i + 1]
                table.insert(puzzle.paths[colorIndex], { row = node.row, col = node.col })
                local prev = orderedPath[i]
                local nextNode = orderedPath[i + 2]
                local conn = getConnections(prev, node, nextNode)
                
                puzzle.gridConnections = puzzle.gridConnections or {}
                puzzle.gridConnections[`{node.row}-{node.col}`] = conn
                
                table.insert(batchNodes, node)
                
                if #batchNodes >= batchSize or i == #orderedPath - 1 then
                    local currentTime = tick()
                    if currentTime - lastUpdate >= updateInterval then
                        puzzle:updateGui()
                        lastUpdate = currentTime
                        RunService.Heartbeat:Wait()
                        task.wait(delayTime * 0.5)
                    end
                    batchNodes = {}
                else
                    if delayTime > 0 then task.wait(delayTime * 0.3) end
                end
            end
            
            puzzle:checkForWin()
            
            if delayTime > 0 then task.wait(delayTime * 2) end
        end
        
        puzzle:updateGui()
        puzzle:checkForWin()
    end
end

local LeftGroupBox = Tabs.zdx:AddLeftGroupbox("Auto Connect Generators")

local AutoConnectEnabled = false
local ConnectionSpeed = 0.05

LeftGroupBox:AddToggle("AutoConnectToggle", {
    Text = "Enable Auto Connect",
    Default = false,
    Callback = function(Value)
        AutoConnectEnabled = Value
        print("Auto Connect:", Value)
    end,
})

LeftGroupBox:AddSlider("ConnectionSpeed", {
    Text = "Connection Speed",
    Default = 0.05,
    Min = 0.001,
    Max = 0.2,
    Rounding = 3,
    Compact = false,
    Callback = function(Value)
        ConnectionSpeed = Value
        print("Connection Speed:", Value)
    end,
    Tooltip = "Lower value = faster speed",
})

local _result = ReplicatedStorage:WaitForChild("Modules"):FindFirstChild("Misc")
if _result then
    _result = _result:FindFirstChild("FlowGameManager")
    if _result then
        _result = _result:FindFirstChild("FlowGame")
    end
end
local bb = _result
if bb then
    local FlowGameModule = require(bb)
    local old = FlowGameModule.new
    FlowGameModule.new = function(...)
        local args = { ... }
        local output = { old(unpack(args)) }
        local puzzle = output[1]
        task.spawn(function()
            if puzzle and puzzle.Solution and AutoConnectEnabled then
            
                local startTime = tick()
                while AutoConnectEnabled and tick() - startTime < 10 do 
                    if Players.LocalPlayer.PlayerGui:FindFirstChild("PuzzleUI") then
                        local totalNodes = 0
                        for _, path in ipairs(puzzle.Solution) do
                            totalNodes += #path
                        end
                        local delayTime = ConnectionSpeed
                        HintSystem:DrawSolutionOneByOne(puzzle, delayTime)
                        break
                    end
                    task.wait(0.2) 
                end
            end
        end)
        return puzzle
    end
end



local KillerSurvival = Tabs.zdx:AddRightGroupbox('Generator farm[Danger]')

KillerSurvival:AddToggle("AutoFix", {
    Text = "Auto Generator Farm",
    Default = false,
    Callback = function(enabled)
        local threadId = tostring(math.random(1, 99999))
        _G.AutoFixThreadId = threadId
        
        local function shouldContinue()
            return _G.AutoFixThreadId == threadId and enabled
        end
        
        -- 检查是否所有发电机进度都达到100%
        local function allGeneratorsCompleted()
            local allCompleted = true
            local anyGeneratorFound = false
            
            for _, v in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
                if v.Name == "Generator" and v:FindFirstChild("Progress") then
                    anyGeneratorFound = true
                    if v.Progress.Value < 100 then
                        allCompleted = false
                        break
                    end
                end
            end
            
            -- 如果没有找到任何发电机，也返回true（没有需要修理的发电机）
            return allCompleted or not anyGeneratorFound
        end
        
        -- 使用事件进行修理
        local function repairGenerator(generator)
            pcall(function()
                generator.Remotes.RE:FireServer()
            end)
        end

        -- 使用ProximityPrompt互动（用于进入和离开）
        local function promptInteract(generator)
            local prompts = {}
            for _, prompt in ipairs(generator:GetDescendants()) do
                if prompt.ClassName == "ProximityPrompt" then
                    table.insert(prompts, prompt)
                end
            end
            
            for _, prompt in ipairs(prompts) do
                pcall(function()
                    fireproximityprompt(prompt)
                end)
            end
        end
        
        local function runGenerator()
            while shouldContinue() do
                -- 检查是否所有发电机都已完成
                if allGeneratorsCompleted() then
                    -- 所有发电机都100%，停止运行
                    break
                end
                
                -- 获取所有未完成的发电机（进度<100）
                local generators = {}
                for _, v in ipairs(workspace.Map.Ingame.Map:GetChildren()) do
                    if v.Name == "Generator" and v:FindFirstChild("Progress") and v.Progress.Value < 100 then
                        table.insert(generators, v)
                    end
                end
                
                -- 如果没有未完成的发电机，也停止
                if #generators == 0 then
                    break
                end
                
                -- 记录本轮已修复的发电机
                local repairedThisRound = {}
                
                for _, generator in ipairs(generators) do
                    if not shouldContinue() then break end
                    
                    -- 在处理每个发电机前再次检查是否所有发电机已完成
                    if allGeneratorsCompleted() then
                        break
                    end
                    
                    -- 检查这个发电机在本轮是否已经修复过
                    if not repairedThisRound[generator] then
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            -- 传送
                            local startTP = tick()
                            
                            -- 寻找传送点
                            local bestPos, minDist = nil, math.huge
                            if generator:FindFirstChild("Positions") then
                                for _, pos in ipairs(generator.Positions:GetChildren()) do
                                    local dist = (char.HumanoidRootPart.Position - pos.Position).Magnitude
                                    if dist < minDist then
                                        bestPos = pos
                                        minDist = dist
                                    end
                                end
                                
                                if bestPos then
                                    char.HumanoidRootPart.CFrame = bestPos.CFrame * CFrame.new(0, 0, -1.2)
                                end
                            end
                            
                            -- 等待传送完成
                            local elapsed = tick() - startTP
                            if elapsed < 0.17 then
                                task.wait(0.17 - elapsed)
                            end
                            
                            -- 进入发电机
                            promptInteract(generator)
                            task.wait(0.00001)
                            
                            -- 修理发电机（每轮只执行一次）
                            repairGenerator(generator)
                            
                            -- 记录本轮已修复
                            repairedThisRound[generator] = true
                            
                            task.wait(0.1)
                            
                            -- 离开发电机
                            promptInteract(generator)
                            
                            -- 电机间间隔
                            task.wait(0.000000000000001)
                        end
                    end
                end
                
                if shouldContinue() then
                    task.wait(0.000000000000000001)
                end
            end
            
            -- 循环结束时的清理
            if _G.AutoFixThreadId == threadId then
                enabled = false
            end
        end

        if enabled then
            if _G.AutoFixThread then
                _G.AutoFixThreadId = tostring(math.random(1, 99999))
                task.cancel(_G.AutoFixThread)
            end
            _G.AutoFixThread = task.spawn(runGenerator)
        else
            _G.AutoFixThreadId = tostring(math.random(1, 99999))
            if _G.AutoFixThread then
                task.cancel(_G.AutoFixThread)
                _G.AutoFixThread = nil
            end
        end
    end
})

KillerSurvival:AddButton({
    Text = 'Teleport to Generator',
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local generators = workspace.Map.Ingame.Map:GetChildren()
        for _, generator in ipairs(generators) do
            if generator.Name == "Generator" and 
               generator:FindFirstChild("Progress") and 
               generator.Progress.Value < 100 then
                
                local generatorPart = generator:FindFirstChild("Main") or  
                                     generator:FindFirstChild("Model") or
                                     generator:FindFirstChild("Base")
                
                if generatorPart then
                    character.HumanoidRootPart.CFrame = generatorPart.CFrame + Vector3.new(0, 3, 0)
                    return  
                end
            end
        end
        warn("no Generator founded")
    end
})




local ZZ = Tabs.zdx:AddRightGroupbox('Switch Server')

ZZ:AddButton({
    Text = "Switching server", 
    Func = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        
        local requestFunc = http_request or syn.request or request
        if not requestFunc then return end
            
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local response = requestFunc({Url = url, Method = "GET"})
        
        if response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)
            if data and data.data and #data.data > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, data.data[math.random(1, #data.data)].id, Players.LocalPlayer)
            end
        end
    end
})
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MapFolder = Workspace:WaitForChild("Map"):WaitForChild("Ingame")

local Settings = {
	Advanced = { Enabled = false, OutlineOnly = true, ShowNametag = false, Color = Color3.fromRGB(0, 255, 255) }
}


local VisualTabBox = Tabs.Esp:AddLeftTabbox()
local KillerGroup = VisualTabBox:AddTab("Killer")
local SurvivorGroup = VisualTabBox:AddTab("Survivor")
local AdvancedVisualGroup = VisualTabBox:AddTab("Ability")

local ObjectTabBox = Tabs.Esp:AddRightTabbox()
local ItemGroup = ObjectTabBox:AddTab("Items")
local SpecialGroup = ObjectTabBox:AddTab("Specials")
local TracerGroup = ObjectTabBox:AddTab("Tracers")

-- 杀手ESP设置
KillerGroup:AddToggle("KillerESP", {
    Text = "Killer ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.killerESP = Value
    end,
})

KillerGroup:AddToggle("KillerTracers", {
    Text = "Killer Tracers",
    Default = false,
    Callback = function(Value)
        ESPSettings.killerTracers = Value
    end,
})

KillerGroup:AddToggle("KillerNameESP", {
    Text = "Killer Name ESP",
    Default = true,
    Callback = function(Value)
        ESPSettings.killerNameESP = Value
        UpdateAllPlayerESPText()
    end,
})

KillerGroup:AddToggle("KillerHealthESP", {
    Text = "Show Killer Health",
    Default = true,
    Callback = function(Value)
        ESPSettings.killerHealthESP = Value
        UpdateAllPlayerESPText()
    end,
})

KillerGroup:AddToggle("KillerSkinESP", {
    Text = "KIller Skin ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.killerSkinESP = Value
        UpdateAllPlayerESPText()
    end,
})

KillerGroup:AddSlider("KillerFillTransparency", {
    Text = "Killer Fill Transparency",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        ESPSettings.killerFillTransparency = Value
        UpdateAllPlayerESPText()
    end,
})

KillerGroup:AddSlider("KillerOutlineTransparency", {
    Text = "Killer Outline Transparency",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        ESPSettings.killerOutlineTransparency = Value
        UpdateAllPlayerESPText()
    end,
})

KillerGroup:AddLabel("Killer Color"):AddColorPicker("KillerColor", {
    Default = ESPSettings.killerColor,
    Title = "Killer ESP Color",
    Callback = function(Value)
        ESPSettings.killerColor = Value
    end,
})

-- 幸存者ESP设置
SurvivorGroup:AddToggle("SurvivorESP", {
    Text = "Survivor ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.playerESP = Value
    end,
})

SurvivorGroup:AddToggle("SurvivorTracers", {
    Text = "Survivor Tracers",
    Default = false,
    Callback = function(Value)
        ESPSettings.survivorTracers = Value
    end,
})

SurvivorGroup:AddToggle("SurvivorNameESP", {
    Text = "Show Survivor name Esp",
    Default = true,
    Callback = function(Value)
        ESPSettings.survivorNameESP = Value
        UpdateAllPlayerESPText()
    end,
})

SurvivorGroup:AddToggle("SurvivorHealthESP", {
    Text = "Show Survivor Health",
    Default = true,
    Callback = function(Value)
        ESPSettings.survivorHealthESP = Value
        UpdateAllPlayerESPText()
    end,
})

SurvivorGroup:AddToggle("SurvivorSkinESP", {
    Text = "Show Survivor Skins",
    Default = false,
    Callback = function(Value)
        ESPSettings.survivorSkinESP = Value
        UpdateAllPlayerESPText()
    end,
})

SurvivorGroup:AddSlider("SurvivorFillTransparency", {
    Text = "Fill Transparency",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        ESPSettings.survivorFillTransparency = Value
        UpdateAllPlayerESPText()
    end,
})

SurvivorGroup:AddSlider("SurvivorOutlineTransparency", {
    Text = "Survivor Outline Transparency",
    Default = 0.3,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
    Callback = function(Value)
        ESPSettings.survivorOutlineTransparency = Value
        UpdateAllPlayerESPText()
    end,
})

SurvivorGroup:AddLabel("幸存者颜色"):AddColorPicker("SurvivorColor", {
    Default = ESPSettings.survivorColor,
    Title = "Survivor ESP Color",
    Callback = function(Value)
        ESPSettings.survivorColor = Value
    end,
})

-- 物品ESP设置
ItemGroup:AddToggle("GeneratorESP", {
    Text = "Generator ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.generatorESP = value
    end,
}):AddColorPicker("GeneratorColor", {
    Default = ESPSettings.generatorColor,
    Title = "Generator Color",
    Callback = function(value)
        ESPSettings.generatorColor = value
    end,
})

ItemGroup:AddToggle("ItemESP", {
    Text = "Item ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.itemESP = value
    end,
}):AddColorPicker("ItemColor", {
    Default = ESPSettings.itemColor,
    Title = "Item Color",
    Callback = function(value)
        ESPSettings.itemColor = value
    end,
})

ItemGroup:AddToggle("PizzaESP", {
    Text = "Pizza ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaEsp = value
    end,
}):AddColorPicker("PizzaColor", {
    Default = ESPSettings.pizzaColor,
    Title = "Pizza Color",
    Callback = function(value)
        ESPSettings.pizzaColor = value
    end,
})

ItemGroup:AddToggle("TaphTripwireESP", {
    Text = "Tripwire ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.taphTripwireEsp = value
    end,
}):AddColorPicker("TaphTripwireColor", {
    Default = ESPSettings.taphTripwireColor,
    Title = "Tripwire Color",
    Callback = function(value)
        ESPSettings.taphTripwireColor = value
    end,
})

ItemGroup:AddToggle("TripMineESP", {
    Text = "subspace Tripmine Esp",
    Default = false,
    Callback = function(value)
        ESPSettings.tripMineEsp = value
    end,
}):AddColorPicker("TripMineColor", {
    Default = ESPSettings.tripMineColor,
    Title = "subspace tripmine color",
    Callback = function(value)
        ESPSettings.tripMineColor = value
    end,
})

ItemGroup:AddToggle("TwoTimeRespawnESP", {
    Text = "Twotime rebirth esp",
    Default = false,
    Callback = function(value)
        ESPSettings.twoTimeRespawnEsp = value
    end,
}):AddColorPicker("TwoTimeRespawnColor", {
    Default = ESPSettings.twoTimeRespawnColor,
    Title = "TwoTime rebirth place color",
    Callback = function(value)
        ESPSettings.twoTimeRespawnColor = value
    end,
})

ItemGroup:AddToggle("GraffitiESP", {
    Text = "Graffiti Esp",
    Default = false,
    Callback = function(value)
        ESPSettings.graffitiEsp = value
    end,
}):AddColorPicker("GraffitiColor", {
    Default = ESPSettings.graffitiColor,
    Title = "Graffiti color",
    Callback = function(value)
        ESPSettings.graffitiColor = value
    end,
})

ItemGroup:AddToggle("SukkarsESP", {
    Text = "Sukkars ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.sukkarsEsp = value
    end,
}):AddColorPicker("SukkarsColor", {
    Default = ESPSettings.sukkarsColor,
    Title = "Sukkars Color",
    Callback = function(value)
        ESPSettings.sukkarsColor = value
    end,
})

-- 特殊ESP设置
SpecialGroup:AddToggle("PizzaDeliveryESP", {
    Text = "Pizza Delivery ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaDeliveryEsp = value
    end,
}):AddColorPicker("PizzaDeliveryColor", {
    Default = ESPSettings.pizzaDeliveryColor,
    Title = "Pizza Delivery Color",
    Callback = function(value)
        ESPSettings.pizzaDeliveryColor = value
    end,
})

SpecialGroup:AddToggle("ZombieESP", {
    Text = "Zombie ESP",
    Default = false,
    Callback = function(value)
        ESPSettings.zombieEsp = value
    end,
}):AddColorPicker("ZombieColor", {
    Default = ESPSettings.zombieColor,
    Title = "Zombie Color",
    Callback = function(value)
        ESPSettings.zombieColor = value
    end,
})

-- 追踪线设置
TracerGroup:AddToggle("GeneratorTracers", {
    Text = "Generator Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.generatorTracers = value
    end,
})

TracerGroup:AddToggle("ItemTracers", {
    Text = "Item Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.itemTracers = value
    end,
})

TracerGroup:AddToggle("PizzaTracers", {
    Text = "Pizza Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaTracers = value
    end,
})

TracerGroup:AddToggle("PizzaDeliveryTracers", {
    Text = "Pizza Delivery Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.pizzaDeliveryTracers = value
    end,
})

TracerGroup:AddToggle("ZombieTracers", {
    Text = "Zombie Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.zombieTracers = value
    end,
})

TracerGroup:AddToggle("TaphTripwireTracers", {
    Text = "Taph Tripwire Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.taphTripwireTracers = value
    end,
})

TracerGroup:AddToggle("TripMineTracers", {
    Text = "Subspace Tripmine Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.tripMineTracers = value
    end,
})

TracerGroup:AddToggle("TwoTimeRespawnTracers", {
    Text = "TwoTime Rebirth place Tracers",
    Default = false,
    Callback = function(value)
        ESPSettings.twoTimeRespawnTracers = value
    end,
})

-- 高级透视设置
AdvancedVisualGroup:AddToggle("AdvancedESP", {
    Text = "Enable",
    Default = false,
    Callback = function(Value)
        AdvancedSettings.Enabled = Value
    end,
})

AdvancedVisualGroup:AddToggle("AdvancedOutline", {
    Text = "show outline only",
    Default = true,
    Callback = function(Value)
        AdvancedSettings.OutlineOnly = Value
    end,
})

AdvancedVisualGroup:AddToggle("AdvancedNametag", {
    Text = "Display Name Tags",
    Default = false,
    Callback = function(Value)
        AdvancedSettings.ShowNametag = Value
    end,
})

AdvancedVisualGroup:AddLabel("Advanced Color"):AddColorPicker("AdvancedColor", {
    Default = AdvancedSettings.Color,
    Title = "Advanced Color",
    Callback = function(Value)
        AdvancedSettings.Color = Value
    end,
})

AdvancedVisualGroup:AddToggle("NST", {
    Text = "Subspace Tripmine Spawn Notification",
    Default = false,
    Callback = function(v)
        if not _G.NSTData then
            _G.NSTData = {
                connection = nil
            }
        end
        local data = _G.NSTData
        if data.connection then
            data.connection:Disconnect()
            data.connection = nil
        end
        if v then
            data.connection = workspace.Map.Ingame.DescendantAdded:Connect(function(v)
                if v.Name == "SubspaceTripmine" then
                    Library:Notify("SubspaceTripmine spawned!")
                end
            end)
        end
    end
})

AdvancedVisualGroup:AddToggle("NEK", {
    Text = "Entity Spawn Notification",
    Default = false,
    Callback = function(v)
        if not _G.NEKData then
            _G.NEKData = {
                connection = nil
            }
        end
        local data = _G.NEKData
        if data.connection then
            data.connection:Disconnect()
            data.connection = nil
        end
        if v then
            data.connection = workspace.DescendantAdded:Connect(function(v)
                if v:IsA("Model") and (v.Name == "PizzaDeliveryRig" or v.Name == "Mafia1" or v.Name == "Mafia2" or v.Name == "Mafia3" or v.Name == "Mafia4") then
                    Library:Notify("Entity '" .. v.Name .. "' spawned!")
                elseif v:IsA("Model") and v.Name == "1x1x1x1Zombie" then
                    Library:Notify("Zombie Spawned!")
                end
            end)
        end
    end
})



local v437 = Tabs.ani:AddLeftGroupbox("Universal Anti-Effects")





v437:AddToggle("AntiBlindness", {
    Text = "Anti-Blind",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiBlindness.Value and task.wait() do
                if game.Lighting:FindFirstChild("BlindnessBlur") then
                    game.Lighting.BlindnessBlur:Destroy()
                end
            end
        end)
    end
})
v437:AddToggle("AntiSubspace", {
    Text = "Anti-Subspace Explosion",
    Default = false,
    Callback = function()
        task.spawn(function()
            while Toggles.AntiSubspace.Value and task.wait() do
                for _, v447 in pairs({"SubspaceVFXBlur", "SubspaceVFXColorCorrection"}) do
                    if game.Lighting:FindFirstChild(v447) then
                        game.Lighting[v447]:Destroy()
                    end
                end
            end
        end)
    end
})


getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
   for _, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           return
       end
   end
   table.insert(getgenv().HookRules, {
       remoteName = remoteName,
       blockedFirstArg = blockedFirstArg,
       block = true
   })
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
   for i, rule in ipairs(getgenv().HookRules) do
       if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
           table.remove(getgenv().HookRules, i)
           break
       end
   end
end

getgenv().isFiringDusekkar = false

getgenv().EnableProtection = function()
   getgenv().activateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "DusekkarCancel")
   if not getgenv().isFiringDusekkar then
       getgenv().isFiringDusekkar = true
       task.spawn(function()
           task.wait(4)
           local ReplicatedStorage = game:GetService("ReplicatedStorage")
           local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
           RemoteEvent:FireServer({game.Players.LocalPlayer.Name .. "DusekkarCancel"})
           getgenv().isFiringDusekkar = false
       end)
   end
end

getgenv().DisableProtection = function()
   getgenv().deactivateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "DusekkarCancel")
end



local DusekkarGroup = Tabs.ani:AddLeftGroupbox("Dusekkar")

DusekkarGroup:AddToggle("ProtectionDusekkar", {
   Text = "Anti-Cancel Protection",
   Default = false,
   Tooltip = "Prevent Shield Cancellation",
   Callback = function(Value)
       if Value then
           getgenv().EnableProtection()
       else
           getgenv().DisableProtection()
       end
   end
})



local ZZ2 = Tabs.ani:AddRightGroupbox('NOOB Anti-Effects')

ZZ2:AddToggle("RemoveSlateskin", {
    Text = "Anti Noob Slate Slow", 
    Default = false,
    Callback = function(v)
        if not _G.SlateskinCleanup then _G.SlateskinCleanup = {} end
        local connections = _G.SlateskinCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.SlateskinCleanup = {}

        if not v then return end

        local function CleanSlateskins()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            local survivorList = survivorsFolder:GetChildren()
            for i = 1, #survivorList, 5 do
                task.spawn(function()
                    for j = i, math.min(i + 4, #survivorList) do
                        local survivor = survivorList[j]
                        local slateskin = survivor:FindFirstChild("SlateskinStatus")
                        if slateskin then
                            slateskin:Destroy()
                        end
                    end
                end)
            end
        end

        task.spawn(CleanSlateskins)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(2)
            CleanSlateskins()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "SlateskinStatus" then
                    descendant:Destroy()
                end
            end)
        end
    end
})




local Disabled = Tabs.ani:AddLeftGroupbox('Guest Anti-Effects')

Disabled:AddToggle("RemoveSlowed", {
    Text = "Anti Slow", 
    Default = false,
    Callback = function(v)
        if not _G.SlowedCleanup then _G.SlowedCleanup = {} end
        local connections = _G.SlowedCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.SlowedCleanup = {}

        if not v then return end

        local function CleanSlowedStatuses()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "SlowedStatus" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanSlowedStatuses)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanSlowedStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "SlowedStatus" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemoveBlockingSlow", {
    Text = "Anti Blocking Speed", 
    Default = false,
    Callback = function(v)
        if not _G.BlockingCleanup then _G.BlockingCleanup = {} end
        local connections = _G.BlockingCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.BlockingCleanup = {}

        if not v then return end

        local function CleanStatuses()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "ResistanceStatus" or survivor.Name == "GuestBlocking" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanStatuses)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "ResistanceStatus" or descendant.Name == "GuestBlocking" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemovePunchSlow", {
    Text = "Anti Punch Speed", 
    Default = false,
    Callback = function(v)
        if not _G.PunchCleanup then _G.PunchCleanup = {} end
        local connections = _G.PunchCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.PunchCleanup = {}

        if not v then return end

        local function CleanStatuses()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "ResistanceStatus" or survivor.Name == "PunchAbility" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanStatuses)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanStatuses()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "ResistanceStatus" or descendant.Name == "PunchAbility" then
                    descendant:Destroy()
                end
            end)
        end
    end
})

Disabled:AddToggle("RemoveChargeEnded", {
    Text = "Effect After Anti-Sprint Ends", 
    Default = false,
    Callback = function(v)
        if not _G.ChargeEndedCleanup then _G.ChargeEndedCleanup = {} end
        local connections = _G.ChargeEndedCleanup

        for _, conn in pairs(connections) do
            if typeof(conn) == "RBXScriptConnection" then
                conn:Disconnect()
            end
        end
        _G.ChargeEndedCleanup = {}

        if not v then return end

        local function CleanChargeEndedEffects()
            local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
            if not survivorsFolder then return end
            
            for _, survivor in ipairs(survivorsFolder:GetDescendants()) do
                if survivor.Name == "GuestChargeEnded" then
                    survivor:Destroy()
                end
            end
        end

        task.spawn(CleanChargeEndedEffects)

        connections.heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
            task.wait(1.5)
            CleanChargeEndedEffects()
        end)

        local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
        if survivorsFolder then
            connections.descendantAdded = survivorsFolder.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "GuestChargeEnded" then
                    descendant:Destroy()
                end
            end)
        end
    end
})









local LeftGroupBox = Tabs.ani:AddRightGroupbox("c00lkidd")

if not getgenv().originalNamecall then
	getgenv().HookRules = {}
	getgenv().originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		if method == "FireServer" then
			for _, rule in ipairs(getgenv().HookRules) do
				if (not rule.remoteName or self.Name == rule.remoteName) then
					if not rule.blockedFirstArg or args[1] == rule.blockedFirstArg then
						if rule.block then
							return
						end
					end
				end
			end
		end
		return getgenv().originalNamecall(self, ...)
	end)
end

getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
	for _, rule in ipairs(getgenv().HookRules) do
		if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
			return
		end
	end
	table.insert(getgenv().HookRules, {
		remoteName = remoteName,
		blockedFirstArg = blockedFirstArg,
		block = true
	})
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
	for i, rule in ipairs(getgenv().HookRules) do
		if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
			table.remove(getgenv().HookRules, i)
			break
		end
	end
end

getgenv().EnableC00lkidd = function()
	getgenv().activateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "C00lkiddCollision")
end

getgenv().DisableC00lkidd = function()
	getgenv().deactivateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "C00lkiddCollision")
end

local globalEnv = getgenv()
globalEnv.Players = game:GetService("Players")
globalEnv.RunService = game:GetService("RunService")
globalEnv.Camera = workspace.CurrentCamera
globalEnv.Player = globalEnv.Players.LocalPlayer
globalEnv.walkSpeed = 100
globalEnv.toggle = false
globalEnv.connection = nil

function globalEnv.getCharacter()
	return globalEnv.Player.Character or globalEnv.Player.CharacterAdded:Wait()
end

function globalEnv.onHeartbeat()
	local player = globalEnv.Player
	local character = globalEnv.getCharacter()
	if character.Name ~= "c00lkidd" then return end
	local char = globalEnv.getCharacter()
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local lv = rootPart and rootPart:FindFirstChild("LinearVelocity")
	if not rootPart or not humanoid or not lv then return end
	if lv then
		lv.VectorVelocity = Vector3.new(math.huge, math.huge, math.huge)
		lv.Enabled = false
	end
	local stopMovement = false
	local validValues = {
		Timeout = true,
		Collide = true,
		Hit = true
	}
	local function watchResult(result)
		local function checkValue()
			if validValues[result.Value] then
				stopMovement = true
			end
		end
		checkValue()
		result:GetPropertyChangedSignal("Value"):Connect(checkValue)
	end
	local function onCharacterAdded(character)
		local result = character:FindFirstChild("Result")
		if result and result:IsA("StringValue") then
			watchResult(result)
		end
		character.ChildAdded:Connect(function(child)
			if child.Name == "Result" and child:IsA("StringValue") then
				watchResult(child)
			end
		end)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
	if not stopMovement then
		local lookVector = globalEnv.Camera.CFrame.LookVector
		local moveDir = Vector3.new(lookVector.X, 0, lookVector.Z)
		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit
			rootPart.Velocity = Vector3.new(moveDir.X * globalEnv.walkSpeed, rootPart.Velocity.Y, moveDir.Z * globalEnv.walkSpeed)
			rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveDir)
		end
	end
end



LeftGroupBox:AddToggle("WalkspeedOverrideController", {
	Text = "Free Movement (Locked View)",
	Tooltip = "Enable Speed Override Controller",
	Default = false,
	Callback = function(value)
		if value then
			globalEnv.connection = globalEnv.RunService.Heartbeat:Connect(globalEnv.onHeartbeat)
		else
			if globalEnv.connection then
				globalEnv.connection:Disconnect()
			end
		end
	end,
})

LeftGroupBox:AddToggle("IgnoreObjectables", {
	Text = "Ignore Collidable Objects",
	Tooltip = "Enable ignoring collidable objects",
	Default = false,
	Callback = function(Value)
		if Value then
			getgenv().EnableC00lkidd()
		else
			getgenv().DisableC00lkidd()
		end
	end
})














local ZZ = Tabs.ani:AddRightGroupbox('1x4')local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local AutoPopup = {
    Enabled = false,
    Task = nil,
    Connections = {},
    Interval = 0.5
}

local function deletePopups()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then
        return false
    end
    
    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
    if not tempUI then
        return false
    end
    
    local deleted = false
    for _, popup in ipairs(tempUI:GetChildren()) do
        if popup.Name == "1x1x1x1Popup" then
            popup:Destroy()
            deleted = true
        end
    end
    return deleted
end

local function triggerEntangled()
    pcall(function()
        ReplicatedStorage.Modules.Network.RemoteEvent:FireServer("Entangled", {})
    end)
end

local function setupPopupListener()
    if not LocalPlayer or not LocalPlayer:FindFirstChild("PlayerGui") then return end
    
    local tempUI = LocalPlayer.PlayerGui:FindFirstChild("TemporaryUI")
    if not tempUI then
        tempUI = Instance.new("Folder")
        tempUI.Name = "TemporaryUI"
        tempUI.Parent = LocalPlayer.PlayerGui
    end
    
    if AutoPopup.Connections.ChildAdded then
        AutoPopup.Connections.ChildAdded:Disconnect()
    end
    
    AutoPopup.Connections.ChildAdded = tempUI.ChildAdded:Connect(function(child)
        if AutoPopup.Enabled and child.Name == "1x1x1x1Popup" then
            task.defer(function()
                child:Destroy()
                triggerEntangled()
            end)
        end
    end)
end

local function runMainTask()
    while AutoPopup.Enabled do
        deletePopups()
        task.wait(AutoPopup.Interval)
    end
end

local function startAutoPopup()
    if AutoPopup.Enabled then return end
    
    AutoPopup.Enabled = true
    setupPopupListener()
    
    if AutoPopup.Task then
        task.cancel(AutoPopup.Task)
    end
    AutoPopup.Task = task.spawn(runMainTask)
end

local function stopAutoPopup()
    if not AutoPopup.Enabled then return end
    
    AutoPopup.Enabled = false
    
    if AutoPopup.Task then
        task.cancel(AutoPopup.Task)
        AutoPopup.Task = nil
    end
    
    for _, connection in pairs(AutoPopup.Connections) do
        connection:Disconnect()
    end
    AutoPopup.Connections = {}
end

ZZ:AddSlider('AutoPopupInterval', {
    Text = 'Execution Interval (s)',
    Default = 0.5,
    Min = 0.5,
    Max = 2,
    Rounding = 0,
    Tooltip = 'Set the interval time for automatic execution (1-5 seconds)',
    Callback = function(value)
        AutoPopup.Interval = value
    end
})

ZZ:AddToggle('AutoPopupCheckBox', {
    Text = 'Auto Popup',
    Default = false,
    Tooltip = 'Remove Notify-[1x1x1x1] and lazy effects',
    Callback = function(state)
        if state then
            startAutoPopup()
        else
            stopAutoPopup()
        end
    end
})

if LocalPlayer then
    LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
        if not LocalPlayer.Parent then
            stopAutoPopup()
        end
    end)
end



local NoliGroup = Tabs.ani:AddLeftGroupbox("Noli")



local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local noliDeleterActive = false
local deletionConnection = nil
local allowedNoli = nil
local isVoidRushCrashed = false
local characterCheckLoop = nil

local function deleteNewNoli()
    local killers = workspace:WaitForChild("Players"):WaitForChild("Killers")
    
    allowedNoli = killers:FindFirstChild("Noli")
    if not allowedNoli then
        return
    end
    
    if deletionConnection then
        deletionConnection:Disconnect()
        deletionConnection = nil
    end
    
    deletionConnection = RunService.Heartbeat:Connect(function()
        allowedNoli = killers:FindFirstChild("Noli")
        
        if not allowedNoli then
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            return
        end
        
        for _, child in killers:GetChildren() do
            if child.Name == "Noli" and child ~= allowedNoli then
                child:Destroy()
            end
        end
    end)
end

local function manageVoidRushState(character)
    while isVoidRushCrashed and character and character.Parent do
        character:SetAttribute("VoidRushState", "Crashed")
        task.wait(0.5)
    end
end



NoliGroup:AddToggle("NoliDeleter", {
    Text = "Anti fake Noli",
    Default = false,
    Callback = function(enabled)
        noliDeleterActive = enabled
        
        if enabled then
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            
            local success = pcall(deleteNewNoli)
            
            if not success then
                noliDeleterActive = false
            end
        else
            if deletionConnection then
                deletionConnection:Disconnect()
                deletionConnection = nil
            end
            allowedNoli = nil
        end
    end
})

NoliGroup:AddToggle("無視障礙[Noli]", {
    Text = "Noli Ignore Obstacles",
    Default = false,
    Callback = function(enabled)
        isVoidRushCrashed = enabled
        local character = player.Character
        
        if characterCheckLoop then
            task.cancel(characterCheckLoop)
            characterCheckLoop = nil
        end
        
        if enabled then
            if character then
                characterCheckLoop = task.spawn(function()
                    manageVoidRushState(character)
                end)
            end
        else
            if character then
                character:SetAttribute("VoidRushState", nil)
            end
        end
    end
})

local killers = workspace:WaitForChild("Players"):WaitForChild("Killers")

killers.ChildAdded:Connect(function(child)
    if noliDeleterActive and child.Name == "Noli" and not deletionConnection then
        task.wait(0.5)
        if noliDeleterActive and not deletionConnection then
            deleteNewNoli()
        end
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    if isVoidRushCrashed then
        if characterCheckLoop then
            task.cancel(characterCheckLoop)
        end
        characterCheckLoop = task.spawn(function()
            manageVoidRushState(newCharacter)
        end)
    end
end)












local ZZ = Tabs.Bro:AddLeftGroupbox('Player Movement')
local CFSpeed = 50
local CFLoop = nil
local RunService = game:GetService("RunService")


local speedValue = 0
_G.SpeedToggle = false

ZZ:AddSlider("SpeedBypass", {
    Text = "Speed",
    Default = 16,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(value)
        speedValue = value
    end
})

ZZ:AddToggle("SpeedToggle", {
    Text = "Speed Hack",
    Default = false,
    Callback = function(state)
        _G.SpeedToggle = state
        task.spawn(function()
            local LocalPlayer = game.Players.LocalPlayer
            while task.wait() and _G.SpeedToggle do
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.MoveDirection ~= Vector3.zero then
                    LocalPlayer.Character:TranslateBy(humanoid.MoveDirection * speedValue * game:GetService("RunService").RenderStepped:Wait())
                end
            end
        end)
    end
})




local noclipParts = {}
_G.noclipState = false

local function enableNoclip()
    local LocalPlayer = game.Players.LocalPlayer
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                noclipParts[part] = part
                part.CanCollide = false
            end
        end
    end
end

local function disableNoclip()
    for _, part in pairs(noclipParts) do
        part.CanCollide = true
    end
end

ZZ:AddToggle("EnableNoclip", {
    Text = "Noclip",
    Default = false,
    Callback = function(state)
        _G.noclipState = state
        task.spawn(function()
            while task.wait() do
                if _G.noclipState then
                    enableNoclip()
                else
                    disableNoclip()
                    break
                end
            end
        end)
    end
})


local function StartCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass('Humanoid')
    local head = character:FindFirstChild("Head")
    
    if not humanoid or not head then return end
    
    humanoid.PlatformStand = true
    head.Anchored = true
    
    if CFLoop then 
        CFLoop:Disconnect() 
        CFLoop = nil
    end
    
    local function isCharacterValid()
        if not character or not character.Parent then return false end
        if not humanoid or humanoid.Parent ~= character then return false end
        if not head or head.Parent ~= character then return false end
        return true
    end
    
    CFLoop = RunService.Heartbeat:Connect(function(deltaTime)
        if not isCharacterValid() then 
            if CFLoop then 
                CFLoop:Disconnect() 
                CFLoop = nil
            end
            return 
        end
        
        local moveDirection = humanoid.MoveDirection
        local headCFrame = head.CFrame
        local camera = workspace.CurrentCamera
        
        if not camera then return end
        
        local cameraCFrame = camera.CFrame
        local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
        cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
        local cameraPosition = cameraCFrame.Position
        local headPosition = headCFrame.Position

        local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection * (CFSpeed * deltaTime))
        
        if isCharacterValid() then
            head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
        end
    end)
end

local function StopCFly()
    local speaker = game.Players.LocalPlayer
    local character = speaker.Character
    
    if CFLoop then
        CFLoop:Disconnect()
        CFLoop = nil
    end
    
    if character and character.Parent then
        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local head = character:FindFirstChild("Head")
        
        if humanoid then
            humanoid.PlatformStand = false
        end
        if head then
            head.Anchored = false
        end
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    StopCFly()
end)

ZZ:AddToggle("CFlyToggle", {
    Text = "Fly Hack",
    Default = false,
    Callback = function(Value)
        if Value then
            task.wait(0.1)
            StartCFly()
        else
            StopCFly()
        end
    end
})

ZZ:AddSlider("CFlySpeed", {
    Text = "Fly Speed",
    Default = 50,
    Min = 1,
    Max = 200,
    Rounding = 1,
    Callback = function(Value)
        CFSpeed = Value
    end
})




ZZ:AddLabel("Undetected/bypassed")


if getgenv().ExistingConnections then
    for _, conn in ipairs(getgenv().ExistingConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
end

getgenv().ExistingConnections = {}

getgenv().Players = game:GetService("Players")
getgenv().RunService = game:GetService("RunService")
getgenv().LocalPlayer = getgenv().Players.LocalPlayer
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().buffer = buffer or require(getgenv().ReplicatedStorage.Buffer)
getgenv().RemoteEvent = getgenv().ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")

local Plrs = getgenv().Players
local RSvc = getgenv().RunService
local LocalP = getgenv().LocalPlayer
local RS = getgenv().ReplicatedStorage
getgenv().AutoBlockSounds = {
   ["12222216"] = true,
   ["71805956520207"] = true,
   ["71834552297085"] = true,
   ["72425554233832"] = true,
   ["75330693422988"] = true,
   ["76467993976301"] = true,
   ["76959687420003"] = true,
   ["77245770579014"] = true,
   ["78298577002481"] = true,
   ["79391273191671"] = true,
   ["79980897195554"] = true,
   ["80516583309685"] = true,
   ["81702359653578"] = true,
   ["82221759983649"] = true,
   ["84116622032112"] = true,
   ["84307400688050"] = true,
   ["85810983952228"] = true,
   ["85853080745515"] = true,
   ["86174610237192"] = true,
   ["86494585504534"] = true,
   ["86833981571073"] = true,
   ["89004992452376"] = true,
   ["89315669689903"] = true,
   ["90878551190839"] = true,
   ["94043596324983"] = true,
   ["95079963655241"] = true,
   ["97894923442490"] = true,
   ["98675142200448"] = true,
   ["99829427721752"] = true,
   ["101199185291628"] = true,
   ["101553872555606"] = true,
   ["101698569375359"] = true,
   ["102228729296384"] = true,
   ["103684883268194"] = true,
   ["104910828105172"] = true,
   ["105200830849301"] = true,
   ["105840448036441"] = true,
   ["106300477136129"] = true,
   ["107444859834748"] = true,
   ["108610718831698"] = true,
   ["108907358619313"] = true,
   ["109348678063422"] = true,
   ["109431876587852"] = true,
   ["110115912768379"] = true,
   ["110372418055226"] = true,
   ["112395455254818"] = true,
   ["112809109188560"] = true,
   ["113037804008732"] = true,
   ["114742322778642"] = true,
   ["115026634746636"] = true,
   ["116581754553533"] = true,
   ["117173212095661"] = true,
   ["117231507259853"] = true,
   ["119089145505438"] = true,
   ["119583605486352"] = true,
   ["119942598489800"] = true,
   ["121954639447247"] = true,
   ["124330645976935"] = true,
   ["124397369810639"] = true,
   ["124903763333174"] = true,
   ["125213046326879"] = true,
   ["127793641088496"] = true,
   ["128856426573270"] = true,
   ["131123355704017"] = true,
   ["131406927389838"] = true,
   ["135448067174226"] = true,
   ["136323728355613"] = true,
   ["136841625231863"] = true,
   ["140242176732868"] = true,
   ["128367348686124"] = true,
   ["116527305931161"] = true,
   ["105204810054381"] = true
}

getgenv().AutoBlockAnims = {
   ["18885909645"] = true,
   ["70371667919898"] = true,
   ["70447634862911"] = true,
   ["99135633258223"] = true,
   ["74707328554358"] = true,
   ["81299297965542"] = true,
   ["81639435858902"] = true,
   ["82113744478546"] = true,
   ["83251433279852"] = true,
   ["83685305553364"] = true,
   ["83829782357897"] = true,
   ["86204001129974"] = true,
   ["87989533095285"] = true,
   ["88451353906104"] = true,
   ["88970503168421"] = true,
   ["92173139187970"] = true,
   ["93069721274110"] = true,
   ["94162446513587"] = true,
   ["96571077893813"] = true,
   ["97167027849946"] = true,
   ["97433060861952"] = true,
   ["98456918873918"] = true,
   ["99135633258223"] = true,
   ["99829427721752"] = true,
   ["100592913030351"] = true,
   ["105458270463374"] = true,
   ["106538427162796"] = true,
   ["106776364623742"] = true,
   ["106847695270773"] = true,
   ["109230267448394"] = true,
   ["109667959938617"] = true,
   ["114356208094580"] = true,
   ["114506382930939"] = true,
   ["118298475669935"] = true,
   ["120112897026015"] = true,
   ["121086746534252"] = true,
   ["121293883585738"] = true,
   ["122709416391891"] = true,
   ["124705663396411"] = true,
   ["125403313786645"] = true,
   ["126171487400618"] = true,
   ["126355327951215"] = true,
   ["126681776859538"] = true,
   ["126830014841198"] = true,
   ["126896426760253"] = true,
   ["128414736976503"] = true,
   ["129976080405072"] = true,
   ["131430497821198"] = true,
   ["131543461321709"] = true,
   ["133336594357903"] = true,
   ["133363345661032"] = true,
   ["137314737492715"] = true,
   ["138938529389204"] = true,
   ["139309647473555"] = true,
   ["139835501033932"] = true,
   ["109700476007435"] = true,
   ["93366464803829"] = true,
   ["98590570796574"] = true,
   ["119062842291223"] = true,
   ["124269076578545"] = true
}

getgenv().PunchAnims = {
    ["108911997126897"]=true,["82137285150006"]=true,["129843313690921"]=true,
    ["140703210927645"]=true,["136007065400978"]=true,["86096387000557"]=true,
    ["87259391926321"]=true,["86709774283672"]=true,["108807732150251"]=true,
    ["138040001965654"]=true
}

getgenv().AutoBlockEnabled = false
getgenv().LooseFacingCheck = false
getgenv().SenseRange = 18
getgenv().PlayerFacingAngle = 90
getgenv().KillerFacingAngle = 90
getgenv().KillerFacingCheckEnabled = false
getgenv().KillersFolder = workspace:WaitForChild("Players"):WaitForChild("Killers")
getgenv().SenseRangeSq = getgenv().SenseRange * getgenv().SenseRange
getgenv().FacingCheckEnabled = false
getgenv().InnerCircleVisible = false
getgenv().OuterCircleVisible = false
getgenv().KillerCircles = {}
getgenv().SoundHooks = {}
getgenv().AnimHooks = {}
getgenv().SoundBlockedUntil = {}
getgenv().AnimBlockedUntil = {}
getgenv().SoundStartTime = {}
getgenv().AnimStartTime = {}
getgenv().MaxSoundAge = 1.2
getgenv().MaxAnimAge = 1.5
getgenv().autoPunchOn = false
getgenv().aimbotPunchOn = false
getgenv().punchRange = 50
getgenv().aimbotDelay = 0.1
getgenv().lastAimbotTime = 0
getgenv().KnownKillers = {"c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher","Sixer","Nosferatu"}
getgenv().CachedGui = getgenv().LocalPlayer:WaitForChild("PlayerGui")
getgenv().CachedPunchBtn = nil
getgenv().CachedCharges = nil
getgenv().CachedBlockBtn = nil
getgenv().CachedCooldown = nil
getgenv().HDPullEnabled = false
getgenv().HDSpeed = 12
getgenv().pulling = false
getgenv().wallCheckEnabled = false
getgenv().visualizationParts = {}
getgenv().lastVisUpdate = 0
getgenv().visUpdateInterval = 0.016
getgenv().VisualizationMode = "指南针"
getgenv().BoxLength = 7.5
getgenv().BoxWidth = 4.5
getgenv().BoxHeight = 6
getgenv().BoxColor = Color3.fromRGB(255, 0, 255)
getgenv().BoxTransparency = 0.7
getgenv().BoxSafeColor = Color3.fromRGB(0, 255, 0)
getgenv().BoxDangerColor = Color3.fromRGB(255, 0, 0)
getgenv().BoxSizeMultiplier = 1.0
getgenv().BoxForwardOffset = -1.4
getgenv().lastBlockTime = 0
getgenv().blockCooldown = 0.2
getgenv().faceKillerUntil = 0
getgenv().currentTargetKiller = nil
getgenv().faceKillerDuration = 3

getgenv().FireBlockRemote = function()
    local now = tick()
    if now - getgenv().lastBlockTime < getgenv().blockCooldown then return end
    getgenv().lastBlockTime = now
    local args = {"UseActorAbility", {buffer.fromstring("\3\5\0\0\0Block")}}
    game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer(unpack(args))
end

getgenv().fireRemotePunch = function()
    local args = {"UseActorAbility", {buffer.fromstring("\3\5\0\0\0Punch")}}
    game:GetService("ReplicatedStorage").Modules.Network.RemoteEvent:FireServer(unpack(args))
    
    local closest = getgenv().getClosestKiller()
    if closest then
        getgenv().currentTargetKiller = closest
        getgenv().faceKillerUntil = tick() + getgenv().faceKillerDuration
    end
end

getgenv().IsPlayerFacingKiller = function(myRoot,killerRoot)
    if not getgenv().FacingCheckEnabled then return true end
    if not myRoot or not killerRoot then return false end
    local dirToKiller = (killerRoot.Position - myRoot.Position)
    local flatDir = Vector3.new(dirToKiller.X, 0, dirToKiller.Z).Unit
    local playerLookDir = Vector3.new(myRoot.CFrame.LookVector.X, 0, myRoot.CFrame.LookVector.Z).Unit
    local dotProduct = playerLookDir:Dot(flatDir)
    local angleInDegrees = math.deg(math.acos(math.clamp(dotProduct,-1,1)))
    return angleInDegrees <= getgenv().PlayerFacingAngle
end

getgenv().IsKillerFacingPlayer = function(myRoot,killerRoot)
    if not getgenv().KillerFacingCheckEnabled then return true end
    if not myRoot or not killerRoot then return false end
    local dirToPlayer = (myRoot.Position - killerRoot.Position)
    local flatDir = Vector3.new(dirToPlayer.X, 0, dirToPlayer.Z).Unit
    local killerLookDir = Vector3.new(killerRoot.CFrame.LookVector.X, 0, killerRoot.CFrame.LookVector.Z).Unit
    local dotProduct = killerLookDir:Dot(flatDir)
    local angleInDegrees = math.deg(math.acos(math.clamp(dotProduct,-1,1)))
    return angleInDegrees <= getgenv().KillerFacingAngle
end

getgenv().HasLineOfSight = function(targetRoot)
    if not getgenv().wallCheckEnabled then return true end
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true
    rayParams.FilterDescendantsInstances = {LocalP.Character}
    local origin = myRoot.Position
    local direction = targetRoot.Position - origin
    local result = workspace:Raycast(origin,direction,rayParams)
    return not result or result.Instance:IsDescendantOf(targetRoot.Parent)
end

getgenv().IsPlayerInBox = function(myRoot, killerRoot)
    if not myRoot or not killerRoot then return false end
    
    local forward = killerRoot.CFrame.LookVector
    local effectiveLength = getgenv().BoxLength * getgenv().BoxSizeMultiplier
    local forwardOffset = forward * ((effectiveLength/2) + getgenv().BoxForwardOffset)
    local boxPos = killerRoot.Position + forwardOffset
    local boxCFrame = CFrame.lookAt(boxPos, boxPos + forward * 100)
    
    local relative = myRoot.Position - boxPos
    local localSpace = boxCFrame:VectorToObjectSpace(relative)
    
    local halfX = (getgenv().BoxWidth * getgenv().BoxSizeMultiplier) / 2
    local halfY = (getgenv().BoxHeight * getgenv().BoxSizeMultiplier) / 2
    local halfZ = effectiveLength / 2
    
    return math.abs(localSpace.X) <= halfX and math.abs(localSpace.Y) <= halfY and math.abs(localSpace.Z) <= halfZ
end

getgenv().CheckAllBlockConditions = function(myRoot,killerRoot)
    if not myRoot or not killerRoot then return false end
    
    local dvec = killerRoot.Position - myRoot.Position
    local distSq = dvec.X^2 + dvec.Y^2 + dvec.Z^2
    
    if getgenv().VisualizationMode == "Box" then
        if not getgenv().IsPlayerInBox(myRoot, killerRoot) then return false end
    elseif getgenv().VisualizationMode == "球体" then
        if distSq > getgenv().SenseRangeSq then return false end
    else
        if distSq > getgenv().SenseRangeSq then return false end
    end
    
    if not getgenv().IsKillerFacingPlayer(myRoot,killerRoot) then return false end
    if not getgenv().HasLineOfSight(killerRoot) then return false end
    if not getgenv().IsPlayerFacingKiller(myRoot,killerRoot) then return false end
    
    return true
end

getgenv().GetSoundIdNumeric = function(snd)
    if not snd or not snd.SoundId then return nil end
    local sid = tostring(snd.SoundId)
    return sid:match("%d+")
end

getgenv().GetAnimIdNumeric = function(anim)
    if not anim or not anim.AnimationId then return nil end
    local aid = tostring(anim.AnimationId)
    return aid:match("%d+")
end

getgenv().GetSoundPosition = function(snd)
    if not snd then return nil end
    if snd.Parent and snd.Parent:IsA("BasePart") then
        return snd.Parent.Position,snd.Parent
    end
    if snd.Parent and snd.Parent:IsA("Attachment") and snd.Parent.Parent and snd.Parent.Parent:IsA("BasePart") then
        return snd.Parent.Parent.Position,snd.Parent.Parent
    end
    local found = snd.Parent and snd.Parent:FindFirstChildWhichIsA("BasePart",true)
    return found and found.Position,found or nil,nil
end

getgenv().GetCharFromDescendant = function(inst)
    if not inst then return nil end
    local mdl = inst:FindFirstAncestorOfClass("Model")
    return mdl and mdl:FindFirstChildOfClass("Humanoid") and mdl or nil
end

getgenv().CanUseBlock = function()
    if getgenv().CachedCooldown and getgenv().CachedCooldown.Text ~= "" then return false end
    return true
end

getgenv().DoHDPull = function(targetPos)
    if getgenv().pulling or not getgenv().CanUseBlock() then return end
    getgenv().pulling = true
    local hrp = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then getgenv().pulling = false return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(50000,0,50000)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local startTime = tick()
    local conn
    conn = RSvc.Heartbeat:Connect(function()
        if not bv.Parent or tick() - startTime > 0.4 then 
            if bv.Parent then bv:Destroy() end
            conn:Disconnect() 
            getgenv().pulling = false 
            return 
        end
        local vec = targetPos - hrp.Position
        if vec.Magnitude < 3 then 
            bv:Destroy() 
            conn:Disconnect() 
            getgenv().pulling = false 
            return 
        end
        bv.Velocity = vec.Unit * (getgenv().HDSpeed * 25)
    end)
end

getgenv().AttemptBlockSound = function(snd)
    if not getgenv().AutoBlockEnabled then return end
    if not snd or not snd:IsA("Sound") then return end
    if not snd.IsPlaying then return end
    local id = getgenv().GetSoundIdNumeric(snd)
    if not id or not getgenv().AutoBlockSounds[id] then return end
    
    local now = tick()
    
    if not getgenv().SoundStartTime[snd] then
        getgenv().SoundStartTime[snd] = now
    end
    local soundAge = now - getgenv().SoundStartTime[snd]
    if soundAge > getgenv().MaxSoundAge then return end
    
    if getgenv().SoundBlockedUntil[snd] and now < getgenv().SoundBlockedUntil[snd] then return end
    
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local pos,part = getgenv().GetSoundPosition(snd)
    if not pos or not part then return end
    local char = getgenv().GetCharFromDescendant(part)
    local plr = char and Plrs:GetPlayerFromCharacter(char)
    if not plr or plr == LocalP then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not getgenv().CheckAllBlockConditions(myRoot,hrp) then return end
    
    getgenv().FireBlockRemote()
    if getgenv().HDPullEnabled then
        task.spawn(function() getgenv().DoHDPull(hrp.Position) end)
    end
    getgenv().SoundBlockedUntil[snd] = now + 0.8
end

getgenv().AttemptBlockAnim = function(animTrack)
    if not getgenv().AutoBlockEnabled then return end
    if not animTrack or not animTrack.Animation then return end
    if not animTrack.IsPlaying then return end
    local id = getgenv().GetAnimIdNumeric(animTrack.Animation)
    if not id or not getgenv().AutoBlockAnims[id] then return end
    
    local now = tick()
    
    if not getgenv().AnimStartTime[animTrack] then
        getgenv().AnimStartTime[animTrack] = now
    end
    local animAge = now - getgenv().AnimStartTime[animTrack]
    if animAge > getgenv().MaxAnimAge then return end
    
    if getgenv().AnimBlockedUntil[animTrack] and now < getgenv().AnimBlockedUntil[animTrack] then return end
    
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local animator = animTrack.Parent
    if not animator or not animator:IsA("Animator") then return end
    local char = getgenv().GetCharFromDescendant(animator)
    if not char then return end
    local plr = Plrs:GetPlayerFromCharacter(char)
    if not plr or plr == LocalP then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if not getgenv().CheckAllBlockConditions(myRoot,hrp) then return end
    
    getgenv().FireBlockRemote()
    if getgenv().HDPullEnabled then
        task.spawn(function() getgenv().DoHDPull(hrp.Position) end)
    end
    getgenv().AnimBlockedUntil[animTrack] = now + 0.8
end

getgenv().HookSound = function(snd)
    if not snd or not snd:IsA("Sound") then return end
    if getgenv().SoundHooks[snd] then return end
    
    local playConn = snd.Played:Connect(function()
        getgenv().SoundStartTime[snd] = tick()
        task.defer(getgenv().AttemptBlockSound,snd)
    end)
    
    local propConn = snd:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if snd.IsPlaying then 
            if not getgenv().SoundStartTime[snd] then
                getgenv().SoundStartTime[snd] = tick()
            end
            task.defer(getgenv().AttemptBlockSound,snd)
        else
            getgenv().SoundStartTime[snd] = nil
        end
    end)
    
    local destroyConn
    destroyConn = snd.Destroying:Connect(function()
        if playConn.Connected then playConn:Disconnect() end
        if propConn.Connected then propConn:Disconnect() end
        if destroyConn.Connected then destroyConn:Disconnect() end
        getgenv().SoundHooks[snd] = nil
        getgenv().SoundBlockedUntil[snd] = nil
        getgenv().SoundStartTime[snd] = nil
    end)
    
    getgenv().SoundHooks[snd] = {playConn,propConn,destroyConn}
    
    if snd.IsPlaying then
        getgenv().SoundStartTime[snd] = tick()
        task.defer(getgenv().AttemptBlockSound,snd)
    end
end

getgenv().HookAnimator = function(animator)
    if not animator or not animator:IsA("Animator") then return end
    animator.AnimationPlayed:Connect(function(animTrack)
        pcall(function()
            getgenv().AnimStartTime[animTrack] = tick()
            
            local playConn = animTrack:GetPropertyChangedSignal("IsPlaying"):Connect(function()
                if animTrack.IsPlaying then
                    if not getgenv().AnimStartTime[animTrack] then
                        getgenv().AnimStartTime[animTrack] = tick()
                    end
                    task.defer(getgenv().AttemptBlockAnim,animTrack)
                else
                    getgenv().AnimStartTime[animTrack] = nil
                end
            end)
            
            animTrack.Stopped:Connect(function()
                if playConn.Connected then playConn:Disconnect() end
                getgenv().AnimBlockedUntil[animTrack] = nil
                getgenv().AnimStartTime[animTrack] = nil
            end)
            
            if animTrack.IsPlaying then
                task.defer(getgenv().AttemptBlockAnim,animTrack)
            end
        end)
    end)
end

for _,d in ipairs(game:GetDescendants()) do
    if d:IsA("Sound") then pcall(getgenv().HookSound,d) end
    if d:IsA("Animator") then pcall(getgenv().HookAnimator,d) end
end

game.DescendantAdded:Connect(function(d)
    if d:IsA("Sound") then task.defer(getgenv().HookSound,d) end
    if d:IsA("Animator") then task.defer(getgenv().HookAnimator,d) end
end)

getgenv().CreateCompassVisualization = function(killer, myRoot)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") or not myRoot then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "CompassVisualization"
    folder.Parent = killerRoot
    
    local segments = 32
    local parts = {}
    
    local centerPart = Instance.new("Part")
    centerPart.Name = "Center"
    centerPart.Size = Vector3.new(0.6,0.1,0.6)
    centerPart.Anchored = true
    centerPart.CanCollide = false
    centerPart.Transparency = 0.7
    centerPart.Material = Enum.Material.Neon
    centerPart.Color = Color3.fromRGB(255,255,0)
    centerPart.Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    centerPart.Parent = folder
    table.insert(parts, centerPart)
    
    for i = 1, segments do
        local part = Instance.new("Part")
        part.Name = "ArcPoint"..i
        part.Size = Vector3.new(0.4,0.15,0.4)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.5
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255,100,100)
        part.Parent = folder
        table.insert(parts, part)
    end
    
    return {folder = folder, parts = parts, killer = killer, mode = "Compass"}
end

getgenv().CreateFixedVisualization = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "FixedVisualization"
    folder.Parent = killerRoot
    
    local segments = 32
    local parts = {}
    
    local centerPart = Instance.new("Part")
    centerPart.Name = "Center"
    centerPart.Size = Vector3.new(0.6,0.1,0.6)
    centerPart.Anchored = true
    centerPart.CanCollide = false
    centerPart.Transparency = 0.7
    centerPart.Material = Enum.Material.Neon
    centerPart.Color = Color3.fromRGB(255,255,0)
    centerPart.Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    centerPart.Parent = folder
    table.insert(parts, centerPart)
    
    for i = 1, segments do
        local part = Instance.new("Part")
        part.Name = "ArcPoint"..i
        part.Size = Vector3.new(0.4,0.15,0.4)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 0.5
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(100,100,255)
        part.Parent = folder
        table.insert(parts, part)
    end
    
    return {folder = folder, parts = parts, killer = killer, mode = "Static"}
end

getgenv().CreateBoxVisualization = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "BoxVisualization"
    folder.Parent = killerRoot
    
    local box = Instance.new("Part")
    box.Name = "DetectionBox"
    box.Material = Enum.Material.ForceField
    box.Anchored = true
    box.CanCollide = false
    box.Transparency = getgenv().BoxTransparency
    box.Color = getgenv().BoxDangerColor
    box.Size = Vector3.new(
        getgenv().BoxWidth * getgenv().BoxSizeMultiplier, 
        getgenv().BoxHeight * getgenv().BoxSizeMultiplier, 
        getgenv().BoxLength * getgenv().BoxSizeMultiplier
    )
    box.Parent = folder
    
    return {folder = folder, box = box, killer = killer, mode = "Box"}
end

getgenv().CreateSphereVisualization = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    local killerRoot = killer.HumanoidRootPart
    
    local folder = Instance.new("Folder")
    folder.Name = "SphereVisualization"
    folder.Parent = killerRoot
    
    local sphere = Instance.new("Part")
    sphere.Name = "DetectionSphere"
    sphere.Shape = Enum.PartType.Ball
    sphere.Material = Enum.Material.ForceField
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Transparency = 0.8
    sphere.Color = Color3.fromRGB(255, 0, 0)
    sphere.Size = Vector3.new(getgenv().SenseRange * 2, getgenv().SenseRange * 2, getgenv().SenseRange * 2)
    sphere.Parent = folder
    
    return {folder = folder, sphere = sphere, killer = killer, mode = "Sphere"}
end

getgenv().UpdateCompassVisualization = function(visData, myRoot)
    if not visData or not visData.folder or not visData.folder.Parent then return end
    if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
    
    local killerRoot = visData.killer.HumanoidRootPart
    local dirToPlayer = (myRoot.Position - killerRoot.Position)
    local forward = Vector3.new(dirToPlayer.X, 0, dirToPlayer.Z).Unit
    local right = Vector3.new(-forward.Z, 0, forward.X)
    
    local angle = getgenv().KillerFacingCheckEnabled and getgenv().KillerFacingAngle or 360
    local angleRad = math.rad(angle)
    local distance = getgenv().SenseRange
    local segments = #visData.parts - 1
    
    visData.parts[1].Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    
    for i = 2, #visData.parts do
        local t = (i - 2) / math.max(1, segments - 1)
        local currentAngle = -angleRad/2 + angleRad * t
        local direction = forward * math.cos(currentAngle) + right * math.sin(currentAngle)
        visData.parts[i].Position = killerRoot.Position + Vector3.new(0, 0.1, 0) + direction * distance
    end
    
    local shouldBlock = getgenv().CheckAllBlockConditions(myRoot, killerRoot)
    local color = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    for _, part in ipairs(visData.parts) do
        part.Color = color
    end
end

getgenv().UpdateFixedVisualization = function(visData, myRoot)
    if not visData or not visData.folder or not visData.folder.Parent then return end
    if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
    
    local killerRoot = visData.killer.HumanoidRootPart
    local forward = Vector3.new(killerRoot.CFrame.LookVector.X, 0, killerRoot.CFrame.LookVector.Z).Unit
    local right = Vector3.new(-forward.Z, 0, forward.X)
    
    local angle = getgenv().KillerFacingCheckEnabled and getgenv().KillerFacingAngle or 360
    local angleRad = math.rad(angle)
    local distance = getgenv().SenseRange
    local segments = #visData.parts - 1
    
    visData.parts[1].Position = killerRoot.Position + Vector3.new(0, 0.1, 0)
    
    for i = 2, #visData.parts do
        local t = (i - 2) / math.max(1, segments - 1)
        local currentAngle = -angleRad/2 + angleRad * t
        local direction = forward * math.cos(currentAngle) + right * math.sin(currentAngle)
        visData.parts[i].Position = killerRoot.Position + Vector3.new(0, 0.1, 0) + direction * distance
    end
    
    local shouldBlock = getgenv().CheckAllBlockConditions(myRoot, killerRoot)
    local color = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(100, 100, 255)
    for _, part in ipairs(visData.parts) do
        part.Color = color
    end
end

getgenv().UpdateBoxVisualization = function(visData, myRoot)
    if not visData or not visData.folder or not visData.folder.Parent then return end
    if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
    
    local killerRoot = visData.killer.HumanoidRootPart
    local forward = killerRoot.CFrame.LookVector
    local effectiveLength = getgenv().BoxLength * getgenv().BoxSizeMultiplier
    local forwardOffset = forward * ((effectiveLength/2) + getgenv().BoxForwardOffset)
    local boxPos = killerRoot.Position + forwardOffset
    
    visData.box.Size = Vector3.new(
        getgenv().BoxWidth * getgenv().BoxSizeMultiplier, 
        getgenv().BoxHeight * getgenv().BoxSizeMultiplier, 
        effectiveLength
    )
    visData.box.CFrame = CFrame.lookAt(boxPos, boxPos + forward * 100)
    visData.box.Transparency = getgenv().BoxTransparency
    
    local shouldBlock = getgenv().IsPlayerInBox(myRoot, killerRoot) and getgenv().CheckAllBlockConditions(myRoot, killerRoot)
    visData.box.Color = shouldBlock and getgenv().BoxSafeColor or getgenv().BoxDangerColor
end

getgenv().UpdateSphereVisualization = function(visData, myRoot)
    if not visData or not visData.folder or not visData.folder.Parent then return end
    if not myRoot or not visData.killer or not visData.killer:FindFirstChild("HumanoidRootPart") then return end
    
    local killerRoot = visData.killer.HumanoidRootPart
    
    visData.sphere.Size = Vector3.new(getgenv().SenseRange * 2, getgenv().SenseRange * 2, getgenv().SenseRange * 2)
    visData.sphere.CFrame = killerRoot.CFrame
    
    local dvec = myRoot.Position - killerRoot.Position
    local distSq = dvec.X^2 + dvec.Y^2 + dvec.Z^2
    local shouldBlock = distSq <= getgenv().SenseRangeSq and getgenv().CheckAllBlockConditions(myRoot, killerRoot)
    visData.sphere.Color = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end

getgenv().CreateVisualizationForKiller = function(killer)
    if not killer or not killer:FindFirstChild("HumanoidRootPart") then return nil end
    
    if getgenv().VisualizationMode == "Compass" then
        local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
        return getgenv().CreateCompassVisualization(killer, myRoot)
    elseif getgenv().VisualizationMode == "Static" then
        return getgenv().CreateFixedVisualization(killer)
    elseif getgenv().VisualizationMode == "Box" then
        return getgenv().CreateBoxVisualization(killer)
    elseif getgenv().VisualizationMode == "Sphere" then
        return getgenv().CreateSphereVisualization(killer)
    end
    return nil
end

getgenv().UpdateVisualization = function(visData, myRoot)
    if not visData then return end
    
    if visData.mode == "Compass" then
        getgenv().UpdateCompassVisualization(visData, myRoot)
    elseif visData.mode == "Static" then
        getgenv().UpdateFixedVisualization(visData, myRoot)
    elseif visData.mode == "Box" then
        getgenv().UpdateBoxVisualization(visData, myRoot)
    elseif visData.mode == "Sphere" then
        getgenv().UpdateSphereVisualization(visData, myRoot)
    end
end

getgenv().AddKillerCircle = function(killer)
    if not killer:FindFirstChild("HumanoidRootPart") then return end
    if getgenv().KillerCircles[killer] then return end
    
    local innerCirc, outerCirc
    
    if getgenv().InnerCircleVisible then
        innerCirc = Instance.new("CylinderHandleAdornment")
        innerCirc.Name = "KillerInnerCircle"
        innerCirc.Adornee = killer.HumanoidRootPart
        innerCirc.Color3 = Color3.fromRGB(255,0,0)
        innerCirc.AlwaysOnTop = true
        innerCirc.ZIndex = 1
        innerCirc.Transparency = 0.6
        innerCirc.Radius = getgenv().SenseRange
        innerCirc.Height = 0.1
        innerCirc.CFrame = CFrame.Angles(math.rad(90),0,0)
        innerCirc.Parent = killer.HumanoidRootPart
    end
    
    if getgenv().OuterCircleVisible then
        outerCirc = Instance.new("CylinderHandleAdornment")
        outerCirc.Name = "KillerOuterCircle"
        outerCirc.Adornee = killer.HumanoidRootPart
        outerCirc.Color3 = Color3.fromRGB(0,255,255)
        outerCirc.AlwaysOnTop = true
        outerCirc.ZIndex = 0
        outerCirc.Transparency = 0.3
        outerCirc.Radius = getgenv().punchRange
        outerCirc.Height = 0.1
        outerCirc.CFrame = CFrame.Angles(math.rad(90),0,0)
        outerCirc.Parent = killer.HumanoidRootPart
    end
    
    local visData = getgenv().CreateVisualizationForKiller(killer)
    
    getgenv().KillerCircles[killer] = {innerCircle = innerCirc, outerCircle = outerCirc, visualization = visData}
end

getgenv().RemoveKillerCircle = function(killer)
    if getgenv().KillerCircles[killer] then
        if getgenv().KillerCircles[killer].innerCircle then
            getgenv().KillerCircles[killer].innerCircle:Destroy()
        end
        if getgenv().KillerCircles[killer].outerCircle then
            getgenv().KillerCircles[killer].outerCircle:Destroy()
        end
        if getgenv().KillerCircles[killer].visualization and getgenv().KillerCircles[killer].visualization.folder then
            getgenv().KillerCircles[killer].visualization.folder:Destroy()
        end
        getgenv().KillerCircles[killer] = nil
    end
end

getgenv().RefreshKillerCircles = function()
    for _,killer in ipairs(getgenv().KillersFolder:GetChildren()) do
        if getgenv().InnerCircleVisible or getgenv().OuterCircleVisible then
            getgenv().AddKillerCircle(killer)
        else
            getgenv().RemoveKillerCircle(killer)
        end
    end
end

getgenv().UpdateVisualizationMode = function(newMode)
    getgenv().VisualizationMode = newMode
    
    for killer, data in pairs(getgenv().KillerCircles) do
        if data.visualization and data.visualization.folder then
            data.visualization.folder:Destroy()
        end
        
        local newVisData = getgenv().CreateVisualizationForKiller(killer)
        data.visualization = newVisData
    end
end

getgenv().UpdateBoxColors = function()
    for killer, data in pairs(getgenv().KillerCircles) do
        if data.visualization and data.visualization.mode == "Box" and data.visualization.box then
            data.visualization.box.Transparency = getgenv().BoxTransparency
        end
    end
end

RSvc.Heartbeat:Connect(function()
    if not (getgenv().InnerCircleVisible or getgenv().OuterCircleVisible) then return end
    
    local now = tick()
    if now - getgenv().lastVisUpdate < getgenv().visUpdateInterval then return end
    getgenv().lastVisUpdate = now
    
    local myRoot = LocalP.Character and LocalP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    for killer, data in pairs(getgenv().KillerCircles) do
        if killer:FindFirstChild("HumanoidRootPart") then
            local killerRoot = killer.HumanoidRootPart
            
            if data.innerCircle and data.innerCircle.Parent then
                data.innerCircle.Radius = getgenv().SenseRange
                local shouldBlock = getgenv().CheckAllBlockConditions(myRoot, killerRoot)
                data.innerCircle.Color3 = shouldBlock and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
            
            if data.outerCircle and data.outerCircle.Parent then
                data.outerCircle.Radius = getgenv().punchRange
                local dvec = killerRoot.Position - myRoot.Position
                local dist = math.sqrt(dvec.X^2 + dvec.Y^2 + dvec.Z^2)
                data.outerCircle.Color3 = dist <= getgenv().punchRange and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(0, 100, 100)
            end
            
            if data.visualization then
                pcall(getgenv().UpdateVisualization, data.visualization, myRoot)
            end
        end
    end
end)

getgenv().KillersFolder.ChildAdded:Connect(function(killer)
    if getgenv().InnerCircleVisible or getgenv().OuterCircleVisible then
        task.spawn(function()
            local hrp = killer:WaitForChild("HumanoidRootPart",5)
            if hrp then getgenv().AddKillerCircle(killer) end
        end)
    end
end)

getgenv().KillersFolder.ChildRemoved:Connect(function(killer)
    getgenv().RemoveKillerCircle(killer)
end)

getgenv().RefreshUI = function()
    getgenv().CachedGui = getgenv().LocalPlayer:FindFirstChild("PlayerGui") or getgenv().CachedGui
    local mainUI = getgenv().CachedGui and getgenv().CachedGui:FindFirstChild("MainUI")
    if mainUI then
        local abilityContainer = mainUI:FindFirstChild("AbilityContainer")
        getgenv().CachedPunchBtn = abilityContainer and abilityContainer:FindFirstChild("Punch")
        getgenv().CachedBlockBtn = abilityContainer and abilityContainer:FindFirstChild("Block")
        getgenv().CachedCharges = getgenv().CachedPunchBtn and getgenv().CachedPunchBtn:FindFirstChild("Charges")
        getgenv().CachedCooldown = getgenv().CachedBlockBtn and getgenv().CachedBlockBtn:FindFirstChild("CooldownTime")
    else
        getgenv().CachedPunchBtn,getgenv().CachedBlockBtn,getgenv().CachedCharges,getgenv().CachedCooldown = nil,nil,nil,nil
    end
end

getgenv().RefreshUI()

if getgenv().CachedGui then
    getgenv().CachedGui.ChildAdded:Connect(function(child)
        if child.Name == "MainUI" then
            task.delay(0.02,getgenv().RefreshUI)
        end
    end)
end

getgenv().LocalPlayer.CharacterAdded:Connect(function()
    task.delay(0.5,getgenv().RefreshUI)
end)

getgenv().getClosestKiller = function()
    local myChar = getgenv().LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest,closestDist = nil,math.huge
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        for _,name in ipairs(getgenv().KnownKillers) do
            local killer = killersFolder:FindFirstChild(name)
            if killer and killer:FindFirstChild("HumanoidRootPart") then
                local root = killer.HumanoidRootPart
                local dvec = root.Position - myRoot.Position
                local dist = math.sqrt(dvec.X^2 + dvec.Y^2 + dvec.Z^2)
                if dist < closestDist and dist <= getgenv().punchRange then
                    closest = killer
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

RSvc.Heartbeat:Connect(function()
    local now = tick()
    
    if getgenv().faceKillerUntil > now and getgenv().currentTargetKiller then
        local myChar = LocalP.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myRoot and getgenv().currentTargetKiller:FindFirstChild("HumanoidRootPart") then
            local killerRoot = getgenv().currentTargetKiller.HumanoidRootPart
            local direction = (killerRoot.Position - myRoot.Position)
            local flatDir = Vector3.new(direction.X, 0, direction.Z)
            if flatDir.Magnitude > 0.1 then
                myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + flatDir)
            end
        end
    else
        getgenv().currentTargetKiller = nil
    end
end)

getgenv().RunService.RenderStepped:Connect(function()
    if not getgenv().autoPunchOn and not getgenv().aimbotPunchOn then return end
    local myChar = getgenv().LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local gui = getgenv().CachedGui:FindFirstChild("MainUI")
    local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
    local charges = punchBtn and punchBtn:FindFirstChild("Charges")
    if punchBtn and charges and myRoot then
        local chargeCount = tonumber(charges.Text) or 0
        if chargeCount >= 1 then
            local killer = getgenv().getClosestKiller()
            if killer and killer:FindFirstChild("HumanoidRootPart") then
                if getgenv().aimbotPunchOn then
                    local currentTime = tick()
                    if currentTime - getgenv().lastAimbotTime >= getgenv().aimbotDelay then
                        getgenv().fireRemotePunch()
                        getgenv().lastAimbotTime = currentTime
                    end
                elseif getgenv().autoPunchOn then
                    getgenv().fireRemotePunch()
                end
            end
        end
    end
end)

getgenv().punchAnimIds = {
    "108911997126897","82137285150006","129843313690921",
    "140703210927645","136007065400978","86096387000557",
    "87259391926321","86709774283672","108807732150251",
    "138040001965654"
}

getgenv().killerNames = {"c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher","Sixer","Nosferatu"}
getgenv().autoFallPunchOn = false
getgenv().autoDashEnabled = false
getgenv().DASH_SPEED = 100
getgenv().MIN_TARGET_MAXHP = 300

if not getgenv().originalNamecall then
    getgenv().HookRules = {}
    getgenv().originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" then
            for _, rule in ipairs(getgenv().HookRules) do
                if (not rule.remoteName or self.Name == rule.remoteName) then
                    if not rule.blockedFirstArg or args[1] == rule.blockedFirstArg then
                        if rule.block then
                            return
                        end
                    end
                end
            end
        end
        return getgenv().originalNamecall(self, ...)
    end)
end

getgenv().activateRemoteHook = function(remoteName, blockedFirstArg)
    for _, rule in ipairs(getgenv().HookRules) do
        if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
            return
        end
    end
    table.insert(getgenv().HookRules, {
        remoteName = remoteName,
        blockedFirstArg = blockedFirstArg,
        block = true
    })
end

getgenv().deactivateRemoteHook = function(remoteName, blockedFirstArg)
    for i, rule in ipairs(getgenv().HookRules) do
        if rule.remoteName == remoteName and rule.blockedFirstArg == blockedFirstArg then
            table.remove(getgenv().HookRules, i)
            break
        end
    end
end

getgenv().EnableC00lkidd = function()
    getgenv().activateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "C00lkiddCollision")
end

getgenv().DisableC00lkidd = function()
    getgenv().deactivateRemoteHook("RemoteEvent", game.Players.LocalPlayer.Name .. "C00lkiddCollision")
end

local globalEnv = getgenv()
globalEnv.walkSpeed = 100
globalEnv.toggle = false
globalEnv.connection = nil

function globalEnv.getCharacter()
    return globalEnv.LocalPlayer.Character or globalEnv.LocalPlayer.CharacterAdded:Wait()
end

function globalEnv.onHeartbeat()
    local player = globalEnv.LocalPlayer
    local character = globalEnv.getCharacter()
    if character.Name ~= "c00lkidd" then return end
    
    local char = globalEnv.getCharacter()
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local lv = rootPart and rootPart:FindFirstChild("LinearVelocity")
    
    if not rootPart or not humanoid or not lv then return end
    
    if lv then
        lv.VectorVelocity = Vector3.new(math.huge, math.huge, math.huge)
        lv.Enabled = false
    end

    local stopMovement = false
    local validValues = {
        Timeout = true,
        Collide = true,
        Hit = true
    }

    if not stopMovement then
        local lookVector = workspace.CurrentCamera.CFrame.LookVector
        local moveDir = Vector3.new(lookVector.X, 0, lookVector.Z)
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            rootPart.Velocity = Vector3.new(moveDir.X * globalEnv.walkSpeed, rootPart.Velocity.Y, moveDir.Z * globalEnv.walkSpeed)
            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + moveDir)
        end
    end
end

local function validTarget(player)
    if not player or player == getgenv().LocalPlayer then return false end
    local char = player.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return false end
    if humanoid.Health <= 0 then return false end
    if humanoid.MaxHealth < getgenv().MIN_TARGET_MAXHP then return false end
    local myChar = getgenv().LocalPlayer.Character
    if not myChar then return false end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end
    if (hrp.Position - myHrp.Position).Magnitude > getgenv().punchRange then return false end
    return true
end

local function findClosestValidTarget()
    local best, bestDist = nil, math.huge
    local myChar = getgenv().LocalPlayer.Character
    if not myChar then return nil end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    for _, p in pairs(getgenv().Players:GetPlayers()) do
        if validTarget(p) then
            local targetHrp = p.Character:FindFirstChild("HumanoidRootPart")
            local d = (targetHrp.Position - myHrp.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = p
            end
        end
    end
    return best
end

local function isPunchAnimationPlaying()
    local char = getgenv().LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local trackList = humanoid:GetPlayingAnimationTracks()
    for _, track in ipairs(trackList) do
        local animId = tostring(track.Animation.AnimationId)
        for _, id in ipairs(getgenv().punchAnimIds) do
            if animId == "rbxassetid://" .. id then
                return true
            end
        end
    end
    return false
end

getgenv().RunService.Heartbeat:Connect(function()
    local myChar = getgenv().LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local gui = getgenv().LocalPlayer.PlayerGui:FindFirstChild("MainUI")
    local punchBtn = gui and gui:FindFirstChild("AbilityContainer") and gui.AbilityContainer:FindFirstChild("Punch")
    local charges = punchBtn and punchBtn:FindFirstChild("Charges")
    
    if getgenv().autoFallPunchOn and punchBtn and charges and myRoot then
        local chargeCount = tonumber(charges.Text) or 0
        if chargeCount >= 1 then
            local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
            if killersFolder then
                for _, name in ipairs(getgenv().killerNames) do
                    local killer = killersFolder:FindFirstChild(name)
                    if killer and killer:FindFirstChild("HumanoidRootPart") then
                        local root = killer.HumanoidRootPart
                        if (root.Position - myRoot.Position).Magnitude <= getgenv().punchRange then
                            myRoot.CFrame = myRoot.CFrame + Vector3.new(0, 8, 0)
                            getgenv().fireRemotePunch()
                            task.wait(0.01)
                        end
                    end
                end
            end
        end
    end
    
    if not getgenv().autoDashEnabled then return end
    local char = getgenv().LocalPlayer.Character
    if not char or char.Name ~= "Guest1337" then return end
    if not isPunchAnimationPlaying() then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local target = findClosestValidTarget()
    if target and target.Character then
        local tgtHrp = target.Character:FindFirstChild("HumanoidRootPart")
        if tgtHrp then
            local dir = (tgtHrp.Position - rootPart.Position)
            local horiz = Vector3.new(dir.X, 0, dir.Z)
            local dist = horiz.Magnitude
            if dist > 3 then
                local unit = horiz.Unit
                local vel = unit * getgenv().DASH_SPEED
                local currentY = rootPart.AssemblyLinearVelocity.Y
                rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, currentY, vel.Z)
            end
        end
    end
end)

local MainBlockTab = Tabs.Block:AddLeftTabbox()
local MainGroup = MainBlockTab:AddTab("Block")
local CombatGroup = MainBlockTab:AddTab("Punch")
local BoxGroup = MainBlockTab:AddTab("Box")
local AdvancedGroup = MainBlockTab:AddTab("Misc")

MainGroup:AddToggle("AutoBlockToggle",{
    Text = "Auto Block",
    Default = false,
    Tooltip = "Toggle Auto Block",
    Callback = function(Value)
        getgenv().AutoBlockEnabled = Value
    end,
})

MainGroup:AddToggle("InnerCircleToggle",{
    Text = "Visualization",
    Default = false,
    Tooltip = "Show Killer Inner Block Range",
    Callback = function(Value)
        getgenv().InnerCircleVisible = Value
        getgenv().RefreshKillerCircles()
    end,
})

MainGroup:AddDropdown("VisualizationModeDropdown",{
    Values = {"Compass", "Static", "Box", "Sphere"},
    Default = 1,
    Multi = false,
    Text = "Visual Mode",
    Tooltip = "Select Visualization Mode\nCompass: Range faces player\nStatic: Range follows killer's facing\nBox: Rectangular detection range\nSphere: Spherical detection range",
    Callback = function(Value)
        getgenv().UpdateVisualizationMode(Value)
    end
})

MainGroup:AddToggle("FacingCheck",{
    Text = "Player Facing Check",
    Default = false,
    Tooltip = "Block Only When Facing Killer",
    Callback = function(Value)
        getgenv().FacingCheckEnabled = Value
    end,
})

MainGroup:AddToggle("KillerFacingCheck",{
    Text = "Killer Facing Check",
    Default = false,
    Tooltip = "Block Only When Killer Faces Player",
    Callback = function(Value)
        getgenv().KillerFacingCheckEnabled = Value
    end,
})

MainGroup:AddToggle("WallCheck",{
    Text = "Wallcheck",
    Default = false,
    Tooltip = "Check Wall Obstruction",
    Callback = function(Value)
        getgenv().wallCheckEnabled = Value
    end,
})

MainGroup:AddSlider("CompassTransparency",{
    Text = "Compass Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Tooltip = "Compass Mode Visualization Opacity",
    Callback = function(Value)
        for killer, data in pairs(getgenv().KillerCircles) do
            if data.visualization and data.visualization.mode == "Compass" and data.visualization.parts then
                for _, part in ipairs(data.visualization.parts) do
                    part.Transparency = Value
                end
            end
        end
    end,
})

MainGroup:AddSlider("StaticTransparency",{
    Text = "Static Transparency",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Tooltip = "Static Mode Visualization Opacity",
    Callback = function(Value)
        for killer, data in pairs(getgenv().KillerCircles) do
            if data.visualization and data.visualization.mode == "Static" and data.visualization.parts then
                for _, part in ipairs(data.visualization.parts) do
                    part.Transparency = Value
                end
            end
        end
    end,
})

MainGroup:AddSlider("SphereTransparency",{
    Text = "Sphere Transparency",
    Default = 0.8,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Tooltip = "Sphere Mode Visualization Opacity",
    Callback = function(Value)
        for killer, data in pairs(getgenv().KillerCircles) do
            if data.visualization and data.visualization.mode == "Sphere" and data.visualization.sphere then
                data.visualization.sphere.Transparency = Value
            end
        end
    end,
})

MainGroup:AddSlider("SenseRange",{
    Text = "Block Range",
    Default = 18,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Tooltip = "Block Detection Range",
    Callback = function(Value)
        getgenv().SenseRange = Value
        getgenv().SenseRangeSq = Value * Value
    end,
})

MainGroup:AddSlider("PlayerFacingAngle",{
    Text = "Player Facing Angle",
    Default = 90,
    Min = 30,
    Max = 180,
    Rounding = 1,
    Tooltip = "Player Facing Angle Check",
    Callback = function(Value)
        getgenv().PlayerFacingAngle = Value
    end,
})

MainGroup:AddSlider("KillerFacingAngle",{
    Text = "Killer Facing Angle",
    Default = 90,
    Min = 30,
    Max = 180,
    Rounding = 1,
    Tooltip = "Killer Facing Angle Check",
    Callback = function(Value)
        getgenv().KillerFacingAngle = Value
    end,
})

MainGroup:AddSlider("MaxSoundAge",{
    Text = "Max Sound Detection Duration (s)",
    Default = 1.5,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Tooltip = "Ignore Sounds Longer Than This Duration",
    Callback = function(Value)
        getgenv().MaxSoundAge = Value
    end,
})

MainGroup:AddSlider("MaxAnimAge",{
    Text = "Max Animation Detection Duration (s)",
    Default = 1.5,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Tooltip = "Ignore Animations Longer Than This Duration",
    Callback = function(Value)
        getgenv().MaxAnimAge = Value
    end,
})

CombatGroup:AddToggle("AutoPunch", {
    Text = "auto punch",
    Default = false,
    Tooltip = "Auto Punch Enemies in Range",
    Callback = function(Value)
        getgenv().autoPunchOn = Value
    end
})

CombatGroup:AddToggle("AimbotPunch", {
    Text = "aimbot punch",
    Default = false,
    Tooltip = "Auto Face Killer for 3s After Punch",
    Callback = function(Value)
        getgenv().aimbotPunchOn = Value
    end
})

CombatGroup:AddToggle("OuterCircleToggle",{
    Text = "Visual",
    Default = false,
    Tooltip = "Show Killer Outer Punch Range",
    Callback = function(Value)
        getgenv().OuterCircleVisible = Value
        getgenv().RefreshKillerCircles()
    end,
})

CombatGroup:AddSlider("PunchRange", {
    Text = "Punch Range",
    Default = 50,
    Min = 10,
    Max = 100,
    Rounding = 1,
    Tooltip = "Punch Detection Range",
    Callback = function(Value)
        getgenv().punchRange = Value
    end
})

CombatGroup:AddSlider("AimbotDelay", {
    Text = "Aimbot Punch Interval",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Tooltip = "Delay between Aimbot Punches (s)",
    Callback = function(Value)
        getgenv().aimbotDelay = Value
    end
})

CombatGroup:AddSlider("FaceKillerDuration", {
    Text = "Duration",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Tooltip = "Time Facing Killer After Punch (s)",
    Callback = function(Value)
        getgenv().faceKillerDuration = Value
    end
})

CombatGroup:AddToggle("AutoFallPunch", {
    Text = "Air Combo",
    Default = false,
    Tooltip = "Auto Punch in Air",
    Callback = function(Value)
        getgenv().autoFallPunchOn = Value
    end
})

AdvancedGroup:AddToggle("HDPullToggle", {
    Text = "Block Pull [HDPull]",
    Default = false,
    Tooltip = "Auto Pull on Block",
    Callback = function(Value)
        getgenv().HDPullEnabled = Value
    end
})

AdvancedGroup:AddSlider("HDSpeed", {
    Text = "Move Speed",
    Default = 12,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Tooltip = "Block Move Speed",
    Callback = function(Value)
        getgenv().HDSpeed = Value
    end
})

AdvancedGroup:AddToggle("AutoDash", {
    Text = "Auto Lock",
    Default = false,
    Tooltip = "auto punch killer",
    Callback = function(Value)
        getgenv().autoDashEnabled = Value
    end
})

AdvancedGroup:AddSlider("DashSpeed", {
    Text = "Dash Speed",
    Default = 100,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Tooltip = "Auto Dash Speed",
    Callback = function(Value)
        getgenv().DASH_SPEED = Value
    end
})

BoxGroup:AddSlider("BoxLength",{
    Text = "Box Length",
    Default = 7.5,
    Min = 1,
    Max = 15,
    Rounding = 1,
    Tooltip = "Box Mode Length [Box Mode Only]",
    Callback = function(Value)
        getgenv().BoxLength = Value
    end,
})

BoxGroup:AddSlider("BoxWidth",{
    Text = "Box Width",
    Default = 4.5,
    Min = 2,
    Max = 15,
    Rounding = 1,
    Tooltip = "Box Width [Box Mode Only]",
    Callback = function(Value)
        getgenv().BoxWidth = Value
    end,
})

BoxGroup:AddSlider("BoxHeight",{
    Text = "Box Height",
    Default = 6,
    Min = 2,
    Max = 10,
    Rounding = 1,
    Tooltip = "Box Height [Box Mode Only]",
    Callback = function(Value)
        getgenv().BoxHeight = Value
    end,
})

BoxGroup:AddSlider("BoxSizeMultiplier",{
    Text = "Box Size Multiplier",
    Default = 1.0,
    Min = 0.5,
    Max = 3.0,
    Rounding = 2,
    Tooltip = "Box size multiplier",
    Callback = function(Value)
        getgenv().BoxSizeMultiplier = Value
    end,
})

BoxGroup:AddSlider("BoxForwardOffset",{
    Text = "Box Forward Offset",
    Default = -1.4,
    Min = -10,
    Max = 10,
    Rounding = 1,
    Tooltip = "Box offset in the forward direction",
    Callback = function(Value)
        getgenv().BoxForwardOffset = Value
    end,
})

BoxGroup:AddSlider("BoxTransparency",{
    Text = "Box Transparency",
    Default = 0.7,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Tooltip = "Box Opacity [0 = Opaque, 1 = Transparent]",
    Callback = function(Value)
        getgenv().BoxTransparency = Value
        getgenv().UpdateBoxColors()
    end,
})

BoxGroup:AddLabel("Safe Color [In Range]:")
BoxGroup:AddSlider("BoxSafeColorR",{
    Text = "red (R)",
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Safe Box Red",
    Callback = function(Value)
        local current = getgenv().BoxSafeColor
        getgenv().BoxSafeColor = Color3.fromRGB(Value, current.G * 255, current.B * 255)
    end,
})

BoxGroup:AddSlider("BoxSafeColorG",{
    Text = "green (G)",
    Default = 255,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Safe Box Green",
    Callback = function(Value)
        local current = getgenv().BoxSafeColor
        getgenv().BoxSafeColor = Color3.fromRGB(current.R * 255, Value, current.B * 255)
    end,
})

BoxGroup:AddSlider("BoxSafeColorB",{
    Text = "blue (B)",
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Safe Box Blue",
    Callback = function(Value)
        local current = getgenv().BoxSafeColor
        getgenv().BoxSafeColor = Color3.fromRGB(current.R * 255, current.G * 255, Value)
    end,
})

BoxGroup:AddLabel("Danger Color [Out of Range]:")

BoxGroup:AddSlider("BoxDangerColorR",{
    Text = "red (R)",
    Default = 255,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Danger Red",
    Callback = function(Value)
        local current = getgenv().BoxDangerColor
        getgenv().BoxDangerColor = Color3.fromRGB(Value, current.G * 255, current.B * 255)
    end,
})

BoxGroup:AddSlider("BoxDangerColorG",{
    Text = "green (G)",
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Danger Green",
    Callback = function(Value)
        local current = getgenv().BoxDangerColor
        getgenv().BoxDangerColor = Color3.fromRGB(current.R * 255, Value, current.B * 255)
    end,
})

BoxGroup:AddSlider("BoxDangerColorB",{
    Text = "blue (B)",
    Default = 0,
    Min = 0,
    Max = 255,
    Rounding = 0,
    Tooltip = "Danger Blue",
    Callback = function(Value)
        local current = getgenv().BoxDangerColor
        getgenv().BoxDangerColor = Color3.fromRGB(current.R * 255, current.G * 255, Value)
    end,
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("UI settings")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,  
    Text = "show keybinds",
    Callback = function(value)
        Library.KeybindFrame.Visible = value  
    end,
})


MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "mouse cursor",
    Default = true,  
    Callback = function(Value)
        Library.ShowCustomCursor = Value  
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",  
    Text = "notify side",
    Callback = function(Value)
        Library:SetNotifySide(Value)  
    end,
})

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "25%", "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "75%",  
    Text = "UI scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")  
        local DPI = tonumber(Value)   
        Library:SetDPIScale(DPI)      
    end,
})


MenuGroup:AddDivider()  
MenuGroup:AddLabel("Menu bind")  
    :AddKeyPicker("MenuKeybind", { 
        Default = "RightShift",  
        NoUI = true,            
        Text = "Menu keybind"    
    })


MenuGroup:AddButton("unload UI", function()
    Library:Unload()  
end)




ThemeManager:SetLibrary(Library)  
SaveManager:SetLibrary(Library)   
SaveManager:IgnoreThemeSettings() 


SaveManager:SetIgnoreIndexes({ "MenuKeybind" })  
ThemeManager:SetFolder("MyScriptHub")            
SaveManager:SetFolder("MyScriptHub/specific-game")  
SaveManager:SetSubFolder("specific-place")       
SaveManager:BuildConfigSection(Tabs["UI Settings"])  

ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()





    Library:SetWatermarkVisibility(true)

    local function updateWatermark()
        local fps = 60
        local frameTimer = tick()
        local frameCounter = 0

        game:GetService('RunService').RenderStepped:Connect(function()
            frameCounter = frameCounter + 1

            if ((tick() - frameTimer) >= 1) then
                fps = frameCounter
                frameTimer = tick()
                frameCounter = 0
            end

            Library:SetWatermark(string.format('NOL | %d FPS |  %d ping ', math.floor(fps), math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())))
        end)
    end

    updateWatermark()


