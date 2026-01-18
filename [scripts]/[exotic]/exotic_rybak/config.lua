Config = {}

Config.Locale = 'pl'
Config.Debug = false

Config.RybakCase = {
    {
        item = 'money',
        label = 'Plik pieniędzy',
        weight = 40,
        minAmount = 50,
        maxAmount = 250
    },
    {
        item = 'bread',
        label = 'Chleb',
        weight = 35,
        minAmount = 1,
        maxAmount = 5
    },
    {
        item = 'water',
        label = 'Woda',
        weight = 30,
        minAmount = 1,
        maxAmount = 3
    },
    {
        item = 'money',
        label = 'Słoik pieniędzy',
        weight = 20,
        minAmount = 250,
        maxAmount = 750
    },
    {
        item = 'money',
        label = 'Walizka gotówki',
        weight = 10,
        minAmount = 750,
        maxAmount = 1500
    },
    {
        item = 'WEAPON_PISTOL',
        label = 'Pistolet',
        weight = 0.027,
        minAmount = 1,
        maxAmount = 1
    },
}

Config.EventRankingCoords = vec3(-1850.1333, -1232.0332, 14.0173)

Config.RybakCaseChance = 2

-- ============================================
-- STREFY ŁOWIENIA (Fishing Zones)
-- ============================================
Config.FishingZones = {
    {
        name = 'Port Los Santos',
        npc = {
            model = 'a_m_m_hillbilly_01',
            coords = vec4(-1848.90, -1250.0, 8.6, 0.0),
        },
        fishingCoords = vec3(-1849.3638, -1244.2877, 8.6158),
        fishingRadius = 20.0,
        blip = {
            enabled = true,
            sprite = 356,
            colour = 26,
            scale = 0.9,
            label = 'Rybak - Port LS'
        }
    },
    {
        name = 'Paleto Bay',
        npc = {
            model = 'a_m_m_hillbilly_01',
            coords = vec4(-1612.8819, 5255.5649, 3.9741, 290.0),
        },
        fishingCoords = vec3(-1612.8819, 5255.5649, 3.9741),
        fishingRadius = 30.0,
        blip = {
            enabled = true,
            sprite = 356,
            colour = 26,
            scale = 0.9,
            label = 'Rybak - Paleto Bay'
        }
    },
    {
        name = 'Sandy Shores',
        npc = {
            model = 'a_m_m_hillbilly_01',
            coords = vec4(1302.6522, 4226.2920, 33.9087, 90.0),
        },
        fishingCoords = vec3(1302.6522, 4226.2920, 33.9087),
        fishingRadius = 30.0,
        blip = {
            enabled = true,
            sprite = 356,
            colour = 26,
            scale = 0.9,
            label = 'Rybak - Sandy Shores'
        }
    },
    {
        name = 'Chumash',
        npc = {
            model = 'a_m_m_hillbilly_01',
            coords = vec4(-3424.4699707031, 970.28900146484, 8.3466854095459, 90.0),
        },
        fishingCoords = vec3(-3424.4699707031, 970.28900146484, 8.3466854095459),
        fishingRadius = 30.0,
        blip = {
            enabled = true,
            sprite = 356,
            colour = 26,
            scale = 0.9,
            label = 'Rybak - Chumash'
        }
    },
    {
        name = 'Del Perro',
        npc = {
            model = 'a_m_m_hillbilly_01',
            coords = vec4(-1820.7700, -1219.9500, 13.0179, 46.9318),
        },
        fishingCoords = vec3(-1820.7700, -1219.9500, 13.0179),
        fishingRadius = 0.0,
        blip = {
            enabled = true,
            sprite = 356,
            colour = 26,
            scale = 0.9,
            label = 'Rybak - Del Perro'
        }
    }
}

-- ============================================
-- CENY WĘDEK
-- ============================================
Config.RodPrice = 7500  -- Cena zakupu pierwszej wędki (Dębowa)

-- Ceny ulepszeń wędek (od poziomu 1 do 5)
-- Każde ulepszenie zwiększa bonusy i odblokowuje lepszą wędkę
Config.RodUpgradePrices = {
    [1] = 60000,
    [2] = 80000,
    [3] = 100000,
    [4] = 120000,
    [5] = 150000,
}

