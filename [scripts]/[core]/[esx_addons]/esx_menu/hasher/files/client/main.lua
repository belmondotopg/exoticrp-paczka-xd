local esx_hud = exports.esx_hud

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	ESX.PlayerData.job = Job
end)

local libCache = lib.onCache
local cachePed = cache.ped
local cacheCoords = cache.coords
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
	cachePed = ped
end)

libCache('coords', function(coords)
	cacheCoords = coords
end)

libCache('vehicle', function(vehicle)
	cacheVehicle = vehicle
end)

local function DoorControl(door)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InBroker or LocalPlayer.state.InKomis then
		ESX.ShowNotification('Nie możesz teraz tego użyć!')
		return
	end

	if IsPedSittingInAnyVehicle(cachePed) then
		if cacheVehicle and GetPedInVehicleSeat(cacheVehicle, -1) == cachePed then
			if GetVehicleDoorAngleRatio(cacheVehicle, door) > 0.0 then
				SetVehicleDoorShut(cacheVehicle, door, false)
			else
				SetVehicleDoorOpen(cacheVehicle, door, false)
			end
		else
			ESX.ShowNotification('Nie jesteś na miejscu kierowcy')
		end
	end
end

local function getPedHair(ped)
	return {
		style = GetPedDrawableVariation(ped, 2),
		color = GetPedHairColor(ped),
		highlight = GetPedHairHighlightColor(ped),
		texture = GetPedTextureVariation(ped, 2)
	}
end

local FACE_FEATURES = {
	"noseWidth",
	"nosePeakHigh",
	"nosePeakSize",
	"noseBoneHigh",
	"nosePeakLowering",
	"noseBoneTwist",
	"eyeBrownHigh",
	"eyeBrownForward",
	"cheeksBoneHigh",
	"cheeksBoneWidth",
	"cheeksWidth",
	"eyesOpening",
	"lipsThickness",
	"jawBoneWidth",
	"jawBoneBackSize",
	"chinBoneLowering",
	"chinBoneLenght",
	"chinBoneSize",
	"chinHole",
	"neckThickness",
}

local function tofloat(num)
	return num + 0.0
end

local function round(number, decimalPlaces)
	return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", number))
end

local function isPedFreemodeModel(ped)
	local model = GetEntityModel(ped)
	return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
end

local function getPedFaceFeatures(ped)
	local size = #FACE_FEATURES
	local faceFeatures2 = {}
	
	for i = 1, size do
		local feature = FACE_FEATURES[i]
		faceFeatures2[feature] = round(GetPedFaceFeature(ped, i-1), 1)
	end
	
	return faceFeatures2
end

local function getPedDefaultFaceFeatures()
	local size = #FACE_FEATURES
	local faceFeatures = {}
	
	for i = 1, size do
		local feature = FACE_FEATURES[i]
		faceFeatures[feature] = 0
	end
	
	return faceFeatures
end

local function getPedHeadBlend(ped)
	local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))
	
	shapeMix = tonumber(string.sub(shapeMix, 0, 4))
	if shapeMix > 1 then shapeMix = 1 end
	
	skinMix = tonumber(string.sub(skinMix, 0, 4))
	if skinMix > 1 then skinMix = 1 end
	
	if not thirdMix then
		thirdMix = 0
	end
	thirdMix = tonumber(string.sub(thirdMix, 0, 4))
	if thirdMix > 1 then thirdMix = 1 end
	
	return {
		shapeFirst = shapeFirst,
		shapeSecond = shapeSecond,
		shapeThird = shapeThird,
		skinFirst = skinFirst,
		skinSecond = skinSecond,
		skinThird = skinThird,
		shapeMix = shapeMix,
		skinMix = skinMix,
		thirdMix = thirdMix
	}
end

local function getPedDefaultHeadBlend(ped)
	local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))
	
	return {
		shapeFirst = 0,
		shapeSecond = 0,
		shapeThird = 0,
		skinFirst = skinFirst,
		skinSecond = skinSecond,
		skinThird = skinThird,
		shapeMix = shapeMix,
		skinMix = skinMix,
		thirdMix = thirdMix
	}
end

local function setPedHeadBlend(ped, headBlend)
	if headBlend and isPedFreemodeModel(ped) then
		SetPedHeadBlendData(ped, headBlend.shapeFirst, headBlend.shapeSecond, headBlend.shapeThird, headBlend.skinFirst, headBlend.skinSecond, headBlend.skinThird, tofloat(headBlend.shapeMix or 0), tofloat(headBlend.skinMix or 0), tofloat(headBlend.thirdMix or 0), false)
	end
end

local function setPedFaceFeatures(ped, faceFeatures)
	if faceFeatures then
		for i = 1, #FACE_FEATURES do
			local feature = FACE_FEATURES[i]
			local value = faceFeatures[feature]
			if value then
				if tofloat(value) < -1 then
					value = -1
				elseif tofloat(value) > 1 then
					value = 1
				end
				SetPedFaceFeature(ped, i-1, tofloat(value))
			end
		end
	end
end

local markerplayer = nil

CreateThread(function()
	while true do
		if markerplayer then
			local ped = GetPlayerPed(markerplayer)
			local coords2 = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, 0x796E))
			if #(cacheCoords - coords2) < 20.0 then
				DrawMarker(0, coords2.x, coords2.y, coords2.z + 0.6, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.25, 64, 159, 247, 100, false, true, 2, false, false, false, false)
				Wait(0)
			else
				Wait(200)
			end
		else
			Wait(400)
		end
	end
end)

Values = {
	kills = 0,
	deaths = 0,
	headshots = 0,
	kd = 0
}

RegisterNetEvent("es_extended:setAfterWeaponData")
AddEventHandler("es_extended:setAfterWeaponData", function(kills, deaths, headshots)
	if kills then Values.kills = kills end
	if deaths then Values.deaths = deaths end
	if headshots then Values.headshots = headshots end

	if Values.kills ~= 0 and Values.deaths ~= 0 then
		Values.kd = Round(Values.kills / Values.deaths, 2)
	else
		Values.kd = 0
	end
end)

RegisterCommand('prawojazdy', function()
	if LocalPlayer.state.IsDead then return end
	exports['esx_hud']:openIDMenu('dmv')
end, false)

RegisterCommand('licencjabron', function()
	if LocalPlayer.state.IsDead then return end
	exports['esx_hud']:openIDMenu('weapon')
end, false)

