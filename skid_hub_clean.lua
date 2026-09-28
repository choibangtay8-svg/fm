local getgenv_ = (typeof and typeof(getgenv) == "function" and getgenv()) or _G

-- Dọn bản cũ nếu có (tránh chạy 2 loop)
pcall(function()
	if type(getgenv_.SkidHub) == "table" and type(getgenv_.SkidHub.Stop) == "function" then
		getgenv_.SkidHub.Stop()
	end
	if type(getgenv_.AutoFishOnly) == "table" and type(getgenv_.AutoFishOnly.Stop) == "function" then
		getgenv_.AutoFishOnly.Stop()
	end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Stardust = require(ReplicatedStorage:WaitForChild("Stardust"))
local Client = Stardust.Client
local Data = ReplicatedStorage:WaitForChild("Data")
local FishingPackets = require(Data:WaitForChild("Packets"):WaitForChild("FishingPackets"))
local FishingConfig = require(Data:WaitForChild("Config"):WaitForChild("FishingConfig"))
local FishingEnums = require(Data:WaitForChild("Enums"):WaitForChild("FishingEnums"))
local PullBarMath = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Lib"):WaitForChild("PullBarMath"))
local SellEnums = nil
local RarityOrder = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine" }
pcall(function()
	SellEnums = require(Data:WaitForChild("Enums"):WaitForChild("SellEnums"))
end)
pcall(function()
	local RarityEnums = require(Data:WaitForChild("Enums"):WaitForChild("RarityEnums"))
	if type(RarityEnums.Order) == "table" and #RarityEnums.Order > 0 then
		RarityOrder = RarityEnums.Order
	end
end)
local Packet = Stardust.Packet
local SellToggleLock = nil
pcall(function()
	SellToggleLock = Packet("SellToggleLock", Packet.String):Response(Packet.NumberU8, Packet.Boolean8)
end)

local FishingController, RodController, LootController, PlayerDataV2Controller, Catalog = nil, nil, nil, nil, nil
pcall(function() FishingController = Client.GetController("FishingController") end)
pcall(function() RodController = Client.GetController("RodController") end)
pcall(function() LootController = Client.GetController("LootController") end)
pcall(function() PlayerDataV2Controller = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("PlayerDataV2Controller")) end)
pcall(function() Catalog = require(Data:WaitForChild("Catalog")) end)

local Config = {
	Enabled = false,          -- nút 1: Auto Câu (y nguyên Hune FarmToggle)
	AutoSkillLowHP = false,   -- nút 2: Auto Skill máu thấp (y nguyên Hune AutoSkill)
	FarmDelay = 0.35,         -- delay mặc định Hune, chỉnh bằng nút -/+ hoặc SetDelay()
	StallTimeout = 30,        -- Waiting quá lâu -> cancel + recast
	SkillOrder = {"Slot1", "Slot2", "Slot3", "Slot4"}, -- combo Z,X,C,V y nguyên
	FilterEnabled = false,    -- lọc cá theo độ hiếm (y nguyên SkipUnselectedFish)
	FarmRarities = { Legendary = true, Mythical = true, Divine = true }, -- y nguyên default Hune
	AutoLock = false,         -- tự lock cá theo độ hiếm (y nguyên applyLocks)
	LockRarities = { Legendary = true, Mythical = true, Divine = true }, -- y nguyên default Hune
	-- No native panel. WindUI only (Farm + Lock).
}

-- Reel spam interval lấy từ config game (giống Hune)
local ReelInterval = 1 / math.max(
	(FishingConfig.GetClickCps and FishingConfig.GetClickCps("Manual"))
		or (FishingConfig.Click and FishingConfig.Click.ManualCps)
		or 6, 1
)
-- QTE reaction delay (giống Hune)
local QteDelay = math.max(
	((FishingConfig.Latency and FishingConfig.Latency.QteReactionFloor) or 0.1) + 0.12,
	((FishingConfig.Counter and FishingConfig.Counter.StrictInputSettleTime) or 0.08) + 0.1
)

