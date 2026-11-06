local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local HudController = {}

local COLORS = {
	Panel = Color3.fromRGB(18, 20, 29),
	PanelLight = Color3.fromRGB(31, 35, 48),
	Text = Color3.fromRGB(241, 239, 232),
	Muted = Color3.fromRGB(158, 163, 179),
	Accent = Color3.fromRGB(238, 139, 62),
	Health = Color3.fromRGB(214, 58, 69),
	XP = Color3.fromRGB(96, 159, 242),
}

local function create(className, props, parent)
	local object = Instance.new(className)
	for key, value in props do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function round(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function stroke(parent, color, transparency)
	return create("UIStroke", { Color = color, Transparency = transparency or 0.5, Thickness = 1 }, parent)
end

local function label(parent, props)
	props.BackgroundTransparency = 1
	props.TextColor3 = props.TextColor3 or COLORS.Text
	props.Font = props.Font or Enum.Font.GothamMedium
	props.TextSize = props.TextSize or 14
	return create("TextLabel", props, parent)
end

local function bar(parent, position, size, color)
	local back = create("Frame", {
		Position = position,
		Size = size,
		BackgroundColor3 = Color3.fromRGB(9, 11, 16),
		BorderSizePixel = 0,
	}, parent)
	round(back, 6)
	local fill = create("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
	}, back)
	round(fill, 6)
	return fill
end

function HudController:Init(context)
	self.Remotes = context.Remotes
	self.Shared = context.Shared
	self.LootConfig = require(context.Shared:WaitForChild("LootConfig"))
	self.Player = Players.LocalPlayer
	self.Profile = nil
end

function HudController:Remote(name)
	return self.Remotes:FindFirstChild(name)
end

