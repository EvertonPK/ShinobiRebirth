local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MetaConfig = require(ReplicatedStorage.ShinobiShared.MetaConfig)

local LeaderboardService = {}

local function bossKills(profile)
	local total = 0
	for _, count in profile.BossKills do
		total += type(count) == "number" and count or 0
	end
	return total
end

function LeaderboardService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Remotes = context.Remotes
	self.Stores = {}
	self.Cache = {}
	self.NameCache = {}
	self.RequestLimits = {}
	self.Latest = {}
	for _, board in MetaConfig.Leaderboards do
		self.Stores[board.Id] = DataStoreService:GetOrderedDataStore("ShinobiRebirth_Board_v1_" .. board.Id)
	end
end

function LeaderboardService:Value(profile, id)
	if id == "BossKillsTotal" then
		return bossKills(profile)
	end
	return math.max(0, math.floor(tonumber(profile[id]) or 0))
end

function LeaderboardService:UpdatePlayer(player, providedProfile)
	local profile = providedProfile or self.Profiles:Get(player) or self.Latest[player]
	if not profile or RunService:IsStudio() then
		return
	end
	for _, board in MetaConfig.Leaderboards do
		local value = self:Value(profile, board.Id)
		pcall(function()
			self.Stores[board.Id]:SetAsync(tostring(player.UserId), value)
		end)
	end
end

function LeaderboardService:ResolveName(userId)
	if self.NameCache[userId] then
		return self.NameCache[userId]
	end
	local name = "Jogador " .. userId
	local ok, result = pcall(Players.GetNameFromUserIdAsync, Players, userId)
	if ok and type(result) == "string" then
		name = result
	end
	self.NameCache[userId] = name
	return name
end

function LeaderboardService:Refresh(id)
	local store = self.Stores[id]
	if not store or RunService:IsStudio() then
		self.Cache[id] = self.Cache[id] or {}
		return
	end
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, 25)
	end)
	if not ok then
		return
	end
	local entries = {}
	for rank, entry in pages:GetCurrentPage() do
		local userId = tonumber(entry.key)
		if userId then
			table.insert(entries, {
				Rank = rank,
				UserId = userId,
				Name = self:ResolveName(userId),
				Value = entry.value,
			})
		end
	end
	self.Cache[id] = entries
end

function LeaderboardService:Push(player, id)
	if type(id) ~= "string" or not self.Stores[id] then
		return
	end
	local now = os.clock()
	if now < (self.RequestLimits[player] or 0) then
		return
	end
	self.RequestLimits[player] = now + 1
	self.Remotes.LeaderboardState:FireClient(player, {
		Id = id,
		Entries = self.Cache[id] or {},
	})
end

function LeaderboardService:Start()
	self.Profiles.Changed.Event:Connect(function(player, snapshot)
		self.Latest[player] = snapshot
	end)
	self.Remotes.LeaderboardRequest.OnServerEvent:Connect(function(player, id)
		self:Push(player, id)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.RequestLimits[player] = nil
		local profile = self.Profiles:Get(player) or self.Latest[player]
		self.Latest[player] = nil
		task.spawn(function()
			self:UpdatePlayer(player, profile)
		end)
	end)
	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				self:UpdatePlayer(player)
			end
			for _, board in MetaConfig.Leaderboards do
				self:Refresh(board.Id)
			end
			task.wait(180)
		end
	end)
end

return LeaderboardService