local Running = true
local Connections = {}
local Threads = {}
local ReelGen, FirstPullGen, LootGen, QteGen, SkillGen = 0, 0, 0, 0, 0
local ReelActive, FirstPullActive, LootActive, SkillActive = false, false, false, false
local NextCastAt = 0
local LastState, LastStateAt = nil, os.clock()
local ReelCounter = 0
-- HP + skill (giống Hune fn84/fn85)
local CurrentHP, MaxHP = 0, 0
local FinisherPct = (FishingConfig.Fight and FishingConfig.Fight.FinisherPct) or 0.075
local SkillBlockUntil = 0
local SkillCD = {} -- [Slot] = expiresAt
local SkillIndex = 1
local _skillCDHooked = false

local function track(conn)
	table.insert(Connections, conn)
	return conn
end

local function GetState()
	if not FishingController then
		pcall(function() FishingController = Client.GetController("FishingController") end)
	end
	local s = nil
	if FishingController then
		pcall(function() s = FishingController:GetState() end)
	end
	return s
end

local function GetHRP()
	local c = LocalPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart") or nil
end

local function IsRodEquipped()
	local c = LocalPlayer.Character
	if not c then return false end
	for _, t in ipairs(c:GetChildren()) do
		if t:IsA("Tool") then return true end
	end
	return false
end

local function EnsureRod()
	local c = LocalPlayer.Character
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if IsRodEquipped() then return true end
	local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
	if not bp then return false end
	local tool = nil
	for _, t in ipairs(bp:GetChildren()) do
		if t:IsA("Tool") then tool = tool or t end
	end
	if not tool then return false end
	local ok = pcall(function() hum:EquipTool(tool) end)
	if not ok then return false end
	local deadline = os.clock() + 0.75
	while os.clock() < deadline do
		if tool.Parent == c then return true end
		task.wait(0.05)
	end
	return tool.Parent == c
end

local function CastPower()
	local base = (FishingConfig.LuckBar and FishingConfig.LuckBar.Threshold) or 0.8
	return math.min(math.max(base + 0.15, 0.95), 0.98)
end

local function CastPosition(power)
	local hrp = GetHRP()
	if not hrp then return Vector3.zero end
	local cast = FishingConfig.Cast or { BaitMinDist = 15, BaitMaxDist = 30 }
	local dist = cast.BaitMinDist + (power or 0) * (cast.BaitMaxDist - cast.BaitMinDist)
	local look = hrp.CFrame.LookVector
	local unit = Vector3.new(look.X, 0, look.Z)
	if unit.Magnitude < 0.01 then unit = Vector3.new(0, 0, 1) end
	unit = unit.Unit
	-- Y mặt nước: cố lấy theo island, fallback 3
	local waterY = 3
	pcall(function()
		local IslandController = Client.GetController("IslandController")
		local islandId = IslandController and IslandController:GetCurrentIslandId() or ""
		local Catalog = require(Data:WaitForChild("Catalog"))
		waterY = Catalog.Island.GetWaterY(islandId)
	end)
	return Vector3.new(hrp.Position.X + unit.X * dist, waterY, hrp.Position.Z + unit.Z * dist)
end

local function DoCast()
	if not Config.Enabled then return false end
	if not EnsureRod() then return false end
	local power = CastPower()
	local pos = CastPosition(power)
	local ok = pcall(function()
		FishingPackets.FishCast:Fire(power, pos)
	end)
	return ok
end

-- Perfect zone: zone có multiplier == 10 (giống Hune fn88)
local function PerfectZone()
	local zones = (FishingConfig.PullBar and FishingConfig.PullBar.Zones) or {}
	local lo = 0
	for _, z in ipairs(zones) do
		if z.multiplier == 10 then
			return lo, z.threshold
		end
		lo = z.threshold or lo
	end
	return 0.8769, 1
end

local function QteKey(dir)
	local k = nil
	pcall(function() k = FishingConfig.Counter.DirectionToKey[dir] end)
	if k == "W" or k == "A" or k == "D" then return k end
	local fb = { Up = "W", Left = "A", Right = "D", W = "W", A = "A", D = "D" }
	return fb[dir]
end

