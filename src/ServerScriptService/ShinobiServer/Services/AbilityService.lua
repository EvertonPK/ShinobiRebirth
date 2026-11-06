local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityConfig = require(ReplicatedStorage.ShinobiShared.AbilityConfig)

local AbilityService = {}

function AbilityService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Combat = context.Services.CombatService
	self.Progression = context.Services.ProgressionService
	self.Bosses = context.Services.BossService
	self.Enemies = context.Services.EnemyService
	self.Remotes = context.Remotes
	self.Cooldowns = {}
end

function AbilityService:Cast(player, abilityId)
	local config = AbilityConfig[abilityId]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not config or not root or not humanoid or humanoid.Health <= 0 then
		return
	end
	local profile = self.Profiles:Get(player)
	if not profile then
		return
	end
	local state = self.Cooldowns[player] or {}
	self.Cooldowns[player] = state
	if os.clock() < (state[abilityId] or 0) then
		return
	end
	local chakra = character:GetAttribute("Chakra") or 0
	if chakra < config.Cost then
		return
	end
	state[abilityId] = os.clock() + config.Cooldown
	character:SetAttribute("Chakra", chakra - config.Cost)
	local damage = self.Combat:DamageFor(player, config.Multiplier, "Ninjutsu")
	local hit = self.Bosses:TryPlayerHit(player, root.Position, config.Range, damage)
	if not hit then
		hit = self.Enemies:TryPlayerHit(player, root.Position, config.Range, damage)
	end
	if hit then
		self.Progression:AddMastery(player, "Ninjutsu", math.clamp(config.Multiplier * 0.06, 0.1, 0.4))
	end
	self.Remotes.CombatFeedback:FireAllClients({
		Action = "Ability",
		Ability = abilityId,
		Origin = root.Position,
		Range = config.Range,
		Color = config.Color,
		Damage = hit and damage or 0,
	})
end

function AbilityService:Start()
	self.Remotes.AbilityRequest.OnServerEvent:Connect(function(player, abilityId)
		if type(abilityId) == "string" and #abilityId <= 32 then
			self:Cast(player, abilityId)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.Cooldowns[player] = nil
	end)
	task.spawn(function()
		while task.wait(0.5) do
			for _, player in Players:GetPlayers() do
				local character = player.Character
				if character then
					local current = character:GetAttribute("Chakra")
					local maximum = character:GetAttribute("MaxChakra")
					if type(current) == "number" and type(maximum) == "number" and current < maximum then
						character:SetAttribute("Chakra", math.min(maximum, current + maximum * 0.025))
					end
				end
			end
		end
	end)
end

return AbilityService
