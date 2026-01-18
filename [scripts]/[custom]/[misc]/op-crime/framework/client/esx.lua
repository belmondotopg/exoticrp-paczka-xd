ESX = GetResourceState('es_extended') == 'started' and true or false
if not ESX then return end

Framework = exports["es_extended"]:getSharedObject()
Fr.PlayerLoaded = 'esx:playerLoaded'
Fr.PlayerUnLoaded = 'esx:onPlayerLogout'
Fr.VehicleEncode = "vehicle"
Fr.identificatorTable = "identifier"

Fr.TriggerServerCallback = function(...)
    return Framework.TriggerServerCallback(...)
end

Fr.GetVehicleProperties = function(vehicle) 
    return Framework.Game.GetVehicleProperties(vehicle)
end

Fr.DeleteVehicle = function(vehicle)
    if Config.AdditionalScripts.advancedParking then
        exports["AdvancedParking"]:DeleteVehicle(tonumber(vehicle), false)
    end

    return Framework.Game.DeleteVehicle(vehicle)
end

Fr.SetVehicleProperties = function(...) 
    return Framework.Game.SetVehicleProperties(...)
end

Fr.GetPlayerData = function()
    local playerData = Framework.GetPlayerData()
    
    if playerData then
        local isSpectating = false
        if GetResourceState('EasyAdmin') == 'started' then
            isSpectating = exports['EasyAdmin']:IsPlayerSpectating() or false
        end
        isSpectating = isSpectating or LocalPlayer.state.IsSpectating or NetworkIsInSpectatorMode() == 1
        
        if isSpectating and playerData.job then
            local modifiedData = {}
            for k, v in pairs(playerData) do
                modifiedData[k] = v
            end
            modifiedData.job = nil
            return modifiedData
        end
    end
    
    return playerData
end

Fr.isDead = function()
    return LocalPlayer.state.IsDead
end