local Player = Player
local MySQL = MySQL
local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local TriggerEvent = TriggerEvent
local ESX = ESX
local DropPlayer = DropPlayer
local ox_inventory = exports.ox_inventory
local esx_core = exports.esx_core
local esx_hud = exports.esx_hud
local GetEntityCoords = GetEntityCoords
local GetPlayerPed = GetPlayerPed
local GetPlayerName = GetPlayerName
local GetCurrentResourceName = GetCurrentResourceName
local os = os

local ReceivedTokens = {}
local Events = {
	HandcuffOnPlayer = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	Drag = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	Dragging = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	putInVehicle = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	OutVehicle = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	putTargetInTrunk = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	outTargetFromTrunk = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	onBuyAddons = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	requestarrest = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	request = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	panicrequest = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	shootingrequest = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	komunikat = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999),
	worek = GetCurrentResourceName()..ESX.GetRandomString(math.random(5, 20))..':'..math.random(100, 999)..'-'..math.random(100, 999)
}

RegisterServerEvent('esx_police:makeRequest')
AddEventHandler('esx_police:makeRequest', function()
	local src = source
	if not ReceivedTokens[src] then
		TriggerClientEvent("esx_police:getRequest", src, Events.HandcuffOnPlayer, Events.Drag, Events.Dragging, Events.putInVehicle, Events.OutVehicle, Events.putTargetInTrunk, Events.outTargetFromTrunk, Events.onBuyAddons, Events.requestarrest, Events.request, Events.panicrequest, Events.shootingrequest, Events.komunikat, Events.worek)
		ReceivedTokens[src] = true
	else
		esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
		DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
		return
	end
end)

AddEventHandler('playerDropped', function()
	ReceivedTokens[source] = nil
end)

local function validateTarget(src, target)
	if tonumber(target) == -1 then
		esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania `TriggerServerEvent` z użyciem `wszystkich graczy`!\nSkrypt `w którym wykryto` niepożądane działanie: `"..GetCurrentResourceName().."`", "ac")
		DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
		return false
	end
	return true
end

local function validatePlayers(src, target)
	if not (src > 0 and target > 0) then return false end
	local sourceXPlayer = ESX.GetPlayerFromId(src)
	local targetXPlayer = ESX.GetPlayerFromId(target)
	if not sourceXPlayer or not targetXPlayer then return false end
	return true, sourceXPlayer, targetXPlayer
end

local function validateDistance(src, target, maxDistance)
	maxDistance = maxDistance or 5.0
	local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(target)))
	return distance <= maxDistance
end

RegisterServerEvent(Events.HandcuffOnPlayer)
AddEventHandler(Events.HandcuffOnPlayer, function(target)
	local src = source
	if not validateTarget(src, target) then return end
	
	local valid, sourceXPlayer, targetXPlayer = validatePlayers(src, target)
	if not valid then return end
	
	if not validateDistance(src, target) then return end
	
	local handcuffCount = ox_inventory:Search(sourceXPlayer.source, 'count', 'handcuffs')
	if not handcuffCount or handcuffCount <= 0 then
		sourceXPlayer.showNotification("Nie posiadasz kajdanek w ekwipunku!")
		return
	end
	
	esx_core:SendLog(src, "Kajdanki", "Zakuto/rozkuto gracza o ID: [" .. target .. "] ", 'hancuffs-cuff')
	TriggerClientEvent('esx_police:HandcuffOnPlayer', target)
end)

RegisterServerEvent(Events.Drag)
AddEventHandler(Events.Drag, function(target)
	local src = source
	if not validateTarget(src, target) then return end
	
	local valid, sourceXPlayer, targetXPlayer = validatePlayers(src, target)
	if not valid then return end
	
	if not validateDistance(src, target) then return end
	
	local isDragging = not Player(src).state.IsDraggingSomeone
	Player(src).state:set('IsDraggingSomeone', isDragging, true)
	Player(src).state:set('DraggingId', isDragging and target or nil, true)
	Player(target).state:set('DraggingById', isDragging and src or nil, true)
	TriggerClientEvent('esx_police:drag', target, src)
	TriggerClientEvent('esx_police:dragging', src, target, not isDragging)
	esx_core:SendLog(src, "Kajdanki", "Przenoszenie gracza o ID: [" .. target .. "] ", 'hancuffs-drag')
end)

RegisterServerEvent(Events.Dragging)
AddEventHandler(Events.Dragging, function(target, cop)
	local src = source
	if not validateTarget(src, target) then return end
	
	if not (target > 0) then return end
	
	if not cop then
		Player(target).state:set('DraggingById', nil, true)
		TriggerClientEvent('esx_police:dragging', target, src, true)
	else
		TriggerClientEvent('esx_police:dragging', target, cop, false)
	end
end)

