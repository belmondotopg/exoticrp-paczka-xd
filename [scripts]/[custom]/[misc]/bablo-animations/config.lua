Config = {}

Config.Debug = false      -- Enable debug mode

Config.Framework = 'auto' -- esx, qbcore, auto or standalone
Config.Locale = 'pl'      -- add more locales in shared/locales
Config.Logs = true       -- Enable/disable discord webhook logs config in webhooks.lua

Config.OpenMenu = 'F3'    -- Open menu keybind or false to disable keymapping
Config.CancelEmote = 'X'  -- Cancel emote keybind or false to disable keymapping
Config.CloseMenuKeys = {  -- Usejavascript keys easy converter https://www.toptal.com/developers/keycode
    'Escape',
    'F3'
}

Config.EmoteCommand = 'emote'            -- Emote command
Config.AnimAdjustCommand = 'dostosuj' -- Command to adjust animations or false to disable

Config.DisarmPlayer = true           -- Disarm player when playing an animation

Config.EnablePlaceAnimation = true   -- Enable placing animations
Config.FreezeEntityOnPlace = true    -- Freeze entity when placing animations
Config.PlaceDistance = 20.0          -- Raycast distance for placing animations
Config.PlaceMaxHeight = 2.0          -- Max height for placing animations
Config.GroupMaxDistance = 5.0        -- Max distance for group members to sync animations
Config.Timeout = 5                   -- Timeout for animation requests in seconds

Config.CustomGunStyles = true        -- Enable custom gun styles
Config.DisableIdleCam = true         -- Disable idle camera when playing animations

Config.DisablePreviews = false       -- Disable emote previews in menu

Config.DisableKeybinds = false       -- Disable all keybinds
Config.DisableNumpadKeybinds = true -- Disable numpad keys for animation keybinds

Config.ServerSideSpawn = true       -- Spawn emote props on the server

Config.CancelOnNewEmote = true       -- Cancel current emote when a new one is played

Config.Music = {
    Enabled = true,    -- Enable music in animations
    MaxDistance = 5.0, -- Max distance for music to be heard
    MaxDuration = 180, -- Max duration (seconds) before auto-stopping music
}

-- Data here is used to either share saved data between characters or to save data for a specific character
Config.CharacterSpecific = {
    expression = true,
    walkingstyle = true,
    weaponstyle = true,
    favorites = true,
    keybinds = true,
}

-- Default Settings for menu
Config.DefaultSettings = {
    menuAlign = "LEFT",
    menuScale = 67,
    musicVolume = 50,
    showGifs = true,
    performanceMode = false,
    bigMenu = false
}

-- custom animations creators that are already configured enable said creator in the table below to use their animations
Config.Creators = {
    ["Pazeee_FreeFootBallEmote"] = false,
    ["Pazeee_VehicleFunnyEmote"] = false,
    ["Pazeee_CatUAI"] = false,
    ["Pazeee_CR7SIU"] = false,
    ["Pazeee_DonaldTrumpDance"] = false,
    ["Pazeee_FortnitePack_1"] = false,
    ["Pazeee_FunHide"] = false,
    ["Pazeee_GaramDanMaduDance"] = false,
    ["Pazeee_KawaikuteGomenDance"] = false,
    ["Pazeee_NewFortniteDancePackV2"] = false,
    ["Pazeee_PUBGDanceItsMyLife"] = false,
    ["Pazeee_PUBGHaidilaoDance"] = false,
    ["Pazeee_PUBGNastyGirl"] = false,
    ["Pazeee_SnowEmotePack"] = false,
    ["Pazeee_SquidGameRoundAndRound"] = false,
    ["Pazeee_WaitDance"] = false,
    ["Pazeee_PUBGMeninaDoJob"] = false,
    ["Pazeee_RatDance"] = false,
    ["Pazeee_TrashCanEmotePack"] = false,
    ["Pazeee_Dances"] = false,
    ["Pazeee_FortniteDancePackV4"] = false,
    ["Pazeee_CarryFunnyEmotePack"] = false,
    ["Pazeee_FortniteDancePackV5"] = false,
    ["Pazeee_FortniteDancePackV6"] = false,
    ["Pazeee_NewFortniteDancePackV3"] = false,
    ["Pazeee_SixFunnyEmotePack"] = false,
    ["Pazeee_NewRoleplayEmotePack"] = false,
    ["Pazeee_PunishmentFunnyEmotePack"] = false,
    ["Pazeee_DancePackV7"] = false,
    ["Pazeee_FlagEmotePack"] = false,
}

