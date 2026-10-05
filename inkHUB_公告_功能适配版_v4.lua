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

pcall(function()
    WindUI:AddTheme({
        Name="inkGray",
        Accent=Color3.fromRGB(105,105,105),
        Dialog=Color3.fromRGB(32,32,32),
        Outline=Color3.fromRGB(125,125,125),
        Text=Color3.fromRGB(235,235,235),
        Placeholder=Color3.fromRGB(145,145,145),
        Background=Color3.fromRGB(24,24,24),
        Button=Color3.fromRGB(58,58,58),
        Icon=Color3.fromRGB(190,190,190),
        Title=Color3.fromRGB(155,155,155),
        Author=Color3.fromRGB(145,145,145),
    })
end

local D = WindUI:CreateWindow({
    Title=gradient("ink_HUB",Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)),
    Author=gradient("@墨水依旧 司空",Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)),
    Icon="rbxassetid://71953031400395",
    Folder="ink_HUB",
    NewElements=true,
    HideSearchBar=false,
    Theme="inkGray",
})

pcall(function()
    D:Tag({Title="永久免费",Radius=5,Color=Color3.fromHex("#555555")})
    D:Tag({Title="2026",Radius=6,Color=Color3.fromHex("#B0B0B0")})
    D:EditOpenButton({
        Title="Project_ink_HUB_2026!",
        Icon="crown",
        StrokeThickness=5,
        TextColor=Color3.fromRGB(150,150,150),
        TitleColor=Color3.fromRGB(150,150,150),
        Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(90,90,90)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(150,150,150)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(70,70,70))
        }),
        Draggable=true
    })
end


pcall(function()
    local RunService = game:GetService("RunService")
    local targetWindow = D.UIElements and D.UIElements.Main
    if not targetWindow then return end
    local stroke = Instance.new("UIStroke")
    stroke.Name = "inkGrayMainBorder"
    stroke.Thickness = 7
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(145,145,145)
    stroke.Parent = targetWindow
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(65,65,65)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(65,65,65))
    })
    gradient.Parent = stroke
    task.spawn(function()
        local rotation=0
        while targetWindow.Parent and stroke.Parent and gradient.Parent do
            rotation=(rotation+1.5)%360
            gradient.Rotation=rotation
            RunService.RenderStepped:Wait()
        end
    end)
end)


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


local GeneralTab = D:Tab({Title="通用", Icon="settings"})
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
        if not ok then safeNotify("飞行", "加载失败: "..tostring(err), 3) end
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
        if not ok then safeNotify("第三人称", "设置失败", 2) end
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
            safeNotify("瞬间交互", "已开启", 2)
        else
            disableInstantProximity()
            safeNotify("瞬间交互", "已关闭", 2)
        end
    end
})

local P = D:Tab({Title="透视", Icon="eye"})

local espEnabled = false
local outlineEnabled = false
local tracersEnabled = false
local espconfig = {
    espcolor = Color3.fromRGB(255, 255, 255),
    outlinecolor = Color3.fromRGB(255, 255, 255),
    outlinefillcolor = Color3.fromRGB(255, 255, 255),
    tracercolor = Color3.fromRGB(255, 255, 255),
    espsize = 16,
    tracersize = 2,
    outlinetransparency = 0,
    outlinefilltransparency = 1,
    rainbowesp = false,
    rainbowoutline = false,
    rainbowtracers = false,
    rainbowspeed = 5,
    tracerposition = "Bottom",
    teamcheck = false,
    teamcolor = Color3.fromRGB(255, 0, 0)
}
local rainbowhue = 0
local lastupdate = 0
local espobjects = {}
local playerconnections = {}
local tracerlines = {}
local activehighlights = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function getrainbowcolor()
    local currenttime = tick()
    local speedmultiplier = 11 - espconfig.rainbowspeed
    local increment = 0.001 * speedmultiplier
    if currenttime - lastupdate >= 0.1 then
        rainbowhue = (rainbowhue + increment) % 1
        lastupdate = currenttime
    end
    return Color3.fromHSV(rainbowhue, 1, 1)
end

local function getESPColor(player, normalColor, rainbowEnabled)
    if espconfig.teamcheck and player and player:IsA("Player") and player ~= LocalPlayer then
        if player.Team ~= LocalPlayer.Team then
            return espconfig.teamcolor
        end
    end
    return rainbowEnabled and getrainbowcolor() or normalColor
