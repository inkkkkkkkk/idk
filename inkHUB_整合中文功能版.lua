local function safeNotify(title,text,duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title=title,
            Text=text,
            Duration=duration or 3
        })
    end)
end

local function safeHttpGet(url)
    local ok,res=pcall(function()
        return game:HttpGet(url)
    end)
    if ok then return res end
    return nil
end

local tasklib=task or {}
if not tasklib.wait then
    tasklib.wait=function(t)
        wait(t)
    end
end
if not tasklib.spawn then
    tasklib.spawn=function(f)
        coroutine.wrap(f)()
    end
end
task=tasklib

local A=game:GetService("StarterGui")

local ok,err=xpcall(function()

local function gradient(text,startColor,endColor)
    local result=""
    local chars={}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do table.insert(chars,uchar) end
    local length=#chars
    for i=1,length do
        local t=(i-1)/math.max(length-1,1)
        local r=startColor.R+(endColor.R-startColor.R)*t
        local g=startColor.G+(endColor.G-startColor.G)*t
        local b=startColor.B+(endColor.B-startColor.B)*t
        result=result..string.format('<font color="rgb(%d,%d,%d)">%s</font>',math.floor(r*255),math.floor(g*255),math.floor(b*255),chars[i])
    end
    return result
end

local B = nil
local winduiLastError = "未知错误"

local ok, result = pcall(function()
    local code = game:HttpGet(
        "https://github.com/Footagesus/WindUI/releases/download/1.6.66/main.lua",
        true
    )
    if type(code) ~= "string" or #code < 100 then
        error("WindUI下载内容为空")
    end

    local loader = loadstring(code)
    if type(loader) ~= "function" then
        error("WindUI loadstring失败")
    end

    return loader()
end)

if ok and result then
    B = result
else
    winduiLastError = tostring(result)
end


if not B then
    pcall(function()
        A:SetCore("SendNotification",{Title="WindUI加载失败",Text="请检查Delta网络/HttpGet支持",Duration=5})
    end)
    warn("[ink_HUB] WindUI加载失败:", winduiLastError)
    error("WindUI加载失败: " .. tostring(winduiLastError))
end

pcall(function()
    B:AddTheme({
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


local C
local windowOk, windowResult = pcall(function()
    return B:CreateWindow({
        Title = gradient("ink_HUB",Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)),
        Author = gradient("@墨水依旧 司空",Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)),
        Icon = "rbxassetid://71953031400395",
        Folder = "ink_HUB",
        NewElements = true,
        HideSearchBar = false,
        Theme = "inkGray",
    })
end)

if not windowOk or not windowResult then
    winduiLastError = tostring(windowResult)
    pcall(function()
        A:SetCore("SendNotification",{
            Title="UI创建失败",
            Text="CreateWindow失败，请查看执行器报错信息",
            Duration=6
        })
    end)
    warn("[ink_HUB] CreateWindow失败:", winduiLastError)
    return
end

C = windowResult

pcall(function()
    C:Tag({ Title = "永久免费", Radius = 5, Color = Color3.fromHex("#555555") })
    C:Tag({ Title = "2026", Radius = 6, Color = Color3.fromHex("#B0B0B0") })
end)

pcall(function()
    C:EditOpenButton({
        Title = "Project_ink_HUB_2026!",
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



pcall(function()
    local RunService = game:GetService("RunService")
    local targetWindow = C.UIElements and C.UIElements.Main

    if not targetWindow then
        local CoreGui = game:GetService("CoreGui")
        for _, obj in ipairs(CoreGui:GetDescendants()) do
            if obj:IsA("Frame") and obj.AbsoluteSize.X > 300 and obj.AbsoluteSize.Y > 150 then
                local title = obj:FindFirstChildWhichIsA("TextLabel", true)
                if title and title.Text == "ink_HUB" then
                    targetWindow = obj
                    break
                end
            end
        end
    end

    if targetWindow then
        local oldStroke = targetWindow:FindFirstChild("inkGrayMainBorder")
        if oldStroke then oldStroke:Destroy() end

        local stroke = Instance.new("UIStroke")
        stroke.Name = "inkGrayMainBorder"
        stroke.Thickness = 7
        stroke.Transparency = 0
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Color = Color3.fromRGB(145,145,145)
        stroke.Parent = targetWindow

        local glowColors = {
            {Name = "inkGrayGlowOuter", Thickness = 16, Transparency = 0.88},
            {Name = "inkGrayGlowMid", Thickness = 11, Transparency = 0.80},
            {Name = "inkGrayGlowInner", Thickness = 7, Transparency = 0.70},
        }
        for _, info in ipairs(glowColors) do
            local oldGlow = targetWindow:FindFirstChild(info.Name)
            if oldGlow then oldGlow:Destroy() end
            local glow = Instance.new("UIStroke")
            glow.Name = info.Name
            glow.Thickness = info.Thickness
            glow.Transparency = info.Transparency
            glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            glow.Color = Color3.fromRGB(150,150,150)
            glow.Parent = targetWindow
            local glowGradient = Instance.new("UIGradient")
            glowGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70,70,70)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(190,190,190)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(70,70,70))
            })
            glowGradient.Parent = glow
            task.spawn(function()
                local r = 0
                while targetWindow.Parent and glow.Parent and glowGradient.Parent do
                    r = (r + 1.1) % 360
                    glowGradient.Rotation = r
                    RunService.RenderStepped:Wait()
                end
            end)
        end

        local gradient = Instance.new("UIGradient")
        gradient.Name = "inkGrayBorderGradient"
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(65,65,65)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(120,120,120)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200,200,200)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(120,120,120)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(65,65,65))
        })
        gradient.Parent = stroke

        task.spawn(function()
            local rotation = 0
            while targetWindow.Parent and stroke.Parent and gradient.Parent do
                rotation = (rotation + 1.5) % 360
                gradient.Rotation = rotation
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

pcall(function()
    local CoreGui = game:GetService("CoreGui")
    local function recolor(root)
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if obj.Text == "ink_HUB" then
                    obj.TextColor3 = Color3.fromRGB(155,155,155)
                elseif obj.Text == "@墨水依旧 司空" then
                    obj.TextColor3 = Color3.fromRGB(125,125,125)
                end
            end
        end
    end
    recolor(CoreGui)
    task.delay(0.25, function() pcall(function() recolor(CoreGui) end) end)
    task.delay(0.8, function() pcall(function() recolor(CoreGui) end) end)
end)

local D=C

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



-- 第二脚本功能适配层：把原 Obsidian API 接到本脚本的 WindUI
local library = {
    Notify = function(_, msg, duration)
        safeNotify("无尽现实", tostring(msg), duration or 2)
    end
}
local localPlayer = game.Players.LocalPlayer

local function makeCompatTab(tab)
    local compat = {}

    function compat:AddTab(_)
        return compat
    end

    function compat:AddLeftTabbox(_)
        return compat
    end

    function compat:AddRightTabbox(_)
        return compat
    end

    function compat:AddToggle(_, cfg)
        cfg = cfg or {}
        local callback
        local obj = tab:Toggle({
            Title = cfg.Text or cfg.Title or "开关",
            Value = cfg.Default == true,
            Callback = function(v)
                if callback then pcall(callback, v) end
            end
        })
        return {
            OnChanged = function(_, fn)
                callback = fn
                return obj
            end
        }
    end

    function compat:AddSlider(_, cfg)
        cfg = cfg or {}
        local callback
        local min = tonumber(cfg.Min) or 0
        local max = tonumber(cfg.Max) or 100
        local default = tonumber(cfg.Default) or min
        local obj = tab:Slider({
            Title = cfg.Text or cfg.Title or "滑块",
            Value = {Min = min, Max = max, Default = default},
            Step = tonumber(cfg.Rounding) or 1,
            Callback = function(v)
                if callback then pcall(callback, v) end
            end
        })
        return {
            OnChanged = function(_, fn)
                callback = fn
                return obj
            end
        }
    end

    function compat:AddDropdown(_, cfg)
        cfg = cfg or {}
        local callback
        local obj = tab:Dropdown({
            Title = cfg.Text or cfg.Title or "下拉菜单",
            Values = cfg.Values or {},
            Value = cfg.Default,
            Callback = function(v)
                if callback then pcall(callback, v) end
            end
        })
        return {
            OnChanged = function(_, fn)
                callback = fn
                return obj
            end,
            Refresh = function(_, values)
                pcall(function() obj:Refresh(values) end)
            end
        }
    end

    function compat:AddButton(name, cfg)
        cfg = cfg or {}
        local title = cfg.Text or (type(name) == "string" and name) or "按钮"
        return tab:Button({
            Title = title,
            Callback = function()
                if cfg.Func then
                    pcall(cfg.Func)
                end
            end
        })
    end

    return compat
end

local v64 = {
    Player = makeCompatTab(D:Tab({Title="玩家", Icon="user"})),
    Visuals = makeCompatTab(D:Tab({Title="视觉", Icon="eye"})),
    Suits = makeCompatTab(D:Tab({Title="服装", Icon="shirt"})),
    Hats = makeCompatTab(D:Tab({Title="帽子", Icon="sparkles"})),
    Items = makeCompatTab(D:Tab({Title="物品", Icon="package"})),
    Endings = makeCompatTab(D:Tab({Title="结局", Icon="map"})),
    Premium = makeCompatTab(D:Tab({Title="高级", Icon="star"})),
}

local movement2 = v64.Player
local visuals2 = v64.Player
local other2 = v64.Player


local players, v168, v173, enabled, v177, v194, v195, v200, v201, npCs, items, players2,
      npcs, v209, v210, v216, v217, v234, v235, v241, v248, replicatedStorage4, events,
      suits, localPlayer5, v326, v327, v328, v329, hats, v354, v355, v356, v357, v358, localPlayer6

do
  local v65 = false
  local v66 = 16
  local f1

  local function f2()
    local v67 = f1()

    if not v67 then
      return
    else
      if v65 then
        v67.WalkSpeed = v66
      else
        v67.WalkSpeed = 16
      end

      return
    end
  end

  f1 = function()
    local character = localPlayer.Character
    local humanoid = character
    local v68

    if character then
      do
      end

      humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    end

    return humanoid
  end

  local v69 = f2

  task.spawn(function()
    local v70, v71

    while (task.wait(0.1)) do
      local v72
      v72 = f1()

      local v73
      v73 = v72

      if v72 then
        do
        end

        do
        end

        v73 = v65 and v72.WalkSpeed ~= v66
      end

      if v73 then
        v72.WalkSpeed = v66
      end
    end

    return
  end)

  do
  end

  ;(movement2:AddToggle("WalkToggle", {
    Text = "移动速度",
    Default = false,
    Tooltip = "提高移动速度，可使用滑块调整速度。",
  })):OnChanged(function(p1)
    local v74 = p1
    local v75, v76, v77
    v65 = p1
    f2()
    local v78 = library

    do
    end

    do
    end

    do
    end

    library:Notify(v65 and "移动速度已开启：" .. v66 or "移动速度已关闭", 1.5)
    return
  end)

  do
  end

  ;(movement2:AddSlider("WalkSlider", {
    Text = "速度",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Tooltip = "调整移动速度",
  })):OnChanged(function(p2)
    v66 = p2

    if v65 then
      f2()
    end

    return
  end)

  local v79 = false
  local v80 = 5
  local v81 = false
  local localPlayer2 = game.Players.LocalPlayer
  local character2 = localPlayer2.Character
  local v82 = character2

  if not character2 then
    do
    end

    v82 = localPlayer2.CharacterAdded:Wait()
  end

  local v83 = v82

  local function f3()
    local v84

    if v83 then
      do
      end

      local humanoidRootPart
      humanoidRootPart = v83:FindFirstChild("HumanoidRootPart")

      if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
      end
    end

    return
  end

  local currentCamera = workspace.CurrentCamera
  local v85 = f3

  do
  end

  localPlayer2.CharacterAdded:Connect(function(character3)
    v83 = character3

    if v79 then
      task.wait(1)

      if v79 then
        activateFly()
      end
    end

    return
  end)

  local getPivot

  local function f4()
    local v86, v87, v88, v89, v90, v91, v92, v93, v94

    if not v83 then
      return
    else
      do
      end

      getPivot = (v83:GetPivot())

      do
      end

      local heartbeat
      heartbeat = (game:GetService("RunService")).Heartbeat

      do
      end

      heartbeat:Connect(function()
        do
        end

        local v95 = not v79 or not v83
        local v96

        if v95 then
          return
        else
          f3()

          do
          end

          local humanoidRootPart2
          humanoidRootPart2 = v83:FindFirstChild("HumanoidRootPart")

          if humanoidRootPart2 then
            humanoidRootPart2.CFrame = getPivot
          end

          return
        end
      end)

      v93 = {
        [Enum.KeyCode.Q] = {
          function()
            local v97, v98, v99, v100, v101

            while true do
              do
              end

              local userInputService
              userInputService = game:GetService("UserInputService")

              do
              end

              do
              end

              if (userInputService:IsKeyDown(Enum.KeyCode.Q)) and v79 then
                do
                end

                do
                end

                ;(game:GetService("RunService")).Heartbeat:Wait()

                if v81 then
                else
                  getPivot = getPivot + (Vector3.new(0, v80 * 0.1, 0))
                end
              else
                break
              end
            end

            return
          end,
        },
        [Enum.KeyCode.E] = {
          function()
            local v102, v103, v104, v105, v106

            while true do
              do
              end

              local userInputService2
              userInputService2 = game:GetService("UserInputService")

              do
              end

              do
              end

              if (userInputService2:IsKeyDown(Enum.KeyCode.E)) and v79 then
                do
                end

                do
                end

                ;(game:GetService("RunService")).Heartbeat:Wait()

                if v81 then
                else
                  getPivot = getPivot + (Vector3.new(0, -v80 * 0.1, 0))
                end
              else
                break
              end
            end

            return
          end,
        },
        [Enum.KeyCode.W] = {
          function()
            local v107, v108, v109, v110, v111

            while true do
              do
              end

              local userInputService3
              userInputService3 = game:GetService("UserInputService")

              do
              end

              do
              end

              if (userInputService3:IsKeyDown(Enum.KeyCode.W)) and v79 then
                do
                end

                do
                end

                ;(game:GetService("RunService")).Heartbeat:Wait()

                if v81 then
                else
                  getPivot = getPivot + currentCamera.CFrame.LookVector * v80 * 0.1
                end
              else
                break
              end
            end

            return
          end,
        },
        [Enum.KeyCode.S] = {
          function()
            local v112, v113, v114, v115, v116

            while true do
              do
              end

              local userInputService4
              userInputService4 = game:GetService("UserInputService")

              do
              end

              do
              end

              if (userInputService4:IsKeyDown(Enum.KeyCode.S)) and v79 then
                do
                end

                do
                end

                ;(game:GetService("RunService")).Heartbeat:Wait()

                if v81 then
                else
                  getPivot = getPivot - currentCamera.CFrame.LookVector * v80 * 0.1
                end
              else
                break
              end
            end

            return
          end,
        },
        [Enum.KeyCode.A] = {
          function()
            local v117, v118, v119, v120, v121

            while true do
              do
              end

              local userInputService5
              userInputService5 = game:GetService("UserInputService")

              do
              end

              do
              end

              if (userInputService5:IsKeyDown(Enum.KeyCode.A)) and v79 then
                do
                end

                do
                end

                ;(game:GetService("RunService")).Heartbeat:Wait()

                if v81 then
                else
                  getPivot = getPivot - currentCamera.CFrame.RightVector * v80 * 0.1
                end
              else
                break
              end
            end

            return
          end,
        },
        [Enum.KeyCode.D] = {
          function()
            local v122, v123, v124, v125, v126

            while true do
              do
              end

              local userInputService6
              userInputService6 = game:GetService("UserInputService")

              do
              end

              do
              end

              if (userInputService6:IsKeyDown(Enum.KeyCode.D)) and v79 then
                do
                end

                do
                end

                ;(game:GetService("RunService")).Heartbeat:Wait()

                if v81 then
                else
                  getPivot = getPivot + currentCamera.CFrame.RightVector * v80 * 0.1
                end
              else
                break
              end
            end

            return
          end,
        },
        [Enum.KeyCode.Space] = {
          function()
            v81 = true
            return
          end,
        },
      }

      v94 = {
        [Enum.KeyCode.Space] = {
          function()
            v81 = false
            return
          end,
        },
      }

      do
      end

      local inputBegan
      inputBegan = (game:GetService("UserInputService")).InputBegan

      do
      end

      inputBegan:Connect(function(p3, p4)
        local v127 = p3

        do
        end

        local v128 = not p4 and v79
        local v129, v130

        if v128 then
          do
          end

          do
          end

          if p3.UserInputType == Enum.UserInputType.Keyboard and v93[p3.KeyCode] then
            for key, value in pairs(v93[p3.KeyCode]) do
              task.spawn(value)
            end
          end
        end

        return
      end)

      do
      end

      local inputEnded
      inputEnded = (game:GetService("UserInputService")).InputEnded

      do
      end

      inputEnded:Connect(function(p5, p6)
        local v131 = not p6
        local v132 = p5
        local v133 = v131 and v79
        local v134, v135

        if v133 then
          do
          end

          do
          end

          if p5.UserInputType == Enum.UserInputType.Keyboard and v94[p5.KeyCode] then
            for key2, value2 in pairs(v94[p5.KeyCode]) do
              task.spawn(value2)
            end
          end
        end

        return
      end)

      local v136
      v136 = library

      library:Notify("飞行已开启 - W/A/S/D移动，Q/E上升/下降", 1.5)
      return
    end
  end

  local function f5()
    if v83 then
      local v137
      v137 = v83

      local v138
      v138 = v83

      v137:PivotTo(CFrame.new((v138:GetPivot()).Position))
    end

    local v139 = library
    library:Notify("飞行已关闭", 1.5)
    return
  end

  do
  end

  ;(movement2:AddToggle("FlyToggle", {
    Text = "飞行",
    Default = false,
    Tooltip = "允许你在地图中飞行。",
  })):OnChanged(function(p7)
    local v140 = p7
    v79 = p7

    if p7 then
      f4()
    else
      f5()
    end

    return
  end)

  do
  end

  ;(movement2:AddSlider("FlySpeed", {
    Text = "飞行速度",
    Default = 5,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Tooltip = "调整飞行移动速度",
  })):OnChanged(function(p8)
    v80 = p8
    return
  end)
end

do
  local v141 = true
  local connect, v142

  local function f6()
    do
    end

    do
    end

    connect = ((game:GetService("RunService")).Stepped:Connect(function()
      do
      end

      local character4 = not v141 and localPlayer.Character
      local v143

      if character4 then
        do
        end

        for key3, value3 in pairs(localPlayer.Character:GetDescendants()) do
          if (value3:IsA("BasePart")) then
            if v142[value3] == nil then
              v142[value3] = value3.CanCollide
            end

            value3.CanCollide = false
          end
        end
      end

      return
    end))

    return
  end

  connect = nil

  local function f7()
    local character5 = localPlayer.Character
    local humanoidRootPart3 = character5
    local v144, v145

    if character5 then
      do
      end

      humanoidRootPart3 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    end

    if humanoidRootPart3 then
      local humanoidRootPart4
      humanoidRootPart4 = localPlayer.Character.HumanoidRootPart
      humanoidRootPart4.Anchored = true

      for key4, value4 in pairs(v142) do
        do
        end

        if key4 and key4.Parent then
          key4.CanCollide = value4
        end
      end

      wait(0.1)
      humanoidRootPart4.Anchored = false
    end

    v142 = {}
    return
  end

  v142 = {}
  local v146 = f6
  local v147 = f7

  do
  end

  ;(movement2:AddToggle("穿墙", {
    Text = "穿墙",
    Default = false,
    Tooltip = "穿过墙壁和物体",
  })):OnChanged(function(p9)
    local v148
    v141 = not p9

    if v141 then
      if connect then
        do
        end

        connect:Disconnect()
        connect = nil
      end

      f7()

      local v149
      v149 = library

      library:Notify("穿墙已关闭", 1.5)
    else
      f6()

      local v150
      v150 = library

      library:Notify("穿墙已开启", 1.5)
    end

    return
  end)

  do
  end

  local lighting = (game:GetService("Lighting"))

  local v151 = {
    Brightness = lighting.Brightness,
    OutdoorAmbient = lighting.OutdoorAmbient,
    Ambient = lighting.Ambient,
  }

  do
  end

  ;(visuals2:AddToggle("Bright", {
    Text = "全亮",
    Default = false,
    Tooltip = "移除黑暗，让环境完全可见。",
  })):OnChanged(function(p10)
    if p10 then
      lighting.Brightness = 2
      lighting.OutdoorAmbient = Color3.new(1, 1, 1)
      lighting.Ambient = Color3.new(1, 1, 1)

      local v152
      v152 = library

      library:Notify("全亮已开启", 1.5)
    else
      lighting.Brightness = v151.Brightness
      lighting.OutdoorAmbient = v151.OutdoorAmbient
      lighting.Ambient = v151.Ambient

      local v153
      v153 = library

      library:Notify("全亮已关闭", 1.5)
    end

    return
  end)
end

do
  do
  end

  ;(visuals2:AddSlider("Fov", {
    Text = "视野",
    Default = 70,
    Min = 0,
    Max = 120,
    Rounding = 1,
    Tooltip = "调整你的视野范围。",
  })):OnChanged(function(fieldOfView)
    workspace.CurrentCamera.FieldOfView = fieldOfView
    return
  end)

  do
  end

  players = (game:GetService("玩家"))
  local localPlayer3 = players.LocalPlayer

  do
  end

  ;(visuals2:AddToggle("PersonToggle", {
    Text = "第三人称",
    Default = false,
    Tooltip = "切换到第三人称视角。",
  })):OnChanged(function(p11)
    if p11 then
      localPlayer3.CameraMode = Enum.CameraMode.Classic

      local v154
      v154 = library

      library:Notify("第三人称已开启", 1.5)
    else
      localPlayer3.CameraMode = Enum.CameraMode.LockFirstPerson

      local v155
      v155 = library

      library:Notify("第三人称已关闭", 1.5)
    end

    return
  end)

  local connect2

  local function f8()
    do
    end

    local v156 = game:GetService("Workspace")

    local function f9(p12)
      local v157 = p12
      local v158
      p12.HoldDuration = 0.0001

      do
      end

      p12.Changed:Connect(function()
        if p12.HoldDuration > 0.0001 then
          p12.HoldDuration = 0.0001
        end

        return
      end)

      return
    end

    local v159

    for index, value5 in ipairs(v156:GetDescendants()) do
      if value5.ClassName == "ProximityPrompt" then
        f9(value5)
      end
    end

    do
    end

    connect2 = (v156.DescendantAdded:Connect(function(descendant)
      local v160 = descendant

      if descendant.ClassName == "ProximityPrompt" then
        f9(descendant)
      end

      return
    end))

    return
  end

  connect2 = nil

  local function f10()
    local v161

    if connect2 then
      do
      end

      connect2:Disconnect()
      connect2 = nil
    end

    return
  end

  local v162 = f8
  local v163 = f10

  do
  end

  ;(other2:AddToggle("InstantProximity", {
    Text = "瞬间交互",
    Default = false,
    Tooltip = "让所有交互提示立即完成，无需长按。",
  })):OnChanged(function(p13)
    local v164 = p13

    if p13 then
      f8()

      local v165
      v165 = library

      library:Notify("瞬间交互已开启", 1.5)
    else
      f10()

      local v166
      v166 = library

      library:Notify("瞬间交互已关闭", 1.5)
    end

    return
  end)
end

other2:AddButton("打开电梯", {
  Text = "打开电梯",
  Func = function()
    do
    end

    local replicatedStorage = game:GetService("ReplicatedStorage")

    local openElevator = replicatedStorage:WaitForChild("OpenElevator")
    openElevator:FireServer()

    local v167 = library
    library:Notify("电梯已打开", 1.5)
    return
  end,
  Tooltip = "立即打开电梯。",
})

local function f11(p14)
  local v169 = p14

  do
  end

  local v170 = not v168[p14] and p14 ~= localPlayer

  if v170 then
    local line
    line = Drawing.new("Line")
    line.Thickness = 2
    line.Color = Color3.fromRGB(37, 150, 190)
    line.Transparency = 1
    line.Visible = false

    v168[p14] = line
  end

  return
end

other2:AddButton("传送到电梯", {
  Text = "传送到电梯",
  Func = function()
    local character6 = localPlayer.Character
    local humanoidRootPart5 = character6
    local v171

    if character6 then
      do
      end

      humanoidRootPart5 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    end

    if humanoidRootPart5 then
      localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
        16.983798980713, 33.711311340332, 572.31719970703
      )

      local v172
      v172 = library

      library:Notify("已传送到电梯", 1.5)
    end

    return
  end,
  Tooltip = "传送到电梯位置。",
})

