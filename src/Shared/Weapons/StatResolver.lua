local BaseStats = require(script.Parent:WaitForChild("BaseWeaponStats"))

local StatResolver = {}

function StatResolver.GetStat(tool, statName)
	local weaponClass = tool:GetAttribute("Class")
	if not weaponClass then
		warn("Weapon missing Class attribute:", tool:GetFullName())
		return nil
	end

	local base = BaseStats[weaponClass]
	if not base then
		warn("No base stats found for class:", weaponClass)
		return nil
	end

	local baseValue = base[statName]
	local modValue = tool:GetAttribute(statName .. "Mod") or 0

	-- Handle nested tables (like DamageFalloff)
	if typeof(baseValue) == "table" then
		return baseValue
	end

	-- Handle strings (like FireType)
	if typeof(baseValue) == "string" then
		return baseValue
	end

	-- Default: numeric + modifier
	return baseValue + modValue
end

return StatResolver