-- exotic_rentalsystem by shevey

Config = {}

Config.CarRental = {
    PedLocation = vector4(-745.7949, -2296.4976, 13.0285, 358.0955),
    PedModel = "a_m_y_business_01",

    SpawnLocation = vector4(-752.9791, -2294.5605, 12.2520, 45.9144),

    Vehicles = {
        {model = "panto", label = "Panto", price = 1200},
        {model = "ingot", label = "Ingot", price = 1400},
        {model = "dilettante", label = "Dilettante", price = 1500},
        {model = "prairie", label = "Prairie", price = 1800},
        {model = "intruder", label = "Intruder", price = 1900},
        {model = "premier", label = "Premier", price = 2100},
        {model = "felon", label = "Felon", price = 3200},
        {model = "f620", label = "F620", price = 4200},
        {model = "exemplar", label = "Exemplar", price = 5000},
        {model = "cogcabrio", label = "Cognoscenti Cabrio", price = 7500},
    }
}

Config.BoatRental = {
    PedLocation = vector4(-795.42, -1510.97, 1.6, 110.0), 
    PedModel = "a_m_y_beach_01",
    
    SpawnLocation = vector4(-798.66, -1507.73, -0.47, 290.0),

    Vehicles = {
        {model = "seashark", label = "Seashark", price = 1000},
        {model = "seashark2", label = "Seashark Lifeguard", price = 1250},
        {model = "seashark3", label = "Seashark Yacht", price = 1500},
        {model = "dinghy", label = "Dinghy", price = 2500},
        {model = "dinghy2", label = "Dinghy 2", price = 2750},
        {model = "suntrap", label = "Suntrap", price = 3250},
        {model = "squalo", label = "Squalo", price = 4250},
        {model = "jetmax", label = "Jetmax", price = 5500},
        {model = "speeder", label = "Speeder", price = 7000},
        {model = "marquis", label = "Marquis", price = 12500},
    }
}

local rentedVehicle = nil
local carRentalPed = nil
local boatRentalPed = nil
local carRentalPedSpawned = false
local boatRentalPedSpawned = false

local function IsPlayerNearby(coords, distance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords) <= distance
end

local function SpawnRentalPed(coords, model)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(1)
    end
    exports["interactions"]:showInteraction(
        vec3(coords.x, coords.y, coords.z), 
        "fa-solid fa-car", 
        "ALT", 
        "Wypożyczalnia", 
        "Naciśnij ALT aby otworzyć menu wypożyczalni"
    )
    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedHearingRange(ped, 0.0)
    SetPedSeeingRange(ped, 0.0)
    SetPedAlertness(ped, 0.0)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    
    return ped
end

local function ResetPedPosition(ped, coords)
    if not ped or not DoesEntityExist(ped) then
        return
    end
    
    SetEntityCoords(ped, coords.x, coords.y, coords.z - 1.0, false, false, false, true)
    SetEntityHeading(ped, coords.w)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
end

