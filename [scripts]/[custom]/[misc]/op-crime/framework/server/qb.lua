QBCore = GetResourceState('qb-core') == 'started' and true or false
local tryQBox = GetResourceState('qbx_core') == 'started' and true or false

if not QBCore then return end
if tryQBox then return end 

Framework = exports['qb-core']:GetCoreObject()

if ServerConfig.EnableQBgangsIntegrations then
    RegisterNetEvent('QBCore:Server:OnGangUpdate', function(id, data)
        local Player = Framework.Functions.GetPlayer(tonumber(id))
        if Player then
            Player.Functions.SetGang(tostring(data.name), tonumber(data.grade.level))
        else
            print('[ERROR] Unable to update player gang. Specified player is offline:', id)
        end
    end)
end

Fr.usersTable = "players"
Fr.identificatorTable = "citizenid"
Fr.Table = 'player_vehicles'
Fr.VehProps = 'mods'
Fr.OwnerTable = "citizenid"
Fr.StoredTable = 'state'
Fr.PlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
Fr.IsPlayerDead = function(source)
    local Player = Fr.getPlayerFromId(source)
    return Player.PlayerData.metadata["isdead"]
end

Fr.VehiclePurchased = function(model, jobId, plate, mods)
    local readyModel = joaat(model)
    local insertQuery = [[
        INSERT INTO `player_vehicles`
        (`license`, `vehicle`, `hash`, `citizenid`, `plate`, `mods`, `gang`, `configName`)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]]

    local params
    if not mods then
        params = {
            "", model, readyModel, nil, plate,
            json.encode({model = readyModel, plate = plate}),
            jobId, model
        }
    else
        params = {
            "", model, readyModel, nil, plate,
            mods, jobId, model
        }
    end

    MySQL.Async.insert(insertQuery, params, function(insertId)
        if not insertId then
            print(("[^1ERROR^7] Vehicle insert failed for plate %s"):format(plate))
        else
            local insertInfo = ("[^2INFO^7] Vehicle inserted with ID: %s, plate: %s"):format(insertId, plate)
            if mods then 
                print(insertInfo)
            else
                debugPrint(insertInfo)
            end
        end
    end)
end

Fr.UpdateVehicleState = function(plate, state, networkId)
    MySQL.Async.execute('UPDATE `'.. Fr.Table ..'` SET `'.. Fr.StoredTable ..'` = @state, vehicleid = @networkid WHERE plate = @plate',
    {['@plate'] = plate, ['@networkid'] = networkId, ['@state'] = state})
end

Fr.IsPlateTaken = function(plate)
    local p = promise.new()
    
    MySQL.scalar('SELECT plate FROM player_vehicles WHERE plate = ?', {plate},
    function(result)
        p:resolve(result ~= nil)
    end)

    return Citizen.Await(p)
end

Fr.RegisterServerCallback = function(...)
    return Framework.Functions.CreateCallback(...)
end
Fr.GetPlayerFromIdentifier = function(identifier)
    return Framework.Functions.GetPlayerByCitizenId(identifier)
end
Fr.getPlayerFromId = function(...)
    return Framework.Functions.GetPlayer(...)
end
Fr.GetMoney = function(Player, account)
    if account == "money" then account = "cash" end
    return Player.PlayerData.money[account]
end
Fr.GetDirtyMoney = function(Player)
    local blackMoney = Player.Functions.GetItemByName(Config.DirtyMoney.itemName)
    return blackMoney and blackMoney.amount or 0
end
Fr.ManageMoney = function(Player, account, action, amount)
    if account == "money" then account = "cash" end
    if action == "add" then
        return Player.Functions.AddMoney(account, amount)
    else
        return Player.Functions.RemoveMoney(account, amount)
    end
end
Fr.ManageDirtyMoney = function(Player, action, amount)
    if action == "add" then
        return Player.Functions.AddItem(Config.DirtyMoney.itemName, amount)
    else
        return Player.Functions.RemoveItem(Config.DirtyMoney.itemName, amount)
    end
end
Fr.GetIndentifier = function(source)
    local xPlayer = Fr.getPlayerFromId(source)
    if not xPlayer then return nil end
    return xPlayer.PlayerData.citizenid
end
Fr.GetPlayerName = function(sourceOrIdentifier)
    local xPlayer = Fr.getPlayerFromId(sourceOrIdentifier)
    local name

    if xPlayer then
        name = xPlayer.PlayerData.charinfo.firstname .." ".. xPlayer.PlayerData.charinfo.lastname
    else
        local result = MySQL.Sync.fetchAll(
            "SELECT charinfo FROM players WHERE citizenid = @citizenid",
            {['@citizenid'] = trim(sourceOrIdentifier)}
        )
        if result and result[1] then
            result[1].charinfo = json.decode(result[1].charinfo)
            name = result[1].charinfo.firstname .. " " .. result[1].charinfo.lastname
        else
            name = "Unknown"
        end
    end

    return name
end
Fr.GetGroup = function(source)
    return "Admin"
end
Fr.addItem = function(xPlayer, itemname, quantity)
    return xPlayer.Functions.AddItem(itemname, quantity)
end
Fr.removeItem = function(xPlayer, itemname, quantity)
    return xPlayer.Functions.RemoveItem(itemname, quantity)
end
Fr.getItem = function(xPlayer, itemname)
    local item = xPlayer.Functions.GetItemByName(itemname)
    local table
    if item then
        table = {amount = item.amount, name = itemname, weight = item.weight, label = item.label}
    else 
        table = {amount = 0, name = itemname, weight = 0, label = ""}
    end
    return table
end
Fr.getInventory = function(xPlayer)
    return xPlayer.PlayerData.items
end
Fr.getItemInfo = function(itemName) 
    return Framework.Shared.Items[itemName]
end
Fr.RegisterItem = function(itemName, itemEvent)
    Framework.Functions.CreateUseableItem(itemName, function(source, item)
        local Player = Fr.getPlayerFromId(source)
        if not Player.Functions.GetItemByName(item.name) then return end
        TriggerClientEvent('op-crime:'.. itemEvent, Fr.GetSourceFromPlayerObject(Player))
    end)
end
Fr.GetSourceFromPlayerObject = function(xPlayer)
    if xPlayer then
        return xPlayer.PlayerData.source
    else
        return nil
    end
end