local addToggle = other2:AddToggle("无敌模式", {
  Text = "无敌模式",
  Default = false,
  Tooltip = "让你免疫伤害。",
})

local function f12(p15)
  local v174 = p15

  do
  end

  local v175 = v173[p15] or p15 == localPlayer

  if v175 then
    return
  else
    local v176

    v176 = {
      TopLeft = (Drawing.new("Line")),
      TopRight = (Drawing.new("Line")),
      BottomLeft = (Drawing.new("Line")),
      BottomRight = (Drawing.new("Line")),
      LeftTop = (Drawing.new("Line")),
      LeftBottom = (Drawing.new("Line")),
      RightTop = (Drawing.new("Line")),
      RightBottom = (Drawing.new("Line")),
    }

    for key5, value6 in pairs(v176) do
      value6.Visible = false
      value6.Color = Color3.fromRGB(37, 150, 190)
      value6.Thickness = 1
      value6.Transparency = 1
    end

    v173[p15] = v176
    return
  end
end

local function f13()
  do
  end

  local puzzle = workspace:FindFirstChild("Puzzle")
  local puzzles = puzzle
  local v178, v179, v180

  if puzzle then
    do
    end

    puzzles = workspace.Puzzle:FindFirstChild("Puzzles")
  end

  local v181 = puzzles

  if not v181 then
    return
  else
    for index2, value7 in ipairs(v181:GetChildren()) do
      if (value7:IsA("Model")) then
        for index3, value8 in ipairs(value7:GetDescendants()) do
          do
          end

          do
          end

          if (value8:IsA("BasePart")) and not v177[value8] then
            local highlight
            highlight = Instance.new("Highlight")
            highlight.Parent = value8
            highlight.Adornee = value8
            highlight.FillTransparency = 0.2
            highlight.FillColor = Color3.new(1, 1, 0)
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.new(1, 1, 0)
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = enabled

            v177[value8] = highlight
          end
        end
      end
    end

    return
  end
