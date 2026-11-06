local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

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
	atmosphere.Color = Color3.fromRGB(181, 202, 218)
	atmosphere.Decay = Color3.fromRGB(76, 89, 115)
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
	correction.TintColor = Color3.fromRGB(255, 241, 226)
	correction:SetAttribute("ShinobiGenerated", true)
	correction.Parent = Lighting
end

function WorldService:BuildWorld()
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
