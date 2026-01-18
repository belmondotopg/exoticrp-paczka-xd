local weedPlants = {}
local weedId = 0
GlobalState.weedPlants = weedPlants

Citizen.CreateThread(function()
    for item, data in pairs(Config.Weed.Seeds) do
        ESX.RegisterUsableItem(item..'_seed', function(playerId)
            local _source = playerId
            TriggerClientEvent('drugs:weed:SetupWeed', _source, {itemName = item, itemData = data})
        end)
        ESX.RegisterUsableItem(item..'_top', function(playerId)
            local _source = playerId
            TriggerClientEvent('drugs:weed:GrindTop', _source, {itemName = item, itemData = data})
        end)
        -- print(item..'_gram')
        ESX.RegisterUsableItem(item..'_gram', function(playerId)
            local _source = playerId
            local weedCount = exports.ox_inventory:Search(_source, 'count', item..'_gram')
            if weedCount < 1 then
                return TriggerClientEvent('esx:showNotification', _source, 'Masz niewystarczająco ilość')
            end

            local paperItem = exports.ox_inventory:Search(_source, 'slots', 'ocb_paper')
            if not paperItem or not paperItem[1] then
                return TriggerClientEvent('esx:showNotification', _source, 'Potrzebujesz w coś to zawinąć')
            end
            -- Sprawdź durability tylko jeśli istnieje w metadata
            if paperItem[1].metadata and paperItem[1].metadata.durability and paperItem[1].metadata.durability < 1.0 then
                return TriggerClientEvent('esx:showNotification', _source, 'Bletka jest zużyta')
            end

            -- paperItem[1].metadata.durability -= 25.0
            -- exports['ox_inventory']:SetMetadata(_source, paperItem[1].slot, paperItem[1].metadata)
            TriggerClientEvent('drugs:weed:RollJoint', _source, {itemName = item, itemData = data, paper = paperItem[1]})
        end)
    end
end)

RegisterNetEvent('drugs:weed:RollJoint', function(data)
    local _source = source
    local weedCount = exports.ox_inventory:Search(_source, 'count', data.itemName..'_gram')
    if weedCount < 1 then
        return TriggerClientEvent('esx:showNotification', _source, 'Masz niewystarczająco ilość')
    end

    local paperItem = exports.ox_inventory:GetSlot(_source, data.paper.slot)
    if not paperItem then
        return TriggerClientEvent('esx:showNotification', _source, 'Potrzebujesz w coś to zawinąć')
    end
    
    -- Sprawdź durability tylko jeśli istnieje w metadata
    if paperItem.metadata and paperItem.metadata.durability and paperItem.metadata.durability < 1.0 then
        return TriggerClientEvent('esx:showNotification', _source, 'Bletka jest zużyta')
    end

    local removedPaper = exports['ox_inventory']:RemoveItem(_source, 'ocb_paper', 1, nil, data.paper.slot)
    if not removedPaper then
        return TriggerClientEvent('esx:showNotification', _source, 'Nie udało się usunąć bibułki')
    end
    
    local removedWeed = exports['ox_inventory']:RemoveItem(_source, data.itemName..'_gram', 1)
    if removedWeed then
        exports['ox_inventory']:AddItem(_source, data.itemName..'_joint', 1)
    end
end)

RegisterNetEvent('drugs:weed:GrindTop', function(data)
    local _source = source
    if (exports['ox_inventory']:Search(_source, 'count', data.itemName..'_top') or 0) < 1 then
        return TriggerClientEvent('esx:showNotification', _source, 'Nie masz ziół do zmielenia')
    end

    local removedItem = exports['ox_inventory']:RemoveItem(_source, data.itemName..'_top', 1)
    if removedItem then
        local gramAmount = math.random(6, 10)
        local success, response = exports['ox_inventory']:AddItem(_source, data.itemName..'_gram', gramAmount)
        if success then
            TriggerClientEvent('esx:showNotification', _source, 'Zmielono zioła: ' .. gramAmount .. 'g')
        else
            -- Zwróć przedmiot jeśli nie udało się dodać
            exports['ox_inventory']:AddItem(_source, data.itemName..'_top', 1)
            TriggerClientEvent('esx:showNotification', _source, 'Nie udało się dodać zmielonych ziół: ' .. (response or 'nieznany błąd'))
            print('[WEED] Błąd dodawania przedmiotu ' .. data.itemName..'_gram' .. ' dla gracza ' .. _source .. ': ' .. tostring(response))
        end
    else
        TriggerClientEvent('esx:showNotification', _source, 'Nie udało się zmielić ziół')
    end
end)

