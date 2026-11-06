local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BossConfig = require(ReplicatedStorage.ShinobiShared.BossConfig)
local GameConfig = require(ReplicatedStorage.ShinobiShared.GameConfig)
local LootConfig = require(ReplicatedStorage.ShinobiShared.LootConfig)

local RewardService = {}

function RewardService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Progression = context.Services.ProgressionService
	self.Quests = context.Services.QuestService
	self.Clans = context.Services.ClanService
	self.Remotes = context.Remotes
	self.Random = Random.new()
	self.NextEquip = {}
end

function RewardService:TryDrop(profile, itemId)
	local item = LootConfig[itemId]
	if not item then
		return false
	end
	if item.Type == "Material" then
		profile.Materials[itemId] = (profile.Materials[itemId] or 0) + self.Random:NextInteger(1, 3)
		return true
	end
	if profile.Inventory[itemId] then
		profile.Ryo += item.DuplicateRyo or 0
		profile.StyleTokens += item.Rarity == "Mythic" and 35 or (item.Rarity == "Legendary" and 12 or 4)
		return false
	end
	local pity = (profile.Pity[itemId] or 0) + 1
	local baseChance = item.Chance or 0.05
	local lootLuck = math.max(1, workspace:GetAttribute("LiveOpsLootLuck") or 1)
	local boostedChance = math.min(1, baseChance * lootLuck + math.max(0, pity - 10) * baseChance * 0.08)
	if self.Random:NextNumber() <= boostedChance or pity >= (item.Pity or 60) then
		profile.Inventory[itemId] = true
		profile.Pity[itemId] = 0
		return true
	end
	profile.Pity[itemId] = pity
	return false
end

function RewardService:AwardBoss(player, bossId, rewardMultiplier)
	local definition = BossConfig.Definitions[bossId]
	local profile = self.Profiles:Get(player)
	if not definition or not profile then
		return
	end
	local tier = GameConfig.GetWorldTier(profile.Rebirths)
	local tierConfig = GameConfig.WorldTiers[tier]
	local liveOpsMultiplier = math.max(1, workspace:GetAttribute("LiveOpsBossRewardMultiplier") or 1)
	local multiplier = (rewardMultiplier or 1) * tierConfig.Rewards * liveOpsMultiplier
	local xp = math.floor((500 + definition.BaseHealth * 0.04) * multiplier)
	local ryo = math.floor((650 + definition.BaseHealth * 0.055) * multiplier)
	local drops = {}
	self.Profiles:Mutate(player, function(data)
		data.BossKills[bossId] = (data.BossKills[bossId] or 0) + 1
		for _, itemId in definition.Drops do
			if self:TryDrop(data, itemId) then
				table.insert(drops, itemId)
			end
		end
	end)
	self.Progression:AddXP(player, xp)
	self.Progression:AddRyo(player, ryo)
	self.Quests:Record(player, "BossKill", 1)
	self.Clans:AddContribution(player, math.floor(100 * multiplier))
	self.Remotes.Notification:FireClient(player, {
		Kind = "BossReward",
		Text = string.format("%s derrotado: +%d XP, +%d Ryo", definition.DisplayName, xp, ryo),
		Drops = drops,
	})
end

function RewardService:Start()
	self.Remotes.EquipRequest.OnServerEvent:Connect(function(player, itemId)
		if type(itemId) ~= "string" or #itemId > 64 then
			return
		end
		local now = os.clock()
		if now < (self.NextEquip[player] or 0) then
			return
		end
		self.NextEquip[player] = now + 0.25
		local item = LootConfig[itemId]
		local profile = self.Profiles:Get(player)
		if not item or not profile or not profile.Inventory[itemId] or item.Type == "Material"
			or profile.Equipped[item.Type] == itemId
		then
			return
		end
		self.Profiles:Mutate(player, function(data)
			if not data.Inventory[itemId] or data.Equipped[item.Type] == itemId then return end
			data.Equipped[item.Type] = itemId
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.NextEquip[player] = nil
	end)
end

return RewardService
