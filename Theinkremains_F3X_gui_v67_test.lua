-- Theinkremains F3X gui v67
-- Test build: 贴纸1 / 天空盒1

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ASSET_ID = "71558205783267"

-- =========================
-- F3X Remote
-- =========================
local function getF3XRemote()
    local tool

    if player.Character then
        tool = player.Character:FindFirstChild("Building Tools+")
    end
    if not tool and player:FindFirstChild("Backpack") then
        tool = player.Backpack:FindFirstChild("Building Tools+")
    end

    if not tool then
        for _, v in ipairs(player:GetDescendants()) do
            if v.Name == "SyncAPI" then
                tool = v.Parent
                break
            end
        end
    end

    if not tool then
        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
            if v.Name == "SyncAPI" then
                tool = v.Parent
                break
            end
        end
    end

    if tool then
        local api = tool:FindFirstChild("SyncAPI")
        if api then
            return api:FindFirstChild("ServerEndpoint")
        end
    end
end

local function invoke(remote, ...)
    if not remote then
        warn("[Theinkremains F3X gui v67] F3X / SyncAPI 未找到，请先确保 Building Tools+ 可用。")
        return false
    end
    local ok = pcall(function()
        remote:InvokeServer(...)
    end)
    return ok
end

-- =========================
-- 功能：贴纸1
-- =========================
local function sticker1()
    local remote = getF3XRemote()
    if not remote then
        warn("[贴纸1] F3X / SyncAPI 未找到")
        return
    end

    local faces = {
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Left,
        Enum.NormalId.Right,
        Enum.NormalId.Top,
        Enum.NormalId.Bottom,
    }

    task.spawn(function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, face in ipairs(faces) do
                    invoke(remote, "CreateTextures", {{
                        Part = part,
                        Face = face,
                        TextureType = "Decal"
                    }})
                    invoke(remote, "SyncTexture", {{
                        Part = part,
                        Face = face,
                        TextureType = "Decal",
                        Texture = "rbxassetid://" .. ASSET_ID
                    }})
                end
                task.wait(0.03)
            end
        end
    end)
end

-- =========================
-- 功能：天空盒1
-- =========================
local function skybox1()
    local remote = getF3XRemote()
    if not remote then
        warn("[天空盒1] F3X / SyncAPI 未找到")
        return
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        warn("[天空盒1] 找不到 HumanoidRootPart")
        return
    end

    local position = root.CFrame + Vector3.new(0, 6, 0)

    invoke(remote, "CreatePart", "Normal", position, workspace)
    task.wait(0.2)

    local skyPart
    for _, part in ipairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and (part.Position - position.Position).Magnitude < 1 then
            skyPart = part
            break
        end
    end

    if not skyPart then
        warn("[天空盒1] 创建天空盒部件失败")
        return
    end

    invoke(remote, "CreateMeshes", {{Part = skyPart}})
    invoke(remote, "SyncMesh", {{
        Part = skyPart,
        MeshId = "rbxassetid://111891702759441"
    }})
    invoke(remote, "SyncMesh", {{
        Part = skyPart,
        TextureId = "rbxassetid://" .. ASSET_ID
    }})
    invoke(remote, "SyncMesh", {{
        Part = skyPart,
        Scale = Vector3.new(1000, 1000, 1000)
    }})
    invoke(remote, "SetName", {skyPart}, "Sky")
    invoke(remote, "SetLocked", {skyPart}, true)
    invoke(remote, "SyncAnchor", {{Part = skyPart}, Anchored = true})
    invoke(remote, "SyncCollision", {{Part = skyPart, CanCollide = false}})
end

-- =========================
-- UI
-- =========================
local old = playerGui:FindFirstChild("TheinkremainsF3XguiV67")
if old then
    old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TheinkremainsF3XguiV67"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(620, 190)
Main.Position = UDim2.new(0.5, -310, 0.5, -95)
Main.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = Main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(145, 145, 145)
stroke.Thickness = 1.5
stroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = TitleBar.BackgroundColor3
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Theinkremains F3X gui v67"
Title.TextColor3 = Color3.fromRGB(55, 55, 55)
Title.TextSize = 19
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = TitleBar

local function makeButton(text, x, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(275, 86)
    button.Position = UDim2.fromOffset(x, 70)
    button.BackgroundColor3 = Color3.fromRGB(242, 242, 242)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamMedium
    button.Text = text
    button.TextColor3 = Color3.fromRGB(65, 65, 65)
    button.TextSize = 18
    button.Parent = Main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = button

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(175, 175, 175)
    s.Thickness = 1
    s.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

makeButton("贴纸1", 20, sticker1)
makeButton("天空盒1", 325, skybox1)

-- =========================
-- 拖动
-- =========================
local dragging = false
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
