local ESX = ESX
local SetMinimapClipType = SetMinimapClipType
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local RemoveMultiplayerWalletCash = RemoveMultiplayerWalletCash
local RemoveMultiplayerBankCash = RemoveMultiplayerBankCash
local SetIgnoreLowPriorityShockingEvents = SetIgnoreLowPriorityShockingEvents
local SetPoliceIgnorePlayer = SetPoliceIgnorePlayer
local SetFarDrawVehicles = SetFarDrawVehicles
local IsPedShooting = IsPedShooting
local IsControlPressed = IsControlPressed
local SetPlayerWantedLevelNow = SetPlayerWantedLevelNow
local SetPlayerWantedLevel = SetPlayerWantedLevel
local SetPlayerWantedLevelNoDrop = SetPlayerWantedLevelNoDrop
local SetPlayerCanBeHassledByGangs = SetPlayerCanBeHassledByGangs
local SetPlayerLockonRangeOverride = SetPlayerLockonRangeOverride
local SetPlayerTargetingMode = SetPlayerTargetingMode
local SetPedCanBeTargetted = SetPedCanBeTargetted
local GetIsTaskActive = GetIsTaskActive
local SetPedConfigFlag = SetPedConfigFlag
local SetPedIntoVehicle = SetPedIntoVehicle
local GetVehicleClass = GetVehicleClass
local GetPedInVehicleSeat = GetPedInVehicleSeat
local IsEntityInAir = IsEntityInAir
local GetEntityRoll = GetEntityRoll
local GetVehicleNumberPlateText = GetVehicleNumberPlateText
local DoesEntityExist = DoesEntityExist
local ToggleUsePickupsForPlayer = ToggleUsePickupsForPlayer
local SetPedDropsWeaponsWhenDead = SetPedDropsWeaponsWhenDead
local IsPedArmed = IsPedArmed
local DisableControlAction = DisableControlAction
local SetAmbientZoneState = SetAmbientZoneState
local ClearAmbientZoneState = ClearAmbientZoneState
local SetGarbageTrucks = SetGarbageTrucks
local SetRandomBoats = SetRandomBoats
local SetRandomTrains = SetRandomTrains
local SetMaxWantedLevel = SetMaxWantedLevel
local SetRelationshipBetweenGroups = SetRelationshipBetweenGroups
local EnableDispatchService = EnableDispatchService
local IsModelAVehicle = IsModelAVehicle
local SetScenarioTypeEnabled = SetScenarioTypeEnabled
local SetScenarioGroupEnabled = SetScenarioGroupEnabled
local SetVehicleModelIsSuppressed = SetVehicleModelIsSuppressed
local IsModelAPed = IsModelAPed
local SetPedModelIsSuppressed = SetPedModelIsSuppressed
local SetCreateRandomCops = SetCreateRandomCops
local SetCreateRandomCopsNotOnScenarios = SetCreateRandomCopsNotOnScenarios
local SetCreateRandomCopsOnScenarios = SetCreateRandomCopsOnScenarios
local SetPlayerCanDoDriveBy = SetPlayerCanDoDriveBy
local LocalPlayer = LocalPlayer
local libCache = lib.onCache
local cachePed = cachePed
local cachePlayerId = cache.playerId
local cacheVehicle = cache.vehicle

local relationships = {
    `AMBIENT_GANG_LOST`,
    `AMBIENT_GANG_MEXICAN`,
    `AMBIENT_GANG_FAMILY`,
    `AMBIENT_GANG_BALLAS`,
    `AMBIENT_GANG_MARABUNTE`,
    `AMBIENT_GANG_CULT`,
    `AMBIENT_GANG_SALVA`,
    `AMBIENT_GANG_WEICHENG`,
    `AMBIENT_GANG_HILLBILLY`,
    `GANG_1`,
    `GANG_2`,
    `GANG_9`,
    `GANG_10`,
    `FIREMAN`,
    `MEDIC`,
    `COP`
}

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('playerId', function(playerId)
    cachePlayerId = playerId
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

RegisterNetEvent('esx:playerLoaded', function()
    TriggerServerEvent('esx_core:checkInMotel')
    Wait(1000)
    TriggerServerEvent('esx_dmvschool:reloadLicense')
    Wait(1000)
    TriggerServerEvent('esx_flightschool:reloadLicense')
end)

CreateThread(function()
    ClearAmbientZoneState("collision_ybmrar", false)
    SetAmbientZoneState("collision_ybmrar", false, false)

    AddEventHandler('esx:setJob', function(data)
        if data.grade_label == "Commissaris" then return end
    end)

    local protectedEvents = {
        "esx:setJob",
        "esx:spawnVehicle"
    }
    
    for _, eventName in ipairs(protectedEvents) do
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, function()
            local rscInv = GetInvokingResource()
            if rscInv ~= nil then
                print('[exotic-ac] Tried to trigger protected event:', eventName)
                CancelEvent()
            end
        end)
    end
end)

