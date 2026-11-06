local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LiveOpsConfig = require(ReplicatedStorage.ShinobiShared.LiveOpsConfig)
local Util = require(ReplicatedStorage.ShinobiShared.Util)

local LiveOpsService = {}

local function dayIndex(now)
	return math.floor((now or os.time()) / 86400)
end

local function weekIndex(now)
	return math.floor(dayIndex(now) / 7)
end

local function seasonIndex(now)
	return math.floor(dayIndex(now) / LiveOpsConfig.SeasonLengthDays)
end

local function defaultState()
	return {
		Login = { LastClaimDay = -1, Streak = 0, GraceTokens = 1, LastGraceDay = -1 },
		Weekly = { Id = -1, Baseline = {}, Claimed = {} },
		Season = { Id = -1, Points = 0, Claimed = {} },
	}
end

local function counter(profile, name)
	return (profile.Quests and profile.Quests.Lifetime and profile.Quests.Lifetime[name]) or 0
end

local function rewardText(reward)
	local pieces = {}
	if reward.Ryo then table.insert(pieces, reward.Ryo .. " Ryo") end
	if reward.XP then table.insert(pieces, reward.XP .. " XP") end
	if reward.Gems then table.insert(pieces, reward.Gems .. " Gemas") end
	if reward.EventTickets then table.insert(pieces, reward.EventTickets .. " Tickets") end
	if reward.StyleTokens then table.insert(pieces, reward.StyleTokens .. " Tokens de Estilo") end
	if reward.Essence then table.insert(pieces, reward.Essence .. " Essência") end
	if reward.SeasonPoints then table.insert(pieces, reward.SeasonPoints .. " pontos de temporada") end
	return table.concat(pieces, " • ")
end

function LiveOpsService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Progression = context.Services.ProgressionService
	self.Remotes = context.Remotes
	self.LastRequest = {}
end

