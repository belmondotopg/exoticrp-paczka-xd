QBox = GetResourceState('qbx_core') == 'started' and true or false

if not QBox then return end

Framework = exports['qb-core']:GetCoreObject()
Fr.PlayerLoaded = 'op-multicharacter:charInitialized'

Fr.OnPlayerLoadEvents = function(coords)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerEvent('qb-weathersync:client:EnableSync')
end

Fr.OnPlayerConnected = function()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
end

Fr.GetPlayerData = function()
    return Framework.Functions.GetPlayerData()
end