Config.AnimationsBlacklistedInVehicles = {
    -- 'animation_name',  type animation name to blacklist it in vehicles
}

Config.AnimalPeds = {
    "a_c_poodle",
    "a_c_pug",
    "a_c_westy",
    "a_c_chop",
    "a_c_husky",
    "a_c_retriever",
    "a_c_shepherd",
    "a_c_rottweiler",
}

-- Enable or disable modules
Config.Modules = {
    ['Pointing'] = true,
    ['Handsup'] = true,
    ['Ragdoll'] = false,
    ['Crouch'] = true,
    ['Crawl'] = false,
    ['Holstering'] = false,
    ['IdleAnimations'] = false,
    ['DisableCombatRoll'] = false,
    ['DisableLeaning'] = false
}

-- weapons that can be used with weapon styles
Config.Weapons = {
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_PISTOL50",
    "WEAPON_SNSPISTOL",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_PDG19",
    "WEAPON_PISTOL_MK2",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_FLAREGUN",
    "WEAPON_STUNGUN",
    "WEAPON_REVOLVER",
    "WEAPON_DOUBLEACTION",
    "WEAPON_CERAMICPISTOL",
    "WEAPON_NAVYREVOLVER",
    "WEAPON_MINISMG",
    "WEAPON_MICROSMG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_TECPISTOL",
    "WEAPON_DBSHOTGUN",
}


Config.Categories = {
    {
        label = "Ulubione",
        icon = "star",
        name = "favorites",
    },
    {
        label = "Wszystkie",
        icon = "list",
        name = "all",
    },
    {
        label = "Emotki",
        icon = "person",
        name = "emotes",
        get = function()
            return Config.Emotes, true
        end
    },
    {
        label = "Tańce",
        icon = "hands",
        name = "dances",
        get = function()
            return Config.Dances, true
        end
    },
    {
        label = "W pojeździe",
        icon = "car",
        name = "vehicle",
        get = function()
            return Config.InVehicle, true
        end
    },
    {
        label = "Emotki zwierząt",
        icon = "dog",
        name = "animal",
        get = function()
            return Config.Animal, true
        end
    },
    {
        label = "Style chodzenia",
        icon = "person-walking",
        name = "walkingstyles",
        type = "walkingstyle",
        get = function()
            return Config.Walks
        end
    },
    {
        label = "Wyrazy twarzy",
        icon = "face-smile",
        name = "expressions",
        type = "expression",
        get = function()
            return Config.Expressions
        end
    },
    {
        label = "Animacje wspólne",
        icon = "people-pulling",
        name = "shared",
        type = "shared",
        get = function()
            return Config.Shared
        end
    },
    {
        label = "Style z bronią",
        icon = "person-rifle",
        name = "weaponstyles",
        type = "weaponstyles",
        get = function()
            return Config.WeaponStyles
        end
    },
    {
        label = "Sekwencje",
        icon = "arrows-repeat",
        name = "sequence",
        type = "sequence",
        get = function()
            return Config.Sequences
        end
    },
}

Config.placeableTypes = {
    'animation',
    'scenario'
}

Config.Groups = {
    -- ["example"] = function() -- client sided check
    --     local hasAccess = true

    --     return hasAccess
    -- end
}

Config.ScenarioModels = {
    `p_amb_coffeecup_01`,
    `p_amb_joint_01`,
    `p_cs_ciggy_01`,
    `p_cs_ciggy_01b_s`,
    `p_cs_clipboard`,
    `prop_curl_bar_01`,
    `p_cs_joint_01`,
    `p_cs_joint_02`,
    `prop_acc_guitar_01`,
    `prop_amb_ciggy_01`,
    `prop_amb_phone`,
    `prop_beggers_sign_01`,
    `prop_beggers_sign_02`,
    `prop_beggers_sign_03`,
    `prop_beggers_sign_04`,
    `prop_bongos_01`,
    `prop_cigar_01`,
    `prop_cigar_02`,
    `prop_cigar_03`,
    `prop_cs_beer_bot_40oz_02`,
    `prop_cs_paper_cup`,
    `prop_cs_trowel`,
    `prop_fib_clipboard`,
    `prop_fish_slice_01`,
    `prop_fishing_rod_01`,
    `prop_fishing_rod_02`,
    `prop_notepad_02`,
    `prop_parking_wand_01`,
    `prop_rag_01`,
    `prop_scn_police_torch`,
    `prop_sh_cigar_01`,
    `prop_sh_joint_01`,
    `prop_tool_broom`,
    `prop_tool_hammer`,
    `prop_tool_jackham`,
    `prop_tennis_rack_01`,
    `prop_weld_torch`,
    `w_me_gclub`,
    `p_amb_clipboard_01`
}

