local isUIOpen = false
local isCrafting = false

-- RegisterCommand('craft', function()
--     OpenCraftingUI()
-- end, false)

-- RegisterKeyMapping('craft', 'Otwórz stół rzemieślniczy', 'keyboard', 'F6')

-- local CraftingTables = {
--     {x = 1090.0, y = -2002.0, z = 31.0, radius = 3.0},
-- }

-- Citizen.CreateThread(function()
--     while true do
--         Wait(0)
--         local playerPed = PlayerPedId()
--         local coords = GetEntityCoords(playerPed)
--         local canSleep = true
        
--         for _, table in pairs(CraftingTables) do
--             local distance = #(coords - vector3(table.x, table.y, table.z))
            
--             if distance < 10.0 then
--                 canSleep = false
--                 DrawMarker(27, table.x, table.y, table.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
--                     table.radius, table.radius, 1.0, 255, 128, 0, 100, false, true, 2, false, nil, nil, false)
                
--                 if distance < table.radius then
--                     ESX.ShowHelpNotification('Naciśnij ~INPUT_CONTEXT~ aby otworzyć stół rzemieślniczy')
                    
--                     if IsControlJustReleased(0, 38) then
--                         OpenCraftingUI()
--                     end
--                 end
--             end
--         end
        
--         if canSleep then
--             Wait(500)
--         end
--     end
-- end)

--^^ Potem mozna to przerobic pod ox_target i pod dany prop albo cos

local duringTable = false
Citizen.CreateThread(function()
    for _, coords in pairs(GlobalState.vwktable) do
        local model = `v_ret_ml_tablec`

        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end

        local tableObj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHeading(tableObj, coords.w)
        FreezeEntityPosition(tableObj, true)
        SetEntityInvincible(tableObj, true)
        exports.ox_target.addSphereZone(tableObj,{
            coords = vec3(coords.x,coords.y,coords.z),
            radius = 3,
            options = {
                {
                    name = "vwkCraftingTable"..math.random(1,99999),
                    label = "Przyjrzyj się stołu",
                    icon = "fa-solid fa-compass-drafting",
                    distance =2.5,
                    onSelect = function()
                        local ped = PlayerPedId()
                        local animDict = "anim@heists@prison_heistig1_p1_guard_checks_bus"
                        local animName = "loop"

                        RequestAnimDict(animDict)
                        while not HasAnimDictLoaded(animDict) do
                            Wait(10)
                        end

                        FreezeEntityPosition(ped, true)
                        duringTable = true
                        CreateThread(function()
                            while duringTable do
                                if not IsEntityPlayingAnim(ped, animDict, animName, 3) then
                                    TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
                                end
                                Wait(0)
                            end
                            ClearPedTasks(ped)
                        end)

                        if exports.esx_hud:progressBar({
                            duration = 5,
                            label = "Sprawdzanie stołu...",
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true,
                                combat = true,
                            },
                        }) then
                            OpenCraftingUI()
                            FreezeEntityPosition(ped, false)
                        else
                            duringTable = false
                            ESX.ShowNotification('Anulowano...')
                            FreezeEntityPosition(ped, false)
                        end
                    end
                }
            }
        })
    end
end)

function OpenCraftingUI()
    if isUIOpen or isCrafting then return end
    
    ESX.TriggerServerCallback('exoticrp_crafting:getData', function(data)
        if not data then 
            ESX.ShowNotification('Nie można otworzyć stołu rzemieślniczego!')
            return 
        end
        
        isUIOpen = true
        SetNuiFocus(true, true)
        
        SendNUIMessage({
            action = 'init',
            payload = {
                recipes = data.recipes
            }
        })
        
        Wait(100)
        
        local mugshot, txd = ESX.Game.GetPedMugshot(PlayerPedId())
        
        SendNUIMessage({
            action = 'changeDisplay',
            payload = {
                display = true,
                inventory = data.inventory,
                profile = data.profile,
                mugshot = txd or "none"
            }
        })
        
        SetTimeout(5000, function()
            if mugshot then
                UnregisterPedheadshot(mugshot)
            end
        end)
    end)
end

function CloseUI()
    if not isUIOpen then return end
    
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'changeDisplay',
        payload = {
            display = false
        }
    })
    duringTable = false
    if isCrafting then
        TriggerServerEvent('exoticrp_crafting:cancelCrafting')
        isCrafting = false
    end
end

