local GetEntityCoords = GetEntityCoords
local GetPlayerPed = GetPlayerPed

RegisterNetEvent('interact-sound_SV:PlayOnSource')
AddEventHandler('interact-sound_SV:PlayOnSource', function(soundFile, soundVolume)
    local src = source
    TriggerClientEvent('interact-sound_CL:PlayOnOne', src, soundFile, soundVolume)
end)

RegisterNetEvent('interact-sound_SV:PlayWithinDistance')
AddEventHandler('interact-sound_SV:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    local src = source

    if maxDistance > 10 then
        maxDistance = 3
    end

    TriggerClientEvent('interact-sound_CL:PlayWithinDistance', -1, GetEntityCoords(GetPlayerPed(src)), maxDistance, soundFile, soundVolume)
end)