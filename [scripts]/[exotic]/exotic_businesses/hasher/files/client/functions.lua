local ox_target = exports.ox_target
local ox_inventory = exports.ox_inventory
local esx_hud = exports.esx_hud

IsInWorkClothes = false
local CompanyVehicleNetId = nil
local privateSkin = {
    components = nil,
    props = nil
}
local WorkBlips = {}

local function MissionText(text, clear)
    if clear or not text or text == "" then
        WorkTips.missionText = nil
        return
    end
    WorkTips.missionText = tostring(text):sub(1, 240)
end

local function SetWorkWaypoint(coords)
    if not coords or not coords.x or not coords.y then return end
    
    local waypointKey = ("%.2f_%.2f"):format(coords.x, coords.y)
    if WorkTips.currentWaypoint == waypointKey then return end
    
    SetNewWaypoint(coords.x, coords.y)
    WorkTips.currentWaypoint = waypointKey
end

function Init()
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end

    CurrentJob = ESX.GetPlayerData().job
    LoadJob(CurrentJob)
    InitCompanies()

    Wait(1000)

    PriceLists = ESX.AwaitServerCallback("exotic_businesses:loadPriceLists")

    CreateThread(function()
        while true do
            local sleep = 1000

            if CurrentJob and IsInWorkClothes then
                local businessConfig = Config.Businesses[CurrentJob.name]
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local nearImportantPoint = false
                
                if not WorkTips.vehicleTaken and not WorkTips.productsDelivered and businessConfig.car and businessConfig.car.npc then
                    local npcCoords = businessConfig.car.npc.coords
                    local dist = #(coords - npcCoords.xyz)
                    if dist < 10.0 then
                        sleep = 0
                        nearImportantPoint = true
                        MissionText("Porozmawiaj z NPC, aby wyciągnąć pojazd firmowy i rozpocząć pracę")
                    end
                end
                
                if WorkTips.vehicleTaken and not WorkTips.packageInVehicle and businessConfig.collectProducts then
                    local dist = #(coords - businessConfig.collectProducts.coords)
                    if dist < 10.0 then
                        sleep = 0
                        nearImportantPoint = true
                        MissionText(WorkTips.hasPackage and "Schowaj paczkę do pojazdu firmowego" or "Porozmawiaj z NPC aby odebrać towar")
                    end
                end
                
                if WorkTips.packageInVehicle and not WorkTips.productsDelivered and businessConfig.deliverProducts then
                    local dist = #(coords - businessConfig.deliverProducts.coords)
                    if dist < 10.0 then
                        sleep = 0
                        nearImportantPoint = true
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        if CompanyVehicleNetId then
                            local companyVehicle = NetworkGetEntityFromNetworkId(CompanyVehicleNetId)
                            if companyVehicle ~= 0 and DoesEntityExist(companyVehicle) then
                                local vehicleCoords = GetEntityCoords(companyVehicle)
                                local vehicleDist = #(coords - vehicleCoords)
                                if vehicleDist < 10.0 then
                                    MissionText(WorkTips.hasPackage and "Użyj interakcji aby dostarczyć produkty do firmy" or "Wyjmij paczkę z pojazdu firmowego, a następnie dostarcz produkty")
                                else
                                    MissionText("Udaj się do pojazdu firmowego i wyjmij paczkę")
                                end
                            else
                                MissionText("Udaj się do pojazdu firmowego i wyjmij paczkę")
                            end
                        else
                            MissionText("Udaj się do pojazdu firmowego i wyjmij paczkę")
                        end
                    end
                end
                
                if WorkTips.hasPackage and not WorkTips.productsDelivered and businessConfig.deliverProducts then
                    local dist = #(coords - businessConfig.deliverProducts.coords)
                    if dist < 10.0 then
                        sleep = 0
                        nearImportantPoint = true
                        local vehicle = GetVehiclePedIsIn(ped, false)
                        MissionText(vehicle ~= 0 and "Odstaw pojazd firmowy, a następnie dostarcz produkty" or "Użyj interakcji aby dostarczyć produkty do firmy")
                    end
                end
                
                if not nearImportantPoint then
                    if WorkTips.productsDelivered then
                        if businessConfig.cooking then
                            MissionText("Produkty zostały dostarczone! Możesz teraz udać się do kuchni i rozpocząć gotowanie potraw")
                            SetWorkWaypoint(businessConfig.cooking.coords)
                        else
                            MissionText("Produkty zostały dostarczone!")
                        end
                    elseif not WorkTips.vehicleTaken then
                        MissionText("Udaj się do NPC przy pojazdach i wyciągnij pojazd firmowy, następnie jedź do punktu Zbierz Produkty")
                        if businessConfig.car and businessConfig.car.npc then
                            SetWorkWaypoint(businessConfig.car.npc.coords)
                        end
                    elseif not WorkTips.packageInVehicle and not WorkTips.productsDelivered then
                        MissionText(WorkTips.hasPackage and "Schowaj paczkę do pojazdu firmowego" or "Jedź do punktu Zbierz Produkty i odebierz towar od NPC")
                        if businessConfig.collectProducts then
                            SetWorkWaypoint(businessConfig.collectProducts.coords)
                        end
                    elseif WorkTips.packageInVehicle then
                        if CompanyVehicleNetId then
                            local companyVehicle = NetworkGetEntityFromNetworkId(CompanyVehicleNetId)
                            if companyVehicle ~= 0 and DoesEntityExist(companyVehicle) then
                                local vehicleCoords = GetEntityCoords(companyVehicle)
                                MissionText("Wyjmij paczkę z pojazdu firmowego")
                                SetWorkWaypoint(vehicleCoords.x, vehicleCoords.y)
                            else
                                MissionText("Udaj się do punktu Dostarcz Produkty")
                                if businessConfig.deliverProducts then
                                    SetWorkWaypoint(businessConfig.deliverProducts.coords)
                                end
                            end
                        else
                            MissionText("Udaj się do punktu Dostarcz Produkty")
                            if businessConfig.deliverProducts then
                                SetWorkWaypoint(businessConfig.deliverProducts.coords)
                            end
                        end
                    elseif WorkTips.hasPackage then
                        MissionText("Udaj się do punktu Dostarcz Produkty")
                        if businessConfig.deliverProducts then
                            SetWorkWaypoint(businessConfig.deliverProducts.coords)
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end)

    CreateThread(function()
        while true do
            local coords = GetEntityCoords(PlayerPed)
            local waitTime = 5000

            for _, jobPriceLists in pairs(PriceLists) do
                for _, priceList in ipairs(jobPriceLists) do
                    local priceListCoords = vec3(priceList.coords.x, priceList.coords.y, priceList.coords.z)
                    if #(priceListCoords - coords) < 10.0 then
                        waitTime = 0
                        Draw3DText(priceList.coords.x, priceList.coords.y, priceList.coords.z, 1.0, priceList.text)
                    end
                end
            end

            Wait(waitTime)
        end
    end)
