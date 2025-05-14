--[[
    Slide Ability Script
    Press C to slide. Press LeftControl to toggle slide mode:
    - Mode 1: Slide in look direction (cursor)
    - Mode 2: Slide in movement direction (WASD)
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Settings
local SLIDE_SPEED = 80
local SLIDE_DURATION = 0.3
local SLIDE_COOLDOWN = 3

-- State
local lastSlideTime = 0
local slideMode = 1 -- 1 = Look Direction, 2 = Movement Direction
local keysDown = {}

-- Handle character respawn
player.CharacterAdded:Connect(function(char)
	character = char
	rootPart = char:WaitForChild("HumanoidRootPart")
	humanoid = char:WaitForChild("Humanoid")
end)

-- Toggle slide direction mode
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	keysDown[input.KeyCode] = true

	if input.KeyCode == Enum.KeyCode.LeftControl then
		slideMode = (slideMode == 1) and 2 or 1
		print("Slide Mode Toggled: " .. (slideMode == 1 and "Look Direction" or "Movement Direction"))
	end

	if input.KeyCode == Enum.KeyCode.C then
		trySlide()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	keysDown[input.KeyCode] = false
end)

-- Try to trigger slide
function trySlide()
	local currentTime = tick()
	if currentTime - lastSlideTime < SLIDE_COOLDOWN then
		print("Slide on cooldown")
		return
	end
	lastSlideTime = currentTime

	if not rootPart then
		print("No rootPart found")
		return
	end

	-- Determine slide direction
	local slideDir = Vector3.zero

	if slideMode == 1 then
		local mouse = player:GetMouse()
		local mouseHit = mouse.Hit
		if not mouseHit then
			print("No mouse.Hit detected")
			return
		end

		local targetPos = Vector3.new(mouseHit.X, rootPart.Position.Y, mouseHit.Z)
		slideDir = (targetPos - rootPart.Position).Unit
		print("SlideDir (Look):", slideDir)
	else
		local inputVector = Vector3.new(
			(keysDown[Enum.KeyCode.D] and 1 or 0) - (keysDown[Enum.KeyCode.A] and 1 or 0),
			0,
			(keysDown[Enum.KeyCode.S] and 1 or 0) - (keysDown[Enum.KeyCode.W] and 1 or 0)
		)

		if inputVector.Magnitude == 0 then
			print("No movement input")
			return
		end

		inputVector = inputVector.Unit

		local camCF = workspace.CurrentCamera.CFrame
		local camYaw = math.atan2(camCF.LookVector.X, camCF.LookVector.Z)

		local rotatedX = inputVector.X * math.cos(camYaw) - inputVector.Z * math.sin(camYaw)
		local rotatedZ = inputVector.X * math.sin(camYaw) + inputVector.Z * math.cos(camYaw)
		slideDir = Vector3.new(rotatedX, 0, rotatedZ)
		print("SlideDir (Movement):", slideDir)
	end

	-- Apply slide using BodyVelocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = slideDir * SLIDE_SPEED
	bodyVelocity.MaxForce = Vector3.new(1, 0, 1) * 1e5 -- Allow only horizontal movement
	bodyVelocity.P = 1e4
	bodyVelocity.Parent = rootPart

	print("Sliding with BodyVelocity:", bodyVelocity.Velocity)

	task.delay(SLIDE_DURATION, function()
		if bodyVelocity then
			bodyVelocity:Destroy()
		end
		print("Slide end.")
	end)
end
