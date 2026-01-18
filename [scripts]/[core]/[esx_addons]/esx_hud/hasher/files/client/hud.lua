local Player = Player
local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local hudRefresh = 300
local LocalPlayer = LocalPlayer

LocalPlayer.state:set('HasBodycam', false, true)

local OptiWaitMap = 200
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local GetVehicleClass = GetVehicleClass
local IsVehicleStopped = IsVehicleStopped
local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local GetVehicleCurrentGear = GetVehicleCurrentGear
local GetPlayerUnderwaterTimeRemaining = GetPlayerUnderwaterTimeRemaining
local GetEntityHealth = GetEntityHealth
local GetPedArmour = GetPedArmour
local GetEntityHeading = GetEntityHeading
local SetRadarZoom = SetRadarZoom
local IsPauseMenuActive = IsPauseMenuActive
local NetworkIsPlayerTalking = NetworkIsPlayerTalking
local GetEntitySpeed = GetEntitySpeed
local SendNUIMessage = SendNUIMessage
local BeginScaleformMovieMethod = BeginScaleformMovieMethod
local SetMapZoomDataLevel = SetMapZoomDataLevel
local SetRadarBigmapEnabled = SetRadarBigmapEnabled
local SetBigmapActive = SetBigmapActive
local RequestScaleformMovie = RequestScaleformMovie
local ScaleformMovieMethodAddParamInt = ScaleformMovieMethodAddParamInt
local EndScaleformMovieMethod = EndScaleformMovieMethod
local IsBigmapFull = IsBigmapFull
local IsBigmapActive = IsBigmapActive
local GetVehicleCurrentRpm = GetVehicleCurrentRpm
local IsPedDeadOrDying = IsPedDeadOrDying
local Config = {
    Directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N' },
    DirectionNames = {
        ['N'] = 'North',
        ['NW'] = 'North-West',
        ['W'] = 'West',
        ['SW'] = 'South-West',
        ['S'] = 'South',
        ['SE'] = 'South-East',
        ['E'] = 'East',
        ['NE'] = 'North-East',
    },
    Zones = {
		['AIRP'] = 'Los Santos Airport',
		['ALAMO'] = 'Alamo Sea',
		['ALTA'] = 'Alta',
		['ARMYB'] = 'Fort Zancudo',
		['BANHAMC'] = 'Banham Canyon Dr',
		['BANNING'] = 'Banning',
		['BEACH'] = 'Vespucci Beach',
		['BHAMCA'] = 'Banham Canyon',
		['BRADP'] = 'Braddock Pass',
		['BRADT'] = 'Braddock Tunnel',
		['BURTON'] = 'Burton',
		['CALAFB'] = 'Calafia Bridge',
		['CANNY'] = 'Raton Canyon',
		['CCREAK'] = 'Cassidy Creek',
		['CHAMH'] = 'Chamberlain Hills',
		['CHIL'] = 'Vinewood Hills',
		['CHU'] = 'Chumash',
		['CMSW'] = 'Chiliad Mountain',
		['CYPRE'] = 'Cypress Flats',
		['DAVIS'] = 'Davis',
		['DELBE'] = 'Del Perro Beach',
		['DELPE'] = 'Del Perro',
		['DELSOL'] = 'La Puerta',
		['DESRT'] = 'Grand Senora Desert',
		['DOWNT'] = 'Downtown',
		['DTVINE'] = 'Downtown Vinewood',
		['EAST_V'] = 'East Vinewood',
		['EBURO'] = 'El Burro Heights',
		['ELGORL'] = 'El Gordo Lighthouse',
		['ELYSIAN'] = 'Elysian Island',
		['GALFISH'] = 'Galilee',
		['GOLF'] = 'GWC and Golfing Society',
		['GRAPES'] = 'Grapeseed',
		['GREATC'] = 'Great Chaparral',
		['HARMO'] = 'Harmony',
		['HAWICK'] = 'Hawick',
		['HORS'] = 'Vinewood Racetrack',
		['HUMLAB'] = 'Humane Labs and Research',
		['JAIL'] = 'Bolingbroke Penitentiary',
		['KOREAT'] = 'Little Seoul',
		['LACT'] = 'Land Act Reservoir',
		['LAGO'] = 'Lago Zancudo',
		['LDAM'] = 'Land Act Dam',
		['LEGSQU'] = 'Legion Square',
		['LMESA'] = 'La Mesa',
		['LOSPUER'] = 'La Puerta',
		['MIRR'] = 'Mirror Park',
		['MORN'] = 'Morningwood',
		['MOVIE'] = 'Richards Majestic',
		['MTCHIL'] = 'Mount Chiliad',
		['MTGORDO'] = 'Mount Gordo',
		['MTJOSE'] = 'Mount Josiah',
		['MURRI'] = 'Murrieta Heights',
		['NCHU'] = 'North Chumash',
		['NOOSE'] = 'N.O.O.S.E',
		['OCEANA'] = 'Pacific Ocean',
		['PALCOV'] = 'Paleto Cove',
		['PALETO'] = 'Paleto Bay',
		['PALFOR'] = 'Paleto Forest',
		['PALHIGH'] = 'Palomino Highlands',
		['PALMPOW'] = 'Palmer-Taylor Power Station',
		['PBLUFF'] = 'Pacific Bluffs',
		['PBOX'] = 'Pillbox Hill',
		['PROCOB'] = 'Procopio Beach',
		['RANCHO'] = 'Rancho',
		['RGLEN'] = 'Richman Glen',
		['RICHM'] = 'Richman',
		['ROCKF'] = 'Rockford Hills',
		['RTRAK'] = 'Redwood Lights Track',
		['SANAND'] = 'San Andreas',
		['SANCHIA'] = 'San Chianski Mountain Range',
		['SANDY'] = 'Sandy Shores',
		['SKID'] = 'Mission Row',
		['SLAB'] = 'Stab City',
		['STAD'] = 'Maze Bank Arena',
		['STRAW'] = 'Strawberry',
		['TATAMO'] = 'Tataviam Mountains',
		['TERMINA'] = 'Terminal',
		['TEXTI'] = 'Textile City',
		['TONGVAH'] = 'Tongva Hills',
		['TONGVAV'] = 'Tongva Valley',
		['VCANA'] = 'Vespucci Canals',
		['VESP'] = 'Vespucci',
		['VINE'] = 'Vinewood',
		['WINDF'] = 'Ron Alternates Wind Farm',
		['WVINE'] = 'West Vinewood',
		['ZANCUDO'] = 'Zancudo River',
		['ZP_ORT'] = 'Port of South Los Santos',
		['ZQ_UAR'] = 'Davis Quartz'
    },
}

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords
local cachePlayerId = cache.playerId
local cacheServerId = cache.serverId
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
    cachePed = ped
    SetPedCanLosePropsOnDamage(ped, false, 0)