end

function InitCompanies()
    for jobName, businessData in pairs(Config.Businesses) do
        local blip = AddBlipForCoord(businessData.blip.coords.x, businessData.blip.coords.y, businessData.blip.coords.z)

        SetBlipSprite(blip, businessData.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, businessData.blip.scale)
        SetBlipColour(blip, businessData.blip.color)
        SetBlipPriority(blip, 999)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Config.BlipPrefix ..
            businessData.label)
        EndTextCommandSetBlipName(blip)

        local carData = businessData.car
        local npcCoords = carData.npc.coords
        local model = lib.requestModel(carData.npc.model)


        local entity = CreatePed(0, model, npcCoords.x, npcCoords.y, npcCoords.z, npcCoords.w, false, true)

        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)

        ox_target:addLocalEntity({ entity }, {
            {
                label = "Odbierz pojazd",
                icon = "fa-solid fa-car",
                distance = 2.0,
                onSelect = function()
                    if not IsInWorkClothes then
                        return ESX.ShowNotification("Musisz być w stroju roboczym, aby wyciągnąć pojazd firmowy.")
                    end

                    local canSpawn = ESX.AwaitServerCallback("exotic_businesses:canSpawnCompanyVehicle", jobName)
                    if not canSpawn then
                        return ESX.ShowNotification("Masz już wyciągnięty pojazd firmowy. Schowaj go, aby wyciągnąć kolejny.")
                    end
                    
                    local isClear = ESX.Game.IsSpawnPointClear(carData.spawnPoint, 3.0)

                    if not isClear then
                        return ESX.ShowNotification("Miejsce parkingowe jest zajęte.")
                    end

                    ESX.Game.SpawnVehicle(carData.model, carData.spawnPoint.xyz, carData.spawnPoint.w, function(veh)
                        if veh == 0 or not DoesEntityExist(veh) then
                            return ESX.ShowNotification("Nie udało się zespawnować pojazdu.")
                        end
                        CompanyVehicleNetId = NetworkGetNetworkIdFromEntity(veh)
                        TriggerServerEvent("exotic_businesses:registerCompanyVehicle", CompanyVehicleNetId, jobName)
                        
                        SetupVehicleTarget(veh, jobName)
                        
                        WorkTips.vehicleTaken = true
                        ShowWorkTip("collect")
                        ESX.ShowNotification("Pojazd został wyciągnięty. Udaj się do punktu zbierania produktów.")
                    end)
                end,
                canInteract = function()
                    return jobName == CurrentJob.name and IsInWorkClothes
                end
            }
        })

        ox_target:addBoxZone({
            name = "exotic_businesses:tray_public_" .. jobName,
            coords = businessData.tray.coords,
            size = businessData.tray.size,
            rotation = businessData.tray.rotation,
            debug = Config.Debug,
            distance = 3.5,
            options = {
                {
                    label = "Postaw jedzenie",
                    icon = "fa-solid fa-burger",
                    onSelect = function()
                        if CurrentJob and CurrentJob.name == jobName then
                            PlaceFoodOnTray()
                        end
                    end,
                    canInteract = function()
                        return CurrentJob and CurrentJob.name == jobName and CurrentJob.grade >= (businessData.tray.minGrade or 0)
                    end
                },
                {
                    label = "Wystaw rachunek",
                    icon = "fa-solid fa-cash-register",
                    onSelect = function()
                        if CurrentJob and CurrentJob.name == jobName then
                            IssueAnInvoice()
                        end
                    end,
                    canInteract = function()
                        return CurrentJob and CurrentJob.name == jobName and CurrentJob.grade >= (businessData.tray.minGrade or 0)
                    end
                },
                {
                    label = "Opłać rachunek",
                    icon = "fa-solid fa-money-bill",
                    onSelect = function()
                        TakeTheBill(jobName)
                    end,
                },
            }
        })
    end
end

