--什么叫你的库不是外部链接   AI就是AI还搁这自我狡辩😂下面那个print说明说明了一切
local genv = getgenv()

game:GetService("Players").LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

local backgroundList = {
    "rbxassetid://104348365371258",
    "rbxassetid://132372937787351",
    "rbxassetid://73573809374499",
    "rbxassetid://109228695009148",
}

local function nextBackground()
    local folder = "ChickenBeachChickenTech_Data"
    if not isfolder(folder) then makefolder(folder) end
    local path = folder .. "/background_index.txt"
    local idx = 0
    if isfile(path) then idx = tonumber(readfile(path)) or 0 end
    writefile(path, tostring((idx + 1) % #backgroundList))
    return backgroundList[idx + 1]
end

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/pl11451481mvcxz/qwer114514/refs/heads/main/mmw.lua"
))()

local Window = WindUI:CreateWindow({
    Title = "依旧培根头(自制)",
    Icon = "crown",
    Author = "依旧培根头",
    Size = UDim2.fromOffset(580, 420),
    Resizable = true,
    ScrollBarEnabled = true,
    Folder = "windui",
    Background = nextBackground(),
    BackgroundImageTransparency = 1,
    Transparent = true,
    SideBarWidth = 210,
    HideSearchBar = false,
    User = { Enabled = true, Anonymous = false },
})

Window:Tag({ Title = "依旧自制", Radius = 5, Color = Color3.fromHex("#00FF87") })
Window:Tag({ Title = "免费开源", Radius = 6, Color = Color3.fromHex("#FFD700") })
Window:SetToggleKey(Enum.KeyCode.F, true)

local state = {
    WalkSpeedEnabled = false, WalkSpeedValue = 16,
    JumpPowerEnabled = false, JumpPowerValue = 50,
    GravityEnabled = false, GravityValue = 196.2,
    SpeedRun = false, RunSpeed = 50,
    InfiniteJump = false,
    Noclip = false,
    FOV = 70,
    FlyEnabled = false, FlySpeed = 35, FlyLoop = false,
    TeleportTargetName = nil,
    TeleportForward = 0, TeleportSide = 0, TeleportHeight = 0,
    NoCollision = false,
    Invisible = false,
    KorbloxEnabled = false,
    GodMode = false, GodModeInterval = 1,
    SpinEnabled = false, SpinSpeed = 10,
    PlayerJoinNotify = false,
    Translation = false, TranslationSpeed = 2,
    OrbitEnabled = false, OrbitRadius = 10, OrbitSpeed = 0.5, OrbitHeight = 0,
    OrbitAngle = 0, OrbitTargetName = nil,
    FrozenEnabled = false,
    GetBackpackEnabled = false,
    AntiVoid = false,
    autoFling = false,
    TD = false,
    LoopTeleport = false,
    playernamedied = nil,
    flingRunning = false,
    KickReason = "",
}

local function setWalkSpeed(value)
    state.WalkSpeedValue = value
    if state.WalkSpeedEnabled then
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = value end
    end
end

local function applyWalkSpeedOnSpawn(char)
    local hum = char:WaitForChild("Humanoid")
    if state.WalkSpeedEnabled then
        hum.WalkSpeed = state.WalkSpeedValue or 16
    end
end

local function setJumpPower(value)
    state.JumpPowerValue = value
    if state.JumpPowerEnabled then
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = value
        end
    end
end

local function applyJumpPowerOnSpawn(char)
    local hum = char:WaitForChild("Humanoid")
    hum.UseJumpPower = true
    if state.JumpPowerEnabled then
        hum.JumpPower = state.JumpPowerValue or 50
    end
end

local function setGravity(value)
    value = tonumber(value)
    if value then
        state.GravityValue = value
        if state.GravityEnabled then workspace.Gravity = value end
    end
end

local function runSpeedLoop()
    if state.SpeedRun then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.MoveDirection.Magnitude > 0 then
            char:TranslateBy(char.Humanoid.MoveDirection * (state.RunSpeed or 50) / 0.5)
        end
    end
end
game:GetService("RunService").Heartbeat:Connect(runSpeedLoop)

local function infiniteJumpLoop()
    local uis = game:GetService("UserInputService")
    while state.InfiniteJump do
        task.wait(0.05)
        if uis:IsKeyDown(Enum.KeyCode.Space) then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end

local function noclipLoop()
    while state.Noclip do
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        task.wait(0.1)
    end
end

local function setFOV(value)
    value = tonumber(value)
    if not value or value < 1 or value > 120 then return end
    state.FOV = value
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = value end
end

local function resetFOV()
    state.FOV = 70
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = 70 end
end

local function startFly()
    if state.FlyLoop then return end
    local plr = game.Players.LocalPlayer
    local runService = game:GetService("RunService")
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bodyVel.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bodyGyro.P = 8000
    bodyGyro.Parent = hrp

    local animate = char:FindFirstChild("Animate")
    if animate then animate.Parent = nil end

    local ctrl = require(plr.PlayerScripts:WaitForChild("PlayerModule")).GetControls(plr.PlayerScripts.PlayerModule)

    task.spawn(function()
        state.FlyLoop = true
        while state.FlyEnabled and state.FlyLoop and char.Parent do
            runService.RenderStepped:Wait()
            local move = hum:GetMoveVector()
            local dir = workspace.CurrentCamera.CFrame.LookVector * -move.Z
                       + workspace.CurrentCamera.CFrame.RightVector * move.X
            bodyVel.Velocity = move.Magnitude > 0 and dir.Unit * state.FlySpeed or Vector3.new(0, 0.1, 0)
            bodyGyro.CFrame = CFrame.new(Vector3.zero,
                move.Magnitude > 0 and dir
                or Vector3.new(workspace.CurrentCamera.CFrame.LookVector.X, 0,
                               workspace.CurrentCamera.CFrame.LookVector.Z))
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        animate.Parent = char
        ctrl:Destroy()
        bodyVel:Destroy()
        bodyGyro:Destroy()
    end)
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