RegisterNetEvent('drugs:weed:PlantSeed')
AddEventHandler('drugs:weed:PlantSeed', function(data, offset)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    local players = GetPlayers()
    if #players < 15 then
        return xPlayer.showNotification('Musi być minimum 15 graczy na serwerze, aby móc sadzić rośliny')
    end
    
    local weedData = Config.Weed.Seeds[data.itemName]
    if not weedData then
        -- print('nie ma ziolo dane')
        return
    end

    if exports['ox_inventory']:Search(_source, 'count', data.itemName..'_seed') < 1 then
        -- print('czm nie ma nasiona')
        return
    end

    local playerIdentifier = xPlayer.identifier
    local playerPlantCount = 0
    for _, plantData in pairs(weedPlants) do
        if plantData.owner == playerIdentifier then
            playerPlantCount = playerPlantCount + 1
        end
    end

    if playerPlantCount >= 3 then
        return xPlayer.showNotification('Możesz mieć maksymalnie 3 krzaki jednocześnie posadzone')
    end

    local isClose = false
    local plantCoords = {x = offset.x, y = offset.y, z = offset.z - 1}
    for _, plantData in pairs(weedPlants) do
        if #(vector3(plantCoords.x, plantCoords.y, plantCoords.z) - vector3(plantData.coords.x, plantData.coords.y, plantData.coords.z)) < 1.75 then
            isClose = true
            break
        end
    end

    if isClose then
        return xPlayer.showNotification('Nie możesz zasadzić nowej rośliny tak blisko innej rośliny')
    end

    exports['ox_inventory']:RemoveItem(_source, data.itemName..'_seed', 1)
    weedId += 1
    local weedObject = CreateObject(weedData.prop[1], plantCoords.x, plantCoords.y, plantCoords.z, true, true, false)
    FreezeEntityPosition(weedObject, true)
    local newPlant = {
        id = weedId,
        coords = plantCoords,
        weedType = data.itemName,
        objId = weedObject,
        model = weedData.prop[1],
        grow = 0,
        water = 0,
        food = 0,
        ticks = 0,
        status = 'Rośnie',
        owner = playerIdentifier
    }
    weedPlants[weedId] = newPlant
    GlobalState.weedPlants = weedPlants
    TriggerClientEvent('drugs:weed:NewPlant', -1, newPlant)
end)

Citizen.CreateThread(function()
    while true do
        for id, data in pairs(weedPlants) do
            Wait(1)
            if data.water < 1 then
                data.ticks += 1

                if data.ticks == 30 then
                    data.status = 'Nie rośnie'
                elseif data.ticks == 60 then
                    data.status = 'Zwiędła'
                elseif data.ticks == 70 then
                    if data.objId and data.objId ~= 0 and DoesEntityExist(data.objId) then
                        DeleteEntity(data.objId)
                    end
                    weedPlants[id] = nil
                end
            else
                data.ticks = 0
                if data.status ~= 'Zwiędła' then
                    data.status = 'Rośnie'
                end
                if data.status == 'Rośnie' and data.grow < 100 then
                    data.grow = data.grow + (data.food > 0 and 4 or 2)

                    if data.food > 0 then
                        data.food -= 1
                    end
    
                    data.water -= 1

                    local weedData = Config.Weed.Seeds[data.weedType]
                    if data.grow >= 30 and data.grow < 75 and weedData.prop[2] and data.model ~= weedData.prop[2] then
                        data.model = weedData.prop[2]
                        if data.objId and data.objId ~= 0 and DoesEntityExist(data.objId) then
                            DeleteEntity(data.objId)
                        end

                        local newObj = CreateObject(data.model, data.coords.x, data.coords.y, data.coords.z, true, true, false)
                        if newObj and newObj ~= 0 then
                            FreezeEntityPosition(newObj, true)
                            data.objId = newObj
                        end
                    elseif data.grow >= 75 and weedData.prop[3] and data.model ~= weedData.prop[3] then
                        data.model = weedData.prop[3]
                        if data.objId and data.objId ~= 0 and DoesEntityExist(data.objId) then
                            DeleteEntity(data.objId)
                        end

                        local newObj = CreateObject(data.model, data.coords.x, data.coords.y, data.coords.z, true, true, false)
                        if newObj and newObj ~= 0 then
                            FreezeEntityPosition(newObj, true)
                            data.objId = newObj
                        end
                    end
                end
            end
        end
        GlobalState.weedPlants = weedPlants
        Citizen.Wait(30 * 1000)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for id, data in pairs(weedPlants) do
            if data.objId and data.objId ~= 0 and DoesEntityExist(data.objId) then
                DeleteEntity(data.objId)
            end
        end
        weedPlants = {}
        GlobalState.weedPlants = weedPlants
    end
end)

