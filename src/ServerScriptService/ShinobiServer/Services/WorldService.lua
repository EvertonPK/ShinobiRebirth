local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local BossConfig = require(game:GetService("ReplicatedStorage").ShinobiShared.BossConfig)
local AssetConfig = require(game:GetService("ReplicatedStorage").ShinobiShared.AssetConfig)

local WorldService = {}

local function assetUri(value)
	if type(value) ~= "string" or value == "" then
		return nil
	end
	if value:match("^%d+$") then
		return "rbxassetid://" .. value
	end
	if value:match("^rbxassetid://%d+$") then
		return value
	end
	return nil
end

local function addDecal(parent, name, texture, face)
	local uri = assetUri(texture)
	if not uri then
		return
	end
	local decal = Instance.new("Decal")
	decal.Name = name
	decal.Texture = uri
	decal.Face = face or Enum.NormalId.Front
	decal.Parent = parent
end

local function part(parent, name, size, cframe, color, material, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = material or Enum.Material.SmoothPlastic
	object.Shape = shape or Enum.PartType.Block
	object.Anchored = true
	object.TopSurface = Enum.SurfaceType.Smooth
	object.BottomSurface = Enum.SurfaceType.Smooth
	object.Parent = parent
	return object
end

local function cylinder(parent, name, size, cframe, color, material)
	return part(parent, name, size, cframe * CFrame.Angles(0, 0, math.rad(90)), color, material, Enum.PartType.Cylinder)
end

local function makeTree(parent, position, scale, palette)
	local model = Instance.new("Model")
	model.Name = "SpiritTree"
	model.Parent = parent
	cylinder(model, "Trunk", Vector3.new(14 * scale, 2.2 * scale, 2.2 * scale), CFrame.new(position + Vector3.new(0, 7 * scale, 0)), palette.Trunk, Enum.Material.Wood)
	for index = 1, 5 do
		local angle = index * math.pi * 2 / 5
		local offset = Vector3.new(math.cos(angle) * 3.5, 13 + (index % 2) * 1.5, math.sin(angle) * 3.5) * scale
		local crown = part(model, "Crown", Vector3.new(7, 7, 7) * scale, CFrame.new(position + offset), palette.Leaf, Enum.Material.Grass, Enum.PartType.Ball)
		crown.CanCollide = false
	end
	return model
end

local function makeTorii(parent, position, rotation, accent)
	local model = Instance.new("Model")
	model.Name = "ToriiGate"
	model.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)
	part(model, "LeftPillar", Vector3.new(3, 24, 3), base * CFrame.new(-10, 12, 0), accent, Enum.Material.Wood)
	part(model, "RightPillar", Vector3.new(3, 24, 3), base * CFrame.new(10, 12, 0), accent, Enum.Material.Wood)
	part(model, "TopBeam", Vector3.new(27, 3, 4), base * CFrame.new(0, 23, 0), accent, Enum.Material.Wood)
	local upperBeam = part(model, "UpperBeam", Vector3.new(32, 2, 5), base * CFrame.new(0, 27, 0), Color3.fromRGB(35, 28, 31), Enum.Material.Wood)
	addDecal(upperBeam, "VillageBanner", AssetConfig.Textures.VillageBanner)
	return model
end

local function makeSign(parent, textValue, position, accent)
	local sign = part(parent, "Signpost", Vector3.new(12, 4, 0.6), CFrame.new(position + Vector3.new(0, 5, 0)), Color3.fromRGB(42, 30, 25), Enum.Material.Wood)
	part(parent, "SignPost", Vector3.new(0.8, 7, 0.8), CFrame.new(position + Vector3.new(0, 1.5, 0)), Color3.fromRGB(75, 50, 38), Enum.Material.Wood)
	local board = Instance.new("BillboardGui")
	board.Adornee = sign
	board.Size = UDim2.fromOffset(210, 44)
	board.AlwaysOnTop = true
	board.Parent = sign
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = string.upper(textValue)
	text.TextColor3 = accent
	text.TextStrokeTransparency = 0.35
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Parent = board
end

local function makeLantern(parent, position, accent)
	local model = Instance.new("Model")
	model.Name = "VillageLantern"
	model.Parent = parent
	part(model, "Post", Vector3.new(0.55, 7, 0.55), CFrame.new(position + Vector3.new(0, 3.5, 0)), Color3.fromRGB(54, 38, 30), Enum.Material.Wood)
	local lamp = part(model, "Lamp", Vector3.new(1.6, 1.6, 1.6), CFrame.new(position + Vector3.new(0, 7, 0)), accent, Enum.Material.Neon, Enum.PartType.Ball)
	lamp.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = accent
	light.Brightness = 1.3
	light.Range = 15
	light.Parent = lamp
end

