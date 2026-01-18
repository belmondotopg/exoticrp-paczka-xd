------
-- Mission: find_vehicle

local findVehicleMarked = nil
local findVehicleBlip = nil
local findVehicleBlip2 = nil
local findVehicleCoords = vec4(232.4930, -1771.4315, 27.6610, 48.4330)
local findVehicleModel = "blista"

function startFindVehicleMission()

    local coords = findVehicleCoords
    local ped = {
        heading = coords.w,
        model = "a_m_m_afriamer_01",
        gender = "male",
    }

    findVehicleBlip = AddBlipForRadius(coords.x, coords.y, coords.z, 60.0)
    SetBlipColour(findVehicleBlip, 49)
    SetBlipAlpha(findVehicleBlip, 222)

    local blipLabel = TranslateIt('mission_end_returnVehicle_blip')
    findVehicleBlip2 = SH.addBlip(coords.xyz, 523, 3, blipLabel)
    SetBlipAsShortRange(findVehicleBlip2, false)

    SetNewWaypoint(coords.x, coords.y)

    local alert = lib.alertDialog({
        header = TranslateIt('vehicleMission_header'),
        content = TranslateIt('vehicleMission_desc', "Blista"),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('vehicleMission_alert_Okay')
        }
    })

    findVehicleMarked = SH.MarkNewCoords(coords, {type = 6, size = vec3(Config.Misc.zoneSize, Config.Misc.zoneSize, Config.Misc.zoneSize), color = Config.Misc.zoneColor}, false, ped, function()
        
    end, function()
        backWithVehicle()
    end, {
        name = "mission_find_vehicle_end",
        label = TranslateIt('mission_ped_returnVehicle'),
        icon = TranslateIt('mission_ped_returnVehicle_icon')
    })
end

function backWithVehicle()
    local playerPed = PlayerPedId()

    local pedDist = vec3(findVehicleCoords.x, findVehicleCoords.y, findVehicleCoords.z)
    local vehicle = GetHashKey(findVehicleModel) 
    local findVehicle = getNearbyVehicleByModel(vehicle, 15.0)

    if findVehicle then
        SH.RemoveMarkedCoords(findVehicleMarked)

        if findVehicleBlip then
            SetBlipDisplay(findVehicleBlip, 0)
            RemoveBlip(findVehicleBlip)
        end
    
        if findVehicleBlip2 then
            SetBlipDisplay(findVehicleBlip2, 0)
            RemoveBlip(findVehicleBlip2)
        end
        
        sendNotify(TranslateIt('vehicleMission_endSuccess'), "success", 5)
        TriggerServerEvent('op-crime:endMission', "find_vehicle")

        SH.fadeOutEntity(findVehicle, false)
        Wait(1000)
        Fr.DeleteVehicle(findVehicle)
    else
        sendNotify(TranslateIt('vehicleMission_noVehicleinradius', "Blista"), "error", 5)
    end
end

function getNearbyVehicleByModel(modelHash, radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyVehicle = nil

    for vehicle in SH.EnumerateVehicles() do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)
            
            if distance <= radius and GetEntityModel(vehicle) == modelHash then
                nearbyVehicle = vehicle
                break
            end
        end
    end

    return nearbyVehicle
end

---------------------------------
-- Laundry dirty money mission --
---------------------------------

totalLaundred = 0
isLaundryMissionStarted = false

function startLaundryMission()
    SetNewWaypoint(Config.MoneyLaundry.laundryMisc.location.x, Config.MoneyLaundry.laundryMisc.location.y)
    isLaundryMissionStarted = true

    local alert = lib.alertDialog({
        header = TranslateIt('laundryMission_header'),
        content = TranslateIt('laundryMission_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('vehicleMission_alert_Okay')
        }
    })
end