RegisterCommand('odznaka', function()
	if LocalPlayer.state.IsDead then return end
	OpenOdznaka()
end, false)

local camMode = false

-- Thread do ukrywania HUD i rysowania letterboxingu
CreateThread(function()
	while true do
		Wait(0)
		if camMode then
			-- Ukryj wszystkie elementy HUD
			HideHudAndRadarThisFrame()
			HideHelpTextThisFrame()
			
			-- Ukryj wszystkie komponenty HUD
			for i = 0, 20 do
				HideHudComponentThisFrame(i)
			end
			
			-- Rysuj czarne paski (letterboxing) u góry i na dole
			-- Górny pasek
			DrawRect(0.5, 0.0, 1.0, 0.08, 0, 0, 0, 255)
			-- Dolny pasek
			DrawRect(0.5, 1.0, 1.0, 0.08, 0, 0, 0, 255)
		else
			Wait(500)
		end
	end
end)

RegisterCommand('cam', function()
	camMode = not camMode
	
	if camMode then
		TriggerEvent('esx_hud/hideHud', false)
		TriggerEvent('chat:toggleChat', true)
		LocalPlayer.state:set('CamMode', true, false)
		
		-- Ukryj wszystkie elementy HUD
		SendNUIMessage({
			eventName = "nui:visible:update",
			elementId = "carhud",
			visible = false
		})
		
		SendNUIMessage({
			eventName = "nui:visible:update",
			elementId = "radio",
			visible = false
		})
		
		SendNUIMessage({
			eventName = "nui:visible:update",
			elementId = "hud",
			visible = false
		})
		
		SendNUIMessage({
			eventName = "nui:visible:update",
			elementId = "watermark",
			visible = false
		})
		
		SendNUIMessage({
			eventName = "nui:visible:update",
			elementId = "bodycam",
			visible = false
		})
		
		DisplayRadar(false)
		
		ESX.ShowNotification('Tryb kamery włączony - HUD ukryty')
	else
		TriggerEvent('esx_hud/hideHud', true)
		TriggerEvent('chat:toggleChat', false)
		LocalPlayer.state:set('CamMode', false, false)
		ESX.ShowNotification('Tryb kamery wyłączony - HUD widoczny')
	end
end, false)

local lastGameTimerId = 0
local lastGameTimerDice = 0

RegisterNetEvent('esx_menu:changeColor', function(color)
	SendNUIMessage({
		action = 'changePBColor',
		color = color
	})
end)

RegisterNetEvent('esx_menu:showF8', function(data)
	print('[KILL-INFO] '..tostring(data))
end)

local closestStinger = 0
local closestStingerDistance = 0
local wheels = {
	["wheel_lf"] = 0,
	["wheel_rf"] = 1,
	["wheel_rr"] = 5,
	["wheel_lr"] = 4,
}

local function TouchingStinger(coords, stinger)
	local min, max = GetModelDimensions(GetEntityModel(stinger))
	local size = max - min
	local w, l, h = size.x, size.y, size.z
	local offset1 = GetOffsetFromEntityInWorldCoords(stinger, 0.0, l/2, h*-1)
	local offset2 = GetOffsetFromEntityInWorldCoords(stinger, 0.0, l/2 * -1, h)
	return IsPointInAngledArea(coords, offset1, offset2, w*2, 0, false)
end

CreateThread(function()
	while not NetworkIsSessionStarted() do
		Wait(500)
	end

	CreateThread(function()
		while true do
			local driving = DoesEntityExist(cacheVehicle)
			local coords = GetEntityCoords(driving and cacheVehicle or cachePed)
			local stinger = GetClosestObjectOfType(coords, 50.0, `p_ld_stinger_s`, false, false, false)
			
			if DoesEntityExist(stinger) then
				closestStinger = stinger
				closestStingerDistance = #(coords - GetEntityCoords(stinger))
			end

			if not DoesEntityExist(closestStinger) or #(coords - GetEntityCoords(closestStinger)) > 50.00 then
				closestStinger = 0
			end
			
			Wait(driving and 50 or 1000)
		end
	end)

	CreateThread(function()
		while true do
			Wait(1500)
			
			while DoesEntityExist(cacheVehicle) do
				Wait(50)
				
				while DoesEntityExist(closestStinger) and closestStingerDistance <= 50.00 do
					Wait(0)
					
					if cacheVehicle and IsEntityTouchingEntity(cacheVehicle, closestStinger) then
						for boneName, wheelId in pairs(wheels) do
							if not IsVehicleTyreBurst(cacheVehicle, wheelId, false) then
								if TouchingStinger(GetWorldPositionOfEntityBone(cacheVehicle, GetEntityBoneIndexByName(cacheVehicle, boneName)), closestStinger) then
									SetVehicleTyreBurst(cacheVehicle, wheelId, 1, 1148846080)
								end
							end
						end
					end
				end
			end
		end
	end)
end)

local function useDices()
	local state = LocalPlayer.state
	if state.IsDead or state.InBroker or state.InKomis or state.IsHandcuffed then
		ESX.ShowNotification('Nie możesz teraz tego użyć!')
		return
	end

	if GetGameTimer() > lastGameTimerDice then
		lib.requestAnimDict('anim@mp_player_intcelebrationmale@wank')
		TaskPlayAnim(cachePed, 'anim@mp_player_intcelebrationmale@wank', "wank", 18.0, 10.0, -1, 50, 0, false, false, false)
		TriggerServerEvent("esx_menu:dices")
		Wait(3000)
		ClearPedTasks(cachePed)
		lastGameTimerDice = GetGameTimer() + 5000
	else
		ESX.ShowNotification('Nie możesz tak często rzucać kostką')
	end
end

exports('useDices', useDices)

if not _G.esx_menu_isPlacingStinger then
	_G.esx_menu_isPlacingStinger = false
end
if not _G.esx_menu_lastStingerPlaceTime then
	_G.esx_menu_lastStingerPlaceTime = 0
end
local STINGER_COOLDOWN = 2000

