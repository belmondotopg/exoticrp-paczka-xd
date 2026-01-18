Config = {}

DEBUG_ENABLED = false

-- Framework setup
Config.Locale = 'pl'
Config.Framework = FRAMEWORK_ESX -- FRAMEWORK_ESX/FRAMEWORK_QB/FRAMEWORK_VRP

-- Cost of taking cue from stand / playing pool
Config.CueRentCost = 100
Config.CueRemoveFromPlayerAtDistance = 10.0

-- Eye-Target Interaction
Config.EnableInteractionTargetScript = true -- true/false
Config.TargetScriptName = SCRIPT_OX_TARGET -- SCRIPT_OX_TARGET/SCRIPT_QB_TARGET

Config.Blips = {
    enable = false,
    blipId = 509, -- https://docs.fivem.net/docs/game-references/blips/
    blipColor = 0,
    blipScale = 0.7,
}

Config.Tables = {
    -----------------
    -- Pool Tables --
    -----------------
    {
        id = 'yellow-jack-table', 
        type = TYPE_POOL_TABLE,
        coords = vector3(1992.8033447265625, 3047.312255859375, 46.22865295410156), 
        heading = 136.7423,
        interactionDistance = 2.5,
        maxPlayers = 2,
        hash = `prop_pooltable_02`,
        height = 1.0,
    },
    {
        id = 'del-perro-beach-table-01', 
        type = TYPE_POOL_TABLE,
        coords = vector3(-1691.0438232421875, -1100.632080078125, 12.15962123870849), 
        heading = -129.5,
        interactionDistance = 2.5,
        maxPlayers = 2,
        hash = `prop_pooltable_3b`,
        height = 1.0,
    },
    {
        id = 'del-perro-beach-table-02', 
        type = TYPE_POOL_TABLE,
        coords = vector3(-1694.711669921875, -1097.7637939453125, 12.15616989135742), 
        heading = -40.0,
        interactionDistance = 2.5,
        maxPlayers = 2,
        hash = `prop_pooltable_02`,
        height = 1.0,
    },

    ----------------
    -- Cue stands --
    ----------------
    {
        id = 'yellow-jack-stand',
        type = TYPE_CUE_STAND,
        coords = vector3(1995.72, 3048.01, 47.21), 
        interactionDistance = 0.75,
    },
    {
        id = 'del-perro-beach-stand-01',
        type = TYPE_CUE_STAND,
        coords = vector3(-1688.05, -1102.95, 12.94), 
        interactionDistance = 0.75,
        prop = {
            hash = `prop_pool_rack_01`,
            coords = vector3(-1688.05, -1102.95, 12.94),
            rot = vector3(0.0, 0.0, -129.5),
        },
    },
    {
        id = 'del-perro-beach-stand-02',
        type = TYPE_CUE_STAND,
        coords = vector3(-1696.194, -1101.81, 12.94), 
        interactionDistance = 0.75,
        prop = {
            hash = `prop_pool_rack_01`,
            coords = vector3(-1696.194, -1101.81, 12.94),
            rot = vector3(0.0, 0.0, 140.0),
        },
    },
}

-- For more advanced settings look at:
--  - shared/settings.lua
--  - shared/controls.lua
--  - shared/frameworks.lua
--  - etc.