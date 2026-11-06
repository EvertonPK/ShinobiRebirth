-- A loja é configurada para funcionar integralmente com moedas obtidas jogando.
-- ProductId = 0 mantém a opção Robux desativada até o produto ser criado no
-- Creator Dashboard. Nunca substitua esses valores por IDs de terceiros.
local StoreConfig = {}

StoreConfig.Rarities = {
	Common = { Weight = 18000, DuplicateRyo = 350, DuplicateStyleTokens = 1 },
	Rare = { Weight = 12000, DuplicateRyo = 900, DuplicateStyleTokens = 2 },
	Epic = { Weight = 7000, DuplicateRyo = 2400, DuplicateStyleTokens = 4 },
	Legendary = { Weight = 280, DuplicateRyo = 7000, DuplicateStyleTokens = 12 },
	Mythic = { Weight = 10, DuplicateRyo = 20000, DuplicateStyleTokens = 35 },
}

StoreConfig.Items = {
	RoninMask = { Ryo = 18000, Gems = 240, StyleTokens = 90, ProductId = 0 },
	AshenKatanaSkin = { Ryo = 90000, Gems = 850, StyleTokens = 320, ProductId = 0 },
	OniArmorSkin = { Ryo = 26000, Gems = 320, StyleTokens = 120, ProductId = 0 },
	RaijinAura = { Ryo = 110000, Gems = 950, StyleTokens = 360, ProductId = 0 },
	ForestCloakSkin = { Ryo = 35000, Gems = 390, StyleTokens = 145, ProductId = 0 },
	VerdantEyes = { Ryo = 135000, Gems = 1100, StyleTokens = 420, ProductId = 0 },
	ShogunArmorSkin = { Ryo = 150000, Gems = 1200, StyleTokens = 450, ProductId = 0 },
	RiftBladeSkin = { Ryo = 450000, Gems = 2800, StyleTokens = 1000, ProductId = 0 },
	EmberEyes = { Ryo = 105000, Gems = 900, StyleTokens = 340, ProductId = 0 },
	PhoenixMantle = { Ryo = 165000, Gems = 1350, StyleTokens = 500, ProductId = 0 },
	SolarFlareAura = { Ryo = 600000, Gems = 3400, StyleTokens = 1250, ProductId = 0 },
	TempestTwinBlade = { Ryo = 125000, Gems = 1050, StyleTokens = 390, ProductId = 0 },
	ThunderCrown = { Ryo = 180000, Gems = 1450, StyleTokens = 540, ProductId = 0 },
	CelestialStormEyes = { Ryo = 650000, Gems = 3600, StyleTokens = 1320, ProductId = 0 },
	AncestorBarkArmor = { Ryo = 130000, Gems = 1100, StyleTokens = 410, ProductId = 0 },
	BlossomAura = { Ryo = 190000, Gems = 1500, StyleTokens = 560, ProductId = 0 },
	JadeSpear = { Ryo = 625000, Gems = 3500, StyleTokens = 1280, ProductId = 0 },
	EclipseEyes = { Ryo = 210000, Gems = 1650, StyleTokens = 610, ProductId = 0 },
	AbyssAura = { Ryo = 700000, Gems = 3900, StyleTokens = 1420, ProductId = 0 },
	CrownOfNothing = { Ryo = 900000, Gems = 4800, StyleTokens = 1750, ProductId = 0 },
	LunarFoxMask = { Ryo = 160000, Gems = 1300, StyleTokens = 480, ProductId = 0 },
	CrimsonCometBlade = { Ryo = 175000, Gems = 1425, StyleTokens = 525, ProductId = 0 },
	AuroraAura = { Ryo = 725000, Gems = 4000, StyleTokens = 1480, ProductId = 0 },
	StarlitEyes = { Ryo = 725000, Gems = 4000, StyleTokens = 1480, ProductId = 0 },
	GoldenWanderer = { Ryo = 200000, Gems = 1575, StyleTokens = 590, ProductId = 0 },
	FrostfangBlade = { Ryo = 170000, Gems = 1375, StyleTokens = 510, ProductId = 0 },
	SpiritBloomEyes = { Ryo = 185000, Gems = 1500, StyleTokens = 555, ProductId = 0 },
	DragonPulseAura = { Ryo = 1000000, Gems = 5200, StyleTokens = 1900, ProductId = 0 },
}