RegisterNetEvent('esx_menu:placeStinger', function()
	local currentTime = GetGameTimer()
	
	if currentTime - _G.esx_menu_lastStingerPlaceTime < STINGER_COOLDOWN then
		return
	end
	
	if _G.esx_menu_isPlacingStinger then
		return
	end
	
	_G.esx_menu_isPlacingStinger = true
	_G.esx_menu_lastStingerPlaceTime = currentTime
	
	Wait(0)
	
	CreateThread(function()
		if ESX.PlayerData.job.name ~= 'police' then 
			_G.esx_menu_isPlacingStinger = false
			return 
		end

		local function LoadDict(Dict)
			while not HasAnimDictLoaded(Dict) do 
				Wait(0)
				RequestAnimDict(Dict)
			end
			return Dict
		end
		
		ESX.Game.SpawnObject('p_ld_stinger_s', vec3(cacheCoords.x, cacheCoords.y, cacheCoords.z + 0.5), function(object)					
			SetEntityAsMissionEntity(object, true, true)
			local netId = NetworkGetNetworkIdFromEntity(object)
			SetNetworkIdCanMigrate(netId, false)
			SetEntityHeading(object, GetEntityHeading(cachePed))
			FreezeEntityPosition(object, true)
			PlaceObjectOnGroundProperly(object)
			SetEntityVisible(object, false)

			local scene = NetworkCreateSynchronisedScene(cacheCoords, GetEntityRotation(cachePed, 2), 2, false, false, 1065353216, 0, 1.0)
			NetworkAddPedToSynchronisedScene(cachePed, scene, LoadDict("amb@medic@standing@kneel@enter"), "enter", 8.0, -8.0, 3341, 16, 1148846080, 0)
			NetworkStartSynchronisedScene(scene)

			while not IsSynchronizedSceneRunning(NetworkConvertSynchronisedSceneToSynchronizedScene(scene)) do
				Wait(0)
			end

			SetSynchronizedSceneRate(NetworkConvertSynchronisedSceneToSynchronizedScene(scene), 3.0)

			while GetSynchronizedScenePhase(NetworkConvertSynchronisedSceneToSynchronizedScene(scene)) < 0.14 do
				Wait(0)
			end

			NetworkStopSynchronisedScene(scene)

			PlayEntityAnim(object, "P_Stinger_S_Deploy", LoadDict("p_ld_stinger_s"), 1000.0, false, true, 0, 0.0, 0)
			
			while not IsEntityPlayingAnim(object, "p_ld_stinger_s", "P_Stinger_S_Deploy", 3) do
				Wait(0)
			end

			SetEntityVisible(object, true)

			while IsEntityPlayingAnim(object, "p_ld_stinger_s", "P_Stinger_S_Deploy", 3) and GetEntityAnimCurrentTime(object, "p_ld_stinger_s", "P_Stinger_S_Deploy") <= 0.99 do
				Wait(0)
			end

			PlayEntityAnim(object, "p_stinger_s_idle_deployed", LoadDict("p_ld_stinger_s"), 1000.0, false, true, 0, 0.99, 0)

			Wait(1000)
			
			if DoesEntityExist(object) then
				SetEntityAsMissionEntity(object, true, true)
				local netId = NetworkGetNetworkIdFromEntity(object)
				
				if netId and netId ~= 0 then
					NetworkRequestControlOfEntity(object)
					local timeout = 0
					while not NetworkHasControlOfEntity(object) and timeout < 50 do
						Wait(100)
						timeout = timeout + 1
					end
				end
			end
			
			_G.esx_menu_isPlacingStinger = false

			Wait(60000 * 5)

			if DoesEntityExist(object) then
				if exports.ox_target and exports.ox_target.removeEntity then
					exports.ox_target:removeEntity(object)
				end
				ESX.Game.DeleteObject(object)
			end
		end)
		
		CreateThread(function()
			Wait(10000)
			if _G.esx_menu_isPlacingStinger then
				_G.esx_menu_isPlacingStinger = false
			end
		end)
	end)
end)

local function vehStats()
	local veh = cache.vehicle
	if veh == 0 then
		ESX.ShowNotification("Nie znaleziono pojazdu.")
		return
	end

	local currentMods = ESX.Game.GetVehicleProperties(veh)

	lib.registerContext({
		id = 'vehstats',
		title = 'Pojazd ['..GetVehicleNumberPlateText(veh)..']',
		options = {
			{title = 'Ilość biegów ' .. tostring(GetVehicleHighGear(veh))},
			{title = 'Ilość miejsc siedzących ' .. tostring(GetVehicleMaxNumberOfPassengers(veh) + 1)},
			{title = 'Hamulce ' .. (currentMods.modBrakes + 1).."/"..GetNumVehicleMods(veh, 12)},
			{title = 'Pancerz ' .. (currentMods.modArmor + 1).."/"..GetNumVehicleMods(veh, 16)},
			{title = 'Silnik ' .. (currentMods.modEngine + 1).."/"..GetNumVehicleMods(veh, 11)},
			{title = 'Skrzynia biegów ' .. (currentMods.modTransmission + 1).."/"..GetNumVehicleMods(veh, 13)},
			{title = 'Zawieszenie ' .. (currentMods.modSuspension + 1).."/"..GetNumVehicleMods(veh, 15)},
			{title = 'Turbo ' .. (currentMods.modTurbo and "TAK" or "NIE")},
		}
	})

	lib.showContext('vehstats')
end

lib.registerRadial({
	id = 'self_menu',
	items = {
		{active = false, label = 'Ubrania', icon = 'fa-solid fa-shirt', id = 'ubrania', canInteract = function() return true end, menu = 'ubrania_menu'},
		{active = false, id = 'dokumenty', label = 'Dokumenty', icon = 'file-lines', menu = "docs_menu"},
		{label = "Rzuć kością", icon = 'dice', onSelect = function() exports.esx_menu:useDices() end},
		{label = 'Zarządzanie pracą', icon = 'bars', onSelect = function() exports.esx_multijob:OpenJobMenu() end},
		{label = 'Faktury', icon = 'fa-solid fa-receipt', onSelect = function() exports["s1n_billing"]:openBillingMenu() end},
		{label = 'Statystyki postaci', icon = 'fa-solid fa-chart-simple', onSelect = function() exports["esx_hud"]:openStatisticsMenu() end}
		--{label = 'Dostosuj pozycję', icon = 'fa-solid fa-user-plus', onSelect = function() exports.esx_position:showMenu() end},
	}
})

lib.registerRadial({
	id = 'editor_menu',
	items = {
		{label = "Anuluj", icon = 'xmark', onSelect = function() StopRecordingAndDiscardClip() end},
		{label = "Zapisz", icon = 'floppy-disk', onSelect = function() StopRecordingAndSaveClip() end},
		{label = "Nagraj", icon = 'camera', onSelect = function() StartRecording(1) end},
	}
})