RegisterServerEvent(Events.worek)
AddEventHandler(Events.worek, function(serverId, apply)
	local src = source
	if not validateTarget(src, serverId) then return end
	
	local tPlayer = ESX.GetPlayerFromId(serverId)
	local xPlayer = ESX.GetPlayerFromId(src)
	if not tPlayer or not xPlayer then return end
	
	if not validateDistance(src, serverId) then return end
	
	local hasHeadbagAlready = Player(tPlayer.source).state.HasHeadbag
	local count = ox_inventory:Search(xPlayer.source, 'count', 'worek')
	if count and count <= 0 and not hasHeadbagAlready then return end
	
	local newState = not hasHeadbagAlready
	if hasHeadbagAlready then
		ox_inventory:AddItem(xPlayer.source, 'worek', 1)
		Player(tPlayer.source).state.HasHeadbag = false
	else
		ox_inventory:RemoveItem(xPlayer.source, 'worek', 1)
		Player(tPlayer.source).state.HasHeadbag = true
	end
	Wait(100)
	TriggerClientEvent("esx_police:refreshHeadbag", tPlayer.source, newState)
end)

RegisterServerEvent(Events.putInVehicle)
AddEventHandler(Events.putInVehicle, function(target, withBelt)
	local src = source
	if not validateTarget(src, target) then return end
	
	local valid, sourceXPlayer, targetXPlayer = validatePlayers(src, target)
	if not valid then return end
	
	if not validateDistance(src, target) then return end
	
	TriggerClientEvent('esx_police:putInVehicle', target)
	if withBelt then
		Wait(500)
		TriggerClientEvent('esx_core:esx_blackout:belt', target, true)
	end
end)

RegisterServerEvent(Events.OutVehicle)
AddEventHandler(Events.OutVehicle, function(target)
	local src = source
	if not validateTarget(src, target) then return end
	
	local valid, sourceXPlayer, targetXPlayer = validatePlayers(src, target)
	if not valid then return end
	
	if not validateDistance(src, target) then return end
	
	TriggerClientEvent('esx_police:OutVehicle', target)
	Wait(500)
	TriggerClientEvent('esx_core:esx_blackout:belt', target, false)
end)

RegisterServerEvent(Events.putTargetInTrunk)
AddEventHandler(Events.putTargetInTrunk, function(target, vehicleNetId)
	local src = source
	if not validateTarget(src, target) then return end
	
	local valid, sourceXPlayer, targetXPlayer = validatePlayers(src, target)
	if not valid then return end
	
	if not validateDistance(src, target) then return end
	
	if not vehicleNetId then return end
	
	TriggerClientEvent('esx_police:putInTrunk', target, vehicleNetId)
end)

RegisterServerEvent(Events.outTargetFromTrunk)
AddEventHandler(Events.outTargetFromTrunk, function(target)
	local src = source
	if not validateTarget(src, target) then return end
	
	local valid, sourceXPlayer, targetXPlayer = validatePlayers(src, target)
	if not valid then return end
	
	if not validateDistance(src, target) then return end
	
	TriggerClientEvent('esx_police:OutTrunk', target)
end)

RegisterNetEvent(Events.onBuyAddons)
AddEventHandler(Events.onBuyAddons, function(tablica, dodatek, state)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer then
		if state then
			xPlayer.showNotification('Zamontowano dodatek')
		else
			xPlayer.showNotification('Zdemontowano dodatek')
		end
	end
end)

RegisterNetEvent("esx_police:cuffLegs", function(serverId)
	local src = source
	local tPlayer = ESX.GetPlayerFromId(serverId)
	local xPlayer = ESX.GetPlayerFromId(src)
	if not tPlayer or not xPlayer then return end
	local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(tPlayer.source)))
	if distance > 5 then return end
	local hasLegsCuffed = Player(tPlayer.source).state.LegsCuffed
	local count = ox_inventory:Search(xPlayer.source, 'count', 'rope')
	if count and count <= 0 then return end
	if hasLegsCuffed then
		xPlayer.showNotification("Rozwiązano nogi "..tPlayer.getName())
		tPlayer.showNotification("Twoje nogi zostały rozwiązane przez "..xPlayer.getName())
		Player(tPlayer.source).state.LegsCuffed = false
	else
		xPlayer.showNotification("Związano nogi "..tPlayer.getName())
		tPlayer.showNotification("Twoje nogi zostały związane przez "..xPlayer.getName())
		Player(tPlayer.source).state.LegsCuffed = true
	end
end)

RegisterServerEvent(Events.requestarrest)
AddEventHandler(Events.requestarrest, function(targetid, playerheading, playerCoords, playerlocation)
	local src = source
	if targetid == -1 then
		esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania `TriggerServerEvent` z użyciem `wszystkich graczy`!\nSkrypt `w którym wykryto` niepożądane działanie: `"..GetCurrentResourceName().."`", "ac")
		DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
		return
	end
	if src and targetid then
		local distance = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(targetid)))
		if distance > 5 then return end
		TriggerClientEvent('esx_police:getarrested', targetid, playerheading, playerCoords, playerlocation)
		TriggerClientEvent('esx_police:doarrested', src)
	end
end)