end)

libCache('coords', function(coords)
    cacheCoords = coords
end)

libCache('playerId', function(playerId)
    cachePlayerId = playerId
end)

libCache('serverId', function(serverId)
    cacheServerId = serverId
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(500)
    end

    TriggerServerEvent('esx_hud:updateBodycam')

    local serverId = cache.serverId
    local ssn = LocalPlayer.state.ssn

    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "watermark-data",
        data = {
            serverId = serverId,
            uuid = ssn,
        },
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "hud",
        visible = true
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "watermark",
        visible = true
    })
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(500)
    end

    TriggerServerEvent('esx_hud:updateBodycam')

    local serverId = cache.serverId
    local ssn = LocalPlayer.state.ssn

    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "watermark-data",
        data = {
            serverId = serverId,
            uuid = ssn,
        },
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "hud",
        visible = true
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "watermark",
        visible = true
    })
end)

local function GetVehicleCurrentGearName(vehicle)
    local vehicleCurrentGear = GetVehicleCurrentGear(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    if not GetIsVehicleEngineRunning(vehicle) then
        return 'P'
    elseif IsVehicleStopped(vehicle) then
        return 'N'
    elseif vehicleClass == 15 or vehicleClass == 16 then
        return 'F'
    elseif vehicleClass == 14 then
        return 'S'
    elseif vehicleCurrentGear == 0 then
        return 'R'
    end

    return vehicleCurrentGear
end

local function GetVehicleEngineRpmScale(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    if (vehicleClass >= 0 and vehicleClass <= 5) or (vehicleClass >= 9 and vehicleClass <= 12) or vehicleClass == 17 or vehicleClass == 18 or
        vehicleClass == 20 then

        return 7000
    elseif vehicleClass == 6 then
        return 7500
    elseif vehicleClass == 7 then
        return 8000
    elseif vehicleClass == 8 then
        return 11000
    elseif vehicleClass == 15 or vehicleClass == 16 then
        return -1
    end

    return -1
end

local function GetDirectionFromHeading(heading)
    heading = math.floor(heading + 0.5) % 360
    
    -- Bezpośrednie obliczenie zamiast iteracji - znacznie szybsze
    local index = math.floor((heading + 22.5) / 45) % 8
    local directionMap = { [0] = 'N', [1] = 'NE', [2] = 'E', [3] = 'SE', [4] = 'S', [5] = 'SW', [6] = 'W', [7] = 'NW' }
    
    return directionMap[index] or "N"
end

local function GetVehicleEngineRpm(vehicle, vehicleRpmScale, vehicleSpeed, isEngineRunning)
    local vehicleCurrentRpm = GetVehicleCurrentRpm(vehicle)

    if not isEngineRunning then
        vehicleCurrentRpm = 0
    elseif vehicleCurrentRpm > 0.99 then
        vehicleCurrentRpm = vehicleCurrentRpm * 100
        vehicleCurrentRpm = vehicleCurrentRpm + math.random(-2, 2)

        vehicleCurrentRpm = vehicleCurrentRpm / 100
        if vehicleCurrentRpm < 0.12 then
            vehicleCurrentRpm = 0.12
        end
    else
        vehicleCurrentRpm = vehicleCurrentRpm - 0.1
    end

    local vehicleRpm = math.floor(vehicleRpmScale * vehicleCurrentRpm + 0.5)
    if vehicleRpm < 0 then
        vehicleRpm = 0
    elseif vehicleSpeed == 0 and vehicleCurrentRpm ~= 0 then
        vehicleRpm = math.random(vehicleRpm, (vehicleRpm + 50))
    end

    return math.floor(vehicleRpm / 10) * 10
end


local function GetStreetsCustom(coords)
    local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	local street1, street2 = GetStreetNameFromHashKey(s1), GetStreetNameFromHashKey(s2)
	return street1
end

local streetLabel = {}
local hudUpdates = {
    hunger = 50,
    thirst = 50,
    health = 100,
    armour = 0,
}

AddEventHandler("esx_status:onTick", function(data)
    local hunger, thirst

    for i = 1, #data do
        if data[i].name == "thirst" then
            thirst = math.floor(data[i].percent)
        end
        if data[i].name == "hunger" then
            hunger = math.floor(data[i].percent)
        end
    end

    hudUpdates.health = math.floor((GetEntityHealth(cachePed) - 100) / (GetEntityMaxHealth(cachePed) - 100) * 100)
    hudUpdates.armour = GetPedArmour(cachePed)
    hudUpdates.thirst = thirst
    hudUpdates.hunger = hunger
end)

Citizen.CreateThread(function()
    SendNUIMessage({
        action = 'setImages',
        data = 'nui://esx_hud/web/images'
    })

    TriggerEvent('chat:addSuggestion', '/hud', 'Dostosuj ustawienia hudu', {})
    TriggerEvent('chat:addSuggestion', '/dostosuj', 'Dostosuj pozycję swojej postaci', {})
    TriggerEvent('chat:addSuggestion', '/heal', 'Ulecz graczy bądź samego siebie', {})
    TriggerEvent('chat:addSuggestion', '/revive', 'Ożyw graczy bądź samego siebie', {})
    TriggerEvent('chat:addSuggestion', '/propfix', 'Wyczyść swoją postać z pozostałych propów', {})
    TriggerEvent('chat:addSuggestion', '/paintball_exit', 'Wyjdź z paintballa', {})

    local offPausemenu = false

    while true do
        Citizen.Wait(hudRefresh)
        if not IsPauseMenuActive() then
            local UnderwaterTime = GetPlayerUnderwaterTimeRemaining(cachePlayerId)

            if UnderwaterTime < 0.0 then
                UnderwaterTime = 0.0
            end

            hudUpdates.health = math.floor((GetEntityHealth(cachePed) - 100) / (GetEntityMaxHealth(cachePed) - 100) * 100)
            hudUpdates.armour = GetPedArmour(cachePed)

            SendNUIMessage({
                eventName = "nui:data:update",
                dataId = "hud-data",
                data = {
                    health = hudUpdates.health,
                    armour = hudUpdates.armour,
                    hunger = hudUpdates.hunger,
                    thirst = hudUpdates.thirst,
                    oxygen = UnderwaterTime * 10,
                },
            })

            local state = NetworkIsPlayerTalking(cachePlayerId)
            local proximityState = LocalPlayer.state.proximity
            local mode = proximityState and proximityState.mode or 'Normal'

            SendNUIMessage({
                eventName = "nui:data:update",
                dataId = "microphone-data",
                data = {
                    isTalking = state,
                    voiceDistance = mode == 'Shouting' and 3 or mode == 'Normal' and 2 or mode == 'Whisper' and 1 or 1,
                },
            })

            if offPausemenu then
                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "hud",
                    visible = true
                })

                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "watermark",
                    visible = true
                })

                TriggerServerEvent('esx_hud:updateBodycam')
            end

            offPausemenu = false
        else
            if not offPausemenu then
                -- SetNuiFocus(false, false)
                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "hud",
                    visible = false
                })

                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "watermark",
                    visible = false
                })

                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "bodycam",
                    visible = false
                })
                
                offPausemenu = true 
            else
                Citizen.Wait(1000)
            end
        end
    end