local function teleportToPlayer()
    if not state.TeleportTargetName then
        Window:Notify({ Title = "提示", Content = "请先选择玩家", Icon = "user", Duration = 3 })
        return
    end
    local target = game.Players:FindFirstChild(state.TeleportTargetName)
    if not target or not target.Character then
        Window:Notify({ Title = "提示", Content = "目标玩家无效", Icon = "user", Duration = 3 })
        return
    end
    local myChar = game.Players.LocalPlayer.Character
    if not myChar then
        Window:Notify({ Title = "提示", Content = "角色未加载", Icon = "user", Duration = 3 })
        return
    end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tgtRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and tgtRoot then
        myRoot.CFrame = tgtRoot.CFrame
        Window:Notify({ Title = "传送成功", Content = "已传送至 " .. state.TeleportTargetName,
            Icon = "check", Duration = 3 })
    end
end

local function noCollisionLoop()
    while state.NoCollision do
        task.wait(0.3)
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end

local function invisibleLoop()
    local plr = game.Players.LocalPlayer
    local runService = game:GetService("RunService")
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    runService.Heartbeat:Connect(function()
        if state.Invisible and hrp and hum then
            local savedCF = hrp.CFrame
            local savedOffset = hum.CameraOffset
            local newCF = savedCF * CFrame.new(0, -75, 0)
            local offset = newCF:ToObjectSpace(CFrame.new(savedCF.Position)).Position
            hrp.CFrame = newCF
            hum.CameraOffset = offset
            runService.RenderStepped:Wait()
            hrp.CFrame = savedCF
            hum.CameraOffset = savedOffset
        end
    end)
end

local function korbloxLoop()
    local plr = game.Players.LocalPlayer
    while state.KorbloxEnabled do
        task.wait(0.5)
        local char = plr.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.RigType == Enum.HumanoidRigType.R15 then
                local rf = char:FindFirstChild("RightFoot")
                local rll = char:FindFirstChild("RightLowerLeg")
                local rul = char:FindFirstChild("RightUpperLeg")
                if rf and rll and rul then
                    rf.Transparency = 1
                    rll.Transparency = 1
                    rul.MeshId = "http://www.roblox.com/asset/?id=902942096"
                    rul.TextureID = "http://roblox.com/asset/?id=902843398"
                end
            else
                local leg = char:FindFirstChild("Right Leg")
                if leg then
                    local mesh = leg:FindFirstChildOfClass("SpecialMesh")
                    if not mesh then mesh = Instance.new("SpecialMesh", leg) end
                    leg.Color = Color3.fromRGB(64, 64, 64)
                    leg.Transparency = 0
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = "rbxassetid://101851696"
                    mesh.TextureId = "rbxassetid://101851254"
                    mesh.Scale = Vector3.new(1, 1, 1)
                end
            end
        end
    end
end

local function setHeadless(enabled)
    local plr = game.Players.LocalPlayer
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    head.Transparency = enabled and 1 or 0
    for _, d in ipairs(head:GetChildren()) do
        if d:IsA("Decal") or d:IsA("Texture") then
            d.Transparency = enabled and 1 or 0
        end
    end
end

local function setBright(enabled)
    local lighting = game:GetService("Lighting")
    if enabled then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        lighting.Brightness = 1
        lighting.ClockTime = 14
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end

local function godModeLoop()
    local plr = game.Players.LocalPlayer
    while state.GodMode do
        task.wait(state.GodModeInterval)
        local char = plr.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.Health = hum.MaxHealth end
        end
    end
end

local function setMaxHealth(value)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum.MaxHealth = value
    hum.Health = value
end

local function setHealth(value)
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    char:WaitForChild("Humanoid").Health = value
end

local function spinLoop()
    local plr = game.Players.LocalPlayer
    while state.SpinEnabled do
        task.wait(0.05)
        local char = plr.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(state.SpinSpeed or 10), 0)
            end
        end
    end
end

local function loadUrl(url)
    loadstring(game:HttpGet(url))()
end

local function flingLoop()
    local plr = game.Players.LocalPlayer
    local runService = game:GetService("RunService")
    runService.Heartbeat:Wait()
    while state.flingRunning do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            runService.RenderStepped:Wait()
            hrp.Velocity = vel
            runService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
        end
        runService.Heartbeat:Wait()
    end
end

local function setFling(enabled)
    state.flingRunning = enabled
    if enabled then coroutine.wrap(flingLoop)() end
    Window:Notify({
        Title = "Fling",
        Content = enabled and "已开启" or "已关闭",
        Icon = enabled and "play" or "square",
        Duration = 2,
    })
end

local translationCache = {}

local function translateText(text)
    if not text or text == "" or #text < 2 then return nil end
    local http = game:GetService("HttpService")
    local ok, res = pcall(function()
        local data = http:JSONDecode(game:HttpGet(
            "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q="
            .. http:UrlEncode(text)))
        return data and data[1] and data[1][1] and data[1][1][1]
    end)
    if ok and res then
        translationCache[text] = res
        return res
    end
    return nil
end

