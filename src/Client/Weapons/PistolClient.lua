local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local tool = script.Parent
local fireEvent = ReplicatedStorage:WaitForChild("FireBullet")

local StatResolver = require(ReplicatedStorage.WeaponSystems.StatResolver)

local equipped = false
local canFire = true
local isReloading = false
local currentAmmo = 0

local function getStat(stat)
	return StatResolver.GetStat(tool, stat)
end

local function reload()
	if isReloading then return end
	isReloading = true
	canFire = false

	local reloadTime = getStat("ReloadSpeed")
	task.wait(reloadTime)

	currentAmmo = getStat("MagazineCapacity")
	isReloading = false
	canFire = true
end

local function fire()
	if not equipped or not canFire or isReloading then return end
	if currentAmmo <= 0 then
		reload()
		return
	end

	local muzzle = tool:FindFirstChild("Muzzle")
	if not muzzle then return end

	-- Raycast direction
	local target = mouse.Hit.Position
	target = Vector3.new(target.X, muzzle.Position.Y, target.Z)
	local direction = (target - muzzle.Position).Unit

	fireEvent:FireServer(direction)

	currentAmmo -= 1
	canFire = false

	local delayBetweenShots = 60 / getStat("RateOfFire")
	task.delay(delayBetweenShots, function()
		canFire = true
	end)
end

tool.Equipped:Connect(function()
	equipped = true
	currentAmmo = getStat("MagazineCapacity")
end)

tool.Unequipped:Connect(function()
	equipped = false
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if not equipped or gameProcessed then return end

	local fireType = getStat("FireType")

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if fireType == "Auto" then
			while UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and equipped and not isReloading do
				fire()
				task.wait()
			end
		elseif fireType == "Semi" then
			fire()
		end
	elseif input.KeyCode == Enum.KeyCode.R then
		reload()
	end
end)
