local esx_core = exports.esx_core
local esx_hud = exports.esx_hud

local queue = {}
local queueLock = false

local function lockQueue()
	local timeout = 0
	while queueLock do
		Citizen.Wait(10)
		timeout = timeout + 10
		if timeout > 5000 then
			print('[esx_tracker] WARNING: lockQueue timeout after 5 seconds, forcing unlock')
			queueLock = false
			break
		end
	end
	queueLock = true
end

local function unlockQueue()
	queueLock = false
end

local function sortQueue()
	table.sort(queue, function(a, b)
		return a.position < b.position
	end)
end

local function updateQueuePositions(alreadyLocked)
	if not alreadyLocked then
		lockQueue()
	end
	for i, v in ipairs(queue) do
		v.position = i
	end
	sortQueue()
	if not alreadyLocked then
		unlockQueue()
	end
end

local function notifyPlayerByLicense(license, callback)
	local xPlayer = ESX.GetPlayerFromIdentifier(license)
	if xPlayer then
		callback(xPlayer)
	end
end

local function removeFromQueue(playerId, license)
	lockQueue()

	local identifier = nil

	if playerId then
		local xPlayer = ESX.GetPlayerFromId(playerId)
		if xPlayer then
			identifier = xPlayer.identifier
		end
	elseif license then
		identifier = license
	end

	if not identifier then
		unlockQueue()
		return
	end

	for i = #queue, 1, -1 do
		local v = queue[i]
		if v.license == identifier then
			table.remove(queue, i)
			notifyPlayerByLicense(v.license, function(xPlayer)
				if v.status == 'waiting' then
					xPlayer.showNotification('Zostałeś usunięty z kolejki!')
				end
			end)
			break
		end
	end

	updateQueuePositions(true)

	for _, v in ipairs(queue) do
		if v.status == 'waiting' and v.position == 1 then
			v.status = 'working'
			notifyPlayerByLicense(v.license, function(xPlayer)
				TriggerEvent('esx_tracker/server/startMission', xPlayer.source)
				xPlayer.showNotification('Zostałeś przydzielony do zlecenia!')
			end)
			break
		end
	end

	unlockQueue()
end

local function startWorkingTimeout(playerId, license)
	local totalTime = 40 * 60 * 1000
	local elapsed = 0

	while elapsed < totalTime do
		Citizen.Wait(60000)
		elapsed = elapsed + 60000

		local remainingMinutes = math.ceil((totalTime - elapsed) / 60000)
		local xPlayer = ESX.GetPlayerFromIdentifier(license)

		if not xPlayer then
			removeFromQueue(playerId, license)
			return
		end

		local playerState = Player(playerId)
		if not playerState or not playerState.state.usingTracker then
			removeFromQueue(playerId, license)
			return
		end

		if remainingMinutes > 0 then
			xPlayer.showNotification('Pozostało ' .. remainingMinutes .. ' minut do usunięcia z kolejki i anulowania zlecenia')
		else
			xPlayer.showNotification('Minęło 40 minut, usunięto z kolejki i anulowano zlecenie!')
			removeFromQueue(playerId, license)
			return
		end
	end
end

local function sendQueuePositionUpdate(v, newPos)
	notifyPlayerByLicense(v.license, function(xPlayer)
		xPlayer.showNotification('Według moich informacji twoja pozycja w kolejce uległa zmianie, od teraz jesteś na pozycji ' .. newPos)
	end)
end

RegisterServerEvent('esx_tracker/server/joinQueue', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local isVIP = ESX.AddonPlayerDiscordRoles(src, 'VIP') or ESX.AddonPlayerDiscordRoles(src, 'SVIP') or ESX.AddonPlayerDiscordRoles(src, 'ELITE')

	lockQueue()

	for _, v in ipairs(queue) do
		if v.license == xPlayer.identifier then
			unlockQueue()
			xPlayer.showNotification('Znajdujesz się już w kolejce a twoja pozycja to [' .. v.position .. ']!')
			return
		end
	end

	local newPosition = #queue + 1

	if #queue >= Config.MaxWorkingPositions then
		local vipPosition = Config.MaxWorkingPositions
		local vipCount = 0

		for _, v in ipairs(queue) do
			if v.vip then vipCount = vipCount + 1 end
		end

		if vipCount > 0 then
			vipPosition = vipPosition + vipCount
		end

		if isVIP then
			newPosition = vipPosition
			for _, v in ipairs(queue) do
				if v.vip and v.position >= vipPosition then
					local oldPos = v.position
					v.position = v.position + 1
					if v.position > oldPos then
						sendQueuePositionUpdate(v, v.position)
					end
				end
			end
		end

		for _, v in ipairs(queue) do
			if not v.vip and v.status == 'waiting' and v.position >= newPosition then
				local oldPos = v.position
				v.position = v.position + 1
				if v.position > oldPos then
					sendQueuePositionUpdate(v, v.position)
				end
			end
		end
	end

	table.insert(queue, {source = src, license = xPlayer.identifier, position = newPosition, status = 'waiting', vip = isVIP})

	for i, v in ipairs(queue) do
		if v.license == xPlayer.identifier then
			if v.position <= Config.MaxWorkingPositions then
				v.status = 'working'
				TriggerEvent('esx_tracker/server/startMission', src)
				xPlayer.showNotification('Dołączono do kolejki, ale z powodu wolnego miejsca otrzymano zlecenie')
				Citizen.CreateThread(function()
					startWorkingTimeout(src, xPlayer.identifier)
				end)
			else
				xPlayer.showNotification('Dołączono do kolejki, aktualnie zajmujesz miejsce ' .. v.position)
			end
			break
		end
	end

	updateQueuePositions(true)
	unlockQueue()
end)

