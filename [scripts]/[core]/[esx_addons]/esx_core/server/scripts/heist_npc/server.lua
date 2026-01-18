local ESX = ESX
local activeHeists = {}
local pendingHostageTokens = {}

AddEventHandler('playerDropped', function()
    local src = source
    activeHeists[src] = nil
    pendingHostageTokens[src] = nil
end)

ESX.RegisterUsableItem('karta_zakladnika', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local item = xPlayer.getInventoryItem('karta_zakladnika')
    if not item or item.count < 1 then
        xPlayer.showNotification('~r~Nie masz karty zakładnika!')
        return
    end
    
    local token = math.random(100000, 999999) .. '_' .. GetGameTimer()
    pendingHostageTokens[src] = {
        token = token,
        timestamp = GetGameTimer()
    }
    
    CreateThread(function()
        Wait(10000)
        if pendingHostageTokens[src] and pendingHostageTokens[src].token == token then
            pendingHostageTokens[src] = nil
        end
    end)
    
    TriggerClientEvent('esx_core:GetPlayerPositionForHostage', src, token)
end)

RegisterServerEvent('esx_core:CreateHostageAtPosition', function(coords, heading, token)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    if not coords or not coords.x or not coords.y or not coords.z then return end
    
    local pendingToken = pendingHostageTokens[src]
    if not pendingToken or not token or pendingToken.token ~= token then
        print(string.format('[ANTI-CHEAT] Gracz %s (%s) próbował stworzyć zakładnika bez użycia przedmiotu!', src, xPlayer.identifier))
        return
    end
    
    local timeDiff = GetGameTimer() - pendingToken.timestamp
    if timeDiff > 5000 then
        print(string.format('[ANTI-CHEAT] Gracz %s (%s) próbował użyć wygasłego tokenu!', src, xPlayer.identifier))
        pendingHostageTokens[src] = nil
        return
    end
    
    local item = xPlayer.getInventoryItem('karta_zakladnika')
    if not item or item.count < 1 then
        print(string.format('[ANTI-CHEAT] Gracz %s (%s) próbował stworzyć zakładnika bez przedmiotu!', src, xPlayer.identifier))
        pendingHostageTokens[src] = nil
        return
    end
    
    xPlayer.removeInventoryItem('karta_zakladnika', 1)
    
    pendingHostageTokens[src] = nil
    
    activeHeists[src] = true
    
    local spawnCoords = {
        coords.x,
        coords.y,
        coords.z,
        heading or 0.0
    }
    
    TriggerClientEvent('esx_core:SetNPC', src, src, 1, spawnCoords, false)
    
    xPlayer.showNotification('~g~Użyłeś karty zakładnika! Zakładnik pojawił się w tym miejscu.')
end)

RegisterServerEvent('esx:core:npc:get', function(npcs)
    local src = source
    if not activeHeists[src] then return end
    
    activeHeists[src] = nil
    TriggerClientEvent('esx_core:setNPCtarget', -1, npcs)

    CreateThread(function()
        Wait(15 * 60 * 1000)
        for _, npcId in ipairs(npcs) do
            local ped = NetworkGetEntityFromNetworkId(npcId)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end)
end)

RegisterServerEvent('esx_core:uncuffHostage', function(npc)
    if not npc then return end
    
    local entity = NetworkGetEntityFromNetworkId(npc)
    if not DoesEntityExist(entity) then return end
    
    FreezeEntityPosition(entity, false)
    ClearPedTasks(entity)
    TaskGoStraightToCoord(entity, 0, 0, 0, 1.0, 1500, 0.0, 0.0)
    
    CreateThread(function()
        Wait(1500)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end)
end)