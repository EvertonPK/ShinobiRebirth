local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MetaConfig = require(ReplicatedStorage.ShinobiShared.MetaConfig)

local CodeService = {}

local function normalize(value)
	if type(value) ~= "string" then
		return nil
	end
	value = value:upper():gsub("%s+", "")
	if #value < 3 or #value > 32 or not value:match("^[%w_]+$") then
		return nil
	end
	return value
end

function CodeService:Init(context)
	self.Profiles = context.Services.ProfileService
	self.Remotes = context.Remotes
	self.RateLimits = {}
end

function CodeService:Redeem(player, rawCode)
	local now = os.clock()
	if now < (self.RateLimits[player] or 0) then
		return
	end
	self.RateLimits[player] = now + 1
	local code = normalize(rawCode)
	local definition = code and MetaConfig.Codes[code]
	local profile = self.Profiles:Get(player)
	if not definition or not definition.Enabled or not profile then
		self.Remotes.CodeResult:FireClient(player, { Success = false, Message = "Código inválido ou inativo." })
		return
	end
	if profile.RedeemedCodes[code] then
		self.Remotes.CodeResult:FireClient(player, { Success = false, Message = "Este código já foi resgatado." })
		return
	end
	local granted = false
	self.Profiles:Mutate(player, function(data)
		if data.RedeemedCodes[code] then
			return
		end
		data.RedeemedCodes[code] = os.time()
		for currency, amount in definition.Reward do
			if type(data[currency]) == "number" and type(amount) == "number" and amount > 0 then
				data[currency] += math.floor(amount)
			end
		end
		granted = true
	end)
	self.Remotes.CodeResult:FireClient(player, {
		Success = granted,
		Message = granted and definition.Message or "Não foi possível resgatar o código.",
		Reward = granted and table.clone(definition.Reward) or nil,
	})
end

function CodeService:Start()
	self.Remotes.CodeRequest.OnServerEvent:Connect(function(player, code)
		self:Redeem(player, code)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.RateLimits[player] = nil
	end)
end

return CodeService
