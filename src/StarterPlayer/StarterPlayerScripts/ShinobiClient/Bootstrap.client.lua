local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("ShinobiRemotes")
local controllers = script.Parent:WaitForChild("Controllers")

local context = {
	Remotes = remotes,
	Shared = ReplicatedStorage:WaitForChild("ShinobiShared"),
}

local order = { "HudController", "VFXController", "CombatController", "ShopController", "MetaController" }
for _, name in order do
	local controller = require(controllers:WaitForChild(name))
	if controller.Init then
		controller:Init(context)
	end
	context[name] = controller
end

for _, name in order do
	local controller = context[name]
	if controller.Start then
		controller:Start()
	end
end
