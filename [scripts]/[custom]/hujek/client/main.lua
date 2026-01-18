local client = {}
-- local baseRef = exports["fiveplay-base"]
local targetRef = exports["ox_target"]

client.missionActive = false
client.missionData = {}
client.oxCooldown = nil
client.blipHandle = nil
client.boatBlipHandle = nil
client.spawnedBoatHandle = nil
client.chestCount = nil

client.chestEntities = {}
client.chestOpened = { normal = 0, extra = 0 }
client.chestOpenedBlips = {}

client.scubaObjects = { mask = nil, tank = nil }
client.scubaIdentifier = nil
client.isScubaGearEquiped = false

client.setupScript = function()
    local model = joaat(Config.MissionPed.model)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local ped = CreatePed(
        4, -- typ peda (4 = male civilian)
        model,
        Config.MissionPed.coords.x,
        Config.MissionPed.coords.y,
        Config.MissionPed.coords.z,
        Config.MissionPed.coords.w,
        false, -- isNetwork
        true   -- thisScriptCheck
    )

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    targetRef:addBoxZone({
        coords = vec3(Config.MissionPed.coords.x, Config.MissionPed.coords.y, Config.MissionPed.coords.z + 0.95),
        debug = ESX.GetConfig().EnableDebug,
        size = vec3(0.5, 0.5, 2),
        options = {
            {
                label = "Porozmawiaj o misji",
                name = "fiveplay-treasure:talkAboutMission",
                icon = "",
                distance = 3,
                onSelect = client.takeMission
            },
            {
                label = "Zakończ misję",
                name = "fiveplay-treasure:cancelMission",
                icon = "",
                distance = 3,
                onSelect = function()
                    client.resetMissionData()
                    TriggerServerEvent("fiveplay-treasure/events/cancelMission")
                    ESX.ShowNotification("Anlulowałeś misję.", "warn")
                end,
                canInteract = function()
                    return client.missionActive
                end
            },
        }
    })
end

client.takeMission = function()
    if client.missionActive then
        return ESX.ShowNotification("Posiadasz już aktywną misję. Udaj się do obszaru zaznaczonego na mapie.")
    end

    if client.oxCooldown and client.oxCooldown > GetGameTimer() then
        return ESX.ShowNotification("Zwolnij! Nie możesz robić tego tak szybko.")
    end

    ESX.TriggerServerCallback("fiveplay-treasure/cb/takeMission", function(canTake, missionData)
        if canTake then
            client.missionActive = true
            client.missionData = missionData

            ESX.ShowNotification("Zaznaczyłem ci na mapię lokalizację, gdzie ekipa przywiezie ci łódkę. Udaj się tam jak najszybciej", "success")

            local coords = client.missionData.boatSpawnPoint
            client.boatBlipHandle = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(client.boatBlipHandle, 427)
            SetBlipColour(client.boatBlipHandle, 47)
            SetBlipScale(client.boatBlipHandle, 1.0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Miejsce odebrania łódki")
            EndTextCommandSetBlipName(client.boatBlipHandle)

            SetNewWaypoint(coords.x, coords.y)
            CreateThread(client.isNearBoat)

            SetTimeout(1000 * 60 * 30, function()
                if client.missionActive then
                    client.resetMissionData()
                    TriggerServerEvent("fiveplay-treasure/events/cancelMission")
                    ESX.ShowNotification("Nie zrobiłeś misji w ciągu wyznaczonych 30 minut. Misja została anulowana")
                end
            end)
        end
    end)
end

client.openTreasureChest = function(index, boxEntity, chestType)
   local esx_hud = exports.esx_hud

    local success = esx_hud:progressBar({
        duration = 5, -- sekundy
        label = 'Przeszukujesz skrzynię...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_ped',
            flag = 49
        },
        prop = {},
    })

    if success then
        if DoesEntityExist(boxEntity) then
            DeleteEntity(boxEntity)
            client.chestEntities[index] = nil
        end

        targetRef:removeLocalEntity(boxEntity)
        ESX.ShowNotification("Udało ci się otworzyć skrzynię!", "success")

        TriggerServerEvent("fiveplay-treasure/events/openChest", chestType)

        if chestType == "normal" then
            client.chestOpened.normal = client.chestOpened.normal + 1
        else
            client.chestOpened.extra = client.chestOpened.extra + 1
        end

        if client.chestOpened.normal + client.chestOpened.extra == client.chestCount.normal + client.chestCount.extra then
            client.resetMissionData()
            TriggerServerEvent("fiveplay-treasure/events/finishMission")
            return ESX.ShowNotification("Brawo! Udało ci się zebrać wszystkie skrzynie. W nagrodę otrzymujesz Złoty Klucz.", "success")
        end

        local coords = client.missionData.locations[index]
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 587)
        SetBlipColour(blip, 47)
        SetBlipScale(blip, 0.7)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Otwarta skrzynia")
        EndTextCommandSetBlipName(blip)

        client.chestOpenedBlips[index] = blip

        SendNUIMessage({
            action = "update",
            part = "chestCollected",
            value = {
                normalOpened = client.chestOpened.normal,
                normalTotal = client.chestCount.normal,
                extraOpened = client.chestOpened.extra,
                extraTotal = client.chestCount.extra
            }
        })
    else
        ESX.ShowNotification("Anulowano przeszukiwanie skrzyni.")
    end