local function GiveVehicleKeys(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then
        return
    end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then return end
    
    plate = string.gsub(plate, "^%s*(.-)%s*$", "%1")
    
    if GetResourceState('esx_vehiclekeys') == 'started' then
        local esxKeys = exports['esx_vehiclekeys']
        if esxKeys and esxKeys.giveVehicleKey then
            esxKeys:giveVehicleKey(plate, vehicle)
            return
        elseif esxKeys and esxKeys.GiveKey then
            esxKeys:GiveKey(plate)
            return
        end
    end
    
    if GetResourceState('cd_garage') == 'started' then
        local cdGarage = exports['cd_garage']
        if cdGarage and cdGarage.GiveKeys then
            cdGarage:GiveKeys(plate)
            return
        end
    end
    
    TriggerEvent('esx_vehiclekeys:giveKey', plate)
    TriggerServerEvent('vehiclekeys:server:giveVehicleKey', plate)
    TriggerServerEvent('esx_vehiclekeys:giveVehicleKey', plate)
end

local function ReturnVehicle()
    if not rentedVehicle or not DoesEntityExist(rentedVehicle) then
        ESX.ShowNotification("~r~Nie masz wypożyczonego pojazdu!")
        return
    end
    
    local vehicleModel = GetEntityModel(rentedVehicle)
    local modelName = GetDisplayNameFromVehicleModel(vehicleModel)
    local rentalType = nil
    
    for _, v in ipairs(Config.CarRental.Vehicles) do
        if GetHashKey(v.model) == vehicleModel then
            rentalType = "car"
            break
        end
    end
    
    if not rentalType then
        for _, v in ipairs(Config.BoatRental.Vehicles) do
            if GetHashKey(v.model) == vehicleModel then
                rentalType = "boat"
                break
            end
        end
    end
    
    TriggerServerEvent('exoticrp:returnVehicle', modelName, rentalType or "car")
    
    DeleteVehicle(rentedVehicle)
    rentedVehicle = nil
    ESX.ShowNotification("~g~Pojazd został zwrócony pomyślnie!")
end

local function ShowPaymentMenu(vehicleData, config, rentalType)
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'payment_method', {
        title = 'Wybierz metodę płatności',
        align = 'center',
        elements = {
            {label = 'Gotówka', value = 'cash'},
            {label = 'Karta bankowa', value = 'bank'}
        }
    }, function(data2, menu2)
        local paymentMethod = data2.current.value
        local playerPed = PlayerPedId()
        local spawnCoords = vector3(config.SpawnLocation.x, config.SpawnLocation.y, config.SpawnLocation.z)
        
        ESX.TriggerServerCallback('exoticrp:checkMoney', function(hasMoney)
            if not hasMoney then
                local paymentText = paymentMethod == 'cash' and 'gotówki' or 'środków na koncie'
                ESX.ShowNotification("~r~Nie masz wystarczająco " .. paymentText .. "!")
                return
            end
            
            if not ESX.Game.IsSpawnPointClear(spawnCoords, 5.0) then
                ESX.ShowNotification("~r~Miejsce spawnu jest zajęte!")
                return
            end
            
            ESX.Game.SpawnVehicle(vehicleData.model, spawnCoords, config.SpawnLocation.w, function(vehicle)
                rentedVehicle = vehicle
                local plate = "RENTAL" .. math.random(10, 99)
                SetVehicleNumberPlateText(vehicle, plate)
                SetEntityAsMissionEntity(vehicle, true, true)
                SetVehicleEngineOn(vehicle, true, true, false)
                
                TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                
                Wait(500)
                GiveVehicleKeys(vehicle)
                
                local paymentText = paymentMethod == 'cash' and 'gotówką' or 'kartą'
                ESX.ShowNotification("~g~Wypożyczyłeś pojazd za $" .. vehicleData.price .. " (" .. paymentText .. ")")
                menu2.close()
                ESX.UI.Menu.CloseAll()
            end, true)
        end, vehicleData.price, paymentMethod, vehicleData.model, rentalType)
    end, function(data2, menu2)
        menu2.close()
    end)
end

