local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameConfig = require(game:GetService("ReplicatedStorage").ShinobiShared.GameConfig)
local Util = require(game:GetService("ReplicatedStorage").ShinobiShared.Util)

local ProfileService = {
	Profiles = {},
	Changed = Instance.new("BindableEvent"),
}

local SESSION_LOCK_TTL = 180
local LOAD_ATTEMPTS = 3
local SAVE_ATTEMPTS = 3

local function reconcileStrict(target, template)
	for key, default in template do
		local current = target[key]
		if type(default) == "table" then
			if type(current) ~= "table" then
				target[key] = Util.DeepCopy(default)
			else
				reconcileStrict(current, default)
			end
		elseif type(current) ~= type(default) then
			target[key] = default
		elseif type(default) == "number" and (current ~= current or current == math.huge or current == -math.huge) then
			target[key] = default
		end
	end
	return target
end

local TEMPLATE = {
	Version = GameConfig.DataVersion,
	Level = 1,
	XP = 0,
	Ryo = 250,
	Gems = 0,
	EventTickets = 0,
	StyleTokens = 0,
	Essence = 0,
	Rebirths = 0,
	StatPoints = 0,
	Stats = { Power = 1, Chakra = 1, Defense = 1, Speed = 1 },
	Inventory = {},
	Materials = {},
	Equipped = { Cosmetic = "", WeaponSkin = "", Aura = "", Eyes = "" },
	Mastery = { Blade = 1, Ninjutsu = 1, Taijutsu = 1 },
	Clan = "",
	ClanContribution = 0,
	BossKills = {},
	Pity = {},
	CratePity = {},
	ProcessedReceipts = {},
	StorePurchases = {},
	Achievements = {},
	Milestones = {},
	RedeemedCodes = {},
	LiveOps = {
		Login = { LastClaimDay = -1, Streak = 0, GraceTokens = 1, LastGraceDay = -1 },
		Weekly = { Id = -1, Baseline = {}, Claimed = {} },
		Season = { Id = -1, Points = 0, Claimed = {} },
	},
	Quests = { DailyStamp = "", Daily = {}, Lifetime = {} },
	Settings = { Music = true, DamageNumbers = true, ScreenShake = true },
	LastSeen = 0,
	TotalPlaySeconds = 0,
}

local function publicSnapshot(profile)
	return {
		Level = profile.Level,
		XP = profile.XP,
		XPNext = GameConfig.XPForLevel(profile.Level),
		Rank = GameConfig.GetRank(profile.Level).Name,
		Ryo = profile.Ryo,
		Gems = profile.Gems,
		EventTickets = profile.EventTickets,
		StyleTokens = profile.StyleTokens,
		Essence = profile.Essence,
		Rebirths = profile.Rebirths,
		WorldTier = GameConfig.GetWorldTier(profile.Rebirths),
		StatPoints = profile.StatPoints,
		Stats = Util.DeepCopy(profile.Stats),
		Inventory = Util.DeepCopy(profile.Inventory),
		Materials = Util.DeepCopy(profile.Materials),
		Equipped = Util.DeepCopy(profile.Equipped),
		Mastery = Util.DeepCopy(profile.Mastery),
		Clan = profile.Clan,
		ClanContribution = profile.ClanContribution,
		BossKills = Util.DeepCopy(profile.BossKills),
		CratePity = Util.DeepCopy(profile.CratePity),
		Quests = Util.DeepCopy(profile.Quests),
		LiveOps = Util.DeepCopy(profile.LiveOps),
		Achievements = Util.DeepCopy(profile.Achievements),
	Milestones = Util.DeepCopy(profile.Milestones),
		RedeemedCodes = Util.DeepCopy(profile.RedeemedCodes),
	}
end

function ProfileService:Init(context)
	self.Remotes = context.Remotes
	self.Store = DataStoreService:GetDataStore(GameConfig.ProfileStore)
	self.UseDataStore = not RunService:IsStudio() or game:GetAttribute("UseStudioDataStore") == true
	self.SessionStarted = {}
	self.Loading = {}
	self.Saving = {}
	self.Leaderstats = {}
end

function ProfileService:Get(player)
	return self.Profiles[player]
end

function ProfileService:GetSnapshot(player)
	local profile = self:Get(player)
	return profile and publicSnapshot(profile) or nil
end

function ProfileService:Push(player)
	local snapshot = self:GetSnapshot(player)
	if snapshot then
		local leaderstats = self.Leaderstats[player]
		if leaderstats and leaderstats.Parent then
			leaderstats.Level.Value = snapshot.Level
			leaderstats.Rebirths.Value = snapshot.Rebirths
		end
		self.Remotes.ProfileUpdate:FireClient(player, snapshot)
		self.Changed:Fire(player, snapshot)
	end
end

function ProfileService:Mutate(player, callback)
	local profile = self:Get(player)
	if not profile then
		return false
	end
	local ok, result = pcall(callback, profile)
	if not ok then
		warn("[ProfileService] Mutation failed: " .. tostring(result))
		return false
	end
	self:Push(player)
	return true, result
end

