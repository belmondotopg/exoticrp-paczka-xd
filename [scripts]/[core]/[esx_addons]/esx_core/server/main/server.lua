local Player = Player
local MySQL = MySQL
local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local ESX = ESX
local GetPlayerName = GetPlayerName
local GetCurrentResourceName = GetCurrentResourceName
local ox_inventory = exports.ox_inventory
local esx_core = exports.esx_core
local esx_menu = exports.esx_menu

local autoClearEnabled = true
local autoClearThread = nil

local function StartAutoClear()
	if autoClearThread then return end
	
	autoClearThread = CreateThread(function()
		local interval = (Config.AutoClearInterval or 30) * 60 * 1000
		
		while autoClearEnabled do
			Citizen.Wait(interval)
			
			if autoClearEnabled then
				TriggerClientEvent('esx_core:timeClear', -1, false)
				esx_core:SendLog(-1, "Automatyczne czyszczenie mapy", "[AUTO] Automatyczne czyszczenie mapy", 'clearmap')
				print(string.format("[esx_core] Automatyczne czyszczenie mapy wykonane. Następne za %d minut.", Config.AutoClearInterval or 30))
			end
		end
		
		autoClearThread = nil
	end)
end

local function StopAutoClear()
	autoClearEnabled = false
	if autoClearThread then
		autoClearThread = nil
	end
end

local AdminGroups = {
	['founder'] = true,
	['managment'] = true,
	['developer'] = true
}

RegisterCommand('clearon', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	if AdminGroups[xPlayer.group] then
		if not autoClearEnabled then
			autoClearEnabled = true
			StartAutoClear()
			xPlayer.showNotification(string.format('Włączono automatyczne czyszczenie mapy! (co %d minut)', Config.AutoClearInterval or 30))
			esx_core:SendLog(xPlayer.source, "Włączono automatyczne czyszczenie mapy", string.format("Włączono automatyczne czyszczenie mapy (co %d minut)", Config.AutoClearInterval or 30), 'admin-commands')
			print(string.format("[esx_core] Automatyczne czyszczenie mapy włączone przez %s (ID: %d). Interwał: %d minut.", GetPlayerName(source), source, Config.AutoClearInterval or 30))
		else
			xPlayer.showNotification('Automatyczne czyszczenie mapy jest już włączone!')
		end
	end
end, false)

RegisterCommand('clearoff', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	if AdminGroups[xPlayer.group] then
		if autoClearEnabled then
			StopAutoClear()
			xPlayer.showNotification('Wyłączono automatyczne czyszczenie mapy!')
			esx_core:SendLog(xPlayer.source, "Wyłączono automatyczne czyszczenie mapy", "Wyłączono automatyczne czyszczenie mapy", "admin-commands")
			print(string.format("[esx_core] Automatyczne czyszczenie mapy wyłączone przez %s (ID: %d).", GetPlayerName(source), source))
		else
			xPlayer.showNotification('Automatyczne czyszczenie mapy jest już wyłączone!')
		end
	end
end, false)

RegisterCommand("ssn", function(src,args,raw) 
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	local ssn = Player(src).state.ssn or 'Brak'
	xPlayer.showNotification("Twój SSN: "..ssn)
end, false)

RegisterCommand('clearmap', function(source, args, rawCommand)
	if source == 0 then
		TriggerClientEvent('esx_core:timeClear', -1, true)
		esx_core:SendLog(-1, "ClearMap", "[PROMPT] Użyto komendy /clearmap", 'admin-commands')
		return
	end

	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	if AdminGroups[xPlayer.group] then
		TriggerClientEvent('esx_core:timeClear', -1, true)
		esx_core:SendLog(xPlayer.source, "ClearMap", "Użyto komendy /clearmap", "clearmap")
	end
end, false)

RegisterServerEvent('esx_core:komunikat', function(text)
	local src = source
	if not src or not text then return end

	local color = {r = 255, g = 202, b = 247, alpha = 255}
	TriggerClientEvent("esx_chat:sendAddonChatMessageMe", -1, src, src, text)
	TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
end)