local function Kolba()
    CreateThread(function()
        while true do
            local sleep = 500
            
            if IsPedArmed(cachePed, 6) then
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 141, true)
                DisableControlAction(1, 142, true)
                sleep = 5
            end

            Wait(sleep)
        end
    end)
end

local function BlockWeaponDrops()
    for i = 1, #Config.PickupList do
        ToggleUsePickupsForPlayer(cachePlayerId, Config.PickupList[i], false)
        RemoveAllPickupsOfType(Config.PickupList[i])
    end
end

local function WeaponDrops()
    CreateThread(function()
        while true do 
            Wait(500)
            BlockWeaponDrops()

            local pedPool = GetGamePool('CPed')
            for _, ped in ipairs(pedPool) do
                SetPedDropsWeaponsWhenDead(ped, false)
            end
        end
    end)
end

local function ScenariosLoop()
    Citizen.InvokeNative(`ADD_TEXT_ENTRY`, 'FE_THDR_GTAO', 'ExoticRP | WL-OFF | discord.gg/exoticrp')
    SetFarDrawVehicles(false)
    SetPedConfigFlag(cachePed, 149, true)
    SetPedConfigFlag(cachePed, 438, true)
end

local function IdleCam()
    CreateThread(function()
        while true do
            InvalidateIdleCam()
            InvalidateVehicleIdleCam()
            Wait(5000)
        end
    end)
end