RegisterNetEvent('drugs:weed:WaterSeed')
AddEventHandler('drugs:weed:WaterSeed', function(plantId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if exports['ox_inventory']:Search(_source, 'count', 'water_bottle') < 1 then
        return
    end

    if not weedPlants[plantId] then
        return
    end

    local waterAmount = Config.Weed.Utils['watering']    
    exports['ox_inventory']:RemoveItem(_source, 'water_bottle', 1)

    weedPlants[plantId].water += waterAmount

    if weedPlants[plantId].water >= 125 then
        xPlayer.showNotification('Przelałeś rośline, nie nadaje się ona do zebrania i przestała rosnąć')
        if weedPlants[plantId].objId and weedPlants[plantId].objId ~= 0 and DoesEntityExist(weedPlants[plantId].objId) then
            DeleteEntity(weedPlants[plantId].objId)
        end
        weedPlants[plantId] = nil
        GlobalState.weedPlants = weedPlants
    end
end)

RegisterNetEvent('drugs:weed:FoodSeed')
AddEventHandler('drugs:weed:FoodSeed', function(plantId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if exports['ox_inventory']:Search(_source, 'count', 'fertilizer') < 1 then
        return
    end

    if not weedPlants[plantId] then
        return
    end

    local foodAmount = Config.Weed.Utils['fertilizing']    
    exports['ox_inventory']:RemoveItem(_source, 'fertilizer', 1)

    weedPlants[plantId].food += foodAmount

    if weedPlants[plantId].food >= 125 then
        xPlayer.showNotification('Przenawoziłeś rośline, nie nadaje się ona do zebrania i przestała rosnąć')
        if weedPlants[plantId].objId and weedPlants[plantId].objId ~= 0 and DoesEntityExist(weedPlants[plantId].objId) then
            DeleteEntity(weedPlants[plantId].objId)
        end
        weedPlants[plantId] = nil
        GlobalState.weedPlants = weedPlants
    end
end)

RegisterNetEvent('drugs:weed:CollectSeed')
AddEventHandler('drugs:weed:CollectSeed', function(plantId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local weedData = weedPlants[plantId]

    if not weedData then
        return
    end

    if weedData.grow < 100 then
        return
    end

    if #(xPlayer.getCoords(true) - vector3(weedData.coords.x, weedData.coords.y, weedData.coords.z)) > 7.5 then
        return
    end

    local weedReward = Config.Weed.Seeds[weedData.weedType]
    local random = math.random(weedReward.top.min, weedReward.top.max)
    exports["esx_hud"]:UpdateTaskProgress(_source, "DrugsCollect")
    exports['ox_inventory']:AddItem(_source, weedData.weedType..'_top', random)
    if weedPlants[plantId].objId and weedPlants[plantId].objId ~= 0 and DoesEntityExist(weedPlants[plantId].objId) then
        DeleteEntity(weedPlants[plantId].objId)
    end
    weedPlants[plantId] = nil
    GlobalState.weedPlants = weedPlants
    TriggerClientEvent('drugs:weed:RemovePlant', -1, plantId)
end)