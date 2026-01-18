local TriggerClientEvent = TriggerClientEvent
local ESX = ESX

local esx_core = exports.esx_core

RegisterCommand('heal', function(source, args)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if not xPlayer then
		return
	end
	
	if not ESX.IsPlayerAdmin(xPlayer.source) then
		xPlayer.showNotification('Nie posiadasz permisji')
		return
	end
	
	if args[1] then
		local target = tonumber(args[1])
		
		if not target then
			xPlayer.showNotification('Nieprawidłowe ID')
			return
		end
		
		if not GetPlayerName(target) then
			xPlayer.showNotification('Nie odnaleziono gracza')
			return
		end
		
		local xPlayer2 = ESX.GetPlayerFromId(target)
		
		if not xPlayer2 then
			xPlayer.showNotification('Nie odnaleziono gracza')
			return
		end
		
		TriggerClientEvent('esx_basicneeds:healPlayer', target)
		xPlayer2.showNotification('Zostałeś/aś uleczony/a przez administratora ' .. GetPlayerName(xPlayer.source) .. '!')
		xPlayer.showNotification('Uleczyłeś/aś gracza ' .. GetPlayerName(target) .. ' (ID: ' .. target .. ')')
		esx_core:SendLog(source, "Uleczenie gracza", "Użył komendy /heal na graczu: " .. target, "admin-heal")
	else
		TriggerClientEvent('esx_basicneeds:healPlayer', source)
		xPlayer.showNotification('Zostałeś/aś uleczony/a przez samego siebie!')
		esx_core:SendLog(source, "Uleczenie gracza", "Użył komendy /heal na samym sobie", "admin-heal")
	end
end, false)