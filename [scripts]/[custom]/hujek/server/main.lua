local server = {}

server.cooldowns = {}
server.activeMissions = {}
server.blockedMissions = {}
server.dropStr = {}

server.playerDropped = function(source)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)


    if server.activeMissions[tostring(xPlayer.uid)] then
        local missionId = server.activeMissions[tostring(xPlayer.uid)]
        server.blockedMissions[tostring(missionId)] = nil

        local droppedItems = {}

        for itemName, quantity in pairs(server.dropStr[tostring(xPlayer.uid)]) do
            droppedItems[#droppedItems + 1] = itemName .. " x" .. quantity
        end

        -- ESX.DiscordLogFields("treasure", "Misja anulowana przez wyrzucenie z serwera", "pink", {
        --     {name = "Player", value = GetPlayerName(xPlayer.source) .. ' | ' .. xPlayer.getIdentifier() .. ' (' .. xPlayer.source .. ' #' .. xPlayer.uid.. ' )', inline = false},
        --     {name = "Dropped Items", value = table.concat(droppedItems, ", ") or "Brak", inline = false}
        -- })

        server.activeMissions[tostring(xPlayer.uid)] = nil
        server.dropStr[tostring(xPlayer.uid)] = nil
        server.cooldowns[tostring(xPlayer.uid)] = os.time() + 60 * 1000 * 60
    end
end

server.getRandomMissionIndex = function()
    local availableMissions = {}

    for id, mission in pairs(Config.Missions) do
        if not server.blockedMissions[id] then
            availableMissions[#availableMissions + 1] = id
        end
    end

    if #availableMissions > 0 then
        local randomIndex = math.random(1, #availableMissions)
        local selectedMissionId = availableMissions[randomIndex]

        if server.blockedMissions[tostring(selectedMissionId)] then
            return server.getRandomMissionIndex()
        end
        
        server.blockedMissions[tostring(selectedMissionId)] = true
        return selectedMissionId
    end
end

server.takeMission = function(source, cb)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if server.cooldowns[tostring(xPlayer.uid)] and server.cooldowns[tostring(xPlayer.uid)] > os.time() then
        cb(false, nil)
        return xPlayer.showNotification("Przeiceż niedawno robiłeś zlecenie. Nie mam dla ciebie nic nowego. Przyjdź pożniej to może coś się znajdzie")
    end

    if #server.blockedMissions == #Config.Missions then
        cb(false, nil)
        return xPlayer.showNotification("Nie mam narazie żadnego wolnego zlecenia. Przyjdź później to może coś się znajdzie.")
    end

    local randomMissionId = server.getRandomMissionIndex()
    server.activeMissions[tostring(xPlayer.uid)] = randomMissionId
    if server.dropStr[tostring(xPlayer.uid)] == nil then
        server.dropStr[tostring(xPlayer.uid)] = {}
    end
    cb(true, Config.Missions[randomMissionId])
end

server.cancelMission = function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not server.activeMissions[tostring(xPlayer.uid)] then
        return
    end

    local missionId = server.activeMissions[tostring(xPlayer.uid)]
    server.blockedMissions[tostring(missionId)] = nil

    local droppedItems = {}

    for itemName, quantity in pairs(server.dropStr[tostring(xPlayer.uid)]) do
        droppedItems[#droppedItems + 1] = itemName .. " x" .. quantity
    end

    -- ESX.DiscordLogFields("treasure", "Misja anulowana", "pink", {
    --     {name = "Player", value = GetPlayerName(xPlayer.source) .. ' | ' .. xPlayer.getIdentifier() .. ' (' .. xPlayer.source .. ' #' .. xPlayer.uid.. ' )', inline = false},
    --     {name = "Dropped Items", value = table.concat(droppedItems, ", ") or "Brak", inline = false}
    -- })

    server.activeMissions[tostring(xPlayer.uid)] = nil
    server.dropStr[tostring(xPlayer.uid)] = nil
    server.cooldowns[tostring(xPlayer.uid)] = os.time() + 60 * 1000 * 60
end

server.finishMission = function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not server.activeMissions[tostring(xPlayer.uid)] then
        return
    end

    local missionId = server.activeMissions[tostring(xPlayer.uid)]
    server.blockedMissions[tostring(missionId)] = nil

    local droppedItems = {}

    for itemName, quantity in pairs(server.dropStr[tostring(xPlayer.uid)]) do
        droppedItems[#droppedItems + 1] = itemName .. " x" .. quantity
    end

    server.activeMissions[tostring(xPlayer.uid)] = nil
    server.cooldowns[tostring(xPlayer.uid)] = os.time() + 60 * 1000 * 60

    xPlayer.addInventoryItem("golden_key", 1)

    -- ESX.DiscordLogFields("treasure", "Misja zakończona powodzeniem", "pink", {
    --     {name = "Player", value = GetPlayerName(xPlayer.source) .. ' | ' .. xPlayer.getIdentifier() .. ' (' .. xPlayer.source .. ' #' .. xPlayer.uid.. ' )', inline = false},
    --     {name = "Dropped Items", value = table.concat(droppedItems, ", ") or "Brak", inline = false}
    -- })

    server.dropStr[tostring(xPlayer.uid)] = nil
end

server.openChest = function(chestType)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not server.activeMissions[tostring(xPlayer.uid)] then
        return
    end
    
    local loot = Config.Chests[chestType].Items
    local awardedItems = {}

    for itemName, itemData in pairs(loot) do
        local roll = math.random(0, 10000) / 100

        if roll <= itemData.chance then
            local quantity = math.random(itemData.quantity[1], itemData.quantity[2])
            awardedItems[itemName] = quantity
        end
    end

    for itemName, quantity in pairs(awardedItems) do
        xPlayer.addInventoryItem(itemName, quantity)

        if server.dropStr[tostring(xPlayer.uid)][itemName] then
            server.dropStr[tostring(xPlayer.uid)][itemName] = server.dropStr[tostring(xPlayer.uid)][itemName] + quantity
        else
            server.dropStr[tostring(xPlayer.uid)][itemName] = quantity
        end
    end
end

ESX.RegisterUsableItem("scuba_gear", function(source)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.removeInventoryItem("scuba_gear", 1)
    TriggerClientEvent("fiveplay-treasure/events/useScubaGear", source)
end)

AddEventHandler('esx:playerDropped', server.playerDropped)
RegisterNetEvent("fiveplay-treasure/events/finishMission", server.finishMission)
RegisterNetEvent("fiveplay-treasure/events/openChest", server.openChest)
RegisterNetEvent("fiveplay-treasure/events/cancelMission", server.cancelMission)
ESX.RegisterServerCallback("fiveplay-treasure/cb/takeMission", server.takeMission)