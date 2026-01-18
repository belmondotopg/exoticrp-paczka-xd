-- ──────────────────────────────────────────────────────────────────────────────
-- Dependency Check Helper                                                     
-- (Information) ► Returns the first matching started resource alias from provided table.
-- (Information) ► Used by Fuel/Keys/TextUI/Inventory/Target detection above.
-- ──────────────────────────────────────────────────────────────────────────────
function scriptCheck(data)            -- Do not modify unless you know what you're doing.
    for k, v in pairs(data) do
        if GetResourceState(k):find('started') ~= nil then
            return v
        end
    end
    return false
end

-- ──────────────────────────────────────────────────────────────────────────────
--  OTHERPLANET / OP Gangs 2.0 Main CONFIGURATION
-- ──────────────────────────────────────────────────────────────────────────────
--  This configuration file controls all customizable behaviour of OP Gangs 2.0.
--  Always make a backup before editing.
--  Wrong edits can break the resource.
-- ──────────────────────────────────────────────────────────────────────────────

Config = {}                           

-- ──────────────────────────────────────────────────────────────────────────────
-- Locale & Debug                                                             
-- (Information) ► Locale controls which language file from locales/* will be used.
-- (Information) ► Debug enables extra logging to help with issue tracking.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Locale = "pl"                  -- Supported: PL / ES / LT / HU / EN / FR / IT / PT / SK / TW / HR / EL / CZ / SI / AR / TR / DE / SV / NL
Config.Debug  = false                 -- true = verbose debug output in console.

-- ──────────────────────────────────────────────────────────────────────────────
-- Fuel Dependency Detection                                                   
-- (Information) ► Auto-detects your active fuel resource.
-- (Information) ► To add support for another fuel script, extend the list below and 
-- (Information) ► handle logic in the integrations where fuel is used.
-- ──────────────────────────────────────────────────────────────────────────────
local fuelScripts = {                 
    ['cdn-fuel']        = "cdn-fuel",
    ['ox_fuel']         = "ox_fuel",
    ['LegacyFuel']      = "LegacyFuel",
    ['qs-fuelstations'] = "qs-fuel",
    ['rcore_fuel']      = "rcore-fuel",
    ['codem-xfuel']     = "codem-xfuel",
    ['lc_fuel']         = "lc_fuel",
    ['stg-fuel']        = "stg-fuel",
}
Config.FuelDependency = scriptCheck(fuelScripts) or 'ox_fuel'

-- ──────────────────────────────────────────────────────────────────────────────
-- Vehicle Keys Dependency Detection                                           
-- (Information) ► Auto-detects supported vehicle key systems.
-- (Information) ► If none is found, script will behave as if no key system is present.
-- ──────────────────────────────────────────────────────────────────────────────
local keyScripts = {                  
    ['brutal_keys']        = "brutal_keys",
    ['qs-keys']            = "qs-keys",
    ['qbx_vehiclekeys'] = "qb-keys",
    ['qb-vehiclekeys']            = "qb-keys",
    ['wasabi_carlock']     = "wasabi_carlock",
    ['sna-vehiclekeys']    = "sna-vehiclekeys",
    ['dusa_vehiclekeys']   = "dusa_vehiclekeys",
    ['Renewed-Vehiclekeys']= "Renewed-Vehiclekeys",
    ['tgiann-hotwire']     = "tgiann-keys",
    ['ak47_vehiclekeys']   = "ak47_vehiclekeys",
    ['ak47_qb_vehiclekeys']= "ak47_qb_vehiclekeys",
    ['mVehicle']           = "mVehicle",
    ['sy_carkeys']         = "sy_carkeys",
    ['MrNewbVehicleKeys']  = "MrNewbVehicleKeys",
}
Config.KeysDependency = scriptCheck(keyScripts) or 'none'

-- ──────────────────────────────────────────────────────────────────────────────
-- Text UI Dependency Detection                                                
-- (Information) ► Auto-detects supported 3D/2D Text UI libraries.
-- (Information) ► If none is found, some prompts may fallback to default behaviour.
-- ──────────────────────────────────────────────────────────────────────────────
local textUIScripts = {              
    ['ox_lib']        = "ox_lib",
    ['jg-textui']     = "jg-textui",
    ['okokTextUI']    = "okokTextUI",
    ['brutal_textui'] = "brutal_textui",
    ['0r-textui']     = "0r-textui",
}
Config.TextUI = scriptCheck(textUIScripts) or 'jg-textui' 

-- ──────────────────────────────────────────────────────────────────────────────
-- Garage Script                                                               
-- (Information) ► Manual selection of external garage script integration.
-- (Information) ► If set to 'none', OP-Crime will handle garage logic internally where applicable.
-- ──────────────────────────────────────────────────────────────────────────────
Config.GarageScript = 'op-garages'          -- Options: 'none', 'op-garages', 'jg-advancedgarages'

-- ──────────────────────────────────────────────────────────────────────────────
-- Additional Script Integrations                                              
-- (Information) ► Toggle support for optional helper resources.
-- ──────────────────────────────────────────────────────────────────────────────
Config.AdditionalScripts = {         
    kq_shellcreator  = false,         -- (Information) ► true if you are using kq_shellcreator.
    advancedParking  = false          -- (Information) ► true if you use AdvancedParking.
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Inventory System Detection                                                  
-- (Information) ► Auto-detects currently started inventory system.
-- (Information) ► To support more inventories, extend the list and update inventory integration.
-- ──────────────────────────────────────────────────────────────────────────────
local inventoryScripts = {            
    ['ox_inventory']     = "ox_inventory",
    ['qb-inventory']     = "qb-inventory",
    ['codem-inventory']  = "codem-inventory",
    ['qs-inventory']     = "quasar_inventory",
    ['tgiann-inventory'] = "tgiann_inventory",
    ['origen_inventory'] = "origen_inventory",
}

-- If you're using QB Inventory and it's not working properly set below option to:
-- Config.Inventory = {                  
--     inventoryScript = 'old-qb-inventory'
-- }

Config.Inventory = {                  
    inventoryScript = scriptCheck(inventoryScripts) or 'ox_inventory'
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Currency Formatting                                                         
-- (Information) ► Visual formatting of money values in the UI (JS Intl.NumberFormat).
-- (Information) ► This does NOT change internal game currency logic, only display.
-- ──────────────────────────────────────────────────────────────────────────────
Config.CurrencySettings = {           
    -- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat
    currency = "USD",                 -- 'USD','EUR','PLN', etc.
    style    = "currency",            -- 'currency','decimal','percent','unit'
    format   = "en-US"                -- Locale string for formatting.
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Dirty Money Handling                                                        
-- (Information) ► ESX: Uses default 'black_money' account automatically.
-- (Information) ► QB/QBOX: Uses configured item as dirty cash equivalent.
-- ──────────────────────────────────────────────────────────────────────────────
Config.DirtyMoney = {                 
    itemName = "black_money" -- Dirty money item name on QB/QBOX.
}

-- ──────────────────────────────────────────────────────────────────────────────
-- ⚒️ MISC CONFIGURATION ⚒️                                                   
-- (Information) ► General behaviour, markers, notifications, ranking limits, etc.
-- ──────────────────────────────────────────────────────────────────────────────

local targets = { -- Target libraries detection
    ['ox_target'] = "ox_target",
    ['qb-target'] = "qb-target"
}

local notifyScripts = { -- Notify libraries detection
    ['op-hud'] = "op_hud",
    ['okokNotify'] = "okokNotify",
    ['vms_notify'] = "vms_notify",
    ['ox_lib'] = "ox_lib",
    ['brutal_notify'] = "brutal_notify",
}

Config.Misc = {                       
    AccessMethod = scriptCheck(targets) or 'ox_target', --  'ox_target' / 'qb-target' / 'none'
    zoneSize = 1.2,                   -- Marker radius for interaction zones.
    zoneColor = {                     -- Marker color (RGB).
        r = 219,
        g = 0,
        b = 0,
    },
    TowingTime = 5,                                -- Towing time in seconds.
    Notify = 'ESX', -- Notify system: none / ESX / QBCORE / QBOX or auto detected from list 'notifyScripts'
    stashCapacityUpgradePer = 5,                   -- One stash upgrade = +X KG. Note: Changing this requires your changes in Locale file! UI description (will still display that upgrade adds 5kg until you adjust translation)
    ranksLimit   = 10,                              -- Max number of ranks per organisation.
    membersLimit = 50,                             -- Max number of members per organisation.
    limitBossMenu = false,                         -- true = only one player can access bossmenu at once. Note: You can limit bossmenu to one player at a time!
    disableGarage = false,                         -- true = completely disable garages & vehicle shop in bossmenu.
    disableDarkChat = true,                       -- true = disable darkchat in crime tablet.
    disableDarkChatNotificationAboveMap = true,   -- true = disable on-screen darkchat notifications.
    disableRanking = false,                        -- true = disable ranking page in tablet.
    defaultStashWeight = 30,                        -- Default Stash KG for new Gangs.
    defaultRanksSlotsAmount = 40,                   -- Default Ranks Slots for new Gangs.
    defaultRanksMembersAmount = 2,                 -- Default Member Slots for new Gangs.
} 

-- ──────────────────────────────────────────────────────────────────────────────
-- Admin Commands & Permissions                                                
-- (Information) ► Configure admin commands and who is allowed to use them.
-- ──────────────────────────────────────────────────────────────────────────────
Config.AdminPanelCommand   = "crimeadmin"   -- Command for Crime Admin Panel.
Config.SetJobCommand       = "setcrimejob"  -- Command to set selected player's crime job.
Config.AddCrimeVehicle     = "addcrimecar"  -- Command to add vehicle to selected organisation.
Config.FireCommand         = "firemember"   -- Command to fire member from current organisation.
Config.ResetGangsStats     = "resetgangstats" -- Wipes all gangs stats (zones, missions, etc.) used in ranking.

-- List of allowed identifiers to use admin Commands /setcrimejob and /addcrimecar
-- (Information) ► Use identifiers from txAdmin -> IDs (no hardware IDs!).
-- (Information) ► You can also use character identifiers or citizenid on QBOX/QB.
-- E.g.: char1:7e0ec7b80d186fd8c29f6631e4377e75812fe8fd
Config.AdminCommandsPlayers = {
    ['discord:498526179117105163'] = true,
    ['discord:465585705939107843'] = true,
    ['discord:815589364133920808'] = true,
    ['discord:1051921534438092840'] = true,
    ['discord:689954905129353340'] = true,
    ['discord:1412832774720589874'] = true,
    ['discord:1128633417593000108'] = true,
    ['discord:775081029043486750'] = true
}

-- List of allowed identifiers to use /crimeadmin
-- Same rules as above (txAdmin IDs / character identifiers / citizenid).
Config.AdminPanelPlayers = {
    ['discord:498526179117105163'] = true,
    ['discord:465585705939107843'] = true,
    ['discord:815589364133920808'] = true,
    ['discord:1051921534438092840'] = true,
    ['discord:689954905129353340'] = true,
    ['discord:1412832774720589874'] = true,
    ['discord:1128633417593000108'] = true,
    ['discord:775081029043486750'] = true
}

Config.SellVehiclePercentage = 20     -- Percentage of original vehicle price when selling in bossmenu.

-- ──────────────────────────────────────────────────────────────────────────────
-- 📱 TABLET CONFIGURATION 📱                                                 
-- (Information) ► Controls how crime tablet is accessed and how missions are handled.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Tablet = {                     
    tabletASItem = true,             -- true = tablet is usable item, false = command-based.
    commandName = "crimetablet",      -- Command used when tabletASItem is false.
    item = {
        name = "crime_tablet"         -- Required item name if tabletASItem is true.
    },
    MissionsPerRestart = 3,           -- How many missions per organisation per update.
    DisableSeasonPass = true,        -- true = disable season pass feature Completly (As well from Boss Menu and Admin Panel).
    DisableFrames = false,            -- true = hide tablet frame UI elements.
}

-- ──────────────────────────────────────────────────────────────────────────────
-- 🌍 BLIPS CONFIGURATION 🌍                                                  
-- (Information) ► Map blips for organisations, garages, zones and money laundry.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Blips = {                      
    BlipScale = 0.7,                  -- Global blip scale.
    ShowBlipsOnMap = true,            -- false = hide money laundry, garages and illegal medic blips.
    ZonesShowBlipsOnMap = true,       -- false = hide PVP/turf zone blips.
    Medic = { blipId = 51, blipColor = 50 },
    Organisation = { blipId = 437, blipColor = 1 },
    Zone = { blipId = 458, blipColor = 26 },
    Garage = { blipId = 357, blipColor = 2 },
    MoneyLaundry = { blipId = 500, blipColor = 25 },
    MoneyLaundryLocation = { blipId = 478, blipColor = 1 },
    LaundryLocationRadiusBlip = { 
        Color = 49,
        Alpha = 222,
        Radius = 60.0
    }
}

-- ──────────────────────────────────────────────────────────────────────────────
-- 🧼 MONEY LAUNDRY CONFIGURATION 🧼                                         
-- (Information) ► Settings for dirty money washing missions.
-- ──────────────────────────────────────────────────────────────────────────────
Config.MoneyLaundry = {               
    Disable = false,                  -- true = disable entire money laundry feature.
    laundryAmountPerOneStop = 20000,  -- Amount of dirty money cleaned per location.
    laundryPercentage = 15,           -- Tax percentage taken from laundered amount.
    Ped = {                           -- Set to false to disable ped (Ped = false,).
        model = "a_m_m_afriamer_01",
        gender = "male", -- options: male/female
    },
    laundryMisc = {
        location = vec4(78.8508, 112.5588, 80.1682, 161.7077),
        vehicleSpawnCoords = vec4(68.4445, 119.2293, 79.1232, 161.5234),
        vehicleModel = 'boxville4',
        -- LAUNDRY MISSION OUTFIT IS LOCATED NOW IN config/ClothingConfig.lua
    },
    laundryLocations = {
        {
            coords = vec4(237.7540, 22.6503, 82.6137, 341.4727)
        },
        {
            coords = vec4(-77.5555, -1200.6666, 26.6352, 92.4784)
        },
        {
            coords = vec4(232.4930, -1771.4315, 27.6610, 48.4330)
        },
        {
            coords = vec4(967.5204, -1823.1718, 30.0824, 229.1019)
        },
        {
            coords = vec4(947.5532, -1698.1992, 29.0851, 84.8497)
        },
    }
}

-- ──────────────────────────────────────────────────────────────────────────────
-- 🏥 MEDIC CONFIGURATION 🏥                                                 
-- (Information) ► Illegal medic / healing spot configuration.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Medic = {                      
    Disable = false,                  -- true = disable this feature.
    HealingTime = 10,                 -- Healing time in seconds.
    Ped = {
        model = "s_m_m_scientist_01",
        gender = "male",
        animation = {
            Dict = "missheistdockssetup1clipboard@base",
            Lib  = "base",
            Prop = {
                Prop = 'prop_notepad_01',
                PropBone = 18905,
                PropPlacement = {
                    0.1,
                    0.02,
                    0.05,
                    10.0,
                    0.0,
                    0.0
                }
            }
        }
    }
}

-- ──────────────────────────────────────────────────────────────────────────────
-- 📍 PVP ZONES CONFIGURATION 📍                                             
-- (Information) ► Non-turf PVP zones. For Turf Zones see: config/TurfConfig.lua
-- ──────────────────────────────────────────────────────────────────────────────

-- THIS IS SECTION FOR PVP ZONES (NO TURFZONES)
-- IF YOU WANT TO CONFIGURE TURF ZONES - GO TO config/TurfConfig.lua

Config.ZonesMisc = {                 
    PerOnePlayerInside = 2,           -- Time (in seconds) for 1% capture progress for one org.
    -- If there are 2 organisations in zone the zone capturing percentage will stop.
    ZonesCooldown   = 30,             -- Cooldown time (in minutes) after a capture.
    ZoneCaptureEXP  = 150,            -- EXP given per zone capture.
    Disable         = false,          -- true = disable PVP zones completely.
}

Config.Zones = {                      -- Add custom PVP zones here.
    -- To create new zones use /pzcreate poly
    -- To add new point to created poly use /pzadd 
    -- More info: https://github.com/mkafrin/PolyZone
    {
        label = "#1 Złomowisko",
        index = "zlomowkisko",
        coords = vec3(2404.2021, 3104.1765, 48.1648),
        Zone = function()
            return PolyZone:Create({
                vector2(2329.3020019532, 3053.681640625),
                vector2(2330.888671875, 3081.3254394532),
                vector2(2361.8330078125, 3087.1943359375),
                vector2(2379.0219726562, 3105.4108886718),
                vector2(2404.3395996094, 3163.1628417968),
                vector2(2437.2124023438, 3160.5307617188),
                vector2(2434.8149414062, 3024.4143066406),
                vector2(2329.9057617188, 3024.9143066406)
            }, {
                name = "Złomowisko",
            })
        end,
    },
    {
        label = "#2 Mini Losty",
        index = "minilosty",
        coords = vec3(2341.5466308594, 2559.3044433594, 46.667495727539),
        Zone = function()
            return PolyZone:Create({
                vector2(2335.3974609375, 2645.3149414062),
                vector2(2379.3532714844, 2644.0764160156),
                vector2(2382.6208496094, 2616.0229492188),
                vector2(2380.2077636719, 2568.5031738281),
                vector2(2371.8662109375, 2534.1787109375),
                vector2(2359.1811523438, 2504.0974121094),
                vector2(2339.3916015625, 2502.2075195312),
                vector2(2316.412109375, 2506.5021972656),
                vector2(2300.7746582031, 2520.2883300781),
                vector2(2296.3771972656, 2541.9865722656)
            }, {
                name = "MiniLosty",
            })
        end,
    },
    {
        label = "#3 Motel",
        index = "motel",
        coords = vec3(1563.1080322266, 3573.8400878906, 33.761451721191),
        Zone = function()
            return PolyZone:Create({
                vector2(1478.5581054688, 3582.7868652344),
                vector2(1588.6329345703, 3646.2890625),
                vector2(1636.5374755859, 3559.6403808594),
                vector2(1586.7253417969, 3539.7348632812),
                vector2(1552.4140625, 3531.2890625),
                vector2(1512.0590820312, 3516.0893554688)
            }, {
                name = "Motel",
            })
        end,
    },
    {
        label = "#4 Elektrownia",
        index = "elektrownia",
        coords = vec3(2821.5078125, 1493.8980712891, 24.571510314941),
        Zone = function()
            return PolyZone:Create({
                vector2(2784.6137695312, 1476.7646484375),
                vector2(2817.7868652344, 1592.0500488281),
                vector2(2882.3898925781, 1574.3654785156),
                vector2(2884.1879882812, 1533.6999511719),
                vector2(2855.7744140625, 1425.9027099609),
                vector2(2852.0480957031, 1426.9506835938),
                vector2(2859.2038574219, 1455.8220214844),
                vector2(2837.6752929688, 1439.3953857422),
                vector2(2814.4895019531, 1444.4295654297),
                vector2(2818.7531738281, 1466.3061523438)
            }, {
                name = "Elektrownia",
            })
        end,
    },
    {
        label = "#5 Paleto",
        index = "paleto",
        coords = vec3(1442.0794677734, 6348.359375, 23.925397872925),
        Zone = function()
            return PolyZone:Create({
                vector2(1473.0926513672, 6378.8989257812),
                vector2(1480.1341552734, 6376.8989257812),
                vector2(1482.0408935547, 6352.4033203125),
                vector2(1459.4664306641, 6337.5229492188),
                vector2(1450.7166748047, 6334.634765625),
                vector2(1441.2388916016, 6326.4936523438),
                vector2(1419.2076416016, 6322.7094726562),
                vector2(1413.7530517578, 6340.623046875),
                vector2(1415.6984863281, 6361.6162109375)
            }, {
                name = "Paleto",
            })
        end,
    },
    {
        label = "#6 Losty",
        index = "losty",
        coords = vec3(58.438304901123, 3702.6540527344, 39.755004882812),
        Zone = function()
            return PolyZone:Create({
                vector2(119.21650695801, 3609.8041992188),
                vector2(14.111699104309, 3624.7817382812),
                vector2(-29.469526290894, 3716.7705078125),
                vector2(53.68631362915, 3770.9033203125),
                vector2(122.64720153809, 3762.146484375),
                vector2(132.77786254883, 3722.2844238281)
            }, {
                name = "Losty",
            })
        end,
    },
    {
        label = "#7 Farma",
        index = "farma",
        coords = vec3(-83.447769165039, 1903.7711181641, 196.73361206055),
        Zone = function()
            return PolyZone:Create({
                vector2(-49.313831329346, 1854.6292724609),
                vector2(-32.548023223877, 1884.0246582031),
                vector2(-36.292282104492, 1929.6977539062),
                vector2(-77.346389770508, 1931.2622070312),
                vector2(-153.82418823242, 1926.0911865234),
                vector2(-150.29266357422, 1889.1628417969),
                vector2(-127.28771972656, 1873.5261230469)
            }, {
                name = "Farma",
            })
        end,
    },
    {
        label = "#8 Rybak",
        index = "rybak",
        coords = vec3(3808.9934082031, 4461.7197265625, 4.3052473068237),
        Zone = function()
            return PolyZone:Create({
                vector2(3775.0749511719, 4481.154296875),
                vector2(3786.134765625, 4437.2158203125),
                vector2(3834.8259277344, 4437.0908203125),
                vector2(3834.6037597656, 4463.2475585938),
                vector2(3832.2978515625, 4488.2622070312),
                vector2(3825.2756347656, 4501.2875976562)
            }, {
                name = "Rybak",
            })
        end,
    },
    {
        label = "#9 Grapeseed",
        index = "grapeseed",
        coords = vec3(2133.4526367188, 4782.3354492188, 40.960880279541),
        Zone = function()
            return PolyZone:Create({
                vector2(2170.6003417969, 4760.7329101562),
                vector2(2141.6501464844, 4760.0004882812),
                vector2(2106.326171875, 4738.548828125),
                vector2(2104.7856445312, 4764.6767578125),
                vector2(2102.8427734375, 4784.1513671875),
                vector2(2098.87890625, 4810.8950195312),
                vector2(2122.830078125, 4821.0893554688),
                vector2(2144.8173828125, 4829.015625),
                vector2(2166.7414550781, 4813.6328125),
                vector2(2176.4487304688, 4797.009765625)
            }, {
                name = "Grapeseed",
            })
        end,
    },
        {
        label = "#10 Wiatraki",
        index = "wiatraki",
        coords = vec3(2288.8278808594, 1989.2531738281, 131.81558227539),
        Zone = function()
            return PolyZone:Create({
                vector2(2315.3549804688, 1966.5656738281),
                vector2(2281.873046875, 1953.9365234375),
                vector2(2266.1381835938, 1993.0386962891),
                vector2(2254.7348632812, 2031.2416992188),
                vector2(2283.4152832031, 2044.1130371094)
            }, {
                name = "Wiatraki",
            })
        end,
    },
        {
        label = "#11 Kościół",
        index = "kosciol",
        coords = vec3(-317.55023193359, 2792.5834960938, 59.665473937988),
        Zone = function()
            return PolyZone:Create({
                vector2(-304.04754638672, 2760.8991699219),
                vector2(-348.78759765625, 2793.8530273438),
                vector2(-333.01150512695, 2821.5080566406),
                vector2(-314.09185791016, 2851.0231933594),
                vector2(-298.52655029297, 2858.2333984375),
                vector2(-286.29486083984, 2851.6040039062),
                vector2(-268.5212097168, 2841.1811523438),
                vector2(-267.07479858398, 2835.6145019531)
            }, {
                name = "Kościół",
            })
        end,
    },
}

-- ──────────────────────────────────────────────────────────────────────────────
-- ROPE MENU                                                                 
-- (Information) ► Enables rope item / keybind usage with optional target integration.
-- ──────────────────────────────────────────────────────────────────────────────
Config.Rope = {                       
    Enable = false, -- false = disable rope completly
    Item = {
        Enable   = false,
        ItemName = "rope"             -- Rope item name.
    },
    Keybind = {
        Enable = false,
        Bind   = "F6"                 -- Keybind used for rope menu when enabled.
    },
    Target = {
        Enable = false                 -- true = add target options to every player.
        -- When it's enabled - will add options to every player on the server.
    }
}

-- ──────────────────────────────────────────────────────────────────────────────
-- AIRDROPS                                                                  
-- (Information) ► Global configuration for Airdrop events, guards and rewards.
-- ──────────────────────────────────────────────────────────────────────────────
Config.AirDrop = {                    
    Guards = {
        enable = false,
        amount = 20, 
        weaponsList = {
            `weapon_SNSPISTOL`,
            `WEAPON_SNSPISTOL_MK2`,
            `WEAPON_VINTAGEPISTOL`,
            `WEAPON_PISTOL`
        },
        guardModels = { 
            "s_m_y_blackops_01", 
            "s_m_y_blackops_02", 
            "s_m_m_armoured_01", 
            "s_m_m_marine_01" 
        }
    },
    StartCommand = {
        Enable = false,               -- Allow your admins to start AirDrop manually.
        CommandName = "startAirDrop" -- Command name to start Airdrop.
    },
    TimeToLand = 2,                  -- Time in minutes before airdrop starts going down.
    Enable = false,                   -- Master toggle for Airdrop system.
    Timer = 2,                       -- Interval in hours between automatic airdrops.
    DespawnTime = 25,                -- Minutes after which unopened airdrop will despawn.
    Locations = {
        vec4(470.7527, 2942.3884, 40.7600, 95.2011),
        vec4(1350.2504, 4354.7686, 42.7147, 315.9569),
        vec4(2034.9507, 4764.8198, 40.0590, 290.3700),
        vec4(3700.1226, 4533.2456, 22.2974, 193.3774),
        vec4(1518.1498, 6341.2002, 23.0057, 171.9430),
        vec4(-70.5034, 1910.8385, 195.1936, 196.7471),
    },
    Exp = 100,                       -- EXP given for opening Airdrop.
    Blip = {
        EnableRadiusBlip = true, 
        Blip      = 550,
        BlipColor = 3,
    },
    RewardsAmount = 3,               -- Number of random rewards per airdrop.
    Rewards = {

        {
            rewardType = "item",       ---@param rewardType "item" | "money" | "blackmoney"
            itemName   = "spray_can",
            amount     = 10,
            chance     = 50,
        },
        {
            rewardType = "item",       ---@param rewardType "item" | "money" | "blackmoney"
            itemName   = "spray_remover",
            amount     = 10,
            chance     = 50,
        },
        {
            rewardType = "blackmoney", ---@param rewardType "item" | "money" | "blackmoney"
            itemName   = "black_money",
            amount     = 100000,
            chance     = 50,
        },
        --[[
        EXAMPLE ITEM WITH METADATA:
        {
            rewardType = "item",       ---@param rewardType "item" | "money" | "blackmoney"
            itemName   = "testitem",
            amount     = 15,
            chance     = 50,
            metadata   = {
                testmeta = 69
            }
        },--]]
        -- [Note]: Metadata currently works only for ox_inventory. 
        -- If you want metadata compatible with your inventory script:
        -- Files that need to be edited: `integrations/server/inventory/`
        -- and one of `framework/server` functions Fr.AddItem
    },
    ProgressTime = 10000,            -- Time in milliseconds for opening progress bar.
    SkillCheck = function()          -- Custom skill check function (uses ox_lib by default).
        return lib.skillCheck({'easy', 'easy', 'medium', 'easy', 'medium'}, {'w', 'a', 's', 'd'})
    end
}

-- ──────────────────────────────────────────────────────────────────────────────
-- Garage Disable Marker Helper                                               
-- (Information) ► Some external garage scripts manage their own markers/blips.
-- (Information) ► This helper allows OP-Crime to disable its own markers when needed.
-- ──────────────────────────────────────────────────────────────────────────────
-- Do not touch function below if you don't know what you're changing!
Config.GarageDisableMarker = function() 
    if Config.GarageScript == 'jg-advancedgarages' then 
        return true
    else 
        return false
    end
end