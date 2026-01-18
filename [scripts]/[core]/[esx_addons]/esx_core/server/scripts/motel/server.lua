local Player = Player

local RegisterServerEvent = RegisterServerEvent
local TriggerClientEvent = TriggerClientEvent
local MySQL = MySQL
local ESX = ESX

local ox_inventory = exports.ox_inventory
local Player = Player

local InMotelBucket = 0

lib.callback.register('esx_core:getMotelBuyed', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT identifier, id FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})
	
	if result ~= nil then
		if result.identifier and result.id then
			return true, result.id
		end
	else
		MySQL.update.await('INSERT INTO motels_owners (identifier) VALUES (?)', {xPlayer.identifier})

		Wait(500)

		local result = MySQL.single.await('SELECT id FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})

		if result ~= nil then
			if result.id then
				return true, result.id
			end
		end
	end

	return false, 0
end)

RegisterServerEvent('esx_core:initZones', function ()
	local src = source

	TriggerClientEvent('esx_core:initZones', src)
end)

RegisterServerEvent('esx_core:remZones', function ()
	local src = source

	TriggerClientEvent('esx_core:remZones', src)
end)

RegisterServerEvent('esx_core:getInToMotel', function (bucket)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	SetPlayerRoutingBucket(src, bucket)

	SetEntityCoords(GetPlayerPed(src), 151.3776, -1007.6270, -99.0001)
	SetEntityHeading(GetPlayerPed(src), 5.4080)

	InMotelBucket = bucket

	MySQL.update.await('UPDATE users SET InMotel = ?, InMotelBucket = ? WHERE identifier = ?', {1, InMotelBucket, xPlayer.identifier})

	Player(src).state:set('InMotel', true, true)

	TriggerClientEvent('esx_core:initZones', src)
end)

RegisterServerEvent('esx_core:exitFromMotel', function ()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	SetPlayerRoutingBucket(src, 0)

	SetEntityCoords(GetPlayerPed(src), -737.5176, -2276.4561, 13.4375)
	SetEntityHeading(GetPlayerPed(src), 138.2964)

	InMotelBucket = 0

	TriggerClientEvent('esx_core:remZones', src)

	MySQL.update.await('UPDATE users SET InMotel = ?, InMotelBucket = ? WHERE identifier = ?', {0, InMotelBucket, xPlayer.identifier})

	Player(src).state:set('InMotel', false, true)
end)

RegisterServerEvent('esx_core:inviteToMotel', function (invitedID)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	TriggerClientEvent('esx_core:inviteRequestToMotel', invitedID, xPlayer.getName(), src)
end)

RegisterServerEvent('esx_core:acceptedInvite', function (ownerId)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(ownerId)

	if not xPlayer then return end

	local resultBucket = MySQL.single.await('SELECT id FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})

	SetPlayerRoutingBucket(src, resultBucket.id)

	SetEntityCoords(GetPlayerPed(src), 151.3776, -1007.6270, -99.0001)
	SetEntityHeading(GetPlayerPed(src), 5.4080)

	InMotelBucket = resultBucket.id

	MySQL.update.await('UPDATE users SET InMotel = ?, InMotelBucket = ? WHERE identifier = ?', {1, InMotelBucket, xPlayer.identifier})

	Player(src).state:set('InMotel', true, true)

	TriggerClientEvent('esx_core:initZones', src, true)
end)

RegisterServerEvent('esx_core:createInventory', function ()
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT kg FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})

	local stash = {
		owner = xPlayer.identifier,
		id = 'hotel_'..xPlayer.identifier,
		label = 'Hotel',
		slots = 50,
		weight = result.kg * 1000,
	}

	ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner)
end)

AddEventHandler('playerDropped', function()
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	if Player(src).state.InMotel then
		MySQL.update.await('UPDATE users SET InMotel = ?, InMotelBucket = ? WHERE identifier = ?', {1, InMotelBucket, xPlayer.identifier})
		TriggerClientEvent('esx_core:remZones', src)
	else
		MySQL.update.await('UPDATE users SET InMotel = ?, InMotelBucket = ? WHERE identifier = ?', {0, 0, xPlayer.identifier})
	end
end)

RegisterServerEvent('esx_core:checkInMotel', function ()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT InMotel, InMotelBucket FROM users WHERE identifier = ?', {xPlayer.identifier})

	if result ~= nil then
		if result.InMotel == 1 then
			TriggerClientEvent('esx_core:remZones', src)

			local bucketResult = MySQL.single.await('SELECT id FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})

			if bucketResult ~= nil then
				if bucketResult.id == result.InMotelBucket then
					TriggerClientEvent('esx_core:initZones', src)
				else
					TriggerClientEvent('esx_core:initZones', src, true)
				end
			else
				TriggerClientEvent('esx_core:initZones', src, true)
			end

			SetPlayerRoutingBucket(src, result.InMotelBucket)
		else
			TriggerClientEvent('esx_core:remZones', src)
		end
	end
end)

local function GetPlayersNearCoords(coords, radius)
    local players = {}
    
    for _, player in pairs(ESX.GetExtendedPlayers()) do
        local playerCoords = GetEntityCoords(GetPlayerPed(player.source))
        local distance = #(coords - playerCoords)
        if distance <= radius then
            table.insert(players, {id = player.source, name = player.getName()})
        end
    end

    return players
end

local function getOutsidePlayers()
    return GetPlayersNearCoords(
        vector3(-737.5178, -2276.4575, 13.4302),
       20
    )
end

ESX.RegisterServerCallback('esx_core:getOutsidePlayers', function(source, cb)
	cb(getOutsidePlayers())
end)

ESX.RegisterServerCallback('esx_core:getStorageLevel', function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT kg FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})

	if result ~= nil then
		if result.kg then
			cb(result.kg)
		end
	end

	cb(0)
end)

RegisterServerEvent('esx_core:upgradeStorage', function (kilograms)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local result = MySQL.single.await('SELECT kg FROM motels_owners WHERE identifier = ?', {xPlayer.identifier})
	local maximumKilograms = 100

	if result ~= nil then
		if result.kg then
			if (result.kg + kilograms) <= maximumKilograms then
				local addValue = result.kg + kilograms

				MySQL.update.await('UPDATE motels_owners SET kg = ? WHERE identifier = ?', {addValue, xPlayer.identifier})

				local stash = {
					owner = xPlayer.identifier,
					id = 'hotel_'..xPlayer.identifier,
					label = 'Hotel',
					slots = 50,
					weight = addValue * 1000,
				}
			
				ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner)
			end
		end
	end
end)