end

local function getPlayerWeapon(player)
    if not player.Character then return "无" end
    local tool = player.Character:FindFirstChildWhichIsA("Tool")
    if tool then return tool.Name end
    return "无"
end

local function createesp(player)
    if player == LocalPlayer or espobjects[player] then return end
    local nametext = Drawing.new("Text")
    nametext.Size = espconfig.espsize
    nametext.Center = true
    nametext.Outline = true
    nametext.Color = espconfig.espcolor
    nametext.Font = 2
    nametext.Visible = false
    espobjects[player] = { Name = nametext }
end

local function removeesp(player)
    if espobjects[player] then
        espobjects[player].Name:Remove()
        espobjects[player] = nil
    end
end

local function applyhighlighttocharacter(player, character)
    if not character then return end
    local userid = player.UserId
    if activehighlights[userid] then
        activehighlights[userid]:Destroy()
        activehighlights[userid] = nil
    end
    local highlighter = Instance.new("Highlight")
    highlighter.FillTransparency = espconfig.outlinefilltransparency
    highlighter.OutlineTransparency = espconfig.outlinetransparency
    highlighter.OutlineColor = getESPColor(player, espconfig.outlinecolor, espconfig.rainbowoutline)
    highlighter.FillColor = getESPColor(player, espconfig.outlinefillcolor, espconfig.rainbowoutline)
    highlighter.Adornee = character
    highlighter.Parent = character
    activehighlights[userid] = highlighter
end

local function removehighlight(player)
    local userid = player.UserId
    if activehighlights[userid] then
        activehighlights[userid]:Destroy()
        activehighlights[userid] = nil
    end
    if playerconnections[userid] then
        for _, conn in pairs(playerconnections[userid]) do
            if conn then conn:Disconnect() end
        end
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
            if outlineEnabled then
                applyhighlighttocharacter(player, character)
            end
            table.insert(playerconnections[userid], player:GetPropertyChangedSignal("TeamColor"):Connect(function()
                local highlight = activehighlights[userid]
                if highlight then
                    highlight.OutlineColor = getESPColor(player, espconfig.outlinecolor, espconfig.rainbowoutline)
                    highlight.FillColor = getESPColor(player, espconfig.outlinefillcolor, espconfig.rainbowoutline)
                end
            end))
            table.insert(playerconnections[userid], humanoid.Died:Connect(function()
                removehighlight(player)
            end))
        end)
    end
    local charaddedconn = player.CharacterAdded:Connect(oncharacteradded)
    table.insert(playerconnections[userid], charaddedconn)
    if player.Character then oncharacteradded(player.Character) end
end

