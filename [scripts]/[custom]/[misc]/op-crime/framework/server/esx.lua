ESX = GetResourceState('es_extended') == 'started' and true or false

if not ESX then return end
Framework = exports["es_extended"]:getSharedObject()

Fr.usersTable = "users"
Fr.identificatorTable = "identifier"
Fr.Table = 'owned_vehicles'
Fr.VehProps = 'vehicle'
Fr.OwnerTable = "owner"
Fr.StoredTable = "stored"
Fr.PlayerLoaded = 'esx:playerLoaded'

Fr.VehiclePurchased = function(model, jobId, plate, mods)
    local readyModel = joaat(model)

    local query = [[
        INSERT INTO `owned_vehicles`
        (`owner`, `plate`, `vehicle`, `gang`, `configName`)
        VALUES (?, ?, ?, ?, ?)
    ]]

    local params
    if not mods then
        params = {
            "",
            plate,
            json.encode({ model = readyModel, plate = plate }),
            jobId,
            model
        }
    else
        params = {
            "",
            plate,
            mods,
            jobId,
            model
        }
    end

    MySQL.Async.insert(query, params, function(insertId)
        if not insertId then
            print(("[^1ERROR^7] Failed to insert vehicle with plate %s into owned_vehicles"):format(plate))
        else
            local insertInfo = ("[^2INFO^7] Inserted vehicle into owned_vehicles. ID: %s, Plate: %s"):format(insertId, plate)
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
    
    MySQL.scalar('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate},
    function(result)
        p:resolve(result ~= nil)
    end)

    return Citizen.Await(p)
end

Fr.IsPlayerDead = function(source)
    return Player(source).state.IsDead
end
Fr.RegisterServerCallback = function(...)
    return Framework.RegisterServerCallback(...)
end
Fr.GetPlayerFromIdentifier = function(identifier)
    return Framework.GetPlayerFromIdentifier(identifier)
end
Fr.getPlayerFromId = function(...)
    return Framework.GetPlayerFromId(...)
end
Fr.GetMoney = function(xPlayer, account)
    return xPlayer.getAccount(account).money
end
Fr.GetDirtyMoney = function(xPlayer)
    return xPlayer.getAccount("black_money").money
end
Fr.ManageMoney = function(xPlayer, account, action, amount)
    if action == "add" then
        return xPlayer.addAccountMoney(account, amount)
    else
        return xPlayer.removeAccountMoney(account, amount)
    end
end
Fr.ManageDirtyMoney = function(xPlayer, action, amount)
    if action == "add" then
        return xPlayer.addAccountMoney("black_money", amount)
    else
        return xPlayer.removeAccountMoney("black_money", amount)
    end
end
Fr.GetIndentifier = function(source)
    local xPlayer = Fr.getPlayerFromId(source)
    if not xPlayer then return nil end
    return xPlayer.identifier
end
Fr.GetPlayerName = function(sourceOrIdentifier)
    local xPlayer = Fr.getPlayerFromId(sourceOrIdentifier)
    local name

    if xPlayer then
        name = xPlayer.name
        if name == GetPlayerName(Fr.GetSourceFromPlayerObject(xPlayer)) then
            name = xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName')
        end
    else
        local result = MySQL.Sync.fetchAll(
            "SELECT firstname, lastname, identifier FROM users WHERE identifier = @identifier",
            {['@identifier'] = trim(sourceOrIdentifier)}
        )
        if result and result[1] then
            if result[1].firstname and result[1].lastname then
                name = result[1].firstname .. " " .. result[1].lastname
            else
                name = "Unknown"
            end
        else
            name = "Unknown"
        end
    end

    return name
end
Fr.GetGroup = function(source)
    local xPlayer = Fr.getPlayerFromId(source)
    return xPlayer.getGroup()
end
Fr.addItem = function(xPlayer, itemname, quantity, metadata)
    if Config.Inventory.inventoryScript == "ox_inventory" then
        exports.ox_inventory:AddItem(xPlayer.source, itemname, quantity, metadata or {})
    else 
        return xPlayer.addInventoryItem(itemname, quantity)
    end
end
Fr.removeItem = function(xPlayer, itemname, quantity)
    return xPlayer.removeInventoryItem(itemname, quantity)
end
Fr.getItem = function(xPlayer, itemname)
    local item = xPlayer.getInventoryItem(itemname)
    local table
    if item then
        table = {amount = item.count, name = itemname, weight = item.weight, label = item.label}
    else 
        table = {amount = 0, name = itemname, weight = 0, label = ""}
    end
    return table
end
Fr.getInventory = function(xPlayer)
    return xPlayer.getInventory()
end
Fr.getItemInfo = function(itemName) 
    return Framework.Items[itemName] 
end

Fr.RegisterItem = function(itemName, itemEvent)
    Framework.RegisterUsableItem(itemName, function(playerId)
        local xPlayer = Fr.getPlayerFromId(playerId)
        TriggerClientEvent('op-crime:'.. itemEvent, Fr.GetSourceFromPlayerObject(xPlayer))
    end)
end
Fr.GetSourceFromPlayerObject = function(xPlayer)
    if xPlayer then
        return xPlayer.source
    else
        return nil
    end
end