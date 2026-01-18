Config = {}

Config.NoRelations = false -- if set to true, test will start automatically in thread with Config.SyncHandle function. If set to false you need to manually run test using exports['drez_antirpfmods']:RunTest()
Config.AntiBulletPenetration = true -- Detect bullet penetration mods (shooting through walls and vehicles)
Config.AntiQuickSeat = true -- Detect quick entering to vehicle
Config.AntiQuickReload = false -- Detect "no realod" mods
Config.AntiMovementMods = true -- Detect enhanced movement, sliding, fast running etc
Config.AntiSuperpunch = true -- Detect superpunch mods (one-shot other players, peds, launch vehicles)
Config.AntiWeaponComponentsDamage = true -- Detect enhanced weapons components meta
Config.AntiNoWaterMods = true -- Detect no water mods
Config.AntiNoBushMods = true -- Detect no bushes, please specify in Config.BushModels


Config.WeaponModel = `WEAPON_PISTOL` -- Default weapon model, dont touch if not needed
Config.PedModel = "mp_m_freemode_01" -- Default ped model, dont touch if not needed

Config.TestPlace = vec4(2419.1, 1414.58, -92.14, 280.95) -- dont touch if not needed

Config.QuickSeatTest = { -- dont touch if not needed
    VehicleModel = "sultan",
    Vehicle = vec4(2421.09, 1414.71, -93.49, 4.55),
    Ped = vec4(2421.04, 1413.64, -92.14, 0.3),
    Player = vec4(2419.1, 1414.58, -92.14, 280.95),
}
Config.BulletPenTest = { -- dont touch if not needed
    VehicleModel = "riot",
    Vehicle = vec4(2421.05, 1422.41, -92.14, 359.03),
    Ped = vec4(2421.13, 1420.75, -92.14, 179.71),
    Player = vec4(2421.04, 1413.64, -92.14, 8.85)
}
Config.MovementTest = { -- dont touch if not needed
    Player = vec4(2422.41, 1412.43, -92.14, 270.27),
    Point = vec3(2422.81, 1428.66, -86.52),
}

--- Its prefered to keep it behind loading screen, before loading player
--- Best use case to sync with other scirpts, ie. ESX framework:
--[[

    RegisterNetEvent('esx:playerLoaded', function(xPlayer, isNew, skin)
        ESX.PlayerData = xPlayer

        exports.spawnmanager:spawnPlayer({
            x = ESX.PlayerData.coords.x,
            y = ESX.PlayerData.coords.y,
            z = ESX.PlayerData.coords.z + 0.25,
            heading = ESX.PlayerData.coords.heading,
            model = `mp_m_freemode_01`,
            skipFade = false
        }, function()
            TriggerServerEvent('esx:onPlayerSpawn')
            TriggerEvent('esx:onPlayerSpawn')
            TriggerEvent('esx:restoreLoadout')

            if isNew then
                TriggerEvent('skinchanger:loadDefaultModel', skin.sex == 0)
            elseif skin then
                TriggerEvent('skinchanger:loadSkin', skin)
            end

            --- TEST RUNS HERE
            exports['drez_antirpfmods']:RunTest()
            Wait(1000)
            while (exports["drez_antirpfmods"]:IsTestRunning()) do
                Wait(500)
            end
            
            while (exports["drez_antirpfmods"]:IsTestRunning()) do
                Wait(500)
            end
            --- TEST ENDS HERE

            TriggerEvent('esx:loadingScreenOff')
            ShutdownLoadingScreen()
            ShutdownLoadingScreenNui()
        end)

        ESX.PlayerLoaded = true

        -- rest of the code
    end)
--]]

-- to your own compatibility - if causing problems, function will return if player is in test or not
--[[ 
    exports["drez_antirpfmods"]:IsTestRunning()
]]


Config.SyncHandle = function() -- Sync function for your own compatibility, this function is triggered on resource init (before detection tick), you can put your Wait or export code to make sure player is fully loaded. Not needed script to work, doesnt matter what you return here
    -- Wait(3000)

    -- export['my_resource']:WaitForLoad()

    return true
end


Config.BushModels = {
    'prop_bush_lrg_01',
    'prop_bush_med_01',
    'prop_bush_neat_01',
    'prop_bush_lrg_03',
    'prop_bush_med_03',
    'prop_joshua_tree_01d',
    'prop_bush_lrg_02',
    'prop_tree_lficus_06',
    'prop_tree_lficus_06',
    'prop_joshua_tree_02e', 
    'prop_cactus_01e',
    'prop_cactus_01d',
    'prop_cactus_01c',
    'prop_dumpster_01a',
    'prop_cactus_01a',
    'prop_joshua_tree_01a',
    'prop_joshua_tree_02a',
    'prop_rock_4_a',
    'prop_rock_5_a',
    'prop_rock_4_big',
    'prop_rock_5_smash1',
    'prop_bin_14a',
    'prop_dumpster_3a',
    'prop_dumpster_4b',
    'prop_skunk_bush_01',
    'prop_desert_iron_01',
    'prop_bush_ornament_04',
    'prop_veg_crop_tr_01',
    'prop_veg_crop_orange',
    'prop_skip_06a',
    'prop_skip_04',
    'prop_barier_conc_01c',
    'prop_barier_conc_04a',
    'prop_cablespool_04',
    'prop_logpile_06b',
    'prop_logpile_07b',
    'prop_scafold_05a',
    'prop_pile_dirt_04',
    'prop_woodpile_01c',
    'prop_woodpile_04b',
    'prop_rub_wreckage_6',
    'prop_rub_wreckage_3',
    'prop_rub_buswreck_06',
    'prop_rub_carwreck_12',
    'prop_billboard_12',
    'prop_billboard_10',
    'prop_billboard_03',
    'prop_container_02a',
    'prop_container_03a',
    'prop_container_01c',
    'prop_container_04a',
    'prop_container_01h',
    'prop_boxpile_06b',
    'prop_boxpile_03a',
    'prop_boxpile_07a',
    'prop_telegraph_06a',
    'prop_telegraph_04a',
    'prop_telegraph_02b',
    'prop_elecbox_15',
    'prop_elecbox_10',
    'prop_palm_fan_04_a',
    'prop_palm_huge_01a',
    'prop_palm_fan_03_a',
    'prop_tree_olive_creator',
    'test_tree_forest_trunk_04',
    'prop_tree_birch_02',
    'prop_tree_eng_oak_01',
    'prop_rock_3_g',
    'prop_rock_4_c',
}
