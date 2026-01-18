RegisterNetEvent('exotic_blackout/dzwon', function(list, damage)
	local src = source
	
	if type(list) ~= "table" or type(damage) ~= "number" then return end
	
	damage = math.max(0, math.min(20, damage))
	
	local processed = {}
	
	for _, playerId in pairs(list) do
		if type(playerId) == "number" and playerId > 0 and not processed[playerId] then
			processed[playerId] = true
			TriggerClientEvent('exotic_blackout/dzwon', playerId, damage)
		end
	end
	
	if not processed[src] then
		TriggerClientEvent('exotic_blackout/dzwon', src, damage)
	end
end)

RegisterNetEvent('exotic_blackout/impact', function(list, speedBuffer, velocityBuffer)
	local src = source
	
	if type(list) ~= "table" or type(speedBuffer) ~= "table" or type(velocityBuffer) ~= "table" then return end
	
	local processed = {}
	
	for _, playerId in pairs(list) do
		if type(playerId) == "number" and playerId > 0 and not processed[playerId] then
			processed[playerId] = true
			TriggerClientEvent('exotic_blackout/impact', playerId, speedBuffer, velocityBuffer)
		end
	end
	
	if not processed[src] then
		TriggerClientEvent('exotic_blackout/impact', src, speedBuffer, velocityBuffer)
	end
end)

RegisterNetEvent('exotic_blackout/beltForPlayer', function(target, status)
	local src = source
	
	if tonumber(target) == -1 or not target or target <= 0 then return end
	
	if src > 0 and target > 0 then
		local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target)))
		if distance > 5 then return end
		
		TriggerClientEvent('exotic_blackout/belt', target, status)
	end
end)