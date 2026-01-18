RegisterNetEvent('vwk/exoticrp/getVehicleProps', function(vehicleModel, plate)
    local model = type(vehicleModel) == "number" and vehicleModel or GetHashKey(vehicleModel)
    local modelHash = ESX.Streaming.RequestModel(model)
    if not modelHash then
        return
    end
    
    local vehicle = CreateVehicle(modelHash, 0.0, 0.0, 0.0, 0.0, false, false)
    RequestCollisionAtCoord(0.0, 0.0, 0.0)
    while not HasCollisionLoadedAroundEntity(vehicle) do
        Wait(0)
    end
    
    Wait(100)
    
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    if vehicleProps then
        vehicleProps.plate = plate
    end
    
    DeleteEntity(vehicle)
    SetModelAsNoLongerNeeded(modelHash)
    TriggerServerEvent('vwk/exoticrp/vehiclePropsCallback', vehicleProps)
end)