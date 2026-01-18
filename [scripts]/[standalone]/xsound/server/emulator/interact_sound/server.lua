RegisterServerEvent('InteractSound_SV:PlayOnOne')
AddEventHandler('InteractSound_SV:PlayOnOne', function(clientNetId, soundFile, soundVolume)
	if clientNetId == -1 then
        return
    end
  
    if clientNetId ~= nil then
		local _source = clientNetId
		TriggerClientEvent('InteractSound_CL:PlayOnOne', _source, soundFile, soundVolume)
	end
end)

RegisterServerEvent('InteractSound_SV:PlayOnSource')
AddEventHandler('InteractSound_SV:PlayOnSource', function(soundFile, soundVolume)
	local _source = source
    TriggerClientEvent('InteractSound_CL:PlayOnOne', _source, soundFile, soundVolume)
end)

RegisterServerEvent('InteractSound_SV:PlayOnAll')
AddEventHandler('InteractSound_SV:PlayOnAll', function(soundFile, soundVolume)
    local src = source 
    TriggerEvent('OnlyRPAC:BanPlr', src, "Próba wysłania dźwięku każdemu")
    -- exports['only_logs']:SendLog(src, "Ktoś wysyła dzwięk każdemu", 'anticheat', '5793266')
end)

RegisterServerEvent('InteractSound_SV:PlayWithinDistance')
AddEventHandler('InteractSound_SV:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    local player = source
    if maxDistance > 7.0 then
        TriggerEvent('OnlyRPAC:BanPlr', source, "Tried to play sound with big distance - "..maxDistance)
        return
    end
    TriggerClientEvent('InteractSound_CL:PlayWithinDistance', -1, source, maxDistance, soundFile, soundVolume)
end)