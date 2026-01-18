Config                   = {}
Config.MarkerLegs        = { type = 21, x = 0.8, y = 0.8, z = 0.4, r = 255, g = 136, b = 0, a = 175, rotate = true }
Config.MarkerCar         = { type = 23, x = 4.0, y = 4.0, z = 4.0, r = 255, g = 136, b = 0, a = 175, rotate = false }
Config.MarkerLift        = { type = 21, x = 0.8, y = 0.8, z = 0.4, r = 255, g = 136, b = 0, a = 175, rotate = true }
Config.DrawDistance		 = 10
Config.Display			 = 2

Config.TeleportsLegs = {
	{ -- Psycholog
		From = vector3(-1011.39, -480.03, 39.97),
		To = vector3(-1002.94, -477.94, 49.13),
		Heading = 120.7
	},
	{ -- Psycholog
		From = vector3(-1002.94, -477.94, 50.03),
		To = vector3(-1011.39, -480.03, 39.07),
		Heading = 120.95
	},
}

Config.Lifts = { 
	{ -- LS Szpital
		{
			Coords = vector3(-664.2611, 326.1943, 78.1239),
			Label = "Piętro - [0]",
			Heading = 355.4572,
			Allow = {['police'] = true, ['ambulance'] = true}
		},
		{
			Coords = vector3(-664.2569, 326.2965, 83.0853),
			Label = "Piętro - [1]",
			Heading = 354.9337,
			Allow = {['police'] = true, ['ambulance'] = true}
		},
		{
			Coords = vector3(-664.2781, 326.3962, 88.0161),
			Label = "Piętro - [2]",
			Heading = 9.3695,
			Allow = {['police'] = true, ['ambulance'] = true}
		},
		{
			Coords = vector3(-664.2872, 326.4003, 92.7363),
			Label = "Piętro - [3]",
			Heading = 34.0220,
			Allow = {['police'] = true, ['ambulance'] = true}
		},
		{
			Coords = vector3(-664.2881, 326.5024, 140.1221),
			Label = "Piętro - [4]",
			Heading = 357.8998,
			Allow = {['police'] = true, ['ambulance'] = true}
		},
	},
	{ -- Dynasty 8
		{
			Coords = vector3(-1399.3136, -480.4728, 72.0421),
			Label = "Biuro",
			Heading = 266.6705,
		},
		{
			Coords = vector3(-1447.6016, -537.4580, 34.7402),
			Label = "Wejście",
			Heading = 211.3178,
		},
	},
	{ -- Urząd
		{
			Coords = vector3(334.4172, -1652.9071, 32.5358),
			Label = "Piętro - [0]",
			Heading = 140.9014,
		},
		{
			Coords = vector3(334.3692, -1652.8785, 38.5013),
			Label = "Piętro - [1]",
			Heading = 135.5807,
		},
		{
			Coords = vector3(334.3672, -1652.8907, 47.2399),
			Label = "Piętro - [2]",
			Heading = 136.9744,
		},
		{
			Coords = vector3(334.3011, -1652.9673, 54.5965),
			Label = "Piętro - [3]",
			Heading = 136.4781,
		},
	},
	{ -- RHPD
		{
			Coords = vector3(473.4098, -983.8162, 26.3861),
			Label = "Piętro - [1]",
			Heading = 87.9968,
		},
		{
			Coords = vector3(473.4811, -983.7485, 30.7104),
			Label = "Piętro - [2]",
			Heading = 90.7458,
		},
		{
			Coords = vector3(473.2396, -983.6736, 35.6839),
			Label = "Piętro - [3]",
			Heading = 91.1516,
		},
		{
			Coords = vector3(473.2587, -983.6057, 43.6922),
			Label = "Piętro - [4]",
			Heading = 91.6956,
		},
	},
	{ -- LS Szpital
		{
			Coords = vector3(110.0334, -736.2807, 33.1332),
			Label = "Piętro - [-1]",
			Heading = 338.5697,
			Allow = {['police'] = true, ['sheriff'] = true}
		},
		{
			Coords = vector3(136.0833, -761.8912, 45.7520),
			Label = "Piętro - [0]",
			Heading = 154.9222,
			Allow = {['police'] = true, ['sheriff'] = true}
		},
		{
			Coords = vector3(136.0355, -761.8199, 242.1518),
			Label = "Piętro - [49]",
			Heading = 163.6056,
			Allow = {['police'] = true, ['sheriff'] = true}
		},
	},
	{ -- Aukcje
		{
			Coords = vector3(-305.0185, -721.0445, 28.0286),
			Label = "Garaż",
			Heading = 156.3339,
		},
		{
			Coords = vector3(-288.2355, -722.6833, 125.4733),
			Label = "Apartament",
			Heading = 255.8208,
		},
	},
}