local function updateesp()
    for player, esp in pairs(espobjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
            local color = getESPColor(player, espconfig.espcolor, espconfig.rainbowesp)
            esp.Name.Color = color
            esp.Name.Size = espconfig.espsize
            if onscreen then
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                local weapon = getPlayerWeapon(player)
                esp.Name.Position = Vector2.new(pos.X, pos.Y - 20)
                esp.Name.Text = player.Name .. " | " .. math.floor(distance) .. " 米 | " .. weapon
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
        else
            esp.Name.Visible = false
        end
    end
    if outlineEnabled then
        for userid, h in pairs(activehighlights) do
            if h then
                local targetPlayer = Players:GetPlayerByUserId(userid)
                if targetPlayer then
                    h.OutlineColor = getESPColor(targetPlayer, espconfig.outlinecolor, espconfig.rainbowoutline)
                    h.FillColor = getESPColor(targetPlayer, espconfig.outlinefillcolor, espconfig.rainbowoutline)
                end
            end
        end
    end
end

local function createtracers()
    tracerlines = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local line = Drawing.new("Line")
            line.Thickness = espconfig.tracersize
            line.Transparency = 1
            line.Visible = false
            tracerlines[player] = line
        end
    end
end

local function updatetracers()
    local screenHeight = Camera.ViewportSize.Y
    local fromY
    if espconfig.tracerposition == "底部" then fromY = screenHeight
    elseif espconfig.tracerposition == "中间" then fromY = screenHeight / 2
    elseif espconfig.tracerposition == "顶部" then fromY = 0 end
    for player, line in pairs(tracerlines) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenpos, onscreen = Camera:WorldToViewportPoint(root.Position)
            local color = getESPColor(player, espconfig.tracercolor, espconfig.rainbowtracers)
            if onscreen then
                line.From = Vector2.new(Camera.ViewportSize.X / 2, fromY)
                line.To = Vector2.new(screenpos.X, screenpos.Y)
                line.Color = color
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        if espEnabled then createesp(p) end
        if outlineEnabled then
            playerconnections[p.UserId] = {}
            setupplayerhighlight(p)
        end
        if tracersEnabled then
            local line = Drawing.new("Line")
            line.Thickness = espconfig.tracersize
            line.Transparency = 1
            line.Visible = false
            tracerlines[p] = line
        end
        p.CharacterAdded:Connect(function(c)
            if espEnabled then
                task.wait(0.1)
                if not espobjects[p] then createesp(p) end
            end
            if outlineEnabled then
                task.wait(0.1)
                applyhighlighttocharacter(p, c)
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeesp(p)
    removehighlight(p)
    if tracerlines[p] then
        tracerlines[p]:Remove()
        tracerlines[p] = nil
    end
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function(c)
            if espEnabled then
                task.wait(0.1)
                if not espobjects[p] then createesp(p) end
            end
            if outlineEnabled then
                task.wait(0.1)
                applyhighlighttocharacter(p, c)
            end
        end)
    end
end

local espGroup = P:Section({ Title = "基础透视", Opened = true })
espGroup:Toggle({
    Title = "透视",
    Value = false,
    Callback = function(v)
        espEnabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then createesp(p) end
            end
            RunService:BindToRenderStep("ESPUpdate", Enum.RenderPriority.Camera.Value + 1, updateesp)
        else
            for p, _ in pairs(espobjects) do removeesp(p) end
            RunService:UnbindFromRenderStep("ESPUpdate")
        end
    end
})

local npcEspEnabled = false
local npcHighlights = {}
local npcAddedConn = nil
local npcRemovingConn = nil

local function isNPCModel(obj)
    if not obj or not obj:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
    return hum ~= nil and root ~= nil
end

local function addNPCESP(obj)
    if not npcEspEnabled or not isNPCModel(obj) or npcHighlights[obj] then return end
    local h = Instance.new("Highlight")
    h.Name = "ink_HUB_NPC_ESP"
    h.Adornee = obj
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = 0.75
    h.OutlineTransparency = 0
    h.FillColor = Color3.fromRGB(255, 170, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.Parent = obj
    npcHighlights[obj] = h
end

local function removeNPCESP(obj)
    local h = npcHighlights[obj]
    if h then
        pcall(function() h:Destroy() end)
        npcHighlights[obj] = nil
    end
end

local function clearNPCESP()
    for obj, h in pairs(npcHighlights) do
        if h then pcall(function() h:Destroy() end) end
        npcHighlights[obj] = nil
    end
end

local function setNPCESP(state)
    npcEspEnabled = state
    if npcAddedConn then npcAddedConn:Disconnect(); npcAddedConn = nil end
    if npcRemovingConn then npcRemovingConn:Disconnect(); npcRemovingConn = nil end

    clearNPCESP()
    if not state then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPCModel(obj) then
            addNPCESP(obj)
        end
    end

    npcAddedConn = workspace.DescendantAdded:Connect(function(obj)
        if not npcEspEnabled then return end
        task.defer(function()
            if obj and obj.Parent then
                if isNPCModel(obj) then
                    addNPCESP(obj)
                elseif obj:IsA("Humanoid") and obj.Parent and obj.Parent:IsA("Model") then
                    addNPCESP(obj.Parent)
                end
            end
        end)
    end)

    npcRemovingConn = workspace.DescendantRemoving:Connect(function(obj)
        if npcHighlights[obj] then
            npcHighlights[obj] = nil
        end
    end)
end

espGroup:Toggle({
    Title = "透视NPC",
    Value = false,
    Callback = function(v)
        setNPCESP(v)
    end
})

espGroup:Toggle({
    Title = "队伍检测",
    Value = false,
    Callback = function(v)
        espconfig.teamcheck = v
    end
})
espGroup:Colorpicker({
    Title = "敌对队伍颜色",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(v)
        espconfig.teamcolor = v
    end
})

espGroup:Colorpicker({
    Title = "透视颜色",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(v) espconfig.espcolor = v end
})
espGroup:Toggle({
    Title = "轮廓",
    Value = false,
    Callback = function(v)
        outlineEnabled = v
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    if not playerconnections[p.UserId] then
                        playerconnections[p.UserId] = {}
                    end
                    if p.Character then
                        applyhighlighttocharacter(p, p.Character)
                    end
                    setupplayerhighlight(p)
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                removehighlight(p)
            end
        end
    end
})
espGroup:Colorpicker({
    Title = "轮廓颜色",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(v)
        espconfig.outlinecolor = v
        if outlineEnabled and not espconfig.rainbowoutline then
            for _, h in pairs(activehighlights) do
                if h then
                    h.OutlineColor = v
                end
            end
        end
    end
})
espGroup:Colorpicker({
    Title = "填充颜色",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(v) espconfig.outlinefillcolor = v end
})
espGroup:Toggle({
    Title = "追踪线",
    Value = false,
    Callback = function(v)
        tracersEnabled = v
        if v then
            createtracers()
            RunService:BindToRenderStep("Tracers", Enum.RenderPriority.Camera.Value + 1, updatetracers)
        else
            RunService:UnbindFromRenderStep("Tracers")
            for _, line in pairs(tracerlines) do line:Remove() end
            tracerlines = {}
        end
    end
})
espGroup:Colorpicker({
    Title = "追踪线颜色",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(v) espconfig.tracercolor = v end
})

local configGroup = P:Section({ Title = "高级配置", Opened = false })
configGroup:Toggle({
    Title = "彩虹透视",
    Value = false,
    Callback = function(v) espconfig.rainbowesp = v end
})
configGroup:Toggle({
    Title = "彩虹轮廓",
    Value = false,
    Callback = function(v) espconfig.rainbowoutline = v end
})
configGroup:Toggle({
    Title = "彩虹追踪线",
    Value = false,
    Callback = function(v) espconfig.rainbowtracers = v end
})
configGroup:Slider({
    Title = "透视大小",
    Value = { Min = 16, Max = 48, Default = 16 },
    Step = 1,
    Callback = function(v) espconfig.espsize = v end
})
configGroup:Dropdown({
    Title = "追踪线位置",
    Values = { "底部", "中间", "顶部" },
    Value = "底部",
    Callback = function(v) espconfig.tracerposition = v end
})
configGroup:Slider({
    Title = "轮廓透明度",
    Value = { Min = 0, Max = 100, Default = 0 },
    Step = 1,
    Callback = function(v) espconfig.outlinetransparency = v / 100 end
})
configGroup:Slider({
    Title = "轮廓填充透明度",
    Value = { Min = 0, Max = 100, Default = 50 },
    Step = 1,
    Callback = function(v) espconfig.outlinefilltransparency = v / 100 end
})
configGroup:Slider({
    Title = "彩虹速度",
    Value = { Min = 1, Max = 10, Default = 5 },
    Step = 1,
    Callback = function(v) espconfig.rainbowspeed = v end
})

local OtherTab = D:Tab({Title="其他功能", Icon="star"})

OtherTab:Button({
    Title = "打开电梯",
    Callback = function()
        local rs = game:GetService("ReplicatedStorage")
        local remote = rs:FindFirstChild("OpenElevator")
        if remote and remote:IsA("RemoteEvent") then
            local ok, err = pcall(function() remote:FireServer() end)
            if ok then
                safeNotify("打开电梯", "已执行", 2)
            else
                safeNotify("打开电梯", "执行失败: "..tostring(err), 3)
            end
        else
            safeNotify("打开电梯", "未找到 OpenElevator", 2)
        end
    end
})

local godModeConnection
OtherTab:Toggle({
    Title = "无敌模式",
    Value = false,
    Callback = function(v)
        if godModeConnection then
            godModeConnection:Disconnect()
            godModeConnection = nil
        end
        if not v then
            safeNotify("无敌模式", "已关闭", 2)
            return
        end
        local player = game:GetService("Players").LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local healthValue = char:FindFirstChild("HealthValue")
        if not healthValue then
            safeNotify("无敌模式", "未找到 HealthValue，当前游戏可能不支持", 3)
            return
        end
        godModeConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not healthValue or not healthValue.Parent then
                local c = player.Character
                healthValue = c and c:FindFirstChild("HealthValue")
                return
            end
            if healthValue.Value < 100 then
                local events = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                local vestEvent = events and events:FindFirstChild("VestEvent")
                if vestEvent and vestEvent:IsA("RemoteEvent") then
                    pcall(function() vestEvent:FireServer(player) end)
                end
            end
        end)
        safeNotify("无敌模式", "已开启", 2)
    end
})

OtherTab:Button({
    Title = "立即失败本回合",
    Callback = function()
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("AddDeath")
        if remote and remote:IsA("RemoteEvent") then
            local ok, err = pcall(function() remote:FireServer() end)
            if ok then safeNotify("回合", "已执行失败回合", 2)
            else safeNotify("回合", "执行失败: "..tostring(err), 3) end
        else
            safeNotify("回合", "未找到 AddDeath", 2)
        end
    end
})

OtherTab:Toggle({
    Title = "无限金钱",
    Value = false,
    Callback = function(v)
        local player = game:GetService("Players").LocalPlayer
        local leaderstats = player:FindFirstChild("leaderstats")
        local money = leaderstats and leaderstats:FindFirstChild("Money")
        if not money then
            safeNotify("无限金钱", "未找到 Money", 3)
            return
        end
        if v then
            if _G.inkInfiniteMoneyConnection then
                _G.inkInfiniteMoneyConnection:Disconnect()
            end
            _G.inkInfiniteMoneyConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if money and money.Parent then money.Value = 999999999 end
                local values = game:GetService("ReplicatedStorage"):FindFirstChild("PlayerValues")
                local m2 = values and values:FindFirstChild("Money")
                if m2 then m2.Value = 999999999 end
            end)
            safeNotify("无限金钱", "已开启", 2)
        else
            if _G.inkInfiniteMoneyConnection then
                _G.inkInfiniteMoneyConnection:Disconnect()
                _G.inkInfiniteMoneyConnection = nil
            end
            safeNotify("无限金钱", "已关闭", 2)
        end
    end
})

