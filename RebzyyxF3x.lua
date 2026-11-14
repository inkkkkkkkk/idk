local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ResetOnSpawn = false

local function c(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local C_BG = Color3.fromRGB(4, 4, 4)
local C_RED = Color3.fromRGB(200, 10, 30)
local C_WHITE = Color3.fromRGB(240, 240, 240)

local MainBG = c("Frame", {BackgroundColor3 = C_BG, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0)}, gui)
local Center = c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.5, 0, 0.5, -20), AnchorPoint = Vector2.new(0.5, 0.5)}, MainBG)

local Petals = {}
for i = 1, 6 do
    local p = c("Frame", {
        BackgroundColor3 = Color3.fromRGB(15, 15, 15), 
        BorderSizePixel = 0, 
        Size = UDim2.new(0, 70, 0, 100), 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        AnchorPoint = Vector2.new(0.5, 0.8), 
        Rotation = i * 60, 
        BackgroundTransparency = 1
    }, Center)
    c("UICorner", {CornerRadius = UDim.new(0.5, 0)}, p)
    c("UIStroke", {Color = C_RED, Thickness = 1.5, Transparency = 1}, p)
    table.insert(Petals, p)
end

local Core = c("Frame", {BackgroundColor3 = C_RED, BorderSizePixel = 0, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1}, Center)
c("UICorner", {CornerRadius = UDim.new(1, 0)}, Core)

local Title = c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0.5, 150), AnchorPoint = Vector2.new(0, 0.5), Font = Enum.Font.GothamBlack, Text = "REBZYYX", TextColor3 = C_WHITE, TextSize = 28, TextTransparency = 1}, Center)
local SubTitle = c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.5, 185), AnchorPoint = Vector2.new(0, 0.5), Font = Enum.Font.Code, Text = "BY.Rebzyyx/Rezlaine", TextColor3 = C_RED, TextSize = 13, TextTransparency = 1}, Center)

task.spawn(function()
    task.wait(0.2)
    
    for i, p in ipairs(Petals) do
        task.delay(i * 0.05, function()
            TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
            TweenService:Create(p:FindFirstChildOfClass("UIStroke"), TweenInfo.new(1), {Transparency = 0.2}):Play()
        end)
    end
    
    TweenService:Create(Core, TweenInfo.new(1), {Size = UDim2.new(0, 12, 0, 12), BackgroundTransparency = 0.2}):Play()
    
    local rot = RunService.RenderStepped:Connect(function()
        Center.Rotation = Center.Rotation + 0.3
    end)
    
    task.wait(1.2)
    
    TweenService:Create(Title, TweenInfo.new(1), {TextTransparency = 0}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(1), {TextTransparency = 0}):Play()
    
    task.wait(1.5)
    
    rot:Disconnect()
    TweenService:Create(MainBG, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.4), {TextTransparency = 1, TextSize = 40}):Play()
    TweenService:Create(SubTitle, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    
    for i, p in ipairs(Petals) do
        local ang = math.rad(p.Rotation)
        TweenService:Create(p, TweenInfo.new(0.8, Enum.EasingStyle.Exponential), {
            Position = UDim2.new(0.5, math.cos(ang)*250, 0.5, math.sin(ang)*250),
            BackgroundTransparency = 1, 
            Size = UDim2.new(0,0,0,0)
        }):Play()
        TweenService:Create(p:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.8), {Transparency = 1}):Play()
    end
    
    TweenService:Create(Core, TweenInfo.new(0.6), {Size = UDim2.new(0, 400, 0, 400), BackgroundTransparency = 1}):Play()
    
    task.wait(0.8)
    gui:Destroy()
end)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

local function c(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

local C_BG = Color3.fromRGB(8, 8, 8)
local C_PANEL = Color3.fromRGB(12, 12, 12)
local C_BTN = Color3.fromRGB(20, 20, 20)
local C_RED = Color3.fromRGB(200, 10, 30)
local C_TXT = Color3.fromRGB(240, 240, 240)
local C_TXT_DIM = Color3.fromRGB(120, 120, 120)

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local Main = c("Frame", {BackgroundColor3 = C_BG, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(0, 500, 0, 360), ClipsDescendants = true}, gui)
c("UIStroke", {Color = C_RED, Thickness = 3, Transparency = 0.1}, Main)

local UIScale = c("UIScale", {Scale = 1}, Main)

local TopBar = c("Frame", {BackgroundColor3 = C_PANEL, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 45), ZIndex = 2}, Main)
c("Frame", {BackgroundColor3 = C_RED, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), ZIndex = 3}, TopBar)

c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 15, 0, 0), Font = Enum.Font.GothamBlack, Text = "REBZYYX", TextColor3 = C_TXT, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3}, TopBar)
c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 140, 0, 0), Font = Enum.Font.GothamBold, Text = "F3Xgui V67", TextColor3 = C_RED, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3}, TopBar)

local Close = c("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 35, 1, 0), Position = UDim2.new(1, -35, 0, 0), Text = "×", TextColor3 = C_TXT_DIM, TextSize = 24, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 3}, TopBar)
Close.MouseEnter:Connect(function() Close.TextColor3 = C_RED end)
Close.MouseLeave:Connect(function() Close.TextColor3 = C_TXT_DIM end)

local Min = c("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 35, 1, 0), Position = UDim2.new(1, -70, 0, 0), Text = "—", TextColor3 = C_TXT_DIM, TextSize = 16, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 3}, TopBar)
Min.MouseEnter:Connect(function() Min.TextColor3 = C_TXT end)
Min.MouseLeave:Connect(function() Min.TextColor3 = C_TXT_DIM end)

local Sidebar = c("Frame", {BackgroundColor3 = C_PANEL, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(0, 120, 1, -45), ZIndex = 1}, Main)
c("Frame", {BackgroundColor3 = C_BG, BorderSizePixel = 0, Position = UDim2.new(1, -2, 0, 0), Size = UDim2.new(0, 2, 1, 0), ZIndex = 2}, Sidebar)

local Content = c("Frame", {BackgroundTransparency = 1, Position = UDim2.new(0, 130, 0, 60), Size = UDim2.new(0, 350, 0, 290), ZIndex = 1}, Main)

local Pages = {
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = true, ZIndex = 1}, Content),
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 1}, Content),
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 1}, Content),
    c("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false, ZIndex = 1}, Content)
}

