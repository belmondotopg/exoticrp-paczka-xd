local Blip = nil
local autoMode = false
local onJob = false
local waypoint = nil
local routes = {}
local customerPed = nil
local spawnerPed = nil
local routeStage = 0
local currentRoute = nil
local currentRouteId = nil
local CustomerIsEnteringVehicle = false
local CustomerEnteredVehicle = false
local inUI = false

local privateSkin = {
    components = nil,
    props = nil
}

local checkJob = function()
    return ESX.PlayerData.job and ESX.PlayerData.job.name == 'taxi'
end

local deleterThread = function()
    CreateThread(function()
        while onJob do
            local sleep = 0
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - Config.Deleter)
            if distance > 15.0 or not IsPedInAnyVehicle(playerPed, false) then
                sleep = 1000
            elseif distance < 10.0 and IsPedInAnyVehicle(playerPed, false) then
                DrawMarker(1, Config.Deleter.x, Config.Deleter.y,
                           Config.Deleter.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                           5.0, 5.0, 2.0, 255, 128, 0, 50, false, true, 2, nil,
                           nil, false)

                if distance < 3.0 then
                    sleep = 0
                    ESX.ShowHelpNotification(
                        'Nacisnij ~INPUT_CONTEXT~ aby usunąć pojazd')
                    if IsControlJustPressed(0, 38) then
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        if vehicle then
                            local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
                            if string.find(plate, 'TAXI') then
                                -- Usuń klucze przed usunięciem pojazdu
                                TriggerServerEvent('esx_carkeys:deleteKeys', plate)
                                Wait(100) -- Czekamy chwilę na usunięcie kluczy
                                ESX.Game.DeleteVehicle(vehicle)
                            else
                                ESX.ShowNotification('To nie jest pojazd służbowy!')
                            end
                        end
                    end
                end
            end
            Wait(sleep)
        end
    end)
end

local startJob = function()
    if checkJob() then
        if not onJob then
            onJob = true
            createJobTargets()
            TriggerServerEvent('taxiJob:startJob')
            deleterThread()
        end
    end
end

local stopJob = function()
    if currentRoute then abandonRoute() end
    onJob = false
    TriggerServerEvent('taxiJob:stopJob')
    if spawnerPed and DoesEntityExist(spawnerPed) then
        exports.ox_target:removeLocalEntity({ spawnerPed }, 'taxi:spawner')
    end
end

local getSex = function()
    local appearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
    local sex = appearance.model == 'mp_m_freemode_01' and 'male' or 'female'
    return sex
end

local addClothes = function(sex)
    local input = lib.inputDialog('Dodaj Strój', {
        {
            type = 'input',
            label = 'Nazwa stroju',
            required = true,
            min = 1,
            max = 255
        }
    })

    if not input or not input[1] then return end
    local appearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
    local skin = {
        props = appearance.props,
        components = appearance.components
    }
    TriggerServerEvent('taxijob:addSkin', input[1], skin, sex)
end

local wearClothes = function(skin)
    if not onJob then
        local appearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
        privateSkin = {
            props = appearance.props,
            components = appearance.components
        }
    end
    exports['qf_skinmenu']:setPedAppearance(PlayerPedId(), skin)
end

local fetchClothes = function(sex)
    local clothesData = lib.callback.await('taxijob:getClothes', false, sex)
    local clothes = {}
    for i = 1, #clothesData do
        table.insert(clothes, {
            title = clothesData[i].name,
            onSelect = function()
                wearClothes(json.decode(clothesData[i].skin))
                startJob()
            end
        })
    end
    return clothes
end

local fetchClothesDelete = function(sex)
    local clothesData = lib.callback.await('taxijob:getClothes', false, sex)
    local clothes = {}
    for i = 1, #clothesData do
        table.insert(clothes, {
            title = clothesData[i].name,
            onSelect = function()
                TriggerServerEvent('taxijob:deleteSkin', clothesData[i].id)
            end
        })
    end
    return clothes
end

local createMenu = function()
    local Options = {}
    local sex = getSex()
    local clothes = fetchClothes(sex)

    if checkJob() and ESX.PlayerData.job.grade >= Config.addClothesGrade then
        table.insert(Options, {
            title = 'Dodaj Strój',
            onSelect = function() addClothes(sex) end
        })
    end

    for i = 1, #clothes do table.insert(Options, clothes[i]) end

    table.insert(Options, {
        title = "Strój Prywatny",
        onSelect = function()
            wearClothes(privateSkin)
            stopJob()
        end
    })

    lib.registerContext({
        id = 'taxi_przebieralnia',
        title = 'Stroje Taxi',
        options = Options
    })
