Framework = Framework or {}

-- Called when using ESX and the player has been loaded
RegisterNetEvent(Config.Framework.esx.events.playerLoaded, function(playerData, isNewCharacter)
    Framework.object.PlayerData = playerData

    EventManager:triggerInternalClientEvent("playerLoaded", nil, nil, playerData, isNewCharacter)

    Logger:debug("esx:playerLoaded - Player data loaded.")
end)

-- Called when using ESX and the player has changed job
RegisterNetEvent(Config.Framework.esx.events.setJob, function(newJob)
    Framework.object.PlayerData.job = newJob

    EventManager:triggerInternalClientEvent("jobUpdated", nil, nil, newJob)

    Logger:debug("esx:setJob - Job set.")
end)

-- Called when using QBCore and the player has changed job
RegisterNetEvent(Config.Framework.qbCore.events.onJobUpdate, function()
    Framework.object.PlayerData = Framework.object.Functions.GetPlayerData()

    EventManager:triggerInternalClientEvent("jobUpdated", nil, nil, Framework.object.PlayerData.job)
end)

-- Called when using QBCore and the player is about to be loaded
RegisterNetEvent(Config.Framework.qbCore.events.onPlayerLoaded, function()
    Framework.object.PlayerData = Framework.object.Functions.GetPlayerData()

    EventManager:triggerInternalClientEvent("playerLoaded", nil, nil, Framework.object.PlayerData)
end)

-- Called when using ESX and the player is about to spawn
RegisterNetEvent(Config.Framework.esx.events.onPlayerSpawn, function()
    EventManager:triggerInternalClientEvent("onPlayerSpawned")
end)

-- Called when using qb-spawn and the player is about to spawn
RegisterNetEvent(Config.Framework.qbCore.events.qbSpawn.setupSpawns, function(characterData, newCharacter, apps)
    EventManager:triggerInternalClientEvent("qb-spawn:setupSpawns", nil, nil, characterData, newCharacter, apps)
end)