local function makeHouse(parent, name, position, scale, wallColor, roofColor)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local width, depth, height = 18 * scale, 15 * scale, 11 * scale
	part(model, "Foundation", Vector3.new(width + 2, 1.2, depth + 2), CFrame.new(position + Vector3.new(0, 0.6, 0)), Color3.fromRGB(84, 83, 76), Enum.Material.Slate)
	part(model, "MainRoom", Vector3.new(width, height, depth), CFrame.new(position + Vector3.new(0, height * 0.5 + 1.2, 0)), wallColor, Enum.Material.WoodPlanks)
	part(model, "RoofLeft", Vector3.new(width * 0.62, 1.5, depth + 3), CFrame.new(position + Vector3.new(-width * 0.2, height + 3.1, 0)) * CFrame.Angles(0, 0, math.rad(22)), roofColor, Enum.Material.Slate)
	part(model, "RoofRight", Vector3.new(width * 0.62, 1.5, depth + 3), CFrame.new(position + Vector3.new(width * 0.2, height + 3.1, 0)) * CFrame.Angles(0, 0, math.rad(-22)), roofColor, Enum.Material.Slate)
	local door = part(model, "Door", Vector3.new(3.6 * scale, 6.5 * scale, 0.35), CFrame.new(position + Vector3.new(0, 4.45 * scale + 1.2, -depth * 0.5 - 0.2)), Color3.fromRGB(53, 35, 28), Enum.Material.Wood)
	door.CanCollide = false
	for side = -1, 1, 2 do
		local window = part(model, "Window", Vector3.new(3.2 * scale, 2.8 * scale, 0.22), CFrame.new(position + Vector3.new(side * width * 0.28, height * 0.64 + 1.2, -depth * 0.5 - 0.23)), Color3.fromRGB(255, 194, 96), Enum.Material.Neon)
		window.Transparency = 0.3
		window.CanCollide = false
	end
	return model
end

local function makeStall(parent, name, position, accent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	part(model, "Counter", Vector3.new(11, 3, 4), CFrame.new(position + Vector3.new(0, 2, 0)), Color3.fromRGB(83, 54, 38), Enum.Material.Wood)
	part(model, "Awning", Vector3.new(13, 0.45, 6), CFrame.new(position + Vector3.new(0, 7, 0)), accent, Enum.Material.Fabric)
	for x = -1, 1, 2 do
		part(model, "Post", Vector3.new(0.45, 7, 0.45), CFrame.new(position + Vector3.new(x * 5, 3.5, 1.8)), Color3.fromRGB(63, 42, 31), Enum.Material.Wood)
	end
	for index = -2, 2 do
		local item = part(model, "MarketGood", Vector3.new(1.1, 1.1, 1.1), CFrame.new(position + Vector3.new(index * 1.8, 4.1, -0.8)), index % 2 == 0 and accent or Color3.fromRGB(224, 187, 105), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		item.CanCollide = false
	end
	return model
end

local function makeRock(parent, position, scale, color, material)
	local rock = part(parent, "Rock", Vector3.new(4, 3, 3) * scale, CFrame.new(position) * CFrame.Angles(math.rad(12 * scale), math.rad(26 * scale), math.rad(8)), color, material or Enum.Material.Slate, Enum.PartType.Ball)
	rock.CanCollide = true
	return rock
end

local function makeBridge(parent, position, length, rotation, accent)
	local model = Instance.new("Model")
	model.Name = "WoodenBridge"
	model.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(rotation), 0)
	for index = -math.floor(length / 3), math.floor(length / 3) do
		part(model, "Plank", Vector3.new(2.7, 0.45, 5.2), base * CFrame.new(index * 3, 0, 0), Color3.fromRGB(108, 70, 43), Enum.Material.WoodPlanks)
	end
	for side = -1, 1, 2 do
		part(model, "Rail", Vector3.new(length + 3, 1, 0.45), base * CFrame.new(0, 2, side * 3), accent, Enum.Material.Wood)
	end
	return model
end

local function makeBiome(parent, name, center, palette, treeCount, landmark)
	local biome = Instance.new("Folder")
	biome.Name = name
	biome.Parent = parent
	part(biome, "BiomeGround", Vector3.new(250, 2, 220), CFrame.new(center + Vector3.new(0, -1.2, 0)), palette.Ground, palette.GroundMaterial)
	for index = 1, treeCount do
		local angle = index * 2.399963
		local radius = 24 + (index % 8) * 13
		makeTree(biome, center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius), 0.7 + (index % 4) * 0.15, palette.Tree)
	end
	for index = 1, 16 do
		local angle = index * 1.73
		local radius = 35 + (index % 6) * 18
		makeRock(biome, center + Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius), 0.7 + (index % 3) * 0.2, palette.Rock, palette.RockMaterial)
	end
	makeSign(biome, landmark, center + Vector3.new(0, 0, -86), palette.Accent)
	return biome
end

local function makeVolcano(parent, position)
	local model = Instance.new("Model")
	model.Name = "EmberVolcano"
	model.Parent = parent
	for level = 1, 5 do
		local radius = 52 - level * 8
		local ring = cylinder(model, "BasaltRing", Vector3.new(10, radius, radius), CFrame.new(position + Vector3.new(0, level * 6, 0)), Color3.fromRGB(62 + level * 5, 43, 39), Enum.Material.Slate)
		ring.CanCollide = true
	end
	local lava = cylinder(model, "LavaCrater", Vector3.new(1.1, 15, 15), CFrame.new(position + Vector3.new(0, 33, 0)), Color3.fromRGB(255, 91, 38), Enum.Material.Neon)
	lava.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = lava.Color
	light.Brightness = 3
	light.Range = 32
	light.Parent = lava
end

local function makeStormTower(parent, position)
	local model = Instance.new("Model")
	model.Name = "StormWatchtower"
	model.Parent = parent
	cylinder(model, "TowerBase", Vector3.new(38, 10, 10), CFrame.new(position + Vector3.new(0, 19, 0)), Color3.fromRGB(49, 69, 113), Enum.Material.Slate)
	for index = 1, 4 do
		local angle = index * math.pi * 0.5
		local crystal = part(model, "ThunderCrystal", Vector3.new(2, 11, 2), CFrame.new(position + Vector3.new(math.cos(angle) * 12, 10, math.sin(angle) * 12)) * CFrame.Angles(math.rad(18), 0, math.rad(18)), Color3.fromRGB(112, 224, 255), Enum.Material.Neon)
		crystal.CanCollide = false
	end
	local beacon = part(model, "StormBeacon", Vector3.new(5, 5, 5), CFrame.new(position + Vector3.new(0, 40, 0)), Color3.fromRGB(151, 239, 255), Enum.Material.Neon, Enum.PartType.Ball)
	beacon.CanCollide = false
