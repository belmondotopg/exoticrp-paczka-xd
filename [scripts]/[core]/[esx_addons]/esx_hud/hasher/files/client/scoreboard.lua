local SendNUIMessage = SendNUIMessage
local LocalPlayer = LocalPlayer
local Player = Player
local ESX = ESX
local lib = lib
local GetActivePlayers = GetActivePlayers
local GetGameTimer = GetGameTimer
local GetPlayerPed = GetPlayerPed
local GetPlayerServerId = GetPlayerServerId
local Citizen = Citizen
local PlayerId = PlayerId
local GetGameplayCamCoord = GetGameplayCamCoord
local GetPedBoneCoords = GetPedBoneCoords
local NetworkIsPlayerTalking = NetworkIsPlayerTalking
local vector3 = vector3

local ANIM_DICT = 'amb@world_human_clipboard@male@idle_a'
local ANIM_NAME = 'idle_a'
local CLIPBOARD_MODEL = 'p_cs_clipboard'
local BONE_INDEX_HEAD = 31086
local BONE_INDEX_HAND = 36029
local COOLDOWN_TIME = 5000
local UPDATE_INTERVAL = 10000
local NUI_UPDATE_INTERVAL = 500
local SLEEP_TIME_IDLE = 300
local SLEEP_TIME_ACTIVE = 1
local ADMIN_DISTANCE = 150.0
local NORMAL_DISTANCE = 50.0
local ADMIN_TAG_DISTANCE = 100.0
local NORMAL_TAG_DISTANCE = 30.0

LocalPlayer.state:set('IsScoreboarding', nil, true)

local IsNuiActive = false
local IsDisplaying = nil
local IsHoldingZ = false
local Timer = 0
local Prop = nil
local Id = nil
local streamers = {}
local ScoreboardInfo = {}
local PedSpectate = nil

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords
local cacheServerId = cache.serverId

libCache('ped', function(ped)
	cachePed = ped
end)

libCache('coords', function(coords)
	cacheCoords = coords
end)

libCache('serverId', function(serverId)
	cacheServerId = serverId
end)

local function CanPerformAction()
	return not IsPedInAnyVehicle(cachePed, false) 
		and not LocalPlayer.state.IsDead 
		and not IsEntityDead(cachePed) 
		and not IsPedFalling(cachePed) 
		and not IsPedCuffed(cachePed) 
		and not IsPedDiving(cachePed) 
		and not IsPedInCover(cachePed, false) 
		and not IsPedInParachuteFreeFall(cachePed) 
		and GetPedParachuteState(cachePed) < 1 
		and not LocalPlayer.state.InTrunk 
		and not LocalPlayer.state.IsHandcuffed
end

local function CleanupProp()
	if Prop then
		DeleteEntity(Prop)
		Prop = nil
	end
end

local function CloseNui()
	SendNUIMessage({
		eventName = "nui:visible:update",
		elementId = "scoreboard",
		visible = false
	})
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
end

local focused = false
local lastGameTimerId = 0

lib.addKeybind({
	name = 'listagraczy',
	description = 'Otwórz listę graczy',
	defaultKey = 'Z',
	onPressed = function()
		if not ESX.IsPlayerLoaded() then return end

		local currentTime = GetGameTimer()
		if currentTime < lastGameTimerId then
			ESX.ShowNotification('Odczekaj 5 sekund przed następnym użyciem!')
			return
		end

		if IsPauseMenuActive() or not DoesEntityExist(cachePed) or not IsEntityVisible(cachePed) then
			return
		end

		IsDisplaying = false
		IsHoldingZ = true
		LocalPlayer.state:set('IsScoreboarding', true, true)

		if not ESX.IsPlayerAdminClient() and CanPerformAction() then
			TaskPlayAnim(cachePed, ANIM_DICT, ANIM_NAME, 8.0, -8.0, -1, 1, 0.0, false, false, false)
			IsDisplaying = true
			lastGameTimerId = currentTime + COOLDOWN_TIME

			ESX.Game.SpawnObject(CLIPBOARD_MODEL, {
				x = cacheCoords.x,
				y = cacheCoords.y,
				z = cacheCoords.z - 3
			}, function(object)
				AttachEntityToEntity(object, cachePed, GetPedBoneIndex(cachePed, BONE_INDEX_HAND), 
					0.1, 0.015, 0.12, 45.0, -130.0, 180.0, true, false, false, false, 0, true)
				Prop = object
			end)
		end
	end,
	onReleased = function()
		if not ESX.IsPlayerLoaded() then return end

		CloseNui()
		focused = false

		if IsDisplaying then
			StopAnimTask(cachePed, ANIM_DICT, ANIM_NAME, 1.0)
		end

		CleanupProp()
		IsDisplaying = nil
		IsHoldingZ = false
		IsNuiActive = false
		LocalPlayer.state:set('IsScoreboarding', nil, true)
	end,
})

