-- ink_HUB | 启动动画 + 仅透视分区
-- 启动动画会先完整播放；之后才尝试加载 WindUI。

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function playStartupAnimation()
    local gui
    local ok, err = pcall(function()
        local old = CoreGui:FindFirstChild("ink_HUB_StartupAnimation")
        if old then old:Destroy() end

        gui = Instance.new("ScreenGui")
        gui.Name = "ink_HUB_StartupAnimation"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 2147483647
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.Parent = CoreGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        bg.BorderSizePixel = 0
        bg.Parent = gui

        local image = Instance.new("ImageLabel")
        image.Name = "Logo"
        image.AnchorPoint = Vector2.new(0.5, 0.5)
        image.Position = UDim2.new(0.5, 0, 1, 180)
        image.Size = UDim2.fromOffset(210, 210)
        image.BackgroundTransparency = 1
        image.Image = "rbxassetid://97528294523613"
        image.ScaleType = Enum.ScaleType.Fit
        image.Active = false
        image.Selectable = false
        image.Parent = bg

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.AnchorPoint = Vector2.new(0, 0.5)
        title.Position = UDim2.new(0, -460, 0.5, 135)
        title.Size = UDim2.fromOffset(440, 64)
        title.BackgroundTransparency = 1
        title.Text = "破坏者谜团2"
        title.TextColor3 = Color3.fromRGB(255, 25, 25)
        title.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
        title.TextStrokeTransparency = 0.3
        title.TextSize = 38
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Center
        title.Active = false
        title.Selectable = false
        title.Parent = bg

        TweenService:Create(image, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, 0.43)
        }):Play()
        task.wait(1.45)

        local moveImage = TweenService:Create(image, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Position = UDim2.fromScale(0.23, 0.43)
        })
        local moveTitle = TweenService:Create(title, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.42, 0, 0.5, 135)
        })
        moveImage:Play()
        moveTitle:Play()
        moveImage.Completed:Wait()
        task.wait(0.45)

        -- 动画结束后淡出并清理；后续 UI 才开始加载。
        local fadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(bg, fadeInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(image, fadeInfo, {ImageTransparency = 1}):Play()
        TweenService:Create(title, fadeInfo, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
        task.wait(0.4)
    end)
    if gui then pcall(function() gui:Destroy() end) end
    if not ok then warn("[ink_HUB] 启动动画异常：", tostring(err)) end
end

-- 无论后续 UI 成功与否，动画都先完整播放。
playStartupAnimation()

local function loadWindUI()
    local source = game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua", true)
    assert(type(source) == "string" and #source > 100, "WindUI 下载内容为空")
    local loader = loadstring(source)
    assert(type(loader) == "function", "WindUI loadstring 失败")
    return loader()
end

local okWind, WindUI = pcall(loadWindUI)
if not okWind or not WindUI then
    warn("[ink_HUB] UI 加载失败（启动动画已完成）：", tostring(WindUI))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "UI加载失败",
            Text = "启动动画已完成，请检查网络或执行器报错。",
            Duration = 5
        })
    end)
    return
end

pcall(function()
    WindUI:AddTheme({
        Name = "inkGray",
        Accent = Color3.fromRGB(105, 105, 105),
        Dialog = Color3.fromRGB(32, 32, 32),
        Outline = Color3.fromRGB(125, 125, 125),
        Text = Color3.fromRGB(235, 235, 235),
        Placeholder = Color3.fromRGB(145, 145, 145),
        Background = Color3.fromRGB(24, 24, 24),
        Button = Color3.fromRGB(58, 58, 58),
        Icon = Color3.fromRGB(190, 190, 190),
        Title = Color3.fromRGB(155, 155, 155),
        Author = Color3.fromRGB(145, 145, 145),
    })
end)

local window
local okWindow, windowResult = pcall(function()
    return WindUI:CreateWindow({
        Title = "ink_HUB",
        Author = "@Theinkremains",
        Icon = "rbxassetid://71953031400395",
        Folder = "ink_HUB",
        NewElements = true,
        HideSearchBar = false,
        Theme = "inkGray",
    })
end)
if not okWindow or not windowResult then
    warn("[ink_HUB] UI 创建失败（启动动画已完成）：", tostring(windowResult))
    return
