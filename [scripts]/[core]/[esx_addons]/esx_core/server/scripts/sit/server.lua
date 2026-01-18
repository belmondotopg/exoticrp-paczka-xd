local seatsTaken = {}

RegisterNetEvent('ox_sit:takePlace')
AddEventHandler('ox_sit:takePlace', function(objectCoords, object)
	seatsTaken[objectCoords] = true
	seatsTaken[object] = object
end)

RegisterNetEvent('ox_sit:leavePlace')
AddEventHandler('ox_sit:leavePlace', function(objectCoords)
	if seatsTaken[objectCoords] then
		seatsTaken[objectCoords] = nil
	end
end)

lib.callback.register('ox_sit:getPlace',function(objectCoords)
    return seatsTaken[objectCoords]
end)
