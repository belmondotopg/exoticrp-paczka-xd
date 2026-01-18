Core = {}
Core.Input = {}
Core.Events = {}

ESX.PlayerData = {}
ESX.PlayerLoaded = false
ESX.playerId = PlayerId()
ESX.serverId = GetPlayerServerId(ESX.playerId)

ESX.UI = {}
ESX.UI.Menu = {}
ESX.UI.Menu.RegisteredTypes = {}
ESX.UI.Menu.Opened = {}

ESX.Game = {}
ESX.Game.Utils = {}

CreateThread(function()
    while not Config.Multichar do
        Wait(100)

        if NetworkIsPlayerActive(ESX.playerId) then
            ESX.DisableSpawnManager()
            DoScreenFadeOut(0)
            Wait(500)
            TriggerServerEvent("esx:onPlayerJoined")
            break
        end
    end
end)

RegisterNetEvent('es_extended:useDecorUpdate')
AddEventHandler('es_extended:useDecorUpdate', function(action, networkId, key, value)
    local entity = NetworkGetEntityFromNetworkId(networkId)
    
    if not entity or entity == 0 then
        print(('[DecorUpdate] Invalid entity for network ID %s'):format(tostring(networkId)))
        return
    end

    if action == 'DEL' then
        if DecorExistOn(entity, key) then
            DecorRemove(entity, key)
        else
            print(('[DecorUpdate] No decorator "%s" on entity %d to remove'):format(key, entity))
        end
    elseif action == 'BOOL' then
        local boolVal = (value == true or tostring(value) == 'true')
        DecorSetBool(entity, key, boolVal)
    elseif action == 'INT' then
        local intVal = tonumber(value)
        if intVal then
            DecorSetInt(entity, key, intVal)
        else
            print(('[DecorUpdate] Invalid INT value for key "%s": %s'):format(key, tostring(value)))
        end
    elseif action == 'FLOAT' then
        local floatVal = tonumber(value)
        if floatVal then
            DecorSetFloat(entity, key, floatVal)
        else
            print(('[DecorUpdate] Invalid FLOAT value for key "%s": %s'):format(key, tostring(value)))
        end
    else
        print(('[DecorUpdate] Unknown action "%s" for entity %d'):format(tostring(action), entity))
    end
end)