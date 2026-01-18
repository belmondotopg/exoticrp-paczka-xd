ESX = exports["es_extended"]:getSharedObject()
Arena = nil
LocalPlayer.state:set("inArena", false, true)
local isDead = false

-- === UI (bl_ui) ===
local function UI_Help(msg, key, desc)
	if IsInArena(true) or LocalPlayer.state.inArena then return end
	exports.esx_hud:helpNotification(msg, key, desc)
end
-- ===================

AddEventHandler('esx:onPlayerDeath', function()
	isDead = true
end)

AddEventHandler('playerSpawned', function()
	isDead = false
end)

local DrawBigMarker = function(coords)
	if not coords then return end

	local rot = vec3(270.0, 0.0, 0.0)
	local size = vec3(4.0, 1.5, 4.0)
	local playerCoords = GetEntityCoords(PlayerPedId())
	local distance = #(playerCoords - vec3(coords.x, coords.y, coords.z))
	local markerType = 6
	local alpha = distance <= size.x and 230 or 120
	DrawMarker(markerType, coords, 0.0, 0.0, 0.0, rot, size, 255, 128, 0, alpha, false, true, 2, false, false, false, false)
end

Citizen.CreateThread(function()
	Config.Weapons = {}

	while true do
		local playerCoords = GetEntityCoords(PlayerPedId())
		local vdist = #(playerCoords - vec3(Config.Hostpoint.x, Config.Hostpoint.y, Config.Hostpoint.z))

		if vdist < Config.ScaleformDistance and not LocalPlayer.state.IsDead then
			if vdist < 2 then
				exports["esx_hud"]:helpNotification('Nacisnij', 'E', 'aby wybrac arene')
				if IsControlJustPressed(0, 51) and not isDead then
					if Arena then
						OpenMenu()
					else
						OpenSelectGameMenu()
					end
				end
			else
				exports["esx_hud"]:hideHelpNotification()
				if vdist >= 7 and Arena and not Arena.started then
					TriggerServerEvent("arenas:sv:exit")
				end
			end
			DrawBigMarker(vec3(Config.Hostpoint.x, Config.Hostpoint.y, Config.Hostpoint.z - 1))
			Citizen.Wait(0)
		else
			pcall(function() exports["esx_hud"]:hideHelpNotification() end)
			Citizen.Wait(1500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)
		exports["ox_inventory"]:weaponWheel(IsInArena(true))
	end
end)

GetScaleformRot = function(coords, coords_2)
	return (180.0 - GetHeadingFromVector_2d((coords_2.x - coords.x), (coords_2.y - coords.y)))
end

OpenSelectGameMenu = function()
	local elements = {
		{label = "Areny Paintball", value = "pb"}
	}

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_arena', {
		title    = "Maze Bank Arena",
		align    = 'right',
		elements = elements
	}, function(data, menu)
		menu.close()
		if data.current.value == "pb" then
			OpenMainMenu()
		end
	end, function(data, menu)
		menu.close()
	end)
end