local function OpenRentalMenu(rentalType)
    local config = rentalType == "car" and Config.CarRental or Config.BoatRental
    local menuTitle = rentalType == "car" and "Wypożyczalnia Samochodów" or "Wypożyczalnia Łodzi"

    if rentedVehicle and DoesEntityExist(rentedVehicle) then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rental_return', {
            title = menuTitle,
            align = 'center',
            elements = {
                {label = 'Zwróć pojazd', value = 'return'},
                {label = 'Anuluj', value = 'cancel'}
            }
        }, function(data, menu)
            if data.current.value == 'return' then
                ReturnVehicle()
            end
            menu.close()
        end, function(data, menu)
            menu.close()
        end)
        return
    end
    
    local elements = {}
    for _, vehicle in ipairs(config.Vehicles) do
        table.insert(elements, {
            label = vehicle.label .. " - <span style='color:green;'>$" .. vehicle.price .. "</span>",
            model = vehicle.model,
            price = vehicle.price
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'rental_menu', {
        title = menuTitle,
        align = 'center',
        elements = elements
    }, function(data, menu)
        ShowPaymentMenu(data.current, config, rentalType)
    end, function(data, menu)
        menu.close()
    end)
end

Citizen.CreateThread(function()
    local CHECK_INTERVAL = 2500
    local RESET_INTERVAL = 30000
    local SPAWN_DISTANCE = 50.0
    
    local carBlip = AddBlipForCoord(Config.CarRental.PedLocation.x, Config.CarRental.PedLocation.y, Config.CarRental.PedLocation.z)
    SetBlipSprite(carBlip, 225)
    SetBlipColour(carBlip, 3)
    SetBlipScale(carBlip, 0.8)
    SetBlipAsShortRange(carBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Wypożyczalnia Samochodów")
    EndTextCommandSetBlipName(carBlip)
    
    local boatBlip = AddBlipForCoord(Config.BoatRental.PedLocation.x, Config.BoatRental.PedLocation.y, Config.BoatRental.PedLocation.z)
    SetBlipSprite(boatBlip, 427)
    SetBlipColour(boatBlip, 3)
    SetBlipScale(boatBlip, 0.8)
    SetBlipAsShortRange(boatBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Wypożyczalnia Łodzi")
    EndTextCommandSetBlipName(boatBlip)
    
    local lastCarReset = GetGameTimer()
    local lastBoatReset = GetGameTimer()
    local carCoords = vector3(Config.CarRental.PedLocation.x, Config.CarRental.PedLocation.y, Config.CarRental.PedLocation.z)
    local boatCoords = vector3(Config.BoatRental.PedLocation.x, Config.BoatRental.PedLocation.y, Config.BoatRental.PedLocation.z)
    
    while true do
        Wait(CHECK_INTERVAL)
        
        local currentTime = GetGameTimer()
        local isNearCarRental = IsPlayerNearby(carCoords, SPAWN_DISTANCE)
        
        if isNearCarRental then
            if not carRentalPedSpawned or not carRentalPed or not DoesEntityExist(carRentalPed) then
                carRentalPed = SpawnRentalPed(Config.CarRental.PedLocation, Config.CarRental.PedModel)
                carRentalPedSpawned = true
                
                exports.ox_target:addLocalEntity(carRentalPed, {
                    {
                        name = 'car_rental',
                        icon = 'fas fa-car',
                        label = 'Wypożycz samochód',
                        distance = 2.5,
                        onSelect = function()
                            OpenRentalMenu("car")
                        end
                    }
                })
            elseif currentTime - lastCarReset >= RESET_INTERVAL then
                ResetPedPosition(carRentalPed, Config.CarRental.PedLocation)
                lastCarReset = currentTime
            end
        elseif carRentalPedSpawned and carRentalPed and DoesEntityExist(carRentalPed) then
            exports.ox_target:removeLocalEntity(carRentalPed, 'car_rental')
            DeletePed(carRentalPed)
            carRentalPed = nil
            carRentalPedSpawned = false
        end
        
        local isNearBoatRental = IsPlayerNearby(boatCoords, SPAWN_DISTANCE)
        
        if isNearBoatRental then
            if not boatRentalPedSpawned or not boatRentalPed or not DoesEntityExist(boatRentalPed) then
                boatRentalPed = SpawnRentalPed(Config.BoatRental.PedLocation, Config.BoatRental.PedModel)
                boatRentalPedSpawned = true
                
                exports.ox_target:addLocalEntity(boatRentalPed, {
                    {
                        name = 'boat_rental',
                        icon = 'fas fa-ship',
                        label = 'Wypożycz łódź',
                        distance = 2.5,
                        onSelect = function()
                            OpenRentalMenu("boat")
                        end
                    }
                })
            elseif currentTime - lastBoatReset >= RESET_INTERVAL then
                ResetPedPosition(boatRentalPed, Config.BoatRental.PedLocation)
                lastBoatReset = currentTime
            end
        elseif boatRentalPedSpawned and boatRentalPed and DoesEntityExist(boatRentalPed) then
            exports.ox_target:removeLocalEntity(boatRentalPed, 'boat_rental')
            DeletePed(boatRentalPed)
            boatRentalPed = nil
            boatRentalPedSpawned = false
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    
    if carRentalPed then
        DeletePed(carRentalPed)
    end
    
    if boatRentalPed then
        DeletePed(boatRentalPed)
    end
    
    if rentedVehicle then
        DeleteVehicle(rentedVehicle)
    end
    
end)

local function startTipsPed()
    local coords = vec4(-757.1389, -2285.1018, 13.0489, 262.8353)
    local model = GetHashKey("a_m_y_business_01")

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local ped = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetEntityProofs(ped, true, true, true, true, true, true, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, true)

    exports["interactions"]:showInteraction(
        vec3(coords.x, coords.y, coords.z),
        "fa-solid fa-question",
        "ALT",
        "Wskazówki",
        "Naciśnij ALT aby dowiedzieć się więcej!"
    )

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'tips_menu',
            icon = 'fas fa-question',
            label = 'Poproś o wskazówkę',
            distance = 2.5,
            onSelect = function()
                exports.exotic_introduction:switchNui()
            end
        }
    })
end
CreateThread(function()
    startTipsPed()

    local blip = AddBlipForCoord(-1119.41357, -1726.52246, 3.29359746)
    SetBlipSprite(blip, 621)
    SetBlipColour(blip, 52)
    SetBlipAsShortRange(blip, true)
    local textEntry = ("Blip:%s"):format(handle)
    AddTextEntry(textEntry, "Park")
    BeginTextCommandSetBlipName(textEntry)
    EndTextCommandSetBlipName(blip)
end)
