local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnemyConfig = require(ReplicatedStorage.ShinobiShared.EnemyConfig)
local GameConfig = require(ReplicatedStorage.ShinobiShared.GameConfig)

local EnemyService = {
	Enemies = {},
}

local SPAWNS = {
	{ Id = "Rogue", Position = Vector3.new(120, 4, 120) },
	{ Id = "Rogue", Position = Vector3.new(-120, 4, 130) },
	{ Id = "Rogue", Position = Vector3.new(145, 4, -115) },
	{ Id = "AshDisciple", Position = Vector3.new(-35, 4, 245) },
	{ Id = "AshDisciple", Position = Vector3.new(45, 4, 275) },
	{ Id = "AshDisciple", Position = Vector3.new(-75, 4, 315) },
	{ Id = "StormAcolyte", Position = Vector3.new(240, 5, 30) },
	{ Id = "StormAcolyte", Position = Vector3.new(290, 5, -55) },
	{ Id = "StormAcolyte", Position = Vector3.new(315, 5, 75) },
	{ Id = "VoidWalker", Position = Vector3.new(-30, 6, -250) },
	{ Id = "VoidWalker", Position = Vector3.new(60, 6, -295) },
	{ Id = "VoidWalker", Position = Vector3.new(-80, 6, -330) },
}

local IMPORTED_MAP_SPAWNS = {
	{ Id = "Rogue", Position = Vector3.new(214, -1163, -1620) },
	{ Id = "Rogue", Position = Vector3.new(232, -1163, -1620) },
	{ Id = "Rogue", Position = Vector3.new(268, -1163, -1620) },
	{ Id = "AshDisciple", Position = Vector3.new(460, -1160, -1840) },
	{ Id = "AshDisciple", Position = Vector3.new(510, -1160, -1885) },
	{ Id = "AshDisciple", Position = Vector3.new(560, -1160, -1840) },
	{ Id = "StormAcolyte", Position = Vector3.new(1220, -1017, -3060) },
	{ Id = "StormAcolyte", Position = Vector3.new(1280, -1017, -3040) },
	{ Id = "StormAcolyte", Position = Vector3.new(1340, -1017, -3060) },
	{ Id = "VoidWalker", Position = Vector3.new(1570, -1017, -3100) },
	{ Id = "VoidWalker", Position = Vector3.new(1615, -1017, -3140) },
	{ Id = "VoidWalker", Position = Vector3.new(1680, -1017, -3170) },
}

local function mapPatrolSpawns()
	local world = workspace:FindFirstChild("ShinobiWorld")
	local integration = world and world:FindFirstChild("MapIntegration")
	local patrols = integration and integration:FindFirstChild("EnemyPatrols")
	if not patrols then
		return IMPORTED_MAP_SPAWNS
	end
	local ids = { "Rogue", "Rogue", "Rogue", "AshDisciple", "AshDisciple", "AshDisciple", "StormAcolyte", "StormAcolyte", "StormAcolyte", "VoidWalker", "VoidWalker", "VoidWalker" }
	local result = {}
	for index, id in ids do
		local marker = patrols:FindFirstChild("Patrol" .. index)
		if marker and marker:IsA("BasePart") then
			table.insert(result, { Id = id, Position = marker.Position })
		end
	end
	return #result > 0 and result or IMPORTED_MAP_SPAWNS
end

