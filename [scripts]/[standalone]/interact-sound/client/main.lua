local standardVolumeOutput = 0.3

RegisterNetEvent('interact-sound_CL:PlayOnOne')
AddEventHandler('interact-sound_CL:PlayOnOne', function(soundFile, soundVolume)
    if ESX.PlayerLoaded then
        SendNUIMessage({
            transactionType = 'playSound',
            transactionFile  = soundFile,
            transactionVolume = soundVolume
        })
    end
end)

RegisterNetEvent('interact-sound_CL:PlayWithinDistance')
AddEventHandler('interact-sound_CL:PlayWithinDistance', function(otherPlayerCoords, maxDistance, soundFile, soundVolume)
	if ESX.PlayerLoaded then
		local myCoords = cache.coords
		local distance = #(myCoords - otherPlayerCoords)

		if distance < maxDistance then
			SendNUIMessage({
				transactionType = 'playSound',
				transactionFile  = soundFile,
				transactionVolume = soundVolume or standardVolumeOutput
			})
		end
	end
end)