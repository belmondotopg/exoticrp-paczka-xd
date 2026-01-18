-- exotic_rentalsystem by shevey

local MAX_DISTANCE = 10.0
local RENTAL_COOLDOWN = {}
local RENTAL_COOLDOWN_TIME = 3000
local WEBHOOK_URL = "https://discord.com/api/webhooks/1439037173155365014/HpTeJaFcBjHFi5wqz2krfFsjYQD0hJO0IqXWzOwEctiM2YX6rG9GTYh7RSikNEoD6JFn"

local CAR_RENTAL_COORDS = vector3(-751.7393, -2291.0669, 13.0369)
local BOAT_RENTAL_COORDS = vector3(-795.42, -1510.97, 1.6)

local CAR_VEHICLES = {
    ["dilettante"] = 1500, ["panto"] = 1200, ["prairie"] = 1800, ["cogcabrio"] = 7500,
    ["exemplar"] = 5000, ["f620"] = 4200, ["felon"] = 3200, ["ingot"] = 1400,
    ["intruder"] = 1900, ["premier"] = 2100
}

local BOAT_VEHICLES = {
    ["seashark"] = 1000, ["seashark2"] = 1250, ["seashark3"] = 1500, ["dinghy"] = 2500,
    ["dinghy2"] = 2750, ["jetmax"] = 5500, ["marquis"] = 12500, ["speeder"] = 7000,
    ["squalo"] = 4250, ["suntrap"] = 3250
}

