local ox_inventory = exports.ox_inventory
local esx_hud = exports.esx_hud
local economy = Config.Economy['orangeharvest']

local function getOxTarget()
    local success, target = pcall(function()
        return exports.ox_target
    end)
    if success and target then
        return target
    end
end

local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

local function requestAnimDict(animDict)
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end
end

local function startOrangeProcess()
    local animDict = "missfam4"
    local animName = "base"
    
    requestAnimDict(animDict)
    FreezeEntityPosition(cachePed, true)

    local processing = true

    CreateThread(function()
        while processing do
            if not IsEntityPlayingAnim(cachePed, animDict, animName, 3) then
                TaskPlayAnim(cachePed, animDict, animName, 8.0, 8.0, -1, 1, 0, false, false, false)
            end
            Wait(0)
        end
    end)

    if esx_hud:progressBar({
        duration = 8,
        label = "Wymieniasz pomarańcze na sok...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {},
        prop = {
            model = `p_amb_clipboard_01`,
            pos = vec3(0.00, 0.00, 0.00),
            rot = vec3(0.0, 0.0, -1.5)
        },
    }) then
        processing = false
        ClearPedTasks(cachePed)
        TriggerServerEvent('esx_jobs/orangeharvest/produceJuice')
        ESX.ShowNotification('Wymieniłeś pomarańcze na sok!')
    else
        processing = false
        ClearPedTasks(cachePed)
        ESX.ShowNotification('Anulowano wymienianie pomarańczy.')
    end

    FreezeEntityPosition(cachePed, false)
end

local function onEnter(point)
    if not point.entity then
        local model = lib.requestModel(`s_m_y_waretech_01`)
        Wait(1000)

        local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 0.95, point.heading, false, true)
        TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)
        SetModelAsNoLongerNeeded(model)
        FreezeEntityPosition(entity, true)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)

        local canInteract = function()
            return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cacheVehicle)
        end

        local ox_target = getOxTarget()
        if not ox_target then
            print("^1[ERROR] ox_target nie jest dostępny!^0")
            return
        end
        
        ox_target:addLocalEntity(entity, {
            {
                icon = 'fa fa-laptop',
                label = point.label,
                canInteract = canInteract,
                onSelect = function()
                    local count = ox_inventory:Search('count', 'orange')
                    if count and count < economy.process.inputAmount then
                        ESX.ShowNotification('Potrzebujesz minimum ' .. economy.process.inputAmount .. ' sztuk pomarańczy aby zrobić sok pomarańczowy!')
                        return
                    end
                    startOrangeProcess()
                end,
                distance = 2.0
            },
            {
                icon = 'fa fa-laptop',
                label = "Sprzedaj Pomarańcze",
                canInteract = canInteract,
                onSelect = function()
                    local count = ox_inventory:Search('count', 'orange')
                    if count and count < economy.sell.inputAmount then
                        ESX.ShowNotification('Możesz sprzedawać po ' .. economy.sell.inputAmount .. ' pomarańczy!')
                        return
                    end

                    local animDict = "oddjobs@taxi@"
                    local animName = "idle_a"

                    requestAnimDict(animDict)
                    FreezeEntityPosition(cachePed, true)
                    TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)

                    if esx_hud:progressBar({
                        duration = 8,
                        label = "Sprzedajesz pomarańcze...",
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true,
                            mouse = false,
                        },
                    }) then
                        ClearPedTasks(cachePed)
                        TriggerServerEvent("vwk/orange/sell")
                    else
                        ClearPedTasks(cachePed)
                        ESX.ShowNotification('Przerwano sprzedawanie!')
                    end

                    FreezeEntityPosition(cachePed, false)
                end,
                distance = 2.0
            },
        })

        point.entity = entity
    end
end

local function onExit(point)
    local entity = point.entity
    if not entity then
        return
    end

    local ox_target = getOxTarget()
    if ox_target then
        ox_target:removeLocalEntity(entity, point.label)
    end

    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
    end

    point.entity = nil
end

CreateThread(function()
    for i = 1, #Config.Blips['orangeharvest'] do
        local blip = AddBlipForCoord(Config.Blips['orangeharvest'][i].Pos)
        SetBlipSprite(blip, Config.Blips['orangeharvest'][i].Sprite)
        SetBlipDisplay(blip, Config.Blips['orangeharvest'][i].Display)
        SetBlipScale(blip, Config.Blips['orangeharvest'][i].Scale)
        SetBlipColour(blip, Config.Blips['orangeharvest'][i].Colour)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blips['orangeharvest'][i].Label)
        EndTextCommandSetBlipName(blip)

        if i == 1 then
            local radiusBlip = AddBlipForRadius(Config.Blips['orangeharvest'][i].Pos, 35.0)
            SetBlipColour(radiusBlip, Config.Blips['orangeharvest'][i].Colour)
            SetBlipAlpha(radiusBlip, 100)
        end
    end

    for k, v in pairs(Config.Peds['orangeharvest']) do
        lib.points.new({
            id = v.id,
            distance = v.distance,
            coords = v.coords,
            heading = v.heading,
            label = v.label,
            onEnter = onEnter,
            onExit = onExit,
        })
    end
end)