local function translateLabel(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    local text = obj.Text
    if not text or text == "" then return end
    local translated = translateText(text)
    if translated and translated ~= text then obj.Text = translated end
end

local function scanGui(root)
    for _, d in ipairs(root:GetDescendants()) do
        task.spawn(function() translateLabel(d) end)
    end
end

local function translationLoop()
    local plr = game.Players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")
    playerGui.DescendantAdded:Connect(function(d)
        task.delay(0.1, function() translateLabel(d) end)
    end)
    game:GetService("CoreGui").DescendantAdded:Connect(function(d)
        task.delay(0.1, function() translateLabel(d) end)
    end)
    while state.Translation do
        scanGui(playerGui)
        pcall(function() scanGui(game:GetService("CoreGui")) end)
        task.wait(1.5 / (state.TranslationSpeed or 2))
    end
end

local function getServers(order)
    local http = game:GetService("HttpService")
    local ok, res = pcall(function()
        return http:JSONDecode(game:HttpGet(
            ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=100")
            :format(game.PlaceId, order)))
    end)
    if ok and res and res.data then return res.data end
    return nil
end

local function joinEmptyServer(order)
    local servers = getServers(order)
    if not servers then
        Window:Notify({ Title = "提示", Content = "无法获取服务器列表", Icon = "alert-triangle", Duration = 3 })
        return
    end
    for _, s in ipairs(servers) do
        if s.playing < s.maxPlayers then
            Window:Notify({
                Title = "找到空服务器",
                Content = ("当前人数 (%d/%d)"):format(s.playing, s.maxPlayers),
                Icon = "users", Duration = 3,
            })
            task.wait(1)
            game:GetService("TeleportService"):TeleportToPlaceInstance(
                game.PlaceId, s.id, game.Players.LocalPlayer)
            return
        end
    end
    Window:Notify({ Title = "提示", Content = "没有找到可用空服务器", Icon = "alert-triangle", Duration = 3 })
end

local function rejoinServer()
    Window:Notify({ Title = "重连服务器", Content = "正在重新加入...", Icon = "refresh-cw", Duration = 3 })
    task.wait(1)
    game:GetService("TeleportService"):TeleportToPlaceInstance(
        game.PlaceId, game.JobId, game.Players.LocalPlayer)
end

local function getThumb(player)
    return game:GetService("Players"):GetUserThumbnailAsync(
        player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end

game.Players.PlayerAdded:Connect(function(p)
    if not state.PlayerJoinNotify then return end
    local ok, thumb = pcall(getThumb, p)
    Window:Notify({
        Title = "玩家加入",
        Content = p.DisplayName .. " (@" .. p.Name .. ")",
        Icon = "user", Duration = 5,
        Background = ok and thumb or nil,
    })
end)

game.Players.PlayerRemoving:Connect(function(p)
    if not state.PlayerJoinNotify then return end
    local ok, thumb = pcall(getThumb, p)
    Window:Notify({
        Title = "玩家离开",
        Content = p.DisplayName .. " (@" .. p.Name .. ")",
        Icon = "user", Duration = 5,
        Background = ok and thumb or nil,
    })
end)

local function copyNotify(text, label)
    setclipboard(text)
    Window:Notify({ Title = "已复制", Content = label or "内容", Duration = 2 })
end

local trail = { obj = nil }

local trailColors = {
    ["蓝色"] = Color3.fromRGB(0, 100, 255),
    ["绿色"] = Color3.fromRGB(0, 255, 100),
    ["红色"] = Color3.fromRGB(255, 0, 0),
    ["青色"] = Color3.fromRGB(0, 255, 255),
    ["黄色"] = Color3.fromRGB(255, 255, 0),
    ["橙色"] = Color3.fromRGB(255, 150, 0),
    ["紫色"] = Color3.fromRGB(150, 0, 255),
    ["粉色"] = Color3.fromRGB(255, 105, 180),
    ["黑色"] = Color3.fromRGB(0, 0, 0),
    ["白色"] = Color3.fromRGB(255, 255, 255),
    ["彩虹"] = "rainbow",
}

local rainbow = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 100, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(75, 0, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 130, 238)),
})

local function createTrail(char, colorName)
    local hrp = char:WaitForChild("HumanoidRootPart")
    for _, n in ipairs({ "TrailAttachment0", "TrailAttachment1", "PlayerTrail" }) do
        local old = hrp:FindFirstChild(n)
        if old then old:Destroy() end
    end
    local a0 = Instance.new("Attachment")
    a0.Name = "TrailAttachment0"
    a0.Position = Vector3.new(0, 0.5, 0)
    a0.Parent = hrp
    local a1 = Instance.new("Attachment")
    a1.Name = "TrailAttachment1"
    a1.Position = Vector3.new(0, -0.5, 0)
    a1.Parent = hrp
    local t = Instance.new("Trail")
    t.Name = "PlayerTrail"
    t.Attachment0 = a0
    t.Attachment1 = a1
    t.Lifetime = 0.8
    t.LightEmission = 1
    t.LightInfluence = 0
    t.FaceCamera = true
    t.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    t.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    if colorName == "彩虹" then
        t.Color = rainbow
    else
        t.Color = ColorSequence.new(trailColors[colorName] or Color3.fromRGB(0, 255, 255))
    end
    t.Parent = hrp
    trail.obj = t
end

local function removeTrail()
    if trail.obj then
        trail.obj:Destroy()
        trail.obj = nil
    end
end

