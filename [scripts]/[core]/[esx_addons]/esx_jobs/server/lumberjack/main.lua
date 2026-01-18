local economy = Config.Economy['lumberjack']
local randomSellPrice = math.random(economy.sellPrice.min, economy.sellPrice.max)
local chopCooldowns = {}
local processCooldowns = {}
local sellCooldowns = {}

local function sendLog(src, message)
    local esx_core = exports.esx_core
    esx_core:SendLog(src, "Drwal", message, "lumberjack")
end

RegisterNetEvent('esx_jobs/lumberjack/treeChoped', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - coords) > economy.distances.chop then
        xPlayer.showNotification('Jesteś za daleko od drzewa.')
        return
    end

    local lastChop = chopCooldowns[src] or 0
    if (GetGameTimer() - lastChop) < economy.cooldowns.chop then
        xPlayer.showNotification('Odczekaj chwilę przed kolejnym ścięciem.')
        return
    end

    chopCooldowns[src] = GetGameTimer()

    if Config.Basics['lumberjack'].job.required then
        if Config.Basics['lumberjack'].job.name ~= xPlayer.job.name then
            return
        end
    end

    local woodItem = xPlayer.getInventoryItem('wood')
    local woodCount = woodItem and woodItem.count or 0
    if woodCount >= economy.wood.maxAmount then
        xPlayer.showNotification('Nie możesz unieść więcej drewna! Musisz udać się przerobić drewno.')
        return
    end

    local addAmount = economy.wood.addAmount
    if woodCount + addAmount > economy.wood.maxAmount then
        addAmount = economy.wood.maxAmount - woodCount
    end

    if addAmount > 0 then
        xPlayer.addInventoryItem('wood', addAmount)
        xPlayer.showNotification('Zebrałeś ' .. addAmount .. ' sztuk drewna.')
        sendLog(src, 'Gracz zebrał ' .. addAmount .. ' sztuk drewna.')
    end
end)

RegisterNetEvent('esx_jobs/lumberjack/processWood', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - coords) > economy.distances.process then
        xPlayer.showNotification('Jesteś za daleko od miejsca obrabiania.')
        return
    end

    local lastProcess = processCooldowns[src] or 0
    if (GetGameTimer() - lastProcess) < economy.cooldowns.process then
        xPlayer.showNotification('Odczekaj chwilę przed kolejnym obrabianiem.')
        return
    end

    processCooldowns[src] = GetGameTimer()

    if Config.Basics['lumberjack'].job.required then
        if Config.Basics['lumberjack'].job.name ~= xPlayer.job.name then
            return
        end
    end

    local woodItem = xPlayer.getInventoryItem('wood')
    local woodCount = woodItem and woodItem.count or 0
    if woodCount < economy.process.inputAmount then
        xPlayer.showNotification('Potrzebujesz przynajmniej ' .. economy.process.inputAmount .. ' sztuk drewna.')
        return
    end

    xPlayer.removeInventoryItem('wood', economy.process.inputAmount)
    xPlayer.addInventoryItem('packaged_plank', economy.process.outputAmount)
    xPlayer.showNotification('Przerobiłeś ' .. economy.process.inputAmount .. ' sztuk drewna na ' .. economy.process.outputAmount .. ' sztuk zapakowanych desek.')
    sendLog(src, 'Gracz przerobił ' .. economy.process.inputAmount .. ' sztuk drewna na ' .. economy.process.outputAmount .. ' zapakowanych desek.')
end)

RegisterNetEvent('esx_jobs/lumberjack/sellPlanks', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - Config.Peds['lumberjack'][3].coords) > economy.distances.sell then
        xPlayer.showNotification('Jesteś za daleko od miejsca sprzedaży.')
        return
    end

    local lastSell = sellCooldowns[src] or 0
    if (GetGameTimer() - lastSell) < economy.cooldowns.sell then
        xPlayer.showNotification('Odczekaj chwilę przed kolejną sprzedażą.')
        return
    end

    sellCooldowns[src] = GetGameTimer()

    if Config.Basics['lumberjack'].job.required then
        if Config.Basics['lumberjack'].job.name ~= xPlayer.job.name then
            return
        end
    end

    local plankItem = xPlayer.getInventoryItem('packaged_plank')
    local plankCount = plankItem and plankItem.count or 0

    if plankCount < economy.sell.minAmount then
        xPlayer.showNotification('Musisz posiadać przy sobie minimum ' .. economy.sell.minAmount .. ' sztuk zapakowanych desek!')
        return
    end

    local salary = plankCount * randomSellPrice
    local societySalary = salary * economy.sell.societyPercent

    xPlayer.removeInventoryItem('packaged_plank', plankCount)
    xPlayer.addMoney(salary)
    xPlayer.showNotification('Otrzymano ' .. salary .. '$ za sprzedaż ' .. plankCount .. ' zapakowanych desek!')

    TriggerEvent('esx_addonaccount:getSharedAccount', Config.Basics['lumberjack'].job.name, function(account)
        account.addMoney(societySalary)
    end)

    -- Zaktualizuj kursy w bazie danych
    local result = MySQL.single.await('SELECT rankLegalCourses FROM users WHERE identifier = ?', {xPlayer.identifier})
    local currentKursy = result and result.rankLegalCourses or 0
    local newKursy = currentKursy + 1
    MySQL.update.await('UPDATE users SET rankLegalCourses = ? WHERE identifier = ?', {newKursy, xPlayer.identifier})
    
    -- Zaktualizuj kursy w QFSOCIETY_SERVER jeśli bossmenu jest otwarte
    if exports.esx_society then
        pcall(function()
            if exports.esx_society.UpdatePlayerKursy then
                -- Używamy 'drwal' jako nazwy joba (zgodnie z esx_society)
                exports.esx_society:UpdatePlayerKursy(xPlayer.identifier, 'drwal', newKursy)
            end
        end)
    end

    sendLog(src, 'Gracz otrzymał ' .. salary .. '$ za sprzedaż ' .. plankCount .. ' sztuk zapakowanych desek.\nFirma otrzymała na swoje konto ' .. societySalary .. '$ za sprzedaż zapakowanych desek przez gracza.')
end)

CreateThread(function()
    while true do
        Wait(economy.priceChangeInterval)

        local newRandomSellPrice = math.random(economy.sellPrice.min, economy.sellPrice.max)

        while newRandomSellPrice == randomSellPrice do
            newRandomSellPrice = math.random(economy.sellPrice.min, economy.sellPrice.max)
        end

        randomSellPrice = newRandomSellPrice
    end
end)

lib.callback.register('esx_jobs/lumberjack/getMarketPrice', function()
    return randomSellPrice
end)

RegisterNetEvent('esx_jobs/lumberjack/endWorkWithPenalty', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local penaltyAmount = economy.vehiclePenalty.amount
    local playerMoney = xPlayer.getAccount('money').money

    if playerMoney >= penaltyAmount then
        xPlayer.removeAccountMoney('money', penaltyAmount)
        xPlayer.showNotification('Zakończono pracę. Nałożono karę: ' .. penaltyAmount .. '$ za nieoddanie pojazdu.')
        sendLog(src, 'Gracz zakończył pracę bez oddania pojazdu. Nałożono karę: ' .. penaltyAmount .. '$')
    else
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy na pokrycie kary (' .. penaltyAmount .. '$).')
    end
end)