RegisterNetEvent("arenas:cl:statsRound")
AddEventHandler("arenas:cl:statsRound", function(data)
	if not data then return end

	local data2 = {}
	local text = "Podsumowanie rundy:<br>"

	for k, v in pairs(data) do
		data2[#data2 + 1] = {name = k, kills = v}
	end

	Citizen.Wait(500)

	table.sort(data2, function(a, b)
		return b.kills < a.kills
	end)

	for _, v in ipairs(data2) do
		text = text .. "[" .. v.name .. "] - Zabojstwa: " .. v.kills .. "<br>"
	end

	ESX.ShowNotification(text)
end)

RegisterNetEvent("arenas:cl:gameStats")
AddEventHandler("arenas:cl:gameStats", function(data)
	if not data then return end

	local data2 = {}
	local text = "Podsumowanie gry:<br>"

	for k, v in pairs(data) do
		data2[#data2 + 1] = {name = k, kills = v}
	end

	Citizen.Wait(500)

	table.sort(data2, function(a, b)
		return b.kills < a.kills
	end)

	for _, v in ipairs(data2) do
		text = text .. "[" .. v.name .. "] - Zabojstwa " .. v.kills .. "<br>"
	end

	ESX.ShowNotification(text)
end)

RegisterNetEvent("arenas:cl:start")
AddEventHandler("arenas:cl:start", function(gameData)
	if not Arena then
		Arena = gameData
		LocalPlayer.state:set("inArena", true, true)
		TriggerEvent("arenas:isInArena", true)
		LocalPlayer.state.syncWeather = false
		local team = gameData.team
		local outfit = team == 1 and Config.OutfitRed or Config.OutfitBlue
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
			TriggerEvent("esx_acessories:OutfitAnim")
			Wait(1000)
			local clothes = skin.sex == 0 and outfit.male or outfit.female
			TriggerEvent('skinchanger:loadClothes', skin, clothes)
		end)

		BusySpinnerDisplay("Dolaczanie do sesji")

		ESX.ShowNotification("Mozesz opuscic gre przy uzyciu /paintball_exit.")

		if Arena.host then
			OpenMenu()
		end

		BusySpinnerDisplay("Oczekiwanie na rozpoczecie sesji przez hosta")

		Citizen.CreateThread(function()
			while IsArenaActive() do
				if Arena.started then
					if not IsPlayerDead(PlayerId()) then
						if IsScreenFadedIn() then
							if not IsInSafezone(GetArenaProperty("safezone")) then
								SetEntityHealth(PlayerPedId(), 0)
							end
						end
					end
				end
				Citizen.Wait(1000)
			end
		end)

		while IsArenaActive() do
			if Arena.started then
				Draw2DText(("~h~~r~Wynik: ~w~%s | ~r~Runda: ~w~%s~r~/~w~%s"):format(GetScoreStr(), Arena.round, Arena.settings.rounds))
			end
			Citizen.Wait(0)
		end
	end
end)

RegisterNetEvent("arenas:cl:unlock")
AddEventHandler("arenas:cl:unlock", function(weapons)
	if Arena then
		for index,weapon in ipairs(weapons) do
			GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 500, false, false)
		end

		BusyspinnerOff()

		if not IsScreenFadedIn() and not IsScreenFadingIn() then
			DoScreenFadeIn(1000)
			while not IsScreenFadedIn() do
				Citizen.Wait(0)
			end
		end

		local scaleformHandle = RequestScaleformMovie_2("COUNTDOWN")
		while not HasScaleformMovieLoaded(scaleformHandle) do
			Citizen.Wait(0)
		end

		local drawScaleform = true
		Citizen.CreateThread(function()
			BeginScaleformMovieMethod(scaleformHandle, "SET_COUNTDOWN_LIGHTS")
			ScaleformMovieMethodAddParamInt(10)
			EndScaleformMovieMethod()
			while drawScaleform do
				DrawScaleformMovieFullscreen(scaleformHandle, 255, 255, 255, 255)
				Citizen.Wait(0)
			end
		end)

		for i=3, 0, -1 do
			SetCountdownScaleform(scaleformHandle, ((i == 0 and "GO") or tostring(i)))
			PlaySoundFrontend(-1, "Countdown_" .. i, "DLC_AW_Frontend_Sounds", 1)
			if i == 1 then
				Citizen.CreateThread(function()
					Citizen.Wait(250)
					PlaySoundFrontend(-1, "Countdown_GO", "DLC_AW_Frontend_Sounds", 1)
				end)
			end
			Citizen.Wait(1000)
		end

		SetPlayerControl(PlayerId(), true, 0)
		Citizen.Wait(500)
		drawScaleform = false
		FreezeEntityPosition(PlayerPedId(), false)
	end
end)