end

local function makeGroveShrine(parent, position)
	local model = Instance.new("Model")
	model.Name = "AncestorShrine"
	model.Parent = parent
	makeTree(model, position, 2.5, { Trunk = Color3.fromRGB(83, 66, 41), Leaf = Color3.fromRGB(117, 190, 91) })
	cylinder(model, "ShrinePlatform", Vector3.new(2.2, 32, 32), CFrame.new(position + Vector3.new(0, 0.5, 0)), Color3.fromRGB(75, 117, 67), Enum.Material.Grass)
	for index = 1, 6 do
		local angle = index * math.pi * 2 / 6
		local rune = part(model, "Rune", Vector3.new(1.2, 3.5, 1.2), CFrame.new(position + Vector3.new(math.cos(angle) * 16, 3, math.sin(angle) * 16)), Color3.fromRGB(174, 255, 123), Enum.Material.Neon)
		rune.CanCollide = false
	end
end

local function makeVoidRuins(parent, position)
	local model = Instance.new("Model")
	model.Name = "VoidRuins"
	model.Parent = parent
	cylinder(model, "RiftPool", Vector3.new(0.8, 26, 26), CFrame.new(position + Vector3.new(0, 0.1, 0)), Color3.fromRGB(105, 44, 139), Enum.Material.Neon)
	for index = 1, 8 do
		local angle = index * math.pi * 2 / 8
		local obelisk = part(model, "VoidObelisk", Vector3.new(3, 18 + (index % 3) * 5, 3), CFrame.new(position + Vector3.new(math.cos(angle) * 27, 9, math.sin(angle) * 27)) * CFrame.Angles(0, angle, math.rad(8)), Color3.fromRGB(49, 28, 68), Enum.Material.Slate)
		local glyph = part(model, "VoidGlyph", Vector3.new(0.25, 4, 2), obelisk.CFrame * CFrame.new(0, 2, -1.6), Color3.fromRGB(235, 108, 255), Enum.Material.Neon)
		glyph.CanCollide = false
	end
end

local function safeTeleport(player, destination, lookAt)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not humanoid or humanoid.Health <= 0 or not root then
		return
	end
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	local facing = Vector3.new(lookAt.X, destination.Y, lookAt.Z)
	if (facing - destination).Magnitude < 0.1 then
		facing = destination + Vector3.zAxis
	end
	character:PivotTo(CFrame.lookAt(destination, facing))
end

local function makePortal(parent, id, displayName, position, accent, destination, lookAt, actionText)
	local model = Instance.new("Model")
	model.Name = id
	model:SetAttribute("Destination", destination)
	model.Parent = parent

	local pad = cylinder(model, "PortalPad", Vector3.new(0.6, 12, 12), CFrame.new(position), accent, Enum.Material.Neon)
	pad.CanCollide = false
	pad.CanTouch = false
	pad.Transparency = 0.16

	local core = cylinder(model, "PortalCore", Vector3.new(0.22, 8.5, 8.5), CFrame.new(position + Vector3.new(0, 0.32, 0)), Color3.fromRGB(245, 242, 230), Enum.Material.ForceField)
	core.CanCollide = false
	core.CanTouch = false
	core.Transparency = 0.48

	for side = -1, 1, 2 do
		local pillar = part(
			model,
			"PortalPillar",
			Vector3.new(1.2, 8, 1.2),
			CFrame.new(position + Vector3.new(side * 5.3, 4, 0)),
			accent,
			Enum.Material.Metal
		)
		pillar.CanCollide = false
		pillar.CanTouch = false
	end
	local beam = part(model, "PortalBeam", Vector3.new(12, 1.2, 1.2), CFrame.new(position + Vector3.new(0, 8, 0)), accent, Enum.Material.Metal)
	beam.CanCollide = false
	beam.CanTouch = false

	local light = Instance.new("PointLight")
	light.Color = accent
	light.Brightness = 1.6
	light.Range = 14
	light.Parent = pad

	local sign = Instance.new("BillboardGui")
	sign.Name = "DestinationSign"
	sign.Adornee = beam
	sign.Size = UDim2.fromOffset(230, 54)
	sign.StudsOffset = Vector3.new(0, 2.2, 0)
	sign.AlwaysOnTop = true
	sign.MaxDistance = 80
	sign.Parent = beam
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
	text.BackgroundTransparency = 0.18
	text.BorderSizePixel = 0
	text.Text = string.upper(displayName)
	text.TextColor3 = Color3.fromRGB(248, 244, 233)
	text.TextStrokeColor3 = Color3.fromRGB(12, 13, 18)
	text.TextStrokeTransparency = 0.35
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Parent = sign
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = text

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "TravelPrompt"
	prompt.ActionText = actionText or "Viajar"
	prompt.ObjectText = displayName
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
	prompt.Parent = pad
	prompt.Triggered:Connect(function(player)
		safeTeleport(player, destination, lookAt)
	end)

	return model
end

