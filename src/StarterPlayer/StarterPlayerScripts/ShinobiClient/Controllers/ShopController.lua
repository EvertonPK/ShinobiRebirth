local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ShopController = {}

local COLORS = {
	Backdrop = Color3.fromRGB(8, 10, 16),
	Panel = Color3.fromRGB(17, 20, 30),
	PanelLight = Color3.fromRGB(28, 33, 47),
	Card = Color3.fromRGB(35, 40, 56),
	Text = Color3.fromRGB(244, 242, 235),
	Muted = Color3.fromRGB(165, 170, 187),
	Accent = Color3.fromRGB(238, 137, 56),
	Soft = Color3.fromRGB(255, 204, 78),
	Robux = Color3.fromRGB(94, 210, 130),
	Rare = Color3.fromRGB(80, 145, 240),
	Epic = Color3.fromRGB(177, 85, 237),
	Legendary = Color3.fromRGB(255, 164, 54),
	Mythic = Color3.fromRGB(242, 72, 112),
}

local function create(className, properties, parent)
	local object = Instance.new(className)
	for key, value in properties do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function round(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function stroke(parent, color, transparency, thickness)
	return create("UIStroke", {
		Color = color or COLORS.Muted,
		Transparency = transparency or 0.55,
		Thickness = thickness or 1,
	}, parent)
end

local function label(parent, properties)
	properties.BackgroundTransparency = 1
	properties.TextColor3 = properties.TextColor3 or COLORS.Text
	properties.Font = properties.Font or Enum.Font.GothamMedium
	properties.TextSize = properties.TextSize or 13
	return create("TextLabel", properties, parent)
end

local function formatNumber(value)
	value = tonumber(value) or 0
	if value >= 1e9 then
		return string.format("%.1fB", value / 1e9)
	elseif value >= 1e6 then
		return string.format("%.1fM", value / 1e6)
	elseif value >= 1e3 then
		return string.format("%.1fK", value / 1e3)
	end
	return tostring(math.floor(value))
end

local function rarityColor(rarity)
	return COLORS[rarity or ""] or COLORS.Muted
end

local function previewPart(parent, name, size, cframe, color, material, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.Shape = shape or Enum.PartType.Block
	object.Anchored = true
	object.CanCollide = false
	object.Parent = parent
	return object
end

local function itemPreview(parent, entry, position, size, crate)
	local rarity = rarityColor(entry.Rarity or (crate and "Legendary") or "Common")
	local viewport = create("ViewportFrame", {
		Position = position,
		Size = size,
		BackgroundColor3 = Color3.fromRGB(14, 17, 26),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Ambient = Color3.fromRGB(180, 185, 205),
		LightColor = rarity,
		LightDirection = Vector3.new(-1, -1, -1),
		ZIndex = 14,
	}, parent)
	round(viewport, 10)
	stroke(viewport, rarity, 0.35, 1)
	local world = Instance.new("WorldModel")
	world.Parent = viewport
	local kind = tostring(entry.Type or "Cosmetic")
	if crate then
		previewPart(world, "Chest", Vector3.new(5.8, 3.4, 4.2), CFrame.new(0, -0.7, 0), Color3.fromRGB(89, 55, 34), Enum.Material.WoodPlanks)
		previewPart(world, "Lid", Vector3.new(6.1, 1.5, 4.5), CFrame.new(0, 1.65, 0), Color3.fromRGB(118, 74, 42), Enum.Material.WoodPlanks)
		previewPart(world, "Band", Vector3.new(1.1, 5.1, 4.7), CFrame.new(0, 0.25, 0), rarity, Enum.Material.Metal)
		previewPart(world, "Lock", Vector3.new(1.2, 1.3, 0.5), CFrame.new(0, 0.2, -2.3), rarity, Enum.Material.Neon)
	elseif kind == "WeaponSkin" then
		previewPart(world, "Handle", Vector3.new(0.7, 3.5, 0.7), CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, math.rad(-28)), Color3.fromRGB(45, 38, 36), Enum.Material.Wood)
		previewPart(world, "Blade", Vector3.new(0.65, 7, 1.1), CFrame.new(-1.25, 1.5, 0) * CFrame.Angles(0, 0, math.rad(-28)), rarity, Enum.Material.Metal)
		previewPart(world, "Edge", Vector3.new(0.16, 7.1, 1.15), CFrame.new(-1.54, 1.65, 0) * CFrame.Angles(0, 0, math.rad(-28)), Color3.fromRGB(235, 242, 255), Enum.Material.Neon)
	elseif kind == "Aura" then
		for index = 1, 3 do
			local orb = previewPart(world, "Aura", Vector3.new(1.5, 1.5, 1.5), CFrame.new(math.cos(index * 2.1) * 2.5, math.sin(index * 1.7) * 2.5, 0), rarity, Enum.Material.Neon, Enum.PartType.Ball)
			orb.Transparency = 0.12
		end
		previewPart(world, "Core", Vector3.new(3.5, 3.5, 3.5), CFrame.new(), rarity, Enum.Material.ForceField, Enum.PartType.Ball).Transparency = 0.35
	elseif kind == "Eyes" then
		previewPart(world, "Face", Vector3.new(6.2, 4.5, 1.5), CFrame.new(), Color3.fromRGB(218, 183, 156), Enum.Material.SmoothPlastic)
		for side = -1, 1, 2 do
			previewPart(world, "Eye", Vector3.new(1.4, 0.75, 0.25), CFrame.new(side * 1.65, 0.35, -0.88), rarity, Enum.Material.Neon, Enum.PartType.Ball)
		end
	else
		previewPart(world, "Torso", Vector3.new(4.6, 5.2, 2.2), CFrame.new(0, -1, 0), rarity, Enum.Material.Fabric)
		previewPart(world, "Head", Vector3.new(2.8, 2.8, 2.8), CFrame.new(0, 3.1, 0), Color3.fromRGB(218, 183, 156), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		previewPart(world, "Accent", Vector3.new(5.1, 1.1, 2.5), CFrame.new(0, 0.1, 0), Color3.fromRGB(28, 31, 42), Enum.Material.Metal)
	end
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(10, 6, 13), Vector3.new(0, 0.5, 0))
	camera.FieldOfView = 36
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return viewport
end

local function chanceText(chance)
	chance = tonumber(chance)
	if not chance then
		return ""
	end
	if chance <= 1 then
		chance *= 100
	end
	if chance < 0.1 then
		return string.format("%.3f%%", chance)
	elseif chance < 1 then
		return string.format("%.2f%%", chance)
	end
	return string.format("%.1f%%", chance)
end

local function moduleData(folder, name)
	local module = folder:FindFirstChild(name)
	if not module or not module:IsA("ModuleScript") then
		return nil
	end
	local ok, result = pcall(require, module)
	return ok and result or nil
end

local function arrayFromMap(source)
	local result = {}
	for id, value in source or {} do
		if type(value) == "table" then
			local copy = table.clone(value)
			copy.Id = copy.Id or id
			table.insert(result, copy)
		end
	end
	table.sort(result, function(a, b)
		local orderA = a.Order or a.SortOrder or 999
		local orderB = b.Order or b.SortOrder or 999
		if orderA == orderB then
			return tostring(a.Name or a.Id or "") < tostring(b.Name or b.Id or "")
		end
		return orderA < orderB
	end)
	return result
end

function ShopController:Init(context)
	self.Player = Players.LocalPlayer
	self.Remotes = context.Remotes
	self.Shared = context.Shared
	self.Profile = nil
	self.ShopState = {}
	self.EventState = {}
	self.CurrentTab = "Featured"
	self.Config = moduleData(self.Shared, "StoreConfig") or moduleData(self.Shared, "ShopConfig") or moduleData(self.Shared, "EconomyConfig") or {}
	self.LiveOpsConfig = moduleData(self.Shared, "LiveOpsConfig") or moduleData(self.Shared, "DailyEventConfig") or {}
	self.LootConfig = moduleData(self.Shared, "LootConfig") or {}
end

function ShopController:Remote(name)
	return self.Remotes:FindFirstChild(name)
end

function ShopController:Toast(text, color)
	if not self.Gui then
		return
	end
	local toast = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = UDim2.new(0.8, 0, 0, 44),
		BackgroundColor3 = color or COLORS.PanelLight,
		BackgroundTransparency = 1,
		Text = tostring(text),
		TextColor3 = COLORS.Text,
		TextTransparency = 1,
		TextWrapped = true,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		ZIndex = 100,
	}, self.Gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(560, 44), MinSize = Vector2.new(260, 44) }, toast)
	round(toast, 10)
	TweenService:Create(toast, TweenInfo.new(0.18), { BackgroundTransparency = 0.06, TextTransparency = 0 }):Play()
	task.delay(3, function()
		if not toast.Parent then
			return
		end
		local tween = TweenService:Create(toast, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		toast:Destroy()
	end)
end

function ShopController:Build()
	local gui = create("ScreenGui", {
		Name = "ShinobiShop",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 20,
	}, self.Player:WaitForChild("PlayerGui"))
	self.Gui = gui

	local openButton = create("TextButton", {
		Name = "OpenShop",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(112, 48),
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		Text = "LOJA",
		TextColor3 = Color3.fromRGB(24, 18, 14),
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		Selectable = true,
		ZIndex = 2,
	}, gui)
	round(openButton, 12)
	stroke(openButton, Color3.fromRGB(255, 211, 141), 0.35, 2)
	self.OpenButton = openButton

	local backdrop = create("TextButton", {
		Name = "Backdrop",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = COLORS.Backdrop,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 10,
	}, gui)
	self.Backdrop = backdrop

	local window = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.86),
		BackgroundColor3 = COLORS.Panel,
		BorderSizePixel = 0,
		ZIndex = 11,
	}, backdrop)
	create("UISizeConstraint", { MaxSize = Vector2.new(1050, 720), MinSize = Vector2.new(300, 300) }, window)
	round(window, 16)
	stroke(window, Color3.fromRGB(118, 126, 157), 0.25, 1.5)
	self.Window = window

	label(window, {
		Position = UDim2.fromOffset(22, 14),
		Size = UDim2.new(0.5, 0, 0, 34),
		Text = "MERCADO SHINOBI",
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 12,
	})
	self.Currency = label(window, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -66, 0, 18),
		Size = UDim2.new(0.45, 0, 0, 26),
		Text = "0 RYO  |  0 GEMAS  |  0 TICKETS",
		TextColor3 = COLORS.Soft,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 12,
	})
	local close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 13),
		Size = UDim2.fromOffset(38, 36),
		BackgroundColor3 = COLORS.PanelLight,
		BorderSizePixel = 0,
		Text = "X",
		TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Selectable = true,
		ZIndex = 13,
	}, window)
	round(close, 9)
	self.CloseButton = close

	local tabs = create("Frame", {
		Position = UDim2.fromOffset(18, 60),
		Size = UDim2.new(1, -36, 0, 42),
		BackgroundTransparency = 1,
		ZIndex = 12,
	}, window)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabs)
	self.TabButtons = {}
	for order, definition in {
		{ Id = "Featured", Name = "DESTAQUES" },
		{ Id = "Crates", Name = "CAIXAS" },
		{ Id = "Events", Name = "EVENTOS" },
		{ Id = "Inventory", Name = "INVENTARIO" },
	} do
		local button = create("TextButton", {
			Name = definition.Id,
			Size = UDim2.new(0.25, -6, 1, 0),
			BackgroundColor3 = COLORS.PanelLight,
			BorderSizePixel = 0,
			Text = definition.Name,
			TextColor3 = COLORS.Muted,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			LayoutOrder = order,
			Selectable = true,
			ZIndex = 13,
		}, tabs)
		round(button, 9)
		button.Activated:Connect(function()
			self:SetTab(definition.Id)
		end)
		self.TabButtons[definition.Id] = button
	end

	local body = create("ScrollingFrame", {
		Name = "Content",
		Position = UDim2.fromOffset(18, 114),
		Size = UDim2.new(1, -36, 1, -132),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = COLORS.Accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ZIndex = 12,
	}, window)
	self.Body = body

	openButton.Activated:Connect(function()
		self:Open()
	end)
	close.Activated:Connect(function()
		self:Close()
	end)
	backdrop.Activated:Connect(function()
		self:Close()
	end)