function LoadJob(job, lastJob)
        if lastJob and Config.Businesses[lastJob.name] then
            local lastBusinessConfig = Config.Businesses[lastJob.name]
            if lastBusinessConfig.deliverProducts and exports.interactions then
                exports.interactions:removeInteraction(lastBusinessConfig.deliverProducts.coords)
            end
            
            for _, v in ipairs(Targets) do
                ox_target:removeZone(v)
            end
            Targets = {}
            CurrentJob = nil
            IsInWorkClothes = false
            CompanyVehicleNetId = nil
            privateSkin = { components = nil, props = nil }
            RemoveWorkBlips()
            ResetWorkTips()
        end

    if not job then return end

    local businessData = Config.Businesses[job.name]
    if not businessData then return end

    local personalStashId = ox_target:addBoxZone({
        name = "exotic_businesses:personalStash",
        coords = businessData.personalStash.coords,
        size = businessData.personalStash.size,
        rotation = businessData.personalStash.rotation,
        debug = Config.Debug,
        distance = 3.5,
        options = {
            label = "Prywatna szafka",
            icon = "fa-solid fa-box",
            onSelect = function()
                local pinCode = GetResourceKvpInt(job.name .. "_personal_stash_pin")

                if pinCode == 0 then
                    SetPersonalStashPinCode()
                    return
                end

                OpenPersonalStash(pinCode)
            end,
            canInteract = function()
                return job.name == CurrentJob.name and job.grade >= (businessData.wardrobe.personalStash or 0)
            end
        }
    })

    local globalStashId = ox_target:addBoxZone({
        name = "exotic_businesses:globalStash",
        coords = businessData.globalStash.coords,
        size = businessData.globalStash.size,
        rotation = businessData.globalStash.rotation,
        debug = Config.Debug,
        distance = 3.5,
        options = {
            label = "Szafka firmowa",
            icon = "fa-solid fa-box",
            onSelect = function()
                TriggerServerEvent('exotic_businesses:openGlobalStash')
                ox_inventory:openInventory('stash', "global_business_" .. CurrentJob.name)
            end,
            canInteract = function()
                return job.name == CurrentJob.name and job.grade >= (businessData.wardrobe.globalStash or 0)
            end
        }
    })

    local wardrobeId = ox_target:addBoxZone({
        name = "exotic_businesses:wardrobe",
        coords = businessData.wardrobe.coords,
        size = businessData.wardrobe.size,
        rotation = businessData.wardrobe.rotation,
        debug = Config.Debug,
        distance = 3.5,
        options = {
            {
                label = "Garderoba",
                icon = "fa-solid fa-shirt",
                onSelect = function()
                    OpenWardrobe()
                end,
                canInteract = function()
                    return job.name == CurrentJob.name and job.grade >= (businessData.wardrobe.minGrade or 0)
                end
            }
        }
    })

    local cookingId = ox_target:addBoxZone({
        name = "exotic_businesses:cooking",
        coords = businessData.cooking.coords,
        size = businessData.cooking.size,
        rotation = businessData.cooking.rotation,
        debug = Config.Debug,
        distance = 3.5,
        options = {
            label = "Gotowanie",
            icon = "fa-solid fa-utensils",
            onSelect = function()
                OpenCookingMenu()
            end,
            canInteract = function()
                return job.name == CurrentJob.name and job.grade >= (businessData.cooking.minGrade or 0)
            end
        }
    })

    local dishesStashId = nil
    if businessData.dishesStash then
        dishesStashId = ox_target:addBoxZone({
            name = "exotic_businesses:dishesStash",
            coords = businessData.dishesStash.coords,
            size = businessData.dishesStash.size,
            rotation = businessData.dishesStash.rotation,
            debug = Config.Debug,
            distance = 3.5,
            options = {
                label = "Szafka z gotowymi daniami",
                icon = "fa-solid fa-box",
                onSelect = function()
                    TriggerServerEvent('exotic_businesses:openDishesStash')
                    ox_inventory:openInventory('stash', "business_" .. CurrentJob.name .. "_dishes")
                end,
                canInteract = function()
                    return job.name == CurrentJob.name and job.grade >= (businessData.cooking.minGrade or 0)
                end
            }
        })
    end


    local bossMenuId = ox_target:addBoxZone({
        name = "exotic_businesses:bossMenu",
        coords = businessData.bossMenu.coords,
        size = businessData.bossMenu.size,
        rotation = businessData.bossMenu.rotation,
        debug = Config.Debug,
        distance = 3.5,
        options = {
            label = "Boss Menu",
            icon = "fa-solid fa-laptop",
            onSelect = function()
                OpenBossMenu()
            end,
            canInteract = function()
                return job.name == CurrentJob.name and job.grade >= (businessData.bossMenu.minGrade or 0)
            end
        }
    })

    local collectProductsId = nil
    if businessData.collectProducts and businessData.collectProducts.npc then
        local npcData = businessData.collectProducts.npc
        local npcModel = lib.requestModel(npcData.model)
        local collectNPC = CreatePed(0, npcModel, npcData.coords.x, npcData.coords.y, npcData.coords.z, npcData.coords.w, false, true)
        SetModelAsNoLongerNeeded(npcModel)
        FreezeEntityPosition(collectNPC, true)
        SetEntityInvincible(collectNPC, true)
        SetBlockingOfNonTemporaryEvents(collectNPC, true)
        SetPedFleeAttributes(collectNPC, 0, false)
        SetPedCombatAttributes(collectNPC, 17, true)
        
        ox_target:addLocalEntity({ collectNPC }, {
            {
                label = "Odbierz towar",
                icon = "fa-solid fa-box",
                distance = 2.0,
                onSelect = function()
                    CollectProductsFromNPC()
                end,
                canInteract = function()
                    return job.name == CurrentJob.name and IsInWorkClothes and not WorkTips.hasPackage and not WorkTips.packageInVehicle
                end
            }
        })
    end

    local deliverProductsId = nil
    if businessData.deliverProducts then
        local deliverCoords = businessData.deliverProducts.coords
        
        if exports.interactions then
            exports.interactions:showInteraction(
                deliverCoords,
                "fa-solid fa-truck",
                "ALT",
                "Dostarcz Produkty",
                "Naciśnij ALT aby dostarczyć produkty"
            )
        end
        
        deliverProductsId = ox_target:addBoxZone({
            name = "exotic_businesses:deliverProducts",
            coords = deliverCoords,
            size = businessData.deliverProducts.size,
            rotation = businessData.deliverProducts.rotation,
            debug = Config.Debug,
            distance = 3.5,
            options = {
                label = "Dostarcz Produkty",
                icon = "fa-solid fa-truck",
                onSelect = function()
                    DeliverProducts()
                end,
                canInteract = function()
                    return job.name == CurrentJob.name and IsInWorkClothes
                end
            }
        })
    end

    table.insert(Targets, personalStashId)
    table.insert(Targets, globalStashId)
    table.insert(Targets, wardrobeId)
    table.insert(Targets, cookingId)
    table.insert(Targets, bossMenuId)
    if collectProductsId then table.insert(Targets, collectProductsId) end
    if dishesStashId then table.insert(Targets, dishesStashId) end
    if deliverProductsId then table.insert(Targets, deliverProductsId) end

    CurrentJob = job
end

function SetPersonalStashPinCode()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.personalStash.minGrade or 0) then return end

    local input = lib.inputDialog('Ustaw PIN do szafki', {
        { type = 'number', label = 'Nowy PIN', min = 1000, max = 9999, default = 1000, required = true },
    })

    if input and input[1] then
        SetResourceKvpInt(CurrentJob.name .. "_personal_stash_pin", input[1])
        ESX.ShowNotification(("PIN został ustawiony: %s"):format(input[1]))
    end
end

function OpenPersonalStash(targetPin)
    if not CurrentJob or targetPin == 0 then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.personalStash.minGrade or 0) then return end

    local input = lib.inputDialog('Wprowadź PIN do szafki', {
        { type = 'number', label = 'PIN', min = 1000, max = 9999, default = 1000, required = true },
    })

    if not input or input[1] ~= targetPin then
        return ESX.ShowNotification("Nieprawidłowy kod PIN.")
    end

    TriggerServerEvent('exotic_businesses:openPersonalStash')
    ox_inventory:openInventory('stash', "business_" .. CurrentJob.name)
end

local getSex = function()
    local appearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
    return appearance.model == 'mp_m_freemode_01' and 'male' or 'female'
end

local wearClothes = function(skin)
    if not IsInWorkClothes then
        local appearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
        privateSkin = { props = appearance.props, components = appearance.components }
    end
    
    if skin.components and skin.props then
        local fullAppearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
        fullAppearance.components = skin.components
        fullAppearance.props = skin.props
        exports['qf_skinmenu']:setPedAppearance(PlayerPedId(), fullAppearance)
    else
        exports['qf_skinmenu']:setPedAppearance(PlayerPedId(), skin)
    end
    
    IsInWorkClothes = true
    CreateWorkBlips()
    ResetWorkTips()
    Wait(500)
    ShowWorkTip("vehicle")
    ESX.ShowNotification("Przebrano się w strój roboczy. Blipy zostały dodane.")
end