ESX.RegisterServerCallback('esx_core:getVehicleFromPlate', function(source, cb, plate)
	if not plate then
		cb('Nieznany')
		return
	end

	local result = MySQL.query.await('SELECT owner, co_owner, co_owner2, co_owner3 FROM owned_vehicles WHERE plate = ?', {plate})
	if not result or not result[1] then
		cb('Nieznany')
		return
	end

	local ownerData = result[1]
	local co_owner1, co_owner2, co_owner3 = '', '', ''

	local userData = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {ownerData.owner})
	local ownerName = 'Nieznany'
	if userData and userData[1] then
		ownerName = userData[1].firstname .. ' ' .. userData[1].lastname
	end

	if ownerData.co_owner and ownerData.co_owner ~= '' then
		local player = ESX.GetPlayerFromIdentifier(ownerData.co_owner)
		if player then
			co_owner1 = player.identifier
		end
	end

	if ownerData.co_owner2 and ownerData.co_owner2 ~= '' then
		local player = ESX.GetPlayerFromIdentifier(ownerData.co_owner2)
		if player then
			co_owner2 = player.identifier
		end
	end

	if ownerData.co_owner3 and ownerData.co_owner3 ~= '' then
		local player = ESX.GetPlayerFromIdentifier(ownerData.co_owner3)
		if player then
			co_owner3 = player.identifier
		end
	end

	cb({
		owner = ownerName,
		co_owner1 = co_owner1,
		co_owner2 = co_owner2,
		co_owner3 = co_owner3,
	})
end)

local function FormatPlateNotification(owner, dateofbirth, co_owner1, co_owner2, co_owner3, poszukiwany, notiftype)
	local parts = {'Właściciel: <b>' .. owner .. '</b> ' .. dateofbirth .. '</b>'}
	
	if co_owner1 then
		table.insert(parts, 'Współwłaściciel 1: <b>' .. co_owner1 .. '</b>')
	end
	if co_owner2 then
		table.insert(parts, 'Współwłaściciel 2: <b>' .. co_owner2 .. '</b>')
	end
	if co_owner3 then
		table.insert(parts, 'Współwłaściciel 3: <b>' .. co_owner3 .. '</b>')
	end
	
	table.insert(parts, 'Poszukiwany: <b>' .. poszukiwany .. '</b>')
	return table.concat(parts, '<br>'), notiftype
end

RegisterNetEvent('esx_core:checkPlates', function(plate)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	if not plate then
		xPlayer.showNotification('Nie znaleziono rejestracji w bazie danych')
		return
	end

	local result = MySQL.query.await('SELECT ov.owner, u.dateofbirth FROM owned_vehicles ov JOIN users u ON ov.owner = u.identifier WHERE ov.plate = ?', {plate})
	if not result or not result[1] then
		xPlayer.showNotification('Nie znaleziono rejestracji w bazie danych')
		return
	end

	local vehicleData = result[1]
	local owner, co_owner1, co_owner2, co_owner3, poszukiwany, notiftype

	local coownerResult = MySQL.query.await('SELECT co_owner, co_owner2, co_owner3 FROM owned_vehicles WHERE plate = ? AND owner = ?', {plate, vehicleData.owner})
	if coownerResult and coownerResult[1] then
		local coData = coownerResult[1]
		
		if coData.co_owner and coData.co_owner ~= '' then
			local player = ESX.GetPlayerFromIdentifier(coData.co_owner)
			if player then
				co_owner1 = player.getName()
			end
		end

		if coData.co_owner2 and coData.co_owner2 ~= '' then
			local player = ESX.GetPlayerFromIdentifier(coData.co_owner2)
			if player then
				co_owner2 = player.getName()
			end
		end

		if coData.co_owner3 and coData.co_owner3 ~= '' then
			local player = ESX.GetPlayerFromIdentifier(coData.co_owner3)
			if player then
				co_owner3 = player.getName()
			end
		end
	end

	local citizenNotes = MySQL.query.await('SELECT reason FROM qf_mdt_citizen_notes WHERE identifier = ?', {vehicleData.owner})
	if citizenNotes and #citizenNotes > 0 then
		poszukiwany = 'TAK (OBYWATEL)'
		notiftype = 'error'
	else
		local vehicleNotes = MySQL.query.await('SELECT note FROM qf_mdt_vehicle_notes WHERE plate = ?', {plate})
		if vehicleNotes and #vehicleNotes > 0 then
			poszukiwany = 'TAK (AUTO)'
			notiftype = 'error'
		else
			poszukiwany = 'NIE'
			notiftype = 'info'
		end
	end

	local ownerPlayer = ESX.GetPlayerFromIdentifier(vehicleData.owner)
	if ownerPlayer then
		owner = ownerPlayer.getName()
	else
		local userData = MySQL.query.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {vehicleData.owner})
		if userData and userData[1] then
			owner = userData[1].firstname .. ' ' .. userData[1].lastname
		else
			owner = 'Nieznany'
		end
	end

	local message, type = FormatPlateNotification(owner, vehicleData.dateofbirth or '', co_owner1, co_owner2, co_owner3, poszukiwany, notiftype)
	xPlayer.showNotification(message, '', type)
