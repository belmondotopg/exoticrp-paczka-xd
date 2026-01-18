Config.Weed = {}

Config.Weed.Zones = {
    {
        coords = vector3(2228.4292, 5583.8164, 53.8220-1),
        size = vector3(100.0,100, 30),
        rotation = 114.1546,
        weeds = {['cannabis'] = true},
        debug = false
    },
    {
        coords = vector3(-277.1190, 2208.6785, 129.8608-10),
        size = vector3(100.0,100, 100),
        rotation = 114.1546,
        weeds = {['ogkush'] = true},
        debug = false
    },
    {
        coords = vector3(3723.0220, 4540.0127, 21.5864-10),
        size = vector3(100.0,100, 100),
        rotation = 114.1546,
        weeds = {['oghaze'] = true},
        debug = false
    },

}

Config.Weed.Seeds = {
    ['cannabis'] = {
        prop = {
            [1] = `bkr_prop_weed_bud_02a`,
            [2] = `prop_weed_02`,
            [3] = `prop_weed_01`
        },
        top = {min = 3, max = 6},
        lucky = {
            ['weapon_knife'] = true,
        }
    },
    ['ogkush'] = {
        prop = {
            [1] = `bkr_prop_weed_bud_02a`,
            [2] = `prop_weed_02`,
            [3] = `prop_weed_01`
        },
        top = {min = 3, max = 6},
        lucky = {
            ['weapon_knife'] = true,
        }
    },
    ['oghaze'] = {
        prop = {
            [1] = `bkr_prop_weed_bud_02a`,
            [2] = `prop_weed_02`,
            [3] = `prop_weed_01`
        },
        top = {min = 3, max = 6},
        lucky = {
            ['weapon_knife'] = true,
        }
    },
}

Config.Weed.Utils = {
    ['watering'] = 5, -- 5 percent for 1 water
    ['fertilizing'] = 5, -- 5 percent for 1 fertilizer
}