local function ClickLoot()
	local cam = workspace.CurrentCamera
	local sz = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
	local p = Vector2.new(sz.X * 0.5, sz.Y * 0.92)
	local ok = pcall(function()
		VirtualInputManager:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0)
		task.wait(0.02)
		VirtualInputManager:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
	end)
	if ok then return true end
	return pcall(function()
		local vu = game:GetService("VirtualUser")
		vu:CaptureController()
		local cf = (cam and cam.CFrame) or CFrame.new()
		vu:Button1Down(p, cf)
		task.wait(0.02)
		vu:Button1Up(p, cf)
	end)
end

local function IsLowHP()
	return MaxHP > 0 and CurrentHP > 0 and CurrentHP <= MaxHP * FinisherPct + 0.001
end

local function GetBookSlots()
	if not PlayerDataV2Controller then return nil end
	local data = nil
	pcall(function() data = PlayerDataV2Controller:Fetch(LocalPlayer) end)
	local equip = data and data.RodEquip
	local book = equip and data.Rods and data.Rods[equip] and data.Rods[equip].BookSlots
	if type(book) == "table" then return book end
	return nil
end

local function EnsureSkillCDListener()
	if not RodController then
		pcall(function() RodController = Client.GetController("RodController") end)
	end
	if RodController and RodController.ReplicatedSkillCooldown and not _skillCDHooked then
		_skillCDHooked = true
		track(RodController.ReplicatedSkillCooldown.OnClientEvent:Connect(function(arg)
			if type(arg) ~= "table" then return end
			for slot, info in pairs(arg) do
				if type(slot) == "string" and type(info) == "table" then
					if info.phase == "Ready" then
						SkillCD[slot] = nil
					elseif info.phase == "Cooldown" and tonumber(info.remaining) then
						SkillCD[slot] = os.clock() + tonumber(info.remaining)
					elseif info.phase == "Casting" then
						SkillCD[slot] = os.clock() + math.max(tonumber(info.remaining) or 0.5, 0.5) + 0.2
					end
				end
			end
		end))
	end
end

