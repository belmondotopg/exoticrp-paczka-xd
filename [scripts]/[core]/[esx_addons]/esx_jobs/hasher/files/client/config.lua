Config = {}

Config.Uniforms = {
    ['lumberjack'] = {
        male = {
            tshirt_1 = 15,     tshirt_2 = 0,
            torso_1 = 97,       torso_2 = 1,
            arms = 63,
            pants_1 = 90,       pants_2 = 2,
            shoes_1 = 25,       shoes_2 = 0,
            helmet_1 = 20,     helmet_2 = 0
        },
        female = {
            tshirt_1 = 219,     tshirt_2 = 0,
            torso_1 = 286,       torso_2 = 1,
            arms = 0,
            pants_1 = 35,       pants_2 = 0,
            shoes_1 = 68,       shoes_2 = 0,
            helmet_1 = -1,     helmet_2 = 0
        }
    },
    ['weazelnews'] = {
        male = {
            tshirt_1 = 15,     tshirt_2 = 0,
            torso_1 = 97,       torso_2 = 1,
            arms = 63,
            pants_1 = 90,       pants_2 = 2,
            shoes_1 = 25,       shoes_2 = 0,
            helmet_1 = 20,     helmet_2 = 0
        },
        female = {
            tshirt_1 = 219,     tshirt_2 = 0,
            torso_1 = 286,       torso_2 = 1,
            arms = 0,
            pants_1 = 35,       pants_2 = 0,
            shoes_1 = 68,       shoes_2 = 0,
            helmet_1 = -1,     helmet_2 = 0
        }
    },
}

Config.Basics = {
    ['lumberjack'] = {
        job = {
            required = true,
            name = 'lumberjack',
            bossGrade = 4,
        }
    },
    ['weazelnews'] = {
        job = {
            required = true,
            name = 'weazelnews',
            bossGrade = 4,
        }
    }
}

Config.Coords = {
    ['lumberjack'] = {
        vehicles = {
            model = "sadler",
            spawn = vec4(-572.2211, 5339.4448, 70.2145, 160.7355),
        },
    },
    ['weazelnews'] = {
        vehicles = {
            model = "rumpo",
            spawn = vec4(-532.6516, -890.0948, 24.7735, 186.1072),
        },
    }
}

Config.Peds = {
    ['lumberjack'] = {
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-565.5708, 5325.7207, 73.5929),
            heading = 72.8725,
            label = "Rozmawiaj",
            isCloakroom = true,
        },
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-581.3472, 5335.7705, 70.2145),
            heading = 255.6429,
            label = "Rozmawiaj",
            isGarage = true,
        },
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-552.5706, 5348.5244, 74.7431),
            heading = 70.0107,
            label = "Rozmawiaj",
            isSell = true,
        },
    },
    ['weazelnews'] = {
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-585.5595, -938.8690, 23.8696),
            heading = 1.9701,
            label = "Rozmawiaj",
            isCloakroom = true,
        },
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-537.0980, -886.8510, 25.1917),
            heading = 183.0977,
            label = "Rozmawiaj",
            isGarage = true,
        },
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-577.5723, -923.0718, 23.8697),
            heading = 185.3474,
            label = "Rozmawiaj",
            isSell = true,
        },
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(-583.28466796875, -928.84478759766, 28.157020568848),
            heading = 185.3474,
            label = "Otwórz menu zarządzania",
            isBoss = true,
        },
    },
    ['orangeharvest'] = {
        {
            id = 15 + math.random(111, 999),
            distance = 100,
            coords = vec3(1710.4817, 4728.5293, 42.1446),
            heading = 106.6049,
            label = "Wymień Pomarańcze",
        },
    }
}

Config.Blips = {
    ['lumberjack'] = {
        {
            Pos     = vector3(-565.5708, 5325.7207, 73.5929),
            Sprite  = 478,
            Display = 4,
            Scale   = 0.8,
            Colour  = 21,
            Label   = "Tartak"
        },
    },
    ['weazelnews'] = {
        {
            Pos     = vector3(-598.2047, -929.8560, 23.8691),
            Sprite  = 184,
            Display = 4,
            Scale   = 0.8,
            Colour  = 6,
            Label   = "Weazel News"
        },
    },
    ['orangeharvest'] = {
        {
            Pos = vector3(2336.7314, 4755.3281, 43.4701),
            Sprite = 85,
            Display = 4,
            Scale = 0.8,
            Colour = 44,
            Label = "Sad pomarańczy"
        },
        {
            Pos = vector3(1710.4817, 4728.5293, 42.1446),
            Sprite = 478,
            Display = 4,
            Scale = 0.8,
            Colour = 44,
            Label = "Sokarnia"
        }
    },
}

