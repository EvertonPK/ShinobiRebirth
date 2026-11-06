local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local VFXController = {}

function VFXController:Init(context)
	self.Remotes = context.Remotes
end

function VFXController:Telegraph(data)
	if type(data) ~= "table" or typeof(data.Position) ~= "Vector3" then
		return
	end
	local delaySeconds = math.clamp(tonumber(data.Delay) or 1, 0.1, 5)
	local color = typeof(data.Color) == "Color3" and data.Color or Color3.fromRGB(255, 74, 74)
	if data.Shape == "Line" and typeof(data.Start) == "Vector3" and typeof(data.Finish) == "Vector3" then
		local delta = data.Finish - data.Start
		local flat = Vector3.new(delta.X, 0, delta.Z)
		if flat.Magnitude < 0.5 then
			return
		end
		local midpoint = (data.Start + data.Finish) * 0.5 - Vector3.new(0, 2.6, 0)
		local line = Instance.new("Part")
		line.Name = "BossLineTelegraph"
		line.Size = Vector3.new(math.max(2, tonumber(data.Width) or 8), 0.18, flat.Magnitude)
		line.CFrame = CFrame.lookAt(midpoint, midpoint + flat.Unit)
		line.Color = color
		line.Material = Enum.Material.Neon
		line.Transparency = 0.58
		line.Anchored = true
		line.CanCollide = false
		line.CanQuery = false
		line.Parent = workspace
		TweenService:Create(line, TweenInfo.new(delaySeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 0.12,
		}):Play()
		task.delay(delaySeconds, function()
			if line.Parent then
				line.Transparency = 0
				TweenService:Create(line, TweenInfo.new(0.2), { Transparency = 1 }):Play()
			end
		end)
		Debris:AddItem(line, delaySeconds + 0.3)
		return
	end

	local disc = Instance.new("Part")
	disc.Name = "BossTelegraph"
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(0.18, 1, 1)
	disc.CFrame = CFrame.new(data.Position - Vector3.new(0, 2.6, 0)) * CFrame.Angles(0, 0, math.rad(90))
	disc.Color = color
	disc.Material = Enum.Material.Neon
	disc.Transparency = 0.5
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanQuery = false
	disc.Parent = workspace
	local diameter = math.max(2, (data.Radius or 10) * 2)
	TweenService:Create(disc, TweenInfo.new(delaySeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.18, diameter, diameter),
		Transparency = 0.15,
	}):Play()
	if data.Shape == "Ring" and tonumber(data.InnerRadius) and data.InnerRadius > 0 then
		local safe = Instance.new("Part")
		safe.Name = "BossTelegraphSafeZone"
		safe.Shape = Enum.PartType.Cylinder
		local safeDiameter = math.max(1, data.InnerRadius * 2)
		safe.Size = Vector3.new(0.2, safeDiameter, safeDiameter)
		safe.CFrame = disc.CFrame + Vector3.new(0, 0.05, 0)
		safe.Color = Color3.fromRGB(65, 218, 151)
		safe.Material = Enum.Material.Neon
		safe.Transparency = 0.35
		safe.Anchored = true
		safe.CanCollide = false
		safe.CanQuery = false
		safe.Parent = workspace
		TweenService:Create(safe, TweenInfo.new(delaySeconds), { Transparency = 0.12 }):Play()
		task.delay(delaySeconds, function()
			if safe.Parent then
				TweenService:Create(safe, TweenInfo.new(0.2), { Transparency = 1 }):Play()
			end
		end)
		Debris:AddItem(safe, delaySeconds + 0.3)
	end
	task.delay(delaySeconds, function()
		if disc.Parent then
			disc.Transparency = 0
			TweenService:Create(disc, TweenInfo.new(0.2), { Transparency = 1 }):Play()
		end
	end)
	Debris:AddItem(disc, delaySeconds + 0.3)
end

function VFXController:Hit(data)
	if data.Action == "Ability" and typeof(data.Origin) == "Vector3" then
		local wave = Instance.new("Part")
		wave.Shape = Enum.PartType.Ball
		wave.Size = Vector3.new(2, 2, 2)
		wave.CFrame = CFrame.new(data.Origin)
		wave.Color = data.Color or Color3.fromRGB(100, 170, 255)
		wave.Material = Enum.Material.Neon
		wave.Transparency = 0.35
		wave.Anchored = true
		wave.CanCollide = false
		wave.CanQuery = false
		wave.Parent = workspace
		local size = math.max(4, (data.Range or 12) * 2)
		TweenService:Create(wave, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(size, size, size),
			Transparency = 1,
		}):Play()
		Debris:AddItem(wave, 0.4)
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local start = camera.CFrame
	local magnitude = data.Action == "Heavy" and 0.28 or 0.11
	task.spawn(function()
		for _ = 1, 5 do
			RunService.RenderStepped:Wait()
			camera.CFrame = start * CFrame.new(Random.new():NextNumber(-magnitude, magnitude), Random.new():NextNumber(-magnitude, magnitude), 0)
		end
		camera.CFrame = start
	end)
end

function VFXController:Start()
	self.Remotes.BossTelegraph.OnClientEvent:Connect(function(data)
		self:Telegraph(data)
	end)
	self.Remotes.CombatFeedback.OnClientEvent:Connect(function(data)
		self:Hit(data)
	end)
end

return VFXController
