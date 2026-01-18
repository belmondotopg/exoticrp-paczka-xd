local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler

local blips = {}
local vehicleTrackerBlips = {}
local libCache = lib.onCache
local cachePlayerId = cache.playerId

libCache('playerId', function(playerId)
	cachePlayerId = playerId
end)

local function setBlipCommonProperties(blip, data, heading)
	SetBlipScale(blip, 0.9)
	SetBlipCategory(blip, 7)
	SetBlipRotation(blip, math.ceil(heading))
	ShowHeadingIndicatorOnBlip(blip, true)
	SetBlipSecondaryColour(blip, 255, 0, 0)
	SetBlipAsShortRange(blip, false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('# '..tostring(data.text))
	EndTextCommandSetBlipName(blip)
end

local function updateBlipVehicleState(blip, ped, data)
	local inVehicle = IsPedInAnyVehicle(ped) or IsPedInAnyHeli(ped) or data.vehicle ~= 0 or data.inHeli
	if inVehicle then
		local isHeli = IsPedInAnyHeli(ped) or data.inHeli
		SetBlipSprite(blip, isHeli and 43 or 637)
		local sirenOn = IsVehicleSirenOn(GetVehiclePedIsIn(ped, false)) or data.siren
		if sirenOn then
			CreateThread(function()
				for i = 1, 5 do
					SetBlipColour(blip, 29)
					Wait(500)
					SetBlipColour(blip, 1)
					Wait(500)
				end
			end)
		else
			SetBlipColour(blip, data.color)
		end
	else
		SetBlipSprite(blip, 1)
		SetBlipColour(blip, data.color)
	end
end

local function createDynamicBlip(playerId, data)
	local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
	local blip = GetBlipFromEntity(ped)
	
	if not DoesBlipExist(blip) then
		if blips[playerId] then
			RemoveBlip(blips[playerId])
		end
		blip = AddBlipForEntity(ped)
		blips[playerId] = blip
		SetBlipSprite(blip, 1)
		SetBlipColour(blip, data.color)
		setBlipCommonProperties(blip, data, GetEntityHeading(ped))
	else
		local b = blips[playerId]
		if b and b ~= blip then
			RemoveBlip(b)
		end
		blips[playerId] = blip
		updateBlipVehicleState(blip, ped, data)
		setBlipCommonProperties(blip, data, GetEntityHeading(ped))
	end
end

local function createStaticBlip(playerId, data)
	local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
	local blip = blips[playerId]
	
	if DoesBlipExist(blip) then
		if GetBlipInfoIdType(blip) ~= 4 then
			RemoveBlip(blip)
			blips[playerId] = nil
		else
			SetBlipCoords(blip, data.coords)
			SetBlipRotation(blip, data.heading)
			updateBlipVehicleState(blip, ped, data)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('# '..tostring(data.text))
			EndTextCommandSetBlipName(blip)
		end
	else
		blip = AddBlipForCoord(data.coords)
		blips[playerId] = blip
		local vehicle = GetVehiclePedIsIn(ped, false)
		local inVehicle = IsPedInAnyVehicle(ped) or IsPedInAnyHeli(ped) or data.vehicle ~= 0
		if inVehicle then
			local isHeli = IsPedInAnyHeli(ped) or data.inHeli
			SetBlipSprite(blip, isHeli and 43 or 637)
			local sirenOn = IsVehicleSirenOn(vehicle) or data.siren
			if sirenOn then
				CreateThread(function()
					for i = 1, 5 do
						SetBlipColour(blip, 29)
						Wait(500)
						SetBlipColour(blip, 1)
						Wait(500)
					end
				end)
			else
				SetBlipColour(blip, data.color)
			end
		else
			SetBlipSprite(blip, 1)
			SetBlipColour(blip, data.color)
		end
		SetBlipDisplay(blip, 4)
		setBlipCommonProperties(blip, data, data.heading)
	end
end

RegisterNetEvent('esx_localizations:updateBlip')
AddEventHandler('esx_localizations:updateBlip', function(ServerData)
	local memory = {}
	for playerId, data in pairs(ServerData) do
		local player = GetPlayerFromServerId(playerId)
		if not player or player == -1 then
			createStaticBlip(playerId, data)
			memory[playerId] = true
		elseif player ~= cachePlayerId then
			createDynamicBlip(playerId, data)
			memory[playerId] = true
		end
	end

	for k, v in pairs(blips) do
		if v and not memory[k] then
			RemoveBlip(v)
			blips[k] = nil
		end
	end
end)

RegisterNetEvent('esx_localizations:removeGPSForID')
AddEventHandler('esx_localizations:removeGPSForID', function(playerId)
	if blips[playerId] then
		RemoveBlip(blips[playerId])
		blips[playerId] = nil
	end
end)

RegisterNetEvent('esx_localizations:cleanup')
AddEventHandler('esx_localizations:cleanup', function()
	for k, v in pairs(blips) do
		RemoveBlip(v)
		blips[k] = nil
	end
end)

local function updateVehicleTrackerBlip(plate, data)
	local blip = vehicleTrackerBlips[plate]
	
	if not blip or not DoesBlipExist(blip) then
		blip = AddBlipForCoord(data.coords)
		vehicleTrackerBlips[plate] = blip
		SetBlipSprite(blip, 225)
		SetBlipColour(blip, 1)
		SetBlipScale(blip, 0.9)
		SetBlipCategory(blip, 7)
		SetBlipAsShortRange(blip, false)
		ShowHeadingIndicatorOnBlip(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Nadajnik GPS - ' .. plate)
		EndTextCommandSetBlipName(blip)
	else
		SetBlipCoords(blip, data.coords)
		SetBlipRotation(blip, math.ceil(data.heading))
	end
end

RegisterNetEvent('esx_localizations:updateVehicleTrackers')
AddEventHandler('esx_localizations:updateVehicleTrackers', function(trackerData)
	local memory = {}
	
	for plate, data in pairs(trackerData) do
		updateVehicleTrackerBlip(plate, data)
		memory[plate] = true
	end
	
	for plate, blip in pairs(vehicleTrackerBlips) do
		if not memory[plate] then
			if DoesBlipExist(blip) then
				RemoveBlip(blip)
			end
			vehicleTrackerBlips[plate] = nil
		end
	end
end)

RegisterNetEvent('esx_localizations:startAnimation', function(plate, netId)
    local playerPed = PlayerPedId()
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    
    if not vehicle or not DoesEntityExist(vehicle) then
        return
    end

    local currentHeading = GetEntityHeading(playerPed)
    SetEntityHeading(playerPed, currentHeading + 180.0)

    RequestAnimDict("amb@world_human_vehicle_mechanic@male@base") 
    while not HasAnimDictLoaded("amb@world_human_vehicle_mechanic@male@base") do
        Wait(100)
    end

    TaskPlayAnim(playerPed, "amb@world_human_vehicle_mechanic@male@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    if exports.esx_hud:progressBar({
		duration = 5,
		label = 'Zakładanie nadajnika GPS',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = true,
			combat = true,
		},
	}) then
		ClearPedTasks(playerPed)
		TriggerServerEvent('esx_localizations:giveGPS', plate, netId)
	end
end)

