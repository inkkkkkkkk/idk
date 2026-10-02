local A=game:GetService("StarterGui")

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

local B=nil
local winduiLastError="未知错误"
local winduiUrls={
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    "https://raw.githubusercontent.com/951357nvjn/dyzs/refs/heads/main/winduiYI.lua"
}

for _,url in ipairs(winduiUrls) do
    local ok,result=pcall(function()
        local code=game:HttpGet(url)
        if type(code)~="string" or #code<100 then error("WindUI下载内容为空") end
        local loader=loadstring(code)
        if type(loader)~="function" then error("WindUI loadstring失败") end
        return loader()
    end)
    if ok and result then
        B=result
        break
    end
    winduiLastError=tostring(result)
    task.wait(0.25)
end

if not B then
    pcall(function()
        A:SetCore("SendNotification",{
            Title="WindUI加载失败",
            Text="请检查Delta网络/HttpGet支持",
            Duration=5
        })
    end)
    warn("[角色|皮肤切换器] WindUI加载失败:",winduiLastError)
    return
end

pcall(function()
    B:AddTheme({
        Name = "inkGray",
        Accent = Color3.fromRGB(105,105,105),
        Dialog = Color3.fromRGB(32,32,32),
        Outline = Color3.fromRGB(125,125,125),
        Text = Color3.fromRGB(235,235,235),
        Placeholder = Color3.fromRGB(145,145,145),
        Background = Color3.fromRGB(24,24,24),
        Button = Color3.fromRGB(58,58,58),
        Icon = Color3.fromRGB(190,190,190),
        Title = Color3.fromRGB(155,155,155),
        Author = Color3.fromRGB(145,145,145),
    })
    B:SetTheme("inkGray")
end)

local C=B:CreateWindow({
    Icon="crown",
    Title=gradient("被遗弃角色|皮肤切换器",Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)),
    Author=gradient("@墨水依旧",Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)),
    Folder="被遗弃角色|皮肤切换器",
    Size=UDim2.fromOffset(520,410),
    Theme="inkGray",
    SideBarWidth=160,
    ScrollBarEnabled=true,
    NewElements=true,
    HideSearchBar=false,
})

pcall(function()
    C:EditOpenButton({
        Title="被遗弃角色|皮肤切换器",
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
end)

-- 与第二个脚本相同的灰色动态边框/发光效果
pcall(function()
    local RunService=game:GetService("RunService")
    local targetWindow=C.UIElements and C.UIElements.Main

    if not targetWindow then
        local CoreGui=game:GetService("CoreGui")
        for _,obj in ipairs(CoreGui:GetDescendants()) do
            if obj:IsA("Frame") and obj.AbsoluteSize.X>300 and obj.AbsoluteSize.Y>150 then
                local title=obj:FindFirstChildWhichIsA("TextLabel",true)
                if title and title.Text=="被遗弃角色|皮肤切换器" then
                    targetWindow=obj
                    break
                end
            end
        end
    end

    if targetWindow then
        local oldStroke=targetWindow:FindFirstChild("inkGrayMainBorder")
        if oldStroke then oldStroke:Destroy() end

        local stroke=Instance.new("UIStroke")
        stroke.Name="inkGrayMainBorder"
        stroke.Thickness=7
        stroke.Transparency=0
        stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        stroke.Color=Color3.fromRGB(145,145,145)
        stroke.Parent=targetWindow

        local glowColors={
            {Name="inkGrayGlowOuter",Thickness=16,Transparency=0.88},
            {Name="inkGrayGlowMid",Thickness=11,Transparency=0.80},
            {Name="inkGrayGlowInner",Thickness=7,Transparency=0.70},
        }

        for _,info in ipairs(glowColors) do
            local oldGlow=targetWindow:FindFirstChild(info.Name)
            if oldGlow then oldGlow:Destroy() end

            local glow=Instance.new("UIStroke")
            glow.Name=info.Name
            glow.Thickness=info.Thickness
            glow.Transparency=info.Transparency
            glow.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            glow.Color=Color3.fromRGB(150,150,150)
            glow.Parent=targetWindow

            local glowGradient=Instance.new("UIGradient")
            glowGradient.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(70,70,70)),
                ColorSequenceKeypoint.new(0.5,Color3.fromRGB(190,190,190)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(70,70,70))
            })
            glowGradient.Parent=glow

            task.spawn(function()
                local r=0
                while targetWindow.Parent and glow.Parent and glowGradient.Parent do
                    r=(r+1.1)%360
                    glowGradient.Rotation=r
                    RunService.RenderStepped:Wait()
                end
            end)
        end

        local gradient=Instance.new("UIGradient")
        gradient.Name="inkGrayBorderGradient"
        gradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(65,65,65)),
            ColorSequenceKeypoint.new(0.25,Color3.fromRGB(120,120,120)),
            ColorSequenceKeypoint.new(0.5,Color3.fromRGB(200,200,200)),
            ColorSequenceKeypoint.new(0.75,Color3.fromRGB(120,120,120)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(65,65,65))
        })
        gradient.Parent=stroke

        task.spawn(function()
            local rotation=0
            while targetWindow.Parent and stroke.Parent and gradient.Parent do
                rotation=(rotation+1.5)%360
                gradient.Rotation=rotation
                RunService.RenderStepped:Wait()
            end
        end)
    end
