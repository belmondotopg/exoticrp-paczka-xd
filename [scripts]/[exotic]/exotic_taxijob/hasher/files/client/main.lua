RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('taxiJob:startRoute')
AddEventHandler('taxiJob:startRoute', function(id)
    startRoute(id)
end)

RegisterNetEvent('taxiJob:routesUpdated')
AddEventHandler('taxiJob:routesUpdated', function()
    if onJob then
        updateNUIData()
    end
end)

CreateThread(function()
    createDefaultTargets()
    createDefaultBlip()
    createSpawnerPed()
end)