end

do
  local connect3

  addToggle:OnChanged(function(p16)
    local v182 = p16
    local v183, v184, v185, v186, v187, localPlayer4, healthValue

    if p16 then
      localPlayer4 = game.Players.LocalPlayer

      do
      end

      do
      end

      healthValue = ((workspace:WaitForChild(localPlayer4.Name)):WaitForChild("HealthValue"))

      do
      end

      do
      end

      connect3 = ((game:GetService("RunService")).Heartbeat:Connect(function()
        local v188, v189, v190

        if healthValue.Value < 100 then
          do
          end

          local replicatedStorage2
          replicatedStorage2 = game:GetService("ReplicatedStorage")

          do
          end

          do
          end

          ;((replicatedStorage2:WaitForChild("活动")):WaitForChild("VestEvent")):FireServer(localPlayer4)
        end

        return
      end))

      local v191
      v191 = library

      library:Notify("无敌模式已开启！", 1.5)
    else
      if connect3 then
        do
        end

        connect3:Disconnect()
        connect3 = nil
      end

      local v192
      v192 = library

      library:Notify("无敌模式已关闭！", 1.5)
    end

    return
  end)

  other2:AddButton("结束本局", {
    Text = "结束本局",
    Func = function()
      do
      end

      local replicatedStorage3 = game:GetService("ReplicatedStorage")

      local addDeath = replicatedStorage3:WaitForChild("AddDeath")
      addDeath:FireServer()

      local v193 = library
      library:Notify("本局已结束", 1.5)
      return
    end,
    Tooltip = "立即结束当前回合。",
  })

  do
  end
end

local npcESP = v64.Visuals:AddLeftTabbox("NPC透视")

do
end

local itemESP = v64.Visuals:AddRightTabbox("物品透视")
local visuals3 = v64.Visuals

local function f14(p17)
  local v196 = p17

  do
  end

  local v197 = not v194[p17] and v195
  local v198, v199

  if v197 then
    local billboardGui
    billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 20)

    local humanoidRootPart6
    humanoidRootPart6 = p17:FindFirstChild("HumanoidRootPart")

    local head
    head = humanoidRootPart6

    if not humanoidRootPart6 then
      do
      end

      do
      end

      head = (p17:FindFirstChild("Head")) or p17.PrimaryPart
    end

    billboardGui.Adornee = head
    billboardGui.AlwaysOnTop = true
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.Parent = p17

    local textLabel
    textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = p17.Name
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = false
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboardGui

    v194[p17] = billboardGui
  end

  return
end

local playerESP = visuals3:AddLeftTabbox("Player ESP")

local function f15(p18)
  local v202 = p18
  local v203 = not v200[p18]
  local v204 = v203
  local v205, v206, v207

  if v203 then
    local v208
    v208 = v201

    local character7
    character7 = v208

    if v208 then
      do
      end

      do
      end

      character7 = p18.Character and p18 ~= localPlayer
    end

    v204 = character7
  end

  local billboardGui2, textLabel2

  if v204 then
    do
    end

    local humanoidRootPart7
    humanoidRootPart7 = p18.Character:FindFirstChild("HumanoidRootPart")

    if not humanoidRootPart7 then
      return
    else
      billboardGui2 = Instance.new("BillboardGui")
      billboardGui2.Size = UDim2.new(0, 100, 0, 20)
      billboardGui2.Adornee = humanoidRootPart7
      billboardGui2.AlwaysOnTop = true
      billboardGui2.StudsOffset = Vector3.new(0, 3, 0)
      billboardGui2.Parent = p18.Character

      textLabel2 = Instance.new("TextLabel")
      textLabel2.Size = UDim2.new(1, 0, 1, 0)
      textLabel2.BackgroundTransparency = 1
      textLabel2.Text = p18.Name
      textLabel2.TextColor3 = Color3.fromRGB(37, 150, 190)
      textLabel2.TextStrokeTransparency = 0
      textLabel2.TextScaled = false
      textLabel2.TextSize = 14
      textLabel2.Font = Enum.Font.SourceSansBold
      textLabel2.Parent = billboardGui2

      v200[p18] = billboardGui2
      ::L16376218::
      return
    end
  else
    goto L16376218
  end
end

npCs = npcESP:AddTab("NPC")
items = itemESP:AddTab("物品")
players2 = playerESP:AddTab("玩家")

do
end

npcs = game.Workspace:WaitForChild("NPCS")

