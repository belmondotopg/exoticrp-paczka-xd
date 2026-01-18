local ox_target = exports.ox_target
local spawnedDisplayVehicles = {}
local vehiclesRequested = false

local RESOURCE_NAME = GetCurrentResourceName()
local REQUEST_TIMEOUT = 10000
local SPAWN_DELAY = 500
local MODEL_LOAD_TIMEOUT = 10000
local RAYCAST_WAIT = 10
local GROUND_CHECK_DISTANCE = 3.0
local GROUND_CHECK_THRESHOLD = 1.5
local GROUND_OFFSET = 0.2

-- Zrobić by pojazdy spawnowały się tylko w market miasto jak jesteś w środku i żeby auta npc nie spawnowały sie w środku marketu
-- local marketMiasto = PolyZone:Create({
--     vector2(-525.04559326172,-2136.4626464844),
--     vector2(-580.05889892578, -2078.5649414063),
--     vector2(-674.93853759766, -2189.2719726563),
--     vector2(-610.36328125, -2239.5939941406),
-- }, {
--     name="marketmiasto",
--     minZ=0.0,
--     maxZ=25.0,
--     debugGrid=true,
--     gridDivisions = 35
-- })

local function requestVehiclesFromServer()
    if vehiclesRequested then
        print("^3[CarMarket Client]^7 Vehicles already requested, skipping duplicate request")
        return
    end
    
    vehiclesRequested = true
    print("^3[CarMarket Client]^7 Requesting vehicles list from server...")
    TriggerServerEvent('qf_carMarket:requestVehiclesList')
    
    SetTimeout(REQUEST_TIMEOUT, function()
        vehiclesRequested = false
    end)
end

local function getVehicleDisplayName(model)
    if type(model) == "string" and tonumber(model) then
        model = tonumber(model)
    end
    
    if type(model) == "number" then
        return GetDisplayNameFromVehicleModel(model) or "Nieznany"
    else
        return model or "Nieznany"
    end
end

local function canPlayerInteract()
    return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle)
end

local function createPurchaseAlertDialog(vehicleData, paymentMethod)
    local methodLabel = paymentMethod == "cash" and "Gotówka" or "Karta"
    
    return lib.alertDialog({
        header = 'Zakup pojazdu - ' .. methodLabel,
        content = 'Czy na pewno chcesz kupić pojazd **' .. getVehicleDisplayName(vehicleData.model) .. '** [' .. vehicleData.plate .. '] za **$' .. ESX.Math.GroupDigits(vehicleData.price) .. '** ' .. methodLabel:lower() .. '?',
        centered = true,
        cancel = true,
        labels = {
            confirm = 'Tak, kupuję',
            cancel = 'Nie'
        }
    })
end

local function cleanupVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end
    
    exports[RESOURCE_NAME]:removeDui(vehicle)
    ox_target:removeLocalEntity(vehicle, {"Jazda Testowa", "Kup Pojazd", "Przywróć do Garażu", "Karta pojazdu"})
    SetEntityAsMissionEntity(vehicle, false, true)
    DeleteEntity(vehicle)
end

