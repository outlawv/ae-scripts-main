--[[
    Omni-directional Movement Script (Isometric Camera Fix)
    Supports WASD movement relative to camera direction and sprinting.
    Place this in: StarterPlayer > StarterPlayerScripts
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Movement variables
local sprinting = false
local WALK_SPEED = 14
local SPRINT_MULTIPLIER = 2.5
local keysDown = {}

-- Handle character respawn
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	rootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Input detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	keysDown[input.KeyCode] = true

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	keysDown[input.KeyCode] = false

	if input.KeyCode == Enum.KeyCode.LeftShift then
		sprinting = false
	end
end)

-- Update movement every frame
RunService.RenderStepped:Connect(function()
	if not rootPart or not humanoid then return end

	-- Get basic input direction from WASD keys
	local inputVector = Vector3.new(
		(keysDown[Enum.KeyCode.D] and 1 or 0) - (keysDown[Enum.KeyCode.A] and 1 or 0),
		0,
		(keysDown[Enum.KeyCode.S] and 1 or 0) - (keysDown[Enum.KeyCode.W] and 1 or 0)
	)

	if inputVector.Magnitude > 0 then
		inputVector = inputVector.Unit

		-- Adjust movement to match camera rotation
		local camCF = workspace.CurrentCamera.CFrame
		local camLook = camCF.LookVector
		local camYaw = math.atan2(camLook.X, camLook.Z)

		-- Rotate input vector by camera yaw
		local rotatedX = inputVector.X * math.cos(camYaw) - inputVector.Z * math.sin(camYaw)
		local rotatedZ = inputVector.X * math.sin(camYaw) + inputVector.Z * math.cos(camYaw)
		local moveDirection = Vector3.new(rotatedX, 0, rotatedZ)

		-- Apply sprint multiplier
		local speed = WALK_SPEED
		if sprinting then
			speed *= SPRINT_MULTIPLIER
		end

		rootPart.Velocity = moveDirection * speed
	else
		-- Stop moving if no input
		rootPart.Velocity = Vector3.zero
	end
end)
