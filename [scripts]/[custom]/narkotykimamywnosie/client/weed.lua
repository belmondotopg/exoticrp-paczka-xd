local inSetup = false
local inZone = nil
local weedTargets = {}

Citizen.CreateThread(function()
    for i = 1, #Config.Weed.Zones, 1 do
        local weedZone = Config.Weed.Zones[i]
        local zone = lib.zones.box({
            coords = weedZone.coords,
            size = weedZone.size,
            rotation = weedZone.rotation,
            debug = weedZone.debug or false,
            onEnter = function()
                inZone = weedZone
            end,
            onExit = function()
                inZone = nil
            end
        })
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    Wait(3000)
    for id, data in pairs(GlobalState.weedPlants) do
        weedTargets[id] = exports['ox_target']:addSphereZone({
            coords = vector3(data.coords.x, data.coords.y, data.coords.z + 0.35),
            radius = 0.2,
            debug = false,
            options = {{
                name = 'Check_Plant_' .. id,
                label = 'Sprawdź stan',
                icon = 'fa-solid fa-cannabis',
                distance = 1.5,
                onSelect = function()
                    RequestAnimDict("mini@repair")
                    while not HasAnimDictLoaded("mini@repair") do
                        Wait(10)
                    end
                    TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
                    local nowData = GlobalState.weedPlants[id]
                   if exports.esx_hud:progressBar({
                    duration = 8,
                    label = 'Sprawdzasz stan...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    },
                }) then
                    ClearPedTasks(PlayerPedId())
                    ESX.ShowNotification(
                    ('Status rośliny: %s\nPoziom nawodnienia: %s\nPoziom nawozu: %s\nPoziom wyrośnięcia: %s'):format(
                        nowData.status, nowData.water .. '%', nowData.food .. '%', nowData.grow .. '%'))
                end
                end
            }, {
                name = 'Water_Plant_' .. id,
                label = 'Nawodnij',
                icon = 'fa-solid fa-droplet',
                distance = 1.5,
                onSelect = function()
                    if exports['ox_inventory']:Search('count', 'water_bottle') < 1 then
                        return ESX.ShowNotification('Potrzebujesz wody aby nawodnić rośline')
                    end
                    RequestAnimDict("mini@repair")
                    while not HasAnimDictLoaded("mini@repair") do
                        Wait(10)
                    end
                    TaskPlayAnim(PlayerPedId(), "fixing_a_player", "mini@repair", 8.0, -8.0, -1, 49, 0, false, false, false)
                    if exports.esx_hud:progressBar({
                        duration = 9,
                        label = 'Nawadnianie...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true
                        },
                        anim = {
                            scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                        }
                    }) then
                        TriggerServerEvent('drugs:weed:WaterSeed', id)
                        ClearPedTasks(PlayerPedId())
                    end
                end
            }, {
                name = 'Food_Plant_' .. id,
                label = 'Nawieź',
                icon = 'fa-solid fa-box-open',
                distance = 1.5,
                onSelect = function()
                    RequestAnimDict("mini@repair")
                    while not HasAnimDictLoaded("mini@repair") do
                        Wait(10)
                    end
                    TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
                    if exports.esx_hud:progressBar({
                        duration = 9,
                        label = 'Nawożenie...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true
                        },
                        anim = {
                            scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                        }
                    }) then
                        TriggerServerEvent('drugs:weed:FoodSeed', id)
                        ClearPedTasks(PlayerPedId())
                    end
                end,
                canInteract = function()
                    local nowData = GlobalState.weedPlants[id]
                    if nowData.status == 'Zwiędła' or nowData.grow >= 100 then
                        return false
                    end

                    return true
                end
            }, {
                name = 'Collect_Plant_' .. id,
                label = 'Zbierz',
                icon = 'fa-solid fa-cannabis',
                distance = 1.5,
                onSelect = function()
                    RequestAnimDict("mini@repair")
                    while not HasAnimDictLoaded("mini@repair") do
                        Wait(10)
                    end
                    TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
                    if exports.esx_hud:progressBar({
                        duration = 15,
                        label = 'Zbieranie...',
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true
                        },
                        anim = {
                            scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                        }
                    }) then
                        TriggerServerEvent('drugs:weed:CollectSeed', id)
                        ClearPedTasks(PlayerPedId())
                    end
                end,
                canInteract = function()
                    local nowData = GlobalState.weedPlants[id]
                    if nowData.grow >= 100 then
                        return true
                    end

                    return false
                end
            }}
        })
    end