lib.registerRadial({
	id = 'panic_menu',
	items = {
		{label = "Code 3", icon = 'bell', onSelect = function() ExecuteCommand("bk 3") end},
		{label = "Code 2", icon = 'bell', onSelect = function() ExecuteCommand("bk 2") end},
		{label = "Code 1", icon = 'bell', onSelect = function() ExecuteCommand("bk 1") end},
		{label = "Code 0", icon = 'bell', onSelect = function() ExecuteCommand("bk 0") end},
	}
})

lib.registerRadial({
	id = 'drzwi_menu',
	items = {
		{label = 'LP Drzwi', icon = 'fas fa-door-open', onSelect = function() DoorControl(0) end},
		{label = 'PP Drzwi', icon = 'fas fa-door-open', onSelect = function() DoorControl(1) end},
		{label = 'LT Drzwi', icon = 'fas fa-door-open', onSelect = function() DoorControl(2) end},
		{label = 'PT Drzwi', icon = 'fas fa-door-open', onSelect = function() DoorControl(3) end},
		{label = 'Maska', icon = 'fas fa-door-open', onSelect = function() DoorControl(4) end},
		{label = 'Bagażnik', icon = 'fas fa-door-open', onSelect = function() DoorControl(5) end},
	}
})

lib.registerRadial({
	id = 'vehicle_menu',
	items = {
		{label = "Sprawdź tuning", icon = 'radio', onSelect = function() vehStats() end},
		{label = "Zarządzaj", icon = 'gear', onSelect = function() ExecuteCommand('carcontrol') end},
		{label = "Radio samochodowe", icon = 'radio', onSelect = function() exports['exotic_carradio']:OpenRadio() end},
	}
})

lib.registerRadial({
	id = 'docs_menu',
	items = {
		{label = "Dowód", icon = 'id-card', onSelect = function() exports['esx_hud']:ShowCardProximity('document-id') end},
		{label = "Wizytówka", icon = 'fas fa-address-card', onSelect = function() exports['esx_hud']:ShowCardProximity('business-card') end},
		{label = "Odznaka", icon = 'fas fa-id-badge', onSelect = function() exports['esx_hud']:ShowCardProximity('badge') end, canInteract = function() return (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'offpolice') or (ESX.PlayerData.job.name == 'sheriff' or ESX.PlayerData.job.name == 'offsheriff') end}
	}
})

CheckJob = function()
	ExecuteCommand('multijobs')
end

OpenMDT = function()
	local job = ESX.PlayerData.job.name
	if job == 'police' or job == 'sheriff' then
		TriggerEvent('qf_mdt/openTablet')
	elseif job == 'ambulance' then
		TriggerEvent('qf_mdt_ems/openTablet')
	elseif job == 'mechanik' then
		TriggerEvent('qf_mdt_lsc/openTablet')
	elseif job == 'ec' then
		TriggerEvent('qf_mdt_ec/openTablet')
	end
end

OpenOdznaka = function()
	exports['esx_hud']:ShowCardProximity('badge')
end

local function openPhone()
	if not exports['simcards']:HasActiveSimCard() then
		TriggerEvent('vwk/phone/notify', "KARTA SIM", "Nie posiadasz aktyowanej karty SIM!", "Settings")
		return false
	end

	if exports['simcards']:isSimTookOut(exports["lb-phone"]:GetEquippedPhoneNumber()) then
		TriggerEvent('vwk/phone/notify', "KARTA SIM", "Nie posiadasz włożonej karty sim!", "Settings")
		return false
	end

	local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber()
	exports['simcards']:isSimDeactivated(phoneNumber, function(blocked)
		if blocked then
			TriggerEvent('vwk/phone/notify', "KARTA SIM", "Ten numer telefonu jest dezaktyowany!", "Settings")
			return
		end
		exports["lb-phone"]:ToggleOpen()
	end)
end

exports('openPhone', openPhone)

local elements = {
	{active = false, id = 'vehicle', label = 'Pojazd', icon = 'car', canInteract = function() return cache.vehicle and cache.vehicle ~= 0 end, menu = "vehicle_menu"},
	{active = false, id = 'animacje', label = 'Animacje', icon = 'masks-theater', 
	canInteract = function() 
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
		return true
	end, onSelect = function()
		lib.hideRadial()
		exports.esx_animations:openAnims()
	end},
	{active = false, id = 'telefon', label = 'Telefon', icon = 'fa-solid fa-phone-alt', canInteract = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
		if exports["lb-phone"]:IsOpen() then return false end
		if (exports.ox_inventory:Search("count", "phone") or 0) < 1 then return false end
		return true
	end, onSelect = function()
		lib.hideRadial()
		openPhone()
	end},
	{active = false, id = 'garage-open', label = 'Otwórz Garaż', icon = 'fa-solid fa-car', canInteract = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or cacheVehicle then return false end
		if not exports["op-garages"]:GetNearestGarage() then return false end
		return true
	end, onSelect = function()
		local NearestGarage = exports["op-garages"]:GetNearestGarage()
		lib.hideRadial()
		NearestGarage["OnSelect"]()
	end},
	{active = false, id = 'garage-pull', label = 'Schowaj Pojazd', icon = 'fa-solid fa-car', canInteract = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or not cacheVehicle then return false end
		if not exports["op-garages"]:GetNearestGarage() then return false end
		return true
	end, onSelect = function()
		local NearestGarage = exports["op-garages"]:GetNearestGarage()
		lib.hideRadial()
		NearestGarage["OnSelect"]()
	end},
	{active = false, id = 'impound-open', label = 'Odholuj Pojazd', icon = 'fa-solid fa-truck-front', canInteract = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
		if not exports["op-garages"]:GetNearestImpound() then return false end
		return true
	end, onSelect = function()
		local NearestGarage = exports["op-garages"]:GetNearestImpound()
		lib.hideRadial()
		NearestGarage["OnSelect"]()
	end},
	{active = false, id = 'fraction_lspd', label = 'Frakcja', icon = 'fa-solid fa-user-astronaut', canInteract = function()
		local job = ESX.PlayerData.job.name
		return (job == 'police' or job == 'offpolice')
	end, menu = "lspd_menu"},
	{active = false, id = 'fraction_sheriff', label = 'Frakcja', icon = 'fa-solid fa-user-astronaut', canInteract = function()
		local job = ESX.PlayerData.job.name
		return (job == 'sheriff' or job == 'offsheriff')
	end, menu = "sheriff_menu"},
	{active = false, id = 'fraction_doj', label = 'Frakcja', icon = 'fa-solid fa-user-astronaut', canInteract = function()
		local job = ESX.PlayerData.job.name
		return job == 'doj' or job == 'offdoj'
	end, menu = "doj_menu"},
	{active = false, id = 'fraction_ems', label = 'Frakcja', icon = 'fa-solid fa-user-astronaut', canInteract = function()
		local job = ESX.PlayerData.job.name
		return job == 'ambulance' or job == 'offambulance'
	end, menu = "ems_menu"},
	{active = false, id = 'fraction_lsc', label = 'Frakcja', icon = 'fa-solid fa-user-astronaut', canInteract = function()
		local job = ESX.PlayerData.job.name
		return job == 'mechanik' or job == 'offmechanik'
	end, menu = "lsc_menu"},
	{active = false, id = 'fraction_ec', label = 'Frakcja', icon = 'fa-solid fa-user-astronaut', canInteract = function()
		local job = ESX.PlayerData.job.name
		return job == 'ec'
	end, menu = "ec_menu"},
	{active = false, id = 'char', label = 'Postać', icon = 'user', menu = "self_menu"},
	{active = false, id = 'event', label = 'Święta', icon = 'fa-solid fa-calendar', canInteract = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
		return true
	end, onSelect = function()
		lib.hideRadial()
		exports['exotic_coinranking']:openShop()
	end},
	{active = false, id = 'editor', label = 'Editor', icon = 'camera', canInteract = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
		return true
	end, menu = "editor_menu"},
}