RegisterNetEvent("arenas:cl:respawn")
AddEventHandler("arenas:cl:respawn", function(teamId)
	if Arena then
		if not Arena.started then
			Arena.started = true
		end

		FreezeEntityPosition(PlayerPedId(), true)

		if not IsScreenFadedOut() and not IsScreenFadingOut() then
			DoScreenFadeOut(300)
			while not IsScreenFadedOut() do
				Citizen.Wait(0)
			end
		end

		BusySpinnerDisplay("Oczekiwanie na polaczenie wszystkich graczy")

		local spawnPoint = false
		for _,pos in ipairs(GetArenaProperty("spawnpoints")[teamId]) do
			spawnPoint = true
			if GetArenaProperty("ipl") then
				RequestIpl("xs_arena_interior")
				local interiorID = GetInteriorAtCoords(2800.000, -3800.000, 100.000)
				if (not IsInteriorReady(interiorID)) then
					Wait(1)
				end
				EnableInteriorProp(interiorID, "Set_Crowd_A")
				EnableInteriorProp(interiorID, "Set_Crowd_B")
				EnableInteriorProp(interiorID, "Set_Crowd_C")
				EnableInteriorProp(interiorID, "Set_Crowd_D")
				EnableInteriorProp(interiorID, "Set_Dystopian_Scene")
				EnableInteriorProp(interiorID, "Set_Dystopian_10")
			end
			Wait(math.random(1, 1500))
			RequestCollisionAtCoord(pos.x, pos.y, pos.z)
			SetEntityCoords(PlayerPedId(), vec3(pos.x, pos.y, pos.z-1))
			while not Citizen.InvokeNative(0xE23D5873C2394C61, PlayerId()) do
				Citizen.Wait(0)
			end

			TriggerEvent("esx_ambulance:onTargetRevive")
			SetPlayerControl(PlayerId(), false, 256)
			TriggerServerEvent("arenas:sv:ready")
			break
		end

		if not spawnPoint then
			TriggerEvent("arenas:cl:respawn", teamId)
		end
	end
end)

RegisterNetEvent("arenas:cl:player")
AddEventHandler("arenas:cl:player", function(data)
	if Arena then
		local player, index = GetPlayer(data.playerId)
		if player then
			for k,v in pairs(data.update) do
				Arena.players[index][k] = v
				if data.playerId == GetPlayerServerId(PlayerId()) and k == "team" then
					local outfit = v == 1 and Config.OutfitRed or Config.OutfitBlue
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
						TriggerEvent("esx_acessories:OutfitAnim")
						Wait(1000)
						local clothes = skin.sex == 0 and outfit.male or outfit.female
						TriggerEvent('skinchanger:loadClothes', skin, clothes)
					end)
				end
			end
		end
	end
end)

RegisterNetEvent("arenas:cl:players")
AddEventHandler("arenas:cl:players", function(players)
	if Arena then
		Arena.players = players
	end
end)

RegisterNetEvent("arenas:cl:round")
AddEventHandler("arenas:cl:round", function(round)
	if Arena then
		Arena.round = round
	end
end)

RegisterNetEvent("arenas:cl:stats")
AddEventHandler("arenas:cl:stats", function(stats)
	if Arena then
		Arena.stats = stats
	end
end)

RegisterNetEvent("arenas:cl:update")
AddEventHandler("arenas:cl:update", function(data)
	if Arena then
		if Arena.settings then
			for k,v in pairs(data) do
				Arena.settings[k] = v
			end
		end
	end
end)

RegisterNetEvent("arenas:cl:endflow")
AddEventHandler("arenas:cl:endflow", function(data)
	if not Arena then return end

	FreezeEntityPosition(PlayerPedId(), true)
	BusySpinnerDisplay("Laczenie z glowna sesja")
	Wait(2000)
	RequestCollisionAtCoord(Config.Hostpoint.x, Config.Hostpoint.y, Config.Hostpoint.z)
	SetEntityCoords(PlayerPedId(), Config.Hostpoint.x, Config.Hostpoint.y, Config.Hostpoint.z)
	Wait(math.random(1, 2500))
	BusyspinnerOff()
	AnimpostfxStopAll()
	SetPlayerControl(PlayerId(), true, 0)
	FreezeEntityPosition(PlayerPedId(), false)
end)