-- ============================================
-- TYPY WĘDEK
-- ============================================
-- Każdy poziom wędki daje bonusy zdefiniowane w Config.RodLevels
Config.RodTypes = {
    { name = 'rod_oak',    label = 'Dębowa Wędka' },
    { name = 'rod_bamboo', label = 'Bambusowa Wędka' },
    { name = 'rod_carbon', label = 'Karbonowa Wędka' },
    { name = 'rod_titan',  label = 'Tytanowa Wędka' },
    { name = 'rod_mythic', label = 'Mityczna Wędka' }
}

-- ============================================
-- POZIOMY WĘDEK I BONUSY
-- ============================================
-- required_xp: Ilość XP potrzebna do odblokowania możliwości upgrade
-- rare_bonus: % zwiększenia szansy na rzadkie ryby (NIE dotyczy common)
-- weight_bonus: % zwiększenia wagi złowionej ryby (wpływa na XP i cenę!)
Config.RodLevels = {
    { required_xp = 200,   rare_bonus = 5,  weight_bonus = 5 },   -- Poziom 1: Dębowa
    { required_xp = 1200,  rare_bonus = 8,  weight_bonus = 8 },   -- Poziom 2: Bambusowa
    { required_xp = 6000,  rare_bonus = 12, weight_bonus = 12 },  -- Poziom 3: Karbonowa
    { required_xp = 18000, rare_bonus = 18, weight_bonus = 18 },  -- Poziom 4: Tytanowa
    { required_xp = 40000, rare_bonus = 25, weight_bonus = 25 }   -- Poziom 5: Mityczna (MAX)
}

-- ============================================
-- POZIOMY GRACZA I BONUSY
-- ============================================
-- Bonusy kumulują się z bonusami wędki i osiągnięć!
-- Poziom gracza podnosi się automatycznie po zdobyciu required_xp
Config.PlayerLevels = {
    { required_xp = 1500,   rare_bonus = 1,  weight_bonus = 4 },  -- Lvl 1: Początkujący Pluskacz
    { required_xp = 4500,   rare_bonus = 2,  weight_bonus = 7 },  -- Lvl 2: Młodszy Haczykowy
    { required_xp = 9000,   rare_bonus = 3,  weight_bonus = 10 }, -- Lvl 3: Wprawny Wędkarz
    { required_xp = 15000,  rare_bonus = 5,  weight_bonus = 13 }, -- Lvl 4: Pogromca Płotek
    { required_xp = 23000,  rare_bonus = 7,  weight_bonus = 16 }, -- Lvl 5: Mistrz Przynęty
    { required_xp = 33000,  rare_bonus = 9,  weight_bonus = 20 }, -- Lvl 6: Cesarz Karpia
    { required_xp = 45000,  rare_bonus = 12, weight_bonus = 24 }, -- Lvl 7: Król Tuńczyka
    { required_xp = 60000,  rare_bonus = 15, weight_bonus = 28 }, -- Lvl 8: Władca Oceanu
    { required_xp = 78000,  rare_bonus = 19, weight_bonus = 34 }, -- Lvl 9: Posejdon Wód
    { required_xp = 100000, rare_bonus = 25, weight_bonus = 40 }  -- Lvl 10: Legenda Głębin (MAX)
}

-- ============================================
-- NAZWY RANG GRACZY (odpowiadają PlayerLevels)
-- ============================================
Config.PlayerRanks = {
    'Początkujący Pluskacz',  -- Poziom 1
    'Młodszy Haczykowy',      -- Poziom 2
    'Wprawny Wędkarz',        -- Poziom 3
    'Pogromca Płotek',        -- Poziom 4
    'Mistrz Przynęty',        -- Poziom 5
    'Cesarz Karpia',          -- Poziom 6
    'Król Tuńczyka',          -- Poziom 7
    'Władca Oceanu',          -- Poziom 8
    'Posejdon Wód',           -- Poziom 9
    'Legenda Głębin'          -- Poziom 10 (MAX)
}

