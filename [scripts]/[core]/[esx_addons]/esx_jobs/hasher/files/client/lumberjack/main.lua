local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target
local esx_hud = exports.esx_hud
local economy = Config.Economy['lumberjack']

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
local lumberTargets = {}
local lumberBlips = {}
local cuttersTargets = {}
local cuttersBlips = {}

local function ToggleBlips(enable)
    local blipConfig = {
        {
            coords = vector3(-581.3472, 5335.7705, 70.2145),
            label = "Garaż",
            sprite = 641,
            color = 21,
            scale = 0.8
        },
        {
            coords = vector3(-552.5706, 5348.5244, 74.7431),
            label = "Skup zapakowanych desek",
            sprite = 642,
            color = 21,
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



local function ChopTree(tree)
    local animDict = "melee@hatchet@streamed_core"
    local animName = "plyr_rear_takedown_b"
    local axeModel = `w_me_hatchet`

    RequestModel(axeModel)
    while not HasModelLoaded(axeModel) do
        Wait(10)
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    local axe = CreateObject(axeModel, cacheCoords, true, true, false)
    AttachEntityToEntity(axe, cachePed, GetPedBoneIndex(cachePed, 57005), 0.10, 0.0, -0.02, -90.0, 0.0, 0.0, true, true, false, true, 1, true)

    FreezeEntityPosition(cachePed, true)

    local chopping = true

    CreateThread(function()
        while chopping do
            if not IsEntityPlayingAnim(cachePed, animDict, animName, 3) then
                TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
            end
            Wait(0)
        end
    end)

    if esx_hud:progressBar({
        duration = 14,
        label = "Zbieranie drewna...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {},
        prop = {},
    }) then
        chopping = false
        ClearPedTasks(cachePed)
        TriggerServerEvent('esx_jobs/lumberjack/treeChoped', tree.coords)

        ox_target:removeZone(tree.name)
        lumberTargets[tree.name] = nil

        if DoesBlipExist(lumberBlips[tree.name]) then
            RemoveBlip(lumberBlips[tree.name])
            lumberBlips[tree.name] = nil
        end
    else
        chopping = false
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano zbieranie drewna.')
    end

    if DoesEntityExist(axe) then
        DetachEntity(axe, true, true)
        DeleteEntity(axe)
    end

    FreezeEntityPosition(cachePed, false)
end

local function ToggleLumberjackTrees(enable)
    local treesConfig = {
        {
            name = "tree1",
            coords = vec3(-644.25, 5241.2, 75.0),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
        {
            name = "t6262ee1",
            coords = vec3(-625.7015, 5315.6455, 61.8686),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
        {
            name = "tr45515151ee1",
            coords = vec3(-689.8793, 5305.2290, 71.7277),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
        {
            name = "tre715775e1",
            coords = vec3(-676.8121, 5388.8262, 55.4906),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
        {
            name = "tr1678171ee1",
            coords = vec3(-638.0416, 5439.7129, 54.9590),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
        {
            name = "tr717ee1",
            coords = vec3(-595.1294, 5451.7295, 61.8147),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
        {
            name = "tree6126161",
            coords = vec3(-500.5115, 5401.2666, 77.6725),
            size = vec3(1.25, 1.35, 7.75),
            rotation = 0.0
        },
    }

    if enable then
        for i, tree in ipairs(treesConfig) do
            local blip = AddBlipForCoord(tree.coords)
            SetBlipSprite(blip, 655)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 21)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Drzewo do wycięcia")
            EndTextCommandSetBlipName(blip)
            lumberBlips[tree.name] = blip

            local zone = ox_target:addBoxZone({
                name = tree.name,
                coords = tree.coords,
                size = tree.size,
                rotation = tree.rotation,
                debug = false,
                options = {
                    {
                        icon = "fas fa-tree",
                        label = "Ścinaj drzewo",
                        distance = 2.0,
                        onSelect = function()
                            if not Control.Car.have then
                                ESX.ShowNotification('Musisz posiadać swój pojazd, aby zbierać drewno!')
                                return
                            end

                            ESX.ShowNotification('Rozpocząłeś zbieranie drewna.')
                            ChopTree(tree)
                        end
                    }
                }
            })

            lumberTargets[tree.name] = zone
        end
    else
        for k, _ in pairs(lumberTargets) do
            ox_target:removeZone(k)
        end
        lumberTargets = {}

        for k, blip in pairs(lumberBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        lumberBlips = {}
    end
end

local function StartCutter(coords)
    local animDict = "anim@amb@business@coc@coc_unpack_cut@"
    local animName = "fullcut_cycle_v3_cokecutter"

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    FreezeEntityPosition(cachePed, true)

    local cutting = true

    CreateThread(function()
        while cutting do
            if not IsEntityPlayingAnim(cachePed, animDict, animName, 3) then
                TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
            end
            Wait(0)
        end
    end)

    if esx_hud:progressBar({
        duration = 10,
        label = "Przerabiasz drewno na deski...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {},
        prop = {},
    }) then
        cutting = false
        ClearPedTasks(cachePed)
        TriggerServerEvent('esx_jobs/lumberjack/processWood', coords)
        FreezeEntityPosition(cachePed, false)
    else
        cutting = false
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano przerabianie drewna.')
        FreezeEntityPosition(cachePed, false)
    end
end

local function ToggleLumberjackCutters(enable)
    local cuttersConfig = {
        {
            name = "cutter1",
            coords = vec3(-804.6927, 5392.4419, 34.15),
            size = vec3(2.45, 1.35, 2.8),
            rotation = 0.0,
        },
        {
            name = "cutter2",
            coords = vec3(-797.2266, 5390.4761, 34.15),
            size = vec3(2.45, 1.35, 2.8),
            rotation = 0.0,
        },
        {
            name = "cutter3",
            coords = vec3(-801.0552, 5387.1938, 34.15),
            size = vec3(2.45, 1.35, 2.8),
            rotation = 0.0,
        },
        {
            name = "cutter4",
            coords = vec3(-808.4592, 5389.5933, 34.15),
            size = vec3(2.45, 1.35, 2.8),
            rotation = 0.0,
        },
    }

    if enable then
        for i, cutter in ipairs(cuttersConfig) do
            local blip = AddBlipForCoord(cutter.coords)
            SetBlipSprite(blip, 643)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 21)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Stół do obróbki drewna")
            EndTextCommandSetBlipName(blip)
            cuttersBlips[cutter.name] = blip

            local zone = ox_target:addBoxZone({
                name = cutter.name,
                coords = cutter.coords,
                size = cutter.size,
                rotation = cutter.rotation,
                debug = false,
                options = {
                    {
                        icon = "fa-solid fa-cubes",
                        label = "Obrób drzewo",
                        distance = 2.0,
                        onSelect = function()
                            local count = ox_inventory:Search('count', 'wood')
                            if count and count < economy.process.inputAmount then
                                ESX.ShowNotification('Musisz posiadać przy sobie minimum ' .. economy.process.inputAmount .. ' sztuk drewna!')
                                return
                            end

                            ESX.ShowNotification('Rozpocząłeś obrabianie drewna.')
                            StartCutter(cutter.coords)
                        end
                    }
                }
            })

            cuttersTargets[cutter.name] = zone
        end
    else
        for k, _ in pairs(cuttersTargets) do
            ox_target:removeZone(k)
        end
        cuttersTargets = {}

        for k, blip in pairs(cuttersBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        cuttersBlips = {}
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
    local uniform = isMale and Config.Uniforms['lumberjack'].male or Config.Uniforms['lumberjack'].female

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

            Control.isWorking = false
            Control.Car.have = false
            Control.Car.netid = nil

            ToggleLumberjackTrees(false)
            ToggleLumberjackCutters(false)
        end
    end

    ToggleBlips(work)
    ClearPedTasks(cachePed)
end

local function SellPlanks()
    local count = ox_inventory:Search('count', 'packaged_plank')
    if count and count < economy.sell.minAmount then
        ESX.ShowNotification('Musisz posiadać przy sobie minimum ' .. economy.sell.minAmount .. ' sztuk zapakowanych desek!')
        return
    end

    local animDict = "mp_am_hold_up"
    local animName = "purchase_beerbox_shopkeeper"
    local boxModel = `prop_cs_cardbox_01`

    RequestModel(boxModel)
    while not HasModelLoaded(boxModel) do
        Wait(10)
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    local box = CreateObject(boxModel, cacheCoords, true, true, false)
    AttachEntityToEntity(box, cachePed, GetPedBoneIndex(cachePed, 28422), 0.05, 0.0, -0.02, 0.0, 90.0, 0.0, true, true, false, true, 1, true)

    FreezeEntityPosition(cachePed, true)

    TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)

    if esx_hud:progressBar({
        duration = 7,
        label = "Sprzedajesz deski...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {},
        prop = {},
    }) then
        ClearPedTasks(cachePed)
        Wait(500)
        TriggerServerEvent('esx_jobs/lumberjack/sellPlanks')
        ESX.ShowNotification('Sprzedaż zakończona!')
        Wait(500)
        local count = ox_inventory:Search('count', 'packaged_plank')
        if count == 0 then
            wyjebAll()
        end
    else
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano sprzedaż.')
    end

    if DoesEntityExist(box) then
        DetachEntity(box, true, true)
        DeleteEntity(box)
    end

    FreezeEntityPosition(cachePed, false)
end

local function openSociety()
    TriggerServerEvent('esx_society:openbosshub', 'legal', false, true, nil)
end

local function openSellMenu()
    lib.callback("esx_jobs/lumberjack/getMarketPrice", false, function(price)
        local sellmenuOptions = {
            {
                title = "Sprzedaj zapakowane deski",
                description = "Aktualna cena rynkowa wynosi: " ..price.. "$",
                icon = 'fa-solid fa-dollar-sign',
                onSelect = function()
                    if not Control.isWorking then
                        ESX.ShowNotification('Nie jesteś w pracy, pierw się przebierz!')
                        return
                    end
                    SellPlanks()
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
                                    TriggerServerEvent('esx_jobs/lumberjack/endWorkWithPenalty')
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
        onSelect = function()
            CleanPlayer()
            exports.qf_skinmenu:openWardrobe()
        end
    }

    if Config.Basics['lumberjack'].job.required then
        if Config.Basics['lumberjack'].job.name == ESX.PlayerData.job.name and ESX.PlayerData.job.grade >= Config.Basics['lumberjack'].job.bossGrade then
            cloakroomOptions[#cloakroomOptions+1] = {
                title = "Zarządzanie",
                description = "Zarządzaj pracownikami",
                icon = 'fa-solid fa-tablet-screen-button',
                onSelect = function()
                    openSociety()
                end
            }
        end
    end

    lib.registerContext({
        id = "openCloakroom",
        title = "Szatnia",
        options = cloakroomOptions
    })

    lib.showContext('openCloakroom')
end

local function openGarage(takeCar)
    if not Control.isWorking then
        ESX.ShowNotification('Musisz pierw rozpocząć pracę!')
        return
    end

    if takeCar then
        local spawnCoords = Config.Coords['lumberjack'].vehicles.spawn
        local spawnPoint = ESX.Game.IsSpawnPointClear(vec3(spawnCoords.x, spawnCoords.y, spawnCoords.z), 5)

        if spawnPoint then
            ESX.Game.SpawnVehicle(Config.Coords['lumberjack'].vehicles.model, {
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

                ToggleLumberjackTrees(true)
                ToggleLumberjackCutters(true)
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
                ToggleLumberjackTrees(false)
                ToggleLumberjackCutters(false)
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
        local model = lib.requestModel(`s_m_m_dockwork_01`)

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
                    if Config.Basics['lumberjack'].job.required then
                        if Config.Basics['lumberjack'].job.name ~= ESX.PlayerData.job.name then
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
    for i = 1, #Config.Blips['lumberjack'] do
        local blip = AddBlipForCoord(Config.Blips['lumberjack'][i].Pos)

        SetBlipSprite(blip, Config.Blips['lumberjack'][i].Sprite)
        SetBlipDisplay(blip, Config.Blips['lumberjack'][i].Display)
        SetBlipScale(blip, Config.Blips['lumberjack'][i].Scale)
        SetBlipColour(blip, Config.Blips['lumberjack'][i].Colour)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blips['lumberjack'][i].Label)
        EndTextCommandSetBlipName(blip)
    end

    for k, v in pairs(Config.Peds['lumberjack']) do
        lib.points.new({
            id = v.id,
            distance = v.distance,
            coords = v.coords,
            heading = v.heading,
            label = v.label,
            isCloakroom = v.isCloakroom or false,
            isGarage = v.isGarage or false,
            isSell = v.isSell or false,
            onEnter = onEnter,
            onExit = onExit,
        })
    end
end)

function wyjebAll()
    ToggleLumberjackTrees(false)
    ToggleLumberjackCutters(false)
    ToggleBlips(false)
    lib.registerContext({
    id = 'jebanemenudrwala',
    title = 'Czy chcesz kolejny raz podjąć pracę?',
    options = {
        {
        title = 'Zacznij jeszcze raz!',
        onSelect = function()
            ToggleLumberjackTrees(true)
            ToggleLumberjackCutters(true)
            ToggleBlips(true)
            lib.hideContext()
        end,
        }, 
        {
            title = 'Zakończ pracę',
            onSelect = function()
                LoadClothes(false)

                lib.hideContext()
            end,
        }
    }})
    lib.showContext('jebanemenudrwala')
end