end
window = windowResult
pcall(function()
    window:EditOpenButton({
        Title = "ink_HUB",
        Icon = "crown",
        StrokeThickness = 5,
        TextColor = Color3.fromRGB(150, 150, 150),
        TitleColor = Color3.fromRGB(150, 150, 150),
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 90)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 150, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70))
        }),
        Draggable = true
    })
end)

-- 只创建“透视”分区；普通玩家、警长、杀手分别拥有透视文字、轮廓、追踪线三个独立开关。
local P = window:Tab({Title = "透视", Icon = "eye"})
local categorySettings = {
    Normal = {
        title = "普通玩家",
        color = Color3.fromRGB(255, 255, 255),
        esp = false, outline = false, tracer = false,
        espColor = Color3.fromRGB(255, 255, 255),
        outlineColor = Color3.fromRGB(255, 255, 255),
        tracerColor = Color3.fromRGB(255, 255, 255),
    },
    Sheriff = {
        title = "透视警长",
        color = Color3.fromRGB(0, 120, 255),
        esp = false, outline = false, tracer = false,
        espColor = Color3.fromRGB(0, 120, 255),
        outlineColor = Color3.fromRGB(0, 120, 255),
        tracerColor = Color3.fromRGB(0, 120, 255),
    },
    Killer = {
        title = "透视杀手",
        color = Color3.fromRGB(255, 0, 0),
        esp = false, outline = false, tracer = false,
        espColor = Color3.fromRGB(255, 0, 0),
        outlineColor = Color3.fromRGB(255, 0, 0),
        tracerColor = Color3.fromRGB(255, 0, 0),
    },
}

local drawTexts = {}
local drawLines = {}
local highlights = {}
local renderBound = false
local categoryNames = {"Normal", "Sheriff", "Killer"}

local function hasNamedTool(player, wantedName)
    local backpack = player:FindFirstChildOfClass("Backpack") or player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild(wantedName) then return true end
    local character = player.Character
    if character and character:FindFirstChild(wantedName) then return true end
    return false
end

local function getCategory(player)
    local hasKnife = hasNamedTool(player, "Knife")
    local hasGun = hasNamedTool(player, "Gun")
    if hasKnife and hasGun then return nil end
    if hasKnife then return "Killer" end
    if hasGun then return "Sheriff" end
    return "Normal"
end

local function removePlayerVisuals(player)
    local textObject = drawTexts[player]
    if textObject then pcall(function() textObject:Remove() end); drawTexts[player] = nil end
    local lineObject = drawLines[player]
    if lineObject then pcall(function() lineObject:Remove() end); drawLines[player] = nil end
    local high = highlights[player]
    if high then pcall(function() high:Destroy() end); highlights[player] = nil end
end

local function ensureText(player)
    if drawTexts[player] or not Drawing then return end
    local ok, obj = pcall(function() return Drawing.new("Text") end)
    if not ok or not obj then return end
    obj.Size = 16
    obj.Center = true
    obj.Outline = true
    obj.Font = 2
    obj.Visible = false
    drawTexts[player] = obj
end

local function ensureLine(player)
    if drawLines[player] or not Drawing then return end
    local ok, obj = pcall(function() return Drawing.new("Line") end)
    if not ok or not obj then return end
    obj.Thickness = 2
    obj.Transparency = 1
    obj.Visible = false
    drawLines[player] = obj
end

local function ensureHighlight(player)
    if highlights[player] or not player.Character then return end
    local ok, high = pcall(function()
        local h = Instance.new("Highlight")
        h.Name = "ink_HUB_PlayerOutline"
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.FillTransparency = 1
        h.OutlineTransparency = 0
        h.Adornee = player.Character
        h.Parent = player.Character
        return h
    end)
    if ok and high then highlights[player] = high end
end

