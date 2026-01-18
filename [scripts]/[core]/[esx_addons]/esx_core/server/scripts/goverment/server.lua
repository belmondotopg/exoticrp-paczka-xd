local Player = Player

local MySQL = MySQL
local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local ESX = ESX

local esx_core = exports.esx_core

RegisterServerEvent('esx_core_contract:sellVehicle', function(target, plate, model, playerIndex)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local _target = target
	local tPlayer = ESX.GetPlayerFromId(_target)

	if Player(src).state.playerIndex then
		if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
			esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
			DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
			return
		else
			Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
		end
	end

	local result = MySQL.query.await('SELECT owner FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {['@identifier'] = xPlayer.identifier, ['@plate'] = plate})
	
	if src then
		if result[1] ~= nil then
			MySQL.update('UPDATE owned_vehicles SET owner = @target WHERE owner = @owner AND plate = @plate', {
				['@owner'] = xPlayer.identifier,
				['@plate'] = plate,
				['@target'] = tPlayer.identifier,
			}, function (rowsChanged)
				if rowsChanged ~= 0 then
					TriggerClientEvent('esx:showNotification', src, 'Sprzedałeś samochód o numerach: '..plate)
					TriggerClientEvent('esx:showNotification', _target, 'Kupiłeś samochód o numerach: '..plate)
					esx_core:SendLog(src, "Sprzedaż pojazdu", "Sprzedano pojazd:\nModel: " .. model .. "\nNr. rej: " .. plate .. "\nNowy właścicel: [" .. _target .. "] " .. GetPlayerName(_target), 'car-sell')
					xPlayer.removeInventoryItem('kontrakt', 1)
				end
			end)
		else
			TriggerClientEvent('esx:showNotification', src, 'To nie twój samochód')
		end
	end
end)

RegisterServerEvent('esx_core_contract:buyContract', function(playerIndex)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if Player(src).state.playerIndex then
		if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
			esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
			DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
			return
		else
			Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
		end
	end

	if xPlayer.getMoney() >= 15000 then
		xPlayer.removeMoney(15000)
		xPlayer.addInventoryItem('kontrakt', 1)
		TriggerEvent('esx_addonaccount:getSharedAccount', 'police', function(account)
			account.addMoney(7500)
		end)
	else
		xPlayer.showNotification("Nie masz wystarczająco pieniędzy!")
	end
end)

RegisterServerEvent('esx_core:alertBell', function ()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if not xPlayer then return end

	local esx_hud = exports.esx_hud
	local xPlayers = esx_hud:Players()

	xPlayer.showNotification('Wezwano funkcjonariusza na komisariat, oczekuj cierpliwie na pomoc!')

	for k,v in pairs(xPlayers) do
		if v.job == 'police' or v.job == 'sheriff' then
			TriggerClientEvent('qf_mdt/addDispatchAlert', v.id, GetEntityCoords(GetPlayerPed(xPlayer.source)), 'Wezwanie na komende!', 'Obywatel wzywa wolnego funkcjonariusza na komisariat Mission Row!', '10-33', 'rgb(49, 145, 105)', '10', 126, 3, 6)
		end
	end
end)