Config.Economy = {
    ['weazelnews'] = {
        -- Ceny sprzedaży obrobionych zdjęć
        sellPrice = {
            min = 1000,          -- Minimalna cena za 1 obrobione zdjęcie (10,000 za kurs przy min 10 zdjęciach)
            max = 1400,          -- Maksymalna cena za 1 obrobione zdjęcie (14,000 za kurs przy min 10 zdjęciach)
            maxAfterHour = 1200, -- Maksymalna cena po pierwszej godzinie
        },
        -- Zarobki z robienia zdjęć
        photo = {
            addAmount = 10,     -- Ilość zdjęć dodawanych po zrobieniu zdjęcia
            maxAmount = 150,    -- Maksymalna ilość zdjęć w ekwipunku
        },
        -- Obróbka zdjęć
        process = {
            inputAmount = 10,    -- Ilość zdjęć potrzebnych do obróbki
            outputAmount = 5,   -- Ilość obrobionych zdjęć otrzymanych z obróbki
        },
        -- Sprzedaż obrobionych zdjęć
        sell = {
            minAmount = 10,     -- Minimalna ilość obrobionych zdjęć do sprzedaży
            societyPercent = 0.10, -- Procent dla firmy (10% = 0.10)
        },
        -- Cooldowny (w milisekundach)
        cooldowns = {
            takePhoto = 5000,   -- Cooldown między robieniem zdjęć (5 sekund)
            process = 5000,     -- Cooldown między obróbką zdjęć (5 sekund)
            sell = 5000,       -- Cooldown między sprzedażą (5 sekund)
        },
        -- Odległości sprawdzania (w metrach)
        distances = {
            takePhoto = 5.0,   -- Maksymalna odległość od miejsca zdjęcia
            process = 5.0,     -- Maksymalna odległość od miejsca obróbki
            sell = 5.0,        -- Maksymalna odległość od miejsca sprzedaży
        },
        -- Czas zmiany ceny rynkowej (w milisekundach)
        priceChangeInterval = 60 * 60 * 1000, -- 1 godzina
        -- Kara za nieoddanie pojazdu
        vehiclePenalty = {
            amount = 5000, -- Kwota kary za nieoddanie pojazdu przy zakończeniu pracy
        },
    },
    ['lumberjack'] = {
        -- Ceny sprzedaży zapakowanych desek
        sellPrice = {
            min = 380,
            max = 420,
        },
        -- Zarobki z ścinania drzew
        wood = {
            addAmount = 10,
            maxAmount = 50,
        },
        -- Obróbka drewna
        process = {
            inputAmount = 10,
            outputAmount = 5,
        },
        -- Sprzedaż zapakowanych desek
        sell = {
            minAmount = 10,
            societyPercent = 0.10,
        },
        -- Cooldowny (w milisekundach)
        cooldowns = {
            chop = 5000,
            process = 5000,
            sell = 5000,
        },
        -- Odległości sprawdzania (w metrach)
        distances = {
            chop = 5.0,
            process = 5.0,
            sell = 5.0,
        },
        -- Czas zmiany ceny rynkowej (w milisekundach)
        priceChangeInterval = 15 * 60 * 1000,
        -- Kara za nieoddanie pojazdu
        vehiclePenalty = {
            amount = 5000,
        },
    },
    ['orangeharvest'] = {
        -- Zarobki z zbierania pomarańczy
        orange = {
            addAmountMin = 1,     -- Minimalna ilość pomarańczy dodawanych przy zbieraniu
            addAmountMax = 4,       -- Maksymalna ilość pomarańczy dodawanych przy zbieraniu
            maxAmount = 100,         -- Maksymalna ilość pomarańczy w ekwipunku
        },
        -- Wymiana pomarańczy na sok
        process = {
            inputAmount = 5,        -- Ilość pomarańczy potrzebnych do wymiany
            outputAmount = 1,       -- Ilość soku otrzymanego z wymiany
        },
        -- Sprzedaż pomarańczy
        sell = {
            inputAmount = 5,        -- Ilość pomarańczy do sprzedaży
            priceMin = 200,         -- Minimalna cena za 5 pomarańczy
            priceMax = 400,         -- Maksymalna cena za 5 pomarańczy
            bonusChance = 25,       -- Szansa na bonus sok (w procentach, 25 = 25%)
            bonusAmount = 1,        -- Ilość soku otrzymanego jako bonus
        },
        -- Cooldowny (w milisekundach)
        cooldowns = {
            harvest = 5000,        -- Cooldown między zbieraniem (5 sekund)
            process = 5000,         -- Cooldown między wymianą (5 sekund)
            sell = 0,              -- Cooldown między sprzedażą (0 = brak)
        },
        -- Odległości sprawdzania (w metrach)
        distances = {
            harvest = 5.0,         -- Maksymalna odległość od miejsca zbierania
            process = 5.0,          -- Maksymalna odległość od miejsca wymiany
            sell = 5.0,            -- Maksymalna odległość od miejsca sprzedaży
        },
    },
}