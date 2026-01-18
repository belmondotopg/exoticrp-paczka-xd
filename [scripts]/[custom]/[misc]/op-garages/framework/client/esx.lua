ESX = GetResourceState('es_extended') == 'started' and true or false

if not ESX then return end

Fr = {}

Framework = exports["es_extended"]:getSharedObject()
Fr.PlayerLoaded = 'esx:playerLoaded'
Fr.VehicleEncode = "vehicle"
Fr.identificatorTable = "identifier"
Fr.StoredTable = 'stored'
Fr.JobUpdateEvent = "esx:setJob"
Fr.OwnerTable = "owner"

function getGangName()
    if GetResourceState('op-crime') == 'started' then
        local orgData = exports['op-crime']:getPlayerOrganisation()

        if not orgData then return nil end

        return tostring(orgData.id)
    else
        if (PlayerData ~= nil and PlayerData.job ~= nil and PlayerData.job.name ~= nil) then
            return PlayerData.job.name
        end
        return nil
    end
end

function getGangGrade(cb) 
    if GetResourceState('op-crime') == 'started' then
        exports['op-crime']:playerGaragePermission(function(canOpen)
            if Config.ReverseGradeCheck then
                if canOpen then 
                    cb(50)
                else
                    cb(0)
                end
            else
                if canOpen then 
                    cb(0)
                else
                    cb(50)
                end
            end
        end)
    else
        if (PlayerData ~= nil and PlayerData.job ~= nil and PlayerData.job.grade ~= nil) then
            cb(type(PlayerData.job.grade) == "table" and PlayerData.job.grade.level or PlayerData.job.grade) 
        end
        return cb(nil)
    end
end

AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
    reloadGangGarages(job)
end)

Fr.TriggerServerCallback = function(...)
    return Framework.TriggerServerCallback(...)
end
Fr.GetVehicleProperties = function(vehicle) 
    return lib.getVehicleProperties(vehicle)
end
Fr.DeleteVehicle = function(vehicle, notNetworked)
    if Config.Addons.AdvancedParking and not notNetworked then
        exports["AdvancedParking"]:DeleteVehicle(vehicle, false)
    end
    return Framework.Game.DeleteVehicle(vehicle)
end
Fr.SpawnVehicle = function(vehicleModel, coords, heading, networked, cb)
    local model = type(vehicleModel) == 'number' and vehicleModel or joaat(vehicleModel)
    local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
    networked = networked == nil and true or networked

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    if not vector or not playerCoords then
        return
    end

    CreateThread(function()
        ScriptFunctions.RequestModel(model)

        local vehicle = CreateVehicle(model, vector.xyz, heading, networked, true)

        if networked then
            local id = NetworkGetNetworkIdFromEntity(vehicle)
            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(vehicle, true, true)
        end
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetModelAsNoLongerNeeded(model)
        SetVehRadioStation(vehicle, 'OFF')

        RequestCollisionAtCoord(vector.xyz)
        while not HasCollisionLoadedAroundEntity(vehicle) do
            Wait(0)
        end

        if cb then
            cb(vehicle)
        end
    end)
end
Fr.SetVehicleProperties = function(...) 
    return lib.setVehicleProperties(...)
end
Fr.GetPlayerData = function()
    return Framework.GetPlayerData()
end