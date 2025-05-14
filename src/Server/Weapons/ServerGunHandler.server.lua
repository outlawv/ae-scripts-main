local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fireEvent = ReplicatedStorage:WaitForChild("FireBullet")

local StatResolver = require(ReplicatedStorage.WeaponSystems.StatResolver)

fireEvent.OnServerEvent:Connect(function(player, shootDirection)
	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then return end
	local weaponStats = {
		Damage = StatResolver.GetStat(tool, "Damage"),
		Spread = StatResolver.GetStat(tool, "Spread"),
	}

	local falloffData = require(ReplicatedStorage.WeaponSystems.BaseWeaponStats)[tool:GetAttribute("Class")].DamageFalloff


	local muzzle = tool:FindFirstChild("Muzzle")
	if not muzzle or not muzzle:IsA("BasePart") then return end

	local shootOrigin = muzzle.Position

	-- Flatten direction to horizontal only
	local flat = Vector3.new(shootDirection.X, 0, shootDirection.Z).Unit

	-- Horizontal-only spread
	local right = Vector3.new(-flat.Z, 0, flat.X)
	local spreadAmount = math.rad(weaponStats.Spread or 0)
	local offset = right * (math.random() - 0.5) * 2 * spreadAmount

	local finalDirection = (flat + offset).Unit * 1000



	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character, tool}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(shootOrigin, finalDirection, rayParams)

	if result then
		print("Ray hit:", result.Instance:GetFullName(), "at position:", result.Position)

		-- 🔴 TEMP DEBUG: Visualize ray hit path
		local visualRay = Instance.new("Part")
		visualRay.Anchored = true
		visualRay.CanCollide = false
		visualRay.Material = Enum.Material.Neon
		visualRay.BrickColor = BrickColor.new("Really red")

		local origin = shootOrigin
		local hitPoint = result.Position
		local distance = (hitPoint - origin).Magnitude

		visualRay.Size = Vector3.new(0.1, 0.1, distance)
		visualRay.CFrame = CFrame.new(origin, hitPoint) * CFrame.new(0, 0, -distance / 2)
		visualRay.Parent = workspace

		game:GetService("Debris"):AddItem(visualRay, 0.15)

		-- ✅ Check for humanoid
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		if model then
			local distance = (result.Position - shootOrigin).Magnitude

			-- Damage falloff
			local falloffStart = falloffData.Start
			local falloffEnd = falloffData.End
			local minMultiplier = falloffData.MinMultiplier

			local multiplier
			if distance <= falloffStart then
				multiplier = 1
			elseif distance >= falloffEnd then
				multiplier = minMultiplier
			else
				local ratio = (distance - falloffStart) / (falloffEnd - falloffStart)
				multiplier = 1 - ratio * (1 - minMultiplier)
			end

			local finalDamage = weaponStats.Damage * multiplier

			local model = result.Instance:FindFirstAncestorOfClass("Model")
			if model then
				local humanoid = model:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid:TakeDamage(finalDamage)
				end
			end
		end

	else
		print("Ray hit nothing.")

		-- 🔴 TEMP DEBUG: Visualize ray miss path
		local visualRay = Instance.new("Part")
		visualRay.Anchored = true
		visualRay.CanCollide = false
		visualRay.Material = Enum.Material.Neon
		visualRay.BrickColor = BrickColor.new("Really red")

		local origin = shootOrigin
		local distance = 1000 -- full ray length

		visualRay.Size = Vector3.new(0.1, 0.1, distance)
		visualRay.CFrame = CFrame.new(origin, origin + shootDirection) * CFrame.new(0, 0, -distance / 2)
		visualRay.Parent = workspace

		game:GetService("Debris"):AddItem(visualRay, 0.15)
	end
end)