end

function ShopController:ClearBody(layoutKind)
	for _, child in self.Body:GetChildren() do
		child:Destroy()
	end
	self.Body.CanvasPosition = Vector2.zero
	if layoutKind == "Grid" then
		create("UIGridLayout", {
			CellSize = UDim2.fromOffset(238, 188),
			CellPadding = UDim2.fromOffset(12, 12),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, self.Body)
	else
		create("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, self.Body)
	end
end

function ShopController:Catalog()
	local store = self.ShopState.Store or {}
	local catalog = store.Items or self.ShopState.Catalog or self.Config.Catalog or self.Config.Items
	if catalog then
		local normalized = {}
		if #catalog > 0 then
			for _, offer in catalog do
				if type(offer) == "table" then
					table.insert(normalized, table.clone(offer))
				end
			end
		else
			normalized = arrayFromMap(catalog)
		end
		for _, offer in normalized do
			local item = self.LootConfig[offer.Id]
			if item then
				offer.Name = item.Name
				offer.Description = item.Description or item.Type
				offer.Type = item.Type
				offer.Rarity = item.Rarity
			end
			offer.Price = offer.Price or offer.Ryo
			offer.Currency = offer.Currency or (offer.Ryo and "Ryo") or (offer.Gems and "Gems") or (offer.StyleTokens and "StyleTokens")
			offer.RobuxPrice = offer.RobuxEnabled and offer.RobuxPrice or nil
		end
		return normalized
	end
	local fallback = {}
	for _, item in arrayFromMap(self.LootConfig) do
		if item.Type ~= "Material" then
			item.Price = item.Price or item.SoftPrice
			table.insert(fallback, item)
		end
	end
	return fallback
end

function ShopController:Crates()
	local store = self.ShopState.Store or {}
	local crates = store.Crates or self.ShopState.Crates or self.Config.Crates or {}
	return #crates > 0 and crates or arrayFromMap(crates)
end

function ShopController:SoftBuy(kind, id, currency)
	-- O servidor concentra compras diretas e abertura de baús no mesmo remote.
	-- Manter esse caminho único evita que o botão de baú dependa de um RemoteEvent
	-- inexistente em uma build limpa.
	local remote = self:Remote("ShopRequest")
	if not remote then
		self:Toast("A loja ainda esta sincronizando com o servidor.")
		return
	end
	if kind == "Crate" then
		remote:FireServer("OpenCrate", id)
	else
		remote:FireServer("BuyItem", id, currency or "Ryo")
	end
end

function ShopController:RobuxBuy(entry)
	local remote = self:Remote("ShopRequest")
	if remote and entry.Id then
		remote:FireServer("PromptRobux", { Kind = "Item", Id = entry.Id })
		return
	end
	local productId = tonumber(entry.ProductId or entry.DeveloperProductId)
	local passId = tonumber(entry.GamePassId)
	if productId and productId > 0 then
		MarketplaceService:PromptProductPurchase(self.Player, productId)
	elseif passId and passId > 0 then
		MarketplaceService:PromptGamePassPurchase(self.Player, passId)
	else
		self:Toast("Compra em Robux aguardando o ID oficial do produto.")
	end
end

function ShopController:PriceButton(parent, text, color, callback, order)
	local button = create("TextButton", {
		Size = UDim2.new(0.5, -5, 0, 34),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = Color3.fromRGB(20, 22, 27),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		LayoutOrder = order or 1,
		Selectable = true,
		ZIndex = 15,
	}, parent)
	round(button, 7)
	button.Activated:Connect(callback)
	return button
end

function ShopController:ItemCard(entry, order)
	local rarity = entry.Rarity or "Common"
	local card = create("Frame", {
		BackgroundColor3 = COLORS.Card,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		LayoutOrder = order,
		ZIndex = 13,
	}, self.Body)
	round(card, 12)
	stroke(card, rarityColor(rarity), 0.25, 1.5)
	label(card, {
		Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 24),
		Text = string.upper(entry.Name or entry.Id or "ITEM"), Font = Enum.Font.GothamBold,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	})
	label(card, {
		Position = UDim2.fromOffset(12, 35), Size = UDim2.new(1, -24, 0, 18),
		Text = string.upper(rarity), TextColor3 = rarityColor(rarity), Font = Enum.Font.GothamBold,
		TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	})
	local description = entry.Description or entry.Type or "Cosmetico colecionavel"
	label(card, {
		Position = UDim2.fromOffset(12, 58), Size = UDim2.new(1, -116, 0, 64),
		Text = description, TextColor3 = COLORS.Muted, TextWrapped = true,
		TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 14,
	})
	itemPreview(card, entry, UDim2.new(1, -100, 0, 54), UDim2.fromOffset(88, 82), false)
	local buttons = create("Frame", {
		Position = UDim2.new(0, 10, 1, -46), Size = UDim2.new(1, -20, 0, 34),
		BackgroundTransparency = 1, ZIndex = 14,
	}, card)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
	}, buttons)
	local currency = entry.Currency or "Ryo"
	local price = entry.Price or entry.SoftPrice or entry.RyoPrice or entry.GemPrice
	if price then
		self:PriceButton(buttons, formatNumber(price) .. " " .. string.upper(currency), COLORS.Soft, function()
			self:SoftBuy("Item", entry.Id, currency)
		end, 1)
	end
	local robuxPrice = entry.RobuxPrice or entry.Robux
	if robuxPrice or entry.ProductId or entry.GamePassId or entry.RobuxEnabled then
		self:PriceButton(buttons, robuxPrice and (formatNumber(robuxPrice) .. " ROBUX") or "COMPRAR ROBUX", COLORS.Robux, function()
			self:RobuxBuy(entry)
		end, 2)
	end
	if not price and not robuxPrice and not entry.ProductId and not entry.GamePassId then
		label(buttons, {
			Size = UDim2.fromScale(1, 1), Text = "OBTIDO JOGANDO", TextColor3 = COLORS.Robux,
			Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 15,
		})
	end
	return card
