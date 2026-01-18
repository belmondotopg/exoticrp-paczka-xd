local esx_hud = exports.esx_hud

lib.callback.register('esx_drops/server/getMarketInfo', function()
    local row = MySQL.single.await('SELECT stock, next_restock FROM esx_drops LIMIT 1', {})
    local nextRestockStr = "Wkrótce"

    if row and row.next_restock then
        local nextTime = os.time({
            year  = tonumber(string.sub(row.next_restock,1,4)),
            month = tonumber(string.sub(row.next_restock,6,7)),
            day   = tonumber(string.sub(row.next_restock,9,10)),
            hour  = tonumber(string.sub(row.next_restock,12,13)),
            min   = tonumber(string.sub(row.next_restock,15,16)),
            sec   = tonumber(string.sub(row.next_restock,18,19))
        })
        if nextTime then
            nextRestockStr = os.date('%d.%m.%Y %H:%M', nextTime)
        end
    end

    return row.stock or 0, nextRestockStr
end)

local playersBuying = {}

local RESTOCK_AMOUNT = 10
local RESTOCK_INTERVAL_SECONDS = 172800
local PLAYER_FLARE_LIMIT_PER_DAY = 3

local function getToday()
    return os.date('%Y-%m-%d', os.time())
end

RegisterNetEvent('esx_drops/server/buyFlare', function()
    local src = source
    if playersBuying[src] then return end
    playersBuying[src] = true

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then playersBuying[src] = nil return end

    local identifier = xPlayer.identifier
    if not identifier then playersBuying[src] = nil return end
    local today = getToday()

    MySQL.single('SELECT stock FROM esx_drops WHERE id = 1', {}, function(row)
        local stock = row and row.stock or 0
        if stock <= 0 then
            xPlayer.showNotification("Brak flar w magazynie!")
            playersBuying[src] = nil
            return
        end

        MySQL.single('SELECT count FROM esx_drops_purchases WHERE identifier = ? AND date = ?', {identifier, today}, function(purchase)
            local boughtToday = purchase and purchase.count or 0
            if boughtToday >= PLAYER_FLARE_LIMIT_PER_DAY then
                xPlayer.showNotification("Osiągnięto dzienny limit: 3 flary na dobę!")
                playersBuying[src] = nil
                return
            end

            if not exports.ox_inventory:CanCarryItem(src, 'dropflare', 1) then
                xPlayer.showNotification("Nie możesz już nosić więcej tych przedmiotów!")
                playersBuying[src] = nil
                return
            end

            if boughtToday == 0 then
                MySQL.insert('INSERT INTO esx_drops_purchases (identifier, date, count) VALUES (?, ?, 1)', {identifier, today}, function()
                    MySQL.update('UPDATE esx_drops SET stock = stock - 1 WHERE id = 1 AND stock > 0', {}, function(affectedRows)
                        if affectedRows and affectedRows > 0 then
                            exports.ox_inventory:AddItem(src, 'dropflare', 1)
                            xPlayer.showNotification("Otrzymano nieoznakowaną flarę! (Limit dzienny: 1/3)")
                        end
                        playersBuying[src] = nil
                    end)
                end)
            else
                MySQL.update('UPDATE esx_drops_purchases SET count = count + 1 WHERE identifier = ? AND date = ? AND count < ?', {identifier, today, PLAYER_FLARE_LIMIT_PER_DAY}, function(affectedRows)
                    if affectedRows and affectedRows > 0 then
                        MySQL.update('UPDATE esx_drops SET stock = stock - 1 WHERE id = 1 AND stock > 0', {}, function(affectedRows2)
                            if affectedRows2 and affectedRows2 > 0 then
                                exports.ox_inventory:AddItem(src, 'dropflare', 1)
                                xPlayer.showNotification("Otrzymano nieoznakowaną flarę! (Limit dzienny: "..(boughtToday+1).."/3)")
                            end
                            playersBuying[src] = nil
                        end)
                    else
                        xPlayer.showNotification("Osiągnięto dzienny limit: 3 flary na dobę!")
                        playersBuying[src] = nil
                    end
                end)
            end
        end)
    end)
end)

