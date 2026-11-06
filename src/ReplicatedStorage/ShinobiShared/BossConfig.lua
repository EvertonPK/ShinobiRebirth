local BossConfig = {}

BossConfig.Order = { "EmberRonin", "StormOni", "VerdantSage", "VoidShogun" }

BossConfig.Definitions = {
	EmberRonin = {
		DisplayName = "Ronin das Cinzas",
		Subtitle = "A lâmina que nunca esfria",
		BaseHealth = 8500,
		BaseDamage = 22,
		Arena = Vector3.new(0, 5, 330),
		ImportedArena = Vector3.new(1150, -1017, -3100),
		Palette = {
			Primary = Color3.fromRGB(47, 22, 18),
			Secondary = Color3.fromRGB(164, 47, 24),
			Accent = Color3.fromRGB(255, 126, 38),
		},
		Material = Enum.Material.Slate,
		AccentMaterial = Enum.Material.Neon,
		Abilities = { "FlameCleave", "AshRing", "FallingEmbers" },
		Drops = { "EmberCore", "RoninMask", "AshenKatanaSkin", "EmberEyes", "PhoenixMantle", "SolarFlareAura" },
	},
	StormOni = {
		DisplayName = "Oni da Tempestade",
		Subtitle = "O trovão ganhou um corpo",
		BaseHealth = 12000,
		BaseDamage = 28,
		Arena = Vector3.new(330, 8, 0),
		ImportedArena = Vector3.new(1400, -1017, -3100),
		Palette = {
			Primary = Color3.fromRGB(25, 31, 65),
			Secondary = Color3.fromRGB(55, 92, 180),
			Accent = Color3.fromRGB(126, 224, 255),
		},
		Material = Enum.Material.Metal,
		AccentMaterial = Enum.Material.Neon,
		Abilities = { "ThunderDash", "LightningPillars", "StormPrison" },
		Drops = { "StormHorn", "OniArmorSkin", "RaijinAura", "TempestTwinBlade", "ThunderCrown", "CelestialStormEyes" },
	},
	VerdantSage = {
		DisplayName = "Sábio Primordial",
		Subtitle = "A floresta se lembra de tudo",
		BaseHealth = 16000,
		BaseDamage = 32,
		Arena = Vector3.new(-330, 6, 0),
		ImportedArena = Vector3.new(1650, -1017, -3100),
		Palette = {
			Primary = Color3.fromRGB(34, 58, 39),
			Secondary = Color3.fromRGB(74, 128, 75),
			Accent = Color3.fromRGB(170, 255, 121),
		},
		Material = Enum.Material.Wood,
		AccentMaterial = Enum.Material.Neon,
		Abilities = { "RootSnare", "BloomBurst", "AncientGuardians" },
		Drops = { "SageSeed", "ForestCloakSkin", "VerdantEyes", "AncestorBarkArmor", "BlossomAura", "JadeSpear" },
	},
	VoidShogun = {
		DisplayName = "Shogun do Vazio",
		Subtitle = "O fim observa por trás da máscara",
		BaseHealth = 24000,
		BaseDamage = 40,
		Arena = Vector3.new(0, 12, -360),
		ImportedArena = Vector3.new(1650, -1012, -3170),
		Palette = {
			Primary = Color3.fromRGB(20, 15, 29),
			Secondary = Color3.fromRGB(73, 42, 107),
			Accent = Color3.fromRGB(229, 94, 255),
		},
		Material = Enum.Material.ForceField,
		AccentMaterial = Enum.Material.Neon,
		Abilities = { "VoidCuts", "GravityWell", "ShadowClones" },
		Drops = { "VoidFragment", "ShogunArmorSkin", "RiftBladeSkin", "EclipseEyes", "AbyssAura", "CrownOfNothing" },
	},
}

BossConfig.Mutators = {
	{ Id = "Frenzied", Name = "Frenético", Health = 0.85, Damage = 1.35, Speed = 1.35, Reward = 1.25 },
	{ Id = "Titanic", Name = "Titânico", Health = 1.8, Damage = 1.15, Speed = 0.8, Reward = 1.4 },
	{ Id = "Vampiric", Name = "Vampírico", Health = 1.2, Damage = 1.1, Speed = 1, Reward = 1.35 },
	{ Id = "Mirrored", Name = "Espelhado", Health = 1.25, Damage = 1.2, Speed = 1.1, Reward = 1.4 },
	{ Id = "Mythic", Name = "Mítico", Health = 2.25, Damage = 1.65, Speed = 1.2, Reward = 2.2 },
}

return table.freeze(BossConfig)