StoreConfig.Crates = {
	VillageChest = {
		Name = "Baú da Vila",
		Description = "Baú acessível comprado com Ryo.",
		Currency = "Ryo",
		Price = 3500,
		ProductId = 0,
		LegendaryPity = 35,
		MythicPity = 100,
		Pool = {
			{ ItemId = "RoninMask", Rarity = "Epic" },
			{ ItemId = "OniArmorSkin", Rarity = "Epic" },
			{ ItemId = "ForestCloakSkin", Rarity = "Epic" },
			{ ItemId = "AshenKatanaSkin", Rarity = "Legendary" },
			{ ItemId = "RaijinAura", Rarity = "Legendary" },
			{ ItemId = "GoldenWanderer", Rarity = "Legendary" },
			{ ItemId = "RiftBladeSkin", Rarity = "Mythic" },
		},
	},
	ShinobiChest = {
		Name = "Baú Shinobi",
		Description = "Gemas também são obtidas em eventos e missões.",
		Currency = "Gems",
		Price = 80,
		ProductId = 0,
		LegendaryPity = 25,
		MythicPity = 75,
		Pool = {
			{ ItemId = "RoninMask", Rarity = "Epic" },
			{ ItemId = "OniArmorSkin", Rarity = "Epic" },
			{ ItemId = "ForestCloakSkin", Rarity = "Epic" },
			{ ItemId = "AshenKatanaSkin", Rarity = "Legendary" },
			{ ItemId = "EmberEyes", Rarity = "Legendary" },
			{ ItemId = "PhoenixMantle", Rarity = "Legendary" },
			{ ItemId = "RaijinAura", Rarity = "Legendary" },
			{ ItemId = "TempestTwinBlade", Rarity = "Legendary" },
			{ ItemId = "ThunderCrown", Rarity = "Legendary" },
			{ ItemId = "VerdantEyes", Rarity = "Legendary" },
			{ ItemId = "AncestorBarkArmor", Rarity = "Legendary" },
			{ ItemId = "BlossomAura", Rarity = "Legendary" },
			{ ItemId = "ShogunArmorSkin", Rarity = "Legendary" },
			{ ItemId = "EclipseEyes", Rarity = "Legendary" },
			{ ItemId = "SolarFlareAura", Rarity = "Mythic" },
			{ ItemId = "CelestialStormEyes", Rarity = "Mythic" },
			{ ItemId = "JadeSpear", Rarity = "Mythic" },
			{ ItemId = "RiftBladeSkin", Rarity = "Mythic" },
			{ ItemId = "AbyssAura", Rarity = "Mythic" },
			{ ItemId = "CrownOfNothing", Rarity = "Mythic" },
		},
	},
	EventChest = {
		Name = "Baú do Evento",
		Description = "Comprado exclusivamente com tickets conquistados jogando.",
		Currency = "EventTickets",
		Price = 25,
		ProductId = 0,
		LegendaryPity = 15,
		MythicPity = 50,
		Pool = {
			{ ItemId = "RoninMask", Rarity = "Epic" },
			{ ItemId = "OniArmorSkin", Rarity = "Epic" },
			{ ItemId = "ForestCloakSkin", Rarity = "Epic" },
			{ ItemId = "LunarFoxMask", Rarity = "Legendary" },
			{ ItemId = "CrimsonCometBlade", Rarity = "Legendary" },
			{ ItemId = "GoldenWanderer", Rarity = "Legendary" },
			{ ItemId = "FrostfangBlade", Rarity = "Legendary" },
			{ ItemId = "SpiritBloomEyes", Rarity = "Legendary" },
			{ ItemId = "AuroraAura", Rarity = "Mythic" },
			{ ItemId = "StarlitEyes", Rarity = "Mythic" },
			{ ItemId = "DragonPulseAura", Rarity = "Mythic" },
		},
	},
}

-- Produtos de moeda opcional. As mesmas moedas possuem fontes gratuitas.
StoreConfig.CurrencyProducts = {
	StyleTokensSmall = { ProductId = 0, Currency = "StyleTokens", Amount = 120 },
	StyleTokensMedium = { ProductId = 0, Currency = "StyleTokens", Amount = 650 },
	StyleTokensLarge = { ProductId = 0, Currency = "StyleTokens", Amount = 1500 },
}

function StoreConfig.GetProductGrants()
	local products = {}
	for offerId, offer in StoreConfig.Items do
		if offer.ProductId > 0 then
			products[offer.ProductId] = { Kind = "Item", Id = offerId }
		end
	end
	for offerId, offer in StoreConfig.CurrencyProducts do
		if offer.ProductId > 0 then
			products[offer.ProductId] = { Kind = "Currency", Id = offerId }
		end
	end
	return products
end

return table.freeze(StoreConfig)
