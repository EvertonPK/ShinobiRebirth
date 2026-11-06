local MetaConfig = {}

-- Códigos são públicos e de uso único por perfil. Ative/desative códigos aqui;
-- nunca use este módulo para segredos ou credenciais.
MetaConfig.Codes = {
	BEMVINDO = {
		Enabled = true,
		Reward = { Ryo = 5000, Gems = 50, EventTickets = 5 },
		Message = "Kit inicial recebido!",
	},
	GUERRADOSCLAS = {
		Enabled = true,
		Reward = { Ryo = 2500, Gems = 25, EventTickets = 15 },
		Message = "Recompensa da Guerra dos Clãs recebida!",
	},
}

MetaConfig.Achievements = {
	FirstSteps = {
		Name = "Primeiros Passos",
		Description = "Alcance o nível 10.",
		Metric = "Level",
		Goal = 10,
		Reward = { Ryo = 1500, Gems = 10 },
	},
	ChuninPath = {
		Name = "Caminho Chunin",
		Description = "Alcance o nível 25.",
		Metric = "Level",
		Goal = 25,
		Reward = { Ryo = 5000, Gems = 25 },
	},
	FirstRebirth = {
		Name = "Um Novo Começo",
		Description = "Realize seu primeiro Rebirth.",
		Metric = "Rebirths",
		Goal = 1,
		Reward = { Gems = 100, EventTickets = 10 },
	},
	BossHunter = {
		Name = "Caçador de Lendas",
		Description = "Derrote 10 chefes.",
		Metric = "BossKillsTotal",
		Goal = 10,
		Reward = { Ryo = 15000, Gems = 75 },
	},
	BossLegend = {
		Name = "Lenda dos Chefes",
		Description = "Derrote 100 chefes.",
		Metric = "BossKillsTotal",
		Goal = 100,
		Reward = { Ryo = 100000, Gems = 500, EventTickets = 50 },
	},
	ClanVanguard = {
		Name = "Vanguarda do Clã",
		Description = "Contribua 5.000 pontos para seu clã.",
		Metric = "ClanContribution",
		Goal = 5000,
		Reward = { Ryo = 25000, Gems = 125 },
	},
	Collector = {
		Name = "Colecionador",
		Description = "Colecione 10 cosméticos.",
		Metric = "InventoryCount",
		Goal = 10,
		Reward = { Gems = 200, EventTickets = 20 },
	},
	Veteran = {
		Name = "Veterano",
		Description = "Jogue por 10 horas no total.",
		Metric = "TotalPlaySeconds",
		Goal = 36000,
		Reward = { Ryo = 50000, Gems = 300 },
	},
}

MetaConfig.Leaderboards = {
	{ Id = "Level", Name = "Nível", Descending = true },
	{ Id = "Rebirths", Name = "Rebirths", Descending = true },
	{ Id = "ClanContribution", Name = "Contribuição", Descending = true },
	{ Id = "BossKillsTotal", Name = "Chefes", Descending = true },
}

return table.freeze(MetaConfig)
