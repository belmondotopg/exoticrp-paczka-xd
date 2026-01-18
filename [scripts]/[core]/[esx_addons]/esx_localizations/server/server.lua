local GetPlayerPed = GetPlayerPed
local GetEntityHeading = GetEntityHeading
local GetEntityCoords = GetEntityCoords

local Config = {
	['police'] = {
		label = 'LSPD',
		color = 3,
	},
	['ambulance'] = {
		label = 'EMS',
		color = 1
	},
	['mechanik'] = {
		label = 'LSC',
		color = 10
	},
	['ec'] = {
		label = 'EC',
		color = 47
	},
	['sheriff'] = {
		label = 'LSSD',
		color = 40
	},
}

local gpsConfig = {
	item = 'nadajnik_gps',
	jobs = {
		'police',
		'sheriff'
	},
	duration = 600000 -- 10 minutes
}

local blips = {}
local gpsEnabled = {}
local vehicleTrackers = {}

local function createBlipData(playerId, xPlayer, jobData)
	local playerPed = GetPlayerPed(playerId)
	local badge = xPlayer.badge or ''
	local unit = jobData.label
	local grade = xPlayer.job.grade_label
	local colorek = jobData.color

	local vehicle = 0
	local inHeli = false
	local siren = false

	if playerPed then
		vehicle = GetVehiclePedIsIn(playerPed, false)
		if vehicle and vehicle ~= 0 then
			inHeli = GetVehicleType(vehicle) == 'heli'
			siren = IsVehicleSirenOn(vehicle)
		end
	end

	local firstName = xPlayer.get('firstName') or ''
	local lastName = xPlayer.get('lastName') or ''
	local characterName = firstName .. ' ' .. lastName
	characterName = string.gsub(characterName, '^%s+', '')
	characterName = string.gsub(characterName, '%s+$', '')
	characterName = string.gsub(characterName, '%s+', ' ')
	
	return {
		text = '['..unit..'] ['..badge..'] '..characterName..' - '..grade,
		badge = badge,
		color = colorek,
		coords = GetEntityCoords(playerPed),
		heading = GetEntityHeading(playerPed),
		vehicle = vehicle,
		inHeli = inHeli,
		siren = siren,
	}
end

local function updateBlipsForAllPlayers()
	for playerId in pairs(blips) do
		TriggerClientEvent('esx_localizations:updateBlip', playerId, blips)
	end
end

local function refreshBlipData(playerId, xPlayer)
	if blips[playerId] then
		local jobData = Config[xPlayer.job.name]
		if jobData then
			blips[playerId] = createBlipData(playerId, xPlayer, jobData)
		end
	end
end

local function addBlip(playerId, xPlayer)
	if not gpsEnabled[playerId] then
		return
	end
	
	local jobData = Config[xPlayer.job.name]
	if not jobData then
		return
	end

	if blips[playerId] then
		refreshBlipData(playerId, xPlayer)
	else
		blips[playerId] = createBlipData(playerId, xPlayer, jobData)
	end
	updateBlipsForAllPlayers()
end

local function removeBlip(playerId)
	if blips[playerId] then
		blips[playerId] = nil
		TriggerClientEvent('esx_localizations:cleanup', playerId)
		for k in pairs(blips) do
			TriggerClientEvent('esx_localizations:removeGPSForID', k, playerId)
		end
	end
end