local function AntiVehicleRoll()
    CreateThread(function()
        while true do
            local sleep = 500
            
            if cacheVehicle then
                local vehicleClass = GetVehicleClass(cacheVehicle)
                if GetPedInVehicleSeat(cacheVehicle, -1) == cachePed and Config.VehicleClassDisable[vehicleClass] then
                    if not IsEntityInAir(cacheVehicle) then
                        local vehicleRoll = GetEntityRoll(cacheVehicle)
                        if math.abs(vehicleRoll) > 60 then
                            DisableControlAction(2, 59, true)
                            DisableControlAction(2, 60, true)
                            sleep = 10
                        end
                    else
                        sleep = 200
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

local function AntiDoublePerson()
    CreateThread(function()
        while true do
            local ped = cachePed
            local sleep = 500

            if DoesEntityExist(ped) then
                local isArmed = IsPedArmed(ped, 6)
                local isShooting = IsPedShooting(ped)
                local isAiming = IsControlPressed(0, 25)

                if isArmed then
                    if isShooting or isAiming then
                        DisableControlAction(1, 140, true)
                        DisableControlAction(1, 141, true)
                        DisableControlAction(1, 142, true)
                        sleep = 0
                    else
                        DisableControlAction(0, 24, true)
                        DisableControlAction(0, 257, true)
                        DisableControlAction(0, 263, true)
                        DisableControlAction(0, 264, true)
                        DisableControlAction(1, 140, true)
                        DisableControlAction(1, 141, true)
                        DisableControlAction(1, 142, true)
                        sleep = 0
                    end
                elseif not isAiming then
                    DisableControlAction(0, 24, true)
                    DisableControlAction(0, 257, true)
                    DisableControlAction(0, 263, true)
                    DisableControlAction(0, 264, true)
                    DisableControlAction(1, 140, true)
                    DisableControlAction(1, 141, true)
                    DisableControlAction(1, 142, true)
                    sleep = 0
                end
            end

            Wait(sleep)
        end
    end)
end

local function Synchronisation()
    SetGarbageTrucks(false)
    SetRandomBoats(false)
    SetRandomTrains(false)
    SetPlayerWantedLevel(cachePlayerId, 0, false)
    SetPlayerWantedLevelNow(cachePlayerId, false)
    SetPlayerWantedLevelNoDrop(cachePlayerId, 0, false)
    SetPlayerCanBeHassledByGangs(cachePed, false)
    SetPlayerLockonRangeOverride(cachePed, 2.0)
    SetIgnoreLowPriorityShockingEvents(cachePed, true)
    SetPlayerTargetingMode(3)
    SetPoliceIgnorePlayer(cachePed, true)
    SetPedCanBeTargetted(cachePed, false)

    RemoveMultiplayerWalletCash()
    RemoveMultiplayerBankCash()

    SetMinimapClipType(0)
end

CreateThread(function()
    Synchronisation()
    ScenariosLoop()
    Kolba()
    WeaponDrops()
    IdleCam()
    AntiVehicleRoll()
    AntiDoublePerson()

    DistantCopCarSirens(false)

    for i = 1, #relationships do
        SetRelationshipBetweenGroups(1, relationships[i], `PLAYER`)
    end

    for i = 1, 32 do
        EnableDispatchService(i, false)
    end
    
    SetMaxWantedLevel(0)
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
    SetAudioFlag('PoliceScannerDisabled', true)
end)

CreateThread(function()
    local SCENARIO_TYPES = {
        "WORLD_VEHICLE_ATTRACTOR",
        "WORLD_VEHICLE_AMBULANCE",
        "WORLD_VEHICLE_BICYCLE_BMX",
        "WORLD_VEHICLE_BICYCLE_BMX_BALLAS",
        "WORLD_VEHICLE_BICYCLE_BMX_FAMILY",
        "WORLD_VEHICLE_BICYCLE_BMX_HARMONY",
        "WORLD_VEHICLE_BICYCLE_BMX_VAGOS",
        "WORLD_VEHICLE_BICYCLE_MOUNTAIN",
        "WORLD_VEHICLE_BICYCLE_ROAD",
        "WORLD_VEHICLE_BIKE_OFF_ROAD_RACE",
        "WORLD_VEHICLE_BIKER",
        "WORLD_VEHICLE_BOAT_IDLE",
        "WORLD_VEHICLE_BOAT_IDLE_ALAMO",
        "WORLD_VEHICLE_BOAT_IDLE_MARQUIS",
        "WORLD_VEHICLE_BOAT_IDLE_MARQUIS",
        "WORLD_VEHICLE_BROKEN_DOWN",
        "WORLD_VEHICLE_BUSINESSMEN",
        "WORLD_VEHICLE_HELI_LIFEGUARD",
        "WORLD_VEHICLE_CLUCKIN_BELL_TRAILER",
        "WORLD_VEHICLE_CONSTRUCTION_SOLO",
        "WORLD_VEHICLE_CONSTRUCTION_PASSENGERS",
        "WORLD_VEHICLE_DRIVE_PASSENGERS",
        "WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED",
        "WORLD_VEHICLE_DRIVE_SOLO",
        "WORLD_VEHICLE_FIRE_TRUCK",
        "WORLD_VEHICLE_EMPTY",
        "WORLD_VEHICLE_MARIACHI",
        "WORLD_VEHICLE_MECHANIC",
        "WORLD_VEHICLE_MILITARY_PLANES_BIG",
        "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
        "WORLD_VEHICLE_PARK_PARALLEL",
        "WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN",
        "WORLD_VEHICLE_PASSENGER_EXIT",
        "WORLD_VEHICLE_POLICE_BIKE",
        "WORLD_VEHICLE_POLICE_CAR",
        "WORLD_VEHICLE_POLICE",
        "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
        "WORLD_VEHICLE_QUARRY",
        "WORLD_VEHICLE_SALTON",
        "WORLD_VEHICLE_SALTON_DIRT_BIKE",
        "WORLD_VEHICLE_SECURITY_CAR",
        "WORLD_VEHICLE_STREETRACE",
        "WORLD_VEHICLE_TOURBUS",
        "WORLD_VEHICLE_TOURIST",
        "WORLD_VEHICLE_TANDL",
        "WORLD_VEHICLE_TRACTOR",
        "WORLD_VEHICLE_TRACTOR_BEACH",
        "WORLD_VEHICLE_TRUCK_LOGS",
        "WORLD_VEHICLE_TRUCKS_TRAILERS",
        "WORLD_VEHICLE_DISTANT_EMPTY_GROUND",
        "WORLD_HUMAN_PAPARAZZI",
    }
    local SCENARIO_GROUPS = {
        2017590552, 
        2141866469, 
        1409640232, 
        "ng_planes", 
    }
    local SUPPRESSED_MODELS = {
        "shamal",
        "luxor",
        "luxor2",
        "jet",
        "lazer",
        "titan",
        "barracks",
        "barracks2",
        "crusader",
        "rhino",
        "airtug",
        "ripley",
        "buzzard",
        "firetruk",
        "ambulance",
        "police",
        "police2",
        "police3",
        "police4",
        "riot2",
        "pranger",
        "iguard",
        "sheriff",
        "police5",
        "pbus",
        "fbi",
        "riot",
        "seriff2",
        "policet",
        "fib2",
        "polmav",
        "frogger",
        "maverick",
        "buzzard2",
        "annihilator",
        "cargobob",
        "cargobob2",
        "cargobob3",
        "seasparrow",
        "lifeguard",
        "valkyrie",
        "savage",
        "frogger2",
        "swift",
        "swift2",
        "supervolito",
        "supervolito2",
        "volatus",
        "havok",
        "velum",
        "velum2",
        "policeb",
        "S_M_Y_Cop_01",
        "S_M_M_Cop_01",
        "S_F_Y_Cop_01",
        "CSB_Cop",
        "S_M_Y_HwayCop_01",
        "S_F_Y_Sheriff_01",
        "S_M_Y_Sheriff_01",
        "adder",
        "autarch",
        "banshee2",
        "bullet",
        "cheetah",
        "cheetah2",
        "deveste",
        "emerus",
        "entityxf",
        "entity2",
        "fmj",
        "furia",
        "gp1",
        "infernus",
        "italigtb",
        "italigtb2",
        "nero",
        "nero2",
        "osiris",
        "penumbra2",
        "reaper",
        "sc1",
        "scramjet",
        "t20",
        "taipan",
        "tempesta",
        "turismor",
        "tyrus",
        "vacca",
        "vagner",
        "visione",
        "xa21",
        "zentorno",
        "zorrusso",
        "811",
        "le7b",
        "penumbra",
        "sultanrs",
        "kuruma",
        "kuruma2",
        "jester",
        "jester2",
        "jester3",
        "massacro",
        "massacro2",
        "carbonizzare",
        "comet2",
        "comet3",
        "comet4",
        "comet5",
        "comet6",
        "comet7",
        "elegy",
        "elegy2",
        "furoregt",
        "furoregt2",
        "turismo2",
        "tampa2",
        "tampa3",
        "verlierer2",
        "sultan",
        "banshee",
        "alpha",
        "carbonizzare",
        "coquette",
        "elegy",
        "feltzer2",
        "furoregt",
        "fusilade",
        "jester",
        "khamelion",
        "lynx",
        "massacro",
        "ninef",
        "ninef2",
        "rapidgt",
        "rapidgt2",
        "schafter3",
        "surano",
        "surano2",
        "voltic",
        "zentorno"
    }

    while true do
        for _, sctyp in next, SCENARIO_TYPES do
            SetScenarioTypeEnabled(sctyp, false)
        end
        for _, scgrp in next, SCENARIO_GROUPS do
            SetScenarioGroupEnabled(scgrp, false)
        end
        for _, model in ipairs(SUPPRESSED_MODELS) do
            local hash = GetHashKey(model)

            if IsModelAVehicle(hash) then
                SetVehicleModelIsSuppressed(hash, true)
            elseif IsModelAPed(hash) then
                SetPedModelIsSuppressed(hash, true)
            end
        end
        Wait(10000)
    end
end)

local function disableAutoShuffle(seatIndex)
    SetPedConfigFlag(cachePed, 184, true)

    if cache.vehicle and not cache.seat then
        SetPedIntoVehicle(cachePed, cache.vehicle, seatIndex)
    end
end

libCache('seat', disableAutoShuffle)

local function shuffleSeat(self)
    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead or LocalPlayer.state.InTrunk then
        return ESX.ShowNotification("Nie możesz się teraz przesiąść")
    end

    if LocalPlayer.state.Belt then
        return ESX.ShowNotification("Nie możesz się teraz przesiąść, pierw odepnij pasy!")
    end

    self:disable(true)

    if cache.vehicle and cache.seat then
        TaskShuffleToNextVehicleSeat(cachePed, cache.vehicle)
        repeat
            Wait(0)
        until not GetIsTaskActive(cachePed, 165)
    end

    self:disable(false)
end

lib.addKeybind({
    name = 'shuffleSeat',
    description = 'Zmiana miejsca',
    defaultKey = "O",
    onPressed = shuffleSeat
})

CreateThread(function()
    local sleep
    while true do
        sleep = 500 
        
        if IsControlEnabled(0, 140) then
            DisableControlAction(0, 140, true)
            sleep = 0
        end

        Wait(sleep)
    end
end)


RegisterNetEvent('esx_core:checkIfThereIsAnyCar', function(plate)
    local vehicles = ESX.Game.GetVehicles()
    for _, vehicle in ipairs(vehicles) do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle)
        if type(vehiclePlate) == 'string' then
            vehiclePlate = vehiclePlate:gsub("%s+$", "")
            if vehiclePlate == plate and cacheVehicle ~= vehicle then
                if DoesEntityExist(vehicle) then
                    ESX.ShowNotification('Ktoś już jeździ tym autem!')
                    ESX.Game.DeleteVehicle(cacheVehicle)
                end
            end
        end
    end
end)

