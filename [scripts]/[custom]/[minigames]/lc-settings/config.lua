Config = {}

Config.Framework = 'auto' -- or 'ox' | 'esx' | 'qb' | 'qbx' | 'nd'
Config.SQLTables = {
    ox = {
        playerTable = 'character_inventory',
        playerColumn = 'charId',
        vehicleTable = 'vehicles',
        vehicleColumn = 'id',
    },
    esx = {
        playerTable = 'users',
        playerColumn = 'identifier',
        vehicleTable = 'owned_vehicles',
        vehicleColumn = 'plate',
    },
    qb = {
        playerTable = 'players',
        playerColumn = 'citizenid',
        vehicleTable = 'player_vehicles',
        vehicleColumn = 'plate',
    },
    qbx = {
        playerTable = 'players',
        playerColumn = 'citizenid',
        vehicleTable = 'player_vehicles',
        vehicleColumn = 'id',
    },
    nd = {
        playerTable = 'nd_characters',
        playerColumn = 'charid',
        vehicleTable = 'nd_vehicles',
        vehicleColumn = 'id',
    },
    -- Add your custom framework below.
}


local function getFramework()
    if Config.Framework == 'auto' then
        if GetResourceState('ox_core') == 'started' then
            Config.Framework = 'ox'
        elseif GetResourceState('es_extended') == 'started' then
            Config.Framework = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            Config.Framework = 'qb'
        elseif GetResourceState('qbx_core') == 'started' then
            Config.Framework = 'qbx'
        elseif GetResourceState('ND_Core') == 'started' then
            Config.Framework = 'nd'
        else
            error('[lc-settings] No supported framework is running. Please define your framework manually.')
        end
    end
end

getFramework()
