local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer

local authorIds = {
    [10380595563] = "脚本作者_墨水依旧",
    [4122111506] = "脚本作者_司空",
    [10619015725] = "脚本作者_司空"
}

local globalHide = false

local isAuthor = authorIds[localPlayer.UserId] ~= nil

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

local function addTag(char, labelText)
    if not char or not char:IsA("Model") then return end

    local head = char:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("AuthorTag") then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "AuthorTag"
    bill.Size = UDim2.fromOffset(160, 35)
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0, 2.8, 0)
    bill.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    bill.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(24,24,24)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Parent = bill

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(145,145,145)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(65,65,65)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(120,120,120)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(120,120,120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(65,65,65))
    })
    grad.Parent = stroke

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = labelText or "脚本作者"
    label.TextColor3 = Color3.fromRGB(190,190,190)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bill

    task.spawn(function()
        while bill.Parent do
            grad.Rotation = (grad.Rotation + 2) % 360
            RunService.RenderStepped:Wait()
        end
    end)
end

local function getAuthorTag(player)
    local char = player and player.Character
    local head = char and char:FindFirstChild("Head")
    local tag = head and head:FindFirstChild("AuthorTag")
    if tag and tag:IsA("BillboardGui") then
        return tag
    end
end

local function applyClientHide()
    for _, player in ipairs(Players:GetPlayers()) do
        if authorIds[player.UserId] then
            local tag = getAuthorTag(player)
            if tag then
                tag.Enabled = not globalHide
            end
        end
    end
end

local function scanAuthors()
    for _, player in ipairs(Players:GetPlayers()) do
        if authorIds[player.UserId] and player.Character then
            addTag(player.Character, authorIds[player.UserId])
        end
    end

    applyClientHide()
end

for _, player in ipairs(Players:GetPlayers()) do
    if authorIds[player.UserId] then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            addTag(char, authorIds[player.UserId])
            task.defer(function()
                applyClientHide()
            end)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if authorIds[player.UserId] then
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            addTag(char, authorIds[player.UserId])
            task.defer(applyClientHide)
        end)
    end
end)

task.spawn(function()
    while task.wait(2) do
        scanAuthors()
    end
end)


if isAuthor then
    pcall(function()
        local old = CoreGui:FindFirstChild("AuthorControl_IndependentUI")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "AuthorControl_IndependentUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(280,145)
    main.Position = UDim2.new(0.5,-140,0.5,-82)
    main.BackgroundColor3 = Color3.fromRGB(24,24,27)
    main.BackgroundTransparency = 0.06
    main.BorderSizePixel = 0
    main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0,14)
    mainCorner.Parent = main

    local border = Instance.new("UIStroke")
    border.Thickness = 2
    border.Color = Color3.fromRGB(160,160,160)
    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    border.Parent = main

    local borderGradient = Instance.new("UIGradient")
    borderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(180,180,180)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(120,120,120)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(180,180,180))
    })
    borderGradient.Parent = border

    task.spawn(function()
        while main.Parent do
            borderGradient.Rotation = (borderGradient.Rotation + 1.2) % 360
            RunService.RenderStepped:Wait()
        end
    end)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1,-105,0,28)
    title.Position = UDim2.fromOffset(14,8)
    title.Font = Enum.Font.GothamBold
    title.Text = "作者控制"
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(220,220,220)
    title.Parent = main

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1,-28,0,14)
    subtitle.Position = UDim2.fromOffset(15,32)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = "欢迎尊敬的作者"
    subtitle.TextSize = 8
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.TextColor3 = Color3.fromRGB(130,130,130)
    subtitle.Parent = main

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.fromOffset(32,32)
    minimize.Position = UDim2.new(1,-84,0,12)
    minimize.BackgroundColor3 = Color3.fromRGB(38,38,42)
    minimize.BorderSizePixel = 0
    minimize.Text = "—"
    minimize.TextSize = 20
    minimize.Font = Enum.Font.GothamBold
    minimize.TextColor3 = Color3.fromRGB(200,200,200)
    minimize.Parent = main

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0,9)
    minCorner.Parent = minimize

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(32,32)
    close.Position = UDim2.new(1,-46,0,12)
    close.BackgroundColor3 = Color3.fromRGB(38,38,42)
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextSize = 26
    close.Font = Enum.Font.GothamBold
    close.TextColor3 = Color3.fromRGB(210,210,210)
    close.Parent = main

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0,9)
    closeCorner.Parent = close

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,-28,0,1)
    line.Position = UDim2.fromOffset(14,56)
    line.BackgroundColor3 = Color3.fromRGB(90,90,90)
    line.BorderSizePixel = 0
    line.Parent = main

    local function makeButton(text,y)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,-28,0,40)
        b.Position = UDim2.fromOffset(14,y)
        b.BackgroundColor3 = Color3.fromRGB(35,35,39)
        b.BorderSizePixel = 0
        b.Text = text
        b.TextSize = 12
        b.Font = Enum.Font.GothamMedium
        b.TextColor3 = Color3.fromRGB(215,215,215)
        b.Parent = main

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0,10)
        c.Parent = b

        local st = Instance.new("UIStroke")
        st.Thickness = 1
        st.Transparency = 0.55
        st.Color = Color3.fromRGB(100,100,100)
        st.Parent = b

        return b
    end

    local globalButton = makeButton("关闭头顶称号：关闭",68)

    local hint = Instance.new("TextLabel")
    hint.BackgroundTransparency = 1
    hint.Size = UDim2.new(1,-28,0,18)
    hint.Position = UDim2.fromOffset(14,113)
    hint.Font = Enum.Font.Gotham
    hint.Text = "当前账号已被检测成作者"
    hint.TextSize = 9
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.TextColor3 = Color3.fromRGB(125,125,125)
    hint.Parent = main

    local function refresh()
        globalButton.Text = "关闭头顶称号：" .. (globalHide and "开启" or "关闭")
    end

    local minimized = false
    local normalSize = main.Size
    local normalPosition = main.Position

    local function setMinimized(value)
        minimized = value

        if minimized then
            normalSize = main.Size
            normalPosition = main.Position

            main.Size = UDim2.fromOffset(165,48)
            main.Position = UDim2.new(0.5,-82,0.5,-24)

            subtitle.Visible = false
            line.Visible = false
            globalButton.Visible = false
            hint.Visible = false
        else
            main.Size = normalSize
            main.Position = normalPosition

            subtitle.Visible = true
            line.Visible = true
            globalButton.Visible = true
            hint.Visible = true
        end
    end

    local dragging = false
    local dragStart
    local startPosition

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    globalButton.MouseButton1Click:Connect(function()
        globalHide = not globalHide
        applyClientHide()
        refresh()
    end)

    minimize.MouseButton1Click:Connect(function()
        setMinimized(not minimized)
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

end
scanAuthors()
refresh()

notify("作者检测", "作者检测已开启", 4)
