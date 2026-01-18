local Entity = Entity
local VehToNet = VehToNet
local ox_inventory = exports.ox_inventory

local BlockedLocks = {
    [13] = true,
    [8] = true
}

local BlockedEngine = {
    [13] = true
}

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('coords', function(coords)
    cacheCoords = coords
end)


local function GetNearestVehicleInFront(ped, distance)
    local pedCoords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)

    local to = pedCoords + forward * distance

    local ray = StartShapeTestRay(
        pedCoords.x, pedCoords.y, pedCoords.z + 0.3,
        to.x, to.y, to.z + 0.3,
        10, ped, 0
    )

    local _, hit, endCoords, _, entity = GetShapeTestResult(ray)

    if hit == 1 and entity and DoesEntityExist(entity) and IsEntityAVehicle(entity) then
        return entity
    end

    return nil
end

local function EngineToggle()
    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
    local veh = cache.vehicle

    if not veh or veh == 0 then return end
    local status = IsVehicleEngineOn(veh)

    if BlockedEngine[GetVehicleClass(veh)] then return end
    if GetPedInVehicleSeat(veh, -1) ~= cache.ped then return end

    lib.callback('esx_carkeys:ToggleEngine', false, function(data)
        SetVehicleKeepEngineOnWhenAbandoned(veh, true)
        if data then
            if data == "Key" then
                return ESX.ShowNotification("Znalazłeś kluczyki do pojazdu.")
            end
            
            if not status then
                SetVehicleEngineOn(veh, true, false, true)
                ESX.ShowNotification("Silnik włączony.")
            else
                SetVehicleEngineOn(veh, false, false, true)
                ESX.ShowNotification("Silnik wyłączony.")
            end
        else
            if status then
                SetVehicleEngineOn(veh, false, false, true)
                ESX.ShowNotification("Silnik wyłączony.")
            else
                ESX.ShowNotification("Nie posiadasz kluczy do auta.")
            end
        end
    end, not status)
end

local function HandleLockStatus(lockedVehicle, playAnim)
    if lockedVehicle == "Key" then
        return ESX.ShowNotification("Znalazłeś kluczyki do pojazdu.")
    end

    if lockedVehicle then
        ESX.ShowNotification("Pojazd zamknięty.")
        TriggerServerEvent('interact-sound_SV:PlayWithinDistance', 10.0, 'lock', 0.3)
    else
        ESX.ShowNotification("Pojazd otwarty.")
        TriggerServerEvent('interact-sound_SV:PlayWithinDistance', 10.0, 'unlock', 0.3)
    end

    if playAnim then
        lib.requestAnimDict('gestures@m@standing@casual')
        TaskPlayAnim(cachePed, "gestures@m@standing@casual", "gesture_you_soft", 3.0, 1.0, -1, 48, 0, 0, 0, 0)
    end
end

local function ToggleLock()
    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end

    local isInside = false
    local targetVehicle = cacheVehicle

    if targetVehicle and targetVehicle ~= 0 and DoesEntityExist(targetVehicle) then 
        isInside = true
    else
        targetVehicle = GetNearestVehicleInFront(cachePed, 5.0)
        if not targetVehicle or targetVehicle == 0 or not DoesEntityExist(targetVehicle) then
            local closestVehicle, closestDistance = ESX.Game.GetClosestVehicle(cacheCoords)
            if closestVehicle and closestVehicle ~= 0 and closestDistance <= 3.0 and DoesEntityExist(closestVehicle) then
                targetVehicle = closestVehicle
            else
                local vehicles = GetGamePool('CVehicle')
                local bestVeh = nil
                local bestDist = 999999
                
                for i = 1, #vehicles do
                    local veh = vehicles[i]
                    if DoesEntityExist(veh) then
                        local dist = #(GetEntityCoords(veh) - cacheCoords)
                        if dist <= 3.0 and dist < bestDist then
                            bestVeh = veh
                            bestDist = dist
                        end
                    end
                end
                
                if bestVeh then
                    targetVehicle = bestVeh
                end
            end
        end
    end

    if not targetVehicle or targetVehicle == 0 or not DoesEntityExist(targetVehicle) then return end

    if BlockedLocks[GetVehicleClass(targetVehicle)] then return end

    if IsControlPressed(0, 21) and isInside then
        TriggerServerEvent("esx_carkeys:putKeys")
        SetVehicleEngineOn(targetVehicle, false, false, false)
        Entity(targetVehicle).state.engine = false
        return
    end

    ---@type boolean | "Key"
    local lockedVehicle = lib.callback.await("esx_carkeys:toggleLockState", 0, NetworkGetNetworkIdFromEntity(targetVehicle))
    if lockedVehicle == nil then return end
    HandleLockStatus(lockedVehicle, isInside)