lib.addKeybind({
	name = 'radialmenu',
	description = 'Otwórz Radial Menu',
	defaultKey = 'F1',
	onPressed = function()
		if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
		
		ESX.UI.Menu.CloseAll()

		for k, v in pairs(elements) do
			local success, resp = pcall(v.canInteract)

			if not success or resp then
				if not v.active then
					elements[k].active = true
					lib.addRadialItem(v)
				end
			else
				elements[k].active = false
				lib.removeRadialItem(v.id)
			end
		end

		Wait(1)
		TriggerEvent('ox_lib:openRadial')
	end,
})

local function createClothingAction(clothType, componentId, targetValue, animDict, animClip, animDuration, isProp, propId)
	return function()
		local skin1, skin2
		local currentValue
		
		if isProp then
			skin1 = GetPedPropIndex(cachePed, propId)
			skin2 = GetPedPropTextureIndex(cachePed, propId)
			currentValue = skin1
		else
			skin1 = GetPedDrawableVariation(cachePed, componentId)
			skin2 = GetPedTextureVariation(cachePed, componentId)
			currentValue = skin1
		end
		
		if currentValue ~= targetValue then
			if isProp then
				ClearPedProp(cachePed, propId)
			else
				SetPedComponentVariation(cachePed, componentId, targetValue, 0, 2)
			end
			
			TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)
			
			if animDict and animClip then
				lib.requestAnimDict(animDict)
				TaskPlayAnim(cachePed, animDict, animClip, 3.0, 3.0, animDuration or 1200, 51, 0, false, false, false)
			end
		end
	end
end