function ProfileService:Load(player)
	if self.Profiles[player] or self.Loading[player] then
		return
	end
	self.Loading[player] = true
	local key = "Player_" .. player.UserId
	local loaded
	if not self.UseDataStore then
		loaded = Util.DeepCopy(TEMPLATE)
	else
		local lastError
		for attempt = 1, LOAD_ATTEMPTS do
			local blocked = false
			local ok, result = pcall(function()
				return self.Store:UpdateAsync(key, function(data)
					data = type(data) == "table" and data or Util.DeepCopy(TEMPLATE)
					local session = data._Session
					if type(session) == "table"
						and session.JobId ~= game.JobId
						and os.time() - (tonumber(session.UpdatedAt) or os.time()) < SESSION_LOCK_TTL
					then
						blocked = true
						return nil
					end
					data = reconcileStrict(data, TEMPLATE)
					data._Session = { JobId = game.JobId, UpdatedAt = os.time() }
					return data
				end)
			end)
			if ok and result and not blocked then
				loaded = result
				break
			end
			lastError = blocked and "profile is active on another server" or tostring(result)
			if attempt < LOAD_ATTEMPTS and player.Parent then
				task.wait(3 * attempt)
			end
		end
		if not loaded then
			self.Loading[player] = nil
			warn("[ProfileService] Load failed for " .. player.Name .. ": " .. tostring(lastError))
			if player.Parent then
				player:Kick("Seus dados ainda estão ativos em outro servidor. Tente novamente em alguns instantes.")
			end
			return
		end
	end
	loaded._Session = nil
	loaded.Level = math.clamp(math.floor(loaded.Level), 1, GameConfig.MaxLevel)
	loaded.XP = math.max(0, math.floor(loaded.XP))
	for _, currency in { "Ryo", "Gems", "EventTickets", "StyleTokens", "Essence" } do
		loaded[currency] = math.max(0, math.floor(loaded[currency]))
	end
	loaded.Rebirths = math.max(0, math.floor(loaded.Rebirths))
	loaded.StatPoints = math.max(0, math.floor(loaded.StatPoints))
	for _, statName in { "Power", "Chakra", "Defense", "Speed" } do
		loaded.Stats[statName] = math.clamp(math.floor(loaded.Stats[statName]), 1, 10000)
	end
	if not player.Parent then
		self.Loading[player] = nil
		if self.UseDataStore then
			pcall(function()
				self.Store:UpdateAsync(key, function(data)
					if type(data) == "table" and type(data._Session) == "table" and data._Session.JobId == game.JobId then
						data._Session = nil
						return data
					end
					return nil
				end)
			end)
		end
		return
	end
	loaded.LastSeen = os.time()
	self.Profiles[player] = loaded
	self.SessionStarted[player] = os.clock()
	self.Loading[player] = nil
	self:CreateLeaderstats(player)
	self:Push(player)
end

function ProfileService:CreateLeaderstats(player)
	local profile = self:Get(player)
	local existing = player:FindFirstChild("leaderstats")
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player
	for _, name in { "Level", "Rebirths" } do
		local value = Instance.new("IntValue")
		value.Name = name
		value.Value = profile[name]
		value.Parent = folder
	end
	self.Leaderstats[player] = folder
end

function ProfileService:Save(player, releaseSession)
	if self.Saving[player] then
		if not releaseSession then
			return false
		end
		local timeout = os.clock() + 10
		while self.Saving[player] and os.clock() < timeout do
			task.wait(0.1)
		end
		if self.Saving[player] then
			return false
		end
	end
	local profile = self:Get(player)
	if not profile then
		return true
	end
	self.Saving[player] = true
	local started = self.SessionStarted[player]
	if started then
		profile.TotalPlaySeconds += math.max(0, math.floor(os.clock() - started))
		self.SessionStarted[player] = os.clock()
	end
	profile.LastSeen = os.time()
	if not self.UseDataStore then
		self.Saving[player] = nil
		return true
	end
	local payload = Util.DeepCopy(profile)
	local lostSession = false
	local ok, err = false, nil
	for attempt = 1, SAVE_ATTEMPTS do
		ok, err = pcall(function()
			self.Store:UpdateAsync("Player_" .. player.UserId, function(current)
				local session = type(current) == "table" and current._Session or nil
				if type(session) == "table" and session.JobId ~= game.JobId then
					lostSession = true
					return nil
				end
				if releaseSession then
					payload._Session = nil
				else
					payload._Session = { JobId = game.JobId, UpdatedAt = os.time() }
				end
				return payload
			end)
		end)
		if ok or lostSession then
			break
		end
		if attempt < SAVE_ATTEMPTS then
			task.wait(attempt)
		end
	end
	self.Saving[player] = nil
	if not ok then
		warn("[ProfileService] Save failed for " .. player.Name .. ": " .. tostring(err))
	elseif lostSession then
		warn("[ProfileService] Refused to overwrite a newer session for " .. player.Name)
		if player.Parent then
			player:Kick("Sua sessão de dados foi aberta em outro servidor.")
		end
	end
	return ok and not lostSession
end

function ProfileService:Start()
	self.Remotes.GetInitialState.OnServerInvoke = function(player)
		local timeout = os.clock() + 10
		while not self.Profiles[player] and player.Parent and os.clock() < timeout do
			task.wait()
		end
		return self:GetSnapshot(player)
	end

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			self:Load(player)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:Save(player, true)
		self.Profiles[player] = nil
		self.SessionStarted[player] = nil
		self.Loading[player] = nil
		self.Leaderstats[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:Load(player)
		end)
	end

	task.spawn(function()
		while task.wait(GameConfig.AutoSaveSeconds) do
			for player in self.Profiles do
				task.spawn(function()
					self:Save(player)
				end)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for player in self.Profiles do
			pending += 1
			task.spawn(function()
				self:Save(player, true)
				pending -= 1
			end)
		end
		local timeout = os.clock() + 25
		while pending > 0 and os.clock() < timeout do
			task.wait(0.1)
		end
	end)
end

return ProfileService