function HudController:Build()
	local gui = create("ScreenGui", {
		Name = "ShinobiHUD",
		IgnoreGuiInset = false,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, self.Player:WaitForChild("PlayerGui"))
	self.Gui = gui

	local profile = create("Frame", {
		Name = "Profile",
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(1, -40, 0, 116),
		BackgroundColor3 = COLORS.Panel,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(315, 116), MinSize = Vector2.new(220, 116) }, profile)
	round(profile, 14)
	stroke(profile, Color3.fromRGB(95, 101, 124), 0.35)
	self.Rank = label(profile, {
		Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 24),
		Text = "ACADEMY • NÍVEL 1", Font = Enum.Font.GothamBold, TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	self.HealthFill = bar(profile, UDim2.fromOffset(16, 45), UDim2.new(1, -32, 0, 15), COLORS.Health)
	self.XPFill = bar(profile, UDim2.fromOffset(16, 68), UDim2.new(1, -32, 0, 11), COLORS.XP)
	self.Currency = label(profile, {
		Position = UDim2.fromOffset(16, 87), Size = UDim2.new(1, -32, 0, 18),
		Text = "0 RYO   •   0 ESSÊNCIA", TextColor3 = COLORS.Muted, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local boss = create("Frame", {
		Name = "Boss",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 22),
		Size = UDim2.new(0.88, 0, 0, 86),
		BackgroundColor3 = COLORS.Panel,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Visible = false,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(760, 86), MinSize = Vector2.new(280, 86) }, boss)
	round(boss, 14)
	stroke(boss, Color3.fromRGB(140, 80, 155), 0.2)
	self.BossFrame = boss
	self.BossName = label(boss, {
		Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -36, 0, 22),
		Text = "CHEFE", Font = Enum.Font.GothamBold, TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	self.BossSubtitle = label(boss, {
		Position = UDim2.fromOffset(18, 31), Size = UDim2.new(1, -36, 0, 16),
		Text = "", TextColor3 = COLORS.Muted, TextSize = 11,
	})
	self.BossFill = bar(boss, UDim2.fromOffset(18, 57), UDim2.new(1, -36, 0, 15), Color3.fromRGB(178, 54, 198))

	local notificationRoot = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -22),
		Size = UDim2.new(1, -40, 0, 260),
		BackgroundTransparency = 1,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(380, 260), MinSize = Vector2.new(220, 260) }, notificationRoot)
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, notificationRoot)
	self.NotificationRoot = notificationRoot

	local clanButton = create("TextButton", {
		Name = "ClanButton",
		Position = UDim2.fromOffset(20, 148),
		Size = UDim2.new(1, -40, 0, 48),
		BackgroundColor3 = COLORS.Panel,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Text = "ESCOLHA SEU CLÃ",
		TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(315, 48), MinSize = Vector2.new(220, 48) }, clanButton)
	round(clanButton, 12)
	stroke(clanButton, Color3.fromRGB(95, 101, 124), 0.35)
	self.ClanButton = clanButton

	local modal = create("Frame", {
		Name = "ClanModal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.9, 0.72),
		BackgroundColor3 = COLORS.Panel,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(560, 410), MinSize = Vector2.new(300, 310) }, modal)
	round(modal, 16)
	stroke(modal, Color3.fromRGB(130, 135, 160), 0.2)
	label(modal, {
		Position = UDim2.fromOffset(20, 16), Size = UDim2.new(1, -80, 0, 30),
		Text = "GUERRA DOS CLÃS", Font = Enum.Font.GothamBold, TextSize = 22, ZIndex = 21,
	})
	local clanClose = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12), Size = UDim2.fromOffset(38, 34),
		BackgroundColor3 = COLORS.PanelLight, BorderSizePixel = 0, Text = "×", TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold, TextSize = 22, Selectable = true, ZIndex = 22,
	}, modal)
	round(clanClose, 9)
	local list = create("ScrollingFrame", {
		Position = UDim2.fromOffset(20, 62), Size = UDim2.new(1, -40, 1, -82),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 21,
	}, modal)
	create("UIGridLayout", {
		CellSize = UDim2.new(0.5, -6, 0, 150),
		CellPadding = UDim2.fromOffset(12, 12),
		SortOrder = Enum.SortOrder.Name,
	}, list)
	self.ClanModal = modal
	self.ClanList = list
	self.ClanClose = clanClose
	clanButton.Activated:Connect(function()
		modal.Visible = not modal.Visible
		if modal.Visible then
			local remote = self:Remote("ClanRequest")
			if remote then
				remote:FireServer("Get")
			end
			if UserInputService.GamepadEnabled then
				GuiService.SelectedObject = clanClose
			end
		end
	end)
	clanClose.Activated:Connect(function()
		modal.Visible = false
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(modal) then
			GuiService.SelectedObject = clanButton
		end
	end)

	local progressButton = create("TextButton", {
		Name = "ProgressButton",
		Position = UDim2.fromOffset(20, 208),
		Size = UDim2.new(1, -40, 0, 48),
		BackgroundColor3 = COLORS.Panel,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Text = "PROGRESSÃO  •  MISSÕES  •  INVENTÁRIO",
		TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(315, 48), MinSize = Vector2.new(220, 48) }, progressButton)
	round(progressButton, 12)
	stroke(progressButton, Color3.fromRGB(95, 101, 124), 0.35)

	local progressModal = create("Frame", {
		Name = "ProgressModal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.92, 0.86),
		BackgroundColor3 = COLORS.Panel,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 30,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(620, 520), MinSize = Vector2.new(310, 360) }, progressModal)
	round(progressModal, 16)
	stroke(progressModal, Color3.fromRGB(130, 135, 160), 0.2)
	label(progressModal, {
		Position = UDim2.fromOffset(20, 14), Size = UDim2.new(1, -80, 0, 32),
		Text = "CAMINHO DO SHINOBI", Font = Enum.Font.GothamBold, TextSize = 21,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 31,
	})
	local close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12), Size = UDim2.fromOffset(38, 34),
		BackgroundColor3 = COLORS.PanelLight, BorderSizePixel = 0, Text = "×", TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold, TextSize = 22, ZIndex = 31,
	}, progressModal)
	round(close, 9)
	local scroll = create("ScrollingFrame", {
		Position = UDim2.fromOffset(18, 58), Size = UDim2.new(1, -36, 1, -76),
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ZIndex = 31,
	}, progressModal)
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	self.ProgressModal = progressModal
	self.ProgressBody = scroll
	self.ProgressButton = progressButton
	self.ProgressClose = close
	progressButton.Activated:Connect(function()
		progressModal.Visible = not progressModal.Visible
		if progressModal.Visible and self.Profile then
			self:RenderProgression(self.Profile)
		end
		if progressModal.Visible and UserInputService.GamepadEnabled then
			GuiService.SelectedObject = close
		end
	end)
	close.Activated:Connect(function()
		progressModal.Visible = false
		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(progressModal) then
			GuiService.SelectedObject = progressButton
		end
	end)