end

function ShopController:RenderFeatured()
	self:ClearBody("Grid")
	local catalog = self:Catalog()
	if #catalog == 0 then
		self:Empty("O catalogo sera exibido quando o servidor concluir a sincronizacao.")
		return
	end
	for index, entry in catalog do
		self:ItemCard(entry, index)
	end
end

function ShopController:CrateCard(crate, order)
	local card = create("Frame", {
		BackgroundColor3 = COLORS.Card, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 13,
	}, self.Body)
	round(card, 12)
	stroke(card, rarityColor(crate.Rarity or "Legendary"), 0.3, 1.5)
	label(card, {
		Position = UDim2.fromOffset(12, 9), Size = UDim2.new(1, -24, 0, 24),
		Text = string.upper(crate.Name or crate.Id or "CAIXA"), Font = Enum.Font.GothamBold,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	})
	local pity = self.ShopState.CratePity and self.ShopState.CratePity[crate.Id]
	local pityText = "CHANCES PUBLICAS"
	if type(pity) == "table" then
		pityText = string.format("PITY LENDARIO %d/%d  |  MITICO %d/%d", pity.Legendary or 0, crate.LegendaryPity or 0, pity.Mythic or 0, crate.MythicPity or 0)
	end
	label(card, {
		Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 18),
		Text = pityText,
		TextColor3 = COLORS.Legendary, Font = Enum.Font.GothamBold, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	})
	local lines = {}
	local drops = crate.Drops or crate.Contents or crate.Pool or {}
	if #drops == 0 then
		drops = arrayFromMap(drops)
	end
	local odds = crate.Odds or {}
	local oddsLines = {}
	for rarity, chance in odds do
		table.insert(oddsLines, { Rarity = rarity, Chance = chance })
	end
	table.sort(oddsLines, function(a, b)
		return a.Chance > b.Chance
	end)
	for index, oddsEntry in oddsLines do
		if index > 4 then
			break
		end
		table.insert(lines, string.format("%s  %s", string.upper(oddsEntry.Rarity), chanceText(oddsEntry.Chance)))
	end
	if #lines == 0 then
		for index, drop in drops do
			if index > 4 then
				table.insert(lines, "+ mais recompensas")
				break
			end
			local item = self.LootConfig[drop.ItemId or drop.Id]
			table.insert(lines, string.format("%s  %s", item and item.Name or drop.ItemId or drop.Id or "Item", string.upper(drop.Rarity or "")))
		end
	end
	label(card, {
		Position = UDim2.fromOffset(12, 58), Size = UDim2.new(1, -112, 0, 70),
		Text = #lines > 0 and table.concat(lines, "\n") or "As chances aparecerao antes da abertura.",
		TextColor3 = COLORS.Muted, TextSize = 10, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 14,
	})
	itemPreview(card, crate, UDim2.new(1, -98, 0, 52), UDim2.fromOffset(86, 80), true)
	local buttons = create("Frame", {
		Position = UDim2.new(0, 10, 1, -46), Size = UDim2.new(1, -20, 0, 34), BackgroundTransparency = 1, ZIndex = 14,
	}, card)
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, buttons)
	local softPrice = crate.Price or crate.SoftPrice or crate.RyoPrice
	local currency = crate.Currency or "Ryo"
	if softPrice then
		self:PriceButton(buttons, formatNumber(softPrice) .. " " .. string.upper(currency), COLORS.Soft, function()
			self:SoftBuy("Crate", crate.Id, currency)
		end, 1)
	end
	label(buttons, {
		Size = UDim2.new(0.5, -5, 1, 0), Text = "SEM CAIXA POR ROBUX", TextColor3 = COLORS.Robux,
		Font = Enum.Font.GothamBold, TextSize = 9, LayoutOrder = 2, ZIndex = 15,
	})
