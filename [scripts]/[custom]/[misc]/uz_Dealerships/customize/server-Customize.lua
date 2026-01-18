local function GetVehicleData(model)
    if not model then return nil end
    
    model = string.lower(model)
    
    for category, vehicles in pairs(Customize.Vehicles) do
        for _, vehicle in ipairs(vehicles) do
            if string.lower(vehicle.model) == model then
                return vehicle
            end
        end
    end
    
    return nil
end

function InsertVehicleToDatabase(playerData, vehicleModel, plate, ESX, callback)
    if ESX then
        local vehicleData = GetVehicleData(vehicleModel)
        local price = vehicleData and vehicleData.price or 0
        exports.esx_core:SendLog(playerData.source, "Zakupiono Pojazd", "Zakupiono pojazd: \nModel: " .. vehicleModel .. "\nNr. rej.: " .. plate .. "\nCena: " .. price .. "$", 'vehicleshop', '3066993')

        MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)', {
            playerData.identifier,
            plate,
            json.encode({model = joaat(vehicleModel), plate = plate})
        }, callback)
    else
        MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            playerData.PlayerData.license,
            playerData.PlayerData.citizenid,
            vehicleModel,
            GetHashKey(vehicleModel),
            '{}',
            plate,
            'pillboxgarage',
            0
        }, callback)
    end
end

exports('InsertVehicleToDatabase', InsertVehicleToDatabase)