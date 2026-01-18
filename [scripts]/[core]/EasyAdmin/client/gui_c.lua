isAdmin = false
showCoords = false
noclipActivated = false
noClipSpeed = 1
noClipLabel = nil

local noClipSpeeds = {
	'Bardzo Wolny',
	'Wolny',
	'Normalny',
	'Szybko',
	'Bardzo szybko',
	'Ultra szybko',
	'Ultra szybko 2.0',
	'Maksymalna predkosc',
}

settings = {
	forceShowGUIButtons = false,
}

local noclipEntity

local SlapAmount = {}
for i = 1, 20 do
	table.insert(SlapAmount, i)
end

function handleOrientation(orientation)
	if orientation == "right" then
		return 1300 - (menuWidth or 0)
	elseif orientation == "middle" then
		return 730
	elseif orientation == "left" then
		return 0
	end
end

RegisterCommand('easyadmin', function(source, args)
	CreateThread(function()
		if not isAdmin then
			TriggerServerEvent("EasyAdmin:amiadmin")
			local waitTime = 0

			repeat
				Wait(10)
				waitTime = waitTime + 1
			until (isAdmin or waitTime == 1000)
			if not isAdmin then
				return
			end
		end

		if not mainMenu or not mainMenu:Visible() then
			if isAdmin then
				playerlist = nil
				if DoesPlayerHavePermissionForCategory(-1, "player") then
					TriggerServerEvent("EasyAdmin:GetInfinityPlayerList")
					repeat
						Wait(10)
					until playerlist
				else
					playerlist = {}
				end
			end

			if strings and isAdmin then
				banLength = {}

				if permissions["player.ban.permanent"] then
					table.insert(banLength, { label = GetLocalisedText("permanent"), time = -1 })
				end

				if permissions["player.ban.temporary"] then
					table.insert(banLength, { label = "6 " .. GetLocalisedText("hours"), time = 6 })
					table.insert(banLength, { label = "12 " .. GetLocalisedText("hours"), time = 12 })
					table.insert(banLength, { label = "1 " .. GetLocalisedText("day"), time = 24 })
					table.insert(banLength, { label = "2 " .. GetLocalisedText("days"), time = 48 })
					table.insert(banLength, { label = "3 " .. GetLocalisedText("days"), time = 72 })
					table.insert(banLength, { label = "4 dni", time = 96 })
					table.insert(banLength, { label = "1 " .. GetLocalisedText("week"), time = 168 })
					table.insert(banLength, { label = "2 " .. GetLocalisedText("weeks"), time = 336 })
					table.insert(banLength, { label = "1 " .. GetLocalisedText("month"), time = 774 })
				end
				GenerateMenu()

				if (args[1]) then
					local id = tonumber(args[1])
					if (reportMenus[id]) then
						reportMenus[id]:Visible(true)
						return
					elseif playerMenus[args[1]] then
						local menu = playerMenus[args[1]]
						menu.generate(menu.menu)
						menu.menu:Visible(true)
						return
					end
				end
				SendNUIMessage({ action = "speak", text = "EasyAdmin" })
				mainMenu:Visible(true)
			else
				TriggerServerEvent("EasyAdmin:amiadmin")
			end
		else
			mainMenu:Visible(false)
			_menuPool:Remove()
			ExecutePluginsFunction("menuRemoved")
			collectgarbage()
		end
	end)
end, false)

RegisterCommand('ea', function(source, args)
	ExecuteCommand('easyadmin ' .. table.concat(args, " "))
end)

Citizen.CreateThread(function()
	RegisterKeyMapping('easyadmin', 'Open EasyAdmin', 'keyboard', 'F10')

	while not NativeUI do
		Wait(100)
	end

	TriggerServerEvent("EasyAdmin:amiadmin")
	TriggerServerEvent("EasyAdmin:requestBanlist")
	TriggerServerEvent("EasyAdmin:requestCachedPlayers")

	local orientation = GetResourceKvpString("ea_menuorientation") or "middle"
	local width = GetResourceKvpInt("ea_menuwidth")
	if width == nil or width == 0 then width = 0 end

	menuWidth = width
	menuOrientation = handleOrientation(orientation)

	if not GetResourceKvpInt("ea_tts") then
		SetResourceKvpInt("ea_tts", 0)
		SetResourceKvpInt("ea_ttsspeed", 4)
	else
		local ttsSpeed = GetResourceKvpInt("ea_ttsspeed")
		if ttsSpeed == 0 then
			SetResourceKvpInt("ea_ttsspeed", 4)
			ttsSpeed = 4
		end
		if GetResourceKvpInt("ea_tts") == 1 then
			SendNUIMessage({
				action = "toggle_speak",
				enabled = true,
				rate = ttsSpeed
			})
		end
	end

	local subtitle = settings.alternativeTitle or "~b~Admin Menu"

	while true do
		if _menuPool then
			if _menuPool:IsAnyMenuOpen() then
				_menuPool:ProcessMenus()
			else
				_menuPool:Remove()
				ExecutePluginsFunction("menuRemoved")
				_menuPool = nil
				collectgarbage()
			end
		else
			Wait(250) 
		end

		Wait(1)
	end
end)

IsSpectating = false

function DrawPlayerInfo(target)
	drawTarget = target
	drawServerId = GetPlayerServerId(target)
	drawInfo = true
	IsSpectating = true
	LocalPlayer.state.IsSpectating = true
	DrawPlayerInfoLoop()
end

function StopDrawPlayerInfo()
	drawInfo = false
	drawTarget = 0
	drawServerId = 0
	IsSpectating = false
	LocalPlayer.state.IsSpectating = false
end

playerMenus = {}
cachedMenus = {}
reportMenus = {}
local easterChance = math.random(0, 101)
local overrideEgg, currentEgg

local eastereggs = {
	main = {
		banner = "dependencies/images/ea_banner.png",
		logo = false,
	},
	pipes = {
		duibanner = "http://legacy.furfag.de/eggs/pipes",
		banner = false,
		logo = "dependencies/images/banner-logo.png",
	},
	nom = {
		duilogo = "http://legacy.furfag.de/eggs/nom",
		banner = "dependencies/images/banner-gradient.png",
		logo = false,
	},
	pride = {
		banner = "dependencies/images/banner-gradient.png",
		logo = "dependencies/images/pride.png",
	},
	ukraine = {
		banner = "dependencies/images/banner-gradient.png",
		logo = "dependencies/images/ukraine.png"
	},
	EOA = {
		banner = "dependencies/images/banner-eoa.png",
		logo = "dependencies/images/logo-eoa.png"
	},
	HardAdmin = {
		banner = "dependencies/images/banner-hardadmin.png",
		logo = "dependencies/images/logo-hardadmin.png"
	}
}