lib.registerRadial({
	id = 'ubrania_menu',
	items = {
		{label = 'Tułów', icon = 'fa-solid fa-shirt', onSelect = function()
			clothType = 'torso'
			skin1 = GetPedDrawableVariation(cachePed, 11)
			skin2 = GetPedTextureVariation(cachePed, 11)
			skin3 = GetPedDrawableVariation(cachePed, 3)
			skin4 = GetPedTextureVariation(cachePed, 3)
			skin5 = GetPedDrawableVariation(cachePed, 8)
			skin6 = GetPedTextureVariation(cachePed, 8)
			
			if GetPedDrawableVariation(cachePed, 11) ~= 15 then
				SetPedComponentVariation(cachePed, 11, 15, 0, 0)
				if GetPedDrawableVariation(cachePed, 3) ~= 15 then
					SetPedComponentVariation(cachePed, 3, 15, 0, 0)
				end
				SetPedComponentVariation(cachePed, 8, -1, 0, 2)
				TriggerServerEvent('esx_core:add:clothestorso', skin1, skin2, skin3, skin4, skin5, skin6, clothType)
				lib.requestAnimDict('clothingtie')
				TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
			end
		end},
		{label = 'T-shirt', icon = 'fa-solid fa-tshirt', onSelect = function()
			clothType = 'tshirt'
			local skin1 = GetPedDrawableVariation(cachePed, 8)
			local skin2 = GetPedTextureVariation(cachePed, 8)
			local current = GetPedDrawableVariation(cachePed, 8)
			if current ~= -1 then
				SetPedComponentVariation(cachePed, 8, -1, 0, 2)
				TriggerServerEvent('esx_core:add:clothestshirt', skin1, skin2)
				lib.requestAnimDict('clothingtie')
				TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
			end
		end},
		{label = 'Spodnie', icon = 'fa-solid fa-people-arrows', onSelect = createClothingAction('jeans', 4, 14, 're@construction', 'out_of_breath', 1300)},
		{label = 'Buty', icon = 'fa-solid fa-shoe-prints', onSelect = createClothingAction('shoes', 6, 34, 'random@domestic', 'pickup_low', 1200)},
		{label = 'Maska', icon = 'fa-solid fa-masks-theater', onSelect = function()
			clothType = 'mask'
			local skin1 = GetPedDrawableVariation(cachePed, 1)
			local skin2 = GetPedTextureVariation(cachePed, 1)
			local current = GetPedDrawableVariation(cachePed, 1)
			if current ~= 0 and current ~= -1 then
				SetPedComponentVariation(cachePed, 1, -1, 0, 2)
				TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)
				lib.requestAnimDict('mp_masks@standard_car@ds@')
				TaskPlayAnim(cachePed, 'mp_masks@standard_car@ds@', 'put_on_mask', 3.0, 3.0, 800, 51, 0, false, false, false)
			else
				local playerData = ESX.GetPlayerData()
				if playerData and playerData.inventory then
					for slot, item in pairs(playerData.inventory) do
						if item and item.name == 'mask' and item.count and item.count > 0 and item.metadata and item.metadata.accessories and item.metadata.accessories2 then
							TriggerEvent('esx_core:clothes:mask', {name = item.name, slot = item.slot or slot, metadata = item.metadata})
							lib.requestAnimDict('mp_masks@standard_car@ds@')
							TaskPlayAnim(cachePed, 'mp_masks@standard_car@ds@', 'put_on_mask', 3.0, 3.0, 800, 51, 0, false, false, false)
							break
						end
					end
				end
			end
		end},
		{label = 'Czapka', icon = 'fa-solid fa-hat-cowboy', onSelect = createClothingAction('helmet', 0, -1, 'mp_masks@standard_car@ds@', 'put_on_mask', 600, true, 0)},
		{label = 'Okulary', icon = 'fa-solid fa-glasses', onSelect = createClothingAction('glasses', 1, -1, 'clothingspecs', 'take_off', 1200, true, 1)},
		{label = 'Rękawiczki', icon = 'fa-solid fa-mitten', onSelect = createClothingAction('arms', 3, 15, 'nmt_3_rcm-10', 'cs_nigel_dual-10', 600)},
		{label = 'Torba', icon = 'fa-solid fa-people-carry-box', onSelect = createClothingAction('bagcloth', 5, -1, 'clothingtie', 'try_tie_negative_a', 1200, true, 5)},
		{label = 'Kamizelka', icon = 'fa-solid fa-vest', onSelect = createClothingAction('vest', 9, -1, 'clothingtie', 'try_tie_negative_a', 1200)},
		{label = 'Łańcuch', icon = 'fa-solid fa-link', onSelect = function()
			clothType = 'chain'
			local skin1 = GetPedDrawableVariation(cachePed, 7)
			local skin2 = GetPedTextureVariation(cachePed, 7)
			local current = GetPedDrawableVariation(cachePed, 7)
			if current ~= 0 and current ~= -1 then
				SetPedComponentVariation(cachePed, 7, -1, 0, 2)
				TriggerServerEvent('esx_core:add:clothes', skin1, skin2, clothType)
				lib.requestAnimDict('clothingtie')
				TaskPlayAnim(cachePed, 'clothingtie', 'try_tie_negative_a', 3.0, 3.0, 1200, 51, 0, false, false, false)
			end
		end},
		{label = 'Branzoletka', icon = 'fa-solid fa-ring', onSelect = createClothingAction('bracelet', 7, -1, 'nmt_3_rcm-10', 'cs_nigel_dual-10', 1200, true, 7)},
		{label = 'Zegarek', icon = 'fa-solid fa-clock', onSelect = createClothingAction('watchcloth', 6, -1, 'nmt_3_rcm-10', 'cs_nigel_dual-10', 1200, true, 6)},
		{label = 'Ucho', icon = 'fa-solid fa-ear-listen', onSelect = createClothingAction('ears', 2, -1, 'mp_cp_stolen_tut', 'b_think', 900, true, 2)},
		{label = 'Popraw włosy', icon = 'fa-solid fa-scissors', onSelect = function()
			if hairOld ~= nil then
				SetPedComponentVariation(cachePed, 2, hairOld, 0, 2)
				hairOld = nil
			else
				hairOld = getPedHair(cachePed).style
				SetPedComponentVariation(cachePed, 2, -1, 0, 2)	
			end
		end},
		{label = 'Popraw maskę', icon = 'fa-regular fa-face-smile-beam', onSelect = function()
			if faceOld ~= nil and blendOld ~= nil then
				setPedFaceFeatures(cachePed, faceOld)
				setPedHeadBlend(cachePed, blendOld)
				faceOld = nil
				blendOld = nil
			else
				faceOld = getPedFaceFeatures(cachePed)
				blendOld = getPedHeadBlend(cachePed)
				local faceFeatures = getPedDefaultFaceFeatures()
				local headBlend = getPedDefaultHeadBlend(cachePed)
				setPedFaceFeatures(cachePed, faceFeatures)
				setPedHeadBlend(cachePed, headBlend)
			end
		end},
	}
})

lib.registerRadial({
	id = 'lsc_menu',
	items = {
		{label = 'Obiekty', icon = 'fa-solid fa-road-barrier', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "mechanik" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			if cacheVehicle then ESX.ShowNotification('Nie możesz tego zrobić w pojeździe!') return end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_mecano_actions_spawn', {
				title = "Obiekty",
				align = 'center',
				elements = {
					{label = 'Słupek', value = 'prop_roadcone01b'},
					{label = 'Barierka', value = 'prop_barrier_work01b'},
					{label = 'Przybornik', value = 'prop_toolchest_02'},
				},
			}, function(data2, menu2)
				local forward = GetEntityForwardVector(cachePed)
				local objectCoords = (cacheCoords + forward * 1.0)
				
				if GetGameTimer() > lastGameTimerId then
					ESX.Game.SpawnObject(data2.current.value, objectCoords, function(obj)			
						SetEntityHeading(obj, GetEntityHeading(cachePed))
						PlaceObjectOnGroundProperly(obj)
						FreezeEntityPosition(obj, true)
						SetEntityCollision(obj, true)
						Wait(60000 * 5)
						DeleteObject(obj)
					end)
					lastGameTimerId = GetGameTimer() + 5000
				else
					ESX.ShowNotification('Nie możesz tak szybko tego używać!')
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end},
		{label = 'Odznaka', icon = 'fas fa-id-badge', onSelect = function()
		if ESX.PlayerData.job.name ~= "mechanik" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['esx_hud']:ShowCardProximity('badge')
		end},
		{label = 'Tablet', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "mechanik" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			TriggerEvent('qf_mdt_lsc/openTablet')
		end},
	}
})

