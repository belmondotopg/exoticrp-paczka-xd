Editable = {}

Editable = {
    spawnVehicle = function(model, data, points)
        local spawnCoords = nil
        for i = 1, #points do
            local vehicles = lib.getNearbyVehicles(vector3(points[i].xyz), 1.25, false)
            if #vehicles == 0 then
                spawnCoords = points[i]
                break
            end
        end

        if not spawnCoords then 
            return Editable.showNotify(locale('no_free_spots'), 'error')
        end

        local vehModel = lib.requestModel(model)
        local vehicle = CreateVehicle(vehModel, spawnCoords, true, false)
        SetVehicleOnGroundProperly(vehicle)
        if data.mods and type(data.mods) == 'table' then
            lib.setVehicleProperties(vehicle, data.mods)
        end
        local vehPlate = GetVehicleNumberPlateText(vehicle)
        if GetResourceState('p_carkeys') == 'started' then
            TriggerServerEvent('p_carkeys:CreateKeys', vehPlate)
        elseif GetResourceState('wasabi_carlock') == 'started' then
            exports['wasabi_carlock']:GiveKey(vehPlate)
        elseif GetResourceState('qs-vehiclekeys') == 'started' then
            exports['qs-vehiclekeys']:GiveKeys(vehPlate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true)
        elseif GetResourceState('tgiann-hotwire') == 'started' then
            exports["tgiann-hotwire"]:GiveKeyPlate(vehPlate, true)
        elseif GetResourceState('qbx_vehiclekeys') == 'started' then
            TriggerServerEvent('qbx_vehiclekeys:server:hotwiredVehicle', utils.getNetIdFromEntity(vehicle))
        elseif GetResourceState('qb-vehiclekeys') == 'started' then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', vehPlate)
        end
        return vehicle
    end,
    hideVehicle = function(entity)
        if entity and DoesEntityExist(entity) then
            local vehPlate = GetVehicleNumberPlateText(entity)
            if GetResourceState('p_carkeys') == 'started' then
                TriggerServerEvent('p_carkeys:RemoveKeys', vehPlate)
            elseif GetResourceState('wasabi_carlock') == 'started' then
                exports['wasabi_carlock']:RemoveKey(vehPlate)
            elseif GetResourceState('qs-vehiclekeys') == 'started' then
                exports['qs-vehiclekeys']:RemoveKeys(vehPlate, GetDisplayNameFromVehicleModel(GetEntityModel(entity)), true)
            end

            Citizen.Wait(1)
            SetEntityAsMissionEntity(entity, true, true)
            DeleteVehicle(entity)
        end
    end,
    showNotify = function(message, type)
        lib.notify({
            title = locale('notify_title'),
            description = message,
            type = type or 'inform'
        })
    end,
    progressBar = function(data)
        return lib.progressBar({
            duration = data.duration,
            label = data.label,
            useWhileDead = false,
            canCancel = true,
            disable = {car = true, move = true, combat = true},
            anim = data.anim or nil,
            prop = data.prop or nil
        })
    end,
    showTextUI = function(text)
        lib.showTextUI(text)
    end,
    hideTextUI = function()
        lib.hideTextUI()
    end,
    setClothes = function(data)
        local animDict = lib.requestAnimDict('clothingtie')
        TaskPlayAnim(cache.ped, animDict, 'try_tie_negative_a', 2.0, 2.0, 2000, 49, 0, false, false, false)
        Citizen.Wait(1000)
        if data == 'private' then
            data = lib.callback.await('p_dojjob/server/getPlayerSkin', false)
        end
        if GetResourceState('illenium-appearance') == 'started' then
            exports['illenium-appearance']:setPedComponents(cache.ped, data.components)
            exports['illenium-appearance']:setPedProps(cache.ped, data.props)
        elseif GetResourceState('esx_skin') == 'started' then
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerEvent('skinchanger:loadClothes', skin, data)
            end)
        elseif GetResourceState('p_appearance') == 'started' then
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerEvent('skinchanger:loadClothes', skin, data)
            end)
        elseif GetResourceState('qb-clothing') == 'started' then
            TriggerEvent('qb-clothing:client:loadPlayerClothing', data)
        end
        RemoveAnimDict(animDict)
    end,
    openInventory = function(invType, data)
        if GetResourceState('ox_inventory') == 'started' then
            exports['ox_inventory']:openInventory(invType, data)
        elseif GetResourceState('qb-inventory') == 'started' then
            if type(data) == 'table' then
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id..'_'..data.owner, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id..'_'..data.owner)
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id)
            end
        elseif GetResourceState('ps-inventory') == 'started' then
            if type(data) == 'table' then
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id..'_'..data.owner, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id..'_'..data.owner)
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id)
            end
        elseif GetResourceState('jpr-inventory') == 'started' then
            if type(data) == 'table' then
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id..'_'..data.owner, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id..'_'..data.owner)
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id)
            end
        elseif GetResourceState('qs-inventory') == 'started' then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id, {
                maxweight = 250000,
                slots = 100,
            })
            TriggerEvent("inventory:client:SetCurrentStash", data.id)
        elseif GetResourceState('tgiann-inventory') == 'started' then
            TriggerServerEvent('p_dojjob/server/openInventory', data)
        elseif GetResourceState('codem-inventory') == 'started' then
            if type(data) == 'table' then
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id..'_'..data.owner, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id..'_'..data.owner)
            else
                TriggerServerEvent("inventory:server:OpenInventory", "stash", data.id, {
                    maxweight = 250000,
                    slots = 100,
                })
                TriggerEvent("inventory:client:SetCurrentStash", data.id)
            end
        end
    end,
    getInventoryItems = function()
        if GetResourceState('ox_inventory') == 'started' then
            return exports['ox_inventory']:GetPlayerItems()
        elseif GetResourceState('qb-inventory') == 'started' then
            return QBCore.PlayerData.items
        elseif GetResourceState('ps-inventory') == 'started' then
            return QBCore.PlayerData.items
        elseif GetResourceState('jpr-inventory') == 'started' then
            return QBCore.PlayerData.items
        elseif GetResourceState('qs-inventory') == 'started' then
            return exports['qs-inventory']:getUserInventory()
        elseif GetResourceState('tgiann-inventory') == 'started' then
            return exports["tgiann-inventory"]:GetPlayerItems()
        elseif GetResourceState('codem-inventory') == 'started' then
            return exports['codem-inventory']:getUserInventory()
        end
    end,
    overrideProximity = function(state, range)
        if state then
            exports['pma-voice']:overrideProximityRange(range, true)
        else
            exports['pma-voice']:clearProximityOverride()
        end
    end
}

-- ## RADIAL MENU FUNCTIONALITY

Citizen.CreateThread(function()
    if not Config.RadialMenu then return end
    lib.registerRadial({
        id = 'doj_job_menu',
        items = {
            {
                icon = 'tablet',
                label = locale('tablet'),
                onSelect = function()
                    if GetResourceState('p_dojmdt') == 'started' then
                        exports['p_dojmdt']:openTablet()
                    else
                        lib.print.error('MDT is not started!')
                    end
                end
            },
        }
    })
end)

function createJobRadial()
    if not Config.RadialMenu then return end
    local playerJob = Bridge.getPlayerJob()
    if Config.Jobs[playerJob.jobName] and tonumber(playerJob.jobGrade) > Config.Jobs[playerJob.jobName] then
        lib.addRadialItem({
            id = 'doj_menu',
            label = locale('job_menu'),
            icon = 'briefcase',
            menu = 'doj_job_menu',
        })
    else
        lib.removeRadialItem('doj_menu')
    end
end