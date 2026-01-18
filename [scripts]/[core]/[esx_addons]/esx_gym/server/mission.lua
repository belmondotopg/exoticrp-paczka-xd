local currentDelivery = nil
local lastDeliveryEnd = 0

local cooldownMs = 1800000
local maxDurationMs = 3600000
local reminderPoints = { 600000, 300000, 60000 }

local function now()
    return GetGameTimer()
end

local function playerOnline(id)
    return GetPlayerName(id) ~= nil
end

lib.callback.register('esx_gym/server/mission/canStartDelivery', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local t = now()

    if currentDelivery and not playerOnline(currentDelivery) then
        currentDelivery = nil
    end

    if currentDelivery ~= nil then
        return false
    end

    if lastDeliveryEnd > 0 and (t - lastDeliveryEnd) < cooldownMs then
        return false
    end

    currentDelivery = source
    local startedAt = t
    local reminded = {}

    for _, ms in ipairs(reminderPoints) do
        reminded[ms] = false
    end

    CreateThread(function()
        while currentDelivery == source do
            local elapsed = now() - startedAt
            local remaining = maxDurationMs - elapsed

            for _, ms in ipairs(reminderPoints) do
                if not reminded[ms] and remaining <= ms and remaining > 0 then
                    local minutes = math.max(1, math.floor(ms / 60000))
                    xPlayer.showNotification(('Twoja dostawa zakończy się za %d min.'):format(minutes))
                    reminded[ms] = true
                end
            end

            if remaining <= 0 then
                if currentDelivery and GetPlayerName(currentDelivery) then
                    TriggerClientEvent('esx_gym/mission/abortMission', currentDelivery)
                end
                currentDelivery = nil
                lastDeliveryEnd = now()
                break
            end

            Wait(5000)
        end
    end)

    return true
end)

RegisterServerEvent('esx_gym/server/mission/resetDelivery', function()
    if source == currentDelivery then
        currentDelivery = nil
        lastDeliveryEnd = now()
    end
end)

AddEventHandler('playerDropped', function()
    if source == currentDelivery then
        currentDelivery = nil
        lastDeliveryEnd = now()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        if currentDelivery and GetPlayerName(currentDelivery) then
            TriggerClientEvent('esx_gym/mission/abortMission', currentDelivery)
        end
        currentDelivery = nil
        lastDeliveryEnd = now()
    end
end)

RegisterServerEvent('esx_gym/server/mission/suppliesDelivered', function (name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local maxStock = Config.MaxStockPerItem or 200
    local newSupplies = {
        kreatyna = maxStock,
        l_karnityna = maxStock,
        bialko = maxStock,
    }

    local result = MySQL.query.await('UPDATE `gym_companies` SET `stock` = ? WHERE `name` = ?', { json.encode(newSupplies), name })

    if result then
        xPlayer.showNotification('Dostawa zakończona! Zapasy uzupełnione do ' .. maxStock .. ' szt. każdego suplementu.')
    end
end)
