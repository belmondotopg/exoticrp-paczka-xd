Config                            = {}

Config.DrawDistance               = 10.0
Config.MaxInService               = -1
Config.NPCSpawnDistance           = 200.0
Config.NPCNextToDistance          = 25.0
Config.Vehicles = {
	'rhapsody',
	'asea',
	'asterope',
	'banshee',
	'buffalo'
}

Config.Blips = {
	Mechanic = {
		Pos = vector3(-347.6831, -129.7496, 39.0294),
		Sprite = 446,
		Color = 27,
		Label = "Los Santos Customs"
	},
	Ec = {
		Pos = vec3(747.02362060547, -1280.1943359375, 26.286104202271),
		Sprite = 446,
		Color = 47,
		Label = "Exotic Customs"
	},
}

Config.Zones = {
	['mechanik'] = {
		BossMenu = {
			coords = vec3(-322.28793334961, -137.18322753906, 43.213489532471),
			size = vec3(2.6, 1.2, 1.4),
			rotation = 340.0,
            icon = "fa-solid fa-people-roof",
            label = "Zarządzanie",
		},

		MechanicActions = {
			coords = vec3(-319.61633300781, -132.19374084473, 39.525020599365),
			size = vec3(1, 5.2, 1.95),
			rotation = 340.0,
			icon = "fa-solid fa-dolly",
            label = "Schowek",
		},

		VehicleSpawner = {
			coords = vec3(-348.5284, -111.8064, 39.4112),
			size = vec3(1.9, 0.75, 1.2),
			rotation = 340.0,
            icon = "fa-solid fa-truck-pickup",
            label = "Garaż",
		},
	},
	['ec'] = {
		BossMenu = {
			coords = vec3(756.45520019531, -1291.4423828125, 29.521518707275),
			size = vec3(2.6, 1.2, 1.4),
			rotation = 340.0,
            icon = "fa-solid fa-people-roof",
            label = "Zarządzanie",
		},

		MechanicActions = {
			coords = vec3(756.57446289062, -1295.7540283203, 26.284858703613),
			size = vec3(1, 5.2, 1.95),
			rotation = 340.0,
			icon = "fa-solid fa-dolly",
            label = "Schowek",
		},

		VehicleSpawner = {
			coords = vec3(733.64367675781, -1295.1536865234, 27.037073135376),
			size = vec3(1.9, 0.75, 1.2),
			rotation = 340.0,
            icon = "fa-solid fa-truck-pickup",
            label = "Garaż",
		},
	}
}

Config.Zones.Vehicles = {
	VehicleDeleter = {
		coords = vec3(-360.5054, -125.0504, 38.6996),
		type  = 28
	},

	VehicleDelivery = {
		coords = vec3(-371.1140, -107.7264, 38.6845),
		type  = 29
	},
}


Config.Uniforms = {
	[0] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 7,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 7,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 7,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 7
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 7,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 7,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 7,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 7
		}
	},
	[1] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 1,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 1,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 1,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 1
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 1,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 1,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 1,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 1
		}
	},
	[2] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 7,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 7,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 7,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 7
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 7,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 5,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 5,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 5
		}
	},
	[3] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 1,
			['torso_1'] = 495,   ['torso_2'] = 3,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 3,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		}
	},
	[4] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 495,   ['torso_2'] = 4,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 196,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 534,   ['torso_2'] = 4,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		}
	},
	[5] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 8,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 8,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 8,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 8
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 8,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 8,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 8,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 8
		}
	},
	[6] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 9,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 9,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 9,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 9
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 9,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 9,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 9,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 9
		}
	},
	[7] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 3,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 3,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 3,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 3,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 3
		}
	},
	[8] = {
		male = {
			['tshirt_1'] = 199,  ['tshirt_2'] = 0,
			['torso_1'] = 497,   ['torso_2'] = 4,
			['arms'] = 8,
			['pants_1'] = 180,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 195,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		},
		female = {
			['tshirt_1'] = 14,  ['tshirt_2'] = 0,
			['torso_1'] = 536,   ['torso_2'] = 4,
			['arms'] = 7,
			['pants_1'] = 194,   ['pants_2'] = 4,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = 194,  ['helmet_2'] = 4,
			['chain_1'] = 0,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0,
			['bags_1'] = 111,  ['bags_2'] = 4
		}
	},
}