local function makeHolidayTree(parent, position, scale)
	local model = Instance.new("Model")
	model.Name = "ChristmasTree"
	model.Parent = parent
	part(model, "Trunk", Vector3.new(1.4, 7, 1.4) * scale, CFrame.new(position + Vector3.new(0, 3.5 * scale, 0)), Color3.fromRGB(87, 52, 33), Enum.Material.Wood)
	for index = 1, 3 do
		local size = (10 - index * 2) * scale
		local foliage = part(model, "SnowyPine", Vector3.new(size, size * 0.52, size), CFrame.new(position + Vector3.new(0, (4 + index * 2.7) * scale, 0)), Color3.fromRGB(28, 104, 65), Enum.Material.Grass, Enum.PartType.Ball)
		foliage.CanCollide = false
	end
	local star = part(model, "Star", Vector3.new(1.4, 1.4, 1.4) * scale, CFrame.new(position + Vector3.new(0, 13 * scale, 0)), Color3.fromRGB(255, 215, 74), Enum.Material.Neon, Enum.PartType.Ball)
	star.CanCollide = false
	local light = Instance.new("PointLight")
	light.Color = star.Color
	light.Brightness = 2
	light.Range = 18 * scale
	light.Parent = star
	for index = 1, 8 do
		local angle = index * math.pi * 2 / 8
		local ornament = part(model, "Ornament", Vector3.new(0.55, 0.55, 0.55) * scale, CFrame.new(position + Vector3.new(math.cos(angle) * 3.2 * scale, (5 + index % 3 * 2) * scale, math.sin(angle) * 3.2 * scale)), index % 2 == 0 and Color3.fromRGB(220, 49, 62) or Color3.fromRGB(83, 174, 255), Enum.Material.Neon, Enum.PartType.Ball)
		ornament.CanCollide = false
	end
	return model
end

local function makeGift(parent, position, color)
	local model = Instance.new("Model")
	model.Name = "HolidayGift"
	model.Parent = parent
	local box = part(model, "GiftBox", Vector3.new(3.2, 3.2, 3.2), CFrame.new(position + Vector3.new(0, 1.6, 0)), color, Enum.Material.SmoothPlastic)
	local ribbonA = part(model, "Ribbon", Vector3.new(0.45, 3.4, 3.4), box.CFrame, Color3.fromRGB(255, 221, 88), Enum.Material.Neon)
	local ribbonB = part(model, "Ribbon", Vector3.new(3.4, 3.4, 0.45), box.CFrame, Color3.fromRGB(255, 221, 88), Enum.Material.Neon)
	ribbonA.CanCollide = false
	ribbonB.CanCollide = false
	return model
end