RegisterNetEvent("arenas:cl:feed")
AddEventHandler("arenas:cl:feed", function(data)
	if not Arena or not data then return end

	if data.type == "chat_kill" then
		local message = Config.KillMessages[math.random(1, #Config.KillMessages)]
		ESX.ShowNotification(("%s %s %s"):format(data.killer, message, data.victim))
	elseif data.type == "esx:showNotification" then
		ESX.ShowNotification(data.msg)
	end
end)

RegisterNetEvent("arenas:cl:stop")
AddEventHandler("arenas:cl:stop", function(bypassCleanUp)
	if Arena then
		ESX.UI.Menu.CloseAll()
		local arenaId = Arena.settings.arena
		Arena = nil
		LocalPlayer.state:set("inArena", false, true)

		TriggerEvent("arenas:isInArena", false)
		LocalPlayer.state.syncWeather = true

		local hostpoint = Config.Arenas[arenaId].hostpoint
		local ipl = Config.Arenas[arenaId].ipl

		RemoveAllPedWeapons(PlayerPedId())
		if not IsScreenFadedOut() and not IsScreenFadingOut() then
			DoScreenFadeOut(0)
		end
		if ipl then
			RemoveIpl("xs_arena_interior")
			local interiorID = GetInteriorAtCoords(2800.000, -3800.000, 100.000)
			if (not IsInteriorReady(interiorID)) then
				Wait(1)
			end
			DeactivateInteriorEntitySet(interiorID, "Set_Crowd_A")
			DeactivateInteriorEntitySet(interiorID, "Set_Crowd_B")
			DeactivateInteriorEntitySet(interiorID, "Set_Crowd_C")
			DeactivateInteriorEntitySet(interiorID, "Set_Crowd_D")
			DeactivateInteriorEntitySet(interiorID, "Set_Dystopian_Scene")
			DeactivateInteriorEntitySet(interiorID, "Set_Dystopian_10")
		end
		BusySpinnerDisplay("Laczenie z glowna sesja")
		Wait(2500)
		RequestCollisionAtCoord(hostpoint.x, hostpoint.y, hostpoint.z)
		SetEntityCoords(PlayerPedId(), hostpoint.x, hostpoint.y, hostpoint.z)
		Wait(math.random(1, 5000))
		BusyspinnerOff()

		AnimpostfxStopAll()
		SetPlayerControl(PlayerId(), true, 0)
		FreezeEntityPosition(PlayerPedId(), false)
		TriggerEvent("esx_ambulance:onTargetRevive")
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
			TriggerEvent("esx_acessories:OutfitAnim")
			Wait(1000)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
		if not IsScreenFadedIn() and not IsScreenFadingIn() then
			DoScreenFadeIn(5000)
			while not IsScreenFadedIn() do
				Citizen.Wait(0)
			end
		end
	end
end)

RegisterNetEvent("arena:invite:showInvite")
AddEventHandler("arena:invite:showInvite", function(src, trg)
	ESX.UI.Menu.CloseAll()
	if LocalPlayer.state.IsDead then
		return TriggerServerEvent("arenas:sv:invite2", src, trg, false)
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'invite', {
		title    = ("Zaproszenie od %s"):format(src),
		align    = 'right',
		elements = {
			{ label = "Przyjmij", value = 1 },
			{ label = "Odrzuc", value = 0 }
		}
	}, function(data, menu)
		if (data.current.value == 1) then
			TriggerServerEvent("arenas:sv:invite2", src, trg, true)
			menu.close()
		elseif (data.current.value == 0) then
			TriggerServerEvent("arenas:sv:invite2", src, trg, false)
			menu.close()
		end
	end, function(data, menu)
		TriggerServerEvent("arenas:sv:invite2", src, trg, false)
		menu.close()
	end)
end)

-- [[ Arena helpers ]] --
IsArenaActive = function()
	return Arena ~= nil
end

IsAlly = function(team)
	if Arena then
		return Arena.team == team
	end
	return false
end

OpenMainMenu = function()
	local elements = {}
	for id, arena in ipairs(Config.Arenas) do
		table.insert(elements, { label = arena.label, value = id })
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'select_arena', {
		title    = "Maze Bank Arena",
		align    = 'right',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent("arenas:sv:requestGame", data.current.value)
		menu.close()
	end, function(data, menu)
		menu.close()
	end)
end

OpenMenu = function()
	local elements = {{ label = "Opusc arene", value = "exit" }}

	if Arena.host then
		if not Arena.started then
			table.insert(elements, 1, { label = "Host", value = "host" })
		else
			ESX.ShowNotification("Panel hosta jest niedostepny w trakcie pojedynku!")
		end
	end

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu', {
		title    = "Arena",
		align    = 'right',
		elements = elements
	}, function(data, menu)
		if (data.current.value == "host") then
			OpenHostMenu()
		elseif (data.current.value == "exit") then
			TriggerServerEvent("arenas:sv:exit")
			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenHostMenu = function()
	if not Arena.host then return end
	if Arena.started then return end

	ESX.UI.Menu.Close("default", GetCurrentResourceName(), 'host')
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'host', {
		title    = "Host",
		align    = 'right',
		elements = {
			{ label = ("Arena - %s"):format(Config.Arenas[Arena.settings.arena].label), value = "set_arena" },
			{ label = ("Rundy - %s ($%s)"):format(Arena.settings.rounds, Arena.settings.rounds*500), value = "set_rounds" },
			{ label = "Gracze", value = "players" },
			{ label = "Start", value = "start" }
		}
	}, function(data, menu)
		if (data.current.value == "set_arena") then
			OpenArenasMenu()
		elseif (data.current.value == "set_rounds") then
			OpenRoundsMenu()
		elseif (data.current.value == "players") then
			OpenPlayersMenu()
		elseif (data.current.value == "start") then
			TriggerServerEvent("arenas:sv:start")
			ESX.UI.Menu.CloseAll()
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenArenasMenu = function()
	local elements = {}
	for id, arena in ipairs(Config.Arenas) do
		table.insert(elements, { label = arena.label, value = id })
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'arenas_select', {
		title    = "Maze Bank Arena",
		align    = 'right',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent("arenas:sv:setArena", data.current.value)
		menu.close()
		Citizen.Wait(300)
		OpenHostMenu()
	end, function(data, menu)
		menu.close()
	end)