local function f16(p19)
  local v211 = p19

  do
  end

  local v212 = not v210[p19] and v209
  local billboardGui3, textLabel3

  if v212 then
    local primaryPart
    primaryPart = p19:FindFirstChild("PrimaryPart")

    local basePart
    basePart = primaryPart

    if not primaryPart then
      local handle
      handle = p19:FindFirstChild("Handle")

      local v213
      v213 = handle

      do
      end

      basePart = handle or p19:FindFirstChildWhichIsA("BasePart")
    end

    local v214
    v214 = basePart

    if not v214 then
      return
    else
      billboardGui3 = Instance.new("BillboardGui")
      billboardGui3.Size = UDim2.new(0, 100, 0, 20)
      billboardGui3.Adornee = v214
      billboardGui3.AlwaysOnTop = true
      billboardGui3.StudsOffset = Vector3.new(0, 3, 0)
      billboardGui3.Parent = p19

      textLabel3 = Instance.new("TextLabel")
      textLabel3.Size = UDim2.new(1, 0, 1, 0)
      textLabel3.BackgroundTransparency = 1
      textLabel3.Text = p19.Name
      textLabel3.TextColor3 = Color3.fromRGB(255, 255, 0)
      textLabel3.TextStrokeTransparency = 0
      textLabel3.TextScaled = false
      textLabel3.TextSize = 14
      textLabel3.Font = Enum.Font.SourceSansBold
      textLabel3.Parent = billboardGui3

      v210[p19] = billboardGui3
      ::L13267526::
      return
    end
  else
    goto L13267526
  end
end

local v215 = npcs
local currentCamera2 = workspace.CurrentCamera
v216 = false

local function f17(p20)
  local v218 = p20

  if v217[p20] then
    return
  else
    local v219

    v219 = {
      TopLeft = (Drawing.new("Line")),
      TopRight = (Drawing.new("Line")),
      BottomLeft = (Drawing.new("Line")),
      BottomRight = (Drawing.new("Line")),
      LeftTop = (Drawing.new("Line")),
      LeftBottom = (Drawing.new("Line")),
      RightTop = (Drawing.new("Line")),
      RightBottom = (Drawing.new("Line")),
    }

    for key6, value9 in pairs(v219) do
      value9.Visible = false
      value9.Color = Color3.fromRGB(255, 0, 0)
      value9.Thickness = 1
      value9.Transparency = 1
    end

    v217[p20] = v219
    return
  end
end

local function f18()
  local v220, v221

  for key7, value10 in pairs(v217) do
    local parent
    parent = key7.Parent

    local v222
    v222 = parent

    do
    end

    if parent and key7:FindFirstChild("HumanoidRootPart") then
      local humanoidRootPart8
      humanoidRootPart8 = key7.HumanoidRootPart

      local v223
      v223 = currentCamera2

      local v224, v225
      v225, v224 = currentCamera2:WorldToViewportPoint(humanoidRootPart8.Position)

      do
      end

      if v224 and v216 then
        local cframe
        cframe = humanoidRootPart8.CFrame

        local vector
        vector = Vector3.new(3, 6, 0)

        local cframe2
        cframe2 = CFrame.new(-vector.X / 2, vector.Y / 2, 0)

        local cframe3
        cframe3 = CFrame.new(vector.X / 2, vector.Y / 2, 0)

        local cframe4
        cframe4 = CFrame.new(-vector.X / 2, -vector.Y / 2, 0)

        local cframe5
        cframe5 = CFrame.new(vector.X / 2, -vector.Y / 2, 0)

        local v226
        v226 = currentCamera2

        local worldToViewportPoint
        worldToViewportPoint = currentCamera2:WorldToViewportPoint((cframe * cframe2).p)

        local v227
        v227 = currentCamera2

        local worldToViewportPoint2
        worldToViewportPoint2 = currentCamera2:WorldToViewportPoint((cframe * cframe3).p)

        local v228
        v228 = currentCamera2

        local worldToViewportPoint3
        worldToViewportPoint3 = currentCamera2:WorldToViewportPoint((cframe * cframe4).p)

        local v229
        v229 = currentCamera2

        local worldToViewportPoint4
        worldToViewportPoint4 = currentCamera2:WorldToViewportPoint((cframe * cframe5).p)

        local v230
        v230 = worldToViewportPoint

        if worldToViewportPoint then
          local v231
          v231 = worldToViewportPoint2

          if worldToViewportPoint2 then
            do
            end

            v231 = worldToViewportPoint3 and worldToViewportPoint4
          end

          v230 = v231
        end

        if v230 then
          value10.TopLeft.From = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
          value10.TopLeft.To = Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y)
          value10.TopRight.From = Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y)
          value10.TopRight.To = Vector2.new(worldToViewportPoint4.X, worldToViewportPoint4.Y)

          value10.BottomLeft.From = Vector2.new(
            worldToViewportPoint3.X, worldToViewportPoint3.Y
          )

          value10.BottomLeft.To = Vector2.new(worldToViewportPoint4.X, worldToViewportPoint4.Y)

          value10.BottomRight.From = Vector2.new(
            worldToViewportPoint4.X, worldToViewportPoint4.Y
          )

          value10.BottomRight.To = Vector2.new(worldToViewportPoint3.X, worldToViewportPoint3.Y)
          value10.LeftTop.From = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
          value10.LeftTop.To = Vector2.new(worldToViewportPoint3.X, worldToViewportPoint3.Y)

          value10.LeftBottom.From = Vector2.new(
            worldToViewportPoint3.X, worldToViewportPoint3.Y
          )

          value10.LeftBottom.To = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
          value10.RightTop.From = Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y)
          value10.RightTop.To = Vector2.new(worldToViewportPoint4.X, worldToViewportPoint4.Y)

          value10.RightBottom.From = Vector2.new(
            worldToViewportPoint4.X, worldToViewportPoint4.Y
          )

          value10.RightBottom.To = Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y)

          for key8, value11 in pairs(value10) do
            value11.Visible = true
          end
        end
      else
        for key9, value12 in pairs(value10) do
          value12.Visible = false
        end
      end
    else
      for key10, value13 in pairs(value10) do
        value13.Visible = false
      end
    end
  end

  return
end

do
  v217 = {}
  local v232 = f17
  local v233 = f18
  v234 = {}
end

local function f19()
  local v236, v237

  for key11, value14 in pairs(v168) do
    local character8
    character8 = key11.Character

    local humanoidRootPart9
    humanoidRootPart9 = character8

    if character8 then
      do
      end

      humanoidRootPart9 = key11.Character:FindFirstChild("HumanoidRootPart")
    end

    if humanoidRootPart9 then
      local v238
      v238 = currentCamera2

      local v239, v240
      v240, v239 = currentCamera2:WorldToViewportPoint(key11.Character.HumanoidRootPart.Position)

      do
      end

      if v239 and v235 then
        value14.From = Vector2.new(
          currentCamera2.ViewportSize.X / 2, currentCamera2.ViewportSize.Y
        )

        value14.To = Vector2.new(v240.X, v240.Y)
        value14.Visible = true
      else
        value14.Visible = false
      end
    else
      value14.Visible = false
    end
  end

  return
end

v241 = false

local function f20(p21)
  local v242 = p21

  if not v234[p21] then
    local line2
    line2 = Drawing.new("Line")
    line2.Thickness = 2
    line2.Color = Color3.fromRGB(255, 0, 0)
    line2.Transparency = 1
    line2.Visible = false

    v234[p21] = line2
  end

  return
end

local function f21()
  local v243

  for key12, value15 in pairs(v234) do
    local parent2
    parent2 = key12.Parent

    local v244
    v244 = parent2

    do
    end

    if parent2 and key12:FindFirstChild("HumanoidRootPart") then
      local v245
      v245 = currentCamera2

      local v246, v247
      v246, v247 = currentCamera2:WorldToViewportPoint(key12.HumanoidRootPart.Position)

      do
      end

      if v247 and v241 then
        value15.From = Vector2.new(
          currentCamera2.ViewportSize.X / 2, currentCamera2.ViewportSize.Y
        )

        value15.To = Vector2.new(v246.X, v246.Y)
        value15.Visible = true
      else
        value15.Visible = false
      end
    else
      value15.Visible = false
    end
  end

  return
end

