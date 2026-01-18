Config = {}
Config.Locale = "pl" -- Supported: EN / SK / CS / DE / PL

Config.Debug = false

Config.AdditionalScripts = {
    op_Gangs = true,
}

Config.LevelCommand = "dealerlevel" -- Check current player level and boost. Set it to false to disable.

Config.dispatchScript = "qf_mdt" 

Config.CurrencySettings = {
    -- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat
    currency = "USD",
    style = "currency",
    format = "en-US"
}

Config.Misc = {
    AccessMethod = "ox-target", -- Supported: ox-target / qb-target
    Notify = "ESX", 
}

Config.DirtyMoney = {
    -- ESX Handles dirty money using balance black_money
    itemName = "black_money"
}

Config.MinCops = 2 -- Minimalna liczba policjantów na służbie wymagana do sprzedaży narkotyków

Config.DrugSelling = {
    availableDrugs = {
        -- Create items in your inventory - https://docs.otherplanet.dev
        ["weed_packaged"] = {
            itemName = "weed_packaged",
            label = "Zapakowana marihuana",
            minimumPrice = 500,
            optimalPrice = 750,
            maximumPrice = 1000,
            maxAmountPedTransaction = 5,
            handPropName = "prop_weed_bottle",
            icon = "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_weed.png",
        },
        ["meth_packaged"] = {
            itemName = "meth_packaged",
            label = "Zapakowana metamfetamina",
            minimumPrice = 1000,
            optimalPrice = 1250,
            maximumPrice = 1500,
            maxAmountPedTransaction = 7,
            handPropName = "p_meth_bag_01_s",
            icon = "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_meth.png",
        },
        ["heroina_packaged"] = {
            itemName = "heroina_packaged",
            label = "Zapakowana heroina",
            minimumPrice = 1000,
            optimalPrice = 1250,
            maximumPrice = 1500,
            maxAmountPedTransaction = 7,
            handPropName = "p_meth_bag_01_s",
            icon = "https://i.ibb.co/fYw6GzNd/heroina-packaged.png",
        },
        ["cocaine_packaged"] = {
            itemName = "cocaincocaine_packagede",
            label = "Zapakowana kokaina",
            minimumPrice = 1500,
            optimalPrice = 1750,
            maximumPrice = 2000,
            maxAmountPedTransaction = 4,
            handPropName = "p_meth_bag_01_s",
            icon = "https://data.otherplanet.dev/fivemicons/%5bdrugs%5d/baggy_cocaine.png",
        },
        ["opium_packaged"] = {
            itemName = "opium_packaged",
            label = "Zapakowane opium",
            minimumPrice = 2000,
            optimalPrice = 2250,
            maximumPrice = 2500,
            maxAmountPedTransaction = 7,
            handPropName = "p_meth_bag_01_s",
            icon = "https://i.ibb.co/QvVsZdtn/opium-packaged.png",
        },
        ["cannabis_joint"] = {
            itemName = "cannabis_joint",
            label = "Joint Cannabis",
            minimumPrice = 525,
            optimalPrice = 650,
            maximumPrice = 750,
            maxAmountPedTransaction = 15,
            handPropName = "p_cs_joint_01",
            icon = "nui://ox_inventory/web/images/cannabis_joint.webp",
        },
        ["ogkush_joint"] = {
            itemName = "ogkush_joint",
            label = "Joint OG Kush",
            minimumPrice = 650,
            optimalPrice = 750,
            maximumPrice = 900,
            maxAmountPedTransaction = 15,
            handPropName = "p_cs_joint_01",
            icon = "nui://ox_inventory/web/images/ogkush_joint.webp",
        },
        ["oghaze_joint"] = {
            itemName = "oghaze_joint",
            label = "Joint OG Haze",
            minimumPrice = 650,
            optimalPrice = 750,
            maximumPrice = 900,
            maxAmountPedTransaction = 15,
            handPropName = "p_cs_joint_01",
            icon = "nui://ox_inventory/web/images/oghaze_joint.webp",
        },
    },
    dispatchCallChance = 20, -- 20% Chance that after transaction dispatch will be called.
    blipData = {
        -- Dispatch Blips Data
        sprite = 51, -- Blip sprite
        color = 1, -- Blip color
    }
}

Config.CornerDealing = {
    Enable = true, 
    SellTimeoutMin = 3,
    SellTimeoutMax = 10,
    Command = "dealer",
    MaxSalesPerArea = {
        Min = 3,
        Max = 6,
    },
    MaxDistance = 70.0,
    AreaCooldownTime = 20,
    AreaRadius = 300.0,
}

Config.JobBlacklist = {
    Enable = true, -- Enable job blacklist check
    Jobs = {
        "police",
        "sheriff",
        "ambulance",
        -- "mechanic",
    }
}

Config.Leveling = {
    Enable = true,
    LevelEXP = 1000, -- One level == 500 exp.
    LevelsList = {
        [1] = 1, -- 1% Boost for level.
        [2] = 2, -- 2% Boost for level.
        [3] = 3, -- 3% Boost for level.
        [4] = 4, -- 4% Boost for level.
        [5] = 5, -- 5% Boost for level.
    }
}

