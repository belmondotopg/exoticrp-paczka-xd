local DEFAULT_AVATAR = "https://imgs.search.brave.com/7JPVrX1-rrex4c53w-1YqddoSVInG8opEOsfUQYuBpU/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/dmVjdG9yc3RvY2su/Y29tL2kvNTAwcC83/MC8wMS9kZWZhdWx0/LW1hbGUtYXZhdGFy/LXByb2ZpbGUtaWNv/bi1ncmV5LXBob3Rv/LXZlY3Rvci0zMTgy/NzAwMS5qcGc"

ESX.RegisterServerCallback('vwk/exoticrp/getSteamData', function(source, cb)
    local name = GetPlayerName(source)
    local steamIdentifier = functions.getSteam(source)
    
    if not steamIdentifier then
        cb({ name = name, avatar = DEFAULT_AVATAR, coins = 0 })
        return
    end
    
    local hex = string.sub(steamIdentifier, 7)
    local steam64 = tonumber(hex, 16)
    local profileURL = string.format("https://steamcommunity.com/profiles/%s?xml=1", steam64)
    
    local result = MySQL.query.await('SELECT coins FROM timecoins WHERE identifier = ?', { steamIdentifier })
    local coins = result and result[1] and result[1].coins or 0
    if result and result[1] then
        MySQL.update.await('UPDATE timecoins SET name = ? WHERE identifier = ?', { name, steamIdentifier })
    else
        MySQL.insert.await('INSERT INTO timecoins (identifier, name, coins) VALUES (?, ?, 0)', { steamIdentifier, name })
    end
    
    PerformHttpRequest(profileURL, function(statusCode, data)
        local avatarURL = DEFAULT_AVATAR
        if statusCode == 200 and data then
            local found = string.match(data, "<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")
            if found then
                avatarURL = found
            end
        end
        cb({ name = name, avatar = avatarURL, coins = coins })
    end)
end)

ESX.RegisterServerCallback('vwk/exoticrp/getClaimedProducts', function(source, cb)
    local identifier = functions.getSteam(source)
    if not identifier then
        cb({})
        return
    end

    local result = MySQL.query.await('SELECT claimed FROM timecoins WHERE identifier = ?', { identifier })
    local claimedItems = {}
    local claimedList = {}

    if result and result[1] and result[1].claimed then
        local success, data = pcall(json.decode, result[1].claimed)
        if success and type(data) == "table" then
            claimedList = data
            for _, itemId in ipairs(data) do
                local product = functions.findProduct(itemId)
                local allowMultiple = product and (product.allowMultipleClaims ~= nil and product.allowMultipleClaims or false)
                if not allowMultiple then
                    claimedItems[itemId] = true
                end
            end
        end
    end
    
    local needsUpdate = false
    local cleanedList = {}
    for _, itemId in ipairs(claimedList) do
        local product = functions.findProduct(itemId)
        local allowMultiple = product and (product.allowMultipleClaims ~= nil and product.allowMultipleClaims or false)
        if not allowMultiple then
            table.insert(cleanedList, itemId)
        else
            needsUpdate = true
        end
    end
    
    if needsUpdate then
        MySQL.update.await('UPDATE timecoins SET claimed = ? WHERE identifier = ?', { json.encode(cleanedList), identifier })
    end
    
    cb(claimedItems)
end)

local NumberCharset = {}
local Charset = {}

for i = 48, 57 do table.insert(NumberCharset, string.char(i)) end
for i = 65, 90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

local function GetRandomNumber(length)
	math.randomseed(GetGameTimer())
	local result = {}
	for i = 1, length do
		result[i] = NumberCharset[math.random(1, #NumberCharset)]
	end
	return table.concat(result)
end

local function GetRandomLetter(length)
	math.randomseed(GetGameTimer())
	local result = {}
	for i = 1, length do
		result[i] = Charset[math.random(1, #Charset)]
	end
	return table.concat(result)
end

vehicleCallbacks = vehicleCallbacks or {}

functions.generatePlate = function()
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

functions.saveVehicleToGarage = function(src, vehicleModel)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end
    
    local plate = functions.generatePlate()
    vehicleCallbacks[src] = {xPlayer = xPlayer, plate = plate}
    
    TriggerClientEvent('vwk/exoticrp/getVehicleProps', src, vehicleModel, plate)
end

RegisterNetEvent('vwk/exoticrp/vehiclePropsCallback', function(vehicleProps)
    local src = source
    local callbackData = vehicleCallbacks[src]
    
    if not callbackData or not vehicleProps then
        return
    end
    
    local xPlayer = callbackData.xPlayer
    local plate = callbackData.plate
    
    vehicleCallbacks[src] = nil
    
    MySQL.update('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, LEFT(@vehicle, 2000), @type)',
    {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@type'] = 'car'
    }, function (rowsChanged)
        TriggerClientEvent('esx:showNotification', src, "Pojazd należy teraz do Ciebie")
    end)
end)