do
  v194 = {}
  v195 = false

  local function f22()
    local v249, v250, v251

    for key13, value16 in pairs(v173) do
      local character9
      character9 = key13.Character

      local humanoidRootPart10
      humanoidRootPart10 = character9

      if character9 then
        do
        end

        humanoidRootPart10 = key13.Character:FindFirstChild("HumanoidRootPart")
      end

      if humanoidRootPart10 then
        local humanoidRootPart11
        humanoidRootPart11 = key13.Character.HumanoidRootPart

        local v252
        v252 = currentCamera2

        local v253, v254
        v253, v254 = currentCamera2:WorldToViewportPoint(humanoidRootPart11.Position)

        do
        end

        if v254 and v248 then
          local cframe6
          cframe6 = humanoidRootPart11.CFrame

          local vector2
          vector2 = Vector3.new(3, 6, 0)

          local cframe7
          cframe7 = CFrame.new(-vector2.X / 2, vector2.Y / 2, 0)

          local cframe8
          cframe8 = CFrame.new(vector2.X / 2, vector2.Y / 2, 0)

          local cframe9
          cframe9 = CFrame.new(-vector2.X / 2, -vector2.Y / 2, 0)

          local cframe10
          cframe10 = CFrame.new(vector2.X / 2, -vector2.Y / 2, 0)

          local v255
          v255 = currentCamera2

          local worldToViewportPoint5
          worldToViewportPoint5 = currentCamera2:WorldToViewportPoint((cframe6 * cframe7).p)

          local v256
          v256 = currentCamera2

          local worldToViewportPoint6
          worldToViewportPoint6 = currentCamera2:WorldToViewportPoint((cframe6 * cframe8).p)

          local v257
          v257 = currentCamera2

          local worldToViewportPoint7
          worldToViewportPoint7 = currentCamera2:WorldToViewportPoint((cframe6 * cframe9).p)

          local v258
          v258 = currentCamera2

          local worldToViewportPoint8
          worldToViewportPoint8 = currentCamera2:WorldToViewportPoint((cframe6 * cframe10).p)

          local v259
          v259 = worldToViewportPoint5

          if worldToViewportPoint5 then
            local v260
            v260 = worldToViewportPoint6

            if worldToViewportPoint6 then
              do
              end

              v260 = worldToViewportPoint7 and worldToViewportPoint8
            end

            v259 = v260
          end

          if v259 then
            value16.TopLeft.From = Vector2.new(worldToViewportPoint5.X, worldToViewportPoint5.Y)
            value16.TopLeft.To = Vector2.new(worldToViewportPoint6.X, worldToViewportPoint6.Y)

            value16.TopRight.From = Vector2.new(
              worldToViewportPoint6.X, worldToViewportPoint6.Y
            )

            value16.TopRight.To = Vector2.new(worldToViewportPoint8.X, worldToViewportPoint8.Y)

            value16.BottomLeft.From = Vector2.new(
              worldToViewportPoint7.X, worldToViewportPoint7.Y
            )

            value16.BottomLeft.To = Vector2.new(
              worldToViewportPoint8.X, worldToViewportPoint8.Y
            )

            value16.BottomRight.From = Vector2.new(
              worldToViewportPoint8.X, worldToViewportPoint8.Y
            )

            value16.BottomRight.To = Vector2.new(
              worldToViewportPoint7.X, worldToViewportPoint7.Y
            )

            value16.LeftTop.From = Vector2.new(worldToViewportPoint5.X, worldToViewportPoint5.Y)
            value16.LeftTop.To = Vector2.new(worldToViewportPoint7.X, worldToViewportPoint7.Y)

            value16.LeftBottom.From = Vector2.new(
              worldToViewportPoint7.X, worldToViewportPoint7.Y
            )

            value16.LeftBottom.To = Vector2.new(
              worldToViewportPoint5.X, worldToViewportPoint5.Y
            )

            value16.RightTop.From = Vector2.new(
              worldToViewportPoint6.X, worldToViewportPoint6.Y
            )

            value16.RightTop.To = Vector2.new(worldToViewportPoint8.X, worldToViewportPoint8.Y)

            value16.RightBottom.From = Vector2.new(
              worldToViewportPoint8.X, worldToViewportPoint8.Y
            )

            value16.RightBottom.To = Vector2.new(
              worldToViewportPoint6.X, worldToViewportPoint6.Y
            )

            for key14, value17 in pairs(value16) do
              value17.Visible = true
            end
          end
        else
          for key15, value18 in pairs(value16) do
            value18.Visible = false
          end
        end
      else
        for key16, value19 in pairs(value16) do
          value19.Visible = false
        end
      end
    end

    return
  end

  local v261 = f14
  v248 = false
  v173 = {}
  local v262 = f12
  local v263 = f22
  v168 = {}
  v235 = false
  local v264 = f11
  local v265 = f19
  v200 = {}
  v201 = false
  local v266 = f15
  enabled = false
  v177 = {}
  local v267 = f13
  v209 = false
  v210 = {}
  local v268 = f16

  do
  end

  do
  end

  ;(game:GetService("RunService")).RenderStepped:Connect(function()
    f18()
    f21()
    f22()
    f19()
    return
  end)
end

do
  do
  end

  npcs.ChildAdded:Connect(function(child)
    local v269 = child
    wait(0.5)
    f17(child)
    f20(child)
    f14(child)
    return
  end)

  do
  end

  npcs.ChildRemoved:Connect(function(child2)
    local v270 = child2
    local v271, v272

    if v217[child2] then
      for key17, value20 in pairs(v217[child2]) do
        value20:Remove()
      end

      v217[child2] = nil
    end

    if v234[child2] then
      do
      end

      v234[child2]:Remove()
      v234[child2] = nil
    end

    if v194[child2] then
      do
      end

      v194[child2]:Destroy()
      v194[child2] = nil
    end

    return
  end)

  do
  end

  players.PlayerAdded:Connect(function(player)
    local v273 = player
    local v274
    f12(player)
    f11(player)

    do
    end

    player.CharacterAdded:Connect(function(character10)
      wait(1)
      f15(player)
      return
    end)

    return
  end)

  do
  end

  players.PlayerRemoving:Connect(function(player2)
    local v275 = player2
    local v276, v277

    if v173[player2] then
      for key18, value21 in pairs(v173[player2]) do
        value21:Remove()
      end

      v173[player2] = nil
    end

    if v168[player2] then
      do
      end

      v168[player2]:Remove()
      v168[player2] = nil
    end

    if v200[player2] then
      do
      end

      v200[player2]:Destroy()
      v200[player2] = nil
    end

    return
  end)

  do
  end

  local puzzle2 = workspace:FindFirstChild("Puzzle")
  local puzzles2 = puzzle2

  if puzzle2 then
    do
    end

    puzzles2 = workspace.Puzzle:FindFirstChild("Puzzles")
  end

  local v278 = puzzles2

  if v278 then
    do
    end

    v278.ChildAdded:Connect(function(child3)
      wait(0.5)
      f13()
      f16(child3)
      return
    end)

    do
    end

    v278.ChildRemoved:Connect(function(child4)
      local v279 = child4
      local v280, v281

      if v177[child4] then
        do
        end

        v177[child4]:Destroy()
        v177[child4] = nil
      end

      if v210[child4] then
        do
        end

        v210[child4]:Destroy()
        v210[child4] = nil
      end

      return
    end)
  end

  local v282 = npcs

  for index4, value22 in ipairs(npcs:GetChildren()) do
    f17(value22)
    f20(value22)
    f14(value22)
  end

  local v283 = players

  for index5, value23 in ipairs(players:GetPlayers()) do
    if value23 ~= localPlayer then
      f12(value23)
      f11(value23)

      if value23.Character then
        f15(value23)
      end
    end
  end

  if v278 then
    f13()

    local v284
    v284 = v278

    for index6, value24 in ipairs(v278:GetChildren()) do
      f16(value24)
    end
  end

  do
  end

  ;(npCs:AddToggle("NPCESPEnabled", {
    Text = "透视",
    Default = false,
    Tooltip = "显示NPC方框，即使隔着墙也能看到。",
  })):OnChanged(function(p22)
    local v285 = p22
    local v286, v287
    v216 = p22

    if not p22 then
      for key19, value25 in pairs(v217) do
        for key20, value26 in pairs(value25) do
          value26.Visible = false
        end
      end
    end

    local v288 = library

    do
    end

    do
    end

    library:Notify(p22 and "NPC透视已开启" or "NPC透视已关闭", 1.5)
    return
  end)

  do
  end

  ;(npCs:AddToggle("NPCTracersEnabled", {
    Text = "追踪线",
    Default = false,
    Tooltip = "显示从屏幕中心指向NPC的连线。",
  })):OnChanged(function(p23)
    local v289 = p23
    local v290, v291
    v241 = p23

    if not p23 then
      for key21, value27 in pairs(v234) do
        value27.Visible = false
      end
    end

    local v292 = library

    do
    end

    do
    end

    library:Notify(p23 and "NPC追踪线已开启" or "NPC追踪线已关闭", 1.5)
    return
  end)

  do
  end

  ;(npCs:AddToggle("NPCNameTagsEnabled", {
    Text = "名称标签",
    Default = false,
    Tooltip = "显示NPC头顶名称。",
  })):OnChanged(function(p24)
    local v293 = p24
    local v294, v295, v296
    v195 = p24

    if p24 then
      local v297
      v297 = npcs

      for index7, value28 in ipairs(npcs:GetChildren()) do
        f14(value28)
      end
    else
      for key22, value29 in pairs(v194) do
        do
        end

        if value29 and value29.Parent then
          value29:Destroy()
        end
      end

      v194 = {}
    end

    local v298 = library

    do
    end

    do
    end

    library:Notify(p24 and "NPC名称标签已开启" or "NPC名称标签已关闭", 1.5)
    return
  end)

  do
  end

  ;(players2:AddToggle("PlayerESPEnabled", {
    Text = "透视",
    Default = false,
    Tooltip = "显示其他玩家方框，即使隔着墙也能看到。",
  })):OnChanged(function(p25)
    local v299 = p25
    local v300, v301
    v248 = p25

    if not p25 then
      for key23, value30 in pairs(v173) do
        for key24, value31 in pairs(value30) do
          value31.Visible = false
        end
      end
    end

    local v302 = library

    do
    end

    do
    end

    library:Notify(p25 and "玩家透视已开启" or "玩家透视已关闭", 1.5)
    return
  end)

  do
  end

  ;(players2:AddToggle("PlayerTracersEnabled", {
    Text = "追踪线",
    Default = false,
    Tooltip = "显示从屏幕中心指向其他玩家的连线。",
  })):OnChanged(function(p26)
    local v303 = p26
    local v304, v305
    v235 = p26

    if not p26 then
      for key25, value32 in pairs(v168) do
        value32.Visible = false
      end
    end

    local v306 = library

    do
    end

    do
    end

    library:Notify(p26 and "玩家追踪线已开启" or "玩家追踪线已关闭", 1.5)
    return
  end)

  do
  end

  ;(players2:AddToggle("PlayerNameTagsEnabled", {
    Text = "名称标签",
    Default = false,
    Tooltip = "显示其他玩家名称。",
  })):OnChanged(function(p27)
    local v307 = p27
    local v308, v309, v310
    v201 = p27

    if p27 then
      local v311
      v311 = players

      for index8, value33 in ipairs(players:GetPlayers()) do
        if value33 ~= localPlayer then
          f15(value33)
        end
      end
    else
      for key26, value34 in pairs(v200) do
        do
        end

        if value34 and value34.Parent then
          value34:Destroy()
        end
      end

      v200 = {}
    end

    local v312 = library

    do
    end

    do
    end

    library:Notify(p27 and "玩家名称标签已开启" or "玩家名称标签已关闭", 1.5)
    return
  end)

  do
  end

  ;(items:AddToggle("ItemESPEnabled", {
    Text = "高亮物品",
    Default = false,
    Tooltip = "用黄色光效高亮谜题物品。",
  })):OnChanged(function(p28)
    local v313 = p28
    local v314, v315, v316
    enabled = p28

    for key27, value35 in pairs(v177) do
      if value35 then
        value35.Enabled = p28
      end
    end

    do
    end

    if p28 and not (next(v177)) then
      f13()
    end

    local v317 = library

    do
    end

    do
    end

    library:Notify(p28 and "物品透视已开启" or "物品透视已关闭", 1.5)
    return
  end)

  do
  end

  ;(items:AddToggle("ItemNameTagsEnabled", {
    Text = "物品名称标签",
    Default = false,
    Tooltip = "显示谜题物品名称。",
  })):OnChanged(function(p29)
    local v318 = p29
    local v319, v320, v321
    v209 = p29

    if p29 then
      if v278 then
        local v322
        v322 = v278

        for index9, value36 in ipairs(v278:GetChildren()) do
          f16(value36)
        end
      end
    else
      for key28, value37 in pairs(v210) do
        do
        end

        if value37 and value37.Parent then
          value37:Destroy()
        end
      end

      v210 = {}
    end

    local v323 = library

    do
    end

    do
    end

    library:Notify(p29 and "物品名称标签已开启" or "物品名称标签已关闭", 1.5)
    return
  end)
