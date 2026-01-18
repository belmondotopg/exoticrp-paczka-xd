local economy = Config.Economy['weazelnews']
-- Ensure max is at least equal to min to avoid empty interval error
local minPrice = economy.sellPrice.min or 1000
local maxPrice = math.max(economy.sellPrice.max or 1400, minPrice)
local randomSellPrice = math.random(minPrice, maxPrice)
local takePhotoCooldowns = {}
local processCooldowns = {}
local sellCooldowns = {}

local function sendLog(src, message)
    local esx_core = exports.esx_core
    esx_core:SendLog(src, "Weazel News", message, "weazelnews")
end

RegisterNetEvent('esx_jobs/weazelnews/photoTaken', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - coords) > economy.distances.takePhoto then
        xPlayer.showNotification('Jesteś za daleko od miejsca zdjęcia.')
        return
    end

    local lastTakePhoto = takePhotoCooldowns[src] or 0
    if (GetGameTimer() - lastTakePhoto) < economy.cooldowns.takePhoto then
        xPlayer.showNotification('Odczekaj chwilę przed kolejnym zdjęciem.')
        return
    end

    takePhotoCooldowns[src] = GetGameTimer()

    if Config.Basics['weazelnews'].job.required then
        if Config.Basics['weazelnews'].job.name ~= xPlayer.job.name then
            return
        end
    end

    local photoItem = xPlayer.getInventoryItem('photo')
    local photoCount = photoItem and photoItem.count or 0
    if photoCount >= economy.photo.maxAmount then
        xPlayer.showNotification('Masz przy sobie maksymalną ilość zdjęć!')
        return
    end

    local addAmount = economy.photo.addAmount
    if photoCount + addAmount > economy.photo.maxAmount then
        addAmount = economy.photo.maxAmount - photoCount
    end

    if addAmount > 0 then
        xPlayer.addInventoryItem('photo', addAmount)
        xPlayer.showNotification('Zrobiłeś ' .. addAmount .. ' sztuk zdjęć.')
        sendLog(src, 'Gracz zebrał ' .. addAmount .. ' sztuk zdjęć.')
    end
end)

RegisterNetEvent('esx_jobs/weazelnews/processPhotos', function(coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - coords) > economy.distances.process then
        xPlayer.showNotification('Jesteś za daleko od miejsca obrabiania zdjęć.')
        return
    end

    local lastProcess = processCooldowns[src] or 0
    if (GetGameTimer() - lastProcess) < economy.cooldowns.process then
        xPlayer.showNotification('Odczekaj chwilę przed kolejnym obrabianiem zdjęć.')
        return
    end

    processCooldowns[src] = GetGameTimer()

    if Config.Basics['weazelnews'].job.required then
        if Config.Basics['weazelnews'].job.name ~= xPlayer.job.name then
            return
        end
    end

    local photoItem = xPlayer.getInventoryItem('photo')
    local photoCount = photoItem and photoItem.count or 0
    if photoCount < economy.process.inputAmount then
        xPlayer.showNotification('Potrzebujesz przynajmniej ' .. economy.process.inputAmount .. ' sztuk zdjęć.')
        return
    end

    xPlayer.removeInventoryItem('photo', economy.process.inputAmount)
    xPlayer.addInventoryItem('processed_photo', economy.process.outputAmount)
    xPlayer.showNotification('Przerobiłeś ' .. economy.process.inputAmount .. ' sztuk zdjęć na obrobione ' .. economy.process.outputAmount .. ' zdjęć.')
    sendLog(src, 'Gracz przerobił ' .. economy.process.inputAmount .. ' sztuk zdjęć na ' .. economy.process.outputAmount .. ' obrobionych zdjęć.')
end)

RegisterNetEvent('esx_jobs/weazelnews/sellProcessedPhotos', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)

    if #(pedCoords - Config.Peds['weazelnews'][3].coords) > economy.distances.sell then
        xPlayer.showNotification('Jesteś za daleko od miejsca sprzedaży.')
        return
    end

    local lastSell = sellCooldowns[src] or 0
    if (GetGameTimer() - lastSell) < economy.cooldowns.sell then
        xPlayer.showNotification('Odczekaj chwilę przed kolejną sprzedażą.')
        return
    end

    sellCooldowns[src] = GetGameTimer()

    if Config.Basics['weazelnews'].job.required then
        if Config.Basics['weazelnews'].job.name ~= xPlayer.job.name then
            return
        end
    end

    local processedPhotoItem = xPlayer.getInventoryItem('processed_photo')
    local processedPhotoCount = processedPhotoItem and processedPhotoItem.count or 0

    if processedPhotoCount < economy.sell.minAmount then
        xPlayer.showNotification('Musisz posiadać przy sobie minimum ' .. economy.sell.minAmount .. ' sztuk obrobionych zdjęć!')
        return
    end

    local salary = processedPhotoCount * randomSellPrice
    local societySalary = salary * economy.sell.societyPercent

    xPlayer.removeInventoryItem('processed_photo', processedPhotoCount)
    xPlayer.addMoney(salary)
    xPlayer.showNotification('Otrzymano ' .. salary .. '$ za sprzedaż ' .. processedPhotoCount .. ' obrobionych zdjęć!')

    TriggerEvent('esx_addonaccount:getSharedAccount', Config.Basics['weazelnews'].job.name, function(account)
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
                exports.esx_society:UpdatePlayerKursy(xPlayer.identifier, 'weazelnews', newKursy)
            end
        end)
    end

    sendLog(src, 'Gracz otrzymał ' .. salary .. '$ za sprzedaż ' .. processedPhotoCount .. ' sztuk obrobionych zdjęć.\nFirma otrzymała na swoje konto ' .. societySalary .. '$ za sprzedaż obrobionych zdjęć przez gracza.')
end)

CreateThread(function()
    while true do
        Wait(economy.priceChangeInterval)

        -- Ensure maxAfterHour is at least equal to min to avoid empty interval error
        local minPrice = economy.sellPrice.min or 1000
        local maxPriceValue = economy.sellPrice.maxAfterHour or economy.sellPrice.max or 1400
        local maxPrice = math.max(maxPriceValue, minPrice)

        -- Validate that both values are valid numbers before calling math.random
        if type(minPrice) == "number" and type(maxPrice) == "number" and minPrice <= maxPrice then
            local newRandomSellPrice = math.random(minPrice, maxPrice)

            while newRandomSellPrice == randomSellPrice do
                newRandomSellPrice = math.random(minPrice, maxPrice)
            end

            randomSellPrice = newRandomSellPrice
        else
            print("[esx_jobs] Error: Invalid price range for weazelnews. minPrice: " .. tostring(minPrice) .. ", maxPrice: " .. tostring(maxPrice))
        end
    end
end)

lib.callback.register('esx_jobs/weazelnews/getMarketPrice', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    return randomSellPrice
end)

RegisterNetEvent('esx_jobs/weazelnews/endWorkWithPenalty', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local penaltyAmount = Config.Economy['weazelnews'].vehiclePenalty.amount
    local playerMoney = xPlayer.getAccount('money').money

    if playerMoney >= penaltyAmount then
        xPlayer.removeAccountMoney('money', penaltyAmount)
        xPlayer.showNotification('Zakończono pracę. Nałożono karę: ' .. penaltyAmount .. '$ za nieoddanie pojazdu.')
        sendLog(src, 'Gracz zakończył pracę bez oddania pojazdu. Nałożono karę: ' .. penaltyAmount .. '$')
    else
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy na pokrycie kary (' .. penaltyAmount .. '$).')
    end
end)