local animPacks = {
    { Name = "默认", data = { idle = "rbxassetid://1083445855", idle2 = "rbxassetid://1083450166",
        walk = "rbxassetid://1083473930", run = "rbxassetid://1083462077",
        jump = "rbxassetid://1083455352", climb = "rbxassetid://1083439238",
        fall = "rbxassetid://1083443587" } },
    { Name = "忍者", data = { idle = "rbxassetid://616111295", idle2 = "rbxassetid://616113536",
        walk = "rbxassetid://616122287", run = "rbxassetid://616117076",
        jump = "rbxassetid://616115533", climb = "rbxassetid://616104706",
        fall = "rbxassetid://616108001" } },
    { Name = "僵尸", data = { idle = "rbxassetid://616158929", idle2 = "rbxassetid://616160636",
        walk = "rbxassetid://616168032", run = "rbxassetid://616163682",
        jump = "rbxassetid://616161997", climb = "rbxassetid://616156119",
        fall = "rbxassetid://616157476" } },
    { Name = "外星人", data = { idle = "rbxassetid://707742142", idle2 = "rbxassetid://707855907",
        walk = "rbxassetid://707897309", run = "rbxassetid://707861613",
        jump = "rbxassetid://707853694", climb = "rbxassetid://707826056",
        fall = "rbxassetid://707829716" } },
    { Name = "小丑", data = { idle = "rbxassetid://616006778", idle2 = "rbxassetid://616008087",
        walk = "rbxassetid://616010382", run = "rbxassetid://616013216",
        jump = "rbxassetid://616008936", climb = "rbxassetid://616003713",
        fall = "rbxassetid://616005863" } },
    { Name = "老外", data = { idle = "rbxassetid://845397899", idle2 = "rbxassetid://845400520",
        walk = "rbxassetid://845403856", run = "rbxassetid://845386501",
        jump = "rbxassetid://845398858", climb = "rbxassetid://845392038",
        fall = "rbxassetid://845396048" } },
    { Name = "小丑女", data = { idle = "rbxassetid://616006778", idle2 = "rbxassetid://616008087",
        walk = "rbxassetid://616013216", run = "rbxassetid://616010382",
        jump = "rbxassetid://616008936", climb = "rbxassetid://616003713",
        fall = "rbxassetid://616005863" } },
    { Name = "僵尸女", data = { idle = "rbxassetid://891621366", idle2 = "rbxassetid://891633237",
        walk = "rbxassetid://891667138", run = "rbxassetid://891636393",
        jump = "rbxassetid://891627522", climb = "rbxassetid://891609353",
        fall = "rbxassetid://891617961" } },
    { Name = "大佬", data = { idle = "rbxassetid://656117400", idle2 = "rbxassetid://656118341",
        walk = "rbxassetid://656121766", run = "rbxassetid://656118852",
        jump = "rbxassetid://656117878", climb = "rbxassetid://656114359",
        fall = "rbxassetid://656115606" } },
    { Name = "傻子", data = { idle = "rbxassetid://1083195517", idle2 = "rbxassetid://1083214717",
        walk = "rbxassetid://1083178339", run = "rbxassetid://1083216690",
        jump = "rbxassetid://1083218792", climb = "rbxassetid://1083182000",
        fall = "rbxassetid://1083189019" } },
    { Name = "小可爱", data = { idle = "rbxassetid://742637544", idle2 = "rbxassetid://742638445",
        walk = "rbxassetid://742640026", run = "rbxassetid://742638842",
        jump = "rbxassetid://742637942", climb = "rbxassetid://742636889",
        fall = "rbxassetid://742637151" } },
    { Name = "老奶奶", data = { idle = "rbxassetid://750781874", idle2 = "rbxassetid://750782770",
        walk = "rbxassetid://750785693", run = "rbxassetid://750783738",
        jump = "rbxassetid://750782230", climb = "rbxassetid://750779899",
        fall = "rbxassetid://750780242" } },
    { Name = "蜘蛛", data = { idle = "rbxassetid://1132473842", idle2 = "rbxassetid://1132477671",
        walk = "rbxassetid://1132510133", run = "rbxassetid://1132494274",
        jump = "rbxassetid://1132489853", climb = "rbxassetid://1132461372",
        fall = "rbxassetid://1132469004" } },
    { Name = "海盗", data = { idle = "rbxassetid://782841498", idle2 = "rbxassetid://782845736",
        walk = "rbxassetid://782843345", run = "rbxassetid://782842708",
        jump = "rbxassetid://782847020", climb = "rbxassetid://782843869",
        fall = "rbxassetid://782846423" } },
    { Name = "女巫", data = { idle = "rbxassetid://657595757", idle2 = "rbxassetid://657568135",
        walk = "rbxassetid://657552124", run = "rbxassetid://657564596",
        jump = "rbxassetid://658409194", climb = "rbxassetid://658360781",
        fall = "rbxassetid://657600338" } },
    { Name = "神跑", data = { idle = "rbxassetid://1069977950", idle2 = "rbxassetid://1069987858",
        walk = "rbxassetid://1070017263", run = "rbxassetid://1070001516",
        jump = "rbxassetid://1069984524", climb = "rbxassetid://1069946257",
        fall = "rbxassetid://1069973677" } },
    { Name = "傻猪相扑", data = { idle = "rbxassetid://1212900985", idle2 = "rbxassetid://1212900985",
        walk = "rbxassetid://1212980338", run = "rbxassetid://1212980348",
        jump = "rbxassetid://1212954642", climb = "rbxassetid://1213044953",
        fall = "rbxassetid://1212900995" } },
    { Name = "爪牙", data = { idle = "rbxassetid://941003647", idle2 = "rbxassetid://941013098",
        walk = "rbxassetid://941028902", run = "rbxassetid://941015281",
        jump = "rbxassetid://941008832", climb = "rbxassetid://940996062",
        fall = "rbxassetid://941000007" } },
    { Name = "俯卧撑", data = { idle = "rbxassetid://1014390418", idle2 = "rbxassetid://1014398616",
        walk = "rbxassetid://1014421541", run = "rbxassetid://1014401683",
        jump = "rbxassetid://1014394726", climb = "rbxassetid://1014380606",
        fall = "rbxassetid://1014384571" } },
    { Name = "街舞", data = { idle = "rbxassetid://1149612882", idle2 = "rbxassetid://1150842221",
        walk = "rbxassetid://1151231493", run = "rbxassetid://1150967949",
        jump = "rbxassetid://1150944216", climb = "rbxassetid://1148811837",
        fall = "rbxassetid://1148863382" } },
}

local function applyAnimPack(pack)
    local char = game.Players.LocalPlayer.Character
    if not char then
        Window:Notify({ Title = "提示", Content = "角色未加载", Duration = 3 })
        return
    end
    local animate = char:FindFirstChild("Animate")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not animate or not hum then
        Window:Notify({ Title = "提示", Content = "找不到 Animate 或 Humanoid", Duration = 3 })
        return
    end
    pcall(function()
        animate.idle.Animation1.AnimationId = pack.idle
        animate.idle.Animation2.AnimationId = pack.idle2
        animate.walk.WalkAnim.AnimationId = pack.walk
        animate.run.RunAnim.AnimationId = pack.run
        animate.jump.JumpAnim.AnimationId = pack.jump
        animate.climb.ClimbAnim.AnimationId = pack.climb
        animate.fall.FallAnim.AnimationId = pack.fall
    end)
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    Window:Notify({ Title = "动作已应用", Content = pack.Name or "自定义", Duration = 3 })
end

local function frozenLoop()
    while state.FrozenEnabled do
        task.wait(0.1)
        local char = game.Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
        end
    end
end

local function backpackLoop()
    while state.GetBackpackEnabled do
        task.wait(1)
        for _, p in ipairs(game.Players:GetChildren()) do
            local bp = p:FindFirstChild("Backpack")
            if not bp then
                task.wait(0.5)
                bp = p:FindFirstChild("Backpack")
            end
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") then
                        item.Parent = game.Players.LocalPlayer.Backpack
                    end
                end
            end
        end
    end
end

local function killAll()
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
    Window:Notify({ Title = "已击杀全部玩家", Content = "本地执行", Duration = 3 })
end

local function suicide()
    local char = game.Players.LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
    Window:Notify({ Title = "已自杀", Content = "本地执行", Duration = 3 })
end