local function makePart(model, name, size, cframe, color, material, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = material
	object.Shape = shape or Enum.PartType.Block
	object.Anchored = true
	object.CanCollide = false
	object.Parent = model
	return object
end

local function buildEnemy(id, definition, position)
	local model = Instance.new("Model")
	model.Name = id
	model:SetAttribute("EnemyId", id)
	model:SetAttribute("CombatTarget", true)
	local base = CFrame.new(position + Vector3.new(0, 4, 0))
	local root = makePart(model, "Root", Vector3.new(3, 7, 3), base, definition.Color, Enum.Material.SmoothPlastic)
	root.Transparency = 1
	local torso = makePart(model, "Torso", Vector3.new(4.5, 5, 2.5), base, definition.Color, Enum.Material.Fabric)
	makePart(model, "Head", Vector3.new(2.7, 2.7, 2.7), base * CFrame.new(0, 3.8, 0), definition.Color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "Mask", Vector3.new(2.8, 1.4, 0.3), base * CFrame.new(0, 3.7, -1.35), definition.Accent, Enum.Material.Metal)
	for side = -1, 1, 2 do
		makePart(model, "Arm", Vector3.new(1.4, 5, 1.4), torso.CFrame * CFrame.new(side * 3, 0, 0), definition.Color, Enum.Material.Fabric)
		makePart(model, "Eye", Vector3.new(0.5, 0.18, 0.1), base * CFrame.new(side * 0.55, 3.9, -1.53), definition.Accent, Enum.Material.Neon)
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = definition.Name
	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.Parent = model
	model.PrimaryPart = root
	return model, humanoid
end

function EnemyService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Progression = context.Services.ProgressionService
	self.Quests = context.Services.QuestService
	self.Remotes = context.Remotes
end

function EnemyService:Spawn(index, spawn)
	local definition = EnemyConfig[spawn.Id]
	local model, humanoid = buildEnemy(spawn.Id, definition, spawn.Position)
	local tiers = {}
	for player in self.Profiles.Profiles do
		local profile = self.Profiles:Get(player)
		if profile then
			table.insert(tiers, GameConfig.GetWorldTier(profile.Rebirths))
		end
	end
	table.sort(tiers)
	local tier = tiers[math.ceil(#tiers * 0.5)] or 1
	local scale = GameConfig.WorldTiers[tier]
	humanoid.MaxHealth = math.floor(definition.Health * scale.Health)
	humanoid.Health = humanoid.MaxHealth
	model.Parent = workspace:WaitForChild("ShinobiWorld")
	local enemy = {
		Index = index,
		Id = spawn.Id,
		Definition = definition,
		Spawn = spawn,
		Model = model,
		Humanoid = humanoid,
		Damage = math.floor(definition.Damage * scale.Damage),
		Contributors = {},
		NextAttack = 0,
	}
	self.Enemies[index] = enemy
	humanoid.Died:Once(function()
		self.Enemies[index] = nil
		local eligible = {}
		local eligibleDamage = 0
		local topPlayer, topDamage = nil, 0
		local minimumContribution = humanoid.MaxHealth * 0.05
		for userId, damage in enemy.Contributors do
			local player = Players:GetPlayerByUserId(userId)
			if player and damage > topDamage then
				topPlayer, topDamage = player, damage
			end
			if player and damage >= minimumContribution then
				table.insert(eligible, { Player = player, Damage = damage })
				eligibleDamage += damage
			end
		end
		if #eligible == 0 and topPlayer then
			table.insert(eligible, { Player = topPlayer, Damage = topDamage })
			eligibleDamage = topDamage
		end
		local xpBudget = math.floor(definition.XP * scale.Rewards)
		local ryoBudget = math.floor(definition.Ryo * scale.Rewards)
		for _, contribution in eligible do
			local share = contribution.Damage / math.max(1, eligibleDamage)
			self.Progression:AddXP(contribution.Player, math.max(1, math.floor(xpBudget * share)))
			self.Progression:AddRyo(contribution.Player, math.max(1, math.floor(ryoBudget * share)))
			self.Quests:Record(contribution.Player, "EnemyKill", 1)
		end
		task.delay(8, function()
			model:Destroy()
			self:Spawn(index, spawn)
		end)
	end)
end

function EnemyService:TryPlayerHit(player, origin, range, damage)
	local selected, distance
	for _, enemy in self.Enemies do
		if enemy.Humanoid.Health > 0 then
			local current = (enemy.Model.PrimaryPart.Position - origin).Magnitude
			if current <= range + 3 and (not distance or current < distance) then
				selected, distance = enemy, current
			end
		end
	end
	if not selected then
		return false
	end
	selected.Contributors[player.UserId] = (selected.Contributors[player.UserId] or 0) + damage
	selected.Humanoid:TakeDamage(damage)
	return true
end

function EnemyService:UpdateEnemy(enemy)
	if enemy.Humanoid.Health <= 0 or not enemy.Model.Parent then
		return
	end
	local root = enemy.Model.PrimaryPart
	local home = enemy.Spawn.Position + Vector3.new(0, 4, 0)
	if (root.Position - home).Magnitude > 90 then
		enemy.Model:PivotTo(CFrame.new(home))
		return
	end
	local nearest, nearestDistance
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if playerRoot and humanoid and humanoid.Health > 0 then
			local distance = (playerRoot.Position - root.Position).Magnitude
			if distance < 65 and (not nearestDistance or distance < nearestDistance) then
				nearest, nearestDistance = player, distance
			end
		end
	end
	if not nearest then
		if (root.Position - home).Magnitude > 4 then
			enemy.Model:PivotTo(CFrame.new(root.Position:Lerp(home, 0.025)))
		end
		return
	end
	local character = nearest.Character
	local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		return
	end
	if nearestDistance > 7 then
		local delta = targetRoot.Position - root.Position
		local flat = Vector3.new(delta.X, 0, delta.Z)
		if flat.Magnitude > 0 then
			local nextPosition = root.Position + flat.Unit * math.min(1.2, flat.Magnitude)
			enemy.Model:PivotTo(CFrame.lookAt(nextPosition, Vector3.new(targetRoot.Position.X, nextPosition.Y, targetRoot.Position.Z)))
		end
	elseif os.clock() >= enemy.NextAttack then
		enemy.NextAttack = os.clock() + 1.8
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:TakeDamage(enemy.Damage)
		end
	end
end

function EnemyService:Start()
	workspace:WaitForChild("ShinobiWorld")
	local spawns = workspace:FindFirstChild("ImportedMapBase") and mapPatrolSpawns() or SPAWNS
	for index, spawn in spawns do
		self:Spawn(index, spawn)
	end
	task.spawn(function()
		while task.wait(0.12) do
			for _, enemy in self.Enemies do
				self:UpdateEnemy(enemy)
			end
		end
	end)
end

return EnemyService