local function configureVehicleInteractions(vehicle, vehicleData)
    if not DoesEntityExist(vehicle) then
        return
    end
    
    ESX.TriggerServerCallback('qf_carMarket:isVehicleOwner', function(isOwner)
        if not DoesEntityExist(vehicle) then
            return
        end
        
        local targetOptions = {}

        if not isOwner then
            table.insert(targetOptions, {
                icon = 'fa-solid fa-car',
                label = "Jazda Testowa",
                canInteract = canPlayerInteract,
                onSelect = function()
                    exports[RESOURCE_NAME]:startTestDrive({
                        id = vehicleData.id,
                        model = vehicleData.model,
                        plate = vehicleData.plate,
                        props = vehicleData.props,
                        price = vehicleData.price,
                        owner = vehicleData.owner
                    })
                end,
                distance = 3.0
            })

            table.insert(targetOptions, {
                icon = 'fa fa-cart-shopping',
                label = "Kup Pojazd",
                canInteract = canPlayerInteract,
                onSelect = function()
                    local paymentOptions = {
                        {
                            title = 'Gotówka',
                            description = 'Zapłać gotówką',
                            icon = 'fa-solid fa-money-bill',
                            onSelect = function()
                                local alert = createPurchaseAlertDialog(vehicleData, "cash")
                                if alert == 'confirm' then
                                    TriggerServerEvent("exotic_carmarket:requestBuyVehicle", vehicleData.id, "cash")
                                end
                            end
                        },
                        {
                            title = 'Karta',
                            description = 'Zapłać kartą',
                            icon = 'fa-solid fa-credit-card',
                            onSelect = function()
                                local alert = createPurchaseAlertDialog(vehicleData, "bank")
                                if alert == 'confirm' then
                                    TriggerServerEvent("exotic_carmarket:requestBuyVehicle", vehicleData.id, "bank")
                                end
                            end
                        }
                    }
                    
                    lib.registerContext({
                        id = 'payment_method_menu',
                        title = 'Wybierz metodę płatności',
                        options = paymentOptions
                    })
                    
                    lib.showContext('payment_method_menu')
                end,
                distance = 3.0
            })
        end

        if isOwner then
            table.insert(targetOptions, {
                icon = 'fa-solid fa-arrow-left',
                label = "Przywróć do Garażu",
                canInteract = canPlayerInteract,
                onSelect = function()
                    local alert = lib.alertDialog({
                        header = 'Przywróć pojazd do garażu',
                        content = 'Czy na pewno chcesz przywrócić pojazd **' .. getVehicleDisplayName(vehicleData.model) .. '** [' .. vehicleData.plate .. '] do swojego garażu?',
                        centered = true,
                        cancel = true,
                        labels = {
                            confirm = 'Tak, przywróć',
                            cancel = 'Nie'
                        }
                    })
                    
                    if alert == 'confirm' then
                        TriggerServerEvent("qf_carMarket:returnVehicleToGarage", vehicleData.plate)
                    end
                end,
                distance = 3.0
            })
        end

        if #targetOptions > 0 then
            ox_target:addLocalEntity(vehicle, targetOptions)
        end
        
        createDUI(vehicle, {
            model = vehicleData.model,
            owner = vehicleData.owner,
            price = vehicleData.price,
            since = vehicleData.since,
            props = vehicleData.props,
            phone = vehicleData.phone or "Brak numeru"
        })
        
        print("^2[CarMarket Client]^7 Configured interactions for vehicle: " .. vehicleData.plate)
    end, vehicleData.plate)
end

