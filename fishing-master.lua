Services = setmetatable({}, {__index = function(self, name)
    local s, c = pcall(function() return cloneref(game:GetService(name)) end)
    if s then rawset(self, name, c) return c
    else error("Invalid Roblox Service: " .. tostring(name))
    end
end})
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local WAIT_FOR_IT = 30

local function Kid(node, name)
	local deadline = os.clock() + WAIT_FOR_IT
	local child = node and node:FindFirstChild(name)
	while not child and os.clock() < deadline do
		task.wait(0.25)
		child = node and node:FindFirstChild(name)
	end
	if not child then
		error("thieu " .. tostring(name), 0)
	end
	return child
end

local function Mod(path)
	local node = ReplicatedStorage
	for part in string.gmatch(path, "[^%.]+") do
		node = Kid(node, part)
	end
	local deadline = os.clock() + WAIT_FOR_IT
	local lastErr
	while true do
		local ok, mod = pcall(require, node)
		if ok then
			return mod
		end
		lastErr = mod
		if os.clock() > deadline then
			error("require " .. path .. " that bai: " .. tostring(lastErr), 0)
		end
		task.wait(0.5)
	end
end

local Client = Mod("Stardust").Client
local ControllerCache = {}
local function getController(name)
	local cached = ControllerCache[name]
	if cached then
		return cached
	end
	local controller = Client.GetController(name)
	if controller then
		ControllerCache[name] = controller
	end
	return controller
end
local Catalog = Mod("Data.Catalog")
local FishingConfig = Mod("Data.Config.FishingConfig")
local PullBarMath = Mod("Shared.Lib.PullBarMath")
local RarityEnums = Mod("Data.Enums.RarityEnums")
local SellEnums = Mod("Data.Enums.SellEnums")
local SellConfig = Mod("Data.Config.SellConfig")
local FishStorageRules = Mod("Shared.Lib.FishStorageRules")
local SkillSlotCount = Mod("Data.Config.SkillSlotConfig").MaxSlots

local Env = (getgenv and getgenv()) or _G

local function disconnect(connection)
	local kind = type(connection)
	if kind ~= "table" and kind ~= "userdata" then
		return
	end
	local direct = type(connection.Disconnect) == "function"
	if direct then
		pcall(function()
			connection:Disconnect()
		end)
		return
	end
	if kind ~= "table" then
		return
	end
	for _, c in pairs(connection) do
		local childKind = type(c)
		if (childKind == "table" or childKind == "userdata") and type(c.Disconnect) == "function" then
			pcall(function()
				c:Disconnect()
			end)
		end
	end
end

local Previous = Env.AutoFarm
if type(Previous) == "table" then
	if type(Previous.Stop) == "function" then
		pcall(function()
			Previous:Stop()
		end)
	end
	if Previous.AntiAfkTask ~= nil then
		Previous.AntiAfkTask = nil
	end
	if type(Previous.Window) == "table" and type(Previous.Window.Destroy) == "function" then
		pcall(function()
			Previous.Window:Destroy()
		end)
	end
	if type(Previous.Library) == "table" and type(Previous.Library.Destroy) == "function" then
		pcall(function()
			Previous.Library:Destroy()
		end)
	end
	if typeof(Previous.ToggleGui) == "Instance" then
		pcall(function()
			Previous.ToggleGui:Destroy()
		end)
	end
	for _, name in ipairs({ "FluentPro", "FluentMinimizerGui", "AutoFarmToggle" }) do
		local stale = CoreGui:FindFirstChild(name)
		if typeof(stale) == "Instance" then
			pcall(function()
				stale:Destroy()
			end)
		end
	end
	Env.AutoFarmUI = nil
	for _, key in ipairs({ "ToggleConnection", "QteConnections", "CooldownConnection" }) do
		disconnect(Previous[key])
	end
end

local Inputs = Kid(ReplicatedStorage, "Inputs")
local Primary = Kid(Kid(Inputs, "FishingContext"), "FishingPrimary")
local QTEContext = Kid(Inputs, "FishingQTEContext")
local QTEAction = {
	Left = Kid(QTEContext, "QTE_A"),
	Up = Kid(QTEContext, "QTE_W"),
	Right = Kid(QTEContext, "QTE_D"),
}
local QTEOrder = { "Left", "Up", "Right" }

local RarityPriority = {}
for index, rarity in ipairs(RarityEnums.Order) do
	RarityPriority[rarity] = index
end

local FinisherGate = FishingConfig.Fight.FinisherPct

local Control = {
	Stopped = false,
	Running = false,
	Settings = {
		CastHold = 0.65,
		TapHold = 0.045,
		FirstPullTarget = 0.96,
		FinisherSlack = 0.02,
		QteDelay = 0.2,
		SkillSpacing = 0.35,
		MinCastGap = 0.7,
		EquipSettleDelay = 0.35,
		SkillPolicy = "Ready",
		AutoSellWhenFull = true,
		WalkToSell = true,
		ReturnAfterSell = true,
		SellInterval = 2.5,
		AntiAfk = true,
		AntiAfkInterval = 55,
		AntiAfkKey = "F13",
		FlySpeed = 80,
		FlyPin = 3,
		TpCooldown = 12,
		TpIdleAfter = 4,
		TpForce = false,
		AutoLock = true,
		AutoLockRarity = {},
		UserName = "TocoHub",
	},
	Stats = {
		AntiAfk = 0,
		Casts = 0,
		Pulls = 0,
		Caught = 0,
		Escaped = 0,
		Qte = 0,
		Skills = 0,
		SkillFires = 0,
		Equips = 0,
		FirstPull = {},
	},
	SlotPhase = {},
	Storage = {
		Farm = { busy = false, state = nil, at = 0 },
		Satchel = { used = 0, capacity = 0, isFull = false, at = 0, busy = false },
		Sell = {
			at = -math.huge,
			busy = false,
			pending = false,
			retryAt = 0,
			last = nil,
			trip = false,
			running = false,
			holding = false,
			attempts = 0,
		},
		Teleport = {
			busy = false,
			running = false,
			island = nil,
			last = nil,
			at = 0,
			home = nil,
			readyAt = 0,
			mode = nil,
		},
		Lock = {
			busy = false,
			sent = {},
			total = 0,
			last = nil,
			at = 0,
		},
		Name = {
			label = nil,
			step = 0,
			dirty = true,
			text = nil,
			color = nil,
			tagLabel = nil,
			humanoid = nil,
			lastKill = 0,
		},
	},
}

Env.AutoFarm = Control

function Control:Stop()
	self.Stopped = true
	self.Running = false
	self.Storage.Farm.busy = false
	if self._disconnect then
		self:_disconnect()
	end
end

function Control:Toggle()
	if self.Stopped then
		self:Start()
		return
	end
	self.Running = not self.Running
end

local Settings = Control.Settings
local Stats = Control.Stats
local SlotPhase = Control.SlotPhase

local function playerGui()
	return Player:FindFirstChildOfClass("PlayerGui")
end

local function lastHandler(signal)
	local fn
	for _, connection in ipairs(getconnections(signal)) do
		fn = connection.Function
	end
	return fn
end

local actionHandlerCache = setmetatable({}, { __mode = "k" })
local function actionHandler(action, eventName)
	if not action then
		return nil
	end
	local cached = actionHandlerCache[action]
	if not cached then
		cached = {}
		actionHandlerCache[action] = cached
	end
	if cached[eventName] then
		return cached[eventName]
	end
	local signal = action[eventName]
	if not signal then
		return nil
	end
	local fn = lastHandler(signal)
	if type(fn) == "function" then
		cached[eventName] = fn
	end
	return fn
end

local function press(action)
	local fn = actionHandler(action, "Pressed")
	if fn then
		fn()
	end
end

local function release(action)
	local fn = actionHandler(action, "Released")
	if fn then
		fn()
	end
end

local function tap(action, hold)
	press(action)
	task.wait(hold or Settings.TapHold)
	release(action)
end

local function sessionHolder()
	local cached = Control.Storage.SessionUi
	if cached and cached.holder and cached.holder.Parent and cached.tension and cached.tension.Parent and cached.hp and cached.hp.Parent and cached.tensionFill and cached.tensionFill.Parent and cached.hpFill and cached.hpFill.Parent then
		return cached.holder
	end
	local gui = playerGui()
	local sessionInfo = gui and gui:FindFirstChild("SessionInfo")
	local holder = sessionInfo and sessionInfo:FindFirstChild("Holder")
	if holder then
		local tension = holder:FindFirstChild("Tension")
		local hp = holder:FindFirstChild("FishHP")
		local tensionFill = tension and tension:FindFirstChild("Fill")
		local hpFill = hp and hp:FindFirstChild("Fill")
		Control.Storage.SessionUi = {
			holder = holder,
			tension = tension,
			hp = hp,
			tensionFill = tensionFill,
			hpFill = hpFill,
		}
	end
	return holder
end

local function tensionRatio()
	local holder = sessionHolder()
	local cached = Control.Storage.SessionUi
	local fill = cached and cached.holder == holder and cached.tensionFill or nil
	if not fill then
		return 0
	end
	return 1 - fill.Size.X.Scale
end

local function hpRatio()
	local holder = sessionHolder()
	local cached = Control.Storage.SessionUi
	local fill = cached and cached.holder == holder and cached.hpFill or nil
	if not fill then
		return 1
	end
	return fill.Size.X.Scale
end

local function finisherReached()
	return hpRatio() <= FinisherGate + Settings.FinisherSlack
end

local QTE = {
	visible = {},
	answered = {},
	seenAt = {},
}

local function qtePrompt()
	local direction
	for _, name in ipairs(QTEOrder) do
		if QTE.visible[name] then
			direction = name
			break
		end
	end
	return direction
end

local function qteBusy()
	return qtePrompt() ~= nil
end