local Tabs = {
    informationTab  = Window:Tab({ Title = "信息", Icon = "rbxassetid://71024334944141" }),
    ActionTab       = Window:Tab({ Title = "玩家", Icon = "rbxassetid://71024334944141" }),
    SpeedTab        = Window:Tab({ Title = "常用", Icon = "rbxassetid://71024334944141" }),
    yiTab           = Window:Tab({ Title = "常用2", Icon = "rbxassetid://71024334944141" }),
    FETab           = Window:Tab({ Title = "FE", Icon = "rbxassetid://71024334944141" }),
    PicturequalityTab = Window:Tab({ Title = "画面", Icon = "rbxassetid://71024334944141" }),
    flingTab        = Window:Tab({ Title = "Fling/传送", Icon = "rbxassetid://71024334944141" }),
    ExecuteTab      = Window:Tab({ Title = "执行器", Icon = "rbxassetid://71024334944141" }),
    ScriptTab       = Window:Tab({ Title = "脚本", Icon = "rbxassetid://71024334944141" }),
    serverTab       = Window:Tab({ Title = "服务器脚本", Icon = "rbxassetid://71024334944141" }),
    DisguiseTab     = Window:Tab({ Title = "伪装", Icon = "rbxassetid://71024334944141" }),
    UITab           = Window:Tab({ Title = "UI设置", Icon = "rbxassetid://71024334944141" }),
}

Tabs.SpeedTab:Toggle({ Title = "启用走速", Desc = "开启秒速走速", Value = false,
    Callback = function(v) state.WalkSpeedEnabled = v end })
Tabs.SpeedTab:Slider({ Title = "修改走速", Desc = "拖动修改走速",
    Value = { Min = 0, Max = 350, Default = 16 }, Callback = setWalkSpeed })
game.Players.LocalPlayer.CharacterAdded:Connect(applyWalkSpeedOnSpawn)

Tabs.SpeedTab:Toggle({ Title = "跳跃力开关", Value = false,
    Callback = function(v) state.JumpPowerEnabled = v end })
Tabs.SpeedTab:Slider({ Title = "跳跃力",
    Value = { Min = 50, Max = 500, Default = 50 }, Callback = setJumpPower })
game.Players.LocalPlayer.CharacterAdded:Connect(applyJumpPowerOnSpawn)

Tabs.SpeedTab:Toggle({ Title = "重力开关", Value = false, Callback = function(v)
    state.GravityEnabled = v
    if not v then workspace.Gravity = 196.2 end
end })
Tabs.SpeedTab:Input({ Title = "重力设置", Placeholder = "输入重力值", Callback = setGravity })

Tabs.SpeedTab:Input({ Title = "速度跑速度", Placeholder = "输入速度",
    Callback = function(v) state.RunSpeed = tonumber(v) or 50 end })
Tabs.SpeedTab:Toggle({ Title = "速度跑开关", Value = false,
    Callback = function(v) state.SpeedRun = v end })

Tabs.SpeedTab:Toggle({ Title = "无限跳跃", Value = false, Callback = function(v)
    state.InfiniteJump = v
    if v then task.spawn(infiniteJumpLoop) end
end })
Tabs.SpeedTab:Toggle({ Title = "穿墙", Value = false, Callback = function(v)
    state.Noclip = v
    if v then task.spawn(noclipLoop) end
end })

Tabs.SpeedTab:Input({ Title = "视角 FOV", Value = "70", Placeholder = "1-120", Callback = setFOV })
Tabs.SpeedTab:Button({ Title = "重置视角", Callback = resetFOV })

Tabs.SpeedTab:Button({ Title = "飞行V3 UI", Callback = function()
    loadUrl("https://raw.githubusercontent.com/pl11451481mvcxz/FlyUI/refs/heads/main/FlyV3")
end })
Tabs.SpeedTab:Slider({ Title = "飞行速度",
    Value = { Min = 10, Max = 200, Default = 35 },
    Callback = function(v) state.FlySpeed = v end })
Tabs.SpeedTab:Toggle({ Title = "飞行开关", Value = false, Callback = function(v)
    state.FlyEnabled = v
    if v then startFly() else state.FlyLoop = false end
end })

local tpDropdown = Tabs.SpeedTab:Dropdown({
    Title = "选择要传送的玩家",
    Values = getPlayerNames(),
    Value = nil,
    AllowNone = true,
    Callback = function(v) state.TeleportTargetName = v end,
})
Tabs.SpeedTab:Button({ Title = "刷新玩家列表", Callback = function()
    tpDropdown:Refresh(getPlayerNames())
end })
Tabs.SpeedTab:Button({ Title = "传送到选择玩家", Desc = "传送到指定玩家",
    Callback = teleportToPlayer })
Tabs.SpeedTab:Button({ Title = "传送到墓碑", Callback = function()
    loadUrl("https://raw.githubusercontent.com/Vesthardov/KeylessForLoveKFL/refs/heads/main/KFL.txt")
end })

Tabs.SpeedTab:Slider({ Title = "传送前后偏移", Desc = "正数前=向前，负数=向后",
    Value = { Min = -50, Max = 50, Default = 0 },
    Callback = function(v) state.TeleportForward = v end })
Tabs.SpeedTab:Slider({ Title = "传送左右偏移",
    Value = { Min = -50, Max = 50, Default = 0 },
    Callback = function(v) state.TeleportSide = v end })
Tabs.SpeedTab:Slider({ Title = "传送上下偏移",
    Value = { Min = -50, Max = 50, Default = 0 },
    Callback = function(v) state.TeleportHeight = v end })

Tabs.SpeedTab:Toggle({ Title = "碰撞穿透", Value = false, Callback = function(v)
    state.NoCollision = v
    if v then task.spawn(noCollisionLoop) end
end })
Tabs.SpeedTab:Toggle({ Title = "隐身(仅本地)", Value = false, Callback = function(v)
    state.Invisible = v
    if v then invisibleLoop() end
end })

Tabs.SpeedTab:Button({ Title = "玩家模型", Callback = function()
    loadUrl("https://pastefy.app/h3VuG7iL/raw")
end })
Tabs.SpeedTab:Toggle({ Title = "自动隐身", Desc = "自动重置角色隐藏", Value = false,
    Callback = function(v)
        state.KorbloxEnabled = v
        if v then task.spawn(korbloxLoop) end
    end })
Tabs.SpeedTab:Toggle({ Title = "无头模式", Value = false, Callback = setHeadless })
Tabs.SpeedTab:Toggle({ Title = "全亮", Value = false, Callback = setBright })
Tabs.SpeedTab:Toggle({ Title = "无敌", Value = false, Callback = function(v)
    state.GodMode = v
    if v then task.spawn(godModeLoop) end
end })
Tabs.SpeedTab:Toggle({ Title = "隐藏血量", Callback = function()
    loadUrl("https://pastefy.app/vFFg6sYB/raw")
end })

Tabs.SpeedTab:Slider({ Title = "最大生命值",
    Value = { Min = 100, Max = 10000, Default = 100 }, Callback = setMaxHealth })
