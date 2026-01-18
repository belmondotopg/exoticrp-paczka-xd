Config = {}
Config.StrengthTime = 90
Config.StaminaTime = 90
Config.LunghTime = 90
Config.MaxStockPerItem = 200

-- System spadania statystyk gdy gracz nie ćwiczy
Config.StatsDecay = {
    enabled = true,
    checkInterval = 3600000, -- Sprawdzaj co 1 godzinę (3600000 ms)
    inactivityTime = 172800000, -- Czas przed rozpoczęciem spadania: 2 dni (172800000 ms = 48h)
    decayAmount = 5, -- O ile spada statystyka za każdy okres
    decayInterval = 86400000, -- Co ile czasu spada: 1 dzień (86400000 ms = 24h)
    minStats = 0, -- Minimalny poziom statystyk (nie spadnie poniżej)
    notification = false -- Czy pokazywać powiadomienia o spadaniu statystyk
}

Config.Upgrades = {
    equipment = {
        price = 100000,
        description = "Ulepszenie sprzętu pozwala na szybsze i efektywniejsze ćwiczenie",
        speedMultiplier = 0.5
    }
}

-- System treningu płuc (nurkowanie, pływanie, bieganie)
Config.LungTraining = {
    enabled = true,
    
    -- Nurkowanie pod wodą
    underwater = {
        enabled = true,
        checkInterval = 5000, -- Sprawdzaj co 5 sekund
        minTimeUnderwater = 45, -- Minimalne 45 sekund pod wodą
        skillGainPerCheck = 1, -- +1 do lung skill co 45 sekund nurkowania
        maxGainPerSession = 2, -- Maksymalnie +2 za jedną sesję nurkowania
        cooldown = 900000, -- 15 minut cooldown między sesjami
        notification = false
    },
    
    -- Pływanie na powierzchni
    swimming = {
        enabled = true,
        checkInterval = 10000, -- Sprawdzaj co 10 sekund
        minTimeSwimming = 120, -- Minimalne 120 sekund (2 minuty) pływania
        skillGainPerCheck = 1, -- +1 do lung skill co 120 sekund pływania
        maxGainPerSession = 2, -- Maksymalnie +2 za sesję pływania
        cooldown = 600000, -- 10 minut cooldown
        notification = false
    },
    
    -- Bieganie (sprint)
    running = {
        enabled = true,
        checkInterval = 5000, -- Sprawdzaj co 5 sekund
        minTimeRunning = 180, -- Minimalne 180 sekund (3 minuty) biegania
        skillGainPerCheck = 1, -- +1 do lung skill co 180 sekund biegania
        maxGainPerSession = 2, -- Maksymalnie +2 za sesję biegania
        cooldown = 720000, -- 12 minut cooldown
        notification = false,
        requiresValidPass = false -- Czy wymaga karnetu do siłowni
    },
    
    -- Globalne ustawienia
    maxSkillLevel = 100,
    showProgressBar = false,
    progressBarColor = {r = 16, g = 185, b = 129}, -- Kolor zielony
}

Config.GymPass = {
    daily = {
        defaultPrice = 3000,
        duration = 24 * 60 * 60 * 1000,
        description = "Przepustka dzienna na 24 godziny"
    },
    weekly = {
        defaultPrice = 15000,
        duration = 7 * 24 * 60 * 60 * 1000,
        description = "Przepustka tygodniowa na 7 dni"
    },
    monthly = {
        defaultPrice = 50000,
        duration = 30 * 24 * 60 * 60 * 1000,
        description = "Przepustka miesięczna na 30 dni"
    }
}
Config.Locations = {
    [1] = {
        coords = vector3(-1204.3635, -1557.7271, 4.7365), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [2] = {
        coords = vector3(-1202.9946, -1559.7297, 4.7359), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [3] = {
        coords = vector3(-1201.7294, -1561.7059, 4.7335), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [4] = {
        coords = vector3(-1200.3441, -1563.6635, 4.7337), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [5] = {
        coords = vector3(-1197.2563, -1568.0027, 4.7347), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [6] = {
        coords = vector3(-1195.9874, -1569.8335, 4.7346), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [7] = {
        coords = vector3(-1194.5778, -1571.8304, 4.7347), heading = 304.8961,
        Text3D = '[E] - Ćwicz (Stamina)', gym_name = 'beach_gym'
    },
    [8] = {
        coords = vector3(-1209.1588, -1564.7075, 4.6302), heading = 126.6030,
        Text3D = '[E] - Ćwicz (Płuca)', gym_name = 'beach_gym'
    },
    [9] = {
        coords = vector3(-1207.7552, -1566.6171, 4.6302), heading = 126.6030,
        Text3D = '[E] - Ćwicz (Płuca)', gym_name = 'beach_gym'
    },
    [10] = {
        coords = vector3(-1206.4481, -1568.5493, 4.6302), heading = 126.6030,
        Text3D = '[E] - Ćwicz (Płuca)', gym_name = 'beach_gym'
    },
    [11] = {
        coords = vector3(-1201.4475, -1575.5889, 4.6302), heading = 126.6030,
        Text3D = '[E] - Ćwicz (Płuca)', gym_name = 'beach_gym'
    },
    [12] = {
        coords = vector3(-1200.1967, -1577.3900, 4.6302), heading = 126.6030,
        Text3D = '[E] - Ćwicz (Płuca)', gym_name = 'beach_gym'
    },
    [13] = {
        coords = vector3(-1198.9111, -1579.4438, 4.6302), heading = 126.6030,
        Text3D = '[E] - Ćwicz (Płuca)', gym_name = 'beach_gym'
    },
    [14] = {
        coords = vector3(-1197.9060, -1574.5729, 4.6104), heading = 0.5734,
        Text3D = '[E] - Ćwicz (Siła)', gym_name = 'beach_gym'
    },
    [15] = {
        coords = vector3(-1199.6436, -1571.9325, 4.6094), heading = 359.7199,
        Text3D = '[E] - Ćwicz (Siła)', gym_name = 'beach_gym'
    },
    [16] = {
        coords = vector3(-1203.0769, -1566.7687, 4.6096), heading = 4.7253,
        Text3D = '[E] - Ćwicz (Siła)', gym_name = 'beach_gym'
    },
    [17] = {
        coords = vector3(-1205.9237, -1562.3990, 4.6099), heading = 10.6525,
        Text3D = '[E] - Ćwicz (Siła)'
    },
}

Config.Mission = {
    vehicle = {
        spawn = vec4(-1188.9387, -1586.2350, 4.3721, 296.6075),
        model = 'boxville3',
        plate = nil,
    },
    magazine = {
        entrance = {
            coords = vec4(849.0831, -1937.9124, 30.0684, 93.3376),
        },
        inside = {
            coords = vec4(844.5461, -3004.9451, -44.4000, 95.9553),
        },
        deliverTo = {
            coords = vec4(-1189.6707, -1586.9331, 4.3716, 307.8986),
        },
    },
    delivery = {
        discount = 0.7 -- Dostawa osobista kosztuje 70% ceny automatycznego uzupełnienia (30% zniżki)
    }
}