end

OpenRoundsMenu = function()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'round_select', {
		title = "Wybierz liczbe rund"
	}, function(data, menu)
		local amount = tonumber(data.value)
		if amount and amount > 0 and amount <= Config.MaxRounds then
			TriggerServerEvent("arenas:sv:setRounds", amount)
			menu.close()
			Citizen.Wait(300)
			OpenHostMenu()
		else
			ESX.ShowNotification("Nieprawidlowa wartosc.")
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenWeaponsMenu = function()
	if not Arena then return end

	local elements = {}
	for _, weapon in ipairs(Config.Arenas[Arena.settings.arena].weapons) do
		local weaponName = weapon.name:lower()
		local isAllowed = IsWeaponAllowed(weaponName)
		local label = isAllowed and weapon.label or ('<span style="color: #525252;">%s</span>'):format(weapon.label)
		table.insert(elements, { label = label, value = weaponName })
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'weapons', {
		title    = "Bronie",
		align    = 'right',
		elements = elements
	}, function(data, menu)
		TriggerServerEvent("arenas:sv:setWeapon", data.current.value, (not IsWeaponAllowed(data.current.value)))
		menu.close()
		Citizen.Wait(300)
		OpenWeaponsMenu()
	end, function(data, menu)
		menu.close()
	end)
end

