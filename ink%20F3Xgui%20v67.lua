--[[
	MikeMercu f3x gui
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ============================================================
-- CLEANUP
-- ============================================================
local KILL_PATTERNS = {
	"Mike", "F3x", "TEST", "ZZZ",
	"MikeMercu", "MikeMercuPanel", "JohnDoe", "Pringles",
}
for _, g in ipairs(playerGui:GetChildren()) do
	if g:IsA("ScreenGui") then
		local name = g.Name
		local kill = false
		for _, pat in ipairs(KILL_PATTERNS) do
			if name:find(pat) then
				kill = true
				break
			end
		end
		if kill then
			pcall(function() g:Destroy() end)
		end
	end
end
task.wait(0.1)

local PREFIX     = ";"
local SPAM_DELAY = 0.03
local PURPLE     = Color3.fromRGB(170, 0, 255)
local BACKGROUND_DECAL = "rbxassetid://92976213364093"

local ENC_WORLD_TOUR_DECAL = "MTI4ODkwMTcxMTI5NjAz"
local ENC_SKYBOX_TEXTURE   = "MTI4ODkwMTcxMTI5NjAz"

local function b64decode(s)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	s = s:gsub('[^' .. b .. '=]', '')
	return (s:gsub('.', function(x)
		if x == '=' then return '' end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if #x ~= 8 then return '' end
		local c = 0
		for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

local REAL_WORLD_TOUR_DECAL = b64decode(ENC_WORLD_TOUR_DECAL)
local REAL_SKYBOX_TEXTURE   = b64decode(ENC_SKYBOX_TEXTURE)

local WORLD_TOUR_DECAL_ID = REAL_WORLD_TOUR_DECAL
local SKYBOX_TEXTURE_ID   = REAL_SKYBOX_TEXTURE

local currentDecalID   = WORLD_TOUR_DECAL_ID
local currentMyDecalID = "104436172542890"
local currentMusicID   = "100048144167699"
local HARDBASS_ID      = "119724983756181"
local HARDBASS_PITCH   = 0.13
local TUBERS93_ID      = "74464434454195"
local TUBERS93_PITCH   = 1.0

local SPARTA_ID        = "88982673611296"
local SPARTA_PITCH     = 0.05

local TROLL_MUSIC_ID   = "131800565792856"
local TROLL_MUSIC_PITCH = 0.05

local REALM_MUSIC_ID   = "123143562570662"

local MY_SKYBOX_TEXTURE = "104436172542890"

local YAAI_DECAL_ID     = "124009046256822"
local MARIO_EXE_DECAL_ID = "109628213967854"

local TROLL_DECAL_ID    = "99065227044934"

local IDIOT_MUSIC_ID    = "3200130016"

local NIGHTCORE_ID      = "140292888574146"
local NIGHTCORE_PITCH   = 0.17

local MIKEMERCU_RET_DECAL_ID = "139452709092966"
local MIKEMERCU_RET_SKYBOX_ID = "140164706115131"

local GOBBYDOOLAN_DECAL_ID  = "140164706115131"
local GOBBYDOOLAN_SKYBOX_ID = "82504261335674"

local SPIKE_MESH       = "rbxassetid://123456789"
local SPIKE_TEXTURE    = "rbxassetid://123456789"
local TRAP_TEXTURE     = "rbxassetid://243660364"
local FIRE_MESH        = "9403473283"
local FIRE_TEXTURE     = "74015851400423"

local PUNCH_DAMAGE     = 25
local PUNCH_KNOCKBACK  = 280
local PUNCH_UP         = 110
local PUNCH_RANGE      = 8
local SPIKE_DAMAGE     = 35
local SPIKE_LIFETIME   = 8
local TRAP_DAMAGE      = 8
local TRAP_TICK        = 0.5
local TRAP_DURATION    = 6
local TRAP_FIELD_LIFE  = 15
local SPEED_404_TIME   = 6
local SPEED_404_BOOST  = 60
local COOLDOWN         = 1.5

-- ============================================================
-- GUI LAYOUT CONSTANTS (GRID)
-- ============================================================
local GUI_WIDTH    = 600
local COLS         = 3
local BTN_W        = 190
local BTN_H        = 26
local BTN_GAP_X    = 4
local BTN_GAP_Y    = 4
local SECTION_GAP  = 6
local HEADER_H     = 18
local PAD          = 6
local ARROW_W      = 16
local PANEL_W      = 150

local function addStroke(obj, thickness)
	local s = Instance.new("UIStroke")
	s.Color = PURPLE
	s.Thickness = thickness or 1.2
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function getSilentRemote()
	local hd = ReplicatedStorage:FindFirstChild("HDAdminHDClient")
		or ReplicatedStorage:FindFirstChild("HDClient")
	if not hd then return nil end
	local signals = hd:FindFirstChild("Signals")
	if not signals then return nil end
	return signals:FindFirstChild("RequestCommandSilent")
		or signals:FindFirstChild("RequestCommand")
end

local function runSilent(cmd)
	local remote = getSilentRemote()
	if not remote then warn("[HD Admin] silent remote not found") return end
	pcall(function() remote:InvokeServer(PREFIX .. cmd) end)
end

local function getink F3Xgui v67Remote()
	local tool
	if player.Character then
		tool = player.Character:FindFirstChild("Building Tools+")
	end
	if not tool and player:FindFirstChild("Backpack") then
		tool = player.Backpack:FindFirstChild("Building Tools+")
	end
	if not tool then
		for _, v in ipairs(player:GetDescendants()) do
			if v.Name == "SyncAPI" then tool = v.Parent break end
		end
	end
	if not tool then
		for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
			if v.Name == "SyncAPI" then tool = v.Parent break end
		end
	end
	if tool then
		local api = tool:FindFirstChild("SyncAPI")
		if api then return api:FindFirstChild("ServerEndpoint") end
	end
end

-- ============================================================
-- ANTI-SKID
-- ============================================================
local function antiSkidCheck()
	if currentDecalID ~= REAL_WORLD_TOUR_DECAL then
		player:Kick("f***in skid")
		return
	end
	if SKYBOX_TEXTURE_ID ~= REAL_SKYBOX_TEXTURE then
		player:Kick("f***in skid")
		return
	end
end

antiSkidCheck()

task.spawn(function()
	while true do
		task.wait(0.5)
		antiSkidCheck()
	end
end)

-- ============================================================
-- ACTIONS
-- ============================================================
local function giveBtools()
	runSilent("btools me")
	task.wait(0.4)
	runSilent("f3x me")
end

local function playMusic()
	runSilent("music " .. currentMusicID)
	task.wait(0.2)
	runSilent("volume inf")
end

local function playHardbass()
	runSilent("music " .. HARDBASS_ID)
	task.wait(0.2)
	runSilent("pitch " .. HARDBASS_PITCH)
	task.wait(0.2)
	runSilent("volume 999")
end

local function playTubers93()
	runSilent("music " .. TUBERS93_ID)
	task.wait(0.2)
	runSilent("pitch " .. TUBERS93_PITCH)
	task.wait(0.2)
	runSilent("volume 999")
end

local function playSparta()
	runSilent("music " .. SPARTA_ID)
	task.wait(0.2)
	runSilent("pitch " .. SPARTA_PITCH)
	task.wait(0.2)
	runSilent("volume 999")
end

local function playTrollMusic()
	runSilent("music " .. TROLL_MUSIC_ID)
	task.wait(0.2)
	runSilent("pitch " .. TROLL_MUSIC_PITCH)
	task.wait(0.2)
	runSilent("volume 999")
end

local function playNightcore()
	runSilent("music " .. NIGHTCORE_ID)
	task.wait(0.2)
	runSilent("pitch " .. NIGHTCORE_PITCH)
	task.wait(0.2)
	runSilent("volume 999")
end

local function playRealmMusic()
	runSilent("music " .. REALM_MUSIC_ID)
	task.wait(0.2)
	runSilent("volume inf")
end

local function playTitle()
	runSilent("titlep me MikeMercu")
end

-- ============================================================
-- YOU ARE AN IDIOT (TOGGLE)
-- ============================================================
local idiotState = { active = false }

local function toggleIdiotMusic(btn)
	idiotState.active = not idiotState.active
	if idiotState.active then
		runSilent("music " .. IDIOT_MUSIC_ID)
		task.wait(0.2)
		runSilent("volume 999")
		if btn then btn.Text = "You Are An Idiot: ON" end
	else
		runSilent("music 0")
		task.wait(0.2)
		runSilent("volume 1")
		if btn then btn.Text = "You Are An Idiot!" end
	end
end

-- ============================================================
-- UNIVERSAL DECAL SPAM
-- ============================================================
local function spamDecalOnEverything(decalID, label)
	local remote = getink F3Xgui v67Remote()
	if not remote then
		warn(("[" .. label .. "] ink F3Xgui v67 not found — click [ink F3Xgui v67] first"))
		return
	end
	local function fire(args) pcall(function() remote:InvokeServer(unpack(args)) end) end

	local faces = {
		Enum.NormalId.Front, Enum.NormalId.Back,
		Enum.NormalId.Left,  Enum.NormalId.Right,
		Enum.NormalId.Top,   Enum.NormalId.Bottom,
	}

	task.spawn(function()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				task.spawn(function()
					fire({"SetLocked", {v}, false})
					for _, f in ipairs(faces) do
						fire({"CreateTextures", {{Part = v, Face = f, TextureType = "Decal"}}})
						fire({"SyncTexture", {{
							Part = v, Face = f, TextureType = "Decal",
							Texture = "rbxassetid://" .. decalID
						}}})
					end
				end)
				task.wait(SPAM_DELAY)
			end
		end
	end)
end

-- ============================================================
-- UNIVERSAL PARTICLE SPAM
-- ============================================================
local function spamParticlesOnEverything(label, options)
	local remote = getink F3Xgui v67Remote()
	if not remote then
		warn(("[" .. label .. "] ink F3Xgui v67 not found — click [ink F3Xgui v67] first"))
		return
	end
	local function fire(args) pcall(function() remote:InvokeServer(unpack(args)) end) end

	options = options or {}
	local texture     = options.Texture     or ("rbxassetid://" .. currentMyDecalID)
	local rate        = options.Rate        or "5000"
	local spreadAngle = options.SpreadAngle or "18000"
	local rotSpeed    = options.RotSpeed    or "10"
	local speed       = options.Speed       or "24"
	local size        = options.Size        or "1"

	task.spawn(function()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				task.spawn(function()
					fire({"SetLocked", {v}, false})
					fire({"CreateDecorations", {{Part = v, DecorationType = "ParticleEmitter"}}})
					fire({"SyncDecorate", {{
						Part = v, DecorationType = "ParticleEmitter",
						Rate = rate, SpreadAngle = spreadAngle, RotSpeed = rotSpeed,
						Texture = texture, Speed = speed, Size = size
					}}})
				end)
				task.wait(SPAM_DELAY)
			end
		end
	end)
end

local function clearParticlesFromEverything(label)
	local remote = getink F3Xgui v67Remote()
	if not remote then
		warn(("[" .. label .. "] ink F3Xgui v67 not found — click [ink F3Xgui v67] first"))
		return
	end
	local function fire(args) pcall(function() remote:InvokeServer(unpack(args)) end) end

	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			pcall(function() v:Destroy() end)
		end
	end

	local decorationTypes = {"ParticleEmitter", "Fire", "Smoke", "Sparkles"}

	task.spawn(function()
		local parts = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				table.insert(parts, v)
			end
		end

		local batchSize = 30
		for i = 1, #parts, batchSize do
			for _, dtype in ipairs(decorationTypes) do
				local batch = {}
				for j = i, math.min(i + batchSize - 1, #parts) do
					table.insert(batch, {
						Part = parts[j],
						DecorationType = dtype
					})
				end
				fire({"RemoveDecorations", batch})
			end
			task.wait(0.05)
		end
	end)
end

local function spamYaaiDecal() spamDecalOnEverything(YAAI_DECAL_ID, "Yaai Decal") end
local function spamMarioExeDecal() spamDecalOnEverything(MARIO_EXE_DECAL_ID, "Mario.exe Decal") end
local function spamTrollDecal() spamDecalOnEverything(TROLL_DECAL_ID, "Troll Decal") end
local function spamMikeMercuRetDecal() spamDecalOnEverything(MIKEMERCU_RET_DECAL_ID, "MikeMercu.ret Decal") end
local function spamGobbyDoolanDecal() spamDecalOnEverything(GOBBYDOOLAN_DECAL_ID, "GobbyDoolan Decal") end

-- ============================================================
-- UNIVERSAL SKYBOX SPAWNER
-- ============================================================
local function spawnSkyboxWithID(textureID, label)
	local char = player.Character or player.CharacterAdded:Wait()
	local tool

	for _, v in ipairs(player:GetDescendants()) do
		if v.Name == "SyncAPI" then tool = v.Parent break end
	end
	if not tool then
		for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
			if v.Name == "SyncAPI" then tool = v.Parent break end
		end
	end

	if not tool then
		warn(("[" .. label .. "] ink F3Xgui v67 not found — click [ink F3Xgui v67] first"))
		return
	end

	local remote = tool.SyncAPI.ServerEndpoint
	local function _(args) pcall(function() remote:InvokeServer(unpack(args)) end) end

	local function SetCollision(part, boolean) _({"SyncCollision", {{Part = part, CanCollide = boolean}}}) end
	local function SetAnchor(boolean, part) _({"SyncAnchor", {{Part = part}, Anchored = boolean}}) end
	local function CreatePart(cf, parent) _({"CreatePart", "Normal", cf, parent}) end
	local function AddMesh(part) _({"CreateMeshes", {{Part = part}}}) end
	local function SetMesh(part, meshid) _({"SyncMesh", {{Part = part, MeshId = "rbxassetid://" .. meshid}}}) end
	local function SetTexture(part, texid) _({"SyncMesh", {{Part = part, TextureId = "rbxassetid://" .. texid}}}) end
	local function SetName(part, stringg) _({"SetName", {part}, stringg}) end
	local function MeshResize(part, size) _({"SyncMesh", {{Part = part, Scale = size}}}) end
	local function SetLocked(part, boolean) _({"SetLocked", {part}, boolean}) end
	local function Color(part, color) _({"SyncColor", {{Part = part, Color = color, UnionColoring = false}}}) end

	local root = char:WaitForChild("HumanoidRootPart")
	local pos = root.CFrame + Vector3.new(0, 6, 0)
	CreatePart(pos, workspace)
	task.wait(0.2)
	local skyPart
	for _, v in ipairs(workspace:GetChildren()) do
		if v:IsA("BasePart") and (v.Position - pos.Position).magnitude < 1 then
			skyPart = v
			break
		end
	end
	if skyPart then
		SetName(skyPart, "Sky")
		AddMesh(skyPart)
		SetMesh(skyPart, "111891702759441")
		SetTexture(skyPart, textureID)
		MeshResize(skyPart, Vector3.new(1000, 1000, 1000))
		SetLocked(skyPart, true)
		SetAnchor(true, skyPart)
	end
end

local function spawnMySkybox() spawnSkyboxWithID(MY_SKYBOX_TEXTURE, "我的天空盒") end
local function spawnMarioExeSkybox() spawnSkyboxWithID("109628213967854", "天空盒3") end
local function spawnTrollSkybox() spawnSkyboxWithID("99065227044934", "天空盒4") end
local function spawnYaaiSkybox() spawnSkyboxWithID("124009046256822", "天空盒5") end
local function spawnMikeMercuRetSkybox() spawnSkyboxWithID(MIKEMERCU_RET_SKYBOX_ID, "MikeMercu.ret Skybox") end
local function spawnGobbyDoolanSkybox() spawnSkyboxWithID(GOBBYDOOLAN_SKYBOX_ID, "GobbyDoolan Skybox") end

-- ============================================================
-- JOHN DOE ANIMATIONS
-- ============================================================
local animState = { activeTweens = {} }

local function tweenJoint(joint, targetC0, duration, easing)
	if not joint then return nil end
	local t = TweenService:Create(
		joint,
		TweenInfo.new(duration or 0.15, easing or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ C0 = targetC0 }
	)
	t:Play()
	table.insert(animState.activeTweens, t)
	return t
end

local function getJoints(char)
	if not char then return nil end
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	local root = char:FindFirstChild("HumanoidRootPart")
	local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
	local leftArm  = char:FindFirstChild("Left Arm")  or char:FindFirstChild("LeftUpperArm")
	local rightLeg = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
	local leftLeg  = char:FindFirstChild("Left Leg")  or char:FindFirstChild("LeftUpperLeg")
	if not torso or not root then return nil end
	return { torso = torso, root = root, rightArm = rightArm, leftArm = leftArm, rightLeg = rightLeg, leftLeg = leftLeg }
end

local function animPunch()
	local char = player.Character
	if not char then return end
	local j = getJoints(char)
	if not j or not j.rightArm then return end
	local rightShoulder = j.rightArm:FindFirstChild("RightShoulder") or j.rightArm:FindFirstChild("RightShoulderJoint")
	if not rightShoulder then return end
	local baseC0 = rightShoulder.C0
	local punch = baseC0 * CFrame.new(0, 0, -1.2) * CFrame.Angles(math.rad(-90), 0, math.rad(-20))
	tweenJoint(rightShoulder, punch, 0.08, Enum.EasingStyle.Quad)
	task.wait(0.12)
	tweenJoint(rightShoulder, baseC0, 0.2, Enum.EasingStyle.Back)
end

local function animSpikes()
	local char = player.Character
	if not char then return end
	local j = getJoints(char)
	if not j then return end
	local rootJoint = j.root:FindFirstChild("RootJoint") or j.torso:FindFirstChild("RootJoint")
	local rightShoulder = j.rightArm and (j.rightArm:FindFirstChild("RightShoulder") or j.rightArm:FindFirstChild("RightShoulderJoint"))
	local leftShoulder  = j.leftArm and (j.leftArm:FindFirstChild("LeftShoulder") or j.leftArm:FindFirstChild("LeftShoulderJoint"))
	if rootJoint then
		local baseRoot = rootJoint.C0
		tweenJoint(rootJoint, baseRoot * CFrame.Angles(math.rad(30), 0, 0), 0.12)
		task.wait(0.15)
		tweenJoint(rootJoint, baseRoot, 0.25)
	end
	if rightShoulder then
		local base = rightShoulder.C0
		tweenJoint(rightShoulder, base * CFrame.Angles(math.rad(120), 0, 0), 0.12)
		task.wait(0.1)
		tweenJoint(rightShoulder, base, 0.25)
	end
	if leftShoulder then
		local base = leftShoulder.C0
		tweenJoint(leftShoulder, base * CFrame.Angles(math.rad(120), 0, 0), 0.12)
		task.wait(0.1)
		tweenJoint(leftShoulder, base, 0.25)
	end
end

local function animTrap()
	local char = player.Character
	if not char then return end
	local j = getJoints(char)
	if not j or not j.rightLeg then return end
	local rightHip = j.rightLeg:FindFirstChild("Right Hip") or j.rightLeg:FindFirstChild("RightHip")
	if not rightHip then return end
	local base = rightHip.C0
	for i = 1, 2 do
		tweenJoint(rightHip, base * CFrame.Angles(math.rad(-25), 0, 0), 0.1)
		task.wait(0.12)
		tweenJoint(rightHip, base, 0.1)
		task.wait(0.15)
	end
end

local function anim404()
	local char = player.Character
	if not char then return end
	local j = getJoints(char)
	if not j then return end
	local rootJoint = j.root:FindFirstChild("RootJoint")
	if not rootJoint then return end
	local base = rootJoint.C0
	task.spawn(function()
		local t0 = tick()
		while tick() - t0 < 0.6 do
			rootJoint.C0 = base * CFrame.new(
				math.random(-5, 5) / 100,
				math.random(-5, 5) / 100,
				math.random(-5, 5) / 100
			) * CFrame.Angles(
				math.rad(math.random(-3, 3)),
				math.rad(math.random(-3, 3)),
				math.rad(math.random(-3, 3))
			)
			task.wait(0.02)
		end
		rootJoint.C0 = base
	end)
end

-- ============================================================
-- JOHN DOE ABILITIES
-- ============================================================
local jdState = {
	active = false, conns = {},
	lastPunch = 0, lastSpike = 0, lastTrap = 0, last404 = 0,
	activeTraps = {},
}

local hudGui

local function logf(...) print("[JohnDoe]", ...) end

local function waitForink F3Xgui v67(timeout)
	timeout = timeout or 5
	local t0 = tick()
	while tick() - t0 < timeout do
		local remote = getink F3Xgui v67Remote()
		if remote then return remote end
		task.wait(0.2)
	end
	return nil
end

local function spawnink F3Xgui v67Part(remote, pos, parent)
	local before = {}
	for _, v in ipairs(workspace:GetChildren()) do
		if v:IsA("BasePart") then before[v] = true end
	end
	local ok = pcall(function()
		remote:InvokeServer("CreatePart", "Normal", pos, parent or workspace)
	end)
	if not ok then return nil end
	local t0 = tick()
	while tick() - t0 < 1.5 do
		for _, v in ipairs(workspace:GetChildren()) do
			if v:IsA("BasePart") and not before[v] then
				return v
			end
		end
		task.wait(0.03)
	end
	return nil
end

local function getMouseWorldPosition()
	local mouseLoc = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { player.Character }
	local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, rayParams)
	if result then
		return result.Position
	else
		return ray.Origin + ray.Direction * 2000
	end
end

local function cleanupJohnDoe()
	for _, c in ipairs(jdState.conns) do
		pcall(function() c:Disconnect() end)
	end
	jdState.conns = {}
	for _, t in ipairs(jdState.activeTraps) do
		if t.field and t.field.Parent then
			pcall(function() t.field:Destroy() end)
		end
	end
	jdState.activeTraps = {}
	jdState.active = false
	if hudGui then hudGui:Destroy() hudGui = nil end
	logf("disabled")
end

local function showHud()
	if hudGui then return end
	hudGui = Instance.new("ScreenGui")
	hudGui.Name = "JohnDoeHud"
	hudGui.ResetOnSpawn = false
	hudGui.DisplayOrder = 5000
	hudGui.IgnoreGuiInset = true
	hudGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 160, 0, 100)
	frame.Position = UDim2.new(1, -170, 1, -110)
	frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Parent = hudGui
	addStroke(frame, 2)
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 16)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.SourceSansBold
	title.Text = "John Doe"
	title.TextColor3 = PURPLE
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame
	local keys = {
		{"LMB", "punch"},
		{"Q",   "spikes"},
		{"E",   "trap"},
		{"R",   "404"},
		{"F",   "stop"},
	}
	for i, k in ipairs(keys) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -16, 0, 14)
		lbl.Position = UDim2.new(0, 8, 0, 22 + (i-1) * 14)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.Code
		lbl.Text = string.format("[%-5s]  %s", k[1], k[2])
		lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
		lbl.TextSize = 10
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = frame
	end
end

local function knockback(targetHRP, dir)
	if not targetHRP or not targetHRP.Parent then return end
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude < 0.1 then dir = targetHRP.CFrame.LookVector end
	dir = dir.Unit
	pcall(function()
		targetHRP.AssemblyLinearVelocity = dir * PUNCH_KNOCKBACK + Vector3.new(0, PUNCH_UP, 0)
	end)
	pcall(function() targetHRP:ApplyImpulse(dir * 3000 + Vector3.new(0, 2000, 0)) end)
	task.spawn(function()
		local t0 = tick()
		while tick() - t0 < 0.25 do
			pcall(function()
				if targetHRP and targetHRP.Parent then
					targetHRP.AssemblyLinearVelocity = dir * PUNCH_KNOCKBACK + Vector3.new(0, PUNCH_UP, 0)
				end
			end)
			task.wait(0.02)
		end
	end)
end

local function dealDamage(targetHumanoid, amount)
	if not targetHumanoid or not targetHumanoid.Parent then return end
	pcall(function() targetHumanoid:TakeDamage(amount) end)
end

local function punch()
	local now = tick()
	if now - jdState.lastPunch < COOLDOWN then return end
	jdState.lastPunch = now
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	task.spawn(animPunch)
	local origin = hrp.Position
	local targetPos = getMouseWorldPosition()
	local dir = (targetPos - origin)
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude < 0.1 then dir = hrp.CFrame.LookVector end
	dir = dir.Unit
	logf("punch fired")
	local remote = getink F3Xgui v67Remote()
	if remote then
		local function _(args) pcall(function() remote:InvokeServer(unpack(args)) end) end
		local punchPos = origin + dir * 3 + Vector3.new(0, 1, 0)
		local fx = spawnink F3Xgui v67Part(remote, CFrame.new(punchPos), workspace)
		if fx then
			_({"SetName", {fx}, "JDPunch"})
			_({"SyncCollision", {{Part = fx, CanCollide = false}}})
			_({"SyncAnchor", {{Part = fx}, true}})
			_({"SyncResize", {{Part = fx, CFrame = fx.CFrame, Size = Vector3.new(4, 4, 4)}}})
			_({"SyncColor", {{Part = fx, Color = Color3.fromRGB(180, 0, 0), UnionColoring = false}}})
			_({"CreateDecorations", {{Part = fx, DecorationType = "Fire"}}})
			_({"SyncDecorate", {{Part = fx, DecorationType = "Fire", Size = 15}}})
			task.spawn(function()
				task.wait(0.3)
				pcall(function() _({"Remove", {fx}}) end)
			end)
		end
	end
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local otherChar = other.Character
			if otherChar then
				local otherHRP = otherChar:FindFirstChild("HumanoidRootPart")
				local otherHumanoid = otherChar:FindFirstChildOfClass("Humanoid")
				if otherHRP and otherHumanoid and otherHumanoid.Health > 0 then
					local toOther = otherHRP.Position - origin
					local dist = toOther.Magnitude
					local dot = dir:Dot(Vector3.new(toOther.X, 0, toOther.Z).Unit)
					if dist < PUNCH_RANGE and dot > 0.3 then
						knockback(otherHRP, toOther)
						dealDamage(otherHumanoid, PUNCH_DAMAGE)
						pcall(function() runSilent("punish " .. other.Name) end)
						logf("punched", other.Name)
					end
				end
			end
		end
	end
end

local function spawnSpikes()
	local now = tick()
	if now - jdState.lastSpike < COOLDOWN then return end
	jdState.lastSpike = now
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	task.spawn(animSpikes)
	local targetPos = getMouseWorldPosition()
	local dir = (targetPos - hrp.Position)
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude < 0.1 then dir = hrp.CFrame.LookVector end
	dir = dir.Unit
	local remote = getink F3Xgui v67Remote()
	if not remote then return end
	local function _(args) pcall(function() remote:InvokeServer(unpack(args)) end) end
	logf("spikes fired")
	for i = 1, 5 do
		local offset = dir * (4 + i * 3)
		local spikePos = hrp.Position + offset + Vector3.new(0, 1, 0)
		local spike = spawnink F3Xgui v67Part(remote, CFrame.new(spikePos), workspace)
		if spike then
			_({"SetName", {spike}, "JDSpike"})
			_({"SyncCollision", {{Part = spike, CanCollide = true}}})
			_({"SyncAnchor", {{Part = spike}, true}})
			_({"SyncResize", {{Part = spike, CFrame = spike.CFrame, Size = Vector3.new(1.5, 3, 1.5)}}})
			_({"SyncColor", {{Part = spike, Color = Color3.fromRGB(80, 80, 80), UnionColoring = false}}})
			_({"CreateDecorations", {{Part = spike, DecorationType = "Fire"}}})
			_({"SyncDecorate", {{Part = spike, DecorationType = "Fire", Size = 5}}})
			local hit = false
			local conn
			conn = spike.Touched:Connect(function(part)
				if hit then return end
				local model = part:FindFirstAncestorOfClass("Model")
				if not model then return end
				local plr = Players:GetPlayerFromCharacter(model)
				if not plr or plr == player then return end
				local h = model:FindFirstChildOfClass("Humanoid")
				if h and h.Health > 0 then
					hit = true
					dealDamage(h, SPIKE_DAMAGE)
					pcall(function() runSilent("damage " .. plr.Name .. " " .. SPIKE_DAMAGE) end)
					logf("spike hit", plr.Name)
					if conn then conn:Disconnect() end
				end
			end)
			task.spawn(function()
				task.wait(SPIKE_LIFETIME)
				if conn then conn:Disconnect() end
				pcall(function() _({"Remove", {spike}}) end)
			end)
		end
		task.wait(0.05)
	end
end

local function spawnTrap()
	local now = tick()
	if now - jdState.lastTrap < COOLDOWN * 2 then return end
	jdState.lastTrap = now
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	task.spawn(animTrap)
	local targetPos = getMouseWorldPosition()
	local fieldPos = Vector3.new(targetPos.X, targetPos.Y + 0.5, targetPos.Z)
	local remote = getink F3Xgui v67Remote()
	if not remote then return end
	local function _(args) pcall(function() remote:InvokeServer(unpack(args)) end) end
	logf("trap fired")
	local field = spawnink F3Xgui v67Part(remote, CFrame.new(fieldPos), workspace)
	if not field then return end
	_({"SetName", {field}, "JDTrapField"})
	_({"SyncCollision", {{Part = field, CanCollide = false}}})
	_({"SyncAnchor", {{Part = field}, true}})
	_({"SyncResize", {{Part = field, CFrame = field.CFrame, Size = Vector3.new(12, 0.2, 12)}}})
	_({"SyncColor", {{Part = field, Color = Color3.fromRGB(120, 0, 200), UnionColoring = false}}})
	_({"SyncMaterial", {{Part = field, Transparency = 0.3}}})
	_({"CreateDecorations", {{Part = field, DecorationType = "ParticleEmitter"}}})
	_({"SyncDecorate", {{
		Part = field, DecorationType = "ParticleEmitter",
		Rate = "100", SpreadAngle = "18000", RotSpeed = "15",
		Texture = TRAP_TEXTURE, Speed = "3", Size = "2"
	}}})
	local trap = { field = field, position = fieldPos, hitters = {} }
	table.insert(jdState.activeTraps, trap)
	local detector = RunService.Heartbeat:Connect(function()
		if not field or not field.Parent then detector:Disconnect() return end
		for _, other in ipairs(Players:GetPlayers()) do
			if other ~= player then
				local otherChar = other.Character
				if otherChar then
					local otherHRP = otherChar:FindFirstChild("HumanoidRootPart")
					if otherHRP then
						local dist = (Vector3.new(otherHRP.Position.X, 0, otherHRP.Position.Z) 
						           - Vector3.new(fieldPos.X, 0, fieldPos.Z)).Magnitude
						if dist < 6 then
							if not trap.hitters[other] then
								trap.hitters[other] = TRAP_DURATION
								logf("trap caught", other.Name)
							end
						end
					end
				end
			end
		end
	end)
	task.spawn(function()
		local lifeTimer = TRAP_FIELD_LIFE
		while lifeTimer > 0 and field and field.Parent do
			task.wait(TRAP_TICK)
			lifeTimer = lifeTimer - TRAP_TICK
			for plr, timeLeft in pairs(trap.hitters) do
				if timeLeft > 0 then
					local otherChar = plr.Character
					if otherChar then
						local h = otherChar:FindFirstChildOfClass("Humanoid")
						if h and h.Health > 0 then
							dealDamage(h, TRAP_DAMAGE)
							pcall(function() runSilent("damage " .. plr.Name .. " " .. TRAP_DAMAGE) end)
						end
					end
					trap.hitters[plr] = timeLeft - TRAP_TICK
					if trap.hitters[plr] <= 0 then trap.hitters[plr] = nil end
				end
			end
		end
		if field and field.Parent then
			pcall(function() _({"Remove", {field}}) end)
		end
		detector:Disconnect()
	end)
end

local function ability404()
	local now = tick()
	if now - jdState.last404 < COOLDOWN * 2 then return end
	jdState.last404 = now
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	task.spawn(anim404)
	logf("404 speed fired")
	local boostConn
	local t0 = tick()
	boostConn = RunService.Heartbeat:Connect(function()
		if tick() - t0 > SPEED_404_TIME then boostConn:Disconnect() return end
		if char and char.Parent then
			local h = char:FindFirstChildOfClass("Humanoid")
			local h2 = char:FindFirstChild("HumanoidRootPart")
			if h and h2 then
				local moveDir = h.MoveDirection
				if moveDir.Magnitude > 0.1 then
					h2.AssemblyLinearVelocity = Vector3.new(
						h2.AssemblyLinearVelocity.X + moveDir.X * SPEED_404_BOOST * 0.1,
						h2.AssemblyLinearVelocity.Y,
						h2.AssemblyLinearVelocity.Z + moveDir.Z * SPEED_404_BOOST * 0.1
					)
				end
			end
		end
	end)
end

local function toggleJohnDoe()
	if jdState.active then cleanupJohnDoe() return end
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		logf("PC only")
		return
	end
	local remote = getink F3Xgui v67Remote()
	if not remote then
		logf("giving btools + f3x...")
		giveBtools()
		remote = waitForink F3Xgui v67(6)
		if not remote then
			logf("no ink F3Xgui v67 — visual effects won't be visible to others")
		end
	end
	jdState.active = true
	showHud()
	table.insert(jdState.conns, UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then punch() end
	end))
	table.insert(jdState.conns, UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Q then spawnSpikes() end
	end))
	table.insert(jdState.conns, UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.E then spawnTrap() end
	end))
	table.insert(jdState.conns, UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.R then ability404() end
	end))
	table.insert(jdState.conns, UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.F then cleanupJohnDoe() end
	end))
	logf("enabled")