local wearPrivateClothes = function()
    if privateSkin.components and privateSkin.props then
        local appearance = exports['qf_skinmenu']:getPedAppearance(PlayerPedId())
        appearance.components = privateSkin.components
        appearance.props = privateSkin.props
        exports['qf_skinmenu']:setPedAppearance(PlayerPedId(), appearance)
        IsInWorkClothes = false
        RemoveWorkBlips()
        ResetWorkTips()
        ESX.ShowNotification("Przebrano się w strój cywilny.")
    else
        ESX.ShowNotification("Nie masz zapisanego stroju cywilnego.")
    end
end

local getWorkUniform = function()
    local sex = getSex()
    local uniform = {}
    
    if sex == 'male' then
        uniform = {
            components = {
                [1] = {drawable = 0, texture = 0},
                [2] = {drawable = 0, texture = 0},
                [3] = {drawable = 15, texture = 0},
                [4] = {drawable = 10, texture = 0},
                [5] = {drawable = 0, texture = 0},
                [6] = {drawable = 36, texture = 0},
                [7] = {drawable = 0, texture = 0},
                [8] = {drawable = 15, texture = 0},
                [9] = {drawable = 0, texture = 0},
                [10] = {drawable = 0, texture = 0},
                [11] = {drawable = 0, texture = 0},
            },
            props = {
                [0] = {drawable = -1, texture = 0},
                [1] = {drawable = -1, texture = 0},
                [2] = {drawable = -1, texture = 0},
                [6] = {drawable = -1, texture = 0},
                [7] = {drawable = -1, texture = 0},
            }
        }
    else
        uniform = {
            components = {
                [1] = {drawable = 0, texture = 0},
                [2] = {drawable = 0, texture = 0},
                [3] = {drawable = 14, texture = 0},
                [4] = {drawable = 6, texture = 0},
                [5] = {drawable = 0, texture = 0},
                [6] = {drawable = 0, texture = 0},
                [7] = {drawable = 0, texture = 0},
                [8] = {drawable = 15, texture = 0},
                [9] = {drawable = 0, texture = 0},
                [10] = {drawable = 0, texture = 0},
                [11] = {drawable = 0, texture = 0},
            },
            props = {
                [0] = {drawable = -1, texture = 0},
                [1] = {drawable = -1, texture = 0},
                [2] = {drawable = -1, texture = 0},
                [6] = {drawable = -1, texture = 0},
                [7] = {drawable = -1, texture = 0},
            }
        }
    end
    
    return uniform
end

local addCompanyOutfit = function(sex)
    local input = lib.inputDialog('Dodaj Strój Firmowy', {
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
    TriggerServerEvent('exotic_businesses:addCompanyOutfit', input[1], skin, sex)
end

local fetchCompanyOutfits = function(sex)
    local clothesData = ESX.AwaitServerCallback("exotic_businesses:getCompanyOutfits", CurrentJob.name, sex)
    local clothes = {}
    if clothesData then
        for _, outfit in ipairs(clothesData) do
            table.insert(clothes, {
                title = outfit.name,
                onSelect = function()
                    local skin = json.decode(outfit.skin)
                    wearClothes(skin)
                end
            })
        end
    end
    return clothes
end

local fetchCompanyOutfitsDelete = function(sex)
    local clothesData = ESX.AwaitServerCallback("exotic_businesses:getCompanyOutfits", CurrentJob.name, sex)
    local clothes = {}
    if clothesData then
        for _, outfit in ipairs(clothesData) do
            table.insert(clothes, {
                title = outfit.name,
                onSelect = function()
                    TriggerServerEvent('exotic_businesses:deleteCompanyOutfit', outfit.id)
                    Wait(500)
                    OpenWardrobe()
                end
            })
        end
    end
    return clothes
end

function OpenWardrobe()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.wardrobe.minGrade or 0) then return end

    local options = {}
    local sex = getSex()
    local companyOutfits = fetchCompanyOutfits(sex)
    
    local addClothesGrade = businessConfig.wardrobe.addClothesGrade or businessConfig.bossMenu.minGrade or 5
    if CurrentJob.grade >= addClothesGrade then
        table.insert(options, {
            title = 'Dodaj Strój Firmowy',
            description = 'Zapisz obecny strój jako strój firmowy',
                onSelect = function() 
                addCompanyOutfit(sex)
                Wait(500)
                OpenWardrobe()
            end
        })
        
        if #companyOutfits > 0 then
            table.insert(options, {
                title = 'Usuń Strój Firmowy',
                description = 'Usuń jeden z dostępnych strojów firmowych',
                onSelect = function()
                    OpenDeleteOutfitMenu()
                end
            })
        end
    end
    
    for _, outfit in ipairs(companyOutfits) do 
        table.insert(options, outfit) 
    end
    
    table.insert(options, {
        title = "Strój Prywatny",
        description = "Przebierz się w swój prywatny strój",
        onSelect = function()
            wearPrivateClothes()
        end
    })
    
    table.insert(options, {
        title = "Prywatna Garderoba",
        description = "Otwórz prywatną garderobę z zapisanymi strojami",
        onSelect = function()
            exports.qf_skinmenu:openWardrobe()
            SetTimeout(2000, function()
                if not IsInWorkClothes then
                    IsInWorkClothes = true
                    CreateWorkBlips()
                    ESX.ShowNotification("Przebrano się w strój roboczy. Blipy zostały dodane.")
                end
            end)
        end
    })
    
    lib.registerContext({
        id = 'business_wardrobe',
        title = 'Garderoba Firmowa',
        options = options
    })
    
    lib.showContext('business_wardrobe')
end

function OpenDeleteOutfitMenu()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    local addClothesGrade = businessConfig.wardrobe.addClothesGrade or businessConfig.bossMenu.minGrade or 5
    if CurrentJob.grade < addClothesGrade then return end

    local options = {}
    local sex = getSex()
    local companyOutfits = fetchCompanyOutfitsDelete(sex)

    for _, outfit in ipairs(companyOutfits) do 
        table.insert(options, outfit) 
    end

    lib.registerContext({
        id = 'business_wardrobe_delete',
        title = 'Usuń Strój Firmowy',
        options = options
    })

    lib.showContext('business_wardrobe_delete')
end

function SocietyMenu()
    TriggerServerEvent('esx_society:openbosshub', 'legal', false, true, nil)
end

function OpenBossMenu()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.bossMenu.minGrade or 0) then return end

    lib.hideContext()

    CreateThread(function()
        Wait(100)
        
        lib.registerContext({
            id = "bossmenu_main",
            title = "Boss Menu",
            canClose = true,
            options = {
                { 
                    title = "Menu zarządzania", 
                    onSelect = function()
                        lib.hideContext()
                        CreateThread(function()
                            Wait(100)
                            SocietyMenu()
                        end)
                    end
                },
                { 
                    title = "Menu ulepszeń", 
                    onSelect = function()
                        OpenUpgradesMenu()
                    end
                }
            }
        })

        lib.showContext("bossmenu_main")
    end)