local function spawnSingleVehicle(vehicleData)
    print("^3[CarMarket Client]^7 Starting to spawn vehicle: " .. vehicleData.plate)
    
    if spawnedDisplayVehicles[vehicleData.plate] and DoesEntityExist(spawnedDisplayVehicles[vehicleData.plate]) then
        print("^3[CarMarket Client]^7 Vehicle " .. vehicleData.plate .. " already spawned, skipping")
        return
    end

    if not vehicleData.model or vehicleData.model == "" or vehicleData.model == "Unknown" then
        print("^1[CarMarket Client]^7 Invalid model for vehicle: " .. vehicleData.plate)
        return
    end
    
    local model
    if type(vehicleData.model) == "number" or (type(vehicleData.model) == "string" and tonumber(vehicleData.model)) then
        model = tonumber(vehicleData.model)
    else
        model = GetHashKey(vehicleData.model)
    end
    
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < MODEL_LOAD_TIMEOUT do
        Wait(50)
        timeout = timeout + 50
    end

    if not HasModelLoaded(model) then 
        print("^1[CarMarket Client]^7 Failed to load model for vehicle: " .. vehicleData.plate)
        return 
    end

    local spawnX, spawnY, spawnZ = vehicleData.coords.x, vehicleData.coords.y, vehicleData.coords.z
    
    local vehicle = CreateVehicle(model, spawnX, spawnY, spawnZ, vehicleData.heading or 0.0, false, true)
    
    if not DoesEntityExist(vehicle) then 
        print("^1[CarMarket Client]^7 Failed to create vehicle: " .. vehicleData.plate)
        SetModelAsNoLongerNeeded(model)
        return 
    end

    Wait(100)
    
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, vehicleData.plate or "CARMRKT")
    
    if vehicleData.props and type(vehicleData.props) == "table" then
        local success, err = pcall(function()
            ESX.Game.SetVehicleProperties(vehicle, vehicleData.props)
        end)
        if not success then
            print("^3[CarMarket Client]^7 Warning: Failed to apply properties to vehicle " .. vehicleData.plate .. ": " .. tostring(err))
        end
    end
    
    Wait(100)
    SetEntityCoords(vehicle, spawnX, spawnY, spawnZ, false, false, false, true)
    SetEntityHeading(vehicle, vehicleData.heading or 0.0)
    Wait(100)
    
    local vehiclePos = GetEntityCoords(vehicle)
    
    local startRay = vector3(spawnX, spawnY, spawnZ + 1.0)
    local endRay = vector3(spawnX, spawnY, spawnZ - 15.0)
    local raycast = StartShapeTestRay(startRay.x, startRay.y, startRay.z, endRay.x, endRay.y, endRay.z, 1, 0, 0)
    Wait(RAYCAST_WAIT)
    local _, hit, hitCoords = GetShapeTestResult(raycast)
    
    if hit and hitCoords then
        local detectedGroundZ = hitCoords.z
        local groundDistanceFromSpawn = math.abs(detectedGroundZ - spawnZ)
        
        if groundDistanceFromSpawn < GROUND_CHECK_DISTANCE and vehiclePos.z < (detectedGroundZ - GROUND_CHECK_THRESHOLD) then
            print("^3[CarMarket Client]^7 Vehicle " .. vehicleData.plate .. " detected underground (Z=" .. vehiclePos.z .. "), correcting to ground + " .. GROUND_OFFSET .. "m (Z=" .. (detectedGroundZ + GROUND_OFFSET) .. ")")
            SetEntityCoords(vehicle, spawnX, spawnY, detectedGroundZ + GROUND_OFFSET, false, false, false, true)
            Wait(100)
        end
    end
    
    FreezeEntityPosition(vehicle, true)
    SetVehicleDoorsLocked(vehicle, 2)
    SetEntityInvincible(vehicle, true)
    SetVehicleEngineOn(vehicle, false, true, true)
    
    Entity(vehicle).state:set('inCarMarket', true, true)
    Entity(vehicle).state:set('carMarketPlate', vehicleData.plate, true)

    spawnedDisplayVehicles[vehicleData.plate] = vehicle
    SetModelAsNoLongerNeeded(model)
    
    print("^2[CarMarket Client]^7 Successfully spawned vehicle: " .. vehicleData.plate)
    
    configureVehicleInteractions(vehicle, vehicleData)
end