-- This event is called when player get to point of laundry money. 
-- Using this example you have resoultion how to connect for example your robbery scripts to this script.
RegisterNetEvent('op-crime:laundryMoney')
AddEventHandler('op-crime:laundryMoney', function(amount)
    print(amount)
    if not isLaundryMissionStarted then return end

    totalLaundred = totalLaundred + amount

    if totalLaundred >= 100000 then
        sendNotify(TranslateIt('laundryMissionEnd'), "success", 5)
        TriggerServerEvent('op-crime:endMission', "laundry_100k")
        isLaundryMissionStarted = false
    end
end)

----------------------------
-- 1 zone capture mission --
----------------------------

isCaptureMissionStarted = false
totalCaptured = 0

function startCaptureMission()
    isCaptureMissionStarted = true
    totalCaptured = 0

    lib.alertDialog({
        header = TranslateIt('captureMission_header'),
        content = TranslateIt('captureMission_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('vehicleMission_alert_Okay')
        }
    })
end

RegisterNetEvent('op-crime:zoneCaptured')
AddEventHandler('op-crime:zoneCaptured', function()
    if not isCaptureMissionStarted then return end

    totalCaptured = totalCaptured + 1

    if totalCaptured == 3 then
        TriggerServerEvent('op-crime:endMission', "capture_3Zones")
        isCaptureMissionStarted = false
        totalCaptured = 0
    end
end)


-------------------------------------------------
-- ONLY FOR VEHICLE THEFT SCRIPT ----------------
-- https://www.otherplanet.dev/product/6503031 --
-------------------------------------------------

isVehicleTheftMissionStarted = false

function startVehicleTheftMission()
    isVehicleTheftMissionStarted = true
    local alert = lib.alertDialog({
        header = TranslateIt('theftMission_header'),
        content = TranslateIt('theftMission_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('vehicleMission_alert_Okay')
        }
    })
end

RegisterNetEvent('op-crime:vehicleTheftMission')
AddEventHandler('op-crime:vehicleTheftMission', function()
    if not isVehicleTheftMissionStarted then return end

    sendNotify(TranslateIt('theftMissionEnd'), "success", 5)
    TriggerServerEvent('op-crime:endMission', "vehicleTheft")
    isVehicleTheftMissionStarted = false
end)

-------------------------------------------------
-- SPRAY GRAFFITI MISSION ----------------
-------------------------------------------------

local isSprayStarted = false
local totalSprayed = 0

function startSprayGraffitiMission()
    isSprayStarted = true
    totalSprayed = 0
    local alert = lib.alertDialog({
        header = TranslateIt('sprayMission_header'),
        content = TranslateIt('sprayMission_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('sprayMission_Okay')
        }
    })
end

function graffitiPainted()
    totalSprayed = totalSprayed + 1

    if totalSprayed == 3 then
        TriggerServerEvent('op-crime:endMission', "spray_graffiti")
        isSprayStarted = false
        totalSprayed = 0
    end
end

-------------------------------------------------
-- REMOVE GRAFFITI MISSION ----------------
-------------------------------------------------

local isSprayRemoveStarted = false
local totalRemoved = 0

function startRemoveGraffitiMission()
    isSprayRemoveStarted = true
    totalRemoved = 0
    local alert = lib.alertDialog({
        header = TranslateIt('sprayMission_2_header'),
        content = TranslateIt('sprayMission_2_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('sprayMission_2_Okay')
        }
    })
end

function graffitiRemoved()
    totalRemoved = totalRemoved + 1

    if totalRemoved == 5 then
        TriggerServerEvent('op-crime:endMission', "remove_graffiti")
        isSprayRemoveStarted = false
        totalRemoved = 0
    end
end

-------------------------------------------------
-------------- SELL DRUGS MISSION ---------------
-------------------------------------------------

local isInSellDrugMission = false
local totalSold = 0

function startSellingDrugsMission()
    isInSellDrugMission = true
    totalSold = 0
    local alert = lib.alertDialog({
        header = TranslateIt('sellDrugsMission_header'),
        content = TranslateIt('sellDrugsMission_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('sellDrugsMission_Okay')
        }
    })
