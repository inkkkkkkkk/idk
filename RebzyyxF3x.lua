local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

local function c(cl, p, par)
    local o = Instance.new(cl)
    for k, v in pairs(p) do o[k] = v end
    if par then o.Parent = par end
    return o
end

local BG = Color3.fromRGB(10, 10, 12)
local PNL = Color3.fromRGB(16, 16, 18)
local BTN = Color3.fromRGB(30, 30, 35)
local BTN_HOVER = Color3.fromRGB(45, 45, 50)
local BTN_DOWN = Color3.fromRGB(20, 20, 25)
local RED = Color3.fromRGB(200, 10, 30)
local WHT = Color3.fromRGB(255, 255, 255)
local TXT = Color3.fromRGB(255, 255, 255)
local DIM = Color3.fromRGB(150, 150, 150)

local BootGui = c("ScreenGui", {Parent = pgui, IgnoreGuiInset = true, DisplayOrder = 999}, nil)
local MainBG = c("Frame", {BackgroundColor3 = Color3.fromRGB(3, 3, 3), Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0}, BootGui)
local Center = c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 200), Position = UDim2.new(0.5, 0, 0.5, -20), AnchorPoint = Vector2.new(0.5, 0.5)}, MainBG)

local Spikes = {}
for i = 1, 4 do
    table.insert(Spikes, c("Frame", {BackgroundColor3 = RED, Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Rotation = 45 + (i-1) * 90, BackgroundTransparency = 1}, Center))
end
local Core = c("Frame", {BackgroundColor3 = WHT, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1}, Center)
c("UICorner", {CornerRadius = UDim.new(1,0)}, Core)

local TxtBox = c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 80), Position = UDim2.new(0, 0, 0.5, 110), AnchorPoint = Vector2.new(0, 0.5)}, Center)
local T1 = c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Font = Enum.Font.GothamBlack, Text = "", TextColor3 = WHT, TextSize = 28}, TxtBox)
local T2 = c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Font = Enum.Font.GothamBlack, Text = "", TextColor3 = RED, TextSize = 28, TextTransparency = 1}, TxtBox)
local T3 = c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 45), Font = Enum.Font.Code, Text = "BY.Rebzyyx/Rezlaine", TextColor3 = RED, TextSize = 13, TextTransparency = 1}, TxtBox)

local MainGui = c("ScreenGui", {Parent = pgui}, nil)
local Main = c("Frame", {BackgroundColor3 = BG, Position = UDim2.new(0.5, 0, 1.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 500, 0, 360), ClipsDescendants = true, BorderSizePixel = 0}, MainGui)
c("UICorner", {CornerRadius = UDim.new(0, 10)}, Main)
c("UIStroke", {Color = RED, Thickness = 2, Transparency = 0.1}, Main)

local UIScale = c("UIScale", {Scale = 1}, Main)

local Top = c("Frame", {BackgroundColor3 = PNL, Size = UDim2.new(1, 0, 0, 45), BorderSizePixel = 0}, Main)
c("UICorner", {CornerRadius = UDim.new(0, 10)}, Top)
c("Frame", {BackgroundColor3 = PNL, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 25), BorderSizePixel = 0}, Top)
c("Frame", {BackgroundColor3 = RED, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BorderSizePixel = 0}, Top)

c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 15, 0, 0), Font = Enum.Font.GothamBlack, Text = "REBZYYX", TextColor3 = TXT, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left}, Top)
c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 140, 0, 0), Font = Enum.Font.GothamBold, Text = "F3Xgui V67", TextColor3 = RED, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, Top)

local Close = c("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 35, 1, 0), Position = UDim2.new(1, -35, 0, 0), Text = "×", TextColor3 = TXT, TextSize = 24, Font = Enum.Font.GothamBold, AutoButtonColor = false, BorderSizePixel = 0}, Top)
Close.MouseEnter:Connect(function() Close.TextColor3 = RED end)
Close.MouseLeave:Connect(function() Close.TextColor3 = TXT end)

local Min = c("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 35, 1, 0), Position = UDim2.new(1, -70, 0, 0), Text = "—", TextColor3 = TXT, TextSize = 16, Font = Enum.Font.GothamBold, AutoButtonColor = false, BorderSizePixel = 0}, Top)
Min.MouseEnter:Connect(function() Min.TextColor3 = RED end)
Min.MouseLeave:Connect(function() Min.TextColor3 = TXT end)

local Side = c("Frame", {BackgroundColor3 = PNL, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(0, 120, 1, -45), BorderSizePixel = 0}, Main)
c("UICorner", {CornerRadius = UDim.new(0, 10)}, Side)
c("Frame", {BackgroundColor3 = BG, Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0}, Side)

local Cont = c("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 130, 0, 60), Size = UDim2.new(0, 350, 0, 290), BorderSizePixel = 0}, Main)

local P = {
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = true, BorderSizePixel = 0}, Cont),
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, BorderSizePixel = 0}, Cont),
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, BorderSizePixel = 0}, Cont),
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, BorderSizePixel = 0}, Cont)
}