-- ============================================
-- RYBY - KONFIGURACJA
-- ============================================
-- price: Cena za 1 KG ryby (waga * price = końcowa cena)
-- minWeight/maxWeight: Zakres wagi w KG
-- chance: Bazowa szansa na złowienie (100 = średnia szansa)
--         Bonusy rare_bonus zwiększają szansę dla rare/epic/legendary
-- base_xp: Podstawowe XP za złowienie
-- xp_multiplier: XP za każdy kilogram (base_xp + weight * xp_multiplier)
-- rarity: 'common', 'rare', 'epic', 'legendary'
--
-- PRZYKŁAD ZAROBKÓW (bez bonusów):
-- - Makrela 2kg: 2 * 60 = 120$ (~10 szt/h = 1200$/h)
-- - Tuńczyk 10kg: 10 * 120 = 1200$ (~3 szt/h = 3600$/h)
-- - Rekin 50kg: 50 * 280 = 14000$ (~0.3 szt/h = 4200$/h)

Config.Fish = {
    -- ========================================
    -- COMMON - Łatwe do złowienia (80-110% szansy)
    -- ========================================
    {
        name = 'barwena',
        label = 'Barwena',
        price = 32,              -- Zwiększono o 5% (30 * 1.05)
        minWeight = 0.8,
        maxWeight = 2.5,
        chance = 110,            -- Bardzo często
        base_xp = 5,
        xp_multiplier = 2,
        rarity = 'common'
    },
    {
        name = 'okon',
        label = 'Okoń morski',
        price = 32,              -- Zwiększono o 5% (30 * 1.05)
        minWeight = 0.8,
        maxWeight = 2.8,
        chance = 110,
        base_xp = 5,
        xp_multiplier = 2,
        rarity = 'common'
    },
    {
        name = 'makrela',
        label = 'Makrela',
        price = 37,              -- Zwiększono o 5% (35 * 1.05)
        minWeight = 1.0,
        maxWeight = 3.2,
        chance = 100,
        base_xp = 6,
        xp_multiplier = 2,
        rarity = 'common'
    },
    {
        name = 'fladra',
        label = 'Flądra',
        price = 37,              -- Zwiększono o 5% (35 * 1.05)
        minWeight = 1.0,
        maxWeight = 3.0,
        chance = 100,
        base_xp = 6,
        xp_multiplier = 2,
        rarity = 'common'
    },
    {
        name = 'sandacz',
        label = 'Sandacz',
        price = 42,              -- Zwiększono o 5% (40 * 1.05)
        minWeight = 1.5,
        maxWeight = 4.5,
        chance = 85,
        base_xp = 7,
        xp_multiplier = 3,
        rarity = 'common'
    },
    {
        name = 'pstrag',
        label = 'Pstrąg',
        price = 44,              -- Zwiększono o 5% (42 * 1.05)
        minWeight = 1.5,
        maxWeight = 4.0,
        chance = 90,
        base_xp = 7,
        xp_multiplier = 3,
        rarity = 'common'
    },
    {
        name = 'dorsz',
        label = 'Dorsz',
        price = 47,               -- Zwiększono o 5% (45 * 1.05)
        minWeight = 2.0,
        maxWeight = 6.0,
        chance = 80,
        base_xp = 8,
        xp_multiplier = 3,
        rarity = 'common'
    },
    {
        name = 'losos',
        label = 'Łosoś',
        price = 50,               -- Zwiększono o 5% (48 * 1.05)
        minWeight = 2.0,
        maxWeight = 5.5,
        chance = 80,
        base_xp = 8,
        xp_multiplier = 3,
        rarity = 'common'
    },
    {
        name = 'halibut',
        label = 'Halibut',
        price = 53,               -- Zwiększono o 5% (50 * 1.05)
        minWeight = 2.5,
        maxWeight = 6.5,
        chance = 75,
        base_xp = 9,
        xp_multiplier = 3,
        rarity = 'common'
    },
    
    -- ========================================
    -- RARE - Średnio trudne (40-55% szansy)
    -- ========================================
    {
        name = 'karmazyn',
        label = 'Karmazyn',
        price = 79,              -- Zwiększono o 5% (75 * 1.05)
        minWeight = 5.0,
        maxWeight = 11.0,
        chance = 50,             -- Zwiększa się z rare_bonus
        base_xp = 22,
        xp_multiplier = 8,
        rarity = 'rare'
    },
    {
        name = 'tunczyk',
        label = 'Tuńczyk',
        price = 68,               -- Zwiększono o 5% (65 * 1.05)
        minWeight = 8.0,
        maxWeight = 14.0,
        chance = 45,
        base_xp = 20,
        xp_multiplier = 7,
        rarity = 'rare'
    },
    
    -- ========================================
    -- EPIC - Trudne (12-18% szansy)
    -- ========================================
    {
        name = 'miecznik',
        label = 'Miecznik',
        price = 126,             -- Zwiększono o 5% (120 * 1.05)
        minWeight = 20.0,
        maxWeight = 32.0,
        chance = 15,             -- Rzadkie, duże bonusy pomagają
        base_xp = 40,
        xp_multiplier = 12,
        rarity = 'epic'
    },
    
    -- ========================================
    -- LEGENDARY - Bardzo trudne (5-8% szansy)
    -- ========================================
    {
        name = 'rekin',
        label = 'Mały Rekin',
        price = 158,             -- Zwiększono o 5% (150 * 1.05)
        minWeight = 40.0,
        maxWeight = 55.0,        -- Zmniejszona max waga
        chance = 8,              -- Bardzo rzadkie
        base_xp = 80,
        xp_multiplier = 15,
        rarity = 'legendary'
    },
    
    -- ========================================
    -- SPECJALNE - Małża (nie łowi się normalnie)
    -- ========================================
    {
        name = 'clam',
        label = 'Małża',
        price = 100,             -- Nie sprzedaje się
        minWeight = 0.1,
        maxWeight = 0.3,
        chance = 0,              -- Nie łowi się, dropuje jako bonus
        base_xp = 0,
        xp_multiplier = 0,
        rarity = 'rare'
    }
}

