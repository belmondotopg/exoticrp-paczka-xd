Config                            = {}
Config.DrawDistance               = 10.0
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.MedicToRemoveItems 		  = 3
Config.RespawnPlaceLOSSANTOS = vector3(282.7317, -580.4449, 43.2672)
Config.RespawnPlaceSANDY = vector3(1772.0236, 3632.1248, 34.6628)

Config.Blips = {
	{
        Pos     = vector3(1155.1768, -1528.2946, 34.8434), -- LS
        Sprite  = 61,
        Display = 4,
        Scale   = 0.9,
        Colour  = 19,
        Label   = "Szpital"
    },
	{
		Pos     = vector3(-252.9706, 6332.9673, 32.4273), -- PALETO
		Sprite  = 61,
		Display = 4,
		Scale   = 0.9,
		Colour  = 19,
		Label 	= "Szpital"
	},
}

Config.Blips.Boats = {
	{
		Pos     = vector3(-1622.3804, -1171.5345, 1.3768), -- LS
		Sprite  = 489,
		Display = 4,
		Scale   = 0.9,
		Colour  = 19,
		Label 	= "Port EMS"
	},
	{
		Pos     = vector3(1414.2546, 3821.2368, 32.1172), -- sandy
		Sprite  = 489,
		Display = 4,
		Scale   = 0.9,
		Colour  = 19,
		Label 	= "Port EMS"
	},
	{
		Pos     = vector3(-284.1506, 6632.3506, 7.3861), -- paleto
		Sprite  = 489,
		Display = 4,
		Scale   = 0.9,
		Colour  = 19,
		Label 	= "Port EMS"
	},
}

