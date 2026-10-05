local function safeNotify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local A = game:GetService("StarterGui")

local function gradient(text, startColor, endColor)
    local result = ""
    local chars = {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    local length = #chars
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = startColor.R + (endColor.R - startColor.R) * t
        local g = startColor.G + (endColor.G - startColor.G) * t
        local b = startColor.B + (endColor.B - startColor.B) * t
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>',
            math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), chars[i])
    end
    return result
end

local WindUI
do
    local ok, result = pcall(function()
        local code = game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua", true)
        if type(code) ~= "string" or #code < 100 then
            error("WindUI下载内容为空")
        end
        local loader = loadstring(code)
        if type(loader) ~= "function" then
            error("WindUI loadstring失败")
        end
        return loader()
    end)
    if not ok or not result then
        pcall(function()
            A:SetCore("SendNotification", {
                Title="WindUI加载失败",
                Text="请检查执行器的HttpGet/loadstring支持",
                Duration=6
            })
        end)
        error("WindUI加载失败: "..tostring(result))
    end
    WindUI = result
end

local windowOk, D = pcall(function()
    return WindUI:CreateWindow({
        Title="ink_HUB",
        Author="@墨水依旧 司空",
        Icon="rbxassetid://71953031400395",
        Folder="ink_HUB",
        NewElements=true,
        HideSearchBar=false,
    })
end)
if not windowOk or not D then
    warn("[ink_HUB] UI创建失败:", tostring(D))
    return
end


local Z = D:Tab({Title="公告", Icon="bell"})
Z:Paragraph({
    Title = "欢迎使用 ink_HUB",
    Desc = "作者：墨水依旧和司空\n墨水快手号:zczczczc766\n司空快手号:smalldesikon111和smalldesikon\n开源并公开的4000+\n没惹你就开源的自动给我30年寿命\n公益脚本禁止倒卖\n认准 ink_HUB",
    Image = "rbxassetid://131444442444524",
    ImageSize = 100,
})

local player = game.Players.LocalPlayer

Z:Paragraph({
    Title = "系统信息",
    Desc = string.format("用户名: %s\n显示名: %s\n用户ID: %d\n账号年龄: %d天",
        player.Name, player.DisplayName, player.UserId, player.AccountAge),
    Image = "rbxassetid://131444442444524",
    ImageSize = 100,
})

Z:Button({Title="复制作者QQ", Callback=function() setclipboard("2047955671") A:SetCore("SendNotification",{Title="已复制", Text="作者QQ：2047955671", Duration=2}) end})
Z:Button({Title="复制作者QQ群", Callback=function() setclipboard("1101093219") A:SetCore("SendNotification",{Title="已复制", Text="作者QQ群：1101093219", Duration=2}) end})
Z:Button({Title="复制作者副群", Callback=function() setclipboard("1063828524") A:SetCore("SendNotification",{Title="已复制", Text="作者副群：1063828524", Duration=2}) end})


local GeneralTab = D:Tab({Title="主要功能", Icon="settings"})
local LocalPlayer = game:GetService("Players").LocalPlayer

-- 第一脚本中可用的 WalkSpeed
local speedEnabled = false
local speedValue = 16
GeneralTab:Toggle({
    Title = "启用修改速度",
    Value = false,
    Callback = function(v)
        speedEnabled = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and speedValue or 16 end
    end
})
GeneralTab:Slider({
    Title = "修改速度",
    Value = {Min=16, Max=100, Default=16},
    Step = 1,
    Callback = function(v)
        speedValue = v
        if speedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    end
})

-- 第一脚本中的飞行入口
GeneralTab:Button({
    Title = "飞行",
    Callback = function()
        local ok, err = pcall(function()
            local src = game:HttpGet("https://raw.githubusercontent.com/inkkkkkkkk/Theinkremains/refs/heads/main/%E9%A3%9E%E8%A1%8C%E8%84%9A%E6%9C%AC.lua")
            local fn = loadstring(src)
            if type(fn) ~= "function" then error("飞行脚本加载失败") end
            fn()
        end)
        if not ok then warn("[ink_HUB] 飞行加载失败:", tostring(err)) end
    end
})

