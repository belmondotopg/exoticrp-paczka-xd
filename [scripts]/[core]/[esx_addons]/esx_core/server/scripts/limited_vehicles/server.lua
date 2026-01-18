local function GetDiscordId(src)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id:find("discord") then
            return id:gsub("discord:", "")
        end
    end
    return nil
end

local function normalizeDiscordId(discordId)
    if not discordId then return nil end
    discordId = tostring(discordId)
    discordId = discordId:gsub("^discord:", "")
    return discordId
end

local Charset = {}
for i = 48, 57 do table.insert(Charset, string.char(i)) end
for i = 65, 90 do table.insert(Charset, string.char(i)) end

local function GetRandomNumber(length)
	math.randomseed(GetGameTimer())
	local result = {}
	for i = 1, length do
		result[i] = Charset[math.random(1, 10)]
	end
	return table.concat(result)
end

local function GetRandomLetter(length)
	math.randomseed(GetGameTimer())
	local result = {}
	for i = 1, length do
		result[i] = Charset[math.random(11, #Charset)]
	end
	return table.concat(result)
end

local function generatePlate()
	local generatedPlate
	while true do
		generatedPlate = string.upper(GetRandomLetter(4) .. GetRandomNumber(4))
		local result = MySQL.query.await('SELECT 1 FROM owned_vehicles WHERE plate = ?', { generatedPlate })
		if not result or not result[1] then
			break
		end
	end
	return generatedPlate
end

local pendingClaims = {}

ESX.RegisterCommand('addlimitedcar', { 'founder', 'developer' }, function(xPlayer, args, showError)
    if not args.discordid or not args.model then
        if xPlayer then
            xPlayer.showNotification("Użycie: /addlimitedcar [discordid] [model]", "error")
        else
            print("Użycie: addlimitedcar [discordid] [model]")
        end
        return
    end
    
    local discordId = normalizeDiscordId(args.discordid)
    local vehicleModel = tostring(args.model)
    
    if not discordId or discordId == "" then
        if xPlayer then
            xPlayer.showNotification("Nieprawidłowe Discord ID!", "error")
        else
            print("Nieprawidłowe Discord ID!")
        end
        return
    end
    MySQL.insert('INSERT INTO limited_vehicles (discord_id, vehicle_model, claimed) VALUES (?, ?, ?)', {
        discordId,
        vehicleModel,
        0
    }, function(insertId)
        if insertId then
            if xPlayer then
                xPlayer.showNotification("Pojazd limitowany dodany! Discord ID: " .. discordId .. " Model: " .. vehicleModel)
                exports.esx_core:SendLog(xPlayer.source, "[LIMITED VEHICLES] Dodano pojazd limitowany", "Discord ID: " .. discordId .. "\nModel: " .. vehicleModel, 'admin-commands')
            else
                print("Pojazd limitowany dodany! Discord ID: " .. discordId .. " Model: " .. vehicleModel)
            end
        else
            if xPlayer then
                xPlayer.showNotification("Błąd podczas dodawania pojazdu!", "error")
            else
                print("Błąd podczas dodawania pojazdu!")
            end
        end
    end)
end, true, {help = "Dodaj pojazd limitowany dla gracza", validate = true, arguments = {
    {name = 'discordid', help = "Discord ID gracza", type = 'number'},
    {name = 'model', help = "Model pojazdu", type = 'string'},
}})

RegisterNetEvent('esx_limitedvehicles:checkVehicles', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        return
    end
    
    local discordId = GetDiscordId(src)
    if not discordId then
        TriggerClientEvent('esx:showNotification', src, "Nie znaleziono Discord ID!", "error")
        return
    end
    
    local vehicles = MySQL.query.await('SELECT id, vehicle_model FROM limited_vehicles WHERE discord_id = ? AND claimed = 0', {
        discordId
    })
    
    if vehicles and #vehicles > 0 then
        TriggerClientEvent('esx_limitedvehicles:showVehicles', src, vehicles)
    else
        TriggerClientEvent('esx:showNotification', src, "Nie masz żadnych pojazdów do odebrania", "info")
    end
end)

RegisterNetEvent('esx_limitedvehicles:claimVehicle', function(vehicleId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer or not vehicleId or type(vehicleId) ~= "number" then
        return
    end
    
    local discordId = GetDiscordId(src)
    if not discordId then
        TriggerClientEvent('esx:showNotification', src, "Nie znaleziono Discord ID!", "error")
        return
    end
    
    local vehicle = MySQL.single.await('SELECT * FROM limited_vehicles WHERE id = ? AND discord_id = ? AND claimed = 0', {
        vehicleId,
        discordId
    })
    
    if not vehicle then
        TriggerClientEvent('esx:showNotification', src, "Nie znaleziono pojazdu do odebrania!", "error")
        return
    end
    
    local requiredMoney = 200000
    if xPlayer.getAccount('money').money < requiredMoney then
        TriggerClientEvent('esx:showNotification', src, "Nie masz wystarczająco pieniędzy! Wymagane: $200,000", "error")
        return
    end
    
    xPlayer.removeAccountMoney('money', requiredMoney)
    
    local plate = generatePlate()
    
    pendingClaims[src] = {
        vehicleId = vehicleId,
        plate = plate,
        discordId = discordId,
        vehicleModel = vehicle.vehicle_model
    }
    
    TriggerClientEvent('esx_limitedvehicles:getVehicleProps', src, vehicle.vehicle_model, plate, vehicleId)
end)

RegisterNetEvent('esx_limitedvehicles:vehiclePropsCallback', function(vehicleProps, plate, vehicleId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer or not vehicleProps then
        return
    end
    
    local pendingClaim = pendingClaims[src]
    if not pendingClaim then
        return
    end
    
    if pendingClaim.vehicleId ~= vehicleId or pendingClaim.plate ~= plate then
        pendingClaims[src] = nil
        xPlayer.addAccountMoney('money', 200000)
        return
    end
    
    local discordId = GetDiscordId(src)
    if not discordId or discordId ~= pendingClaim.discordId then
        pendingClaims[src] = nil
        xPlayer.addAccountMoney('money', 200000)
        return
    end
    
    local vehicle = MySQL.single.await('SELECT * FROM limited_vehicles WHERE id = ? AND discord_id = ? AND claimed = 0', {
        vehicleId,
        discordId
    })
    
    if not vehicle then
        pendingClaims[src] = nil
        xPlayer.addAccountMoney('money', 200000)
        TriggerClientEvent('esx:showNotification', src, "Nie znaleziono pojazdu do odebrania!", "error")
        return
    end
    
    if not vehicleProps.model or type(vehicleProps.model) ~= "number" then
        pendingClaims[src] = nil
        xPlayer.addAccountMoney('money', 200000)
        return
    end
    
    local expectedModel = joaat(pendingClaim.vehicleModel)
    if vehicleProps.model ~= expectedModel then
        pendingClaims[src] = nil
        xPlayer.addAccountMoney('money', 200000)
        return
    end
    
    if vehicleProps.plate ~= plate then
        vehicleProps.plate = plate
    end
    
    vehicleProps.bodyHealth = 1000.0
    vehicleProps.engineHealth = 1000.0
    vehicleProps.tankHealth = 1000.0
    vehicleProps.fuelLevel = vehicleProps.fuelLevel or 100.0
    vehicleProps.oilLevel = vehicleProps.oilLevel or 100.0
    vehicleProps.dirtLevel = 0.0
    
    if vehicleProps.windowsBroken then
        vehicleProps.windowsBroken = {}
    end
    if vehicleProps.doorsBroken then
        vehicleProps.doorsBroken = {}
    end
    if vehicleProps.tyreBurst then
        vehicleProps.tyreBurst = {}
    end
    
    local requiredMoney = 200000
    
    local insertId = MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)', {
        xPlayer.identifier,
        plate,
        json.encode(vehicleProps),
        'car',
        0
    })
    
    if insertId then
        MySQL.update.await('UPDATE limited_vehicles SET claimed = 1, claimed_at = NOW() WHERE id = ?', {
            vehicleId
        })
        
        pendingClaims[src] = nil
        
        TriggerClientEvent('esx:showNotification', src, "Pojazd został odebrany i zapisany do garazu! Tablica: " .. plate)
        exports.esx_core:SendLog(src, "[LIMITED VEHICLES] Odebrano pojazd limitowany", "Gracz: " .. xPlayer.getName() .. "\nModel: " .. (vehicleProps.model or "unknown") .. "\nTablica: " .. plate, 'vehicleshop')
    else
        pendingClaims[src] = nil
        xPlayer.addAccountMoney('money', requiredMoney)
        TriggerClientEvent('esx:showNotification', src, "Błąd podczas zapisywania pojazdu! Pieniądze zostały zwrócone.", "error")
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if pendingClaims[src] then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addAccountMoney('money', 200000)
        end
        pendingClaims[src] = nil
    end
end)