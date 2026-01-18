return {
    dispatch = {
        title = 'Napad na Kontener',
        subtitle = 'Bandziory postanowiły napaśc na kontener, potrzebne wsparcie.',
        code = '10-90',
        color = 'rgb(255, 0, 0)',
        maxReactions = 10, -- max. ilośc PD ktore moga zareagować na zgloszenie. ustaw 0 jak chcesz brak limitu
    },
    crimeNotify = {
        blip = { -- false = brak blipa
            radius = { min = 50 , max = 150 },
            alpha = 200,
            color = 4
        },
        highDetailedBlip = {
            alpha = 200,
            color = 28,
            scale = 1,
            sprite = 50,
            label = 'Kontener'
        },
        centerredBlip = {
            alpha = 200,
            color = 28,
            scale = 1,
            sprite = 50,
            label = 'Napad na Kontener'
        },
        notification = 'Jedna z ekip postanowiła napaśc na kontener. Czujecie się na siłach z swoją ekipą? Odbijcie go. Macie zbliżoną lokalizację oznaczoną na mapie.'
    },
    minTimeToOpenContainer = 30, -- po ilu sekundach gracze mogą otworzyć kontener od rozpoczęcia.
    openContainerMinigame = 'Balance', -- minigra do otwierania kontenera (np. 'CodeFind', 'Hacking', 'Memory', 'Maze', 'Puzzle')
    lootSpots = {
        {
            offset = vec3(0.0, 1.0, 0.2),
            model = 'vw_prop_vw_table_01a',
            rewards = {
                -- Gotówka - zawsze
                { item = 'money', min = 1800, max = 3000, chance = 100 },
                -- Elektronika - podstawowa
                { item = 'phone', min = 1, max = 2, chance = 45 },
                { item = 'lornetka', min = 1, max = 1, chance = 30 },
                { item = 'clean_pendrive', min = 1, max = 2, chance = 35 },
                -- Biżuteria - podstawowa (klamy)
                { item = 'bizuteria', min = 1, max = 3, chance = 50 },
                { item = 'figurka', min = 1, max = 2, chance = 40 },
                { item = 'zegarek', min = 1, max = 1, chance = 30 },
                -- Cenne przedmioty - rzadkie
                { item = 'ring', min = 1, max = 1, chance = 20 },
                { item = 'gold', min = 1, max = 2, chance = 15 },
            }
        },
        {
            offset = vec3(0.80, -0.9, 0.2),
            model = 'm23_2_prop_m32_cratelspd_01a',
            rewards = {
                -- Gotówka - zawsze
                { item = 'money', min = 2000, max = 3500, chance = 100 },
                -- Elektronika - średnia wartość
                { item = 'konsola', min = 1, max = 1, chance = 25 },
                { item = 'gopro', min = 1, max = 1, chance = 30 },
                { item = 'clean_disk', min = 1, max = 2, chance = 35 },
                { item = 'mastercard', min = 1, max = 1, chance = 20 },
                -- Biżuteria - średnia wartość
                { item = 'necklace', min = 1, max = 2, chance = 30 },
                { item = 'goldwatch', min = 1, max = 1, chance = 25 },
                -- Klamy
                { item = 'figurka', min = 1, max = 3, chance = 45 },
                { item = 'bizuteria', min = 1, max = 2, chance = 40 },
            }
        },
        {
            offset = vec3(0.0, -1.25, 0.2),
            model = 'xm_prop_crates_weapon_mix_01a',
            rewards = {
                -- Gotówka - zawsze
                { item = 'money', min = 2000, max = 4000, chance = 100 },
                -- Biżuteria i cenne przedmioty - dobra wartość
                { item = 'rolex', min = 1, max = 1, chance = 25 },
                { item = 'diamond_ring', min = 1, max = 1, chance = 20 },
                { item = 'diamond', min = 1, max = 2, chance = 30 },
                { item = 'gold', min = 1, max = 3, chance = 35 },
                { item = 'necklace', min = 1, max = 2, chance = 30 },
                -- Elektronika premium
                { item = 'konsola', min = 1, max = 1, chance = 20 },
                { item = 'gopro', min = 1, max = 1, chance = 25 },
                -- Klamy
                { item = 'figurka', min = 1, max = 2, chance = 40 },
                { item = 'zegarek', min = 1, max = 1, chance = 35 },
            }
        },
        {
            offset = vec3(0.0, 0.3, 0.2),
            model = 'xm_prop_x17_torpedo_case_01',
            rewards = {
                -- Gotówka - zawsze
                { item = 'money', min = 2000, max = 4500, chance = 100 },
                -- Najcenniejsze przedmioty - premium loot
                { item = 'rolex', min = 1, max = 2, chance = 30 },
                { item = 'diamond_ring', min = 1, max = 2, chance = 25 },
                { item = 'diamond', min = 1, max = 3, chance = 35 },
                { item = 'gold', min = 1, max = 4, chance = 40 },
                { item = 'goldwatch', min = 1, max = 1, chance = 20 },
                { item = 'ring', min = 1, max = 2, chance = 25 },
                -- Sztuka i kolekcjonerskie - bardzo cenne
                { item = 'obraz', min = 1, max = 1, chance = 15 },
                { item = 'artskull', min = 1, max = 1, chance = 12 },
                { item = 'artegg', min = 1, max = 1, chance = 10 },
                { item = 'panther', min = 1, max = 1, chance = 8 },
                -- Elektronika premium
                { item = 'konsola', min = 1, max = 1, chance = 25 },
                { item = 'gopro', min = 1, max = 1, chance = 30 },
                { item = 'clean_disk', min = 1, max = 2, chance = 30 },
                -- Klamy - mniejsza szansa w premium spot
                { item = 'figurka', min = 1, max = 2, chance = 30 },
                { item = 'bizuteria', min = 1, max = 2, chance = 25 },
            }
        }
    },
    
}