-- ============================================
-- SYSTEM MAŁŻY I PEREŁ
-- ============================================
-- ClamChance: % szansy na otrzymanie małży przy złowieniu ryby
-- PearlChance: % szansy na perłę przy otwieraniu małży
-- 
-- OBLICZENIA:
-- Szansa na perłę przy każdym połowie: 10% * 15% = 1.5%
-- Średnia wartość perły (ważona):
--   - Biała (60%): 10000$ * 0.6 = 6000$
--   - Czerwona (30%): 12500$ * 0.3 = 3750$
--   - Niebieska (10%): 15000$ * 0.1 = 1500$
--   ŚREDNIA: 6000 + 3750 + 1500 = 11250$ za perłę
-- ŚREDNI ZAROBEK: 1.5% * 11250$ = ~168.75$/połów dodatkowy
Config.ClamChance = 10
Config.PearlChance = 15

Config.PearlTypes = {
    {
        name = 'white_pearl',
        label = 'Biała Perła',
        price = 10000,            -- Zwiększono cena
        chance = 60              -- 60% szans przy dropie perły
    },
    {
        name = 'red_pearl',
        label = 'Czerwona Perła',
        price = 12500,            -- Zwiększono cena
        chance = 30              -- 30% szans
    },
    {
        name = 'blue_pearl',
        label = 'Niebieska Perła',
        price = 15000,            -- Zwiększono cena
        chance = 10              -- 10% szans (najrzadsza)
    }
}