end)

local sendedCar = false
local lastData = {
    kmh = -1,
    rpm = -1,
    gear = -1,
    fuel = -1,
    isEngineOn = nil,
    isSeatbeltOn = nil,
    roadName = '',
    direction = ''
}

local cachedVehicle = nil
local cachedVehicleRpmScale = nil
local lastStreetUpdate = 0
local streetUpdateInterval = 500
local lastHeading = -1
local lastDirection = nil

Citizen.CreateThread(function()
    while true do
        local ped = cachePed
        local veh = cacheVehicle
        
        local isPedInVehicle = veh and IsPedInAnyVehicle(ped, false)
        local isVehicleValid = veh and DoesEntityExist(veh)

        if veh and isPedInVehicle and isVehicleValid and not IsPauseMenuActive() and not IsPedDeadOrDying(ped, true) and not LocalPlayer.state.CamMode then
            if cachedVehicle ~= veh then
                cachedVehicle = veh
                cachedVehicleRpmScale = GetVehicleEngineRpmScale(veh)
            end

            local speed = math.ceil(GetEntitySpeed(veh) * 3.6)
            local engineOn = GetIsVehicleEngineRunning(veh)
            local rpm = GetVehicleEngineRpm(veh, cachedVehicleRpmScale, speed, engineOn)
            local gear = GetVehicleCurrentGear(veh)

            if gear == 0 then
                gear = "R"
            end
            
            local heading = GetEntityHeading(veh)
            local rotation = (-heading) % 360
            
            local direction = lastDirection
            if math.abs(heading - lastHeading) >= 5.0 then
                direction = GetDirectionFromHeading(heading)
                lastDirection = direction
                lastHeading = heading
            end

            local roadName = lastData.roadName
            local currentTime = GetGameTimer()
            if currentTime - lastStreetUpdate >= streetUpdateInterval then
                local coords = cacheCoords
                roadName = GetStreetsCustom(coords)
                lastStreetUpdate = currentTime
            end
            local seatbelt = LocalPlayer.state.Belt
            local fuel = math.floor(GetVehicleFuelLevel(veh))


            local newSpeed = string.format("%03d", speed)

            if lastData.kmh ~= speed
                or math.abs(lastData.rpm - rpm) >= 50
                or lastData.gear ~= gear
                or lastData.fuel ~= fuel
                or lastData.isEngineOn ~= engineOn
                or lastData.isSeatbeltOn ~= seatbelt
                or lastData.roadName ~= roadName
                or lastData.direction ~= direction
            then
                lastData.kmh = speed
                lastData.rpm = rpm
                lastData.gear = gear
                lastData.fuel = fuel
                lastData.isEngineOn = engineOn
                lastData.isSeatbeltOn = seatbelt
                lastData.roadName = roadName
                lastData.direction = direction
                
                SendNUIMessage({
                    eventName = "nui:data:update",
                    dataId = "carhud-data",
                    data = {
                        kmh = newSpeed,
                        fuel = fuel,
                        isEngineOn = engineOn,
                        isSeatbeltOn = seatbelt,
                        rpm = rpm,
                        gear = gear,
                        roadName = roadName,
                        direction = Config.DirectionNames[direction],
                        rotation = rotation,
                    }
                })
            end

            if sendedCar and not LocalPlayer.state.CamMode then
                sendedCar = false
                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "carhud",
                    visible = true
                })
            end

            Citizen.Wait(50)
        else
            if cachedVehicle then
                cachedVehicle = nil
                cachedVehicleRpmScale = nil
                lastHeading = -1
                lastDirection = nil
            end
            
            if not sendedCar then
                SendNUIMessage({
                    eventName = "nui:visible:update",
                    elementId = "carhud",
                    visible = false
                })
                sendedCar = true
            end
            Citizen.Wait(300)
        end
    end