RegisterServerEvent(Events.request)
AddEventHandler(Events.request, function(Officer, radioChannel, buttonType)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if xPlayer.job.name ~= 'police' and xPlayer.job.name ~= 'sheriff' and xPlayer.job.name ~= 'ambulance' and xPlayer.job.name ~= 'doj' then return end
	local jobTxt = ''
	if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
		jobTxt = 'Ranny funkcjonariusz'
	elseif xPlayer.job.name == 'ambulance' then
		jobTxt = 'Ranny medyk'
	elseif xPlayer.job.name == 'doj' then
		jobTxt = 'Ranny funkcjonariusz DOJ'
	else
		jobTxt = 'Ranny'
	end
	local text = "Obezwładniony funkcjonariusz użył dziwnego przycisku"
	local color = {r = 255, g = 0, b = 0, alpha = 255}
	local badge = xPlayer.badge
	local name = "[" .. badge .. "] " .. xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName')
	local GetPlayers = esx_hud:Players()
	local playerCoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
	TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
	for k, v in pairs(GetPlayers) do
		if v.job == 'police' or v.job == 'sheriff' or v.job == 'ambulance' or v.job == 'doj' then
			TriggerClientEvent("esx_police:get1013Alert", v.id, Officer, name, jobTxt, radioChannel)
			if v.job == 'police' then
				TriggerClientEvent('qf_mdt:addDispatchAlert', v.id, playerCoords, 'Panic-Button (10-13'..buttonType..')!', jobTxt .. ' udaj się jak najszybciej na jego lokalizacje!', '10-13'..buttonType, 'rgb(256, 202, 247)', '10', 58, 3, 6)
			elseif v.job == 'sheriff' then
				TriggerClientEvent('qf_mdt_sheriff:addDispatchAlert', v.id, playerCoords, 'Panic-Button (10-13'..buttonType..')!', jobTxt .. ' udaj się jak najszybciej na jego lokalizacje!', '10-13'..buttonType, 'rgb(256, 202, 247)', '10', 58, 3, 6)
			elseif v.job == 'ambulance' then
				TriggerClientEvent('qf_mdt_ems:addDispatchAlert', v.id, playerCoords, 'Panic-Button (10-13'..buttonType..')!', jobTxt .. ' udaj się jak najszybciej na jego lokalizacje!', '10-13'..buttonType, 'rgb(256, 202, 247)', '10', 58, 3, 6)
			end
		end
	end
end)

local lastsend = false

RegisterCommand('c0', function(source, args, rawCommand)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if lastsend then return end
	if xPlayer.getInventoryItem('panic').count >= 1 then
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
			xPlayer.removeInventoryItem('panic', 1)
			TriggerClientEvent('esx_police:getCoordsForShooting', source)
		else
			xPlayer.showNotification("Częstotliwość tego panic buttona została zablokowana!")
		end
		lastsend = true
		SetTimeout(5000, function()
			lastsend = false
		end)
	else
		xPlayer.showNotification("Nie posiadasz panic buttona!")
	end
end, false)

RegisterCommand('pb', function(source, args, rawCommand)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if lastsend then return end
	if xPlayer.getInventoryItem('panic').count >= 1 then
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
			xPlayer.removeInventoryItem('panic', 1)
			TriggerClientEvent('esx_police:getCoords', source)
		else
			xPlayer.showNotification("Częstotliwość tego panic buttona została zablokowana!")
		end
		lastsend = true
		SetTimeout(5000, function()
			lastsend = false
		end)
	else
		xPlayer.showNotification("Nie posiadasz panic buttona!")
	end
end, false)

RegisterCommand('bk', function(source, args, rawCommand)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if lastsend then return end
	if xPlayer.getInventoryItem('panic').count >= 1 then
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
			xPlayer.removeInventoryItem('panic', 1)
			TriggerClientEvent('esx_police:getCoords', source)
		else
			xPlayer.showNotification("Częstotliwość tego panic buttona została zablokowana!")
		end
		lastsend = true
		SetTimeout(5000, function()
			lastsend = false
		end)
	else
		xPlayer.showNotification("Nie posiadasz panic buttona!")
	end
end, false)

ESX.RegisterUsableItem('panic', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if lastsend then return end
	if xPlayer.getInventoryItem('panic').count >= 1 then
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
			xPlayer.removeInventoryItem('panic', 1)
			TriggerClientEvent('esx_police:getCoords', source)
		else
			xPlayer.showNotification("Częstotliwość tego panic buttona została zablokowana!")
		end
		lastsend = true
		SetTimeout(5000, function()
			lastsend = false
		end)
	else
		xPlayer.showNotification("Nie posiadasz panic buttona!")
	end
end)