OpenPlayersMenu = function()
	if not Arena then return end

	local elements = {{ label = "Zapros gracza", value = "invite" }}
	for _, player in ipairs(Arena.players) do
		table.insert(elements, { label = '[' .. player.source .. '] ' .. player.nickname, value = player.source })
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'players_menu', {
		title    = "Gracze",
		align    = 'right',
		elements = elements
	}, function(data, menu)
		if (data.current.value == "invite") then
			OpenInviteMenu()
		else
			OpenPlayerMenu(data.current.value)
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenPlayerMenu = function(playerId)
	local player, _ = GetPlayer(playerId)
	if not player then return end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_menu', {
		title    = '[' .. player.source .. '] ' .. player.nickname,
		align    = 'right',
		elements = {
			{ label = "Druzyna: " .. player.team, value = nil },
			{ label = "Zmien druzyne", value = "change_team" },
			{ label = "Wyrzuc", value = "kick" }
		}
	}, function(data, menu)
		if (data.current.value == "change_team") then
			local elements2 = {}
			for i=1, Arena.teams do
				table.insert(elements2, { label = ("Druzyna #%s [%s] %s"):format(i, #GetPlayers(i), (Arena.team == i and " (TWOJA)") or ""), value = i })
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_set_team', {
				title    = "Wybierz druzyne",
				align    = 'right',
				elements = elements2
			}, function(data2, menu2)
				TriggerServerEvent("arenas:sv:team", player.source, data2.current.value)
				menu2.close()
				menu.close()
				Citizen.Wait(300)
				OpenPlayerMenu(playerId)
			end, function(data2, menu2)
				menu2.close()
			end)
		elseif (data.current.value == "kick") then
			TriggerServerEvent("arenas:sv:kick", player.source)
			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

OpenInviteMenu = function()
	if not Arena then return end

	ESX.SelectPlayerMenu(8.0, function(data)
		if not data then return end

		local elements2 = {}
		for i = 1, Arena.teams do
			local teamPlayers = GetPlayers(i)
			local isYourTeam = Arena.team == i and " / (TWOJA)" or ""
			table.insert(elements2, { label = ("Druzyna %s / %s%s"):format(i, #teamPlayers, isYourTeam), value = i })
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_invite_team_select', {
			title    = "Wybierz druzyne",
			align    = 'right',
			elements = elements2
		}, function(data2, menu2)
			TriggerServerEvent("arenas:sv:invite", data, data2.current.value)
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'players_menu')
			menu2.close()
		end, function(data2, menu2)
			menu2.close()
		end)
	end)
end

-- [[ Utils ]] --
SetCountdownScaleform = function(scaleformHandle, msg)
	BeginScaleformMovieMethod(scaleformHandle, "SET_MESSAGE")
	PushScaleformMovieMethodParameterString(msg)
	ScaleformMovieMethodAddParamInt(math.ceil( Config.Colors[msg].x ))
	ScaleformMovieMethodAddParamInt(math.ceil( Config.Colors[msg].y ))
	ScaleformMovieMethodAddParamInt(math.ceil( Config.Colors[msg].z ))
	ScaleformMovieMethodAddParamBool(true)
	EndScaleformMovieMethod()
end

GetPlayer = function(playerId)
	for index, player in ipairs(Arena.players) do
		if player.source == playerId then
			return player, index
		end
	end
	return nil
end

GetPlayers = function(teamId)
	if not Arena then return {} end

	if teamId then
		local players = {}
		for _, player in ipairs(Arena.players) do
			if player.team == teamId then
				table.insert(players, player)
			end
		end
		return players
	end
	return Arena.players
end

GetScoreStr = function()
	if not Arena or not Arena.stats then return nil end

	local str = {}
	for teamId, teamStats in pairs(Arena.stats) do
		local rounds = teamStats.rounds or 0
		if IsAlly(teamId) then
			table.insert(str, 1, rounds)
		else
			table.insert(str, rounds)
		end
	end
	return table.concat(str, "~r~/~w~")
end

GetArenaProperty = function(property)
	if not Arena or not Arena.settings or not Config.Arenas[Arena.settings.arena] then
		return nil
	end
	return Config.Arenas[Arena.settings.arena][property]
end

IsInSafezone = function(safezone)
	return #(GetEntityCoords(PlayerPedId()) - vec3(safezone.x, safezone.y, safezone.z)) <= safezone.w
end

IsWeaponAllowed = function(weaponName)
	if not Arena or not Arena.settings or not Arena.settings.weapons then
		return false
	end

	for _, weapon in ipairs(Arena.settings.weapons) do
		if weapon == weaponName then
			return true
		end
	end
	return false
end

BusySpinnerDisplay = function(text)
	AddTextEntry("GTAO_BUSYSPINNER", "~a~")
	BeginTextCommandBusyspinnerOn("GTAO_BUSYSPINNER")
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandBusyspinnerOn(4)
end

Draw2DText = function(text)
	SetTextScale(0.32, 0.32)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 55)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(0.5, 0.02)