end)

RegisterNetEvent('esx_core:saveMandat', function(job, job_grade, wyrok)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	local Identifiers = ESX.ExtractIdentifiers(src)
	local identifier = xPlayer.identifier
	local result, kursCount

	if job == "ambulance" then
		result = MySQL.query.await("SELECT rankAmbulanceInvoice FROM users WHERE identifier = ? AND job = ?", {identifier, job})
		if result and result[1] then
			kursCount = result[1].rankAmbulanceInvoice or 0
			MySQL.update.await('UPDATE users SET rankAmbulanceInvoice = ?, job_grade = ?, discordid = ? WHERE identifier = ? AND job = ?', {kursCount + 1, job_grade, Identifiers.discord, identifier, job})
		end
	elseif job == "mechanik" then
		result = MySQL.query.await("SELECT rankMechanicInvoice FROM users WHERE identifier = ? AND job = ?", {identifier, job})
		if result and result[1] then
			kursCount = result[1].rankMechanicInvoice or 0
			MySQL.update.await('UPDATE users SET rankMechanicInvoice = ?, job_grade = ?, discordid = ? WHERE identifier = ? AND job = ?', {kursCount + 1, job_grade, Identifiers.discord, identifier, job})
		end
	elseif job == "police" then
		if wyrok then
			result = MySQL.query.await("SELECT rankPoliceJail FROM users WHERE identifier = ? AND job = ?", {identifier, job})
			if result and result[1] then
				kursCount = result[1].rankPoliceJail or 0
				MySQL.update.await('UPDATE users SET rankPoliceJail = ?, job_grade = ?, discordid = ? WHERE identifier = ? AND job = ?', {kursCount + 1, job_grade, Identifiers.discord, identifier, job})
			end
		else
			result = MySQL.query.await("SELECT rankPoliceFine FROM users WHERE identifier = ? AND job = ?", {identifier, job})
			if result and result[1] then
				kursCount = result[1].rankPoliceFine or 0
				MySQL.update.await('UPDATE users SET rankPoliceFine = ?, job_grade = ?, discordid = ? WHERE identifier = ? AND job = ?', {kursCount + 1, job_grade, Identifiers.discord, identifier, job})
			end
		end
	end
end)

RegisterServerEvent("esx_core:deleteOldItem", function (itemName)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		xPlayer.removeInventoryItem(itemName, 1)
	end
end)

RegisterServerEvent('esx_core:onDetectSomething', function(diffrence, playerIndex)
	local src = source

	if Player(src).state.playerIndex then
		if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
			esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
			DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją ExoticRP")
			return
		else
			Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
		end
	end

	DropPlayer(src, diffrence)
end)

RegisterServerEvent("esx_core:onRemoveDurability", function(item)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer or not item then return end

	local search = ox_inventory:Search(src, 'slots', item)
	if not search or #search == 0 then return end

	for _, v in ipairs(search) do
		if not v.metadata or not v.metadata.durability then
			break
		end

		if v.metadata.durability <= 10 then
			xPlayer.showNotification('Twój wytrych się zepsuł!')
			xPlayer.removeInventoryItem(item, 1)
		elseif v.slot then
			ox_inventory:SetDurability(src, v.slot, v.metadata.durability - 10.0)
		end
		break
	end
end)

function takeMoney(xPlayer, money, method, cb)
	if not xPlayer or not money or money <= 0 then
		if cb then cb(false) end
		return
	end

	if xPlayer.getMoney() >= money then
		xPlayer.removeMoney(money)
		xPlayer.showNotification("Pobrano " .. money .. "$ z twojej kieszeni.")
		if cb then cb(true) end
		return
	end

	local bankAccount = xPlayer.getAccount("bank")
	if bankAccount and bankAccount.money >= money then
		xPlayer.removeAccountMoney("bank", money)
		xPlayer.showNotification("Pobrano " .. money .. "$ z konta bankowego.")
		if cb then cb(true) end
		return
	end

	if cb then cb(false) end
end

local MoneyCosts = {
	apartment = 25000,
	localmedic = 1000,
	localmechanic = 2500,
	flare = 4000,
	gym = 500
}

ESX.RegisterServerCallback('esx_core:onCheckMoney', function(source, cb, method, newMoney)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then
		if cb then cb(false) end
		return
	end

	local money = 5000

	if method then
		if method == 'localmedic' then
			money = esx_menu:CheckInsuranceEMS(xPlayer.source) and 0 or MoneyCosts.localmedic
		elseif method == "localmechanic" then
			money = esx_menu:CheckInsuranceLSC(xPlayer.source) and 0 or MoneyCosts.localmechanic
		else
			money = MoneyCosts[method] or money
		end
	elseif newMoney and newMoney > 0 then
		money = newMoney
	end

	takeMoney(xPlayer, money, method, cb)
end)