RegisterServerEvent('esx_tracker/server/removeQueue', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	removeFromQueue(src)

	local playerState = Player(src)
	if playerState then
		playerState.state.usingTracker = false
	end
end)

lib.callback.register('esx_tracker/server/getPlayerQueue', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then return end

	local position = 0
	local totalPlayers = #queue

	for _, v in ipairs(queue) do
		if v.license == xPlayer.identifier then
			position = v.position
			break
		end
	end

	return position, totalPlayers
end)

AddEventHandler('playerDropped', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	for i = #queue, 1, -1 do
		local v = queue[i]
		if v.license == xPlayer.identifier then
			if v.status == 'working' then
				local players = esx_hud:Players()
				for _, playerData in pairs(players) do
					if playerData.job == 'police' or playerData.job == 'sheriff' then
						TriggerClientEvent('esx_tracker/client/removeCopBlip', playerData.id)
					end
				end
			end
			removeFromQueue(src, xPlayer.identifier)
			break
		end
	end
end)

RegisterServerEvent('esx_tracker/server/startMission', function(src)
	local src = src or source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT `missionTier` FROM `esx_tracker` WHERE `identifier` = ?', {xPlayer.identifier})

	if not result then
		MySQL.insert.await('INSERT INTO `esx_tracker` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 0, 1})
		result = {missionTier = 1}
	elseif not result.missionTier then
		return
	end

	local playerState = Player(src)
	if playerState then
		playerState.state.usingTracker = true
	end

	TriggerClientEvent("esx_tracker/client/startMission", src, result.missionTier or 1)
end)

lib.callback.register('esx_tracker/server/getFreeRobSpot', function(source, vehicleClass)
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then return nil, nil end

	vehicleClass = vehicleClass or 'C'
	local coordsForClass = Config.SpawnLocations[vehicleClass]
	if not coordsForClass then
		coordsForClass = Config.SpawnLocations['C']
	end

	local freeSpots = {}
	for idx, spot in pairs(coordsForClass) do
		if not spot.locked then
			table.insert(freeSpots, {index = idx, coords = spot.coords, class = vehicleClass})
		end
	end

	if #freeSpots > 0 then
		local pick = freeSpots[math.random(#freeSpots)]
		coordsForClass[pick.index].locked = true
		return {coords = pick.coords}, pick.index
	else
		local fallback = coordsForClass[1]
		if fallback then
			fallback.locked = true
			return {coords = fallback.coords}, 1
		end
	end

	return nil, nil
end)

RegisterServerEvent('esx_tracker/server/releaseRobSpot', function(mission)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local vehicleClass = mission.vehicleClass or 'C'
	local missionNumber = mission.number or 1

	if Config.SpawnLocations[vehicleClass] and Config.SpawnLocations[vehicleClass][missionNumber] and Config.SpawnLocations[vehicleClass][missionNumber].locked then
		Config.SpawnLocations[vehicleClass][missionNumber].locked = false
	end

	removeFromQueue(src)

	local playerState = Player(src)
	if playerState then
		playerState.state.usingTracker = false
	end
end)

function getSpecialisation(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then
		return 0, 0, 0, 0
	end

	local result = MySQL.single.await('SELECT `missionsCompleted`, `missionTier` FROM `esx_tracker` WHERE `identifier` = ?', {xPlayer.identifier})

	if not result then
		MySQL.insert.await('INSERT INTO `esx_tracker` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 0, 1})
		result = {missionsCompleted = 0, missionTier = 1}
	elseif not result.missionsCompleted or not result.missionTier then
		return 0, 0, 0, 0
	end

	local missionsCompleted = result.missionsCompleted
	local missionTier = result.missionTier
	local requiredCount = 0
	local maxCount = 250

	if missionsCompleted < 50 then
		requiredCount = 50
	elseif missionsCompleted < 150 then
		requiredCount = 150
	else
		requiredCount = 250
	end

	return missionsCompleted, requiredCount, missionTier, maxCount
end

lib.callback.register('esx_tracker/server/getSpecialisation', function(source)
	return getSpecialisation(source)
end)

exports("getSpecialisation", getSpecialisation)

RegisterServerEvent('esx_tracker/server/upgradeLevel', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT `missionsCompleted`, `missionTier` FROM `esx_tracker` WHERE `identifier` = ?', {xPlayer.identifier})

	if not result then
		MySQL.insert.await('INSERT INTO `esx_tracker` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 0, 1})
		result = {missionsCompleted = 0, missionTier = 1}
	elseif not result.missionsCompleted or not result.missionTier then
		return
	end

	local missionsCompleted = result.missionsCompleted
	local missionTier = result.missionTier
	local requiredCount = 0

	if missionsCompleted < 50 then
		requiredCount = 50
	elseif missionsCompleted < 150 then
		requiredCount = 150
	else
		requiredCount = 250
	end

	if missionsCompleted >= requiredCount and missionTier < 3 then
		local newTier = missionTier + 1
		MySQL.update.await('UPDATE `esx_tracker` SET `missionTier` = ? WHERE `identifier` = ?', {newTier, xPlayer.identifier})
		xPlayer.showNotification('Zwiększono poziom specjalizacji od teraz wynosi on [' .. newTier .. ']')
	end
end)

RegisterServerEvent('esx_tracker/server/finishMission', function(mission)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then
		return
	end

	local missionTier = mission and mission.tier or 1
	local missionNumber = mission and mission.number or 1
	local vehicleClass = mission and mission.vehicleClass or 'C'

	local playerState = Player(src)

	if not playerState then
		return
	end

	if not playerState.state.usingTracker then
		return
	end

	removeFromQueue(src)

	if Config.SpawnLocations[vehicleClass] and Config.SpawnLocations[vehicleClass][missionNumber] and Config.SpawnLocations[vehicleClass][missionNumber].locked then
		Config.SpawnLocations[vehicleClass][missionNumber].locked = false
	end

	playerState.state.usingTracker = false

	local result = MySQL.single.await('SELECT `missionsCompleted`, `missionTier` FROM `esx_tracker` WHERE `identifier` = ?', {xPlayer.identifier})

	local missionsCompleted = 0
	local missionTier = 1
	if result and result.missionsCompleted then
		missionsCompleted = result.missionsCompleted
		missionTier = result.missionTier or 1
		missionsCompleted = missionsCompleted + 1
		MySQL.update.await('UPDATE `esx_tracker` SET `missionsCompleted` = ? WHERE `identifier` = ?', {missionsCompleted, xPlayer.identifier})
	else
		MySQL.insert.await('INSERT INTO `esx_tracker` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 1, missionTier})
		missionsCompleted = 1
	end

	local requiredCount = 250
	if missionsCompleted < 50 then
		requiredCount = 50
	elseif missionsCompleted < 150 then
		requiredCount = 150
	end

	if missionsCompleted >= requiredCount and missionTier < 3 then
		local newTier = missionTier + 1
		MySQL.update.await('UPDATE `esx_tracker` SET `missionTier` = ? WHERE `identifier` = ?', {newTier, xPlayer.identifier})
		xPlayer.showNotification('Zwiększono poziom specjalizacji od teraz wynosi on [' .. newTier .. ']')
	end

	local rewardConfig = Config.Rewards[vehicleClass] or Config.Rewards['C']
	if not rewardConfig then
		rewardConfig = Config.Rewards['C']
	end

	local getMoney = math.random(rewardConfig.min, rewardConfig.max)

	esx_core:SendLog(src, "Tracker", "Otrzymał za wykonanie misji Trackera (klasa " .. vehicleClass .. ") brudną gotówkę w ilości `" .. getMoney .. "$\nSkrypt wykonujący: `" .. GetCurrentResourceName() .. "`", "tracker")

	local success, err = pcall(function()
		xPlayer.addAccountMoney('black_money', getMoney)
	end)

	if not success then
		local success2, err2 = pcall(function()
			xPlayer.addMoney(getMoney)
		end)
	end

	xPlayer.showNotification('Otrzymałeś ' .. getMoney .. '$ brudnej gotówki za wykonanie zlecenia!')
end)

RegisterServerEvent('esx_tracker/server/startAlertCops', function(coords)
	local Players = esx_hud:Players()

	for _, v in pairs(Players) do
		if v.job == 'police' or v.job == 'sheriff' then
			TriggerClientEvent('esx_tracker/client/setCopBlip', v.id, coords)
		end
	end
end)

RegisterServerEvent('esx_tracker/server/stopAlertCops', function()
	local Players = esx_hud:Players()

	for _, v in pairs(Players) do
		if v.job == 'police' or v.job == 'sheriff' then
			TriggerClientEvent('esx_tracker/client/removeCopBlip', v.id)
		end
	end
end)