end

function ShopController:RenderCrates()
	self:ClearBody("Grid")
	local crates = self:Crates()
	if #crates == 0 then
		self:Empty("Caixas justas usam moeda conquistada no jogo, chances visiveis e pity garantido.")
		return
	end
	for index, crate in crates do
		self:CrateCard(crate, index)
	end
end

function ShopController:EventRow(event, order)
	local row = create("Frame", {
		Size = UDim2.new(1, -8, 0, 92), BackgroundColor3 = COLORS.Card,
		BorderSizePixel = 0, LayoutOrder = order, ZIndex = 13,
	}, self.Body)
	round(row, 11)
	stroke(row, event.Color or COLORS.Epic, 0.4)
	label(row, {
		Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -150, 0, 23),
		Text = string.upper(event.Name or event.Id or "EVENTO"), Font = Enum.Font.GothamBold,
		TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
	})
	local progress = event.Progress or 0
	local goal = event.Goal or event.Target or 1
	label(row, {
		Position = UDim2.fromOffset(14, 36), Size = UDim2.new(1, -150, 0, 40),
		Text = string.format("%s\nProgresso: %s/%s", event.Description or event.RewardText or "Recompensas gratuitas por participacao", formatNumber(progress), formatNumber(goal)),
		TextColor3 = COLORS.Muted, TextWrapped = true, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 14,
	})
	local canClaim = event.CanClaim
	if canClaim == nil then
		canClaim = progress >= goal and not event.Claimed
	end
	local buttonText = event.ActionText or (event.Claimed and "RESGATADO" or (canClaim and "RESGATAR" or "EM PROGRESSO"))
	local claim = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(118, 38),
		BackgroundColor3 = canClaim and COLORS.Robux or COLORS.PanelLight,
		BorderSizePixel = 0, Text = buttonText,
		TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 10,
		Selectable = canClaim, AutoButtonColor = canClaim, ZIndex = 14,
	}, row)
	round(claim, 8)
	if canClaim then
		claim.Activated:Connect(function()
			local remote = self:Remote("LiveOpsRequest") or self:Remote("EventRequest") or self:Remote("DailyEventRequest")
			if remote then
				remote:FireServer(event.Action or "Claim", event.ActionArg or event.Id or order)
			else
				self:Toast("O evento ainda esta sincronizando.")
			end
		end)
	end
