if Config.Inventory.inventoryScript ~= "qb-inventory" then return end

while Framework == nil do Wait(5) end

Fr.RegisterServerCallback('op-crime:searchPlayer', function(source, cb, target)
    if handcuffedPlayers[tostring(target)] or Fr.IsPlayerDead(target) then
        exports['qb-inventory']:OpenInventoryById(source, playerId)
        cb('ok')
    else    
        cb(false)
    end
end)

function registerStashes()
end

function registerNewOrgStash(orgId, orgLabel)
end

function updateOrgStash(orgId, orgLabel, Capacity)
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
        exports['qb-inventory']:AddItem('organisation_' .. orgId, reward.nameSpawn, reward.amount, nil, false, "")
    elseif reward.type == "money" then
        addOrgMoney("balance", reward.amount, orgId)
    elseif reward.type == "black_money" then
        addOrgMoney("dirtymoney", reward.amount, orgId)
    elseif reward.type == "car" then
        insertCarToOrg(reward.nameSpawn, orgId)
    end
end

RegisterNetEvent('op-crime:openQBStash')
AddEventHandler('op-crime:openQBStash', function()
    local playerObject = playersJobs[trim(Fr.GetIndentifier(source))]

    if playerObject then
        local playerOrg = organisations[tostring(playerObject.jobId)]

        if playerOrg then
            local label = playerOrg.label
            local capacity = playerOrg.upgrades.stashCapacity * 1000

            local data = { label = label, maxweight = capacity, slots = 500 }
            exports['qb-inventory']:OpenInventory(source, "organisation_" .. playerObject.jobId, data)
        end
    end
end)