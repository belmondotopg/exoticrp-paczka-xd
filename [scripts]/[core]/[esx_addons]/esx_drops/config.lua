Config = {}

Config.AllowedJobs = {
    [1] = true,
}

Config.Peds = {
    {
        id = 30 + math.random(111, 999),
        distance = 200,
        coords = vec3(1061.4652, -1998.8534, 40.3177-.95),
        heading = 54.7974,
        label = "Zobacz towary...",
    },
}

Config.DropBoxModel = `ch_prop_ch_crate_01a`
Config.DropParachuteModel = `prop_v_parachute`
Config.FlareParticle = 'exp_grd_flare'
Config.ParachuteOffset = 5.25
Config.FallTime = 3500
Config.FlareDuration = 20000

Config.MinimumPlayers = 30

Config.Rewards = {
    ['small'] = {
        items = {
            {name = 'bread', count = 1},
        },
        money = 20000,
        money_type = 'black_money',
    },
    ['medium'] = {
        items = {
            {name = 'bread', count = 2},
        },
        money = 30000,
        money_type = 'black_money',
    },
    ['large'] = {
        items = {
            {name = 'bread', count = 3},
        },
        money = 40000,
        money_type = 'black_money',
    },
}

Global = {
    DropBoxes = {},
    objects = {},
    openTimestamp = 0,
    duiTimestamp = 1, --// 10 minut
}