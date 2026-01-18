local cooldowns = {}
local unlockedSafes = {}
local powerRestoreTimers = {}
local globalCooldown = false
local activeHeist = false

lib.callback.register('vwk/safes/removeItem', function(source, item, amount)
    return exports.ox_inventory:RemoveItem(source, item, amount)
end)

lib.callback.register('vwk/safes/checkItem', function(source, item, amount)
    local count = exports.ox_inventory:Search(source, 'count', item)
    return count >= amount
end)

RegisterNetEvent("vwk/safes/powerCut", function(safeData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not safeData or not safeData.coords then return end

    -- Sprawdzenie liczby policjantów
    if GlobalState.Counter['police'] < Config.MinCops then
        TriggerClientEvent("esx:showNotification", src, ('Minimalnie musi być %d policjantów, aby włamać się do sejfu!'):format(Config.MinCops), 'error')
        return
    end

    if activeHeist then
        TriggerClientEvent("esx:showNotification", src, "Trwa już inny napad! Poczekaj aż się zakończy.", 'error')
        return
    end

    if globalCooldown then
        TriggerClientEvent("esx:showNotification", src, "Globalny cooldown aktywny! Poczekaj chwilę.", 'error')
        return
    end

    local targetCoords = xPlayer.getCoords(true)
    local powerCoords = vector3(safeData.powerCoords.x, safeData.powerCoords.y, safeData.powerCoords.z)

    if #(powerCoords - targetCoords) >= 1.5 then
        return
    end
    
    local safeCoords = vector3(safeData.coords.x, safeData.coords.y, safeData.coords.z)
    local safeKey = safeCoords.x .. '_' .. safeCoords.y

    if unlockedSafes[safeKey] then
        return
    end
    
    activeHeist = true
    unlockedSafes[safeKey] = {
        unlocked = true,
        playerId = src
    }
    TriggerClientEvent('vwk/safes/addSafe', -1, safeData)
    
    powerRestoreTimers[safeKey] = nil
    
    CreateThread(function()
        powerRestoreTimers[safeKey] = true
        Wait(900000)
        
        if powerRestoreTimers[safeKey] and unlockedSafes[safeKey] then
            local heistData = unlockedSafes[safeKey]
            local playerId = type(heistData) == "table" and heistData.playerId or nil
            
            unlockedSafes[safeKey] = nil
            powerRestoreTimers[safeKey] = nil
            activeHeist = false
            
            TriggerClientEvent('vwk/safes/removeSafe', -1, safeData.coords)
            TriggerClientEvent('vwk/safes/restorePower', -1, safeData)
            
            if playerId then
                TriggerClientEvent('vwk/safes/restorePlayerPower', playerId, safeData)
            end
            
            functions.startGlobalCooldown(Config.GlobalSafes.globalCooldown)
        end
    end)
end)

lib.callback.register('vwk/safes/getUnlockedSafes', function(source)
    local result = {}
    for k, v in pairs(unlockedSafes) do
        if (type(v) == "table" and v.unlocked) or v == true then
            result[k] = true
        end
    end
    return result
end)

RegisterNetEvent("vwk/safes/openSafe", function(safe)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not safe or not safe.coords then return end
    if not Player(src).state.isRobbing then
        print("Player " .. src .. " tried to open safe without robbing state.")
        return
    end

    local playerCoords = xPlayer.getCoords(true)
    local clientSafeCoords = vector3(safe.coords.x, safe.coords.y, safe.coords.z)
    local matchedSafe = nil

    for _, data in pairs(Config.Safes) do
        local globalCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
        if #(clientSafeCoords - globalCoords) < 1.5 then
            matchedSafe = data
            break
        end
    end

    if not matchedSafe then
        return
    end

    local safeKey = clientSafeCoords.x .. '_' .. clientSafeCoords.y
    local heistData = unlockedSafes[safeKey]
    
    if not heistData or (type(heistData) == "table" and not heistData.unlocked) then
        return
    end

    local trueSafeCoords = vector3(matchedSafe.coords.x, matchedSafe.coords.y, matchedSafe.coords.z)
    if #(playerCoords - trueSafeCoords) > 10.0 then
        DropPlayer(src, "daj spokuj typie")
        return
    end

    powerRestoreTimers[safeKey] = nil
    activeHeist = false
    TriggerClientEvent('vwk/safes/removeSafe', -1, safe.coords)
    
    local playerId = type(heistData) == "table" and heistData.playerId or nil
    unlockedSafes[safeKey] = nil
    
    if playerId then
        TriggerClientEvent('vwk/safes/restorePlayerPower', playerId, matchedSafe)
    end
    
    functions.startGlobalCooldown(Config.GlobalSafes.failedHeistCooldown)

    for _, drop in pairs(Config.GlobalSafes.addondrops or {}) do
        if math.random(1, 100) <= drop.chance then
            if drop.item == "black_money" then
                local moneyAmount = drop.amount and math.random(drop.amount[1], drop.amount[2]) or 100
                xPlayer.addAccountMoney('black_money', moneyAmount)
                TriggerClientEvent("esx:showNotification", src, "Znalazłeś $" .. moneyAmount .. " brudnych pieniędzy!", 'success')
            elseif drop.item == "money" then
                local moneyAmount = drop.amount and math.random(drop.amount[1], drop.amount[2]) or 100
                xPlayer.addMoney(moneyAmount)
                TriggerClientEvent("esx:showNotification", src, "Znalazłeś $" .. moneyAmount .. " w gotówce!", 'success')
            else
                local amount = drop.amount and math.random(drop.amount[1], drop.amount[2]) or 1
                xPlayer.addInventoryItem(drop.item, amount)
                TriggerClientEvent("esx:showNotification", src, "Znalazłeś " .. drop.item .. (amount > 1 and " x" .. amount or ""), 'success')
            end
        end
    end

    local dropMoney = math.random(matchedSafe.drop[1], matchedSafe.drop[2])
    xPlayer.addAccountMoney('black_money', dropMoney)
    TriggerClientEvent("esx:showNotification", src, "Otrzymałeś $" .. dropMoney .. " z sejfu!", 'success')
end)

RegisterNetEvent("vwk/safes/notifyPolice", function(safe)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not safe or not safe.coords then return end

    local playerCoords = xPlayer.getCoords(true)
    local safeCoords = vector3(safe.coords.x, safe.coords.y, safe.coords.z)

    if #(playerCoords - safeCoords) > 10.0 then
        DropPlayer(src, "daj spokuj typie")
        return
    end

    if not Player(src).state.isRobbing then
        print("Player " .. src .. " tried to notify police without robbing state.")
        return
    end

    -- Powiadomienia TYLKO dla policji (LSPD i sheriff)
    local text = "Napad na sklep! Zgłoszono próbę włamania do sejfu!"
    local color = {r = 220, g = 20, b = 60, alpha = 255}
    
    local GetPlayers = exports.esx_hud:Players()
    if not GetPlayers then
        -- Fallback - użyj ESX.GetExtendedPlayers jeśli esx_hud nie działa
        local players = ESX.GetExtendedPlayers()
        for _, v in pairs(players) do
            if v.job.name == 'police' or v.job.name == 'sheriff' then
                -- Powiadomienie przez chat
                TriggerClientEvent('esx_chat:onCheckChatDisplay', v.source, text, src, color)
                -- Powiadomienie przez MDT
                TriggerClientEvent('qf_mdt/addDispatchAlert', v.source, safeCoords, 'Napad na sklep!', 'Zgłoszono próbę włamania do sejfu w sklepie! Wymagana natychmiastowa interwencja!', '10-90', 'rgb(220, 20, 60)', '10', 126, 3, 6)
            end
        end
    else
        for _, v in pairs(GetPlayers) do
            if v.job == 'police' or v.job == 'sheriff' then
                -- Powiadomienie przez chat
                TriggerClientEvent('esx_chat:onCheckChatDisplay', v.id, text, src, color)
                -- Powiadomienie przez MDT
                TriggerClientEvent('qf_mdt/addDispatchAlert', v.id, safeCoords, 'Napad na sklep!', 'Zgłoszono próbę włamania do sejfu w sklepie! Wymagana natychmiastowa interwencja!', '10-90', 'rgb(220, 20, 60)', '10', 126, 3, 6)
            end
        end
    end
end)

RegisterNetEvent("vwk/safes/cooldown", function(safeData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local targetCoords = xPlayer.getCoords(true)
    local powerCoords = vector3(safeData.powerCoords.x, safeData.powerCoords.y, safeData.powerCoords.z)

    if #(powerCoords - targetCoords) < 1.5 then
        local cooldownKey = powerCoords.x .. '_' .. powerCoords.y
        CreateThread(function()
            cooldowns[cooldownKey] = true
            Wait(Config.GlobalSafes.cooldown)
            cooldowns[cooldownKey] = false
        end)
    end
end)

lib.callback.register('vwk/safes/checkCooldown', function(source, powerCoords)
    local cooldownKey = powerCoords.x .. '_' .. powerCoords.y
    return cooldowns[cooldownKey] == true
end)

lib.callback.register('vwk/safes/canStartHeist', function(source)
    return not activeHeist and not globalCooldown
end)

functions.startGlobalCooldown = function(cooldownTime)
    cooldownTime = cooldownTime or Config.GlobalSafes.globalCooldown
    globalCooldown = true
    CreateThread(function()
        Wait(cooldownTime)
        globalCooldown = false
    end)
end

functions.findSafeByPlayer = function(playerId)
    for safeKey, heistData in pairs(unlockedSafes) do
        if type(heistData) == "table" and heistData.playerId == playerId then
            for _, safeData in pairs(Config.Safes) do
                local safeCoords = vector3(safeData.coords.x, safeData.coords.y, safeData.coords.z)
                local key = safeCoords.x .. '_' .. safeCoords.y
                if key == safeKey then
                    return safeData, safeKey
                end
            end
        end
    end
    return nil, nil
end

RegisterNetEvent("vwk/safes/cancelRobbing", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local safeData, safeKey = functions.findSafeByPlayer(src)
    if not safeData or not safeKey then
        return
    end
    
    powerRestoreTimers[safeKey] = nil
    activeHeist = false
    unlockedSafes[safeKey] = nil
    
    TriggerClientEvent('vwk/safes/removeSafe', -1, safeData.coords)
    TriggerClientEvent('vwk/safes/restorePower', -1, safeData)
    TriggerClientEvent('vwk/safes/restorePlayerPower', src, safeData)
    
    functions.startGlobalCooldown(Config.GlobalSafes.failedHeistCooldown)
end)