local function watchQte()
	for _, name in ipairs(QTEOrder) do
		QTE.visible[name] = nil
		QTE.answered[name] = nil
		QTE.seenAt[name] = nil
	end
	local gui = playerGui()
	local counter = gui and gui:FindFirstChild("ReelCounterGui")
	if not counter then
		return {}, nil
	end
	local connections = {}
	for _, name in ipairs(QTEOrder) do
		local prompt = counter:FindFirstChild(name)
		if prompt and prompt:IsA("GuiObject") then
			if prompt.Visible then
				QTE.visible[name] = true
				QTE.answered[name] = false
				QTE.seenAt[name] = os.clock()
			end
			table.insert(connections, prompt:GetPropertyChangedSignal("Visible"):Connect(function()
				if prompt.Visible then
					QTE.visible[name] = true
					QTE.answered[name] = false
					QTE.seenAt[name] = os.clock()
				else
					QTE.visible[name] = nil
					QTE.answered[name] = nil
					QTE.seenAt[name] = nil
				end
			end))
		end
	end
	return connections, counter
end

local function answerQte(direction)
	local action = QTEAction[direction]
	if not action then
		return
	end
	press(action)
	task.wait(Settings.TapHold)
	release(action)
end

local function serviceQte()
	local direction = qtePrompt()
	if not direction then
		return
	end
	if QTE.answered[direction] then
		return
	end
	if os.clock() - (QTE.seenAt[direction] or os.clock()) < Settings.QteDelay then
		return
	end
	QTE.answered[direction] = true
	Stats.Qte += 1
	answerQte(direction)
end

local function markSlotCasting(slotName, skillId)
	local entry = type(SlotPhase) == "table" and SlotPhase[slotName]
	if type(entry) ~= "table" then
		return
	end
	entry.phase = "Casting"
	entry.remaining = 0
	local skill = skillId and Catalog.Skill.GetById(skillId)
	entry.localReadyAt = os.clock() + (skill and (skill.cooldown or 0) or 0)
end

local function slotReady(slotName)
	local entry = type(SlotPhase) == "table" and SlotPhase[slotName]
	if type(entry) ~= "table" then
		return true
	end
	if entry.phase == "Ready" then
		return true
	end
	if entry.localReadyAt and os.clock() >= entry.localReadyAt then
		return true
	end
	return false
end

local skillCache = { at = 0, ids = {} }
local SKILL_CACHE_TTL = 1.5

local function equippedSkillIds()
	local now = os.clock()
	if now - skillCache.at < SKILL_CACHE_TTL then
		return skillCache.ids
	end
	local data = getController("PlayerDataV2Controller")
	local profile = data and data:Fetch()
	local rodId = profile and profile.RodEquip
	local entry = rodId and profile.Rods and profile.Rods[rodId]
	local bookSlots = entry and entry.BookSlots
	local out = {}
	if type(bookSlots) ~= "table" then
		skillCache.at = now
		skillCache.ids = out
		return out
	end
	for i = 1, SkillSlotCount do
		local skillId = bookSlots["Slot" .. i]
		if type(skillId) == "string" and skillId ~= "" then
			out[i] = skillId
		end
	end
	skillCache.at = now
	skillCache.ids = out
	return out
end

local keybindsController
local SKILL_ORDER_LOW = { 1, 2, 3, 4 }
local SKILL_ORDER_HIGH = { 4, 3, 2, 1 }

local function useSkill(slotIndex, skillId)
	local keybinds = keybindsController
	if not keybinds then
		keybinds = getController("KeybindsController")
		keybindsController = keybinds
	end
	local bind = keybinds and keybinds.Keys and keybinds.Keys["Slot" .. slotIndex]
	local callback = bind and bind.callback
	if type(callback) ~= "function" then
		return false
	end
	local slotName = "Slot" .. slotIndex
	callback(false)
	markSlotCasting(slotName, skillId)
	Stats.Skills += 1
	return true
end

local function castSkill(preferLowIndex)
	local ids = equippedSkillIds()
	local order = preferLowIndex and SKILL_ORDER_LOW or SKILL_ORDER_HIGH
	for _, index in ipairs(order) do
		local skillId = ids[index]
		if skillId and slotReady("Slot" .. index) then
			Stats.SkillFires += 1
			return useSkill(index, skillId)
		end
	end
	return false
end

local function hasRodTool(rodId)
	local backpack = Player:FindFirstChildOfClass("Backpack")
	return backpack ~= nil and backpack:FindFirstChild(rodId) ~= nil
end

local rodScoreCache = {}
local function rodScore(rodId)
	local cached = rodScoreCache[rodId]
	if cached ~= nil then
		return cached
	end
	local catalog = Catalog.Rod.GetById(rodId)
	if not catalog then
		rodScoreCache[rodId] = false
		return nil
	end
	local damage, luck = 0, 0
	for _, stat in ipairs(catalog.stats or {}) do
		if stat.stat == "attackDamage" then
			damage += stat.value or 0
		elseif stat.stat == "luck" then
			luck += stat.value or 0
		end
	end
	local rarity = RarityPriority[catalog.rarity] or 0
	local score = damage * 1e6 + luck * 1e3 + (catalog.skillSlots or 0) * 10 + rarity
	rodScoreCache[rodId] = score
	return score
end

local bestRodCache = { profile = nil, at = 0, id = nil }
local function bestRodId(profile)
	local now = os.clock()
	if bestRodCache.profile == profile and now - bestRodCache.at < 1 then
		return bestRodCache.id
	end
	local bestId, bestScore
	for rodId in pairs(profile.Rods or {}) do
		local score = rodScore(rodId)
		if score and (not bestScore or score > bestScore) then
			bestId, bestScore = rodId, score
		end
	end
	bestRodCache.profile = profile
	bestRodCache.at = now
	bestRodCache.id = bestId
	return bestId
end

local function equipRod(rodId)
	local backpack = getController("BackpackController")
	local held = getController("HeldToolController")
	if not backpack or not held or not held:IsInputEnabled() then
		return false
	end
	local predicted = held:PredictEquipByName(rodId)
	backpack.EquipByName:Fire(rodId, predicted)
	return true
end

local function fetchProfile()
	local now = os.clock()
	local cached = Control.Storage.Profile
	if cached and now - (cached.at or 0) < 0.75 then
		return cached.value
	end
	local controller = getController("PlayerDataV2Controller")
	if not controller then
		return nil
	end
	local ok, profile = pcall(function()
		return controller:Fetch()
	end)
	if ok and type(profile) == "table" then
		Control.Storage.Profile = { value = profile, at = now }
		return profile
	end
	return nil
end

local function heldRodId()
	local character = Player.Character
	if not character then
		return nil
	end
	local cached = Control.Storage.HeldRod
	local now = os.clock()
	if cached and cached.character == character and now - cached.at < 0.2 then
		return cached.id
	end
	local found
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") and Catalog.Rod.GetById(child.Name) then
			found = child.Name
			break
		end
	end
	Control.Storage.HeldRod = { character = character, id = found, at = now }
	return found
end

local function equipAnyRod()
	local profile = fetchProfile()
	if type(profile) ~= "table" or type(profile.Rods) ~= "table" then
		return false
	end
	local best = bestRodId(profile)
	if not best or not hasRodTool(best) then
		return false
	end
	Stats.Equips += 1
	return equipRod(best)
end

local function formatCoin(value)
	local n = math.floor(tonumber(value) or 0)
	local sign = n < 0 and "-" or ""
	local digits = tostring(math.abs(n))
	while true do
		local replaced
		digits, replaced = digits:gsub("^(%d+)(%d%d%d)", "%1,%2")
		if replaced == 0 then
			break
		end
	end
	return sign .. digits
end