local function toggleGPS(playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if not xPlayer then
		return false
	end

	local item = xPlayer.getInventoryItem('gps')
	if not item or item.count < 1 then
		return false
	end

	if not Config[xPlayer.job.name] then
		return false
	end

	if gpsEnabled[playerId] then
		gpsEnabled[playerId] = false
		removeBlip(playerId)
		return false
	else
		gpsEnabled[playerId] = true
		addBlip(playerId, xPlayer)
		return true
	end
end

AddEventHandler('esx:playerLoaded', function(playerId)
	CreateThread(function()
		Wait(2000)
		
		local xPlayer = ESX.GetPlayerFromId(playerId)
		if not xPlayer then
			return
		end

		if not Config[xPlayer.job.name] then
			return
		end

		local item = xPlayer.getInventoryItem('gps')
		if item and item.count >= 1 then
			gpsEnabled[playerId] = true
			addBlip(playerId, xPlayer)
		end
	end)
end)

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if not xPlayer then
		return
	end

	local hasNewJob = Config[job.name]
	local hadOldJob = Config[lastJob.name]

	if hasNewJob and not hadOldJob then
		local item = xPlayer.getInventoryItem('gps')
		if item and item.count >= 1 then
			if not gpsEnabled[playerId] then
				gpsEnabled[playerId] = true
			end
			addBlip(playerId, xPlayer)
		end
	elseif not hasNewJob and hadOldJob then
		local item = xPlayer.getInventoryItem('gps')
		if item and item.name == 'gps' then
			removeBlip(playerId)
		end
	elseif hasNewJob and hadOldJob then
		local item = xPlayer.getInventoryItem('gps')
		if item and item.count >= 1 then
			if not gpsEnabled[playerId] then
				gpsEnabled[playerId] = true
			end
			addBlip(playerId, xPlayer)
		end
	end
end)

RegisterNetEvent('esx_multijob/switchJob')
AddEventHandler('esx_multijob/switchJob', function(job)
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if not xPlayer then
		return
	end

	if not job or not job.name then
		return
	end

	local lastJob = xPlayer.job
	local lastJobName = lastJob and lastJob.name or 'unknown'
	local hasNewJob = Config[job.name]
	local hadOldJob = lastJob and Config[lastJobName] or false

	if hasNewJob and not hadOldJob then
		local item = xPlayer.getInventoryItem('gps')
		if item and item.count >= 1 then
			if not gpsEnabled[playerId] then
				gpsEnabled[playerId] = true
			end
			addBlip(playerId, xPlayer)
		end
	elseif not hasNewJob and hadOldJob then
		local item = xPlayer.getInventoryItem('gps')
		if item and item.name == 'gps' then
			removeBlip(playerId)
		end
	elseif hasNewJob and hadOldJob then
		local item = xPlayer.getInventoryItem('gps')
		if item and item.count >= 1 then
			if not gpsEnabled[playerId] then
				gpsEnabled[playerId] = true
			end
			refreshBlipData(playerId, xPlayer)
			updateBlipsForAllPlayers()
		end
	end
end)

RegisterServerEvent('esx:onAddInventoryItem')
AddEventHandler('esx:onAddInventoryItem', function(playerId, item, count)
	if item == 'gps' and count[item] >= 1 then
		if not blips[playerId] then
			local xPlayer = ESX.GetPlayerFromId(playerId)
			if xPlayer and Config[xPlayer.job.name] then
				if not gpsEnabled[playerId] then
					gpsEnabled[playerId] = true
				end
				addBlip(playerId, xPlayer)
			end
		end
	end
end)

RegisterServerEvent('esx:onRemoveInventoryItem')
AddEventHandler('esx:onRemoveInventoryItem', function(playerId, item, count)
	if item == 'gps' then
		removeBlip(playerId)
		gpsEnabled[playerId] = nil
	end
end)

ESX.RegisterUsableItem('gps', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		return
	end

	local item = xPlayer.getInventoryItem('gps')
	if not item or item.count < 1 then
		return
	end

	if not Config[xPlayer.job.name] then
		return
	end

	local isEnabled = toggleGPS(source)
	if isEnabled then
		xPlayer.showNotification('GPS włączony', 'success')
	else
		xPlayer.showNotification('GPS wyłączony', 'error')
	end
end)