end

-- ============================================================
-- My Realm
-- ============================================================
local function playMyRealm()
	runSilent("btools me")
	task.wait(0.4)
	runSilent("punish all")
	task.wait(0.1)

	local char = player.Character
	local backpack = player:FindFirstChild("Backpack")

	local function getf3x()
		if backpack then
			for _, v in ipairs(backpack:GetChildren()) do
				if v:FindFirstChild("SyncAPI") then return v end
			end
		end
		if char then
			for _, v in ipairs(char:GetChildren()) do
				if v:FindFirstChild("SyncAPI") then return v end
			end
		end
		return nil
	end

	local f3x = getf3x()
	if not f3x then
		warn("[My Realm] you dont have f3x skid")
		return
	end
	local syncapi = f3x.SyncAPI
	local serverendpoint = syncapi.ServerEndpoint

	local function delete(part) pcall(function() serverendpoint:InvokeServer("Remove", { part }) end) end

	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("UnionOperation") then
			task.spawn(function() delete(v) end)
		end
	end
	task.wait(0.3)

	runSilent("fogcolor black")
	runSilent("time")

	local function resize(part, size, cf)
		pcall(function() serverendpoint:InvokeServer("SyncResize", {{ Part = part, CFrame = cf, Size = size }}) end)
	end
	local function syncmaterial(part, mate)
		pcall(function() serverendpoint:InvokeServer("SyncMaterial", {{ Part = part, Material = mate }}) end)
	end
	local function transparency(part, trans)
		pcall(function() serverendpoint:InvokeServer("SyncMaterial", {{ Part = part, Transparency = trans }}) end)
	end
	local function color(part, c)
		pcall(function() serverendpoint:InvokeServer("SyncColor", {{ Part = part, Color = c, UnionColoring = false }}) end)
	end
	local function syncmeshid(part, id)
		pcall(function() serverendpoint:InvokeServer("SyncMesh", {{ Part = part, MeshId = "rbxassetid://" .. id }}) end)
	end
	local function makemesh(part)
		pcall(function() serverendpoint:InvokeServer("CreateMeshes", {{ Part = part }}) end)
	end
	local function syncmeshsize(part, vec)
		pcall(function() serverendpoint:InvokeServer("SyncMesh", {{ Part = part, Scale = vec }}) end)
	end
	local function syncmeshtexture(part, id)
		pcall(function() serverendpoint:InvokeServer("SyncMesh", {{ Part = part, TextureId = "rbxassetid://" .. id }}) end)
	end
	local function name(part, s) pcall(function() serverendpoint:InvokeServer("SetName", { part }, s) end) end
	local function lock(part, b) pcall(function() serverendpoint:InvokeServer("SetLocked", { part }, b) end) end
	local function setcollision(part, b)
		pcall(function() serverendpoint:InvokeServer("SyncCollision", {{ Part = part, CanCollide = b }}) end)
	end
	local function createdecal(part, side)
		pcall(function() serverendpoint:InvokeServer("CreateTextures", {{ Part = part, Face = side, TextureType = "Decal" }}) end)
	end
	local function setdecal(part, asset, side)
		pcall(function() serverendpoint:InvokeServer("SyncTexture", {{ Part = part, Face = side, TextureType = "Decal", Texture = "rbxassetid://" .. asset }}) end)
	end

	local function makerealmbase()
		local position = CFrame.new(0, 5, 0)
		local base = serverendpoint:InvokeServer("CreatePart", "Normal", position, workspace)
		resize(base, Vector3.new(512, 16, 512), position)
		syncmaterial(base, Enum.Material.Concrete)
		color(base, Color3.new(0.513725, 0.513725, 0.513725))
		name(base, "loltroll")
		lock(base, true)

		local spawnpos = CFrame.new(34.5, 8.1, -26)
		local spawna = serverendpoint:InvokeServer("CreatePart", "Spawn", spawnpos, workspace)
		resize(spawna, Vector3.new(20, 10, 20), spawnpos)
		name(spawna, "SpawnLocation")
		lock(spawna, true)
		createdecal(spawna, Enum.NormalId.Top)
		setdecal(spawna, WORLD_TOUR_DECAL_ID, Enum.NormalId.Top)
		transparency(spawna, 1)

		local pos1 = CFrame.new(74.143, 24, -25.232)
		local rules = serverendpoint:InvokeServer("CreatePart", "Normal", pos1, workspace)
		transparency(rules, 0)
		setcollision(rules, false)
		createdecal(rules, Enum.NormalId.Left)
		setdecal(rules, WORLD_TOUR_DECAL_ID, Enum.NormalId.Left)
		color(rules, Color3.fromRGB(235, 235, 235))
		resize(rules, Vector3.new(4, 23, 37), pos1)

		local pos2 = CFrame.new(1.143, 24, -25.232)
		local bad = serverendpoint:InvokeServer("CreatePart", "Normal", pos2, workspace)
		transparency(bad, 1)
		setcollision(bad, false)
		createdecal(bad, Enum.NormalId.Right)
		setdecal(bad, "74015851400423", Enum.NormalId.Right)
		resize(bad, Vector3.new(4, 23, 37), pos2)
	end

	local function sky()
		local position = CFrame.new(0, 5, 0)
		local sky = serverendpoint:InvokeServer("CreatePart", "Normal", position, workspace)
		makemesh(sky)
		syncmeshid(sky, "111891702759441")
		syncmeshtexture(sky, SKYBOX_TEXTURE_ID)
		syncmeshsize(sky, Vector3.new(20000, 20000, 20000))
		lock(sky, true)
		name(sky, "Sky")
		setcollision(sky, false)
	end

	sky()
	makerealmbase()

	runSilent("res all")
	task.wait(0.3)
	runSilent("r6 all")
	runSilent("time 14")
	task.wait(0.7)

	runSilent("music " .. REALM_MUSIC_ID)
	task.wait(0.3)
	runSilent("volume inf")

	task.spawn(function()
		task.wait(4)
		runSilent("music " .. currentMusicID)
		task.wait(0.3)
		runSilent("volume inf")
	end)