local function restockFlares()
    MySQL.single('SELECT stock, next_restock FROM esx_drops WHERE id = 1', {}, function(row)
        local now = os.time()
        local nextRestockTime = 0
        if row and row.next_restock then
            nextRestockTime = os.time({
                year  = tonumber(string.sub(row.next_restock,1,4)),
                month = tonumber(string.sub(row.next_restock,6,7)),
                day   = tonumber(string.sub(row.next_restock,9,10)),
                hour  = tonumber(string.sub(row.next_restock,12,13)),
                min   = tonumber(string.sub(row.next_restock,15,16)),
                sec   = tonumber(string.sub(row.next_restock,18,19))
            }) or 0
        end

        if not row or row.stock == nil or now >= nextRestockTime then
            local nextTime = os.date('%Y-%m-%d %H:%M:%S', now + RESTOCK_INTERVAL_SECONDS)
            MySQL.update('UPDATE esx_drops SET stock = ?, next_restock = ? WHERE id = 1', {RESTOCK_AMOUNT, nextTime}, function()
                print('[esx_drops] Automatyczny restock flar na magazynie! Następny: '..nextTime)
            end)
        end
    end)
end

CreateThread(function()
    while true do
        restockFlares()
        Wait(600000)
    end
end)

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    restockFlares()
end)

local DropActive = false
local DropTimeout = 0
local DropID = nil
local DropTimer = nil
local activeDrops = {}

lib.callback.register('esx_drops:canUseFlare', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local now = os.time()
    if DropActive and (now < DropTimeout) then
        if xPlayer then
            xPlayer.showNotification("Nie możesz teraz użyć flary. Poczekaj aż obecna skrzynka zostanie otwarta lub minie czas blokady.")
        end
        return false
    end
    local cwelowyItemek = exports.ox_inventory:RemoveItem(source, 'dropflare', 1)
    return cwelowyItemek
end)

local function sendNotify(message)
    local Players = esx_hud:Players()

    for k, v in pairs(Players) do
        local cwlPlayer = ESX.GetPlayerFromId(v.id)
        local cwelowatyJob = exports['op-crime']:getPlayerOrganisation(cwlPlayer.identifier)
        if cwelowatyJob then
            ESX.GetPlayerFromId(v.id).showNotification(message)
        end
    end
end

RegisterNetEvent('esx_drops/server/broadcastDrop', function(id, coords, heading)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    DropActive = true
    DropTimeout = os.time() + 1800
    DropID = id

    sendNotify(('Organizacja %s zrzuciła zrzut! Udaj się na miejsce oznaczone na mapie i przejmij go.'):format(exports['op-crime']:getPlayerOrganisation(xPlayer.identifier).orgData.label or exports['op-crime']:getPlayerOrganisation(xPlayer.identifier).orgIndex))
    local openTimestamp = os.time() + 600
    TriggerClientEvent('esx_drops/client/spawnDrop', -1, id, coords, heading, openTimestamp)
    activeDrops[id] = {coords = coords, opened = {}}
    
    if DropTimer then TerminateThread(DropTimer) DropTimer = nil end

    DropTimer = CreateThread(function()
        Wait(1800000)
        TriggerEvent('esx_drops/server/clearDrop', id)
        TriggerClientEvent('esx_drops/client/clearDrop', -1)
    end)
end)

RegisterNetEvent('esx_drops/server/clearDrop', function(id)
    if DropActive and DropID == id then
        activeDrops[id] = nil
        DropActive = false
        DropTimeout = 0
        DropID = nil

        if DropTimer then DropTimer = nil end
        TriggerClientEvent('esx_drops/client/clearDrop', -1)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    
    activeDrops = {}
    DropActive = false
    DropTimeout = 0
    DropID = nil

    if DropTimer then DropTimer = nil end
    TriggerClientEvent('esx_drops/client/clearDrop', -1)
end)

local rewardTypes = {}

for k in pairs(Config.Rewards) do
    table.insert(rewardTypes, k)
end

lib.callback.register('esx_drops/server/getLootReward', function(src, id, pos)
    local drop = activeDrops[id]

    if not drop or not drop.coords or not pos then return false end
    if drop.opened[src] then return false end

    local dist = #(vector3(drop.coords.x, drop.coords.y, drop.coords.z) - vector3(pos.x, pos.y, pos.z))
    if dist > 3.0 then return false end

    drop.opened[src] = true
    
    local t = rewardTypes[math.random(1, #rewardTypes)]
    local reward = Config.Rewards[t]
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return false end

    if reward.items then
        for _, v in ipairs(reward.items) do
            xPlayer.addInventoryItem(v.name, v.count)
        end
    end

    if reward.money and reward.money > 0 then
        if reward.money_type == 'black_money' then
            xPlayer.addAccountMoney('black_money', reward.money)
        else
            xPlayer.addMoney(reward.money)
        end
    end

    return {
        type = t,
        items = reward.items,
        money = reward.money,
        money_type = reward.money_type
    }
end)