local blockedCommands = {'rcon_password', 'sv_licenseKey', 'mysql_connection_string'}

for _, cmd in ipairs(blockedCommands) do
    RegisterCommand(cmd, function()
        CancelEvent()
    end)
end

RegisterNetEvent("esx_core:startHeistCooldown", function(time)
    LocalPlayer.state:set('HeistCooldown', time, true)
end)

CreateThread(function()
    while true do
        local sleep = 1000
        
        if ESX.PlayerLoaded and LocalPlayer.state.HeistCooldown then
            if LocalPlayer.state.HeistCooldown > 0 then
                sleep = 60000
                local newCooldown = LocalPlayer.state.HeistCooldown - 1
                LocalPlayer.state:set('HeistCooldown', math.max(0, newCooldown), true)
            else
                sleep = 2000
            end
        end
        
        Wait(sleep)
    end
end)

local function DisableControlsInVehicle()
    lib.disableControls:Add(354, 351, 350, 357)
end

local function EnableControlsOutsideVehicle()
    lib.disableControls:Clear(354, 351, 350, 357)
end

libCache('vehicle', function(value)
    CreateThread(function()
        while value do
            if cacheVehicle then
                local Veh = GetVehiclePedIsUsing(cachePed)
                if DoesVehicleHaveWeapons(Veh) == 1 then
                    VehWeapon, WepHash = GetCurrentPedVehicleWeapon(cachePed)
                    if VehWeapon == 1 and WepHash ~= 1422046295 then
                        DisableControlsInVehicle()
                        DisableVehicleWeapon(true, WepHash, Veh, cachePed)
                        SetCurrentPedWeapon(cachePed, joaat("weapon_unarmed"), true)
                    else
                        EnableControlsOutsideVehicle()
                        break
                    end
                else
                    EnableControlsOutsideVehicle()
                    break
                end
            else
                EnableControlsOutsideVehicle()
                break
            end
            Wait(0)
            if not value then break end
        end
    end)
end)

