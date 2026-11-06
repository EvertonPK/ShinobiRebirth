local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaConfig = require(ReplicatedStorage.ShinobiShared.MetaConfig)

local AchievementService = {}

local function countTruthy(values)
	local count = 0
	for _, value in values do
		if value then
			count += 1
		end
	end
	return count
end

local function sumValues(values)
	local total = 0
	for _, value in values do
		if type(value) == "number" then
			total += value
		end
	end
	return total
end

local function metric(profile, name)
	if name == "BossKillsTotal" then
		return sumValues(profile.BossKills)
	elseif name == "InventoryCount" then
		return countTruthy(profile.Inventory)
	end
	return type(profile[name]) == "number" and profile[name] or 0
end

function AchievementService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Remotes = context.Remotes
	self.Checking = {}
end

function AchievementService:Check(player)
	if self.Checking[player] then
		return
	end
	local profile = self.Profiles:Get(player)
	if not profile then
		return
	end
	local unlocked = {}
	for id, definition in MetaConfig.Achievements do
		if not profile.Achievements[id] and metric(profile, definition.Metric) >= definition.Goal then
			table.insert(unlocked, id)
		end
	end
	if #unlocked == 0 then
		return
	end
	self.Checking[player] = true
	self.Profiles:Mutate(player, function(data)
		for _, id in unlocked do
			if not data.Achievements[id] then
				local definition = MetaConfig.Achievements[id]
				data.Achievements[id] = os.time()
				for currency, amount in definition.Reward do
					if type(data[currency]) == "number" then
						data[currency] += math.floor(amount)
					end
				end
			end
		end
	end)
	self.Checking[player] = nil
	for _, id in unlocked do
		local definition = MetaConfig.Achievements[id]
		self.Remotes.AchievementUnlocked:FireClient(player, {
			Id = id,
			Name = definition.Name,
			Description = definition.Description,
			Reward = table.clone(definition.Reward),
		})
	end
end

function AchievementService:Start()
	self.Profiles.Changed.Event:Connect(function(player)
		self:Check(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		task.delay(2, function()
			if player.Parent then
				self:Check(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:Check(player)
		end)
	end
end

return AchievementService