end

local createDeleteMenu = function()
    local Options = {}
    local sex = getSex()
    local clothes = fetchClothesDelete(sex)

    for i = 1, #clothes do table.insert(Options, clothes[i]) end

    lib.registerContext({
        id = 'taxi_przebieralnia_delete',
        title = 'Usuń Strój',
        options = Options
    })
end

local openPrzebieralnia = function()
    createMenu()
    lib.showContext('taxi_przebieralnia')
end

local openPrzebieralniaDelete = function()
    createDeleteMenu()
    lib.showContext('taxi_przebieralnia_delete')
end

local openBossMenu = function()
    TriggerServerEvent('esx_society:openbosshub', 'legal', false, true, nil)
end

createSpawnerPed = function()
    if spawnerPed and DoesEntityExist(spawnerPed) then
        DeleteEntity(spawnerPed)
    end

    local modelHash = GetHashKey(Config.Spawner.pedModel)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    local coords = Config.Spawner.pedCoords
    spawnerPed = CreatePed(4, modelHash, coords.x, coords.y, coords.z, Config.Spawner.pedHeading, false, true)
    
    SetEntityAsMissionEntity(spawnerPed, true, true)
    SetPedFleeAttributes(spawnerPed, 0, 0)
    SetBlockingOfNonTemporaryEvents(spawnerPed, true)
    SetPedCanRagdollFromPlayerImpact(spawnerPed, false)
    SetPedDiesWhenInjured(spawnerPed, false)
    FreezeEntityPosition(spawnerPed, true)
    
    -- Dodaj target na peda
    Wait(100) -- Czekamy chwilę, aby ped był w pełni załadowany
    exports.ox_target:addLocalEntity({ spawnerPed }, {
        {
            name = 'taxi:spawner',
            icon = 'fa-solid fa-car',
            label = 'Wybierz Pojazd',
            distance = 2.0,
            groups = 'taxi',
            onSelect = function()
                if onJob then
                    openVehicleMenu()
                else
                    lib.notify({
                        title = 'Błąd',
                        description = 'Musisz rozpocząć pracę, aby wybrać pojazd!',
                        type = 'error'
                    })
                end
            end
        }
    })
end

createDefaultTargets = function()
    exports.ox_target:addSphereZone({
        name = 'taxi_przebieralnia',
        coords = vector3(-1259.4821, -290.7396, 40.1789-.95),
        radius = 1.5,
        debug = Config.Debug,
        options = {
            {
                name = 'taxi:przebieralnia',
                icon = 'fa-solid fa-tshirt',
                label = 'Przebieralnia',
                distance = 2,
                groups = {'taxi'},
                onSelect = function() openPrzebieralnia() end
            }, {
                name = 'taxi:przebieralniaDelete',
                icon = 'fa-solid fa-tshirt',
                label = 'Usuń Strój',
                distance = 2,
                groups = {taxi = Config.addClothesGrade},
                onSelect = function()
                    openPrzebieralniaDelete()
                end
            }, {
                name = 'taxi:szafkapubliczna',
                icon = 'fa-solid fa-users',
                label = 'Szafka Publiczna',
                distance = 2,
                groups = {taxi = 2},
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', {id = 'taxi_public'})
                end
            }, {
                name = 'taxi:szafkaprywatna',
                icon = 'fa-solid fa-users',
                label = 'Szafka Prywatna',
                distance = 2,
                groups = {taxi = 0},
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', {id = 'taxi_private'})
                end
            }
        }
    })

   exports.ox_target:addSphereZone({
        name = 'taxi_bossMenu',
        coords = vector3(-1243.6469, -276.9409, 44.9698-.95),
        radius = 1.5,
        debug = Config.Debug,
        options = {
            {
                name = 'taxi:bossmenu',
                icon = 'fa-solid fa-users',
                label = 'Menu Szefa',
                distance = 2,
                canInteract = function()
                    if not ESX.PlayerData.job or ESX.PlayerData.job.name ~= 'taxi' then
                        return false
                    end
                    local grade = ESX.PlayerData.job.grade or 0
                    local gradeName = ESX.PlayerData.job.grade_name or ""
                    local hasGrade = grade >= Config.bossMenuGrade
                    local isKierownik = gradeName == "kierownik"
                    return hasGrade or isKierownik
                end,
                onSelect = function() openBossMenu() end
            }
        }
    })

    exports.ox_target:addSphereZone({
        name = 'taxi_zarzadszafka',
        coords = vector3(-1254.1094, -268.9099, 44.4910-.95),
        radius = 1.5,
        debug = Config.Debug,
        options = {
            {
                name = 'taxi:zarzadszakfa',
                icon = 'fa-solid fa-users',
                label = 'Szafka zarządu',
                distance = 2,
                groups = {taxi = 5}, -- Kierownik i wyżej (grade 5+)
                onSelect = function()
                    exports.ox_inventory:openInventory('stash', {id = 'taxi_zarzad'})
                end
            }
        }
    })
