local Config = {
	ShowNUIDelay = 100
}

local isScratching = false
local cachePed = cache.ped
local cacheVehicle = cache.vehicle

lib.onCache('ped', function(ped)
	cachePed = ped
end)

lib.onCache('vehicle', function(vehicle)
	cacheVehicle = vehicle
end)

local function closeScratchCard()
	if not isScratching then
		return
	end

	isScratching = false
	SetNuiFocus(false, false)

	if not cacheVehicle and cachePed then
		ClearPedTasks(cachePed)
	end

	TriggerServerEvent('esx_scratchcards:payment')
end

RegisterNetEvent('esx_scratchcards:showSC')
AddEventHandler('esx_scratchcards:showSC', function(scratch, payment)
	if isScratching then
		return
	end

	isScratching = true

	CreateThread(function()
		Wait(Config.ShowNUIDelay)

		if not cacheVehicle and cachePed then
			TaskStartScenarioInPlace(cachePed, "PROP_HUMAN_PARKING_METER", 0, false)
		end

		SetNuiFocus(true, true)
		SendNUIMessage({
			type = 'showNUI',
			scratch = scratch,
			component = payment
		})
	end)
end)

RegisterNUICallback('NUIFocusOff', function()
	closeScratchCard()
end)

AddEventHandler('gameEventTriggered', function(event, args)
	if event ~= "CEventNetworkEntityDamage" then 
		return 
	end

	if GetEntityType(args[1]) ~= 1 then 
		return 
	end

	if NetworkGetPlayerIndexFromPed(args[1]) ~= PlayerId() then 
		return 
	end

	if not IsEntityDead(cachePed) then 
		return 
	end

	closeScratchCard()
end)
