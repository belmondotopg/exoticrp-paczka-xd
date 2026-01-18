local vehiclesOnDisplay = {}

local MIN_PRICE = 10000
local MAX_PRICE = 999999999
local CLEANUP_INTERVAL = 30 * 60 * 1000
local LOAD_RETRY_ATTEMPTS = 10
local LOAD_RETRY_DELAY = 1000
local REQUEST_RATE_LIMIT = 2000 -- Minimum time between requests in ms
local pendingRequests = {} -- Track pending requests per player

local function parseVehicleProps(vehicleData)
    if type(vehicleData) == "string" then
        local success, decoded = pcall(json.decode, vehicleData)
        if success and type(decoded) == "table" then
            return decoded
        end
    elseif type(vehicleData) == "table" then
        return vehicleData
    end
    return {}
end

local function normalizeVehicleModel(model)
    if type(model) == "number" then
        return tostring(model)
    end
    return model
end

local function getPlayerPaymentAmount(xPlayer, paymentMethod)
    if paymentMethod == "cash" then
        return xPlayer.getMoney(), "gotówka"
    elseif paymentMethod == "bank" then
        return xPlayer.getAccount('bank').money, "kartą"
    end
    return 0, nil
end

local function addVehicleToDisplay(vehData, index)
    if not Config.VehiclesPlaces[index] then
        return false
    end

    for _, v in ipairs(vehiclesOnDisplay) do
        if v.plate == vehData.plate then
            print("^3[CarMarket]^7 Vehicle " .. vehData.plate .. " already spawned on display")
            return false
        end
    end
    
    local pos = Config.VehiclesPlaces[index]
    local currentDate = os.date("%d.%m.%Y", vehData.inserted_at)
    local props = parseVehicleProps(vehData.vehicle)
    local vehicleModel = normalizeVehicleModel(vehData.model)

    local newVehicle = {
        id = vehData.id,
        plate = vehData.plate,
        model = vehicleModel,
        owner = vehData.owner,
        identifier = vehData.identifier,
        since = currentDate,
        price = vehData.price,
        props = props,
        coords = vector3(pos.x, pos.y, pos.z),
        heading = pos.w,
        phone = vehData.phone or "Brak numeru"
    }

    vehiclesOnDisplay[#vehiclesOnDisplay + 1] = newVehicle

    TriggerClientEvent("qf_carMarket:spawnVehicle", -1, newVehicle)

    print("^2[CarMarket]^7 Added vehicle to display: " .. newVehicle.plate)
    return true
end


local function removeVehicleFromDisplay(plate)
    for i = #vehiclesOnDisplay, 1, -1 do
        if vehiclesOnDisplay[i].plate == plate then
            table.remove(vehiclesOnDisplay, i)
            TriggerClientEvent("qf_carMarket:removeVehicle", -1, plate)
            print("^2[CarMarket]^7 Removed vehicle: " .. plate)
            return true
        end
    end
    return false
end

local function returnVehicleToGarage(src, plate)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end

    MySQL.Async.fetchScalar("SELECT identifier FROM car_market WHERE plate = @plate", {
        ['@plate'] = plate
    }, function(ownerIdentifier)
        if not ownerIdentifier then
            xPlayer.showNotification("~r~Ten pojazd nie jest na giełdzie!")
            return
        end

        if ownerIdentifier ~= xPlayer.identifier then
            xPlayer.showNotification("~r~Ten pojazd nie należy do Ciebie!")
            return
        end

        MySQL.Async.fetchScalar("SELECT vehicle FROM car_market WHERE plate = @plate", {
            ['@plate'] = plate
        }, function(vehicleJson)
            if not vehicleJson then
                xPlayer.showNotification("~r~Nie można znaleźć właściwości pojazdu!")
                return
            end

            MySQL.Async.execute("UPDATE owned_vehicles SET vehicle = @vehicle, stored = 1 WHERE plate = @plate", {
                ['@vehicle'] = vehicleJson,
                ['@plate'] = plate
            }, function(affectedRows)
                if affectedRows > 0 then
                    MySQL.Async.execute("DELETE FROM car_market WHERE plate = @plate", {
                        ['@plate'] = plate
                    }, function()
                        removeVehicleFromDisplay(plate)
                        xPlayer.showNotification("~g~Pomyślnie przywrócono pojazd [~w~" .. plate .. "~g~] do garażu!")
                    end)
                else
                    xPlayer.showNotification("~r~Wystąpił błąd podczas przywracania pojazdu!")
                end
            end)
        end)
    end)
end

local function cleanExpiredVehicles()
    local maxAge = Config.MarketDurationDays * 24 * 60 * 60
    local currentTime = os.time()
    local expirationTime = currentTime - maxAge

    MySQL.Async.fetchAll("SELECT plate FROM car_market WHERE inserted_at < @expTime", {
        ['@expTime'] = expirationTime
    }, function(results)
        if not results or #results == 0 then return end
        
        MySQL.Async.execute("DELETE FROM car_market WHERE inserted_at < @expTime", {
            ['@expTime'] = expirationTime
        }, function(affectedRows)
            if affectedRows > 0 then
                for _, row in ipairs(results) do
                    removeVehicleFromDisplay(row.plate)
                end
            end
        end)
    end)
end

local function updateVehicleOwner(src, vehicle, callback)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then 
        if callback then callback(false) end
        return 
    end

    MySQL.Async.fetchScalar("SELECT vehicle FROM car_market WHERE plate = @plate", {
        ['@plate'] = vehicle.plate
    }, function(vehicleJson)
        if not vehicleJson then
            xPlayer.showNotification("~r~Nie można znaleźć właściwości pojazdu!")
            if callback then callback(false) end
            return
        end

        MySQL.Async.execute("UPDATE owned_vehicles SET owner = @owner, vehicle = @vehicle, stored = 1 WHERE plate = @plate", {
            ['@owner'] = xPlayer.identifier,
            ['@vehicle'] = vehicleJson,
            ['@plate'] = vehicle.plate
        }, function(affectedRows)
            if affectedRows > 0 then
                MySQL.Async.execute("DELETE FROM car_market WHERE plate = @plate", {
                    ['@plate'] = vehicle.plate
                }, function()
                    removeVehicleFromDisplay(vehicle.plate)
                    if callback then callback(true) end
                end)
            else
                xPlayer.showNotification("~r~Nie można zaktualizować właściciela pojazdu!")
                if callback then callback(false) end
            end
        end)
    end)
end

local function getOwnedVehicles(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return {} end
    
    local ownedVehiclesQuery = MySQL.query.await(
        "SELECT vehicle, plate, mileage FROM owned_vehicles WHERE owner = ? AND stored = 0 AND plate NOT IN (SELECT plate FROM car_market)", 
        {xPlayer.identifier}
    )

    if not ownedVehiclesQuery or #ownedVehiclesQuery == 0 then 
        return {}
    end

    local ownedVehicles = {}
    for i, vehicleRow in ipairs(ownedVehiclesQuery) do
        local vehicleData = json.decode(vehicleRow.vehicle)
        local vehicleModel = normalizeVehicleModel(vehicleData.model or "Unknown")

        ownedVehicles[i] = {
            Plate = vehicleRow.plate,
            Data = vehicleData,
            Model = vehicleModel,
            Mileage = vehicleRow.mileage,
            Label = "[" .. vehicleRow.plate .. "]  " .. vehicleModel .. "  >  PRZEBIEG: " .. ESX.Math.Round(vehicleRow.mileage) .. "km",
        }
    end

    return ownedVehicles
end

local function getVehicleById(vehicleId)
    for _, vehicle in ipairs(vehiclesOnDisplay) do 
        if vehicle.id == vehicleId then 
            return vehicle
        end
    end
    return nil
end

RegisterServerEvent("exotic_carmarket:requestBuyVehicle", function(vehicleId, paymentMethod)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end

    local vehicle = getVehicleById(vehicleId)
    if not vehicle then 
        xPlayer.showNotification("~r~Ten pojazd nie jest już dostępny")
        return
    end

    if vehicle.identifier == xPlayer.identifier then
        xPlayer.showNotification("~r~Nie możesz kupić własnego pojazdu!")
        return
    end

    local playerMoney, paymentType = getPlayerPaymentAmount(xPlayer, paymentMethod)
    if not paymentType then
        xPlayer.showNotification("~r~Nieprawidłowa metoda płatności!")
        return
    end

    if playerMoney < vehicle.price then 
        xPlayer.showNotification("~r~Nie posiadasz wystarczającej ilości środków na " .. paymentType .. " (~g~$" .. vehicle.price .. "~r~)")
        return
    end

    MySQL.Async.fetchScalar("SELECT id FROM car_market WHERE plate = @plate", {
        ['@plate'] = vehicle.plate
    }, function(existsInDb)
        if not existsInDb then
            xPlayer.showNotification("~r~Ten pojazd został właśnie kupiony przez kogoś innego")
            return
        end

        xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end
        
        local playerMoney = getPlayerPaymentAmount(xPlayer, paymentMethod)
        if playerMoney < vehicle.price then
            xPlayer.showNotification("~r~Nie posiadasz już wystarczającej ilości środków")
            return
        end

        updateVehicleOwner(src, vehicle, function(success)
            if success then
                if paymentMethod == "cash" then
                    xPlayer.removeMoney(vehicle.price)
                elseif paymentMethod == "bank" then
                    xPlayer.removeAccountMoney('bank', vehicle.price)
                end
                
                xPlayer.showNotification("~g~Pomyślnie zakupiłeś pojazd [~w~" .. vehicle.plate .. "~g~] za ~w~$" .. vehicle.price .. " " .. paymentType)
                
                local seller = ESX.GetPlayerFromIdentifier(vehicle.identifier)
                if seller then
                    seller.addMoney(vehicle.price)
                    seller.showNotification("~g~Sprzedano Twój pojazd [~w~" .. vehicle.plate .. "~g~] za ~w~$" .. vehicle.price)
                else
                    MySQL.Async.execute("UPDATE users SET money = money + @amount WHERE identifier = @identifier", {
                        ['@amount'] = vehicle.price,
                        ['@identifier'] = vehicle.identifier
                    })
                end
            else
                xPlayer.showNotification("~r~Wystąpił błąd podczas zakupu pojazdu")
            end
        end)
    end)
end)

RegisterServerEvent("exotic_carmarket:requestVehiclesMenu", function()
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local ownedVehicles = getOwnedVehicles(src)
    if #ownedVehicles == 0 then
        xPlayer.showNotification("~r~Nie masz żadnych pojazdów w garażu do wystawienia!")
        return
    end

    TriggerClientEvent("exotic_carmarket:openVehiclesMenu", src, ownedVehicles)
end)

RegisterNetEvent("qf_carMarket:addVehicleFromClient")
AddEventHandler("qf_carMarket:addVehicleFromClient", function(data)
    local src = source
    if not data or type(data) ~= "table" then return end
    if not tonumber(data.price) or not data.plate then 
        return 
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local price = tonumber(data.price)
    if not price or price < MIN_PRICE or price > MAX_PRICE then
        xPlayer.showNotification("~r~Nieprawidłowa cena pojazdu!")
        return
    end

    MySQL.Async.fetchScalar("SELECT plate FROM car_market WHERE plate = @plate", {
        ['@plate'] = data.plate
    }, function(existing)
        if existing then 
            xPlayer.showNotification("~r~Ten pojazd jest już wystawiony na giełdzie!")
            return 
        end

        MySQL.Async.fetchAll("SELECT owner, vehicle FROM owned_vehicles WHERE plate = @plate AND stored = 0", {
            ['@plate'] = data.plate
        }, function(vehicleData)
            if not vehicleData or #vehicleData == 0 then
                xPlayer.showNotification("~r~Ten pojazd nie istnieje lub nie jest w garażu!")
                return
            end
            
            local vehicle = vehicleData[1]
            if vehicle.owner ~= xPlayer.identifier then
                xPlayer.showNotification("~r~Ten pojazd nie należy do Ciebie!")
                return
            end
            
            local props = parseVehicleProps(vehicle.vehicle)
            if not props or not props.model then
                xPlayer.showNotification("~r~Błąd odczytu właściwości pojazdu!")
                return
            end
            
            local vehicleModel = normalizeVehicleModel(props.model)
            if vehicleModel == "Unknown" or not vehicleModel then
                xPlayer.showNotification("~r~Nieprawidłowy model pojazdu!")
                return
            end

            local placeIndex = #vehiclesOnDisplay + 1
            if not Config.VehiclesPlaces[placeIndex] then
                xPlayer.showNotification("~r~Brak wolnych miejsc na giełdzie! (~w~" .. #vehiclesOnDisplay .. "/" .. #Config.VehiclesPlaces .. "~r~)")
                return
            end

            local playerName = xPlayer.get("firstName") .. " " .. xPlayer.get("lastName")
            
            MySQL.Async.insert("INSERT INTO car_market (owner, identifier, plate, model, vehicle, price, inserted_at) VALUES (@owner, @identifier, @plate, @model, @vehicle, @price, @time)", {
                ['@owner'] = playerName,
                ['@identifier'] = xPlayer.identifier,
                ['@plate'] = data.plate,
                ['@model'] = vehicleModel,
                ['@vehicle'] = json.encode(props),
                ['@price'] = price,
                ['@time'] = os.time()
            }, function(insertId)
                if not insertId then 
                    xPlayer.showNotification("~r~Wystąpił błąd podczas wystawiania pojazdu")
                    return 
                end

                local success = addVehicleToDisplay({
                    id = insertId,
                    plate = data.plate,
                    model = vehicleModel,
                    owner = playerName,
                    identifier = xPlayer.identifier,
                    inserted_at = os.time(),
                    price = price,
                    vehicle = json.encode(props)
                }, placeIndex)

                if success then
                    MySQL.Async.execute("UPDATE owned_vehicles SET stored = 1 WHERE plate = @plate", {
                        ['@plate'] = data.plate
                    })
                    xPlayer.showNotification("~g~Pomyślnie wystawiono pojazd [~w~" .. data.plate .. "~g~] za ~w~$" .. price)
                else
                    MySQL.Async.execute("DELETE FROM car_market WHERE id = @id", {['@id'] = insertId})
                    xPlayer.showNotification("~r~Wystąpił błąd podczas wystawiania pojazdu")
                end
            end)
        end)
    end)
end)

RegisterNetEvent("qf_carMarket:removeVehicleFromClient")
AddEventHandler("qf_carMarket:removeVehicleFromClient", function(plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not plate then return end

    MySQL.Async.fetchScalar("SELECT identifier FROM car_market WHERE plate = @plate", {
        ['@plate'] = plate
    }, function(ownerIdentifier)
        if not ownerIdentifier then
            xPlayer.showNotification("~r~Nie znaleziono pojazdu na giełdzie")
            return
        end

        if ownerIdentifier ~= xPlayer.identifier then 
            xPlayer.showNotification("~r~Ten pojazd nie należy do Ciebie!")
            return 
        end

        MySQL.Async.execute("DELETE FROM car_market WHERE plate = @plate", {
            ['@plate'] = plate
        }, function(affectedRows)
            if affectedRows > 0 then
                removeVehicleFromDisplay(plate)
                xPlayer.showNotification("~g~Pomyślnie wycofano pojazd [~w~" .. plate .. "~g~] z giełdy")
            else
                xPlayer.showNotification("~r~Wystąpił błąd podczas wycofywania pojazdu")
            end
        end)
    end)
end)

RegisterNetEvent("qf_carMarket:returnVehicleToGarage")
AddEventHandler("qf_carMarket:returnVehicleToGarage", function(plate)
    local src = source
    returnVehicleToGarage(src, plate)
end)

ESX.RegisterServerCallback('qf_carMarket:isVehicleOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        cb(false)
        return 
    end

    MySQL.Async.fetchScalar("SELECT identifier FROM car_market WHERE plate = @plate", {
        ['@plate'] = plate
    }, function(ownerIdentifier)
        cb(ownerIdentifier == xPlayer.identifier)
    end)
end)

exports("AddVehicleToMarket", function(identifier, owner, plate, model, props, price)
    if not identifier or not owner or not plate or not model or not props or not price then
        return false
    end

    local placeIndex = #vehiclesOnDisplay + 1
    if not Config.VehiclesPlaces[placeIndex] then
        return false
    end

    MySQL.Async.insert("INSERT INTO car_market (owner, identifier, plate, model, vehicle, price, inserted_at) VALUES (@owner, @identifier, @plate, @model, @vehicle, @price, @time)", {
        ['@owner'] = owner,
        ['@identifier'] = identifier,
        ['@plate'] = plate,
        ['@model'] = model,
        ['@vehicle'] = json.encode(props),
        ['@price'] = price,
        ['@time'] = os.time()
    }, function(insertId)
        if not insertId then 
            return 
        end
        
        local success = addVehicleToDisplay({
            id = insertId,
            plate = plate,
            model = model,
            owner = owner,
            identifier = identifier,
            inserted_at = os.time(),
            price = price,
            vehicle = json.encode(props)
        }, placeIndex)

        if not success then
            MySQL.Async.execute("DELETE FROM car_market WHERE id = @id", {['@id'] = insertId})
        end
    end)
    
    return true
end)

exports("RemoveVehicleFromMarket", function(plate)
    if not plate then
        return false
    end

    MySQL.Async.execute("DELETE FROM car_market WHERE plate = @plate", {
        ['@plate'] = plate
    }, function(affectedRows)
        if affectedRows > 0 then
            removeVehicleFromDisplay(plate)
            return true
        else
            return false
        end
    end)
end)

AddEventHandler("onResourceStart", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    
    MySQL.ready(function()
        cleanExpiredVehicles()
        
        Wait(1000)
        
        MySQL.Async.fetchAll("SELECT * FROM car_market ORDER BY inserted_at ASC", {}, function(results)
            vehiclesOnDisplay = {}
            
            if not results or #results == 0 then
                -- Send empty list to all clients
                TriggerClientEvent("qf_carMarket:spawnAllVehicles", -1, {})
                return
            end

            local loadedCount = 0
            local phonePromises = {}
            
            for i, row in ipairs(results) do
                if i <= #Config.VehiclesPlaces then
                    local pos = Config.VehiclesPlaces[i]
                    local currentDate = os.date("%d.%m.%Y", row.inserted_at)
                    local props = parseVehicleProps(row.vehicle)
                    local vehicleModel = normalizeVehicleModel(row.model)

                    phonePromises[i] = function(callback)
                        MySQL.Async.fetchScalar("SELECT phone_number FROM users WHERE identifier = @identifier", {
                            ['@identifier'] = row.identifier
                        }, function(phoneNumber)
                            local phone = phoneNumber or "Brak numeru"
                            local playerName = row.owner -- fallback to stored owner name
                            
                            -- Try to get current player data if online
                            local xPlayer = ESX.GetPlayerFromIdentifier(row.identifier)
                            if xPlayer then
                                playerName = xPlayer.get("firstName") .. " " .. xPlayer.get("lastName")
                            end
                            
                            callback(phone, playerName)
                        end)
                    end
                    
                    vehiclesOnDisplay[#vehiclesOnDisplay + 1] = {
                        id = row.id,
                        plate = row.plate,
                        model = vehicleModel,
                        owner = row.owner,
                        identifier = row.identifier,
                        since = currentDate,
                        price = row.price,
                        props = props,
                        coords = vector3(pos.x, pos.y, pos.z),
                        heading = pos.w,
                        phone = "Loading..."
                    }
                    loadedCount = loadedCount + 1
                end
            end
            
            local phoneCount = 0
            for i, promise in pairs(phonePromises) do
                promise(function(phone, playerName)
                    if vehiclesOnDisplay[i] then
                        vehiclesOnDisplay[i].phone = phone
                        vehiclesOnDisplay[i].owner = playerName
                    end
                    phoneCount = phoneCount + 1
                    
                    if phoneCount >= loadedCount then
                        Wait(1000)
                        TriggerClientEvent("qf_carMarket:spawnAllVehicles", -1, vehiclesOnDisplay)
                        print("^2[CarMarket]^7 Sent " .. #vehiclesOnDisplay .. " vehicles to clients for spawning")
                    end
                end)
            end
            
            if loadedCount == 0 then
                TriggerClientEvent("qf_carMarket:spawnAllVehicles", -1, vehiclesOnDisplay)
                print("^2[CarMarket]^7 Sent " .. #vehiclesOnDisplay .. " vehicles to clients for spawning (no phones)")
            end
        end)
    end)
end)

CreateThread(function()
    while true do
        Wait(CLEANUP_INTERVAL)
        cleanExpiredVehicles()
    end
end)

RegisterNetEvent('qf_carMarket:getVehicleDetailsByPlate')
AddEventHandler('qf_carMarket:getVehicleDetailsByPlate', function(plate)
    local src = source
    for _, vehicleData in ipairs(vehiclesOnDisplay) do
        if vehicleData.plate == plate then
            TriggerClientEvent("qf_carMarket:configureVehicleInteractions", src, vehicleData)
            break
        end
    end
end)

RegisterNetEvent('qf_carMarket:getVehicleDetails')
AddEventHandler('qf_carMarket:getVehicleDetails', function(vehicleId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local vehicle = getVehicleById(vehicleId)
    if not vehicle then
        xPlayer.showNotification("~r~Nie znaleziono pojazdu!")
        return
    end
    
    MySQL.Async.fetchScalar("SELECT phone_number FROM users WHERE identifier = @identifier", {
        ['@identifier'] = vehicle.identifier
    }, function(phoneNumber)
        local phone = phoneNumber or "Brak numeru"
        local playerName = vehicle.owner
        
        local ownerPlayer = ESX.GetPlayerFromIdentifier(vehicle.identifier)
        if ownerPlayer then
            playerName = ownerPlayer.get("firstName") .. " " .. ownerPlayer.get("lastName")
        end
        
        TriggerClientEvent("qf_carMarket:openVehicleCard", src, {
            id = vehicle.id,
            model = vehicle.model,
            plate = vehicle.plate,
            owner = playerName,
            price = vehicle.price,
            since = vehicle.since,
            props = vehicle.props,
            phone = phone
        })
    end)
end)

RegisterNetEvent('qf_carMarket:requestVehiclesList')
AddEventHandler('qf_carMarket:requestVehiclesList', function()
    local src = source
    
    if not src or src == 0 then
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end
    
    local currentTime = GetGameTimer()
    if pendingRequests[src] then
        local timeSinceLastRequest = currentTime - pendingRequests[src].lastRequest
        if timeSinceLastRequest < REQUEST_RATE_LIMIT then
            return
        end
        
        if pendingRequests[src].threadActive then
            pendingRequests[src].threadActive = false
        end
    end
    
    pendingRequests[src] = {
        lastRequest = currentTime,
        threadActive = true
    }
    
    local function sendVehiclesToClient(playerSource, vehicleList)
        if not ESX.GetPlayerFromId(playerSource) then
            if pendingRequests[playerSource] then
                pendingRequests[playerSource].threadActive = false
            end
            return
        end
        
        local success, err = pcall(function()
            TriggerClientEvent("qf_carMarket:spawnAllVehicles", playerSource, vehicleList)
        end)
        
        if not success then
            print("^1[CarMarket Server]^7 Error sending vehicles to client " .. playerSource .. ": " .. tostring(err))
        end
        
        if pendingRequests[playerSource] then
            pendingRequests[playerSource].threadActive = false
        end
    end
    
    local function waitForVehiclesAndSend(playerSource)
        local attempts = 0
        while (not vehiclesOnDisplay or #vehiclesOnDisplay == 0) and attempts < LOAD_RETRY_ATTEMPTS do
            if not pendingRequests[playerSource] or not pendingRequests[playerSource].threadActive then
                return
            end
            
            if not ESX.GetPlayerFromId(playerSource) then
                if pendingRequests[playerSource] then
                    pendingRequests[playerSource].threadActive = false
                end
                return
            end
            
            Wait(LOAD_RETRY_DELAY)
            attempts = attempts + 1
        end
        
        if pendingRequests[playerSource] and pendingRequests[playerSource].threadActive then
            if vehiclesOnDisplay and #vehiclesOnDisplay > 0 then
                sendVehiclesToClient(playerSource, vehiclesOnDisplay)
            else
                sendVehiclesToClient(playerSource, {})
            end
        end
    end
    
    if not vehiclesOnDisplay or #vehiclesOnDisplay == 0 then
        CreateThread(function()
            waitForVehiclesAndSend(src)
        end)
    else
        sendVehiclesToClient(src, vehiclesOnDisplay)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    
    TriggerClientEvent("qf_carMarket:spawnAllVehicles", -1, {})
    vehiclesOnDisplay = {}
    pendingRequests = {}
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    if pendingRequests[src] then
        pendingRequests[src].threadActive = false
        pendingRequests[src] = nil
    end
end)