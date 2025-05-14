-- Character Mouse Rotation Script (Fixed with Ray Offset for Isometric)
-- Rotates player toward cursor-projected target on XZ plane

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- Handle respawn
player.CharacterAdded:Connect(function(char)
	character = char
	rootPart = char:WaitForChild("HumanoidRootPart")
end)

RunService.RenderStepped:Connect(function()
	if not rootPart then return end

	local camera = workspace.CurrentCamera

	-- Shift ray origin forward to compensate for isometric angle
	local rawRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local origin = rawRay.Origin + camera.CFrame.LookVector * -19.6 -- tweak this number
	local direction = rawRay.Direction

	-- Project to the XZ plane (player's Y height)
	local yLevel = rootPart.Position.Y
	local t = (yLevel - origin.Y) / direction.Y
	local targetPosition = origin + direction * t

	-- Visual debug sphere (cursor projection marker)
	local marker = Instance.new("Part")
	marker.Anchored = true
	marker.CanCollide = false
	marker.Size = Vector3.new(0.3, 0.3, 0.3)
	marker.Shape = Enum.PartType.Ball
	marker.Material = Enum.Material.Neon
	marker.BrickColor = BrickColor.Red()
	-- Match height with player's aiming level (e.g., 2.5 studs up from rootPart)
	marker.Position = Vector3.new(targetPosition.X, rootPart.Position.Y + -1.6, targetPosition.Z)
	marker.Parent = workspace
	game:GetService("Debris"):AddItem(marker, 0.05)

	-- Calculate look direction and rotation
	local lookDirection = (targetPosition - rootPart.Position).Unit
	local flatFrame = CFrame.new(rootPart.Position, rootPart.Position + lookDirection)
	local _, y, _ = flatFrame:ToEulerAnglesYXZ()
	rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, y, 0)

	-- Debug line showing player facing direction
	local lineLength = 40
	local line = Instance.new("Part")
	line.Anchored = true
	line.CanCollide = false
	line.Size = Vector3.new(0.1, 0.1, lineLength)
	line.CFrame = CFrame.new(
		rootPart.Position + Vector3.new(0, 2.5, 0) + lookDirection * (lineLength / 2),
		rootPart.Position + Vector3.new(0, 2.5, 0) + lookDirection * lineLength
	)
	line.BrickColor = BrickColor.Red()
	line.Material = Enum.Material.Neon
	line.Parent = workspace
	game:GetService("Debris"):AddItem(line, 0.05)
end)
