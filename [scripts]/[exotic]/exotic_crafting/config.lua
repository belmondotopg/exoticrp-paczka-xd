Config = {}

Config.Recipes = {
    -- POZIOM 1
    {
        label = "Nabój 9mm",
        shortDescription = "Amunicja do broni krótkiej",
        fullDescription = "Standardowy nabój kalibru 9mm. Stosowany w większości pistoletów. Niezbędny, jeśli chcesz utrzymać broń w akcji.",
        itemName = "ammo-9",
        craftItems = {
            ["bulletcasings"] = {
                label = "Łuska",
                quantity = 1
            },
            ["proch"] = {
                label = "Proch strzelniczy",
                quantity = 2
            },
        },
        craftDuration = 5000,
        requiredLevel = 1
    },
    {
        label = "Bandaż medyczny",
        shortDescription = "Podstawowy opatrunek",
        fullDescription = "Standardowy bandażyk do opatrywania ran. Przywraca niewielką ilość zdrowia.",
        itemName = "bandage",
        craftItems = {
            ["clothe"] = {
                label = "Tkanina",
                quantity = 2
            },
            ["tasma"] = {
                label = "Taśma",
                quantity = 1
            },
        },
        craftDuration = 5000,
        requiredLevel = 1
    },

    -- POZIOM 2
    {
        label = "Apteczka",
        shortDescription = "Podstawowa apteczka medyczna",
        fullDescription = "Kompletna apteczka zawierająca podstawowe środki medyczne. Przywraca znaczną ilość zdrowia.",
        itemName = "medikit",
        craftItems = {
            ["bandage"] = {
                label = "Bandaż medyczny",
                quantity = 3
            },
            ["apteka_bandaz"] = {
                label = "Bandaż",
                quantity = 2
            },
            ["apteka_opatrunek"] = {
                label = "Opatrunek",
                quantity = 2
            },
        },
        craftDuration = 10000,
        requiredLevel = 2
    },
    {
        label = "Zestaw czyszczący",
        shortDescription = "Zestaw do czyszczenia pojazdów",
        fullDescription = "Zestaw do czyszczenia pojazdów. Czyści brud i decale z karoserii.",
        itemName = "cleaningkit",
        craftItems = {
            ["szmata"] = {
                label = "Szmata",
                quantity = 2
            },
            ["water_bottle"] = {
                label = "Woda",
                quantity = 3
            },
        },
        craftDuration = 6000,
        requiredLevel = 2
    },

    -- POZIOM 3
    {
        label = "Magazynek",
        shortDescription = "Magazynek do broni",
        fullDescription = "Standardowy magazynek zwiększający pojemność amunicji w broni. Niezbędny dla każdego strzelca.",
        itemName = "magazynek",
        craftItems = {
            ["iron"] = {
                label = "Żelazo",
                quantity = 2
            },
            ["sprezyna"] = {
                label = "Sprężyna",
                quantity = 1
            },
        },
        craftDuration = 8000,
        requiredLevel = 3
    },
    {
        label = "Joint",
        shortDescription = "Zawinięty joint",
        fullDescription = "Gotowy do użycia joint. Popularny wśród mieszkańców miasta.",
        itemName = "joint",
        craftItems = {
            ["weed"] = {
                label = "Marihuana",
                quantity = 2
            },
            ["cigarette"] = {
                label = "Papieros",
                quantity = 1
            },
        },
        craftDuration = 5000,
        requiredLevel = 3
    },

    -- POZIOM 5
    {
        label = "Zestaw naprawczy",
        shortDescription = "Podstawowy zestaw do naprawy pojazdów",
        fullDescription = "Zestaw narzędzi i części do podstawowej naprawy pojazdów. Naprawia pojazd do około 60-70%.",
        itemName = "repairkit",
        craftItems = {
            ["iron"] = {
                label = "Żelazo",
                quantity = 3
            },
            ["tasma"] = {
                label = "Taśma",
                quantity = 2
            },
            ["fixtool"] = {
                label = "Narzędzia naprawcze",
                quantity = 1
            },
        },
        craftDuration = 12000,
        requiredLevel = 5
    },

    -- POZIOM 10
    {
        label = "Zaawansowany zestaw naprawczy",
        shortDescription = "Profesjonalny zestaw do pełnej naprawy",
        fullDescription = "Zaawansowany zestaw do pełnej naprawy pojazdów (100%). Tylko dla doświadczonych mechaników.",
        itemName = "advancedrepairkit",
        craftItems = {
            ["iron"] = {
                label = "Żelazo",
                quantity = 5
            },
            ["copper"] = {
                label = "Miedź",
                quantity = 3
            },
            ["fixtool"] = {
                label = "Narzędzia naprawcze",
                quantity = 2
            },
            ["repair_kit"] = {
                label = "Zestaw naprawczy",
                quantity = 1
            },
        },
        craftDuration = 20000,
        requiredLevel = 10
    },
    {
        label = "Ładunek termiczny",
        shortDescription = "Termiczny ładunek wybuchowy",
        fullDescription = "Zaawansowany ładunek termiczny. Używany do otwierania sejfów i drzwi.",
        itemName = "ladunektermiczny",
        craftItems = {
            ["thermite"] = {
                label = "Termit",
                quantity = 2
            },
            ["iron"] = {
                label = "Żelazo",
                quantity = 3
            },
            ["tasma"] = {
                label = "Taśma",
                quantity = 1
            },
        },
        craftDuration = 18000,
        requiredLevel = 10
    },

    -- POZIOM 12
    {
        label = "Bomba do bankomatu",
        shortDescription = "Ładunek wybuchowy",
        fullDescription = "Specjalistyczna bomba do wysadzania bankomatów. Niebezpieczna, ale skuteczna.",
        itemName = "atm_bomb",
        craftItems = {
            ["c4"] = {
                label = "Ładunek C4",
                quantity = 1
            },
            ["tasma"] = {
                label = "Taśma",
                quantity = 2
            },
            ["iron"] = {
                label = "Żelazo",
                quantity = 2
            },
        },
        craftDuration = 20000,
        requiredLevel = 12
    },
}

Config.XPRewards = {
    craftSuccess = 50,
    levelUpMultiplier = 100,
    bandage = 50
}

Config.MaxLevel = 50
Config.DefaultLevel = 1
Config.DefaultXP = 0