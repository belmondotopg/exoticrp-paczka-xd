local interactions = {}
local pressedInteractions = {}

function ESX.RemoveInteraction(name)
    if not interactions[name] then return end
    interactions[name] = nil
end

ESX.RegisterInteraction = function(name, onPress, condition)
    interactions[name] = {
        condition = condition or function() return true end,
        onPress = onPress,
        creator = GetInvokingResource() or "es_extended"
    }
end

function ESX.GetInteractKey()
    local hash = joaat('esx_interact') | 0x80000000
    return GetControlInstructionalButton(0, hash, true):sub(3)
end

ESX.RegisterInput("esx_interact", "Interact", "keyboard", "e", function()
    for _, interaction in pairs(interactions) do
        local success, result = pcall(interaction.condition)
        if success and result then
            pressedInteractions[#pressedInteractions+1] = interaction
            interaction.onPress()
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    for name, interaction in pairs(interactions) do
        if interaction.creator == resource then
            interactions[name] = nil
        end
    end
end)

local boosting = false
local currentVehicle = 0

RegisterNetEvent('es_extended/launchboost:applyBoost')
AddEventHandler('es_extended/launchboost:applyBoost', function(shouldBoost)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then return end

    if shouldBoost then
        if not boosting or currentVehicle ~= vehicle then
            SetVehicleEnginePowerMultiplier(vehicle, 50.0)
            SetVehicleEngineTorqueMultiplier(vehicle, 50.0)
            boosting = true
            currentVehicle = vehicle
        end
    else
        if boosting and currentVehicle == vehicle then
            SetVehicleEnginePowerMultiplier(vehicle, 1.0)
            SetVehicleEngineTorqueMultiplier(vehicle, 1.0)
            boosting = false
            currentVehicle = 0
        end
    end
end)

Citizen.CreateThread(function()
    local lastPlate = nil
    local lastVehicle = 0

    while true do
        Citizen.Wait(1500)

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= lastVehicle then
                if boosting and currentVehicle ~= vehicle and currentVehicle ~= 0 then
                    SetVehicleEnginePowerMultiplier(currentVehicle, 1.0)
                    SetVehicleEngineTorqueMultiplier(currentVehicle, 1.0)
                    boosting = false
                    currentVehicle = 0
                end

                lastVehicle = vehicle
                lastPlate = nil
            end

            local plate = GetVehicleNumberPlateText(vehicle)
            if plate and plate ~= lastPlate then
                lastPlate = plate
                TriggerServerEvent('es_extended/launchboost:checkVehicle', plate)
            end
        else
            if boosting and currentVehicle ~= 0 then
                SetVehicleEnginePowerMultiplier(currentVehicle, 1.0)
                SetVehicleEngineTorqueMultiplier(currentVehicle, 1.0)
                boosting = false
                currentVehicle = 0
            end
            lastPlate = nil
            lastVehicle = 0
            Citizen.Wait(2000)
        end
    end
end)