-- 第一脚本中的穿墙
local noclipEnabled = false
local function applyNoClip(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end
GeneralTab:Toggle({
    Title = "穿墙",
    Value = false,
    Callback = function(v)
        noclipEnabled = v
        applyNoClip(v)
    end
})
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.15)
    if noclipEnabled then applyNoClip(true) end
    if speedEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speedValue end
    end
end)

-- 第一脚本中的高亮/全亮
local Lighting = game:GetService("Lighting")
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
GeneralTab:Toggle({
    Title = "高亮",
    Value = false,
    Callback = function(v)
        if v then
            Lighting.Brightness = 5
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
        else
            Lighting.Brightness = originalBrightness
            Lighting.Ambient = originalAmbient
            Lighting.OutdoorAmbient = originalOutdoorAmbient
        end
    end
})

-- 第一脚本中的视野/FOV
GeneralTab:Slider({
    Title = "视野",
    Value = {Min=60, Max=120, Default=70},
    Step = 1,
    Callback = function(v)
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = v end
    end
})

-- 第二脚本剩余功能：第三人称
GeneralTab:Toggle({
    Title = "第三人称",
    Value = false,
    Callback = function(v)
        local ok = pcall(function()
            if v then
                LocalPlayer.CameraMode = Enum.CameraMode.Classic
            else
                LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
            end
        end)
        if not ok then warn("[ink_HUB] 第三人称设置失败") end
    end
})

-- 第二脚本剩余功能：瞬间交互
local proximityConnection
local proximityChanged = {}
local function enableInstantProximity()
    local workspaceService = workspace
    local function patch(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") then return end
        if not proximityChanged[prompt] then
            proximityChanged[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0.0001
        prompt.Changed:Connect(function()
            if prompt.Parent and prompt.HoldDuration > 0.0001 then
                prompt.HoldDuration = 0.0001
            end
        end)
    end
    for _, obj in ipairs(workspaceService:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then patch(obj) end
    end
    proximityConnection = workspaceService.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then patch(obj) end
    end)
end
local function disableInstantProximity()
    if proximityConnection then
        proximityConnection:Disconnect()
        proximityConnection = nil
    end
    for prompt, oldValue in pairs(proximityChanged) do
        if prompt and prompt.Parent then
            pcall(function() prompt.HoldDuration = oldValue end)
        end
    end
    proximityChanged = {}
end
GeneralTab:Toggle({
    Title = "瞬间交互",
    Value = false,
    Callback = function(v)
        if v then
            enableInstantProximity()
        else
            disableInstantProximity()
        end
    end
})


local function forceChatVisible()
    local player = game:GetService("Players").LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    local CoreGui = game:GetService("CoreGui")
    pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
    local chatFrame = player.PlayerGui:FindFirstChild("Chat") or CoreGui:FindFirstChild("Chat")
    if chatFrame and chatFrame:IsA("Frame") then
        chatFrame.Visible = true
    end
    local textChat = game:GetService("TextChatService")
    pcall(function()
        textChat.ChatWindowConfiguration.Enabled = true
        textChat.ChatInputBarConfiguration.Enabled = true
    end)
    local chatWindows = CoreGui:FindFirstChild("ChatWindow")
    if chatWindows then chatWindows.Visible = true end
end
GeneralTab:Button({Title="强制显示聊天框", Callback=forceChatVisible})

local P = D:Tab({Title="透视", Icon="eye"})

local espEnabled = false
local outlineEnabled = false
local tracersEnabled = false
local entityNameEnabled = false
local entityTracerEnabled = false
local itemNameEnabled = false
local itemTracerEnabled = false

local ESP_PLAYER_COLOR = Color3.fromRGB(0, 255, 255)
local ESP_ENTITY_COLOR = Color3.fromRGB(255, 170, 0)
local ESP_ITEM_COLOR = Color3.fromRGB(0, 255, 100)
local ESP_OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)

local espconfig = {
    espcolor = ESP_PLAYER_COLOR,
    outlinecolor = ESP_OUTLINE_COLOR,
    outlinefillcolor = ESP_PLAYER_COLOR,
    tracercolor = ESP_PLAYER_COLOR,
    espsize = 16,
    tracersize = 2,
    outlinetransparency = 0,
    outlinefilltransparency = 1,
    tracerposition = "底部",
}

local espobjects = {}
local playerconnections = {}
local tracerlines = {}
local activehighlights = {}
local entityLabels = {}
local entityTracers = {}
local itemEspEnabled = false
local itemEspConnections = {}
local itemEspObjects = {}
local itemTracers = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function createBillboard(adornee, text, color, name)
    if not adornee then return nil end
    local gui = Instance.new("BillboardGui")
    gui.Name = name
    gui.Adornee = adornee
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 180, 0, 28)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.Parent = gui
    gui.Parent = adornee
    return gui
