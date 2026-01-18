limitedVehiclesConfig = {}
limitedVehiclesConfig.PedLocation = {
    coords = vec3(-555.71881103516, -185.78956604004, 38.221118927002),
    heading = 210.0
}
limitedVehiclesConfig.PedModel = 's_m_m_highsec_01'
limitedVehiclesConfig.ClaimPrice = 200000

local limitedVehiclePed = nil

local function formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1 %2')
        if k == 0 then
            break
        end
    end
    return formatted
end

local function GetVehicleLabel(model)
    local hash = type(model) == "string" and joaat(model) or model
    local makeName = GetMakeNameFromVehicleModel(hash)
    local modelName = GetDisplayNameFromVehicleModel(hash)
    local label = GetLabelText(makeName) .. " " .. GetLabelText(modelName)
    
    if makeName == "CARNOTFOUND" or modelName == "CARNOTFOUND" then
        label = tostring(model)
    else
        if GetLabelText(modelName) == "NULL" and GetLabelText(makeName) == "NULL" then
            label = (makeName or "") .. " " .. (modelName or "")
        elseif GetLabelText(makeName) == "NULL" then
            label = GetLabelText(modelName)
        end
    end
    
    return label
end

local function openLimitedVehicleMenu()
    TriggerServerEvent('esx_limitedvehicles:checkVehicles')
end

RegisterNetEvent('esx_limitedvehicles:showVehicles', function(vehicles)
    if not vehicles or #vehicles == 0 then
        return
    end
    
    local options = {}
    for _, vehicle in ipairs(vehicles) do
        local vehicleLabel = GetVehicleLabel(vehicle.vehicle_model)
        table.insert(options, {
            title = vehicleLabel,
            description = "Cena odbioru: $" .. formatNumber(limitedVehiclesConfig.ClaimPrice),
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Odbierz pojazd limitowany',
                    content = 'Czy na pewno chcesz odebrać pojazd ' .. vehicleLabel .. ' za $' .. formatNumber(limitedVehiclesConfig.ClaimPrice) .. '?',
                    centered = true,
                    cancel = true
                })
                
                if confirm == 'confirm' then
                    TriggerServerEvent('esx_limitedvehicles:claimVehicle', vehicle.id)
                end
            end
        })
    end
    
    lib.registerContext({
        id = 'limited_vehicles_menu',
        title = 'Pojazdy limitowane do odebrania',
        options = options
    })
    
    lib.showContext('limited_vehicles_menu')
end)

CreateThread(function()
    local pedModel = GetHashKey(limitedVehiclesConfig.PedModel)
    lib.requestModel(pedModel)
    
    limitedVehiclePed = CreatePed(4, pedModel, limitedVehiclesConfig.PedLocation.coords.x, limitedVehiclesConfig.PedLocation.coords.y,
    limitedVehiclesConfig.PedLocation.coords.z - 1.0, limitedVehiclesConfig.PedLocation.heading, false, true)
    
    FreezeEntityPosition(limitedVehiclePed, true)
    SetEntityInvincible(limitedVehiclePed, true)
    SetBlockingOfNonTemporaryEvents(limitedVehiclePed, true)
    
    exports.ox_target:addLocalEntity(limitedVehiclePed, {
        {
            name = 'limited_vehicle_pickup',
            label = 'Odbierz pojazd limitowany',
            icon = 'fas fa-car',
            distance = 2.5,
            onSelect = function()
                openLimitedVehicleMenu()
            end
        }
    })
end)

RegisterNetEvent('esx_limitedvehicles:getVehicleProps', function(vehicleModel, plate, vehicleId)
    CreateThread(function()
        if not vehicleModel or not plate or not vehicleId then
            return
        end
        
        local model = type(vehicleModel) == "number" and vehicleModel or joaat(vehicleModel)
        
        local success, modelHash = pcall(function()
            return lib.requestModel(model, 5000)
        end)
        
        if not success or not modelHash then
            lib.notify({
                title = 'Błąd',
                description = 'Nieprawidłowy model pojazdu!',
                type = 'error'
            })
            return
        end
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local spawnCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z - 500.0)
        
        local vehicle = CreateVehicle(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, false, false)
        
        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
            SetModelAsNoLongerNeeded(modelHash)
            return
        end
        
        SetEntityAsMissionEntity(vehicle, true, true)
        SetEntityCollision(vehicle, false, false)
        SetEntityAlpha(vehicle, 0, false)
        FreezeEntityPosition(vehicle, true)
        SetEntityInvincible(vehicle, true)
        
        SetVehicleFixed(vehicle)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
        
        Wait(100)
        
        local vehicleProps = exports.ox_lib:getVehicleProperties(vehicle) or ESX.Game.GetVehicleProperties(vehicle)
        if not vehicleProps then
            DeleteEntity(vehicle)
            SetModelAsNoLongerNeeded(modelHash)
            return
        end
        
        vehicleProps.plate = plate
        vehicleProps.bodyHealth = 1000.0
        vehicleProps.engineHealth = 1000.0
        vehicleProps.tankHealth = 1000.0
        vehicleProps.fuelLevel = 100.0
        vehicleProps.oilLevel = 100.0
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
        
        DeleteEntity(vehicle)
        SetModelAsNoLongerNeeded(modelHash)
        
        TriggerServerEvent('esx_limitedvehicles:vehiclePropsCallback', vehicleProps, plate, vehicleId)
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    if limitedVehiclePed and DoesEntityExist(limitedVehiclePed) then
        DeleteEntity(limitedVehiclePed)
    end
end)
