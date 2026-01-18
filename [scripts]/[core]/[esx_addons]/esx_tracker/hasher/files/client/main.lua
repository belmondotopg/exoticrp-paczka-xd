local ox_target = exports.ox_target
local ox_inventory = exports.ox_inventory

LocalPlayer.state:set('usingTracker', false, true)

local Mission = {
	tier = 1,
	number = 1,
	vehicleClass = nil,
	vehicle = {
		coords = nil,
		model = nil,
		hash = nil,
		plate = nil,
		label = nil,
		spawned = nil,
		entity = nil,
	},
	blips = {
		map = nil,
		map_label = nil,
		delivery = nil,
	},
	timer = nil,
	work = {
		inJob = nil,
		inTransport = nil,
		policeGPS = nil,
		isTaken = nil,
		isDelivered = nil,
		canDeliver = nil,
		deliveryCoords = nil,
	},
	police = {
		onTrack = nil,
		carBlip = nil,
	}
}

local libCache = lib.onCache
local cache = {}

libCache('ped', function(ped)
    cache.ped = ped
end)

libCache('coords', function(coords)
    cache.coords = coords
end)

Citizen.CreateThread(function()
    while not cache.ped do
        cache.ped = PlayerPedId()
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while not cache.coords do
        cache.coords = GetEntityCoords(PlayerPedId())
        Citizen.Wait(500)
    end
end)

local function deleteMissionVehicle()
    local veh = Mission.vehicle.entity
    if not veh or not DoesEntityExist(veh) then
        Mission.vehicle.entity = nil
        return
    end

	if NetworkHasControlOfEntity(veh) then
		SetEntityAsMissionEntity(veh, false, true)
		DeleteEntity(veh)
	else
		NetworkRequestControlOfEntity(veh)
		local start = GetGameTimer()
		while not NetworkHasControlOfEntity(veh) and GetGameTimer() - start < 1000 do
			Citizen.Wait(50)
		end
		if NetworkHasControlOfEntity(veh) then
			SetEntityAsMissionEntity(veh, false, true)
			DeleteEntity(veh)
		end
	end

	if DoesEntityExist(veh) then
		DeleteVehicle(veh)
	end

	Mission.vehicle.entity = nil
	Mission.vehicle.plate = nil
end

local function stopMission()
	if not LocalPlayer.state.usingTracker then return end

	Mission.work.inJob = false

	LocalPlayer.state:set('usingTracker', false, true)

	TriggerServerEvent('esx_tracker/server/releaseRobSpot', Mission)

	if Mission.blips.map then
		RemoveBlip(Mission.blips.map)
		Mission.blips.map = nil
	end
	if Mission.blips.map_label then
		RemoveBlip(Mission.blips.map_label)
		Mission.blips.map_label = nil
	end
	if Mission.blips.delivery then
		RemoveBlip(Mission.blips.delivery)
		Mission.blips.delivery = nil
	end
	if Mission.police.carBlip then
		RemoveBlip(Mission.police.carBlip)
		Mission.police.carBlip = nil
	end

	deleteMissionVehicle()

	Mission = {
		tier = 1,
		number = 1,
		vehicleClass = nil,
		vehicle = {
			coords = nil,
			model = nil,
			hash = nil,
			plate = nil,
			label = nil,
			spawned = nil,
			entity = nil,
		},
		blips = {
			map = nil,
			map_label = nil,
			delivery = nil,
		},
		timer = nil,
		work = {
			inJob = nil,
			inTransport = nil,
			policeGPS = nil,
			isTaken = nil,
			isDelivered = nil,
			canDeliver = nil,
			deliveryCoords = nil,
		},
		police = {
			onTrack = nil,
			carBlip = nil,
		}
	}
end

