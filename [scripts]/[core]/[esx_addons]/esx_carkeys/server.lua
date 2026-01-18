local ox_inventory = exports.ox_inventory
local keys = {}
local Entity = Entity
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
local GetCurrentResourceName = GetCurrentResourceName

local function GetItemMetadata(plate)
    return {plate = plate, id = keys[plate], description = 'Rejestracja pojazdu: '..plate}
end

local function AddKey(src, plate)
    if not plate or not src then return end
    local itemID = plate.."_"..math.random(1, 99999999)
    
    ox_inventory:AddItem(src, "kluczyki", 1, {plate = plate, id = itemID, description = 'Rejestracja pojazdu: '..plate}, nil, function(success, reason)
        if success then
            keys[plate] = itemID
        elseif reason == "inventory_full" then
            local xPlayer = ESX.GetPlayerFromId(src)
            xPlayer.showNotification("Nie dasz rady unieść kluczy")
        end
    end)
end

local function RemoveKey(src, plate, onlyDelete)
    ox_inventory:RemoveItem(src, "kluczyki", 1, GetItemMetadata(plate))
    
    if not onlyDelete then
        keys[plate] = nil
    end
end

lib.callback.register('esx_carkeys:ToggleEngine', function(source, status, ignoreKeys)
    if type(status) ~= "boolean" then return end
    
    local src = source
    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
    local plate = GetVehicleNumberPlateText(veh)

    if not plate then return end
    
    local hasKey = ox_inventory:GetItem(src, "kluczyki", GetItemMetadata(plate), true) > 0

    if hasKey or ignoreKeys then
        Entity(veh).state:set("engine", status, true)
        return true
    end
    
    if not keys[plate] then
        AddKey(src, plate)
        return "Key"
    end
    
    return false
end)

---@param veh number Entity
---@return boolean IsFree
local function isVehicleFree(veh)
    for i = -1, 6 do
        local pedinSeat = GetPedInVehicleSeat(veh, i)
        if (pedinSeat ~= 0) then
            return false
        end
    end
    return true
end

lib.callback.register("esx_carkeys:toggleLockState", function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or not DoesEntityExist(vehicle) then return nil end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then return nil end

    local keyCount = ox_inventory:GetItem(source, "kluczyki", GetItemMetadata(plate), true)

    if keyCount > 0 then
        local isLocked = Entity(vehicle).state.locked
        local lockStatus = (isLocked) and 1 or 2

        if isLocked == 1 then
            lockStatus = isVehicleFree(vehicle) and 2 or 4
        end

        Entity(vehicle).state:set("locked", lockStatus, true)

        return (isLocked ~= 2 and isLocked ~= 4)
    end

    if not keys[plate] and GetVehiclePedIsIn(GetPlayerPed(source), false) == vehicle then
        AddKey(source, plate)
        return "Key"
    end

    return nil
end)

RegisterServerEvent("esx_carkeys:putKeys", function()
    local src = source
    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
    
    if not veh or veh == 0 then return end
    
    local plate = GetVehicleNumberPlateText(veh)

    if not plate then return end

    local hasKey = ox_inventory:GetItem(src, "kluczyki", GetItemMetadata(plate), true) > 0
    local xPlayer = ESX.GetPlayerFromId(src)

    if hasKey and xPlayer then
        xPlayer.showNotification("Odłożyłeś kluczyki.")
        Entity(veh).state:set("engine", false, true)
        RemoveKey(src, plate)
    end
end)

RegisterServerEvent("esx_carkeys:getKeys", function(plateSent)
    local src = source
    local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
    local plate = GetVehicleNumberPlateText(veh)

    if not plate and not plateSent then return end
    
    local vehPlate = plate or plateSent

    local hasKey = ox_inventory:GetItem(src, "kluczyki", GetItemMetadata(vehPlate), true) > 0

    if not hasKey then
        AddKey(src, vehPlate)
    end
end)

RegisterServerEvent("esx_carkeys:deleteKeys", function(plate)
    if not keys[plate] then return end

    local src = source
    local hasKey = ox_inventory:GetItem(src, "kluczyki", GetItemMetadata(plate), true) > 0
    local xPlayer = ESX.GetPlayerFromId(src)

    if hasKey then
        xPlayer.showNotification("Odłożyłeś kluczyki.")
        RemoveKey(src, plate)
    end
end)

RegisterServerEvent("esx_carkeys:updateLockStatus", function(netId, status)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) then return end

    local plate = GetVehicleNumberPlateText(veh)
    if plate then
        SetVehicleDoorsLocked(veh, status)
    end
end)

AddEventHandler('esx_carkeys:vehicleDeleted', function(src, plate)
    if not keys[plate] then return end
    RemoveKey(src, plate)
end)

AddEventHandler("ls:blockCar", function(plate)
    keys[plate] = "BLOCKED"
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    Citizen.Wait(5000)

    playerId = tonumber(playerId)

    if not playerId then return end

    local data = ox_inventory:Search(playerId, "slots", "kluczyki")

    if data then
        for i = 1, #data do
            local metadata = data[i].metadata
            local plate = metadata.plate
            
            if plate then
                if not keys[plate] then
                    ox_inventory:RemoveItem(playerId, "kluczyki", data[i].count, {plate = plate, id = metadata.id, description = 'Rejestracja pojazdu: '..plate})
                elseif metadata.id and metadata.id ~= keys[plate] then
                    ox_inventory:RemoveItem(playerId, "kluczyki", data[i].count, {plate = plate, id = metadata.id, description = 'Rejestracja pojazdu: '..plate})
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in ipairs(xPlayers) do
        local count = ox_inventory:Search(xPlayer.source, "count", "kluczyki")
        if count > 0 then
            ox_inventory:RemoveItem(xPlayer.source, "kluczyki", count)
        end
    end
end)