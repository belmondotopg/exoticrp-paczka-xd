local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target
local esx_hud = exports.esx_hud
local economy = Config.Economy['weazelnews']


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

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
    ESX.PlayerData.job = Job
end)

local Control = {
    isWorking = false,
    Car = {
        have = false,
        netid = nil,
    }
}

local jobBlips = {}
local weazelTargets = {}
local weazelBlips = {}
local processsTargets = {}
local processsBlips = {}
local sortedPhotos = {}
local currentPhotoIndex = 1
local baseBlip = nil
local processBlip = nil
local showProcessBlip = false


local function UpdatePhotoBlips()
    for i, photo in ipairs(sortedPhotos) do
        if weazelBlips[photo.name] and DoesBlipExist(weazelBlips[photo.name]) then
            if i == currentPhotoIndex then
                SetBlipColour(weazelBlips[photo.name], 1)
                SetBlipScale(weazelBlips[photo.name], 0.9)
                SetBlipRoute(weazelBlips[photo.name], true)
                SetBlipRouteColour(weazelBlips[photo.name], 1)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("! Zdjęcie do zrobienia")
                EndTextCommandSetBlipName(weazelBlips[photo.name])
            else
                SetBlipColour(weazelBlips[photo.name], 6)
                SetBlipScale(weazelBlips[photo.name], 0.75)
                SetBlipRoute(weazelBlips[photo.name], false)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Zdjęcie do zrobienia")
                EndTextCommandSetBlipName(weazelBlips[photo.name])
            end
        end
    end
end

