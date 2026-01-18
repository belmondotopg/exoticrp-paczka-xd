local Player = Player
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local TriggerClientEvent = TriggerClientEvent

local playerRequestLimit = {} 
local limitRequest = 5000

local function canRequest(src)
    if playerRequestLimit[src] and (os.time() - playerRequestLimit[src]) < (limitRequest / 1000) then
        return false
    end
    playerRequestLimit[src] = os.time()
    return true
end

local animationCache = {}

local function saveAnimationsToCache(identifier, anims)
    animationCache[identifier] = anims
end

AddEventHandler('esx:playerLoaded', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer and animationCache[xPlayer.identifier] then 
		MySQL.Async.fetchAll('SELECT anims FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
			saveAnimationsToCache(xPlayer.identifier, result[1].anims or {})
		end)
	end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    Wait(5000)
    if xPlayer then
		local identifier = xPlayer.identifier
		MySQL.query.await('UPDATE users SET anims = ? WHERE identifier = ?', { animationCache[identifier], identifier})
		animationCache[identifier] = nil
    end
end)


RegisterServerEvent('esx_animations:save')
AddEventHandler('esx_animations:save', function(binds)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local animsData = json.encode(binds)
	if #animsData > 2000 then
		animsData = string.sub(animsData, 1, 2000)
	end

	saveAnimationsToCache(xPlayer.identifier, animsData)
end)

RegisterServerEvent('esx_animations:load')
AddEventHandler('esx_animations:load', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	if animationCache[xPlayer.identifier] then
		TriggerClientEvent('esx_animations:bind', src, json.decode(animationCache[xPlayer.identifier]))
	else
		MySQL.Async.fetchAll('SELECT anims FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
			if result and result[1] and result[1].anims then
				saveAnimationsToCache(xPlayer.identifier, result[1].anims)
				TriggerClientEvent('esx_animations:bind', src, json.decode(result[1].anims))
			else
				TriggerClientEvent('esx_animations:bind', src, {})
			end
		end)
	end
end)

RegisterServerEvent('esx_animations:syncAccepted')
AddEventHandler('esx_animations:syncAccepted', function(requester, id)
    local accepted = source

	if not canRequest(accepted) then return end

    TriggerClientEvent('esx_animations:playSynced', accepted, requester, id, 'Accepter')
    TriggerClientEvent('esx_animations:playSynced', requester, accepted, id, 'Requester')
end)

RegisterServerEvent('esx_animations:requestSynced')
AddEventHandler('esx_animations:requestSynced', function(target, id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer or target == -1 then return end

    TriggerClientEvent('esx_animations:syncRequest', target, src, id)
end)

RegisterServerEvent('esx_animations:OdpalAnimacje4')
AddEventHandler('esx_animations:OdpalAnimacje4', function(target)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local xTarget = ESX.GetPlayerFromId(target)

	if not xPlayer or not xTarget or target == -1 then return end

	if Player(xTarget.source).state.IsJailed > 0 or Player(xTarget.source).state.isCrawling then
		xPlayer.showNotification('Nie możesz podnieść teraz tej osoby!')
		return
	end

	xTarget.showNotification('Naciśnij [Y] aby zostać noszonym przez ['..xPlayer.source..']')
	xPlayer.showNotification('Oczekiwanie na akceptację przez obywatela ['..xTarget.source..']')
	TriggerClientEvent('esx_animations:przytulSynchroC2', xTarget.source, xPlayer.source)
end)

RegisterServerEvent('esx_animations:stop')
AddEventHandler('esx_animations:stop', function(target)
	local xTarget = ESX.GetPlayerFromId(target)

	if not xTarget or target == -1 then return end

	TriggerClientEvent('esx_animations:cl_stop', xTarget.source)
end)

RegisterServerEvent('esx_animations:sync')
AddEventHandler('esx_animations:sync', function(target, animationLib, animationLib2, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget, playerIndex)
    local src = source

	if target == -1 then return end

	if not canRequest(src) then return end

    TriggerClientEvent('esx_animations:syncTarget', targetSrc, src, animationLib2, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget)
    TriggerClientEvent('esx_animations:syncMe', src, animationLib, animation, length, controlFlagSrc, animFlagTarget)
end)

RegisterServerEvent('esx_animations:OdpalAnimacje5')
AddEventHandler('esx_animations:OdpalAnimacje5', function(target, playerIndex)
    local src = source
	local xTarget = ESX.GetPlayerFromId(target)

	if not xTarget or target == -1 then return end

	TriggerClientEvent('esx_animations:startMenu2', xTarget.source)
end)