end

client.resetMissionData = function()
    for index, chestEntity in pairs(client.chestEntities) do
        if DoesEntityExist(chestEntity) then
            targetRef:removeLocalEntity(chestEntity)
            DeleteEntity(chestEntity)
            client.chestEntities[index] = nil
        end
    end

    for __, blip in pairs(client.chestOpenedBlips) do
        RemoveBlip(blip)
    end

    if client.blipHandle then
        RemoveBlip(client.blipHandle)
    end

    client.chestOpened = { normal = 0, extra = 0 }
    client.chestCount = nil
    client.missionActive = false
    client.missionData = {}

    SendNUIMessage({
        action = "hide",
        part = "chestCollected",
    })
end

client.createTreasureChest = function(model, coords)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    local success, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    if success then
        coords = vec3(coords.x, coords.y, groundZ)
    end

    local chestEntity = CreateObject(model, coords.x, coords.y, coords.z, false, true, false)
    SetEntityHeading(chestEntity, coords.w)
    FreezeEntityPosition(chestEntity, true)

    return chestEntity
end

client.createMissionBlip = function(data)
    local radiusBlip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    SetBlipAlpha(radiusBlip, 128)
    SetBlipColour(radiusBlip, 2)

    client.blipHandle = radiusBlip
end

client.generateRandomBoxesData = function()
    client.chestCount = { normal = 0, extra = 0 }
    local boxesData = {}

    for i = 1, math.random(5, 10) do
        local totalChance = Config.Chests["normal"].chance + Config.Chests["weapon"].chance + Config.Chests["supplies"].chance + Config.Chests["extra"].chance
        local roll = math.random(0, totalChance)
        
        local boxType = nil
        if roll <= Config.Chests["normal"].chance then
            boxType = "normal"
            client.chestCount.normal = client.chestCount.normal + 1
        elseif roll <= Config.Chests["normal"].chance + Config.Chests["weapon"].chance then
            boxType = "weapon"
            client.chestCount.extra = client.chestCount.extra + 1
        elseif roll <= Config.Chests["normal"].chance + Config.Chests["weapon"].chance + Config.Chests["supplies"].chance then
            boxType = "supplies"
            client.chestCount.extra = client.chestCount.extra + 1
        else
            boxType = "extra"
            client.chestCount.extra = client.chestCount.extra + 1
        end

        local coords = client.missionData.locations[i]
        boxesData[#boxesData + 1] = { boxType = boxType, coords = coords }
    end
    return boxesData
end

client.useScubaGear = function()
    if client.isScubaGearEquiped then
        return ESX.ShowNotification("Masz już założoną butlę i maskę!", "warn")
    end

    RequestModel(Config.ScubaTankModel)
    while not HasModelLoaded(Config.ScubaTankModel) do
        Wait(100)
    end

    client.scubaObjects.tank = CreateObject(Config.ScubaTankModel, 1.0, 1.0, 1.0, 1, 1, 0)
    local tankBone = GetPedBoneIndex(cache.ped, 24818)
    AttachEntityToEntity(client.scubaObjects.tank, cache.ped, tankBone, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)

    RequestModel(Config.ScubaMaskModel)
    while not HasModelLoaded(Config.ScubaMaskModel) do
        Wait(100)
    end

    client.scubaObjects.mask = CreateObject(Config.ScubaMaskModel, 1.0, 1.0, 1.0, 1, 1, 0)
    local maskBone = GetPedBoneIndex(cache.ped, 12844)
    AttachEntityToEntity(client.scubaObjects.mask, cache.ped, maskBone, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)

    SetEnableScuba(cache.ped, true)
    SetPedMaxTimeUnderwater(cache.ped, 9999999.00)
    client.isScubaGearEquiped = true

    local randomScubaIdentifier = math.random(1, 999999)
    client.scubaIdentifier = randomScubaIdentifier

    ESX.ShowNotification("Założyłeś butlę i maskę. Na butli pisało, że tlenu starczy ci na 20 minut",  "success")
    SetTimeout(1000 * 60 * 19, function()
        if client.scubaIdentifier == randomScubaIdentifier then
            ESX.ShowNotification("Kończy ci się tlen w butli. Zostało go na 1 minutę.", "warn")
        end
    end)

    SetTimeout(1000 * 60 * 20, function()
        if client.scubaIdentifier == randomScubaIdentifier then
            ESX.ShowNotification("Skończył ci się tlen w butli!", "warn")
            SetEnableScuba(cache.ped, false)
            SetPedMaxTimeUnderwater(cache.ped, 1.00)

            for __, v in pairs(client.scubaObjects) do
                if DoesEntityExist(v) then
                    DetachEntity(v, 0, 1)
                    DeleteEntity(v)
                end
            end
        end
    end)
end

exports('useScubaGear', client.useScubaGear)

client.enterBoat = function(vehicle, seat)
    if vehicle == client.spawnedBoatHandle and client.missionActive then
        RemoveBlip(client.boatBlipHandle)
        client.createMissionBlip(client.missionData.radiusBlip)
        ESX.ShowNotification("Na mapie znaznaczyłem obszar w którym znajdziesz beczki oraz skrzynie z cennymi rzeczami. Zbierz je wszystkie a dostaniesz dalsze intrukcje.", "success")
        CreateThread(client.isInsideZone)
    end
end

client.isInsideZone = function()
    while true do
        if #(GetEntityCoords(cache.ped) - client.missionData.radiusBlip.coords) <= client.missionData.radiusBlip.radius then
            ESX.ShowNotification("Wkroczyłeś w strefę poszukiwań. Pamiętaj, że zostało ci niewiele czasu. Lepiej się pośpiesz.", "success")

            local randomBoxesData = client.generateRandomBoxesData()

            for i, boxData in pairs(randomBoxesData) do
                local model = Config.ChestModels[boxData.boxType]
                local coords = boxData.coords
                
                local boxEntity = client.createTreasureChest(model, boxData.coords)
                client.chestEntities[i] = boxEntity

                targetRef:addLocalEntity(boxEntity, {
                    {
                        label = "Otwórz skrzynię",
                        name = "fiveplay-treasure:openChest",
                        icon = "fa-solid fa-box-open",
                        onSelect = function()
                            client.openTreasureChest(i, boxEntity, boxData.boxType)
                        end,
                        distance = 4.0
                    }
                })
            end
            
            SendNUIMessage({
                action = "show",
                part = "chestCollected",
                value = {
                    normalOpened = client.chestOpened.normal,
                    normalTotal = client.chestCount.normal,
                    extraOpened = client.chestOpened.extra,
                    extraTotal = client.chestCount.extra
                }
            })

            break
        end

        Wait(2000)
    end
end

client.isNearBoat = function()
    local newCoords = vec3(client.missionData.boatSpawnPoint.x, client.missionData.boatSpawnPoint.y, client.missionData.boatSpawnPoint.z)
    while true do
        if #(GetEntityCoords(cache.ped) - newCoords) <= 120 then
            ESX.Game.SpawnVehicle(Config.SpawnBoatModel, vec3(client.missionData.boatSpawnPoint.x, client.missionData.boatSpawnPoint.y, client.missionData.boatSpawnPoint.z), client.missionData.boatSpawnPoint.w, function(veh)
                client.spawnedBoatHandle = veh
                ESX.ShowNotification("Twoja łódka jest już dostarczona na brzeg. Wsiądz do niej czym prędzej aby nie zabrały jej fale", "success")
            end, true)
            
            break
        end

        Wait(2000)
    end
end

RegisterCommand("zdejmijstrojnurka", function()
    if client.isScubaGearEquiped then
        client.scubaIdentifier = nil
        for __, v in pairs(client.scubaObjects) do
            if DoesEntityExist(v) then
                DetachEntity(v, 0, 1)
                DeleteEntity(v)
            end
        end
    end
end)

CreateThread(client.setupScript)
RegisterNetEvent("esx:enteredVehicle", client.enterBoat)
RegisterNetEvent("fiveplay-treasure/events/useScubaGear", client.useScubaGear)