end

local function getPlayerWeapon(player)
    if not player.Character then return "无" end
    local tool = player.Character:FindFirstChildWhichIsA("Tool")
    return tool and tool.Name or "无"
end

local function createesp(player)
    if player == LocalPlayer or espobjects[player] then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local gui = createBillboard(root, player.Name, ESP_PLAYER_COLOR, "ink_PlayerESP")
    if gui then espobjects[player] = { Name = gui } end
end

local function removeesp(player)
    if espobjects[player] then
        pcall(function() espobjects[player].Name:Destroy() end)
        espobjects[player] = nil
    end
end

local function applyhighlighttocharacter(player, character)
    if not character then return end
    local userid = player.UserId
    if activehighlights[userid] then activehighlights[userid]:Destroy() end
    local highlighter = Instance.new("Highlight")
    highlighter.FillTransparency = espconfig.outlinefilltransparency
    highlighter.OutlineTransparency = espconfig.outlinetransparency
    highlighter.OutlineColor = ESP_OUTLINE_COLOR
    highlighter.FillColor = ESP_PLAYER_COLOR
    highlighter.Adornee = character
    highlighter.Parent = character
    activehighlights[userid] = highlighter
end

local function removehighlight(player)
    local userid = player.UserId
    if activehighlights[userid] then activehighlights[userid]:Destroy(); activehighlights[userid] = nil end
    if playerconnections[userid] then
        for _, conn in pairs(playerconnections[userid]) do pcall(function() conn:Disconnect() end) end
        playerconnections[userid] = nil
    end
end

local function setupplayerhighlight(player)
    local userid = player.UserId
    playerconnections[userid] = playerconnections[userid] or {}
    local function oncharacteradded(character)
        if not character then return end
        task.spawn(function()
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not humanoid then return end
            if outlineEnabled then applyhighlighttocharacter(player, character) end
            table.insert(playerconnections[userid], humanoid.Died:Connect(function() removehighlight(player) end))
        end)
    end
    table.insert(playerconnections[userid], player.CharacterAdded:Connect(oncharacteradded))
    if player.Character then oncharacteradded(player.Character) end
end

local function updateesp()
    for player, esp in pairs(espobjects) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local gui = esp.Name
        if root and gui then
            gui.Enabled = true
            local label = gui:FindFirstChildOfClass("TextLabel")
            if label then
                local distance = (Camera.CFrame.Position - root.Position).Magnitude
                label.Text = player.Name .. " | " .. math.floor(distance) .. " 米 | " .. getPlayerWeapon(player)
                label.TextColor3 = ESP_PLAYER_COLOR
            end
        elseif gui then
            gui.Enabled = false
        end
    end
end

local function clearPlayerTracers()
    for _, line in pairs(tracerlines) do pcall(function() line:Remove() end) end
    tracerlines = {}
end

local function createtracers()
    clearPlayerTracers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local line = Drawing.new("Line")
            line.Thickness = espconfig.tracersize
            line.Transparency = 1
            line.Color = ESP_PLAYER_COLOR
            line.Visible = false
            tracerlines[player] = line
        end
    end
end

local function updatetracers()
    local screenHeight = Camera.ViewportSize.Y
    local fromY = screenHeight
    if espconfig.tracerposition == "中间" then fromY = screenHeight / 2
    elseif espconfig.tracerposition == "顶部" then fromY = 0 end
    for player, line in pairs(tracerlines) do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local screenpos, onscreen = Camera:WorldToViewportPoint(root.Position)
            line.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            line.To = Vector2.new(screenpos.X, screenpos.Y)
            line.Color = ESP_PLAYER_COLOR
            line.Visible = onscreen and tracersEnabled
        else
            line.Visible = false
        end
    end
end