AddEventHandler('playerDropped', function(reason)
	local playerId = source
	removeBlip(playerId)
	gpsEnabled[playerId] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then
		return
	end

	Wait(1000)

	local players = ESX.GetExtendedPlayers()

	for _, xPlayer in pairs(players) do
		local playerId = xPlayer.source
		if Config[xPlayer.job.name] then
			local item = xPlayer.getInventoryItem('gps')
			if item and item.count >= 1 then
				if not blips[playerId] then
					if not gpsEnabled[playerId] then
						gpsEnabled[playerId] = true
					end
					addBlip(playerId, xPlayer)
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		local playerList = {}
		for playerId, data in pairs(blips) do
			local playerPed = GetPlayerPed(playerId)
			if playerPed then
				data.coords = GetEntityCoords(playerPed)
				data.heading = GetEntityHeading(playerPed)
				data.vehicle = GetVehiclePedIsIn(playerPed, false)
				data.inHeli = GetVehicleType(data.vehicle) == 'heli'
				data.siren = IsVehicleSirenOn(data.vehicle)
				playerList[#playerList + 1] = playerId
			end
		end

		lib.triggerClientEvent('esx_localizations:updateBlip', playerList, blips)

		local trackerBlips = {}
		for plate, trackerData in pairs(vehicleTrackers) do
			local vehicle = NetworkGetEntityFromNetworkId(trackerData.netId)
			if vehicle and DoesEntityExist(vehicle) then
				local coords = GetEntityCoords(vehicle)
				local heading = GetEntityHeading(vehicle)
				vehicleTrackers[plate].lastCoords = coords
				trackerBlips[plate] = {
					plate = plate,
					coords = coords,
					heading = heading,
					vehicle = vehicle,
				}
			else
				if trackerData.lastCoords then
					trackerBlips[plate] = {
						plate = plate,
						coords = trackerData.lastCoords,
						heading = 0.0,
						vehicle = 0,
					}
				else
					vehicleTrackers[plate] = nil
				end
			end
		end

		lib.triggerClientEvent('esx_localizations:updateVehicleTrackers', playerList, trackerBlips)

		Wait(5000)
	end
end)

ESX.RegisterUsableItem(gpsConfig.item, function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not lib.table.contains(gpsConfig.jobs, xPlayer.job.name) then return end

    local ped = GetPlayerPed(src)
    local playerVehicle = GetVehiclePedIsIn(ped, false)
    if playerVehicle and playerVehicle ~= 0 then
        xPlayer.showNotification("~r~Musisz być poza pojazdem, aby zainstalować nadajnik!")
        return
    end

    local vehicle  = lib.getClosestVehicle(GetEntityCoords(ped), 5)
    if not vehicle or not DoesEntityExist(vehicle) then
        xPlayer.showNotification("~r~Brak pojazdu w pobliżu!")
        return
    end

    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
    if vehicleTrackers[plate] then
        xPlayer.showNotification("~r~Ten pojazd ma już nadajnik!")
        return
    end
	TriggerClientEvent('esx_localizations:startAnimation', src, plate, NetworkGetNetworkIdFromEntity(vehicle))
end)

RegisterNetEvent('esx_localizations:giveGPS', function(plate, netId)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	
	if not lib.table.contains(gpsConfig.jobs, xPlayer.job.name) then
		return
	end

	local ped = GetPlayerPed(src)
	local playerVehicle = GetVehiclePedIsIn(ped, false)
	if playerVehicle and playerVehicle ~= 0 then
		xPlayer.showNotification("~r~Musisz być poza pojazdem, aby zainstalować nadajnik!")
		return
	end

	if xPlayer.getInventoryItem(gpsConfig.item).count < 1 then
		xPlayer.showNotification("~r~Nie masz nadajnika w ekwipunku!")
		return
	end

	local vehicle = NetworkGetEntityFromNetworkId(netId)
	local initialCoords = vehicle and DoesEntityExist(vehicle) and GetEntityCoords(vehicle) or nil
	
	vehicleTrackers[plate] = { 
		netId = netId, 
		time = os.time(),
		lastCoords = initialCoords
	}
	xPlayer.removeInventoryItem(gpsConfig.item, 1)
	xPlayer.showNotification("~g~Nadajnik założony!")
end)

local function notifyTrackerExpired(plate, lastCoords)
	if not lastCoords then
		return
	end
	
	local players = ESX.GetExtendedPlayers()
	for _, xPlayer in pairs(players) do
		if lib.table.contains(gpsConfig.jobs, xPlayer.job.name) then
			TriggerClientEvent('esx_localizations:removedGPS', xPlayer.source, {
				coords = lastCoords,
				name = plate
			})
		end
	end
end

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for plate, data in pairs(vehicleTrackers) do
            if now - data.time >= (gpsConfig.duration / 1000) then
				if data.lastCoords then
					notifyTrackerExpired(plate, data.lastCoords)
				end
                vehicleTrackers[plate] = nil
            end
        end
    end
end)