end

openVehicleMenu = function()
    if not checkJob() then return end

    local options = {}

    for _, vehicle in ipairs(Config.Vehicles) do
        if ESX.PlayerData.job and ESX.PlayerData.job.grade >= vehicle.minGrade then
            table.insert(options, {
                title = vehicle.title,
                icon = 'car',
                onSelect = function()
                    ESX.Game.SpawnVehicle(vehicle.model, Config.Spawner.vehicleSpawnerCoords, 209.0, function(veh)
                        if DoesEntityExist(veh) then
                            local playerPed = PlayerPedId()
                            TaskWarpPedIntoVehicle(playerPed, veh, -1)
                            local plate = ('TAXI%s'):format(math.random(1000, 9999))
                            SetVehicleNumberPlateText(veh, plate)
                            SetVehicleFuelLevel(veh, 100.0)
                            DecorSetFloat(veh, "_FUEL_LEVEL", 100.0)
                            Wait(100)
                            TriggerServerEvent('esx_carkeys:getKeys', plate)
                        else
                            lib.notify({
                                title = 'Błąd',
                                description = 'Nie udało się zespawnować pojazdu.',
                                type = 'error'
                            })
                        end
                    end)
                end
            })
        end
    end

    if #options == 0 then
        lib.notify({
            title = 'Brak pojazdów',
            description = 'Nie masz dostępu do żadnego pojazdu.',
            type = 'error'
        })
        return
    end

    lib.registerContext({
        id = 'taxi_auta',
        title = 'Wybierz auto',
        options = options
    })

    lib.showContext('taxi_auta')
end

createJobTargets = function()
    -- Dodaj target z powrotem do spawnerPed po zatrzymaniu pracy
    if spawnerPed and DoesEntityExist(spawnerPed) then
        Wait(100) -- Czekamy chwilę, aby upewnić się, że ped jest gotowy
        exports.ox_target:addLocalEntity({ spawnerPed }, {
            {
                name = 'taxi:spawner',
                icon = 'fa-solid fa-car',
                label = 'Wybierz Pojazd',
                distance = 2.0,
                groups = 'taxi',
                onSelect = function()
                    if onJob then
                        openVehicleMenu()
                    else
                        lib.notify({
                            title = 'Błąd',
                            description = 'Musisz rozpocząć pracę, aby wybrać pojazd!',
                            type = 'error'
                        })
                    end
                end
            }
        })
    end
end

local inAuthorizedVehicle = function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and vehicle ~= 0 then
        local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
        if plate and string.find(plate, 'TAXI') then return true end
    end
    return false
end

createDefaultBlip = function()
    Blip = AddBlipForCoord(Config.Blip.coords)
    SetBlipSprite(Blip, Config.Blip.id)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, Config.Blip.scale)
    SetBlipColour(Blip, Config.Blip.color)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.title)
    EndTextCommandSetBlipName(Blip)
end

local removeWaypoint = function()
    if waypoint then
        RemoveBlip(waypoint)
        waypoint = nil
    end
end

local clearVariables = function()
    routeStage = 0
    currentRoute = nil
    currentRouteId = nil
    CustomerIsEnteringVehicle = false
    CustomerEnteredVehicle = false
    -- Usuń peda jeśli istnieje
    if customerPed and DoesEntityExist(customerPed) then
        DeleteEntity(customerPed)
        customerPed = nil
    end
end