local orangeTargets = {}
local treeCooldowns = {}
local treesConfig = {
    {
        name = "orangetree1",
        coords = vec3(2327.6, 4770.8, 36.35),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "orangetree2",
        coords = vec3(2325.5977, 4761.5962, 37.8892),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "orangetree3",
        coords = vec3(2324.4983, 4746.7754, 37.1349),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "oran5151getree1",
        coords = vec3(2339.3982, 4741.3169, 36.2205),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "orangetgggggggggggggggggggggree1",
        coords = vec3(2343.6995, 4755.6113, 36.0549),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "ora6161ngetree1",
        coords = vec3(2339.4541, 4767.3027, 36.200),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "orange51353151e1",
        coords = vec3(2353.6411, 4760.5776, 35.3329),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "orang156513",
        coords = vec3(2350.4324, 4734.1943, 36.0108),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
    {
        name = "orangetree75817651",
        coords = vec3(2359.0916, 4723.9478, 35.8498),
        size = vec3(1.1, 1.1, 4.0),
        rotation = 0.0,
    },
}

local treesByName = {}
for _, tree in ipairs(treesConfig) do
    treesByName[tree.name] = tree
end

local function RemoveTreeZone(treeName)
    local ox_target = getOxTarget()
    if ox_target and orangeTargets[treeName] then
        pcall(function()
            ox_target:removeZone(treeName)
        end)
        orangeTargets[treeName] = nil
    end
end

local function HarvestOrangeTree(orangeTree)
    local animDict = "missmechanic"
    local animName = "work_base"

    requestAnimDict(animDict)
    FreezeEntityPosition(cachePed, true)

    local harvestingTree = true

    CreateThread(function()
        while harvestingTree do
            if not IsEntityPlayingAnim(cachePed, animDict, animName, 3) then
                TaskPlayAnim(cachePed, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
            end
            Wait(0)
        end
    end)

    if esx_hud:progressBar({
        duration = 8,
        label = "Zbierasz pomarańcze...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {},
        prop = {
            model = `ng_proc_food_ornge1a`,
            pos = vec3(0.03, 0.03, 0.03),
            rot = vec3(0.0, 0.0, -1.5)
        },
    }) then
        harvestingTree = false
        ClearPedTasks(cachePed)
        TriggerServerEvent('esx_jobs/orangeharvest/getOrange', orangeTree.coords)
        treeCooldowns[orangeTree.name] = GetGameTimer() + (30 * 1000)
        RemoveTreeZone(orangeTree.name)
    else
        harvestingTree = false
        ClearPedTasks(cachePed)
    end

    FreezeEntityPosition(cachePed, false)
end

local function AddTreeZone(orangeTree)
    local ox_target = getOxTarget()
    if not ox_target then
        return false
    end

    if orangeTargets[orangeTree.name] then
        return true
    end

    local success, zone = pcall(function()
        return ox_target:addBoxZone({
            name = orangeTree.name,
            coords = orangeTree.coords,
            size = orangeTree.size,
            rotation = orangeTree.rotation,
            debug = false,
            options = {
                {
                    icon = "fa-solid fa-leaf",
                    label = "Zbierz pomarańcze",
                    distance = 2.0,
                    onSelect = function()
                        if treeCooldowns[orangeTree.name] and treeCooldowns[orangeTree.name] > GetGameTimer() then
                            local timeLeft = math.ceil((treeCooldowns[orangeTree.name] - GetGameTimer()) / 1000)
                            ESX.ShowNotification('To drzewo jest już zebrane! Poczekaj ' .. timeLeft .. ' sekund.')
                            return
                        end

                        local count = ox_inventory:Search('count', 'orange')
                        if count and count >= economy.orange.maxAmount then
                            ESX.ShowNotification('Masz już przy sobie maksymalną ilość pomarańczy!')
                            return
                        end
                        HarvestOrangeTree(orangeTree)
                    end
                }
            }
        })
    end)

    if success and zone then
        orangeTargets[orangeTree.name] = zone
        return true
    else
        print("^1[ERROR] Nie udało się dodać strefy dla drzewa: " .. orangeTree.name .. "^0")
        return false
    end
end

local function InitializeOrangeHarvest()
    local ox_target = getOxTarget()
    if not ox_target then
        print("^1[ERROR] ox_target nie jest dostępny podczas próby dodania stref!^0")
        return
    end

    for _, orangeTree in ipairs(treesConfig) do
        AddTreeZone(orangeTree)
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        local currentTime = GetGameTimer()
        for treeName, cooldownEndTime in pairs(treeCooldowns) do
            if currentTime >= cooldownEndTime then
                treeCooldowns[treeName] = nil
                local tree = treesByName[treeName]
                if tree then
                    AddTreeZone(tree)
                end
            end
        end
    end
end)

CreateThread(function()
    local attempts = 0
    local maxAttempts = 50
    
    while attempts < maxAttempts do
        local ox_target = getOxTarget()
        if ox_target then
            break
        end
        Wait(100)
        attempts = attempts + 1
    end
    
    if attempts >= maxAttempts then
        print("^1[ERROR] ox_target nie jest dostępny po " .. maxAttempts .. " próbach!^0")
        return
    end
    
    Wait(500)
    InitializeOrangeHarvest()
end)
