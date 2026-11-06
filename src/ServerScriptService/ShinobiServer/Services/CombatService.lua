local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.ShinobiShared.GameConfig)
local Util = require(ReplicatedStorage.ShinobiShared.Util)

local CombatService = {}

function CombatService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Progression = context.Services.ProgressionService
	self.Quests = context.Services.QuestService
	self.Bosses = context.Services.BossService
	self.Enemies = context.Services.EnemyService
	self.Remotes = context.Remotes
	self.Cooldowns = {}
end

function CombatService:CanAct(player, action, cooldown)
	local now = os.clock()
	local state = self.Cooldowns[player]
	if not state then
		state = {}
		self.Cooldowns[player] = state
	end
	if now < (state[action] or 0) then
		return false
	end
	state[action] = now + cooldown
	return true
end

function CombatService:DamageFor(player, multiplier, masteryName)
	local profile = self.Profiles:Get(player)
	if not profile then
		return 0
	end
	local base = 12 + profile.Level * 1.8 + profile.Stats.Power * 4
	local mastery = self.Progression:GetMasteryMultiplier(player, masteryName or "Taijutsu")
	local rebirth = 1 + profile.Rebirths * 0.1
	return math.floor(base * mastery * rebirth * multiplier)
end

function CombatService:Attack(player, action)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root then
		return
	end
	local isHeavy = action == "Heavy"
	local cooldown = isHeavy and GameConfig.HeavyAttackCooldown or GameConfig.BasicAttackCooldown
	if not self:CanAct(player, action, cooldown) then
		return
	end
	local damage = self:DamageFor(player, isHeavy and 2.6 or 1)
	local range = GameConfig.BasicAttackRange + (isHeavy and 5 or 0)
	local hit = self.Bosses:TryPlayerHit(player, root.Position, range, damage)
	if not hit then
		hit = self.Enemies:TryPlayerHit(player, root.Position, range, damage)
	end
	if not hit then
		local world = workspace:FindFirstChild("ShinobiWorld")
		local training = world and world:FindFirstChild("TrainingGround")
		if training then
			for _, target in training:GetChildren() do
				if target:GetAttribute("CombatTarget") and (target.Position - root.Position).Magnitude <= range then
					local health = target:GetAttribute("Health") or 0
					target:SetAttribute("Health", math.max(0, health - damage))
					if health - damage <= 0 then
						target:SetAttribute("Health", target:GetAttribute("MaxHealth") or 500)
					end
					self.Quests:Record(player, "Training", 1)
					hit = true
					break
				end
			end
		end
	end
	if hit then
		self.Progression:AddMastery(player, "Taijutsu", isHeavy and 0.15 or 0.05)
		self.Quests:Record(player, "Damage", damage)
		self.Remotes.CombatFeedback:FireClient(player, { Action = action, Damage = damage })
	end
end

function CombatService:Dash(player, direction)
	if not self:CanAct(player, "Dash", GameConfig.DashCooldown) or typeof(direction) ~= "Vector3" then
		return
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root
		or not Util.IsFiniteNumber(direction.X)
		or not Util.IsFiniteNumber(direction.Y)
		or not Util.IsFiniteNumber(direction.Z)
		or direction.Magnitude < 0.1
	then
		return
	end
	local flat = Vector3.new(direction.X, 0, direction.Z)
	if flat.Magnitude < 0.1 then
		return
	end
	root.AssemblyLinearVelocity = flat.Unit * 70 + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
end

function CombatService:Start()
	self.Remotes.CombatRequest.OnServerEvent:Connect(function(player, request)
		if type(request) ~= "table" or type(request.Action) ~= "string" then
			return
		end
		if request.Action == "Light" or request.Action == "Heavy" then
			self:Attack(player, request.Action)
		elseif request.Action == "Dash" then
			self:Dash(player, request.Direction)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.Cooldowns[player] = nil
	end)
end

return CombatService