end

-- [[ Exports ]] --
IsInArena = function(andStarted)
	if andStarted then
		return Arena ~= nil and Arena.started == true
	end
	return Arena ~= nil
end

AddEventHandler("onResourceStop", function(rsc)
	if GetCurrentResourceName() == rsc then
		if Arena then
			if not IsScreenFadedIn() and not IsScreenFadingIn() then
				DoScreenFadeIn(300)
			end
			local arenaId = Arena.settings.arena
			local hostpoint = Config.Arenas[arenaId].hostpoint
			SetEntityCoords(PlayerPedId(), hostpoint.x, hostpoint.y, hostpoint.z)
			FreezeEntityPosition(PlayerPedId(), false)
			SetPlayerControl(PlayerId(), true, 0)
			RemoveAllPedWeapons(PlayerPedId())
			ExecuteCommand("propfix")
			BusyspinnerOff()
		end
	end
end)

local silencers = {
	'COMPONENT_AT_PI_SUPP',
	'COMPONENT_AT_SR_SUPP',
	'COMPONENT_AT_AR_SUPP',
	'COMPONENT_AT_AR_SUPP_02',
	'COMPONENT_AT_PI_SUPP_02',
}

local flashlights = {
	'COMPONENT_AT_PI_FLSH',
	'COMPONENT_AT_PI_FLSH_03',
	'COMPONENT_AT_PI_FLSH_02',
	'COMPONENT_AT_AR_FLSH'
}

RegisterNetEvent('epic_paintball:tlumik')
AddEventHandler('epic_paintball:tlumik', function()
	local ped = PlayerPedId()
	local currWea = GetSelectedPedWeapon(ped)
	local foundIndex = nil

	for i = 1, #silencers do
		if DoesWeaponTakeWeaponComponent(currWea, GetHashKey(silencers[i])) then
			foundIndex = i
			break
		end
	end

	if foundIndex then
		local componentHash = GetHashKey(silencers[foundIndex])
		if not HasPedGotWeaponComponent(ped, currWea, componentHash) then
			ESX.ShowNotification("Zalozyles dodatek.")
			GiveWeaponComponentToPed(ped, currWea, componentHash)
		end
	else
		ESX.ShowNotification("Nie mozesz zalozyc tlumika do tej broni.")
	end
end)

RegisterNetEvent('epic_paintball:flashlight2')
AddEventHandler('epic_paintball:flashlight2', function()
	local ped = PlayerPedId()
	local currWea = GetSelectedPedWeapon(ped)
	local foundIndex = nil

	for i = 1, #flashlights do
		if DoesWeaponTakeWeaponComponent(currWea, GetHashKey(flashlights[i])) then
			foundIndex = i
			break
		end
	end

	if foundIndex then
		local componentHash = GetHashKey(flashlights[foundIndex])
		if not HasPedGotWeaponComponent(ped, currWea, componentHash) then
			ESX.ShowNotification("Zalozyles dodatek.")
			GiveWeaponComponentToPed(ped, currWea, componentHash)
		end
	else
		ESX.ShowNotification("Nie mozesz zalozyc latarki do tej broni.")
	end
end)