end

function ShopController:RenderEvents()
	self:ClearBody("List")
	local events = {}
	local calendar = self.EventState.Calendar
	if calendar and calendar.Daily then
		table.insert(events, {
			Id = calendar.Daily.Id,
			Name = "Evento diario: " .. (calendar.Daily.Name or "Evento"),
			Description = calendar.Daily.Description or "Bonus global ativo durante o dia.",
			Goal = 1, Progress = 0, ActionText = "ATIVO", CanClaim = false,
		})
	end
	if calendar and calendar.Flash then
		table.insert(events, {
			Id = calendar.Flash.Id,
			Name = "Evento relampago: " .. (calendar.Flash.Name or "Evento"),
			Description = "Bonus temporario de servidor ativo agora.",
			Goal = 1, Progress = 0, ActionText = "ATIVO", CanClaim = false,
		})
	end
	local login = self.EventState.Login
	if login then
		local reward = login.NextReward or {}
		local rewardParts = {}
		for currency, amount in reward do
			table.insert(rewardParts, formatNumber(amount) .. " " .. string.upper(currency))
		end
		table.insert(events, {
			Id = "DailyLogin",
			Name = "Recompensa diaria - sequencia " .. (login.Streak or 0),
			Description = #rewardParts > 0 and table.concat(rewardParts, " + ") or "Volte todos os dias para manter a sequencia.",
			Goal = 1, Progress = login.CanClaim and 1 or 0, Claimed = not login.CanClaim,
			CanClaim = login.CanClaim, Action = "ClaimLogin", ActionText = login.CanClaim and "RESGATAR" or "AGUARDE",
		})
	end
	for index, weekly in self.EventState.Weekly or {} do
		table.insert(events, {
			Id = weekly.Id,
			Name = "Semanal: " .. (weekly.Name or weekly.Id),
			Description = weekly.RewardText or "Progresso semanal gratuito",
			Goal = weekly.Goal, Progress = weekly.Progress, Claimed = weekly.Claimed,
			Action = "ClaimWeekly", ActionArg = weekly.Index or index,
		})
	end
	local season = self.EventState.Season
	if season and season.Level and season.Level > 0 then
		local nextClaim = season.NextClaimableLevel or 1
		if not season.NextClaimableLevel then
			for level = 1, season.Level do
				local claimed = season.Claimed and (season.Claimed[tostring(level)] == true or season.Claimed[level] == true)
				if not claimed then
					nextClaim = level
					break
				end
			end
		end
		local levelClaimed = season.Claimed
			and (season.Claimed[tostring(nextClaim)] == true or season.Claimed[nextClaim] == true)
		table.insert(events, {
			Id = "Season" .. nextClaim,
			Name = string.format("Temporada %s - nivel %d/%d", season.Id or "atual", season.Level, season.MaxLevel or 30),
			Description = string.format(
				"%d pontos de temporada. Próxima recompensa: %s",
				season.Points or 0,
				season.NextRewardText or "trilha gratuita para todos"
			),
			Goal = 1, Progress = 1, Claimed = levelClaimed == true,
			Action = "ClaimSeason", ActionArg = nextClaim,
		})
	end
	if #events == 0 then
		events = self.EventState.Events or self.EventState.Objectives or self.LiveOpsConfig.Events or {}
	end
	if #events == 0 then
		events = arrayFromMap(events)
	end
	if #events == 0 and self.Profile and self.Profile.Quests then
		events = self.Profile.Quests.Daily or {}
	end
	if #events == 0 then
		self:Empty("Eventos diarios, semanais e de servidor aparecerao aqui.")
		return
	end
	for index, event in events do
		self:EventRow(event, index)
	end