end

RegisterNetEvent('op-crime:onDrugSold', function()
    if not isInSellDrugMission then return end
    totalSold = totalSold + 1 

    if totalSold == 5 then
        TriggerServerEvent('op-crime:endMission', "sell_drugs")
        isInSellDrugMission = false
        totalSold = 0
    end
end)

-------------------------------------------------
------------- DELIVER VAN MISSION ---------------
-------------------------------------------------

local isDeliverVanMission = false
local missionVeh, missionPeds = nil, {}
local GUARDS_GROUP = nil

local deliverVanCoordsRandom = {
    vec4(-534.7047, -2815.8403, 6.0004, 241.7177),
    vec4(-118.4501, -2668.7634, 6.0021, 5.3313),
    vec4(280.4062, -3219.1924, 5.7903, 265.1155),
    vec4(611.9205, -3175.1401, 6.0695, 355.3698),
    vec4(984.7985, -2542.1875, 28.3020, 356.1865),
    vec4(1717.1259, -1654.7063, 112.5039, 197.5105),
    vec4(2791.1785, -707.2554, 4.7015, 112.4764),
    vec4(2483.9858, 1583.2714, 32.7202, 334.9705),
    vec4(889.7740, 3652.7827, 32.8274, 157.2273),
}
local finalVanCoordsRandom = vec4(-488.8385, 6267.6802, 12.0418, 126.0662)

local function loadModel(model)
    if type(model) == "string" then model = joaat(model) end
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end
    return true
end

local function unloadModel(model)
    if type(model) == "string" then model = joaat(model) end
    SetModelAsNoLongerNeeded(model)
end

local function createRelationshipGroup()
    if not GUARDS_GROUP then
        local _, group = AddRelationshipGroup("OP_DELIVER_GUARDS")
        GUARDS_GROUP = group
        SetRelationshipBetweenGroups(1, GUARDS_GROUP, GUARDS_GROUP) 
        local PLAYER_GROUP = GetHashKey("PLAYER")
        SetRelationshipBetweenGroups(5, GUARDS_GROUP, PLAYER_GROUP) 
        SetRelationshipBetweenGroups(5, PLAYER_GROUP, GUARDS_GROUP) 
    end
end

local function setGuardCombatStats(ped)
    SetPedRelationshipGroupHash(ped, GUARDS_GROUP)
    SetPedCanSwitchWeapon(ped, true)
    SetPedDropsWeaponsWhenDead(ped, false)
    SetPedFleeAttributes(ped, 0, false) 
    SetPedCombatAttributes(ped, 46, true) 
    SetPedCombatAttributes(ped, 5, true)  
    SetPedCombatMovement(ped, 2)          
    SetPedCombatRange(ped, 2)            
    SetPedAlertness(ped, 3)
    SetPedAccuracy(ped, 35)               
    SetPedHearingRange(ped, 60.0)
    SetPedSeeingRange(ped, 90.0)
    SetPedArmour(ped, 25)
    SetEntityAsMissionEntity(ped, true, true)
end