function generateTextures()
	if not txd or (overrideEgg ~= currentEgg) then
		if dui then
			DestroyDui(dui)
			dui = nil
		end
		txd = CreateRuntimeTxd("easyadmin")
		CreateRuntimeTextureFromImage(txd, 'badge_dev', 'dependencies/images/pl_badge_dev.png')
		CreateRuntimeTextureFromImage(txd, 'badge_contrib', 'dependencies/images/pl_badge_contr.png')

		if ((overrideEgg == nil) and easterChance == 100) or (overrideEgg or overrideEgg == false) then
			local chance = overrideEgg
			if ((overrideEgg == nil) and easterChance == 100) then
				local tbl = {}
				for k, v in pairs(eastereggs) do
					table.insert(tbl, k)
				end

				chance = tbl[math.random(#tbl)]
			end

			local egg = eastereggs[chance]
			if egg then
				if egg.duibanner then
					dui = CreateDui(egg.duibanner, 512, 128)
					local duihandle = GetDuiHandle(dui)
					CreateRuntimeTextureFromDuiHandle(txd, 'banner-gradient', duihandle)
					Wait(800)
				elseif egg.duilogo then
					dui = CreateDui(egg.duilogo, 512, 128)
					local duihandle = GetDuiHandle(dui)
					CreateRuntimeTextureFromDuiHandle(txd, 'logo', duihandle)
					Wait(800)
				end
				if egg.logo then
					CreateRuntimeTextureFromImage(txd, 'logo', egg.logo)
				end
				if egg.banner then
					CreateRuntimeTextureFromImage(txd, 'banner-gradient', egg.banner)
				end
				currentEgg = chance
			else
				CreateRuntimeTextureFromImage(txd, 'logo', 'dependencies/images/ea_banner.png')
				CreateRuntimeTextureFromImage(txd, 'banner-gradient', 'dependencies/images/ea_banner.png')
				currentEgg = false
			end
		else
			if settings.alternativeLogo then
				CreateRuntimeTextureFromImage(txd, 'logo', 'dependencies/images/' .. settings.alternativeLogo .. '.png')
			else
				CreateRuntimeTextureFromImage(txd, 'logo', 'dependencies/images/ea_banner.png')
			end
			if settings.alternativeBanner then
				CreateRuntimeTextureFromImage(txd, 'banner-gradient',
					'dependencies/images/' .. settings.alternativeBanner .. '.png')
			else
				CreateRuntimeTextureFromImage(txd, 'banner-gradient', 'dependencies/images/ea_banner.png')
			end
			currentEgg = nil
		end
	end
end

function ExecutePluginsFunction(funcName, ...)
	for i, plugin in pairs(plugins) do
		if plugin.functions[funcName] then
			PrintDebugMessage("Processing Plugin: " .. plugin.name, 4)
			local ran, errorMsg = pcall(plugin.functions[funcName], ...)
			if not ran then
				PrintDebugMessage("Error in plugin " .. plugin.name .. ": \n" .. errorMsg, 1)
			end
		end
	end
end

function GenerateMenu()
	generateTextures()
	TriggerServerEvent("EasyAdmin:requestCachedPlayers")
	if _menuPool then
		_menuPool:Remove()
		ExecutePluginsFunction("menuRemoved")
		collectgarbage()
	end
	_menuPool = NativeUI.CreatePool()
	collectgarbage()
	if not GetResourceKvpString("ea_menuorientation") then
		SetResourceKvp("ea_menuorientation", "middle")
		SetResourceKvpInt("ea_menuwidth", 0)
		menuWidth = 0
		menuOrientation = handleOrientation("middle")
	else
		local width = GetResourceKvpInt("ea_menuwidth")
		menuWidth = width or 0
		menuOrientation = handleOrientation(GetResourceKvpString("ea_menuorientation"))
	end
	maxRightTextWidth = math.floor((24 + (menuWidth * 0.12)))
	local subtitle = "Admin Menu"
	if settings.updateAvailable then
		subtitle = "~g~UPDATE " .. settings.updateAvailable .. " AVAILABLE!"
	elseif settings.alternativeTitle then
		subtitle = settings.alternativeTitle
	end
	mainMenu = NativeUI.CreateMenu("", subtitle, menuOrientation, 0, "easyadmin",
		"banner-gradient", "logo")
	_menuPool:Add(mainMenu)

	_menuPool:ControlDisablingEnabled(false)
	_menuPool:MouseControlsEnabled(false)

	if DoesPlayerHavePermissionForCategory(-1, "player") then
		playermanagement = _menuPool:AddSubMenu(mainMenu, GetLocalisedText("playermanagement"), "", true, true)
		playermanagement:SetMenuWidthOffset(menuWidth)
	end

	if DoesPlayerHavePermissionForCategory(-1, "vehicle") and GetVehiclePedIsIn(PlayerPedId(), false) > 0 then
		vehiclemanagement = _menuPool:AddSubMenu(mainMenu, "Pojazd", "", true, true)
		vehiclemanagement:SetMenuWidthOffset(menuWidth)
	end

	if DoesPlayerHavePermissionForCategory(-1, "dev") then
		developermanagement = _menuPool:AddSubMenu(mainMenu, "Dev menu", "", true, true)
		developermanagement:SetMenuWidthOffset(menuWidth)
	end

	settingsMenu = _menuPool:AddSubMenu(mainMenu, GetLocalisedText("settings"), "", true, true)

	if DoesPlayerHavePermissionForCategory(-1, "general") then
		if permissions["general.noclip"] then
			local noclip = _menuPool:AddSubMenu(mainMenu, 'Noclip', "", true)

			noclip:SetMenuWidthOffset(menuWidth)

			noclip:AddInstructionButton({GetControlInstructionalButton(0, 21, 0), "Zmień prędkość"})
			noclip:AddInstructionButton({GetControlInstructionalButton(0, 31, 0), "Do przodu/tyłu"})
			noclip:AddInstructionButton({GetControlInstructionalButton(0, 30, 0), "W lewo/prawo"})
			noclip:AddInstructionButton({GetControlInstructionalButton(0, 44, 0), "Do góry"})
			noclip:AddInstructionButton({GetControlInstructionalButton(0, 38, 0), "W dół"})

			local thisItem = NativeUI.CreateCheckboxItem('Noclip', noclipActivated, "")
			noclip:AddItem(thisItem)
			thisItem.CheckboxEvent = function(sender, item, checked_)
				if item == thisItem then
					noclipActivated = checked_

					local ped = PlayerPedId()

					if IsPedInAnyVehicle(ped, false) then
						noclipEntity = GetVehiclePedIsIn(ped, false)
					else
						noclipEntity = ped
					end

					if noclipActivated then
						Citizen.CreateThread(NoclipThread)
					else
						ResetEntityAlpha(noclipEntity)
						SetEntityVisible(noclipEntity, true, 0)
						NetworkSetEntityInvisibleToNetwork(noclipEntity, false)
						SetEntityCollision(noclipEntity, true, true)
						FreezeEntityPosition(noclipEntity, false)
						SetEntityInvincible(noclipEntity, false)
					end
				end
			end
			noClipLabel = NativeUI.CreateItem('Prędkość', "")
			noClipLabel:RightLabel(noClipSpeeds[noClipSpeed])
			noclip:AddItem(noClipLabel)
		end

		if permissions["general.invisible"] then
			local invisible = false
			local thisItem = NativeUI.CreateCheckboxItem("Niewidzialność", invisible, "Stań się niewidzialny")
			mainMenu:AddItem(thisItem)
			thisItem.CheckboxEvent = function(sender, item, checked_)
				invisible = checked_
				local ped = PlayerPedId()

				SetEntityVisible(ped, not invisible)

				Citizen.CreateThread(function()
					while invisible do
						Citizen.Wait(0)

						SetEntityAlpha(ped, 50)
						SetEntityLocallyVisible(ped)
					end

					ResetEntityAlpha(ped)
				end)
			end
		end

		if permissions["general.revive"] then
			local thisItem = NativeUI.CreateItem("Revive", "")
			mainMenu:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				ExecuteCommand("revive")
			end
		end

		if permissions["general.tpm"] then
			local thisItem = NativeUI.CreateItem("Teleport do waypoint", "Teleportuj się do znacznika")
			mainMenu:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				ExecuteCommand("tpm")
			end
		end
	end

	mainMenu:SetMenuWidthOffset(menuWidth)
	settingsMenu:SetMenuWidthOffset(menuWidth)

	players = {}
	local localplayers = playerlist or {}
	local temp = {}
	for i, thePlayer in pairs(localplayers) do
		table.insert(temp, thePlayer.id)
	end
	table.sort(temp)
	for i, thePlayerId in pairs(temp) do
		for _, thePlayer in pairs(localplayers) do
			if thePlayerId == thePlayer.id then
				players[i] = thePlayer
			end
		end
	end

	ExecutePluginsFunction("mainMenu")

	if DoesPlayerHavePermissionForCategory(-1, "player") then
		local userSearch = NativeUI.CreateItem(GetLocalisedText("searchuser"), GetLocalisedText("searchuserguide"))
		playermanagement:AddItem(userSearch)
		userSearch.Activated = function(ParentMenu, SelectedItem)
			local input = lib.inputDialog('Wyszukiwanie gracza', {
				{type = 'input', label = 'Podaj ID lub nick gracza', icon = 'hashtag', description = 'Możesz wpisać ID lub nick gracza'}
			})
			if not input then return end
			local result = tostring(input[1])

			if result and result ~= "" then
				local found = false
				local temp = {}
				
				local isNumber = tonumber(result) ~= nil
				
				if isNumber then
					local foundbyid = playerMenus[result] or false
					if foundbyid then
						found = true
						table.insert(temp, { id = foundbyid.id, name = foundbyid.name, menu = foundbyid.menu })
					end
				end
				
				for k, v in pairs(playerMenus) do
					if string.find(string.lower(v.name), string.lower(result)) then
						local alreadyAdded = false
						for _, existing in ipairs(temp) do
							if existing.id == v.id then
								alreadyAdded = true
								break
							end
						end
						if not alreadyAdded then
							found = true
							table.insert(temp, { id = v.id, name = v.name, menu = v.menu })
						end
					end
				end

				for k, v in pairs(cachedMenus) do
					if string.find(string.lower(v.name), string.lower(result)) then
						local alreadyAdded = false
						for _, existing in ipairs(temp) do
							if existing.id == v.id then
								alreadyAdded = true
								break
							end
						end
						if not alreadyAdded then
							found = true
							table.insert(temp, { id = v.id, name = v.name, menu = v.menu, cached = true })
						end
					end
				end

				if found and (#temp > 1) then
					local searchsubtitle = "Found " .. tostring(#temp) .. " results!"
					ttsSpeechText(searchsubtitle)
					local resultMenu = NativeUI.CreateMenu("Search Results", searchsubtitle, menuOrientation, 0,
						"easyadmin", "banner-gradient", "logo")
					_menuPool:Add(resultMenu)
					_menuPool:ControlDisablingEnabled(false)
					_menuPool:MouseControlsEnabled(false)

					for i, thePlayer in ipairs(temp) do
						local title = "[" .. thePlayer.id .. "] " .. thePlayer.name, ""
						if thePlayer.cached then
							title = thePlayer.name
						end
						local thisItem = NativeUI.CreateItem(title)
						resultMenu:AddItem(thisItem)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							_menuPool:CloseAllMenus()
							Citizen.Wait(300)
							local thisMenu = thePlayer.menu
							playerMenus[tostring(thePlayer.id)].generate(thisMenu)
							thisMenu:Visible(true)
						end
					end
					_menuPool:CloseAllMenus()
					Citizen.Wait(300)
					resultMenu:Visible(true)
					return
				end
				if found and (#temp == 1) then
					local thisMenu = temp[1].menu
					_menuPool:CloseAllMenus()
					Citizen.Wait(300)
					ttsSpeechText("Found User.")
					playerMenus[tostring(temp[1].id)].generate(thisMenu)
					thisMenu:Visible(true)
					return
				end
				TriggerEvent("EasyAdmin:showNotification", "~r~Nie znaleziono gracza!")
			end
		end

		playerMenus = {}
		cachedMenus = {}
		reportMenus = {}
		for i, thePlayer in pairs(players) do
			local thisPlayerMenu = _menuPool:AddSubMenu(playermanagement, "[" .. thePlayer.id .. "] " .. thePlayer.name,
				"", true)
			if thePlayer.developer then
				thisPlayerMenu.ParentItem:SetRightBadge(23)
			elseif thePlayer.contributor then
				thisPlayerMenu.ParentItem:SetRightBadge(24)
			end
			playerMenus[tostring(thePlayer.id)] = { menu = thisPlayerMenu, name = thePlayer.name, id = thePlayer.id }

			thisPlayerMenu:SetMenuWidthOffset(menuWidth)

			playerMenus[tostring(thePlayer.id)].generate = function(menu)
				thisPlayer = menu

				if not playerMenus[tostring(thePlayer.id)].generated then
					if permissions["player.kick"] then
						local thisKickMenu = _menuPool:AddSubMenu(thisPlayer, GetLocalisedText("kickplayer"), "", true)
						thisKickMenu:SetMenuWidthOffset(menuWidth)

						local thisItem = NativeUI.CreateItem(GetLocalisedText("reason"),
							GetLocalisedText("kickreasonguide"))
						thisKickMenu:AddItem(thisItem)
						KickReason = GetLocalisedText("noreason")
						thisItem:RightLabel(KickReason)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							local input = lib.inputDialog('Wyszukiwanie gracza', {
								{type = 'input', label = 'Podaj powód wyrzucenia', icon = 'hashtag', description = 'Możesz wpisać powód wyrzucenia'}
							})
							if not input then return end
							local result = tostring(input[1])

							if result and result ~= "" then
								KickReason = result
								thisItem:RightLabel(result)
							else
								KickReason = GetLocalisedText("noreason")
							end
						end

						local thisItem = NativeUI.CreateItem(GetLocalisedText("confirmkick"),
							GetLocalisedText("confirmkickguide"))
						thisKickMenu:AddItem(thisItem)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							if KickReason == "" then
								KickReason = GetLocalisedText("noreason")
							end
							TriggerServerEvent("EasyAdmin:kickPlayer", thePlayer.id, KickReason)
							_menuPool:CloseAllMenus()
							Citizen.Wait(800)
							GenerateMenu()
							playermanagement:Visible(true)
						end
					end

					if permissions["player.ban.temporary"] or permissions["player.ban.permanent"] then
						local thisBanMenu = _menuPool:AddSubMenu(thisPlayer, GetLocalisedText("banplayer"), "", true)
						thisBanMenu:SetMenuWidthOffset(menuWidth)

						local thisItem = NativeUI.CreateItem(GetLocalisedText("reason"),
							GetLocalisedText("banreasonguide"))
						thisBanMenu:AddItem(thisItem)
						BanReason = GetLocalisedText("noreason")
						thisItem:RightLabel(BanReason)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							local input = lib.inputDialog('Wyszukiwanie gracza', {
								{type = 'input', label = 'Podaj powód blokady', icon = 'hashtag', description = 'Możesz wpisać powód blokady'}
							})
							if not input then return end
							local result = tostring(input[1])

							if result and result ~= "" then
								BanReason = result
								thisItem:RightLabel(result)
							else
								BanReason = GetLocalisedText("noreason")
							end
						end
						local bt = {}
						for i, a in ipairs(banLength) do
							table.insert(bt, a.label)
						end

						local thisItem = NativeUI.CreateListItem(GetLocalisedText("banlength"), bt, 1,
							GetLocalisedText("banlengthguide"))
						thisBanMenu:AddItem(thisItem)
						local BanTime = banLength[1].time
						thisItem.OnListChanged = function(sender, item, index)
							BanTime = banLength[index].time
						end

						local thisItem = NativeUI.CreateItem(GetLocalisedText("confirmban"),
							GetLocalisedText("confirmbanguide"))
						thisBanMenu:AddItem(thisItem)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							if BanReason == "" then
								BanReason = GetLocalisedText("noreason")
							end
							TriggerServerEvent("EasyAdmin:banPlayer", thePlayer.id, BanReason, BanTime)
							BanTime = 1
							BanReason = ""
							_menuPool:CloseAllMenus()
							Citizen.Wait(800)
							GenerateMenu()
							playermanagement:Visible(true)
						end
					end

					if permissions["player.spectate"] then
						local thisItem = NativeUI.CreateItem(GetLocalisedText("spectateplayer"), "")
						thisPlayer:AddItem(thisItem)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							TriggerServerEvent("EasyAdmin:requestSpectate", thePlayer.id)
						end
					end

					if permissions["player.heal"] then
						local thisItem = NativeUI.CreateItem("Heal", "")
						thisPlayer:AddItem(thisItem)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							TriggerServerEvent("EasyAdmin:healPlayer", thePlayer.id)
						end
					end

					if permissions["player.revive"] then
						local thisItem = NativeUI.CreateItem("Revive", "")
						thisPlayer:AddItem(thisItem)
						thisItem.Activated = function(ParentMenu, SelectedItem)
							TriggerServerEvent("EasyAdmin:revivePlayer", thePlayer.id)
						end
					end

					if permissions["player.teleport.single"] then
						local sl = { GetLocalisedText("teleporttoplayer"), GetLocalisedText("teleportplayertome"),
							"do ..." }
						local thisItem = NativeUI.CreateListItem(GetLocalisedText("teleportplayer"), sl, 1, "")
						thisPlayer:AddItem(thisItem)
						thisItem.OnListSelected = function(sender, item, index)
							if item == thisItem then
								i = item:IndexToItem(index)
								local playerPed = PlayerPedId()
								if i == GetLocalisedText("teleporttoplayer") then
									if settings.infinity then
										TriggerServerEvent('EasyAdmin:TeleportAdminToPlayer', thePlayer.id)
									else
										lastLocation = GetEntityCoords(playerPed)
										local targetPed = GetPlayerPed(GetPlayerFromServerId(thePlayer.id))
										local x, y, z = table.unpack(GetEntityCoords(targetPed, true))
										local heading = GetEntityHeading(targetPed)
										SetEntityCoords(playerPed, x, y, z, 0, 0, heading, false)
									end
								elseif i == GetLocalisedText("teleportplayertome") then
									local coords = GetEntityCoords(playerPed, true)
									TriggerServerEvent("EasyAdmin:TeleportPlayerToCoords", thePlayer.id, coords)
								elseif i == "do ..." then
									local input = lib.inputDialog('Wyszukiwanie gracza', {
										{type = 'number', label = 'Podaj ID gracza', icon = 'hashtag', description = 'Możesz wpisać ID gracza', default = thePlayer.id}
									})
									if not input then return end
									local result = tonumber(input[1])

									if result and result ~= "" then
										TriggerServerEvent("EasyAdmin:TeleportPlayerToPlayer", thePlayer.id, result)
									else
										TriggerEvent("EasyAdmin:showNotification", "Nie prawidłowe ID")
									end
								end
							end
						end
					end

					if permissions["player.slap"] then
						local thisItem = NativeUI.CreateSliderItem(GetLocalisedText("slapplayer"), SlapAmount, 20, false,
							false)
						thisPlayer:AddItem(thisItem)
						thisItem.OnSliderSelected = function(index)
							TriggerServerEvent("EasyAdmin:SlapPlayer", thePlayer.id, index * 10)
						end
					end

					if permissions["player.freeze"] then
						local thisItem = NativeUI.CreateCheckboxItem(GetLocalisedText("setplayerfrozen"),
							FrozenPlayers[thePlayer.id])
						thisPlayer:AddItem(thisItem)
						thisItem.CheckboxEvent = function(sender, item, checked_)
							TriggerServerEvent("EasyAdmin:FreezePlayer", thePlayer.id, checked_)
						end
					end

					if GetConvar("ea_routingBucketOptions", "false") == "true" and (permissions["player.bucket.join"] or permissions["player.bucket.force"]) then
						local options = {}
						if permissions["player.bucket.join"] then
							table.insert(options, GetLocalisedText("joinplayerbucket"))
						end
						if permissions["player.bucket.force"] then
							table.insert(options, GetLocalisedText("forceplayerbucket"))
						end
						local bucketItem = NativeUI.CreateListItem(GetLocalisedText("routingbucket"), options, 1,
							GetLocalisedText("bucketguide"))
						thisPlayer:AddItem(bucketItem)
						bucketItem.OnListSelected = function(sender, item, index)
							if item == bucketItem then
								i = item:IndexToItem(index)
								if i == GetLocalisedText("joinplayerbucket") then
									TriggerServerEvent("EasyAdmin:JoinPlayerRoutingBucket", thePlayer.id)
									TriggerEvent("EasyAdmin:showNotification", GetLocalisedText("playerbucketjoined"))
								elseif i == GetLocalisedText("forceplayerbucket") then
									TriggerServerEvent("EasyAdmin:ForcePlayerRoutingBucket", thePlayer.id)
									TriggerEvent("EasyAdmin:showNotification", GetLocalisedText("playerbucketforced"))
								end
							end
						end
					end

					local copyDiscordItem = NativeUI.CreateItem(GetLocalisedText("copydiscord"), "")
					thisPlayer:AddItem(copyDiscordItem)
					copyDiscordItem.Activated = function(ParentMenu, SelectedItem)
						if thePlayer.discord then
							copyToClipboard(thePlayer.discord)
						else
							TriggerEvent("EasyAdmin:showNotification", GetLocalisedText("nodiscordpresent"))
						end
					end

					if permissions["player.call"] then
						local callItem = NativeUI.CreateItem("Wezwij na poczekalnie", "")
						thisPlayer:AddItem(callItem)
						callItem.Activated = function(ParentMenu, SelectedItem)
							TriggerServerEvent("EasyAdmin:callPlayer", thePlayer.id)
						end
					end

					ExecutePluginsFunction("playerMenu", thePlayer.id)

					_menuPool:ControlDisablingEnabled(false)
					_menuPool:MouseControlsEnabled(false)

					thisPlayer:RefreshIndexRecursively()
					playerMenus[tostring(thePlayer.id)].generated = true
				end
			end

			thisPlayerMenu.ParentItem.Activated = function(ParentMenu, SelectedItem)
				thisPlayer = thisPlayerMenu
				playerMenus[tostring(thePlayer.id)].generate(thisPlayer)

				for i, menu in pairs(playerMenus) do
					menu.menu.ParentMenu = playermanagement
				end
			end
		end

		playermanagement.ParentItem.Activated = function(ParentMenu, SelectedItem)
			for i, menu in pairs(playerMenus) do
				menu.menu.ParentMenu = playermanagement
			end
		end

		if permissions["player.reports.view"] then
			reportViewer = _menuPool:AddSubMenu(playermanagement, GetLocalisedText("reportviewer"), "", true)
			local thisMenuWidth = math.max(menuWidth, 150)
			reportViewer:SetMenuWidthOffset(thisMenuWidth)
			reportViewer.ParentItem:RightLabel(tostring(#reports) .. " " .. GetLocalisedText("open"))

			for i, report in pairs(reports) do
				local reportColour = (report.type == 0 and "~y~" or "~r~")
				if report.claimed then
					reportColour = "~g~"
				end
				local thisMenu = _menuPool:AddSubMenu(reportViewer,
					reportColour ..
					"#" .. report.id .. " " .. string.sub((report.reportedName or report.reporterName), 1, 12) .. "~w~",
					"", true)
				thisMenu:SetMenuWidthOffset(thisMenuWidth)
				thisMenu.ParentItem:RightLabel(formatRightString(report.reason, 32))
				reportMenus[report.id] = thisMenu

				if permissions["player.reports.claim"] then
					local claimText = GetLocalisedText("claimreport")
					local rightLabel = ""
					if report.claimed then
						claimText = GetLocalisedText("claimedby")
						rightLabel = formatRightString(report.claimedName)
					end

					local thisItem = NativeUI.CreateItem(claimText, "")
					thisItem:RightLabel(rightLabel)
					thisMenu:AddItem(thisItem)
					thisItem.Activated = function(ParentMenu, SelectedItem)
						if not report.claimed then
							TriggerServerEvent("EasyAdmin:ClaimReport", i)
						else
							TriggerEvent("EasyAdmin:showNotification", GetLocalisedText("reportalreadyclaimed"))
						end
					end
				end

				local thisItem = NativeUI.CreateItem(GetLocalisedText("reporter"), GetLocalisedText("entertoopen"))
				thisItem:RightLabel(formatRightString(report.reporterName))
				thisMenu:AddItem(thisItem)
				thisItem.Activated = function(ParentMenu, SelectedItem)
					_menuPool:CloseAllMenus()
					Citizen.Wait(50)
					GenerateMenu()
					Wait(100)
					if not playerMenus[tostring(report.reporter)] then
						TriggerEvent("EasyAdmin:showNotification", "~r~Zgłaszający nie znaleziony.")
						reportViewer:Visible(true)
					else
						local ourMenu = playerMenus[tostring(report.reporter)].menu
						playerMenus[tostring(report.reporter)].generate(ourMenu)
						ourMenu.ParentMenu = reportMenus[report.id]
						ourMenu:Visible(true)
					end
				end

				if report.type == 1 then
					local thisItem = NativeUI.CreateItem(GetLocalisedText("reported"), GetLocalisedText("entertoopen"))
					thisItem:RightLabel(formatRightString(report.reportedName))
					thisMenu:AddItem(thisItem)
					thisItem.Activated = function(ParentMenu, SelectedItem)
						_menuPool:CloseAllMenus()
						Citizen.Wait(50)
						GenerateMenu()
						Wait(100)
						if not playerMenus[tostring(report.reported)] then
							TriggerEvent("EasyAdmin:showNotification", "~r~Zgłoszony gracz nie znaleziony.")
							reportViewer:Visible(true)
						else
							local ourMenu = playerMenus[tostring(report.reported)].menu
							playerMenus[tostring(report.reported)].generate(ourMenu)
							ourMenu.ParentMenu = reportMenus[report.id]
							ourMenu:Visible(true)
						end
					end
				end

				local thisItem = NativeUI.CreateItem(GetLocalisedText("reason"), "")
				thisItem:RightLabel(formatRightString(report.reason, 48))
				thisMenu:AddItem(thisItem)
				thisItem.Activated = function(ParentMenu, SelectedItem)
					TriggerEvent("EasyAdmin:showNotification", GetLocalisedText("reason") .. ": " .. report.reason)
				end

				local thisItem = NativeUI.CreateItem(GetLocalisedText("time"), "")
				thisItem:RightLabel(report.reportTimeFormatted, 48)
				thisMenu:AddItem(thisItem)

				if permissions["player.reports.process"] then
					local thisItem = NativeUI.CreateItem(GetLocalisedText("closereport"), "")
					thisMenu:AddItem(thisItem)
					thisItem.Activated = function(ParentMenu, SelectedItem)
						TriggerServerEvent("EasyAdmin:RemoveReport", report)
						_menuPool:CloseAllMenus()
						Citizen.Wait(800)
						GenerateMenu()
						reportViewer:Visible(true)
					end

					local thisItem = NativeUI.CreateItem(GetLocalisedText("closesimilarreports"),
						GetLocalisedText("closesimilarreportsguide"))
					thisMenu:AddItem(thisItem)
					thisItem.Activated = function(ParentMenu, SelectedItem)
						TriggerServerEvent("EasyAdmin:RemoveSimilarReports", report)
						_menuPool:CloseAllMenus()
						Citizen.Wait(800)
						GenerateMenu()
						reportViewer:Visible(true)
					end
				end
			end
			local thisItem = NativeUI.CreateItem(GetLocalisedText("refreshreports"),
				GetLocalisedText("refreshreportsguide"))
			reportViewer:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				_menuPool:CloseAllMenus()
				repeat
					Wait(100)
				until reportViewer
				GenerateMenu()
				reportViewer:Visible(true)
			end
		end

		allPlayers = _menuPool:AddSubMenu(playermanagement, GetLocalisedText("allplayers"), "", true)
		allPlayers:SetMenuWidthOffset(menuWidth)
		if permissions["player.teleport.everyone"] then
			local thisItem = NativeUI.CreateItem(GetLocalisedText("teleporttome"), GetLocalisedText("teleporttomeguide"))
			allPlayers:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				local pCoords = GetEntityCoords(PlayerPedId(), true)
				TriggerServerEvent("EasyAdmin:TeleportPlayerToCoords", -1, pCoords)
			end
		end
	end

	if DoesPlayerHavePermissionForCategory(-1, "vehicle") and GetVehiclePedIsIn(PlayerPedId(), false) > 0 then
		if permissions["vehicle.fix.engine"] then
			local thisItem = NativeUI.CreateItem("Napraw silnik", "")
			vehiclemanagement:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

				if vehicle > 0 then
					SetVehicleEngineHealth(vehicle, 1000.0)
					SetVehicleEngineOn(vehicle, true, true, false)
				end
			end
		end

		if permissions["vehicle.fix.body"] then
			local thisItem = NativeUI.CreateItem("Napraw karoserie", "")
			vehiclemanagement:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

				if vehicle > 0 then
					local engineHealth = GetVehicleEngineHealth(vehicle)
					local petrolHealth = GetVehiclePetrolTankHealth(vehicle)
					SetVehicleFixed(vehicle)
					SetVehicleEngineHealth(vehicle, engineHealth)
					SetVehiclePetrolTankHealth(vehicle, petrolHealth)
				end
			end
		end

		if permissions["vehicle.fix.all"] then
			local thisItem = NativeUI.CreateItem("Napraw wszystko", "")
			vehiclemanagement:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

				if vehicle > 0 then
					SetVehicleEngineHealth(vehicle, 1000.0)
					SetVehicleEngineOn(vehicle, true, true, false)
					SetVehicleFixed(vehicle)
					SetVehicleDirtLevel(vehicle, 0)
				end
			end
		end

		if permissions["vehicle.givekeys"] then
			local thisItem = NativeUI.CreateItem("Daj klucze", "")
			vehiclemanagement:AddItem(thisItem)
			thisItem.Activated = function(ParentMenu, SelectedItem)
				local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

				if vehicle > 0 then
					local plate = GetVehicleNumberPlateText(vehicle)
					TriggerServerEvent("esx_carkeys:getKeys", plate)
				end
			end
		end
	end

	if DoesPlayerHavePermissionForCategory(-1, "dev") then
		if permissions["dev.showcordinates"] then
			local thisItem = NativeUI.CreateCheckboxItem("Wyświetlaj koordynaty", showCoords or false,
				"Wyświetlaj koordynaty na ekranie")
			developermanagement:AddItem(thisItem)
			thisItem.CheckboxEvent = function(sender, item, checked_)
				showCoords = checked_
				SendNUIMessage({
					action = showCoords and "showCoords" or "hideCoords"
				})

				if not showCoords then return end

				Citizen.CreateThread(function()
					local playerPed = PlayerPedId()

					while showCoords do
						local coords = GetEntityCoords(playerPed)
						local heading = GetEntityHeading(playerPed)

						SendNUIMessage({
							action = "setCoords",
							coords = ("Coords: vec3(%s, %s, %s)"):format(coords.x, coords.y, coords.z),
							heading = ("Heading: %s"):format(heading)
						})
						Citizen.Wait(100)
					end
				end)
			end
		end

		if permissions["dev.copycordinates"] then
			local copyCoordsIndex = 1
			local sl = { "vec3", "vec4", "x,y,z" }
			local thisItem = NativeUI.CreateListItem("Kopiuj koordynaty", sl, copyCoordsIndex,
				"Skopiuj koordynaty do schowka")
			developermanagement:AddItem(thisItem)
			thisItem.OnListSelected = function(sender, item, index)
				if item == thisItem then
					i = item:IndexToItem(index)
					local playerPed = PlayerPedId()
					local coords = GetEntityCoords(playerPed)
					local heading = GetEntityHeading(playerPed)
					local text = ""

					if i == sl[1] then
						text = ("vec3(%s, %s, %s)"):format(coords.x, coords.y, coords.z)
					elseif i == sl[2] then
						text = ("vec4(%s, %s, %s, %s)"):format(coords.x, coords.y, coords.z, heading)
					else
						text = ("{ x = %s, y = %s, z = %s }"):format(coords.x, coords.y, coords.z)
					end

					SendNUIMessage({
						action = "clip",
						text = text
					})
				end
			end
		end
	end

	if permissions["player.ban.temporary"] or permissions["player.ban.permanent"] then
		local thisItem = NativeUI.CreateItem(GetLocalisedText("refreshcachedplayers"),
			GetLocalisedText("refreshcachedplayersguide"))
		settingsMenu:AddItem(thisItem)
		thisItem.Activated = function(ParentMenu, SelectedItem)
			cachedplayers = nil
			TriggerServerEvent("EasyAdmin:requestCachedPlayers")
			repeat
				Wait(500)
			until cachedplayers
			GenerateMenu()
			settingsMenu:Visible(true)
			collectgarbage()
		end
	end

	local thisItem = NativeUI.CreateItem(GetLocalisedText("refreshpermissions"),
		GetLocalisedText("refreshpermissionsguide"))
	settingsMenu:AddItem(thisItem)
	thisItem.Activated = function(ParentMenu, SelectedItem)
		TriggerServerEvent("EasyAdmin:amiadmin")
	end

	local orientationIndex = 1
	if GetResourceKvpString("ea_menuorientation") == "middle" then
		orientationIndex = 2
	elseif GetResourceKvpString("ea_menuorientation") == "right" then
		orientationIndex = 3
	end

	local sl = { GetLocalisedText("left"), GetLocalisedText("middle"), GetLocalisedText("right") }
	local thisItem = NativeUI.CreateListItem(GetLocalisedText("menuOrientation"), sl, orientationIndex,
		GetLocalisedText("menuOrientationguide"))
	settingsMenu:AddItem(thisItem)
	thisItem.OnListSelected = function(sender, item, index)
		if item == thisItem then
			i = item:IndexToItem(index)
			if i == GetLocalisedText("left") then
				SetResourceKvp("ea_menuorientation", "left")
			elseif i == GetLocalisedText("middle") then
				SetResourceKvp("ea_menuorientation", "middle")
			else
				SetResourceKvp("ea_menuorientation", "right")
			end
		end
	end

	local sl = {}
	for i = 0, 250, 10 do
		table.insert(sl, i)
	end
	local thisi = 0
	for i, a in ipairs(sl) do
		if menuWidth == a then
			thisi = i
		end
	end
	local thisItem = NativeUI.CreateSliderItem(GetLocalisedText("menuOffset"), sl, thisi,
		GetLocalisedText("menuOffsetguide"), false)
	settingsMenu:AddItem(thisItem)
	thisItem.OnSliderSelected = function(index)
		local widthValue = thisItem:IndexToItem(index)
		SetResourceKvpInt("ea_menuwidth", widthValue)
		menuWidth = widthValue
	end

	local thisItem = NativeUI.CreateItem(GetLocalisedText("resetmenuOffset"), "")
	settingsMenu:AddItem(thisItem)
	thisItem.Activated = function(ParentMenu, SelectedItem)
		SetResourceKvpInt("ea_menuwidth", 0)
		menuWidth = 0
	end

	if permissions["anon"] then
		local thisItem = NativeUI.CreateCheckboxItem(GetLocalisedText("anonymous"), anonymous or false,
			GetLocalisedText("anonymousguide"))
		settingsMenu:AddItem(thisItem)
		thisItem.CheckboxEvent = function(sender, item, checked_)
			anonymous = checked_
			TriggerServerEvent("EasyAdmin:SetAnonymous", checked_)
		end
	end

	ExecutePluginsFunction("settingsMenu")
	_menuPool:ControlDisablingEnabled(false)
	_menuPool:MouseControlsEnabled(false)

	_menuPool:RefreshIndex()
end

local function DrawText3D(x, y, z, text, size, color)
	local onScreen, screenX, screenY = World3dToScreen2d(x, y, z)
	local camCoords = GetGameplayCamCoord()
	local coords = vector3(x, y, z)
	local dist = #(camCoords - coords)
	
	color = color or {255, 255, 255, 255}
	size = size or 1
	
	local scale = (size / dist) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov
	
	if onScreen and dist < 25.0 then
		SetTextScale(0.0 * scale, 0.55 * scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(color[1], color[2], color[3], color[4])
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(2, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(true)
		AddTextComponentString(text)
		DrawText(screenX, screenY)
	end
end

function DrawPlayerInfoLoop()
	CreateThread(function()
		while drawInfo do
			Wait(0)

			local text = {}
			local targetPed = GetPlayerPed(drawTarget)
			local targetGod = GetPlayerInvincible(drawTarget)
			if targetGod then
				table.insert(text, GetLocalisedText("godmodedetected"))
			else
				table.insert(text, GetLocalisedText("godmodenotdetected"))
			end
			if not CanPedRagdoll(targetPed) and not IsPedInAnyVehicle(targetPed, false) and (GetPedParachuteState(targetPed) == -1 or GetPedParachuteState(targetPed) == 0) and not IsPedInParachuteFreeFall(targetPed) then
				table.insert(text, GetLocalisedText("antiragdoll"))
			end
			table.insert(text,
				GetLocalisedText("health") .. ": " .. GetEntityHealth(targetPed) ..
				"/" .. GetEntityMaxHealth(targetPed))

			table.insert(text, GetLocalisedText("armor") .. ": " .. GetPedArmour(targetPed))

			table.insert(text, GetLocalisedText("wantedlevel") .. ": " .. GetPlayerWantedLevel(drawTarget))
			table.insert(text, GetLocalisedText("exitspectator"))

			for i, theText in pairs(text) do
				SetTextFont(0)
				SetTextProportional(1)
				SetTextScale(0.0, 0.30)
				SetTextDropshadow(0, 0, 0, 0, 255)
				SetTextEdge(1, 0, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString(theText)
				EndTextCommandDisplayText(0.3, 0.7 + (i / 30))
			end

			if IsControlPressed(0, 20) then
				local camCoords = GetGameplayCamCoord()
				local maxDist = 100.0
				
				if DoesEntityExist(targetPed) then
					local headCoords = GetPedBoneCoords(targetPed, 31086, 0.0, 0.0, 0.0) -- BONE_HEAD
					local dist = #(camCoords - headCoords)
					if dist < maxDist then
						DrawText3D(headCoords.x, headCoords.y, headCoords.z + 0.5, "ID: " .. tostring(drawServerId), 1.0, {71, 175, 255, 255})
					end
				end
				
				for _, player in ipairs(GetActivePlayers()) do
					local playerServerId = GetPlayerServerId(player)
					if playerServerId == drawServerId then goto continue end
					
					local playerPed = GetPlayerPed(player)
					if not DoesEntityExist(playerPed) then goto continue end
					
					local playerHeadCoords = GetPedBoneCoords(playerPed, 31086, 0.0, 0.0, 0.0)
					local dist = #(camCoords - playerHeadCoords)
					
					if dist < maxDist then
						local talkingColor = NetworkIsPlayerTalking(player) and {71, 175, 255, 255} or {255, 255, 255, 255}
						DrawText3D(playerHeadCoords.x, playerHeadCoords.y, playerHeadCoords.z + 0.5, "ID: " .. tostring(playerServerId), 1.0, talkingColor)
					end
					::continue::
				end
			end

			if IsControlJustPressed(0, 103) then
				local targetPed = PlayerPedId()
				local targetPlayer = -1
				local targetx, targety, targetz = table.unpack(GetEntityCoords(targetPed, false))
				spectatePlayer(targetPed, targetPlayer, GetPlayerName(targetPlayer))
				TriggerEvent('EasyAdmin:FreezePlayer', false)

				StopDrawPlayerInfo()
				TriggerEvent("EasyAdmin:showNotification", GetLocalisedText("stoppedSpectating"))
				TriggerServerEvent("EasyAdmin:resetBucket", MyBucket)
			end
		end
	end)

	CreateThread(function()
		while drawInfo do
			Wait(5000)

			local targetPed = GetPlayerPed(drawTarget)
			if not DoesEntityExist(targetPed) and drawServerId ~= 0 then
				TriggerServerEvent("EasyAdmin:requestBucket", drawServerId)
			end
		end
	end)
end

function NoclipThread()
	if not noclipActivated then return end

	local ped = PlayerPedId()

	while noclipActivated do
		if IsPedInAnyVehicle(ped, false) then
			noclipEntity = GetVehiclePedIsIn(ped, false)
		else
			noclipEntity = ped
		end

		FreezeEntityPosition(noclipEntity, true)
		SetEntityInvincible(noclipEntity, true)

		DisableControlAction(0, 31, true)
		DisableControlAction(0, 30, true)
		DisableControlAction(0, 44, true)
		DisableControlAction(0, 38, true)
		DisableControlAction(0, 32, true)
		DisableControlAction(0, 33, true)
		DisableControlAction(0, 34, true)
		DisableControlAction(0, 35, true)

		SetEntityAlpha(noclipEntity, 128, false)
		SetEntityVisible(noclipEntity, false, 0)
		SetEntityLocallyVisible(noclipEntity)
		NetworkSetEntityInvisibleToNetwork(noclipEntity, true)
		local speedMultipliers = {0.25, 0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0}
		local currentSpeed = speedMultipliers[noClipSpeed] or 1.0
		
		local yoff = 0.0
		local zoff = 0.0
		if IsControlJustPressed(0, 21) then
			noClipSpeed = noClipSpeed + 1
			if noClipSpeed > #noClipSpeeds then
				noClipSpeed = 1
			end

			if noClipLabel then
				noClipLabel:RightLabel(noClipSpeeds[noClipSpeed])
			end
		end

		if IsDisabledControlPressed(0, 32) then
			yoff = 0.5;
		end

		if IsDisabledControlPressed(0, 33) then
			yoff = -0.5;
		end

		if IsDisabledControlPressed(0, 34) then
			SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) + 2.0)
		end

		if IsDisabledControlPressed(0, 35) then
			SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity) - 2.0)
		end

		if IsDisabledControlPressed(0, 44) then
			zoff = 0.5;
		end

		if IsDisabledControlPressed(0, 38) then
			zoff = -0.5;
		end

		local heading = GetEntityHeading(noclipEntity)
		local xoff = 0.0
		
		if yoff ~= 0.0 then
			local rad = math.rad(heading)
			xoff = -math.sin(rad) * yoff * currentSpeed
			yoff = math.cos(rad) * yoff * currentSpeed
		else
			yoff = 0.0
		end

		local pos = GetEntityCoords(noclipEntity, true)
		local newX = pos.x + xoff
		local newY = pos.y + yoff
		local newZ = pos.z + (zoff * currentSpeed)

		SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
		SetEntityCollision(noclipEntity, false, false)
		SetEntityCoordsNoOffset(noclipEntity, newX, newY, newZ, true, true, true)
		Citizen.Wait(0)
	end
	
	if noclipEntity then
		ResetEntityAlpha(noclipEntity)
		SetEntityVisible(noclipEntity, true, 0)
		NetworkSetEntityInvisibleToNetwork(noclipEntity, false)
	end
end