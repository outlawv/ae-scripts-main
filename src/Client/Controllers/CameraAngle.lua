--[[
    Isometric Camera Script
    Places the camera above and behind the player at a fixed angle.
    Author: ChatGPT

    Place this script in: StarterPlayer > StarterPlayerScripts
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Constants
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cameraDistance = 25     -- Distance from the player
local cameraHeight = 20       -- Height above the player
local cameraAngle = Vector3.new(-42, 45, 0) -- Rotation in degrees (X, Y, Z)

-- Function to get the character (waits if needed)
local function getCharacter()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return player.Character
	end

	-- Wait for character to spawn
	player.CharacterAdded:Wait()
	return player.Character
end

-- Initialize the camera
camera.CameraType = Enum.CameraType.Scriptable -- We control the camera with code

RunService.RenderStepped:Connect(function()
	local character = getCharacter()
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Calculate the desired camera position
	local offset = CFrame.Angles(
		math.rad(cameraAngle.X),
		math.rad(cameraAngle.Y),
		math.rad(cameraAngle.Z)
	)

	-- Position the camera behind and above the player
	local cameraCFrame = CFrame.new(root.Position) * offset * CFrame.new(0, cameraHeight, cameraDistance)

	-- Set the camera to look at the player
	camera.CFrame = CFrame.new(cameraCFrame.Position, root.Position)
end)