RegisterNetEvent('esx_localizations:removedGPS')
AddEventHandler('esx_localizations:removedGPS', function(data)
	if not data or not data.coords or not data.name then
		return
	end

	if vehicleTrackerBlips[data.name] then
		local activeBlip = vehicleTrackerBlips[data.name]
		if DoesBlipExist(activeBlip) then
			RemoveBlip(activeBlip)
		end
		vehicleTrackerBlips[data.name] = nil
	end

	if GetResourceState('qf_mdt') == 'started' then
		TriggerServerEvent('qf_mdt:addDispatchAlertSV', data.coords, 'Utracono połączenie z nadajnikiem!', 'Nadajnik [' .. data.name .. '] przestał wysyłać aktywny sygnał, sprawdźcie jego lokalizacje!', '10-74', 'rgb(192, 222, 0)', '10', 484, 63, 63)
	end
	
	local alpha = 250
	local gpsBlip = AddBlipForCoord(data.coords)

	SetBlipSprite(gpsBlip, 280)
	SetBlipColour(gpsBlip, 3)
	SetBlipAlpha(gpsBlip, alpha)
	SetBlipScale(gpsBlip, 0.7)
	SetBlipAsShortRange(gpsBlip, false)
	SetBlipCategory(gpsBlip, 15)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("# Ostatnia lokalizacja nadajnika " .. data.name)
	EndTextCommandSetBlipName(gpsBlip)
	
	CreateThread(function()
		while alpha ~= 0 do
			Wait(60 * 4)
			alpha = alpha - 1
			SetBlipAlpha(gpsBlip, alpha)
			if alpha == 0 then
				RemoveBlip(gpsBlip)
				return
			end
		end
	end)
end)