AddEventHandler("esx_core:takeMoneyServer", function(playerId, amount, cb) 
	local xPlayer = ESX.GetPlayerFromId(playerId)
	if not xPlayer then return end
	takeMoney(xPlayer, amount, nil, cb)
end)

local blockedCommands = {'rcon_password', 'sv_licenseKey', 'mysql_connection_string'}

for _, cmd in ipairs(blockedCommands) do
	RegisterCommand(cmd, function()
		CancelEvent()
	end)
end

AddEventHandler("esx:playerLoaded", function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	local heistCooldown = MySQL.scalar.await("SELECT heistcooldown_minutes FROM users WHERE identifier = ?", {xPlayer.identifier})
	if heistCooldown and heistCooldown >= 0 then
		TriggerClientEvent("esx_core:startHeistCooldown", src, heistCooldown)
	end

	local timeResult = MySQL.query.await('SELECT timePlayer FROM users WHERE identifier = ?', {xPlayer.identifier})
	if timeResult and timeResult[1] and timeResult[1].timePlayer then
		Player(src).state.RankTime = tonumber(timeResult[1].timePlayer)
	end

	SetConvarServerInfo("Graczy", tostring(GetNumPlayerIndices()))
end)

AddEventHandler("playerDropped", function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then
		SetConvarServerInfo("Graczy", tostring(GetNumPlayerIndices()))
		return
	end

	local timeCooldown = tonumber(Player(src).state.HeistCooldown)
	if timeCooldown then
		MySQL.update("UPDATE users SET heistcooldown_minutes = ? WHERE identifier = ?", {timeCooldown, xPlayer.identifier}, function() end)
	end

	local time = tonumber(Player(src).state.RankTime)
	if time then
		MySQL.update.await('UPDATE users SET timePlayer = ? WHERE identifier = ?', {time, xPlayer.identifier})
	end

	SetConvarServerInfo("Graczy", tostring(GetNumPlayerIndices()))
end)

local TWO_WEEKS_IN_SECONDS = 14 * 24 * 60 * 60

local function CanLicense(timestamp)
	if not timestamp then return true end
	local currentTime = os.time()
	return (currentTime - timestamp) >= TWO_WEEKS_IN_SECONDS
end

lib.callback.register('esx_core:getLicenseTest', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then
		return {false, "Błąd: Nie znaleziono gracza"}
	end

	local result = MySQL.single.await('SELECT MAX(addDate) as addDate FROM esx_prisons_list WHERE identifier = ?', {xPlayer.identifier})

	if not result or not result.addDate then
		return {true, "Możesz"}
	end

	local time = tonumber(result.addDate)
	if not time then
		return {true, "Możesz"}
	end

	local can = CanLicense(time)
	if can then
		return {true, "Możesz"}
	end

	local remainingDays = math.ceil(((time + TWO_WEEKS_IN_SECONDS) - os.time()) / (24 * 60 * 60))
	return {false, "Od twojego ostatniego wyroku nie minęło jeszcze 14 dni! Wróć ponownie za " .. remainingDays .. " dni!"}
end)

local function GetPlayersNearCoords(coords, radius)
	local players = {}
	
	for _, player in pairs(ESX.GetExtendedPlayers()) do
		local playerCoords = GetEntityCoords(GetPlayerPed(player.source))
		local distance = #(coords - playerCoords)
		if distance <= radius then
			table.insert(players, {id = player.source, pName = player.getName(), identifier = player.identifier})
		end
	end

	return players
end

exports("getPlayers", function() 
	return ESX.GetExtendedPlayers()
end)

local function SplitId(string)
	local output
	for str in string.gmatch(string, "([^:]+)") do
		output = str
	end
	return output
end

local function ExtractIdentifiers(src)
	local identifiers = {
		id = src,
		name = GetPlayerName(src),
		steamhex = "Brak",
		steamid = "Brak",
		ip = "Brak",
		discord = "Brak",
		license = "Brak",
		license2 = "Brak",
		xbl = "Brak",
		live = "Brak",
		fivem = "Brak",
		hwid = {}
	}

	for i = 0, GetNumPlayerIdentifiers(src) - 1 do
		local id = GetPlayerIdentifier(src, i)
		if id:find("steam") then
			identifiers.steamhex = SplitId(id)
			identifiers.steamid = tonumber(SplitId(id), 16)
		elseif id:find("ip") then
			identifiers.ip = SplitId(id)
		elseif id:find("discord") then
			identifiers.discord = SplitId(id)
		elseif id:find("license2") then
			identifiers.license2 = SplitId(id)
		elseif id:find("license") then
			identifiers.license = SplitId(id)
		elseif id:find("xbl") then
			identifiers.xbl = SplitId(id)
		elseif id:find("live") then
			identifiers.live = SplitId(id)
		elseif id:find("fivem") then
			identifiers.fivem = SplitId(id)
		end
	end

	for i = 0, GetNumPlayerTokens(src) - 1 do
		table.insert(identifiers.hwid, GetPlayerToken(src, i))
	end

	return identifiers
