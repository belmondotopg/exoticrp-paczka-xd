Framework = Framework or {}

-- Get the nearest players to a baseCoords within a maxDistance
-- @param baseCoords table The base coordinates
-- @param maxDistance number The maximum distance
-- @return table The nearest players
function Framework:GetClosestPlayers(baseCoords, maxDistance)
    if not baseCoords then
        baseCoords = GetEntityCoords(PlayerPedId())
    end

    local players = EventManager:awaitTriggerServerEvent("getClosestPlayers", { baseCoords = baseCoords, maxDistance = maxDistance })

    return players
end
exports("getClosestPlayers", function(baseCoords, maxDistance)
    return Framework:GetClosestPlayers(baseCoords, maxDistance)
end)

-- Get the nearest player to a baseCoords within a maxDistance
-- @param dataObject table The data object
-- @param options table The options
-- @return table The nearest player
function Framework:GetClosestPlayer(dataObject, options)
    local closestPlayers = self:GetClosestPlayers(dataObject.baseCoords, dataObject.maxDistance)
    if not closestPlayers then return end

    if #closestPlayers == 0 then return end

    local closestPlayer = closestPlayers[1]

    if options then
        if options.mapData then
            local mappedData = {}

            for key, value in pairs(closestPlayer) do
                if options.mapData[key] then
                    mappedData[key] = value
                end
            end

            return mappedData
        end
    end

    return closestPlayer
end
exports("getClosestPlayer", function(...)
    return Framework:GetClosestPlayer(...)
end)

-- Get a vehicle plate
-- @param dataObject table The data object
-- @return string The vehicle plate
function Framework:GetVehiclePlate(dataObject)
    if not TypeChecker:ValidateSchema(dataObject, TypeChecker.Framework.GetVehiclePlate) then
        return
    end

    if dataObject.returnWithFrameworkFormat then
        if self.currentFramework == "esx" then
            return self.object.Math.Trim(GetVehicleNumberPlateText(dataObject.vehicleEntity))
        elseif self.currentFramework == "qbcore" then
            return self.object.Functions.GetPlate(dataObject.vehicleEntity)
        end

        Logger:error("No framework found for getting vehicle plate")
    end
end
exports("getVehiclePlate", function(...)
    return Framework:GetVehiclePlate(...)
end)