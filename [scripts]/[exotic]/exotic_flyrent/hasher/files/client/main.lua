local Licenses = {}
local ox_target = exports.ox_target

RegisterNetEvent('esx_flightschool:loadLicenses', function(licenses)
    Licenses = licenses
end)

CreateThread(function()
    while true do
        Wait(10000)
        SetAudioFlag("DisableFlightMusic", true)
    end
end)

local function DrawText3D(x, y, z, text)
    local size = 0.35
    SetTextScale(size, size)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(1)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        DrawText(_x, _y)
    end
end

local function openNUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setVisible',
        data = true
    })
end

RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false
    })

    cb('ok')
end)

RegisterNUICallback('rent', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        data = false
    })

    if IsAnyVehicleNearPoint(-1271.6899, -3399.6235, 13.9401, 10.0) then
        ESX.ShowNotification('Miejsce jest zajęte przez inny pojazd!')
        cb('ok')
        return
    end

    lib.callback("exotic_flyrent:rent", false, function() end, data.value)
    cb('ok')
end)

local function onEnter(point)
    if point.entity then return end

    local model = lib.requestModel(`s_m_m_strpreach_01`)
    if not model then return end

    Wait(1000)

    local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z, point.heading, false, true)

    TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    ox_target:addLocalEntity(entity, {
        {
            icon = 'fa-solid fa-plane-up',
            label = point.label,
            canInteract = function()
                return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead or LocalPlayer.state.InTrunk or cache.vehicle)
            end,
            onSelect = function()
                TriggerServerEvent('esx_flightschool:reloadLicense')

                local ownedLicenses = {}
                for i = 1, #Licenses do
                    ownedLicenses[Licenses[i].type] = true
                end

                if not ownedLicenses['fly'] then
                    ESX.ShowNotification('Nie posiadasz licencji pilota, wyrób ją w szkole lotniczej!')
                    return
                end

                openNUI()
            end,
            distance = 2.0
        }
    })

    point.entity = entity
end
 
local function onExit(point)
    if not point.entity then return end

    local entity = point.entity
    ox_target:removeLocalEntity(entity, point.label)

    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, false, true)
        DeleteEntity(entity)
    end

    point.entity = nil
end

CreateThread(function()
    lib.points.new({
        id = 140,
        distance = 200,
        coords = vec3(-1242.1051, -3393.0796, 13.9401 - 1.0),
        heading = 56.1081,
        label = 'Rozmawiaj',
        onEnter = onEnter,
        onExit = onExit,
    })
end)

local returnPoint = lib.points.new(vec3(-1271.6899, -3399.6235, 13.9401), 20)
local validModels = {
    [GetHashKey('frogger')] = true,
    [GetHashKey('maverick')] = true,
    [GetHashKey('supervolito')] = true,
    [GetHashKey('velum2')] = true,
    [GetHashKey('luxor2')] = true,
}

function returnPoint:nearby()
    if not cache.vehicle then return end

    DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 0.99, 0.0, 0.0, 0.0, 0.0, 0.0, -6.0, 8.0, 8.0, 0.6, 178, 15, 52, 120, false, false, 2, false, false, false, false)

    if self.currentDistance >= 12 then return end

    local vehicleModel = GetEntityModel(cache.vehicle)

    if validModels[vehicleModel] then
        DrawText3D(self.coords.x, self.coords.y, self.coords.z + 0.80, 'Naciśnij ~r~[E] ~w~aby zwrócić pojazd')
        if self.currentDistance < 3 and IsControlJustReleased(0, 38) then
            ESX.Game.DeleteVehicle(cache.vehicle, false)
            SetEntityCoords(cache.ped, -1242.9617, -3392.0518, 13.9401)
        end
    else
        DrawText3D(self.coords.x, self.coords.y, self.coords.z, '~r~Nie zwrócisz tego pojazdu!')
    end
end