RegisterServerEvent(Events.panicrequest)
AddEventHandler(Events.panicrequest, function(Officer)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	local text = "Funkcjonariusz użył dziwnego przycisku"
	local color = {r = 255, g = 202, b = 247, alpha = 255}
	local badgeData = xPlayer.get('badge')
	local badge = ""

	if badgeData then
		local success, decoded = pcall(json.decode, badgeData)
		
		if success and type(decoded) == "table" and decoded.id then
			badge = tostring(decoded.id)
		else
			badge = tostring(badgeData)
		end
	end

	local name = "[" .. badge .. "] " .. xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName')
	local GetPlayers = esx_hud:Players()
	local playerCoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
	TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
	for k, v in pairs(GetPlayers) do
		if v.job == 'police' or v.job == 'sheriff' or v.job == 'ambulance' or v.job == 'doj' then
			if v.job == 'police' or v.job == 'sheriff' or v.job == 'doj' then
				TriggerClientEvent("esx_police:TriggerPanicButton", v.id, Officer, name)
			end
			if v.job == 'police' then
				TriggerClientEvent('qf_mdt:addDispatchAlert', v.id, playerCoords, 'Panic-Button (CODE 0)!', 'Funkcjonariusz '..name..' użył Panic-Buttona koniecznie udaj się na jego lokalizację!', '10-84', 'rgb(49, 145, 105)', '10', 58, 3, 6)
			elseif v.job == 'sheriff' then
				TriggerClientEvent('qf_mdt_sheriff:addDispatchAlert', v.id, playerCoords, 'Panic-Button (CODE 0)!', 'Funkcjonariusz '..name..' użył Panic-Buttona koniecznie udaj się na jego lokalizację!', '10-84', 'rgb(49, 145, 105)', '10', 58, 3, 6)
			elseif v.job == 'ambulance' then
				TriggerClientEvent('qf_mdt_ems:addDispatchAlert', v.id, playerCoords, 'Panic-Button (CODE 0)!', 'Funkcjonariusz '..name..' użył Panic-Buttona koniecznie udaj się na jego lokalizację!', '10-84', 'rgb(49, 145, 105)', '10', 58, 3, 6)
			end
		end
	end
end)

RegisterServerEvent(Events.shootingrequest)
AddEventHandler(Events.shootingrequest, function(Officer)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	
	if type(Officer) == "string" and Officer == "Przeszukuje" then
		return
	end
	
	local text = "Strzelanina! Funkcjonariusz potrzebuje wsparcia!"
	local color = {r = 255, g = 0, b = 0, alpha = 255}
	local badgeData = xPlayer.get('badge')
	local badge = ""

	if badgeData then
		local success, decoded = pcall(json.decode, badgeData)
		
		if success and type(decoded) == "table" and decoded.id then
			badge = tostring(decoded.id)
		else
			badge = tostring(badgeData)
		end
	end

	local name = "[" .. badge .. "] " .. xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName')
	local GetPlayers = esx_hud:Players()
	local playerCoords = GetEntityCoords(GetPlayerPed(xPlayer.source))
	TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
	for k, v in pairs(GetPlayers) do
		if v.job == 'police' or v.job == 'sheriff' or v.job == 'ambulance' or v.job == 'doj' then
			if v.job == 'police' or v.job == 'sheriff' then
				if Officer and type(Officer) == "table" and Officer.Coords then
					TriggerClientEvent("esx_police:TriggerShootingAlert", v.id, Officer, name)
				else
					local fallbackOfficer = {
						Coords = playerCoords,
						Location = "Nieznana lokalizacja"
					}
					TriggerClientEvent("esx_police:TriggerShootingAlert", v.id, fallbackOfficer, name)
				end
			end
			if v.job == 'police' then
				TriggerClientEvent('qf_mdt:addDispatchAlert', v.id, playerCoords, 'Strzelanina (CODE 0)!', 'Funkcjonariusz '..name..' zgłasza strzelaninę! Koniecznie udaj się na jego lokalizację!', '10-13', 'rgb(255, 0, 0)', '10', 432, 3, 6)
			elseif v.job == 'sheriff' then
				TriggerClientEvent('qf_mdt_sheriff:addDispatchAlert', v.id, playerCoords, 'Strzelanina (CODE 0)!', 'Funkcjonariusz '..name..' zgłasza strzelaninę! Koniecznie udaj się na jego lokalizację!', '10-13', 'rgb(255, 0, 0)', '10', 432, 3, 6)
			elseif v.job == 'ambulance' then
				TriggerClientEvent('qf_mdt_ems:addDispatchAlert', v.id, playerCoords, 'Strzelanina (CODE 0)!', 'Funkcjonariusz '..name..' zgłasza strzelaninę! Koniecznie udaj się na jego lokalizację!', '10-13', 'rgb(255, 0, 0)', '10', 432, 3, 6)
			end
		end
	end
end)

local cached = {}

ESX.RegisterServerCallback('esx_police:getBadge', function(source, cb, sid)
	local xPlayer = ESX.GetPlayerFromId(sid)
	local name = sid

	if xPlayer and (xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'mechanik') then
		local badgeData = xPlayer.get('badge')
		local badge = ""

		if badgeData then
			local success, decoded = pcall(json.decode, badgeData)
			
			if success and type(decoded) == "table" and decoded.id then
				badge = tostring(decoded.id)
			else
				badge = tostring(badgeData)
			end
		end

		name = "["..badge.."] "..xPlayer.get('firstName').." "..xPlayer.get('lastName')
	end

	cb(name)
end)

