local Config = require('config.main')
local HeistConfig = Config.Heist
local StarterZone = require('client.modules.starterZone')
local HeistZone = require('client.modules.heistZone.init')

---@type table<number, CPoint>
local starterPoints = {}

local LootSpots = require('client.modules.heistZone.modules.lootSpot')

CreateThread(function()
    if Config.debug then
        RegisterCommand('startcontainer', function()
            TriggerServerEvent('exotic-containers:startHeist', 'destroyComputer', 1, nil)
        end)
    end

    for i = 1, #Config.MissionStarter do
        local zoneData = Config.MissionStarter[i]
        starterPoints[i] = lib.points.new({
            coords = zoneData.coords,
            distance = zoneData.radius or 30.0,
            onEnter = function()
                StarterZone.setupZone(i)
            end,
            onExit = function()
                StarterZone.destroyZone()
            end
        })
    end

    Wait(1500)
    local currentHeist = lib.callback.await('exotic-containers:getCurrentHeist')
    if currentHeist then
        HeistZone.setup(currentHeist.coords, currentHeist.startedBy)
    end
end)

local function cleanup()
    for i = 1, #starterPoints do
        if starterPoints[i] then
            starterPoints[i]:remove()
            starterPoints[i] = nil
        end
    end

    LootSpots.clearAll()
    StarterZone.destroyZone()
    HeistZone.Container.cleanup()
end

---@param coords vector3
---@param startedBy number
ESX.SecureNetEvent('exotic-containers:heistStarted', function(coords, startedBy)
    HeistZone.setup(coords, startedBy)
end)

ESX.SecureNetEvent('exotic-containers:containerOpened', function(coords)
    HeistZone.Container.playOpeningAnimation(coords)
    
    local animationObjects = HeistZone.Container.getAnimationObjects()
    local baseEntity = animationObjects.localContainer

    if not baseEntity or not DoesEntityExist(baseEntity) then
        lib.print.warn("localContainer does not exist for loot spawning")
        return
    end

    for spotIndex, item in ipairs(HeistConfig.lootSpots) do
        local spawnCoords = GetOffsetFromEntityInWorldCoords(
            baseEntity,
            item.offset.x,
            item.offset.y,
            item.offset.z
        )

        lib.requestModel(item.model)
        local object = CreateObject(item.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, true, false)

        if object and DoesEntityExist(object) then
            FreezeEntityPosition(object, true)

            local lootData = {
                object = object,
                coords = spawnCoords
            }

            LootSpots.add(spotIndex, lootData)
        end

        SetModelAsNoLongerNeeded(item.model)
    end
end)

---@param spotIndex number
ESX.SecureNetEvent('exotic-containers:spotSearched', function(spotIndex)
    LootSpots.remove(spotIndex)
end)

--- Event gdy napad się zakończy
ESX.SecureNetEvent('exotic-containers:heistFinished', function()
    HeistZone.cleanup()
    ESX.ShowNotification('Napad zakończony - wszystkie miejsca zostały przeszukane')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource == resourceName then
        cleanup()
    end
end)