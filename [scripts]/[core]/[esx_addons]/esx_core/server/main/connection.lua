local esx_core = exports.esx_core
local isRestarting = false
local BanList = {}
local weryfikacjaDiscord = true
local DC_TOKEN = "MTQ1Nzc1NTg4MDc2NTUyNjA4OA.G-Ddy9.xbRAfdaIsU97AaZKGBHF419kxU0loJ03jNy7Zw"

local DISCORD_GUILD_ID = "1244700092108378113"
local ADMIN_ROLE_ID = "1318648922171772949"
local LOGO_URL = "https://i.ibb.co/kVsZnt71/logo.png"
local LOADING_GIF_URL = "https://data.qfdevelopers.com/qf/loading_circles.gif"
local DISCORD_INVITE_URL = "https://discord.com/invite/exoticrp"
local THUMBNAIL_URL = "https://i.ibb.co/0y8Q24NV/exoticrp.png"

local Webhooks = {
	UbWebhook = '',
	BanWebhook = 'https://discord.com/api/webhooks/1454239288500682917/F1tGRX6dvi0MvD7UEbLc6MdA8Wt83ncrFb83gmkBHfVgTU4HGggGMr1_ZIJ6FvzdruMp',
	EditWebhook = '',
	ServerBanWebhook = 'https://discord.com/api/webhooks/1438860789078556815/hwxeGclZ4eef9Pyx3pzSpRwgsp3SIEMqf4GTizrv-STLhdBRi4BYM8Sp7ByvWw0XmsQa',
	BanAntycheat = 'https://discord.com/api/webhooks/1459725034846421002/qd99a3PexC0UOV0eOqh3jED7bTgE9PiZ0oAqBsZKbV2bHpf8B0hLiNFJLR8U70rtNdzW'
}

local function SplitIdentifier(entry)
	return entry:match("^(%a+):(.+)$")
end

local function MapIdentifierToColumn(identifierType)
	local columnMap = {
		steam = "steamhex",
		license = "license",
		licencneid = "license",
		license2 = "license2",
		ip = "ip",
		discord = "discord",
		xbl = "xbl",
		live = "live",
		fivem = "fivem"
	}
	return columnMap[identifierType] or identifierType
end