end)

RegisterNetEvent('drugs:weed:SetupWeed')
AddEventHandler('drugs:weed:SetupWeed', function(data)
    if not inZone then
        return ESX.ShowNotification('Nie możesz tutaj zasadzić nasiona')
    end

    if exports['ox_inventory']:Search('count', 'mini_shovel') < 1 then
        return ESX.ShowNotification('Nie posiadasz wymaganych narzędzi')
    end

    if inZone.weeds and not inZone.weeds[data.itemName] then
        return ESX.ShowNotification('Nie możesz tutaj zasadzić tego nasiona')
    end

    if inSetup or exports['ox_inventory']:Search('count', data.itemName .. '_seed') < 1 then
        return
    end

    LocalPlayer.state.invBusy = true
    LocalPlayer.state.invHotkeys = false
    LocalPlayer.state.canUseWeapons = false
    inSetup = true
    Wait(1)
    RequestAnimDict("mini@repair")  
        while not HasAnimDictLoaded("mini@repair") do
            Wait(10)
        end
        TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
    if exports.esx_hud:progressBar({
        duration = 3,
        label = 'Sadzenie...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            scenario = 'WORLD_HUMAN_GARDENER_PLANT'
        }
    }) then
        -- print('udane sadzenie')
        ClearPedTasks(PlayerPedId())
        inSetup = false
            LocalPlayer.state.invBusy = false
            LocalPlayer.state.invHotkeys = true
            LocalPlayer.state.canUseWeapons = true
        if exports['ox_inventory']:Search('count', data.itemName .. '_seed') < 1 then
            -- print('brak nasiona po progressie')
            return
        end

        local plyOffset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 0.0)
        TriggerServerEvent('drugs:weed:PlantSeed', data, plyOffset)
    else
        inSetup = false
    end
end)

