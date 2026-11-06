local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local LootConfig = require(ReplicatedStorage.ShinobiShared.LootConfig)
local StoreConfig = require(ReplicatedStorage.ShinobiShared.StoreConfig)

local EconomyService = {}

local VALID_CURRENCIES = {
	Ryo = true,
	Gems = true,
	EventTickets = true,
	StyleTokens = true,
}

local function rarityWeight(rarity, lootLuck)
	local base = StoreConfig.Rarities[rarity].Weight
	if rarity == "Epic" then
		return base * lootLuck
	elseif rarity == "Legendary" then
		return base * lootLuck ^ 1.5
	elseif rarity == "Mythic" then
		return base * lootLuck ^ 2
	end
	return base
end

local function copyPublicStore(lootLuck)
	local crates = {}
	for crateId, crate in StoreConfig.Crates do
		local rarityWeights = {}
		local totalWeight = 0
		for _, entry in crate.Pool do
			if not rarityWeights[entry.Rarity] then
				local weight = rarityWeight(entry.Rarity, lootLuck)
				rarityWeights[entry.Rarity] = weight
				totalWeight += weight
			end
		end
		local odds = {}
		local rarityCounts = {}
		for _, entry in crate.Pool do
			rarityCounts[entry.Rarity] = (rarityCounts[entry.Rarity] or 0) + 1
		end
		for rarity, weight in rarityWeights do
			odds[rarity] = weight / totalWeight
		end
		local itemOdds = {}
		for _, entry in crate.Pool do
			itemOdds[entry.ItemId] = odds[entry.Rarity] / rarityCounts[entry.Rarity]
		end
		crates[crateId] = {
			Name = crate.Name,
			Description = crate.Description,
			Currency = crate.Currency,
			Price = crate.Price,
			RobuxEnabled = false,
			LegendaryPity = crate.LegendaryPity,
			MythicPity = crate.MythicPity,
			Odds = odds,
			ItemOdds = itemOdds,
			Pool = crate.Pool,
		}
	end
	local items = {}
	for itemId, offer in StoreConfig.Items do
		items[itemId] = {
			Ryo = offer.Ryo,
			Gems = offer.Gems,
			StyleTokens = offer.StyleTokens,
			RobuxEnabled = offer.ProductId > 0,
		}
	end
	return { Crates = crates, Items = items, LootLuck = lootLuck }
end

function EconomyService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Remotes = context.Remotes
	self.Random = Random.new()
	self.RateLimits = {}
	self.ProductGrants = StoreConfig.GetProductGrants()
	self.PolicyCache = {}
	self.ReceiptStore = DataStoreService:GetDataStore("ShinobiRebirth_Receipts_v1")
end

function EconomyService:GetPolicy(player)
	if self.PolicyCache[player] then
		return self.PolicyCache[player]
	end
	local policy = { ArePaidRandomItemsRestricted = true }
	local ok, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(player)
	end)
	if ok and type(result) == "table" then
		policy = result
	end
	self.PolicyCache[player] = policy
	return policy
end

function EconomyService:CanRequest(player)
	local now = os.clock()
	if now < (self.RateLimits[player] or 0) then
		return false
	end
	self.RateLimits[player] = now + 0.35
	return true
end

function EconomyService:Notify(player, text, kind)
	self.Remotes.Notification:FireClient(player, { Kind = kind or "Shop", Text = text })
end

function EconomyService:PushState(player)
	local profile = self.Profiles:Get(player)
	if not profile then
		return
	end
	self.Remotes.ShopState:FireClient(player, {
		Store = copyPublicStore(workspace:GetAttribute("LiveOpsLootLuck") or 1),
		Currencies = {
			Ryo = profile.Ryo,
			Gems = profile.Gems,
			EventTickets = profile.EventTickets,
			StyleTokens = profile.StyleTokens,
		},
		CratePity = table.clone(profile.CratePity),
		PaidRandomItemsRestricted = self:GetPolicy(player).ArePaidRandomItemsRestricted == true,
	})
end

function EconomyService:Spend(profile, currency, amount)
	if not VALID_CURRENCIES[currency] or type(amount) ~= "number" or amount < 0 then
		return false
	end
	if profile[currency] < amount then
		return false
	end
	profile[currency] -= amount
	return true
end

