local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("ShinobiShared")
local NetworkConfig = require(shared:WaitForChild("NetworkConfig"))

local remotes = ReplicatedStorage:FindFirstChild(NetworkConfig.FolderName)
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = NetworkConfig.FolderName
	remotes.Parent = ReplicatedStorage
end

for _, name in NetworkConfig.Events do
	if not remotes:FindFirstChild(name) then
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = remotes
	end
end

for _, name in NetworkConfig.Functions do
	if not remotes:FindFirstChild(name) then
		local fn = Instance.new("RemoteFunction")
		fn.Name = name
		fn.Parent = remotes
	end
end

local serviceFolder = script.Parent:WaitForChild("Services")
local order = {
	"ProfileService",
	"EconomyService",
	"AchievementService",
	"CodeService",
	"LeaderboardService",
	"WorldService",
	"ProgressionService",
	"CosmeticService",
	"ClanService",
	"RewardService",
	"QuestService",
	"LiveOpsService",
	"EnemyService",
	"CombatService",
	"AbilityService",
	"BossService",
}

local services = {}
for _, name in order do
	services[name] = require(serviceFolder:WaitForChild(name))
end

local context = {
	Remotes = remotes,
	Shared = shared,
	Services = services,
}

for _, name in order do
	local service = services[name]
	if service.Init then
		service:Init(context)
	end
end

for _, name in order do
	local service = services[name]
	if service.Start then
		local ok, err = xpcall(function()
			service:Start()
		end, debug.traceback)
		if not ok then
			warn(string.format("[ShinobiServer] %s failed to start:\n%s", name, err))
		end
	end
end

print("[ShinobiServer] Services initialized")