end

do
  do
  end

  local basicSuits = v64.Suits:AddLeftTabbox("Basic Suits")

  do
  end

  local specialSuits = v64.Suits:AddRightTabbox("Special Suits")

  do
  end

  local characterSuits = v64.Suits:AddLeftTabbox("Character Suits")

  do
  end

  local rankSuits = v64.Suits:AddRightTabbox("Rank Suits")
  local basic = basicSuits:AddTab("基础")
  local special = specialSuits:AddTab("特殊")
  local characters = characterSuits:AddTab("角色")
  local rank = rankSuits:AddTab("等级")

  do
  end

  replicatedStorage4 = (game:GetService("ReplicatedStorage"))
  local v324 = replicatedStorage4
  events = (replicatedStorage4:WaitForChild("活动"))
  local v325 = events
  suits = (events:WaitForChild("服装"))
  localPlayer5 = game.Players.LocalPlayer

  v326 = {
    { "Yellow", "YellowSuitEvent", "Basic yellow colored suit" },
    { "Orange", "OrangeSuitEvent", "Basic orange colored suit" },
    { "Red", "RedSuitEvent", "Basic red colored suit" },
    { "Blue", "BlueSuitEvent", "Basic blue colored suit" },
    { "White", "WhiteSuitEvent", "Basic white colored suit" },
    { "Black", "BlackSuitEvent", "Basic black colored suit" },
    { "Green", "GreenSuitEvent", "Basic green colored suit" },
    { "Purple", "PurpleSuitEvent", "Basic purple colored suit" },
  }

  v327 = {
    { "相机", "CameraSuitEvent", "Camera-themed suit" },
    { "Speaker", "SpeakerSuitEvent", "Speaker-themed suit" },
    { "TV", "TVSuitEvent", "TV-themed suit" },
    { "Fancy", "FancySuitEvent", "Elegant fancy suit" },
    { "Invincible", "InvincibleSuitEvent", "Invincibility-themed suit" },
    { "SCP", "SCPSuitEvent", "SCP-themed suit" },
    { "Pilot", "PilotSuitEvent", "Pilot uniform" },
    { "Police", "PoliceSuitEvent", "Police officer uniform" },
    { "Ginger", "GingerbreadmanSuitEvent", "Gingerbread man costume" },
    { "Santa", "SantaSuitEvent", "Santa Claus suit" },
    { "Snowman", "SnowmanSuitEvent", "Snowman costume" },
  }

  v328 = {
    { "Prisoner", "PrisonerSuitEvent", "Prisoner outfit" },
    { "Astronaut", "AstronautSuitEvent", "Astronaut space suit" },
    { "Lethal", "LethalSuitEvent", "Lethal company themed suit" },
    { "Skeleton", "SkeletonSuitEvent", "Skeleton costume" },
    { "Sukuna", "SukunaSuitEvent", "Sukuna character suit" },
    { "Gojo", "GojoSuitEvent", "Gojo character suit" },
  }

  v329 = {
    { "Bronze", "BronzeSuitEvent", "Bronze rank suit" },
    { "Silver", "SilverSuitEvent", "Silver rank suit" },
    { "Diamond", "DiamondSuitEvent", "Diamond rank suit" },
    { "Ruby", "RubySuitEvent", "Ruby rank suit" },
    { "Sketch", "SketchSuitEvent", "Sketch rank suit" },
  }

  for index10, value38 in ipairs(v326) do
    local v330
    v330 = value38[2]

    local tooltip
    tooltip = value38[3]

    local v331 = value38[1]
    local v332 = v330

    basic:AddButton(v331, {
      Text = v331,
      Func = function()
        local v333 = { localPlayer5 }
        local v334 = suits
        local findFirstChild = suits:FindFirstChild(v332)

        if findFirstChild then
          findFirstChild:FireServer(unpack(v333))

          local v335
          v335 = library

          library:Notify("已装备：" .. v331, 1.5)
        end

        return
      end,
      Tooltip = tooltip,
    })
  end

  for index11, value39 in ipairs(v327) do
    local v336
    v336 = value39[2]

    local tooltip2
    tooltip2 = value39[3]

    local v337 = value39[1]
    local v338 = v336

    special:AddButton(v337, {
      Text = v337,
      Func = function()
        local v339 = { localPlayer5 }
        local v340 = suits
        local findFirstChild2 = suits:FindFirstChild(v338)

        if findFirstChild2 then
          findFirstChild2:FireServer(unpack(v339))

          local v341
          v341 = library

          library:Notify("已装备：" .. v337, 1.5)
        end

        return
      end,
      Tooltip = tooltip2,
    })
  end

  for index12, value40 in ipairs(v328) do
    local v342
    v342 = value40[2]

    local tooltip3
    tooltip3 = value40[3]

    local v343 = value40[1]
    local v344 = v342

    characters:AddButton(v343, {
      Text = v343,
      Func = function()
        local v345 = { localPlayer5 }
        local v346 = suits
        local findFirstChild3 = suits:FindFirstChild(v344)

        if findFirstChild3 then
          findFirstChild3:FireServer(unpack(v345))

          local v347
          v347 = library

          library:Notify("已装备：" .. v343, 1.5)
        end

        return
      end,
      Tooltip = tooltip3,
    })
  end

  for index13, value41 in ipairs(v329) do
    local v348
    v348 = value41[2]

    local tooltip4
    tooltip4 = value41[3]

    local v349 = value41[1]
    local v350 = v348

    rank:AddButton(v349, {
      Text = v349,
      Func = function()
        local v351 = suits
        local findFirstChild4 = suits:FindFirstChild(v350)

        if findFirstChild4 then
          findFirstChild4:FireServer()

          local v352
          v352 = library

          library:Notify("已装备：" .. v349, 1.5)
        end

        return
      end,
      Tooltip = tooltip4,
    })
  end
end

do
  do
  end

  local basicHats = v64.Hats:AddLeftTabbox("Basic Hats")

  do
  end

  local eventHats = v64.Hats:AddRightTabbox("Event Hats")

  do
  end

  local specialHats = v64.Hats:AddLeftTabbox("Special Hats")

  do
  end

  local rankHats = v64.Hats:AddRightTabbox("Rank Hats")

  do
  end

  local newHats = v64.Hats:AddRightTabbox("New Hats")
  local basic2 = basicHats:AddTab("基础")
  local events2 = eventHats:AddTab("活动")
  local special2 = specialHats:AddTab("特殊")
  local rank2 = rankHats:AddTab("等级")
  local new = newHats:AddTab("最新")
  local v353 = events
  hats = (events:WaitForChild("帽子"))

  v354 = {
    { "Red Fedora", "RedFedoraEvent", "Classic red fedora hat" },
    { "Cone", "ConeEvent", "Traffic cone hat" },
    { "Tin Pot", "TinPotHatEvent", "Tin pot helmet" },
    { "Burger", "BurgerHatEvent", "Burger hat" },
    { "Backwards", "BackwardsHatEvent", "Backwards cap" },
    { "Large Top Hat", "LargeTopHatEvent", "Large formal top hat" },
  }

  v355 = {
    { "Partygoer Mask", "PartygoerMaskEvent", "Partygoer entity mask" },
    { "PartyPooper Mask", "PartyPooperMaskEvent", "PartyPooper entity mask" },
    { "Kid", "KidHatEvent", "Kid character hat" },
    { "Sleepy", "SleepyHatEvent", "Sleepy themed hat" },
    { "Bear Trap", "BearTrapHatEvent", "Bear trap headgear" },
    { "Plunger", "PlungerHatEvent", "Plunger hat" },
  }

  v356 = {
    { "Jack O Lantern", "JackOLanternHatEvent", "Halloween pumpkin hat" },
    { "Scarecrow", "ScarecrowHatEvent", "Scarecrow hat" },
    { "Wendigo", "WendigoHatEvent", "Wendigo creature hat" },
    { "Summer Towel", "Summer_TowelEvent", "Summer beach towel" },
    { "Summer Snorkel", "Summer_SnorkelEvent", "Summer snorkel gear" },
    { "Summer Duck", "Summer_DuckEvent", "Summer duck floatie" },
    { "Santa", "SantaHatEvent", "Santa Claus hat" },
    { "Egg Head", "EggHeadEvent", "Egg head costume" },
    { "Patrick", "PatrickHatEvent", "Patrick Star hat" },
  }

  v357 = {
    { "Golden Cone", "GoldenConeEvent", "Golden traffic cone" },
    { "Gold Fedora", "GoldFedoraEvent", "Golden fedora hat" },
    { "Golden Shades", "GoldenShadesHatEvent", "Golden sunglasses" },
  }

  v358 = {
    { "Moai Hat", "MoaiHatEvent", "Moai statue hat" },
    { "Cat Ears Headphones", "CatHeadphonesHatEvent", "Cat ears with headphones" },
    { "Turkey Hat", "TurkeyHatEvent", "Turkey themed hat" },
  }

  for index14, value42 in ipairs(v354) do
    local v359
    v359 = value42[2]

    local tooltip5
    tooltip5 = value42[3]

    local v360 = value42[1]
    local v361 = v359

    basic2:AddButton(v360, {
      Text = v360,
      Func = function()
        local v362 = { localPlayer5 }
        local v363 = hats
        local findFirstChild5 = hats:FindFirstChild(v361)

        if findFirstChild5 then
          findFirstChild5:FireServer(unpack(v362))

          local v364
          v364 = library

          library:Notify("已装备：" .. v360, 1.5)
        end

        return
      end,
      Tooltip = tooltip5,
    })
  end

  for index15, value43 in ipairs(v355) do
    local v365
    v365 = value43[2]

    local tooltip6
    tooltip6 = value43[3]

    local v366 = value43[1]
    local v367 = v365

    events2:AddButton(v366, {
      Text = v366,
      Func = function()
        local v368 = { localPlayer5 }
        local v369 = hats
        local findFirstChild6 = hats:FindFirstChild(v367)

        if findFirstChild6 then
          findFirstChild6:FireServer(unpack(v368))

          local v370
          v370 = library

          library:Notify("已装备：" .. v366, 1.5)
        end

        return
      end,
      Tooltip = tooltip6,
    })
  end

  for index16, value44 in ipairs(v356) do
    local v371
    v371 = value44[2]

    local tooltip7
    tooltip7 = value44[3]

    local v372 = value44[1]
    local v373 = v371

    special2:AddButton(v372, {
      Text = v372,
      Func = function()
        local v374 = { localPlayer5 }
        local v375 = v373 == "Summer_TowelEvent"
        local v376 = v375
        local v377, v378, v379, v380

        if not v375 then
          do
          end

          do
          end

          v376 = v373 == "Summer_SnorkelEvent" or v373 == "Summer_DuckEvent"
        end

        if v376 then
          local v381
          v381 = hats

          local summer
          summer = hats:WaitForChild("Summer")

          if summer then
            local findFirstChild7
            findFirstChild7 = summer:FindFirstChild(v373)

            if findFirstChild7 then
              findFirstChild7:FireServer(unpack(v374))

              local v382
              v382 = library

              library:Notify("已装备：" .. v372, 1.5)
            end
          end
        else
          local v383
          v383 = v373 == "JackOLanternHatEvent"

          local v384
          v384 = v383

          if not v383 then
            do
            end

            do
            end

            v384 = v373 == "ScarecrowHatEvent" or v373 == "WendigoHatEvent"
          end

          if v384 then
            local v385
            v385 = hats

            local halloween
            halloween = hats:WaitForChild("Halloween")

            if halloween then
              local findFirstChild8
              findFirstChild8 = halloween:FindFirstChild(v373)

              if findFirstChild8 then
                findFirstChild8:FireServer(unpack(v374))

                local v386
                v386 = library

                library:Notify("已装备：" .. v372, 1.5)
              end
            end
          else
            local v387
            v387 = hats

            local findFirstChild9
            findFirstChild9 = hats:FindFirstChild(v373)

            if findFirstChild9 then
              findFirstChild9:FireServer(unpack(v374))

              local v388
              v388 = library

              library:Notify("已装备：" .. v372, 1.5)
            end
          end
        end

        return
      end,
      Tooltip = tooltip7,
    })
  end

  for index17, value45 in ipairs(v357) do
    local v389
    v389 = value45[2]

    local tooltip8
    tooltip8 = value45[3]

    local v390 = value45[1]
    local v391 = v389

    rank2:AddButton(v390, {
      Text = v390,
      Func = function()
        local v392 = hats
        local findFirstChild10 = hats:FindFirstChild(v391)

        if findFirstChild10 then
          findFirstChild10:FireServer()

          local v393
          v393 = library

          library:Notify("已装备：" .. v390, 1.5)
        end

        return
      end,
      Tooltip = tooltip8,
    })
  end

  for index18, value46 in ipairs(v358) do
    local v394
    v394 = value46[2]

    local tooltip9
    tooltip9 = value46[3]

    local v395 = value46[1]
    local v396 = v394

    new:AddButton(v395, {
      Text = v395,
      Func = function()
        local v397 = { localPlayer5 }
        local v398 = hats
        local findFirstChild11 = hats:FindFirstChild(v396)

        if findFirstChild11 then
          findFirstChild11:FireServer(unpack(v397))

          local v399
          v399 = library

          library:Notify("已装备：" .. v395, 1.5)
        end

        return
      end,
      Tooltip = tooltip9,
    })
  end
