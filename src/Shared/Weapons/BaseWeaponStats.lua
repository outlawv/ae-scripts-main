local BaseStats = {
	Shotgun = {
		Damage = 12,
		Spread = 8,
		ReloadSpeed = 2.5,
		RateOfFire = 70,
		FireType = "Semi",
		MagazineCapacity = 6,
		DamageFalloff = {
			Start = 20,
			End = 45,
			MinMultiplier = 0.4,
		},
	},

	SMG = {
		Damage = 6,
		Spread = 3,
		ReloadSpeed = 1.8,
		RateOfFire = 800,
		FireType = "Auto",
		MagazineCapacity = 30,
		DamageFalloff = {
			Start = 30,
			End = 70,
			MinMultiplier = 0.6,
		},
	},

	Rifle = {
		Damage = 9,
		Spread = 2,
		ReloadSpeed = 2.2,
		RateOfFire = 600,
		FireType = "Auto",
		MagazineCapacity = 24,
		DamageFalloff = {
			Start = 40,
			End = 90,
			MinMultiplier = 0.7,
		},
	},
	
	Pistol = {
		Damage = 8,
		Spread = 1,
		ReloadSpeed = 1.5,
		RateOfFire = 400,
		FireType = "Semi",
		MagazineCapacity = 12,
		DamageFalloff = {
			Start = 8,
			End = 90,
			MinMultiplier = 0.7,
		},
	},
}

return BaseStats