end

local function spamDecalByID(decalID)
	local remote = getink F3Xgui v67Remote()
	if not remote then warn("[ink F3Xgui v67] ServerEndpoint not found - press ink F3Xgui v67 first") return end
	local function fire(args) pcall(function() remote:InvokeServer(unpack(args)) end) end
	local faces = {
		Enum.NormalId.Front, Enum.NormalId.Back,
		Enum.NormalId.Left,  Enum.NormalId.Right,
		Enum.NormalId.Top,   Enum.NormalId.Bottom,
	}
	task.spawn(function()
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				task.spawn(function()
					fire({"SetLocked", {v}, false})
					for _, f in ipairs(faces) do
						fire({"CreateTextures", {{Part = v, Face = f, TextureType = "Decal"}}})
						fire({"SyncTexture", {{
							Part = v, Face = f, TextureType = "Decal",
							Texture = "rbxassetid://" .. decalID
						}}})
					end
				end)
				task.wait(SPAM_DELAY)
			end
		end
	end)
end

local function spamDecals()  spamDecalByID(WORLD_TOUR_DECAL_ID)  end
local function spamMyDecal() spamDecalByID(currentMyDecalID)      end

local function spawnWorldTourSkybox()
	spawnSkyboxWithID("104436172542890", "天空盒1")