Tabs.SpeedTab:Slider({ Title = "当前生命值",
    Value = { Min = 1, Max = 10000, Default = 100 }, Callback = setHealth })

Tabs.SpeedTab:Toggle({ Title = "旋转角色", Value = false, Callback = function(v)
    state.SpinEnabled = v
    if v then task.spawn(spinLoop) end
end })
Tabs.SpeedTab:Input({ Title = "旋转速度", Value = "10",
    Callback = function(v) state.SpinSpeed = tonumber(v) or 10 end })

Tabs.SpeedTab:Button({ Title = "服务器跳跃", Callback = function()
    loadUrl("https://raw.githubusercontent.com/TypingSP/verity/main/RQE")
end })
Tabs.SpeedTab:Button({ Title = "全部工具给本地", Callback = function()
    loadUrl("https://pastefy.app/7rv5KarK/raw")
end })
Tabs.SpeedTab:Button({ Title = "全部给副手", Callback = function()
    loadUrl("https://raw.githubusercontent.com/AFKZxc/ERT.MAIN/main/DMK.lua")
end })

Tabs.SpeedTab:Toggle({ Title = "玩家加入提示", Value = false,
    Callback = function(v) state.PlayerJoinNotify = v end })

Tabs.FETab:Button({ Title = "096脚本", Callback = function()
    loadUrl("https://rawscripts.net/raw/Universal-Script-FE-SCP-096-36948")
end })
Tabs.FETab:Button({ Title = "表情动作", Callback = function()
    loadUrl("https://rawscripts.net/raw/Universal-Script-Fe-Emote-Player-51936")
end })
Tabs.FETab:Button({ Title = "Tubers93", Callback = function()
    loadUrl("https://rawscripts.net/raw/Universal-Script-Tufoos93-Gui-V1-153864")
end })
Tabs.FETab:Button({ Title = "Coolkid", Callback = function()
    loadUrl("https://rawscripts.net/raw/Universal-Script-Coolkid-gui-2.0-224364")
end })
Tabs.FETab:Button({ Title = "1x1x1x1", Callback = function()
    loadUrl("https://pastebin.com/raw/JipYNCht")
end })
Tabs.FETab:Button({ Title = "无头人模型", Callback = function()
    loadUrl("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/Kenny%E5%A4%B4%E4%B8%AD%E5%8D%88.lua")
end })
Tabs.FETab:Button({ Title = "玩家模型r6", Callback = function()
    loadUrl("https://pastebin.com/raw/XR4sGcgJ")
end })
Tabs.FETab:Button({ Title = "另一个动作", Callback = function()
    loadUrl("https://rawscripts.net/raw/Universal-Script-Fe-Emote-Player-51936")
end })
Tabs.FETab:Button({ Title = "低配VR", Callback = function()
    loadUrl("https://pastefy.app/XuozWTqG/raw")
end })
Tabs.FETab:Button({ Title = "FE无限", Callback = function()
    loadUrl("https://pastefy.app/3nfhEHQi/raw")
end })
Tabs.FETab:Button({ Title = "verity", Callback = function()
    loadUrl("https://pastebin.com/raw/Mb49LJyU")
end })
Tabs.FETab:Button({ Title = "不知名FE", Callback = function()
    loadUrl("https://raw.githubusercontent.com/STEVE-916-create/Uhhhhhh/heads/main/source/reanimdev.lua")
end })
Tabs.FETab:Button({ Title = "FE视角跳跃", Callback = function()
    loadUrl("https://rawscripts.net/raw/Universal-Script-Invisible-script-20557")
end })
Tabs.FETab:Button({ Title = "稳定瞬移(r15)", Callback = function()
    loadUrl("https://pastebin.com/raw/r862rtmj")
end })
Tabs.FETab:Button({ Title = "FE失控", Callback = function()
    loadUrl("https://raw.githubusercontent.com/3LD4D0/Crazy-Man-R6/36ec60d16bf8d208c40807aa0fd2662af76a5385/Crazy%20Man%20R6")
end })

local scriptLinks = {
    { "小皮脚本", "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua" },
    { "XK", "https://github.com/devslopo/DVES/raw/main/XK%20Hub" },
    { "窗口脚本中心", "https://githubusercontent.com/pl11451481mvcxz/chuangjiaobenzhongxin/raw/refs/heads/main/Script.lua" },
    { "窗口脚本", "https://raw.githubusercontent.com/pl11451481mvcxz/nb/refs/heads/main/%E7%AA%97%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8.lua" },
    { "小夜脚本", "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua" },
    { "叶脚本", "https://raw.githubusercontent.com/61646764343/ye-script/refs/heads/main/ye%20script.lua" },
    { "ROB", "https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2" },
    { "落叶中心", "https://raw.githubusercontent.com/krlpl/Deciduous-center-LS/main/%E8%90%BD%E5%8F%B6%E4%B8%AD%E5%BF%83%E6%B7%B7%E6%B7%86.txt" },
    { "数脚本", "https://raw.githubusercontent.com/Yb666TX-Free-YDYS/main/ShuHUB.lua" },
    { "XA", "https://raw.githubusercontent.com/Xingdiandian/Script3/rw/penu/LoadiQ192095711/lua" },
    { "XB", "https://raw.githubusercontent.com/CheekSB/X-pro/refs/heads/main/SBX(Pro).lua" },
    { "RB", "https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub" },
}
for _, item in ipairs(scriptLinks) do
    Tabs.ScriptTab:Button({ Title = item[1], Callback = function() loadUrl(item[2]) end })
end

Tabs.ScriptTab:Button({ Title = "Z某脚本中心", Callback = function()
    loadstring(utf8.char(table.unpack({
        108,111,97,100,115,116,114,105,110,103,40,103,97,109,101,58,72,116,116,112,71,101,116,40,34,104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,67,104,105,110,97,81,89,47,45,47,109,97,105,110,47,37,69,54,37,56,51,37,56,53,37,69,52,37,66,65,37,57,49,34,41,41,40,41
    })))()
end })