end

function OpenUpgradesMenu()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.bossMenu.minGrade or 0) then return end

    lib.hideContext()

    local upgradesLevels = ESX.AwaitServerCallback("exotic_businesses:getUpgradesLevels")
    local upgradePrices = ESX.AwaitServerCallback("exotic_businesses:getUpgradePrices")
    local options = {}

    for upgradeName, upgradeData in pairs(Config.Upgrades) do
        local level = upgradesLevels[upgradeName] or 0
        local price = upgradePrices[upgradeName] or 0
        local isMaxLevel = level >= upgradeData.maxLevel
        
        local description = ""
        if upgradeName == "personalStash" then
            local currentWeight = upgradeData.defaultWeight + (upgradeData.increaseWeight * level)
            local nextWeight = isMaxLevel and currentWeight or (upgradeData.defaultWeight + (upgradeData.increaseWeight * (level + 1)))
            description = ("Obecnie: %dkg | Następny poziom: %dkg"):format(currentWeight / 1000, nextWeight / 1000)
        elseif upgradeName == "globalStash" then
            local currentWeight = upgradeData.defaultWeight + (upgradeData.increaseWeight * level)
            local nextWeight = isMaxLevel and currentWeight or (upgradeData.defaultWeight + (upgradeData.increaseWeight * (level + 1)))
            description = ("Obecnie: %dkg | Następny poziom: %dkg"):format(currentWeight / 1000, nextWeight / 1000)
        elseif upgradeName == "employeeLimit" then
            local currentLimit = upgradeData.defaultLimit + (upgradeData.increaseLimit * level)
            local nextLimit = isMaxLevel and currentLimit or (upgradeData.defaultLimit + (upgradeData.increaseLimit * (level + 1)))
            description = ("Obecnie: %d pracowników | Następny poziom: %d pracowników"):format(currentLimit, nextLimit)
        end
        
        table.insert(options, {
            title = ("%s | LVL: %d/%d"):format(upgradeData.label, level, upgradeData.maxLevel),
            description = isMaxLevel and "Maksymalny poziom" or (description .. (" | Koszt: $%s"):format(price)),
            disabled = isMaxLevel,
            onSelect = function()
                if not isMaxLevel then
                    OpenUpgradeMenu(upgradeName, level, price)
                end
            end
        })
    end

    CreateThread(function()
        Wait(100)
        
        lib.registerContext({
            id = "bossmenu_upgrades",
            title = "Boss Menu | Ulepszenia",
            canClose = true,
            onBack = function()
                lib.hideContext()
                CreateThread(function()
                    Wait(100)
                    OpenBossMenu()
                end)
            end,
            onExit = function()
                lib.hideContext()
                CreateThread(function()
                    Wait(100)
                    OpenBossMenu()
                end)
            end,
            options = options
        })

        lib.showContext("bossmenu_upgrades")
    end)
end

function OpenUpgradeMenu(upgradeName, upgradeLevel, price)
    local upgradeData = Config.Upgrades[upgradeName]

    lib.registerContext({
        id = "bossmenu_upgrade_" .. upgradeName,
        title = ("%s | LVL: %d/%d"):format(upgradeData.label, upgradeLevel, upgradeData.maxLevel),
        canClose = true,
        onBack = function()
            lib.hideContext()
            CreateThread(function()
                Wait(100)
                OpenUpgradesMenu()
            end)
        end,
        onExit = function()
            lib.hideContext()
            CreateThread(function()
                Wait(100)
                OpenUpgradesMenu()
            end)
        end,
        options = {
            {
                title = ("Ulepsz | Koszt: $%s"):format(price),
                description = "Potwierdź zakup ulepszenia",
                onSelect = function()
                    TriggerServerEvent("exotic_businesses:upgrade", upgradeName)
                    Wait(500)
                    OpenUpgradesMenu()
                end
            }
        }
    })
    lib.showContext("bossmenu_upgrade_" .. upgradeName)
end

function OpenOrderingIngredientsMenu()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.orderingIngredients.minGrade or 0) then return end

    lib.registerContext({
        id = "ordering_ingredients",
        title = "Zamawianie składników | Typ dostwy",
        canClose = true,
        options = {
            {
                title = "Dostawa automatyczna | Droższa o 25%",
                onSelect = function()
                    lib.hideContext()
                    OrderIngredients("fast")
                end
            },
            {
                title = "Dostawa własna",
                onSelect = function()
                    lib.hideContext()
                    OrderIngredients("normal")
                end
            }
        }
    })
    lib.showContext("ordering_ingredients")
end

function OrderIngredients(deliveryType)
    local businessConfig = Config.Businesses[CurrentJob.name]
    local ingredients = {}

    for _, ingredientName in pairs(businessConfig.orderingIngredients.ingredients) do
        ingredients[ingredientName] = 0
    end

    lib.registerContext({
        id = "order_ingredients",
        title = "Zamawianie składników | Wybór przedmiotów",
        canClose = true,
        options = {
            {
                title = "Wszystkie składniki",
                onSelect = function()
                    local input = lib.inputDialog('Zamawianie składników', {
                        { type = 'number', label = 'Ilość składników', description = 'Ile sztuk każdego składniku chcesz dostać', min = 1, max = 100, required = true },
                    })

                    if input and input[1] then
                        for k in pairs(ingredients) do
                            ingredients[k] = input[1]
                        end
                        TriggerServerEvent("exotic_businesses:orderIngredients", deliveryType, ingredients)
                        lib.hideContext()
                    end
                end
            },
            {
                title = "Konkretne składniki",
                onSelect = function()
                    local items = {}
                    local ingredientKeys = {}

                    for k in pairs(ingredients) do
                        table.insert(items, { type = "slider", label = ox_inventory:Items(k).label, default = 0, min = 0, max = 100, step = 1 })
                        table.insert(ingredientKeys, k)
                    end

                    local input = lib.inputDialog('Zamawianie składników', items)

                    if input then
                        for i, v in pairs(input) do
                            ingredients[ingredientKeys[i]] = v
                        end
                        TriggerServerEvent("exotic_businesses:orderIngredients", deliveryType, ingredients)
                        lib.hideContext()
                    end
                end
            }
        }
    })
    lib.showContext("order_ingredients")
end

