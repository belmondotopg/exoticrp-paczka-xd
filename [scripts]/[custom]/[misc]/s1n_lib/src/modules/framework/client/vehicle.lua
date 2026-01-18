Framework = Framework or {}

-- Get the vehicle properties depending on the framework
-- @param vehicleEntity number The vehicle entity
-- @return table The vehicle properties
function Framework:GetVehicleProperties(vehicleEntity)
    if self.currentFramework == "esx" then
        return self.object.GetVehicleProperties(vehicleEntity)
    elseif self.currentFramework == "qbcore" then
        return self.object.Functions.GetVehicleProperties(vehicleEntity)
    end

    Logger:error(("No framework found for getting vehicle properties for vehicleEntity=%s"):format(vehicleEntity))

    return false
end
exports("getVehicleProperties", function(...)
    return Framework:GetVehicleProperties(...)
end)

-- Set the vehicle properties depending on the framework
-- @param dataObject table The data object
function Framework:SetVehicleProperties(dataObject)
    if self.currentFramework == "esx" then
        self.object.SetVehicleProperties(dataObject.vehicleEntity, dataObject.properties)
    elseif self.currentFramework == "qbcore" then
        self.object.Functions.SetVehicleProperties(dataObject.vehicleEntity, dataObject.properties)
    end

    -- Fixes issues with vehicle colors
    SetVehicleExtraColours(dataObject.vehicleEntity, dataObject.properties.pearlescentColor, dataObject.properties.wheelColor)
end
exports("setVehicleProperties", function(...)
    return Framework:SetVehicleProperties(...)
end)

-- Spawn a vehicle depending on the framework
-- @param dataObject table The data object
function Framework:SpawnVehicle(dataObject)
    if self.currentFramework == "esx" then
        self.object.SpawnVehicle(dataObject.model, dataObject.coords, dataObject.heading, dataObject.onCallback)

        return true
    elseif self.currentFramework == "qbcore" then
        self.object.Functions.SpawnVehicle(dataObject.model, dataObject.onCallback, { x = dataObject.coords.x, y = dataObject.coords.y, z = dataObject.coords.z, w = dataObject.heading }, true)

        return true
    end

    Logger:error(("No framework found for spawning vehicle for model=%s"):format(dataObject.model))

    return false
end
exports("spawnVehicle", function(...)
    return Framework:SpawnVehicle(...)
end)