end

exports("kluczyki", function(data, slot)
    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end

    local kluczyk = ox_inventory:Search('slots', data.name)

    ---@param entity number Entity handle
    ---@param targetPlate string Required plate
    ---@param maxDistance number?
    ---@return boolean IsMatching, number? Distance
    local function vehicleMatching(entity, targetPlate, maxDistance)
        if not entity or not DoesEntityExist(entity) then return false end
        if GetVehicleNumberPlateText(entity) ~= targetPlate then return false end
        if not maxDistance then return true end

        local distance = #(GetEntityCoords(entity) - cacheCoords)
        if distance <= maxDistance then
            return true, distance
        end
    end

    for _, v in pairs(kluczyk) do
        if v.slot == data.slot then
            local blacha = v.metadata.plate
            if not blacha then
                ESX.ShowNotification("Błędne kluczyki - brak numeru rejestracyjnego.")
                return
            end
            
            local foundVehicle = nil
            local vehicleDistance = 999999
            
            if vehicleMatching(cacheVehicle, blacha) then
                foundVehicle = cacheVehicle
                vehicleDistance = 0
            end
            
            if not foundVehicle then
                local vehicles = GetGamePool('CVehicle')
                for i = 1, #vehicles do
                    local veh = vehicles[i]
                    local isMatching, nextDistance = vehicleMatching(veh, blacha, vehicleDistance)
                    if isMatching then
                        foundVehicle = veh
                        vehicleDistance = nextDistance or vehicleDistance
                    end
                end
            end
            
            if not foundVehicle then
                for _, veh in ipairs(ESX.Game.GetVehicles()) do
                    local isMatching, nextDistance = vehicleMatching(veh, blacha, vehicleDistance)
                    if isMatching then
                        foundVehicle = veh
                        vehicleDistance = nextDistance or vehicleDistance
                    end
                end
            end

            if foundVehicle and vehicleDistance > 50 then
                return ESX.ShowNotification("Pojazd jest za daleko (max 50m).")
            elseif not foundVehicle then
                return ESX.ShowNotification(("Nie znaleziono pojazdu z rejestracją: %s"):format(blacha))
            end

            ---@type boolean | "Key"
            local lockedVehicle = lib.callback.await("esx_carkeys:toggleLockState", 0,
                NetworkGetNetworkIdFromEntity(foundVehicle))
            HandleLockStatus(lockedVehicle, foundVehicle == cacheVehicle)
        end
    end
end)