RegisterNUICallback('close', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('craftItem', function(data, cb)
    if isCrafting then 
        ESX.ShowNotification('~r~Już wytwarzasz przedmiot!')
        cb('already_crafting')
        return 
    end
    
    if not data.itemName or type(data.itemName) ~= "string" then
        cb('invalid_data')
        return
    end
    
    TriggerServerEvent('exoticrp_crafting:craftItem', data.itemName)
    cb('ok')
end)

RegisterNetEvent('exoticrp_crafting:startCrafting')
AddEventHandler('exoticrp_crafting:startCrafting', function(duration)
    isCrafting = true
    SendNUIMessage({
        action = 'craftingStarted',
        payload = {
            duration = duration
        }
    })
    
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
    
    Citizen.SetTimeout(duration, function()
        ClearPedTasks(playerPed)
    end)
end)

RegisterNetEvent('exoticrp_crafting:craftingComplete')
AddEventHandler('exoticrp_crafting:craftingComplete', function(profileData)
    isCrafting = false
    
    SendNUIMessage({
        action = 'craftingComplete',
        payload = profileData
    })
    
    ESX.TriggerServerCallback('exoticrp_crafting:getData', function(data)
        if data then
            SendNUIMessage({
                action = 'updateInventory',
                payload = {
                    inventory = data.inventory
                }
            })
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if isUIOpen then
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then
                CloseUI()
            end
            
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 106, true)
        else
            Wait(1000)
        end
    end
end)

-- admin shit

local spawnedTables = {}
local carryingTable = false
local carriedTable = nil
local targets = {}

RegisterCommand("crafttable", function()
    if not ESX.GetPlayerData().group == "admin" and not ESX.GetPlayerData().group == "superadmin" then
        ESX.ShowNotification("~r~Nie masz uprawnień!")
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TriggerServerEvent("adminCraftingTable:spawn", coords, heading)
    ESX.ShowNotification("~g~Postawiłeś stół rzemieślniczy (admin)!")
end, false)

RegisterNetEvent("adminCraftingTable:spawnOne", function(coords, heading, netId)
    spawnCraftingTable(coords, heading, netId)
end)

RegisterNetEvent("adminCraftingTable:removeOne", function(netId)
    if spawnedTables[netId] and DoesEntityExist(spawnedTables[netId]) then
        DeleteEntity(spawnedTables[netId])
        spawnedTables[netId] = nil
    end
end)

function spawnCraftingTable(coords, heading, netId)
    local model = `v_ret_ml_tablec`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local obj = CreateObject(model, coords.x, coords.y, coords.z - 0.98, true, true, false)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(obj), false)

    if netId then
        spawnedTables[netId] = obj
    else
        spawnedTables[NetworkGetNetworkIdFromEntity(obj)] = obj
    end
    targets[netId] = exports.ox_target.addSphereZone(tableObj,{
        coords = vec3(coords.x,coords.y,coords.z),
        radius = 3,
        options = {
        {
            name = "crafting_use",
            label = "Przyjrzyj się stołu",
            icon = "fa-solid fa-compass-drafting",
            distance = 2.5,
            onSelect = function()
                local ped = PlayerPedId()
                local animDict = "anim@heists@prison_heistig1_p1_guard_checks_bus"
                local animName = "loop"

                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(10)
                end

                FreezeEntityPosition(ped, true)
                duringTable = true
                CreateThread(function()
                    while duringTable do
                        if not IsEntityPlayingAnim(ped, animDict, animName, 3) then
                            TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 1, 0, false, false, false)
                        end
                        Wait(0)
                    end
                    ClearPedTasks(ped)
                end)

                if exports.esx_hud:progressBar({
                    duration = 5,
                    label = "Sprawdzanie stołu...",
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = true,
                        combat = true,
                    },
                }) then
                    OpenCraftingUI()
                    FreezeEntityPosition(ped, false)
                else
                    duringTable = false
                    ESX.ShowNotification('Anulowano...')
                    FreezeEntityPosition(ped, false)
                end
            end
        },
        {
            name = "pickup_table",
            label = "Podnieś stół",
            icon = "fas fa-hand",
            distance = 2.0,
            -- groups = { "admin", "superadmin" },
            canInteract = function()
                local group = ESX.GetPlayerData().group
                if group ~= "admin" and group ~= "founder" then return false end
                return not carryingTable
            end,
            onSelect = function()
                startCarrying(obj, netId or NetworkGetNetworkIdFromEntity(obj))
            end
        },
        {
            name = "delete_table",
            label = "Usuń stół (na zawsze)",
            icon = "fas fa-trash",
            distance = 2.0,
            -- groups = { "admin", "superadmin" },
            canInteract = function()
                local group = ESX.GetPlayerData().group
                if group ~= "admin" and group ~= "founder" then return false end
                return not carryingTable
            end,
            onSelect = function()
                TriggerServerEvent("adminCraftingTable:delete", netId or NetworkGetNetworkIdFromEntity(obj))
            end
        }
    }})
end

function startCarrying(tableObj, netId)
    carryingTable = true
    carriedTable = tableObj
    local ped = PlayerPedId()
    exports.ox_target.removeZone(targets[netId])

    NetworkRequestControlOfEntity(tableObj)
    while not NetworkHasControlOfEntity(tableObj) do Wait(10) end
    local przedCoords = GetEntityCoords(tableObj)
    local przedHeading = GetEntityHeading(tableObj)
    AttachEntityToEntity(tableObj, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    ESX.ShowNotification("Naciśnij [E] aby postawić stół, [G] aby anulować")

    CreateThread(function()
        while carryingTable do
            Wait(0)
            DisableControlAction(0, 38, true)  -- E
            DisableControlAction(0, 47, true)  -- G (detonate)

            if IsDisabledControlJustPressed(0, 38) then -- E - postaw
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                stopCarrying(netId)
            elseif IsDisabledControlJustPressed(0, 47) then -- G - anuluj
                stopCarrying(netId,przedCoords, przedHeading)
            end
        end
    end)
end

function stopCarrying(netId,przedCoords, przedHeading)
    if not carryingTable then return end
    carryingTable = false
    local cwelCoords = GetEntityCoords(PlayerPedId())
    local cwelHeading = GetEntityHeading(PlayerPedId())
    TriggerServerEvent('adminCraftingTable:delete', netId)
    DeleteEntity(carriedTable)
    if przedCoords and przedHeading then
        TriggerServerEvent("adminCraftingTable:spawn", przedCoords, przedHeading)
        ESX.ShowNotification("~r~Anulowano przenoszenie stołu")
        carriedTable = nil
        return
    end
    TriggerServerEvent("adminCraftingTable:spawn", cwelCoords, cwelHeading)

    carriedTable = nil
    ESX.ShowNotification("~g~Postawiono stół")
end