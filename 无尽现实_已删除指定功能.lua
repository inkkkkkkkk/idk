-- This file has been deobfuscated at https://discord.gg/mgdnCWdsDP 
local library, localPlayer, v64, movement2, visuals2, other2, players, localPlayer6

do

  local ok, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
  end)
  if not ok or not result then
    warn("[Hook Software] Obsidian Library failed to load: " .. tostring(result))
    return
  end
  library = result
  local v1 = game

  local v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20,
    v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38,
    v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56,
    v57, v58, v59, v60, v61

  pcall(function()
    loadstring(v1:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
  end)


  pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()
  end)

  library.ForceCheckbox = false
  library.ShowToggleFrameInKeybinds = true

  task.spawn(function()
    while (task.wait()) do
      local v62
      v62 = game
      ;(v62:GetService("UserInputService")).MouseIconEnabled = true
    end

    return
  end)

  localPlayer = game.Players.LocalPlayer
  localPlayer6 = localPlayer
  local v63 = library
end

do
  local hookSoftwareWindow = library:CreateWindow({
    Title = "Hook Software",
    Footer = "version: 1.0.0",
    Center = true,
    AutoShow = true,
    NotifySide = "Right",
    ShowCustomCursor = true,
  })

  v64 = {
    Player = (hookSoftwareWindow:AddTab("Player", "user")),
    Visuals = (hookSoftwareWindow:AddTab("Visuals", "eye")),
    Premium = (hookSoftwareWindow:AddTab("Premium", "star")),
  }


  local movement = v64.Player:AddLeftTabbox("Movement")


  local visuals = v64.Player:AddRightTabbox("Visuals")


  local other = v64.Player:AddLeftTabbox("Other")
  movement2 = movement:AddTab("Movement")
  visuals2 = visuals:AddTab("Visuals")


  other2 = other:AddTab("Other")
end


do



  players = (game:GetService("Players"))
  local localPlayer3 = players.LocalPlayer


  ;(visuals2:AddToggle("PersonToggle", {
    Text = "Third Person",
    Default = false,
    Tooltip = "Switch to third-person camera view",
  })):OnChanged(function(p11)
    if p11 then
      localPlayer3.CameraMode = Enum.CameraMode.Classic

      local v154
      v154 = library

      library:Notify("Third Person Enabled", 1.5)
    else
      localPlayer3.CameraMode = Enum.CameraMode.LockFirstPerson

      local v155
      v155 = library

      library:Notify("Third Person Disabled", 1.5)
    end

    return
  end)

  local connect2

  local function f8()

    local v156 = game:GetService("Workspace")

    local function f9(p12)
      local v157 = p12
      local v158
      p12.HoldDuration = 0.0001

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

      connect2:Disconnect()
      connect2 = nil
    end

    return
  end

  local v162 = f8
  local v163 = f10


  ;(other2:AddToggle("InstantProximity", {
    Text = "Instant Proximity Prompt",
    Default = false,
    Tooltip = "Makes all interaction prompts instant (no holding required)",
  })):OnChanged(function(p13)
    local v164 = p13

    if p13 then
      f8()

      local v165
      v165 = library

      library:Notify("Instant Proximity Enabled", 1.5)
    else
      f10()

      local v166
      v166 = library

      library:Notify("Instant Proximity Disabled", 1.5)
    end

    return
  end)
end

other2:AddButton("Open Elevator", {
  Text = "Open Elevator",
  Func = function()

    local replicatedStorage = game:GetService("ReplicatedStorage")

    local openElevator = replicatedStorage:FindFirstChild("OpenElevator")
    if not openElevator or not openElevator:IsA("RemoteEvent") then
      library:Notify("OpenElevator not found", 2)
      return
    end
    openElevator:FireServer()

    local v167 = library
    library:Notify("Elevator Opened", 1.5)
    return
  end,
  Tooltip = "Instantly open the elevator",
})

local addToggle = other2:AddToggle("GodMode", {
  Text = "GodMode",
  Default = false,
  Tooltip = "Makes you invincible",
})

