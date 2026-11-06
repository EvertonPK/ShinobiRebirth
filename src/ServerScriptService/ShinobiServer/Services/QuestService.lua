local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JourneyConfig = require(ReplicatedStorage.ShinobiShared.JourneyConfig)

local QuestService = {}

local DAILY_POOL = {
	{ Id = "Damage", Name = "Punhos em movimento", Goal = 2500, RewardXP = 500, RewardRyo = 650 },
	{ Id = "BossDamage", Name = "Desafie o impossível", Goal = 1200, RewardXP = 700, RewardRyo = 900 },
	{ Id = "BossKill", Name = "Caçador de lendas", Goal = 1, RewardXP = 900, RewardRyo = 1200 },
	{ Id = "Training", Name = "Disciplina shinobi", Goal = 30, RewardXP = 400, RewardRyo = 500 },
	{ Id = "EnemyKill", Name = "Patrulha da fronteira", Goal = 12, RewardXP = 650, RewardRyo = 800 },
}

local function dayStamp()
	return os.date("!%Y-%j")
end

function QuestService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Progression = context.Services.ProgressionService
	self.Remotes = context.Remotes
	self.LastRequest = {}
end

function QuestService:EnsureDaily(player)
	local profile = self.Profiles:Get(player)
	if not profile then
		return
	end
	local stamp = dayStamp()
	if profile.Quests.DailyStamp == stamp then
		return
	end
	local journeyReward, journeyName, journeyCycle
	self.Profiles:Mutate(player, function(data)
		data.Quests.DailyStamp = stamp
		data.Quests.Daily = {}
		local seed = tonumber(stamp:match("%-(%d+)$")) or 1
		for offset = 0, 2 do
			local definition = DAILY_POOL[(seed + offset * 3) % #DAILY_POOL + 1]
			table.insert(data.Quests.Daily, {
				Id = definition.Id,
				Name = definition.Name,
				Goal = definition.Goal,
				Progress = 0,
				RewardXP = definition.RewardXP,
				RewardRyo = definition.RewardRyo,
				Claimed = false,
			})
		end
	end)
end

function QuestService:Record(player, kind, amount)
	local profile = self.Profiles:Get(player)
	if not profile then
		return
	end
	self:EnsureDaily(player)
	self.Profiles:Mutate(player, function(data)
		for _, quest in data.Quests.Daily do
			if quest.Id == kind and not quest.Claimed then
				quest.Progress = math.min(quest.Goal, quest.Progress + (amount or 1))
			end
		end
		data.Quests.Lifetime[kind] = (data.Quests.Lifetime[kind] or 0) + (amount or 1)
		data.Journey = data.Journey or { Stage = 1, Cycle = 1, Progress = 0 }
		local journey = data.Journey
		local step = JourneyConfig.GetStep(journey.Stage)
		if step.Counter == kind then
			journey.Progress = math.min(step.Goal, (journey.Progress or 0) + (amount or 1))
			if journey.Progress >= step.Goal then
				local scale = JourneyConfig.RewardScale(journey.Cycle)
				journeyReward = {}
				for currency, value in step.Reward do journeyReward[currency] = math.floor(value * scale) end
				journeyName, journeyCycle = step.Name, journey.Cycle
				journey.Stage += 1
				journey.Progress = 0
				if journey.Stage > #JourneyConfig.Steps then
					journey.Stage = 1
					journey.Cycle += 1
				end
			end
		end
	end)
	if journeyReward then
		if journeyReward.XP then self.Progression:AddXP(player, journeyReward.XP) end
		if journeyReward.Ryo then self.Progression:AddRyo(player, journeyReward.Ryo) end
		self.Profiles:Mutate(player, function(data)
			for _, currency in { "Gems", "EventTickets", "StyleTokens", "Essence" } do
				data[currency] += journeyReward[currency] or 0
			end
		end)
		self.Remotes.Notification:FireClient(player, { Kind = "Journey", Text = string.format("Objetivo concluído: %s • Ciclo %d", journeyName, journeyCycle) })
	end
end

function QuestService:Start()
	self.Profiles.Changed.Event:Connect(function(player)
		self:EnsureDaily(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		task.delay(2, function()
			if player.Parent then
				self:EnsureDaily(player)
			end
		end)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:EnsureDaily(player)
		end)
	end
	self.Remotes.QuestRequest.OnServerEvent:Connect(function(player, action, questIndex)
		if action ~= "Claim" or type(questIndex) ~= "number" then
			return
		end
		local now = os.clock()
		if now < (self.LastRequest[player] or 0) then
			return
		end
		self.LastRequest[player] = now + 0.25
		questIndex = math.floor(questIndex)
		local profile = self.Profiles:Get(player)
		local quest = profile and profile.Quests.Daily[questIndex]
		if not quest or quest.Claimed or quest.Progress < quest.Goal then
			return
		end
		local xp, ryo = quest.RewardXP, quest.RewardRyo
		local claimed = false
		self.Profiles:Mutate(player, function(data)
			local current = data.Quests.Daily[questIndex]
			if current and not current.Claimed and current.Progress >= current.Goal then
				current.Claimed = true
				claimed = true
			end
		end)
		if not claimed then
			return
		end
		self.Progression:AddXP(player, xp)
		self.Progression:AddRyo(player, ryo)
		self:Record(player, "DailyClaim", 1)
		self.Remotes.Notification:FireClient(player, {
			Kind = "Quest",
			Text = string.format("Missão concluída: +%d XP, +%d Ryo", xp, ryo),
		})
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.LastRequest[player] = nil
	end)
end

return QuestService