end

-- ============================================================
-- UNANCHOR ALL (МАКСИМАЛЬНО БЫСТРАЯ ВЕРСИЯ)
-- ============================================================
local function unanchorAll()
	local remote = getink F3Xgui v67Remote()
	if not remote then
		warn("[Unanchor All] ink F3Xgui v67 not found — click [ink F3Xgui v67] first")
		return
	end

	local function fire(args)
		pcall(function() remote:InvokeServer(unpack(args)) end)
	end

	task.spawn(function()
		local parts = {}
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				parts[#parts + 1] = v
			end
		end

		local total = #parts
		print("[Unanchor All] Найдено частей:", total)
		local t0 = tick()

		if total == 0 then
			print("[Unanchor All] Нечего откреплять.")
			return
		end

		local completed = 0

		for i = 1, total do
			local part = parts[i]
			task.spawn(function()
				if part and part.Parent then
					fire({"SyncAnchor", {{Part = part}, false}})
					fire({"SetLocked", {part}, false})
				end
				completed = completed + 1
			end)
		end

		while completed < total do
			task.wait()
		end

		local elapsed = tick() - t0
		print(string.format("[Unanchor All] Карта откреплена за %.2f сек! (%d частей)", elapsed, total))
	end)
end

-- ============================================================
-- GUI (GRID LAYOUT)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MikeMercuF3xGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, 400)
MainFrame.Position = UDim2.new(0.5, -GUI_WIDTH/2, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui
addStroke(MainFrame, 2)

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "BackgroundImage"
BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
BackgroundImage.Position = UDim2.new(0, 0, 0, 0)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = BACKGROUND_DECAL
BackgroundImage.ScaleType = Enum.ScaleType.Crop
BackgroundImage.ZIndex = 0
BackgroundImage.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -PAD*2, 1, 0)
ContentFrame.Position = UDim2.new(0, 0, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 28)
Title.Position = UDim2.new(0, PAD, 0, PAD)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Text = "MikeMercu F3x GUI v3"
Title.TextColor3 = PURPLE
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.ZIndex = 3
Title.Parent = ContentFrame

