Games = {}
Players = {}
Invites = {}
RoutingBuckets = {}
ESX = exports["es_extended"]:getSharedObject()

--[[ Game ]]--
GetGame = function(gameId)
	if Games[gameId] and Games[gameId] ~= 0 then
		return Games[gameId]
	end

	return nil
end
HostGame = function(arenaId, teamSize)
	if not arenaId then
		arenaId = math.random(1, #Config.Arenas)
	end

	if not Config.Arenas[arenaId] then
		return false
	end

	local routingBucket = GetFreeRoutingBucket()
	if not routingBucket then
		return false
	end

	local gameId = #Games + 1
	if GetGame(gameId) then
		return false
	end

	Games[gameId] = New_Game(gameId, routingBucket, arenaId, 3, Config.Arenas[arenaId].weapons)

	for i = 1, teamSize or 2 do
		Games[gameId].addTeam()
	end

	Games[gameId].hostTimeout()

	return Games[gameId]
end

StopGame = function(gameId, endflow)
	local game = GetGame(gameId)
	if not game then
		return false
	end

	if endflow then
		game.syncAll("endflow", {
			players = game.getPlayers(),
			teams = game.getTeams(),
			arena = game.getArena()
		})
	end

	game.syncAll("gameStats", game.kills)

	for playerId in pairs(game.getPlayers()) do
		game.removePlayer(playerId)
	end

	SetRoutingBucketAsFree(game.bucket)
	Games[gameId] = 0

	return true
end


--[[ Arenas ]]--
ExitArena = function(playerId, notification, kicked, hex)
	if not Players[playerId] then
		return
	end

	local game = GetGame(Players[playerId])
	if not game then
		return
	end

	game.removePlayer(playerId)

	if notification then
		local message = kicked and ("%s został wyrzucony z areny."):format(GetPlayerName(playerId)) or ("%s opuścił arenę."):format(GetPlayerName(playerId))
		game.syncAll("notification", message)
	end

	if hex then
		Wait(5000)
		MySQL.Sync.execute('UPDATE users SET position = @position WHERE identifier = @identifier', {
			['@identifier'] = hex,
			['@position'] = '{"z":30.1,"y":-2031.3,"x":-281.6}'
		})
	end
end

--[[ Routing buckets ]]--
GetFreeRoutingBucket = function()
	for i = 15000, Config.MaxSessions do
		if not RoutingBuckets[i] then
			RoutingBuckets[i] = true
			return i
		end
	end
	return nil
end
SetRoutingBucketAsFree = function(routingBucket)
	if RoutingBuckets[routingBucket] then
		RoutingBuckets[routingBucket] = nil
	end
end

--[[ Events ]]--
RegisterServerEvent("arenas:sv:requestGame")
AddEventHandler("arenas:sv:requestGame", function(arenaId)
	if not Players[source] then
		local game = HostGame(tonumber(arenaId))

		if game then
			game.addPlayer(source)
		else
			TriggerClientEvent("esx:showNotification", source, "Wystąpił błąd podczas hostowania sesji, prawodopodobnie wszystkie dostępne sesje są zajęte.")
		end
	end
end)

RegisterServerEvent("arenas:sv:setArena")
AddEventHandler("arenas:sv:setArena", function(arenaId)
	if arenaId and Config.Arenas[arenaId] then
		if Players[source] then
			local game = GetGame(Players[source])

			if game and game.isHost(source) and not game.isStarted() then
				if game.getArena() ~= arenaId then
					game.setArena(arenaId)
				end
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:setRounds")
AddEventHandler("arenas:sv:setRounds", function(rounds)
	if rounds and rounds > 0 and rounds <= Config.MaxRounds then
		if Players[source] then
			local game = GetGame(Players[source])

			if game and game.isHost(source) and not game.isStarted() then
				if game.getRounds() ~= rounds then
					game.setRounds(rounds)
				end
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:setWeapon")
AddEventHandler("arenas:sv:setWeapon", function(weapon, allow)
	if Players[source] then
		local game = GetGame(Players[source])

		if game and game.isHost(source) and not game.isStarted() then
			if allow then
				game.addWeapon(weapon)
			else
				game.removeWeapon(weapon)
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:invite")
AddEventHandler("arenas:sv:invite", function(id, team)
	if Players[source] then
		if not Players[id] then
			if GetPlayerPing(id) > 0 then
				New_Invite(source, id, function(src, trg)
					local game = GetGame(Players[src])

					if game and game.isHost(src) and not game.isStarted() then
						if game.addPlayer(trg, team) then
							TriggerClientEvent("esx:showNotification", src, ("[%s] %s przyjął zaproszenie."):format(trg, ESX.GetPlayerFromId(trg).getName()))
						end
					else
						TriggerClientEvent("esx:showNotification", id, "Wystąpił błąd podczas przetwarzania zaproszenia.")
					end
				end, function(src, trg, timeout)
					if timeout then
						TriggerClientEvent("esx:showNotification", src, ("[%s] %s przekroczył limit czasu na odpowiedź."):format(trg, ESX.GetPlayerFromId(trg).getName()))
					else
						TriggerClientEvent("esx:showNotification", src, ("[%s] %s odrzucił zaproszenie."):format(trg, ESX.GetPlayerFromId(trg).getName()))
					end
				end)
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:team")
AddEventHandler("arenas:sv:team", function(id, team)
	if Players[source] then
		if Players[id] then
			local game = GetGame(Players[source])

			if game and game.isHost(source) and not game.isStarted() then
				if game.getPlayer(id) then
					game.setPlayerTeam(id, team)
				end
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:kick")
AddEventHandler("arenas:sv:kick", function(id)
	if Players[source] then
		if Players[id] then
			local game = GetGame(Players[source])

			if game and game.isHost(source) and not game.isStarted() then
				if game.getPlayer(id) then
					if not game.isHost(id) then
						ExitArena(id, true, true)
					else
						TriggerClientEvent("esx:showNotification", source, "Nie możesz siebie wyrzucić?")
					end
				end
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:start")
AddEventHandler("arenas:sv:start", function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if Players[source] then
		local game = GetGame(Players[source])
		if xPlayer.getAccount('bank').money < (game.getRounds()*500) then
			TriggerClientEvent("esx:showNotification", source, "Nie stać Cię na uruchomienie gry.")
			return
		end
		if game and game.isHost(source) and not game.isStarted() then
			if not game.start() then
				TriggerClientEvent("esx:showNotification", source, "Nie możesz uruchomić sesji gdy drużyny są puste.")
			else
				xPlayer.removeAccountMoney("bank", (game.getRounds()*500))
			end
		end
	end
end)

RegisterServerEvent("arenas:sv:ready")
AddEventHandler("arenas:sv:ready", function()
	if Players[source] then
		local game = GetGame(Players[source])

		if game and game.isStarted() then
			if game["onReady"] then
				game["onReady"](source)
			end
		end
	end
end)

RegisterServerEvent("esx:onPlayerDeath")
AddEventHandler("esx:onPlayerDeath", function(data)
	if Players[source] then
		local game = GetGame(Players[source])

		if game and game.isStarted() then
			if game["onPlayerDeath"] then
				game["onPlayerDeath"](source, data)
			end
		end
	end
end)

-- RegisterServerEvent('DiscordBot:plaZpD7H1J8iCMXJsprLG8TyerDied')
-- AddEventHandler('DiscordBot:plaZpD7H1J8iCMXJsprLG8TyerDied', function(Message, Weapon, killer, dist, headshot, bron)
-- 	if Players[source] then
-- 		local game = GetGame(Players[source])

-- 		if game and game.isStarted() then
-- 			if game["onPlayerDeath"] then
-- 				local data = {
-- 					killedByPlayer = killer ~= nil,
-- 					killerServerId = killer
-- 				}
-- 				game["onPlayerDeath"](source, data)
-- 			end
-- 		end
-- 	end
-- end)

RegisterServerEvent("arenas:sv:exit")
AddEventHandler("arenas:sv:exit", function()
	ExitArena(source, true)
end)

RegisterServerEvent("arenas:sv:invite2")
AddEventHandler("arenas:sv:invite2", function(src, trg, accepted)
	local invite = FindInvite(src, trg)

	if invite then
		if accepted then
			invite.accept()
		else
			invite.reject()
		end
	else
		TriggerClientEvent("esx:showNotification", source, "Wystąpił błąd podczas aktualizowania zaproszenia, zaproszenie mogło wygasnąć.")
	end
end)


AddEventHandler("onResourceStop", function(rsc)
	if GetCurrentResourceName() == rsc then
		for id, game in pairs(Games) do
			if game and game ~= 0 then
				StopGame(id)
			end
		end
	end
end)

AddEventHandler("playerDropped", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local identifier = xPlayer and xPlayer.identifier or nil
	ExitArena(source, true, nil, identifier)
end)

FindInvite = function(source, target)
	for index,invite in ipairs(Invites) do
		if (invite.src == source) and (invite.trg == target) then
			return invite, index
		end
	end

	return nil
end