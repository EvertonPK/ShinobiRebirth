local LiveOpsConfig = {}

LiveOpsConfig.SeasonLengthDays = 28
LiveOpsConfig.SeasonPointsPerLevel = 100
LiveOpsConfig.SeasonMaxLevel = 30

LiveOpsConfig.DailyEvents = {
	{ Id = "WinterFestival", Name = "Festival de Natal Shinobi", Description = "O vilarejo está coberto de neve: chefes, missões e baús rendem mais durante o festival.", Modifiers = { XP = 1.35, Ryo = 1.35, BossReward = 1.4, LootLuck = 1.25, Mastery = 1.2 } },
	{ Id = "TrainingFrenzy", Name = "Treino Intensivo", Description = "XP e Ryo aumentados durante todo o dia.", Modifiers = { XP = 1.5, Ryo = 1.25, BossReward = 1, LootLuck = 1 } },
	{ Id = "BossRush", Name = "Investida dos Chefes", Description = "Chefes rendem mais recompensas e mutadores melhores.", Modifiers = { XP = 1.15, Ryo = 1.2, BossReward = 1.6, LootLuck = 1.2 } },
	{ Id = "BountyHunt", Name = "Caçada aos Renegados", Description = "Inimigos de campo concedem XP e Ryo adicionais.", Modifiers = { XP = 1.35, Ryo = 1.5, BossReward = 1, LootLuck = 1.05 } },
	{ Id = "TreasureRain", Name = "Chuva de Tesouros", Description = "A sorte de drops aumenta para todos, sem custo de entrada.", Modifiers = { XP = 1, Ryo = 1.15, BossReward = 1.15, LootLuck = 1.75 } },
	{ Id = "EndlessRift", Name = "Fenda Infinita", Description = "Cada ciclo de chefes fica mais difícil e concede recompensas maiores.", Modifiers = { XP = 1.25, Ryo = 1.25, BossReward = 1.45, LootLuck = 1.2, Mastery = 1.2 } },
	{ Id = "MasterySurge", Name = "Surto de Maestria", Description = "Um dia para evoluir técnicas e avançar níveis mais rápido.", Modifiers = { XP = 1.75, Ryo = 1, BossReward = 1.1, LootLuck = 1, Mastery = 1.75 } },
	{ Id = "LegendaryHunt", Name = "Caçada Lendária", Description = "A chance de itens raros aumenta, mantendo o pity.", Modifiers = { XP = 1.1, Ryo = 1.1, BossReward = 1.25, LootLuck = 2 } },
}

LiveOpsConfig.FlashEvents = {
	{ Id = "RyoHour", Name = "Hora do Ryo", Modifiers = { XP = 1, Ryo = 1.5, LootLuck = 1 } },
	{ Id = "ShinobiHour", Name = "Hora Shinobi", Modifiers = { XP = 1.35, Ryo = 1, LootLuck = 1 } },
	{ Id = "LuckyHour", Name = "Hora da Sorte", Modifiers = { XP = 1, Ryo = 1, LootLuck = 1.3 } },
}

LiveOpsConfig.LoginRewards = {
	{ Ryo = 500, Gems = 5, SeasonPoints = 20 },
	{ XP = 350, EventTickets = 2, SeasonPoints = 20 },
	{ Essence = 2, StyleTokens = 2, SeasonPoints = 25 },
	{ Ryo = 900, Gems = 10, SeasonPoints = 25 },
	{ XP = 700, EventTickets = 3, SeasonPoints = 30 },
	{ Essence = 5, StyleTokens = 4, SeasonPoints = 35 },
	{ Ryo = 2000, Gems = 25, EventTickets = 5, StyleTokens = 8, Essence = 10, SeasonPoints = 50 },
}

LiveOpsConfig.WeeklyObjectives = {
	{ Id = "WeeklyDamage", Counter = "Damage", Name = "Cause dano em qualquer atividade", Goal = 30000, Ryo = 1800, XP = 1200, Gems = 20, StyleTokens = 3, SeasonPoints = 100 },
	{ Id = "WeeklyEnemies", Counter = "EnemyKill", Name = "Derrote shinobi renegados", Goal = 45, Ryo = 2200, XP = 1500, Gems = 20, EventTickets = 5, SeasonPoints = 120 },
	{ Id = "WeeklyBosses", Counter = "BossKill", Name = "Participe de vitórias contra chefes", Goal = 5, Ryo = 3000, Gems = 35, StyleTokens = 6, Essence = 5, SeasonPoints = 160 },
	{ Id = "WeeklyDailies", Counter = "DailyClaim", Name = "Conclua missões diárias", Goal = 9, Ryo = 2500, XP = 1800, Gems = 25, EventTickets = 10, StyleTokens = 4, SeasonPoints = 140 },
	{ Id = "WeeklyTraining", Counter = "Training", Name = "Treine nos campos da vila", Goal = 100, Ryo = 1600, XP = 1000, Gems = 15, StyleTokens = 5, SeasonPoints = 90 },
}

function LiveOpsConfig.GetSeasonReward(level)
	if level == LiveOpsConfig.SeasonMaxLevel then
		return { Essence = 42, Ryo = 30000, Gems = 300, EventTickets = 25, StyleTokens = 60 }
	elseif level % 10 == 0 then
		return {
			Essence = 12 + level,
			Ryo = 1000 * level,
			Gems = 50 + level * 5,
			EventTickets = 10,
			StyleTokens = 15 + level,
		}
	elseif level % 5 == 0 then
		return {
			Essence = 5 + math.floor(level / 2),
			Ryo = 500 * level,
			Gems = 35 + level * 2,
			EventTickets = 5,
			StyleTokens = 10 + math.floor(level / 2),
		}
	elseif level % 2 == 0 then
		return { XP = 250 + level * 50, Ryo = 150 * level, Gems = 8 + level, StyleTokens = 2 }
	end
	return { Ryo = 250 + level * 125, EventTickets = 2, StyleTokens = 1 }
end

return table.freeze(LiveOpsConfig)
