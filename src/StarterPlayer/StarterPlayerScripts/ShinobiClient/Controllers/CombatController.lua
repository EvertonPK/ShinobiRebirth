local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CombatController = {}

function CombatController:Init(context)
	self.Remotes = context.Remotes
	self.Player = Players.LocalPlayer
end

function CombatController:Fire(action)
	local root = self.Player.Character and self.Player.Character:FindFirstChild("HumanoidRootPart")
	self.Remotes.CombatRequest:FireServer({
		Action = action,
		Direction = root and root.CFrame.LookVector or Vector3.zAxis,
	})
end

function CombatController:BindAction(name, keys, callback, title, position)
	ContextActionService:BindAction(name, function(_, state)
		if state == Enum.UserInputState.Begin then
			callback()
		end
		return Enum.ContextActionResult.Sink
	end, true, table.unpack(keys))
	ContextActionService:SetTitle(name, title)
	ContextActionService:SetPosition(name, position)
end

function CombatController:Start()
	self:BindAction("ShinobiLight", { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 }, function()
		self:Fire("Light")
	end, "ATACAR", UDim2.new(1, -120, 1, -170))
	self:BindAction("ShinobiHeavy", { Enum.KeyCode.F, Enum.KeyCode.ButtonL2 }, function()
		self:Fire("Heavy")
	end, "FORTE", UDim2.new(1, -220, 1, -115))
	self:BindAction("ShinobiDash", { Enum.KeyCode.Q, Enum.KeyCode.ButtonB }, function()
		local character = self.Player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local direction = humanoid and humanoid.MoveDirection.Magnitude > 0 and humanoid.MoveDirection or root.CFrame.LookVector
			self.Remotes.CombatRequest:FireServer({ Action = "Dash", Direction = direction })
		end
	end, "DASH", UDim2.new(1, -120, 1, -270))
	self:BindAction("ShinobiChakraBurst", { Enum.KeyCode.E, Enum.KeyCode.ButtonX }, function()
		self.Remotes.AbilityRequest:FireServer("ChakraBurst")
	end, "E", UDim2.new(1, -320, 1, -170))
	self:BindAction("ShinobiPhantomCuts", { Enum.KeyCode.R, Enum.KeyCode.ButtonY }, function()
		self.Remotes.AbilityRequest:FireServer("PhantomCuts")
	end, "R", UDim2.new(1, -320, 1, -270))
	self:BindAction("ShinobiClanAwakening", { Enum.KeyCode.T, Enum.KeyCode.DPadUp }, function()
		self.Remotes.AbilityRequest:FireServer("ClanAwakening")
	end, "T", UDim2.new(1, -420, 1, -220))

	if not UserInputService.TouchEnabled then
		for _, action in { "ShinobiLight", "ShinobiHeavy", "ShinobiDash", "ShinobiChakraBurst", "ShinobiPhantomCuts", "ShinobiClanAwakening" } do
			local button = ContextActionService:GetButton(action)
			if button then
				button.Visible = false
			end
		end
	end
end

return CombatController