local giveBtoolsBtn = Instance.new("TextButton")
giveBtoolsBtn.Size = UDim2.new(0, 50, 0, 24)
giveBtoolsBtn.Position = UDim2.new(0, PAD, 0, PAD + 2)
giveBtoolsBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
giveBtoolsBtn.BackgroundTransparency = 0.3
giveBtoolsBtn.BorderSizePixel = 0
giveBtoolsBtn.Font = Enum.Font.SourceSansBold
giveBtoolsBtn.Text = "give\nF3x"
giveBtoolsBtn.TextColor3 = PURPLE
giveBtoolsBtn.TextSize = 10
giveBtoolsBtn.ZIndex = 5
giveBtoolsBtn.Parent = ContentFrame
addStroke(giveBtoolsBtn, 1.2)

local clearSkyboxBtn = Instance.new("TextButton")
clearSkyboxBtn.Size = UDim2.new(0, 90, 0, 24)
clearSkyboxBtn.Position = UDim2.new(1, -90 - PAD, 0, PAD + 2)
clearSkyboxBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
clearSkyboxBtn.BackgroundTransparency = 0.3
clearSkyboxBtn.BorderSizePixel = 0
clearSkyboxBtn.Font = Enum.Font.SourceSansBold
clearSkyboxBtn.Text = "Clear Skybox"
clearSkyboxBtn.TextColor3 = PURPLE
clearSkyboxBtn.TextSize = 10
clearSkyboxBtn.ZIndex = 5
clearSkyboxBtn.Parent = ContentFrame
addStroke(clearSkyboxBtn, 1.2)