ESX.RegisterServerCallback('skinchanger:getSkin', function(source, cb, sid)
	if sid then
		if cached[sid] then
			cb(cached[sid])
		else
			local xPlayer = ESX.GetPlayerFromId(sid)
			MySQL.query('SELECT skin FROM users WHERE identifier = ?', {xPlayer.identifier}, function(users)
				local user, skin = users[1]
				if user ~= nil then
					if user.skin then
						skin = json.decode(user.skin)
					end
					cb(skin)
				end
			end)	
		end
	else
		local xPlayer = ESX.GetPlayerFromId(source)
		
		MySQL.query('SELECT skin FROM users WHERE identifier = ?',  {xPlayer.identifier}, function(users)
			local user, skin = users[1]
			if user ~= nil then
				if user.skin then
					skin = json.decode(user.skin)
				end
				cb(skin)
			end
		end)	
	end
end)

AddEventHandler('playerDropped', function()
	if cached[source] then
		cached[source] = nil
	end
end)

local stashes = {
    {
		id = 'policemagazine1',
		label = '[LSPD/LSSD] Zbrojownia #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 1, ["sheriff"] = 1}
	},
	{
		id = 'policeschowek1',
		label = '[LSPD/LSSD] Schowek #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 0, ["sheriff"] = 0} -- Zmienione na 0, aby umożliwić wkładanie od rangi 0 (branie kontrolowane w ox_inventory)
	},
	{
		id = 'policemagazine2',
		label = '[LSPD/LSSD] Zbrojownia #2',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 1, ["sheriff"] = 1}
	},
	{
		id = 'policeschowek2',
		label = '[LSPD/LSSD] Schowek #2',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 0, ["sheriff"] = 0}
	},
	{
		id = 'policehc1',
		label = '[LSPD/LSSD] HC Zbrojownia #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 1, ["sheriff"] = 10}
	},
	{
		id = 'policeswat1',
		label = '[LSPD/LSSD] SWAT Zbrojownia #1',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 1, ["sheriff"] = 1}
	},
	{
		id = 'policehc2',
		label = '[LSPD/LSSD] HC Zbrojownia #2',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 1, ["sheriff"] = 10}
	},
	{
		id = 'policeswat2',
		label = '[LSPD/LSSD] SWAT Zbrojownia #2',
		slots = 350,
		weight = 500000,
		owner = false,
		groups = {["police"] = 1, ["sheriff"] = 1}
	},
}

AddEventHandler('onServerResourceStart', function(resourceName)
	if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
		for i = 1, #stashes do
			local stash = stashes[i]
			ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner, stash.groups)
		end
	end
end)

RegisterServerEvent(Events.komunikat)
AddEventHandler(Events.komunikat, function(text)
	local src = source
	local color = {r = 255, g = 202, b = 247, alpha = 255}
	TriggerClientEvent("esx_chat:sendAddonChatMessageMe", -1, src, src, text)
	TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
end)

RegisterServerEvent('esx_police:setPlayerLicense')
AddEventHandler('esx_police:setPlayerLicense', function(id)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromId(id)
	local playerName = GetPlayerName(id)
	if not xPlayer or not tPlayer then return end
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then return end
	if #(GetEntityCoords(GetPlayerPed(xPlayer.source)) - GetEntityCoords(GetPlayerPed(tPlayer.source))) > 5 then return end
	TriggerEvent('esx_license:addLicense', id, 'weapon')
	xPlayer.showNotification('Nadano licencję na broń obywatelowi [' ..tPlayer.getName().. ']')
	tPlayer.showNotification('Otrzymano licencję na broń od funkcjonariusza [' ..xPlayer.getName().. ']')
	esx_core:SendLog(src, "Licencje na broń", "Funkcjonariusz `nadał` licencję na broń dla: [" .. id .. "] " .. playerName, 'license-set')
end)

RegisterServerEvent('esx_police:takePlayerLicense')
AddEventHandler('esx_police:takePlayerLicense', function(id)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromId(id)
	local playerName = GetPlayerName(id)
	if not xPlayer or not tPlayer then return end
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then return end
	if #(GetEntityCoords(GetPlayerPed(xPlayer.source)) - GetEntityCoords(GetPlayerPed(tPlayer.source))) > 5 then return end
	TriggerEvent('esx_license:removeLicense', id, 'weapon')
	xPlayer.showNotification('Unieważniono licencję na broń obywatelowi [' ..tPlayer.getName().. ']')
	tPlayer.showNotification('Utracono licencję na broń przez funkcjonariusza [' ..xPlayer.getName().. ']')
	esx_core:SendLog(src, "Licencje na broń", "Funkcjonariusz `zabrał` licencję na broń dla: [" .. id .. "] " .. playerName, 'license-take')
end)

