if Config.Inventory.inventoryScript ~= "tgiann_inventory" then return end

while Framework == nil do Wait(5) end

Fr.RegisterServerCallback('op-crime:searchPlayer', function(source, cb, target)
    if handcuffedPlayers[tostring(target)] or Fr.IsPlayerDead(target) then
        local playerId = tonumber(target)
        exports["tgiann-inventory"]:OpenInventoryById(source, playerId, true)
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

        exports["tgiann-inventory"]:RegisterStash(stashName, orgLabel, 500, capacity * 1000)
    end
end

function registerNewOrgStash(orgId, orgLabel)
    exports["tgiann-inventory"]:RegisterStash("organisation_" .. orgId, orgLabel, 500, Config.Misc.defaultStashWeight * 1000)
end

function updateOrgStash(orgId, orgLabel, Capacity)
    local Inv = exports["tgiann-inventory"]:GetInventory("organisation_" .. orgId, "stash")
    if not Inv then return end
    local lvlData = config.stash[lvl]
    Inv.Functions.UpdateInventoryData({
        MaxWeight = Capacity * 1000,
        MaxSlots = 500
    })
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
        exports["tgiann-inventory"]:AddItemToSecondaryInventory("stash", 'organisation_' .. orgId, reward.nameSpawn, reward.amount)
    elseif reward.type == "money" then
        addOrgMoney("balance", reward.amount, orgId)
    elseif reward.type == "black_money" then
        addOrgMoney("dirtymoney", reward.amount, orgId)
    elseif reward.type == "car" then
        insertCarToOrg(reward.nameSpawn, orgId)
    end
end

RegisterNetEvent('op-crime:openTgiannStash')
AddEventHandler('op-crime:openTgiannStash', function()
    local playerObject = playersJobs[trim(Fr.GetIndentifier(source))]

    if playerObject then
        local playerOrg = organisations[tostring(playerObject.jobId)]

        if playerOrg then
            local label = playerOrg.label
            local capacity = playerOrg.upgrades.stashCapacity * 1000

            local data = { label = label, maxweight = capacity, slots = 500 }
            exports["tgiann-inventory"]:OpenInventory(source, "stash", label, {
                maxweight = capacity,
                slots = 50,
            })
        end
    end
end)