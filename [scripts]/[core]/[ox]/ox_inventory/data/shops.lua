return {
	Jeweller = {
		name = 'Jubiler',
		blip = {
			id = 617, colour = 68, scale = 0.7
		}, inventory = {
			{ name = 'diamond_ring', price = 20000 },
			{ name = 'rolex', price = 15000 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(-623.2723, -229.9506, 38.057 - 1.0),
				heading = 211.38,
			},
		}
	},

	PoliceArmoury = {
		name = 'Magazyn [LSPD/LSSD]',
		groups = {
			['police'] = 0,
			['sheriff'] = 0,
		},
		inventory = {
			{ name = 'WEAPON_NIGHTSTICK', price = 0 },
			{ name = 'WEAPON_FLASHLIGHT', price = 0 },
			{ name = 'WEAPON_STUNGUN', price = 0, metadata = { registered = true, serial = 'POL'} },
			{ name = 'WEAPON_PISTOL', price = 0, metadata = { registered = true, serial = 'POL'}, grade = 1 },
			{ name = 'WEAPON_PDG19', price = 0, metadata = { registered = true, serial = 'POL'}, grade = 1 },
			{ name = 'ammo9', price = 0, grade = 1 },
			{ name = 'ammo-9', price = 0, grade = 1 },
			{ name = 'handcuffs', price = 0},
			{ name = 'nurek', price = 0 },
			{ name = 'gps', price = 0 },
			{ name = 'bodycam', price = 0},
			{ name = 'panic', price = 0 },
			{ name = 'radio', price = 0 },
			{ name = 'armour50pd', price = 0, grade = 1},
		}, 
		locations = {}, 
		targets = {
			{ -- VESPUCCI
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(-1036.6934814453, -824.42541503906, 10.951584815979),
				heading = 357.5107,
			},
			{ -- DAVIS
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(378.3544921875, -1632.4675292969, 29.759466171265),
				heading = 320.5107,
			},
			{ -- SANDY
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(1838.5085, 3682.8574, 38.9392 - 1.0),
				heading = 290.4835,
			},
			{ -- PALETO
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(-441.8851, 6020.7861, 31.490 - 1.0),
				heading = 223.4835,
			},

		}
	},

	HCArmoury = {
		name = 'Magazyn [LSPD/LSSD] HC',
		groups = {
			['police'] = 12,
			['sheriff'] = 12,
		},
		inventory = {
			{ name = 'WEAPON_COMBATPISTOL', price = 0, metadata = { registered = true, serial = 'POL' }, license = 'weapon' },
			--
			{ name = 'handcuffs', price = 0, },
			{ name = 'WEAPON_FLASHBANG', price = 0, },
			{ name = 'redbull', price = 0, },
			{ name = 'ammo9', price = 0, },
			--
			{ name = 'armour100pd', price = 0 },
			{ name = 'armour50pd', price = 0 },
			{ name = 'kaskswat', price = 0 },
			--
			{ name = 'at_flashlight', price = 0, }, -- Taktyczna latarka
			{ name = 'at_grip', price = 0 }, -- Uchwyt
			{ name = 'nadajnik_gps', price = 250000 },
		}, 
		locations = {}, 
		targets = {
			{ -- VESPUCCI
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(-1030.2143554688, -816.31604003906, 10.951588630676),
				heading = 355.3037,
			},
			{ -- DAVIS
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(383.2414855957, -1602.232421875, 25.361968994141),
				heading = 342.3037,
			},
			{ -- sandy
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(1835.8900, 3684.1055, 38.9293 - 1.0),
				heading = 302.8385,
			},
			{ -- PALETO
				ped = `s_m_y_cop_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(-445.2032, 6016.0513, 31.716 - 1.0),
				heading = 222.0684,
			},
		}
	},

	Medicine = {
		name = 'Magazyn EMS',
		groups = {
			['ambulance'] = 0
		},
		inventory = {
			{ name = 'medikit', price = 0 },
			{ name = 'bandage', price = 0 },
			{ name = 'radio', price = 0 },
			{ name = 'gps', price = 0 },
			{ name = 'bodycam', price = 0},
			{ name = 'nurek', price = 0 },
			{ name = 'panic', price = 0, grade = 0 },
			{ name = 'handcuffs', price = 0, grade = 5 },
		}, 
		locations = {
		}, 
		targets = {
			{ -- LS
				ped = `s_m_m_doctor_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(1137.5540, -1540.5123, 35.0330-.95),
				heading = 265.5857,
			},
			{ -- PALETO
				ped = `s_m_m_doctor_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(-252.8429, 6307.8530, 32.4272 - 1.0),
				heading =  53.8522
			},
		}
	},
	
	Mechanik = {
		name = 'Magazyn LSC',
		groups = {
			['mechanik'] = 0
		},
		inventory = {
			{ name = 'repair_kit', price = 0 },
			{ name = 'cleaningkit', price = 0 },
			{ name = 'gps', price = 0 },
			{ name = 'WEAPON_HAMMER', price = 0 },
			{ name = 'krotkofalowka', price = 0 },
			{ name = 'mechanic_tablet', price = 0 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(-323.8724, -141.2217, 39.5251-.9),
				heading = 340.6608,
			},
		}
	},

	MechanikParts = {
		name = 'Sklep z Częściami',
		groups = {
			['mechanik'] = 0
		},
		inventory = {
		-- { name = 'engine_oil', price = 0 },
		-- { name = 'tyre_replacement', price = 0 },
		-- { name = 'clutch_replacement', price = 0 },
		-- { name = 'air_filter', price = 0 },
		-- { name = 'spark_plug', price = 0 },
		-- { name = 'brakepad_replacement', price = 0 },
		-- { name = 'suspension_parts', price = 0 },

		-- Silniki
		{ name = 'i4_engine', price = 125000 },
		{ name = 'v6_engine', price = 350000 },
		{ name = 'v8_engine', price = 650000 },
		{ name = 'v12_engine', price = 900000 },

		-- -- Elektryczne napędy
		-- { name = 'ev_motor', price = 7000 },
		-- { name = 'ev_battery', price = 6500 },
		-- { name = 'ev_coolant', price = 1000 },

		-- Napęd
		{ name = 'awd_drivetrain', price = 200000 },
		{ name = 'rwd_drivetrain', price = 150000 },
		{ name = 'fwd_drivetrain', price = 150000 },

		-- Tuning
		{ name = 'slick_tyres', price = 45000 },
		{ name = 'semi_slick_tyres', price = 40000 },
		{ name = 'offroad_tyres', price = 47500 },

		{ name = 'drift_tuning_kit', price = 110000 },
		{ name = 'ceramic_brakes', price = 80000 },

		-- Kosmetyka
		{ name = 'lighting_controller', price = 70000 },
		-- { name = 'stancing_kit', price = 0 },
		{ name = 'cosmetic_part', price = 0 },
		{ name = 'respray_kit', price = 0 },
		{ name = 'vehicle_wheels', price = 0 },
		{ name = 'tyre_smoke_kit', price = 0 },
		{ name = 'bulletproof_tyres', price = 100000 },
		{ name = 'extras_kit', price = 0 },

		-- Nitro & czyszczenie
		{ name = 'nitrous_bottle', price = 300000 },
		-- { name = 'empty_nitrous_bottle', price = 500 },
		{ name = 'nitrous_install_kit', price = 500000 },
		{ name = 'cleaningkit', price = 0 },
		{ name = 'duct_tape', price = 0 },

		-- Performance
		{ name = 'performance_part', price = 10000 },

		-- Skrzynia biegów
		{ name = 'manual_gearbox', price = 25000 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(-326.9203, -127.5572, 39.0293-.95),
				heading = 119.804,
			},
		}
	},

		ExoticCustoms = {
		name = 'Magazyn ExoticCustoms',
		groups = {
			['ec'] = 0
		},
		inventory = {
			{ name = 'repair_kit', price = 0 },
			{ name = 'cleaningkit', price = 0 },
			{ name = 'gps', price = 0 },
			{ name = 'WEAPON_HAMMER', price = 0 },
			{ name = 'krotkofalowka', price = 0 },
			{ name = 'mechanic_tablet', price = 0 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(736.29901123047, -1294.6340332031, 26.284854888916-.9),
				heading = 315.34713745117,
			},
		}
	},

	ExoticCustomsParts = {
		name = 'Sklep z Częściami',
		groups = {
			['ec'] = 0
		},
		inventory = {
		-- Silniki
		{ name = 'i4_engine', price = 125000 },
		{ name = 'v6_engine', price = 350000 },
		{ name = 'v8_engine', price = 650000 },
		{ name = 'v12_engine', price = 900000 },

		-- Napęd
		{ name = 'awd_drivetrain', price = 200000 },
		{ name = 'rwd_drivetrain', price = 150000 },
		{ name = 'fwd_drivetrain', price = 150000 },

		-- Tuning
		{ name = 'slick_tyres', price = 45000 },
		{ name = 'semi_slick_tyres', price = 40000 },
		{ name = 'offroad_tyres', price = 47500 },

		{ name = 'drift_tuning_kit', price = 110000 },
		{ name = 'ceramic_brakes', price = 80000 },

		-- Kosmetyka
		{ name = 'lighting_controller', price = 70000 },
		-- { name = 'stancing_kit', price = 0 },
		{ name = 'cosmetic_part', price = 0 },
		{ name = 'respray_kit', price = 0 },
		{ name = 'vehicle_wheels', price = 0 },
		{ name = 'tyre_smoke_kit', price = 0 },
		{ name = 'bulletproof_tyres', price = 100000 },
		{ name = 'extras_kit', price = 0 },

		-- Nitro & czyszczenie
		{ name = 'nitrous_bottle', price = 300000 },
		{ name = 'nitrous_install_kit', price = 500000 },
		{ name = 'cleaning_kit', price = 0 },
		{ name = 'duct_tape', price = 0 },

		-- Performance
		{ name = 'performance_part', price = 10000 },

		-- Skrzynia biegów
		{ name = 'manual_gearbox', price = 25000 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(743.39019775391, -1279.4937744141, 26.287445068359-.95),
				heading = 357.53198242188,
			},
		}
	},

	Bolingbroke = {
		name = 'Bufet',
		inventory = {
			{ name = 'hamburger', price = 10 },
			{ name = 'water_bottle', price = 10 }
		}, locations = {
		}, targets = {
			{ 
				ped = `s_m_y_chef_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vec3(1779.5208, 2560.6865, 45.6731 - 1.0),
				heading = 173.38,
			},
		}
	},

	BlackMarketArms = {
		name = 'Handlarz',
		inventory = {
			{ name = 'WEAPON_PISTOL', price = 70000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_PISTOL_MK2', price = 90000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_COMBATPISTOL', price = 80000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_VINTAGEPISTOL', price = 75000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_SNSPISTOL', price = 65000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_SNSPISTOL_MK2', price = 85000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_HEAVYPISTOL', price = 100000, metadata = { registered = false }, currency = 'black_money' },
			-- { name = 'WEAPON_PISTOLXM3', price = 90000, metadata = { registered = false }, currency = 'black_money' },
			{ name = 'advancedlockpick', price = 10000, currency = 'money' },
			{ name = 'ammo-9', price = 300, currency = 'black_money' },
			{ name  = 'ammo9', price = 500, currency = 'black_money' },
			{ name  = 'spray_can', price = 5000, currency = 'black_money' },
			{ name  = 'spray_remover', price = 10000, currency = 'black_money' },
			{ name  = 'crime_tablet', price = 10000, currency = 'black_money' },
		}, locations = {
		}, targets = {
			{
				ped = `a_m_y_soucent_02`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(1247.9103, -2916.5264, 26.4571 -1.0),
				heading = 279.2617,
			},
		}
	},

	BlackMarketVangelico = {
		name = 'Handlarz',
		inventory = {
			{ name = 'WEAPON_BZGAS', price = 15000, metadata = { registered = false }, currency = 'black_money' },
			{ name = 'gasmask', price = 7500, currency = 'black_money' },
		}, locations = {
		}, targets = {
			{
				ped = `a_m_y_soucent_02`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(-2277.5193, 171.7595, 167.6016 -1.0),
				heading = 117.2617,
			},
		}
	},

	VendingMachineDrinks = {
		name = 'Automat',
		inventory = {
			{ name = 'water_bottle', price = 15 },
			{ name = 'bread', price = 20 },
		},
		model = {
			`prop_vend_soda_02`, `prop_vend_fridge01`, `prop_vend_water_01`, `prop_vend_soda_01`
		}
	},

	General = {
		name = 'Sklep 24/7',
		blip = {
			id = 59, colour = 2, scale = 0.7
		}, inventory = {
			{ name = 'water_bottle', price = 25 },
			{ name = 'chipsy', price = 35 },
			{ name = 'bread', price = 30 },
			{ name = 'cola', price = 30 },
			{ name = 'hamburger', price = 40 },
			{ name = 'icetea', price = 30 },
			{ name = 'sandwich', price = 35 },
			{ name = 'kawa_drink', price = 50 },
			{ name = 'redbull', price = 45 },
			{ name = 'cigarette', price = 20 },
			{ name = 'tost', price = 35 },
			{ name = 'snikkel_candy', price = 40 },
			{ name = 'twerks_candy', price = 40 },
			{ name = 'lighter', price = 15 },
			{ name = 'roza', price = 30 },
			{ name = 'kocyk', price = 50 },
			{ name = 'kocyk_zestaw', price = 80 },
			{ name = 'chocolate', price = 35 },
			{ name = 'beer', price = 80 },
			{ name = 'whiskey', price = 120 },
			{ name = 'vodka', price = 100 },
			{ name = 'scratchcardbasic', price = 1000 },
			{ name = 'scratchcardpremium', price = 2500 },
		}, locations = {
		}, targets = {
			{ -- 1/12
                ped = `a_m_y_busicas_01`,
                scenario = 'WORLD_HUMAN_AA_COFFEE',
                loc = vec3(-3038.2332, 585.1897, 7.9089-1),
                heading = 21.0285,
            },
			{ -- 2/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-3241.3728, 1000.3292, 12.8306-1),
				heading = 350.8888,
			},
			{ -- 3/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(548.5128, 2672.1870, 42.1564-1),
				heading = 98.9389,
			},
			{ -- 4/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1960.8992, 3739.4180, 32.3437-1),
				heading = 301.0316,
			},
			{ -- 5/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(24.8479, -1348.0630, 29.4970-1),
				heading = 262.7657,
			},
			{ -- 6/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(372.7585, 325.4783, 103.5664-1),
				heading = 255.1064,
			},
			{ -- 7/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(2678.9817, 3279.2847, 55.2410-1),
				heading = 332.2704,
			},
			{ -- 8/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1727.7747, 6414.1611, 35.0371-1),
				heading = 244.0154,
			},
			{ -- 9/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(160.2164, 6640.7466, 31.6989-1),
				heading = 221.4523,
			},
			{ -- 11/12
				ped = `a_m_y_busicas_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(2558.2026, 381.1581, 108.6228-1),
				heading = 359.5324,
			}
		}
	},

	Monopolowy = {
		name = 'Sklep Monopolowy',
		blip = {
			id = 59, colour = 1, scale = 0.7
		}, inventory = {
			{ name = 'water_bottle', price = 25 },
			{ name = 'chipsy', price = 35 },
			{ name = 'bread', price = 30 },
			{ name = 'cola', price = 30 },
			{ name = 'hamburger', price = 40 },
			{ name = 'icetea', price = 30 },
			{ name = 'sandwich', price = 35 },
			{ name = 'kawa_drink', price = 50 },
			{ name = 'redbull', price = 45 },
			{ name = 'cigarette', price = 20 },
			{ name = 'tost', price = 35 },
			{ name = 'snikkel_candy', price = 40 },
			{ name = 'twerks_candy', price = 40 },
			{ name = 'lighter', price = 15 },
			{ name = 'roza', price = 30 },
			{ name = 'kocyk', price = 50 },
			{ name = 'kocyk_zestaw', price = 80 },
			{ name = 'chocolate', price = 35 },
			{ name = 'beer', price = 80 },
			{ name = 'whiskey', price = 120 },
			{ name = 'vodka', price = 100 },
			{ name = 'scratchcardbasic', price = 1000 },
			{ name = 'scratchcardpremium', price = 2500 },
		}, locations = {
		}, targets = {
			{ -- 1/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-2966.2849, 392.5121, 15.0433-1),
				heading = 84.0688,
			},
			{ -- 2/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1164.1665, 2710.8677, 38.1577-1),
				heading = 177.1046,
			},
			{ -- 3/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1134.3943, -983.9752, 46.4158-1),
				heading = 272.3905,
			},
			{ -- 4/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1220.4941, -907.2835, 12.3263-1),
				heading = 33.3856,
			},
			{ -- 5/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1487.4694, -376.8400, 40.1634-1),
				heading = 131.2028,
			},
			{ -- 6/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1390.9501, 3605.6936, 34.9809-1),
				heading = 200.0692,
			},
			{ -- 6/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-340.6541, 7153.6704, 6.4016-1),
				heading = 270.5027,
			},
			{ -- 6/6
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-382.8769, 7206.9883, 18.2214-1),
				heading = 177.4763,
			},
		}
	},

	StacjaPaliw = {
		name = 'Stacja Paliw',
		blip = {
			id = 361, colour = 1, scale = 0.7
		}, inventory = {
			{ name = 'water_bottle', price = 30 },
			{ name = 'chipsy', price = 40 },
			{ name = 'bread', price = 35 },
			{ name = 'cola', price = 35 },
			{ name = 'hamburger', price = 45 },
			{ name = 'icetea', price = 35 },
			{ name = 'kawa_drink', price = 100 },
			{ name = 'sandwich', price = 40 },
			{ name = 'cigarette', price = 25 },
			{ name = 'snikkel_candy', price = 45 },
			{ name = 'twerks_candy', price = 45 },
			{ name = 'tost', price = 40 },
			{ name = 'scratchcardbasic', price = 1000 },
			{ name = 'scratchcardpremium', price = 2500 },
			{ name = 'lighter', price = 20 },
			{ name = 'roza', price = 35 },
			{ name = 'kocyk', price = 100 },
			{ name = 'kocyk_zestaw', price = 150 },
		}, locations = { 
		}, targets = {
			{ -- 1/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-47.8804, -1759.3583, 29.4210-1),
				heading = 45.8488,
			},
			{ -- 2/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1165.0236, -324.5127, 69.2050-1),
				heading = 94.1764,
			},
			{ -- 3/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-706.1506, -915.4036, 19.2156-1),
				heading = 82.1925,
			},
			{ -- 4/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1818.9453, 792.8862, 138.0832-1),
				heading = 123.0506,
			},
			{ -- 5/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1696.5778, 4923.9048, 42.0636-1),
				heading = 312.2549,
			},
			{ -- 5/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-524.2560, 7562.6157, 6.5240-1),
				heading = 233.2092,
			},
			{ -- 5/5
				ped = `a_m_y_mexthug_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1226.1918, 6927.6406, 20.4751-1),
				heading = 71.6410,
			},
		}
	},

	SklepTechniczny = {
		name = 'Sklep Techniczny',
		blip = {
			id = 566, colour = 7, scale = 0.7
		}, inventory = {
			{ name = 'krotkofalowka', price = 2500 },
			{ name = 'wiertlo', price = 5000 },
			{ name = 'handcuffs', price = 7500 },
			{ name = 'bag', price = 3500 },
			{ name = 'cutter', price = 2000 },
			{ name = 'roza', price = 50 },
			{ name = 'kocyk', price = 100 },
			{ name = 'kocyk_zestaw', price = 150 },
			--- { name = 'spray', price = 1500 },
			--- { name = 'spray_remover', price = 500 },
			-- { name = 'boombox', price = 2500 },
			{ name = 'worek', price = 3500 },
			-- { name = 'racingtablet', price = 15000 },
			-- { name = 'cups', price = 500 },
			{ name = 'lornetka', price = 5000 },
			{ name = 'gopro', price = 1500 },
			{ name = 'nurek', price = 800 },
			{ name = 'WEAPON_PETROLCAN', price = 2000 },
			{ name = 'lockpick', price = 1000 },
			{ name = 'desc_remover', price = 1500},
			{ name = 'repair_kit', price = 5000 },
		}, locations = {
		}, targets = {
			{ -- miasto
				ped = `s_m_m_gaffer_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vector3(-239.1384, -1397.7441, 31.2797-1.0),
				heading = 278.1005,
			},
			{ -- paleto
				ped = `s_m_m_gaffer_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vector3(37.7796, 6454.3555, 31.4253-1),
				heading = 223.8918,
			},
			{ -- sandy
				ped = `s_m_m_gaffer_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vector3(2507.1775, 4097.1763, 38.7163-1),
				heading = 65.9061,
			},
			{
				ped = `s_m_m_gaffer_01`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vector3(-1209.2861, -824.5102, 15.4548-1),
				heading = 313.9673,
			}
		}
	},

	AmmunationDesigins = {
		name = 'Ammunation Designs',
		inventory = {
			{ name = 'at_skin_patriotic', price = 12500 },
			{ name = 'at_skin_boom', price = 12500 },
			{ name = 'at_skin_geometric', price = 12500 },
			{ name = 'at_skin_zebra', price = 12500 },
			{ name = 'at_skin_leopard', price = 12500 },
			{ name = 'at_skin_perseus', price = 12500 },
			{ name = 'at_skin_sessanta', price = 12500 },
			{ name = 'at_skin_skull', price = 12500 },
			{ name = 'at_skin_woodland', price = 12500 },
			{ name = 'at_skin_brushstroke', price = 12500 },
			{ name = 'at_skin_camo', price = 12500 },
			{ name = 'at_skin_security', price = 12500 },
			{ name = 'at_skin_bodyguard', price = 12500 },
			{ name = 'at_skin_vip', price = 12500 },
			{ name = 'at_skin_wall', price = 12500 },
			{ name = 'at_skin_tiedye', price = 12500 },
			{ name = 'at_skin_trippy', price = 12500 },
			{ name = 'at_skin_luchalibre', price = 12500 },
			{ name = 'at_skin_fatalincursion', price = 12500 },
			{ name = 'at_skin_cluckinbell', price = 12500 },
			{ name = 'at_skin_burgershot', price = 12500 },
			{ name = 'at_skin_bulletholes', price = 12500 },
			{ name = 'at_skin_splatter', price = 12500 },
			{ name = 'at_skin_blagueurs', price = 12500 },
			{ name = 'at_skin_vagos', price = 12500 },
			{ name = 'at_skin_player', price = 12500 },
			{ name = 'at_skin_pimp', price = 12500 },
			{ name = 'at_skin_love', price = 12500 },
			{ name = 'at_skin_king', price = 12500 },
			{ name = 'at_skin_hate', price = 12500 },
			{ name = 'at_skin_dollar', price = 12500 },
			{ name = 'at_skin_diamond', price = 12500 },
			{ name = 'at_skin_ballas', price = 12500 },
			{ name = 'at_skin_pearl', price = 12500 },
			{ name = 'at_skin_metal', price = 12500 },
			{ name = 'at_skin_wood', price = 12500 },
			{ name = 'at_skin_luxe', price = 12500 },
		}, locations = {
		}, targets = {
			{ -- 1/12
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(8.1438, -1105.6338, 29.7972 - 1.0),
				heading = 251.3871
			},
			{ -- 2/12
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(845.62, -1032.13, 28.19-1.0),
				heading = 89.68,
			},
			{ -- 3/12
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1119.20, 2695.30, 18.55-1.0),
				heading = 308.67,
			},
			{ -- 4/12
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1692.36, 3756.56, 34.71-1.0),
				heading = 309.76,
			},
			{ -- 5/12
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-331.42, 6080.20, 31.45-1.0),
				heading = 319.05,
			},
			{ -- 6/12
				ped = `a_m_y_business_02`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1796.7104, 8380.2939, 36.2346 - 1.0),
				heading = 115.4864,
			},
		}
	},
	
	Ammunation = {
		name = 'Ammunation',
		blip = {
			id = 110, colour = 26, scale = 0.7
		}, 		inventory = {
			{ name = 'WEAPON_PISTOL', price = 40000, metadata = { registered = true }, license = 'weapon' },
			{ name = 'WEAPON_CROWBAR', price = 22000 },
			{ name = 'WEAPON_BAT', price = 21000 },
			{ name = 'WEAPON_KNIFE', price = 20000 },
			{ name = 'WEAPON_DAGGER', price = 21000 },
			{ name = 'WEAPON_MACHETE', price = 25000 },
			{ name = 'WEAPON_SWITCHBLADE', price = 21000 },
			{ name = 'WEAPON_HAMMER', price = 20000 },
			{ name = 'WEAPON_KNUCKLE', price = 20000 },
			{ name = 'WEAPON_GOLFCLUB', price = 23000 },
			{ name = 'WEAPON_NIGHTSTICK', price = 22000 },
			{ name = 'WEAPON_WRENCH', price = 21000 },
			{ name = 'parachute', price = 5000 },
			{ name = 'kabura', price = 15000 },
			{ name = 'ammo-9', price = 300, license = 'weapon' },
		}, locations = {
		}, targets = {
			{ -- 1/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-665.49, -938.78, 21.83-1.0),
				heading = 263.53,
			},
			{ -- 2/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(811.45, -2156.66, 29.62-1.0),
				heading = 359.35,
			},
			{ -- 3/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(1693.74, 3755.24, 34.71-1.0),
				heading = 310.44,
			},
			{ -- 4/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-330.24, 6079.03, 31.45-1.0),
				heading = 313.11,
			},
			{ -- 5/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(250.06, -45.81, 69.940-1.0),
				heading = 156.95,
			},
			{ -- 6/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(20.52, -1107.71, 29.78-1.0),
				heading = 154.86,
			},
			{ -- 7/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(2571.14, 297.70, 108.73-1.0),
				heading = 84.59,
			},
			{ -- 8/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1117.88, 2693.83, 18.55-1.0),
				heading = 309.43,
			},
			{ -- 9/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(845.56, -1030.19, 28.19-1.0),
				heading = 88.19,
			},
			{ -- 10/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1308.37, -390.27, 36.70-1.0),
				heading = 166.03,
			},
			{ -- 11/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-3170.00, 1083.35, 20.84-1.0),
				heading = 341.70,
			},
			--[[{ -- 12/12
				ped = `csb_mweather`,
				scenario = 'WORLD_HUMAN_AA_COFFEE',
				loc = vec3(-1799.3296, 8374.0713, 36.2346-1.0),
				heading = 24.2545,
			},--]]
		}
	},
	
	ZielarzCannabis = {
		name = 'Zielarz Franek',
		inventory = { 
			{ name = 'cannabis_seed', price = 200 },
			{ name = 'mini_shovel', price = 250 },
			{ name = 'fertilizer', price = 150 },
			{ name = 'water_bottle', price = 20 },
			{ name = 'grinder', price = 500 },
			{ name = 'ocb_paper', price = 20 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(2221.9287, 5614.5322, 54.9016-.95),
				heading = 106.6608,
			},
		}
	},
	ZielarzOGKush = {
		name = 'Zielarz Michał',
		inventory = { 
			{ name = 'ogkush_seed', price = 200 },
			{ name = 'mini_shovel', price = 250 },
			{ name = 'fertilizer', price = 150 },
			{ name = 'water_bottle', price = 20 },
			{ name = 'grinder', price = 500 },
			{ name = 'ocb_paper', price = 20 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(-277.4080, 2208.9114, 129.8476-.95),
				heading = 74.6608,
			},
		}
	},
	ZielarzOGHaze = {
		name = 'Zielarz Patryk',
		inventory = { 
			{ name = 'oghaze_seed', price = 200 },
			{ name = 'mini_shovel', price = 250 },
			{ name = 'fertilizer', price = 150 },
			{ name = 'water_bottle', price = 20 },
			{ name = 'grinder', price = 500 },
			{ name = 'ocb_paper', price = 20 },
		}, locations = {
		}, targets = {
			{ 
				ped = `a_m_y_genstreet_01`,
				scenario = 'WORLD_HUMAN_GUARD_STAND',
				loc = vector3(3723.0396, 4539.7168, 21.5883-.95),
				heading = 352.6608,
			},
		}
	},
}