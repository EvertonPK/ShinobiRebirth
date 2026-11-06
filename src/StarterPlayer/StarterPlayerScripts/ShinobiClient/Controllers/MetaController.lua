local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local MetaController = {}

local COLORS = {
	Panel = Color3.fromRGB(18, 20, 29),
	Card = Color3.fromRGB(32, 36, 50),
	Text = Color3.fromRGB(242, 240, 234),
	Muted = Color3.fromRGB(157, 163, 180),
	Accent = Color3.fromRGB(238, 139, 62),
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
	create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function text(parent, value, size, bold)
	return create("TextLabel", {
		Size = size,
		BackgroundTransparency = 1,
		Text = tostring(value or ""),
		TextColor3 = COLORS.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium,
		TextSize = bold and 15 or 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, parent)
end

function MetaController:Init(context)
	self.Remotes = context.Remotes
	self.MetaConfig = require(context.Shared:WaitForChild("MetaConfig"))
	self.Player = Players.LocalPlayer
	self.Hud = context.HudController
	self.Profile = nil
end

function MetaController:Clear()
	self.CodeStatus = nil
	for _, child in self.Content:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
end

function MetaController:Remote(name)
	return self.Remotes:FindFirstChild(name)
end

function MetaController:Card(title, description, action)
	local card = create("Frame", {
		Size = UDim2.new(1, -8, 0, 64),
		BackgroundColor3 = COLORS.Card,
		BorderSizePixel = 0,
	}, self.Content)
	round(card, 9)
	text(card, title, UDim2.new(1, action and -130 or -24, 0, 24), true).Position = UDim2.fromOffset(12, 7)
	local body = text(card, description, UDim2.new(1, action and -130 or -24, 0, 26), false)
	body.Position = UDim2.fromOffset(12, 31)
	body.TextColor3 = COLORS.Muted
	if action then
		local button = create("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(105, 34),
			BackgroundColor3 = COLORS.Accent,
			BorderSizePixel = 0,
			Text = action.Text,
			TextColor3 = COLORS.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
		}, card)
		round(button, 8)
		button.Activated:Connect(action.Callback)
	end
	return card
end

function MetaController:ShowAchievements()
	self:Clear()
	local unlocked = self.Profile and self.Profile.Achievements or {}
	for id, definition in self.MetaConfig.Achievements do
		local done = unlocked[id] ~= nil
		local rewardParts = {}
		for currency, amount in definition.Reward do
			table.insert(rewardParts, tostring(amount) .. " " .. currency)
		end
		self:Card((done and "✓ " or "○ ") .. definition.Name, definition.Description .. "  •  " .. table.concat(rewardParts, ", "))
	end
end

function MetaController:ShowCodes()
	self:Clear()
	local card = create("Frame", {
		Size = UDim2.new(1, -8, 0, 105), BackgroundColor3 = COLORS.Card, BorderSizePixel = 0,
	}, self.Content)
	round(card, 9)
	text(card, "CÓDIGOS PROMOCIONAIS", UDim2.new(1, -24, 0, 24), true).Position = UDim2.fromOffset(12, 8)
	local input = create("TextBox", {
		Position = UDim2.fromOffset(12, 42), Size = UDim2.new(1, -132, 0, 42),
		BackgroundColor3 = Color3.fromRGB(13, 15, 22), BorderSizePixel = 0,
		PlaceholderText = "DIGITE O CÓDIGO", Text = "", TextColor3 = COLORS.Text,
		PlaceholderColor3 = COLORS.Muted, Font = Enum.Font.GothamBold, TextSize = 14,
		ClearTextOnFocus = false,
	}, card)
	round(input, 8)
	local redeem = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 42), Size = UDim2.fromOffset(100, 42),
		BackgroundColor3 = COLORS.Accent, BorderSizePixel = 0, Text = "RESGATAR",
		TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 11,
	}, card)
	round(redeem, 8)
	redeem.Activated:Connect(function()
		local remote = self:Remote("CodeRequest")
		if remote then
			remote:FireServer(input.Text)
		else
			self.CodeStatus.Text = "O sistema de códigos ainda está sincronizando."
		end
	end)
	self.CodeStatus = text(card, "Cada código funciona uma vez por conta.", UDim2.new(1, -24, 0, 16), false)
	self.CodeStatus.Position = UDim2.fromOffset(12, 86)
	self.CodeStatus.TextColor3 = COLORS.Muted
end

function MetaController:ShowLeaderboard(id)
	self:Clear()
	self.ActiveBoard = id
	for _, board in self.MetaConfig.Leaderboards do
		local selected = board.Id == id
		self:Card(board.Name, selected and "Atualizando classificação global..." or "Abrir esta classificação", {
			Text = selected and "ATUAL" or "ABRIR",
			Callback = function()
				self:ShowLeaderboard(board.Id)
			end,
		})
	end
	local remote = self:Remote("LeaderboardRequest")
	if remote then
		remote:FireServer(id)
	end
end

