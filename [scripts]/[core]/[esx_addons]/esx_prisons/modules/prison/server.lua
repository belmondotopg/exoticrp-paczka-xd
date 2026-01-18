local Player = Player
local esx_core = exports.esx_core
local esx_hud = exports.esx_hud

Prisoners = {}
Breakouts = {}

ESX.RegisterCommand('unjail', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer then
        UnjailEvent(xPlayer.source, args.playerId.source)
        esx_core:SendLog(xPlayer.source, "Wiezienie", "Administrator "..xPlayer.source.." "..GetPlayerName(xPlayer.source).." nadał /unjail "..args.playerId.source, 'wiezienie-unjail')
	end
end, true, {help = 'Uwolnij gracza z więzienia', validate = true, arguments = {
	{name = 'playerId', help = 'ID gracza', type = 'player'},
}})

ESX.RegisterCommand('jail', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' }, function(xPlayer, args, showError)
	if xPlayer and (not args.playerId) then return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!') end

	if xPlayer then
        JailEvent(xPlayer.source, args.playerId.source,args.time)
        esx_core:SendLog(xPlayer.source, "Wiezienie", "Administrator "..xPlayer.source.." "..GetPlayerName(xPlayer.source).." nadał /jail "..args.playerId.source, 'wiezienie-jail')
	end
end, true, {help = 'Uwolnij gracza z więzienia', validate = true, arguments = {
	{name = 'playerId', help = 'ID gracza', type = 'player'},
    {name = "time",help = "czas",type="number"}
}})

