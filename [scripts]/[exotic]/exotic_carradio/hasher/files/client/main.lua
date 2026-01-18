exports('OpenRadio', function()
    TriggerServerEvent('piotreq_radiocar:server:OpenRadio')
end)


RegisterNetEvent('piotreq_radiocar:client:OpenRadio', function(data)
    if (data.vehicle) then
        if exports['xsound']:soundExists(data.plate) then
            data.vehicle.time = exports['xsound']:getTimeStamp(data.plate)
            data.vehicle.duration = exports['xsound']:getMaxDuration(data.plate)
        else
            data.vehicle.time, data.vehicle.duration = 0, 0
        end
    end
    SendNUIMessage({action = 'OpenRadio', radio = data, lang = Config.Translation[Config.Language]})
    SetNuiFocus(true, true)
end)

RegisterNUICallback('CloseRadio', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('PlayMusic', function(data)
    local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    data.model = GetDisplayNameFromVehicleModel(GetEntityModel(plyVeh))
    TriggerServerEvent('piotreq_radiocar:server:PlayMusic', data)
end)

RegisterNUICallback('StopMusic', function(data)
    TriggerServerEvent('piotreq_radiocar:server:StopMusic', data)
end)

RegisterNUICallback('SaveMusic', function(data)
    TriggerServerEvent('piotreq_radiocar:server:SaveMusic', data)
end)

RegisterNetEvent('piotreq_radiocar:client:RadioTime', function(data)
    local duration = exports['xsound']:getMaxDuration(data.plate)
    local time = exports['xsound']:getTimeStamp(data.plate)
    SendNUIMessage({action = 'RadioTime', duration = duration, time = time})
end)

RegisterNUICallback('ToggleLoop', function(data)
    TriggerServerEvent('piotreq_radiocar:server:ToggleLoop', data)
end)

RegisterNetEvent('piotreq_radiocar:client:LoopRadio', function(data)
    exports['xsound']:setSoundLoop(data.name, data.toggle)
end)

RegisterNetEvent('piotreq_radiocar:client:Dynamic', function(data)
    exports['xsound']:setSoundDynamic(data.name, true)
end)

RegisterNUICallback('ChangeVolume', function(data)
    TriggerServerEvent('piotreq_radiocar:server:ChangeVolume', data)
end)