end

local function SendDiscordCallWebhook(discordId, callerName, webhookUrl)
	if not webhookUrl or webhookUrl == '' then return end

	local discord = "<@" .. discordId:gsub("discord:", "") .. ">"
	local embedData = {
		content = discord,
		embeds = {{
			color = 11669300,
			description = "```Zapraszam na poczekalnie masz 3 minuty```\nWezwany przez: " .. callerName,
			footer = {
				text = "ExoticRP - " .. os.date("%x %X %p"),
				icon_url = "https://i.ibb.co/kVsZnt71/logo.png"
			}
		}},
		avatar_url = "https://i.ibb.co/kVsZnt71/logo.png"
	}

	PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode(embedData), {['Content-Type'] = 'application/json'})
end

ESX.RegisterCommand('wezwanie', { 'founder', 'developer', 'managment', 'headadmin', 'admin' , 'trialadmin' , 'seniormod' , 'mod' , 'trialmod' , 'support', 'trialsupport' }, function(xPlayer, args, showError)
	if not xPlayer then return end
	if not args.playerId then
		return xPlayer.showNotification('Nie znaleziono gracza o podanym ID!')
	end

	if args.method ~= 'rzadowy' and args.method ~= 'sprawdzanie' then
		return xPlayer.showNotification('Niepoprawny typ wezwania!')
	end

	local targetId = args.playerId.source
	local callerName = GetPlayerName(xPlayer.source)
	local ids = ExtractIdentifiers(targetId)
	local discordId = ids.discord or ""

	esx_core:SendLog(xPlayer.source, "Wezwanie gracza", "Użył komendy /wezwanie " .. targetId .. " " .. args.method, 'admin-commands')

	--todo
	local webhookUrl = ""

	if args.method == 'rzadowy' then
		TriggerClientEvent("esx_core:calledPlayer", targetId, callerName, "<@" .. discordId:gsub("discord:", "") .. ">", GetPlayerName(targetId))
		SendDiscordCallWebhook(discordId, callerName, webhookUrl)
	else
		TriggerClientEvent("esx_core:cheaterCalled", targetId, callerName)
		SendDiscordCallWebhook(discordId, callerName, webhookUrl)
	end
end, true, {help = 'Wezwij gracza', validate = true, arguments = {
	{name = 'playerId', help = 'ID', type = 'player'},
	{name = 'method', help = 'rzadowy / sprawdzanie', type = 'string'},
}})

local function SendLog(img, message, url)
	if not message or message == '' then return false end
	if not url or url == '' then return false end

	local embeds = {
		{
			["avatar_url"] = "https://i.ibb.co/kVsZnt71/logo.png",
			["username"] = "ExoticRP",
			["author"] = {
				["name"] = "ExoticRP",
				["url"] = "https://exoticrp.eu/",
				["icon_url"] = "https://i.ibb.co/kVsZnt71/logo.png",
			},
			["description"] = message,
			["type"] = "rich",
			["color"] = 11669300,
			["image"] = {
				["url"] = img,
			},
			['thumbnail'] = {
				['url'] = 'https://i.ibb.co/kVsZnt71/logo.png',
			},
			["footer"] = {
				["text"] = "ExoticRP ▪ [" .. os.date("%Y/%m/%d %X") .. ']',
				['icon_url'] = 'https://i.ibb.co/kVsZnt71/logo.png'
			},
		}
	}

	PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode({username = 'ExoticRP', avatar_url = 'https://i.ibb.co/kVsZnt71/logo.png', embeds = embeds}), {['Content-Type'] = 'application/json'})
end