end

function ShopController:RenderInventory()
	self:ClearBody("Grid")
	local inventory = self.Profile and self.Profile.Inventory or {}
	local entries = {}
	for id, owned in inventory do
		if owned then
			local definition = self.LootConfig[id] or { Id = id, Name = id, Type = "Item" }
			local copy = table.clone(definition)
			copy.Id = copy.Id or id
			table.insert(entries, copy)
		end
	end
	if #entries == 0 then
		self:Empty("Jogue eventos e derrote chefes para montar sua colecao.")
		return
	end
	for index, entry in entries do
		local card = self:ItemCard(entry, index)
		local equipped = self.Profile.Equipped and self.Profile.Equipped[entry.Type] == entry.Id
		local button = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(78, 24),
			BackgroundColor3 = equipped and COLORS.Robux or COLORS.PanelLight, BorderSizePixel = 0,
			Text = equipped and "EQUIPADO" or "EQUIPAR", TextColor3 = COLORS.Text,
			Font = Enum.Font.GothamBold, TextSize = 9, Selectable = true, ZIndex = 16,
		}, card)
		round(button, 6)
		if not equipped then
			button.Activated:Connect(function()
				local remote = self:Remote("EquipRequest")
				if remote then
					remote:FireServer(entry.Id)
				end
			end)
		end
	end