function CheckRequired(source, required)
    if not required or #required < 1 then return true end
    local success = true
    local missingItems = {}
    for i=1, #required do 
        local part = required[i]
        if (not part.type or part.type == "item") then
            local remaining = Inventory.GetItemCount(source, part.name) - (part.amount)
            if remaining < 0 then 
                success = false
                missingItems[#missingItems + 1] = {index = i, name = part.name, count = remaining * -1}
            end
        elseif (part.type == "cash") then
            local remaining = GetMoney(source) - part.amount
            if remaining < 0 then 
                success = false
                missingItems[#missingItems + 1] = {index = i, name = "cash", count = remaining * -1}
            end
        elseif (part.type == "weapon" and not Inventory.HasWeapon(source, part.name)) then
            success = false
            missingItems[#missingItems + 1] = {index = i, name = part.name, count = 1}
        end
    end
    return success, missingItems
end

function TakeRequired(source, required)
    if not required or #required < 1 then return true end
    for i=1, #required do 
        local part = required[i]
        if (not part.type or part.type == "item") then
            Inventory.RemoveItem(source, part.name, part.amount)
        elseif (part.type == "cash") then
            RemoveMoney(source, part.amount)
        elseif (part.type == "weapon" and not Inventory.HasWeapon(source, part.name)) then
            Inventory.RemoveWeapon(source, part.name, 1)
        end
    end
end

function TakeInventory(source)
    local inventory = {}
    local data = Inventory.GetInventory(source)
    for i=1, #data do 
        inventory[#inventory + 1] = data[i]
        Inventory.RemoveItem(source, data[i].name, data[i].count)
    end
    return inventory
end

function JailPlayer(source, time, index, noSave)
    if Prisoners[source] then return end
    local index = index or "default"
    local prison = Config.Prisons[index]
    if not time or not prison then return end
    local identifier = GetIdentifier(source)
    Prisoners[source] = {
        identifier = identifier,
        index = index,
        time = time,
        sentence_date = os.time(),
    }
    SetPlayerMetadata(source, "IsJailed", time)
    Player(source).state.IsJailed = time
    TriggerClientEvent("esx_prisons:jailPlayer", source, Prisoners[source])
    if noSave then return end
    MySQL.Async.execute("DELETE FROM esx_prisons WHERE identifier=@identifier;", {["@identifier"] = identifier})
    MySQL.Async.execute("INSERT INTO esx_prisons (identifier, prison, time, inventory, sentence_date) VALUES (@identifier, @prison, @time, @inventory, @sentence_date);", {
        ["@identifier"] = Prisoners[source].identifier,
        ["@prison"] = Prisoners[source].index,
        ["@time"] = Prisoners[source].time,
        ["@inventory"] = json.encode(Prisoners[source].inventory),
        ["@sentence_date"] = Prisoners[source].sentence_date,
    })
    MySQL.Async.execute("INSERT INTO esx_prisons_list (identifier, addDate) VALUES (@identifier, @addDate);", {
        ["@identifier"] = Prisoners[source].identifier,
        ["@addDate"] = os.time(),
    })
end

function UnjailPlayer(source, breakout)
    local data = Prisoners[source]
    if not data then return end
    Prisoners[source] = nil
    local identifier = GetIdentifier(source)
    MySQL.Async.execute("DELETE FROM esx_prisons WHERE identifier=?;", {identifier})
    SetPlayerMetadata(source, "IsJailed", 0)
    Player(source).state.IsJailed = 0
    StopActivity(source)

    if breakout then return end

    esx_core:SendLog(source, "Wiezienie", "Gracz " .. GetPlayerName(source) .. " wyszedł z więzienia stanowego po upływie wyroku", 'wiezienie')
    TriggerClientEvent("esx_prisons:unjailPlayer", source, data)
end

function UpdatePrisonTime(source, time)
    local identifier = GetIdentifier(source)
    MySQL.Async.execute("UPDATE esx_prisons SET time=? WHERE identifier=?", {time, identifier})
end

RegisterCallback("esx_prisons:canBreakout", function(source, cb, index)
    if Breakouts[index] then return cb(false) end
    local required = Config.Breakout.required
    local success, missingItems = CheckRequired(source, required)
    if not success then 
        for i=1, #missingItems do 
            ShowNotification(source, _L("missing_item", missingItems[i].label, missingItems[i].count))
        end
        return cb(false)
    end
    cb(true)
end)

RegisterCallback("esx_prisons:enterBreakoutPoint", function(source, cb, index, name)
    if name == "enter" and not Breakouts[index] then 
        cb(false)
    else
        cb(true)
    end
end)

RegisterNetEvent("esx_prisons:startBreakout", function(index)
    local source = source
    if Breakouts[index] then return end
    local required = Config.Breakout.required
    local success, missingItems = CheckRequired(source, required)
    if not success then 
        for i=1, #missingItems do 
            ShowNotification(source, _L("missing_item", missingItems[i].label, missingItems[i].count))
        end
        return
    end
    TakeRequired(source, required)
    Breakouts[index] = {}
    TriggerClientEvent("esx_prisons:startBreakout", -1, index)
    if Config.Breakout.alert then 
        StartSiren(index, Config.Breakout.time)
    end
    SetTimeout(1000 * Config.Breakout.time, function()
        if Config.Breakout.alert then 
            StopSiren(index, Config.Breakout.time)
        end
        Breakouts[index] = nil
        TriggerClientEvent("esx_prisons:stopBreakout", -1, index)
    end)
end)

RegisterNetEvent("esx_prisons:initializePlayer", function()
    local source = source
    local identifier = GetIdentifier(source)
    MySQL.Async.fetchAll("SELECT * FROM esx_prisons WHERE identifier = ?;", {identifier}, function(results) 
        local result = results[1]
        if result then 
            local time = result.time
            if Config.ServeTimeOffline then
                time = (os.time() - result.sentence_date)
            end
            Prisoners[source] = {
                identifier = result.identifier,
                index = result.prison,
                time = time,
                sentence_date = result.sentence_date,
            } 
            if time <= 0 then 
                return UnjailPlayer(source)
            end  
            SetPlayerMetadata(source, "IsJailed", time)
            Player(source).state.IsJailed = time
            TriggerClientEvent("esx_prisons:jailPlayer", source, Prisoners[source])
        end
    end)
    UpdateLootables(source)
    TriggerClientEvent("esx_prisons:setupInventory", source, {items = Inventory.Items})
end)

RegisterNetEvent("esx_prisons:breakout", function()
    local source = source
    UnjailPlayer(source, true)
    ShowNotification(source, _L("breakout_self"))
end)

AddEventHandler("playerDropped", function()
    local source = source
    if not Prisoners[source] then return end
    UpdatePrisonTime(source, Prisoners[source].time)
    Prisoners[source] = nil
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for source,v in pairs(Prisoners) do 
        UpdatePrisonTime(source, v.time)
    end
end)

function JailEvent(source, target, time, index)
    if not target or target < 1 then return end 
    if not GetPlayerName(target) then return end

    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    local targetCoords = GetEntityCoords(GetPlayerPed(target))
    local distance = #(sourceCoords - targetCoords)
    
    if distance > 4.0 then
        ShowNotification(source, "Zbyt duża odległość od osoby którą chcesz wysłać do więzienia!")
        return
    end

    local prisoner = Prisoners[target]
    if prisoner then 
        local prison = Config.Prisons[prisoner.index]
        return ShowNotification(source, _L("in_prison", target, prisoner.time, prison.label))
    else
        local index = index or "default"
        local prison = Config.Prisons[index]
        if not prison then return end
        local permissions = prison.permissions or Config.Default.permissions 
        if not CheckPermission(source, permissions.jail) then 
            ShowNotification(source, _L("no_permission"))
        else
            ShowNotification(source, _L("in_prison", target, time, prison.label))
            JailPlayer(target, time, index)
            esx_core:SendLog(source, "Wiezienie", "Gracz " .. GetPlayerName(source) .. " wysłał do więzienia stanowego gracza " .. GetPlayerName(target) .. " na czas ".. time .. " sekund [".. (time / 60) .. " minut]", 'wiezienie')
        end
    end
end

function StartSiren(index, time)
    local xPlayers = esx_hud:Players()
    
    for k,v in pairs(xPlayers) do
        if v.job == 'police' or v.job == 'sheriff' then
            TriggerClientEvent('qf_mdt:addDispatchAlert', v.id, vec3(1684.1676, 2580.1064, 45.5648), 'Zakład karny Bolingbroke', 'Zgłoszono ucieczkę z więzienia, prosimy o wsparcie jednostek!', '10-62', 'rgb(0, 252, 17)', '10', 176, 3, 6)
        end
    end

    TriggerClientEvent("esx_prisons:startSiren", -1, index)

    if time then 
        SetTimeout(time * 1000, function()
            StopSiren(index)
        end)
    end
end

function StopSiren(index)
    local xPlayers = esx_hud:Players()
    
    for k,v in pairs(xPlayers) do
        if v.job == 'police' or v.job == 'sheriff' then
            TriggerClientEvent('qf_mdt:addDispatchAlert', v.id, vec3(1684.1676, 2580.1064, 45.5648), 'Zakład karny Bolingbroke', 'Alarm został wyłączony, poszukujemy zbiegów!', '10-62', 'rgb(0, 252, 17)', '10', 176, 3, 6)
        end
    end

    TriggerClientEvent("esx_prisons:stopSiren", -1, index)
end

-- RegisterCommand("jailstatus", function(source, args, raw)
--     local target = tonumber(args[1]) or source
--     local prisoner = Prisoners[target]
--     if not prisoner then 
--         return ShowNotification(source, _L("not_prison", target))
--     else
--         local prison = Config.Prisons[prisoner.index]
--         return ShowNotification(source, _L("in_prison", target, prisoner.time,  prison.label))
--     end
-- end)

-- RegisterCommand("startsiren", function(source, args, raw)
--     local index = args[1]
--     if not index or not Config.Prisons[index] then return end
--     local prison = Config.Prisons[index]
--     local permissions = prison.permissions or Config.Default.permissions
--     if not CheckPermission(source, permissions.alert) then 
--         ShowNotification(source, _L("no_permission"))
--     else
--         StartSiren(index)
--     end
-- end)

-- RegisterCommand("stopsiren", function(source, args, raw)
--     local index = args[1]
--     if not index or not Config.Prisons[index] then return end
--     local prison = Config.Prisons[index]
--     local permissions = prison.permissions or Config.Default.permissions
--     if not CheckPermission(source, permissions.alert) then 
--         ShowNotification(source, _L("no_permission"))
--     else
--         StopSiren(index)
--     end
-- end)

function PrisonTimer()
    for source,v in pairs(Prisoners) do
        Prisoners[source].time = Prisoners[source].time - 1
        if Prisoners[source].time <= 0 then
            UnjailPlayer(source)
        else
            Player(source).state.IsJailed = Prisoners[source].time
        end
    end

    SetTimeout(60000 * 1, PrisonTimer)
end

AddEventHandler('playerDropped', function()
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
        for source,v in pairs(Prisoners) do
            if Prisoners[source].time > 0 then
                SetPlayerMetadata(source, "IsJailed", Prisoners[source].time)
            end
        end
	end
end)

CreateThread(function()
    PrisonTimer()
end)

function UnjailEvent(source, target)
    if not target or target < 1 then return end 
    local prisoner = Prisoners[target]
    if not prisoner then 
        return ShowNotification(source, _L("not_prison", target))
    else
        local index = prisoner.index
        local prison = Config.Prisons[index]
        local permissions = prison.permissions or Config.Default.permissions
        if not CheckPermission(source, permissions.unjail) then
            ShowNotification(source, _L("no_permission"))
        else
            UnjailPlayer(target)
        end
    end
end

exports('JailPlayer', JailEvent)