Config.Achievements = {
    {
        id = 'fish_master',
        name = 'Mistrz Wędkowania',
        description = 'Złów określoną liczbę ryb',
        icon = 'fish',
        tiers = {
            { requirement = 500, reward_money = 2500, bonus_rare = 1.0, bonus_weight = 1.5 },
            { requirement = 1500, reward_money = 7500, bonus_rare = 1.5, bonus_weight = 2.0 },
            { requirement = 5000, reward_money = 25000, bonus_rare = 2.0, bonus_weight = 3.0 }
        }
    },
    {
        id = 'rare_hunter',
        name = 'Łowca Rzadkości',
        description = 'Złów rzadkie ryby (Rare, Epic, Legendary)',
        icon = 'star',
        tiers = {
            { requirement = 50, reward_money = 3750, bonus_rare = 1.5, bonus_weight = 0.5 },
            { requirement = 150, reward_money = 10000, bonus_rare = 2.0, bonus_weight = 1.0 },
            { requirement = 400, reward_money = 30000, bonus_rare = 3.0, bonus_weight = 1.5 }
        }
    },
    {
        id = 'legendary_fisher',
        name = 'Pogromca Legend',
        description = 'Złów legendarne ryby',
        icon = 'trophy',
        tiers = {
            { requirement = 10, reward_money = 5000, bonus_rare = 2.0, bonus_weight = 1.0 },
            { requirement = 35, reward_money = 15000, bonus_rare = 3.0, bonus_weight = 2.0 },
            { requirement = 100, reward_money = 50000, bonus_rare = 4.0, bonus_weight = 3.0 }
        }
    },
    {
        id = 'weight_collector',
        name = 'Kolekcjoner Wagi',
        description = 'Złów ryby o łącznej wadze',
        icon = 'weight',
        tiers = {
            { requirement = 1000000, reward_money = 4000, bonus_rare = 0.5, bonus_weight = 2.0 },  -- 1000 kg w gramach
            { requirement = 5000000, reward_money = 12500, bonus_rare = 1.0, bonus_weight = 3.0 }, -- 5000 kg w gramach
            { requirement = 15000000, reward_money = 37500, bonus_rare = 1.5, bonus_weight = 4.0 } -- 15000 kg w gramach
        }
    },
    {
        id = 'merchant',
        name = 'Handlarz Morski',
        description = 'Sprzedaj ryby za określoną kwotę',
        icon = 'coins',
        tiers = {
            { requirement = 50000, reward_money = 2500, bonus_rare = 0.5, bonus_weight = 1.0 },
            { requirement = 250000, reward_money = 10000, bonus_rare = 1.0, bonus_weight = 2.0 },
            { requirement = 1000000, reward_money = 37500, bonus_rare = 1.5, bonus_weight = 3.0 }
        }
    },
    {
        id = 'pearl_seeker',
        name = 'Poszukiwacz Pereł',
        description = 'Otwórz określoną liczbę małży',
        icon = 'gem',
        tiers = {
            { requirement = 50, reward_money = 3000, bonus_rare = 1.0, bonus_weight = 0.5 },
            { requirement = 200, reward_money = 10000, bonus_rare = 1.5, bonus_weight = 1.0 },
            { requirement = 500, reward_money = 30000, bonus_rare = 2.0, bonus_weight = 1.5 }
        }
    },
    {
        id = 'dedicated_angler',
        name = 'Oddany Wędkarz',
        description = 'Spędź czas łowiąc ryby (w minutach)',
        icon = 'clock',
        tiers = {
            { requirement = 30, reward_money = 5000, bonus_rare = 1.0, bonus_weight = 1.0 },      -- 30 min (0.5h)
            { requirement = 120, reward_money = 20000, bonus_rare = 1.5, bonus_weight = 2.0 },   -- 120 min (2h)
            { requirement = 300, reward_money = 50000, bonus_rare = 2.0, bonus_weight = 3.0 }   -- 300 min (5h)
        }
    }
}

-- ============================================
-- MISJE CODZIENNE (Daily Missions)
-- ============================================
Config.DailyMissions = {
    ResetTime = 0, -- Godzina resetu misji (0 = północ)
    MissionsPerDay = 3, -- Ile misji gracz dostaje na dzień
    
    Types = {
        -- Typ: catch_specific (złów konkretną rybę)
        {
            type = 'catch_specific',
            fish = 'makrela',
            min_count = 3,
            max_count = 8,
            reward_money_per_item = 2500,
            reward_xp_per_item = 50,
            description_template = "Złów %d szt. ryby: Makrela"
        },
        {
            type = 'catch_specific',
            fish = 'dorsz',
            min_count = 2,
            max_count = 5,
            reward_money_per_item = 4000,
            reward_xp_per_item = 75,
            description_template = "Złów %d szt. ryby: Dorsz"
        },
        -- Typ: catch_any (złów dowolne ryby)
        {
            type = 'catch_any',
            min_count = 10,
            max_count = 20,
            reward_money_per_item = 750,
            reward_xp_per_item = 25,
            description_template = "Złów %d dowolnych ryb"
        },
        -- Typ: catch_rare (złów rzadkie ryby)
        {
            type = 'catch_rarity',
            rarity = 'rare',
            min_count = 1,
            max_count = 3,
            reward_money_per_item = 3000,
            reward_xp_per_item = 200,
            description_template = "Złów %d rzadkich ryb (Rare)"
        },
        -- Typ: earn_money (zarób pieniądze ze sprzedaży)
        {
            type = 'earn_money',
            min_amount = 10000,
            max_amount = 30000,
            reward_money = 2500,
            reward_xp = 300,
            description_template = "Zarób $%d ze sprzedaży ryb"
        }
    }
}