end

function HudController:Section(text)
	return label(self.ProgressBody, {
		Size = UDim2.new(1, -8, 0, 30), Text = text, Font = Enum.Font.GothamBold,
		TextColor3 = COLORS.Accent, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32,
	})
end

function HudController:Row(text, actionText, callback, enabled)
	local row = create("Frame", {
		Size = UDim2.new(1, -8, 0, 48), BackgroundColor3 = COLORS.PanelLight,
		BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 32,
	}, self.ProgressBody)
	round(row, 9)
	label(row, {
		Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -136, 1, -8), Text = text,
		TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextSize = 12, ZIndex = 33,
	})
	if actionText then
		local button = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(108, 32),
			BackgroundColor3 = enabled == false and Color3.fromRGB(64, 67, 76) or COLORS.Accent,
			BorderSizePixel = 0, Text = actionText, TextColor3 = COLORS.Text,
			Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = enabled ~= false, ZIndex = 33,
		}, row)
		round(button, 7)
		if enabled ~= false and callback then
			button.Activated:Connect(callback)
		end
	end
	return row
end

function HudController:RenderProgression(profile)
	if type(profile) ~= "table" then
		return
	end
	for _, child in self.ProgressBody:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	local statPoints = math.max(0, math.floor(tonumber(profile.StatPoints) or 0))
	local stats = type(profile.Stats) == "table" and profile.Stats or {}
	self:Section("ATRIBUTOS  •  " .. statPoints .. " PONTOS DISPONÍVEIS")
	for _, statName in { "Power", "Chakra", "Defense", "Speed" } do
		self:Row(string.upper(statName) .. "  •  " .. tostring(stats[statName] or 0), "+1", function()
			local remote = self:Remote("StatRequest")
			if remote then remote:FireServer(statName) end
		end, statPoints > 0)
	end
	self:Section("MISSÕES DIÁRIAS")
	local quests = type(profile.Quests) == "table" and profile.Quests.Daily or {}
	for index, quest in type(quests) == "table" and quests or {} do
		local progress = math.max(0, tonumber(quest.Progress) or 0)
		local goal = math.max(1, tonumber(quest.Goal) or 1)
		local complete = progress >= goal
		local action = quest.Claimed and "RESGATADO" or (complete and "RESGATAR" or "EM PROGRESSO")
		self:Row(string.format("%s  •  %d/%d  •  %d XP + %d Ryo", tostring(quest.Name or "Missão"), progress, goal, tonumber(quest.RewardXP) or 0, tonumber(quest.RewardRyo) or 0), action, function()
			local remote = self:Remote("QuestRequest")
			if remote then remote:FireServer("Claim", index) end
		end, complete and not quest.Claimed)
	end
	self:Section("SKINS E COSMÉTICOS")
	local hasInventory = false
	local inventory = type(profile.Inventory) == "table" and profile.Inventory or {}
	local equippedItems = type(profile.Equipped) == "table" and profile.Equipped or {}
	for itemId, owned in inventory do
		if owned and self.LootConfig[itemId] then
			hasInventory = true
			local item = self.LootConfig[itemId]
			local equipped = equippedItems[item.Type] == itemId
			self:Row(item.Name .. "  •  " .. string.upper(item.Rarity), equipped and "EQUIPADO" or "EQUIPAR", function()
				local remote = self:Remote("EquipRequest")
				if remote then remote:FireServer(itemId) end
			end, not equipped)
		end
	end
	if not hasInventory then
		self:Row("Derrote chefes para encontrar skins, auras e equipamentos raros.")
	end
	self:Section("REBIRTH")
	local level = math.max(1, tonumber(profile.Level) or 1)
	self:Row("Reinicia nível e atributos, preserva coleção e concede Essência permanente.", level >= 100 and "RENASCER" or "NÍVEL 100", function()
		local remote = self:Remote("RebirthRequest")
		if remote then remote:FireServer() end
	end, level >= 100)