end

function ShopController:Empty(text)
	label(self.Body, {
		Size = UDim2.new(1, -20, 0, 100), Text = text, TextColor3 = COLORS.Muted,
		TextWrapped = true, Font = Enum.Font.GothamMedium, TextSize = 14, ZIndex = 13,
	})
end

function ShopController:Render()
	if self.CurrentTab == "Featured" then
		self:RenderFeatured()
	elseif self.CurrentTab == "Crates" then
		self:RenderCrates()
	elseif self.CurrentTab == "Events" then
		self:RenderEvents()
	else
		self:RenderInventory()
	end
end

function ShopController:SetTab(tab)
	self.CurrentTab = tab
	for id, button in self.TabButtons do
		local selected = id == tab
		button.BackgroundColor3 = selected and COLORS.Accent or COLORS.PanelLight
		button.TextColor3 = selected and Color3.fromRGB(25, 20, 15) or COLORS.Muted
	end
	self:Render()
end

function ShopController:UpdateCurrency()
	local profile = self.Profile or {}
	local currencies = self.ShopState.Currencies or profile
	self.Currency.Text = string.format(
		"%s RYO  |  %s GEMAS  |  %s TICKETS  |  %s ESTILO",
		formatNumber(currencies.Ryo),
		formatNumber(currencies.Gems),
		formatNumber(currencies.EventTickets or currencies.Tickets),
		formatNumber(currencies.StyleTokens)
	)