local function updateVisuals()
    local camera = workspace.CurrentCamera
    if not camera then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local category = getCategory(player)
            local settings = category and categorySettings[category] or nil
            local character = player.Character
            local root = character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head"))
            local valid = settings ~= nil and character ~= nil and root ~= nil
            local pos, onScreen
            if valid then pos, onScreen = camera:WorldToViewportPoint(root.Position) end
            local showOnScreen = valid and onScreen and pos.Z > 0

            local textObj = drawTexts[player]
            if textObj then
                if showOnScreen and settings.esp then
                    local distance = math.floor((camera.CFrame.Position - root.Position).Magnitude)
                    textObj.Color = settings.espColor
                    textObj.Position = Vector2.new(pos.X, pos.Y - 20)
                    textObj.Text = player.Name .. " | " .. distance .. " 米"
                    textObj.Visible = true
                else
                    textObj.Visible = false
                end
            end

            local lineObj = drawLines[player]
            if lineObj then
                if showOnScreen and settings.tracer then
                    lineObj.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    lineObj.To = Vector2.new(pos.X, pos.Y)
                    lineObj.Color = settings.tracerColor
                    lineObj.Visible = true
                else
                    lineObj.Visible = false
                end
            end

            local high = highlights[player]
            if settings and settings.outline and character then
                if not high or high.Parent ~= character then
                    if high then pcall(function() high:Destroy() end) end
                    highlights[player] = nil
                    ensureHighlight(player)
                    high = highlights[player]
                end
                if high then
                    high.Adornee = character
                    high.OutlineColor = settings.outlineColor
                    high.FillColor = settings.outlineColor
                    high.Enabled = true
                end
            elseif high then
                high.Enabled = false
            end

            -- 类别切换时立即隐藏旧类别的视觉，避免残留颜色/轮廓。
            if not settings then
                if textObj then textObj.Visible = false end
                if lineObj then lineObj.Visible = false end
                if high then high.Enabled = false end
            end
        end
    end
end

local function refreshRenderBinding()
    local anyEnabled = false
    for _, key in ipairs(categoryNames) do
        local s = categorySettings[key]
        if s.esp or s.outline or s.tracer then anyEnabled = true end
    end
    if anyEnabled and not renderBound then
        RunService:BindToRenderStep("ink_HUB_ThreeCategoryESP", Enum.RenderPriority.Camera.Value + 1, updateVisuals)
        renderBound = true
    elseif not anyEnabled and renderBound then
        RunService:UnbindFromRenderStep("ink_HUB_ThreeCategoryESP")
        renderBound = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if drawTexts[player] then drawTexts[player].Visible = false end
                if drawLines[player] then drawLines[player].Visible = false end
                if highlights[player] then highlights[player].Enabled = false end
            end
        end
    end
end

local function setOption(category, option, value)
    local s = categorySettings[category]
    s[option] = value
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and getCategory(player) == category then
            if option == "esp" and value then ensureText(player) end
            if option == "tracer" and value then ensureLine(player) end
            if option == "outline" and value then ensureHighlight(player) end
        end
    end
    refreshRenderBinding()
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.2)
        if categorySettings.Normal.esp or categorySettings.Sheriff.esp or categorySettings.Killer.esp then ensureText(player) end
        if categorySettings.Normal.tracer or categorySettings.Sheriff.tracer or categorySettings.Killer.tracer then ensureLine(player) end
        if categorySettings.Normal.outline or categorySettings.Sheriff.outline or categorySettings.Killer.outline then ensureHighlight(player) end
    end)
end)
Players.PlayerRemoving:Connect(removePlayerVisuals)

local function addCategoryControls(key)
    local s = categorySettings[key]
    local group = P:Section({Title = s.title, Opened = true})
    local prefix = key == "Normal" and "普通" or (key == "Sheriff" and "警长" or "杀手")
    group:Toggle({Title = prefix .. "透视", Value = false, Callback = function(v) setOption(key, "esp", v) end})
    group:Colorpicker({Title = prefix .. "透视颜色", Default = s.espColor, Callback = function(v) s.espColor = v end})
    group:Toggle({Title = prefix .. "轮廓", Value = false, Callback = function(v) setOption(key, "outline", v) end})
    group:Colorpicker({Title = prefix .. "轮廓颜色", Default = s.outlineColor, Callback = function(v) s.outlineColor = v end})
    group:Toggle({Title = prefix .. "追踪线", Value = false, Callback = function(v) setOption(key, "tracer", v) end})
    group:Colorpicker({Title = prefix .. "追踪线颜色", Default = s.tracerColor, Callback = function(v) s.tracerColor = v end})
end

addCategoryControls("Normal")
addCategoryControls("Sheriff")
addCategoryControls("Killer")

print("[ink_HUB] 仅透视分区已加载")