end

function HudController:UpdateClan(state)
	if type(state) ~= "table" or type(state.Clans) ~= "table" then
		return
	end
	self.ClanState = state
	local selectedClan = type(state.Selected) == "string" and state.Selected or ""
	if selectedClan ~= "" then
		local clan = state.Clans[selectedClan]
		if clan then
			self.ClanButton.Text = string.format("%s  •  %d PONTOS PESSOAIS", string.upper(tostring(clan.Name or selectedClan)), tonumber(state.Contribution) or 0)
			self.ClanButton.TextColor3 = typeof(clan.Color) == "Color3" and clan.Color or COLORS.Accent
		end
	else
		self.ClanButton.Text = "ESCOLHA SEU CLÃ"
		self.ClanButton.TextColor3 = COLORS.Text
	end
	for _, child in self.ClanList:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for id, clan in state.Clans do
		if type(clan) ~= "table" then
			continue
		end
		local score = type(state.Scores) == "table" and state.Scores[id] or 0
		local clanColor = typeof(clan.Color) == "Color3" and clan.Color or COLORS.Accent
		local button = create("TextButton", {
			Name = tostring(id),
			BackgroundColor3 = clanColor,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Text = string.format("%s\n%s\n%d PONTOS", string.upper(tostring(clan.Name or id)), tostring(clan.Motto or ""), tonumber(score) or 0),
			TextColor3 = COLORS.Text,
			TextWrapped = true,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 22,
			AutoButtonColor = selectedClan == "",
			Selectable = selectedClan == "",
		}, self.ClanList)
		round(button, 12)
		button.Activated:Connect(function()
			if selectedClan == "" then
				local remote = self:Remote("ClanRequest")
				if remote then remote:FireServer("Choose", id) end
				self.ClanModal.Visible = false
			end
		end)
	end
end

