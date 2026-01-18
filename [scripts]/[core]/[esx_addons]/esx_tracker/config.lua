Config = {}

Config.Requirements = {
	Cops = 1
}

Config.MaxWorkingPositions = 1

Config.SpawnLocations = {
    ['C'] = {
        {locked = false, coords = vec4(-1374.6375732422, -447.74899291992, 34.065338134766, 215.60598754883)},
        {locked = false, coords = vec4(-1537.5731201172, -577.57836914062, 25.295721054077, 33.778118133545)},
        {locked = false, coords = vec4(-1984.2017822266, -289.87686157227, 43.696220397949, 236.52877807617)},
        {locked = false, coords = vec4(-1826.5390625, -624.9404296875, 10.666346549988, 322.13424682617)},
        {locked = false, coords = vec4(-937.44903564453, -1302.9197998047, 4.606529712677, 200.39895629883)},
        {locked = false, coords = vec4(-84.204299926758, -821.31256103516, 35.616851806641, 350.40841674805)},
    },
    ['B'] = {
        {locked = false, coords = vec4(972.93988037109, 8.2312107086182, 80.630935668945, 150.59506225586)},
        {locked = false, coords = vec4(1395.0814208984, -574.47778320312, 73.926948547363, 112.52770233154)},
        {locked = false, coords = vec4(890.59466552734, -922.57043457031, 25.870935440063, 270.53036499023)},
        {locked = false, coords = vec4(696.29125976562, -1043.7010498047, 21.948556900024, 256.23498535156)},
        {locked = false, coords = vec4(547.24157714844, -1926.8083496094, 24.941909790039, 297.8454284668)},
    },
    ['A'] = {
        {locked = false, coords = vec4(-362.69720458984, -1868.6077880859, 20.118894577026, 7.8443293571472)},
        {locked = false, coords = vec4(-746.02844238281, 372.81491088867, 87.468116760254, 359.51248168945)},
        {locked = false, coords = vec4(-90.578140258789, 362.95431518555, 112.04621887207, 246.81039428711)},
        {locked = false, coords = vec4(-421.84759521484, 1197.7629394531, 325.22964477539, 47.461658477783)},
        {locked = false, coords = vec4(-1688.8524169922, 34.851982116699, 64.029579162598, 108.73860931396)},
    },
    ['S'] = {
        {locked = false, coords = vec4(-1469.3999023438, -649.93255615234, 29.093046188354, 215.18850708008)},
        {locked = false, coords = vec4(-1553.8238525391, -1021.8427124023, 12.602604866028, 74.751350402832)},
        {locked = false, coords = vec4(-859.53338623047, -2353.8483886719, 13.543924331665, 266.18481445312)},
        {locked = false, coords = vec4(135.75555419922, -1050.0557861328, 28.742485046387, 337.62533569336)},
        {locked = false, coords = vec4(-329.48199462891, -1298.2677001953, 30.982261657715, 268.59075927734)},
    }
}

Config.Coords = {
	[1] = Config.SpawnLocations['C'],
	[2] = Config.SpawnLocations['B'],
	[3] = Config.SpawnLocations['A'],
	[4] = Config.SpawnLocations['S'],
}

Config.VehicleClasses = {
	['S'] = {
		'adder',
		'zentorno',
		't20',
		'osiris',
		'turismor',
		'entityxf',
		'vagner',
		'xa21',
		'tyrus',
		'voltic',
		'bullet',
		'cheetah',
		'infernus',
		'veigero',
		'vacca',
	},
	['A'] = {
		'carbonizzare',
		'comet2',
		'coquette',
		'elegy',
		'feltzer2',
		'jester',
		'massacro',
		'rapidgt',
		'sultan',
		'surano',
		'banshee',
		'lynx',
		'furoregt',
		'fusilade',
		'ninef',
	},
	['B'] = {
		'fugitive',
		'schafter2',
		'cognoscenti',
		'premier',
		'stanier',
		'tailgater',
		'washington',
		'stratum',
		'primo',
		'regina',
		'glendale',
		'warrener',
		'emperor',
		'ingot',
		'intruder',
	},
	['C'] = {
		'blista',
		'brioso',
		'dilettante',
		'issi2',
		'panto',
		'prairie',
		'rhapsody',
		'felon',
		'felon2',
		'jackal',
		'oracle',
		'sentinel',
		'zion',
		'zion2',
		'blade',
	}
}

Config.TierUnlocks = {
	[1] = {'C'},
	[2] = {'C', 'B'},
	[3] = {'C', 'B', 'A'},
	[4] = {'C', 'B', 'A', 'S'},
}

Config.ForbiddenJobs = {
	['mechanik'] = true,
	['ambulance'] = true,
	['police'] = true,
	['fib'] = true,
}

Config.Peds = {
	{
		id = 20 + math.random(111, 999),
		distance = 200,
		coords = vec3(-2175.3466796875, 4294.6938476562, 49.058132171631-0.95),
		heading = 240.8679,
		label = "Rozmawiaj",
		level = 1,
		isSeller = false,
	},
	{
		id = 20 + math.random(111, 999),
		distance = 200,
		coords = vec3(296.08459472656, -1713.9732666016, 29.175273895264-0.95),
		heading = 183.1135,
		label = "Rozmawiaj",
		isSeller = true,
	},
}

Config.Rewards = {
	['S'] = {min = 40000, max = 45000},
	['A'] = {min = 35000, max = 40000},
	['B'] = {min = 32500, max = 37500},
	['C'] = {min = 27500, max = 32500},
}