local LastNuiUpdate = 0
local function UpdatePlayerList()
	if IsNuiActive then return end
	
	if not ESX.PlayerData or not ESX.PlayerData.job then return end

	local timer = GetGameTimer()
	
	if not Id or (timer - Timer > UPDATE_INTERVAL) then
		Timer = timer
		Id = nil
		TriggerServerEvent('esx_hud:showPlayers')
		return
	end

	if not ScoreboardInfo or not ScoreboardInfo.onlinePlayers then return end

	if timer - LastNuiUpdate <= NUI_UPDATE_INTERVAL then return end
	
	LastNuiUpdate = timer

	SendNUIMessage({
		eventName = "nui:data:update",
		dataId = "scoreboard-data",
		data = {
			onlinePlayers = tonumber(ScoreboardInfo.onlinePlayers),
			playerName = ScoreboardInfo.playerName,
			playerJob = ScoreboardInfo.playerJob,
			playerJobGrade = ScoreboardInfo.playerJobGrade,
			lspd = tonumber(ScoreboardInfo.lspd),
			lssd = tonumber(ScoreboardInfo.lssd),
			ems = tonumber(ScoreboardInfo.ems),
			doj = tonumber(ScoreboardInfo.doj),
			lsc = tonumber(ScoreboardInfo.lsc),
			ec = tonumber(ScoreboardInfo.ec),
			dangerCode = tostring(ScoreboardInfo.dangerCode)
		}
	})

	SendNUIMessage({
		eventName = "nui:visible:update",
		elementId = "scoreboard",
		visible = true
	})

	IsNuiActive = true
end

local groups = {
	['founder'] = { 252, 216, 10 },
	['developer'] = { 252, 216, 10 },
	['managment'] = { 252, 216, 10 },
	['headadmin'] = { 255, 0, 0 },
	['admin'] = { 0, 191, 255 },
	['moderator'] = { 132, 112, 255 },
	['helper'] = { 255, 165, 0 },
	['trialhelper'] = { 255, 255, 0 },
	['user'] = { 227, 230, 228 }
}

local tagsVisible = false

local function GetUpIndexForExclamation(target)
	if not IsHoldingZ then return 0.40 end
	
	local targetSrcString = tostring(target)
	local targetHasNametag = GlobalState.Nametags and GlobalState.Nametags[targetSrcString] ~= nil
	local targetIsStreamer = streamers[target] ~= nil
	
	if targetHasNametag and targetIsStreamer then return 0.80
	elseif targetHasNametag then return 0.65
	elseif targetIsStreamer then return 0.70
	else return 0.40 end
end

local function GetNametagColor(userNametag)
	local configColor = (Config and Config.NametagColors and Config.NametagColors[userNametag]) or {255, 255, 255}
	return {
		configColor[1] or 255,
		configColor[2] or 255,
		configColor[3] or 255,
		configColor[4] or 255
	}
end

local function DrawPlayerTags(target, player, playerPed, coords)
	if tagsVisible then return end
	
	local srcString = tostring(target)
	local hasNametag = GlobalState.Nametags and GlobalState.Nametags[srcString] ~= nil
	local isStreamer = streamers[target] ~= nil
	local isTalking = NetworkIsPlayerTalking(player)
	
	local idColor = isTalking and {255, 136, 0, 255} or {255, 255, 255, 255}
	ESX.Game.Utils.DrawText3D(vector3(coords.x, coords.y, coords.z + 0.4), tostring(target), 1.5, idColor, 4)
	
	if hasNametag then
		local userNametag = GlobalState.Nametags[srcString]
		local username = (GlobalState.Usernames and GlobalState.Usernames[srcString]) or ''
		local nametagText = userNametag .. (username ~= '' and (' ' .. username) or '')
		local nametagColor = GetNametagColor(userNametag)
		ESX.Game.Utils.DrawText3D(vector3(coords.x, coords.y, coords.z + 0.50), nametagText, 0.8, nametagColor, 4)
	end

	if isStreamer then
		local upIndex = hasNametag and 0.65 or 0.55
		ESX.Game.Utils.DrawText3D(vector3(coords.x, coords.y, coords.z + upIndex), 'NA ŻYWO', 1.15, {100, 65, 165, 255}, 4)
	end
end

