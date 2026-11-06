local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BossConfig = require(ReplicatedStorage.ShinobiShared.BossConfig)
local GameConfig = require(ReplicatedStorage.ShinobiShared.GameConfig)
local AssetConfig = require(ReplicatedStorage.ShinobiShared.AssetConfig)

local BossService = {
	Active = nil,
	Cycle = 0,
}

local function addBossSigil(parent)
	local texture = AssetConfig.Textures.BossSigil
	if type(texture) ~= "string" or texture == "" then
		return
	end
	if texture:match("^%d+$") then
		texture = "rbxassetid://" .. texture
	elseif not texture:match("^rbxassetid://%d+$") then
		return
	end
	local decal = Instance.new("Decal")
	decal.Name = "BossSigil"
	decal.Texture = texture
	decal.Face = Enum.NormalId.Front
	decal.Parent = parent
end

local function createPart(model, name, size, cframe, color, material, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cframe
	object.Color = color
	object.Material = material
	object.Shape = shape or Enum.PartType.Block
	object.Anchored = true
	object.CanCollide = name == "Root"
	object.CastShadow = true
	object.Parent = model
	return object
end

local function adorn(model, parent, name, size, offset, color, material, shape)
	local item = createPart(model, name, size, parent.CFrame * offset, color, material, shape)
	item.CanCollide = false
	return item
end

local function buildBossModel(bossId, definition)
	local model = Instance.new("Model")
	model.Name = bossId
	model:SetAttribute("BossId", bossId)
	model:SetAttribute("CombatTarget", true)
	local origin = CFrame.new(definition.Arena + Vector3.new(0, 8, 0))
	local root = createPart(model, "Root", Vector3.new(6, 13, 5), origin, definition.Palette.Primary, definition.Material)
	root.Transparency = 1
	local torso = adorn(model, root, "Torso", Vector3.new(9, 11, 5), CFrame.new(0, 2, 0), definition.Palette.Primary, definition.Material)
	local chest = adorn(model, root, "Armor", Vector3.new(10, 5, 6), CFrame.new(0, 4, 0), definition.Palette.Secondary, Enum.Material.Metal)
	chest.Shape = Enum.PartType.Block
	local head = adorn(model, root, "Head", Vector3.new(5.5, 5.5, 5.5), CFrame.new(0, 10, 0), definition.Palette.Primary, definition.Material, Enum.PartType.Ball)
	local mask = adorn(model, root, "Mask", Vector3.new(5.7, 4, 0.8), CFrame.new(0, 10, -2.55), definition.Palette.Secondary, Enum.Material.Metal)
	addBossSigil(mask)
	for side = -1, 1, 2 do
		adorn(model, root, "Arm", Vector3.new(3.2, 12, 3.2), CFrame.new(side * 6.2, 1.5, 0) * CFrame.Angles(0, 0, side * math.rad(10)), definition.Palette.Primary, definition.Material)
		adorn(model, root, "Leg", Vector3.new(3.7, 11, 3.7), CFrame.new(side * 2.7, -8, 0), definition.Palette.Primary, definition.Material)
		adorn(model, root, "Eye", Vector3.new(1.25, 0.55, 0.35), CFrame.new(side * 1.35, 10.5, -3), definition.Palette.Accent, Enum.Material.Neon)
	end

	if bossId == "EmberRonin" then
		adorn(model, root, "Katana", Vector3.new(1, 18, 1), CFrame.new(7, 0, -2) * CFrame.Angles(0, 0, math.rad(-12)), definition.Palette.Accent, Enum.Material.Neon)
	elseif bossId == "StormOni" then
		for side = -1, 1, 2 do
			adorn(model, root, "Horn", Vector3.new(1.5, 7, 1.5), CFrame.new(side * 2.4, 14, 0) * CFrame.Angles(0, 0, side * math.rad(18)), definition.Palette.Accent, Enum.Material.Neon)
		end
	elseif bossId == "VerdantSage" then
		for index = 1, 6 do
			local angle = index * math.pi * 2 / 6
			adorn(model, root, "Branch", Vector3.new(1.3, 10, 1.3), CFrame.new(math.cos(angle) * 4, 10 + math.sin(angle) * 2, 2) * CFrame.Angles(angle, 0, angle), definition.Palette.Accent, Enum.Material.Wood)
		end
	elseif bossId == "VoidShogun" then
		for index = 1, 4 do
			local angle = index * math.pi / 2
			local blade = adorn(model, root, "VoidBlade", Vector3.new(0.8, 14, 2), CFrame.new(math.cos(angle) * 10, 3, math.sin(angle) * 10) * CFrame.Angles(0, angle, math.rad(35)), definition.Palette.Accent, Enum.Material.Neon)
			blade:SetAttribute("OrbitIndex", index)
		end
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = definition.Palette.Accent
	highlight.FillTransparency = 0.82
	highlight.OutlineColor = definition.Palette.Secondary
	highlight.OutlineTransparency = 0.05
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = definition.DisplayName
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	humanoid.Parent = model
	model.PrimaryPart = root
	return model, humanoid
end

function BossService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Rewards = context.Services.RewardService
	self.Quests = context.Services.QuestService
	self.Remotes = context.Remotes
	self.Random = Random.new()
end

function BossService:GetServerTier()
	local tier = 1
	for player in self.Profiles.Profiles do
		local profile = self.Profiles:Get(player)
		if profile then
			tier = math.max(tier, GameConfig.GetWorldTier(profile.Rebirths))
		end
	end
	return tier
end

function BossService:SelectMutator()
	local maxIndex = math.min(#BossConfig.Mutators, 2 + math.floor(self.Cycle / 2))
	if self.Cycle > 0 and self.Cycle % 8 == 0 then
		return BossConfig.Mutators[#BossConfig.Mutators]
	end
	return BossConfig.Mutators[self.Random:NextInteger(1, math.max(1, maxIndex))]
end

function BossService:BroadcastState(extra)
	local active = self.Active
	if active and not extra then
		local now = os.clock()
		if now - (active.LastStateSent or 0) < 0.1 then
			return
		end
		active.LastStateSent = now
	end
	local state = extra or {}
	if active then
		state.Active = true
		state.Id = active.Id
		state.Name = active.Definition.DisplayName
		state.Subtitle = active.Definition.Subtitle
		state.Health = active.Humanoid.Health
		state.MaxHealth = active.Humanoid.MaxHealth
		state.Phase = active.Phase
		state.Mutator = active.Mutator.Name
		state.Color = active.Definition.Palette.Accent
	else
		state.Active = false
	end
	self.Remotes.BossState:FireAllClients(state)
end

local function horizontalDistance(first, second)
	local delta = first - second
	return Vector2.new(delta.X, delta.Z).Magnitude
end

local function distanceToSegment(position, startPosition, endPosition)
	local point = Vector2.new(position.X, position.Z)
	local startPoint = Vector2.new(startPosition.X, startPosition.Z)
	local endPoint = Vector2.new(endPosition.X, endPosition.Z)
	local segment = endPoint - startPoint
	local lengthSquared = segment:Dot(segment)
	if lengthSquared <= 0.001 then
		return (point - startPoint).Magnitude
	end
	local alpha = math.clamp((point - startPoint):Dot(segment) / lengthSquared, 0, 1)
	return (point - (startPoint + segment * alpha)).Magnitude
end

function BossService:IsActive(active)
	return self.Active == active and active.Humanoid.Health > 0 and active.Model.Parent ~= nil
end

function BossService:ForEachLivingPlayer(callback)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			callback(player, root, humanoid)
		end
	end
end

function BossService:DamagePlayers(position, radius, amount, innerRadius, onHit, damaged)
	self:ForEachLivingPlayer(function(player, root, humanoid)
		local distance = horizontalDistance(root.Position, position)
		if distance <= radius and distance >= (innerRadius or 0) and not (damaged and damaged[player]) then
			humanoid:TakeDamage(math.max(0, amount))
			if damaged then
				damaged[player] = true
			end
			if onHit then
				onHit(player, root, humanoid)
			end
		end
	end)
end

function BossService:DamageLine(startPosition, endPosition, width, amount, onHit, damaged)
	self:ForEachLivingPlayer(function(player, root, humanoid)
		if math.abs(root.Position.Y - startPosition.Y) <= 24
			and distanceToSegment(root.Position, startPosition, endPosition) <= width * 0.5
			and not (damaged and damaged[player])
		then
			humanoid:TakeDamage(math.max(0, amount))
			if damaged then
				damaged[player] = true
			end
			if onHit then
				onHit(player, root, humanoid)
			end
		end
	end)
end

function BossService:SendTelegraph(active, data)
	if not self:IsActive(active) then
		return false
	end
	data.Color = data.Color or active.Definition.Palette.Accent
	self.Remotes.BossTelegraph:FireAllClients(data)
	return true
end

function BossService:TelegraphCircle(active, position, radius, delaySeconds, kind, damageMultiplier, innerRadius, onHit)
	if not self:SendTelegraph(active, {
		Shape = innerRadius and "Ring" or "Circle",
		Position = position,
		Radius = radius,
		InnerRadius = innerRadius,
		Delay = delaySeconds,
		Kind = kind,
	}) then
		return
	end
	task.wait(delaySeconds)
	if self:IsActive(active) then
		self:DamagePlayers(position, radius, active.Damage * (damageMultiplier or 1), innerRadius, onHit)
	end
end

function BossService:TelegraphLine(active, startPosition, endPosition, width, delaySeconds, kind, damageMultiplier, onHit, damaged)
	if not self:SendTelegraph(active, {
		Shape = "Line",
		Position = (startPosition + endPosition) * 0.5,
		Start = startPosition,
		Finish = endPosition,
		Width = width,
		Delay = delaySeconds,
		Kind = kind,
	}) then
		return
	end
	task.wait(delaySeconds)
	if self:IsActive(active) then
		self:DamageLine(startPosition, endPosition, width, active.Damage * (damageMultiplier or 1), onHit, damaged)
	end
end

function BossService:CircleVolley(active, positions, radius, delaySeconds, kind, damageMultiplier, hitOnce)
	for _, position in positions do
		self:SendTelegraph(active, {
			Shape = "Circle",
			Position = position,
			Radius = radius,
			Delay = delaySeconds,
			Kind = kind,
		})
	end
	task.wait(delaySeconds)
	if not self:IsActive(active) then
		return
	end
	local damaged = hitOnce and {} or nil
	for _, position in positions do
		self:DamagePlayers(position, radius, active.Damage * (damageMultiplier or 1), nil, nil, damaged)
	end
end

function BossService:ApplyControl(humanoid, speed, duration)
	local untilTime = os.clock() + duration
	local previousUntil = humanoid:GetAttribute("ShinobiBossControlUntil") or 0
	if previousUntil <= os.clock() then
		humanoid:SetAttribute("ShinobiBossOriginalSpeed", humanoid.WalkSpeed)
	end
	humanoid:SetAttribute("ShinobiBossControlUntil", math.max(previousUntil, untilTime))
	humanoid.WalkSpeed = math.min(humanoid.WalkSpeed, speed)
	task.delay(duration + 0.05, function()
		if not humanoid.Parent then
			return
		end
		local controlUntil = humanoid:GetAttribute("ShinobiBossControlUntil") or 0
		if controlUntil <= os.clock() then
			local originalSpeed = humanoid:GetAttribute("ShinobiBossOriginalSpeed")
			if type(originalSpeed) == "number" then
				humanoid.WalkSpeed = originalSpeed
			end
			humanoid:SetAttribute("ShinobiBossControlUntil", nil)
			humanoid:SetAttribute("ShinobiBossOriginalSpeed", nil)
		end
	end)
end

function BossService:PerformAbility(active, ability, targetPosition)
	if not self:IsActive(active) then
		return
	end
	local root = active.Model.PrimaryPart
	local delaySeconds = math.max(0.7, 1.4 - active.Phase * 0.14)
	local phase = active.Phase

	if ability == "FlameCleave" then
		local direction = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)
		if direction.Magnitude < 1 then direction = root.CFrame.LookVector end
		self:TelegraphLine(active, root.Position, root.Position + direction.Unit * 38, 13 + phase * 2, delaySeconds, ability, 1.15)
	elseif ability == "AshRing" then
		self:TelegraphCircle(active, root.Position, 32 + phase * 2, delaySeconds, ability, 1.05, 10)
	elseif ability == "FallingEmbers" then
		local positions = { targetPosition }
		for index = 1, 2 + phase do
			local angle = index * 2.399963
			local distance = 8 + index * 3
			table.insert(positions, targetPosition + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance))
		end
		self:CircleVolley(active, positions, 7, delaySeconds + 0.2, ability, 0.72, true)
	elseif ability == "ThunderDash" then
		local delta = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)
		if delta.Magnitude < 1 then delta = root.CFrame.LookVector end
		local finish = root.Position + delta.Unit * math.min(65, math.max(18, delta.Magnitude))
		self:TelegraphLine(active, root.Position, finish, 12, delaySeconds * 0.75, ability, 1.25)
		if self:IsActive(active) then
			active.Model:PivotTo(CFrame.lookAt(finish, finish + delta.Unit))
		end
	elseif ability == "LightningPillars" then
		local positions = { targetPosition }
		for index = 1, 3 + phase do
			local angle = index * math.pi * 2 / (3 + phase)
			table.insert(positions, targetPosition + Vector3.new(math.cos(angle) * 17, 0, math.sin(angle) * 17))
		end
		self:CircleVolley(active, positions, 5.5, delaySeconds, ability, 0.82, true)
	elseif ability == "StormPrison" then
		self:TelegraphCircle(active, targetPosition, 18 + phase * 2, delaySeconds, ability, 0.8, nil, function(_, _, humanoid)
			self:ApplyControl(humanoid, 7, 2 + phase * 0.35)
		end)
	elseif ability == "RootSnare" then
		self:TelegraphCircle(active, targetPosition, 15 + phase * 2, delaySeconds, ability, 0.75, nil, function(_, _, humanoid)
			self:ApplyControl(humanoid, 4, 2.4 + phase * 0.35)
		end)
	elseif ability == "BloomBurst" then
		self:TelegraphCircle(active, root.Position, 30, delaySeconds, ability .. "Outer", 0.8, 12)
		if self:IsActive(active) then
			self:TelegraphCircle(active, root.Position, 13, 0.65, ability .. "Core", 0.8)
		end
	elseif ability == "AncientGuardians" then
		local positions = {}
		for index = 1, 3 + phase do
			local angle = index * math.pi * 2 / (3 + phase)
			table.insert(positions, targetPosition + Vector3.new(math.cos(angle) * 12, 0, math.sin(angle) * 12))
		end
		self:CircleVolley(active, positions, 8, delaySeconds + 0.15, ability, 0.75, true)
	elseif ability == "VoidCuts" then
		local baseDirection = Vector3.new(targetPosition.X - root.Position.X, 0, targetPosition.Z - root.Position.Z)
		if baseDirection.Magnitude < 1 then baseDirection = root.CFrame.LookVector end
		local baseAngle = math.atan2(baseDirection.Z, baseDirection.X)
		local damaged = {}
		local lines = {}
		for _, offset in { -0.32, 0, 0.32 } do
			local direction = Vector3.new(math.cos(baseAngle + offset), 0, math.sin(baseAngle + offset))
			local finish = root.Position + direction * 46
			table.insert(lines, { Start = root.Position, Finish = finish })
			self:SendTelegraph(active, { Shape = "Line", Position = (root.Position + finish) * 0.5, Start = root.Position, Finish = finish, Width = 8, Delay = delaySeconds, Kind = ability })
		end
		task.wait(delaySeconds)
		if self:IsActive(active) then
			for _, line in lines do
				self:DamageLine(line.Start, line.Finish, 8, active.Damage * 1.1, nil, damaged)
			end
		end
	elseif ability == "GravityWell" then
		self:TelegraphCircle(active, targetPosition, 25 + phase * 2, delaySeconds + 0.25, ability, 0.7, nil, function(_, playerRoot)
			local pull = targetPosition - playerRoot.Position
			local flat = Vector3.new(pull.X, 0, pull.Z)
			if flat.Magnitude > 1 then
				playerRoot.AssemblyLinearVelocity = flat.Unit * math.min(55, 22 + flat.Magnitude) + Vector3.new(0, 12, 0)
			end
		end)
	elseif ability == "ShadowClones" then
		local lines = {}
		for index = 1, 3 + phase do
			local angle = index * math.pi * 2 / (3 + phase)
			local startPosition = targetPosition + Vector3.new(math.cos(angle) * 32, 0, math.sin(angle) * 32)
			local finish = targetPosition - Vector3.new(math.cos(angle) * 8, 0, math.sin(angle) * 8)
			table.insert(lines, { Start = startPosition, Finish = finish })
			self:SendTelegraph(active, { Shape = "Line", Position = (startPosition + finish) * 0.5, Start = startPosition, Finish = finish, Width = 7, Delay = delaySeconds, Kind = ability })
		end
		task.wait(delaySeconds)
		if self:IsActive(active) then
			local damaged = {}
			for _, line in lines do
				self:DamageLine(line.Start, line.Finish, 7, active.Damage, nil, damaged)
			end
		end
	else
		self:TelegraphCircle(active, targetPosition, 18 + phase * 3, delaySeconds, ability, 1)
	end
