local carrying = {}
local carried = {}
local pendingRequests = {}

RegisterNetEvent("CarryPeople:request")
AddEventHandler("CarryPeople:request", function(targetSrc)
	local source = source
	local sourceCoords = GetEntityCoords(GetPlayerPed(source))
	local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
	if #(sourceCoords - targetCoords) <= 3.0 then
		if Player(targetSrc).state.IsHandcuffed then
			TriggerClientEvent("esx:showNotification", source, "Nie możesz podnieść zakutego gracza")
			return
		end
		
		if Player(targetSrc).state.IsConcussed then
			TriggerClientEvent("esx:showNotification", source, "Nie możesz podnieść powalonego gracza")
			return
		end
		
		pendingRequests[targetSrc] = {
			source = source,
			timestamp = os.time()
		}
		TriggerClientEvent("CarryPeople:requestReceived", targetSrc, source)
		TriggerClientEvent("esx:showNotification", source, "Wysłano prośbę o podniesienie")
		
		Citizen.SetTimeout(30000, function()
			if pendingRequests[targetSrc] and pendingRequests[targetSrc].source == source then
				pendingRequests[targetSrc] = nil
				TriggerClientEvent("esx:showNotification", source, "Prośba wygasła")
			end
		end)
	end
end)

RegisterNetEvent("CarryPeople:accept")
AddEventHandler("CarryPeople:accept", function(sourceSrc)
	local target = source
	local source = sourceSrc
	if pendingRequests[target] and pendingRequests[target].source == source then
		if Player(target).state.IsHandcuffed then
			TriggerClientEvent("esx:showNotification", source, "Nie możesz podnieść zakutego gracza")
			pendingRequests[target] = nil
			return
		end
		
		if Player(target).state.IsConcussed then
			TriggerClientEvent("esx:showNotification", source, "Nie możesz podnieść powalonego gracza")
			pendingRequests[target] = nil
			return
		end
		
		local sourceCoords = GetEntityCoords(GetPlayerPed(source))
		local targetCoords = GetEntityCoords(GetPlayerPed(target))
		if #(sourceCoords - targetCoords) <= 3.0 then
			TriggerClientEvent("CarryPeople:syncTarget", target, source)
			TriggerClientEvent("CarryPeople:startCarrying", source, target)
			carrying[source] = target
			carried[target] = source
			TriggerClientEvent("esx:showNotification", source, "Gracz zaakceptował prośbę")
		end
		pendingRequests[target] = nil
	end
end)

RegisterNetEvent("CarryPeople:reject")
AddEventHandler("CarryPeople:reject", function(sourceSrc)
	local target = source
	local source = sourceSrc
	if pendingRequests[target] and pendingRequests[target].source == source then
		TriggerClientEvent("esx:showNotification", source, "Gracz odrzucił prośbę")
		pendingRequests[target] = nil
	end
end)

RegisterNetEvent("CarryPeople:sync")
AddEventHandler("CarryPeople:sync", function(targetSrc)
	local source = source
	local sourceCoords = GetEntityCoords(GetPlayerPed(source))
	local targetCoords = GetEntityCoords(GetPlayerPed(targetSrc))
	if #(sourceCoords - targetCoords) <= 3.0 then
		TriggerClientEvent("CarryPeople:syncTarget", targetSrc, source)
		carrying[source] = targetSrc
		carried[targetSrc] = source
	end
end)

RegisterNetEvent("CarryPeople:stop")
AddEventHandler("CarryPeople:stop", function(targetSrc)
	local source = source
	if carrying[source] then
		TriggerClientEvent("CarryPeople:cl_stop", targetSrc)
		carried[targetSrc] = nil
		carrying[source] = nil
	elseif carried[source] then
		local carrier = carried[source]
		TriggerClientEvent("CarryPeople:cl_stop", carrier)
		carrying[carrier] = nil
		carried[source] = nil
	end
end)

AddEventHandler("playerDropped", function(reason)
	local source = source
	if carrying[source] then
		local target = carrying[source]
		TriggerClientEvent("CarryPeople:cl_stop", target)
		carried[target] = nil
		carrying[source] = nil
	end
	if carried[source] then
		local carrier = carried[source]
		TriggerClientEvent("CarryPeople:cl_stop", carrier)
		carrying[carrier] = nil
		carried[source] = nil
	end
	if pendingRequests[source] then
		pendingRequests[source] = nil
	end
	for targetSrc, request in pairs(pendingRequests) do
		if request.source == source then
			pendingRequests[targetSrc] = nil
		end
	end
end)