RegisterServerEvent('esx_core/screenPlayer', function(screenedId)
	local src = source
	if not screenedId then return end

	local Identifiers = ExtractIdentifiers(screenedId)
	local img = lib.callback.await('ss:getImage', screenedId)

	if not img then return end

	-- TODO: Dodać prawidłowy URL webhooka
	local webhookUrl = ""
	
	local message = string.format(
		'Administrator: `%s` wykonał zrzut ekranu graczowi:\nName: `%s` ID: `%s`\nLicense: `%s`\nDiscordID: `%s`\nSteam: `%s`',
		GetPlayerName(src),
		GetPlayerName(screenedId),
		screenedId,
		Identifiers.license or 'Brak',
		Identifiers.discord or 'Brak',
		Identifiers.steamhex or 'Brak'
	)

	SendLog(img, message, webhookUrl)
end)

ESX.RegisterCommand('setslots', { 'founder', 'developer', 'managment' }, function(xPlayer, args, showError)
	local source = xPlayer and xPlayer.source or 0
	local isConsole = source == 0

	if not args.identifier or not args.slots then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Nie podano identifier lub slots!')
		else
			print('^1[ERROR]^7 Błąd: Nie podano identifier lub slots!')
		end
		return
	end

	if type(args.slots) ~= 'number' or args.slots < 1 then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Slots musi być liczbą większą lub równą 1!')
		else
			print('^1[ERROR]^7 Błąd: Slots musi być liczbą większą lub równą 1!')
		end
		return
	end

	local slots = MySQL.scalar.await('SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?', {
		args.identifier
	})

	if not slots then
		MySQL.update.await('INSERT INTO `multicharacter_slots` (`identifier`, `slots`) VALUES (?, ?)', { args.identifier, args.slots })
	else
		MySQL.update.await('UPDATE `multicharacter_slots` SET `slots` = ? WHERE `identifier` = ?', { args.slots, args.identifier })
	end

	local message = ("Nadał dla: %s ilość slotów postaci w ilości: %d"):format(args.identifier, args.slots)
	
	if not isConsole and xPlayer then
		xPlayer.showNotification(message)
	else
		print(('[^2INFO^7] %s'):format(message))
	end
	
	esx_core:SendLog(source, "Ustawienie slotów postaci", message, 'admin-slots', '9807270')
end, true, {help = ('command_setslots'), validate = true, arguments = {
	{name = 'identifier', help = ('command_identifier'), type = 'string'},
	{name = 'slots', help = ('command_slots'), type = 'number'}
}})

ESX.RegisterCommand('remslots', { 'founder', 'developer', 'managment' }, function(xPlayer, args, showError)
	local source = xPlayer and xPlayer.source or 0
	local isConsole = source == 0

	if not args.identifier then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Nie podano identifier!')
		else
			print('^1[ERROR]^7 Błąd: Nie podano identifier!')
		end
		return
	end

	local slots = MySQL.scalar.await('SELECT `slots` FROM `multicharacter_slots` WHERE identifier = ?', {
		args.identifier
	})

	if slots then
		MySQL.update.await('DELETE FROM `multicharacter_slots` WHERE `identifier` = ?', {
			args.identifier
		})
		
		local message = ("Usunął dla: %s ilość dodatkowych slotów postaci"):format(args.identifier)
		
		if not isConsole and xPlayer then
			xPlayer.showNotification(message)
		else
			print(('[^2INFO^7] %s'):format(message))
		end
		
		esx_core:SendLog(source, "Usunięcie slotów postaci", message, 'admin-slots', '9807270')
	else
		local message = ("Nie znaleziono slotów dla identifier: %s"):format(args.identifier)
		if not isConsole and xPlayer then
			xPlayer.showNotification(message)
		else
			print(('[^3WARN^7] %s'):format(message))
		end
	end
end, true, {help = ('command_remslots'), validate = true, arguments = {
	{name = 'identifier', help = ('command_identifier'), type = 'string'}
}})

local DB_TABLES = {users = 'identifier', esx_tracker = 'identifier', gym_passes = 'player_identifier', gym_workers = 'worker_identifier', gym_player_stats = 'player_identifier', user_licenses = 'owner', mechanic_settings = 'identifier', mechanic_invoices = 'identifier', mechanic_orders = 'identifier', opcrime_playersaction = 'identificator', opcrime_players = 'identificator', phone_phones = 'id', phone_numbers = 'owner', qf_mdt_time = 'identifier', qf_mdt_profiles = 'identifier', qf_mdt_notes = 'identifier', qf_mdt_lsc_time = 'identifier', qf_mdt_lsc_profiles = 'identifier', qf_mdt_lsc_notes = 'identifier', qf_mdt_lsc_invoices = 'identifier', qf_mdt_lsc_citizen_notes = 'identifier', qf_mdt_ec_time = 'identifier', qf_mdt_ec_profiles = 'identifier', qf_mdt_ec_notes = 'identifier', qf_mdt_ec_invoices = 'identifier', qf_mdt_ec_citizen_notes = 'identifier', qf_mdt_jails = 'identifier', qf_mdt_fines = 'identifier', qf_mdt_ems_time = 'identifier', qf_mdt_ems_profiles = 'identifier', qf_mdt_ems_notes = 'identifier', qf_mdt_ems_invoices = 'identifier', qf_mdt_ems_citizen_notes = 'identifier', qf_mdt_citizen_notes = 'identifier', owned_vehicles = 'owner', motels_owners = 'identifier', esx_prisons = 'identifier', esx_prisons_list = 'identifier', ox_inventory = 'owner'}
local PREFIX = Config.Prefix or 'char'