function OpenCookingMenu()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.cooking.minGrade or 0) then return end

    local courseProgress = ESX.AwaitServerCallback("exotic_businesses:getCourseProgress")
    
    local options = {
        {
            title = "Szafka z gotowymi daniami",
            onSelect = function()
                TriggerServerEvent('exotic_businesses:openDishesStash')
                ox_inventory:openInventory('stash', "business_" .. CurrentJob.name .. "_dishes")
            end
        }
    }

    if courseProgress then
        table.insert(options, {
            title = ("Postęp kursu: %d/5 produktów"):format(courseProgress.productsMade),
            description = "Wytwórz 5 produktów, aby ukończyć kurs",
            disabled = true
        })
    end

    for dishName, dishData in pairs(businessConfig.cooking.dishes) do
        local dishesCount = ESX.AwaitServerCallback("exotic_businesses:getDishesStashCount", dishName)
        
        local description = nil
        if courseProgress then
            description = ("Postęp: %d/5"):format(courseProgress.productsMade)
            if dishesCount and dishesCount > 0 then
                description = description .. ("\nW magazynie: %d"):format(dishesCount)
            end
        end
        
        table.insert(options, {
            title = dishData.label,
            icon = dishData.icon,
            description = description,
            onSelect = function()
                ESX.TriggerServerCallback("exotic_businesses:cook", function(success)
                    if not success then return end

                    local successProgressbar = esx_hud:progressBar({
                        duration = 30,
                        label = 'Gotowanie...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true,
                            mouse = false,
                        },
                        anim = {
                            dict = "amb@prop_human_bbq@male@base",
                            clip = "base",
                        },
                        prop = {},
                    })

                    if successProgressbar then
                        TriggerServerEvent("exotic_businesses:successCook")
                        OpenCookingMenu()
                    end
                end, dishName)
            end
        })
    end

    lib.registerContext({
        id = "cooking_" .. GetGameTimer(),
        title = "Gotowanie",
        canClose = true,
        options = options
    })
    lib.showContext("cooking_" .. GetGameTimer())
end

function PlaceFoodOnTray()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.tray.minGrade or 0) then return end

    TriggerServerEvent('exotic_businesses:openTray')
    ox_inventory:openInventory('stash', "business_" .. CurrentJob.name .. "_tray")
end

function IssueAnInvoice()
    if not CurrentJob then return end

    local businessConfig = Config.Businesses[CurrentJob.name]
    if CurrentJob.grade < (businessConfig.tray.minGrade or 0) then return end

    local input = lib.inputDialog('Wystawianie rachunku', {
        { type = 'number', label = 'Kwota', description = 'Kwota do zapłaty przez klienta', min = 1, max = 20000, icon = 'dollar', required = true },
        { type = 'input', label = 'Opis', description = 'Opis wyświetlony na rachunku' },
    })

    if input and input[1] and input[2] then
        TriggerServerEvent("exotic_businesses:issueAnInvoice", input[1], input[2])
    end
end

function TakeTheBill(jobName)
    ESX.TriggerServerCallback("exotic_businesses:showTheBill", function(billData)
        if not billData then return end

        lib.registerContext({
            id = "bill",
            title = "Rachunek",
            canClose = true,
            options = {
                {
                    title = ('Kwota: %s'):format(billData.price),
                    disabled = true
                },
                {
                    title = ('Opis: %s'):format(billData.description ~= "" and billData.description or "Brak"),
                    disabled = true
                },
                {
                    title = 'Zapłać kartą',
                    onSelect = function()
                        TriggerServerEvent("exotic_businesses:takeTheBill", jobName, "bank")
                        lib.hideContext()
                    end
                },
                {
                    title = 'Zapłać gotówką',
                    onSelect = function()
                        TriggerServerEvent("exotic_businesses:takeTheBill", jobName, "money")
                        lib.hideContext()
                    end
                },
            }
        })
        lib.showContext("bill")
    end, jobName)
end

function UseItem(data)
    local percent = ESX.AwaitServerCallback("exotic_businesses:useItem", data.metadata.durability)

    for _, businessConfig in pairs(Config.Businesses) do
        local dishData = businessConfig.cooking and businessConfig.cooking.dishes[data.name]
        if dishData then
            TriggerEvent("esx_status:add", "hunger", dishData.hunger * percent)
            TriggerEvent("esx_status:add", "thirst", dishData.thirst * percent)
            break
        end
    end
end


function OpenPriceListMenu()
    if not CurrentJob then return end
    
    local businessConfig = Config.Businesses[CurrentJob.name]
    if not businessConfig then 
        return ESX.ShowNotification("Ta praca nie posiada systemu cenników.")
    end
    
    if CurrentJob.grade < (businessConfig.priceLists.minGrade or 0) then return end

    local coords = GetEntityCoords(PlayerPed)

    if #(businessConfig.blip.coords - coords) > 20.0 then
        return ESX.ShowNotification("Jesteś za daleko od restauracji.")
    end

    lib.registerContext({
        id = "price_list_menu",
        title = "Cennik",
        canClose = true,
        options = {
            { 
                title = "Stwórz nowy cennik", 
                onSelect = function()
                    CreateNewPriceList()
                end
            },
            { 
                title = "Lista cenników", 
                onSelect = function()
                    OpenPriceLists()
                end
            }
        }
    })

    lib.showContext("price_list_menu")
end

function CreateNewPriceList()
    if IsCreatingPriceList then return end

    local priceLists = ESX.AwaitServerCallback("exotic_businesses:getPriceLists")
    if #priceLists >= 2 then
        return ESX.ShowNotification("Firma ma już stworzone 2 cenniki.")
    end

    local input = lib.inputDialog('Stwórz cennik', {
        { type = 'textarea', label = 'Cennik', description = "Możesz korzystać z kolorów ~~", required = true, autosize = true },
    })

    if not input or not input[1] then return end

    IsCreatingPriceList = true
    PriceListText = input[1]

    while IsCreatingPriceList do
        local hit, entityHit, endCoords = lib.raycast.fromCamera(1, 0, 10.0)

        if hit then
            PriceListCoords = endCoords
            Draw3DText(endCoords.x, endCoords.y, endCoords.z, 1.0, PriceListText)
        end

        Wait(0)
    end
end

function PlacePriceList()
    if not IsCreatingPriceList then return end
    if not PriceListCoords then return ESX.ShowNotification("Cennik nie może zostać postawiony w tym miejscu.") end

    IsCreatingPriceList = false

    TriggerServerEvent("exotic_businesses:placePriceList", PriceListText, PriceListCoords)

    PriceListCoords = nil
    PriceListText = nil
end

function CancelPlacingPriceList()
    if not IsCreatingPriceList then return end

    IsCreatingPriceList = false

    ESX.ShowNotification("Anulowano stawianie cennika.")
end