end)

-- 标题与作者文字颜色与第二个脚本保持一致
pcall(function()
    local CoreGui=game:GetService("CoreGui")
    local function recolor(root)
        for _,obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                if obj.Text=="被遗弃角色|皮肤切换器" then
                    obj.TextColor3=Color3.fromRGB(155,155,155)
                elseif obj.Text=="@墨水依旧" then
                    obj.TextColor3=Color3.fromRGB(125,125,125)
                end
            end
        end
    end
    recolor(CoreGui)
    task.delay(0.25,function() pcall(function() recolor(CoreGui) end) end)
    task.delay(0.8,function() pcall(function() recolor(CoreGui) end) end)
end)

local D=C:Section({Title="功能菜单",Opened=true})

local KillerTab=D:Tab({Title="杀手",Icon="skull"})
KillerTab:Button({Title="13号星期五杰森",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!Slasher_FRIDAY"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="3月18号约翰",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!JohnDoe_MARCH"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="马",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!Horse"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="谢德",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!DoppelgangerShedletsky"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="剑术大师",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("ShedletskyFunny"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="苏库娜",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!SukunaKiller"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="黑木",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!Herobrine"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="猫",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!Cat"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
KillerTab:Button({Title="烈焰石",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Killers"):WaitForChild("!Brimstone"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})

local SurvivorTab=D:Tab({Title="幸存",Icon="user"})
SurvivorTab:Button({Title="noob_世界",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("!NoobTheWorld"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SurvivorTab:Button({Title="武术家",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("#MArtist"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SurvivorTab:Button({Title="特种部队",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("#SWATOfficer"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SurvivorTab:Button({Title="中毒者",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("1xFunny"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SurvivorTab:Button({Title="腐化者",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("JohnDoeFunny"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SurvivorTab:Button({Title="小孩",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Survivors"):WaitForChild("c00lkiddFunny"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})

local SkinTab=D:Tab({Title="皮肤",Icon="palette"})
SkinTab:Button({Title="KJ",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Guest1337"):WaitForChild("#KJGuest"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小谢德",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Shedletsky"):WaitForChild("#LittleGuyShedletsky"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})SkinTab:Button({Title="小披萨",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Elliot"):WaitForChild("#LittleGuyElliot"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小noob",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Noob"):WaitForChild("#LittleNoob"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小建筑工",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Builderman"):WaitForChild("#LittleGuyBuilderman"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小007",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("007n7"):WaitForChild("#LittleGuy007n7"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="婴儿两次",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("TwoTime"):WaitForChild("!BabyTwoTime"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小访客",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Guest1337"):WaitForChild("#LittleGuyGuest"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小塔夫",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Taph"):WaitForChild("#LittleTaph"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小卡尔",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Dusekkar"):WaitForChild("#LittleGuyDusekkar"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小维罗妮卡",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Veeronica"):WaitForChild("#LittleGalVeeronica"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})
SkinTab:Button({Title="小机会",Callback=function()
    local args={"EquipState",{game:GetService("ReplicatedStorage"):WaitForChild("Assets"):WaitForChild("Skins"):WaitForChild("Survivors"):WaitForChild("Chance"):WaitForChild("#LittleGuyChance"),buffer.fromstring("\001\001")}}
    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
end})

task.wait(0.1)
A:SetCore("SendNotification",{Title="加载成功",Text="角色|皮肤切换器已正常运行",Duration=3})