local function copyCoords(includeHeading)
    if not ESX.IsPlayerAdminClient() then return ESX.ShowNotification('Nie posiadasz odpowiednich uprawnień!') end
    
    includeHeading = includeHeading or false
    local playerCoords = GetEntityCoords(cachePed)

    if not includeHeading then
        lib.setClipboard(('%.4f %.4f %.4f'):format(playerCoords.x, playerCoords.y, playerCoords.z))
        return
    end

    lib.setClipboard(('%.4f %.4f %.4f %.4f'):format(playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(cachePed)))
end

RegisterCommand('vec3', copyCoords)
RegisterCommand('vec4', function()
    copyCoords(true)
end)

RegisterNetEvent("esx_core:cheaterCalled", function(admin)
    if admin then
        PlaySoundFrontend(-1, "DELETE", "HUD_DEATHMATCH_SOUNDSET", 1)
        ESX.Scaleform.ShowFreemodeMessage('~r~Zapraszam na sprawdzanie', ('Zostałeś/aś zawołany/a przez: ~b~%s~w~\nWyjście z serwera = ~r~PERM'):format(admin), 30)
    end
end)

RegisterNetEvent('esx_core:calledPlayer', function(admin)
    if admin then
        PlaySoundFrontend(-1, "DELETE", "HUD_DEATHMATCH_SOUNDSET", 1)
        ESX.Scaleform.ShowFreemodeMessage('~r~Zapraszam na poczekalnie', ('Zostałeś/aś zawołany/a przez: ~b~%s'):format(admin), 30)
    end
end)