Config.AnimPos = {
    -- Edit controls for right clicking on a animation
    { type = 'control', phase = 'edit',     name = 'goUp',            code = 85 },  -- Q
    { type = 'control', phase = 'edit',     name = 'goDown',          code = 48 },  -- Z
    { type = 'control', phase = 'edit',     name = 'goLeft',          code = 34 },  -- A
    { type = 'control', phase = 'edit',     name = 'goRight',         code = 35 },  -- D
    { type = 'control', phase = 'edit',     name = 'goForward',       code = 32 },  -- W
    { type = 'control', phase = 'edit',     name = 'goBackward',      code = 33 },  -- S
    { type = 'control', phase = 'edit',     name = 'turnLeft',        code = 14 },  -- Mouse Wheel Down
    { type = 'control', phase = 'edit',     name = 'turnRight',       code = 15 },  -- Mouse Wheel Up
    { type = 'control', phase = 'edit',     name = 'pitchUp',         code = 10 },  -- PageUp
    { type = 'control', phase = 'edit',     name = 'pitchDown',       code = 11 },  -- PageDown
    { type = 'control', phase = 'edit',     name = 'confirm',         code = 38 },  -- E
    { type = 'control', phase = 'edit',     name = 'cancel',          code = 200 }, -- ESC

    -- Placement controls for /animpos command
    { type = 'control', phase = 'place',    name = 'increaseHeight',  code = 44 },  -- Q
    { type = 'control', phase = 'place',    name = 'decreaseHeight',  code = 48 },  -- Z
    { type = 'control', phase = 'place',    name = 'setOnGround',     code = 47 },  -- G
    { type = 'control', phase = 'place',    name = 'rotateLeftFast',  code = 14 },  -- Mouse Wheel Down (+10)
    { type = 'control', phase = 'place',    name = 'rotateRightFast', code = 15 },  -- Mouse Wheel Up (-10)
    { type = 'control', phase = 'place',    name = 'rotateUpSlow',    code = 172 }, -- Arrow Up (+1)
    { type = 'control', phase = 'place',    name = 'rotateDownSlow',  code = 173 }, -- Arrow Down (-1)
    { type = 'control', phase = 'place',    name = 'rotateLeftSlow',  code = 174 }, -- Arrow Left (-3)
    { type = 'control', phase = 'place',    name = 'rotateRightSlow', code = 175 }, -- Arrow Right (+3)
    { type = 'control', phase = 'place',    name = 'pitchUp',         code = 10 },  -- PageUp (+1)
    { type = 'control', phase = 'place',    name = 'pitchDown',       code = 11 },  -- PageDown (-1)
    { type = 'control', phase = 'place',    name = 'confirm',         code = 38 },  -- E
    { type = 'control', phase = 'place',    name = 'cancel',          code = 200 }, -- ESC

    -- Help overlay: when right clicking on a animation
    { type = 'help',    phase = 'help',     key = 'E',                textKey = 'PLACE_ANIMATION' },
    { type = 'help',    phase = 'help',     key = 'Q',                textKey = 'HEIGHT_UP_ANIMATION' },
    { type = 'help',    phase = 'help',     key = 'Z',                textKey = 'HEIGHT_DOWN_ANIMATION' },
    { type = 'help',    phase = 'help',     key = 'G',                textKey = 'SET_ON_GROUND_ANIMATION' },
    { type = 'help',    phase = 'help',     icon = 'SCROLL',          textKey = 'ROTATE_ANIMATION' },
    { type = 'help',    phase = 'help',     key = 'ESC',              textKey = 'CANCEL_ANIMATION' },

    -- Help overlay: when using /animpos command
    { type = 'help',    phase = 'helpEdit', key = 'E',                textKey = 'PLACE_ANIMATION' },
    { type = 'help',    phase = 'helpEdit', key = 'Q',                textKey = 'HEIGHT_UP_ANIMATION' },
    { type = 'help',    phase = 'helpEdit', key = 'Z',                textKey = 'HEIGHT_DOWN_ANIMATION' },
    { type = 'help',    phase = 'helpEdit', icon = 'SCROLL',          textKey = 'ROTATE_ANIMATION' },
    { type = 'help',    phase = 'helpEdit', key = 'PGUP',             textKey = 'ROTATE_UP' },
    { type = 'help',    phase = 'helpEdit', key = 'PGDN',             textKey = 'ROTATE_DOWN' },
    { type = 'help',    phase = 'helpEdit', key = 'ESC',              textKey = 'CANCEL_ANIMATION' },
}
