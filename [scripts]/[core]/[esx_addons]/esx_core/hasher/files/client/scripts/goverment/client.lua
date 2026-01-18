local RegisterNetEvent = RegisterNetEvent
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local DeleteEntity = DeleteEntity
local ox_target = exports.ox_target
local CreatePed = CreatePed
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local FreezeEntityPosition = FreezeEntityPosition
local SetEntityInvincible = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents
local GetEntityCoords = GetEntityCoords
local GetPlayerServerId = GetPlayerServerId
local TaskStartScenarioInPlace = TaskStartScenarioInPlace
local GetCurrentResourceName = GetCurrentResourceName
local DoesEntityExist = DoesEntityExist
local Wait = Wait
local GetGameTimer = GetGameTimer
local GetDisplayNameFromVehicleModel = GetDisplayNameFromVehicleModel
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
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

local function OpenSellCarMenu()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'yesorno',
		{
			title = "Czy na pewno chcesz zakupić umowę za 15 000$?",
			align = 'center',
			elements = {
				{label = "Tak", value = 'yes'},
				{label = "Nie", value = 'no'}
			}
		},
		function(data, menu)
			if data.current.value == 'yes' then
				Wait(1000)
				TriggerServerEvent('esx_core_contract:buyContract', ESX.GetClientKey(LocalPlayer.state.playerIndex))
			end
			menu.close()
		end,
		function(data, menu)
			menu.close()
		end
	)
end

exports('OpenSellCarMenu', OpenSellCarMenu)

RegisterNetEvent('esx_core_contract:getVehicle', function()
	local closestPlayer, playerDistance = ESX.Game.GetClosestPlayer()
	local esx_hud = exports.esx_hud

	if closestPlayer == -1 or playerDistance > 2.0 then
		ESX.ShowNotification('Nie ma nikogo w pobliżu')
		return
	end

	if cacheVehicle then
		ESX.ShowNotification('Nie możesz wypisać umowy będąc w pojeździe')
		return
	end

	if not esx_hud:progressBar({
		duration = 15,
		label = 'Wypisywanie kontraktu',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = false,
		},
		anim = {
			dict = 'amb@world_human_clipboard@male@idle_a',
			clip = 'idle_c',
			flag = 1
		},
		prop = {},
	}) then
		return
	end

	local vehicle = ESX.Game.GetClosestVehicle(cacheCoords)
	if not DoesEntityExist(vehicle) then
		ESX.ShowNotification('Nie ma samochodu w pobliżu')
		return
	end

	local vehicleCoords = GetEntityCoords(vehicle)
	local vehDistance = #(cacheCoords - vehicleCoords)

	if vehDistance > 3.0 then
		ESX.ShowNotification('Nie ma samochodu w pobliżu')
		return
	end

	local vehProps = ESX.Game.GetVehicleProperties(vehicle)
	Wait(1000)
	
	local vehName = GetDisplayNameFromVehicleModel(vehProps.model)
	if vehName and not ESX.IsPlayerAdminClient() and vehName:find("lim") then
		ESX.ShowNotification('Ten pojazd jest limitowany i nie możesz go sprzedać innej osobie!')
		return
	end

	TriggerServerEvent('esx_core_contract:sellVehicle', GetPlayerServerId(closestPlayer), vehProps.plate, vehProps.model, ESX.GetClientKey(LocalPlayer.state.playerIndex))
end)

local lastGameTimerId = 0
local COOLDOWN_TIME = 30000

local function canInteractWithPed()
	return not LocalPlayer.state.IsHandcuffed 
		and not LocalPlayer.state.InTrunk 
		and not cache.vehicle
end

local function onEnter(point)
	if point.entity then return end

	local model = lib.requestModel(`a_m_y_busicas_01`)
	Wait(1000)

	local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)
	
	TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_SMOKING', 0, true)
	
	SetModelAsNoLongerNeeded(model)
	FreezeEntityPosition(entity, true)
	SetEntityInvincible(entity, true)
	SetBlockingOfNonTemporaryEvents(entity, true)

	local onSelectCallback = point.policealert and function()
		local now = GetGameTimer()
		if now > lastGameTimerId then
			lastGameTimerId = now + COOLDOWN_TIME
			TriggerServerEvent('esx_core:alertBell')
		else
			ESX.ShowNotification('Nie możesz tak szybko tego używać!')
		end
	end or function()
		OpenSellCarMenu()
	end

	ox_target:addLocalEntity(entity, {
		{
			icon = 'fa fa-laptop',
			label = point.label,
			canInteract = canInteractWithPed,
			onSelect = onSelectCallback,
			distance = 3.0
		}
	})

	point.entity = entity
end
 
local function onExit(point)
	local entity = point.entity

	if not entity then return end

	ox_target:removeLocalEntity(entity, point.label)
	
	if DoesEntityExist(entity) then
		SetEntityAsMissionEntity(entity, false, true)
		DeleteEntity(entity)
	end

	point.entity = nil
end

local peds = {}

CreateThread(function()
	for k, v in pairs(Config.localGovermentSpawn) do
		peds[k] = lib.points.new({
			id = 10 + k,
			coords = v.coords,
			distance = 15,
			onEnter = onEnter,
			onExit = onExit,
			label = v.label,
			heading = v.heading,
			policealert = v.policealert
		})
	end
end)

local function canInteractWithZone(distance, requireInHouseRobbery, requiredJob)
	if LocalPlayer.state.IsDead then return false end
	if LocalPlayer.state.IsHandcuffed then return false end
	if distance > 2.0 then return false end
	if requireInHouseRobbery and not LocalPlayer.state.InHouseRobbery then return false end
	if not requireInHouseRobbery and LocalPlayer.state.InHouseRobbery then return false end
	if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then return false end
	if ESX.PlayerData.job.name ~= requiredJob then return false end
	return true
end

ox_target:addBoxZone({
	coords = vec3(-528.45, -189.0, 43.0),
	size = vec3(1.95, 3.45, 4.0),
	rotation = 26.0,
	debug = false,
	options = {
		{
			name = 'use_menu',
			icon = 'fa-solid fa-house-laptop',
			label = 'Zarządzaj',
			canInteract = function(entity, distance, coords, name)
				return canInteractWithZone(distance, true, 'doj')
			end,
			onSelect = function()
				TriggerServerEvent('esx_society:openbosshub', 'fraction', false, true)
			end
		},
	},
})

ox_target:addBoxZone({
	coords = vec3(156.05, -1707.5, 29.0),
	size = vec3(4.1, 1.4, 1.3),
	rotation = 320.75,
	debug = false,
	options = {
		{
			name = 'use_menu',
			icon = 'fa-solid fa-house-laptop',
			label = 'Zarządzaj',
			canInteract = function(entity, distance, coords, name)
				return canInteractWithZone(distance, false, 'myjnia')
			end,
			onSelect = function()
				TriggerServerEvent('esx_society:openbosshub', 'legal', false, true, nil)
			end
		},
	},
})