function OpenPriceLists()
    local jobPriceLists = ESX.AwaitServerCallback("exotic_businesses:getPriceLists")
    local options = {}

    for _, priceList in ipairs(jobPriceLists) do
        table.insert(options, {
            title = string.sub(priceList.text, 1, 16) .. "...",
            onSelect = function()
                lib.hideContext()
                EditPriceList(priceList.text, priceList.coords)
            end
        })
    end

    lib.registerContext({
        id = "price_lists",
        title = "Cenniki",
        canClose = true,
        options = options
    })

    lib.showContext("price_lists")
end

function EditPriceList(text, coords)
    lib.registerContext({
        id = "edit_price_list",
        title = "Edytuj cennik",
        canClose = true,
        options = {
            {
                title = "Zmień tekst",
                onSelect = function()
                    local input = lib.inputDialog('Zmień tekst w cenniku', {
                        { type = 'textarea', label = 'Cennik', description = "Możesz korzystać z kolorów ~~", required = true, autosize = true },
                    })

                    if not input or not input[1] then return end

                    local newText = input[1]
                    TriggerServerEvent("exotic_businesses:updatePriceList", text, coords, newText)
                end
            },
            {
                title = "Usuń",
                onSelect = function()
                    TriggerServerEvent("exotic_businesses:deletePriceList", text, coords)
                    lib.hideContext()
                end
            }
        }
    })
    lib.showContext("edit_price_list")
end

function LoadPriceLists(jobName, priceLists)
    PriceLists[jobName] = priceLists
end