local function isPlayerNearRental(source, rentalType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local playerPed = GetPlayerPed(source)
    if not playerPed or playerPed == 0 then return false end
    
    local playerCoords = GetEntityCoords(playerPed)
    local rentalCoords = rentalType == "car" and CAR_RENTAL_COORDS or BOAT_RENTAL_COORDS
    
    return #(playerCoords - rentalCoords) <= MAX_DISTANCE
end

local function isValidVehicle(vehicleModel, rentalType, price)
    if not vehicleModel or type(vehicleModel) ~= "string" then return false end
    if not rentalType or (rentalType ~= "car" and rentalType ~= "boat") then return false end
    if not price or type(price) ~= "number" or price <= 0 or price > 100000 then return false end
    
    local vehicles = rentalType == "car" and CAR_VEHICLES or BOAT_VEHICLES
    return vehicles[vehicleModel] == price
end

local function SendWebhook(title, description, color, fields)
    local embed = {
        {
            title = title,
            description = description,
            type = "rich",
            color = color or 3447003,
            fields = fields or {},
            footer = {
                text = "exotic_rentalsystem"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    PerformHttpRequest(WEBHOOK_URL, function(err, text, headers) end, 'POST', json.encode({
        username = "Rental System",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

ESX.RegisterServerCallback('exoticrp:checkMoney', function(source, cb, price, paymentMethod, vehicleModel, rentalType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb(false)
        return
    end
    
    local currentTime = GetGameTimer()
    if RENTAL_COOLDOWN[source] and currentTime - RENTAL_COOLDOWN[source] < RENTAL_COOLDOWN_TIME then
        SendWebhook("⚠️ Cooldown", "Gracz próbował wynająć pojazd podczas cooldown", 15158332, {
            {name = "Gracz", value = GetPlayerName(source) .. " (" .. xPlayer.identifier .. ")", inline = true}
        })
        cb(false)
        return
    end
    
    local playerName = GetPlayerName(source)
    local identifier = xPlayer.identifier
    
    if not isPlayerNearRental(source, rentalType) then
        SendWebhook("⚠️ Próba exploit", "Gracz próbował wynająć pojazd z nieprawidłowej odległości", 15158332, {
            {name = "Gracz", value = playerName .. " (" .. identifier .. ")", inline = true},
            {name = "Typ", value = rentalType == "car" and "Samochód" or "Łódź", inline = true}
        })
        cb(false)
        return
    end
    
    if not isValidVehicle(vehicleModel, rentalType, price) then
        SendWebhook("⚠️ Próba exploit", "Gracz próbował wynająć pojazd z nieprawidłowymi danymi", 15158332, {
            {name = "Gracz", value = playerName .. " (" .. identifier .. ")", inline = true},
            {name = "Typ", value = rentalType == "car" and "Samochód" or "Łódź", inline = true},
            {name = "Pojazd", value = tostring(vehicleModel), inline = true},
            {name = "Cena", value = tostring(price), inline = true}
        })
        cb(false)
        return
    end
    
    if paymentMethod ~= 'cash' and paymentMethod ~= 'bank' then
        SendWebhook("⚠️ Próba exploit", "Gracz próbował użyć nieprawidłowej metody płatności", 15158332, {
            {name = "Gracz", value = playerName .. " (" .. identifier .. ")", inline = true},
            {name = "Metoda płatności", value = tostring(paymentMethod), inline = true}
        })
        cb(false)
        return
    end
    
    local rentalTypeName = rentalType == "car" and "Samochód" or "Łódź"
    local paymentMethodName = paymentMethod == "cash" and "Gotówka" or "Karta bankowa"
    
    local hasEnoughMoney = false
    local currentMoney = 0
    
    if paymentMethod == 'cash' then
        currentMoney = xPlayer.getMoney()
        hasEnoughMoney = currentMoney >= price
        if hasEnoughMoney then
            xPlayer.removeMoney(price)
        end
    elseif paymentMethod == 'bank' then
        currentMoney = xPlayer.getAccount('bank').money
        hasEnoughMoney = currentMoney >= price
        if hasEnoughMoney then
            xPlayer.removeAccountMoney('bank', price)
        end
    end
    
    if hasEnoughMoney then
        RENTAL_COOLDOWN[source] = currentTime
        SendWebhook("✅ Wynajęcie pojazdu", "Gracz wynajął pojazd", 3066993, {
            {name = "Gracz", value = playerName .. " (" .. identifier .. ")", inline = true},
            {name = "Typ", value = rentalTypeName, inline = true},
            {name = "Pojazd", value = vehicleModel, inline = true},
            {name = "Cena", value = "$" .. price, inline = true},
            {name = "Metoda płatności", value = paymentMethodName, inline = true}
        })
        cb(true)
    else
        local moneyFieldName = paymentMethod == 'cash' and "Posiadane środki" or "Środki na koncie"
        SendWebhook("❌ Brak środków", "Gracz próbował wynająć pojazd bez wystarczających środków", 15158332, {
            {name = "Gracz", value = playerName .. " (" .. identifier .. ")", inline = true},
            {name = "Typ", value = rentalTypeName, inline = true},
            {name = "Pojazd", value = vehicleModel, inline = true},
            {name = "Wymagana cena", value = "$" .. price, inline = true},
            {name = moneyFieldName, value = "$" .. currentMoney, inline = true},
            {name = "Metoda płatności", value = paymentMethodName, inline = true}
        })
        cb(false)
    end
end)

RegisterNetEvent('exoticrp:returnVehicle')
AddEventHandler('exoticrp:returnVehicle', function(vehicleModel, rentalType)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    local playerName = GetPlayerName(source)
    local identifier = xPlayer.identifier
    local rentalTypeName = rentalType == "car" and "Samochód" or "Łódź"
    
    SendWebhook("🔄 Zwrot pojazdu", "Gracz zwrócił wynajęty pojazd", 3447003, {
        {name = "Gracz", value = playerName .. " (" .. identifier .. ")", inline = true},
        {name = "Typ", value = rentalTypeName, inline = true},
        {name = "Pojazd", value = vehicleModel or "Nieznany", inline = true}
    })
end)

AddEventHandler('playerDropped', function()
    RENTAL_COOLDOWN[source] = nil
end)