RegisterNetEvent('drugs:weed:NewPlant', function(plantData)
    -- print('Adding weed target for plant id ' .. plantData.id)
    weedTargets[plantData.id] = exports['ox_target']:addSphereZone({
        coords = vector3(plantData.coords.x, plantData.coords.y, plantData.coords.z + 0.35),
        radius = 0.2,
        debug = false,
        options = {{
            name = 'Check_Plant_' .. plantData.id,
            label = 'Sprawdź stan',
            icon = 'fa-solid fa-cannabis',
            distance = 1.5,
            onSelect = function()
                local nowData = GlobalState.weedPlants[plantData.id]
                    RequestAnimDict("mini@repair")
                    while not HasAnimDictLoaded("mini@repair") do
                        Wait(10)
                    end
                    TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
                if exports.esx_hud:progressBar({
                    duration = 8,
                    label = 'Sprawdzasz stan...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    },
                    anim = {
                        scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                    }
                }) then
                    ClearPedTasks(PlayerPedId())
                    ESX.ShowNotification(
                    ('Status rośliny: %s\nPoziom nawodnienia: %s\nPoziom nawozu: %s\nPoziom wyrośnięcia: %s'):format(
                        nowData.status, nowData.water .. '%', nowData.food .. '%', nowData.grow .. '%'))
                end
            end
        }, {
            name = 'Water_Plant_' .. plantData.id,
            label = 'Nawodnij',
            icon = 'fa-solid fa-droplet',
            distance = 1.5,
            onSelect = function()
                if exports['ox_inventory']:Search('count', 'water_bottle') < 1 then
                    return ESX.ShowNotification('Potrzebujesz wody aby nawodnić rośline')
                end
                RequestAnimDict("mini@repair")
                while not HasAnimDictLoaded("mini@repair") do
                    Wait(10)
                end
                TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)

                if exports.esx_hud:progressBar({
                    duration = 9,
                    label = 'Nawadnianie...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    },
                    anim = {
                        scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                    }
                }) then
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('drugs:weed:WaterSeed', plantData.id)
                end
            end,
            canInteract = function()
                local nowData = GlobalState.weedPlants[plantData.id]
                if nowData.status == 'Zwiędła' or nowData.grow >= 100 then
                    return false
                end

                return true
            end
        }, {
            name = 'Food_Plant_' .. plantData.id,
            label = 'Nawieź',
            icon = 'fa-solid fa-box-open',
            distance = 1.5,
            onSelect = function()
                if exports['ox_inventory']:Search('count', 'fertilizer') < 1 then
                    return ESX.ShowNotification('Potrzebujesz nawozu aby nawodnić rośline')
                end
                RequestAnimDict("mini@repair")  
                while not HasAnimDictLoaded("mini@repair") do
                    Wait(10)
                end
                TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
                if exports.esx_hud:progressBar({
                    duration = 9,
                    label = 'Nawożenie...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    },
                    anim = {
                        scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                    }
                }) then
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('drugs:weed:FoodSeed', plantData.id)
                end
            end,
            canInteract = function()
                local nowData = GlobalState.weedPlants[plantData.id]
                if nowData.status == 'Zwiędła' or nowData.grow >= 100 then
                    return false
                end

                return true
            end
        }, {
            name = 'Collect_Plant_' .. plantData.id,
            label = 'Zbierz',
            icon = 'fa-solid fa-cannabis',
            distance = 1.5,
            onSelect = function()
                if exports.esx_hud:progressBar({
                    duration = 15,
                    label = 'Zbieranie...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true
                    },
                    anim = {
                        scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                    }
                }) then
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('drugs:weed:CollectSeed', plantData.id)
                end
            end,
            canInteract = function()
                local nowData = GlobalState.weedPlants[plantData.id]
                if nowData.status == 'Zwiędła' then
                    return false
                end

                if nowData.grow >= 100 then
                    return true
                end

                return false
            end
        }}
    })
end)

RegisterNetEvent('drugs:weed:RemovePlant', function(plantId)
    exports['ox_target']:removeZone(weedTargets[plantId])
    weedTargets[plantId] = nil
end)


RegisterNetEvent('drugs:weed:GrindTop')
AddEventHandler('drugs:weed:GrindTop', function(data)
    if (exports['ox_inventory']:Search('count', 'grinder') or 0) < 1 then
        return ESX.ShowNotification('Potrzebujesz czegoś aby to zmielić')
    end

    if (exports['ox_inventory']:Search('count', data.itemName..'_top') or 0) < 1 then
        return ESX.ShowNotification('Nie masz ziół do zmielenia')
    end

    if exports.esx_hud:progressBar({
        duration = 6,
        label = 'Mielenie...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = "mp_common_heist",
            clip = "pick_door"
        }
    }) then
        TriggerServerEvent('drugs:weed:GrindTop', data)
    end
end)

RegisterNetEvent('drugs:weed:RollJoint', function(data)
    if exports['ox_inventory']:Search('count', 'ocb_paper') < 1 then
        return ESX.ShowNotification('Potrzebujesz w coś to zawinąć')
    end

    if exports.esx_hud:progressBar({
        duration = 7,
        label = 'Zwijanie...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = "mp_common_heist",
            clip = "pick_door"
        }
    }) then
        TriggerServerEvent('drugs:weed:RollJoint', data)
    end
end)