function MetaController:RenderLeaderboard(payload)
	if type(payload) ~= "table" or payload.Id ~= self.ActiveBoard then
		return
	end
	self:Clear()
	local entries = type(payload.Entries) == "table" and payload.Entries or {}
	if #entries == 0 then
		self:Card("Sem dados ainda", "A classificação será preenchida depois das primeiras partidas publicadas.")
		return
	end
	for index, entry in entries do
		if type(entry) == "table" then
			local rank = math.max(1, math.floor(tonumber(entry.Rank) or index))
			self:Card(string.format("#%d  %s", rank, tostring(entry.Name or "Shinobi")), tostring(entry.Value or 0))
		end
	end
end

function MetaController:SetVisible(visible)
	if not self.Modal then
		return
	end
	self.Modal.Visible = visible
	if visible then
		self:ShowAchievements()
		if UserInputService.GamepadEnabled and self.FirstTab then
			GuiService.SelectedObject = self.FirstTab
		end
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.Modal) then
		GuiService.SelectedObject = self.OpenButton
	end
end

function MetaController:Build()
	local gui = create("ScreenGui", {
		Name = "MetaUI", ResetOnSpawn = false, IgnoreGuiInset = false,
		DisplayOrder = 15, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, self.Player:WaitForChild("PlayerGui"))
	local open = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -20, 0, 20), Size = UDim2.fromOffset(118, 42),
		BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0, Text = "CONQUISTAS",
		TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 11,
	}, gui)
	round(open, 10)
	self.OpenButton = open
	local modal = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.92, 0.86),
		BackgroundColor3 = COLORS.Panel, BorderSizePixel = 0, Visible = false,
	}, gui)
	create("UISizeConstraint", { MaxSize = Vector2.new(610, 510), MinSize = Vector2.new(300, 330) }, modal)
	round(modal, 15)
	text(modal, "REGISTRO SHINOBI", UDim2.new(1, -40, 0, 35), true).Position = UDim2.fromOffset(20, 14)
	local tabs = create("Frame", { Position = UDim2.fromOffset(18, 54), Size = UDim2.new(1, -36, 0, 38), BackgroundTransparency = 1 }, modal)
	create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }, tabs)
	for index, tab in {
		{ Name = "CONQUISTAS", Callback = function() self:ShowAchievements() end },
		{ Name = "CÓDIGOS", Callback = function() self:ShowCodes() end },
		{ Name = "RANKING", Callback = function() self:ShowLeaderboard("Level") end },
	} do
		local button = create("TextButton", {
			Size = UDim2.new(1 / 3, -6, 1, 0), BackgroundColor3 = COLORS.Card, BorderSizePixel = 0,
			Text = tab.Name, TextColor3 = COLORS.Text, Font = Enum.Font.GothamBold, TextSize = 11,
			Selectable = true,
		}, tabs)
		round(button, 8)
		button.Activated:Connect(tab.Callback)
		if index == 1 then
			self.FirstTab = button
		end
	end
	local close = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 12), Size = UDim2.fromOffset(38, 34),
		BackgroundColor3 = COLORS.Card, BorderSizePixel = 0, Text = "×", TextColor3 = COLORS.Text,
		Font = Enum.Font.GothamBold, TextSize = 20,
	}, modal)
	round(close, 8)
	local content = create("ScrollingFrame", {
		Position = UDim2.fromOffset(18, 102), Size = UDim2.new(1, -36, 1, -120), BackgroundTransparency = 1,
		BorderSizePixel = 0, ScrollBarThickness = 4, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
	}, modal)
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, content)
	self.Modal = modal
	self.Content = content
	open.Activated:Connect(function()
		self:SetVisible(not modal.Visible)
	end)
	close.Activated:Connect(function()
		self:SetVisible(false)
	end)
end

function MetaController:Start()
	self:Build()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not self.Modal.Visible then
			return
		end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
			self:SetVisible(false)
		end
	end)
	local profileUpdate = self:Remote("ProfileUpdate")
	if profileUpdate then
		profileUpdate.OnClientEvent:Connect(function(profile)
			self.Profile = profile
		end)
	end
	local codeResult = self:Remote("CodeResult")
	if codeResult then
		codeResult.OnClientEvent:Connect(function(result)
			if self.CodeStatus and self.CodeStatus.Parent and type(result) == "table" then
				self.CodeStatus.Text = tostring(result.Message or "Resposta recebida.")
				self.CodeStatus.TextColor3 = result.Success and Color3.fromRGB(102, 220, 137) or Color3.fromRGB(235, 92, 92)
			end
		end)
	end
	local achievementUnlocked = self:Remote("AchievementUnlocked")
	if achievementUnlocked then
		achievementUnlocked.OnClientEvent:Connect(function(payload)
			if self.Hud and type(payload) == "table" then
				self.Hud:Notify({ Kind = "Achievement", Text = "Conquista: " .. tostring(payload.Name or payload.Id or "Desbloqueada") })
			end
		end)
	end
	local leaderboardState = self:Remote("LeaderboardState")
	if leaderboardState then
		leaderboardState.OnClientEvent:Connect(function(payload)
			self:RenderLeaderboard(payload)
		end)
	end
	local ok, profile = pcall(function()
		local remote = self:Remote("GetInitialState")
		return remote and remote:InvokeServer()
	end)
	if ok and profile then
		self.Profile = profile
	end
end

return MetaController