local function afterThief()
	TriggerServerEvent('qf_mdt/addDispatchAlert', cache.coords, 'Kradzież pojazdu! (Tracker)', 'Zgłoszono kradzież pojazdu!', '10-72', 'rgb(156, 85, 37)', '10', 227, 3, 6)

	if Mission.blips.map then
		RemoveBlip(Mission.blips.map)
		Mission.blips.map = nil
	end
	if Mission.blips.map_label then
		RemoveBlip(Mission.blips.map_label)
		Mission.blips.map_label = nil
	end

	Mission.work.inJob = true
	Mission.work.inTransport = true
	Mission.work.policeGPS = true
	Mission.work.isTaken = 1
	Mission.work.isDelivered = 0

	ESX.ShowNotification('Musisz jeździć przez 10 minut, aby nadajnik GPS przestał działać! Uważaj na policję!')

	Citizen.Wait(1000)

	Citizen.CreateThread(function()
		local hasBeenInVehicle = false
		local warned = false
		local timer = 60

		while Mission.work.inJob do
			Citizen.Wait(1000)

			local veh = GetVehiclePedIsUsing(cache.ped)
			local currentVeh = (veh ~= 0) and GetEntityModel(veh) or nil

			if currentVeh == Mission.vehicle.hash then
				hasBeenInVehicle = true
				warned = false
			elseif hasBeenInVehicle then
				if not warned then
					warned = true
					timer = 60
					ESX.ShowNotification('Masz minutę na powrót do pojazdu!')
				else
					timer = timer - 1
					if timer <= 0 then
						ESX.ShowNotification('Misja została przerwana!')
						stopMission()
						return
					end
				end
			end
		end
	end)

	Citizen.CreateThread(function()
		while Mission.work.policeGPS and Mission.work.inJob do
			Citizen.Wait(2000)
			if Mission.work.isTaken == 1 and DoesEntityExist(Mission.vehicle.entity) then
				local v = GetEntityCoords(Mission.vehicle.entity)
				TriggerServerEvent('esx_tracker/server/startAlertCops', v)
			else
				TriggerServerEvent('esx_tracker/server/stopAlertCops')
			end
		end
	end)

	Citizen.CreateThread(function()
		for i = 10, 1, -1 do
			if not Mission.work.inJob then return end
			if i == 10 then
				ESX.ShowNotification('Musisz jeździć przez ' .. i .. ' minut, aby zdezaktywować nadajnik. Uważaj na policję!')
			elseif i <= 3 then
				ESX.ShowNotification('Za ' .. i .. ' minut nadajnik zostanie zdezaktywowany!')
			end
			Citizen.Wait(60000)
		end

		if not Mission.work.inJob then return end

		TriggerServerEvent('esx_tracker/server/stopAlertCops')

		Mission.work.policeGPS = false
		Mission.work.inTransport = false

		ESX.ShowNotification('Nadajnik został zdezaktywowany!')

		local sellers = {}
		for _, ped in ipairs(Config.Peds) do
			if ped.isSeller then
				table.insert(sellers, ped)
			end
		end

		local chosen = sellers[math.random(#sellers)]
		Mission.work.deliveryCoords = chosen.coords
		Mission.blips.delivery = AddBlipForCoord(Mission.work.deliveryCoords.x, Mission.work.deliveryCoords.y, Mission.work.deliveryCoords.z)

		SetBlipSprite(Mission.blips.delivery, 304)
		SetBlipDisplay(Mission.blips.delivery, 4)
		SetBlipScale(Mission.blips.delivery, 0.7)
		SetBlipColour(Mission.blips.delivery, 17)
		SetBlipAsShortRange(Mission.blips.delivery, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString('Zlecenie: Punkt dostawy')
		EndTextCommandSetBlipName(Mission.blips.delivery)
		SetBlipRoute(Mission.blips.delivery, true)

		Mission.work.canDeliver = true

		PlaySoundFrontend(-1, 'Mission_Pass_Notify', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', 0)
		ESX.ShowNotification('Udaj się do miejsca dostawy oznaczonego na GPS.')
	end)

	Citizen.CreateThread(function()
		while Mission.work.inJob do
			Citizen.Wait(1000)
			if not Mission.vehicle.entity or not DoesEntityExist(Mission.vehicle.entity) then
				ESX.ShowNotification('Pojazd został unieruchomiony lub zniszczony! Misja przerwana.')
				stopMission()
				return
			end
		end
	end)
end

libCache('vehicle', function(newVehicle)
	cache.vehicle = newVehicle

	if not LocalPlayer.state.usingTracker or not Mission.timer then return end
	if not newVehicle or newVehicle == 0 then return end

	local model = GetEntityModel(newVehicle)
	local plate = GetVehicleNumberPlateText(newVehicle)

	if model == Mission.vehicle.hash and plate == Mission.vehicle.plate then
		afterThief()
		Mission.timer = false
	end
end)

RegisterNetEvent('esx_tracker/client/stopMission', stopMission)

AddEventHandler('esx:onPlayerDeath', stopMission)

local spawnedModelHash = nil

local function preloadVehicleModel(modelHash)
    if spawnedModelHash ~= modelHash then
        spawnedModelHash = modelHash
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(10)
        end
    end
end

local function spawnVehicle()
	if not Mission.vehicle.model or not Mission.vehicle.coords then return end

	local modelHash = GetHashKey(Mission.vehicle.model)
	preloadVehicleModel(modelHash)

	local c = Mission.vehicle.coords
	local vehicle = CreateVehicle(modelHash, c.x, c.y, c.z, c.w or 0.0, true, false)
	if not DoesEntityExist(vehicle) then return end

	local netId = NetworkGetNetworkIdFromEntity(vehicle)
	NetworkRegisterEntityAsNetworked(vehicle)
	SetNetworkIdCanMigrate(netId, true)
	SetNetworkIdExistsOnAllMachines(netId, true)
	SetEntityAsMissionEntity(vehicle, true, true)

	Mission.vehicle.entity = vehicle
	Mission.vehicle.plate = GetVehicleNumberPlateText(vehicle)

	SetVehicleDoorsLocked(vehicle, 2)
	SetVehicleDoorsLockedForAllPlayers(vehicle, true)
	Entity(vehicle).state:set('InRobbery', true, true)

	Mission.vehicle.coords = nil
end

Citizen.CreateThread(function()
	while true do
		if LocalPlayer.state.usingTracker and Mission.vehicle.coords and not Mission.vehicle.spawned then
			if #(cache.coords - vec3(Mission.vehicle.coords.x, Mission.vehicle.coords.y, Mission.vehicle.coords.z)) <= 50.0 then
				spawnVehicle()
			else
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(1000)
		end
	end
end)

RegisterNetEvent('esx_tracker/client/startMission', function(missionTier)
	Mission.tier = missionTier

	local availableClasses = Config.TierUnlocks[missionTier] or Config.TierUnlocks[1]
	local selectedClass = availableClasses[math.random(#availableClasses)]
	local vehiclesInClass = Config.VehicleClasses[selectedClass]

	if not vehiclesInClass or #vehiclesInClass == 0 then
		vehiclesInClass = Config.VehicleClasses['C']
		selectedClass = 'C'
	end

	Mission.vehicleClass = selectedClass
	Mission.vehicle.model = vehiclesInClass[math.random(#vehiclesInClass)]
	Mission.vehicle.hash = GetHashKey(Mission.vehicle.model)
	Mission.vehicle.label = GetDisplayNameFromVehicleModel(Mission.vehicle.hash)

	lib.callback('esx_tracker/server/getFreeRobSpot', false, function(randomCar, randomNumber)
		if not randomCar or not randomNumber then
			stopMission()
			return
		end

		Mission.number = randomNumber
		Mission.vehicle.coords = randomCar.coords

		ESX.ShowNotification('Przesyłam ci lokalizację pojazdu klasy [' .. selectedClass .. '] udaj się tam i ukradnij [' .. Mission.vehicle.label .. ']. Nie zawiedź mnie!')

		Mission.blips.map = AddBlipForRadius(Mission.vehicle.coords, 100.0)
		SetBlipHighDetail(Mission.blips.map, true)
		SetBlipColour(Mission.blips.map, 24)
		SetBlipAlpha(Mission.blips.map, 128)

		Mission.blips.map_label = AddBlipForCoord(Mission.vehicle.coords.x, Mission.vehicle.coords.y, Mission.vehicle.coords.z)
		SetBlipHighDetail(Mission.blips.map_label, true)
		SetBlipSprite(Mission.blips.map_label, 724)
		SetBlipScale(Mission.blips.map_label, 0.7)
		SetBlipColour(Mission.blips.map_label, 24)
		SetBlipAsShortRange(Mission.blips.map_label, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Zlecenie: Poszukiwanie pojazdu')
		EndTextCommandSetBlipName(Mission.blips.map_label)

		Mission.timer = true
	end, selectedClass)
end)

RegisterNetEvent('esx_tracker/client/removeCopBlip', function()
	if Mission.police.carBlip and DoesBlipExist(Mission.police.carBlip) then
		RemoveBlip(Mission.police.carBlip)
		Mission.police.carBlip = nil
	end

	Mission.police.onTrack = false
end)

RegisterNetEvent('esx_tracker/client/setCopBlip', function(coords)
	if Mission.police.carBlip and DoesBlipExist(Mission.police.carBlip) then
		RemoveBlip(Mission.police.carBlip)
	end

	Mission.police.carBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(Mission.police.carBlip, 724)
	SetBlipScale(Mission.police.carBlip, 0.9)
	SetBlipColour(Mission.police.carBlip, 6)
	PulseBlip(Mission.police.carBlip)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('# Nadajnik GPS pojazdu')
	EndTextCommandSetBlipName(Mission.police.carBlip)
end)

local function finishDelivery()
	if not Mission.work.canDeliver then
		ESX.ShowNotification('Nie możesz jeszcze dostarczyć pojazdu!')
		return
	end

	if not Mission.work.deliveryCoords then
		ESX.ShowNotification('Brak lokalizacji dostawy!')
		return
	end

	local distance = #(cache.coords - Mission.work.deliveryCoords)
	
	if distance > 8.0 then
		ESX.ShowNotification('Trochę za daleko to auto, przyprowadź mi je bliżej!')
		return
	end
	
	Mission.work.isTaken = 0
	Mission.work.isDelivered = 1
	Mission.work.inTransport = false
	Mission.work.inJob = false

	if Mission.blips.delivery then
		RemoveBlip(Mission.blips.delivery)
		Mission.blips.delivery = nil
	end

	ESX.ShowNotification('Dzięki za furkę, dobra robota!')
	PlaySoundFrontend(-1, 'Mission_Pass_Notify', 'DLC_HEISTS_GENERAL_FRONTEND_SOUNDS', 0)
	
	if not Mission.tier then
		Mission.tier = 1
	end
	if not Mission.number then
		Mission.number = 1
	end
	if not Mission.vehicleClass then
		Mission.vehicleClass = 'C'
	end

	TriggerServerEvent('esx_tracker/server/finishMission', Mission)
	Citizen.Wait(1000)
	deleteMissionVehicle()
	stopMission()
end

local function cancelMenu()
	lib.callback('esx_tracker/server/getPlayerQueue', false, function(position, totalPlayers)
		position = position or 0
		totalPlayers = totalPlayers or 0

		if position > 0 and position <= Config.MaxWorkingPositions then
			lib.registerContext({
				id = 'cancelMenu',
				title = 'Zlecenia',
				options = {
					{
						title = 'Opuść zlecenie',
						description = 'Po kliknięciu przycisku, przerwiesz wykonywanie zlecenia.',
						icon = 'fa-solid fa-hourglass-half',
						onSelect = function()
							stopMission()
							TriggerServerEvent('esx_tracker/server/removeQueue')
						end,
						metadata = {
							{label = 'Ilość osób w kolejce', value = totalPlayers},
							{label = 'Twoja pozycja w kolejce', value = position}
						},
					},
				}
			})

			lib.showContext('cancelMenu')
		end
	end)
end

local function queueMenu()
	lib.callback('esx_tracker/server/getPlayerQueue', false, function(position, totalPlayers)
		lib.callback('esx_tracker/server/getSpecialisation', false, function(count, requiredCount, level, maxCount)
			if position == 0 then
				lib.registerContext({
					id = 'queueMenu',
					title = 'Zlecenia',
					options = {
						{
							title = 'Dołącz do kolejki zleceń',
							description = 'Po kliknięciu przycisku, dołączysz do kolejki oczekujących na zlecenie.',
							icon = 'fa-solid fa-hourglass-half',
							onSelect = function()
								TriggerServerEvent('esx_tracker/server/joinQueue')
								lib.hideContext('queueMenu')
							end,
							metadata = {
								{label = 'Ilość osób w kolejce', value = totalPlayers},
								{label = 'Twój poziom specjalizacji', value = level .. ' / 4'},
								{label = 'Ilość zleceń do zwiększenia', value = (count >= maxCount) and 'Maksymalny poziom' or (requiredCount - count)}
							},
						},
					}
				})
			else
				lib.registerContext({
					id = 'queueMenu',
					title = 'Zlecenia',
					options = {
						{
							title = 'Opuść kolejkę zleceń',
							description = 'Po kliknięciu przycisku, opuścisz kolejkę oczekujących na zlecenie.',
							icon = 'fa-solid fa-hourglass-half',
							onSelect = function()
								stopMission()
								TriggerServerEvent('esx_tracker/server/removeQueue')
							end,
							metadata = {
								{label = 'Ilość osób w kolejce', value = totalPlayers},
								{label = 'Twoja pozycja w kolejce', value = position},
								{label = 'Twój poziom specjalizacji', value = level .. ' / 3'},
								{label = 'Ilość zleceń do zwiększenia', value = (count >= maxCount) and 'Maksymalny poziom' or (requiredCount - count)}
							},
						},
					}
				})
			end

			lib.showContext('queueMenu')
		end)
	end)
end

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`a_m_m_og_boss_01`)

		Citizen.Wait(1000)

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z, point.heading, false, true)
	
		TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)
	
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

		ox_target:addLocalEntity(entity, {
			{
				icon = 'fa fa-laptop',
				label = point.label,
				canInteract = function()
					if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
					if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
					if Config.ForbiddenJobs[ESX.PlayerData.job.name] then return false end

					if point.isSeller then
						return (LocalPlayer.state.usingTracker and Mission.work.canDeliver) and (Mission.work.deliveryCoords == point.coords)
					end

					return true
				end,
				onSelect = function()
					if not point.isSeller then
						if GlobalState.Counter['police'] >= Config.Requirements.Cops then
							local count = ox_inventory:Search('count', 'lockpick')
							if count > 0 then
								local options = {}

								options[0] = {
									title = 'Poziom specjalizacji',
									icon = 'fa-solid fa-file',
									onSelect = function()
										lib.callback('esx_tracker/server/getSpecialisation', false, function(count, requiredCount, level, maxCount)
											lib.registerContext({
												id = 'Specialisations',
												title = 'Poziom specjalizacji',
												options = {
													{
														title = (count >= maxCount) and 'Ilość wykonanych zleceń' or 'Ilość zleceń do zwiększenia poziomu',
														description = (count >= maxCount) and tostring(count) or (count .. ' / ' .. requiredCount),
														icon = 'fa-solid fa-list-check',
													},
													{
														title = 'Poziom specjalizacji',
														description = level .. ' / 3',
														icon = 'fa-solid fa-building',
													},
													{
														title = 'Zwiększ poziom',
														description = (level >= 3) and
															'Osiągnąłeś na ten moment maksymalny poziom specjalizacji!' or
															'Wykonuj zlecenia i zwiększaj przy użyciu tego przycisku poziom specjalizacji, aby zdobywać bardziej wartościowe łupy!',
														icon = 'fa-solid fa-turn-up',
														onSelect = function()
															if count == requiredCount then
																TriggerServerEvent('esx_tracker/server/upgradeLevel')
															else
																ESX.ShowNotification('Musisz jeszcze wykonać ' .. (requiredCount - count) .. ' zleceń, aby zwiększyć swój poziom specjalizacji')
															end
														end,
													},
												},
											})
											lib.showContext('Specialisations')
										end)
									end
								}

								options[1] = {
									title = 'Zlecenia',
									icon = 'fa-solid fa-truck-fast',
									onSelect = function()
										lib.callback('esx_tracker/server/getPlayerQueue', false, function()
											if LocalPlayer.state.usingTracker then
												cancelMenu()
											else
												queueMenu()
											end
										end)
									end
								}

								options[2] = {
									title = 'Wskazówki',
									icon = 'fa-solid fa-circle-info',
									onSelect = function()
										ESX.ShowNotification('Wysyłam ci GPS, udajesz się na miejsce, wytrchujesz pojazd następnie wsiadasz do niego i przez 10 minut musisz jeździć aby zdezaktywować nadajnik. Jak już to zrobisz dostarczasz pojazd do dziupli zaznaczonej na GPS.')
									end
								}

								lib.registerContext({
									id = 'manageNPC',
									title = 'Zarządzaj',
									options = options
								})
								lib.showContext('manageNPC')
							else
								ESX.ShowNotification('Zanim cokolwiek pierw weź ze sobą wytrych, bez niego nic nie zrobisz.')
							end
						else
							ESX.ShowNotification('Nie ma odpowiedniej liczby policjantów!')
						end
					else
						finishDelivery()
					end
				end,
				distance = 2.0
			}
		})

		point.entity = entity
	end
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

Citizen.CreateThread(function()
	for _, v in pairs(Config.Peds) do
		lib.points.new({
			id = v.id,
			distance = v.distance,
			coords = v.coords,
			heading = v.heading,
			label = v.label,
			isSeller = v.isSeller,
			onEnter = onEnter,
			onExit = onExit,
		})
	end
end)