Citizen.CreateThread(function()
	lib.requestAnimDict(ANIM_DICT)

	while true do
		local sleep = true
		local isPaused = IsPauseMenuActive()
		local pedExists = DoesEntityExist(cachePed)
		
		if not isPaused and pedExists then
			if PedSpectate then
				cachePed = PedSpectate
			end
			
			local isAdmin = ESX.IsPlayerAdminClient()
			local maxDist = isAdmin and ADMIN_DISTANCE or NORMAL_DISTANCE
			local camCoords = GetGameplayCamCoord()

			for _, player in ipairs(GetActivePlayers()) do
				local target = GetPlayerServerId(player)
				if target == cacheServerId then goto continue end
				
				local playerPed = GetPlayerPed(player)
				local playerState = Player(target).state
				local canDisplay = (IsEntityVisible(playerPed) or isAdmin) and not playerState.Spectating

				if canDisplay and playerState.IsScoreboarding and not tagsVisible then
					local coords = GetPedBoneCoords(playerPed, BONE_INDEX_HEAD)
					local distBetween = #(camCoords - coords)

					if distBetween < maxDist then
						sleep = false
						local upIndex = GetUpIndexForExclamation(target)
						ESX.Game.Utils.DrawText3D(vector3(coords.x, coords.y, coords.z + upIndex), '!', 1.55, {178, 15, 52, 255}, 4)
					end
				end
				::continue::
			end

			if IsHoldingZ then
				UpdatePlayerList()
				
				local ownCoords = GetPedBoneCoords(cachePed, BONE_INDEX_HEAD)
				local ownDistBetween = #(camCoords - ownCoords)
				if ownDistBetween < maxDist then
					sleep = false
					DrawPlayerTags(cacheServerId, PlayerId(), cachePed, ownCoords)
				end
				
				for _, player in ipairs(GetActivePlayers()) do
					local target = GetPlayerServerId(player)
					if target == cacheServerId then goto continue_tags end
					
					local playerPed = GetPlayerPed(player)
					local playerState = Player(target).state
					local canDisplay = (IsEntityVisible(playerPed) or isAdmin) and not playerState.Spectating

					if canDisplay then
						local coords = GetPedBoneCoords(playerPed, BONE_INDEX_HEAD)
						local distBetween = #(camCoords - coords)

						if distBetween < maxDist then
							sleep = false
							DrawPlayerTags(target, player, playerPed, coords)
						end
					end
					::continue_tags::
				end
			end
		end

		Citizen.Wait(sleep and SLEEP_TIME_IDLE or SLEEP_TIME_ACTIVE)
	end
end)

local function GetRangInfo(playerState)
	if playerState.vip then
		local color = groups['vip']
		return '[VIP] ', color and {color[1], color[2], color[3], 255} or {255, 255, 255, 255}
	elseif playerState.svip then
		local color = groups['svip']
		return '[SVIP] ', color and {color[1], color[2], color[3], 255} or {255, 255, 255, 255}
	elseif playerState.elite then
		local color = groups['elite']
		return '[ELITE] ', color and {color[1], color[2], color[3], 255} or {255, 255, 255, 255}
	end
	return '', {255, 255, 255, 255}
end

local function showTags()
	Citizen.CreateThread(function()
		while tagsVisible do
			local sleep = true
			local isAdmin = ESX.IsPlayerAdminClient()
			local maxDist = isAdmin and ADMIN_TAG_DISTANCE or NORMAL_TAG_DISTANCE
			local coords1 = GetPedBoneCoords(cachePed, BONE_INDEX_HEAD, -0.4, 0.0, 0.0)

			for _, player in ipairs(GetActivePlayers()) do
				local playerServerId = GetPlayerServerId(player)
				if playerServerId == Id then goto continue end
				
				local playerPed = GetPlayerPed(player)
				if not ((IsEntityVisible(playerPed) or isAdmin)) then goto continue end

				local coords2 = GetPedBoneCoords(playerPed, BONE_INDEX_HEAD, -0.4, 0.0, 0.0)
				local distance = #(coords1 - coords2)

				if distance < maxDist then
					sleep = false
					local playerState = Player(playerServerId).state
					local rang, rangColor = GetRangInfo(playerState)
					local talkingColor = NetworkIsPlayerTalking(player) and {71, 175, 255, 255} or rangColor
					
					ESX.Game.Utils.DrawText3D(vector3(coords2.x, coords2.y, coords2.z + 0.88), tostring(playerServerId), 1.0, talkingColor, 4)
					if rang ~= '' then
						ESX.Game.Utils.DrawText3D(vector3(coords2.x, coords2.y, coords2.z + 0.92), rang, 1.0, rangColor, 4)
					end
				end
				::continue::
			end

			Citizen.Wait(sleep and SLEEP_TIME_IDLE or SLEEP_TIME_ACTIVE)
		end
	end)
end

local ADMIN_GROUPS = {
	['founder'] = true,
	['developer'] = true,
	['managment'] = true,
	['headadmin'] = true,
	['admin'] = true,
	['trialadmin'] = true,
	['seniormod'] = true,
	['mod'] = true,
	['trialmod'] = true,
}

RegisterCommand('admintag', function()
	if ESX.PlayerData.group ~= 'user' and ADMIN_GROUPS[ESX.PlayerData.group] then
		tagsVisible = not tagsVisible
		if tagsVisible then
			showTags()
		end
	end
end, false)

RegisterNetEvent('esx_hud:showPlayers')
AddEventHandler('esx_hud:showPlayers', function(Data)
	Id = cacheServerId
	ScoreboardInfo = Data
end)

RegisterNUICallback('esx_hud:scoreboard:offFocus', function(data, cb)
	CloseNui()
	focused = false
	cb(true)
end)

RegisterNetEvent('esx_hud:open_admin_list', function(data)
	lib.registerContext({
		id = 'admins',
		title = 'Administratorzy na serwerze',
		options = data
	})

	lib.showContext('admins')
end)

RegisterNetEvent('esx_hud:updateStreamers', function(data)
	streamers = data
end)

RegisterNetEvent('esx_hud:updateDangerCode', function(newCode)
    if ScoreboardInfo then
        ScoreboardInfo.dangerCode = newCode
    end
end)