Tabs.serverTab:Section({ Title = "gb" })
Tabs.serverTab:Button({ Title = "GB官方服务器", Callback = function()
    loadUrl("https://raw.githubusercontent.com/pl11451481mvcxz/Yellowtooth/refs/heads/main/GB.HUB")
end })
Tabs.serverTab:Button({ Title = "旧版(皮肤脚本)", Callback = function()
    loadUrl("https://raw.githubusercontent.com/wzhxll/Liu-Ye-is-aguest/refs/heads/main/Skin%20HUB%20%E5%85%8D%E8%B4%B9%E7%89%88.lua")
end })
Tabs.serverTab:Button({ Title = "英雄联盟", Callback = function()
    loadUrl("https://raw.githubusercontent.com/pl11451481mvcxz/Legio197/refs/heads/main/GBHUB.lua")
end })
Tabs.serverTab:Button({ Title = "猫猫", Callback = function()
    loadUrl("https://api.jnkie.com/api/v1/luascripts/public/8d36cbb0e44bb4a4a844499c7f7140bc7734f8072eebf59a4d4784773bf17dfa/download")
end })
Tabs.serverTab:Button({ Title = "GB家庭群", Callback = function()
    loadUrl("https://raw.githubusercontent.com/sleenndn/Sleenndn-/refs/heads/main/cnm")
end })
Tabs.serverTab:Button({ Title = "崩坏", Callback = function()
    loadUrl("https://pastefy.app/xOXIJXr9/raw")
end })
Tabs.serverTab:Button({ Title = "飞行", Callback = function()
    loadUrl("https://raw.githubusercontent.com/pl11451481mvcxz/gbfly/refs/heads/main/fly.lua")
end })

Tabs.serverTab:Section({ Title = "第三人称射击" })
Tabs.serverTab:Button({ Title = "幽灵碰撞", Callback = function()
    loadUrl("https://raw.githubusercontent.com/pl11451481mvcxz/Q1107181697/refs/heads/main/Roor.lua")
end })
Tabs.serverTab:Button({ Title = "第三人称射击 #1", Callback = function()
    loadUrl("https://raw.githubusercontent.com/f34p9fh3a4/.xyz/refs/heads/main/loader.lua")
end })
Tabs.serverTab:Button({ Title = "第三人称射击 #2", Callback = function()
    loadUrl("https://raw.githubusercontent.com/nlzzpro/rscripts/refs/heads/main/prisonlife")
end })

Tabs.serverTab:Section({ Title = "通用" })
Tabs.serverTab:Button({ Title = "vexonhub", Callback = function()
    loadUrl("https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub")
end })
Tabs.serverTab:Button({ Title = "TSB", Callback = function()
    loadUrl("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/phantasm.lua")
end })
Tabs.serverTab:Button({ Title = "穿透视角", Callback = function()
    loadUrl("https://raw.githubusercontent.com/cytj777i/Deliver-through-the-wall-perspective/main/%E5%A4%A7%E4%B8%8D%E5%88%97%E9%A2%A0%E6%AD%AA")
end })
Tabs.serverTab:Button({ Title = "最强战场", Callback = function()
    loadUrl("https://rawscripts.net/raw/The-Strongest-Battlegrounds-SION-ELTNAM-ATLASIA-61168")
end })
Tabs.serverTab:Button({ Title = "自动刷钱", Callback = function()
    loadUrl("https://gitlab.com/zkay404-group/ProjectYielding/-/raw/main/ZKPublicFarm")
end })

Tabs.PicturequalityTab:Button({ Title = "画质", Callback = function()
    loadUrl("https://pastebin.com/raw/arzRCgwS")
end })
Tabs.PicturequalityTab:Button({ Title = "画质2", Callback = function()
    loadUrl("https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml")
end })

Tabs.ExecuteTab:Button({ Title = "全部脚本工坊", Callback = function()
    loadUrl("https://raw.githubusercontent.com/ke9460394-dot/ugik/refs/heads/main/%E5%BF%AB%E7%9B%9F.lua")
end })
Tabs.ExecuteTab:Button({ Title = "免费全能工坊", Callback = function()
    loadUrl("https://raw.githubusercontent.com/AZYsGithub/chillz-workshop/main/Arceus%20X%20V3")
end })

Tabs.informationTab:Paragraph({
    Title = "本脚本是永久免费的",
    Desc = "免责声明",
    Image = "rbxassetid://71024334944141",
    ImageSize = 50,
    Thumbnail = "rbxassetid://90738680026244",
    ThumbnailSize = 210,
    Buttons = {
        { Title = "复制作者QQ群", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("1107181697", "QQ群") end },
        { Title = "复制本脚本作者", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("依旧培根头", "作者") end },
        { Title = "复制脚本", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("脚本", "脚本") end },
    },
})

Tabs.informationTab:Paragraph({
    Title = "混淆器及工具",
    Desc = "免责声明",
    Image = "rbxassetid://71024334944141",
    ImageSize = 50,
    Thumbnail = "rbxassetid://132372937787351",
    ThumbnailSize = 360,
    Buttons = {
        { Title = "复制 wearedevs.net", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("https://wearedevs.net/obfuscator") end },
        { Title = "复制 Luraph", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("https://lura.ph/") end },
        { Title = "复制 moonveil", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("https://moonveil.cc") end },
        { Title = "复制 goofyscator", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify("https://goofyscator.lua.cz/") end },
    },
})

Tabs.informationTab:Paragraph({
    Title = "交流群(dc)",
    Image = "rbxassetid://104348365371258",
    ImageSize = 50,
    Thumbnail = "rbxassetid://104348365371258",
    ThumbnailSize = 360,
    Buttons = {
        { Title = "复制 Moonsec V3 群", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify(".gg/25ms") end },
        { Title = "复制 WeAreDabs 群", Variant = "Primary", Icon = "copy",
          Callback = function() copyNotify(".gg/threaded") end },
    },
})

Tabs.informationTab:Button({ Title = "跳转到最少人服务器",
    Callback = function() joinEmptyServer("Asc") end })
Tabs.informationTab:Button({ Title = "跳转到最多人服务器",
    Callback = function() joinEmptyServer("Desc") end })
Tabs.informationTab:Button({ Title = "重新加入本服务器", Callback = rejoinServer })

local function getDisguisePlayers()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    if #names == 0 then table.insert(names, "当前无其他玩家") end
    return names
end