local function makeFestivalNpc(parent, name, position, color, promptText, callback)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local root = part(model, "Root", Vector3.new(3.5, 7, 3), CFrame.new(position + Vector3.new(0, 4, 0)), color, Enum.Material.Fabric)
	root.CanCollide = false
	local head = part(model, "Head", Vector3.new(3, 3, 3), CFrame.new(position + Vector3.new(0, 9, 0)), Color3.fromRGB(255, 218, 188), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	head.CanCollide = false
	local hat = part(model, "HolidayHat", Vector3.new(2.7, 2.5, 2.7), CFrame.new(position + Vector3.new(0, 11, 0)), Color3.fromRGB(206, 51, 59), Enum.Material.Fabric, Enum.PartType.Ball)
	hat.CanCollide = false
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = promptText
	prompt.ObjectText = name
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = head
	prompt.Triggered:Connect(callback)
	return model
end

local function makeArena(parent, key, definition)
	local model = Instance.new("Model")
	model.Name = key .. "Arena"
	model:SetAttribute("BossId", key)
	model.Parent = parent
	local center = definition.Arena
	cylinder(model, "ArenaFloor", Vector3.new(4, 130, 130), CFrame.new(center - Vector3.new(0, 3, 0)), definition.Palette.Primary, definition.Material)
	for index = 1, 16 do
		local angle = index * math.pi * 2 / 16
		local offset = Vector3.new(math.cos(angle) * 70, 1, math.sin(angle) * 70)
		local pillar = cylinder(model, "Boundary", Vector3.new(12, 4, 4), CFrame.new(center + offset), definition.Palette.Secondary, definition.Material)
		pillar.CanCollide = true
	end
	local spawn = part(model, "BossSpawn", Vector3.new(2, 1, 2), CFrame.new(center), definition.Palette.Accent, Enum.Material.Neon)
	spawn.Transparency = 1
	spawn.CanCollide = false
	makeTorii(model, center + Vector3.new(0, 0, 74), 180, definition.Palette.Secondary)
	return model
end

function WorldService:Init(context)
	self.Context = context
end

function WorldService:BuildLighting()
	for _, className in { "Atmosphere", "BloomEffect", "ColorCorrectionEffect", "SunRaysEffect" } do
		for _, child in Lighting:GetChildren() do
			if child:IsA(className) and child:GetAttribute("ShinobiGenerated") then
				child:Destroy()
			end
		end
	end
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Density = 0.28
	atmosphere.Offset = 0.15
	atmosphere.Color = Color3.fromRGB(210, 229, 244)
	atmosphere.Decay = Color3.fromRGB(94, 123, 153)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.6
	atmosphere:SetAttribute("ShinobiGenerated", true)
	atmosphere.Parent = Lighting
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.45
	bloom.Size = 32
	bloom.Threshold = 1.2
	bloom:SetAttribute("ShinobiGenerated", true)
	bloom.Parent = Lighting
	local correction = Instance.new("ColorCorrectionEffect")
	correction.Contrast = 0.08
	correction.Saturation = -0.04
	correction.TintColor = Color3.fromRGB(221, 238, 255)
	correction:SetAttribute("ShinobiGenerated", true)
	correction.Parent = Lighting
end

function WorldService:BuildHolidayFestival(runtime)
	local festival = Instance.new("Folder")
	festival.Name = "NatalShinobi"
	festival.Parent = runtime
	local snow = Color3.fromRGB(239, 248, 255)
	local red = Color3.fromRGB(206, 51, 59)
	local green = Color3.fromRGB(31, 118, 70)

	for _, patchData in {
		{ Position = Vector3.new(415, -1154, -1587), Size = Vector3.new(110, 0.35, 100) },
		{ Position = Vector3.new(881, -1180, -1982), Size = Vector3.new(90, 0.35, 90) },
		{ Position = Vector3.new(240, -1156, -2101), Size = Vector3.new(120, 0.35, 95) },
		{ Position = Vector3.new(1150, -1016, -3100), Size = Vector3.new(104, 0.25, 104) },
		{ Position = Vector3.new(1400, -1016, -3100), Size = Vector3.new(104, 0.25, 104) },
		{ Position = Vector3.new(1650, -1016, -3100), Size = Vector3.new(104, 0.25, 104) },
	} do
		local patch = part(festival, "SnowCover", patchData.Size, CFrame.new(patchData.Position), snow, Enum.Material.Snow)
		patch.CanCollide = false
	end

	for _, treeData in {
		{ Position = Vector3.new(415, -1153, -1557), Scale = 1.5 },
		{ Position = Vector3.new(850, -1180, -1960), Scale = 1.25 },
		{ Position = Vector3.new(912, -1180, -2007), Scale = 1.1 },
		{ Position = Vector3.new(220, -1156, -2060), Scale = 1.15 },
		{ Position = Vector3.new(1150, -1016, -3063), Scale = 1.0 },
		{ Position = Vector3.new(1400, -1016, -3063), Scale = 1.0 },
		{ Position = Vector3.new(1650, -1016, -3063), Scale = 1.0 },
	} do
		makeHolidayTree(festival, treeData.Position, treeData.Scale)
	end

	for index = 1, 18 do
		local angle = index * math.pi * 2 / 18
		local radius = 38 + (index % 3) * 9
		makeGift(festival, Vector3.new(415 + math.cos(angle) * radius, -1153, -1587 + math.sin(angle) * radius), index % 2 == 0 and red or green)
	end

	local notify = function(player, message)
		self.Context.Remotes.Notification:FireClient(player, { Kind = "Holiday", Text = message })
	end
	makeFestivalNpc(festival, "Papai Noel Shinobi", Vector3.new(415, -1153, -1609), red, "Receber missão", function(player)
		notify(player, "Festival de Natal: complete chefes, missões e baús para ganhar Gemas, Tickets e Tokens de Estilo.")
	end)
	makeFestivalNpc(festival, "Mestre das Missões", Vector3.new(240, -1156, -2074), green, "Ver missões", function(player)
		notify(player, "Missões diárias e objetivos semanais avançam seu nível, temporada e recompensas natalinas.")
	end)
	makeFestivalNpc(festival, "Guia dos Chefes", Vector3.new(881, -1180, -2014), Color3.fromRGB(74, 112, 196), "Ver rota", function(player)
		notify(player, "Os portais festivos levam às arenas. Cada chefe entrega XP, Ryo, Gemas, Tickets e skins.")
	end)

	local hubs = {
		Vector3.new(842, -1179, -1950), Vector3.new(882, -1179, -1950),
		Vector3.new(922, -1179, -1950), Vector3.new(962, -1179, -1950),
	}
	for index, bossId in BossConfig.Order do
		local definition = BossConfig.Definitions[bossId]
		local target = definition.ImportedArena or definition.Arena
		makePortal(festival, bossId .. "HolidayPortal", definition.DisplayName, hubs[index], definition.Palette.Accent, target + Vector3.new(0, 4, 32), target, "Ir ao chefe")
	end
	for _, definition in BossConfig.Definitions do
		local position = definition.ImportedArena or definition.Arena
		local beacon = part(festival, "BossHolidayBeacon", Vector3.new(3, 11, 3), CFrame.new(position + Vector3.new(0, 5, -38)), definition.Palette.Accent, Enum.Material.Neon)
		beacon.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = definition.Palette.Accent
		light.Brightness = 2
		light.Range = 20
		light.Parent = beacon
	end
	workspace:SetAttribute("HolidayTheme", "Natal Shinobi")
end

local function landmark(instance)
	if instance and instance:IsA("Model") then
		local cframe, size = instance:GetBoundingBox()
		return cframe, size
	end
	local basePart = instance and (instance:IsA("BasePart") and instance or instance:FindFirstChildWhichIsA("BasePart", true))
	if basePart then
		return basePart.CFrame, basePart.Size
	end
	return nil, nil
end

function WorldService:BuildMapIntegration(imported, runtime)
	local integration = Instance.new("Folder")
	integration.Name = "MapIntegration"
	integration.Parent = runtime

	local function find(name)
		return imported:FindFirstChild(name, true)
	end
	local function anchor(name, target, offset)
		local cframe, size = landmark(target)
		if not cframe then return nil end
		local point = part(integration, name, Vector3.new(2, 2, 2), cframe * CFrame.new(offset or Vector3.new(0, size.Y * 0.5 + 3, size.Z * 0.5 + 4)), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
		point.Transparency = 1
		point.CanCollide = false
		point.CanTouch = false
		return point
	end
	local function prompt(point, actionText, objectText, callback)
		if not point then return end
		local interaction = Instance.new("ProximityPrompt")
		interaction.ActionText = actionText
		interaction.ObjectText = objectText
		interaction.HoldDuration = 0
		interaction.MaxActivationDistance = 12
		interaction.RequiresLineOfSight = false
		interaction.Parent = point
		interaction.Triggered:Connect(callback)
	end
	local function activateDoor(door, displayName, onOpen)
		if not door or not door:IsA("BasePart") then return end
		door:SetAttribute("ShinobiDoor", true)
		local closed = door.CFrame
		local opened = false
		local busy = false
		local doorPrompt = Instance.new("ProximityPrompt")
		doorPrompt.ActionText = "Abrir"
		doorPrompt.ObjectText = displayName
		doorPrompt.HoldDuration = 0
		doorPrompt.MaxActivationDistance = 10
		doorPrompt.RequiresLineOfSight = false
		doorPrompt.Parent = door
		doorPrompt.Triggered:Connect(function(player)
			if busy then return end
			busy = true
			opened = not opened
			doorPrompt.ActionText = opened and "Fechar" or "Abrir"
			door.CanCollide = not opened
			TweenService:Create(door, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = opened and (closed * CFrame.Angles(0, math.rad(82), 0)) or closed,
			}):Play()
			if opened and onOpen then onOpen(player) end
			task.delay(0.45, function() busy = false end)
		end)
	end
	local function decorateWindow(window)
		if not window or not window:IsA("BasePart") then return end
		window.Material = Enum.Material.Glass
		window.Color = Color3.fromRGB(156, 206, 238)
		window.Transparency = math.max(window.Transparency, 0.22)
		window.Reflectance = 0.08
		window.CanCollide = false
	end
	local commerceBuildings = {
		{ Name = "Posto do Kage", Open = function(player) self.Context.Remotes.WorldAction:FireClient(player, "Progression") end },
		{ Name = "Taverna do Ramen", Open = function(player)
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.Health = humanoid.MaxHealth end
			self.Context.Remotes.Notification:FireClient(player, { Kind = "Ramen", Text = "Você descansou na Taverna do Ramen e recuperou sua vida." })
		end },
		{ Name = "Banco de Yen", Open = function(player) self.Context.Remotes.WorldAction:FireClient(player, "Shop", "Featured") end },
		{ Name = "Casa de Campeões", Open = function(player) self.Context.Remotes.WorldAction:FireClient(player, "Shop", "Inventory") end },
		{ Name = "Armazém de Espadas", Open = function(player) self.Context.Remotes.WorldAction:FireClient(player, "Shop", "Featured") end },
		{ Name = "Loja de Jutsus", Open = function(player) self.Context.Remotes.WorldAction:FireClient(player, "Shop", "Crates") end },
	}
	for _, entry in commerceBuildings do
		local buildingName = entry.Name
		local building = find(buildingName)
		if building then
			activateDoor(building:FindFirstChild("Porta", true), buildingName, entry.Open)
			decorateWindow(building:FindFirstChild("JanelaDir", true))
			decorateWindow(building:FindFirstChild("JanelaEsq", true))
		end
	end
	activateDoor(find("PortaCasaPrincipal"), "Casa Principal")
	local commerce = find("VilaDoComercio") or find("CidadeComercio")
	local shop = anchor("ShopEntrance", commerce)
	prompt(shop, "Abrir loja", "Mercado Shinobi", function(player)
		self.Context.Remotes.WorldAction:FireClient(player, "Shop", "Featured")
	end)
	local quest = anchor("QuestEntrance", find("MestreDeMissoes"))
	prompt(quest, "Ver objetivos", "Mestre de Missões", function(player)
		local quests = self.Context.Services.QuestService
		if quests then quests:EnsureDaily(player) end
		self.Context.Remotes.WorldAction:FireClient(player, "Progression")
	end)
	local training = anchor("TrainingEntrance", find("TrainingZones"))
	prompt(training, "Treinar", "Campo de Treino", function(player)
		self.Context.Remotes.Notification:FireClient(player, { Kind = "Training", Text = "Acerte os bonecos e complete a missão Disciplina Shinobi para ganhar XP e Ryo." })
	end)
	local champion = anchor("ChampionHouse", find("Casa de Campeões"))
	prompt(champion, "Ver coleção", "Casa de Campeões", function(player)
		self.Context.Remotes.WorldAction:FireClient(player, "Shop", "Inventory")
	end)

	local bossSpawns = Instance.new("Folder")
	bossSpawns.Name = "BossSpawns"
	bossSpawns.Parent = integration
	local arenaNames = { "Arena1_GolemDePedra", "Arena2_SerpenteSombria", "Arena3_EspiritoVazio", "BossArena" }
	for index, bossId in BossConfig.Order do
		local target = find(arenaNames[index]) or find("BossArena")
		local cframe, size = landmark(target)
		if cframe then
			local spawn = part(bossSpawns, bossId, Vector3.new(2, 2, 2), cframe * CFrame.new(0, size.Y * 0.5 + 3, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
			spawn.Transparency, spawn.CanCollide, spawn.CanTouch = 1, false, false
		end
	end

	local enemyZone = find("EnemySpawners")
	local enemyCFrame, enemySize = landmark(enemyZone)
	if enemyCFrame and enemySize then
		local patrols = Instance.new("Folder")
		patrols.Name = "EnemyPatrols"
		patrols.Parent = integration
		for index = 1, 12 do
			local angle = index * math.pi * 2 / 12
			local localOffset = Vector3.new(math.cos(angle) * math.max(8, enemySize.X * 0.32), enemySize.Y * 0.5 + 3, math.sin(angle) * math.max(8, enemySize.Z * 0.32))
			local patrol = part(patrols, "Patrol" .. index, Vector3.new(2, 2, 2), enemyCFrame * CFrame.new(localOffset), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
			patrol.Transparency, patrol.CanCollide, patrol.CanTouch = 1, false, false
		end
	end
	imported:SetAttribute("IntegratedWithMap", true)
end

function WorldService:BuildImportedRuntime(imported)
	local existing = Workspace:FindFirstChild("ShinobiWorld")
	if existing then
		existing:Destroy()
	end
	local runtime = Instance.new("Folder")
	runtime.Name = "ShinobiWorld"
	runtime.Parent = Workspace
	runtime:SetAttribute("UsesImportedMap", true)
	self.World = runtime

	self:BuildMapIntegration(imported, runtime)

	imported:SetAttribute("ShinobiMapReady", true)
	self:BuildLighting()
end

function WorldService:BuildWorld()
	local imported = Workspace:FindFirstChild("ImportedMapBase")
	if imported then
		self:BuildImportedRuntime(imported)
		return
	end
	local old = Workspace:FindFirstChild("ShinobiWorld")
	if old then
		old:Destroy()
	end
	local world = Instance.new("Folder")
	world.Name = "ShinobiWorld"
	world.Parent = Workspace
	self.World = world

	part(world, "WorldBase", Vector3.new(900, 8, 900), CFrame.new(0, -6, 0), Color3.fromRGB(47, 70, 50), Enum.Material.Grass)
	part(world, "VillageStone", Vector3.new(170, 3, 170), CFrame.new(0, -0.5, 0), Color3.fromRGB(102, 103, 98), Enum.Material.Cobblestone)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "VillageSpawn"
	spawn.Size = Vector3.new(14, 1, 14)
	spawn.CFrame = CFrame.new(0, 2, 20)
	spawn.Color = Color3.fromRGB(236, 156, 53)
	spawn.Material = Enum.Material.Neon
	spawn.Transparency = 0.35
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Parent = world

	makeTorii(world, Vector3.new(0, 0, 82), 0, Color3.fromRGB(160, 38, 36))
	local treePalette = { Trunk = Color3.fromRGB(75, 50, 41), Leaf = Color3.fromRGB(235, 133, 160) }
	for index = 1, 28 do
		local angle = index * 2.399963
		local radius = 100 + (index % 7) * 24
		makeTree(world, Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius), 0.75 + (index % 4) * 0.1, treePalette)
	end

	local village = Instance.new("Folder")
	village.Name = "HiddenLeafVillage"
	village.Parent = world
	part(village, "MainRoadNorth", Vector3.new(22, 0.5, 190), CFrame.new(0, 1.2, 89), Color3.fromRGB(154, 143, 126), Enum.Material.Cobblestone)
	part(village, "MainRoadEast", Vector3.new(190, 0.5, 20), CFrame.new(90, 1.2, 0), Color3.fromRGB(154, 143, 126), Enum.Material.Cobblestone)
	part(village, "MainRoadWest", Vector3.new(190, 0.5, 20), CFrame.new(-90, 1.2, 0), Color3.fromRGB(154, 143, 126), Enum.Material.Cobblestone)
	part(village, "MainRoadSouth", Vector3.new(22, 0.5, 180), CFrame.new(0, 1.2, -114), Color3.fromRGB(154, 143, 126), Enum.Material.Cobblestone)
	makeHouse(village, "HokageResidence", Vector3.new(0, 0, 58), 1.15, Color3.fromRGB(206, 183, 148), Color3.fromRGB(145, 44, 37))
	makeHouse(village, "NinjaAcademy", Vector3.new(-62, 0, 12), 0.92, Color3.fromRGB(194, 174, 139), Color3.fromRGB(56, 85, 128))
	makeHouse(village, "VillageClinic", Vector3.new(62, 0, 12), 0.88, Color3.fromRGB(211, 204, 181), Color3.fromRGB(67, 130, 92))
	makeHouse(village, "Dojo", Vector3.new(-62, 0, -53), 0.84, Color3.fromRGB(177, 143, 104), Color3.fromRGB(88, 56, 43))
	makeHouse(village, "GuildHall", Vector3.new(62, 0, -53), 0.84, Color3.fromRGB(170, 151, 132), Color3.fromRGB(78, 47, 104))
	makeStall(village, "RyoMarket", Vector3.new(-27, 0, -12), Color3.fromRGB(226, 115, 55))
	makeStall(village, "CosmeticMarket", Vector3.new(27, 0, -12), Color3.fromRGB(115, 192, 239))
	makeSign(village, "Academia", Vector3.new(-62, 0, -2), Color3.fromRGB(115, 192, 239))
	makeSign(village, "Clínica", Vector3.new(62, 0, -2), Color3.fromRGB(113, 225, 143))
	makeSign(village, "Mercado Shinobi", Vector3.new(0, 0, -28), Color3.fromRGB(255, 191, 83))
	for index = 1, 18 do
		local angle = index * math.pi * 2 / 18
		makeLantern(village, Vector3.new(math.cos(angle) * 76, 0, math.sin(angle) * 76), index % 2 == 0 and Color3.fromRGB(255, 187, 83) or Color3.fromRGB(255, 117, 72))
	end

	local regions = Instance.new("Folder")
	regions.Name = "ShinobiRegions"
	regions.Parent = world
	makeBiome(regions, "AshenFrontier", Vector3.new(0, 0, 235), {
		Ground = Color3.fromRGB(73, 48, 41), GroundMaterial = Enum.Material.Ground,
		Tree = { Trunk = Color3.fromRGB(63, 39, 32), Leaf = Color3.fromRGB(154, 55, 32) },
		Rock = Color3.fromRGB(83, 56, 50), RockMaterial = Enum.Material.Slate, Accent = Color3.fromRGB(255, 126, 54),
	}, 12, "Fronteira das Cinzas")
	makeBiome(regions, "StormHighlands", Vector3.new(235, 0, 0), {
		Ground = Color3.fromRGB(50, 62, 96), GroundMaterial = Enum.Material.Rock,
		Tree = { Trunk = Color3.fromRGB(44, 54, 78), Leaf = Color3.fromRGB(91, 146, 202) },
		Rock = Color3.fromRGB(58, 72, 112), RockMaterial = Enum.Material.Slate, Accent = Color3.fromRGB(115, 215, 255),
	}, 10, "Planalto da Tempestade")
	makeBiome(regions, "AncientGrove", Vector3.new(-235, 0, 0), {
		Ground = Color3.fromRGB(52, 91, 58), GroundMaterial = Enum.Material.Grass,
		Tree = { Trunk = Color3.fromRGB(80, 62, 42), Leaf = Color3.fromRGB(109, 174, 83) },
		Rock = Color3.fromRGB(76, 112, 66), RockMaterial = Enum.Material.Grass, Accent = Color3.fromRGB(179, 255, 122),
	}, 24, "Bosque Ancestral")
	makeBiome(regions, "VoidMarsh", Vector3.new(0, 0, -235), {
		Ground = Color3.fromRGB(43, 31, 59), GroundMaterial = Enum.Material.Mud,
		Tree = { Trunk = Color3.fromRGB(45, 33, 56), Leaf = Color3.fromRGB(100, 53, 126) },
		Rock = Color3.fromRGB(67, 43, 89), RockMaterial = Enum.Material.Slate, Accent = Color3.fromRGB(228, 98, 255),
	}, 15, "Pântano do Vazio")
	makeVolcano(regions, Vector3.new(0, 0, 155))
	makeStormTower(regions, Vector3.new(152, 0, -72))
	makeGroveShrine(regions, Vector3.new(-152, 0, -72))
	makeVoidRuins(regions, Vector3.new(0, 0, -286))

	local river = part(world, "MoonRiver", Vector3.new(130, 0.35, 22), CFrame.new(0, -0.15, -145), Color3.fromRGB(54, 147, 184), Enum.Material.Glass)
	river.Transparency = 0.34
	river.CanCollide = false
	makeBridge(world, Vector3.new(0, 1.15, -145), 28, 90, Color3.fromRGB(88, 57, 41))
	makeTorii(world, Vector3.new(0, 0, -192), 180, Color3.fromRGB(99, 54, 129))
	makeTorii(world, Vector3.new(0, 0, 168), 0, Color3.fromRGB(163, 57, 37))
	makeTorii(world, Vector3.new(170, 0, 0), 90, Color3.fromRGB(56, 98, 163))
	makeTorii(world, Vector3.new(-170, 0, 0), -90, Color3.fromRGB(67, 132, 72))

	local arenas = Instance.new("Folder")
	arenas.Name = "BossArenas"
	arenas.Parent = world
	for key, definition in BossConfig.Definitions do
		makeArena(arenas, key, definition)
	end

	local travel = Instance.new("Folder")
	travel.Name = "TravelNetwork"
	travel.Parent = world
	local hubPositions = {
		Vector3.new(-48, 1.35, 42),
		Vector3.new(48, 1.35, 42),
		Vector3.new(-48, 1.35, -38),
		Vector3.new(48, 1.35, -38),
	}
	local villageArrival = Vector3.new(0, 4, 46)
	for index, bossId in BossConfig.Order do
		local definition = BossConfig.Definitions[bossId]
		local arenaArrival = definition.Arena + Vector3.new(0, 4, 48)
		makePortal(
			travel,
			bossId .. "Portal",
			definition.DisplayName,
			hubPositions[index],
			definition.Palette.Accent,
			arenaArrival,
			definition.Arena,
			"Ir para arena"
		)
		makePortal(
			travel,
			bossId .. "ReturnPortal",
			"Retornar à vila",
			definition.Arena + Vector3.new(0, 0.35, 58),
			definition.Palette.Accent,
			villageArrival,
			Vector3.new(0, villageArrival.Y, 0),
			"Voltar"
		)
	end

	local training = Instance.new("Folder")
	training.Name = "TrainingGround"
	training.Parent = world
	for index = 1, 6 do
		local angle = index * math.pi * 2 / 6
		local location = Vector3.new(math.cos(angle) * 38, 5, math.sin(angle) * 38 - 110)
		local dummy = part(training, "TrainingDummy", Vector3.new(4, 10, 4), CFrame.new(location), Color3.fromRGB(112, 76, 51), Enum.Material.Wood)
		dummy:SetAttribute("MaxHealth", 500)
		dummy:SetAttribute("Health", 500)
		dummy:SetAttribute("CombatTarget", true)
	end
	self:BuildLighting()
end

function WorldService:Start()
	self:BuildWorld()
end

return WorldService
