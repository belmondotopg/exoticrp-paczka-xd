--- One of the starter actions. Silent way of starting the container heist.
--- @param data TargetData
--- @return boolean Success status of the hack attempt
return function(data)
    local deskEntity = data.entity
    local ped = cache.ped   
    local zoneIndex = data.zoneIndex
    
    local animDict = 'anim@scripted@ulp_missions@computerhack@male@'
    local exitAnim = 'exit'

    if not DoesEntityExist(deskEntity) then
        ESX.ShowNotification('Biurko nie istnieje.')
        return false
    end

    local deskCoords = GetEntityCoords(deskEntity)
    if not deskCoords or deskCoords.x == 0.0 then
        ESX.ShowNotification('Coś poszło nie tak, spróbuj ponownie.')
        return false
    end

    lib.requestAnimDict(animDict)
    
    local Scenes = require('client.modules.syncedScene')
    local sceneCoords, sceneRot = Scenes.getTransformFromEntity(deskEntity)
    SetEntityHeading(ped, GetEntityHeading(deskEntity))

    Wait(200)

    Scenes.playScene(ped, deskEntity, animDict, 'enter', 'enter_desk', sceneCoords, sceneRot)
    Wait(1000)
    
    local loopScene = Scenes.playScene(ped, deskEntity, animDict, 'hacking_loop', 'enter_desk', sceneCoords, sceneRot)

    local result = exports['lc-minigames']:StartMinigame('CodeFind')

    Wait(1500)
    Scenes.stopScene(loopScene)
    
    Scenes.playAndWait(ped, deskEntity, animDict, 'exit', 'enter_desk', sceneCoords, sceneRot, {
        [deskEntity] = true
    })
    RemoveAnimDict(animDict)

    TriggerServerEvent('exotic-containers:startHeist', 'hackComputer', zoneIndex, result)

    return result
end