local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local flyingPlayers = {}

local function startFlying(player)
	if flyingPlayers[player] then return end

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	local attachment = Instance.new("Attachment")
	attachment.Parent = root

	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.MaxForce = math.huge
	velocity.VectorVelocity = Vector3.zero
	velocity.Parent = root

	local orientation = Instance.new("AlignOrientation")
	orientation.Attachment0 = attachment
	orientation.RigidityEnabled = true
	orientation.MaxTorque = math.huge
	orientation.Parent = root

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if not flyingPlayers[player] then
			connection:Disconnect()
			return
		end

		local moveDir = humanoid.MoveDirection
		velocity.VectorVelocity = moveDir * 60

		if moveDir.Magnitude > 0 then
			orientation.CFrame = CFrame.lookAt(
				root.Position,
				root.Position + moveDir
			)
		end
	end)

	flyingPlayers[player] = {
		Attachment = attachment,
		Velocity = velocity,
		Orientation = orientation,
		Connection = connection
	}
end

local function stopFlying(player)
	local data = flyingPlayers[player]
	if not data then return end

	if data.Connection then data.Connection:Disconnect() end
	if data.Attachment then data.Attachment:Destroy() end
	if data.Velocity then data.Velocity:Destroy() end
	if data.Orientation then data.Orientation:Destroy() end

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end

	flyingPlayers[player] = nil
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		message = message:lower()

		if message == ":fly" then
			startFlying(player)
		elseif message == ":unfly" then
			stopFlying(player)
		end
	end)
end)