function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    
    local p = GetGameplayCamCoords()
    local distance = #(p - vec3(x, y, z))
    local scale = ((1 / distance) * 2) * ((1 / GetGameplayCamFov()) * 100) * scl_factor
    SetTextScale(0.0, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function CreateWorkBlips()
    if not CurrentJob then return end
    
    RemoveWorkBlips()
    
    local businessConfig = Config.Businesses[CurrentJob.name]
    if not businessConfig then return end
    
    if businessConfig.collectProducts then
        local blip = AddBlipForCoord(businessConfig.collectProducts.coords.x, businessConfig.collectProducts.coords.y, businessConfig.collectProducts.coords.z)
        SetBlipSprite(blip, 478)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("! Zbierz Produkty")
        EndTextCommandSetBlipName(blip)
        WorkBlips["collect"] = blip
    end
    
    if businessConfig.deliverProducts then
        local blip = AddBlipForCoord(businessConfig.deliverProducts.coords.x, businessConfig.deliverProducts.coords.y, businessConfig.deliverProducts.coords.z)
        SetBlipSprite(blip, 478)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("! Dostarcz Produkty")
        EndTextCommandSetBlipName(blip)
        WorkBlips["deliver"] = blip
    end
end

function RemoveWorkBlips()
    for _, blip in pairs(WorkBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    WorkBlips = {}
    ResetWorkTips()
end

function ResetWorkTips()
    WorkTips.vehicleTaken = false
    WorkTips.productsCollected = false
    WorkTips.productsDelivered = false
    WorkTips.hasPackage = false
    WorkTips.packageInVehicle = false
    WorkTips.currentWaypoint = nil
    RemovePackageFromPlayer()
    MissionText("", true)
    DeleteWaypoint()
end

function ShowWorkTip(tipType)
    if not CurrentJob or not IsInWorkClothes then return end
    
    local businessConfig = Config.Businesses[CurrentJob.name]
    if not businessConfig then return end
    
    if tipType == "vehicle" and not WorkTips.vehicleTaken then
        MissionText("Udaj się do NPC przy pojazdach i wyciągnij pojazd firmowy, następnie jedź do punktu Zbierz Produkty")
        if businessConfig.car and businessConfig.car.npc then
            SetWorkWaypoint(businessConfig.car.npc.coords)
        end
    elseif tipType == "collect" and WorkTips.vehicleTaken and not WorkTips.packageInVehicle and not WorkTips.productsDelivered and businessConfig.collectProducts then
        MissionText("Jedź do punktu Zbierz Produkty i odebierz towar od NPC")
        SetWorkWaypoint(businessConfig.collectProducts.coords)
    elseif tipType == "deliver" and WorkTips.packageInVehicle and not WorkTips.productsDelivered and businessConfig.deliverProducts then
        if WorkTips.hasPackage then
            MissionText("Teraz udaj się do punktu Dostarcz Produkty, aby dostarczyć zebrane produkty do firmy")
            SetWorkWaypoint(businessConfig.deliverProducts.coords)
        else
            MissionText("Wyjmij paczkę z pojazdu firmowego, a następnie dostarcz produkty")
            if CompanyVehicleNetId then
                local companyVehicle = NetworkGetEntityFromNetworkId(CompanyVehicleNetId)
                if companyVehicle ~= 0 and DoesEntityExist(companyVehicle) then
                    local vehicleCoords = GetEntityCoords(companyVehicle)
                    SetWorkWaypoint(vehicleCoords.x, vehicleCoords.y)
                else
                    SetWorkWaypoint(businessConfig.deliverProducts.coords)
                end
            else
                SetWorkWaypoint(businessConfig.deliverProducts.coords)
            end
        end
    elseif tipType == "cooking" and WorkTips.productsDelivered and businessConfig.cooking then
        MissionText("Produkty zostały dostarczone! Możesz teraz udać się do kuchni i rozpocząć gotowanie potraw")
        SetWorkWaypoint(businessConfig.cooking.coords)
    end
end

function CollectProductsFromNPC()
    if not CurrentJob or not IsInWorkClothes then return end
    if WorkTips.hasPackage or WorkTips.packageInVehicle then return end
    
    local successProgressbar = exports.esx_hud:progressBar({
        duration = 90,
        label = 'Odbieranie towaru...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "mp_common",
            clip = "givetake1_a",
        },
        prop = {},
    })
    
    if successProgressbar then
        TriggerServerEvent("exotic_businesses:collectProducts")
        GivePackageToPlayer()
        MissionText("Schowaj paczkę do pojazdu firmowego, a następnie udaj się do punktu dostarczania")
    end
end

function SetupVehicleTarget(vehicle, jobName)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    
    ox_target:addLocalEntity({ vehicle }, {
        {
            label = "Schowaj paczkę do pojazdu",
            icon = "fa-solid fa-box",
            distance = 3.0,
            onSelect = function()
                PutPackageInVehicle(vehicle)
            end,
            canInteract = function()
                return CurrentJob and CurrentJob.name == jobName and IsInWorkClothes and WorkTips.hasPackage and not WorkTips.packageInVehicle
            end
        },
        {
            label = "Wyjmij paczkę z pojazdu",
            icon = "fa-solid fa-box",
            distance = 3.0,
            onSelect = function()
                TakePackageFromVehicle(vehicle)
            end,
            canInteract = function()
                return CurrentJob and CurrentJob.name == jobName and IsInWorkClothes and WorkTips.packageInVehicle and not WorkTips.hasPackage
            end
        }
    })
end

function GivePackageToPlayer()
    local ped = PlayerPedId()
    
    if PackageProp and DoesEntityExist(PackageProp) then
        DeleteObject(PackageProp)
        PackageProp = nil
    end
    
    local animDict = "anim@heists@box_carry@"
    lib.requestAnimDict(animDict)
    
    TaskPlayAnim(ped, animDict, "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    Wait(500)
    
    local model = lib.requestModel(`prop_cs_cardbox_01`)
    PackageProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
    SetModelAsNoLongerNeeded(model)
    
    AttachEntityToEntity(PackageProp, ped, GetPedBoneIndex(ped, 57005), 0.17, 0.10, -0.13, 145.0, 280.0, 180.0, true, true, false, true, 1, true)
    
    WorkTips.hasPackage = true
    
    CreateThread(function()
        while WorkTips.hasPackage do
            local currentPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(currentPed, false)
            
            if vehicle ~= 0 then
                StopAnimTask(currentPed, animDict, "idle", 1.0)
                break
            end
            
            if not IsEntityPlayingAnim(currentPed, animDict, "idle", 3) then
                TaskPlayAnim(currentPed, animDict, "idle", 8.0, -8.0, -1, 49, 0, false, false, false)
            end
            Wait(1000)
        end
    end)
end

function RemovePackageFromPlayer()
    local ped = PlayerPedId()
    
    if PackageProp and DoesEntityExist(PackageProp) then
        DeleteObject(PackageProp)
        PackageProp = nil
    end
    
    ClearPedTasksImmediately(ped)
    WorkTips.hasPackage = false
end

function PutPackageInVehicle(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if not WorkTips.hasPackage then return end
    
    local businessConfig = Config.Businesses[CurrentJob.name]
    if not businessConfig then return end
    
    local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= businessConfig.car.model then
        return ESX.ShowNotification("To nie jest pojazd firmowy.")
    end
    
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local dist = #(pedCoords - vehicleCoords)
    
    if dist > 5.0 then
        return ESX.ShowNotification("Jesteś za daleko od pojazdu.")
    end
    
    local successProgressbar = exports.esx_hud:progressBar({
        duration = 5,
        label = 'Chowanie paczki...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "anim@heists@box_carry@",
            clip = "idle",
        },
        prop = {},
    })
    
    if successProgressbar then
        StopAnimTask(PlayerPedId(), "anim@heists@box_carry@", "idle", 1.0)
        RemovePackageFromPlayer()
        WorkTips.packageInVehicle = true
        WorkTips.productsCollected = true
        WorkTips.currentWaypoint = nil
        TriggerServerEvent("exotic_businesses:collectProducts")
        ShowWorkTip("deliver")
    end
end

function TakePackageFromVehicle(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if not WorkTips.packageInVehicle then return end
    
    local businessConfig = Config.Businesses[CurrentJob.name]
    if not businessConfig then return end
    
    local vehicleModel = GetEntityModel(vehicle)
    if vehicleModel ~= businessConfig.car.model then
        return ESX.ShowNotification("To nie jest pojazd firmowy.")
    end
    
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehicleCoords = GetEntityCoords(vehicle)
    local dist = #(pedCoords - vehicleCoords)
    
    if dist > 5.0 then
        return ESX.ShowNotification("Jesteś za daleko od pojazdu.")
    end
    
    local vehiclePed = GetVehiclePedIsIn(ped, false)
    if vehiclePed ~= 0 and vehiclePed == vehicle then
        return ESX.ShowNotification("Musisz wysiąść z pojazdu, aby wyjąć paczkę.")
    end
    
    local successProgressbar = exports.esx_hud:progressBar({
        duration = 5,
        label = 'Wyjmowanie paczki...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "anim@heists@box_carry@",
            clip = "idle",
        },
        prop = {},
    })
    
    if successProgressbar then
        WorkTips.packageInVehicle = false
        GivePackageToPlayer()
        MissionText("Wyjmij paczkę i dostarcz ją do firmy")
    end
end

function DeliverProducts()
    if not CurrentJob or not IsInWorkClothes then return end
    
    local businessConfig = Config.Businesses[CurrentJob.name]
    if not businessConfig or not businessConfig.deliverProducts then return end
    
    local vehicle = GetVehiclePedIsIn(PlayerPed, false)
    if vehicle ~= 0 then
        return ESX.ShowNotification("Musisz odstawić pojazd firmowy przed dostarczeniem produktów.")
    end
    
    if not WorkTips.hasPackage then
        if WorkTips.packageInVehicle then
            return ESX.ShowNotification("Musisz najpierw wyjąć paczkę z pojazdu, aby dostarczyć produkty.")
        else
            return ESX.ShowNotification("Nie masz załadowanych produktów do dostarczenia.")
        end
    end
    
    local hasProducts, _ = ESX.AwaitServerCallback("exotic_businesses:checkProductsStatus")
    if not hasProducts then
        return ESX.ShowNotification("Nie masz załadowanych produktów do dostarczenia.")
    end
    
    if CompanyVehicleNetId then
        local vehicle = NetworkGetEntityFromNetworkId(CompanyVehicleNetId)
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            TriggerServerEvent("exotic_businesses:deleteCompanyVehicle")
            Wait(100)
            ESX.Game.DeleteVehicle(vehicle)
            CompanyVehicleNetId = nil
            WorkTips.vehicleTaken = false
        end
    end
    
    local successProgressbar = exports.esx_hud:progressBar({
        duration = 60,
        label = 'Dostarczanie produktów...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = "amb@world_human_clipboard@male@idle_a",
            clip = "idle_c",
        },
        prop = {},
    })
    
    if successProgressbar then
        TriggerServerEvent("exotic_businesses:deliverProducts")
        RemovePackageFromPlayer()
        WorkTips.packageInVehicle = false
        WorkTips.productsCollected = false
        WorkTips.productsDelivered = true
        WorkTips.currentWaypoint = nil
        WorkTips.vehicleTaken = false
        
        ShowWorkTip("cooking")
        -- Po dostarczeniu produktów, zresetuj flagę pojazdu aby gracz mógł wyjąć nowy pojazd
        Wait(1000)
        ShowWorkTip("vehicle")
    end
end

CreateThread(function()
    while true do
        if WorkTips.missionText and IsInWorkClothes then
            Wait(0)
            SetTextFont(4)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextCentre(true)
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(WorkTips.missionText)
            EndTextCommandDisplayText(0.5, 0.90)
        else
            Wait(2000)
        end
    end
end)