local function clearEntityESP()
    for obj, gui in pairs(entityLabels) do if gui then pcall(function() gui:Destroy() end) end entityLabels[obj] = nil end
    for obj, line in pairs(entityTracers) do if line then pcall(function() line:Remove() end) end entityTracers[obj] = nil end
end

local function isNPCModel(obj)
    if not obj or not obj:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
    return hum ~= nil and root ~= nil
end

local function addEntityESP(obj)
    if not isNPCModel(obj) then return end
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
    if not root then return end
    if entityLabels[obj] then pcall(function() entityLabels[obj]:Destroy() end) end
    if entityNameEnabled then
        entityLabels[obj] = createBillboard(root, obj.Name, ESP_ENTITY_COLOR, "ink_EntityESP")
    end
    if entityTracerEnabled and not entityTracers[obj] then
        local line = Drawing.new("Line")
        line.Thickness = espconfig.tracersize
        line.Transparency = 1
        line.Color = ESP_ENTITY_COLOR
        line.Visible = false
        entityTracers[obj] = line
    end
end

local function setEntityESP(state)
    clearEntityESP()
    if not state and not entityNameEnabled and not entityTracerEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do if isNPCModel(obj) then addEntityESP(obj) end end
end

local function clearItemESP()
    for obj, gui in pairs(itemEspObjects) do if gui then pcall(function() gui:Destroy() end) end itemEspObjects[obj] = nil end
    for obj, line in pairs(itemTracers) do if line then pcall(function() line:Remove() end) end itemTracers[obj] = nil end
end

local function isItemObject(obj) return obj and obj:IsA("Tool") end

local function addItemESP(obj)
    if not isItemObject(obj) then return end
    local adornee = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then return end
    if itemEspObjects[obj] then pcall(function() itemEspObjects[obj]:Destroy() end) end
    if itemNameEnabled then
        itemEspObjects[obj] = createBillboard(adornee, obj.Name, ESP_ITEM_COLOR, "ink_ItemESP")
    end
    if itemTracerEnabled and not itemTracers[obj] then
        local line = Drawing.new("Line")
        line.Thickness = espconfig.tracersize
        line.Transparency = 1
        line.Color = ESP_ITEM_COLOR
        line.Visible = false
        itemTracers[obj] = line
    end
end

local function setItemESP(state)
    itemEspEnabled = state
    for _, conn in pairs(itemEspConnections) do pcall(function() conn:Disconnect() end) end
    itemEspConnections = {}
    clearItemESP()
    if not state and not itemNameEnabled and not itemTracerEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do if isItemObject(obj) then addItemESP(obj) end end
    table.insert(itemEspConnections, workspace.DescendantAdded:Connect(function(obj)
        if isItemObject(obj) then task.defer(function() addItemESP(obj) end) end
    end))
    table.insert(itemEspConnections, workspace.DescendantRemoving:Connect(function(obj)
        if itemEspObjects[obj] then pcall(function() itemEspObjects[obj]:Destroy() end); itemEspObjects[obj] = nil end
        if itemTracers[obj] then pcall(function() itemTracers[obj]:Remove() end); itemTracers[obj] = nil end
    end))
end