end)

RegisterNetEvent('esx_hud/hideHud', function(state)
    -- SetNuiFocus(false, false)

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "hud",
        visible = state
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "watermark",
        visible = state
    })

    if not state then
        SendNUIMessage({
            eventName = "nui:visible:update",
            elementId = "carhud",
            visible = false
        })
        sendedCar = true
    end

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "bodycam",
        visible = state
    })

    DisplayRadar(state)
end)

RegisterNetEvent('esx_hud/hideHud2', function(state)
    -- SetNuiFocus(false, false)

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "hud",
        visible = state
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "watermark",
        visible = state
    })

    if not state then
        SendNUIMessage({
            eventName = "nui:visible:update",
            elementId = "carhud",
            visible = false
        })
        sendedCar = true
    end

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "bodycam",
        visible = state
    })

    DisplayRadar(state)
end)

local function showHudSettings()
    SetNuiFocus(true, true)
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "settings",
        visible = true
    })
end

RegisterCommand('hud', function()
    showHudSettings()
end, false)

RegisterNUICallback('settings', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('setting-value-changed', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('npc-dialogs:close', function(data, cb)
    cb('ok')
end)

local cinemaMode = false

RegisterNUICallback('esx_hud:showEventNotifications', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('esx_hud:setRadioVolume', function(data, cb)
    local volume = tonumber(data)
    TriggerEvent('pma-voice:changeVolume', volume)
    cb('ok')
end)

RegisterNUICallback('esx_hud:setRadioSound', function(data, cb)
    local state = data
    TriggerEvent('pma-voice:ToggleRadioEffect', state)
    cb('ok')
end)

RegisterNUICallback('esx_hud:cinemaMode', function(data, cb)
    local state = data
    cinemaMode = state

    if state == true then
        DisplayRadar(false)
        TriggerEvent('chat:toggleChat', true)
    else
        TriggerEvent('chat:toggleChat', false)
    end
    cb('ok')
end)

RegisterNUICallback('esx_hud:setHudRefresh', function(data, cb)
    if data == 1 then
        hudRefresh = 300
    elseif data == 2 then
        hudRefresh = 2000
    elseif data == 3 then
        hudRefresh = 3000
    end
    cb('ok')
end)

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(5000)
        if IsBigmapActive() or IsBigmapFull() then
            SetRadarBigmapEnabled(true, false)
            SetRadarBigmapEnabled(false, false)
        end    
    end
end)

Citizen.CreateThread(function()
    DisplayRadar(false)
    
    while true do
        Citizen.Wait(500)
        
        if not cinemaMode then
            local phoneOpen = LocalPlayer.state.phoneOpen or false
            local shouldShowRadar = cacheVehicle or phoneOpen
            DisplayRadar(shouldShowRadar)
        end
    end
end)

Citizen.CreateThread(function() 
    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0) -- Level 0
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0) -- Level 1
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) -- Level 2
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0) -- Level 3
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0) -- Level 4
    SetMapZoomDataLevel(5, 55.0, 0.0, 0.1, 2.0, 1.0) -- ZOOM_LEVEL_GOLF_COURSE
    SetMapZoomDataLevel(6, 450.0, 0.0, 0.1, 1.0, 1.0) -- ZOOM_LEVEL_INTERIOR
    SetMapZoomDataLevel(7, 4.5, 0.0, 0.0, 0.0, 0.0) -- ZOOM_LEVEL_GALLERY
    SetMapZoomDataLevel(8, 11.0, 0.0, 0.0, 2.0, 3.0) -- ZOOM_LEVEL_GALLERY_MAXIMIZE

    Citizen.CreateThread(function()
        SetRadarBigmapEnabled(true, false)
        SetRadarBigmapEnabled(false, false)
    end)

    Citizen.CreateThread(function()
        SetBigmapActive(true, true)
        SetBigmapActive(false, false)
    end)

    local minimap = RequestScaleformMovie("minimap")
    
    BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()
    
    Citizen.CreateThread(function ()
        while true do
            SetRadarZoom(1100)
            Citizen.Wait(OptiWaitMap)
        end
    end)
end)