do
  local connect3

  addToggle:OnChanged(function(p16)
    local v182 = p16
    local v183, v184, v185, v186, v187, localPlayer4, healthValue

    if p16 then
      localPlayer4 = game.Players.LocalPlayer


      local character = localPlayer4.Character or localPlayer4.CharacterAdded:Wait()
      healthValue = character:FindFirstChild("HealthValue")
      if not healthValue then
        library:Notify("HealthValue not found; GodMode unavailable", 2)
        return
      end


      connect3 = ((game:GetService("RunService")).Heartbeat:Connect(function()
        local v188, v189, v190

        if healthValue.Value < 100 then

          local replicatedStorage2
          replicatedStorage2 = game:GetService("ReplicatedStorage")


          local eventsFolder = replicatedStorage2:FindFirstChild("Events")
          local vestEvent = eventsFolder and eventsFolder:FindFirstChild("VestEvent")
          if vestEvent and vestEvent:IsA("RemoteEvent") then
            vestEvent:FireServer(localPlayer4)
          end
        end

        return
      end))

      local v191
      v191 = library

      library:Notify("GodMode Enabled!", 1.5)
    else
      if connect3 then

        connect3:Disconnect()
        connect3 = nil
      end

      local v192
      v192 = library

      library:Notify("GodMode Disabled!", 1.5)
    end

    return
  end)

  other2:AddButton("Fail Round", {
    Text = "Fail Round",
    Func = function()

      local replicatedStorage3 = game:GetService("ReplicatedStorage")

      local addDeath = replicatedStorage3:FindFirstChild("AddDeath")
      if not addDeath or not addDeath:IsA("RemoteEvent") then
        library:Notify("AddDeath not found", 2)
        return
      end
      addDeath:FireServer()

      local v193 = library
      library:Notify("Round Failed", 1.5)
      return
    end,
    Tooltip = "Instantly fail the current round",
  })

end