end

function ShopController:Open()
	if self.Backdrop.Visible then
		return
	end
	self.Backdrop.Visible = true
	self.Window.Size = UDim2.fromScale(0.86, 0.78)
	self.Window.BackgroundTransparency = 0.15
	TweenService:Create(self.Window, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(0.92, 0.86), BackgroundTransparency = 0,
	}):Play()
	TweenService:Create(self.Backdrop, TweenInfo.new(0.16), { BackgroundTransparency = 0.25 }):Play()
	self:UpdateCurrency()
	self:SetTab(self.CurrentTab)
	local shopRemote = self:Remote("ShopRequest")
	if shopRemote then
		shopRemote:FireServer("Get")
	end
	local eventRemote = self:Remote("LiveOpsRequest") or self:Remote("EventRequest") or self:Remote("DailyEventRequest")
	if eventRemote then
		eventRemote:FireServer(self:Remote("LiveOpsRequest") and "Get" or "GetState")
	end
	if UserInputService.GamepadEnabled then
		GuiService.SelectedObject = self.TabButtons[self.CurrentTab]
	end
end

function ShopController:Close()
	if not self.Backdrop.Visible then
		return
	end
	GuiService.SelectedObject = nil
	local tween = TweenService:Create(self.Window, TweenInfo.new(0.14), {
		Size = UDim2.fromScale(0.86, 0.78), BackgroundTransparency = 0.2,
	})
	tween:Play()
	TweenService:Create(self.Backdrop, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
	tween.Completed:Once(function()
		self.Backdrop.Visible = false
	end)
end

function ShopController:Start()
	self:Build()
	self:SetTab("Featured")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self.Backdrop.Visible then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			self:Close()
		end
	end)
	local profileUpdate = self:Remote("ProfileUpdate")
	if profileUpdate then
		profileUpdate.OnClientEvent:Connect(function(profile)
			self.Profile = profile
			self:UpdateCurrency()
			if self.Backdrop.Visible then
				self:Render()
			end
		end)
	end
	local shopState = self:Remote("ShopState")
	if shopState then
		shopState.OnClientEvent:Connect(function(state)
			if type(state) == "table" then
				self.ShopState = state
				self:UpdateCurrency()
				if state.Message then
					self:Toast(state.Message, state.Success == false and COLORS.Mythic or COLORS.PanelLight)
				end
				if self.Backdrop.Visible then
					self:Render()
				end
			end
		end)
	end
	local crateResult = self:Remote("CrateResult")
	if crateResult then
		crateResult.OnClientEvent:Connect(function(result)
			if type(result) ~= "table" then
				return
			end
			local item = self.LootConfig[result.ItemId]
			local text = string.format("Voce encontrou: %s [%s]", item and item.Name or result.ItemId or "Item", result.Rarity or "")
			if result.Duplicate then
				text ..= " - duplicata: " .. formatNumber(result.DuplicateRyo) .. " Ryo + " .. formatNumber(result.DuplicateStyleTokens) .. " Estilo"
			end
			self:Toast(text, rarityColor(result.Rarity))
			if self.Backdrop.Visible and self.CurrentTab == "Crates" then
				self:RenderCrates()
			end
		end)
	end
	local worldAction = self:Remote("WorldAction")
	if worldAction then
		worldAction.OnClientEvent:Connect(function(action, tab)
			if action == "Shop" then
				self.CurrentTab = tab or "Featured"
				self:Open()
			end
		end)
	end
	for _, remoteName in { "LiveOpsState", "EventState", "DailyEventState" } do
		local remote = self:Remote(remoteName)
		if remote then
			remote.OnClientEvent:Connect(function(state)
				if type(state) == "table" then
					self.EventState = state
					if self.Backdrop.Visible and self.CurrentTab == "Events" then
						self:RenderEvents()
					end
				end
			end)
		end
	end
	local ok, profile = pcall(function()
		local remote = self:Remote("GetInitialState")
		return remote and remote:InvokeServer()
	end)
	if ok and profile then
		self.Profile = profile
		self:UpdateCurrency()
	end
end

return ShopController
