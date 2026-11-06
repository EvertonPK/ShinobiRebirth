local GameConfig = {}

GameConfig.DataVersion = 1
GameConfig.ProfileStore = "ShinobiRebirth_Profile_v2"
GameConfig.AutoSaveSeconds = 60
GameConfig.MaxLevel = 100
GameConfig.BaseWalkSpeed = 16
GameConfig.BaseHealth = 100
GameConfig.BaseChakra = 100
GameConfig.BasicAttackRange = 12
GameConfig.BasicAttackCooldown = 0.55
GameConfig.HeavyAttackCooldown = 3.5
GameConfig.DashCooldown = 2.25
GameConfig.RebirthLevel = 100
GameConfig.BossIntermission = 35
GameConfig.BossTimeLimit = 420

GameConfig.Ranks = {
	{ Name = "Academy", Level = 1, Color = Color3.fromRGB(175, 175, 175) },
	{ Name = "Genin", Level = 10, Color = Color3.fromRGB(106, 190, 92) },
	{ Name = "Chunin", Level = 25, Color = Color3.fromRGB(82, 151, 210) },
	{ Name = "Jonin", Level = 45, Color = Color3.fromRGB(163, 103, 215) },
	{ Name = "Anbu", Level = 70, Color = Color3.fromRGB(225, 82, 92) },
	{ Name = "Kage", Level = 100, Color = Color3.fromRGB(255, 185, 63) },
}

GameConfig.WorldTiers = {
	[1] = { Health = 1, Damage = 1, Rewards = 1 },
	[2] = { Health = 1.65, Damage = 1.25, Rewards = 1.45 },
	[3] = { Health = 2.6, Damage = 1.6, Rewards = 2.1 },
	[4] = { Health = 4.1, Damage = 2.05, Rewards = 3.0 },
	[5] = { Health = 6.5, Damage = 2.7, Rewards = 4.4 },
}

function GameConfig.XPForLevel(level)
	return math.floor(75 + 28 * level + 10 * level ^ 1.55)
end

function GameConfig.StatPointsForLevel(_level)
	return 3
end

function GameConfig.GetRank(level)
	local current = GameConfig.Ranks[1]
	for _, rank in GameConfig.Ranks do
		if level >= rank.Level then
			current = rank
		else
			break
		end
	end
	return current
end

function GameConfig.GetWorldTier(rebirths)
	return math.clamp(math.floor(rebirths / 2) + 1, 1, #GameConfig.WorldTiers)
end

return table.freeze(GameConfig)