local handledPeds = {}

CreateThread(function()
    while true do
        Wait(500)

        local playerCoords = GetEntityCoords(cachePed)
        local pedList = GetGamePool('CPed')

        for _, ped in ipairs(pedList) do
            if not handledPeds[ped] and ped ~= cachePed and IsPedHuman(ped) and not IsPedAPlayer(ped) then
                local pedCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - pedCoords)

                if distance <= 100.0 then
                    SetPedConfigFlag(ped, 281, true)
                    SetPedConfigFlag(ped, 33, false)
                    handledPeds[ped] = true
                end
            end
        end
        
        local handledCount = 0
        for _ in pairs(handledPeds) do
            handledCount = handledCount + 1
        end
        
        if #pedList < handledCount * 0.5 then
            for ped in pairs(handledPeds) do
                if not DoesEntityExist(ped) then
                    handledPeds[ped] = nil
                end
            end
        end
    end
end)

CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end

    local profileSettings = {4, 226, 230, 70, 71, 25, 74, 36, 87, 75, 110, 112, 200, 201, 208, 210, 211, 212, 213, 217, 218, 220, 223}
    
    for _, setting in ipairs(profileSettings) do
        StatSetProfileSetting(setting, 0)
    end

    while true do
        for setting, value in pairs(Config.Visuals) do
            SetVisualSettingFloat(setting, value)
        end

        Wait(60000)
    end
end)

CreateThread(function()
    local playerZero = GetHashKey("player_zero")
    local mpModel = `mp_m_freemode_01`

    while true do
        Wait(10000)

        local ped = PlayerPedId()
        local model = GetEntityModel(ped)

        if model == playerZero then
            RequestModel(mpModel)
            while not HasModelLoaded(mpModel) do
                Wait(10)
            end

            SetPlayerModel(PlayerId(), mpModel)
            SetModelAsNoLongerNeeded(mpModel)
        end
    end
end)

local doors = {
	["seat_pside_f"] = 0,
	["seat_dside_r"] = 1,
	["seat_pside_r"] = 2
}

CreateThread(function()
	while true do
		Wait(0)
		local VehicleInFront = ESX.Game.GetVehicleInDirection(0.0, 20.0, -0.95)

		if VehicleInFront then
			DisableControlAction(0, 47, true)
			if IsDisabledControlJustPressed(0, 47) then
				local doorDistances = {}
				local coords = cache.coords

				for bone, seat in pairs(doors) do
					local doorBone = GetEntityBoneIndexByName(VehicleInFront, bone)
					if doorBone ~= -1 then
						local doorCoords = GetWorldPositionOfEntityBone(VehicleInFront, doorBone)
						table.insert(doorDistances, {seat = seat, distance = #(coords - doorCoords)})
					end
				end

				if #doorDistances > 0 then
					local closestSeat = doorDistances[1]
					for i = 2, #doorDistances do
						if doorDistances[i].distance < closestSeat.distance then
							closestSeat = doorDistances[i]
						end
					end
					TaskEnterVehicle(cachePed, VehicleInFront, -1, closestSeat.seat, 1.0, 1, 0)
				end
			end
		else
			Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(30)
		if cacheVehicle ~= false then
			SetPlayerCanDoDriveBy(cachePlayerId, false)
		else
			Citizen.Wait(500)
		end
	end
end)

CreateThread(function()
    local coords = vec3(-765.64056396484, 325.005859375, 199.48638916016)
    local drawDist = 10.0
    local interactDist = 2.0

    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - coords)

        if dist < drawDist then
            sleep = 0

            ESX.DrawMarker(coords)

            if dist < interactDist then
                exports["esx_hud"]:helpNotification('Naciśnij', 'E', 'aby się wytepać')

                if IsControlJustReleased(0, 38) then
                    SetEntityCoords(playerPed, -739.13916015625, -2277.8549804688, 13.437429428101)
                    exports["esx_hud"]:hideHelpNotification()
                end
            end
        end

        Wait(sleep)
    end
end)