local createWaypoint = function(coords, title)
    waypoint = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(waypoint, 280)
    SetBlipColour(waypoint, 5)
    SetBlipRoute(waypoint, true)
    SetBlipRouteColour(waypoint, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(title)
    EndTextCommandSetBlipName(waypoint)
end

local deletePedAfterTime = function(ped, time)
    CreateThread(function()
        local pedToDelete = ped
        Wait(time)
        if pedToDelete and DoesEntityExist(pedToDelete) then
            DeleteEntity(pedToDelete)
        end
    end)
end

local finishRoute = function()
    removeWaypoint()
    SendNUIMessage({action = 'haveRoute', data = false})
    clearVariables()
    CreateThread(function()
        if customerPed and DoesEntityExist(customerPed) then
            TaskWanderStandard(customerPed, 10.0, 10)
            deletePedAfterTime(customerPed, 10000)
            customerPed = nil
        end
    end)
end

abandonRoute = function()
    finishRoute()
    TriggerServerEvent('taxijob:abandonRoute')
    -- Odśwież trasy po porzuceniu
    Wait(500)
    if onJob then
        updateNUIData()
    end
end

local startPedRoute = function(id)
    if not currentRoute then return end
    routeStage = 2
    removeWaypoint()
    createWaypoint(currentRoute.finish, "Punkt Docelowy")

    CreateThread(function()
        local isLeaving = false
        while currentRoute ~= nil and routeStage == 2 do
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle and DoesEntityExist(vehicle) and customerPed and DoesEntityExist(customerPed) then
                local vehicleCoords = GetEntityCoords(vehicle)
                local distanceToTarget = #(vehicleCoords - currentRoute.finish)
                local vehicleSpeed = GetEntitySpeed(vehicle)

                if distanceToTarget < 10.0 and vehicleSpeed < 1.0 and
                    CustomerEnteredVehicle and IsPedSittingInVehicle(customerPed, vehicle) then
                    isLeaving = true
                    TaskLeaveVehicle(customerPed, vehicle, 0)
                end
                if isLeaving and customerPed and DoesEntityExist(customerPed) and not IsPedSittingInVehicle(customerPed, vehicle) then
                    local routeId = currentRouteId
                    finishRoute()
                    if routeId then
                        TriggerServerEvent('taxiJob:finishRoute', routeId)
                    end
                    break
                end
            end
            Wait(100)
        end
    end)
end

local getFreeSeat = function(vehicle)
    local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
    for i = maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle, i) then
            freeSeat = i
            break
        end
    end
    return freeSeat
end

local tryEnterVehicle = function(id)
    CreateThread(function()
        local playerPed = PlayerPedId()
        while routeStage == 1 and currentRoute ~= nil do
            if customerPed and DoesEntityExist(customerPed) and routeStage == 1 then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(GetEntityCoords(customerPed) - playerCoords)

                if distance < 10.0 and vehicle and vehicle ~= 0 then
                    if not CustomerIsEnteringVehicle and
                        not IsPedSittingInVehicle(customerPed, vehicle) then
                        ClearPedTasksImmediately(customerPed)

                        local freeSeat = getFreeSeat(vehicle)

                        if freeSeat then
                            TaskEnterVehicle(customerPed, vehicle, -1, freeSeat,
                                             2.0, 1, 0)
                            CustomerIsEnteringVehicle = true
                            CreateThread(function()
                                while CustomerIsEnteringVehicle and routeStage == 1 do
                                    if customerPed and DoesEntityExist(customerPed) and IsPedSittingInVehicle(customerPed, vehicle) then
                                        CustomerIsEnteringVehicle = false
                                        CustomerEnteredVehicle = true
                                        if routeStage == 1 then
                                            startPedRoute(id)
                                        end
                                        break
                                    end
                                    Wait(100)
                                end
                            end)
                        end
                    end
                end
            end
            Wait(500)
        end
    end)
end

local GetGenderFromName = function(name)
    local lastChar = name:sub(-1):lower()
    if lastChar == "a" then
        return "Female"
    else
        return "Male"
    end
end

