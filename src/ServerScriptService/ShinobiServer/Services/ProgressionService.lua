local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.ShinobiShared.GameConfig)

local ProgressionService = {}

local VALID_STATS = {
	Power = true,
	Chakra = true,
	Defense = true,
	Speed = true,
}

local MASTERY_CAP = 100
local MASTERY_RATE = {
	Blade = 0.008,
	Ninjutsu = 0.0125,
	Taijutsu = 0.01,
}

function ProgressionService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Remotes = context.Remotes
	self.RequestCooldowns = {}
end

function ProgressionService:CanRequest(player, action, interval)
	local now = os.clock()
	local state = self.RequestCooldowns[player]
	if not state then
		state = {}
		self.RequestCooldowns[player] = state
	end
	if now < (state[action] or 0) then
		return false
	end
	state[action] = now + interval
	return true
end

function ProgressionService:GetMasteryMultiplier(player, masteryName)
	local profile = self.Profiles:Get(player)
	local rate = MASTERY_RATE[masteryName]
	if not profile or not rate then
		return 1
	end
	local level = math.clamp(tonumber(profile.Mastery[masteryName]) or 1, 1, MASTERY_CAP)
	return 1 + (level - 1) * rate
end

function ProgressionService:AddMastery(player, masteryName, amount)
	if not MASTERY_RATE[masteryName] or type(amount) ~= "number" or amount <= 0 then
		return false
	end
	local profile = self.Profiles:Get(player)
	if not profile then
		return false
	end
	local current = math.clamp(tonumber(profile.Mastery[masteryName]) or 1, 1, MASTERY_CAP)
	if current >= MASTERY_CAP then
		return false
	end
	local liveOpsMultiplier = math.max(1, workspace:GetAttribute("LiveOpsMasteryMultiplier") or 1)
	amount = math.clamp(amount * liveOpsMultiplier, 0.01, 1)
	local nextLevel = math.min(MASTERY_CAP, math.floor((current + amount) * 100 + 0.5) / 100)
	if nextLevel <= current then
		return false
	end
	local ok = self.Profiles:Mutate(player, function(data)
		data.Mastery[masteryName] = nextLevel
	end)
	return ok == true
end

function ProgressionService:GetPower(player)
	local profile = self.Profiles:Get(player)
	if not profile then
		return 1
	end
	local stats = profile.Stats
	local rebirthMultiplier = 1 + profile.Rebirths * 0.12 + profile.Essence * 0.002
	return math.floor((profile.Level * 4 + stats.Power * 7 + stats.Chakra * 3 + stats.Defense * 2) * rebirthMultiplier)
end

function ProgressionService:AddXP(player, amount)
	local multiplier = workspace:GetAttribute("LiveOpsXPMultiplier") or 1
	amount = math.max(0, math.floor(amount * multiplier))
	self.Profiles:Mutate(player, function(profile)
		profile.XP += amount
		while profile.Level < GameConfig.MaxLevel do
			local needed = GameConfig.XPForLevel(profile.Level)
			if profile.XP < needed then
				break
			end
			profile.XP -= needed
			profile.Level += 1
			profile.StatPoints += GameConfig.StatPointsForLevel(profile.Level)
			self.Remotes.Notification:FireClient(player, {
				Kind = "LevelUp",
				Text = "Nível " .. profile.Level .. " alcançado!",
			})
		end
		if profile.Level >= GameConfig.MaxLevel then
			profile.XP = math.min(profile.XP, GameConfig.XPForLevel(GameConfig.MaxLevel))
		end
	end)
end

function ProgressionService:AddRyo(player, amount)
	local multiplier = workspace:GetAttribute("LiveOpsRyoMultiplier") or 1
	amount = math.floor(amount * multiplier)
	self.Profiles:Mutate(player, function(profile)
		profile.Ryo = math.max(0, profile.Ryo + math.floor(amount))
	end)
end

function ProgressionService:ApplyCharacterStats(player, refill)
	local profile = self.Profiles:Get(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not profile or not character or not humanoid then
		return
	end
	local health = GameConfig.BaseHealth + profile.Stats.Defense * 8 + profile.Rebirths * 15
	local healthRatio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 1
	humanoid.MaxHealth = health
	if humanoid.Health > 0 then
		humanoid.Health = refill and health or math.clamp(health * healthRatio, 1, health)
	end
	humanoid.WalkSpeed = GameConfig.BaseWalkSpeed + math.min(10, profile.Stats.Speed * 0.2)
	local oldMaxChakra = character:GetAttribute("MaxChakra") or GameConfig.BaseChakra
	local oldChakra = character:GetAttribute("Chakra") or oldMaxChakra
	local chakraRatio = oldMaxChakra > 0 and oldChakra / oldMaxChakra or 1
	local maxChakra = GameConfig.BaseChakra + profile.Stats.Chakra * 10
	character:SetAttribute("MaxChakra", maxChakra)
	character:SetAttribute("Chakra", refill and maxChakra or math.clamp(maxChakra * chakraRatio, 0, maxChakra))
end

function ProgressionService:BindPlayer(player)
	player.CharacterAdded:Connect(function(character)
		local timeout = os.clock() + 10
		while not self.Profiles:Get(player) and player.Parent and os.clock() < timeout do
			task.wait()
		end
		if not player.Parent or not character:WaitForChild("Humanoid", 10) then
			return
		end
		self:ApplyCharacterStats(player, true)
	end)
	if player.Character then
		task.spawn(function()
			local character = player.Character
			if character and character:WaitForChild("Humanoid", 10) then
				self:ApplyCharacterStats(player, true)
			end
		end)
	end
end

function ProgressionService:Start()
	self.Remotes.StatRequest.OnServerEvent:Connect(function(player, statName)
		if type(statName) ~= "string" or not VALID_STATS[statName] then
			return
		end
		local profile = self.Profiles:Get(player)
		if not profile or profile.StatPoints <= 0 or not self:CanRequest(player, "Stat", 0.12) then
			return
		end
		local changed = false
		local ok = self.Profiles:Mutate(player, function(data)
			if data.StatPoints <= 0 then return end
			data.StatPoints -= 1
			data.Stats[statName] += 1
			changed = true
		end)
		if ok and changed then
			self:ApplyCharacterStats(player, false)
		end
	end)

	self.Remotes.RebirthRequest.OnServerEvent:Connect(function(player)
		local profile = self.Profiles:Get(player)
		if not profile or profile.Level < GameConfig.RebirthLevel or not self:CanRequest(player, "Rebirth", 1) then
			return
		end
		local rebirthed = false
		local reward = 0
		local rebirths = profile.Rebirths
		local ok = self.Profiles:Mutate(player, function(data)
			if data.Level < GameConfig.RebirthLevel then return end
			reward = 10 + math.floor(data.Rebirths * 2.5)
			data.Rebirths += 1
			data.Essence += reward
			data.Level = 1
			data.XP = 0
			data.StatPoints = 0
			data.Stats = { Power = 1, Chakra = 1, Defense = 1, Speed = 1 }
			rebirths = data.Rebirths
			rebirthed = true
		end)
		if not ok or not rebirthed then return end
		self.Remotes.Notification:FireClient(player, {
			Kind = "Rebirth",
			Text = string.format("Rebirth %d! +%d Essência", rebirths, reward),
		})
		local character = player.Character
		if character and character:FindFirstChildOfClass("Humanoid") then
			character:FindFirstChildOfClass("Humanoid").Health = 0
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		self:BindPlayer(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.RequestCooldowns[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		self:BindPlayer(player)
	end
end

return ProgressionService