local function ShowProcessBlip()
    if processBlip and DoesBlipExist(processBlip) then
        RemoveBlip(processBlip)
    end

    local processCoords = vec3(1735.4873, -1646.3447, 113.6612)
    processBlip = AddBlipForCoord(processCoords)
    SetBlipSprite(processBlip, 643)
    SetBlipDisplay(processBlip, 4)
    SetBlipScale(processBlip, 0.9)
    SetBlipColour(processBlip, 1)
    SetBlipAsShortRange(processBlip, true)
    SetBlipRoute(processBlip, true)
    SetBlipRouteColour(processBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("! Obrób zdjęcia")
    EndTextCommandSetBlipName(processBlip)
    showProcessBlip = true
end

local function ShowBaseBlip()
    if baseBlip and DoesBlipExist(baseBlip) then
        RemoveBlip(baseBlip)
    end

    if processBlip and DoesBlipExist(processBlip) then
        RemoveBlip(processBlip)
        processBlip = nil
    end

    local baseCoords = Config.Coords['weazelnews'].vehicles.spawn
    baseBlip = AddBlipForCoord(baseCoords.x, baseCoords.y, baseCoords.z)
    SetBlipSprite(baseBlip, 641)
    SetBlipDisplay(baseBlip, 4)
    SetBlipScale(baseBlip, 0.9)
    SetBlipColour(baseBlip, 1)
    SetBlipAsShortRange(baseBlip, true)
    SetBlipRoute(baseBlip, true)
    SetBlipRouteColour(baseBlip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("! Powrót do bazy")
    EndTextCommandSetBlipName(baseBlip)
    showProcessBlip = false
end

local function ToggleBlips(enable)
    local blipConfig = {
        {
            coords = vector3(-532.6516, -890.0948, 24.7735),
            label = "Garaż",
            sprite = 641,
            color = 6,
            scale = 0.8
        },
        {
            coords = vector3(-577.5723, -923.0718, 23.8697),
            label = "Skup obrobionych zdjęć",
            sprite = 642,
            color = 6,
            scale = 0.8
        },
    }

    if enable then
        for i, config in ipairs(blipConfig) do
            local blip = AddBlipForCoord(config.coords)
            SetBlipSprite(blip, config.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, config.scale)
            SetBlipColour(blip, config.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(config.label)
            EndTextCommandSetBlipName(blip)
            jobBlips[i] = blip
        end
    else
        for _, blip in pairs(jobBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        jobBlips = {}
    end
end

local function TakePhoto(photo)
    local animDict = "amb@world_human_paparazzi@male@idle_a"
    local animName = "idle_c"
    local cameraModel = `prop_pap_camera_01`

    RequestModel(cameraModel)
    while not HasModelLoaded(cameraModel) do
        Wait(10)
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    local camera = CreateObject(cameraModel, cacheCoords, true, true, false)
    AttachEntityToEntity(camera, cachePed, GetPedBoneIndex(cachePed, 0xE5F2), 0.1, -0.05, 0.0, -10.0, 50.0, 5.0, 1, 0, 0, 0, 0, 1)

    FreezeEntityPosition(cachePed, true)

    local takingPhoto = true

    CreateThread(function()
        while takingPhoto do
            if not IsEntityPlayingAnim(cachePed, animDict, animName, 3) then
                TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
            end
            Wait(0)
        end
    end)

    if esx_hud:progressBar({
        duration = 8,
        label = "Robisz zdjęcia...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
    }) then
        takingPhoto = false
        ClearPedTasks(cachePed)
        TriggerServerEvent('esx_jobs/weazelnews/photoTaken', photo.coords)
        ESX.ShowNotification('Zrobiłeś zdjęcia!')

        ox_target:removeZone(photo.name)
        weazelTargets[photo.name] = nil

        if DoesBlipExist(weazelBlips[photo.name]) then
            RemoveBlip(weazelBlips[photo.name])
            weazelBlips[photo.name] = nil
        end

        currentPhotoIndex = currentPhotoIndex + 1

        if currentPhotoIndex <= #sortedPhotos then
            UpdatePhotoBlips()
            local nextPhoto = sortedPhotos[currentPhotoIndex]
            ESX.ShowNotification('Następny punkt: ' .. math.floor(#(cacheCoords - nextPhoto.coords)) .. 'm')
        else
            ShowProcessBlip()
            ESX.ShowNotification('Wszystkie zdjęcia zrobione! Jedź do obróbki zdjęć.')
        end
    else
        takingPhoto = false
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano robienie zdjęć.')
    end

    if DoesEntityExist(camera) then
        DetachEntity(camera, true, true)
        DeleteEntity(camera)
    end

    FreezeEntityPosition(cachePed, false)
end

local function ToggleWeazelNewsPhotos(enable)
    local photosConfig = {
        {
            name = "pho16561211212to1",
            coords = vec3(-516.3, -729.0, 33.25),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 42.0,
        },
        {
            name = "pho61364788to1",
            coords = vec3(-253.1959, -900.2599, 31.9980),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 42.0,
        },
        {
            name = "ph15133516671oto1",
            coords = vec3(-606.3193, -1094.8607, 22.3249),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 42.0,
        },
        {
            name = "ph617oto1",
            coords = vec3(-556.5853, -618.4819, 34.6762),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 42.0,
        },
        {
            name = "phot51515o1",
            coords = vec3(507.7555, -1458.5535, 30.5376),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 42.0,
        },
        {
            name = "phot154151515o1",
            coords = vec3(1241.7219, -366.4670, 70.1486),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 343.0,
        },
        {
            name = "111111ph4ot154151515o1",
            coords = vec3(1130.3395, -776.8751, 57.6100),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 343.0,
        },
        {
            name = "w8ziomoui1hyugfahuyighayuphoto",
            coords = vec3(719.0810, -2103.0166, 29.6457),
            size = vec3(1.25, 5.25, 4.75),
            rotation = 343.0,
        },
    }

    if enable then
        sortedPhotos = photosConfig
        currentPhotoIndex = 1

        for i, photo in ipairs(sortedPhotos) do
            local blip = AddBlipForCoord(photo.coords)
            SetBlipSprite(blip, 655)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Zdjęcie do zrobienia")
            EndTextCommandSetBlipName(blip)
            weazelBlips[photo.name] = blip

            local zone = ox_target:addBoxZone({
                name = photo.name,
                coords = photo.coords,
                size = photo.size,
                rotation = photo.rotation,
                debug = false,
                options = {
                    {
                        icon = "fas fa-camera",
                        label = "Zrób zdjęcia",
                        distance = 5.0,
                        onSelect = function()
                            if not Control.Car.have then
                                ESX.ShowNotification('Musisz posiadać swój pojazd, aby robić zdjęcia!')
                                return
                            end

                            ESX.ShowNotification('Rozpocząłeś robienie zdjęć.')
                            TakePhoto(photo)
                        end
                    }
                }
            })

            weazelTargets[photo.name] = zone
        end

        UpdatePhotoBlips()
    else
        for k, _ in pairs(weazelTargets) do
            ox_target:removeZone(k)
        end
        weazelTargets = {}

        for k, blip in pairs(weazelBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        weazelBlips = {}

        if baseBlip and DoesBlipExist(baseBlip) then
            RemoveBlip(baseBlip)
            baseBlip = nil
        end

        if processBlip and DoesBlipExist(processBlip) then
            RemoveBlip(processBlip)
            processBlip = nil
        end

        sortedPhotos = {}
        currentPhotoIndex = 1
        showProcessBlip = false
    end
end

local function StartProcessPhoto(coords)
    local animDict = "anim@heists@prison_heistig1_p1_guard_checks_bus"
    local animName = "loop"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    FreezeEntityPosition(cachePed, true)

    local editing = true

    CreateThread(function()
        while editing do
            if not IsEntityPlayingAnim(cachePed, animDict, animName, 3) then
                TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
            end
            Wait(0)
        end
    end)

    if esx_hud:progressBar({
        duration = 10,
        label = "Obrabiasz zdjęcia...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
    }) then
        editing = false
        ClearPedTasks(cachePed)
        TriggerServerEvent('esx_jobs/weazelnews/processPhotos', coords)
        
        if showProcessBlip then
            ShowBaseBlip()
            ESX.ShowNotification('Zdjęcia obrobione! Wróć do garażu.')
        end
    else
        editing = false
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano obróbkę zdjęć.')
    end
    
    FreezeEntityPosition(cachePed, false)
end

local function ToggleWeazelNewsProcesses(enable)
    local processesConfig = {
        {
            name = "processphoto1",
            coords = vec3(1735.4873, -1646.3447, 113.6612),
            size = vec3(1.1, 2.6, 2.0),
            rotation = 281.5817,
        },
    }

    if enable then
        for i, process in ipairs(processesConfig) do
            local blip = AddBlipForCoord(process.coords)
            SetBlipSprite(blip, 643)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 6)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Stanowisko do obróbki zdjęć")
            EndTextCommandSetBlipName(blip)
            processsBlips[process.name] = blip

            local zone = ox_target:addBoxZone({
                name = process.name,
                coords = process.coords,
                size = process.size,
                rotation = process.rotation,
                debug = false,
                options = {
                    {
                        icon = "fa-solid fa-cubes",
                        label = "Obrób zdjęcia",
                        distance = 2.0,
                        onSelect = function()
                            local count = ox_inventory:Search('count', 'photo')
                            if count and count < economy.process.inputAmount then
                                ESX.ShowNotification('Musisz posiadać przy sobie minimum ' .. economy.process.inputAmount .. ' sztuk zdjęć!')
                                return
                            end

                            ESX.ShowNotification('Rozpocząłeś obrabianie zdjęć.')
                            StartProcessPhoto(process.coords)
                        end
                    }
                }
            })

            processsTargets[process.name] = zone
        end
    else
        for k, _ in pairs(processsTargets) do
            ox_target:removeZone(k)
        end
        processsTargets = {}

        for k, blip in pairs(processsBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        processsBlips = {}
    end
end

local LastClothes = nil

local function playClothingAnim()
    local dict = "clothingshirt"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
    TaskPlayAnim(cachePed, dict, "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    Wait(1000)
end

local function LoadClothes(work)
    local isMale = (GetEntityModel(cachePed) == `mp_m_freemode_01`)
    local uniform = isMale and Config.Uniforms['weazelnews'].male or Config.Uniforms['weazelnews'].female

    Control.isWorking = work

    if work then
        if Control.Car.have then
            if Control.Car.netid and NetworkDoesEntityExistWithNetworkId(Control.Car.netid) then
                ESX.ShowNotification('Pierw musisz schować swój pojazd!')
                return
            else
                Control.Car.have = false
                Control.Car.netid = nil
            end
        end
        if LastClothes == nil then
            playClothingAnim()

            LastClothes = {
                tshirt_1 = GetPedDrawableVariation(cachePed, 8),
                tshirt_2 = GetPedTextureVariation(cachePed, 8),
                torso_1 = GetPedDrawableVariation(cachePed, 11),
                torso_2 = GetPedTextureVariation(cachePed, 11),
                arms = GetPedDrawableVariation(cachePed, 3),
                pants_1 = GetPedDrawableVariation(cachePed, 4),
                pants_2 = GetPedTextureVariation(cachePed, 4),
                shoes_1 = GetPedDrawableVariation(cachePed, 6),
                shoes_2 = GetPedTextureVariation(cachePed, 6),
                helmet_1 = GetPedPropIndex(cachePed, 0),
                helmet_2 = GetPedPropTextureIndex(cachePed, 0)
            }

            SetPedComponentVariation(cachePed, 8,  uniform.tshirt_1 or 0, uniform.tshirt_2 or 0, 2)
            SetPedComponentVariation(cachePed, 11, uniform.torso_1 or 0,  uniform.torso_2 or 0, 2)
            SetPedComponentVariation(cachePed, 3,  uniform.arms or 0,     0,                   2)
            SetPedComponentVariation(cachePed, 4,  uniform.pants_1 or 0, uniform.pants_2 or 0, 2)
            SetPedComponentVariation(cachePed, 6,  uniform.shoes_1 or 0, uniform.shoes_2 or 0, 2)

            if uniform.helmet_1 and uniform.helmet_1 ~= -1 then
                SetPedPropIndex(cachePed, 0, uniform.helmet_1, uniform.helmet_2 or 0, true)
            else
                ClearPedProp(cachePed, 0)
            end

            ESX.ShowNotification('Przebrano się w strój roboczy, rozpoczęto pracę!')
        end
    else
        if LastClothes then
            playClothingAnim()

            SetPedComponentVariation(cachePed, 8,  LastClothes.tshirt_1, LastClothes.tshirt_2, 2)
            SetPedComponentVariation(cachePed, 11, LastClothes.torso_1,  LastClothes.torso_2, 2)
            SetPedComponentVariation(cachePed, 3,  LastClothes.arms,     0,                  2)
            SetPedComponentVariation(cachePed, 4,  LastClothes.pants_1, LastClothes.pants_2, 2)
            SetPedComponentVariation(cachePed, 6,  LastClothes.shoes_1, LastClothes.shoes_2, 2)

            if LastClothes.helmet_1 and LastClothes.helmet_1 ~= -1 then
                SetPedPropIndex(cachePed, 0, LastClothes.helmet_1, LastClothes.helmet_2 or 0, true)
            else
                ClearPedProp(cachePed, 0)
            end

            LastClothes = nil
            ESX.ShowNotification('Przebrano się w strój cywilny, zakończono pracę!')

            if Control.Car.have then
                local vehicles = ESX.Game.GetVehiclesInArea(cacheCoords, 20.0)
                for _, veh in pairs(vehicles) do
                    local vehNetId = NetworkGetNetworkIdFromEntity(veh)
                    if vehNetId == Control.Car.netid then
                        DeleteEntity(veh)
                        break
                    end
                end
            end

            Control = {
                isWorking = false,
                Car = {
                    have = false,
                    netid = nil,
                }
            }

            ToggleWeazelNewsPhotos(false)
            ToggleWeazelNewsProcesses(false)
        end
    end

    ToggleBlips(work)
    ClearPedTasks(cachePed)
end

local function sellProcessedPhotos()
    local count = ox_inventory:Search('count', 'processed_photo')
    if count and count < economy.sell.minAmount then
        ESX.ShowNotification('Musisz posiadać przy sobie minimum ' .. economy.sell.minAmount .. ' sztuk obrobionych zdjęć!')
        return
    end

    local animDict = "oddjobs@taxi@"
    local animName = "idle_a"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    FreezeEntityPosition(cachePed, true)

    TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)

    if esx_hud:progressBar({
        duration = 7,
        label = "Sprzedajesz obrobione zdjęcia...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
    }) then
        ClearPedTasks(cachePed)
        Wait(500)
        TriggerServerEvent('esx_jobs/weazelnews/sellProcessedPhotos')
        ESX.ShowNotification('Sprzedaż zakończona!')
    else
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano sprzedaż.')
    end

    FreezeEntityPosition(cachePed, false)
end

local function openSociety()
    TriggerServerEvent('esx_society:openbosshub', 'legal', false, true, nil)
end

local function openSellMenu()
    lib.callback("esx_jobs/weazelnews/getMarketPrice", false, function(price)
        local sellmenuOptions = {
            {
                title = "Sprzedaj obrobione zdjęcia",
                description = "Aktualna cena rynkowa wynosi: " ..price.. "$",
                icon = 'fa-solid fa-dollar-sign',
                onSelect = function()
                    if not Control.isWorking then
                        ESX.ShowNotification('Nie jesteś w pracy, pierw się przebierz!')
                        return
                    end
                    sellProcessedPhotos()
                end
            },
        }

        lib.registerContext({
            id = "openSellmenu",
            title = "Szatnia",
            options = sellmenuOptions
        })

        lib.showContext('openSellmenu')
    end)
end

local function CleanPlayer()
    ClearPedBloodDamage(cachePed)
    ResetPedVisibleDamage(cachePed)
    ClearPedLastWeaponDamage(cachePed)
    ResetPedMovementClipset(cachePed, 0)
end

local function openCloakroom()
    local cloakroomOptions = {}

    if not Control.isWorking then
        cloakroomOptions[#cloakroomOptions+1] = {
            title = "Rozpocznij pracę",
            description = "Przebierz się w strój roboczy i zacznij pracę",
            icon = 'fa-solid fa-boxes-packing',
            onSelect = function()
                if Control.isWorking then
                    ESX.ShowNotification('Już wcześniej rozpocząłeś pracę!')
                    return
                end
                CleanPlayer()
                LoadClothes(true)
            end
        }
    end

    if Control.isWorking then
        if Control.Car.have then
            cloakroomOptions[#cloakroomOptions+1] = {
                title = "Zakończ pracę (z karą)",
                description = "Zakończ pracę bez oddania pojazdu. Zostanie nałożona kara: " .. economy.vehiclePenalty.amount .. "$",
                icon = 'fa-solid fa-exclamation-triangle',
                onSelect = function()
                    if not Control.isWorking then
                        ESX.ShowNotification('Nie rozpocząłeś wcześniej pracy!')
                        return
                    end

                    lib.registerContext({
                        id = "confirmEndWorkPenalty",
                        title = "Potwierdź zakończenie pracy",
                        options = {
                            {
                                title = "Tak, zakończ pracę",
                                description = "Zostanie nałożona kara: " .. economy.vehiclePenalty.amount .. "$",
                                icon = 'fa-solid fa-check',
                                onSelect = function()
                                    TriggerServerEvent('esx_jobs/weazelnews/endWorkWithPenalty')
                                    CleanPlayer()
                                    LoadClothes(false)
                                end
                            },
                            {
                                title = "Anuluj",
                                description = "Wróć do menu",
                                icon = 'fa-solid fa-times',
                                onSelect = function()
                                    openCloakroom()
                                end
                            }
                        }
                    })
                    lib.showContext('confirmEndWorkPenalty')
                end
            }
        else
            cloakroomOptions[#cloakroomOptions+1] = {
                title = "Zakończ pracę",
                description = "Przebierz się w strój cywilny i zakończ pracę",
                icon = 'fa-solid fa-boxes-packing',
                onSelect = function()
                    if not Control.isWorking then
                        ESX.ShowNotification('Nie rozpocząłeś wcześniej pracy!')
                        return
                    end
                    CleanPlayer()
                    LoadClothes(false)
                end
            }
        end
    end

    cloakroomOptions[#cloakroomOptions+1] = {
        title = "Prywatna Szatnia",
        description = "Przebierz się w prywatny strój",
        icon = 'fa-solid fa-warehouse',
        onSelect = function ()
            CleanPlayer()
            exports.qf_skinmenu:openWardrobe()
        end
    }

    lib.registerContext({
        id = "openCloakroom",
        title = "Szatnia",
        options = cloakroomOptions
    })

    lib.showContext('openCloakroom')
end

local function openBossmenu()
    if Config.Basics['weazelnews'].job.required then
        if Config.Basics['weazelnews'].job.name == ESX.PlayerData.job.name and ESX.PlayerData.job.grade >= Config.Basics['weazelnews'].job.bossGrade then
            openSociety()
        else
            ESX.ShowNotification('Nie posiadasz do tego dostępu', 'error')
        end
    end
end

local function openGarage(takeCar)
    if not Control.isWorking then
        ESX.ShowNotification('Musisz pierw rozpocząć pracę!')
        return
    end

    if takeCar then
        local spawnCoords = Config.Coords['weazelnews'].vehicles.spawn
        local spawnPoint = ESX.Game.IsSpawnPointClear(vec3(spawnCoords.x, spawnCoords.y, spawnCoords.z), 5)

        if spawnPoint then
            ESX.Game.SpawnVehicle(Config.Coords['weazelnews'].vehicles.model, {
                x = spawnCoords.x,
                y = spawnCoords.y,
                z = spawnCoords.z
            }, spawnCoords.w, function(veh)
                Control.Car.have = true
                Control.Car.netid = NetworkGetNetworkIdFromEntity(veh)

                SetVehicleDirtLevel(veh, 0)
                Entity(veh).state.fuel = 100
                TaskWarpPedIntoVehicle(cachePed, veh, -1)
                SetVehicleColours(veh, 111, 0)
                SetVehicleLivery(veh, 1)

                Wait(500)
                ToggleWeazelNewsPhotos(true)
                ToggleWeazelNewsProcesses(true)
            end)
        else
            ESX.ShowNotification('Miejsce wyjęcia pojazdu jest zajęte przez inny pojazd!')
        end
    else
        if Control.Car.have then
            local vehicles = ESX.Game.GetVehiclesInArea(cacheCoords, 20.0)
            local found = false

            for _, veh in pairs(vehicles) do
                local vehNetId = NetworkGetNetworkIdFromEntity(veh)
                if vehNetId == Control.Car.netid then
                    DeleteEntity(veh)
                    found = true
                    break
                end
            end

            if found then
                Control.Car.have = false
                Control.Car.netid = nil
                ToggleWeazelNewsPhotos(false)
                ToggleWeazelNewsProcesses(false)
                ESX.ShowNotification('Pojazd został schowany, aby zakończyć pracę idź się przebrać.')
            else
                ESX.ShowNotification('Twój pojazd jest za daleko!')
            end
        else
            ESX.ShowNotification('Nie masz wyciągniętego pojazdu.')
        end
    end
end

local function onEnter(point)
    if not point.entity then
        local model = lib.requestModel(`a_m_m_paparazzi_01`)

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
                canInteract = function()
                    if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cacheVehicle then
                        return false
                    end
                    if Config.Basics['weazelnews'].job.required then
                        if Config.Basics['weazelnews'].job.name ~= ESX.PlayerData.job.name then
                            return false
                        end
                    end
                    return true
                end,
                onSelect = function()
                    if point.isCloakroom then
                        openCloakroom()
                    elseif point.isSell then
                        openSellMenu()
                    elseif point.isGarage then
                        if Control.Car.have then
                            openGarage(false)
                        else
                            openGarage(true)
                        end
                    elseif point.isBoss then
                        openBossmenu()
                    end
                end,
                distance = 2.0
            }
        })

        point.entity = entity
    end
end

local function onExit(point)
    local entity = point.entity

    if not entity then
        return
    end

    ox_target:removeLocalEntity(entity, point.label)

    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
    end

    point.entity = nil
end

CreateThread(function()
    for i = 1, #Config.Blips['weazelnews'] do
        local blip = AddBlipForCoord(Config.Blips['weazelnews'][i].Pos)

        SetBlipSprite(blip, Config.Blips['weazelnews'][i].Sprite)
        SetBlipDisplay(blip, Config.Blips['weazelnews'][i].Display)
        SetBlipScale(blip, Config.Blips['weazelnews'][i].Scale)
        SetBlipColour(blip, Config.Blips['weazelnews'][i].Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blips['weazelnews'][i].Label)
        EndTextCommandSetBlipName(blip)
    end

    for k, v in pairs(Config.Peds['weazelnews']) do
        lib.points.new({
            id = v.id,
            distance = v.distance,
            coords = v.coords,
            heading = v.heading,
            label = v.label,
            isCloakroom = v.isCloakroom or false,
            isGarage = v.isGarage or false,
            isSell = v.isSell or false,
            isBoss = v.isBoss or false,
            onEnter = onEnter,
            onExit = onExit,
        })
    end
end)