end

function BossService:NearestPlayer(position, maxDistance)
	local nearest, distance
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root and humanoid and humanoid.Health > 0 then
			local current = (root.Position - position).Magnitude
			if current <= maxDistance and (not distance or current < distance) then
				nearest, distance = player, current
			end
		end
	end
	return nearest, distance
end

function BossService:RunAI(active)
	local nextAttack = 0
	while self.Active == active and active.Humanoid.Health > 0 do
		local root = active.Model.PrimaryPart
		local target, distance = self:NearestPlayer(root.Position, 180)
		if target then
			local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local delta = targetRoot.Position - root.Position
				local flat = Vector3.new(delta.X, 0, delta.Z)
				if flat.Magnitude > 12 then
					local step = math.min(flat.Magnitude - 10, active.Speed * 0.1)
					local nextPosition = root.Position + flat.Unit * step
					active.Model:PivotTo(CFrame.lookAt(nextPosition, Vector3.new(targetRoot.Position.X, nextPosition.Y, targetRoot.Position.Z)))
				end
				if os.clock() >= nextAttack then
					nextAttack = os.clock() + math.max(2.2, 5.2 - active.Phase * 0.65) / active.Mutator.Speed
					local ability = active.Definition.Abilities[self.Random:NextInteger(1, #active.Definition.Abilities)]
					local targetPosition = targetRoot.Position
					task.spawn(function()
						self:PerformAbility(active, ability, targetPosition)
					end)
				end
			end
		end
		task.wait(0.1)
	end
end

function BossService:TryPlayerHit(player, origin, range, damage)
	local active = self.Active
	if not active or active.Humanoid.Health <= 0 then
		return false
	end
	if (active.Model.PrimaryPart.Position - origin).Magnitude > range + active.Model.PrimaryPart.Size.X * 0.5 then
		return false
	end
	active.DamageByUser[player.UserId] = (active.DamageByUser[player.UserId] or 0) + damage
	active.Humanoid:TakeDamage(damage)
	self.Quests:Record(player, "BossDamage", damage)
	return true
end

function BossService:Spawn(bossId)
	local definition = BossConfig.Definitions[bossId]
	local mutator = self:SelectMutator()
	local tier = self:GetServerTier()
	local tierConfig = GameConfig.WorldTiers[tier]
	local model, humanoid = buildBossModel(bossId, definition)
	local health = math.floor(definition.BaseHealth * tierConfig.Health * mutator.Health * (1 + math.max(0, #Players:GetPlayers() - 1) * 0.45))
	humanoid.MaxHealth = health
	humanoid.Health = health
	model.Parent = workspace:WaitForChild("ShinobiWorld")
	local active = {
		Id = bossId,
		Definition = definition,
		Mutator = mutator,
		Tier = tier,
		Model = model,
		Humanoid = humanoid,
		Damage = math.floor(definition.BaseDamage * tierConfig.Damage * mutator.Damage),
		Speed = 22 * mutator.Speed,
		Phase = 1,
		DamageByUser = {},
		StartedAt = os.clock(),
	}
	self.Active = active

	humanoid.HealthChanged:Connect(function(healthNow)
		if self.Active ~= active then
			return
		end
		local ratio = healthNow / humanoid.MaxHealth
		local phase = ratio <= 0.35 and 3 or (ratio <= 0.7 and 2 or 1)
		if phase ~= active.Phase then
			active.Phase = phase
			active.Damage = math.floor(active.Damage * 1.18)
			active.Speed *= 1.12
		end
		self:BroadcastState()
	end)

	humanoid.Died:Once(function()
		if self.Active ~= active then
			return
		end
		self.Active = nil
		self:BroadcastState({ Defeated = true, Id = bossId, Name = definition.DisplayName })
		for _, player in Players:GetPlayers() do
			local contribution = active.DamageByUser[player.UserId] or 0
			if contribution >= humanoid.MaxHealth * 0.01 then
				self.Rewards:AwardBoss(player, bossId, mutator.Reward)
			end
		end
		task.delay(5, function()
			model:Destroy()
		end)
	end)

	self:BroadcastState({ Spawned = true, Tier = tier })
	task.spawn(function()
		self:RunAI(active)
	end)
	task.delay(GameConfig.BossTimeLimit, function()
		if self.Active == active then
			self.Active = nil
			self:BroadcastState({ Escaped = true })
			model:Destroy()
		end
	end)
end

function BossService:Start()
	task.spawn(function()
		task.wait(10)
		while true do
			if not self.Active then
				for remaining = GameConfig.BossIntermission, 1, -1 do
					if self.Active then
						break
					end
					if remaining % 5 == 0 or remaining <= 5 then
						self:BroadcastState({ Intermission = remaining })
					end
					task.wait(1)
				end
				if not self.Active then
					self.Cycle += 1
					local bossId = BossConfig.Order[(self.Cycle - 1) % #BossConfig.Order + 1]
					self:Spawn(bossId)
				end
			end
			task.wait(3)
		end
	end)

	RunService.Heartbeat:Connect(function()
		local active = self.Active
		if active and active.Model.Parent then
			local elapsed = os.clock() - active.StartedAt
			for _, child in active.Model:GetChildren() do
				if child.Name == "VoidBlade" then
					local root = active.Model.PrimaryPart
					local angle = elapsed * 0.8 + (child:GetAttribute("OrbitIndex") or 1) * math.pi / 2
					child.CFrame = CFrame.new(root.Position + Vector3.new(math.cos(angle) * 10, 3, math.sin(angle) * 10)) * CFrame.Angles(0, -angle, math.rad(35))
				end
			end
		end
	end)
end

return BossService
