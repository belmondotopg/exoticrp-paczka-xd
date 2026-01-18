local blockedHashes = {}
local hashesLoaded = false

Citizen.CreateThread(function()
    while not Config or not Config.BlockedVehicles do
        Citizen.Wait(100)
    end
    
    for vehicleName in Config.BlockedVehicles:gmatch("([^\r\n]+)") do
        vehicleName = vehicleName:match("^%s*(.-)%s*$") -- Trim whitespace
        if vehicleName and vehicleName ~= "" then
            local hash = GetHashKey(vehicleName)
            if hash and hash ~= 0 then
                blockedHashes[hash] = true
            end
        end
    end
    
    hashesLoaded = true
    local count = 0
    for _ in pairs(blockedHashes) do count = count + 1 end
    print(string.format("[exotic_blacklist] Loaded %d blocked vehicle hashes", count))
end)

local function CheckVehicle(vehicle)
    if not hashesLoaded or not vehicle or vehicle == 0 then 
        return 
    end
    
    if not DoesEntityExist(vehicle) then
        return
    end
    
    local vehicleModel = GetEntityModel(vehicle)
    if blockedHashes[vehicleModel] then
        local ped = PlayerPedId()
        if IsPedInVehicle(ped, vehicle, false) then
            TaskLeaveVehicle(ped, vehicle, 0)
            Citizen.Wait(300)
        end
        
        if DoesEntityExist(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleHasBeenOwnedByPlayer(vehicle, false)
            DeleteEntity(vehicle)
        end
        
        if Config.NotificationMessage then
            ESX.ShowNotification(Config.NotificationMessage)
        end
    end
end

AddEventHandler('baseevents:enteredVehicle', function(vehicle)
    Citizen.Wait(200)
    CheckVehicle(vehicle)
end)

local lastVehicle = 0
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= lastVehicle then
                lastVehicle = vehicle
                CheckVehicle(vehicle)
            end
        else
            lastVehicle = 0
        end
    end
end)
