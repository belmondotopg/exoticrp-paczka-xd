-- i recommend to NOT change the command name. it will make easier for people to use this command
-- when ever is this library.. so please keep this command name on "streamermode" command
local ESX = nil
CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        if ESX == nil then
            ESX = exports['es_extended']:getSharedObject()
        end
        Wait(100)
    end
end)

RegisterCommand("streamermode", function(source, args, rawCommand)
    disableMusic = not disableMusic
    TriggerEvent("xsound:streamerMode", disableMusic)
    TriggerEvent("rtx_dj:StreamerMode", disableMusic)
    
    if disableMusic then
        SendNUIMessage({ status = "position", x = -900000, y = -900000, z = -900000 })
        SendNUIMessage({ status = "muteAll" })
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(config.Messages["streamer_on"])
        end
    else
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        SendNUIMessage({
            status = "position",
            x = pos.x,
            y = pos.y,
            z = pos.z
        })
        SendNUIMessage({ status = "unmuteAll" })
        if ESX and ESX.ShowNotification then
            ESX.ShowNotification(config.Messages["streamer_off"])
        end
    end
end, false)

AddEventHandler("xsound:streamerMode", function(status)
    if status then
        for k, v in pairs(soundInfo) do
            Destroy(v.id)
        end
    end
end)