RegisterNetEvent("qf_carMarket:spawnAllVehicles")
AddEventHandler("qf_carMarket:spawnAllVehicles", function(vehiclesData)
    print("^3[CarMarket Client]^7 Received " .. #vehiclesData .. " vehicles to spawn")
    
    if #vehiclesData == 0 then
        print("^3[CarMarket Client]^7 No vehicles to spawn")
        return
    end
    
    local hasExistingVehicles = false
    for plate, vehicle in pairs(spawnedDisplayVehicles) do
        if DoesEntityExist(vehicle) then
            hasExistingVehicles = true
            break
        end
    end
    
    if hasExistingVehicles then
        print("^3[CarMarket Client]^7 Vehicles already spawned, clearing first...")
        for plate, vehicle in pairs(spawnedDisplayVehicles) do
            cleanupVehicle(vehicle)
        end
        spawnedDisplayVehicles = {}
        Wait(SPAWN_DELAY)
    end
    
    for i, vehicleData in ipairs(vehiclesData) do
        print("^3[CarMarket Client]^7 Scheduling spawn for vehicle " .. i .. "/" .. #vehiclesData .. ": " .. vehicleData.plate)
        SetTimeout(i * SPAWN_DELAY, function()
            spawnSingleVehicle(vehicleData)
        end)
    end
end)

RegisterNetEvent("qf_carMarket:spawnVehicle")
AddEventHandler("qf_carMarket:spawnVehicle", function(vehicleData)
    if not vehicleData or not vehicleData.plate then
        print("^1[CarMarket Client]^7 Invalid vehicle data received")
        return
    end

    if spawnedDisplayVehicles[vehicleData.plate] and DoesEntityExist(spawnedDisplayVehicles[vehicleData.plate]) then
        print("^3[CarMarket Client]^7 Vehicle with plate " .. vehicleData.plate .. " already exists, skipping spawn.")
        return
    end

    print("^2[CarMarket Client]^7 Spawning vehicle: " .. vehicleData.plate)
    spawnSingleVehicle(vehicleData)
end)

RegisterNetEvent("qf_carMarket:removeVehicle")
AddEventHandler("qf_carMarket:removeVehicle", function(plate)
    print("^3[CarMarket Client]^7 Received vehicle removal request: " .. plate)
    
    local vehicle = spawnedDisplayVehicles[plate]
    if vehicle then
        cleanupVehicle(vehicle)
    end
    
    spawnedDisplayVehicles[plate] = nil
end)

RegisterNetEvent("exotic_carmarket:requestVehicle", function(Vehicle)
    TriggerServerEvent("qf_carMarket:addVehicleFromClient", {
        plate = Vehicle["Plate"],
        price = Vehicle["Price"]
    })
end)

RegisterNetEvent("qf_carMarket:requestCurrentVehicle")
AddEventHandler("qf_carMarket:requestCurrentVehicle", function(price)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end

    local props = ESX.Game.GetVehicleProperties(veh)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh)):lower()
    local plate = GetVehicleNumberPlateText(veh)

    TriggerServerEvent("qf_carMarket:addVehicleFromClient", {
        plate = plate,
        model = model,
        props = props,
        price = price
    })
end)

RegisterNetEvent("qf_carMarket:requestRemoveVehicle")
AddEventHandler("qf_carMarket:requestRemoveVehicle", function(plate)
    TriggerServerEvent("qf_carMarket:removeVehicleFromClient", plate)
end)

RegisterNetEvent("qf_carMarket:openVehicleCard")
AddEventHandler("qf_carMarket:openVehicleCard", function(vehicleDetails)
    SetNuiFocus(true, true)
    print(json.encode(vehicleDetails))
    SendNUIMessage({
        action = "openVehicleCard",
        data = vehicleDetails
    })
end)

RegisterNUICallback('setNuiFocus', function(data, cb)
    SetNuiFocus(data.hasFocus, data.hasCursor)
    cb('ok')
end)

local function showNotification(type, title, message)
    SendNUIMessage({
        action = "showNotification",
        data = {
            type = type,
            title = title,
            message = message
        }
    })
end

function showLoading(visible, text)
    SendNUIMessage({
        action = "setLoading",
        data = {
            visible = visible,
            text = text or "Ładowanie..."
        }
    })
end

exports('showNotification', showNotification)
exports('showLoading', showLoading)