RegisterServerEvent('esx_police:checkPlayerLicense')
AddEventHandler('esx_police:checkPlayerLicense', function(id)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromId(id)
	local playerName = GetPlayerName(id)
	if not xPlayer or not tPlayer then return end
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then return end
	if #(GetEntityCoords(GetPlayerPed(xPlayer.source)) - GetEntityCoords(GetPlayerPed(tPlayer.source))) > 5 then return end
	local result = MySQL.single.await('SELECT type FROM user_licenses WHERE owner = ? AND type = ?', {tPlayer.identifier, 'weapon'})
	if result and result.type == 'weapon' then
		xPlayer.showNotification('Obywatel [' ..tPlayer.getName().. '] <b>posiada</b> licencję na broń!')
	else
		xPlayer.showNotification('Obywatel [' ..tPlayer.getName().. '] <b>nieposiada</b> licencji na broń!')
	end
	esx_core:SendLog(src, "Licencje na broń", "Funkcjonariusz `sprawdził posiadanie` licencji na broń dla: [" .. id .. "] " .. playerName, 'license-check')
end)

RegisterServerEvent('esx_police:sync:addTargets')
AddEventHandler('esx_police:sync:addTargets', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if xPlayer.job.name == "police" or xPlayer.job.name == "sheriff" then
		TriggerClientEvent('esx_police:sync:removeTargets', src)
		TriggerClientEvent('esx_police:sync:addTargetsCL', src)
	else
		TriggerClientEvent('esx_police:sync:removeTargets', src)
	end
end)
local RegisteredPoliceStashes = {}

RegisterNetEvent('esx_police:createOrResetStash')
AddEventHandler('esx_police:createOrResetStash', function(stashId, pin)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	if xPlayer.job.name ~= 'police' and xPlayer.job.name ~= 'sheriff' then return end
	stashId = tostring(stashId):gsub("%s+", ""):upper()
	if #stashId < 4 or #stashId > 20 then
		xPlayer.showNotification("ID szafki musi mieć od 4 do 20 znaków.")
		return
	end
	if #pin < 4 or #pin > 8 then
		xPlayer.showNotification("PIN musi mieć od 4 do 8 cyfr.")
		return
	end
	if RegisteredPoliceStashes[stashId] and RegisteredPoliceStashes[stashId].owner ~= xPlayer.identifier then
		xPlayer.showNotification("Schowek o tym ID już istnieje i nie jesteś jej właścicielem.")
		return
	end
	RegisteredPoliceStashes[stashId] = { pin = pin, owner = xPlayer.identifier }
	local label = ('Schowek prywatny [%s]'):format(stashId)
	local slots, weight = 60, 15000
	ox_inventory:RegisterStash(stashId, label, slots, weight, false, {[xPlayer.job.name] = 1})
	xPlayer.showNotification("PIN został ustawiony.")
	TriggerClientEvent('esx_police:openStash', src, stashId)
end)

RegisterNetEvent('esx_police:openStashByID', function(stashId, pin)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer or (xPlayer.job.name ~= 'police' and xPlayer.job.name ~= 'sheriff') then return end
	stashId = tostring(stashId):gsub("%s+", ""):upper()
	if not RegisteredPoliceStashes[stashId] then
		xPlayer.showNotification("Nie ma schowka o podanym ID.")
		return
	end
	if RegisteredPoliceStashes[stashId].pin ~= pin then
		xPlayer.showNotification("Nieprawidłowy PIN.")
		return
	end
	TriggerClientEvent('esx_police:openStash', src, stashId)
end)

local itemLimits = {
    radio = 1,
    gps = 1,
    handcuffs = 3,
    bodycam = 1,
    panic = 5
}

CreateThread(function()
	while true do
		Wait(10000)
		local players = GetPlayers()
		for _, src in ipairs(players) do
			local playerId = tonumber(src)
			if playerId then
				for itemName, limit in pairs(itemLimits) do
					local count = exports.ox_inventory:Search(playerId, 'count', itemName) or 0
					if count > limit then
						local excess = count - limit
						exports.ox_inventory:RemoveItem(playerId, itemName, excess)
						TriggerClientEvent('ox_lib:notify', playerId, {
							type = 'error',
							description = ('Ilość %s została ograniczona do %d sztuk.'):format(itemName, limit)
						})
					end
				end
			end
		end
	end
end)

ESX.RegisterServerCallback('vwk/police/getUniforms', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({})
        return
    end
    
    if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
        cb({})
        return
    end
    
    local jobName = xPlayer.job.name
    
    MySQL.query('SELECT * FROM fractions_uniforms WHERE job = ?', {jobName}, function(result)
        local uniforms = {}
        
        if not result then
            cb({})
            return
        end
        
        if result and #result > 0 then
            for i=1, #result, 1 do
                if result[i].category and result[i].name then
                    local minGrade = result[i].min_grade or 0
                    if xPlayer.job.grade < minGrade then
                        goto continue
                    end
                    
                    if not uniforms[result[i].category] then
                        uniforms[result[i].category] = {}
                    end
                    
                    local maleData = {}
                    local femaleData = {}
                    
                    if result[i].male and result[i].male ~= '' then
                        local success, decoded = pcall(json.decode, result[i].male)
                        if success and decoded then
                            maleData = decoded
                        end
                    end
                    
                    if result[i].female and result[i].female ~= '' then
                        local success, decoded = pcall(json.decode, result[i].female)
                        if success and decoded then
                            femaleData = decoded
                        end
                    end
                    
                    uniforms[result[i].category][result[i].name] = {
                        male = maleData,
                        female = femaleData,
                        min_grade = minGrade
                    }
                    ::continue::
                end
            end
        end
        
        cb(uniforms)
    end)
end)