local merchantCache = { part = nil, at = 0 }
local merchantPrefixes = {}
for id in pairs(SellConfig.MerchantInteractiveIds) do
	merchantPrefixes[#merchantPrefixes + 1] = id
end

local function merchantPart()
	if merchantCache.part and merchantCache.part.Parent and os.clock() - merchantCache.at < 10 then
		return merchantCache.part
	end
	merchantCache.at = os.clock()
	merchantCache.part = nil
	for _, d in ipairs(workspace:GetDescendants()) do
		if typeof(d) == "Instance" and typeof(d.Name) == "string" then
			local matches = false
			for _, id in ipairs(merchantPrefixes) do
				if d.Name:sub(1, #id) == id then
					matches = true
					break
				end
			end
			if matches then
				local part = d:IsA("BasePart") and d or d:FindFirstChild("HumanoidRootPart")
				if not part and d:IsA("Model") then
					part = d.PrimaryPart
				end
				if part then
					merchantCache.part = part
					return part
				end
			end
		end
	end
	return nil
end

local DRAG_PART_NAME = "AutoFarmDragPart"
local DRAG_SPEED = 100
local DRAG_STEP = 1.5
local DRAG_TICK = 1 / 60
local DRAG_RAMP_TICKS = 12
local DRAG_EASE_DISTANCE = 8
local DRAG_GUARD = 4000

local function clearDragParts()
	local character = Player.Character
	if character then
		local own = character:FindFirstChild(DRAG_PART_NAME)
		if own then
			own:Destroy()
		end
	end
	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name == DRAG_PART_NAME then
			child:Destroy()
		end
	end
end

function Control:_beginDrag()
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	clearDragParts()
	local part = Instance.new("Part")
	part.Name = DRAG_PART_NAME
	part.Size = Vector3.new(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CFrame = root.CFrame
	part.Parent = character
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	return part
end

function Control:_dragTo(part, target)
	local guard = DRAG_GUARD
	local tick = 0
	while part.Parent and guard > 0 do
		guard -= 1
		tick += 1
		local character = Player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return false
		end
		local delta = target - root.Position
		local distance = delta.Magnitude
		if distance <= DRAG_STEP then
			return true
		end
		local ramp = math.min(1, 0.3 + 0.7 * (tick / DRAG_RAMP_TICKS))
		local step = math.min(DRAG_SPEED * DRAG_TICK * ramp, distance)
		if distance < DRAG_EASE_DISTANCE then
			step = math.min(step, distance * 0.3)
		end
		local look = delta / distance
		part.CFrame = CFrame.lookAt(part.Position + look * step, part.Position + look * (step + 1))
		task.wait(DRAG_TICK)
	end
	return false
end

function Control:UpdateSatchel()
	local store = self.Storage.Satchel
	if store.busy then
		return
	end
	store.busy = true
	task.spawn(function()
		local profile = fetchProfile()
		local state
		if type(profile) == "table" then
			local ok, result = pcall(function()
				return FishStorageRules.GetState(profile)
			end)
			if ok and type(result) == "table" then
				state = result
			end
		end
		store.busy = false
		store.at = os.clock()
		if not state then
			return
		end
		store.used = state.used or 0
		store.capacity = state.capacity or 0
		store.isFull = state.isFull == true
	end)
end

local AUTO_LOCK_GAP = 0.15
local AUTO_LOCK_MAX_PER_PASS = 12
local AUTO_LOCK_RETRY = 20

local rarityOf = nil
local rarityCounts = nil

function Control:RarityCounts()
	if rarityOf == nil then
		local built = {}
		local ok, all = pcall(function()
			return Catalog.Fish.GetAll()
		end)
		if ok and type(all) == "table" then
			for index = 1, #all do
				local entry = all[index]
				if type(entry) == "table" and type(entry.id) == "string" then
					built[entry.id] = entry.rarity
				end
			end
		end
		rarityOf = built
		rarityCounts = {}
		for _, rarity in pairs(rarityOf) do
			if type(rarity) == "string" then
				rarityCounts[rarity] = (rarityCounts[rarity] or 0) + 1
			end
		end
	end
	return rarityCounts, rarityOf
end

function Control:RarityList()
	local counts = self:RarityCounts()
	local out = {}
	for _, rarity in ipairs(RarityEnums.Order or {}) do
		if type(rarity) == "string" and counts[rarity] then
			out[#out + 1] = rarity
		end
	end
	if #out == 0 then
		for rarity in pairs(counts) do
			out[#out + 1] = rarity
		end
		table.sort(out, function(a, b)
			return (RarityPriority[a] or 99) < (RarityPriority[b] or 99)
		end)
	end
	return out
end

function Control:CountLocked()
	local profile = fetchProfile()
	local fishes = profile and profile.Inventory and profile.Inventory.Fishes
	if type(fishes) ~= "table" then
		return 0, 0
	end
	local locked, total = 0, 0
	for _uid, fish in pairs(fishes) do
		if type(fish) == "table" then
			total = total + 1
			if fish.locked == true then
				locked = locked + 1
			end
		end
	end
	return locked, total
end

function Control:AutoLockPass()
	local store = self.Storage.Lock
	if store.busy then
		return
	end
	if not Settings.AutoLock then
		return
	end
	local wantRarity = Settings.AutoLockRarity
	if type(wantRarity) ~= "table" then
		return
	end
	local wanted = 0
	for _ in pairs(wantRarity) do
		wanted = wanted + 1
	end
	if wanted == 0 then
		return
	end
	local _counts, rarityOf = self:RarityCounts()
	local targets = {}
	for id, rarity in pairs(rarityOf) do
		if wantRarity[rarity] then
			targets[id] = true
		end
	end
	store.busy = true
	task.spawn(function()
		local sent = store.sent
		local fresh = 0
		local failed = 0
		local ok, err = pcall(function()
			local profile = fetchProfile()
			local fishes = profile and profile.Inventory and profile.Inventory.Fishes
			if type(fishes) ~= "table" then
				return
			end
			local now = os.clock()
			local seen = {}
			for uid, fish in pairs(fishes) do
				seen[uid] = true
				if type(fish) == "table" then
					if fish.locked == true then
						sent[uid] = nil
					elseif
						targets[fish.fishId]
						and (sent[uid] == nil or now - (sent[uid] or 0) > AUTO_LOCK_RETRY)
					then
						if fresh < AUTO_LOCK_MAX_PER_PASS then
							sent[uid] = now
							fresh = fresh + 1
							local sell = getController("SellController")
							local status = sell and sell:ToggleLock(uid) or -1
							if status ~= SellEnums.Status.Ok then
								sent[uid] = nil
								fresh = fresh - 1
								failed = failed + 1
							end
							task.wait(AUTO_LOCK_GAP)
						end
					end
				end
			end
			for uid in pairs(sent) do
				if not seen[uid] then
					sent[uid] = nil
				end
			end
		end)
		store.busy = false
		store.at = os.clock()
		store.total = (store.total or 0) + fresh
		if not ok then
			store.last = "lỗi: " .. tostring(err)
		elseif fresh > 0 then
			store.last = ("đã khoá thêm %d con"):format(fresh)
		elseif failed > 0 then
			store.last = ("máy chưa sẵn sàng, thử lại %d"):format(failed)
		else
			store.last = nil
		end
	end)
end

local function sellResultText(status, count, coin)
	if status == SellEnums.Status.Ok then
		return ("đã bán %d cá · +%s$"):format(count or 0, formatCoin(coin))
	elseif status == SellEnums.Status.Empty then
		return "rương trống, không có cá để bán"
	elseif status == SellEnums.Status.OutOfRange then
		return "không ở gần thương nhân và không tìm thấy NPC bán cá"
	elseif status == -1 then
		return "lỗi khi kéo tới thương nhân, xem Console"
	elseif status == -2 then
		return "kéo tới thương nhân không được, vẫn đang ở chỗ cũ"
	elseif status == -3 then
		return "máy chủ không trả lời, xem Console"
	elseif status == SellEnums.Status.NoPass then
		return "cần pass bán mọi nơi, hoặc đứng gần thương nhân"
	elseif status == SellEnums.Status.Busy then
		return "đang câu, để bán ở lần kế tiếp"
	end
	return ("bán không thành công (mã %s)"):format(tostring(status))
end

local function sellWithRetry(sell, tries)
	local status, coin, count
	for _ = 1, (tries or 8) do
		status, coin, count = sell:SellAll()
		if status ~= SellEnums.Status.Busy then
			break
		end
		task.wait(0.25)
	end
	if status == nil then
		return -3, coin or 0, count or 0
	end
	return status, coin, count
end

local WALK_TIMEOUT = 20
local WALK_STUCK = 0.8
local WALK_MARGIN = 6

function Control:_walkTo(goal, stopAt, timeout)
	local character = Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and root) then
		return false
	end
	local deadline = os.clock() + (timeout or WALK_TIMEOUT)
	local lastPos = root.Position
	local stillFor = 0
	local reissues = 0
	humanoid:MoveTo(goal)
	while os.clock() < deadline do
		task.wait(0.1)
		local live = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not live then
			break
		end
		if (live.Position - goal).Magnitude <= (stopAt or 1.5) then
			humanoid:MoveTo(live.Position)
			return true
		end
		if (live.Position - lastPos).Magnitude < 0.3 then
			stillFor += 0.1
		else
			stillFor = 0
			lastPos = live.Position
		end
		if stillFor >= WALK_STUCK then
			stillFor = 0
			lastPos = live.Position
			reissues += 1
			local aim = if reissues % 2 == 0 then goal else lastPos:Lerp(goal, 0.5)
			humanoid:MoveTo(aim)
		end
	end
	local endHum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
	if endHum then
		endHum:MoveTo(endHum.RootPart and endHum.RootPart.Position or endHum.Position)
	end
	return false
end


local FLY_SPEED = 80
local FLY_PIN_SECONDS = 2
local FLY_MAX_SPEED = 80
local FLY_SUPPORT_DROP = 6

local function flySupport()
	local part = Instance.new("Part")
	part.Name = "AutoFarmFlySupport"
	part.Size = Vector3.new(10, 1, 10)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = true
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CastShadow = false
	part.Parent = workspace
	return part
end

function Control:_flyTo(target, lookCFrame, speed, pinSeconds)
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not (root and humanoid) then
		return false
	end
	local flySpeed = math.clamp(tonumber(speed) or FLY_SPEED, 8, FLY_MAX_SPEED)
	local startPosition = root.Position
	local delta = target - startPosition
	local distance = delta.Magnitude
	if distance < 0.5 then
		if lookCFrame then
			root.CFrame = lookCFrame
		end
		return true
	end

	local direction = delta / distance
	local lookVector = lookCFrame and lookCFrame.LookVector or nil
	local duration = math.max(0.1, distance / flySpeed)
	local totalTime = duration + (tonumber(pinSeconds) or FLY_PIN_SECONDS)
	local startTime = os.clock()

	local prevAutoRotate = humanoid.AutoRotate
	local prevPlatformStand = humanoid.PlatformStand
	humanoid.AutoRotate = false
	humanoid.PlatformStand = true

	local support = flySupport()
	support.CFrame = CFrame.new(startPosition - Vector3.new(0, FLY_SUPPORT_DROP, 0))

	local alive = true
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		local travelled = math.min(distance, distance * (elapsed / duration))
		local position = startPosition + direction * travelled
		if elapsed >= duration then
			position = target
		end
		local live = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not live then
			alive = false
			connection:Disconnect()
			return
		end
		support.CFrame = CFrame.new(position - Vector3.new(0, FLY_SUPPORT_DROP, 0))
		live.AssemblyAngularVelocity = Vector3.zero
		live.AssemblyLinearVelocity = Vector3.zero
		if lookVector then
			live.CFrame = CFrame.lookAt(position, position + lookVector)
		else
			live.CFrame = CFrame.new(position)
		end
		if elapsed >= totalTime then
			connection:Disconnect()
		end
	end)

	while connection.Connected do
		task.wait(0.05)
	end

	support:Destroy()
	humanoid.AutoRotate = prevAutoRotate
	humanoid.PlatformStand = prevPlatformStand
	local live = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if live and alive then
		live.CFrame = lookCFrame or CFrame.new(target)
	end
	return alive
end

local function islandRoot()
	local world = workspace:FindFirstChild("World")
	if not world then
		return nil
	end
	return world:FindFirstChild("Islands")
end

local ISLAND_LABELS = {
	island_starter = "Starter",
	island_jungle = "Jungle",
	island_desert = "Desert",
	island_snow = "Snow",
	island_volcano = "Volcanic",
	island_fossil = "Fossil",
}

local islandMetaCache = nil

local function islandMeta()
	if islandMetaCache then
		return islandMetaCache
	end
	local data = game:GetService("ReplicatedStorage"):FindFirstChild("Data")
	local map = {}
	if data then
		local cfgFolder = data:FindFirstChild("Config")
		local catFolder = data:FindFirstChild("Catalog")
		local cfgMod = cfgFolder and cfgFolder:FindFirstChild("IslandConfig")
		local catMod = catFolder and catFolder:FindFirstChild("Island")
		if cfgMod then
			local okCfg, cfg = pcall(require, cfgMod)
			if okCfg and type(cfg) == "table" then
				for id, entry in pairs(cfg) do
					if type(entry) == "table" then
						map[id] = {
							id = id,
							level = entry.requiredLevel,
							cost = entry.unlockCost,
							open = entry.defaultUnlocked,
							color = entry.color,
						}
					end
				end
			end
		end
		if catMod then
			local okCat, cat = pcall(require, catMod)
			if okCat and type(cat) == "table" then
				for id, entry in pairs(cat) do
					if type(entry) == "table" then
						local slot = map[id]
						if not slot then
							slot = { id = id }
							map[id] = slot
						end
						slot.name = entry.name
						slot.icon = entry.icon
						slot.order = entry.order
					end
				end
			end
		end
	end
	local list = {}
	for _, slot in pairs(map) do
		list[#list + 1] = slot
	end
	table.sort(list, function(a, b)
		local oa, ob = tonumber(a.order) or 999, tonumber(b.order) or 999
		if oa == ob then
			return tostring(a.id) < tostring(b.id)
		end
		return oa < ob
	end)
	if #list == 0 then
		return nil
	end
	islandMetaCache = { map = map, list = list }
	return islandMetaCache
end

local function islandList()
	local names, seen = {}, {}
	local meta = islandMeta()
	if meta then
		for _, slot in ipairs(meta.list) do
			seen[slot.id] = true
			names[#names + 1] = slot.id
		end
	end
	local root = islandRoot()
	if root then
		local extra = {}
		for _, child in ipairs(root:GetChildren()) do
			local n = tostring(child.Name)
			if not seen[n] and (child:IsA("Folder") or child:IsA("Model")) and n:lower():find("^island") then
				extra[#extra + 1] = n
			end
		end
		table.sort(extra)
		for _, n in ipairs(extra) do
			names[#names + 1] = n
		end
	end
	return names
end

local islandPoints = {}

local function landPart(holder)
	if not holder then
		return nil
	end
	if holder:IsA("BasePart") then
		return holder
	end
	for _, wanted in ipairs({ "Spawner", "SpawnLocation", "Spawn" }) do
		local part = holder:FindFirstChild(wanted)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	if holder:IsA("Model") then
		local primary = holder.PrimaryPart
		if primary and primary:IsA("BasePart") then
			return primary
		end
	end
	return holder:FindFirstChildWhichIsA("BasePart", true)
end

local function islandPoint(name)
	if islandPoints[name] then
		return islandPoints[name]
	end
	local root = islandRoot()
	if not root then
		return nil
	end
	local island = root:FindFirstChild(name)
	if not island then
		return nil
	end
	local part = landPart(island:FindFirstChild("SpawnPoint")) or landPart(island)
	if not part then
		return nil
	end
	local point = part.Position + Vector3.new(0, 4, 0)
	islandPoints[name] = point
	return point
end

local function islandPortal(name)
	local root = islandRoot()
	if not root then
		return nil
	end
	local island = root:FindFirstChild(name)
	if not island then
		return nil
	end
	for _, child in ipairs(island:GetChildren()) do
		local n = tostring(child.Name):lower()
		if n:find("fast_travel") or n:find("portal") then
			for _, part in ipairs(child:GetDescendants()) do
				if part:IsA("BasePart") then
					local p = part.Position
					if p.Y < 60 then
						return p + Vector3.new(0, 2, 0)
					end
				end
			end
		end
	end
	return nil
end

local function fastTravelPacket()
	local ok, controllers = pcall(function()
		return game:GetService("ReplicatedStorage"):FindFirstChild("Controllers")
	end)
	if not ok or not controllers then
		return nil
	end
	local mod = controllers:FindFirstChild("FastTravelController")
	if not mod then
		return nil
	end
	local okReq, controller = pcall(require, mod)
	if not okReq or type(controller) ~= "table" then
		return nil
	end
	local packet = controller.TravelToIsland
	if type(packet) == "table" and type(packet.Fire) == "function" then
		return packet
	end
	return nil
end

local function requestServerTravel(islandId)
	local packet = fastTravelPacket()
	if not packet then
		return -1, "không gọi được fast travel của game"
	end
	local ok, code = pcall(function()
		return packet:Fire(islandId)
	end)
	if not ok then
		return -1, "fast travel lỗi: " .. tostring(code)
	end
	return tonumber(code) or -1
end

local function islandLabel(name)
	local meta = islandMeta()
	local slot = meta and meta.map[name]
	if slot and type(slot.name) == "string" and slot.name ~= "" then
		return (tostring(slot.name):gsub("%s*[Ii]sland$", ""))
	end
	return ISLAND_LABELS[name] or (tostring(name):gsub("^island_", ""))
end

function Control:_flyIsland(goal, label, lookCFrame)
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return -1, "không có nhân vật"
	end
	local speed = tonumber(Settings.FlySpeed) or 80
	local pin = tonumber(Settings.FlyPin) or 3
	if not Control:_flyTo(goal, lookCFrame, speed, pin) then
		return -1, ("bay tới %s không được"):format(label)
	end
	local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:MoveTo(goal)
	end
	task.wait(0.6)
	local live = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not live then
		return -1, "mất nhân vật giữa chừng"
	end
	local distance = (live.Position - goal).Magnitude
	if distance > 30 then
		return 1, ("tới %s nhưng lệch %.0f studs, server có thể kéo lại"):format(label, distance)
	end
	return 0, ("đã tới %s"):format(label)
end

function Control:_runTeleport(job)
	local store = self.Storage.Teleport
	local resumeRunning, resumeStopped = self.Running, self.Stopped
	self:Stop()
	local ok, status, message = pcall(job)
	store.busy = false
	store.running = false
	store.at = os.clock()
	store.who = nil
	if not ok then
		status, message = -1, "lỗi khi bay: " .. tostring(status)
		store.last = message
	elseif type(message) == "string" then
		store.last = message
	else
		store.last = "bay xong"
	end
	if not resumeStopped then
		self.Stopped = false
		self.Running = resumeRunning
		self:Start()
	end
	return status, message
end


local IDLE_STATES = {
	Idling = true,
	None = true,
	Idle = true,
}

local function castHoldReason()
	local farm = Control.Storage.Farm
	if Control.Running and not Control.Stopped then
		if farm.busy then
			return ("đang câu (%s), bấm Dừng trước khi bay"):format(tostring(farm.state))
		end
		return "farm đang chạy, bấm Dừng trước khi bay"
	end
	local since = tonumber(farm.at) or 0
	if since > 0 then
		local quiet = (tonumber(Settings.TpIdleAfter) or 4) - (os.clock() - since)
		if quiet > 0 then
			return ("nghỉ thêm %.1f giây cho câu nguội"):format(quiet)
		end
	end
	return nil
end

function Control:FlyToIsland(name)
	local store = self.Storage.Teleport
	if store.busy or store.running then
		store.last = "đang bay, xong lát nữa"
		return
	end
	if not Settings.TpForce then
		local hold = castHoldReason()
		if hold then
			store.last = hold
			return
		end
	end
	local wait = (store.readyAt or 0) - os.clock()
	if wait > 0 then
		store.last = ("nghỉ thêm %.0f giây trước khi bay tiếp"):format(wait)
		return
	end
	local goal = islandPoint(name)
	if not goal then
		store.last = ("không tìm thấy đảo %s"):format(tostring(name))
		return
	end
	local label = islandLabel(name)
	local portal = islandPortal(name)
	store.busy = true
	store.running = true
	store.island = name
	store.mode = portal and "portal" or "fly"
	task.spawn(function()
		local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if root and not store.home then
			store.home = root.CFrame
		end
		if portal then
			store.last = "bay tới cổng của " .. label .. "..."
		else
			store.last = "đang bay tới " .. label .. "..."
		end
		Control:_runTeleport(function()
			local status, message = -1, "không chạy"
			if portal then
				local reached, why = Control:_flyIsland(portal, "cổng " .. label)
				if not reached then
					return -1, why
				end
				local code, detail = requestServerTravel(name)
				if code == 0 then
					task.wait(2)
					return 0, ("đã tới %s"):format(label)
				end
				if code == 1 then
					task.wait(2)
					return 1, ("server đang chuyển, xong tới %s"):format(label)
				end
				status = 1
				message = ("server từ chối sang %s: %s"):format(label, tostring(detail))
			end
			status, message = Control:_flyIsland(goal, label)
			return status, message
		end)
		store.readyAt = os.clock() + (tonumber(Settings.TpCooldown) or 12)
	end)
end

function Control:FlyHome()
	local store = self.Storage.Teleport
	if store.busy or store.running then
		store.last = "đang bay, xong lát nữa"
		return
	end
	if not Settings.TpForce then
		local hold = castHoldReason()
		if hold then
			store.last = hold
			return
		end
	end
	local wait = (store.readyAt or 0) - os.clock()
	if wait > 0 then
		store.last = ("nghỉ thêm %.0f giây trước khi bay tiếp"):format(wait)
		return
	end
	local home = store.home
	if not home then
		store.last = "chưa lưu được chỗ đã lưu"
		return
	end
	store.busy = true
	store.running = true
	store.mode = "home"
	task.spawn(function()
		store.last = "đang về chỗ đã lưu..."
		Control:_runTeleport(function()
			return Control:_flyIsland(home.Position, "chỗ đã lưu", home)
		end)
		store.readyAt = os.clock() + (tonumber(Settings.TpCooldown) or 12)
	end)
end

function Control:SaveHome()
	local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	self.Storage.Teleport.home = root.CFrame
	self.Storage.Teleport.last = "đã lưu chỗ này làm điểm về"
	self.Storage.Teleport.at = os.clock()
end

function Control:SellTrip(sell)
	local store = self.Storage.Sell
	local seller = merchantPart()
	local character = Player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (seller and root) then
		return sell:SellAllAnywhere()
	end
	local home = root.CFrame
	store.trip = true
	local status, coin, count = -2, 0, 0
	local ok = pcall(function()
		store.last = "đang bay tới thương nhân..."
		local approach = seller.Position
			+ (home.Position - seller.Position).Unit * (SellConfig.MerchantRadius - WALK_MARGIN)
		Control:_flyTo(approach)
		local function distanceToSeller()
			local live = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
			return live and (live.Position - seller.Position).Magnitude or math.huge
		end

		Control:_walkTo(seller.Position, SellConfig.MerchantRadius - WALK_MARGIN, 14)
		task.wait(0.4)
		if distanceToSeller() <= SellConfig.MerchantRadius then
			status, coin, count = sellWithRetry(sell, 6)
			local poll = 0
			while status == SellEnums.Status.OutOfRange and poll < 12 do
				poll += 1
				Control:_walkTo(
					seller.Position,
					math.max(2, SellConfig.MerchantRadius - WALK_MARGIN - poll * 2),
					3
				)
				task.wait(0.3)
				status, coin, count = sellWithRetry(sell, 1)
			end
		else
			status, coin, count = -2, 0, 0
		end
		if Settings.ReturnAfterSell then
			store.last = "đang quay lại chỗ cũ..."
			Control:_flyTo(home.Position, home)
		end
	end)
	store.trip = false
	clearDragParts()
	if not ok then
		return -1, 0, 0
	end
	return status, coin, count
end

function Control:SellNow(reason)
	local store = self.Storage.Sell
	if store.busy or store.running then
		store.pending = false
		return
	end
	store.busy = true
	store.running = true
	store.holding = true
	store.pending = false
	store.attempts = 0
	task.spawn(function()
		local status, coin, count
		local ok, failure = pcall(function()
			local sell = getController("SellController")
			if not sell then
				return -1, 0, 0
			end
			local seller = merchantPart()
			local startRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
			local far = seller ~= nil
				and startRoot ~= nil
				and (startRoot.Position - seller.Position).Magnitude > SellConfig.MerchantRadius
			local travelling = far and Settings.WalkToSell

			local resumeRunning, resumeStopped
			if travelling then
				resumeRunning, resumeStopped = self.Running, self.Stopped
				self:Stop()
			end

			local fishing = getController("FishingController")
			local guard = 0
			while guard < 150 do
				guard += 1
				local state = fishing and fishing:GetState()
				if not state or (state ~= "Reeling" and state ~= "FirstPull") then
					break
				end
				task.wait(0.1)
			end

			local rodId = heldRodId()
			local held = getController("HeldToolController")
			local backpack = getController("BackpackController")
			if rodId and held and backpack and held:PredictUnequipAll() then
				backpack.EquipByName:Fire("", false)
			end
			for _ = 1, 15 do
				local state = fishing and fishing:GetState()
				if not state or state == "Idling" then
					break
				end
				task.wait(0.1)
			end

			if travelling then
				local legs = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
				for _ = 1, 24 do
					if legs and legs.WalkSpeed > 0 then
						break
					end
					task.wait(0.25)
				end
				status, coin, count = Control:SellTrip(sell)
				if not resumeStopped then
					self:Start()
				end
				if not resumeRunning then
					self.Running = false
				end
			else
				status, coin, count = sellWithRetry(sell, 8)
				if status == SellEnums.Status.OutOfRange and not Settings.WalkToSell then
					status, coin, count = sell:SellAllAnywhere()
				end
			end
			if rodId and backpack and held then
				local predicted = held:PredictEquipByName(rodId)
				backpack.EquipByName:Fire(rodId, predicted)
			end
			return status, coin, count
		end)
		store.busy = false
		store.running = false
		store.holding = false
		store.at = os.clock()
		if not ok then
			store.last = "lỗi khi bán: " .. tostring(failure)
		else
			store.last = sellResultText(status, count, coin)
			if status == SellEnums.Status.Busy then
				store.attempts = (store.attempts or 0) + 1
				store.pending = store.attempts <= 3
			else
				store.attempts = 0
				store.pending = false
			end
			store.retryAt = (status == SellEnums.Status.Ok) and 0 or (os.clock() + 20)
		end
		if status == SellEnums.Status.Ok then
			self:UpdateSatchel()
		end
	end)
end

function Control:RequestSell()
	local store = self.Storage.Sell
	if store.busy or store.running then
		store.last = "đang bán, xong lát nữa"
		return
	end
	store.pending = true
	store.last = "đang chờ câu xong để bán"
	self:SellNow("manual")
end

local ANTI_AFK_KEYS = { "F13", "F14", "Numpad7", "F15" }

local function antiAfkKey()
	local wanted = Settings.AntiAfkKey
	for _, name in ipairs(ANTI_AFK_KEYS) do
		if name == wanted then
			return Enum.KeyCode[name]
		end
	end
	return Enum.KeyCode.F13
end

local function antiAfkCanFire()
	if Control.Storage.Sell.trip or Control.Storage.Sell.holding then
		return false, "sell"
	end
	if Control.Storage.Teleport.running then
		return false, "teleport"
	end
	local ok, focused = pcall(function()
		return UserInputService:GetFocusedTextBox()
	end)
	if ok and focused then
		return false, "textbox"
	end
	return true
end

function Control:_antiAfkTick()
	if not Settings.AntiAfk then
		return
	end
	if Control.Stopped then
		return
	end
	local allowed, reason = antiAfkCanFire()
	if not allowed then
		Stats.AntiAfkHeld = (Stats.AntiAfkHeld or 0) + 1
		return
	end
	local pressed = pcall(function()
		local input = game:GetService("VirtualInputManager")
		local code = antiAfkKey()
		input:SendKeyEvent(true, code, false, game)
		task.wait(0.05)
		input:SendKeyEvent(false, code, false, game)
	end)
	if pressed then
		Stats.AntiAfk += 1
		Stats.AntiAfkAt = os.clock()
	end
end

function Control:_startAntiAfk()
	if self.AntiAfkTask then
		return
	end
	self.AntiAfkTask = task.spawn(function()
		while not Control.Stopped do
			task.wait(math.max(10, Settings.AntiAfkInterval or 55))
			if not Settings.AntiAfk then
				continue
			end
			Control:_antiAfkTick()
		end
		Control.AntiAfkTask = nil
	end)
end

local function watchCooldowns()
	local rod = getController("RodController")
	local packet = rod and rod.ReplicatedSkillCooldown
	local signal = packet and packet.OnClientEvent
	if type(signal) ~= "table" or type(signal.Connect) ~= "function" then
		return nil
	end
	local ok, connection = pcall(function()
		return signal:Connect(function(payload)
			if type(payload) ~= "table" then
				return
			end
			for slotName, state in pairs(payload) do
				if type(state) == "table" and type(state.phase) == "string" then
					local entry = SlotPhase[slotName]
					if type(entry) ~= "table" then
						entry = {}
						SlotPhase[slotName] = entry
					end
					entry.phase = state.phase
					entry.remaining = state.remaining
					if state.phase == "Ready" then
						entry.localReadyAt = 0
					end
				end
			end
		end)
	end)
	if not ok then
		return nil
	end
	return connection
end

function Control:_connect()
	if self.Stopped then
		return
	end
	if not self.ToggleConnection then
		self.ToggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			if input.KeyCode == Enum.KeyCode.F7 then
				Control:Toggle()
			end
		end)
	end
	local now = os.clock()
	local qteAlive = typeof(self.QteCounter) == "Instance" and self.QteCounter.Parent ~= nil
	if (type(self.QteConnections) ~= "table" or #self.QteConnections == 0 or not qteAlive)
		and now - (self.QteWatchAt or 0) >= 1
	then
		self.QteWatchAt = now
		if type(self.QteConnections) == "table" then
			disconnect(self.QteConnections)
		end
		self.QteConnections, self.QteCounter = watchQte()
	end
	if not self.CooldownConnection and now - (self.CooldownWatchAt or 0) >= 1 then
		self.CooldownWatchAt = now
		self.CooldownConnection = watchCooldowns()
	end
	self:_startAntiAfk()
end

function Control:_disconnect()
	for _, key in ipairs({ "ToggleConnection", "QteConnections", "CooldownConnection" }) do
		local connection = self[key]
		if connection then
			disconnect(connection)
			self[key] = nil
		end
	end
	self.QteCounter = nil
end

Control:_connect()

local lastCast = 0
local lastSkill = 0
local lastEquip = 0
local firstPullDone = false
local lastState = nil
local active = false
local fishingController = nil
local autoSessionCache = { controller = nil, value = false, at = 0 }

local function resetLoopState()
	lastCast = 0
	lastSkill = 0
	lastEquip = 0
	firstPullDone = false
	lastState = nil
	fishingController = nil
	autoSessionCache.controller = nil
	autoSessionCache.at = 0
end

local function isAutoSession(fishing)
	local now = os.clock()
	if autoSessionCache.controller == fishing and now - autoSessionCache.at < 0.5 then
		return autoSessionCache.value
	end
	local ok, value = pcall(function()
		return fishing:IsAutoSession()
	end)
	autoSessionCache.controller = fishing
	autoSessionCache.at = now
	autoSessionCache.value = ok and value == true
	return autoSessionCache.value
end

local function runLoop()
	active = true
	resetLoopState()
	Control:_connect()

	while not Control.Stopped do
		if not Control.Running then
				task.wait(0.2)
			continue
		end

		if Control.Storage.Sell.trip then
			task.wait(0.05)
			continue
		end

		if Control.Storage.Teleport.running then
			task.wait(0.1)
			continue
		end

		Control:_connect()

		if
			not heldRodId()
			and not Control.Storage.Sell.holding
			and os.clock() - lastEquip >= Settings.EquipSettleDelay
		then
			lastEquip = os.clock()
			if equipAnyRod() then
				task.wait(Settings.EquipSettleDelay)
			end
		end

		local fishing = fishingController
		if not fishing then
			fishing = getController("FishingController")
			fishingController = fishing
		end
		if not fishing then
			task.wait(0.25)
			continue
		end

		local state = fishing:GetState()

		local farm = Control.Storage.Farm
		farm.state = state
		if state and not IDLE_STATES[state] then
			farm.busy = true
			farm.at = os.clock()
		else
			farm.busy = false
		end

		if state ~= lastState then
			if state == "FirstPull" then
				firstPullDone = false
			elseif state == "Caught" then
				Stats.Caught += 1
			elseif state == "Escaped" then
				Stats.Escaped += 1
			end
			lastState = state
		end

		if state ~= "Reeling" and state ~= "FirstPull" then
			local sellStore = Control.Storage.Sell
			local satchel = Control.Storage.Satchel
			local full = Settings.AutoSellWhenFull
				and satchel.isFull
				and satchel.used > 0
				and satchel.capacity > 0
			if
				(sellStore.pending or full)
				and not sellStore.busy
				and os.clock() >= sellStore.retryAt
				and os.clock() - sellStore.at >= Settings.SellInterval
			then
				sellStore.last = full and "rương đầy, đang bán..." or "đang bán..."
				Control:SellNow("auto")
			end
		end

		if state == "Idling" then
			if Control.Storage.Sell.holding then
				task.wait(0.1)
			elseif os.clock() - lastCast >= Settings.MinCastGap then
				lastCast = os.clock()
				Stats.Casts += 1
				tap(Primary, Settings.CastHold)
			else
				task.wait(0.1)
			end
		elseif state == "FirstPull" then
			local value = fishing:GetPullBarValue()
			if not firstPullDone and value >= Settings.FirstPullTarget then
				firstPullDone = true
				local multiplier = PullBarMath.Multiplier(value)
				Stats.FirstPull[multiplier] = (Stats.FirstPull[multiplier] or 0) + 1
				tap(Primary, Settings.TapHold)
			else
				task.wait(0.03)
			end
		elseif state == "Reeling" then
			if qteBusy() then
				serviceQte()
				task.wait()
			else
				local policy = Settings.SkillPolicy
				local wantSkill = policy == "Ready" or (policy == "Finisher" and finisherReached())
				if wantSkill and os.clock() - lastSkill >= Settings.SkillSpacing then
					if Player:GetAttribute("IsUsingSkill") ~= true then
						if castSkill(policy == "Ready") then
							lastSkill = os.clock()
						end
					end
				end
				if isAutoSession(fishing) then
					task.wait(0.05)
				else
					Stats.Pulls += 1
					tap(Primary, Settings.TapHold)
				end
			end
		else
			task.wait(0.05)
		end
	end

	active = false
	Control:_disconnect()
end

function Control:Start()
	if active then
		self.Stopped = false
		self.Running = true
		return
	end
	self.Stopped = false
	self.Running = true
	task.spawn(runLoop)
	self:_startAntiAfk()
	local ui = Env.AutoFarmUI
	if ui and ui.startTask then
		ui.startTask()
	end
end

local FLUENT_URL = "https://raw.githubusercontent.com/StyearX/Fluent-modded/main/dist/main.lua"
local FLUENT_THEME = "Deep Ocean"

local SavedSettings = Env.AutoFarmSettings
if type(SavedSettings) ~= "table" then
	SavedSettings = {}
	Env.AutoFarmSettings = SavedSettings
end

local SETTINGS_FILE = "fishingmaster_settings.json"
local lastSaveAt = 0

local function plainSettings()
	local out = {}
	for key, value in pairs(Control.Settings) do
		local kind = type(value)
		if kind == "boolean" or kind == "number" or kind == "string" then
			out[key] = value
		elseif kind == "table" then
			local copy = {}
			for k, v in pairs(value) do
				copy[tostring(k)] = (type(v) == "boolean") and v or true
			end
			out[key] = copy
		end
	end
	return out
end

local function loadSettings()
	if type(readfile) ~= "function" then
		return
	end
	local ok, raw = pcall(readfile, SETTINGS_FILE)
	if not ok or type(raw) ~= "string" or raw == "" then
		return
	end
	local HttpService = game:GetService("HttpService")
	local decoded
	ok = pcall(function()
		decoded = HttpService:JSONDecode(raw)
	end)
	if not ok or type(decoded) ~= "table" then
		return
	end
	for key, value in pairs(decoded) do
		local want = Control.Settings[key]
		if want ~= nil then
			if type(want) == "table" then
				if type(value) == "table" then
					local copy = {}
					for k, v in pairs(value) do
						copy[tostring(k)] = v
					end
					SavedSettings[key] = copy
				end
			elseif type(value) == type(want) then
				SavedSettings[key] = value
			end
		end
	end
end

local function saveSettings()
	if type(writefile) ~= "function" then
		return false
	end
	local HttpService = game:GetService("HttpService")
	local ok, json = pcall(function()
		return HttpService:JSONEncode(plainSettings())
	end)
	if not ok or type(json) ~= "string" then
		return false
	end
	return (pcall(writefile, SETTINGS_FILE, json))
end

loadSettings()

local function savedDefaults()
	local out = {}
	for key, value in pairs(Control.Settings) do
		local kind = type(value)
		if kind == "boolean" or kind == "number" or kind == "string" then
			local saved = SavedSettings[key]
			out[key] = (type(saved) == kind) and saved or value
		end
	end
	out.FlySpeed = math.clamp(tonumber(out.FlySpeed) or 80, 10, 80)
	out.FlyPin = math.clamp(tonumber(out.FlyPin) or 3, 0, 8)
	out.TpCooldown = math.clamp(tonumber(out.TpCooldown) or 12, 0, 90)
	out.TpIdleAfter = math.clamp(tonumber(out.TpIdleAfter) or 4, 0, 30)
	local savedRarity = SavedSettings.AutoLockRarity
	if type(savedRarity) == "table" then
		out.AutoLockRarity = savedRarity
	else
		out.AutoLockRarity = {}
	end
	if type(out.UserName) ~= "string" or out.UserName == "" then
		out.UserName = "TocoHub"
	end
	return out
end

local function buildUi()
	local loaded, Fluent = pcall(function()
		return loadstring(game:HttpGet(FLUENT_URL))()
	end)
	if not loaded or type(Fluent) ~= "table" then
		Control.BuildError = "Fluent load failed: " .. tostring(Fluent)
		warn("[FishingMaster] " .. Control.BuildError)
		return nil
	end

	local window
	local ui = {}
	ui.errors = {}
	local farmShown = false
	local uiReady = false
	local defaults = savedDefaults()
	for key, value in pairs(defaults) do
		if type(value) ~= "table" then
			Control.Settings[key] = value
		end
	end
	Control.Settings.AutoLockRarity = defaults.AutoLockRarity

	local built, err = pcall(function()
		window = Fluent:CreateWindow({
			Title = "TocoHub",
			SubTitle = "AutoFarm · Fishing Master",
			Version = "v1.5",
			TabWidth = 160,
			Size = UDim2.fromOffset(560, 460),
			Acrylic = false,
			Theme = FLUENT_THEME,
			MinimizeKey = Enum.KeyCode.F6,
			Search = false,
			Tags = {
				{ Text = " AutoFarm ", Color = Color3.fromRGB(45, 212, 191) },
			},
			UserInfoTop = true,
			UserInfoTitle = defaults.UserName,
			UserInfoSubtitle = Player.DisplayName,
		})

		local tabFarm = window:AddTab({ Title = "AutoFarm", Icon = "settings" })

		local control = tabFarm:AddCollapsibleSection("Điều khiển", nil, true)
		ui.farm = control:AddToggle("Farm", {
			Title = "Tự động câu",
			Description = "",
			Default = false,
		})
		ui.farm:OnChanged(function(state)
			farmShown = state
			if not uiReady then
				return
			end
			if state == Control.Running and not Control.Stopped then
				return
			end
			if state then
				Control:Start()
			else
				Control:Stop()
			end
		end)
		ui.status = control:AddParagraph({
			Title = "Trạng thái",
			Content = "Đang khởi tạo...",
		})
		ui.sell = control:AddButton({
			Title = "Bán ngay",
			Description = "Bán toàn bộ cá trong rương",
			Callback = function()
				Control:RequestSell()
			end,
		})
		control:AddToggle("AutoSellWhenFull", {
			Title = "Tự bán khi đầy rương",
			Description = "Bán hết cá ngay khi rương đầy",
			Default = defaults.AutoSellWhenFull,
			Callback = function(value)
				Settings.AutoSellWhenFull = value
				SavedSettings.AutoSellWhenFull = value
			end,
		})

		local lockPanel = tabFarm:AddCollapsibleSection("Tự khoá cá", nil, true)
		lockPanel:AddToggle("AutoLock", {
			Title = "Tự động khoá",
			Description = "Cá đạt độ hiếm đã chọn sẽ bị khoá ngay, không bao giờ bị bán",
			Default = defaults.AutoLock,
			Callback = function(value)
				Settings.AutoLock = value
				SavedSettings.AutoLock = value
			end,
		})

		local rarityNames = Control:RarityList()
		local rarityCounts = Control:RarityCounts()
		local countParts = {}
		for index = 1, #rarityNames do
			local rarity = rarityNames[index]
			countParts[index] = ("%s %d"):format(rarity, rarityCounts[rarity] or 0)
		end

		Settings.AutoLock = defaults.AutoLock
		Settings.AutoLockRarity = defaults.AutoLockRarity

		ui.autoLockRarity = lockPanel:AddDropdown("AutoLockRarity", {
			Title = "Độ hiếm cần khoá",
			Description = "" .. table.concat(countParts, " · "),
			Values = rarityNames,
			Multi = true,
			Default = defaults.AutoLockRarity,
			Callback = function(picked)
				local set = {}
				if type(picked) == "table" then
					for rarity in pairs(picked) do
						set[rarity] = true
					end
				end
				Settings.AutoLockRarity = set
				SavedSettings.AutoLockRarity = set
			end,
		})

		ui.lockInfo = lockPanel:AddParagraph({
			Title = "Đang khoá",
			Content = "chưa chọn độ hiếm nào",
		})

		lockPanel:AddButton({
			Title = "Khoá ngay",
			Description = "Quét rương và khoá luôn, không cần chờ câu",
			Callback = function()
				Control:AutoLockPass()
			end,
		})

		local tabTp = window:AddTab({ Title = "TP", Icon = "map-pin" })

		local tpPanel = tabTp:AddCollapsibleSection("Bay giữa các đảo", nil, true)
		Control.IslandNames = islandList()
		local islandNames = Control.IslandNames
		if #islandNames == 0 then
			for _ = 1, 20 do
				task.wait(0.5)
				islandNames = islandList()
				Control.IslandNames = islandNames
				if #islandNames > 0 then
					break
				end
			end
		end
		for _, entry in ipairs(islandNames) do
			local name = entry
			local label = islandLabel(name)
			local meta = islandMeta()
			local slot = meta and meta.map[name]
			local level = tonumber(slot and slot.level)
			local note = "Đảo mở sẵn"
			if level and level > 1 then
				note = (""):format(level)
			end
			tpPanel:AddButton({
				Title = label,
				Description = ("Bay tới đảo %s · %s"):format(label, note),
				Callback = function()
					Control:FlyToIsland(name)
				end,
			})
		end
		if #islandNames == 0 then
			tpPanel:AddParagraph({
				Title = "Chưa thấy đảo",
				Content = "",
			})
		end
		tpPanel:AddButton({
			Title = "Về chỗ đã lưu",
			Description = "Bay về điểm đã lưu trước khi bay đi",
			Callback = function()
				Control:FlyHome()
			end,
		})
		tpPanel:AddButton({
			Title = "Lưu chỗ này",
			Description = "Đặt vị trí hiện tại làm điểm để quay lại",
			Callback = function()
				Control:SaveHome()
			end,
		})
		tpPanel:AddSlider("FlySpeed", {
			Title = "Tốc độ bay",
			Description = "",
			Default = defaults.FlySpeed,
			Min = 10,
			Max = 80,
			Rounding = 0,
			Callback = function(value)
				Settings.FlySpeed = value
				SavedSettings.FlySpeed = value
			end,
		})
		tpPanel:AddSlider("FlyPin", {
			Title = "Thời gian giữ chỗ",
			Description = "",
			Default = defaults.FlyPin,
			Min = 0,
			Max = 8,
			Rounding = 1,
			Callback = function(value)
				Settings.FlyPin = value
				SavedSettings.FlyPin = value
			end,
		})
		tpPanel:AddToggle("TpForce", {
			Title = "Bay cả khi đang câu",
			Description = "",
			Default = defaults.TpForce,
			Callback = function(value)
				Settings.TpForce = value
				SavedSettings.TpForce = value
			end,
		})
		tpPanel:AddSlider("TpIdleAfter", {
			Title = "Chờ câu nguội",
			Description = "",
			Default = defaults.TpIdleAfter,
			Min = 0,
			Max = 30,
			Rounding = 1,
			Callback = function(value)
				Settings.TpIdleAfter = value
				SavedSettings.TpIdleAfter = value
			end,
		})
		tpPanel:AddSlider("TpCooldown", {
			Title = "Nghỉ giữa 2 lần bay",
			Description = "Giây chờ sau mỗi lần bay",
			Default = defaults.TpCooldown,
			Min = 0,
			Max = 90,
			Rounding = 1,
			Callback = function(value)
				Settings.TpCooldown = value
				SavedSettings.TpCooldown = value
			end,
		})

		local tabSetting = window:AddTab({ Title = "Setting", Icon = "wrench" })

		local afk = tabSetting:AddCollapsibleSection("Anti-AFK", nil, true)
		afk:AddToggle("AntiAfk", {
			Title = "Chống AFK",
			Description = "",
			Default = defaults.AntiAfk,
			Callback = function(value)
				Settings.AntiAfk = value
				SavedSettings.AntiAfk = value
			end,
		})
		afk:AddSlider("AntiAfkInterval", {
			Title = "Chu kỳ Anti-AFK",
			Description = "Giây giữa hai lần giảm phím (tối thiểu 10)",
			Default = defaults.AntiAfkInterval,
			Min = 10,
			Max = 300,
			Rounding = 0,
			Callback = function(value)
				Settings.AntiAfkInterval = value
				SavedSettings.AntiAfkInterval = value
			end,
		})
		afk:AddDropdown("AntiAfkKey", {
			Title = "Phím giảm",
			Description = "Phím này không bị UI câu hay script này dùng",
			Values = ANTI_AFK_KEYS,
			Default = defaults.AntiAfkKey,
			Callback = function(value)
				Settings.AntiAfkKey = value
				SavedSettings.AntiAfkKey = value
			end,
		})

		local options = tabSetting:AddCollapsibleSection("Tuỳ chọn", nil, true)
		options:AddSlider("FirstPullTarget", {
			Title = "Ngưỡng First Pull",
			Description = "Càng cao càng dễ trúng x10",
			Default = defaults.FirstPullTarget,
			Min = 0.8,
			Max = 0.99,
			Rounding = 2,
			Callback = function(value)
				Settings.FirstPullTarget = value
				SavedSettings.FirstPullTarget = value
			end,
		})
		options:AddSlider("CastHold", {
			Title = "Giữ nút câu",
			Description = "Số giây giữ nút để ném câu",
			Default = defaults.CastHold,
			Min = 0.1,
			Max = 1,
			Rounding = 2,
			Callback = function(value)
				Settings.CastHold = value
				SavedSettings.CastHold = value
			end,
		})
		options:AddSlider("QteDelay", {
			Title = "Độ trễ QTE",
			Description = "Chờ trước khi trả lời prompt",
			Default = defaults.QteDelay,
			Min = 0,
			Max = 0.6,
			Rounding = 2,
			Callback = function(value)
				Settings.QteDelay = value
				SavedSettings.QteDelay = value
			end,
		})

		local trip = tabSetting:AddCollapsibleSection("Đi tới thương nhân", nil, true)
		trip:AddToggle("WalkToSell", {
			Title = "Kéo tới thương nhân khi bán",
			Description = "Server chỉ bán trong 25 studs, nên tự kéo tạm tới NPC rồi bán",
			Default = defaults.WalkToSell,
			Callback = function(value)
				Settings.WalkToSell = value
				SavedSettings.WalkToSell = value
			end,
		})
		trip:AddToggle("ReturnAfterSell", {
			Title = "Quay lại chỗ cũ sau khi bán",
			Description = "Kéo ngược về vị trí đang câu, tắt nếu muốn đứng lại ở thương nhân",
			Default = defaults.ReturnAfterSell,
			Callback = function(value)
				Settings.ReturnAfterSell = value
				SavedSettings.ReturnAfterSell = value
			end,
		})

		local tabMisc = window:AddTab({ Title = "Misc", Icon = "sparkles" })

		local namePanel = tabMisc:AddCollapsibleSection("Tên trên đầu", nil, true)
		ui.userName = namePanel:AddInput("UserName", {
			Title = "Custom name",
			Description = "Tên hiện ở ô người chơi, trên cùng cửa sổ",
			Placeholder = "TocoHub",
			Default = defaults.UserName,
			Callback = function(value)
				local text = tostring(value or "")
				text = text:gsub("^%s+", ""):gsub("%s+$", "")
				if text == "" then
					text = Player.DisplayName
				end
				Settings.UserName = text
				SavedSettings.UserName = text
				saveSettings()
				Control.Storage.Name.dirty = true
			end,
		})
		namePanel:AddButton({
			Title = "Áp dụng ngay",
			Description = "Đặt lại tên đang gõ",
			Callback = function()
				Control.Storage.Name.dirty = true
			end,
		})
	end)

	if not built or not window then
		Control.BuildError = "UI build failed: " .. tostring(err)
		warn("[FishingMaster] " .. Control.BuildError)
		if type(Fluent.Destroy) == "function" then
			pcall(function()
				Fluent:Destroy()
			end)
		end
		return nil
	end

	local function statusText()
		local fishing = getController("FishingController")
		local state = "?"
		if fishing then
			local read, value = pcall(function()
				return fishing:GetState()
			end)
			if read then
				state = tostring(value)
			end
		end
		local mode
		if Control.Stopped then
			mode = "đã dừng"
		elseif Control.Running then
			mode = "đang chạy"
		else
			mode = "tạm dừng (F7)"
		end
		local lines = {
			("Câu: %s"):format(state),
			("AutoFarm: %s"):format(mode),
		}
		if state == "Reeling" then
			table.insert(lines, ("HP %d%%  |  Tension %d%%"):format(
				math.floor(hpRatio() * 100),
				math.floor(tensionRatio() * 100)
			))
		end
		local satchel = Control.Storage.Satchel
		if (satchel.capacity or 0) > 0 then
			table.insert(lines, ("Rương: %d/%d%s"):format(
				satchel.used or 0,
				satchel.capacity,
				satchel.isFull and "  (đầy)" or ""
			))
		end
		local sellStore = Control.Storage.Sell
		if sellStore.last and os.clock() - (sellStore.at or 0) < 10 then
			table.insert(lines, sellStore.last)
		end
		if Settings.AntiAfk and not Control.Stopped and (Stats.AntiAfk or 0) > 0 then
			table.insert(lines, ("Anti-AFK: %d lần"):format(Stats.AntiAfk))
		end
		local tp = Control.Storage.Teleport
		if tp.last and os.clock() - (tp.at or 0) < 12 then
			table.insert(lines, "TP: " .. tostring(tp.last))
		end
		return table.concat(lines, "\n")
	end

	local function lockStatusText()
		local lines = {}
		if Settings.AutoLock then
			local chosen = {}
			for rarity in pairs(Settings.AutoLockRarity or {}) do
				chosen[#chosen + 1] = rarity
			end
			if #chosen > 0 then
				table.sort(chosen, function(a, b)
					return (RarityPriority[a] or 99) < (RarityPriority[b] or 99)
				end)
				lines[#lines + 1] = ("Đang khoá: %s"):format(table.concat(chosen, ", "))
				lines[#lines + 1] = ("Rương: %d/%d con đã khoá"):format(
					Control:CountLocked(),
					Control.Storage.Satchel.used or 0
				)
			else
				lines[#lines + 1] = "Chưa chọn độ hiếm nào"
			end
		else
			lines[#lines + 1] = "Tự khoá đang tắt"
		end
		local lockStore = Control.Storage.Lock
		if lockStore.last and os.clock() - (lockStore.at or 0) < 10 then
			lines[#lines + 1] = lockStore.last
		end
		return table.concat(lines, "\n")
	end

	local function paintFarmToggle()
		local running = Control.Running and not Control.Stopped
		if not ui.farm or farmShown == running then
			return
		end
		farmShown = running
		local ok, err = pcall(function()
			ui.farm:SetValue(running)
		end)
		ui.errors.farm = ok and "ok" or ("set: " .. tostring(err))
	end

	local statusCache = { at = 0, text = nil }
	local lockCache = { at = 0, text = nil }
	local STATUS_REFRESH = 1
	local LOCK_REFRESH = 2.5

	local function refresh()
		local function paint(name, element, text)
			if not element then
				ui.errors[name] = "no element"
				return
			end
			local got, value = pcall(text)
			if not got then
				ui.errors[name] = "text: " .. tostring(value)
				return
			end
			local label = element.DescLabel
			if typeof(label) ~= "Instance" then
				ui.errors[name] = "no DescLabel"
				return
			end
			if label.Text == value then
				return
			end
			local ok, err = pcall(function()
				label.Text = value
			end)
			if not ok then
				task.spawn(function()
					local again, err2 = pcall(function()
						label.Text = value
					end)
					ui.errors[name] = again and "ok (spawn)" or ("set: " .. tostring(err2))
				end)
				ui.errors[name] = "retry"
			else
				ui.errors[name] = "ok"
			end
		end
		local now = os.clock()
		if now - statusCache.at >= STATUS_REFRESH or statusCache.text == nil then
			statusCache.at = now
			statusCache.text = statusText()
		end
		if now - lockCache.at >= LOCK_REFRESH or lockCache.text == nil then
			lockCache.at = now
			lockCache.text = lockStatusText()
		end
		paint("status", ui.status, function()
			return statusCache.text
		end)
		paint("lockInfo", ui.lockInfo, function()
			return lockCache.text
		end)
		paintFarmToggle()
		if os.clock() - (Control.Storage.Satchel.at or 0) >= 2.5 then
			Control:UpdateSatchel()
		end
		if Settings.AutoLock and os.clock() - (Control.Storage.Lock.at or 0) >= 1.2 then
			Control:AutoLockPass()
		end
		if os.clock() - lastSaveAt >= 5 then
			lastSaveAt = os.clock()
			saveSettings()
		end
	end

	local function buildToggleButton()
		for _, name in ipairs({ "FluentMinimizerGui", "AutoFarmToggle" }) do
			local stale = CoreGui:FindFirstChild(name)
			if typeof(stale) == "Instance" then
				pcall(function()
					stale:Destroy()
				end)
			end
		end
		local ok, err = pcall(function()
			local gui = Instance.new("ScreenGui")
			gui.Name = "AutoFarmToggle"
			gui.ResetOnSpawn = false
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.IgnoreGuiInset = true
			gui.DisplayOrder = 999999
			gui.Parent = CoreGui
			local button = Instance.new("TextButton")
			button.Name = "ToggleButton"
			button.Size = UDim2.fromOffset(46, 46)
			button.Position = UDim2.new(1, -12, 0, 12)
			button.AnchorPoint = Vector2.new(1, 0)
			button.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
			button.BackgroundTransparency = 0.15
			button.BorderSizePixel = 0
			button.AutoButtonColor = true
			button.Draggable = true
			button.Text = "UI"
			button.Font = Enum.Font.GothamBold
			button.TextSize = 14
			button.TextColor3 = Color3.fromRGB(255, 255, 255)
			button.Parent = gui
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = button
			button.MouseButton1Click:Connect(function()
				local win = Control.Window
				if not win then
					return
				end
				if win.Minimized then
					win:Show()
				else
					win:Hide()
				end
			end)
			Control.ToggleGui = gui
		end)
		if not ok then
			ui.errors.minimizer = tostring(err)
		end
	end

	function Control:_startUiTask()
		if self.UiTask or not self.Window then
			return
		end
		self.UiTask = task.spawn(function()
			while Control.Window and not Fluent.Unloaded do
				task.wait(0.75)
				refresh()
			end
			Control.UiTask = nil
		end)
	end

	local function userInfoLabel()
		local root = window and window.Root
		if not root then
			return nil
		end
		local side = root:FindFirstChild("_SidebarFrame", true) or root:FindFirstChild("SidebarFrame", true)
		if not side then
			return nil
		end
		local top = side:FindFirstChild("UserInfoTop", true) or side:FindFirstChild("UserInfo", true)
		if not top then
			return nil
		end
		return top:FindFirstChild("DisplayName", true)
	end

	local nameStore = Control.Storage.Name

	local NAME_RAINBOW = 7
	-- Roblox trim khoang trang nen DisplayName = " " bi tro ve ten goc; zero-width thi khong
	local NAME_HIDE = string.char(226, 128, 139)

	local function makeNameTag()
		local char = Player.Character
		if typeof(char) ~= "Instance" then
			return nil
		end
		local head = char:FindFirstChild("Head")
		if typeof(head) ~= "Instance" then
			head = char:FindFirstChild("HumanoidRootPart")
		end
		if typeof(head) ~= "Instance" then
			return nil
		end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local stale = head:FindFirstChild("TocoHubNameTag")
		if typeof(stale) == "Instance" then
			pcall(function()
				stale:Destroy()
			end)
		end
		local gui = Instance.new("BillboardGui")
		gui.Name = "TocoHubNameTag"
		gui.Adornee = head
		gui.Size = UDim2.fromOffset(240, 34)
		gui.StudsOffset = Vector3.new(0, 2.5, 0)
		gui.AlwaysOnTop = true
		gui.MaxDistance = 150
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = head
		local holder = Instance.new("Frame")
		holder.Name = "Holder"
		holder.Size = UDim2.fromScale(1, 1)
		holder.BackgroundTransparency = 1
		holder.Parent = gui
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(8, 10, 18)
		stroke.Thickness = 3
		stroke.Transparency = 0.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		stroke.Parent = holder
		local tag = Instance.new("TextLabel")
		tag.Name = "Label"
		tag.Size = UDim2.fromScale(1, 1)
		tag.BackgroundTransparency = 1
		tag.Text = tostring(Settings.UserName or Player.DisplayName)
		tag.TextSize = 16
		tag.Font = Enum.Font.GothamBold
		tag.TextColor3 = Color3.fromRGB(255, 255, 255)
		tag.TextStrokeTransparency = 1
		tag.RichText = false
		tag.Parent = holder
		if typeof(humanoid) == "Instance" then
			nameStore.humanoid = humanoid
			pcall(function()
				humanoid.DisplayName = NAME_HIDE
			end)
		end
		return tag
	end

	-- game tu ve nametag bang Part + SurfaceGui trong Workspace.Nametags; xoa de hien ten rieng
	local function killGameNameTag()
		local now = os.clock()
		if now - (nameStore.lastKill or 0) < 0.5 then
			return
		end
		nameStore.lastKill = now
		local folder = Services.Workspace:FindFirstChild("Nametags")
		if typeof(folder) ~= "Instance" then
			return
		end
		local own = folder:FindFirstChild(Player.Name)
		if typeof(own) == "Instance" then
			pcall(function()
				own:Destroy()
			end)
		end
	end

	local function refreshName()
		local text = tostring(Settings.UserName or "")
		if text == "" then
			text = tostring(Player.DisplayName)
		end

		local label = nameStore.label
		if typeof(label) ~= "Instance" or not label.Parent then
			label = userInfoLabel()
			nameStore.label = label
		end

		local tag = nameStore.tagLabel
		if typeof(tag) ~= "Instance" or not tag.Parent then
			tag = makeNameTag()
			nameStore.tagLabel = tag
		end

		if nameStore.dirty or nameStore.text ~= text then
			nameStore.text = text
			nameStore.dirty = false
			pcall(function()
				if typeof(label) == "Instance" then
					label.Text = text
				end
			end)
			pcall(function()
				if typeof(tag) == "Instance" then
					tag.Text = text
				end
			end)
		end

		local humanoid = nameStore.humanoid
		if typeof(humanoid) ~= "Instance" or not humanoid.Parent then
			humanoid = nil
			nameStore.humanoid = nil
		end
		if humanoid and humanoid.DisplayName ~= NAME_HIDE then
			pcall(function()
				humanoid.DisplayName = NAME_HIDE
			end)
		end

		killGameNameTag()

		nameStore.step = (nameStore.step + 1) % NAME_RAINBOW
		local color = Color3.fromHSV(nameStore.step / NAME_RAINBOW, 0.85, 1)
		if nameStore.color ~= color then
			nameStore.color = color
			pcall(function()
				if typeof(label) == "Instance" then
					label.TextColor3 = color
				end
			end)
			pcall(function()
				if typeof(tag) == "Instance" then
					tag.TextColor3 = color
				end
			end)
		end
	end

	function Control:_startNameTask()
		if self.NameTask or not self.Window then
			return
		end
		self.NameTask = task.spawn(function()
			local store = Control.Storage.Name
			while Control.Window and not Fluent.Unloaded do
				local ok, err = pcall(refreshName)
				store.calls = (store.calls or 0) + 1
				if not ok then
					store.err = tostring(err)
				end
			 task.wait(0.2)
			end
			Control.NameTask = nil
		end)
	end

	ui.window = window
	ui.refresh = refresh
	ui.startTask = function()
		Control:_startUiTask()
	end

	Control.Window = window
	Control.Library = Fluent
	buildToggleButton()
	refresh()
	uiReady = true
	Control:_startUiTask()

	Env.AutoFarmUI = ui
	return ui
end

buildUi()
Control:Stop()
local bootUi = Env.AutoFarmUI
if bootUi and bootUi.startTask then
	bootUi.startTask()
end
Control:_startNameTask()

Env.FishingMasterLoaded = os.clock()