local spawnPed = function(coords, name)
    CreateThread(function()
        local sex = GetGenderFromName(name)
        local pedModel = Config.Peds[sex][math.random(1, #Config.Peds[sex])]
        local modelHash = GetHashKey(pedModel)
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do Wait(0) end

        -- Lepsza metoda znajdowania ziemi
        local found, groundZ = false, coords.z
        local testZ = coords.z
        
        -- Sprawdzamy różne wysokości, zaczynając od oryginalnej
        for i = 0, 100 do
            local testHeight = coords.z - (i * 0.5)
            found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, testHeight, false)
            if found then
                break
            end
        end
        
        -- Jeśli nie znaleziono, użyj oryginalnej wysokości
        if not found then
            groundZ = coords.z
        end
        
        -- Dodaj mały offset, aby ped był na ziemi
        groundZ = groundZ + 0.1

        customerPed = CreatePed(4, modelHash, coords.x, coords.y, groundZ, 0.0,
                                true, true)

        if DoesEntityExist(customerPed) then
            SetEntityAsMissionEntity(customerPed, true, false)
            ClearPedTasksImmediately(customerPed)
            SetBlockingOfNonTemporaryEvents(customerPed, true)
            SetPedFleeAttributes(customerPed, 0, 0)
            SetPedCombatAttributes(customerPed, 46, true)
            TaskStartScenarioInPlace(customerPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
            
            -- Upewnij się, że ped jest na ziemi
            Wait(100)
            local pedCoords = GetEntityCoords(customerPed)
            local _, finalZ = GetGroundZFor_3dCoord(pedCoords.x, pedCoords.y, pedCoords.z + 10.0, false)
            if finalZ then
                SetEntityCoords(customerPed, pedCoords.x, pedCoords.y, finalZ + 0.1, false, false, false, false)
            end
        end
    end)
end

startRoute = function(id)
    -- Sprawdź czy trasa nadal istnieje
    if not routes[id] then
        lib.notify({
            title = 'Błąd',
            description = 'Ta trasa nie jest już dostępna.',
            type = 'error'
        })
        return
    end
    
    currentRoute = routes[id]
    currentRouteId = id
    routeStage = 1
    SendNUIMessage({action = 'haveRoute', data = true})
    CreateThread(function()
        if not currentRoute then return end

        createWaypoint(currentRoute.start, "Odbierz Klienta")

        while routeStage == 1 and currentRoute ~= nil do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - currentRoute.start)

            if distance < 100 and not customerPed and routeStage == 1 then
                spawnPed(currentRoute.start, currentRoute.name)
            end

            if customerPed and DoesEntityExist(customerPed) and IsPedFatallyInjured(customerPed) then
                abandonRoute()
                break
            end

            if distance < 10.0 and inAuthorizedVehicle() and routeStage == 1 then
                tryEnterVehicle(id)
            end
            Wait(500)
        end
    end)
end

updateNUIData = function()
    if not onJob then return end
    routes = lib.callback.await('taxiJob:getRoutes', false)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local data = {}

    for id, route in pairs(routes) do
        local distanceToMe = #(playerCoords - route.start)
        table.insert(data, {
            name = route.name,
            stars = route.stars,
            distanceToMe = math.floor(distanceToMe),
            distanceToTarget = math.floor(#(route.start - route.finish)),
            vip = route.vip,
            id = id
        })
    end
    SendNUIMessage({action = 'setData', data = data})
end

RegisterKeyMapping('toggleTaxiMenu', 'Przełącz tablet taxi', 'keyboard', 'F6')

RegisterCommand('toggleTaxiMenu', function()
    if checkJob() then
        if onJob and not inUI then
            updateNUIData()
            SetNuiFocus(true, true)
            inUI = true
            SendNUIMessage({action = 'setVisible', data = true})
        end
    end
end, false)

RegisterCommand('anulujprzejazd', function()
    if checkJob() and onJob then
        if currentRoute then
            abandonRoute()
            lib.notify({
                title = 'Taxi',
                description = 'Anulowano przejazd',
                type = 'success'
            })
        else
            lib.notify({
                title = 'Taxi',
                description = 'Nie masz aktywnego przejazdu do anulowania',
                type = 'error'
            })
        end
    end
end, false)

RegisterNUICallback('hideFrame', function(data, cb)
    SetNuiFocus(false, false)
    inUI = false
    SendNUIMessage({action = 'setVisible', data = false})
    cb('ok')
end)

RegisterNUICallback('RefreshData', function(data, cb)
    updateNUIData()
    cb('ok')
end)

RegisterNUICallback('startRoute', function(data, cb)
    if data and data.id then
        local playerCoords = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('taxiJob:startRoute', data.id, playerCoords)
    end
    cb({success = true})
end)

local startAutoMode = function()
    CreateThread(function()
        while autoMode do
            if not currentRoute then
                routes = lib.callback.await('taxiJob:getRoutes', false)
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local closestDistance = math.huge
                local closestRoute = nil

                for id, route in pairs(routes) do
                    local distance = #(playerCoords - route.start)
                    if distance < closestDistance then
                        closestDistance = distance
                        closestRoute = id
                    end
                end

                if closestRoute then
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    TriggerServerEvent('taxiJob:startRoute', closestRoute, playerCoords)
                end
            end
            Wait(5000)
        end
    end)
end

RegisterNUICallback('ToggleAuto', function(data, cb)
    autoMode = not autoMode
    cb({success = true, data = autoMode})
    if autoMode then 
        startAutoMode() 
    end
    if not autoMode and currentRoute then
        updateNUIData()
        SendNUIMessage({action = 'haveRoute', data = true})
    end
end)

RegisterNUICallback('abandonRoute', function(data, cb)
    if currentRoute then
        abandonRoute()
        lib.notify({
            title = 'Taxi',
            description = 'Anulowano przejazd',
            type = 'success'
        })
        cb({success = true})
    else
        cb({success = false, error = 'Brak aktywnego przejazdu'})
    end
end)

