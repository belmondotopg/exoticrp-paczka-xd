local economy = Config.Economy['orangeharvest']
local harvestTreeCooldowns = {}
local processCooldowns = {}

local function sendLog(src, message)
    local esx_core = exports.esx_core
    esx_core:SendLog(src, "Zbieranie pomarańczy", message, "orangeharvest")
end

RegisterNetEvent('esx_jobs/orangeharvest/getOrange', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - coords) > economy.distances.harvest then
        xPlayer.showNotification('Jesteś za daleko od miejsca zbierania.')
        return
    end

    local lastHarvest = harvestTreeCooldowns[src] or 0
    if (GetGameTimer() - lastHarvest) < economy.cooldowns.harvest then
        xPlayer.showNotification('Odczekaj chwilę przed kolejnym zbieraniem.')
        return
    end

    harvestTreeCooldowns[src] = GetGameTimer()

    local orangeItem = xPlayer.getInventoryItem('orange')
    local orangeCount = orangeItem and orangeItem.count or 0
    if orangeCount >= economy.orange.maxAmount then
        xPlayer.showNotification('Masz przy sobie maksymalną ilość pomarańczy!')
        return
    end

    local addAmount = math.random(economy.orange.addAmountMin, economy.orange.addAmountMax)

    if orangeCount + addAmount > economy.orange.maxAmount then
        addAmount = economy.orange.maxAmount - orangeCount
    end

    if addAmount > 0 then
        xPlayer.addInventoryItem('orange', addAmount)
        xPlayer.showNotification('Zebrałeś ' .. addAmount .. ' sztuk pomarańczy.')
        sendLog(src, 'Gracz zebrał ' .. addAmount .. ' sztuk pomarańczy.')
    end
end)

RegisterNetEvent('esx_jobs/orangeharvest/produceJuice', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local processCoords = vec3(1709.5624, 4728.3848, 42.1539)

    if #(pedCoords - processCoords) > economy.distances.process then
        xPlayer.showNotification('Jesteś za daleko od miejsca wymieniania.')
        return
    end

    local lastProcess = processCooldowns[src] or 0
    if (GetGameTimer() - lastProcess) < economy.cooldowns.process then
        xPlayer.showNotification('Odczekaj chwilę przed kolejnym wymienianiem.')
        return
    end

    processCooldowns[src] = GetGameTimer()

    local orangeItem = xPlayer.getInventoryItem('orange')
    local orangeCount = orangeItem and orangeItem.count or 0
    if orangeCount < economy.process.inputAmount then
        xPlayer.showNotification('Potrzebujesz przy sobie mieć przynajmniej ' .. economy.process.inputAmount .. ' sztuk pomarańczy!')
        return
    end

    xPlayer.removeInventoryItem('orange', economy.process.inputAmount)
    xPlayer.addInventoryItem('orange_juice', economy.process.outputAmount)
    sendLog(src, 'Gracz przerobił ' .. economy.process.inputAmount .. ' sztuk pomarańczy na ' .. economy.process.outputAmount .. ' sztukę soku pomarańczowego.')
end)

RegisterNetEvent('vwk/orange/sell', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local sellCoords = vec3(1709.5624, 4728.3848, 42.1539)

    if #(pedCoords - sellCoords) > economy.distances.sell then
        xPlayer.showNotification('Jesteś za daleko od miejsca sprzedaży.')
        return
    end

    local orangeItem = xPlayer.getInventoryItem('orange')
    local orangeCount = orangeItem and orangeItem.count or 0

    if orangeCount < economy.sell.inputAmount then
        xPlayer.showNotification('Musisz posiadać przy sobie minimum ' .. economy.sell.inputAmount .. ' sztuk pomarańczy!')
        return
    end

    local success = exports.ox_inventory:RemoveItem(src, 'orange', economy.sell.inputAmount)
    if success then
        local price = math.random(economy.sell.priceMin, economy.sell.priceMax)
        exports.ox_inventory:AddItem(src, 'money', price)
        
        local bonusRoll = math.random(1, 100)
        if bonusRoll <= economy.sell.bonusChance then
            xPlayer.addInventoryItem('orange_juice', economy.sell.bonusAmount)
            xPlayer.showNotification('Sprzedawca dał ci sok za darmo!')
        end
        
        xPlayer.showNotification('Sprzedałeś ' .. economy.sell.inputAmount .. ' pomarańczy za ' .. price .. '$')
        sendLog(src, 'Gracz sprzedał ' .. economy.sell.inputAmount .. ' pomarańczy za ' .. price .. '$')
    end
end)