local function TryFireOneSkill()
	if not RodController then
		pcall(function() RodController = Client.GetController("RodController") end)
	end
	if not RodController or not RodController.Moveset then return false end
	local book = GetBookSlots()
	if not book then return false end
	local order = Config.SkillOrder
	for i = 0, #order - 1 do
		local idx = ((SkillIndex + i - 1) % #order) + 1
		local slot = order[idx]
		local skillId = book[slot]
		if type(skillId) == "string" and skillId ~= "" then
			local cd = SkillCD[slot]
			if not cd or os.clock() >= cd then
				-- kiểm tra CooldownActive trực tiếp nếu có
				local busy = false
				pcall(function()
					local ca = RodController.CooldownActive and RodController.CooldownActive[slot]
					if type(ca) == "table" and (ca.phase == "Cooldown" or ca.phase == "Casting") then
						if ca.phase == "Casting" then busy = true
						elseif ca.endTick and tick() < ca.endTick then busy = true
						elseif not ca.endTick then busy = true end
					end
				end)
				if not busy then
					local ok = pcall(function()
						RodController.Moveset:Fire(slot, skillId)
					end)
					if ok then
						SkillIndex = idx % #order + 1
						SkillCD[slot] = os.clock() + 0.6 -- chống spam nếu server chưa trả cooldown
						return true
					end
				end
			end
		end
	end
	return false
end

local function StartSkillLoop(gen)
	if SkillActive and gen == SkillGen then return end
	SkillActive = true
	task.spawn(function()
		EnsureSkillCDListener()
		while Config.Enabled and Config.AutoSkillLowHP and Running and gen == SkillGen do
			if GetState() ~= FishingEnums.State.Reeling then
				task.wait(0.1)
				-- thoát khi hết reeling thì vòng reel sẽ tăng gen để dừng
				if GetState() ~= FishingEnums.State.Reeling then
					-- chờ event mới, không break ngay để đỡ miss phase HP
					task.wait(0.1)
				end
			else
				if IsLowHP() then
					if LocalPlayer:GetAttribute("IsUsingSkill") ~= true and os.clock() >= SkillBlockUntil then
						TryFireOneSkill()
					end
					task.wait(0.12)
				else
					task.wait(0.15)
				end
			end
			if gen ~= SkillGen then break end
			-- nếu tắt skill giữa chừng
			if not Config.AutoSkillLowHP then break end
		end
		if gen == SkillGen then SkillActive = false end
	end)
end

-- ===== Lọc cá + Auto Lock (y nguyên Hune tbl10) =====
local SkipPending, SkipAt, LastCancelAt, CurrentFishId = false, 0, -math.huge, nil
local VerifiedLocked, ObservedLocked, LastLockAttempt = {}, {}, {}
local Locking, LockQueued, LockAgain = false, false, false

local function MatchesRarity(fishId, set)
	if not Catalog or not Catalog.Fish or not Catalog.Fish.GetById then return false end
	local ok, info = pcall(function() return Catalog.Fish.GetById(fishId) end)
	if not ok or type(info) ~= "table" then return false end
	return set[info.rarity] == true
end

local function ShouldSkipFish(fishId)
	-- y nguyên tbl10:shouldSkip (bỏ nhánh boss vì fork riêng không cần)
	if not Config.Enabled or not Config.FilterEnabled then return false end
	if type(fishId) ~= "string" or fishId == "" then return false end
	return not MatchesRarity(fishId, Config.FarmRarities)
end

local function SkipCurrentFish()
	if not SkipPending then
		SkipPending = true
		SkipAt = os.clock()
	end
	if os.clock() - LastCancelAt >= 0.3 then
		LastCancelAt = os.clock()
		pcall(function() FishingPackets.FishCancel:Fire() end)
	end
end

local function AllowsCurrent()
	if SkipPending then return false end
	if not (Config.Enabled and Config.FilterEnabled) then return true end
	local fid = CurrentFishId
	if not fid and FishingController then
		pcall(function() fid = FishingController:GetFishInfo() end)
		CurrentFishId = fid
	end
	if type(fid) ~= "string" or fid == "" then return false end
	if ShouldSkipFish(fid) then
		SkipCurrentFish()
		return false
	end
	return true
end

local function ApplyLocks()
	-- y nguyên tbl10:applyLocks
	if not Config.AutoLock or not SellToggleLock then return true end
	if not next(Config.LockRarities) then return true end
	if not PlayerDataV2Controller then return false end
	local data = nil
	pcall(function() data = PlayerDataV2Controller:Fetch(LocalPlayer) end)
	local fishes = data and data.Inventory and data.Inventory.Fishes
	if type(fishes) ~= "table" then return false end
	local allOk = true
	for k, fishe in pairs(fishes) do
		if type(fishe) == "table" then
			local uid = fishe.uid or k
			if fishe.locked == true then
				VerifiedLocked[uid] = true
				ObservedLocked[uid] = true
			elseif ObservedLocked[uid] then
				VerifiedLocked[uid] = nil
				ObservedLocked[uid] = false
			end
			if fishe.locked ~= true and not VerifiedLocked[uid] and MatchesRarity(fishe.fishId, Config.LockRarities) then
				if type(uid) == "string" then
					local now = os.clock()
					if now - (LastLockAttempt[uid] or -math.huge) >= 2 then
						LastLockAttempt[uid] = now
						local ok, r1, r2 = pcall(function() return SellToggleLock:Fire(uid) end)
						local expect = SellEnums and SellEnums.Status and SellEnums.Status.Ok or 0
						if not ok or (r1 ~= expect and r1 ~= 0 and r1 ~= true) or (r2 ~= true and r2 ~= 0 and r2 ~= nil and r2 ~= expect) then
							-- Hune check: result == Ok và result2 == true, giữ tương thích fork (chấp nhận 0/true)
							if not (ok and (r2 == true or r1 == true or r1 == expect)) then
								allOk = false
							else
								VerifiedLocked[uid] = true
							end
						else
							VerifiedLocked[uid] = true
						end
						task.wait(0.08)
					else
						allOk = false
					end
				else
					allOk = false
				end
			end
		end
	end
	return allOk
end

local function QueueLocks()
	if not Config.AutoLock then return end
	if Locking then LockAgain = true return end
	if LockQueued then return end
	LockQueued = true
	task.delay(0.2, function()
		LockQueued = false
		if not Config.AutoLock then return end
		if Locking then LockAgain = true return end
		Locking = true
		pcall(ApplyLocks)
		Locking = false
		if LockAgain then
			LockAgain = false
			QueueLocks()
		end
	end)
end

pcall(function()
	if PlayerDataV2Controller and PlayerDataV2Controller.Listen then
		track(PlayerDataV2Controller:Listen(LocalPlayer, QueueLocks))
	end
end)

-- ===== Event handlers (core auto câu) =====

track(FishingPackets.FishWaitingAck.OnClientEvent:Connect(function()
	CurrentFishId = nil
	LastState, LastStateAt = FishingEnums.State.Waiting, os.clock()
end))

track(FishingPackets.FishFirstPullStart.OnClientEvent:Connect(function(_fishId, _a, _timeLimit, _serverTime)
	if not Config.Enabled then return end
	CurrentFishId = _fishId
	if ShouldSkipFish(_fishId) then
		SkipCurrentFish()
		return
	end
	FirstPullGen += 1
	local gen = FirstPullGen
	FirstPullActive = true
	task.spawn(function()
		local lo, hi = PerfectZone()
		lo = lo + 0.025
		local speed = (FishingConfig.FirstPull and FishingConfig.FirstPull.OscillateSpeed) or 2.4
		local limit = tonumber(_timeLimit) or ((FishingConfig.FirstPull and FishingConfig.FirstPull.TimeLimit) or 2)
		local startT = tonumber(_serverTime)
		if startT then
			limit = limit - (workspace:GetServerTimeNow() - startT)
		end
		local deadline = os.clock() + math.max(limit - 0.1, 0.05)
		task.wait(0.05)
		local prev = nil
		while Config.Enabled and Running and gen == FirstPullGen and os.clock() < deadline do
			if not AllowsCurrent() then break end
			if GetState() ~= FishingEnums.State.FirstPull then
				if GetState() ~= FishingEnums.State.Waiting then break end
				task.wait(0.015)
				continue
			end
			local val = nil
			local rising = false
			if startT then
				local dt = workspace:GetServerTimeNow() - startT
				val = PullBarMath.Position(dt, speed)
				rising = (math.max(dt, 0) * speed % 2) <= 1
			else
				pcall(function() val = FishingController:GetPullBarValue() end)
				rising = type(val) == "number" and prev ~= nil and val > prev + 0.001
				if prev == nil then rising = true end
			end
			if type(val) == "number" then
				if rising and val >= lo and val <= hi then
					pcall(function() FishingPackets.FishFirstPull:Fire() end)
					break
				end
				prev = val
			end
			task.wait(0.015)
		end
		-- fallback: hết giờ vẫn pull 1 cái
		if Config.Enabled and gen == FirstPullGen and GetState() == FishingEnums.State.FirstPull then
			pcall(function() FishingPackets.FishFirstPull:Fire() end)
		end
		if gen == FirstPullGen then FirstPullActive = false end
	end)
end))

track(FishingPackets.FishReelStartAck.OnClientEvent:Connect(function(_fishId, hp, maxHp)
	if not Config.Enabled then return end
	CurrentFishId = _fishId
	if not AllowsCurrent() then return end
	CurrentHP, MaxHP = tonumber(hp) or 0, tonumber(maxHp) or 0
	SkillBlockUntil = 0
	ReelGen += 1
	local gen = ReelGen
	ReelActive = true
	if Config.AutoSkillLowHP then
		SkillGen += 1
		StartSkillLoop(SkillGen)
	end
	task.spawn(function()
		while Config.Enabled and Running and gen == ReelGen do
			if not AllowsCurrent() then break end
			local st = GetState()
			if st and st ~= FishingEnums.State.Reeling then break end
			-- nhường skill cast / QTE giống Hune (n15 + IsUsingSkill)
			if LocalPlayer:GetAttribute("IsUsingSkill") == true or os.clock() < SkillBlockUntil then
				task.wait(0.03)
			else
				ReelCounter = (ReelCounter + 1) % 65536
				pcall(function() FishingPackets.FishReelPull:Fire(ReelCounter) end)
				task.wait(ReelInterval)
			end
		end
		if gen == ReelGen then ReelActive = false end
	end)
end))

track(FishingPackets.FishReelHPUpdate.OnClientEvent:Connect(function(_hp)
	if not AllowsCurrent() then return end
	CurrentHP = tonumber(_hp) or CurrentHP
end))

track(FishingPackets.FishReelPhaseHP.OnClientEvent:Connect(function(_hp, _max)
	if not AllowsCurrent() then return end
	CurrentHP = tonumber(_hp) or CurrentHP
	MaxHP = tonumber(_max) or MaxHP
end))

track(FishingPackets.FishSkillWindow.OnClientEvent:Connect(function(dur)
	SkillBlockUntil = math.max(SkillBlockUntil, os.clock() + math.max(tonumber(dur) or 0, 0))
end))

track(FishingPackets.FishQTEPrompt.OnClientEvent:Connect(function(dir, timeout)
	if not Config.Enabled then return end
	if not AllowsCurrent() then return end
	local key = QteKey(dir)
	if not key then return end
	QteGen += 1
	local gen = QteGen
	local t = math.max(tonumber(timeout) or 0.5, 0.05)
	task.delay(math.min(QteDelay, math.max(t - 0.2, 0.02)), function()
		if gen ~= QteGen or not Config.Enabled or not Running then return end
		if GetState() ~= FishingEnums.State.Reeling then return end
		pcall(function() FishingPackets.FishQTEResponse:Fire(key) end)
	end)
end))

track(FishingPackets.FishCatchResult.OnClientEvent:Connect(function(success, _fish, _val)
	SkipPending = false
	CurrentFishId = nil
	ReelGen += 1 ReelActive = false
	FirstPullGen += 1 FirstPullActive = false
	SkillGen += 1 SkillActive = false
	CurrentHP, MaxHP = 0, 0
	QueueLocks()
	NextCastAt = os.clock() + math.max(Config.FarmDelay, 0.1)
	LastState, LastStateAt = FishingEnums.State.Caught, os.clock()
	if not success or not Config.Enabled then return end
	LootGen += 1
	local gen = LootGen
	LootActive = true
	task.spawn(function()
		local delay = ((FishingConfig.Loot and FishingConfig.Loot.ConfirmReadyDelay) or 0.75) + 0.08
		task.wait(delay)
		for _ = 1, 12 do
			if not Config.Enabled or not Running or gen ~= LootGen then break end
			if GetState() ~= FishingEnums.State.Caught then break end
			if not LootController then
				pcall(function() LootController = Client.GetController("LootController") end)
			end
			local active = false
			if LootController then
				pcall(function() active = LootController:IsFishingLootActive() end)
			end
			if active then ClickLoot() end
			task.wait(0.15)
		end
		if gen == LootGen then LootActive = false end
	end)
end))

track(FishingPackets.FishReset.OnClientEvent:Connect(function()
	SkipPending = false
	CurrentFishId = nil
	ReelGen += 1 ReelActive = false
	FirstPullGen += 1 FirstPullActive = false
	LootGen += 1 LootActive = false
	SkillGen += 1 SkillActive = false
	CurrentHP, MaxHP = 0, 0
	NextCastAt = os.clock() + math.max(Config.FarmDelay, 0.1)
	LastState, LastStateAt = FishingEnums.State.Idling, os.clock()
end))

-- ===== Main loop: chỉ recast khi Idling (y nguyên Hune state 94-105) =====
table.insert(Threads, task.spawn(function()
	while Running do
		if Config.Enabled then
			local st = GetState()
			if st ~= LastState then
				LastState, LastStateAt = st, os.clock()
			end
			if st == FishingEnums.State.Idling then
				if SkipPending then
					if os.clock() - SkipAt < 0.5 then
						task.wait(0.05)
					else
						SkipPending = false
						CurrentFishId = nil
					end
				elseif os.clock() >= NextCastAt then
					DoCast()
					NextCastAt = os.clock() + 1
				end
			elseif st == FishingEnums.State.Waiting then
				if os.clock() - LastStateAt > Config.StallTimeout then
					pcall(function() FishingPackets.FishCancel:Fire() end)
					LastStateAt = os.clock()
					NextCastAt = os.clock() + 1
				end
			end
		end
		task.wait(0.05)
	end
end))

local Api = {}
Api.Config = Config
function Api.Start()
	Config.Enabled = true
	SkipPending = false
	CurrentFishId = nil
	NextCastAt = 0
	LastState, LastStateAt = GetState(), os.clock()
end
function Api.Stop()
	Config.Enabled = false
	SkipPending = false
	CurrentFishId = nil
	ReelGen += 1 ReelActive = false
	FirstPullGen += 1 FirstPullActive = false
	LootGen += 1 LootActive = false
	SkillGen += 1 SkillActive = false
	CurrentHP, MaxHP = 0, 0
	QteGen += 1
	pcall(function() FishingPackets.FishCancel:Fire() end)
end
function Api.SetSkill(on)
	Config.AutoSkillLowHP = on and true or false
	EnsureSkillCDListener()
	if Config.AutoSkillLowHP and Config.Enabled and GetState() == FishingEnums.State.Reeling then
		SkillGen += 1
		StartSkillLoop(SkillGen)
	else
		SkillGen += 1 SkillActive = false
	end
end
function Api.SetFilter(on)
	Config.FilterEnabled = on and true or false
	if not Config.FilterEnabled then
		SkipPending = false
	else
		local st = GetState()
		if st == FishingEnums.State.FirstPull or st == FishingEnums.State.Reeling then
			AllowsCurrent()
		end
	end
end
function Api.SetFarmRarity(rarity, on)
	if type(rarity) ~= "string" then return end
	if on then Config.FarmRarities[rarity] = true else Config.FarmRarities[rarity] = nil end
	if Config.FilterEnabled and Config.Enabled then
		local st = GetState()
		if st == FishingEnums.State.FirstPull or st == FishingEnums.State.Reeling then
			AllowsCurrent()
		end
	end
end
function Api.SetAutoLock(on)
	Config.AutoLock = on and true or false
	EnsureSkillCDListener()
	if Config.AutoLock then QueueLocks() end
end
function Api.SetLockRarity(rarity, on)
	if type(rarity) ~= "string" then return end
	if on then Config.LockRarities[rarity] = true else Config.LockRarities[rarity] = nil end
	if Config.AutoLock then QueueLocks() end
end
function Api.SetSkillOrder(orderStr)
	-- y nguyên Hune: "Z,X,C,V" -> Slot1..4
	local map = { Z = "Slot1", X = "Slot2", C = "Slot3", V = "Slot4" }
	local order, seen = {}, {}
	for token in tostring(orderStr or ""):upper():gmatch("[^,%s>]+") do
		local slot = map[token]
		if slot and not seen[slot] then
			table.insert(order, slot)
			seen[slot] = true
		end
	end
	if #order > 0 then
		Config.SkillOrder = order
		SkillIndex = 1
		return true
	end
	return false
end
function Api.Unload()
	Api.Stop()
	Running = false
	for _, c in ipairs(Connections) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(Connections)
	getgenv_.SkidHub = nil
	getgenv_.AutoFishOnly = nil
end
function Api.SetDelay(s)
	Config.FarmDelay = math.clamp(tonumber(s) or 0.35, 0.1, 2)
end

getgenv_.SkidHub = Api
getgenv_.AutoFishOnly = Api -- alias cũ cho tương thích

-- ===== Skid Hub WindUI (Farm + Lock, không tab rác) =====
pcall(function()
	local Core = Api
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	pcall(function()
		if type(getgenv_.SkidHubWindUI) == "table" and getgenv_.SkidHubWindUI.Window then
			getgenv_.SkidHubWindUI.Window:Destroy()
		end
	end)
	local lib = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
	pcall(function() lib:SetParent(PlayerGui) end)
	local RarityValues = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Divine" }
	pcall(function()
		local RarityEnums = require(Data:WaitForChild("Enums"):WaitForChild("RarityEnums"))
		if type(RarityEnums.Order) == "table" and #RarityEnums.Order > 0 then
			RarityValues = RarityEnums.Order
		end
	end)
	local function syncSet(setTbl, selected, applyOne)
		local sel = {}
		if type(selected) == "table" then
			for k, v in pairs(selected) do
				if type(k) == "number" and type(v) == "string" then sel[v] = true
				elseif v == true and type(k) == "string" then sel[k] = true end
			end
		elseif type(selected) == "string" then sel[selected] = true end
		for _, r in ipairs(RarityValues) do
			local want = sel[r] == true
			if (setTbl[r] == true) ~= want then applyOne(r, want) end
		end
	end
	local win = lib:CreateWindow({
		Title = "Skid Hub | Auto Fish",
		Icon = "fish",
		Author = "skid",
		Folder = "Skid Hub",
		Size = UDim2.fromOffset(580, 460),
		MinSize = Vector2.new(560, 350),
		MaxSize = Vector2.new(850, 560),
		Transparent = true,
		Theme = "Dark",
		Resizable = true,
		SideBarWidth = 200,
		HideSearchBar = true,
		ScrollBarEnabled = false,
	})
	win:SetToggleKey(Enum.KeyCode.RightControl)
	getgenv_.SkidHubWindUI = { Window = win }
	local MainSection = win:Section({ Title = "Main", Icon = "house", Opened = true })
	local FarmTab = MainSection:Tab({ Title = "Auto Farm", Icon = "fish", Locked = false })
	local LockTab = MainSection:Tab({ Title = "Lock & Filter", Icon = "lock", Locked = false })
	FarmTab:Section({ Title = "Main Features" })
	FarmTab:Toggle({ Title = "Auto Farm", Default = Core.Config.Enabled, Flag = "AutoFarm", Callback = function(v) if v then Core.Start() else Core.Stop() end })
	FarmTab:Toggle({ Title = "Auto Skill + Low HP", Default = Core.Config.AutoSkillLowHP, Flag = "AutoSkill", Callback = function(v) Core.SetSkill(v) end })
	FarmTab:Input({ Title = "Skill Combo (Z,X,C,V)", Default = "Z,X,C,V", Placeholder = "Z,X,C,V", Flag = "SkillComboOrder", Callback = function(v) Core.SetSkillOrder(v) end })
	FarmTab:Section({ Title = "Speed Settings" })
	FarmTab:Slider({ Title = "Farm Delay (Seconds)", Value = { Min = 0.1, Max = 2, Default = Core.Config.FarmDelay or 0.35 }, Step = 0.01, Flag = "FarmDelay", Callback = function(v) Core.SetDelay(v) end })
	LockTab:Section({ Title = "Fish Rarity Filter" })
	LockTab:Dropdown({ Title = "Target Rarities", Values = RarityValues, Value = { "Legendary", "Mythical", "Divine" }, Multi = true, AllowNone = true, Flag = "FarmTargetRarities", Callback = function(v) syncSet(Core.Config.FarmRarities, v, function(r, on) Core.SetFarmRarity(r, on) end) end })
	LockTab:Toggle({ Title = "Filter Fish by Rarity", Default = Core.Config.FilterEnabled, Flag = "SkipUnselectedFish", Callback = function(v) Core.SetFilter(v) end })
	LockTab:Section({ Title = "Auto Lock Fish by Rarity" })
	LockTab:Dropdown({ Title = "Rarities to Lock", Values = RarityValues, Value = { "Legendary", "Mythical", "Divine" }, Multi = true, AllowNone = true, Flag = "LockRarities", Callback = function(v) syncSet(Core.Config.LockRarities, v, function(r, on) Core.SetLockRarity(r, on) end) end })
	LockTab:Toggle({ Title = "Auto Lock Fish", Default = Core.Config.AutoLock, Flag = "AutoLockFish", Callback = function(v) Core.SetAutoLock(v) end })
end)

return Api