function EconomyService:GrantDuplicate(profile, itemId)
	local item = LootConfig[itemId]
	local rarity = item and item.Rarity or "Rare"
	local rarityConfig = StoreConfig.Rarities[rarity] or StoreConfig.Rarities.Rare
	profile.Ryo += rarityConfig.DuplicateRyo
	profile.StyleTokens += rarityConfig.DuplicateStyleTokens or 0
	return rarityConfig.DuplicateRyo, rarityConfig.DuplicateStyleTokens or 0
end

function EconomyService:ChooseCrateItem(crate, pity)
	local forcedRarity
	if pity.Mythic + 1 >= crate.MythicPity then
		forcedRarity = "Mythic"
	elseif pity.Legendary + 1 >= crate.LegendaryPity then
		forcedRarity = "Legendary"
	end
	local byRarity = {}
	local rarityCandidates = {}
	local total = 0
	for _, entry in crate.Pool do
		if not forcedRarity or entry.Rarity == forcedRarity then
			byRarity[entry.Rarity] = byRarity[entry.Rarity] or {}
			table.insert(byRarity[entry.Rarity], entry)
		end
	end
	local lootLuck = math.max(1, workspace:GetAttribute("LiveOpsLootLuck") or 1)
	for rarity in byRarity do
		local weight = rarityWeight(rarity, lootLuck)
		total += weight
		table.insert(rarityCandidates, { Rarity = rarity, Cumulative = total })
	end
	if #rarityCandidates == 0 then
		return nil
	end
	local roll = self.Random:NextNumber(0, total)
	local selectedRarity = rarityCandidates[#rarityCandidates].Rarity
	for _, candidate in rarityCandidates do
		if roll <= candidate.Cumulative then
			selectedRarity = candidate.Rarity
			break
		end
	end
	local entries = byRarity[selectedRarity]
	return entries[self.Random:NextInteger(1, #entries)]
end

function EconomyService:OpenCrate(player, crateId, freeGrant)
	local crate = StoreConfig.Crates[crateId]
	local profile = self.Profiles:Get(player)
	if not crate or not profile then
		return false
	end
	local result
	local ok = self.Profiles:Mutate(player, function(data)
		if not freeGrant and not self:Spend(data, crate.Currency, crate.Price) then
			return false
		end
		local pity = data.CratePity[crateId] or { Legendary = 0, Mythic = 0 }
		local entry = self:ChooseCrateItem(crate, pity)
		if not entry then
			return false
		end
		pity.Legendary += 1
		pity.Mythic += 1
		if entry.Rarity == "Legendary" or entry.Rarity == "Mythic" then
			pity.Legendary = 0
		end
		if entry.Rarity == "Mythic" then
			pity.Mythic = 0
		end
		data.CratePity[crateId] = pity
		local duplicate = data.Inventory[entry.ItemId] == true
		local duplicateRyo = 0
		local duplicateStyleTokens = 0
		if duplicate then
			duplicateRyo, duplicateStyleTokens = self:GrantDuplicate(data, entry.ItemId)
		else
			data.Inventory[entry.ItemId] = true
		end
		result = {
			CrateId = crateId,
			ItemId = entry.ItemId,
			Rarity = entry.Rarity,
			Duplicate = duplicate,
			DuplicateRyo = duplicateRyo,
			DuplicateStyleTokens = duplicateStyleTokens,
			Pity = table.clone(pity),
		}
		return true
	end)
	if not ok or not result then
		if not freeGrant then
			self:Notify(player, "Moeda insuficiente para abrir este baú.", "Error")
		end
		return false
	end
	self.Remotes.CrateResult:FireClient(player, result)
	self:PushState(player)
	return true
end

function EconomyService:BuyItem(player, itemId, currency)
	local offer = StoreConfig.Items[itemId]
	local item = LootConfig[itemId]
	local profile = self.Profiles:Get(player)
	local price = offer and offer[currency]
	if not offer or not item or not profile or not VALID_CURRENCIES[currency] or type(price) ~= "number" then
		return false
	end
	local purchased = false
	self.Profiles:Mutate(player, function(data)
		if data.Inventory[itemId] or not self:Spend(data, currency, price) then
			return
		end
		data.Inventory[itemId] = true
		purchased = true
	end)
	if not purchased then
		self:Notify(player, "Compra não concluída: confira o saldo ou o inventário.", "Error")
		return false
	end
	self:Notify(player, item.Name .. " foi adicionado ao inventário.")
	self:PushState(player)
	return true
end

function EconomyService:PromptRobux(player, kind, id)
	local productId = 0
	if kind == "Item" and StoreConfig.Items[id] then
		productId = StoreConfig.Items[id].ProductId
	elseif kind == "Crate" then
		self:Notify(player, "Baús só podem ser abertos com moedas conquistadas jogando.", "Error")
		return
	elseif kind == "Currency" and StoreConfig.CurrencyProducts[id] then
		productId = StoreConfig.CurrencyProducts[id].ProductId
	end
	if productId <= 0 or not self.ProductGrants[productId] then
		self:Notify(player, "Esta opção Robux ainda não foi configurada pelo criador.", "Error")
		return
	end
	MarketplaceService:PromptProductPurchase(player, productId)
end

function EconomyService:GrantProduct(player, purchaseId, productId)
	local grant = self.ProductGrants[productId]
	local profile = self.Profiles:Get(player)
	if not grant or not profile then
		return false
	end
	if profile.ProcessedReceipts[purchaseId] then
		-- Uma tentativa anterior pode ter alterado apenas a memória antes de uma
		-- falha de DataStore. Confirme a persistência antes de aceitar o recibo.
		return self.Profiles:Save(player)
	end
	local granted = false
	if grant.Kind == "Item" then
		self.Profiles:Mutate(player, function(data)
			if data.Inventory[grant.Id] then
				local offer = StoreConfig.Items[grant.Id]
				data.StyleTokens += math.max(1, math.floor((offer.StyleTokens or 1) * 0.5))
			else
				data.Inventory[grant.Id] = true
			end
			data.ProcessedReceipts[purchaseId] = os.time()
			granted = true
		end)
	elseif grant.Kind == "Currency" then
		local offer = StoreConfig.CurrencyProducts[grant.Id]
		self.Profiles:Mutate(player, function(data)
			data[offer.Currency] += offer.Amount
			data.ProcessedReceipts[purchaseId] = os.time()
			granted = true
		end)
	end
	if not granted then
		return false
	end
	-- O recibo só é confirmado depois de uma tentativa de persistência.
	return self.Profiles:Save(player)
end

function EconomyService:BeginReceipt(receiptInfo)
	local receiptKey = "Receipt_" .. tostring(receiptInfo.PurchaseId)
	local state
	local ok = pcall(function()
		state = self.ReceiptStore:UpdateAsync(receiptKey, function(existing)
			if type(existing) == "table" and existing.State == "Delivered" then
				return existing
			end
			return {
				State = "Pending",
				PlayerId = receiptInfo.PlayerId,
				ProductId = receiptInfo.ProductId,
				UpdatedAt = os.time(),
			}
		end)
	end)
	return ok, state
end

function EconomyService:FinishReceipt(receiptInfo)
	local receiptKey = "Receipt_" .. tostring(receiptInfo.PurchaseId)
	return pcall(function()
		self.ReceiptStore:UpdateAsync(receiptKey, function(existing)
			existing = type(existing) == "table" and existing or {}
			existing.State = "Delivered"
			existing.PlayerId = receiptInfo.PlayerId
			existing.ProductId = receiptInfo.ProductId
			existing.UpdatedAt = os.time()
			return existing
		end)
	end)
end

function EconomyService:Start()
	self.Remotes.ShopRequest.OnServerEvent:Connect(function(player, action, arg1, arg2)
		if not self:CanRequest(player) or type(action) ~= "string" then
			return
		end
		if action == "Get" then
			self:PushState(player)
		elseif action == "BuyItem" and type(arg1) == "string" and type(arg2) == "string" then
			self:BuyItem(player, arg1, arg2)
		elseif action == "OpenCrate" and type(arg1) == "string" then
			self:OpenCrate(player, arg1, false)
		elseif action == "PromptRobux" and type(arg1) == "table" then
			self:PromptRobux(player, arg1.Kind, arg1.Id)
		end
	end)
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local purchaseId = tostring(receiptInfo.PurchaseId)
		local began, receiptState = self:BeginReceipt(receiptInfo)
		if not began then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if receiptState.State == "Delivered" then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		if self:GrantProduct(player, purchaseId, receiptInfo.ProductId) then
			local finished = self:FinishReceipt(receiptInfo)
			if finished then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	Players.PlayerRemoving:Connect(function(player)
		self.RateLimits[player] = nil
		self.PolicyCache[player] = nil
	end)
end

return EconomyService