local function updateExtraTracers()
    for obj, gui in pairs(entityLabels) do
        local root = obj and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head"))
        if root and gui then
            gui.Enabled = entityNameEnabled
            local label = gui:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = obj.Name .. " | " .. math.floor((Camera.CFrame.Position - root.Position).Magnitude) .. " 米"
                label.TextColor3 = ESP_ENTITY_COLOR
            end
        elseif gui then gui.Enabled = false end
    end
    for obj, gui in pairs(itemEspObjects) do
        local part = obj and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true))
        if part and gui then
            gui.Enabled = itemNameEnabled
            local label = gui:FindFirstChildOfClass("TextLabel")
            if label then
                label.Text = obj.Name .. " | " .. math.floor((Camera.CFrame.Position - part.Position).Magnitude) .. " 米"
                label.TextColor3 = ESP_ITEM_COLOR
            end
        elseif gui then gui.Enabled = false end
    end
    local screenHeight = Camera.ViewportSize.Y
    local fromY = screenHeight
    if espconfig.tracerposition == "中间" then fromY = screenHeight / 2
    elseif espconfig.tracerposition == "顶部" then fromY = 0 end
    for obj, line in pairs(entityTracers) do
        local root = obj and (obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head"))
        if root then
            local pos, visible = Camera:WorldToViewportPoint(root.Position)
            line.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            line.To = Vector2.new(pos.X, pos.Y)
            line.Color = ESP_ENTITY_COLOR
            line.Visible = entityTracerEnabled and visible
        else line.Visible = false end
    end
    for obj, line in pairs(itemTracers) do
        local part = obj and (obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true))
        if part then
            local pos, visible = Camera:WorldToViewportPoint(part.Position)
            line.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
            line.To = Vector2.new(pos.X, pos.Y)
            line.Color = ESP_ITEM_COLOR
            line.Visible = itemTracerEnabled and visible
        else line.Visible = false end
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if espEnabled then createesp(p) end
            if outlineEnabled and p.Character then applyhighlighttocharacter(p, p.Character) end
        end)
        if espEnabled then createesp(p) end
        if outlineEnabled then setupplayerhighlight(p) end
        if tracersEnabled then
            local line = Drawing.new("Line")
            line.Thickness = espconfig.tracersize
            line.Color = ESP_PLAYER_COLOR
            line.Visible = false
            tracerlines[p] = line
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeesp(p)
    removehighlight(p)
    if tracerlines[p] then tracerlines[p]:Remove(); tracerlines[p] = nil end
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function()
            task.wait(0.1)
            if espEnabled then createesp(p) end
            if outlineEnabled and p.Character then applyhighlighttocharacter(p, p.Character) end
        end)
    end
end

local espGroup = P:Section({ Title = "基础透视", Opened = true })
espGroup:Toggle({Title="透视", Value=false, Callback=function(v)
    espEnabled = v
    if v then
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createesp(p) end end
        RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Camera.Value + 1, updateesp)
    else
        for p in pairs(espobjects) do removeesp(p) end
        RunService:UnbindFromRenderStep("ESPUpdate")
    end
end})

espGroup:Toggle({Title="追踪线", Value=false, Callback=function(v)
    tracersEnabled = v
    if v then
        createtracers()
        RunService:BindToRenderStep("Tracers", Enum.RenderPriority.Camera.Value + 1, updatetracers)
    else
        RunService:UnbindFromRenderStep("Tracers")
        clearPlayerTracers()
    end
end})

espGroup:Toggle({Title="轮廓", Value=false, Callback=function(v)
    outlineEnabled = v
    if v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                setupplayerhighlight(p)
                if p.Character then applyhighlighttocharacter(p, p.Character) end
            end
        end
    else
        for _, p in ipairs(Players:GetPlayers()) do removehighlight(p) end
    end
end})

espGroup:Toggle({Title="透视实体", Value=false, Callback=function(v)
    entityNameEnabled = v
    clearEntityESP()
    if v or entityTracerEnabled then setEntityESP(true) end
end})

espGroup:Toggle({Title="实体追踪线", Value=false, Callback=function(v)
    entityTracerEnabled = v
    clearEntityESP()
    if v or entityNameEnabled then setEntityESP(true) end
end})

espGroup:Toggle({Title="透视物品", Value=false, Callback=function(v)
    itemNameEnabled = v
    setItemESP(v or itemTracerEnabled)
end})

espGroup:Toggle({Title="物品追踪线", Value=false, Callback=function(v)
    itemTracerEnabled = v
    setItemESP(v or itemNameEnabled)
end})

local configGroup = P:Section({ Title = "高级配置", Opened = false })
configGroup:Slider({Title="透视大小", Value={Min=16,Max=48,Default=16}, Step=1, Callback=function(v) espconfig.espsize=v end})
configGroup:Dropdown({Title="追踪线位置", Values={"底部","中间","顶部"}, Value="底部", Callback=function(v) espconfig.tracerposition=v end})
configGroup:Slider({Title="轮廓透明度", Value={Min=0,Max=100,Default=0}, Step=1, Callback=function(v) espconfig.outlinetransparency=v/100 end})
configGroup:Slider({Title="轮廓填充透明度", Value={Min=0,Max=100,Default=50}, Step=1, Callback=function(v) espconfig.outlinefilltransparency=v/100 end})

RunService:BindToRenderStep("ink_ExtraESPTracers", Enum.RenderPriority.Camera.Value + 2, updateExtraTracers)