local function DeleteCharacter(source, charid)
	local identifiers = ExtractIdentifiers(source)
	local license = identifiers.license
	
	if not license or license == "Brak" then
		print(('[^1ERROR^7] Nie można pobrać license dla gracza %s (ID: %d)'):format(GetPlayerName(source), source))
		return
	end
	
	local identifier = ('%s%d:%s'):format(PREFIX, charid, license)
	local query = 'DELETE FROM %s WHERE %s = ?'
	local queries = {}
	local queryInfo = {}

	for table, column in pairs(DB_TABLES) do
		local formattedQuery = query:format(table, column)
		queries[#queries + 1] = {query = formattedQuery, values = {identifier}}
		queryInfo[#queryInfo + 1] = {table = table, column = column, query = formattedQuery}
	end

	MySQL.transaction(queries, function(result, err)
		if result then
			print(('[^2INFO^7] Player ^5%s %s^7 has deleted a character ^5(%s)^7'):format(GetPlayerName(source), source, identifier))
			CreateThread(function()
				Wait(50)
				if source then
					DropPlayer(source, 'Zostałeś wyrzucony z serwera z powodu usunięcia postaci.')
				end
			end)
		else
			print(('[^1ERROR^7] Transaction failed while trying to delete %s'):format(identifier))
			if err then
				print(('[^1ERROR^7] Transaction error: %s'):format(err))
			end
			
			-- Test each query individually to find which one fails
			print(('[^3DEBUG^7] Testing queries individually to find the problematic one...'):format())
			for i, info in ipairs(queryInfo) do
				local success, queryErr = xpcall(function()
					MySQL.query.await(info.query, {identifier})
				end, function(err)
					return tostring(err)
				end)
				if not success then
					print(('[^1ERROR^7] Failed query #%d: DELETE FROM %s WHERE %s = ? (Table: %s, Column: %s, Error: %s)'):format(i, info.table, info.column, info.table, info.column, tostring(queryErr)))
				else
					print(('[^2OK^7] Query #%d succeeded: DELETE FROM %s WHERE %s = ?'):format(i, info.table, info.column))
				end
			end
		end
	end)
end

ESX.RegisterCommand('deletecharid', { 'founder', 'developer', 'managment', 'headadmin' }, function(xPlayer, args, showError)
	local source = xPlayer and xPlayer.source or 0
	local isConsole = source == 0

	if not args.playerId or not args.playerId.source then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Musisz podać ID gracza!')
		else
			print('^1[ERROR]^7 Błąd: Musisz podać ID gracza!')
		end
		return
	end

	if not args.charid or type(args.charid) ~= 'number' or args.charid < 1 or args.charid > 99 then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Niepoprawny numer postaci! Musi być liczbą od 1 do 99.')
		else
			print('^1[ERROR]^7 Błąd: Niepoprawny numer postaci! Musi być liczbą od 1 do 99.')
		end
		return
	end

	if not PREFIX or not DB_TABLES then
		local errorMsg = 'Błąd: PREFIX lub DB_TABLES nie są zdefiniowane!'
		if not isConsole and xPlayer then
			xPlayer.showNotification(errorMsg)
		else
			print(('[^1ERROR^7] %s'):format(errorMsg))
		end
		return
	end

	local targetSource = args.playerId.source
	if not GetPlayerName(targetSource) then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Nie znaleziono gracza o podanym ID!')
		else
			print('^1[ERROR]^7 Błąd: Nie znaleziono gracza o podanym ID!')
		end
		return
	end

	local targetIdentifiers = ExtractIdentifiers(targetSource)
	local targetLicense = targetIdentifiers.license or 'unknown'
	
	DeleteCharacter(targetSource, args.charid)
	esx_core:SendLog(source, "Usunięcie postaci", ("[PROMPT] Usunięto postać: char%d:%s (Gracz: %s)"):format(args.charid, targetLicense, GetPlayerName(targetSource)), 'admin-deletecharacter')
	
	if not isConsole and xPlayer then
		xPlayer.showNotification(("Usunięto postać char%d dla gracza %s"):format(args.charid, GetPlayerName(targetSource)))
	else
		print(('[^2INFO^7] Usunięto postać char%d dla gracza %s (ID: %d)'):format(args.charid, GetPlayerName(targetSource), targetSource))
	end
end, true, {help = 'Usuń postać po ID gracza', validate = true, arguments = {
	{name = 'playerId', help = 'Id gracza', type = 'player'},
	{name = 'charid', help = 'Numer postaci', type = 'number'},
}})

ESX.RegisterCommand('deletecharlicense', { 'founder', 'developer', 'managment', 'headadmin' }, function(xPlayer, args, showError)
	local source = xPlayer and xPlayer.source or 0
	local isConsole = source == 0

	if not args.license then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Musisz podać license!')
		else
			print('^1[ERROR]^7 Błąd: Musisz podać license!')
			print('^3[INFO]^7 Przykład użycia z konsoli: deletecharlicense [charid] [license]')
		end
		return
	end

	if not args.charid or type(args.charid) ~= 'number' or args.charid < 1 or args.charid > 99 then
		if not isConsole and xPlayer then
			xPlayer.showNotification('Błąd: Niepoprawny numer postaci! Musi być liczbą od 1 do 99.')
		else
			print('^1[ERROR]^7 Błąd: Niepoprawny numer postaci! Musi być liczbą od 1 do 99.')
		end
		return
	end

	if not PREFIX or not DB_TABLES then
		local errorMsg = 'Błąd: PREFIX lub DB_TABLES nie są zdefiniowane!'
		if not isConsole and xPlayer then
			xPlayer.showNotification(errorMsg)
		else
			print(('[^1ERROR^7] %s'):format(errorMsg))
		end
		return
	end

	local identifier = ('%s%d:%s'):format(PREFIX, args.charid, args.license)
	local query = 'DELETE FROM %s WHERE %s = ?'
	local queries = {}
	local queryInfo = {}
	
	for table, column in pairs(DB_TABLES) do
		local formattedQuery = query:format(table, column)
		queries[#queries + 1] = {query = formattedQuery, values = {identifier}}
		queryInfo[#queryInfo + 1] = {table = table, column = column, query = formattedQuery}
	end

	MySQL.transaction(queries, function(result, err)
		if result then
			local message = ("Usunięto postać: %s"):format(identifier)
			if not isConsole and xPlayer then
				xPlayer.showNotification(message)
			else
				print(('[^2INFO^7] %s'):format(message))
			end
			esx_core:SendLog(source, "Usunięcie postaci", ("[PROMPT] Usunięto postać: char%d:%s"):format(args.charid, args.license), 'admin-deletecharacter')
		else
			local errorMsg = ("Błąd transakcji podczas usuwania postaci: %s"):format(identifier)
			if not isConsole and xPlayer then
				xPlayer.showNotification(errorMsg)
			else
				print(('[^1ERROR^7] %s'):format(errorMsg))
			end
			print(('[^1ERROR^7] Transaction failed while trying to delete %s'):format(identifier))
			if err then
				print(('[^1ERROR^7] Transaction error: %s'):format(err))
			end
			
			print(('[^3DEBUG^7] Testing queries individually to find the problematic one...'):format())
			for i, info in ipairs(queryInfo) do
				local success, queryErr = xpcall(function()
					MySQL.query.await(info.query, {identifier})
				end, function(err)
					return tostring(err)
				end)
				if not success then
					print(('[^1ERROR^7] Failed query #%d: DELETE FROM %s WHERE %s = ? (Table: %s, Column: %s, Error: %s)'):format(i, info.table, info.column, info.table, info.column, tostring(queryErr)))
				else
					print(('[^2OK^7] Query #%d succeeded: DELETE FROM %s WHERE %s = ?'):format(i, info.table, info.column))
				end
			end
		end
	end)
end, true, {help = 'Usuń postać po license', validate = false, arguments = {
	{name = 'charid', help = 'Numer postaci', type = 'number'},
	{name = 'license', help = 'Licencja gracza', type = 'string'},
}})

lib.callback.register('ox_inventory:checkIfVehicleIsOwned', function(source, plate)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return false end
	
	local identifier = xPlayer.identifier
	
	local result = MySQL.scalar.await(
		'SELECT 1 FROM owned_vehicles WHERE plate = ? AND (owner = ? OR co_owner = ? OR co_owner2 = ? OR co_owner3 = ?) LIMIT 1',
		{plate, identifier, identifier, identifier, identifier}
	)
	
	return result ~= nil
end)