function LiveOpsService:GetCalendar(now)
	now = now or os.time()
	local day = dayIndex(now)
	local flashSlot = math.floor(now / 7200)
	return {
		Day = day,
		Week = weekIndex(now),
		Season = seasonIndex(now),
		Daily = LiveOpsConfig.DailyEvents[day % #LiveOpsConfig.DailyEvents + 1],
		Flash = LiveOpsConfig.FlashEvents[flashSlot % #LiveOpsConfig.FlashEvents + 1],
		NextDailyAt = (day + 1) * 86400,
		NextFlashAt = (flashSlot + 1) * 7200,
	}
end

function LiveOpsService:ApplyWorldModifiers()
	local calendar = self:GetCalendar()
	local daily = calendar.Daily.Modifiers
	local flash = calendar.Flash.Modifiers
	workspace:SetAttribute("LiveOpsXPMultiplier", (daily.XP or 1) * (flash.XP or 1))
	workspace:SetAttribute("LiveOpsRyoMultiplier", (daily.Ryo or 1) * (flash.Ryo or 1))
	workspace:SetAttribute("LiveOpsLootLuck", (daily.LootLuck or 1) * (flash.LootLuck or 1))
	workspace:SetAttribute("LiveOpsBossRewardMultiplier", daily.BossReward or 1)
	workspace:SetAttribute("LiveOpsMasteryMultiplier", (daily.Mastery or 1) * (flash.Mastery or 1))
	workspace:SetAttribute("LiveOpsDailyEvent", calendar.Daily.Id)
	workspace:SetAttribute("LiveOpsFlashEvent", calendar.Flash.Id)
end

function LiveOpsService:EnsureState(player)
	local profile = self.Profiles:Get(player)
	if not profile then return end
	local calendar = self:GetCalendar()
	local live = profile.LiveOps
	local needsUpdate = type(live) ~= "table"
		or not live.Login
		or not live.Weekly or live.Weekly.Id ~= calendar.Week
		or not live.Season or live.Season.Id ~= calendar.Season
	if not needsUpdate then return end
	self.Profiles:Mutate(player, function(data)
		data.LiveOps = type(data.LiveOps) == "table" and data.LiveOps or defaultState()
		local state = data.LiveOps
		state.Login = state.Login or defaultState().Login
		if not state.Weekly or state.Weekly.Id ~= calendar.Week then
			local baseline = {}
			for _, objective in LiveOpsConfig.WeeklyObjectives do
				baseline[objective.Counter] = counter(data, objective.Counter)
			end
			state.Weekly = { Id = calendar.Week, Baseline = baseline, Claimed = {} }
		end
		if not state.Season or state.Season.Id ~= calendar.Season then
			state.Season = { Id = calendar.Season, Points = 0, Claimed = {} }
		end
	end)
end

function LiveOpsService:GetSnapshot(player)
	local profile = self.Profiles:Get(player)
	if not profile or not profile.LiveOps then return nil end
	local calendar = self:GetCalendar()
	local state = profile.LiveOps
	state.Weekly.Baseline = state.Weekly.Baseline or {}
	state.Weekly.Claimed = state.Weekly.Claimed or {}
	state.Season.Claimed = state.Season.Claimed or {}
	local weekly = {}
	for index, objective in LiveOpsConfig.WeeklyObjectives do
		local baseline = state.Weekly.Baseline[objective.Counter] or 0
		local reward = {
			Ryo = objective.Ryo,
			XP = objective.XP,
			Gems = objective.Gems,
			EventTickets = objective.EventTickets,
			StyleTokens = objective.StyleTokens,
			Essence = objective.Essence,
			SeasonPoints = objective.SeasonPoints,
		}
		table.insert(weekly, {
			Index = index, Id = objective.Id, Name = objective.Name, Goal = objective.Goal,
			Progress = math.clamp(counter(profile, objective.Counter) - baseline, 0, objective.Goal),
			Claimed = state.Weekly.Claimed[objective.Id] == true,
			Reward = reward,
			RewardText = rewardText(reward),
		})
	end
	local seasonLevel = math.clamp(math.floor(state.Season.Points / LiveOpsConfig.SeasonPointsPerLevel), 0, LiveOpsConfig.SeasonMaxLevel)
	local nextClaimableLevel
	for level = 1, seasonLevel do
		if state.Season.Claimed[tostring(level)] ~= true then
			nextClaimableLevel = level
			break
		end
	end
	local nextSeasonReward = nextClaimableLevel and LiveOpsConfig.GetSeasonReward(nextClaimableLevel) or nil
	return {
		Calendar = calendar,
		Login = {
			CanClaim = state.Login.LastClaimDay < calendar.Day,
			Streak = state.Login.Streak,
			GraceTokens = state.Login.GraceTokens,
			NextReward = LiveOpsConfig.LoginRewards[state.Login.Streak % #LiveOpsConfig.LoginRewards + 1],
		},
		Weekly = weekly,
		Season = {
			Id = state.Season.Id, Points = state.Season.Points,
			Level = seasonLevel,
			MaxLevel = LiveOpsConfig.SeasonMaxLevel,
			PointsPerLevel = LiveOpsConfig.SeasonPointsPerLevel,
			Claimed = Util.DeepCopy(state.Season.Claimed),
			NextClaimableLevel = nextClaimableLevel,
			NextReward = nextSeasonReward and Util.DeepCopy(nextSeasonReward) or nil,
			NextRewardText = nextSeasonReward and rewardText(nextSeasonReward) or nil,
		},
	}
end

function LiveOpsService:Push(player)
	local snapshot = self:GetSnapshot(player)
	if snapshot then self.Remotes.LiveOpsState:FireClient(player, snapshot) end
end

function LiveOpsService:Award(player, reward)
	if reward.XP then self.Progression:AddXP(player, reward.XP) end
	if reward.Ryo then self.Progression:AddRyo(player, reward.Ryo) end
	if reward.Gems or reward.EventTickets or reward.StyleTokens or reward.Essence then
		self.Profiles:Mutate(player, function(data)
			for _, currency in { "Gems", "EventTickets", "StyleTokens", "Essence" } do
				local amount = reward[currency]
				if type(amount) == "number" and amount > 0 then
					data[currency] += math.floor(amount)
				end
			end
		end)
	end
end

function LiveOpsService:ClaimLogin(player)
	self:EnsureState(player)
	local profile = self.Profiles:Get(player)
	if not profile then return end
	local today = dayIndex()
	local login = profile.LiveOps.Login
	if login.LastClaimDay >= today then return end
	local missed = today - login.LastClaimDay
	local usedGrace = login.LastClaimDay >= 0 and missed == 2 and login.GraceTokens > 0
	local newStreak = (login.LastClaimDay < 0 or (missed > 1 and not usedGrace)) and 1 or login.Streak + 1
	local reward = LiveOpsConfig.LoginRewards[(newStreak - 1) % #LiveOpsConfig.LoginRewards + 1]
	local updated = self.Profiles:Mutate(player, function(data)
		local state = data.LiveOps
		state.Login.LastClaimDay = today
		state.Login.Streak = newStreak
		if usedGrace then state.Login.GraceTokens -= 1 end
		if today - (state.Login.LastGraceDay or -1) >= 14 then
			state.Login.GraceTokens = math.min(2, state.Login.GraceTokens + 1)
			state.Login.LastGraceDay = today
		end
		state.Season.Points += reward.SeasonPoints or 0
	end)
	if not updated then return end
	self:Award(player, reward)
	self.Remotes.Notification:FireClient(player, { Kind = "DailyReward", Text = "Recompensa diária: " .. rewardText(reward) })
end

function LiveOpsService:ClaimWeekly(player, index)
	self:EnsureState(player)
	index = math.floor(index)
	local objective = LiveOpsConfig.WeeklyObjectives[index]
	local profile = self.Profiles:Get(player)
	if not objective or not profile then return end
	local weekly = profile.LiveOps.Weekly
	local progress = counter(profile, objective.Counter) - (weekly.Baseline[objective.Counter] or 0)
	if weekly.Claimed[objective.Id] or progress < objective.Goal then return end
	local updated = self.Profiles:Mutate(player, function(data)
		data.LiveOps.Weekly.Claimed[objective.Id] = true
		data.LiveOps.Season.Points += objective.SeasonPoints or 0
	end)
	if not updated then return end
	self:Award(player, objective)
	self.Remotes.Notification:FireClient(player, { Kind = "WeeklyReward", Text = "Objetivo semanal: " .. rewardText(objective) })
end

function LiveOpsService:ClaimSeason(player, level)
	self:EnsureState(player)
	level = math.floor(level)
	if level < 1 or level > LiveOpsConfig.SeasonMaxLevel then return end
	local profile = self.Profiles:Get(player)
	if not profile then return end
	local season = profile.LiveOps.Season
	if season.Points < level * LiveOpsConfig.SeasonPointsPerLevel or season.Claimed[tostring(level)] then return end
	local reward = LiveOpsConfig.GetSeasonReward(level)
	local updated = self.Profiles:Mutate(player, function(data)
		data.LiveOps.Season.Claimed[tostring(level)] = true
	end)
	if not updated then return end
	self:Award(player, reward)
	self.Remotes.Notification:FireClient(player, { Kind = "SeasonReward", Text = "Trilha gratuita nível " .. level .. ": " .. rewardText(reward) })
end

function LiveOpsService:Start()
	self:ApplyWorldModifiers()
	self.Remotes.LiveOpsRequest.OnServerEvent:Connect(function(player, action, argument)
		local now = os.clock()
		if now - (self.LastRequest[player] or 0) < 0.2 then return end
		self.LastRequest[player] = now
		if action == "Get" then self:EnsureState(player); self:Push(player)
		elseif action == "ClaimLogin" then self:ClaimLogin(player); self:Push(player)
		elseif action == "ClaimWeekly" and type(argument) == "number" then self:ClaimWeekly(player, argument); self:Push(player)
		elseif action == "ClaimSeason" and type(argument) == "number" then self:ClaimSeason(player, argument); self:Push(player) end
	end)
	Players.PlayerAdded:Connect(function(player)
		task.delay(2, function()
			if player.Parent then self:EnsureState(player); self:Push(player) end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player) self.LastRequest[player] = nil end)
	for _, player in Players:GetPlayers() do task.spawn(function() self:EnsureState(player); self:Push(player) end) end
	task.spawn(function()
		local lastDay, lastFlash = -1, -1
		while task.wait(30) do
			local calendar = self:GetCalendar()
			local flash = math.floor(os.time() / 7200)
			if calendar.Day ~= lastDay or flash ~= lastFlash then
				lastDay, lastFlash = calendar.Day, flash
				self:ApplyWorldModifiers()
				for _, player in Players:GetPlayers() do self:EnsureState(player); self:Push(player) end
			end
		end
	end)
end

return LiveOpsService
