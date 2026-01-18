if Config.Inventory.inventoryScript ~= "ox_inventory" then return end

while Framework == nil do Wait(5) end

local function isPlayerInGZ(playerId)
    if not Config.Zones or not Config.Zones[1] then return false end
    
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return false end
    
    local playerCoords = GetEntityCoords(playerPed)
    if not playerCoords then return false end
    
    for _, zoneData in pairs(Config.Zones) do
        if zoneData.Zone then
            local zone = zoneData.Zone()
            if zone and zone.isPointInside then
                local point2D = vector2(playerCoords.x, playerCoords.y)
                if zone:isPointInside(point2D) then
                    return true
                end
            end
        end
    end
    
    return false
end

local function canLootInGZ(playerId)
    local xPlayer = Fr.getPlayerFromId(playerId)
    if not xPlayer then return false end
    
    local job = xPlayer.job
    if not job or not job.name then return false end
    
    local jobName = string.lower(job.name)
    
    if jobName == "police" or jobName == "sheriff" then
        return true
    end
    
    if jobName == "ambulance" or jobName == "medic" or jobName == "doj" then
        return true
    end
    
    return false
end

Fr.RegisterServerCallback('op-crime:searchPlayer', function(source, cb, target)
    if handcuffedPlayers[tostring(target)] or Fr.IsPlayerDead(target) then
        if handcuffedPlayers[tostring(target)] and isPlayerInGZ(target) then
            if not canLootInGZ(source) then
                cb(false)
                return
            end
        end
        
        exports.ox_inventory:forceOpenInventory(source, 'player', tonumber(target))
        cb('ok')
    else    
        cb(false)
    end
end)

function registerStashes()
    for k, v in pairs(organisations) do
        local stashName = "organisation_" .. v.id
        local orgLabel = v.label
        local capacity = v.upgrades.stashCapacity

        exports.ox_inventory:RegisterStash(stashName, orgLabel, 500, capacity * 1000)
    end
end

function registerNewOrgStash(orgId, orgLabel)
    exports.ox_inventory:RegisterStash("organisation_" .. orgId, orgLabel, 500, Config.Misc.defaultStashWeight * 1000)
end

function updateOrgStash(orgId, orgLabel, Capacity)
    exports.ox_inventory:RegisterStash("organisation_" .. orgId, orgLabel, 500, Capacity * 1000)
end

-----------------------------------------------
-- ASSIGN REWARD TO ORG
-----------------------------------------------

function assignReward(reward, orgId, playerId)
    if not orgId then
        print('[ERROR] - Unable to assign reward by Player:', playerId)
        print('reward.nameSpawn', reward.nameSpawn)
        return
    end

    if reward.type == "item" or reward.type == "weapon" then
        exports.ox_inventory:AddItem('organisation_' .. orgId, reward.nameSpawn, reward.amount, reward.metadata or {})
    elseif reward.type == "money" then
        addOrgMoney("balance", reward.amount, orgId)
    elseif reward.type == "black_money" then
        addOrgMoney("dirtymoney", reward.amount, orgId)
    elseif reward.type == "car" then
        insertCarToOrg(reward.nameSpawn, orgId)
    end
end