local ActiveIndicator = c("Frame", {BackgroundColor3 = C_RED, BorderSizePixel = 0, Position = UDim2.new(0, 5, 0, 29), Size = UDim2.new(0, 3, 0, 22), ZIndex = 2}, Sidebar)
local NavBtns = {}
local function makeNavBtn(text, y)
    local b = c("TextButton", {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, y), Size = UDim2.new(0, 100, 0, 40), Font = Enum.Font.GothamBold, Text = text, TextColor3 = C_TXT_DIM, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 2}, Sidebar)
    b.MouseEnter:Connect(function() if b.TextColor3 ~= C_TXT then b.TextColor3 = Color3.fromRGB(200, 200, 200) end end)
    b.MouseLeave:Connect(function() if b.TextColor3 ~= C_TXT then b.TextColor3 = C_TXT_DIM end end)
    table.insert(NavBtns, b)
    return b
end

local N_Home = makeNavBtn("家", 20)
local N1 = makeNavBtn("基础", 70)
local N2 = makeNavBtn("音乐", 120)
local N3 = makeNavBtn("其它", 170)

local function setPage(idx)
    for i, p in ipairs(Pages) do p.Visible = (i == idx) end
    TweenService:Create(ActiveIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 5, 0, 29 + (idx - 1) * 50)}):Play()
    for i, btn in ipairs(NavBtns) do btn.TextColor3 = (i == idx) and C_TXT or C_TXT_DIM end
end

N_Home.MouseButton1Down:Connect(function() setPage(1) end)
N1.MouseButton1Down:Connect(function() setPage(2) end)
N2.MouseButton1Down:Connect(function() setPage(3) end)
N3.MouseButton1Down:Connect(function() setPage(4) end)

setPage(1)

local function makeBtn(parent, text, pos)
    local b = c("TextButton", {BackgroundColor3 = C_BTN, BorderSizePixel = 0, Position = pos, Size = UDim2.new(0, 105, 0, 38), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = C_TXT, TextSize = 13, AutoButtonColor = false, ZIndex = 2}, parent)
    local s = c("UIStroke", {Color = Color3.fromRGB(35, 35, 35), Thickness = 1}, b)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(28, 28, 28); s.Color = C_RED end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = C_BTN; s.Color = Color3.fromRGB(35, 35, 35) end)
    return b
end

local function populate(page, list)
    for i, name in ipairs(list) do makeBtn(page, name, UDim2.new(0, ((i - 1) % 3) * 115, 0, math.floor((i - 1) / 3) * 48)) end
end

c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 60), Font = Enum.Font.GothamBlack, Text = "BLACK ROSE", TextColor3 = C_TXT, TextSize = 36}, Pages[1])
c("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 130), Font = Enum.Font.Code, Text = "BY.Rebzyyx/Rezlaine", TextColor3 = C_RED, TextSize = 14}, Pages[1])
c("Frame", {BackgroundColor3 = C_RED, BorderSizePixel = 0, Size = UDim2.new(0, 50, 0, 2), Position = UDim2.new(0.5, -25, 0, 170)}, Pages[1])

populate(Pages[2], {"火焰", "烟雾", "光照", "闪光", "固定", "解固", "开碰撞", "关碰撞", "隐藏", "显示", "贴图", "底座"})
populate(Pages[3], {"18 Hardstyle", "Epic Sax", "Nyan Cat", "Syria Song", "Trollface", "John Cena", "Wonga", "Horror", "Sp00k"})
populate(Pages[4], {"天空", "地图", "清图", "着火", "隐形", "发光", "Disco", "悬浮", "脚本"})

local ResizeZone = c("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 1, -30), Text = "", AutoButtonColor = false, ZIndex = 5}, Main)
local isMin, normalSize, minSize = false, UDim2.new(0, 500, 0, 360), UDim2.new(0, 500, 0, 45)

Min.MouseButton1Down:Connect(function()
    isMin = not isMin
    if isMin then
        Sidebar.Visible, Content.Visible = false, false
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = minSize}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = normalSize}):Play()
        task.delay(0.3, function() Sidebar.Visible, Content.Visible = true, true end)
    end
end)

local drag, dragStart, startPos, rDrag, rStart, rScaleStart = false, nil, nil, false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag, dragStart, startPos = true, input.Position, Main.Position end
end)
ResizeZone.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then rDrag, rStart, rScaleStart = true, input.Position, UIScale.Scale end
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then drag, rDrag = false, false end
end)

Close.MouseButton1Down:Connect(function()
    local absPos, absSize = Main.AbsolutePosition, Main.AbsoluteSize
    Main.Visible = false
    local pieces = {}
    for i = 1, 40 do
        local p = c("Frame", {BackgroundColor3 = (i % 2 == 0) and C_RED or C_BTN, BorderSizePixel = 0, Position = UDim2.new(0, absPos.X + math.random(0, absSize.X), 0, absPos.Y + math.random(0, absSize.Y)), Size = UDim2.new(0, math.random(5, 20), 0, math.random(5, 20)), ZIndex = 10}, gui)
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
        if elapsed > 1.5 then 
            conn:Disconnect()
            gui:Destroy() 
        end
    end)
end)