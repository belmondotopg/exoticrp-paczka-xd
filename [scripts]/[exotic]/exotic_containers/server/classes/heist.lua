local HeistConfig = require('config.heist')

---@class ContainerHeist : OxClass
---@field playerId number
---@field startTime number
---@field endTime number?
---@field status 'started' | 'finished'
---@field containerNetId number?
---@field collisionNetId number?
---@field lockNetId number?
---@field isOpen boolean
---@field searchedSpots table<number, boolean> Key is spot index, value indicates if searched
local Heist = lib.class('ContainerHeist')

---@param playerIdentifier stringlib Player Framework Identifier who started the heist
---@param coords vector4 Heist coordinates
function Heist:constructor(playerIdentifier, coords)
    self.startedBy = playerIdentifier
    self.private = {
        coords = coords,
        startTime = os.time(),
        endTime = nil,
        status = 'started',
        containerNetId = nil,
        collisionNetId = nil,
        lockNetId = nil,
        isOpen = false,
        searchedSpots = self:initializeSearchedSpots(),
        inventories = {}
    }
end

--- Initialize searched spots table
---@return table<number, boolean>
function Heist:initializeSearchedSpots()
    local spots = {}
    for spotIndex, _ in pairs(HeistConfig.lootSpots) do
        spots[spotIndex] = false
    end
    return spots
end

function Heist:stop()
    local entities = {
        { id = self.private.containerNetId, name = "container" },
        { id = self.private.lockNetId,      name = "lock" },
        { id = self.private.collisionNetId, name = "collision" }
    }

    for i = 1, #entities do
        local entityData = entities[i]
        if entityData.id then
            local entity = NetworkGetEntityFromNetworkId(entityData.id)
            if entity and DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end
end

---@param inventoryId string
---@return number
function Heist:getIndexFromInventory(inventoryId)
    return self.private.inventories[inventoryId]
end

function Heist:getInventoryFromIndex(spotIndex)
    local inventories = self.private.inventories
    for inventoryId, _spotIndex in pairs(inventories) do
        if _spotIndex == spotIndex then
            return inventoryId
        end
    end
    return nil
end

function Heist:registerInventory(inventoryId, spotIndex)
    self.private.inventories[inventoryId] = spotIndex
end

--- Check if container is opened
---@return boolean
function Heist:isOpened()
    return self.private.isOpen
end

--- Get nearby players within range
---@return number[] playerSources Array of player source IDs
function Heist:getNearbyPlayers()
    local xPlayers = ESX.GetExtendedPlayers()
    local nearbyPlayers = {}
    local containerCoords = self.private.coords.xyz

    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        local playerCoords = xPlayer.getCoords(true)

        if playerCoords and #(playerCoords - containerCoords) < 100.0 then
            nearbyPlayers[#nearbyPlayers + 1] = xPlayer.source
        end
    end

    return nearbyPlayers
end

--- Get heist status
---@return string status 'started' | 'finished'
function Heist:getStatus()
    return self.private.status
end

--- Get heist start time
---@return number timestamp Unix timestamp
function Heist:getStartTime()
    return self.private.startTime
end

--- Get heist end time
---@return number? timestamp Unix timestamp or nil if not finished
function Heist:getEndTime()
    return self.private.endTime
end

--- Get container network ID
---@return number? netId Container network ID
function Heist:getContainer()
    return self.private.containerNetId
end

--- Get collision network ID
---@return number? netId Collision network ID
function Heist:getCollision()
    return self.private.collisionNetId
end

--- Get lock network ID
---@return number? netId Lock network ID
function Heist:getLock()
    return self.private.lockNetId
end

--- Get heist coordinates
---@return vector4
function Heist:getCoords()
    return self.private.coords
end

--- Check if spot is searched
---@param spotIndex number Loot spot index
---@return boolean
function Heist:isSpotSearched(spotIndex)
    return self.private.searchedSpots[spotIndex] or false
end

---@return table<number, boolean>
function Heist:getSearchedSpots()
    return self.private.searchedSpots
end

--- Mark spot as searched and check completion
---@param spotIndex number Loot spot index
function Heist:markSpotAsSearched(spotIndex)
    self.private.searchedSpots[spotIndex] = true

    local searchedCount, totalCount = 0, 0
    for _, value in pairs(self.private.searchedSpots) do
        totalCount = totalCount + 1
        if value then
            searchedCount = searchedCount + 1
        end
    end

    if searchedCount >= totalCount then
        self.private.status = 'finished'
        self.private.endTime = os.time()
        return true -- Zwraca true jeśli napad się zakończył
    end
    return false
end

--- Set container, collision, and lock network IDs
---@param container number? Container network ID
---@param collision number? Collision network ID
---@param lock number? Lock network ID
function Heist:setObjects(container, collision, lock)
    self.private.containerNetId = container
    self.private.collisionNetId = collision
    self.private.lockNetId = lock
end

function Heist:openContainer()
    self.private.isOpen = true

    local entities = {
        { id = self.private.containerNetId, name = "container" },
        { id = self.private.lockNetId, name = "lock" }
    }

    for i = 1, #entities do
        local entityData = entities[i]
        if entityData.id then
            local entity = NetworkGetEntityFromNetworkId(entityData.id)
            if entity and DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
    end

    self:setObjects(nil, self.private.collisionNetId, nil)
end

return Heist