local function ExtractIdentifiers(src)
	local identifiers = {
		id = src,
		name = GetPlayerName(src),
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

	local identifierMap = {
		steam = "steamid",
		ip = "ip",
		discord = "discord",
		license2 = "license2",
		license = "license",
		xbl = "xbl",
		live = "live",
		fivem = "fivem"
	}

	for _, entry in ipairs(GetPlayerIdentifiers(src)) do
		local typ, val = SplitIdentifier(entry)
		if typ and identifierMap[typ] then
			identifiers[identifierMap[typ]] = val
		end
	end

	for _, t in ipairs(GetPlayerTokens(src)) do
		table.insert(identifiers.hwid, t)
	end

	return identifiers
end

local function FormatDateLegacy()
	return os.date("%Y-%m-%d %H:%M:%S")
end

local function formatDate(date)
	return string.format('%02d/%02d/%04d %02d:%02d', date.day, date.month, date.year, date.hour, date.min)
end

local function formatPolishDate(timestamp)
	local months = {
		"stycznia", "lutego", "marca", "kwietnia", "maja", "czerwca",
		"lipca", "sierpnia", "września", "października", "listopada", "grudnia"
	}
	local date = os.date('*t', timestamp)
	return string.format('%d %s %d %02d:%02d', date.day, months[date.month], date.year, date.hour, date.min)
end

local function sendToDiscord(webhook, embeds, content)
	PerformHttpRequest(webhook, function(_, _, _) end, 'POST', json.encode({ username = 'ExoticRP - BanRoom', embeds = embeds, content = content }), { ['Content-Type'] = 'application/json' })
	Wait(1000)
	PerformHttpRequest(Webhooks.ServerBanWebhook, function(_, _, _) end, 'POST', json.encode({ username = 'ExoticRP - BanRoom', embeds = embeds, content = content }), { ['Content-Type'] = 'application/json' })
end

local function CalculateBanDuration(timeInHours)
	if timeInHours == -1 then
		return -1
	end
	return os.time() + (tonumber(timeInHours) * 3600)
end

local function FormatBanTime(expiredTime)
	local tempsrestant = (tonumber(expiredTime) - os.time()) / 60
	local txtday, txthrs, txtminutes

	if tempsrestant >= 1440 then
		local day = tempsrestant / 1440
		txtday = math.floor(day)
		local hrs = (day - txtday) * 24
		txthrs = math.floor(hrs)
		txtminutes = math.ceil((hrs - txthrs) * 60)
	elseif tempsrestant >= 60 then
		txtday = 0
		txthrs = math.floor(tempsrestant / 60)
		txtminutes = math.ceil((tempsrestant / 60 - txthrs) * 60)
	else
		txtday = 0
		txthrs = 0
		txtminutes = math.ceil(tempsrestant)
	end

	return txtday, txthrs, txtminutes
end

local function CreateLoadingCard(text, dot)
	return [==[{]==] .. [[
		"type": "AdaptiveCard",
		"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
		"version": "1.5",
		"body": [
			{
				"type": "Container",
				"items": [
					{
						"type": "Image",
						"url": "]] .. LOGO_URL .. [[",
						"size": "Large",
						"horizontalAlignment": "Center",
						"selectAction": {
							"type": "Action.OpenUrl",
							"url": "]] .. DISCORD_INVITE_URL .. [["
						}
					},
					{
						"type": "Image",
						"url": "]] .. LOADING_GIF_URL .. [[",
						"size": "Large",
						"horizontalAlignment": "Center",
						"altText": ""
					},
					{
						"type": "TextBlock",
						"text": "]] .. text .. (dot or "") .. [[",
						"wrap": true,
						"size": "Medium",
						"horizontalAlignment": "Center",
						"weight": "Default"
					}
				],
				"style": "default",
				"bleed": true,
				"height": "stretch"
			}
		]
	}]]
end

local function CreateErrorCard(message, submessage)
	local submessageText = submessage and [[
					{
						"type": "TextBlock",
						"text": "]] .. submessage .. [[",
						"wrap": true,
						"size": "Medium",
						"horizontalAlignment": "Left",
						"weight": "Default"
					}]] or ""

	return [==[{]==] .. [[
		"type": "AdaptiveCard",
		"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
		"version": "1.5",
		"body": [
			{
				"type": "ColumnSet",
				"columns": [
					{
						"type": "Column",
						"width": "auto",
						"items": [
							{
								"type": "Image",
								"url": "]] .. LOGO_URL .. [[",
								"size": "Large",
								"horizontalAlignment": "Center",
								"selectAction": {
									"type": "Action.OpenUrl",
									"url": "]] .. DISCORD_INVITE_URL .. [["
								}
							}
						]
					},
					{
						"type": "Column",
						"width": "stretch",
						"verticalContentAlignment": "Center",
						"items": [
							{
								"type": "TextBlock",
								"text": "]] .. message .. [[",
								"wrap": true,
								"size": "Medium",
								"horizontalAlignment": "Left",
								"weight": "Default"
							},]] .. submessageText .. [[
						]
					}
				]
			}
		]
	}]]
end

local function CreateSimpleCard(message)
	return [==[{]==] .. [[
		"type": "AdaptiveCard",
		"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
		"version": "1.5",
		"body": [
			{
				"type": "Container",
				"items": [
					{
						"type": "Image",
						"url": "]] .. LOGO_URL .. [[",
						"size": "Large",
						"horizontalAlignment": "Center",
						"selectAction": {
							"type": "Action.OpenUrl",
							"url": "]] .. DISCORD_INVITE_URL .. [["
						}
					},
					{
						"type": "TextBlock",
						"text": "]] .. message .. [[",
						"wrap": true,
						"size": "Large",
						"horizontalAlignment": "Center",
						"weight": "Default"
					}
				],
				"style": "default",
				"bleed": true,
				"height": "stretch"
			}
		]
	}]]
end

local function CreateBanCard(bannedby, reason, banid, timeRemaining)
	local timeText = timeRemaining and [[
							{
								"type": "TextBlock",
								"text": "Pozostały czas: ]] .. timeRemaining .. [[",
								"wrap": true,
								"size": "Medium",
								"horizontalAlignment": "Center",
								"weight": "Default"
							},]] or ""

	local titleText = timeRemaining and "Zostałeś zbanowany na serwerze ExoticRP" or "Zostałeś zbanowany permanentnie na serwerze ExoticRP"

	return [==[{]==] .. [[
		"type": "AdaptiveCard",
		"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
		"version": "1.5",
		"body": [
			{
				"type": "Container",
				"items": [
					{
						"type": "Image",
						"url": "]] .. LOGO_URL .. [[",
						"size": "Large",
						"horizontalAlignment": "Center",
						"selectAction": {
							"type": "Action.OpenUrl",
							"url": "]] .. DISCORD_INVITE_URL .. [[" 
						}
					},
					{
						"type": "TextBlock",
						"text": "]] .. titleText .. [[",
						"wrap": true,
						"size": "Large",
						"horizontalAlignment": "Center",
						"weight": "Default"
					},]] .. (timeText ~= "" and timeText or "") .. [[
					{
						"type": "TextBlock",
						"text": "Administrator banujący: ]] .. bannedby .. [[",
						"wrap": true,
						"size": "Medium",
						"horizontalAlignment": "Center",
						"weight": "Default"
					},
					{
						"type": "TextBlock",
						"text": "Powód: ]] .. reason .. [[",
						"wrap": true,
						"size": "Medium",
						"horizontalAlignment": "Center",
						"weight": "Default"
					},
					{
						"type": "TextBlock",
						"text": "Ban ID: ]] .. banid .. [[",
						"wrap": true,
						"size": "Medium",
						"horizontalAlignment": "Center",
						"weight": "Default"
					}
				],
				"style": "default",
				"bleed": true,
				"height": "stretch"
			}
		]
	}]]
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
	local src = source

	deferrals.defer()
	deferrals.update("Wczytywanie...")

	print('[connection] Player [' .. GetPlayerName(src) .. '] connecting to server')

	local dot = ""
	for i = 1, math.random(3, 4) do
		deferrals.presentCard(CreateLoadingCard("Zaraz rozpocznie się łączenie", dot))
		dot = dot .. "."
		Wait(700)
	end

	local Identifiers = ExtractIdentifiers(src)

	dot = ""
	for i = 1, math.random(3, 4) do
		deferrals.presentCard(CreateLoadingCard("Pobieranie Identyfikatorów", dot))
		dot = dot .. "."
		Wait(700)
	end

	if not Identifiers then
		setKickReason("Generalny błąd serwisu! \n Spróbuj ponownie")
		deferrals.presentCard(CreateErrorCard(
			"Nie wykryto identyfikatora [All] upewnij się, że problem nie leży po twojej stronie.",
			"W razie problemów skontaktuj się z administracją na serwerze discord.gg/exoticrp"
		))
		CancelEvent()
	elseif Identifiers.discord == "Brak" then
		setKickReason("Musisz połączyć fivem'a z kontem discord!")
		deferrals.presentCard(CreateErrorCard(
			"Nie wykryto identyfikatora [Discord] upewnij się, że twój FiveM jest poprawnie połączony z twoim kontem discord.",
			"W razie problemów skontaktuj się z administracją na serwerze discord.gg/exoticrp"
		))
		CancelEvent()
	elseif Identifiers.license == "Brak" then
		setKickReason("Nie wykryto licencji Rockstar Games!")
		deferrals.presentCard(CreateErrorCard(
			"Nie wykryto identyfikatora [Rockstar License] upewnij się, że w tle masz włączony program Social Club.",
			"W razie problemów skontaktuj się z administracją na serwerze discord.gg/exoticrp"
		))
		CancelEvent()
	elseif isRestarting then
		setKickReason("Trwa Restart...")
		deferrals.presentCard(CreateErrorCard(
			"Trwa restart serwera, czekaj cierpliwie na ponowne uruchomienie!",
			"W razie problemów skontaktuj się z administracją na serwerze discord.gg/exoticrp"
		))
		CancelEvent()
	elseif CheckBanlist(src, deferrals, false) then
		local _, reason, expired, bannedby, banid = CheckBanlist(src, nil, true)
		bannedby = bannedby or 'Administracja ExoticRP'
		banid = banid or "Brak"
		expired = expired or 24

		if tonumber(expired) == -1 then
			setKickReason("Zostałeś zbanowany permanentnie na serwerze ExoticRP\nAdministrator: " ..
				bannedby .. "\nPowód: " .. reason .. "\nBan ID: " .. banid)
			deferrals.presentCard(CreateBanCard(bannedby, reason, banid))
			CancelEvent()
		elseif tonumber(expired) > os.time() then
			local txtday, txthrs, txtminutes = FormatBanTime(expired)
			local timeText = txtday .. " dni " .. txthrs .. " godzin " .. txtminutes .. " minut"

			setKickReason("Zostałeś zbanowany na serwerze ExoticRP\nAdministrator: " ..
				bannedby ..
				"\nPowód: " ..
				reason ..
				"\nPozostały czas: " ..
				timeText .. "\nBan ID: " .. banid)
			deferrals.presentCard(CreateBanCard(bannedby, reason, banid, timeText))
			CancelEvent()
		elseif tonumber(expired) <= os.time() then
			MySQL.update(
				'UPDATE bans SET reason=@reason, expired=@expired, bannedby=@bannedby, isBanned=@isBanned WHERE license=@license',
				{
					['@license'] = Identifiers.license,
					['@reason'] = "Brak",
					['@expired'] = nil,
					['@bannedby'] = nil,
					['@isBanned'] = 0
				}, function(rowsChanged)
					if rowsChanged and rowsChanged > 0 and BanList[Identifiers.license] then
						BanList[Identifiers.license].isBanned = 0
						BanList[Identifiers.license].expired = nil
						BanList[Identifiers.license].bannedby = nil
						BanList[Identifiers.license].reason = "Brak"
					end
				end)

			setKickReason("Twój ban dobiegł końca, połącz się ponownie aby wejść na serwer")
			deferrals.presentCard(CreateSimpleCard("Twój ban dobiegł końca połącz się ponownie, aby wejść na serwer."))
			CancelEvent()
		else
			setKickReason("Wystąpił błąd zgłoś to do ExoticRP DevTeam")
			deferrals.presentCard(CreateSimpleCard("Wystąpił błąd podczas ładowania zgłoś ten błąd do ExoticRP DevTeam."))
			CancelEvent()
		end
	else
		if not weryfikacjaDiscord then
			Wait(1000)
			deferrals.done()
		else
			if not Identifiers.discord or Identifiers.discord == "Brak" then
				setKickReason("Musisz połączyć FiveM z kontem Discord!")
				deferrals.presentCard(CreateErrorCard(
					"Nie wykryto identyfikatora Discord. Upewnij się, że twój FiveM jest poprawnie połączony z kontem Discord.",
					"W razie problemów skontaktuj się z administracją na serwerze discord.gg/exoticrp"
				))
				CancelEvent()
				return
			end

			local discordId = Identifiers.discord
			if discordId:find(":") then
				discordId = discordId:match("discord:(.+)") or discordId
			end

			if not discordId or discordId == "" or not discordId:match("^%d+$") then
				setKickReason("Nieprawidłowy identyfikator Discord!")
				deferrals.presentCard(CreateErrorCard(
					"Nieprawidłowy identyfikator Discord. Upewnij się, że twój FiveM jest poprawnie połączony z kontem Discord.",
					"W razie problemów skontaktuj się z administracją na serwerze discord.gg/exoticrp"
				))
				CancelEvent()
				return
			end

			deferrals.update("Weryfikacja członkostwa na serwerze Discord...")
			
			local apiUrl = "https://discord.com/api/v10/guilds/" .. DISCORD_GUILD_ID .. "/members/" .. discordId
			
			PerformHttpRequest(apiUrl,
				function(err, text, headers)
					if err ~= 200 then
						if err == 401 then
							Wait(1000)
							deferrals.done()
							return
						end
						
						if err == 404 then
							Wait(1000)
							deferrals.done()
							return
						end
						
						Wait(1000)
						deferrals.done()
						return
					end

					if not text or text == "" then
						Wait(1000)
						deferrals.done()
						return
					end
					
					local DiscordData = json.decode(text)
					
					if not DiscordData then
						Wait(1000)
						deferrals.done()
						return
					end
					
					local hasARole = false
					if DiscordData.roles and type(DiscordData.roles) == "table" then
						for _, role in pairs(DiscordData.roles) do
							local roleStr = tostring(role)
							local adminRoleStr = tostring(ADMIN_ROLE_ID)
							if roleStr == adminRoleStr then
								hasARole = true
								break
							end
						end
					end

					if not hasARole then
						setKickReason("Nieautoryzowane konto Discord. Upewnij się, że jesteś zalogowany na poprawne konto i masz wymaganą rolę.")
						deferrals.presentCard(CreateSimpleCard("Wykryto nieautoryzowane konto Discord. Upewnij się, że jesteś zalogowany na poprawne konto i znajdujesz się na naszym serwerze Discord z odpowiednią rolą!"))
						esx_core:SendLog(src,
							"Weryfikacja Discord",
							"Gracz " .. GetPlayerName(src) .. " (Discord ID: " .. discordId .. ") próbował dołączyć bez wymaganej roli Discord.",
							"connection")
						CancelEvent()
					else
						Wait(1000)
						deferrals.done()
					end
				end, 'GET', nil, { 
					['Content-Type'] = 'application/json', 
					['Authorization'] = 'Bot ' .. DC_TOKEN,
					['User-Agent'] = 'ExoticRP-Server/1.0'
				})
		end
	end
end)

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		LoadBanList()
		print('[connection] Załadowano listę banów z bazy danych')
	end
