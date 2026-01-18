local keyManagerPed = nil
local blip = nil
local Config = {}

Config.PedLocation = {
    coords = vec3(-556.94732666016, -186.28381347656, 38.22114944458),
    heading = 216.4092
}

Config.PedModel = 'a_m_y_business_01'

local function openKeyMenu()
    local input = lib.inputDialog('Zarządzanie kluczykami', {
        {
            type = 'input',
            label = 'Numer rejestracyjny',
            description = 'Wprowadź numer rejestracyjny pojazdu',
            required = true,
            min = 1,
            max = 8
        }
    })

    if input and input[1] then
        local plate = string.upper(input[1])
        TriggerEvent('op-garages:openSubOwnerMenu', plate)
    end
end

CreateThread(function()
    local pedModel = GetHashKey(Config.PedModel)
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end

    keyManagerPed = CreatePed(4, pedModel, Config.PedLocation.coords.x, Config.PedLocation.coords.y,
        Config.PedLocation.coords.z - 1.0, Config.PedLocation.heading, false, true)

    FreezeEntityPosition(keyManagerPed, true)
    SetEntityInvincible(keyManagerPed, true)
    SetBlockingOfNonTemporaryEvents(keyManagerPed, true)

    exports.ox_target:addLocalEntity(keyManagerPed, {
        {
            name = 'key_management',
            label = 'Zarządzanie kluczykami',
            icon = 'fas fa-key',
            distance = 2.5,
            onSelect = function()
                openKeyMenu()
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if keyManagerPed and DoesEntityExist(keyManagerPed) then
        DeleteEntity(keyManagerPed)
    end

    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end)