local disguiseDropdown = Tabs.DisguiseTab:Dropdown({
    Title = "选择要伪装的玩家",
    Values = getDisguisePlayers(),
    Value = nil,
    AllowNone = true,
    Callback = function(v) state.playernamedied = v end,
})
Tabs.DisguiseTab:Button({ Title = "刷新玩家列表", Callback = function()
    disguiseDropdown:Refresh(getDisguisePlayers())
end })
Tabs.DisguiseTab:Button({ Title = "伪装玩家(r6)", Callback = function()
    loadUrl("https://raw.githubusercontent.com/giobolqv1/invincible-characters-animations-by-GioBolqv1-/refs/heads/main/universal.lua")
end })
Tabs.DisguiseTab:Button({ Title = "隐藏本地角色", Callback = function()
    loadUrl("https://raw.githubusercontent.com/wzhxll/Willow-the-Invincible/refs/heads/main/(%C3%A9%C3%A5%C2%B2%C3%A7)%204-obfuscated%20(4).lua")
end })

Tabs.flingTab:Dropdown({
    Title = "选择玩家",
    Values = getPlayerNames(),
    Value = nil,
    AllowNone = true,
    Callback = function(v) state.TeleportTargetName = v end,
})

Tabs.flingTab:Button({ Title = "Fling 开关", Callback = function() setFling(true) end })
Tabs.flingTab:Button({ Title = "触碰玩家", Callback = function()
    loadUrl("https://raw.githubusercontent.com/pl11451481mvcxz/qwer114514/refs/heads/main/touch.lua")
end })

Tabs.flingTab:Slider({ Title = "自动环绕半径",
    Value = { Min = 1, Max = 60, Default = 10 },
    Callback = function(v) state.OrbitRadius = v end })
Tabs.flingTab:Slider({ Title = "自动环绕速度",
    Value = { Min = 1, Max = 120, Default = 5 },
    Callback = function(v) state.OrbitSpeed = v / 10 end })
Tabs.flingTab:Slider({ Title = "自动环绕高度",
    Value = { Min = -20, Max = 25, Default = 0 },
    Callback = function(v) state.OrbitHeight = v end })
Tabs.flingTab:Toggle({ Title = "自动环绕玩家", Value = false, Callback = function(v)
    state.OrbitEnabled = v
end })

for _, pack in ipairs(animPacks) do
    Tabs.ActionTab:Button({
        Title = pack.Name,
        Desc = "点击应用 " .. pack.Name .. " 动作包",
        Icon = "play",
        Callback = function() applyAnimPack(pack) end,
    })
end

Tabs.yiTab:Toggle({ Title = "冻结本地角色", Desc = "本地无法移动", Value = false,
    Callback = function(v)
        state.FrozenEnabled = v
        if v then
            task.spawn(frozenLoop)
        else
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        end
    end })
Tabs.yiTab:Button({ Title = "击杀当前服务器玩家", Icon = "skull", Callback = killAll })
Tabs.SpeedTab:Button({ Title = "自杀", Icon = "skull", Callback = suicide })
Tabs.yiTab:Toggle({ Title = "获取本地玩家背包", Value = false, Callback = function(v)
    state.GetBackpackEnabled = v
    if v then task.spawn(backpackLoop) end
end })

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if trail.obj then
        task.wait(0.5)
        createTrail(char, "青色")
    end
end)

Tabs.ActionTab:Toggle({ Title = "启用玩家拖尾", Desc = "本地创建彩色拖尾", Value = false,
    Callback = function(v)
        if v then
            local char = game.Players.LocalPlayer.Character
            if char then createTrail(char, "青色") end
        else
            removeTrail()
        end
    end })
Tabs.ActionTab:Dropdown({
    Title = "拖尾颜色",
    Values = { "蓝色", "绿色", "红色", "青色", "黄色", "橙色", "彩虹", "黑色", "白色", "紫色", "粉色" },
    Value = "青色",
    Callback = function(v)
        if trail.obj then
            if v == "彩虹" then
                trail.obj.Color = rainbow
            else
                trail.obj.Color = ColorSequence.new(trailColors[v] or Color3.fromRGB(0, 255, 255))
            end
        end
    end,
})

Tabs.UITab:Input({
    Title = "设置背景图片",
    Desc = "输入图片的资源ID",
    Value = "",
    Placeholder = "输入 rbxassetid:// 资源ID",
    Callback = function(v)
        if v ~= "" then
            local id = "rbxassetid://" .. v
            pcall(function() Window:SetBackgroundImage(id) end)
            Window:Notify({ Title = "背景已设置", Content = id, Icon = "check", Duration = 3 })
        end
    end,
})

Tabs.UITab:Dropdown({
    Title = "选择主题",
    Desc = "更改UI主题",
    Values = { "Dark", "Light", "Mocha", "Aqua", "Rose" },
    Value = "Dark",
    Callback = function(v) Window:SetTheme(v) end,
})

Tabs.UITab:Dropdown({
    Title = "UI背景图片",
    Desc = "选择背景图片",
    Values = { "黑色背景", "白色", "蓝色", "蓝色rk", "红色" },
    Value = "白色",
    Callback = function(v)
        local map = {
            ["黑色背景"] = "rbxassetid://104348365371258",
            ["白色"] = "rbxassetid://132372937787351",
            ["蓝色"] = "rbxassetid://73573809374499",
            ["蓝色rk"] = "rbxassetid://73573809374499",
            ["红色"] = "rbxassetid://109228695009148",
        }
        local id = map[v] or ""
        pcall(function() Window:SetBackgroundImage(id) end)
    end,
})

Tabs.UITab:Slider({ Title = "背景透明度", Desc = "调整背景透明度",
    Value = { Min = 0, Max = 1, Default = 0 }, Step = 0.05,
    Callback = function(v)
        Window:SetBackgroundTransparency(v)
        Window:SetBackgroundImageTransparency(v)
    end })
Tabs.UITab:Button({ Title = "完全透明", Callback = function()
    Window:SetBackgroundTransparency(1)
    Window:SetBackgroundImageTransparency(1)
end })
Tabs.UITab:Button({ Title = "半透明", Callback = function()
    Window:SetBackgroundTransparency(0.5)
    Window:SetBackgroundImageTransparency(0.5)
end })
Tabs.UITab:Button({ Title = "完全不透明", Callback = function()
    Window:SetBackgroundTransparency(0)
    Window:SetBackgroundImageTransparency(0)
end })

task.spawn(function()
    task.wait(0.5)
    Window:Notify({ Title = "欢迎", Content = "依旧培根头脚本已加载", Icon = "crown", Duration = 3 })
end)

print("[依旧培根头] 脚本加载完成")