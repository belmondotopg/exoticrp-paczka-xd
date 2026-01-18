local Config = require('config.main')
local CurrentHeist = require('server.modules.currentHeist')
local notifyGroups = require('server.modules.notifyGroups')
local setupItems = require('server.modules.setupItems')

---@type table<string, number>
local Cooldowns = {}

---@type table<number, table<string, string>>
local requiredItems = {}

for cooldownName, minutes in pairs(Config.Cooldowns) do
    Cooldowns[cooldownName] = minutes * 60
end

local function initializeRequiredItems()
    local success, err = pcall(function()
        for i = 1, #Config.MissionStarter do
            requiredItems[i] = {}

            local starterZone = Config.MissionStarter[i]
            local targetData = starterZone and starterZone.targetData

            if targetData and targetData.options and next(targetData.options) then
                for j = 1, #targetData.options do
                    local option = targetData.options[j]
                    if option.actionId and option.requiredItems then
                        requiredItems[i][option.actionId] = option.requiredItems
                    end
                end
            end
        end
    end)

    if not success then
        lib.print.error(("Failed to load requiredItems: %s"):format(err))
    else
        lib.print.info('Loaded requiredItems')
    end
end
initializeRequiredItems()

--- Get random container coordinates
---@return vector4
local function getRandomContainer()
    local containerPool = Config.Containers
    return containerPool[math.random(#containerPool)]
end

---@alias StartMethod 'hackComputer' | 'destroyComputer'

--- Check if player can start heist
---@param playerId number Player server ID
---@param zoneIndex number Mission starter zone index
---@param startMethod StartMethod Method of starting the heist
---@return boolean canStart Whether heist can be started
---@return { reason: string, timeLeft: number? }? errorInfo Error information if cannot start
local function canStartHeist(playerId, zoneIndex, startMethod)
    local requiredItem = requiredItems[zoneIndex] and requiredItems[zoneIndex][startMethod]
    if requiredItem and exports.ox_inventory:Search(playerId, 'count', requiredItem) < 1 then
        return false, { reason = 'missing_item' }
    end

    local heist = CurrentHeist.getCurrent()
    if not heist then return true end

    local status = heist:getStatus()
    local now = os.time()

    if status == 'started' then
        local timeLeft = Cooldowns.abandoned - (now - heist:getStartTime())
        if timeLeft <= 0 then
            CurrentHeist.stop()
            return true, nil
        end
        return false, { reason = 'abandoned_cooldown', timeLeft = timeLeft }
    elseif status == 'finished' then
        local timeLeft = Cooldowns.afterFinish - (now - heist:getEndTime())
        if timeLeft <= 0 then
            CurrentHeist.stop()
            return true, nil
        end
        return false, { reason = 'finish_cooldown', timeLeft = timeLeft }
    end

    CurrentHeist.stop()
    return true
end

lib.callback.register('exotic-containers:canStartHeist', function(source, zoneIndex, startMethod)
    return canStartHeist(source, zoneIndex, startMethod)
end)

---@param startMethod StartMethod
---@param zoneIndex number
---@param minigameResult boolean?
RegisterNetEvent('exotic-containers:startHeist', function(startMethod, zoneIndex, minigameResult)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local canStart = canStartHeist(source, zoneIndex, startMethod)

    if not canStart then
        xPlayer.showNotification('Nie udało się wystartować napadu.')
        return
    end

    local valid = false

    if startMethod == 'hackComputer' then
        if minigameResult then
            valid = true
        else
            xPlayer.showNotification('Nie wyszło ci to hackowanie byku...')
        end
    elseif startMethod == 'destroyComputer' then
        valid = true
    end

    if valid then
        local coords = getRandomContainer()
        local playerIdentifier = xPlayer.getIdentifier()
        CurrentHeist.start(playerIdentifier, coords)
        notifyGroups(coords, startMethod == 'destroyComputer', playerIdentifier)

        -- Powiadomienie dla gracza, który rozpoczął napad
        local minTimeToOpen = Config.Heist.minTimeToOpenContainer
        local lootSpotsCount = #Config.Heist.lootSpots
        xPlayer.showNotification(('Napad rozpoczęty! Kontener znajduje się w oznaczonym miejscu na mapie.\nMusisz poczekać %d sekund przed otwarciem kontenera.\nW kontenerze znajduje się %d miejsc do przeszukania.'):format(minTimeToOpen, lootSpotsCount))

        if Config.debug then
            lib.print.info(("Heist started by player %s using method '%s' at zone %s"):format(source, startMethod,
                zoneIndex))
        end
    end
end)

lib.callback.register('exotic-containers:doesContainerExist', function(source)
    local heist = CurrentHeist.getCurrent()
    if not heist then return false end

    local netContainer = heist:getContainer()
    if not netContainer then
        return false
    end

    local entity = NetworkGetEntityFromNetworkId(netContainer)
    return entity and DoesEntityExist(entity)
end)

RegisterNetEvent('exotic-containers:createContainer', function(netContainer, netCollision, netLock)
    local source = source

    --- Validate network ID
    ---@param netId number Network ID to validate
    ---@return boolean valid Whether the network ID is valid
    local function isValidNetId(netId)
        if not netId or type(netId) ~= 'number' then return false end
        local entity = NetworkGetEntityFromNetworkId(netId)
        return entity and DoesEntityExist(entity)
    end

    if not isValidNetId(netContainer) or not isValidNetId(netCollision) or not isValidNetId(netLock) then
        lib.print.warn(("Player %s attempted to create container with invalid net IDs."):format(source))
        return
    end

    local heist = CurrentHeist.getCurrent()
    if not heist then
        lib.print.warn(("Player %s tried to assign containers without an active heist."):format(source))
        return
    end

    heist:setObjects(netContainer, netCollision, netLock)

    if Config.debug then
        lib.print.info(("Container registered for heist by player %s"):format(source))
    end
end)

lib.callback.register('exotic-containers:getContainerNetIds', function(source)
    local heist = CurrentHeist.getCurrent()
    if not heist then return nil end

    return {
        container = heist:getContainer(),
        collision = heist:getCollision(),
        lock = heist:getLock()
    }
end)

lib.callback.register('exotic-containers:canOpenContainer', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local heist = CurrentHeist.getCurrent()

    if not heist then return end

    local diff = os.time() - heist:getStartTime()
    local minTime = Config.Heist.minTimeToOpenContainer

    if diff < minTime then
        xPlayer.showNotification((
            "Aby móc otworzyć kontener, musi minąć jeszcze %d sekund."
        ):format(minTime - diff))
        return false
    end

    return true
end)

--- Validate player distance from heist
---@param playerPed number Player ped
---@param heistCoords vector3 Heist coordinates
---@return boolean valid Whether player is in valid range
local function validatePlayerDistance(playerPed, heistCoords)
    local pedCoords = GetEntityCoords(playerPed)
    return #(pedCoords - heistCoords) <= 10.0
end

RegisterNetEvent('exotic-containers:openContainer', function()
    local source = source
    local heist = CurrentHeist.getCurrent()

    if not heist then return end

    local xPlayer = ESX.GetPlayerFromId(source)

    local diff = os.time() - heist:getStartTime()
    local minTime = Config.Heist.minTimeToOpenContainer

    if diff < minTime then
        return xPlayer.showNotification((
            "Aby móc otworzyć kontener, musi minąć jeszcze %d sekund."
        ):format(minTime - diff))
    end

    local playerPed = GetPlayerPed(source)
    if not validatePlayerDistance(playerPed, heist:getCoords().xyz) then
        return
    end

    heist:openContainer()
    lib.triggerClientEvent('exotic-containers:containerOpened', heist:getNearbyPlayers(), heist:getCoords())
end)

lib.callback.register('exotic-containers:isContainerOpened', function(source)
    local heist = CurrentHeist.getCurrent()
    return heist and heist:isOpened() or false
end)

lib.callback.register('exotic-containers:getCurrentHeist', function(source)
    local heist = CurrentHeist.getCurrent()
    if not heist then return nil end

    return {
        coords = heist:getCoords(),
        searchedSpots = heist:getSearchedSpots(),
        startedBy = heist.startedBy
    }
end)

lib.callback.register('exotic-containers:getSearchedSpots', function(source)
    local heist = CurrentHeist.getCurrent()
    if not heist then return nil end

    return heist:getSearchedSpots()
end)

lib.callback.register('exotic-containers:startSearchingSpot', function(source, spotIndex)
    local heist = CurrentHeist.getCurrent()
    if not heist then return false end

    if not heist:isOpened() then
        return false
    end

    if heist:isSpotSearched(spotIndex) then
        return false
    end

    return true
end)

RegisterNetEvent('exotic-containers:searchSpot', function(spotIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local heist = CurrentHeist.getCurrent()

    if not heist then return end

    if not heist:isOpened() then
        xPlayer.showNotification('Kontener nie jest otwarty.')
        return
    end

    if heist:isSpotSearched(spotIndex) then
        xPlayer.showNotification('To miejsce zostało już przeszukane.')
        return
    end

    local playerPed = GetPlayerPed(source)
    local heistCoords = heist:getCoords().xyz
    if not validatePlayerDistance(playerPed, heistCoords) then
        return
    end

    local inventoryId = heist:getInventoryFromIndex(spotIndex)
    local inventory = exports.ox_inventory
    if not inventoryId then
        local items = setupItems(spotIndex)
        inventoryId = inventory:CreateTemporaryStash({
            label = 'Przedmioty z kontenera',
            slots = #items,
            maxWeight = 1000000,
            coords = heistCoords,
            items = items
        })
        heist:registerInventory(inventoryId, spotIndex)
    end

    inventory:forceOpenInventory(source, 'stash', inventoryId)
end)

exports.ox_inventory:registerHook('swapItems', function(data)
    local inventoryId = data.fromInventory
    if not inventoryId then return true end

    local heist = CurrentHeist.getCurrent()
    if not heist then return true end

    local spotIndex = heist:getIndexFromInventory(inventoryId)
    if not spotIndex then return true end

    -- needed because ox_inventory awaits return from this hook (so we check items after we return true)
    SetTimeout(0, function()
        local items = exports.ox_inventory:GetInventoryItems(inventoryId)
        local itemCount = 0

        for _, item in pairs(items) do
            if item then
                itemCount += 1
                break
            end
        end

        if itemCount == 0 then
            local heistFinished = heist:markSpotAsSearched(spotIndex)
            lib.triggerClientEvent('exotic-containers:spotSearched', heist:getNearbyPlayers(), spotIndex)
            lib.print.info(('tempInv %s empty, markingn as searched.'):format(inventoryId))
            
            if heistFinished then
                -- Napad zakończony - powiadom wszystkich graczy w pobliżu
                lib.triggerClientEvent('exotic-containers:heistFinished', heist:getNearbyPlayers())
                lib.print.info('Napad zakończony - wszystkie miejsca przeszukane')
                
                -- Usuń kontener z mapy po 15 sekundach (daj graczom czas na zebranie lootu)
                SetTimeout(60000, function()
                    CurrentHeist.stop()
                    lib.print.info('Kontener został usunięty z mapy')
                end)
            end
        end
    end)

    return true
end, {
    inventoryFilter = {
        '^temp%-%d+'
    }
})

-- local objs = GetAllObjects()
-- for i = 1, #objs do
--     DeleteEntity(objs[i])
-- end