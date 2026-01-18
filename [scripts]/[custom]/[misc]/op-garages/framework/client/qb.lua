QBCore = GetResourceState('qb-core') == 'started' and true or false
local isQBox = GetResourceState('qbx_core') == 'started' and true or false

if not QBCore then return end
if isQBox then return end

Fr = {}

Framework = exports['qb-core']:GetCoreObject()
Fr.PlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
Fr.VehicleEncode = "mods"
Fr.identificatorTable = "citizenid"
Fr.StoredTable = 'state'
Fr.JobUpdateEvent = "QBCore:Client:OnJobUpdate"
Fr.OwnerTable = "citizenid"

function getGangName()
    if GetResourceState('op-crime') == 'started' then
        local orgData = exports['op-crime']:getPlayerOrganisation()

        if not orgData then return nil end

        return tostring(orgData.id)
    else
        if (PlayerData ~= nil and PlayerData.gang ~= nil and PlayerData.gang.name ~= nil) then
            return PlayerData.gang.name
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
        if (PlayerData ~= nil and PlayerData.gang ~= nil and PlayerData.gang.grade ~= nil) then
            cb(type(PlayerData.gang.grade) == "table" and PlayerData.gang.grade.level or PlayerData.gang.grade)
        end
        return cb(nil)
    end
end

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gangData)
    PlayerData.gang = gangData
    reloadGangGarages(gangData)
end)

Fr.TriggerServerCallback = function(...)
    return Framework.Functions.TriggerCallback(...)
end
Fr.GetVehicleProperties = function(vehicle) 
    return lib.getVehicleProperties(vehicle)
end
Fr.DeleteVehicle = function(vehicle)
    if Config.Addons.AdvancedParking then
        exports["AdvancedParking"]:DeleteVehicle(vehicle, false)
    end
    return Framework.Functions.DeleteVehicle(vehicle)
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
    return Framework.Functions.GetPlayerData()
end