end

do
  do
  end

  local utilityItems = v64.Items:AddLeftTabbox("Utility Items")

  do
  end

  local equipmentItems = v64.Items:AddRightTabbox("Equipment Items")
  local utility = utilityItems:AddTab("实用")
  local equipment = equipmentItems:AddTab("装备")

  local v400 = {
    { "Green Flash", "GreenFlashEvent", "Green flashlight" },
    { "UV Flash", "UVFlashEvent", "UV flashlight" },
    { "Night Vision", "NightVisionEvent", "Night vision goggles" },
    { "Vest", "VestEvent", "Protective vest" },
    { "医疗包", "MedkitEvent", "Medical kit for healing" },
    { "Speed Coil", "SpeedCoilEvent", "Increases movement speed" },
    { "Watch", "WatchEvent", "Time telling watch" },
    { "无线电", "RadioEvent", "Communication radio" },
  }

  local v401 = {
    { "指南针", "CompassEvent", "Navigation compass" },
    { "Ping", "pingEvent", "Ping location marker" },
    { "Bear Trap", "BearTrapEvent", "Bear trap item" },
    { "相机", "CameraItemEvent", "Camera equipment" },
    { "扳手", "WrenchItemEvent", "Wrench tool" },
    { "Entity Tracker", "EntityTrackerItemEvent", "Tracks entity locations" },
    { "Bandages", "BandagesItemEvent", "Bandages for healing" },
    { "Candy Basket", "CandyBasketItemEvent", "Candy collection basket" },
  }

  for index19, value47 in ipairs(v400) do
    local v402
    v402 = value47[2]

    local tooltip10
    tooltip10 = value47[3]

    local v403 = value47[1]
    local v404 = v402

    utility:AddButton(v403, {
      Text = v403,
      Func = function()
        local v405 = { localPlayer5 }
        local v406 = events
        local findFirstChild12 = events:FindFirstChild(v404)

        if findFirstChild12 then
          findFirstChild12:FireServer(unpack(v405))

          local v407
          v407 = library

          library:Notify("已装备：" .. v403, 1.5)
        end

        return
      end,
      Tooltip = tooltip10,
    })
  end

  for index20, value48 in ipairs(v401) do
    local v408
    v408 = value48[2]

    local tooltip11
    tooltip11 = value48[3]

    local v409 = value48[1]
    local v410 = v408

    equipment:AddButton(v409, {
      Text = v409,
      Func = function()
        local v411 = { localPlayer5 }
        local v412 = events
        local findFirstChild13 = events:FindFirstChild(v410)

        if findFirstChild13 then
          findFirstChild13:FireServer(unpack(v411))

          local v413
          v413 = library

          library:Notify("已装备：" .. v409, 1.5)
        end

        return
      end,
      Tooltip = tooltip11,
    })
  end

  do
  end

  do
  end

  local locations = (v64.Endings:AddLeftTabbox("传送")):AddTab("地点")

  do
  end

  local teleportService = (game:GetService("TeleportService"))
  localPlayer6 = players.LocalPlayer

  for index21, value49 in ipairs({
    { Text = "主游戏", PlaceId = 99078474560152, Tooltip = "传送到主游戏区域" },
    { Text = "结局1", PlaceId = 93228425740454, Tooltip = "传送到结局1区域" },
  }) do
    local v414 = value49

    locations:AddButton(v414.Text, {
      Text = v414.Text,
      Func = function()
        local v415 = teleportService
        teleportService:Teleport(v414.PlaceId, localPlayer6)
        local v416 = library
        library:Notify("正在传送到：" .. v414.Text, 1.5)
        return
      end,
      Tooltip = v414.Tooltip,
    })
  end

  do
  end

  local moneySpam = v64.Premium:AddLeftTabbox("Money & Spam")

  do
  end

  local itemControl = v64.Premium:AddRightTabbox("Item Control")
  local currency = moneySpam:AddTab("货币")
  local lagMethods = moneySpam:AddTab("卡顿方式")
  local spawnItems = itemControl:AddTab("生成物品")
  local emotes = itemControl:AddTab("动作")

  do
  end

  local value50, connect4

  ;(currency:AddToggle("InfiniteMoneyToggle", {
    Text = "无限金钱",
    Default = false,
    Tooltip = "获得无限金钱。",
  })):OnChanged(function(p30)
    local v417 = p30
    local v418 = localPlayer6
    local leaderstats = localPlayer6:WaitForChild("leaderstats")
    local v419, v420, v421, v422, money

    if leaderstats then
      money = (leaderstats:WaitForChild("Money"))

      if money then
        if p30 then
          value50 = money.Value

          do
          end

          do
          end

          connect4 = ((game:GetService("RunService")).Heartbeat:Connect(function()
            local v423
            money.Value = 999999999

            do
            end

            local playerValues = game.ReplicatedStorage:WaitForChild("PlayerValues")

            if playerValues then
              local money2
              money2 = playerValues:WaitForChild("Money")

              if money2 then
                money2.Value = 999999999
              end
            end

            return
          end))

          local v424
          v424 = library

          library:Notify("无限金钱已开启！", 1.5)
        else
          if connect4 then
            do
            end

            connect4:Disconnect()
            connect4 = nil
          end

          if value50 ~= nil then
            money.Value = value50

            do
            end

            local playerValues2
            playerValues2 = game.ReplicatedStorage:WaitForChild("PlayerValues")

            if playerValues2 then
              local money3
              money3 = playerValues2:WaitForChild("Money")

              if money3 then
                money3.Value = value50
              end
            end
          end

          local v425
          v425 = library

          library:Notify("无限金钱已关闭！", 1.5)
        end
      end
    end

    return
  end)

  currency:AddButton("全部解锁", {
    Text = "全部解锁",
    Func = function()
      local localPlayer7 = game.Players.LocalPlayer
      local v426 = { localPlayer7 }
      local v427, v428, v429, v430

      for index22, value51 in ipairs(v326) do
        local v431
        v431 = suits

        local findFirstChild14
        findFirstChild14 = suits:FindFirstChild(value51[2])

        if findFirstChild14 then
          findFirstChild14:FireServer(unpack(v426))
        end
      end

      for index23, value52 in ipairs(v327) do
        local v432
        v432 = suits

        local findFirstChild15
        findFirstChild15 = suits:FindFirstChild(value52[2])

        if findFirstChild15 then
          findFirstChild15:FireServer(unpack(v426))
        end
      end

      for index24, value53 in ipairs(v328) do
        local v433
        v433 = suits

        local findFirstChild16
        findFirstChild16 = suits:FindFirstChild(value53[2])

        if findFirstChild16 then
          findFirstChild16:FireServer(unpack(v426))
        end
      end

      for index25, value54 in ipairs(v329) do
        local v434
        v434 = suits

        local findFirstChild17
        findFirstChild17 = suits:FindFirstChild(value54[2])

        if findFirstChild17 then
          findFirstChild17:FireServer()
        end
      end

      for index26, value55 in ipairs(v354) do
        local v435
        v435 = hats

        local findFirstChild18
        findFirstChild18 = hats:FindFirstChild(value55[2])

        if findFirstChild18 then
          findFirstChild18:FireServer(unpack(v426))
        end
      end

      for index27, value56 in ipairs(v355) do
        local v436
        v436 = hats

        local findFirstChild19
        findFirstChild19 = hats:FindFirstChild(value56[2])

        if findFirstChild19 then
          findFirstChild19:FireServer(unpack(v426))
        end
      end

      for index28, value57 in ipairs(v356) do
        local v437
        v437 = value57[2]

        local v438
        v438 = v437 == "Summer_TowelEvent"

        local v439
        v439 = v438

        if not v438 then
          do
          end

          do
          end

          v439 = v437 == "Summer_SnorkelEvent" or v437 == "Summer_DuckEvent"
        end

        if v439 then
          local v440
          v440 = hats

          local summer2
          summer2 = hats:WaitForChild("Summer")

          if summer2 then
            local findFirstChild20
            findFirstChild20 = summer2:FindFirstChild(v437)

            if findFirstChild20 then
              findFirstChild20:FireServer(unpack(v426))
            end
          end
        else
          local v441
          v441 = v437 == "JackOLanternHatEvent"

          local v442
          v442 = v441

          if not v441 then
            do
            end

            do
            end

            v442 = v437 == "ScarecrowHatEvent" or v437 == "WendigoHatEvent"
          end

          if v442 then
            local v443
            v443 = hats

            local halloween2
            halloween2 = hats:WaitForChild("Halloween")

            if halloween2 then
              local findFirstChild21
              findFirstChild21 = halloween2:FindFirstChild(v437)

              if findFirstChild21 then
                findFirstChild21:FireServer(unpack(v426))
              end
            end
          else
            local v444
            v444 = hats

            local findFirstChild22
            findFirstChild22 = hats:FindFirstChild(v437)

            if findFirstChild22 then
              findFirstChild22:FireServer(unpack(v426))
            end
          end
        end
      end

      for index29, value58 in ipairs(v357) do
        local v445
        v445 = hats

        local findFirstChild23
        findFirstChild23 = hats:FindFirstChild(value58[2])

        if findFirstChild23 then
          findFirstChild23:FireServer()
        end
      end

      for index30, value59 in ipairs(v358) do
        local v446
        v446 = hats

        local findFirstChild24
        findFirstChild24 = hats:FindFirstChild(value59[2])

        if findFirstChild24 then
          findFirstChild24:FireServer(unpack(v426))
        end
      end

      for index31, value60 in ipairs(v400) do
        local v447
        v447 = events

        local findFirstChild25
        findFirstChild25 = events:FindFirstChild(value60[2])

        if findFirstChild25 then
          findFirstChild25:FireServer(localPlayer7)
        end
      end

      for index32, value61 in ipairs(v401) do
        local v448
        v448 = events

        local findFirstChild26
        findFirstChild26 = events:FindFirstChild(value61[2])

        if findFirstChild26 then
          findFirstChild26:FireServer(localPlayer7)
        end
      end

      local v449 = library
      library:Notify("全部物品已解锁！", 1.5)
      return
    end,
    Tooltip = "解锁游戏中的全部内容。",
  })

  local v450 = "尸体"
  local v451 = false

  do
  end

  ;(lagMethods:AddDropdown("LagMethod", {
    Text = "卡顿方式",
    Default = "尸体",
    Values = { "尸体", "生成陷阱" },
    Tooltip = "Select which method to use for lagging the game",
  })):OnChanged(function(p31)
    v450 = p31
    return
  end)

  do
  end

  ;(lagMethods:AddToggle("LagToggle", {
    Text = "开始卡顿",
    Default = false,
    Tooltip = "启用所选卡顿方式。",
  })):OnChanged(function(p32)
    v451 = p32

    if v451 then
      if v450 == "尸体" then
        task.spawn(function()
          local v452

          while v451 do
            if game.Players.LocalPlayer.Character then
              do
              end

              local deathEvent
              deathEvent = game.Players.LocalPlayer.Character:FindFirstChild("DeathEvent")

              if deathEvent then
                deathEvent:FireServer()
              end
            end

            task.wait()
          end

          return
        end)

        local v453
        v453 = library

        library:Notify("尸体生成已开启", 1.5)
      else
        if v450 == "生成陷阱" then
          task.spawn(function()
            local v454, v455, v456, v457, v458, v459, v460

            while v451 do
              do
              end

              game.ReplicatedStorage.Events.BearTrapEvent:FireServer()

              do
              end

              do
              end

              for key29, value62 in pairs((game.Players.LocalPlayer:WaitForChild("Backpack")):GetChildren()) do
                do
                end

                do
                end

                if (value62:IsA("Tool")) and value62.Name == "陷阱工具" then
                  local character11
                  character11 = game.Players.LocalPlayer.Character

                  local humanoid2
                  humanoid2 = character11

                  if character11 then
                    do
                    end

                    humanoid2 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                  end

                  if humanoid2 then
                    do
                    end

                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(value62)

                    value62:Activate()
                    value62:Destroy()

                    task.wait(0.1)
                  end
                end
              end

              task.wait()
            end

            return
          end)

          local v461
          v461 = library

          library:Notify("陷阱生成已开启", 1.5)
        end
      end
    else
      local v462
      v462 = library
      library:Notify("卡顿方式已关闭", 1.5)
    end

    return
  end)

  local v463 = "移除尸体"

  do
  end

  ;(lagMethods:AddDropdown("RemoveMethod", {
    Text = "清理方式",
    Default = "移除尸体",
    Values = { "移除尸体", "移除陷阱" },
    Tooltip = "Select what to clean up from the game",
  })):OnChanged(function(p33)
    v463 = p33
    return
  end)

  lagMethods:AddButton("清理所选", {
    Text = "清理所选",
    Func = function()
      local v464, v465, v466, v467, v468, v469, v470, v471, v472, v473, v474

      if v463 == "移除尸体" then
        do
        end

        local npcs2
        npcs2 = workspace:FindFirstChild("NPCS")

        if npcs2 then
          for key30, value63 in pairs(npcs2:GetChildren()) do
            do
            end

            do
            end

            if (value63:IsA("Model")) and value63.Name == "Ragdoll" then
              value63:Destroy()
            end
          end
        end

        if game.Players.LocalPlayer.Character then
          do
          end

          game.Players.LocalPlayer.Character:BreakJoints()
        end

        local v475
        v475 = library

        library:Notify("尸体已清理", 1.5)
      else
        if v463 == "移除陷阱" then
          do
          end

          local npcs3
          npcs3 = workspace:FindFirstChild("NPCS")

          if npcs3 then
            for key31, value64 in pairs(npcs3:GetChildren()) do
              do
              end

              do
              end

              if (value64:IsA("Model")) and value64.Name == "Trap" then
                value64:Destroy()
              end
            end
          end

          do
          end

          do
          end

          for key32, value65 in pairs((game.Players.LocalPlayer:WaitForChild("Backpack")):GetChildren()) do
            do
            end

            do
            end

            if (value65:IsA("Tool")) and value65.Name == "陷阱工具" then
              value65:Destroy()
            end
          end

          local v476
          v476 = library

          library:Notify("陷阱已清理", 1.5)
        end
      end

      return
    end,
    Tooltip = "清理游戏中的尸体或陷阱。",
  })

  do
  end

  local v477

  ;(spawnItems:AddDropdown("ItemDropdown", {
    Text = "生成物品",
    Values = {
      "杏仁水", "相机", "指南针", "能量饮料", "跳跃手臂", "钥匙卡", "12级钥匙",
      "医疗包", "Ping", "无线电", "陷阱工具", "扳手", "实体追踪器", "绷带箱",
      "糖果篮",
    },
    Default = "",
    Tooltip = "选择要在游戏中生成的物品。",
  })):OnChanged(function(p34)
    v477 = p34
    return
  end)

  spawnItems:AddButton("生成", {
    Text = "生成",
    Func = function()
      local character12 = localPlayer6.Character
      local humanoidRootPart12 = character12
      local v478, v479, v480

      if character12 then
        do
        end

        do
        end

        do
        end

        humanoidRootPart12 = (localPlayer6.Character:FindFirstChild("HumanoidRootPart"))
          and v477
      end

      if humanoidRootPart12 then
        local v481
        v481 = replicatedStorage4

        local clonedObjects
        clonedObjects = replicatedStorage4:FindFirstChild("ClonedObjects")

        if clonedObjects then
          local findFirstChild27
          findFirstChild27 = clonedObjects:FindFirstChild(v477)

          if findFirstChild27 then
            local clone
            clone = findFirstChild27:Clone()
            clone.Name = v477
            clone.Parent = workspace

            clone:SetPrimaryPartCFrame(localPlayer6.Character.HumanoidRootPart.CFrame
              * (CFrame.new(0, 0, -5)))

            local v482
            v482 = library

            library:Notify("Spawned: " .. v477, 1.5)
          end
        end
      end

      return
    end,
    Tooltip = "在你面前生成所选物品。",
  })

  spawnItems:AddButton("移除物品", {
    Text = "移除物品",
    Func = function()
      local v483 = workspace
      local v484, v485

      for index33, value66 in ipairs(v483:GetChildren()) do
        local model
        model = value66:IsA("Model")

        local v486
        v486 = model

        if model then
          do
          end

          do
          end

          v486 = v477 and value66.Name == v477
        end

        if v486 then
          value66:Destroy()
        end
      end

      local v487 = library
      library:Notify("Removed: " .. v477, 1.5)
      return
    end,
    Tooltip = "移除所选类型的所有已生成物品。",
  })

  emotes:AddButton("解锁动作第3级", {
    Text = "解锁动作第3级",
    Func = function()
      do
      end

      local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
      local emoteui = playerGui:WaitForChild("Emoteui")
      local v488 = emoteui
      local v489

      do
      end

      local emoteGui = emoteui or playerGui:WaitForChild("EmoteGui")
      local buttonThree = emoteGui:WaitForChild("ButtonThree")
      local container1 = (emoteGui:WaitForChild("container1"))
      local container2 = (emoteGui:WaitForChild("container2"))
      local container3 = (emoteGui:WaitForChild("container3"))

      local function f23(p35)
        local v490 = p35
        local lock = p35:FindFirstChild("Lock")
        local v491

        if lock then
          lock:Destroy()
        end

        do
        end

        p35.ChildAdded:Connect(function(child5)
          local v492 = child5

          if child5.Name == "Lock" then
            child5:Destroy()
          end

          return
        end)

        return
      end

      f23(buttonThree)

      do
      end

      buttonThree.MouseButton1Click:Connect(function()
        container1.Visible = false
        container2.Visible = false
        container3.Visible = true
        return
      end)

      local v493 = library
      library:Notify("动作第3级已解锁！", 1.5)
      return
    end,
    Tooltip = "无需条件即可解锁第3级动作。",
  })
end

do
  local v494 = library
  return
end

library:Notify("无尽现实功能已加载完成", 2)

end,function(e)
    safeNotify("ink_HUB错误", tostring(e):sub(1,120), 5)
end)
