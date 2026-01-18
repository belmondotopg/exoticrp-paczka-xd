Config = {}
Config.Debug = false
Config.MinCops = 2 -- Minimalna liczba policjantów wymaganych do napadu

Config.GlobalSafes = {
    addondrops = {
        {
            item = "black_money",
            chance = 25,
            amount = {500, 1500}
        },
        {
            item = "lockpick",
            chance = 35,
            amount = {1, 3}
        },
    },
    cooldown = 5000,
    globalCooldown = 300000,
    failedHeistCooldown = 3600000,
    requiredItems = {
        powerCut = "cutter",
        safeOpen = "lockpick"
    },
    safeModel = `prop_ld_int_safe_01`, -- Model sejfu do spawnowania
    spawnSafe = true -- Czy spawnować fizyczny obiekt sejfu (jeśli false, sejf musi być już w mapie)
}

Config.Safes = {
    ['24/7 Grove Street'] = {
        coords = vec3(-43.933471679688, -1747.9831542969, 29.020959472656),
        powerCoords = vec3(-87.788215637207, -1750.8194580078, 29.53727722168),
        drop = {30000, 35000}
    },
    ['24/7 Innocence Blvd'] = {
        coords = vec3(31.046390533447, -1338.0543457031, 29.797051239014),
        powerCoords = vec3(19.1355, -1335.2437, 29.4642),
        drop = {30000, 35000}
    },
    ['24/7 Palomino Avenue'] = {
        coords = vec3(2548.403125, 387.76525878906, 108.92287902832),
        powerCoords = vec3(2546.1576660156, 371.85488891602, 108.61477661133),
        drop = {30000, 35000}
    },
    ['24/7 Clinton Avenue'] = {
        coords = vec3(381.14053344727, 333.7791809082, 103.56634521484),
        powerCoords = vec3(387.02722167969, 354.62310180664, 102.5764541626),
        drop = {30000, 35000}
    },
    ['24/7 Ineseno Road'] = {
        coords = vec3(-3049.757421875, 588.16192626953, 7.9089822769165),
        powerCoords = vec3(-3050.0249023438, 589.16265869141, 7.7661933898926),
        drop = {30000, 35000}
    },
    ['24/7 Alhambra Drive'] = {
        coords = vec3(1961.357421875, 3751.3293457031, 32.343753814697),
        powerCoords = vec3(1965.1618652344, 3749.8220703125, 32.247772216797),
        drop = {30000, 35000}
    },
    ['Stacja Benzynowa Great Ocean Highway'] = {
        coords = vec3(1707.8781738281, 4920.7794921875, 41.863735961914),
        powerCoords = vec3(1699.6063232422, 4917.5641601562, 42.078063964844),
        drop = {30000, 35000}
    },
    ['Sklep Rob\'s Liquor Route 68'] = {
        coords = vec3(1169.7050537109, 2717.8559570312, 37.157615661621),
        powerCoords = vec3(1158.0704833984, 2709.0244140625, 37.98136138916),
        drop = {30000, 35000}
    },
    ['Sklep Rob\'s Liquor Great Ocean Highway'] = {
        coords = vec3(-3250.7561035156, 1007.217956543, 12.830752372742),
        powerCoords = vec3(-3241.9030761719, 1012.6318237305, 12.394282341003),
        drop = {30000, 35000}
    },
    ['Sklep Rob\'s Liquor San Andreas Avenue'] = {
        coords = vec3(-1220.9928466797, -916.14022216797, 11.326352119446),
        powerCoords = vec3(-1207.2455322266, -917.50964355469, 12.180317878723),
        drop = {30000, 35000}
    },
    ['Sklep Rob\'s Liquor El Rancho Boulevard'] = {
        coords = vec3(1126.6188720703, -979.96003417969, 45.415904998779),
        powerCoords = vec3(1124.7313232422, -973.00450439453, 46.532291412354),
        drop = {30000, 35000}
    },
    ['Sklep LTD Mirror Park'] = {
        coords = vec3(1159.2718017578, -314.1475769043, 69.004978942871),
        powerCoords = vec3(1166.6947509766, -321.21112060547, 69.274597167969),
        drop = {30000, 35000}
    }
}