Config.PedTypes = {
    ['addicted'] = {
        label = "Uzależniony",
        saleEXP = 5, -- EXP per Sale.
        stealDrugChance = 30, -- Chance that ped will steal your drugs!
        buyChance = 80, -- Range 0-100
        refuseChance = 0, -- Range 0-100 (This is refuse without even open of drug dealing menu)
        dispatchCall = false, -- Can this type of ped call dispatch
        colors = {
            -- Label Box next to ped Name.
            border = "#8400ff",
            background = "#8400ff8c"
        }
    },
    ['normal'] = {
        label = "Normalny",
        saleEXP = 25, -- EXP per Sale.
        stealDrugChance = 10, -- Chance that ped will steal your drugs!
        buyChance = 50, -- Range 0-100
        refuseChance = 15, -- Range 0-100 (This is refuse without even open of drug dealing menu)
        dispatchCall = true, -- Can this type of ped call dispatch
        colors = {
            -- Label Box next to ped Name.
            border = "#00ccffff",
            background = "#00aeff8c"
        }
    },
    ['party'] = {
        label = "Imprezowy",
        saleEXP = 15, -- EXP per Sale.
        stealDrugChance = 10, -- Chance that ped will steal your drugs!
        buyChance = 75, -- Range 0-100
        refuseChance = 5, -- Range 0-100 (This is refuse without even open of drug dealing menu)
        dispatchCall = true, -- Can this type of ped call dispatch
        colors = {
            -- Label Box next to ped Name.
            border = "#ffa600ff",
            background = "#ffbb008c"
        }
    },
    ['snitch'] = {
        label = "Kapuś",
        saleEXP = 40,
        stealDrugChance = 0, -- nie kradnie
        buyChance = 20, -- bardzo rzadko kupuje
        refuseChance = 50, -- często od razu odmawia
        dispatchCall = true, -- zawsze duże ryzyko wzywania policji
        colors = {
            border = "#ff0000",
            background = "#ff00008c"
        }
    },
    ['dealer'] = {
        label = "Diler uliczny",
        saleEXP = 30,
        stealDrugChance = 20, -- może spróbować cię ograć
        buyChance = 60, -- kupi, ale w większych ilościach
        refuseChance = 10,
        dispatchCall = false, -- nie wzywa psów, bo sam kręci biznes
        colors = {
            border = "#00ff00",
            background = "#00ff008c"
        }
    },
    ['rich'] = {
        label = "Bogacz",
        saleEXP = 10,
        stealDrugChance = 0,
        buyChance = 90, -- prawie zawsze kupuje
        refuseChance = 0,
        dispatchCall = true, -- czasami zadzwoni, jak się przestraszy
        colors = {
            border = "#ffd700",
            background = "#ffd7008c"
        }
    },
    ['junkie'] = {
        label = "Narkoman",
        saleEXP = 5,
        stealDrugChance = 50, -- mega ryzyko kradzieży
        buyChance = 70,
        refuseChance = 10,
        dispatchCall = false, -- nie ogarnia policji
        colors = {
            border = "#8b4513",
            background = "#8b45138c"
        }
    },
    ['undercover'] = {
        label = "Policjant pod przykrywką",
        saleEXP = 50,
        stealDrugChance = 0,
        buyChance = 30, -- udaje że kupuje
        refuseChance = 0,
        dispatchCall = true, -- 100% szansa że poleci dispatch
        colors = {
            border = "#2121c4ff",
            background = "#0404ff69"
        }
    },
}