function HudController:Notify(payload)
	local message = type(payload) == "table" and payload.Text or tostring(payload)
	if type(message) ~= "string" or message == "" then
		message = "Nova notificação"
	end
	local card = create("Frame", {
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundColor3 = COLORS.PanelLight,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, self.NotificationRoot)
	create("UISizeConstraint", { MaxSize = Vector2.new(340, 58), MinSize = Vector2.new(220, 58) }, card)
	round(card, 10)
	local copy = label(card, {
		Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -28, 1, -12),
		Text = message, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
	})
	TweenService:Create(card, TweenInfo.new(0.2), { BackgroundTransparency = 0.08 }):Play()
	TweenService:Create(copy, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
	task.delay(4, function()
		if not card.Parent then
			return
		end
		local tween = TweenService:Create(card, TweenInfo.new(0.25), { BackgroundTransparency = 1 })
		TweenService:Create(copy, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
		tween:Play()
		tween.Completed:Wait()
		if card.Parent then
			card:Destroy()
		end
	end)
end

function HudController:UpdateProfile(profile)
	if type(profile) ~= "table" then
		return
	end
	self.Profile = profile
	local level = math.max(1, math.floor(tonumber(profile.Level) or 1))
	local xp = math.max(0, tonumber(profile.XP) or 0)
	local xpNext = math.max(1, tonumber(profile.XPNext) or 1)
	self.Rank.Text = string.upper(tostring(profile.Rank or "Academy")) .. "  •  NÍVEL " .. level
	self.XPFill.Size = UDim2.fromScale(math.clamp(xp / xpNext, 0, 1), 1)
	self.Currency.Text = string.format("%s RYO   •   %s ESSÊNCIA   •   %d REBIRTH", tostring(profile.Ryo or 0), tostring(profile.Essence or 0), tonumber(profile.Rebirths) or 0)
	if self.ProgressModal and self.ProgressModal.Visible then
		self:RenderProgression(profile)
	end
end

function HudController:UpdateBoss(state)
	if type(state) ~= "table" then
		return
	end
	if state.Active then
		self.BossFrame.Visible = true
		self.BossName.Text = string.format("%s  •  FASE %d  •  %s", tostring(state.Name or "Chefe"), tonumber(state.Phase) or 1, string.upper(tostring(state.Mutator or "Normal")))
		self.BossSubtitle.Text = tostring(state.Subtitle or "")
		self.BossFill.BackgroundColor3 = state.Color or Color3.fromRGB(178, 54, 198)
		self.BossFill.Size = UDim2.fromScale(math.clamp((tonumber(state.Health) or 0) / math.max(1, tonumber(state.MaxHealth) or 1), 0, 1), 1)
	else
		if state.Intermission then
			self.BossFrame.Visible = true
			self.BossName.Text = "PRÓXIMO CHEFE EM " .. tostring(state.Intermission) .. "s"
			self.BossSubtitle.Text = "Prepare-se na vila"
			self.BossFill.Size = UDim2.fromScale(0, 1)
		else
			self.BossFrame.Visible = false
		end
	end
end

function HudController:BindCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid or not humanoid:IsA("Humanoid") then
		return
	end
	local function updateHealth()
		self.HealthFill.Size = UDim2.fromScale(math.clamp(humanoid.Health / math.max(1, humanoid.MaxHealth), 0, 1), 1)
	end
	humanoid.HealthChanged:Connect(updateHealth)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)
	updateHealth()
end

function HudController:Start()
	self:Build()
	local profileUpdate = self:Remote("ProfileUpdate")
	if profileUpdate then profileUpdate.OnClientEvent:Connect(function(profile) self:UpdateProfile(profile) end) end
	local bossState = self:Remote("BossState")
	if bossState then bossState.OnClientEvent:Connect(function(state) self:UpdateBoss(state) end) end
	local notification = self:Remote("Notification")
	if notification then notification.OnClientEvent:Connect(function(payload) self:Notify(payload) end) end
	local clanState = self:Remote("ClanState")
	if clanState then clanState.OnClientEvent:Connect(function(state) self:UpdateClan(state) end) end
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			if self.ProgressModal.Visible then
				self.ProgressModal.Visible = false
				GuiService.SelectedObject = UserInputService.GamepadEnabled and self.ProgressButton or nil
			elseif self.ClanModal.Visible then
				self.ClanModal.Visible = false
				GuiService.SelectedObject = UserInputService.GamepadEnabled and self.ClanButton or nil
			end
		end
	end)
	self.Player.CharacterAdded:Connect(function(character)
		self:BindCharacter(character)
	end)
	if self.Player.Character then
		task.spawn(function()
			self:BindCharacter(self.Player.Character)
		end)
	end
	local ok, profile = pcall(function()
		local remote = self:Remote("GetInitialState")
		return remote and remote:InvokeServer()
	end)
	if ok and profile then
		self:UpdateProfile(profile)
	end
end

return HudController