lib.registerRadial({
	id = 'ec_menu',
	items = {
		{label = 'Obiekty', icon = 'fa-solid fa-road-barrier', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "ec" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			if cacheVehicle then ESX.ShowNotification('Nie możesz tego zrobić w pojeździe!') return end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_mecano_actions_spawn', {
				title = "Obiekty",
				align = 'center',
				elements = {
					{label = 'Słupek', value = 'prop_roadcone01b'},
					{label = 'Barierka', value = 'prop_barrier_work01b'},
					{label = 'Przybornik', value = 'prop_toolchest_02'},
				},
			}, function(data2, menu2)
				local forward = GetEntityForwardVector(cachePed)
				local objectCoords = (cacheCoords + forward * 1.0)
				
				if GetGameTimer() > lastGameTimerId then
					ESX.Game.SpawnObject(data2.current.value, objectCoords, function(obj)			
						SetEntityHeading(obj, GetEntityHeading(cachePed))
						PlaceObjectOnGroundProperly(obj)
						FreezeEntityPosition(obj, true)
						SetEntityCollision(obj, true)
						Wait(60000 * 5)
						DeleteObject(obj)
					end)
					lastGameTimerId = GetGameTimer() + 5000
				else
					ESX.ShowNotification('Nie możesz tak szybko tego używać!')
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end},
		{label = 'Odznaka', icon = 'fas fa-id-badge', onSelect = function()
		if ESX.PlayerData.job.name ~= "ec" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['esx_hud']:ShowCardProximity('badge')
		end},
		{label = 'Tablet', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "ec" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			TriggerEvent('qf_mdt_ec/openTablet')
		end},
	}
})

local Police_PROPS = {
	['Kolczatka'] = {model = 'p_ld_stinger_s'},
	['Pachołek'] = {model = 'prop_roadcone01b'},
	['Barierka'] = {model = 'prop_barrier_work05'},
}

if not _G.esx_menu_stingerModelAdded then
	_G.esx_menu_stingerModelAdded = false
end
if not _G.esx_menu_stingerModelAdding then
	_G.esx_menu_stingerModelAdding = false
end

CreateThread(function()
	Wait(2000)
	
	if _G.esx_menu_stingerModelAdding or _G.esx_menu_stingerModelAdded then
		return
	end
	
	_G.esx_menu_stingerModelAdding = true
	
	Wait(0)
	
	if _G.esx_menu_stingerModelAdded then
		_G.esx_menu_stingerModelAdding = false
		return
	end

	_G.esx_menu_stingerModelAdded = true
	_G.esx_menu_stingerModelAdding = false
	
	exports.ox_target:addModel(`p_ld_stinger_s`, {
		{
			icon = 'fa-solid fa-lock',
			label = 'Podnieś Kolczatka',
			distance = 2.0,
			groups = {['police'] = 0},
			canInteract = function(entity, distance, coords, name, bone)
				if not entity or entity == 0 then return false end
				if not DoesEntityExist(entity) then return false end
				
				local isFrozen = IsEntityPositionFrozen(entity)
				local isVisible = GetEntityAlpha(entity) > 0
				
				return isFrozen and isVisible
			end,
			onSelect = function(data)
				local entity = data.entity
				if not entity or not DoesEntityExist(entity) then 
					return 
				end
				
				if esx_hud:progressBar({
					duration = 1.5,
					label = 'Podnoszenie Kolczatka',
					useWhileDead = false,
					canCancel = true,
					disable = {car = true, move = true},
					anim = {dict = 'amb@prop_human_bum_bin@idle_b', clip = 'idle_d'},
				}) then
					if DoesEntityExist(entity) then
						exports.ox_target:removeEntity(entity)
						SetEntityAsMissionEntity(entity, true, true)
						DeleteEntity(entity)
						Wait(50)
						if DoesEntityExist(entity) then
							ESX.Game.DeleteObject(entity)
						end
					end
				end
			end
		},
	})
end)


local confirmed
local heading

