return {
	{
		name = 'debug_crafting',
		items = {
			{
				name = 'lockpick',
				ingredients = {
					scrapmetal = 5,
					WEAPON_HAMMER = 0.05
				},
				duration = 15,
				count = 1,
			},
			{
				name = 'WEAPON_PETROLCAN',
				ingredients = {
					szmata = 1,
					scrapmetal = 4
				},
				duration = 15,
				count = 1,
			},
		},
		points = {
			vector3(-320.1464, -120.5012, 39.0099),
		},
        groups = {["mechanik"] = 0},
		zones = {
			{
				coords = vec3(-319.9, -119.85, 39.15),
				size = vec3(4.0, 1, 2.25),
				distance = 1.5,
				rotation = 340.0,
			},
		},
	},
}