local activeCrafting = {}

function GetPlayerCraftingData(identifier)
    local result = MySQL.Sync.fetchAll('SELECT level, xp FROM player_crafting WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    })
    
    if result and result[1] then
        return result[1].level, result[1].xp
    else
        MySQL.Async.execute('INSERT INTO player_crafting (identifier, level, xp) VALUES (@identifier, @level, @xp)', {
            ['@identifier'] = identifier,
            ['@level'] = Config.DefaultLevel,
            ['@xp'] = Config.DefaultXP
        })
        return Config.DefaultLevel, Config.DefaultXP
    end
end

function UpdatePlayerXP(source, xpToAdd)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local identifier = xPlayer.identifier
    local currentLevel, currentXP = GetPlayerCraftingData(identifier)
    
    local newXP = currentXP + xpToAdd
    local newLevel = currentLevel
    
    local xpNeeded = newLevel * Config.XPRewards.levelUpMultiplier
    while newXP >= xpNeeded and newLevel < Config.MaxLevel do
        newXP = newXP - xpNeeded
        newLevel = newLevel + 1
        xpNeeded = newLevel * Config.XPRewards.levelUpMultiplier
        TriggerClientEvent('esx:showNotification', source, 'Awansowałeś na poziom ' .. newLevel .. '!')
    end
    
    MySQL.Async.execute('UPDATE player_crafting SET level = @level, xp = @xp WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['@level'] = newLevel,
        ['@xp'] = newXP
    })
    
    return newLevel, newXP
end

ESX.RegisterServerCallback('exoticrp_crafting:getData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb(nil)
        return 
    end
    
    if activeCrafting[source] then
        TriggerClientEvent('esx:showNotification', source, 'Już wytwarzasz przedmiot!')
        cb(nil)
        return
    end
    
    local identifier = xPlayer.identifier
    local level, xp = GetPlayerCraftingData(identifier)
    
    local inventory = {}
    local playerInventory = xPlayer.getInventory()
    
    for _, item in pairs(playerInventory) do
        if item.count > 0 then
            inventory[item.name] = item.count
        end
    end
    
    local xpNeeded = level * Config.XPRewards.levelUpMultiplier
    local levelProgress = math.min((xp / xpNeeded) * 100, 100)
    
    local data = {
        recipes = Config.Recipes,
        profile = {
            level = level,
            fullname = xPlayer.getName(),
            xp = xp,
            levelProgress = string.format("%.1f%%", levelProgress)
        },
        inventory = inventory
    }
    
    cb(data)
end)

RegisterNetEvent('exoticrp_crafting:craftItem')
AddEventHandler('exoticrp_crafting:craftItem', function(recipeName)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then return end
    
    if activeCrafting[source] then
        TriggerClientEvent('esx:showNotification', source, 'Już wytwarzasz przedmiot!')
        return
    end
    
    if type(recipeName) ~= "string" or recipeName == "" then
        return
    end
    
    local recipe = nil
    for _, r in pairs(Config.Recipes) do
        if r.itemName == recipeName then
            recipe = r
            break
        end
    end
    
    if not recipe then
        return
    end
    
    local identifier = xPlayer.identifier
    local level, _ = GetPlayerCraftingData(identifier)
    
    if not level then
        TriggerClientEvent('esx:showNotification', source, 'Błąd podczas pobierania danych!')
        return
    end
    
    if level < recipe.requiredLevel then
        TriggerClientEvent('esx:showNotification', source, 'Twój poziom jest za niski! Wymagany poziom: ' .. recipe.requiredLevel)
        return
    end
    
    local hasAllItems = true
    local missingItems = {}
    
    for itemName, itemData in pairs(recipe.craftItems) do
        local item = xPlayer.getInventoryItem(itemName)
        if not item or item.count < itemData.quantity then
            hasAllItems = false
            table.insert(missingItems, itemData.label .. ' (brakuje: ' .. (itemData.quantity - (item and item.count or 0)) .. ')')
        end
    end
    
    if not hasAllItems then
        TriggerClientEvent('esx:showNotification', source, 'Brakuje ci przedmiotów: ' .. table.concat(missingItems, ', '))
        return
    end
    
    local recipeItem = xPlayer.getInventoryItem(recipe.itemName)
    if recipeItem then
        if recipeItem.limit and recipeItem.limit ~= -1 and (recipeItem.count + 1) > recipeItem.limit then
            TriggerClientEvent('esx:showNotification', source, 'Nie możesz unieść więcej tego przedmiotu!')
            return
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'Przedmiot nie istnieje w bazie danych!')
        return
    end
    
    activeCrafting[source] = {
        recipe = recipe,
        startTime = os.time()
    }
    
    TriggerClientEvent('exoticrp_crafting:startCrafting', source, recipe.craftDuration)
    
    for itemName, itemData in pairs(recipe.craftItems) do
        xPlayer.removeInventoryItem(itemName, itemData.quantity)
    end
    
    SetTimeout(recipe.craftDuration, function()
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer or not activeCrafting[source] then
            if xPlayer then
                for itemName, itemData in pairs(recipe.craftItems) do
                    xPlayer.addInventoryItem(itemName, itemData.quantity)
                end
            end
            return
        end
        
        xPlayer.addInventoryItem(recipe.itemName, 1)
        
        local xpReward = Config.XPRewards[recipe.itemName] or Config.XPRewards.craftSuccess
        local newLevel, newXP = UpdatePlayerXP(source, xpReward)
        
        if not newLevel or not newXP then
            activeCrafting[source] = nil
            return
        end
        
        local xpNeeded = newLevel * Config.XPRewards.levelUpMultiplier
        local levelProgress = math.min((newXP / xpNeeded) * 100, 100)
        
        TriggerClientEvent('esx:showNotification', source, 'Pomyślnie wytworzono: ' .. recipe.label)
        TriggerClientEvent('exoticrp_crafting:craftingComplete', source, {
            level = newLevel,
            xp = newXP,
            levelProgress = string.format("%.1f%%", levelProgress)
        })
                
        activeCrafting[source] = nil
    end)
end)

RegisterNetEvent('exoticrp_crafting:cancelCrafting')
AddEventHandler('exoticrp_crafting:cancelCrafting', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if activeCrafting[source] and xPlayer then
        local recipe = activeCrafting[source].recipe
        
        for itemName, itemData in pairs(recipe.craftItems) do
            xPlayer.addInventoryItem(itemName, itemData.quantity)
        end
        
        activeCrafting[source] = nil
        TriggerClientEvent('esx:showNotification', source, 'Anulowano wytwarzanie')
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    
    if activeCrafting[source] then
        activeCrafting[source] = nil
    end
end)

GlobalState.vwktable = {
    vec4(903.9724, -1687.7684, 47.3525-.95, 263.8971)
}

RegisterNetEvent("adminCraftingTable:spawn", function(coords, heading)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or (xPlayer.group ~= "admin" and xPlayer.group ~= "founder") then return end

    local netId = NetworkGetNetworkIdFromEntity(0) + math.random(100000,999999) -- proste unikalne ID
    print("Spawning crafting table with netId: " .. netId)
    TriggerClientEvent("adminCraftingTable:spawnOne", -1, coords, heading, netId)
end)    


RegisterNetEvent("adminCraftingTable:delete", function(netId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or (xPlayer.group ~= "admin" and xPlayer.group ~= "superadmin") then return end
    TriggerClientEvent("adminCraftingTable:removeOne", -1, netId)
end)