local function giveGuardWeapon(ped)
    local pool = {
        `weapon_SNSPISTOL`,
        `WEAPON_SNSPISTOL_MK2`,
        `WEAPON_VINTAGEPISTOL`,
        `WEAPON_PISTOL`
    }
    local choice = pool[math.random(#pool)]
    GiveWeaponToPed(ped, choice, 200, false, true)
    SetCurrentPedWeapon(ped, choice, true)
end

local function groundZ(x, y, zHint)
    local found, z = GetGroundZFor_3dCoord(x + 0.0, y + 0.0, (zHint or 50.0), true)
    return found and z or (zHint or 50.0)
end

local function spawnGuardAt(model, x, y, z, heading)
    if not loadModel(model) then return nil end
    z = groundZ(x, y, z)
    local ped = CreatePed(4, joaat(model), x, y, z, heading or 0.0, true, true)
    if not DoesEntityExist(ped) then return nil end
    setGuardCombatStats(ped)
    giveGuardWeapon(ped)
    SetPedKeepTask(ped, true)
    return ped
end

local function getCirclePosAroundEntity(ent, count, minR, maxR)
    local positions = {}
    local base = GetEntityCoords(ent)
    local heading = GetEntityHeading(ent)
    for i = 1, count do
        local angle = math.rad((i / count) * 360.0 + math.random(-10,10))
        local r = minR + (maxR - minR) * math.random()
        local x = base.x + math.cos(angle) * r
        local y = base.y + math.sin(angle) * r
        local z = base.z + 0.5
        positions[#positions+1] = {x=x, y=y, z=z, h=heading + math.deg(angle)}
    end
    return positions
end

local function taskGuards(peds)
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then
            TaskGuardCurrentPosition(ped, 10.0, 10.0, true)
        end
    end
end

local deliverVanBlip = nil
local deliverVanBlip2 = nil
local markedDeliverDestination = nil

function deliverVanMission()
    if isDeliverVanMission then return end

    local alert = lib.alertDialog({
        header = TranslateIt('drugVan_dialog_header'),
        content = TranslateIt('drugVan_dialog_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('drugVan_dialog_Okay')
        }
    })

    isDeliverVanMission = true
    createRelationshipGroup()

    local randomCoords = deliverVanCoordsRandom[math.random(1, #deliverVanCoordsRandom)]
    if not randomCoords then
        isDeliverVanMission = false
        return
    end

    SetNewWaypoint(randomCoords.x,  randomCoords.y)

    deliverVanBlip = AddBlipForRadius(randomCoords.x, randomCoords.y, randomCoords.z, 60.0)
    SetBlipColour(deliverVanBlip, 49)
    SetBlipAlpha(deliverVanBlip, 222)

    deliverVanBlip2 = SH.addBlip(randomCoords.xyz, 140, 2, TranslateIt('drug_van_blip'))
    SetBlipAsShortRange(deliverVanBlip2, false)

    while true do 
        local PlayerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(PlayerPed)
        local cords = vec3(randomCoords.x, randomCoords.y, randomCoords.z)
        local dist = #(cords - playerCoords)
        if dist < 150 then 
            break
        end
        Wait(50)
    end

    local notEnteredYet = true 

    Fr.SpawnVehicle("rumpo3", randomCoords.xyz, 0.0, true, function(vehicle)
        missionVeh = vehicle
        local guardModels = { "s_m_y_blackops_01", "s_m_y_blackops_02", "s_m_m_armoured_01", "s_m_m_marine_01" }
        local positions = getCirclePosAroundEntity(vehicle, 10, 8.0, 16.0)

        for i, pos in ipairs(positions) do
            local mdl = guardModels[(i % #guardModels) + 1]
            local ped = spawnGuardAt(mdl, pos.x, pos.y, pos.z, pos.h)
            if ped then
                table.insert(missionPeds, ped)
            end
            Wait(50)
        end

        taskGuards(missionPeds)
        local vehicleProps = Fr.GetVehicleProperties(vehicle)
        giveKeys(vehicle, "rumpo3", vehicleProps.plate)

        Citizen.CreateThread(function()
            while notEnteredYet do
                local sleep = 500
                local PlayerPed = PlayerPedId()
                local playerVehicle = GetVehiclePedIsUsing(PlayerPed)
                if playerVehicle == vehicle then 
                    notEnteredYet = false 
                    SetEntityDrawOutline(vehicle, false)
                    break 
                end

                local playerCoords = GetEntityCoords(PlayerPed)
                local cords = vec3(randomCoords.x, randomCoords.y, randomCoords.z)
                local dist = #(cords - playerCoords)

                if dist < 15.0 then
                    sleep = 0
                    SetEntityDrawOutlineColor(255, 255, 255, 255)
                    SetEntityDrawOutline(vehicle, true)
                end
                Wait(sleep)
            end
            RemoveBlip(deliverVanBlip)
            RemoveBlip(deliverVanBlip2)

            local ped = {
                heading = finalVanCoordsRandom.w,
                model = "csb_brucie2",
                gender = "male",
                weapon = "weapon_assaultrifle"
            }

            markedDeliverDestination = SH.MarkNewCoords(finalVanCoordsRandom, {type = 6, size = vec3(Config.Misc.zoneSize, Config.Misc.zoneSize, Config.Misc.zoneSize), color = Config.Misc.zoneColor}, false, ped, function()
            end, function()
                backWithVan()
            end, {
                name = "mission_steal_drugs_end",
                label = TranslateIt('drug_van_endMission_returnVeh'),
                icon = TranslateIt('drug_van_endMission_returnVeh_icon')
            })

            sendNotify(TranslateIt('drug_van_inside'), "info", 10)
            SetNewWaypoint(finalVanCoordsRandom.x,  finalVanCoordsRandom.y)
            deliverVanBlip2 = SH.addBlip(finalVanCoordsRandom.xyz, 280, 1, TranslateIt('drug_van_blip2'))
            SetBlipAsShortRange(deliverVanBlip2, false)
        end)
    end)
end

function backWithVan()
    local PlayerPed = PlayerPedId()
    local playerVehicle = GetVehiclePedIsIn(PlayerPed, true)

    if playerVehicle == missionVeh then 
        Fr.DeleteVehicle(missionVeh)
        SH.RemoveMarkedCoords(markedDeliverDestination)
        RemoveBlip(deliverVanBlip2)
        markedDeliverDestination = nil
        deliverVanBlip = nil
        deliverVanBlip2 = nil
        markedDeliverDestination = nil
        sendNotify(TranslateIt('drug_van_mission_end_notify'), "success", 10)
        TriggerServerEvent('op-crime:endMission', "steal_van")
    else
        sendNotify(TranslateIt('drug_van_mission_end_notify_error'), "error", 10)
    end
end

----------------------------------------------
------------- DELIVER 50G WEED ---------------
----------------------------------------------

local weedDeliveryMarked = nil
local weedDeliveryCoords = vec4(1698.8948, 6438.6714, 31.7840, 284.9956)
local weedBlip = nil

function startWeedDelivey()
    local ped = {
        heading = weedDeliveryCoords.w,
        model = "g_m_y_pologoon_01",
        gender = "male",
    }

    local alert = lib.alertDialog({
        header = TranslateIt('drugDeliver_dialog_header'),
        content = TranslateIt('drugDeliver_dialog_desc'),
        centered = true,
        cancel = false,
        labels = {
            confirm = TranslateIt('drugDeliver_dialog_Okay')
        }
    })

    weedBlip = SH.addBlip(weedDeliveryCoords.xyz, 140, 2, TranslateIt('drugDeliver_dialog_blip'))
    SetBlipAsShortRange(weedBlip, false)

    weedDeliveryMarked = SH.MarkNewCoords(weedDeliveryCoords, {type = 6, size = vec3(Config.Misc.zoneSize, Config.Misc.zoneSize, Config.Misc.zoneSize), color = Config.Misc.zoneColor}, false, ped, function()
    end, function()
        backWithDrugs()
    end, {
        name = "mission_selldrugs_safe",
        label = TranslateIt('drugDeliver_dialog_target'),
        icon = TranslateIt('drugDeliver_dialog_icon')
    })
end

function backWithDrugs()
    Fr.TriggerServerCallback('op-crime:sellDrugs', function(res)
        if res then 
            RemoveBlip(weedBlip)
            weedBlip = nil
            SH.RemoveMarkedCoords(weedDeliveryMarked)
            weedDeliveryMarked = nil
            sendNotify(TranslateIt('drugDeliver_notify_success'), "success", 5)
            TriggerServerEvent('op-crime:endMission', "drug_sell_npc")
        else 
            sendNotify(TranslateIt('drugDeliver_notify_error'), "error", 5)
        end
    end)
end 