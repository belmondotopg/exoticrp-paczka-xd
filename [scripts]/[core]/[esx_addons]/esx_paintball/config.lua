Config = {}

Config.Debug = false

Config.ScaleformDistance = 20.0

Config.MaxSessions = 100 + 15000
Config.MaxRounds = 25

Config.InviteTimeout = 15000
Config.RoundTimeout = math.ceil(60 * 5)
Config.HostTimeout = math.ceil(60 * 5)

Config.Hostpoint = vec4(-285.9919, -1918.6376, 29.9460, 157.3553)

Config.Arenas = {
	{ 
		label = "Bronie Krótkie (1v1)",
		weapons = {"WEAPON_PISTOL", "WEAPON_VINTAGEPISTOL", "WEAPON_COMBATPISTOL", "WEAPON_PISTOL_MK2", "WEAPON_SNSPISTOL_MK2", "WEAPON_SNSPISTOL"},
		ipl = false,
		hostpoint = vec4(-285.9919, -1918.6376, 29.9460, 157.3553),
		safezone = vector4(-3878.97, 7892.00, 698.27, 34.0),
		spawnpoints = {
			[1] = {
				vector4(-3908.02, 7891.44, 698.27, 270.37)
			},
			[2] = {
				vector4(-3855.99, 7893.35, 698.27, 90.29)
			}
		}
	},
	{ 
		label = "Bronie Krótkie (2v2)",
		weapons = {"WEAPON_PISTOL", "WEAPON_VINTAGEPISTOL", "WEAPON_COMBATPISTOL", "WEAPON_PISTOL_MK2", "WEAPON_SNSPISTOL_MK2", "WEAPON_SNSPISTOL"},
		ipl = false,
		hostpoint = vec4(-285.9919, -1918.6376, 29.9460, 157.3553),
		safezone = vector4(-3933.73, 7852.04, 698.49, 40.0),
		spawnpoints = {
			[1] = {
				vector4(-3955.18, 7830.66, 698.49, 315.37)
			},
			[2] = {
				vector4(-3913.39, 7873.97, 698.49, 132.45)
			}
		}
	},
	{ 
		label = "Bronie Krótkie (5v5)",
		weapons = {"WEAPON_PISTOL", "WEAPON_VINTAGEPISTOL", "WEAPON_COMBATPISTOL", "WEAPON_PISTOL_MK2", "WEAPON_SNSPISTOL_MK2", "WEAPON_SNSPISTOL"},
		ipl = false,
		hostpoint = vec4(-285.9919, -1918.6376, 29.9460, 157.3553),
		safezone = vector4(-3953.72, 7910.20, 698.25, 70.0),
		spawnpoints = {
			[1] = {
				vector4(-3913.12, 7950.02, 698.27, 137.77)
			},
			[2] = {
				vector4(-3994.06, 7867.47, 698.27, 316.10)
			}
		}
	}
}

Config.Weapons = {}

Config.KillMessages = {
	"zabija",
}

Config.Colors = {
	["3"] = vector3(0, 171, 11),
	["2"] = vector3(171, 105, 0),
	["1"] = vector3(117, 0, 0),
	["GO"] = vector3(3, 66, 161)
}

Config.OutfitRed = {
	male = {
		tshirt_1 = 15,  tshirt_2 = 0,
		torso_1 = 0,   torso_2 = 2,
		decals_1 = 0,   decals_2 = 0,
		arms = 0,		arms_2 = 0,
		pants_1 = 1,   pants_2 = 0,
		shoes_1 = 48,   shoes_2 = 0,
		mask_1 = 0,     mask_2 = 0,
		bags_1 = 0, bags_2 = 0,
		helmet_1 = -1,  helmet_2 = 0,
	},
	female = {
		tshirt_1 = 14,  tshirt_2 = 0,
		torso_1 = 0,   torso_2 = 2,
		decals_1 = 181,   decals_2 = 1,
		arms = 4,		arms_2 = 0,
		pants_1 = 2,   pants_2 = 1,
		shoes_1 = 49,   shoes_2 = 0,
		mask_1 = 169,    mask_2 = 13,
		bags_1 = 0, bags_2 = 0,
		helmet_1 = -1,  helmet_2 = 0,
	}
}

Config.OutfitBlue = {
	male = {
		tshirt_1 = 15,  tshirt_2 = 0,
		torso_1 = 0,   torso_2 = 3,
		decals_1 = 0,   decals_2 = 0,
		arms = 0,		arms_2 = 0,
		pants_1 = 1,   pants_2 = 0,
		shoes_1 = 48,   shoes_2 = 0,
		mask_1 = 0,     mask_2 = 0,
		bags_1 = 0, bags_2 = 0,
		helmet_1 = -1,  helmet_2 = 0,
	},
	female = {
		tshirt_1 = 14,  tshirt_2 = 0,
		torso_1 = 0,   torso_2 = 3,
		decals_1 = 181,   decals_2 = 1,
		arms = 4,		arms_2 = 0,
		pants_1 = 2,   pants_2 = 1,
		shoes_1 = 49,   shoes_2 = 0,
		mask_1 = 169,    mask_2 = 13,
		bags_1 = 0, bags_2 = 0,
		helmet_1 = -1,  helmet_2 = 0,
	}
}