local JourneyConfig = {}

JourneyConfig.Steps = {
	{ Name = "Primeiro Treino", Description = "Pratique golpes no campo de treino.", Counter = "Training", Goal = 20, Reward = { XP = 500, Ryo = 600 } },
	{ Name = "Patrulha Inicial", Description = "Derrote renegados espalhados pelo mapa.", Counter = "EnemyKill", Goal = 8, Reward = { XP = 700, Ryo = 900, Gems = 5 } },
	{ Name = "Prova de Combate", Description = "Cause dano em inimigos ou chefes.", Counter = "Damage", Goal = 5000, Reward = { XP = 900, Ryo = 1200 } },
	{ Name = "Primeiro Chefe", Description = "Participe da derrota de um chefe mundial.", Counter = "BossKill", Goal = 1, Reward = { XP = 1200, Ryo = 1800, Gems = 10, EventTickets = 2 } },
	{ Name = "Caçador Shinobi", Description = "Limpe as zonas de inimigos do mapa.", Counter = "EnemyKill", Goal = 25, Reward = { XP = 1800, Ryo = 2500, Gems = 15 } },
	{ Name = "Ciclo dos Guardiões", Description = "Derrote três chefes no ciclo atual.", Counter = "BossKill", Goal = 3, Reward = { XP = 2600, Ryo = 4000, Gems = 25, EventTickets = 5 } },
	{ Name = "Rotina de Aventureiro", Description = "Conclua e resgate cinco missões diárias.", Counter = "DailyClaim", Goal = 5, Reward = { XP = 3200, Ryo = 5500, Gems = 35, StyleTokens = 5 } },
	{ Name = "Ruptura Infinita", Description = "Derrote oito chefes para reiniciar a jornada em dificuldade maior.", Counter = "BossKill", Goal = 8, Reward = { XP = 5000, Ryo = 9000, Gems = 60, EventTickets = 10, Essence = 3 } },
}

function JourneyConfig.GetStep(stage)
	return JourneyConfig.Steps[math.clamp(math.floor(tonumber(stage) or 1), 1, #JourneyConfig.Steps)]
end

function JourneyConfig.RewardScale(cycle)
	return 1 + math.min(4, math.max(0, (tonumber(cycle) or 1) - 1) * 0.2)
end

return table.freeze(JourneyConfig)