local lagMethod = "尸体刷屏"
local lagEnabled = false
OtherTab:Dropdown({
    Title = "刷屏方式",
    Values = {"尸体刷屏"},
    Value = "尸体刷屏",
    Callback = function(v) lagMethod = v end
})
OtherTab:Toggle({
    Title = "开始刷屏",
    Value = false,
    Callback = function(v)
        lagEnabled = v
        if not v then
            safeNotify("刷屏", "已关闭", 2)
            return
        end
        task.spawn(function()
            while lagEnabled do
                local char = game:GetService("Players").LocalPlayer.Character
                local deathEvent = char and char:FindFirstChild("DeathEvent")
                if deathEvent then pcall(function() deathEvent:FireServer() end) end
                task.wait()
            end
        end)
        safeNotify("刷屏", "尸体刷屏已开启", 2)
    end
})

OtherTab:Button({
    Title = "清理尸体",
    Callback = function()
        local npcs = workspace:FindFirstChild("NPCS")
        if npcs then
            for _, obj in ipairs(npcs:GetChildren()) do
                if obj:IsA("Model") and obj.Name == "Ragdoll" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        local char = game:GetService("Players").LocalPlayer.Character
        if char then pcall(function() char:BreakJoints() end) end
        safeNotify("清理尸体", "已执行", 2)
    end
})

OtherTab:Button({
    Title = "解锁三级表情",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then safeNotify("三级表情", "未找到 PlayerGui", 2); return end
        local gui = playerGui:FindFirstChild("Emoteui") or playerGui:FindFirstChild("EmoteGui")
        if not gui then safeNotify("三级表情", "未找到表情界面", 2); return end
        local buttonThree = gui:FindFirstChild("ButtonThree")
        local container1 = gui:FindFirstChild("container1")
        local container2 = gui:FindFirstChild("container2")
        local container3 = gui:FindFirstChild("container3")
        if not buttonThree or not container1 or not container2 or not container3 then
            safeNotify("三级表情", "表情界面结构不完整", 2)
            return
        end
        local function removeLock(obj)
            local lock = obj:FindFirstChild("Lock")
            if lock then pcall(function() lock:Destroy() end) end
            obj.ChildAdded:Connect(function(child)
                if child.Name == "Lock" then pcall(function() child:Destroy() end) end
            end)
        end
        removeLock(buttonThree)
        buttonThree.MouseButton1Click:Connect(function()
            container1.Visible = false
            container2.Visible = false
            container3.Visible = true
        end)
        safeNotify("三级表情", "已解锁", 2)
    end
})