local function openPriceInput(vehicle)
    local input = lib.inputDialog('Sprzedaż Pojazdu', {
        {type = 'number', label = vehicle.Label, description = 'Kwota ($)', required = true, min = 10000, max = 999999999},
    })
    
    if not input or not input[1] then
        ESX.ShowNotification("Anulowano sprzedaż pojazdu")
        return
    end

    vehicle.Price = input[1]
    TriggerEvent("exotic_carmarket:requestVehicle", vehicle)
end

RegisterNetEvent("exotic_carmarket:openVehiclesMenu", function(ownedVehicles)
    if not ownedVehicles or #ownedVehicles == 0 then
        ESX.ShowNotification("Nie posiadasz żadnych pojazdów do sprzedania")
        return
    end

    local options = {}

    for i, currentVehicle in ipairs(ownedVehicles) do
        local displayModel = getVehicleDisplayName(currentVehicle.Data.model)
        currentVehicle.Model = displayModel
        currentVehicle.Label = "[" .. currentVehicle.Plate .. "]  " .. displayModel

        options[i] = {
            title = currentVehicle.Label,
            onSelect = function()
                openPriceInput(currentVehicle)
            end
        }
    end

    lib.registerContext({
        id = "market_seller_menu",
        title = "Twoje Pojazdy",
        options = options
    })

    lib.showContext("market_seller_menu")
end)

local function onEnter(point)
    if not point.entity then
        local model = lib.requestModel("s_m_m_dockwork_01")
        Wait(1000)
        local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 0.95, point.heading, false, true)
        TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)
        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)
        ox_target:addLocalEntity(entity, {
            {
                icon = 'fa fa-laptop',
                label = point.label,
                canInteract = canPlayerInteract,
                onSelect = function()
                    TriggerServerEvent("exotic_carmarket:requestVehiclesMenu")
                end,
                distance = 2.0
            }
        })
        point.entity = entity
    end
end

local function onExit(point)
    local entity = point.entity
    if not entity then return end
    ox_target:removeLocalEntity(entity, point.label)
    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
    end
    point.entity = nil
end

CreateThread(function ()
    for i=1, #Config.Blips do
        local blip = AddBlipForCoord(Config.Blips[i].Pos)
        SetBlipSprite (blip, Config.Blips[i].Sprite)
        SetBlipDisplay(blip, Config.Blips[i].Display)
        SetBlipScale  (blip, Config.Blips[i].Scale)
        SetBlipColour (blip, Config.Blips[i].Colour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blips[i].Label)
        EndTextCommandSetBlipName(blip)
    end

    for _, v in pairs(Config.Peds) do
        lib.points.new({
            id = v.id,
            distance = v.distance,
            coords = v.coords,
            heading = v.heading,
            label = v.label,
            onEnter = onEnter,
            onExit = onExit
        })
    end
end)

AddEventHandler('entityCreated', function(entity)
    if not DoesEntityExist(entity) then return end
    if GetEntityType(entity) ~= 2 then return end
    
    local state = Entity(entity).state
    if state.inCarMarket and state.carMarketProps then
        Wait(100)
        if DoesEntityExist(entity) then
            ESX.Game.SetVehicleProperties(entity, state.carMarketProps)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for plate, vehicle in pairs(spawnedDisplayVehicles) do
        cleanupVehicle(vehicle)
    end
    
    spawnedDisplayVehicles = {}
    vehiclesRequested = false
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    spawnedDisplayVehicles = {}
    vehiclesRequested = false
    
    SendNUIMessage({
        action = "setVisible",
        data = true
    })
                  
    local localeData = LoadResourceFile(RESOURCE_NAME, 'web/locale.json')
    if localeData then
        local success, locales = pcall(json.decode, localeData)
        if success and type(locales) == "table" then
            SendNUIMessage({
                action = "loadLocales",
                data = locales
            })
        end
    end
end)

AddEventHandler('esx:playerLoaded', function()
    CreateThread(function()
        Wait(3000)
        requestVehiclesFromServer()
    end)
end)