Config.Ambulance = {
	Cloakrooms = { 
		{ -- LS
			coords = vec3(1142.0, -1539.75, 35.0),
			size = vec3(0.5, 1.05, 2.45),
			rotation = 0.0,
            icon = "fa-solid fa-truck-pickup",
            label = "Szatnia",
		},
		{ -- PALETO
			coords = vec3(-252.6661, 6337.1650, 32.4146),
			size = vec3(1.2, 0.45, 1.9),
			rotation = 231.5,
			icon = "fa-solid fa-truck-pickup",
			label = "Szatnia",
		},
	},

	CloakroomsPrivate = {
		{ -- LS
			coords = vec3(1138.7938232422, -1538.1134033203, 35.032943725586),
			size = vec3(0.5, 1.05, 2.45),
			rotation = 0.0,
			icon = "fa-solid fa-truck-pickup",
			label = "Szatnia prywatna",
		},
		{ -- PALETO
			coords = vec3(-252.6661, 6337.1650, 32.4146),
			size = vec3(1.2, 0.45, 1.9),
			rotation = 231.5,
			icon = "fa-solid fa-truck-pickup",
			label = "Szatnia prywatna",
		},
	},
	
	Inventories = {  
		{ -- LS
			coords = vec3(1135.85, -1542.5, 34.9),
			size = vec3(1.7, 0.2, 1.75),
			rotation = 0.0,
            icon = "fa-solid fa-truck-pickup",
            label = "Schowek",
		},
		{ -- PALETO
			coords = vec3(-252.0463, 6309.8735, 32.4273),
			size = vec3(2.6, 0.60000000000001, 2.55),
			rotation = 0.0,
			icon = "fa-solid fa-truck-pickup",
			label = "Schowek",
		},
	},

	InventoriesHC = {  
		{ -- LS
			coords = vec3(1117.3, -1561.3, 39.6),
			size = vec3(1.75, 0.55, 2.3),
			rotation = 269.75,
            icon = "fa-solid fa-truck-pickup",
            label = "Schowek HC",
		},
		{ -- PALETO
			coords = vec3(-255.3387, 6313.2549, 32.4273),
			size = vec3(1.75, 0.55, 2.3),
			rotation = 269.75,
			icon = "fa-solid fa-truck-pickup",
			label = "Schowek HC",
		},
	},

	BossActions = {
		{ -- LS
			coords = vec3(1119.2, -1563.4, 39.4),
			size = vec3(2.15, 0.65, 0.4),
			rotation = 269.75,
			icon = "fa-solid fa-truck-pickup",
			label = "Zarządzanie",
		},
		{ -- PALETO
			coords = vec3(-255.6400, 6306.5444, 33.2203),
			size = vec3(1.1, 2.15, 0.25),
			rotation = 321.0,
			icon = "fa-solid fa-truck-pickup",
			label = "Zarządzanie",
		},
	},
}
Config.Ambulance.Cars = {
    Vehicles = { 
        { -- LS
            coords = vector3(1163.2030, -1539.9563, 39.4010),
            spawnPoint = vector3(1171.1395, -1546.1863, 39.4007 - 0.95),
            heading = 273.0868
        },
		{ -- LS Pod autobus
			coords = vector3(323.9745, -558.8085, 28.7434),
			spawnPoint = vector3(328.4852, -548.0084, 28.7435 - 0.95),
			heading = 278.5282
		},
		{ -- LS garaż
			coords = vec3(1133.7974853516, -1580.2094726562, 34.864028930664),
			spawnPoint = vector3(1135.7689, -1588.7355, 34.7208 - 0.95),
			heading = 180.1750
		},
		{ -- PALETO
			coords = vector3(-261.4927, 6330.7744, 32.4221),
			spawnPoint = vector3(-264.8772, 6336.1699, 32.3464 - 0.95),
			heading = 314.3346
		},
    },

    Boats = {
        { -- ls 
            coords = vector3(-1622.3806, -1171.5443, 1.3820),
            spawnPoint = vector3(-1634.5243, -1167.8956, 4.9276),
            heading = 137.1882
        },
        { --sandy
            coords = vector3(1414.2546, 3821.2368, 32.1172),
            spawnPoint = vector3(1449.6888, 3835.2834, 29.5292),
            heading = 172.7509
        },
        { --paleto
            coords = vector3(-284.1506, 6632.3506, 7.3861),
            spawnPoint = vector3(-291.3105, 6642.9648, -0.6945),
            heading = 23.8180
        },
    },

    Helicopters = {
        { -- LS
            coords = vector3(1179.9054, -1546.1884, 39.4012),
            spawnPoint = vector3(1186.0925, -1552.5062, 39.4012),
            heading = 182.1221
        },
		{ -- PALETO
			coords = vector3(-260.4318, 6313.8130, 37.6170),
			spawnPoint = vector3(-254.3477, 6320.9678, 39.6594),
			heading = 236.9133
		},
    },
 
    VehicleFix = {},
    VehicleAddons = {
        { -- LS
            coords = vector3(1171.1395, -1546.1863, 39.4007),
        },
		{ -- PALETO
			coords = vector3(-264.8772, 6336.1699, 32.3464),
		},
    },
    VehicleDeleters = { 
        { -- LS
            coords = vector3(1171.1395, -1546.1863, 39.4007),
        },
		{ -- LS HELI
			coords = vector3(1186.0925, -1552.5062, 39.4012),
		},
		{ -- PALETO
			coords = vector3(-264.8772, 6336.1699, 32.3464),
		},
		{ -- PALETO HELI
			coords = vector3(-254.3477, 6320.9678, 39.6594),
		},
    },
}
 
Config.VehicleGroups = {
	'PATROL', -- 1
	'TRANSPORT', -- 2
	'DODATKOWE', -- 3
}

Config.AuthorizedVehicles = {
	{
		grade = 0,
		model = 'emsnspeedo',
        label = 'Karetka',
        groups = {2},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
	},
    {
        grade = 0,
        model = 'vc_emsbuffalosx',
        label = 'Buffalo SX',
        groups = {3},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
    },
    {
        grade = 2,
        model = 'vc_emsaleutian',
        label = 'Aleutian',
        groups = {3},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
    },
    {
        grade = 2,
        model = 'vc_emscastigator',
        label = 'Castigator',
        groups = {3},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
    },
    {
        grade = 3,
        model = 'vc_emsschyster',
        label = 'Schyster',
        groups = {1},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
    },
    {
        grade = 3,
        model = 'vc_emsscout',
        label = 'Scout',
        groups = {1},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
    },
    {
        grade = 3,
        model = 'vc_emstorrence',
        label = 'BMW M5',
        groups = {1},
        livery = 0,
        extrason = {1,2,3,4,5,6},
        extrasoff = {},
    },
}

Config.AuthorizedHeli = {
    {
       model = 'buzzard',
       label = 'Helikopter',
       livery = 0,
    },
}

Config.AuthorizedBoats = {
	{
		model = 'dinghy',
		label = 'Łódź'
	},
}