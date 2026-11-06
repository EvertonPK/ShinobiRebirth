local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClanConfig = require(ReplicatedStorage.ShinobiShared.ClanConfig)

local ClanService = {
	Scores = {},
}

local function seasonId()
	local now = os.date("!*t")
	local dayIndex = math.floor(os.time() / 86400)
	local season = math.floor(dayIndex / ClanConfig.SeasonDays)
	return string.format("S%d_%d", now.year, season)
end

function ClanService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Remotes = context.Remotes
	self.Store = DataStoreService:GetOrderedDataStore("ShinobiRebirth_ClanWar_" .. seasonId())
	self.LastSnapshots = {}
	for id in ClanConfig.Clans do
		self.Scores[id] = 0
	end
end

function ClanService:Snapshot(player)
	local profile = self.Profiles:Get(player)
	return {
		Season = seasonId(),
		Selected = profile and profile.Clan or "",
		Contribution = profile and profile.ClanContribution or 0,
		Scores = table.clone(self.Scores),
		Clans = ClanConfig.Clans,
	}
end

function ClanService:Push(player, force)
	local profile = self.Profiles:Get(player)
	local pieces = {
		profile and profile.Clan or "",
		tostring(profile and profile.ClanContribution or 0),
	}
	for id in ClanConfig.Clans do
		table.insert(pieces, id .. ":" .. tostring(self.Scores[id] or 0))
	end
	local signature = table.concat(pieces, "|")
	if not force and self.LastSnapshots[player] == signature then
		return
	end
	self.LastSnapshots[player] = signature
	self.Remotes.ClanState:FireClient(player, self:Snapshot(player))
end

function ClanService:AddContribution(player, amount)
	local profile = self.Profiles:Get(player)
	if not profile or profile.Clan == "" or not ClanConfig.Clans[profile.Clan] then
		return
	end
	local multiplier = workspace:GetAttribute("LiveOpsClanMultiplier") or 1
	amount = math.max(0, math.floor(amount * multiplier))
	if amount <= 0 then
		return
	end
	local clanId = profile.Clan
	self.Profiles:Mutate(player, function(data)
		data.ClanContribution += amount
	end)
	self.Scores[clanId] = (self.Scores[clanId] or 0) + amount
	if not RunService:IsStudio() then
		task.spawn(function()
			local ok, score = pcall(function()
				return self.Store:IncrementAsync(clanId, amount)
			end)
			if ok then
				self.Scores[clanId] = score
			end
		end)
	end
	self:Push(player)
end

function ClanService:RefreshScores()
	if RunService:IsStudio() then
		return
	end
	local ok, pages = pcall(function()
		return self.Store:GetSortedAsync(false, 10)
	end)
	if ok then
		for _, entry in pages:GetCurrentPage() do
			if ClanConfig.Clans[entry.key] then
				self.Scores[entry.key] = entry.value
			end
		end
	end
end

function ClanService:Start()
	self.Remotes.ClanRequest.OnServerEvent:Connect(function(player, action, clanId)
		if action == "Get" then
			self:Push(player, true)
			return
		end
		if action ~= "Choose" or type(clanId) ~= "string" or not ClanConfig.Clans[clanId] then
			return
		end
		local profile = self.Profiles:Get(player)
		if not profile or profile.Clan ~= "" then
			return
		end
		self.Profiles:Mutate(player, function(data)
			data.Clan = clanId
		end)
		self.Remotes.Notification:FireClient(player, {
			Kind = "Clan",
			Text = "Você jurou lealdade ao clã " .. ClanConfig.Clans[clanId].Name,
		})
		self:Push(player)
	end)

	self.Profiles.Changed.Event:Connect(function(player)
		self:Push(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		task.delay(3, function()
			if player.Parent then
				self:Push(player)
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.LastSnapshots[player] = nil
	end)
	task.spawn(function()
		while task.wait(60) do
			self:RefreshScores()
			for _, player in Players:GetPlayers() do
				self:Push(player)
			end
		end
	end)
end

return ClanService