function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	return {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
end

function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = {
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

function setProp(prop)
	local modelHash = joaat(prop)
	heading = 0.0
	confirmed = false

	RequestModel(modelHash)
	while not HasModelLoaded(modelHash) do
		RequestModel(modelHash)
		Wait(0)
	end

	local playerPed = cachePed
	local playerCoords = cacheCoords
	local forward = GetEntityForwardVector(playerPed)
	
	local spawnCoords = vector3(
		playerCoords.x + forward.x * 2.0,
		playerCoords.y + forward.y * 2.0,
		playerCoords.z
	)

	local propObject = CreateObject(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, false)
	
	if not DoesEntityExist(propObject) then
		print("Błąd: Nie udało się utworzyć obiektu dla modelu: " .. prop)
		return
	end
	
	SetEntityAsMissionEntity(propObject, true, true)
	SetEntityVisible(propObject, true, false)
	SetEntityAlpha(propObject, 100, false)
	FreezeEntityPosition(propObject, true)
	SetEntityCollision(propObject, false, false)
	SetModelAsNoLongerNeeded(modelHash)

	lib.showTextUI("[◀] LEWO \n[▶] PRAWO \n[ENTER] POSTAW\n[BACKSPACE] ANULUJ", {
		position = 'top-center',
		style = {borderRadius = 0}
	})

	CreateThread(function()
		while not confirmed do
			if not DoesEntityExist(propObject) then
				confirmed = true
				lib.hideTextUI()
				break
			end
			
			local hit, coords, entity = RayCastGamePlayCamera(5.0)
			
			if hit and coords then
				SetEntityCoordsNoOffset(propObject, coords.x, coords.y, coords.z, false, false, false, true)
			else
				local playerCoords = cacheCoords
				local forward = GetEntityForwardVector(cachePed)
				local fallbackCoords = vector3(
					playerCoords.x + forward.x * 2.0,
					playerCoords.y + forward.y * 2.0,
					playerCoords.z
				)
				SetEntityCoordsNoOffset(propObject, fallbackCoords.x, fallbackCoords.y, fallbackCoords.z, false, false, false, true)
			end

			FreezeEntityPosition(propObject, true)
			SetEntityCollision(propObject, false, false)
			SetEntityAlpha(propObject, 100, false)
			SetEntityVisible(propObject, true, false)
			SetEntityHeading(propObject, heading)
			Wait(0)

			if IsControlPressed(0, 174) then
				heading = heading + 1.0
			elseif IsControlPressed(0, 175) then
				heading = heading - 1.0
			end
			
			if heading > 360.0 then
				heading = 0.0
			elseif heading < 0.0 then
				heading = 360.0
			end

			SetEntityHeading(propObject, heading)

			if IsControlJustPressed(0, 18) then
				if #(GetEntityCoords(propObject) - GetEntityCoords(cache.ped)) < 2.0 then
					if esx_hud:progressBar({
						duration = 2,
						label = 'Kładzenie...',
						useWhileDead = false,
						canCancel = true,
						disable = {move = true, car = true, combat = true},
						anim = {dict = 'amb@prop_human_bum_bin@idle_b', clip = 'idle_d'},
					}) then
						confirmed = true
						lib.hideTextUI()
						SetEntityAlpha(propObject, 255, false)
						SetEntityCollision(propObject, true, true)
						
						local modelName = GetEntityModel(propObject)
						local propName = nil
						for k, v in pairs(Police_PROPS) do
							if GetHashKey(v.model) == modelName then
								propName = k
								break
							end
						end
						
						if propName then
							exports.ox_target:addEntity(propObject, {
								{
									icon = 'fa-solid fa-lock',
									label = 'Podnieś '..propName,
									groups = {['police'] = 0},
									onSelect = function(data)
										if esx_hud:progressBar({
											duration = 1.5,
											label = 'Podnoszenie '..propName,
											useWhileDead = false,
											canCancel = true,
											disable = {car = true, move = true},
											anim = {dict = 'amb@prop_human_bum_bin@idle_b', clip = 'idle_d'},
										}) then
											exports.ox_target:removeEntity(data.entity)
											ESX.Game.DeleteObject(data.entity)
										end
									end
								},
							})
						end
					else
						confirmed = true
						DeleteObject(propObject)
						lib.hideTextUI()
					end
				else
					ESX.ShowNotification('Prop musi być bliżej ciebie!')
				end
			end
			if IsControlJustPressed(0, 177) then
				confirmed = true
				DeleteObject(propObject)
				lib.hideTextUI()
			end
		end
	end)
end

lib.registerRadial({
	id = 'lspd_menu',
	items = {
		{label = 'Obiekty', icon = 'fa-solid fa-road-barrier', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "police" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			if cacheVehicle then ESX.ShowNotification('Nie możesz tego zrobić w pojeździe!') return end
			
			local table = {}
			for k, v in pairs(Police_PROPS) do
				table[#table+1] = {label = k, value = v.model}
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title = 'Interakcja z ruchem',
				align = 'center',
				elements = table
			}, function(data2, menu2)
				local forward = GetEntityForwardVector(cachePed)
				local objectCoords = (cacheCoords + forward * 1.0)
				
				if GetGameTimer() > lastGameTimerId then
					if data2.current.value == 'p_ld_stinger_s' then
						TriggerServerEvent('esx_menu:placeStinger')
					else
						setProp(data2.current.value)
						ESX.UI.Menu.CloseAll()
					end
					lastGameTimerId = GetGameTimer() + 5000
				else
					ESX.ShowNotification('Nie możesz tak szybko tego używać!')
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end},
		{label = 'Odznaka', icon = 'fas fa-id-badge', onSelect = function()
			if ESX.PlayerData.job.name ~= "police" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['esx_hud']:ShowCardProximity('badge')
		end},
		{label = 'Tablet', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "police" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			TriggerEvent('qf_mdt/openTablet')
		end},
		{label = 'Tablet [BOSSMENU]', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "police" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
				if hasWeaponLicense then
					TriggerServerEvent('esx_society:openbosshub', 'fraction', false, false)
				else
					if ESX.PlayerData.job.grade > 9 then
						TriggerServerEvent('esx_society:openbosshub', 'fraction', false, false)
					else
						ESX.ShowNotification("Nie posiadasz dostępu do tego elementu!")
					end
				end
			end, cache.serverId, 'cb')
		end},
	}
})

lib.registerRadial({
	id = 'sheriff_menu',
	items = {
		{label = 'Obiekty', icon = 'fa-solid fa-road-barrier', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "sheriff" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			if cacheVehicle then ESX.ShowNotification('Nie możesz tego zrobić w pojeździe!') return end
			
			local table = {}
			for k, v in pairs(Police_PROPS) do
				table[#table+1] = {label = k, value = v.model}
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title = 'Interakcja z ruchem',
				align = 'center',
				elements = table
			}, function(data2, menu2)
				local forward = GetEntityForwardVector(cachePed)
				local objectCoords = (cacheCoords + forward * 1.0)
				
				if GetGameTimer() > lastGameTimerId then
					if data2.current.value == 'p_ld_stinger_s' then
						TriggerServerEvent('esx_menu:placeStinger')
					else
						setProp(data2.current.value)
						ESX.UI.Menu.CloseAll()
					end
					lastGameTimerId = GetGameTimer() + 5000
				else
					ESX.ShowNotification('Nie możesz tak szybko tego używać!')
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end},
		{label = 'Odznaka', icon = 'fas fa-id-badge', onSelect = function()
			if ESX.PlayerData.job.name ~= "sheriff" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['esx_hud']:ShowCardProximity('badge')
		end},
		{label = 'Tablet', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "sheriff" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			TriggerEvent('qf_mdt_sheriff/openTablet')
		end},
		{label = 'Tablet [BOSSMENU]', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "sheriff" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
				if hasWeaponLicense then
					TriggerServerEvent('esx_society:openbosshub', 'fraction', false, false)
				else
					if ESX.PlayerData.job.grade > 9 then
						TriggerServerEvent('esx_society:openbosshub', 'fraction', false, false)
					else
						ESX.ShowNotification("Nie posiadasz dostępu do tego elementu!")
					end
				end
			end, cache.serverId, 'cb')
		end},
	}
})

lib.registerRadial({
	id = 'doj_menu',
	items = {
		{label = 'Legitymacja', icon = 'fas fa-id-badge', onSelect = function()
			if ESX.PlayerData.job.name ~= "doj" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['esx_hud']:ShowCardProximity('badge')
		end},
		{label = 'Tablet', icon = 'fas fa-tablet', onSelect = function()
			if ESX.PlayerData.job.name ~= "doj" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['p_dojmdt']:openTablet(skipAnim)
		end},
	}
})

lib.registerRadial({
	id = 'ems_menu',
	items = {
		{label = 'Odznaka', icon = 'fas fa-id-badge', onSelect = function()
			if ESX.PlayerData.job.name ~= "ambulance" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			exports['esx_hud']:ShowCardProximity('badge')
		end},
		{label = 'Tablet', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "ambulance" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			TriggerEvent('qf_mdt_ems/openTablet')
		end},
		{label = 'Tablet [BOSSMENU]', icon = 'fa-solid fa-tablet-screen-button', onSelect = function()
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return end
			if ESX.PlayerData.job.name ~= "ambulance" then ESX.ShowNotification("Nie posiadasz dostępu!") return end
			TriggerServerEvent('esx_society:openbosshub', 'fraction', false, false)
		end},
	}
})