local Ind = c("Frame", {BackgroundColor3 = RED, Position = UDim2.new(0, 5, 0, 29), Size = UDim2.new(0, 3, 0, 22), BorderSizePixel = 0}, Side)
c("UICorner", {CornerRadius = UDim.new(1, 0)}, Ind)
local NB = {}
local function mNB(t, y)
    local b = c("TextButton", {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, y), Size = UDim2.new(0, 100, 0, 40), Font = Enum.Font.GothamBold, Text = t, TextColor3 = DIM, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0}, Side)
    b.MouseEnter:Connect(function() if b.TextColor3 == DIM then b.TextColor3 = WHT end end)
    b.MouseLeave:Connect(function() if b.TextColor3 == WHT then b.TextColor3 = DIM end end)
    table.insert(NB, b)
    return b
end

local NH, N1, N2, N3 = mNB("家", 20), mNB("基础", 70), mNB("音乐", 120), mNB("其它", 170)
local function setP(i)
    for j, p in ipairs(P) do p.Visible = (j == i) end
    TweenService:Create(Ind, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 5, 0, 29 + (i - 1) * 50)}):Play()
    for j, b in ipairs(NB) do b.TextColor3 = (j == i) and TXT or DIM end
end

NH.MouseButton1Down:Connect(function() setP(1) end)
N1.MouseButton1Down:Connect(function() setP(2) end)
N2.MouseButton1Down:Connect(function() setP(3) end)
N3.MouseButton1Down:Connect(function() setP(4) end)
setP(1)

local function mBtn(par, t, pos)
    local b = c("TextButton", {BackgroundColor3 = BTN, BorderSizePixel = 0, Position = pos, Size = UDim2.new(0, 105, 0, 38), Font = Enum.Font.GothamMedium, Text = t, TextColor3 = TXT, TextSize = 13, AutoButtonColor = false}, par)
    c("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = BTN_HOVER}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = BTN}):Play() end)
    b.MouseButton1Down:Connect(function() TweenService:Create(b, TweenInfo.new(0.05), {BackgroundColor3 = BTN_DOWN}):Play() end)
    b.MouseButton1Up:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = BTN_HOVER}):Play() end)
end

local function pop(par, list)
    for i, n in ipairs(list) do mBtn(par, n, UDim2.new(0, ((i - 1) % 3) * 115, 0, math.floor((i - 1) / 3) * 48)) end
end

c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 60), Font = Enum.Font.GothamBlack, Text = "BLACK ROSE", TextColor3 = TXT, TextSize = 36, BorderSizePixel = 0}, P[1])
c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 130), Font = Enum.Font.Code, Text = "BY.Rebzyyx/Rezlaine", TextColor3 = RED, TextSize = 14, BorderSizePixel = 0}, P[1])
c("Frame", {BackgroundColor3 = RED, Size = UDim2.new(0, 50, 0, 2), Position = UDim2.new(0.5, -25, 0, 170), BorderSizePixel = 0}, P[1])

pop(P[2], {"火焰", "烟雾", "光照", "闪光", "固定", "解固", "开碰撞", "关碰撞", "隐藏", "显示", "贴图", "底座"})
pop(P[3], {"18 Hardstyle", "Epic Sax", "Nyan Cat", "Syria Song", "Trollface", "John Cena", "Wonga", "Horror", "Sp00k"})
pop(P[4], {"天空", "地图", "清图", "着火", "隐形", "发光", "Disco", "悬浮", "脚本"})