ESX.RegisterServerCallback('vwk/police/addUniform', function(source, cb, uniformData)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade < 11 then
		cb(false)
		return
	end
	
	if not uniformData or not uniformData.name or not uniformData.category then
		cb(false)
		return
	end
	local maleJson = json.encode(uniformData.male or {})
	local femaleJson = json.encode(uniformData.female or {})
	local minGrade = uniformData.min_grade or 0
	
	MySQL.query([[
		CREATE TABLE IF NOT EXISTS fractions_uniforms (
			id INT AUTO_INCREMENT PRIMARY KEY,
			job VARCHAR(50) NOT NULL,
			name VARCHAR(100) NOT NULL,
			category VARCHAR(100) NOT NULL,
			male TEXT,
			female TEXT,
			min_grade INT DEFAULT 0,
			UNIQUE KEY unique_job_name (job, name)
		)
	]], {}, function()
		MySQL.insert('INSERT INTO fractions_uniforms (job, name, category, male, female, min_grade) VALUES (?, ?, ?, ?, ?, ?)',
			{xPlayer.job.name, uniformData.name, uniformData.category, maleJson, femaleJson, minGrade},
			function(id)
				cb(id ~= nil)
			end)
	end)
end)

ESX.RegisterServerCallback('vwk/police/removeUniform', function(source, cb, uniformName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade < 11 then
		cb(false)
		return
	end
	
	MySQL.query('DELETE FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, uniformName}, function(affected)
		cb(affected.affectedRows > 0)
	end)
end)

ESX.RegisterServerCallback('vwk/police/copyUniform', function(source, cb, sourceName, newName, newCategory)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade < 11 then
		cb(false)
		return
	end
	
	MySQL.query('SELECT * FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, sourceName}, function(result)
		if result and #result > 0 then
			local uniform = result[1]
			MySQL.query('SELECT id FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, newName}, function(checkResult)
				if checkResult and #checkResult > 0 then
					cb(false)
					return
				end
				
				MySQL.insert('INSERT INTO fractions_uniforms (job, name, category, male, female, min_grade) VALUES (?, ?, ?, ?, ?, ?)',
					{xPlayer.job.name, newName, newCategory or uniform.category, uniform.male, uniform.female, uniform.min_grade or 0},
					function(id)
						cb(id ~= nil)
					end)
			end)
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('vwk/police/setUniformMinGrade', function(source, cb, uniformName, minGrade)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade < 11 then
		cb(false)
		return
	end
	
	MySQL.update('UPDATE fractions_uniforms SET min_grade = ? WHERE job = ? AND name = ?',
		{minGrade, xPlayer.job.name, uniformName},
		function(affected)
			cb(affected and affected > 0)
		end)
end)

ESX.RegisterServerCallback('vwk/police/renameUniform', function(source, cb, oldName, newName)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		cb(false)
		return
	end
	
	if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
		cb(false)
		return
	end
	
	if xPlayer.job.grade < 11 then
		cb(false)
		return
	end
	
	if not oldName or not newName or newName == '' then
		cb(false)
		return
	end
	
	MySQL.query('SELECT id FROM fractions_uniforms WHERE job = ? AND name = ?', {xPlayer.job.name, newName}, function(result)
		if result and #result > 0 then
			cb(false)
			return
		end
		
		MySQL.update('UPDATE fractions_uniforms SET name = ? WHERE job = ? AND name = ?', 
			{newName, xPlayer.job.name, oldName}, 
			function(affected)
				cb(affected and affected > 0)
			end)
	end)
end)

local crimeActive = {}
local bracelets = {}
local vehicleTrackers = {}

MySQL.ready(function()
    MySQL.Async.execute('CREATE TABLE IF NOT EXISTS player_bracelets (id INT AUTO_INCREMENT PRIMARY KEY, identifier VARCHAR(50), putter_identifier VARCHAR(50), time BIGINT)', {})
end)

ESX.RegisterUsableItem(Config.Crime.item, function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if crimeActive[src] then
        xPlayer.showNotification("~r~Już używasz kabelków!")
        return
    end

    local deleteGPS = exports.ox_inventory:RemoveItem(src, 'gps', 1)
	if not deleteGPS then
		xPlayer.showNotification("~r~Nie posiadasz potrzebego przedmiotu!")
		return
	end
	local deleteItem = exports.ox_inventory:RemoveItem(src, Config.Crime.item, 1)
	if not deleteItem then
		xPlayer.showNotification("~r~Nie posiadasz "..Config.Crime.item.." aby przerobić GPS!")
		return
	end
    xPlayer.showNotification("Przerobiłeś GPS, za chwile obbierzesz sygnał GPS policji!")

    crimeActive[src] = true
    TriggerClientEvent('vwk/crime/gps', src, true)

    SetTimeout(Config.Crime.duration, function()
        if crimeActive[src] then
            crimeActive[src] = nil
            TriggerClientEvent('vwk/crime/gps', src, false)
            xPlayer.showNotification("~r~Sygnał GPS policji zniknął.")
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    crimeActive[src] = nil
end)

local function getClosestPlayer(src, maxDistance)
	local closest = ESX.OneSync.GetClosestPlayer(src, maxDistance, {})
	return closest and closest.id or nil
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.identifier
    MySQL.Async.fetchAll('SELECT * FROM player_bracelets WHERE identifier = @id', {['@id'] = identifier}, function(result)
        if result[1] then
            local data = result[1]
            bracelets[playerId] = { putter = nil, time = data.time, db_id = data.id }
            TriggerClientEvent('vwk/bracelet/put', playerId, true)
        end
    end)
end)

ESX.RegisterUsableItem(Config.Bracelet.item_put, function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or xPlayer.job.name ~= Config.Bracelet.job then return end

    local target = getClosestPlayer(src, 2.0)
    if not target then xPlayer.showNotification("~r~Brak gracza w pobliżu!") return end

    local targetPlayer = ESX.GetPlayerFromId(target)
    if bracelets[target] then xPlayer.showNotification("~r~Ma już opaskę!") return end

    TriggerClientEvent('vwk/bracelet:startAnimation', src, target)
end)

RegisterNetEvent('vwk/bracelet:give', function(target)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local targetPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer or not targetPlayer then return end
    
    if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "sheriff" then
        return
    end

    local srcPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    local srcCoords = GetEntityCoords(srcPed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(srcCoords - targetCoords)
    
    if distance > 2.0 then
        xPlayer.showNotification("~r~Target jest zbyt daleko!")
        return
    end

    if xPlayer.getInventoryItem(Config.Bracelet.item_put).count < 1 then
        xPlayer.showNotification("~r~Nie masz opaski w ekwipunku!")
        return
    end

    if bracelets[target] then
        xPlayer.showNotification("~r~Gracz ma już opaskę!")
        return
    end

    xPlayer.removeInventoryItem(Config.Bracelet.item_put, 1)

    MySQL.Async.insert('INSERT INTO player_bracelets (identifier, putter_identifier, time) VALUES (@id, @putter, @time)', {
        ['@id'] = targetPlayer.identifier,
        ['@putter'] = xPlayer.identifier,
        ['@time'] = os.time()
    }, function(id)
        bracelets[target] = { putter = xPlayer.identifier, time = os.time(), db_id = id }
        xPlayer.showNotification("~g~Opaska założona!")
        targetPlayer.showNotification("~r~Masz opaskę policyjną!")
        TriggerClientEvent('vwk/bracelet/put', target, true)
    end)
end)


ESX.RegisterUsableItem(Config.Bracelet.item_remove, function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local target = getClosestPlayer(src, 2.0)
    if not target or not bracelets[target] then xPlayer.showNotification("~r~Brak opaski!") return end

    xPlayer.removeInventoryItem(Config.Bracelet.item_remove, 1)
    local db_id = bracelets[target].db_id
    bracelets[target] = nil
    MySQL.Async.execute('DELETE FROM player_bracelets WHERE id = @id', {['@id'] = db_id})
    TriggerClientEvent('vwk/bracelet/put', target, false)
    xPlayer.showNotification("~g~Opaska zdjęta.")
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for plate, data in pairs(vehicleTrackers) do
            if now - data.time >= (Config.Tracker.duration / 1000) then
                vehicleTrackers[plate] = nil
                TriggerClientEvent('vwk/tracker/put', -1, plate, false)
            end
        end
    end
end)

RegisterNetEvent('vwk/bracelet:removeAtNPC', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not bracelets[src] then xPlayer.showNotification("~r~Nie masz opaski!") return end

    if xPlayer.getMoney() < Config.Bracelet.remove_price then
        xPlayer.showNotification("~r~Za mało pieniędzy! Potrzeba: $"..Config.Bracelet.remove_price)
        return
    end

    xPlayer.removeMoney(Config.Bracelet.remove_price)
    local db_id = bracelets[src].db_id
    bracelets[src] = nil
    MySQL.Async.execute('DELETE FROM player_bracelets WHERE id = @id', {['@id'] = db_id})
    TriggerClientEvent('vwk/bracelet/put', src, false)
    xPlayer.showNotification("~g~Opaska zdjęta za ~g~$"..Config.Bracelet.remove_price)
end)

exports('hasBracelet', function(playerId)
    return bracelets[playerId] ~= nil
end)

RegisterServerEvent('esx_police:openKosz', function()
    local src = source

    local stashId = exports.ox_inventory:CreateTemporaryStash({
        label = 'Kosz',
        slots = 350,
        maxWeight = 500000,
    })

    exports.ox_inventory:forceOpenInventory(src, 'stash', stashId)
end)