local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteEntity = DeleteEntity
local IsPedInVehicle = IsPedInVehicle

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		disposeFunc(iter)
	end)
end

local function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

RegisterNetEvent("esx_core:timeClear", function(isAdmin)
	Wait(100)

	local prefix = isAdmin and "przez administratora" or ""
	local times = {30, 15, 5}

	for _, time in ipairs(times) do
		ESX.ShowNotification(('Mapa zostanie wyczyszczona%s za %d sekund'):format(prefix ~= "" and " " .. prefix or "", time))
		Wait(time * 1000)
	end

	local message = isAdmin and " Mapa została wyczyszczona przez administratora" or " Mapa została wyczyszczona"
	TriggerEvent('chat:sendNewAddonChatMessage', "^*INFO", {255, 0, 0}, message, "fas fa-shield-alt")

	Wait(100)

	local ped = cache.ped
	for vehicle in EnumerateVehicles() do
		if not IsPedInVehicle(ped, vehicle, true) then
			if not Entity(vehicle).state.InRobbery then
				SetEntityAsMissionEntity(vehicle, true, true)
				DeleteEntity(vehicle)
			end
		end
	end
end)