Config.PedsList = {
    -- Other Peds Not Listed Here will be handled like Normal Ped Type.
    -- [Addicted Peds]
    [`a_f_m_skidrow_01`] = 'addicted',
    [`g_m_y_ballasout_01`] = 'addicted',
    [`g_m_y_ballaeast_01`] = 'addicted',
    [`g_m_y_famca_01`] = 'addicted',
    [`g_m_y_famdnf_01`] = 'addicted',
    [`g_m_y_mexgoon_03`] = 'addicted',
    [`g_m_y_pologoon_01`] = 'addicted',
    [`g_m_y_pologoon_02`] = 'addicted',
    [`g_m_y_salvagoon_01`] = 'addicted',
    [`g_m_y_salvagoon_03`] = 'addicted',
    [`g_m_y_strpunk_01`] = 'addicted',

    -- [Party Peds]
    [`a_m_y_hipster_01`] = 'party',
    [`a_f_y_clubcust_01`] = 'party',
    [`a_m_y_clubcust_01`] = 'party',
    [`a_f_y_clubcust_02`] = 'party',
    [`a_m_y_clubcust_02`] = 'party',
    [`a_m_y_clubcust_03`] = 'party',
    [`csb_ramp_hipster`] = 'party',
    [`csb_ramp_mex`] = 'party',

    -- [Snitch Peds]
    [`a_m_m_business_01`] = 'snitch',
    [`a_m_m_eastsa_02`] = 'snitch',
    [`a_f_y_business_01`] = 'snitch',
    [`a_f_y_business_02`] = 'snitch',
    [`csb_reporter`] = 'snitch',

    -- [Dealer Peds]
    [`g_m_y_ballaorig_01`] = 'dealer',
    [`g_m_y_mexgang_01`] = 'dealer',
    [`g_m_y_mexgoon_01`] = 'dealer',
    [`g_m_y_famfor_01`] = 'dealer',
    [`g_m_y_strpunk_02`] = 'dealer',

    -- [Rich Peds]
    [`a_m_m_soucent_01`] = 'rich',
    [`a_m_y_bevhills_01`] = 'rich',
    [`a_f_y_bevhills_01`] = 'rich',
    [`a_f_y_bevhills_02`] = 'rich',
    [`u_m_y_imporage`] = 'rich',
    [`u_m_y_party_01`] = 'rich',

    -- [Junkie Peds]
    [`a_m_y_skater_01`] = 'junkie',
    [`a_m_y_skater_02`] = 'junkie',
    [`a_m_m_tramp_01`] = 'junkie',
    [`a_f_m_tramp_01`] = 'junkie',
    [`a_m_m_trampbeac_01`] = 'junkie',
    [`a_m_m_trampbeac_02`] = 'junkie',
    [`u_m_y_staggrm_01`] = 'junkie',

    -- [Undercover Cop Peds]
    [`s_m_m_ciasec_01`] = 'undercover',
    [`s_m_m_highsec_01`] = 'undercover',
    [`s_m_m_highsec_02`] = 'undercover',
    [`s_m_y_cop_01`] = 'undercover',
    [`csb_undercover`] = 'undercover'
}


-- Black list peds
Config.BlackListPeds = {
    [`a_m_m_skidrow_01`] = true,
}

Config.City = {
    {
        name = "Miasto",
        points = {
            vector3(-3158.0380859375, 696.20330810547, 5.0),
            vector3(1712.7565917969, 647.62292480469, 5.0),
            vector3(1712.7565917969, 647.62292480469, 5.0),
            vector3(1892.6589355469, -1355.2430419922, 5.0),
            vector3(1654.6428222656, -2616.9780273438, 5.0),
            vector3(1335.8132324219, -3392.4216308594, 5.0),
            vector3(-23.743768692017, -3427.4011230469, 5.0),
            vector3(-1085.7600097656, -3603.8869628906, 5.0),
            vector3(-2032.7357177734, -3129.3762207031, 5.0)
        },
        thickness = 200.0
    },
}

Config.BlockedAreas = {
    Enable = true,
    Areas = {
        -- Komenda Mission Row
        {
            type = "circle",
            center = vector3(425.1, -979.5, 30.7),
            radius = 100.0,
        },
        -- Komenda Davis
        {
            type = "circle",
            center = vec3(374.2077331543, -1600.7231445312, 30.051355361938),
            radius = 50.0,
        },
        -- Rybak
        {
            type = "circle",
            center = vec3(-1838.4334716797, -1225.7275390625, 13.017248153687),
            radius = 40.0,
        },
        -- Szpital
        {
            type = "circle",
            center = vec3(1155.1767578125, -1528.2945556641, 34.843688964844),
            radius = 70.0,
        },
        -- Komenda Sandy
        {
            type = "circle",
            center = vec3(1838.1047363281, 3681.5993652344, 34.454231262207),
            radius = 60.0,
        },
        -- Komenda Paleto
        {
            type = "circle",
            center = vec3(-459.00561523438, 6013.3681640625, 36.630310058594),
            radius = 40.0,
        },
        -- Więzienie
        {
            type = "circle",
            center = vec3(1691.8187255859, 2604.5383300781, 45.564842224121),
            radius = 200.0,
        },
        -- Doj
        {
            type = "circle",
            center = vec3(-549.90991210938, -195.28869628906, 38.920913696289),
            radius = 70.0,
        },
        -- Mechanik
        {
            type = "circle",
            center = vec3(-347.68310546875, -129.74960327148, 40.66943359375),
            radius = 40.0,
        },
        -- Taxi
        {
            type = "circle",
            center = vec3(-1246.4388427734, -277.55590820312, 37.876842498779),
            radius = 30.0,
        },
        -- Bahamas
        {
            type = "circle",
            center = vec3(-1404.1961669922, -598.75329589844, 30.318969726562),
            radius = 20.0,
        },
        -- Uwu
        {
            type = "circle",
            center = vec3(-583.32080078125, -1060.1566162109, 22.344188690186),
            radius = 30.0,
        },
        -- Bean Cafe
        {
            type = "circle",
            center = vec3(343.69369506836, -779.18188476562, 30.523582458496),
            radius = 24.0,
        },
        -- Urząd Pracy
        {
            type = "circle",
            center = vec3(-265.88861083984, -962.24627685547, 30.906616210938),
            radius = 20.0,
        },
        -- Apartamenty
        {
            type = "circle",
            center = vector3(-742.8883, -2283.5989, 13.0600),
            radius = 60.0,
        },
    }
}