RegisterNetEvent("esx_carkeys:startVehicle", function(veh)
    if not veh then return end
    SetVehicleEngineOn(veh, true, false, true)
    Entity(veh).state.engine = true
    ESX.ShowNotification("Silnik włączony.")
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        if cacheVehicle and cacheVehicle ~= 0 and not BlockedEngine[GetVehicleClass(cacheVehicle)] then
            if not Entity(cacheVehicle).state.engine then
                DisableControlAction(0, 32, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 87, true)
                DisableControlAction(0, 129, true)
                DisableControlAction(0, 136, true)
                sleep = 0
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    local lastVehicle = 0
    while true do
        Citizen.Wait(250)
        if cacheVehicle and cacheVehicle ~= 0 and not BlockedEngine[GetVehicleClass(cacheVehicle)] then
            if cacheVehicle ~= lastVehicle then
                lastVehicle = cacheVehicle
                SetVehicleEngineOn(cacheVehicle, true, false, true)
                Entity(cacheVehicle).state.engine = true
            end
        else
            lastVehicle = 0
        end
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         local sleep = 500

--         if cacheVehicle and cacheVehicle ~= 0 and IsControlPressed(2, 75) then
--             if DoesEntityExist(cacheVehicle) then
--                 local engine = GetIsVehicleEngineRunning(cacheVehicle)
--                 repeat
--                     if engine then
--                         sleep = 16
--                         SetVehicleEngineOn(cacheVehicle, true, true, true)
--                     end
--                     Citizen.Wait(16)
--                 until not cacheVehicle
--             end
--         end
        
--         Citizen.Wait(sleep)
--     end
-- end)

lib.addKeybind({
	name = 'engineToggle',
	description = 'Włącz/wyłącz silnik',
	defaultKey = 'Y',
	onPressed = function()
		EngineToggle()
	end
})

lib.addKeybind({
	name = 'lockToggle',
	description = 'Zablokuj/odblokuj pojazd',
	defaultKey = 'U',
	onPressed = function()
		ToggleLock()
	end
})

RegisterNetEvent('esx_carkeys:lockpick:try', function()
    lib.requestAnimDict('mp_arresting')

    if cache.vehicle then
        local class = GetVehicleClass(cache.vehicle)
        if BlockedEngine[class] then return end

        local driver = GetPedInVehicleSeat(cache.vehicle, -1)
        if driver ~= cache.ped then return end

        if not IsVehicleEngineOn(cache.vehicle) then
            local success = lib.skillCheck({'medium', 'easy', {areaSize = 60, speedMultiplier = 2}, 'medium', 'medium'})

            if success then
                SetVehicleEngineOn(cache.vehicle, true, false, true)
                Entity(cache.vehicle).state.engine = true
            end
        end
    else
        local class = GetVehicleClass(cacheVehicle)
        if BlockedLocks[class] then return end

        local entity = GetNearestVehicleInFront(cache.ped, 4.0)
        if not entity then return end

        local locked = GetVehicleDoorLockStatus(entity)
        if locked == 2 then
            local success = lib.skillCheck({'medium', 'easy', {areaSize = 60, speedMultiplier = 2}, 'medium', 'medium', 'easy', {areaSize = 60, speedMultiplier = 2}})

            if success then
                TaskPlayAnim(cache.ped, "mp_arresting", "a_uncuff", 1.0, -1.0, 5500, 0, 1, true, true, true)
                FreezeEntityPosition(cache.ped, true)

                SetVehicleDoorsLocked(entity, 1)
                SetVehicleDoorsLockedForAllPlayers(entity, false)
                TriggerServerEvent("esx_carkeys:updateLockStatus", VehToNet(entity), 1)

                local vehicleState = Entity(entity).state
                if vehicleState and vehicleState.InRobbery then
                    SetVehicleDoorsLocked(entity, 1)
                    SetVehicleDoorsLockedForAllPlayers(entity, false)
                end

                Wait(3500)

                SetVehicleAlarm(entity, true)
                SetVehicleAlarmTimeLeft(entity, 10000)

                FreezeEntityPosition(cache.ped, false)
            end
        end
    end
end)

AddStateBagChangeHandler("locked", "", function(bagName, _, value)
    local vehicle = GetEntityFromStateBagName(bagName)
    if not vehicle or not DoesEntityExist(vehicle) then return end

    SetVehicleDoorsLocked(vehicle, value)
    SetVehicleDoorsLockedForAllPlayers(vehicle, value == 2 or value == 4)
end)