do
  local moneySpam = v64.Premium:AddLeftTabbox("Money & Spam")


  local itemControl = v64.Premium:AddRightTabbox("Item Control")
  local currency = moneySpam:AddTab("Currency")
  local lagMethods = moneySpam:AddTab("Lag Methods")
  local emotes = itemControl:AddTab("Emotes")


  local value50, connect4

  ;(currency:AddToggle("InfiniteMoneyToggle", {
    Text = "Infinite Money",
    Default = false,
    Tooltip = "Gives you unlimited money",
  })):OnChanged(function(p30)
    local v417 = p30
    local v418 = localPlayer6
    local leaderstats = localPlayer6:FindFirstChild("leaderstats")
    local v419, v420, v421, v422, money

    if leaderstats then
      money = leaderstats:FindFirstChild("Money")

      if money then
        if p30 then
          value50 = money.Value


          connect4 = ((game:GetService("RunService")).Heartbeat:Connect(function()
            local v423
            money.Value = 999999999

            local playerValues = game.ReplicatedStorage:FindFirstChild("PlayerValues")

            if playerValues then
              local money2
              money2 = playerValues:FindFirstChild("Money")

              if money2 then
                money2.Value = 999999999
              end
            end

            return
          end))

          local v424
          v424 = library

          library:Notify("Infinite Money Enabled!", 1.5)
        else
          if connect4 then

            connect4:Disconnect()
            connect4 = nil
          end

          if value50 ~= nil then
            money.Value = value50

            local playerValues2
            playerValues2 = game.ReplicatedStorage:FindFirstChild("PlayerValues")

            if playerValues2 then
              local money3
              money3 = playerValues2:FindFirstChild("Money")

              if money3 then
                money3.Value = value50
              end
            end
          end

          local v425
          v425 = library

          library:Notify("Infinite Money Disabled!", 1.5)
        end
      end
    end

    return
  end)

  

  local v450 = "Dead Bodies"
  local v451 = false


  ;(lagMethods:AddDropdown("LagMethod", {
    Text = "Lag Methods",
    Default = "Dead Bodies",
    Values = { "Dead Bodies", "Spawn Traps" },
    Tooltip = "Select which method to use for lagging the game",
  })):OnChanged(function(p31)
    v450 = p31
    return
  end)


  ;(lagMethods:AddToggle("LagToggle", {
    Text = "Start Lag",
    Default = false,
    Tooltip = "Activate selected lag method to cause server lag",
  })):OnChanged(function(p32)
    v451 = p32

    if v451 then
      if v450 == "Dead Bodies" then
        task.spawn(function()
          local v452

          while v451 do
            if game.Players.LocalPlayer.Character then

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

        library:Notify("Dead Bodies Spam Enabled", 1.5)
      else
        if v450 == "Spawn Traps" then
          task.spawn(function()
            local v454, v455, v456, v457, v458, v459, v460

            while v451 do

              game.ReplicatedStorage.Events.BearTrapEvent:FireServer()


              for key29, value62 in pairs((game.Players.LocalPlayer:WaitForChild("Backpack")):GetChildren()) do


                if (value62:IsA("Tool")) and value62.Name == "TrapTool" then
                  local character11
                  character11 = game.Players.LocalPlayer.Character

                  local humanoid2
                  humanoid2 = character11

                  if character11 then

                    humanoid2 = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                  end

                  if humanoid2 then

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

          library:Notify("Trap Spam Enabled", 1.5)
        end
      end
    else
      local v462
      v462 = library
      library:Notify("Lag Method Disabled", 1.5)
    end

    return
  end)

  local v463 = "Remove Dead Bodies"


  ;(lagMethods:AddDropdown("RemoveMethod", {
    Text = "Remove Method",
    Default = "Remove Dead Bodies",
    Values = { "Remove Dead Bodies", "Remove Traps" },
    Tooltip = "Select what to clean up from the game",
  })):OnChanged(function(p33)
    v463 = p33
    return
  end)

  lagMethods:AddButton("Remove Selected", {
    Text = "Remove Selected",
    Func = function()
      local v464, v465, v466, v467, v468, v469, v470, v471, v472, v473, v474

      if v463 == "Remove Dead Bodies" then

        local npcs2
        npcs2 = workspace:FindFirstChild("NPCS")

        if npcs2 then
          for key30, value63 in pairs(npcs2:GetChildren()) do


            if (value63:IsA("Model")) and value63.Name == "Ragdoll" then
              value63:Destroy()
            end
          end
        end

        if game.Players.LocalPlayer.Character then

          game.Players.LocalPlayer.Character:BreakJoints()
        end

        local v475
        v475 = library

        library:Notify("Dead Bodies Removed", 1.5)
      else
        if v463 == "Remove Traps" then

          local npcs3
          npcs3 = workspace:FindFirstChild("NPCS")

          if npcs3 then
            for key31, value64 in pairs(npcs3:GetChildren()) do


              if (value64:IsA("Model")) and value64.Name == "Trap" then
                value64:Destroy()
              end
            end
          end


          for key32, value65 in pairs((game.Players.LocalPlayer:WaitForChild("Backpack")):GetChildren()) do


            if (value65:IsA("Tool")) and value65.Name == "TrapTool" then
              value65:Destroy()
            end
          end

          local v476
          v476 = library

          library:Notify("Traps Removed", 1.5)
        end
      end

      return
    end,
    Tooltip = "Clean up dead bodies or traps from the game",
  })


  local v477

    emotes:AddButton("Unlock Emote Tier 3", {
    Text = "Unlock Emote Tier 3",
    Func = function()

      local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
      if not playerGui then
        library:Notify("PlayerGui not found", 2)
        return
      end
      local emoteGui = playerGui:FindFirstChild("Emoteui") or playerGui:FindFirstChild("EmoteGui")
      if not emoteGui then
        library:Notify("Emote UI not found", 2)
        return
      end
      local buttonThree = emoteGui:FindFirstChild("ButtonThree")
      local container1 = emoteGui:FindFirstChild("container1")
      local container2 = emoteGui:FindFirstChild("container2")
      local container3 = emoteGui:FindFirstChild("container3")
      if not buttonThree or not container1 or not container2 or not container3 then
        library:Notify("Emote UI is incomplete", 2)
        return
      end

      local function f23(p35)
        local v490 = p35
        local lock = p35:FindFirstChild("Lock")
        local v491

        if lock then
          lock:Destroy()
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

      buttonThree.MouseButton1Click:Connect(function()
        container1.Visible = false
        container2.Visible = false
        container3.Visible = true
        return
      end)

      local v493 = library
      library:Notify("Emote Tier 3 Unlocked!", 1.5)
      return
    end,
    Tooltip = "Unlock the third tier of emotes without requirements",
  })
end

do
  local v494 = library
  library:Notify("Hookv1.0.0 Loaded Successfully!", 1.5)
  return
end
