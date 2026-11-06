-- Chances são probabilidades por tentativa (0.001 = 0,1%).
-- Pity garante o item após a quantidade indicada de tentativas válidas.
-- Sources descreve onde o item pode ser obtido e pode ser exibido pela UI.
local function item(name, rarity, itemType, chance, pity, sources, duplicateRyo)
	return {
		Name = name,
		Rarity = rarity,
		Type = itemType,
		Chance = chance,
		Pity = pity,
		Sources = sources,
		DuplicateRyo = duplicateRyo,
		Tradable = false,
	}
end

return table.freeze({
	EmberCore = item("Núcleo de Brasa", "Rare", "Material", 1, 1, { "EmberRonin" }, 0),
	StormHorn = item("Chifre da Tempestade", "Rare", "Material", 1, 1, { "StormOni" }, 0),
	SageSeed = item("Semente Ancestral", "Rare", "Material", 1, 1, { "VerdantSage" }, 0),
	VoidFragment = item("Fragmento do Vazio", "Epic", "Material", 1, 1, { "VoidShogun" }, 0),

	RoninMask = item("Máscara do Ronin", "Epic", "Cosmetic", 0.08, 20, { "EmberRonin", "BossChest" }, 800),
	AshenKatanaSkin = item("Katana Cinzenta", "Legendary", "WeaponSkin", 0.025, 40, { "EmberRonin", "BossChest" }, 2200),
	EmberEyes = item("Olhos de Brasa", "Legendary", "Eyes", 0.015, 55, { "EmberRonin", "LegendaryChest" }, 3000),
	PhoenixMantle = item("Manto da Fênix", "Legendary", "Cosmetic", 0.008, 80, { "EmberRonin", "LegendaryChest" }, 5500),
	SolarFlareAura = item("Aura da Chama Solar", "Mythic", "Aura", 0.002, 180, { "EmberRonin", "MythicChest" }, 12000),

	OniArmorSkin = item("Armadura Oni", "Epic", "Cosmetic", 0.065, 22, { "StormOni", "BossChest" }, 900),
	RaijinAura = item("Aura de Raijin", "Legendary", "Aura", 0.02, 45, { "StormOni", "BossChest" }, 2600),
	TempestTwinBlade = item("Lâmina Gêmea da Tormenta", "Legendary", "WeaponSkin", 0.012, 65, { "StormOni", "LegendaryChest" }, 4200),
	ThunderCrown = item("Coroa do Trovão", "Legendary", "Cosmetic", 0.006, 95, { "StormOni", "LegendaryChest" }, 6500),
	CelestialStormEyes = item("Olhos da Tempestade Celeste", "Mythic", "Eyes", 0.0015, 200, { "StormOni", "MythicChest" }, 14000),

	ForestCloakSkin = item("Manto da Floresta", "Epic", "Cosmetic", 0.055, 25, { "VerdantSage", "BossChest" }, 1000),
	VerdantEyes = item("Olhos Verdejantes", "Legendary", "Eyes", 0.018, 50, { "VerdantSage", "BossChest" }, 2800),
	AncestorBarkArmor = item("Armadura da Casca Ancestral", "Legendary", "Cosmetic", 0.012, 70, { "VerdantSage", "LegendaryChest" }, 4300),
	BlossomAura = item("Aura da Flor Eterna", "Legendary", "Aura", 0.006, 100, { "VerdantSage", "LegendaryChest" }, 6800),
	JadeSpear = item("Lança de Jade Vivo", "Mythic", "WeaponSkin", 0.0018, 190, { "VerdantSage", "MythicChest" }, 13500),

	ShogunArmorSkin = item("Armadura do Shogun", "Legendary", "Cosmetic", 0.03, 40, { "VoidShogun", "BossChest" }, 2400),
	RiftBladeSkin = item("Lâmina da Fenda", "Mythic", "WeaponSkin", 0.008, 90, { "VoidShogun", "LegendaryChest" }, 7000),
	EclipseEyes = item("Olhos do Eclipse", "Legendary", "Eyes", 0.005, 110, { "VoidShogun", "LegendaryChest" }, 7500),
	AbyssAura = item("Aura do Abismo", "Mythic", "Aura", 0.0015, 210, { "VoidShogun", "MythicChest" }, 14500),
	CrownOfNothing = item("Coroa do Nada", "Mythic", "Cosmetic", 0.0008, 300, { "VoidShogun", "MythicChest" }, 22000),

	LunarFoxMask = item("Máscara da Raposa Lunar", "Legendary", "Cosmetic", 0.006, 100, { "MoonFestival", "EventChest" }, 6000),
	CrimsonCometBlade = item("Lâmina do Cometa Carmesim", "Legendary", "WeaponSkin", 0.004, 120, { "CometNight", "EventChest" }, 7800),
	AuroraAura = item("Aura da Aurora", "Mythic", "Aura", 0.001, 250, { "AuroraWeek", "MythicChest" }, 18000),
	StarlitEyes = item("Olhos Estelares", "Mythic", "Eyes", 0.001, 250, { "Starfall", "MythicChest" }, 18000),
	GoldenWanderer = item("Traje do Andarilho Dourado", "Legendary", "Cosmetic", 0.003, 140, { "WeeklyPass", "LegendaryChest" }, 9000),
	FrostfangBlade = item("Presa de Gelo", "Legendary", "WeaponSkin", 0.005, 110, { "FrostInvasion", "EventChest" }, 7200),
	SpiritBloomEyes = item("Olhos da Flor Espiritual", "Legendary", "Eyes", 0.004, 130, { "BloomEvent", "EventChest" }, 8200),
	DragonPulseAura = item("Aura do Pulso Dracônico", "Mythic", "Aura", 0.0005, 350, { "EndlessCycle", "MythicChest" }, 30000),
})
