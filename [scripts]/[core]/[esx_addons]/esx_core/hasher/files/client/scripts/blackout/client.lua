-- local Citizen = Citizen
-- local RegisterNetEvent = RegisterNetEvent
-- local AddEventHandler = AddEventHandler
-- local TriggerServerEvent = TriggerServerEvent
-- local TriggerEvent = TriggerEvent
-- local LocalPlayer = LocalPlayer

-- local libCache = lib.onCache
-- local cacheVehicle = cache.vehicle

-- LocalPlayer.state:set("Belt", false, true)

-- libCache('vehicle', function(vehicle)
--     cacheVehicle = vehicle
--     if cacheVehicle == false then
--         LocalPlayer.state:set("Belt", false, true)
--     end
-- end)

-- local function IsCar(v, ignoreBikes)
--     if ignoreBikes and (IsThisModelABike(GetEntityModel(v)) or IsThisModelAQuadbike(GetEntityModel(v)) or IsThisModelAPlane(GetEntityModel(v)) or IsThisModelAHeli(GetEntityModel(v)) or IsThisModelAJetski(GetEntityModel(v)) or IsThisModelABoat(GetEntityModel(v)) or IsThisModelAnAmphibiousQuadbike(GetEntityModel(v))) then
--         return false
--     end
--     local vc = GetVehicleClass(v)
--     return (vc >= 0 and vc <= 12) or vc == 17 or vc == 18 or vc == 20
-- end

-- local function pasyState()
--     return LocalPlayer.state.Belt
-- end

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(5)
--         if cacheVehicle and IsCar(cacheVehicle, true) and not LocalPlayer.state.Belt and not LocalPlayer.state.InKomis and not LocalPlayer.state.InBroker then
--             TriggerServerEvent("interact-sound_SV:PlayOnSource", "pasy-beep", 0.25)
--             Citizen.Wait(1500)
--         else
--             Citizen.Wait(2000)
--         end
--     end
-- end)

-- RegisterNetEvent('esx_core:esx_blackout:belt')
-- AddEventHandler('esx_core:esx_blackout:belt', function(status)
--     if cacheVehicle then
--         LocalPlayer.state:set("Belt", status, true)
--         for i = -1, GetVehicleNumberOfPassengers(cacheVehicle) do
--             local ped = GetPedInVehicleSeat(cacheVehicle, i)
--             if ped and ped ~= 0 then
--                 TriggerServerEvent("interact-sound_SV:PlayOnSource", (LocalPlayer.state.Belt and 'belton' or 'beltoff'), 0.1)
--             end
--         end
--     end
-- end)

-- lib.addKeybind({
--     name = 'pasy',
--     description = 'Pasy',
--     defaultKey = 'B',
--     onPressed = function()
--         if IsCar(cacheVehicle, true) then
--             TriggerEvent('esx_core:esx_blackout:belt', not LocalPlayer.state.Belt)
--         end
--     end
-- })

-- CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         if cacheVehicle and LocalPlayer.state.Belt then
--             DisableControlAction(0, 75, true)
--             DisableControlAction(27, 75, true)
--         else
--             Citizen.Wait(2000)
--         end
--     end
-- end)

-- CreateThread(function()
--     local prevSpeed = 0.0
--     while true do
--         Wait(50)
--         if cacheVehicle and IsCar(cacheVehicle, true) and not LocalPlayer.state.Belt then
--             local speed = GetEntitySpeed(cacheVehicle) * 3.6
--             if (prevSpeed - speed) >= 35.0 and speed <= 40.0 then
--                 local ped = PlayerPedId()
--                 if IsPedInAnyVehicle(ped, false) then
--                     TaskLeaveVehicle(ped, cacheVehicle, 4160)
--                     Wait(500)
--                     SetPedToRagdoll(ped, 1000, 1000, 0, false, false, false)
--                 end
--             end
--             prevSpeed = speed
--         else
--             prevSpeed = 0.0
--             Wait(500)
--         end
--     end
-- end)

-- exports('pasyState', pasyState)
-- exports('IsCar', IsCar)

-- AddEventHandler('baseevents:onPlayerDied', function()
--     local ped = PlayerPedId()
--     if cacheVehicle and IsPedInVehicle(ped, cacheVehicle, false) and not LocalPlayer.state.Belt then
--         TaskLeaveVehicle(ped, cacheVehicle, 4160)
--         Wait(150)
--         SetPedToRagdoll(ped, 1500, 1500, 0, false, false, false)
--     end
-- end)