end)

function EntriesInTable(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function LoadBanList()
	BanList = {}
	MySQL.query('SELECT * FROM bans', function(data)
		if data then
			local count = 0
			for _, inf in pairs(data) do
				if inf.license then
					BanList[inf.license] = {}
					for k, v in pairs(inf) do
						if k ~= 'license' then
							BanList[inf.license][k] = v
						end
					end
					count = count + 1
				end
			end
			print('[connection] Załadowano ' .. count .. ' wpisów z bazy danych')
		else
			print('[connection] Błąd podczas ładowania listy banów z bazy danych')
		end
	end)
end

local function CheckBanMatch(Identifiers, license, values, source, log)
	if Identifiers.license == license then
		if log then
			print(string.format("[ban] Zbanowany gracz [%s] próbował połączyć się na serwer.\nWykrycie: Licencja\n[BanID] %s",
				GetPlayerName(source), values.id))
		end
		return true, values.reason, values.expired, values.bannedby, values.id
	elseif Identifiers.discord == values.discord then
		if log then
			print(string.format("[ban] Zbanowany gracz [%s] próbował połączyć się na serwer.\nWykrycie: Discord\n[BanID] %s",
				GetPlayerName(source), values.id))
		end
		return true, values.reason, values.expired, values.bannedby, values.id
	elseif values.xbl ~= "Brak" and Identifiers.xbl == values.xbl then
		if log then
			print(string.format("[ban] Zbanowany gracz [%s] próbował połączyć się na serwer.\nWykrycie: XBL\n[BanID] %s",
				GetPlayerName(source), values.id))
		end
		return true, values.reason, values.expired, values.bannedby, values.id
	elseif values.live ~= "Brak" and Identifiers.live == values.live then
		if log then
			print(string.format("[ban] Zbanowany gracz [%s] próbował połączyć się na serwer.\nWykrycie: Live\n[BanID] %s",
				GetPlayerName(source), values.id))
		end
		return true, values.reason, values.expired, values.bannedby, values.id
	elseif values.ip ~= "Brak" and Identifiers.ip == values.ip then
		if log then
			print(string.format("[ban] Zbanowany gracz [%s] próbował połączyć się na serwer.\nWykrycie: IP\n[BanID] %s",
				GetPlayerName(source), values.id))
		end
		return true, values.reason, values.expired, values.bannedby, values.id
	end
	return false
end

function CheckBanlist(source, deferrals, log)
	local Identifiers = ExtractIdentifiers(source)
	local BanEntriesOveral = EntriesInTable(BanList)
	local seconds = 5

	if deferrals then
		for i = 2, 5 do
			seconds = seconds - 1
			deferrals.presentCard([==[{]==] .. [[
				"type": "AdaptiveCard",
				"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
				"version": "1.5",
				"body": [
					{
						"type": "Container",
						"items": [
							{
								"type": "Image",
								"url": "]] .. LOGO_URL .. [[",
								"size": "Large",
								"horizontalAlignment": "Center",
								"selectAction": {
									"type": "Action.OpenUrl",
									"url": "]] .. DISCORD_INVITE_URL .. [["
								}
							},
							{
								"type": "Image",
								"url": "]] .. LOADING_GIF_URL .. [[",
								"size": "Large",
								"horizontalAlignment": "Center",
								"altText": ""
							},
							{
								"type": "TextBlock",
								"text": "Połączenie z serwerem nastąpi, za ]] .. (seconds or 1) .. [[ sekund.",
								"wrap": true,
								"size": "Large",
								"horizontalAlignment": "Center",
								"weight": "Default"
							},
							{
								"type": "TextBlock",
								"text": "Nasz serwer odwiedziło ]] .. BanEntriesOveral .. [[ osób",
								"wrap": true,
								"size": "Small",
								"horizontalAlignment": "Center",
								"weight": "Default"
							}
						],
						"style": "default",
						"bleed": true,
						"height": "stretch"
					}
				]
			}]])
			Wait(1000)
		end
	end

	for license, values in pairs(BanList) do
		if values.isBanned == 1 or values.isBanned == true then
			local matched, reason, expired, bannedby, banid = CheckBanMatch(Identifiers, license, values, source, log)
			if matched then
				return matched, reason, expired, bannedby, banid
			end
		end
	end

	local currentDate = FormatDateLegacy()
	local existingResult = MySQL.query.await("SELECT * FROM bans WHERE license = ?", { Identifiers.license })
	local getID = 0

	if existingResult and #existingResult > 0 then
		getID = existingResult[1].id
		MySQL.update(
			'UPDATE `bans` SET `xbl` = ?, `steamhex` = ?, `live` = ?, `ip` = ?, `discord` = ?, `hwid` = ?, `name` = ?, `added` = ? WHERE license = ?',
			{ Identifiers.xbl, Identifiers.steamid, Identifiers.live, Identifiers.ip, Identifiers.discord, json.encode(Identifiers.hwid),
				Identifiers.name, currentDate, Identifiers.license }, function(rowsChanged)
				if rowsChanged and rowsChanged > 0 then
					BanList[Identifiers.license] = {
						id = getID,
						steamhex = Identifiers.steamid,
						xbl = Identifiers.xbl,
						live = Identifiers.live,
						ip = Identifiers.ip,
						discord = Identifiers.discord,
						hwid = json.encode(Identifiers.hwid),
						name = Identifiers.name,
						added = currentDate,
						isBanned = existingResult[1].isBanned or 0,
						reason = existingResult[1].reason,
						expired = existingResult[1].expired,
						bannedby = existingResult[1].bannedby,
					}
				end
			end)
	else
		MySQL.update(
			'INSERT INTO `bans` (`license`, `steamhex`, `xbl`, `live`, `ip`, `discord`, `hwid`, `name`, `added`, `isBanned`) VALUES (@license, @steamhex, @xbl, @live, @ip, @discord, @hwid, @name, @added, @isBanned)',
			{
				['@license'] = Identifiers.license,
				['@steamhex'] = Identifiers.steamid,
				['@xbl'] = Identifiers.xbl,
				['@live'] = Identifiers.live,
				['@ip'] = Identifiers.ip,
				['@discord'] = Identifiers.discord,
				['@hwid'] = json.encode(Identifiers.hwid),
				['@name'] = Identifiers.name,
				['@added'] = currentDate,
				['@isBanned'] = 0
			}, function(rowsChanged)
				if rowsChanged and rowsChanged > 0 then
					local newResult = MySQL.query.await("SELECT id FROM bans WHERE license = ? ORDER BY id DESC LIMIT 1", { Identifiers.license })
					local newID = 0
					if newResult and #newResult > 0 then
						newID = newResult[1].id
					end

					BanList[Identifiers.license] = {
						id = newID,
						steamhex = Identifiers.steamid,
						xbl = Identifiers.xbl,
						live = Identifiers.live,
						ip = Identifiers.ip,
						discord = Identifiers.discord,
						hwid = json.encode(Identifiers.hwid),
						name = Identifiers.name,
						added = currentDate,
						isBanned = 0,
					}
				end
			end)
	end

	return false
end

local function CreateBanEmbed(source, reason, expiredText, bannedby, banID, title)
    local date = os.date('*t')
    local dateStr = formatDate(date)
    local lengthText = expiredText == "PERM" and "**PERMANENTNY**" or formatPolishDate(expiredText)
    
    return {
        {
            color = 16744448,
            title = title,

            thumbnail = {
                url = THUMBNAIL_URL
            },
            description = string.format(
                "```\n" ..
                "Nick: %s\n" ..
                "Powód: %s\n" ..
                "Długość: %s\n" ..
				"Ban ID: %s\n" ..
                "Zbanowany przez: %s\n" ..
                "```\n" ..
                "**Aby się odwołać utwórz ticket o unban na kanale** \n<#1318654295960453170>",
                GetPlayerName(source) or 'Nieznane',
                reason,
                lengthText,
                banID,
                bannedby
            ),
            footer = {
                text = "ExoticRP - BanRoom " .. dateStr,
                icon_url = THUMBNAIL_URL
            }
        }
    }
end

local function CreateBanMessage(time, bannedby, reason, banID)
	if time == -1 then
		return string.format("Zostałeś zbanowany permanentnie na tym serwerze przez %s. \nPowód: %s \nBAN ID: %s", bannedby, reason, banID)
	else
		return string.format("Zostałeś zbanowany przez %s. \nPowód: %s \nBAN ID: %s", bannedby, reason, banID)
	end
end

local function UpdateBanListEntry(identifiers, getID, reason, currentDate, unixDuration, bannedby)
	BanList[identifiers.license] = {
		id = getID,
		xbl = identifiers.xbl,
		live = identifiers.live,
		ip = identifiers.ip,
		discord = identifiers.discord,
		hwid = json.encode(identifiers.hwid),
		name = identifiers.name,
		reason = reason,
		added = currentDate,
		expired = unixDuration,
		bannedby = bannedby,
		isBanned = 1,
	}
end

local function BanPlayer(source, time, reason, bannedby)
	if not source then return end

	reason = reason or "Brak"
	bannedby = bannedby or "Brak"

	local identifiers = ExtractIdentifiers(source)
	local currentDate = FormatDateLegacy()
	local unixDuration = CalculateBanDuration(time)
	local result = MySQL.query.await("SELECT id FROM bans WHERE license = ?", { identifiers.license })
	local banID = 0

	if result and #result > 0 then
		banID = result[1].id
	else
		local doubleCheck = MySQL.query.await("SELECT id FROM bans WHERE license = ?", { identifiers.license })
		if doubleCheck and #doubleCheck > 0 then
			banID = doubleCheck[1].id
		end
	end

	local function ProcessBan(getID)
		local discordMention = identifiers.discord ~= 'nieznane' and '<@' .. identifiers.discord .. '>' or ''
		if getID == 0 then
			MySQL.update(
				'INSERT INTO `bans` (`license`, `steamhex`, `xbl`, `live`, `ip`, `discord`, `hwid`, `name`, `reason`, `added`, `expired`, `bannedby`, `isBanned`) VALUES (@license, @steamhex, @xbl, @live, @ip, @discord, @hwid, @name, @reason, @added, @expired, @bannedby, @isBanned)',
				{
					['@license'] = identifiers.license,
					['@steamhex'] = identifiers.steamid,
					['@xbl'] = identifiers.xbl,
					['@live'] = identifiers.live,
					['@ip'] = identifiers.ip,
					['@discord'] = identifiers.discord,
					['@hwid'] = json.encode(identifiers.hwid),
					['@name'] = identifiers.name,
					['@reason'] = reason,
					['@added'] = currentDate,
					['@expired'] = unixDuration,
					['@bannedby'] = bannedby,
					['@isBanned'] = 1
				},
				function(rowsChanged)
					if rowsChanged and rowsChanged > 0 then
						local newResult = MySQL.query.await("SELECT id FROM bans WHERE license = ? ORDER BY id DESC LIMIT 1", { identifiers.license })
						local newID = 0
						if newResult and #newResult > 0 then
							newID = newResult[1].id
						end
						banID = newID

						UpdateBanListEntry(identifiers, newID, reason, currentDate, unixDuration, bannedby)

						local expiredText = unixDuration == -1 and "PERM" or unixDuration
						sendToDiscord(Webhooks.BanWebhook, CreateBanEmbed(source, reason, expiredText, bannedby, newID, "ExoticRP - BanSystem (BANID)"), discordMention)
						DropPlayer(source, CreateBanMessage(time, bannedby, reason, newID))
					end
				end
			)
		else
			MySQL.update(
				'UPDATE bans SET xbl=@xbl, live=@live, ip=@ip, discord=@discord, hwid=@hwid, name=@name, reason=@reason, added=@added, expired=@expired, bannedby=@bannedby, isBanned=1 WHERE license=@license',
				{
					['@license'] = identifiers.license,
					['@xbl'] = identifiers.xbl,
					['@live'] = identifiers.live,
					['@ip'] = identifiers.ip,
					['@discord'] = identifiers.discord,
					['@hwid'] = json.encode(identifiers.hwid),
					['@name'] = identifiers.name,
					['@reason'] = reason,
					['@added'] = currentDate,
					['@expired'] = unixDuration,
					['@bannedby'] = bannedby
				},
				function(rowsChanged)
					if rowsChanged and rowsChanged > 0 then
						UpdateBanListEntry(identifiers, getID, reason, currentDate, unixDuration, bannedby)

						local expiredText = unixDuration == -1 and "PERM" or unixDuration
						sendToDiscord(Webhooks.BanWebhook, CreateBanEmbed(source, reason, expiredText, bannedby, getID, "ExoticRP - BanSystem (BANID)"), discordMention)
						DropPlayer(source, CreateBanMessage(time, bannedby, reason, getID))
					end
				end
			)
		end
	end

	ProcessBan(banID)
end
exports('BanPlayer', BanPlayer)

ESX.RegisterCommand("banid", { 'founder', 'developer', 'managment', 'headadmin', 'admin', 'trialadmin', 'seniormod', 'mod', 'trialmod', 'support' },
	function(xPlayer, args, showError)
		if not args.playerId then
			if xPlayer then
				xPlayer.showNotification("~r~Nie znaleziono gracza o podanym ID!")
			end
			return
		end

		local bannedby = xPlayer and xPlayer.name or "ADMINISTRACJA"
		local playerName = GetPlayerName(args.playerId.source)
		BanPlayer(args.playerId.source, args.time, args.reason, bannedby)

		if xPlayer then
			xPlayer.showNotification(string.format("~g~Gracz %s został zbanowany! (Ban ID zostanie wyświetlone w Discord)", playerName))
			esx_core:SendLog(xPlayer.source, "Banowanie gracza",
				string.format("Gracz %s (ID: %d) został zbanowany przez %s. Powód: %s",
					playerName, args.playerId.source, bannedby, args.reason),
				'admin-commands')
		end
	end, true, {
		help = "Komenda do banowania gracza po id",
		validate = true,
		arguments = {
			{ name = 'playerId', help = "ID gracza", type = 'player' },
			{ name = 'time', help = "Czas w godzinach", type = 'number' },
			{ name = 'reason', help = 'Powód w ""', type = 'merge' },
		}
	})

ESX.RegisterCommand("banoffline", { 'founder', 'developer', 'managment', 'headadmin', 'admin', 'trialadmin', 'seniormod', 'mod', 'trialmod', 'support' },
	function(xPlayer, args, showError)
		local typ, val = SplitIdentifier(args.identifier)
		
		if not typ or not val then
			if xPlayer then
				xPlayer.showNotification("~r~Nieprawidłowy format identyfikatora! Użyj formatu: typ:wartość (np. steam:11000016578bdbc)")
			else
				print("Nieprawidłowy format identyfikatora! Użyj formatu: typ:wartość (np. steam:11000016578bdbc)")
			end
			return
		end
		
		local columnName = MapIdentifierToColumn(typ)
		local currentDate = FormatDateLegacy()
		local sqlString = "SELECT * FROM bans WHERE " .. columnName .. " = ?"
		local result = MySQL.query.await(sqlString, { val })
		local bannedby = xPlayer and xPlayer.name or "ADMINISTRACJA"

		if not result or #result == 0 then
			if xPlayer then
				xPlayer.showNotification("~r~Nie znaleziono gracza o podanym identyfikatorze w bazie danych!")
			else
				print("Nie znaleziono gracza o podanym identyfikatorze w bazie danych!")
			end
			return
		end

		local getID = result[1].id
		local unixDuration = CalculateBanDuration(args.time)
		local playerName = result[1].name or "Nieznany"
		local expiredText = unixDuration == -1 and "PERM" or unixDuration
		local date = os.date('*t')
		local dateStr = formatDate(date)

		MySQL.update(
			'UPDATE bans SET reason=@reason, added=@added, expired=@expired, bannedby=@bannedby, isBanned=@isBanned WHERE ' ..
			columnName .. '=@identifier',
			{
				['@identifier'] = val,
				['@reason'] = args.reason,
				['@added'] = currentDate,
				['@expired'] = unixDuration,
				['@bannedby'] = bannedby,
				['@isBanned'] = 1
			}, function(rowsChanged)
				if rowsChanged and rowsChanged > 0 and result and #result > 0 then
					BanList[result[1].license] = {
						id = getID,
						xbl = result[1].xbl,
						live = result[1].live,
						ip = result[1].ip,
						discord = result[1].discord,
						hwid = result[1].hwid,
						name = result[1].name,
						reason = args.reason,
						added = currentDate,
						expired = unixDuration,
						bannedby = bannedby,
						isBanned = 1,
					}

					local lengthText = expiredText == "PERM" and "**PERMANENTNY**" or formatPolishDate(expiredText)
					local discordMention = result[1].discord ~= 'nieznane' and '<@' .. result[1].discord .. '>' or ''

					local BanOfflineEmbed = {
						{
							color = 16744448,
							title = "ExoticRP - BanSystem (OFFLINE BAN)",

							thumbnail = {
								url = THUMBNAIL_URL
							},
							description = string.format(
								"```\n" ..
								"Nick: %s\n" ..
								"Powód: %s\n" ..
								"Długość: %s\n" ..
								"Ban ID: %s\n" ..
								"Zbanowany przez: %s\n" ..
								"```\n" ..
								"**Aby się odwołać utwórz ticket o unban na kanale** \n<#1318654295960453170>",
								playerName,
								args.reason,
								lengthText,
								getID,
								bannedby
							),
							footer = {
								text = "ExoticRP - BanRoom " .. dateStr,
								icon_url = THUMBNAIL_URL
							}
						}
					}
					sendToDiscord(Webhooks.BanWebhook, BanOfflineEmbed, discordMention)

					if xPlayer then
						xPlayer.showNotification(string.format("~g~Gracz %s został zbanowany offline! (Ban ID: %d)", playerName, getID))
						esx_core:SendLog(xPlayer.source, "Banowanie gracza offline",
							string.format("Gracz %s (ID: %s) został zbanowany przez %s. Powód: %s (Ban ID: %d)",
								playerName, args.identifier, bannedby, args.reason, getID),
							'admin-commands')
					else
						print(string.format("[BAN] Gracz %s (ID: %s) został zbanowany offline przez [PROMPT]. Powód: %s (Ban ID: %d)",
							playerName, args.identifier, args.reason, getID))
					end
				else
					if xPlayer then
						xPlayer.showNotification("~r~Wystąpił błąd podczas banowania gracza offline!")
					else
						print("Wystąpił błąd podczas banowania gracza offline!")
					end
				end
			end)
	end, true, {
		help = "Komenda do banowania gracza offline",
		validate = true,
		arguments = {
			{ name = 'identifier', help = "Hex/license", type = 'string' },
			{ name = 'time', help = "Czas w godzinach", type = 'number' },
			{ name = 'reason', help = 'Powód w ""', type = 'merge' },
		}
	})

ESX.RegisterCommand("bancheck", { 'founder', 'developer', 'managment', 'headadmin', 'admin', 'trialadmin', 'seniormod', 'mod', 'trialmod', 'support' },
	function(xPlayer, args, showError)
		if not args.banId or type(args.banId) ~= 'number' or args.banId <= 0 then
			if xPlayer then
				xPlayer.showNotification("~r~Nieprawidłowe ID bana")
			else
				print("Nieprawidłowe ID bana")
			end
			return
		end

		local result = MySQL.single.await("SELECT * FROM bans WHERE id = ?", { args.banId })

		if not result then
			if xPlayer then
				xPlayer.showNotification("~r~Ban o podanym ID nie istnieje")
			else
				print("Ban o podanym ID nie istnieje")
			end
			return
		end

		print(("=== INFORMACJE O BANIE ID: %d ==="):format(args.banId))
		print(("Gracz: %s"):format(result.name or "Nieznany"))
		print(("Licencja: %s"):format(result.license or "Brak"))
		print(("Powód: %s"):format(result.reason or "Brak powodu"))
		print(("Data bana: %s"):format(result.added or "Nieznana"))
		print(("Data wygaśnięcia: %s"):format(result.expired and os.date("%Y-%m-%d %H:%M:%S", result.expired) or "Permanentny"))
		print(("Zbanowany przez: %s"):format(result.bannedby or "Nieznany"))
		print("=====================================")

		if xPlayer then
			xPlayer.showNotification(string.format("~g~Informacje o banie ID: %d wyświetlone w konsoli (F8)", args.banId))
			esx_core:SendLog(xPlayer.source, "Sprawdzanie bana",
				string.format("Sprawdzono ban ID: %d (Gracz: %s)", args.banId, result.name or "Nieznany"),
				'admin-commands')
		end
	end, true, {
		help = "Sprawdź informacje o banie po ID",
		validate = true,
		arguments = {
			{ name = 'banId', help = "ID bana do sprawdzenia", type = 'number' },
		}
	})

ESX.RegisterCommand("banedit", { 'founder', 'developer', 'managment', 'headadmin', 'admin', 'trialadmin', 'seniormod', 'mod', 'trialmod', 'support' },
	function(xPlayer, args, showError)
		if not args.banId or type(args.banId) ~= 'number' or args.banId <= 0 then
			if xPlayer then
				xPlayer.showNotification("~r~Nieprawidłowe ID bana")
			else
				print("Nieprawidłowe ID bana")
			end
			return
		end

		local currentDate = FormatDateLegacy()
		local result = MySQL.query.await("SELECT * FROM bans WHERE id = ?", { args.banId })

		if not result or #result == 0 then
			if xPlayer then
				xPlayer.showNotification("~r~Ban o podanym ID nie istnieje")
			else
				print("Ban o podanym ID nie istnieje")
			end
			return
		end

		local getID = result[1].id
		local bannedby = xPlayer and xPlayer.name or "ADMINISTRACJA"
		local unixDuration = CalculateBanDuration(args.time)
		local playerName = result[1].name or "Nieznany"
		local expiredText = unixDuration == -1 and "PERM" or unixDuration
		local date = os.date('*t')
		local dateStr = formatDate(date)

		MySQL.update(
			'UPDATE bans SET added=@added, expired=@expired, bannedby=@bannedby, isBanned=@isBanned WHERE id=@id',
			{
				['@id'] = args.banId,
				['@added'] = currentDate,
				['@expired'] = unixDuration,
				['@bannedby'] = bannedby,
				['@isBanned'] = 1
			}, function(rowsChanged)
				if rowsChanged and rowsChanged > 0 and result and #result > 0 then
					BanList[result[1].license] = {
						id = getID,
						xbl = result[1].xbl,
						live = result[1].live,
						ip = result[1].ip,
						discord = result[1].discord,
						hwid = result[1].hwid,
						name = result[1].name,
						reason = result[1].reason,
						added = currentDate,
						expired = unixDuration,
						bannedby = bannedby,
						isBanned = 1,
					}

					local discordMention = result[1].discord ~= 'nieznane' and '<@' .. result[1].discord .. '>' or ''
					local lengthText = expiredText == "PERM" and "**PERMANENTNY**" or formatPolishDate(expiredText)
					local BanEditEmbed = {
						{
							color = 16744448,
							title = "ExoticRP - BanSystem (EDYCJA BANA)",

							thumbnail = {
								url = THUMBNAIL_URL
							},
							description = string.format(
								"```\n" ..
								"Nick: %s\n" ..
								"Powód: %s\n" ..
								"Ban ID: %s\n" ..
								"Nowy czas wygaśnięcia: %s\n" ..
								"Edytowany przez: %s\n" ..
								"```\n" ..
								"**Aby się odwołać utwórz ticket o unban na kanale** \n<#1318654295960453170>",
								playerName,
								args.reason,
								getID,
								lengthText,
								bannedby
							),
							footer = {
								text = "ExoticRP - BanRoom " .. dateStr,
								icon_url = THUMBNAIL_URL
							}
						}
					}
					sendToDiscord(Webhooks.BanWebhook, BanEditEmbed, discordMention)

					if xPlayer then
						xPlayer.showNotification(string.format("~g~Ban ID: %d został zedytowany!", getID))
						esx_core:SendLog(xPlayer.source, "Edycja bana",
							string.format("Ban ID: %d (Gracz: %s) został zedytowany przez %s. Nowy czas: %s",
								getID, playerName, bannedby, expiredText == "PERM" and "PERM" or os.date("%Y-%m-%d %H:%M:%S", unixDuration)),
							'admin-commands')
					else
						print(string.format("[BAN] Ban ID: %d (Gracz: %s) został zedytowany przez [PROMPT]. Nowy czas: %s",
							getID, playerName, expiredText == "PERM" and "PERM" or os.date("%Y-%m-%d %H:%M:%S", unixDuration)))
					end
				else
					if xPlayer then
						xPlayer.showNotification("~r~Wystąpił błąd podczas edytowania bana!")
					else
						print("Wystąpił błąd podczas edytowania bana!")
					end
				end
			end)
	end, true, {
		help = "Komenda do edytowania bana",
		validate = true,
		arguments = {
			{ name = 'banId', help = "ID Bana", type = 'number' },
			{ name = 'time', help = "Czas w godzinach", type = 'number' },
		}
	})

function UnbanPlayerBySteamHex(steamHex)
	if not steamHex or type(steamHex) ~= "string" or steamHex == "" then
		return false
	end

	local result = MySQL.query.await("SELECT * FROM bans WHERE steamhex = ? AND isBanned = 1", { steamHex })

	if not result or #result == 0 then
		return false
	end

	local ban = result[1]
	local license = ban.license
	local playerName = ban.name or "Nieznany"
	local banId = ban.id
	local unbannedBy = "SKLEP"
	local date = os.date('*t')
	local dateStr = formatDate(date)

	local updateResult = MySQL.query.await('UPDATE bans SET isBanned = 0, reason = "Brak", expired = NULL, bannedby = NULL WHERE steamhex = ? AND isBanned = 1', { steamHex })
	local rowsChanged = updateResult and updateResult.affectedRows or 0

	if rowsChanged > 0 then
		if BanList[license] then
			BanList[license].isBanned = 0
			BanList[license].expired = nil
			BanList[license].bannedby = nil
			BanList[license].reason = "Brak"
		end

        print('Ban removed from list')
		return true
    else
        print('No matching identifier found in the database')
		return false
    end
end
exports('UnbanPlayerBySteamHex', UnbanPlayerBySteamHex)

function ShortenBanBySteamHex(steamHex, newExpiredTimestamp)
	if not steamHex or type(steamHex) ~= "string" or steamHex == "" then
		return false
	end

	if not newExpiredTimestamp or type(newExpiredTimestamp) ~= "number" then
		return false
	end

	local result = MySQL.query.await("SELECT * FROM bans WHERE steamhex = ? AND isBanned = 1", { steamHex })

	if not result or #result == 0 then
		return false
	end

	local ban = result[1]
	local license = ban.license
	local banId = ban.id

	local updateResult = MySQL.query.await('UPDATE bans SET expired = ? WHERE steamhex = ? AND isBanned = 1', { newExpiredTimestamp, steamHex })
	local rowsChanged = updateResult and updateResult.affectedRows or 0

	if rowsChanged > 0 then
		if BanList[license] then
			BanList[license].expired = newExpiredTimestamp
		end

		print(string.format('[BAN] Ban skrócony dla SteamHex: %s (Ban ID: %d, Nowy expired: %d)', steamHex, banId, newExpiredTimestamp))
		return true
	else
		print('No matching identifier found in the database')
		return false
	end
end
exports('ShortenBanBySteamHex', ShortenBanBySteamHex)

ESX.RegisterCommand('unban', { 'founder', 'developer', 'managment', 'headadmin', 'admin', 'trialadmin', 'seniormod', 'mod', 'trialmod', 'support' },
	function(xPlayer, args, showError)
		if not args.id or type(args.id) ~= 'number' or args.id <= 0 then
			if xPlayer then
				xPlayer.showNotification("~r~Nieprawidłowe ID bana")
			else
				print("Nieprawidłowe ID bana")
			end
			return
		end

		local result = MySQL.query.await("SELECT * FROM bans WHERE id = ?", { args.id })

		if not result or #result == 0 then
			if xPlayer then
				xPlayer.showNotification("~r~Ban o podanym ID nie istnieje!")
			else
				print('[ban] Gracz nie znajduje się w bazie danych!')
			end
			return
		end

		local license = result[1].license
		local playerName = result[1].name or "Nieznany"
		local unbannedBy = xPlayer and (xPlayer.name or GetPlayerName(xPlayer.source)) or "ADMINISTRACJA"
		local date = os.date('*t')
		local dateStr = formatDate(date)

		MySQL.update('UPDATE bans SET isBanned = 0, reason = "Brak", expired = NULL, bannedby = NULL WHERE id = ?', { args.id },
			function(rowsChanged)
				if rowsChanged and rowsChanged > 0 then
					if BanList[license] then
						BanList[license].isBanned = 0
						BanList[license].expired = nil
						BanList[license].bannedby = nil
						BanList[license].reason = "Brak"
					end

					local discordMention = result[1].discord ~= 'nieznane' and '<@' .. result[1].discord .. '>' or ''
					local UnbanEmbed = {
						{
							color = 3066993,
							title = "ExoticRP - BanSystem (UNBAN)",

							thumbnail = {
								url = THUMBNAIL_URL
							},
							description = string.format(
								"```\n" ..
								"Nick: %s\n" ..
								"Ban ID: %s\n" ..
								"Odbanowany przez: %s\n" ..
								"```\n" ..
								"**Aby się odwołać utwórz ticket o unban na kanale** \n<#1318654295960453170>",
								playerName,
								args.id,
								unbannedBy
							),
							footer = {
								text = "ExoticRP - BanRoom " .. dateStr,
								icon_url = THUMBNAIL_URL
							}
						}
					}
					sendToDiscord(Webhooks.BanWebhook, UnbanEmbed, discordMention)

					if xPlayer then
						xPlayer.showNotification(string.format("~g~Gracz %s został odbanowany! (Ban ID: %d)", playerName, args.id))
						esx_core:SendLog(xPlayer.source,
							"Odbanowanie gracza",
							string.format("Gracz %s (Ban ID: %d) został odbanowany przez %s",
								playerName, args.id, unbannedBy),
							'admin-commands')
					else
						print(string.format("[BAN] Gracz %s (Ban ID: %d) został odbanowany przez [PROMPT]", playerName, args.id))
						esx_core:SendLog(nil, "Odbanowanie gracza",
							string.format("Gracz %s (Ban ID: %d) został odbanowany przez [PROMPT]", playerName, args.id),
							'admin-commands')
					end
				else
					if xPlayer then
						xPlayer.showNotification("~r~Wystąpił błąd podczas odbanowywania gracza!")
					else
						print("Wystąpił błąd podczas odbanowywania gracza!")
					end
				end
			end)
	end, true, {
		help = "Komenda do odbanowywania gracza",
		validate = true,
		arguments = {
			{ name = 'id', help = "ID Bana", type = 'number' }
		}
	})

ESX.RegisterCommand('refreshbanlist', { 'founder' },
	function(xPlayer, args, showError)
		LoadBanList()
		if xPlayer then
			xPlayer.showNotification('~g~Lista banów została odświeżona!')
			print('[connection] Lista banów została odświeżona przez ' .. GetPlayerName(xPlayer.source))
		else
			print('[connection] Lista banów została odświeżona przez konsolę')
		end
	end, false, {
		help = "Odświeża listę banów z bazy danych (tylko dla foundera)",
		validate = false
	})

AddEventHandler('txAdmin:events:playerBanned', function(data)
	local date = os.date('*t')
	local dateStr = formatDate(date)

	local lengthText = data.expiration == false and "PERMANENTNY" or formatPolishDate(data.expiration)
	local discordId

	for _, id in ipairs(data.targetIds) do
		if id:sub(1, 8) == "discord:" then
			discordId = id:sub(9)
			break
		end
	end
	local discordMention = discordId and ("<@" .. discordId .. ">") or "brak discord"

	local BantxAdminEmbed = {
		{
			color = 16744448,
			title = "ExoticRP - BanSystem (txAdmin)",

			thumbnail = {
				url = THUMBNAIL_URL
			},
			description = string.format(
				"```\n" ..
				"Nick: %s\n" ..
				"Powód: %s\n" ..
				"Długość: %s\n" ..
				"Ban ID: %s\n" ..
				"Zbanowany przez: %s\n" ..
				"```\n" ..
				"**Aby się odwołać utwórz ticket o unban na kanale** \n<#1318654295960453170>",
				data.targetName,
				data.reason,
				lengthText,
				data.actionId,
				data.author
			),
			footer = {
				text = "ExoticRP - BanRoom " .. dateStr,
				icon_url = THUMBNAIL_URL
			}
		}
	}
	sendToDiscord(Webhooks.BanWebhook, BantxAdminEmbed, discordMention)
end)

AddEventHandler("ElectronAC:playerBanned", function(source, reason, details, automatic)
    local date = os.date('*t')
	local dateStr = formatDate(date)

	local BanElectronEmbed = {
		{
			color = 16744448,
			title = "ExoticRP - BanSystem (Anticheat)",

			thumbnail = {
				url = THUMBNAIL_URL
			},
			description = string.format(
				"```\n" ..
				"Nick: %s\n" ..
				"Powód: %s\n" ..
				"Długość: %s\n" ..
				"Zbanowany przez: %s\n" ..
				"```\n" ..
				"**Aby się odwołać utwórz ticket o unban na kanale** \n<#1318654295960453170>",
				GetPlayerName(source),
				reason,
				"PERMANENTNY",
				"Anitcheat"
			),
			footer = {
				text = "ExoticRP - BanRoom " .. dateStr,
				icon_url = THUMBNAIL_URL
			}
		}
	}
	sendToDiscord(Webhooks.BanAntycheat, BanElectronEmbed, discordMention)
end)