-- ============================================================
-- GRID SECTIONS
-- ============================================================
local sections = {}
local allButtons = {}

local function makeGridSection(parent, yPos, title)
	local header = Instance.new("TextLabel")
	header.Name = "Header_" .. title
	header.Size = UDim2.new(1, -PAD*2, 0, HEADER_H)
	header.Position = UDim2.new(0, PAD, 0, yPos)
	header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	header.BackgroundTransparency = 0.35
	header.BorderSizePixel = 0
	header.Font = Enum.Font.SourceSansBold
	header.Text = title
	header.TextColor3 = PURPLE
	header.TextSize = 14
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.ZIndex = 3
	header.Active = false
	header.Selectable = false
	header.Parent = parent
	addStroke(header, 1.2)

	local container = Instance.new("Frame")
	container.Name = "Grid_" .. title
	container.Size = UDim2.new(1, -PAD*2, 0, 0)
	container.Position = UDim2.new(0, PAD, 0, yPos + HEADER_H + 2)
	container.BackgroundTransparency = 1
	container.ZIndex = 3
	container.Parent = parent

	local section = {
		header = header,
		container = container,
		buttons = {},
		rows = 0,
		yPos = yPos,
	}
	table.insert(sections, section)
	return section
end

local function addGridButton(section, text, callback)
	local idx = #section.buttons
	local col = idx % COLS
	local row = math.floor(idx / COLS)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
	btn.Position = UDim2.new(0, col * (BTN_W + BTN_GAP_X), 0, row * (BTN_H + BTN_GAP_Y))
	btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	btn.BackgroundTransparency = 0.35
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.SourceSansBold
	btn.Text = text
	btn.TextColor3 = PURPLE
	btn.TextSize = 12
	btn.ZIndex = 4
	btn.TextWrapped = true
	btn.Parent = section.container
	addStroke(btn, 1.2)
	if callback then btn.MouseButton1Click:Connect(callback) end

	table.insert(section.buttons, btn)
	table.insert(allButtons, btn)

	local totalRows = math.ceil(#section.buttons / COLS)
	section.container.Size = UDim2.new(1, -PAD*2, 0, totalRows * (BTN_H + BTN_GAP_Y) - BTN_GAP_Y)

	return btn
end

local function finalizeLayout()
	local y = PAD + 30
	for _, sec in ipairs(sections) do
		sec.header.Position = UDim2.new(0, PAD, 0, y)
		sec.container.Position = UDim2.new(0, PAD, 0, y + HEADER_H + 2)
		y = y + HEADER_H + 2 + sec.container.Size.Y.Offset + SECTION_GAP
	end
	local totalH = y - SECTION_GAP + PAD
	MainFrame.Size = UDim2.new(0, GUI_WIDTH, 0, totalH)
	return totalH
end

-- ============================================================
-- СЕКЦИЯ 1: Skybox & Decal
-- ============================================================
local sec1 = makeGridSection(ContentFrame, 0, "Skybox & Decal")
addGridButton(sec1, "贴图1",  spamDecals)
addGridButton(sec1, "天空盒1", spawnWorldTourSkybox)
addGridButton(sec1, "我的贴图", spamMyDecal)
addGridButton(sec1, "我的天空盒", spawnMySkybox)
addGridButton(sec1, "贴图3", spamYaaiDecal)
addGridButton(sec1, "贴图4", spamMarioExeDecal)
addGridButton(sec1, "贴图5", spamTrollDecal)
addGridButton(sec1, "天空盒3", spawnMarioExeSkybox)
addGridButton(sec1, "天空盒4", spawnTrollSkybox)
addGridButton(sec1, "天空盒5", spawnYaaiSkybox)
addGridButton(sec1, "贴图6", spamMikeMercuRetDecal)
addGridButton(sec1, "天空盒6", spawnMikeMercuRetSkybox)
addGridButton(sec1, "贴图7", spamGobbyDoolanDecal)
addGridButton(sec1, "天空盒7", spawnGobbyDoolanSkybox)

-- ============================================================
-- СЕКЦИЯ 2: Music
-- ============================================================
local sec2 = makeGridSection(ContentFrame, 0, "Music")
addGridButton(sec2, "My Theme",                playMusic)
addGridButton(sec2, "Hardbass",                playHardbass)
addGridButton(sec2, "Tubers 93",               playTubers93)
addGridButton(sec2, "This Is Sparta (slowed)", playSparta)
addGridButton(sec2, "Troll Music (slowed)",    playTrollMusic)
addGridButton(sec2, "Nightcore",               playNightcore)
addGridButton(sec2, "Realm Music",             playRealmMusic)
addGridButton(sec2, "Title",                   playTitle)

local idiotBtn = addGridButton(sec2, "You Are An Idiot!", function() end)
idiotBtn.MouseButton1Click:Connect(function()
	toggleIdiotMusic(idiotBtn)
end)

-- ============================================================
-- СЕКЦИЯ 3: Maps
-- ============================================================
local sec3 = makeGridSection(ContentFrame, 0, "Maps")
addGridButton(sec3, "My Realm",     playMyRealm)
addGridButton(sec3, "Unanchor All", unanchorAll)

-- ============================================================
-- СЕКЦИЯ 4: Particles
-- ============================================================
local sec4 = makeGridSection(ContentFrame, 0, "Particles")

local trollParticlesState = { active = false }
local toadRainState       = { active = false }
local particlesState      = { active = false }
local marioPartState      = { active = false }
local yaaiPartState       = { active = false }
local wtPartState         = { active = false }

local function onTrollParticlesClick(btn)
	trollParticlesState.active = not trollParticlesState.active
	btn.Text = trollParticlesState.active and "Troll Particles: ON" or "Troll Particles: OFF"
	if trollParticlesState.active then
		spamParticlesOnEverything("TrollParticles", {
			Texture = "rbxassetid://" .. TROLL_DECAL_ID,
			Rate = "5000", SpreadAngle = "18000", RotSpeed = "10",
			Speed = "24", Size = "6"
		})
	else
		clearParticlesFromEverything("TrollParticles")
	end
end

local function onToadRainClick(btn)
	toadRainState.active = not toadRainState.active
	btn.Text = toadRainState.active and "ToadRain: ON" or "ToadRain: OFF"
	if toadRainState.active then
		spamParticlesOnEverything("ToadRain", {
			Texture = "rbxassetid://1009824086",
			Rate = "5000", SpreadAngle = "18000", RotSpeed = "10",
			Speed = "20", Size = "4"
		})
	else
		clearParticlesFromEverything("ToadRain")
	end
end

local function onParticlesClick(btn)
	particlesState.active = not particlesState.active
	btn.Text = particlesState.active and "Particles: ON" or "Particles: OFF"
	if particlesState.active then
		spamParticlesOnEverything("Particles", {
			Texture = "rbxassetid://" .. currentMyDecalID,
			Rate = "5000", SpreadAngle = "18000", RotSpeed = "10",
			Speed = "24", Size = "1"
		})
	else
		clearParticlesFromEverything("Particles")
	end
end

local function onMarioExeParticlesClick(btn)
	marioPartState.active = not marioPartState.active
	btn.Text = marioPartState.active and "Mario.exe Particles: ON" or "Mario.exe Particles"
	if marioPartState.active then
		spamParticlesOnEverything("Mario.exe", { Texture = "rbxassetid://" .. MARIO_EXE_DECAL_ID })
	else
		clearParticlesFromEverything("Mario.exe")
	end
end

local function onYaaiParticlesClick(btn)
	yaaiPartState.active = not yaaiPartState.active
	btn.Text = yaaiPartState.active and "Yaai Particles: ON" or "Yaai Particles"
	if yaaiPartState.active then
		spamParticlesOnEverything("Yaai", { Texture = "rbxassetid://" .. YAAI_DECAL_ID })
	else
		clearParticlesFromEverything("Yaai")
	end
end

local function onWorldTourParticlesClick(btn)
	wtPartState.active = not wtPartState.active
	btn.Text = wtPartState.active and "World Tour Particles: ON" or "MikeMercu World Tour Particles"
	if wtPartState.active then
		spamParticlesOnEverything("WorldTour", { Texture = "rbxassetid://" .. WORLD_TOUR_DECAL_ID })
	else
		clearParticlesFromEverything("WorldTour")
	end
end

local trollPartBtn = addGridButton(sec4, "Troll Particles", function() end)
trollPartBtn.MouseButton1Click:Connect(function() onTrollParticlesClick(trollPartBtn) end)

local toadBtn = addGridButton(sec4, "ToadRain", function() end)
toadBtn.MouseButton1Click:Connect(function() onToadRainClick(toadBtn) end)

local partBtn = addGridButton(sec4, "Particles", function() end)
partBtn.MouseButton1Click:Connect(function() onParticlesClick(partBtn) end)

local marioPartBtn = addGridButton(sec4, "Mario.exe Particles", function() end)
marioPartBtn.MouseButton1Click:Connect(function() onMarioExeParticlesClick(marioPartBtn) end)

local yaaiPartBtn = addGridButton(sec4, "Yaai Particles", function() end)
yaaiPartBtn.MouseButton1Click:Connect(function() onYaaiParticlesClick(yaaiPartBtn) end)

local wtPartBtn = addGridButton(sec4, "World Tour Particles", function() end)
wtPartBtn.MouseButton1Click:Connect(function() onWorldTourParticlesClick(wtPartBtn) end)

-- ============================================================
-- СЕКЦИЯ 5: Fun
-- ============================================================
local sec5 = makeGridSection(ContentFrame, 0, "Fun")
local johnDoeBtn = addGridButton(sec5, "John Doe", function() end)
johnDoeBtn.MouseButton1Click:Connect(function()
	toggleJohnDoe()
	johnDoeBtn.Text = jdState.active and "John Doe: ON" or "John Doe"
end)

finalizeLayout()

-- ============================================================
-- ID PANEL
-- ============================================================
local ArrowButton = Instance.new("TextButton")
ArrowButton.Name = "ArrowButton"
ArrowButton.Size = UDim2.new(0, ARROW_W, 1, 0)
ArrowButton.Position = UDim2.new(1, -ARROW_W, 0, 0)
ArrowButton.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
ArrowButton.BackgroundTransparency = 0.2
ArrowButton.BorderSizePixel = 0
ArrowButton.Font = Enum.Font.SourceSansBold
ArrowButton.Text = "►"
ArrowButton.TextColor3 = PURPLE
ArrowButton.TextSize = 11
ArrowButton.ZIndex = 10
ArrowButton.Parent = MainFrame
addStroke(ArrowButton, 1)

local SlidePanel = Instance.new("Frame")
SlidePanel.Name = "SlidePanel"
SlidePanel.Size = UDim2.new(0, PANEL_W, 1, 0)
SlidePanel.Position = UDim2.new(1, 0, 0, 0)
SlidePanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SlidePanel.BackgroundTransparency = 0.15
SlidePanel.BorderSizePixel = 0
SlidePanel.ClipsDescendants = false
SlidePanel.Visible = false
SlidePanel.Active = false
SlidePanel.Selectable = false
SlidePanel.ZIndex = 20
SlidePanel.Parent = MainFrame
addStroke(SlidePanel, 1.5)

local PanelTitle = Instance.new("TextLabel")
PanelTitle.Size = UDim2.new(1, -12, 0, 16)
PanelTitle.Position = UDim2.new(0, 6, 0, 4)
PanelTitle.BackgroundTransparency = 1
PanelTitle.Font = Enum.Font.SourceSansBold
PanelTitle.Text = "Settings"
PanelTitle.TextColor3 = PURPLE
PanelTitle.TextSize = 11
PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
PanelTitle.ZIndex = 21
PanelTitle.Parent = SlidePanel

local MyDecalLabel = Instance.new("TextLabel")
MyDecalLabel.Size = UDim2.new(1, -12, 0, 12)
MyDecalLabel.Position = UDim2.new(0, 6, 0, 24)
MyDecalLabel.BackgroundTransparency = 1
MyDecalLabel.Font = Enum.Font.SourceSans
MyDecalLabel.Text = "我的贴图 ID"
MyDecalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MyDecalLabel.TextSize = 10
MyDecalLabel.TextXAlignment = Enum.TextXAlignment.Left
MyDecalLabel.ZIndex = 21
MyDecalLabel.Parent = SlidePanel

local MyDecalBox = Instance.new("TextBox")
MyDecalBox.Name = "MyDecalBox"
MyDecalBox.Size = UDim2.new(1, -12, 0, 18)
MyDecalBox.Position = UDim2.new(0, 6, 0, 38)
MyDecalBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MyDecalBox.BorderSizePixel = 0
MyDecalBox.Font = Enum.Font.SourceSans
MyDecalBox.Text = currentMyDecalID
MyDecalBox.PlaceholderText = "asset id"
MyDecalBox.TextColor3 = PURPLE
MyDecalBox.TextSize = 10
MyDecalBox.ClearTextOnFocus = false
MyDecalBox.ZIndex = 21
MyDecalBox.Parent = SlidePanel
addStroke(MyDecalBox, 1)

local MyThemeLabel = Instance.new("TextLabel")
MyThemeLabel.Size = UDim2.new(1, -12, 0, 12)
MyThemeLabel.Position = UDim2.new(0, 6, 0, 62)
MyThemeLabel.BackgroundTransparency = 1
MyThemeLabel.Font = Enum.Font.SourceSans
MyThemeLabel.Text = "My Theme ID"
MyThemeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
MyThemeLabel.TextSize = 10
MyThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
MyThemeLabel.ZIndex = 21
MyThemeLabel.Parent = SlidePanel

local MyThemeBox = Instance.new("TextBox")
MyThemeBox.Name = "MyThemeBox"
MyThemeBox.Size = UDim2.new(1, -12, 0, 18)
MyThemeBox.Position = UDim2.new(0, 6, 0, 76)
MyThemeBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MyThemeBox.BorderSizePixel = 0
MyThemeBox.Font = Enum.Font.SourceSans
MyThemeBox.Text = currentMusicID
MyThemeBox.PlaceholderText = "asset id"
MyThemeBox.TextColor3 = PURPLE
MyThemeBox.TextSize = 10
MyThemeBox.ClearTextOnFocus = false
MyThemeBox.ZIndex = 21
MyThemeBox.Parent = SlidePanel
addStroke(MyThemeBox, 1)

local WalkSpeedLabel = Instance.new("TextLabel")
WalkSpeedLabel.Size = UDim2.new(1, -12, 0, 12)
WalkSpeedLabel.Position = UDim2.new(0, 6, 0, 100)
WalkSpeedLabel.BackgroundTransparency = 1
WalkSpeedLabel.Font = Enum.Font.SourceSans
WalkSpeedLabel.Text = "WalkSpeed"
WalkSpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
WalkSpeedLabel.TextSize = 10
WalkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkSpeedLabel.ZIndex = 21
WalkSpeedLabel.Parent = SlidePanel

local WalkSpeedBox = Instance.new("TextBox")
WalkSpeedBox.Name = "WalkSpeedBox"
WalkSpeedBox.Size = UDim2.new(1, -12, 0, 18)
WalkSpeedBox.Position = UDim2.new(0, 6, 0, 114)
WalkSpeedBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
WalkSpeedBox.BorderSizePixel = 0
WalkSpeedBox.Font = Enum.Font.SourceSans
WalkSpeedBox.Text = "16"
WalkSpeedBox.PlaceholderText = "16"
WalkSpeedBox.TextColor3 = PURPLE
WalkSpeedBox.TextSize = 10
WalkSpeedBox.ClearTextOnFocus = false
WalkSpeedBox.ZIndex = 21
WalkSpeedBox.Parent = SlidePanel
addStroke(WalkSpeedBox, 1)

local JumpPowerLabel = Instance.new("TextLabel")
JumpPowerLabel.Size = UDim2.new(1, -12, 0, 12)
JumpPowerLabel.Position = UDim2.new(0, 6, 0, 138)
JumpPowerLabel.BackgroundTransparency = 1
JumpPowerLabel.Font = Enum.Font.SourceSans
JumpPowerLabel.Text = "JumpPower"
JumpPowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
JumpPowerLabel.TextSize = 10
JumpPowerLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpPowerLabel.ZIndex = 21
JumpPowerLabel.Parent = SlidePanel

local JumpPowerBox = Instance.new("TextBox")
JumpPowerBox.Name = "JumpPowerBox"
JumpPowerBox.Size = UDim2.new(1, -12, 0, 18)
JumpPowerBox.Position = UDim2.new(0, 6, 0, 152)
JumpPowerBox.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
JumpPowerBox.BorderSizePixel = 0
JumpPowerBox.Font = Enum.Font.SourceSans
JumpPowerBox.Text = "50"
JumpPowerBox.PlaceholderText = "50"
JumpPowerBox.TextColor3 = PURPLE
JumpPowerBox.TextSize = 10
JumpPowerBox.ClearTextOnFocus = false
JumpPowerBox.ZIndex = 21
JumpPowerBox.Parent = SlidePanel
addStroke(JumpPowerBox, 1)

local ApplyButton = Instance.new("TextButton")
ApplyButton.Name = "ApplyButton"
ApplyButton.Size = UDim2.new(1, -12, 0, 20)
ApplyButton.Position = UDim2.new(0, 6, 0, 178)
ApplyButton.BackgroundColor3 = Color3.fromRGB(60, 0, 90)
ApplyButton.BorderSizePixel = 0
ApplyButton.Font = Enum.Font.SourceSansBold
ApplyButton.Text = "Apply"
ApplyButton.TextColor3 = PURPLE
ApplyButton.TextSize = 10
ApplyButton.ZIndex = 21
ApplyButton.Parent = SlidePanel
addStroke(ApplyButton, 1)

local ResetButton = Instance.new("TextButton")
ResetButton.Name = "ResetButton"
ResetButton.Size = UDim2.new(1, -12, 0, 18)
ResetButton.Position = UDim2.new(0, 6, 0, 202)
ResetButton.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
ResetButton.BorderSizePixel = 0
ResetButton.Font = Enum.Font.SourceSansBold
ResetButton.Text = "Reset speed/jump"
ResetButton.TextColor3 = PURPLE
ResetButton.TextSize = 10
ResetButton.ZIndex = 21
ResetButton.Parent = SlidePanel
addStroke(ResetButton, 1)

ApplyButton.MouseButton1Click:Connect(function()
	local decalRaw = string.match(MyDecalBox.Text or "", "%d+")
	if decalRaw then currentMyDecalID = decalRaw; MyDecalBox.Text = decalRaw end
	local themeRaw = string.match(MyThemeBox.Text or "", "%d+")
	if themeRaw then currentMusicID = themeRaw; MyThemeBox.Text = themeRaw end

	local ws = tonumber(WalkSpeedBox.Text)
	local char = player.Character
	if char then
		local h = char:FindFirstChildOfClass("Humanoid")
		if h and ws then
			h.WalkSpeed = math.clamp(ws, 0, 1000)
		end
		local jp = tonumber(JumpPowerBox.Text)
		if h and jp then
			pcall(function() h.UseJumpPower = true end)
			h.JumpPower = math.clamp(jp, 0, 1000)
		end
	end
end)

ResetButton.MouseButton1Click:Connect(function()
	local char = player.Character
	if char then
		local h = char:FindFirstChildOfClass("Humanoid")
		if h then
			h.WalkSpeed = 16
			h.JumpPower = 50
			WalkSpeedBox.Text = "16"
			JumpPowerBox.Text = "50"
		end
	end
end)

MyDecalBox.FocusLost:Connect(function()
	local raw = string.match(MyDecalBox.Text or "", "%d+")
	if raw then currentMyDecalID = raw; MyDecalBox.Text = raw
	else MyDecalBox.Text = currentMyDecalID end
end)
MyThemeBox.FocusLost:Connect(function()
	local raw = string.match(MyThemeBox.Text or "", "%d+")
	if raw then currentMusicID = raw; MyThemeBox.Text = raw
	else MyThemeBox.Text = currentMusicID end
end)

-- ============================================================
-- ARROW TOGGLE
-- ============================================================
local isPanelOpen = false
local isAnimating = false
local basePosition = UDim2.new(0.5, -GUI_WIDTH/2, 0.15, 0)

ArrowButton.MouseButton1Click:Connect(function()
	if isAnimating then return end
	isAnimating = true

	isPanelOpen = not isPanelOpen
	ArrowButton.Text = isPanelOpen and "◄" or "►"

	local targetPos
	if isPanelOpen then
		targetPos = UDim2.new(0.5, -GUI_WIDTH/2 - PANEL_W, 0.15, 0)
		SlidePanel.Visible = true
		SlidePanel.Active = true
		SlidePanel.Selectable = true
	else
		targetPos = basePosition
		SlidePanel.Visible = false
		SlidePanel.Active = false
		SlidePanel.Selectable = false
	end

	local tween = TweenService:Create(
		MainFrame,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = targetPos }
	)
	tween.Completed:Connect(function()
		isAnimating = false
	end)
	tween:Play()
end)

giveBtoolsBtn.MouseButton1Click:Connect(giveBtools)

clearSkyboxBtn.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "Sky" then
			pcall(function() v:Destroy() end)
		end
	end
end)