local ResizeZone = c("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 1, -30), Text = "", BorderSizePixel = 0, ZIndex = 5}, Main)
local isMin, normalSize, minSize = false, UDim2.new(0, 500, 0, 360), UDim2.new(0, 500, 0, 45)

Min.MouseButton1Down:Connect(function()
    isMin = not isMin
    if isMin then
        Side.Visible, Cont.Visible = false, false
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = minSize}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = normalSize}):Play()
        task.delay(0.3, function() Side.Visible, Cont.Visible = true, true end)
    end
end)

local drag, dragStart, startPos, rDrag, rStart, rScaleStart = false, nil, nil, false, nil, nil
Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag, dragStart, startPos = true, input.Position, Main.Position end
end)
ResizeZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        rDrag, rStart, rScaleStart = true, input.Position, UIScale.Scale 
    end
end)

UIS.InputChanged:Connect(function(input)
    if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X / UIScale.Scale, startPos.Y.Scale, startPos.Y.Offset + d.Y / UIScale.Scale)
    end
    if rDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        UIScale.Scale = math.clamp(rScaleStart + ((input.Position.X - rStart.X) / 300), 0.5, 1.5)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        drag, rDrag = false, false 
    end
end)

Close.MouseButton1Down:Connect(function()
    local absPos, absSize = Main.AbsolutePosition, Main.AbsoluteSize
    Main.Visible = false
    local pieces = {}
    for i = 1, 40 do
        local p = c("Frame", {BackgroundColor3 = (i % 2 == 0) and RED or BTN, Position = UDim2.new(0, absPos.X + math.random(0, absSize.X), 0, absPos.Y + math.random(0, absSize.Y)), Size = UDim2.new(0, math.random(5, 20), 0, math.random(5, 20)), BorderSizePixel = 0, ZIndex = 10}, MainGui)
        table.insert(pieces, {Frame = p, VelX = math.random(-400, 400), VelY = math.random(-500, 100), RotVel = math.random(-15, 15)})
    end
    local startTime, conn = tick(), nil
    conn = RunService.RenderStepped:Connect(function(dt)
        local elapsed = tick() - startTime
        for _, data in pairs(pieces) do
            if data.Frame and data.Frame.Parent then
                data.VelY = data.VelY + 1200 * dt
                data.Frame.Position = UDim2.new(0, data.Frame.Position.X.Offset + data.VelX * dt, 0, data.Frame.Position.Y.Offset + data.VelY * dt)
                data.Frame.Rotation = data.Frame.Rotation + data.RotVel * dt * 5
                data.Frame.BackgroundTransparency = math.clamp((elapsed - 0.5) / 1, 0, 1)
            end
        end
        if elapsed > 1.5 then conn:Disconnect(); MainGui:Destroy() end
    end)
end)

task.spawn(function()
    task.wait(0.2)
    for i, s in ipairs(Spikes) do
        task.delay(i * 0.04, function()
            TweenService:Create(s, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, 2, 0, 180), BackgroundTransparency = 0}):Play()
        end)
    end
    TweenService:Create(Core, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 15, 0, 15), BackgroundTransparency = 0}):Play()
    task.wait(0.5)
    
    local str = "REBZYYX"
    local ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    local el = 0
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        el = el + dt
        local prog = math.floor((el / 0.8) * #str)
        local cur = string.sub(str, 1, prog)
        for i = prog + 1, #str do cur = cur .. string.sub(ch, math.random(1, #ch), math.random(1, #ch)) end
        T1.Text, T2.Text = cur, cur
        if el >= 0.8 then conn:Disconnect(); T1.Text, T2.Text = str, str end
    end)
    
    TweenService:Create(T3, TweenInfo.new(0.5), {TextTransparency = 0.2}):Play()
    task.wait(1.2)
    
    for _, s in ipairs(Spikes) do
        TweenService:Create(s, TweenInfo.new(0.2), {Size = UDim2.new(0, 2, 0, 0), BackgroundTransparency = 1}):Play()
    end
    TweenService:Create(Core, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    TweenService:Create(T1, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 40}):Play()
    TweenService:Create(T2, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 40}):Play()
    TweenService:Create(T3, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
    
    local F = c("Frame", {BackgroundColor3 = RED, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BorderSizePixel = 0}, MainBG)
    TweenService:Create(F, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 2000), BackgroundTransparency = 1}):Play()
    TweenService:Create(MainBG, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.3)
    TweenService:Create(Main, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    task.wait(0.8)
    BootGui:Destroy()
end)