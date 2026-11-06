local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Visuals = require(ReplicatedStorage.ShinobiShared.CosmeticVisualConfig)

local CosmeticService = {}

local function weldPart(parent, target, name, size, offset, color, material, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = target.CFrame * offset
	object.Color = color
	object.Material = material
	object.Shape = shape or Enum.PartType.Block
	object.CanCollide = false
	object.CanQuery = false
	object.Massless = true
	object.Parent = parent
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = object
	weld.Part1 = target
	weld.Parent = object
	return object
end

local function bodyPart(character, r15, r6)
	return character:FindFirstChild(r15) or character:FindFirstChild(r6)
end

local function addCrown(folder, head, visual)
	for index = -2, 2 do
		local height = 0.9 + (2 - math.abs(index)) * 0.22
		weldPart(
			folder,
			head,
			"CrownSpire",
			Vector3.new(0.26, height, 0.26),
			CFrame.new(index * 0.43, 1 + height * 0.35, 0),
			index % 2 == 0 and visual.Accent or visual.Primary,
			visual.Material,
			Enum.PartType.Ball
		)
	end
end

local function applyOutfit(folder, torso, head, visual)
	local style = visual.Style
	if style:find("Mask") then
		weldPart(folder, head, "FaceMask", Vector3.new(2.1, 1.55, 0.35), CFrame.new(0, 0, -0.62), visual.Primary, visual.Material)
		weldPart(folder, head, "MaskMark", Vector3.new(0.3, 1, 0.08), CFrame.new(0, 0, -0.83), visual.Accent, Enum.Material.Neon)
		if style == "FoxMask" then
			for side = -1, 1, 2 do
				weldPart(folder, head, "FoxEar", Vector3.new(0.55, 1.4, 0.5), CFrame.new(side * 0.7, 1.15, 0), visual.Primary, visual.Material)
			end
		end
	end
	if style:find("Armor") then
		weldPart(folder, torso, "ArmorChest", Vector3.new(3.4, 2.5, 1.2), CFrame.new(0, 0.2, -0.45), visual.Primary, visual.Material)
		weldPart(folder, torso, "ArmorCore", Vector3.new(1.1, 1.6, 0.2), CFrame.new(0, 0.3, -1.08), visual.Accent, Enum.Material.Neon)
		for side = -1, 1, 2 do
			weldPart(folder, torso, "ShoulderArmor", Vector3.new(1.2, 1.2, 1.5), CFrame.new(side * 2, 0.8, 0), visual.Accent, visual.Material, Enum.PartType.Ball)
		end
	end
	if style:find("Cloak") then
		weldPart(folder, torso, "Cloak", Vector3.new(3.4, 3.8, 0.35), CFrame.new(0, -0.4, 0.7) * CFrame.Angles(math.rad(8), 0, 0), visual.Primary, Enum.Material.Fabric)
		weldPart(folder, torso, "CloakTrim", Vector3.new(3.55, 0.28, 0.42), CFrame.new(0, -2.2, 0.82), visual.Accent, Enum.Material.Neon)
	end
	if style:find("Helm") then
		weldPart(folder, head, "Helm", Vector3.new(2.4, 0.7, 2.3), CFrame.new(0, 0.72, 0), visual.Primary, visual.Material)
	end
	if style:find("Crown") then
		addCrown(folder, head, visual)
	end
end

local function applyWeapon(folder, hand, itemId, visual)
	local style = visual.Style
	if style == "Spear" then
		weldPart(folder, hand, itemId, Vector3.new(0.25, 7.5, 0.25), CFrame.new(0, -2.5, 0), visual.Primary, visual.Material)
		weldPart(folder, hand, "SpearTip", Vector3.new(0.8, 1.4, 0.8), CFrame.new(0, -6.7, 0), visual.Accent, Enum.Material.Neon, Enum.PartType.Ball)
	elseif style == "Twinblade" then
		for side = -1, 1, 2 do
			weldPart(folder, hand, itemId, Vector3.new(0.25, 4.4, 0.55), CFrame.new(side * 0.42, side * -2.2, 0), side == 1 and visual.Primary or visual.Accent, visual.Material)
		end
	else
		local great = style == "Greatblade"
		weldPart(folder, hand, itemId, great and Vector3.new(0.65, 6.8, 1.15) or Vector3.new(0.28, 5.8, 0.65), CFrame.new(0, great and -3.2 or -2.7, -0.3), visual.Primary, visual.Material)
		weldPart(folder, hand, "WeaponGuard", Vector3.new(great and 2.4 or 1.6, 0.25, 0.45), CFrame.new(0, -0.2, -0.3), visual.Accent, Enum.Material.Metal)
	end
end

local function applyEyes(folder, head, visual)
	for side = -1, 1, 2 do
		weldPart(folder, head, "ShinobiEye", Vector3.new(0.35, 0.18, 0.08), CFrame.new(side * 0.3, 0.12, -0.61), side == -1 and visual.Primary or visual.Secondary, Enum.Material.Neon)
	end
end

local function applyAura(folder, character, torso, visual)
	local anchor = weldPart(folder, torso, "AuraAnchor", Vector3.new(1, 1, 1), CFrame.identity, visual.Primary, Enum.Material.Neon, Enum.PartType.Ball)
	anchor.Transparency = 1
	local light = Instance.new("PointLight")
	light.Color = visual.Primary
	light.Range = 12 + visual.Orbitals
	light.Brightness = 1.5 + visual.Orbitals * 0.15
	light.Parent = anchor
	local highlight = Instance.new("Highlight")
	highlight.Name = "AuraHighlight"
	highlight.Adornee = character
	highlight.FillColor = visual.Secondary
	highlight.FillTransparency = 0.88
	highlight.OutlineColor = visual.Primary
	highlight.OutlineTransparency = 0.25
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = folder
	for index = 1, visual.Orbitals do
		local angle = index * math.pi * 2 / visual.Orbitals
		local offset = CFrame.new(math.cos(angle) * 2.2, (index % 3 - 1) * 0.75, math.sin(angle) * 1.4)
		local orb = weldPart(folder, torso, "AuraOrb", Vector3.new(0.28, 0.28, 0.28), offset, index % 2 == 0 and visual.Primary or visual.Secondary, Enum.Material.Neon, Enum.PartType.Ball)
		orb.Transparency = 0.15
	end
end

function CosmeticService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Applied = {}
end

function CosmeticService:Clear(character)
	local existing = character:FindFirstChild("ShinobiCosmetics")
	if existing then
		existing:Destroy()
	end
end

function CosmeticService:Apply(player)
	local profile = self.Profiles:Get(player)
	local character = player.Character
	if not profile or not character then
		return
	end
	local equipped = profile.Equipped
	local signature = table.concat({ equipped.Cosmetic, equipped.WeaponSkin, equipped.Aura, equipped.Eyes }, "|")
	local previous = self.Applied[player]
	if previous and previous.Character == character and previous.Signature == signature then
		return
	end
	local torso = bodyPart(character, "UpperTorso", "Torso")
	local head = character:FindFirstChild("Head")
	local rightHand = bodyPart(character, "RightHand", "Right Arm")
	if not torso or not head then
		return
	end
	self:Clear(character)
	local folder = Instance.new("Folder")
	folder.Name = "ShinobiCosmetics"
	folder.Parent = character

	local cosmetic = profile.Equipped.Cosmetic
	local outfitVisual = Visuals.Cosmetics[cosmetic]
	if outfitVisual then
		applyOutfit(folder, torso, head, outfitVisual)
	end

	local weapon = profile.Equipped.WeaponSkin
	local weaponVisual = Visuals.Weapons[weapon]
	if rightHand and weaponVisual then
		applyWeapon(folder, rightHand, weapon, weaponVisual)
	end

	local eyeVisual = Visuals.Eyes[profile.Equipped.Eyes]
	if eyeVisual then
		applyEyes(folder, head, eyeVisual)
	end

	local auraVisual = Visuals.Auras[profile.Equipped.Aura]
	if auraVisual then
		applyAura(folder, character, torso, auraVisual)
	end
	self.Applied[player] = { Character = character, Signature = signature }
end

function CosmeticService:Start()
	self.Profiles.Changed.Event:Connect(function(player)
		self:Apply(player)
	end)
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			self.Applied[player] = nil
			task.wait(1)
			if player.Character == character then
				self:Apply(player)
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.Applied[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		if player.Character then
			task.spawn(function()
				self:Apply(player)
			end)
		end
	end
end

return CosmeticService
