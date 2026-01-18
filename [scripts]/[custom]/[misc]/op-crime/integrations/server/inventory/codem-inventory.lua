if Config.Inventory.inventoryScript ~= "codem-inventory" then return end

while Framework == nil do Wait(5) end

Fr.RegisterServerCallback('op-crime:searchPlayer', function(source, cb, target)
    if handcuffedPlayers[tostring(target)] or Fr.IsPlayerDead(target) then
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
        exports['codem-inventory']:AddItem(playerId, reward.nameSpawn, reward.amount)
    elseif reward.type == "money" then
        addOrgMoney("balance", reward.amount, orgId)
    elseif reward.type == "black_money" then
        addOrgMoney("dirtymoney", reward.amount, orgId)
    elseif reward.type == "car" then
        insertCarToOrg(reward.nameSpawn, orgId)
    end
end