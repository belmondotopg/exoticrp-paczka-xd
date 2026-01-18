local ESX = ESX
local Citizen = Citizen
local TriggerEvent = TriggerEvent
local LocalPlayer = LocalPlayer
local DeleteEntity = DeleteEntity
local esx_hud = exports.esx_hud
local CreatePed = CreatePed
local FreezeEntityPosition = FreezeEntityPosition
local GetEntityHealth = GetEntityHealth
local TaskStartScenarioInPlace = TaskStartScenarioInPlace
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local SetEntityInvincible = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents
local SetEntityCoords = SetEntityCoords
local SetEntityHeading = SetEntityHeading
local DoesEntityExist = DoesEntityExist
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local ox_target = exports.ox_target
local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle

local MAX_HEALTH = 200
local HEAL_DURATION = 15

libCache('ped', function(ped)
	cachePed = ped
end)

libCache('vehicle', function(vehicle)
	cacheVehicle = vehicle
end)

local function localMedicHeal(healed)
	FreezeEntityPosition(cachePed, false)
	
	if healed then
		TriggerEvent('esx_ambulance:onTargetRevive', true)
		ESX.ShowNotification('Uleczono.')
	else
		ESX.ShowNotification('Anulowano.')
	end
end

local function getProgressBarConfig(isDead)
	local config = {
		duration = HEAL_DURATION,
		label = 'Otrzymywanie pomocy',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = false,
		},
		anim = isDead and {
			dict = 'dead',
			clip = 'dead_a',
			flag = 1
		} or {
			dict = 'anim@heists@prison_heistig_5_p1_rashkovsky_idle',
			clip = 'idle',
			flag = 1
		}
	}
	
	if not isDead then
		config.prop = {}
	end
	
	return config
end

local function performHeal(isDead)
	FreezeEntityPosition(cachePed, true)
	local healed = esx_hud:progressBar(getProgressBarConfig(isDead))
	localMedicHeal(healed)
end

local function healMedic(black, hospital)
	local isDead = LocalPlayer.state.IsDead
	
	if isDead then
		if black then
			performHeal(true)
		else
			ESX.TriggerServerCallback('esx_core:getFreeBed', function(bed)
				if not bed then
					ESX.ShowNotification('Nie ma wolnych łóżek, spróbuj ponownie później')
					return
				end
				
				ESX.TriggerServerCallback('esx_core:onCheckMoney', function(hasEnoughMoney)
					if not hasEnoughMoney then
						ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (1.000$)')
						return
					end
					
					SetEntityCoords(cachePed, bed.pos[1], bed.pos[2], bed.pos[3])
					SetEntityHeading(cachePed, bed.heading)
					performHeal(true)
				end, 'localmedic')
			end, hospital)
		end
	else
		if GetEntityHealth(cachePed) == MAX_HEALTH then
			ESX.ShowNotification('Nie potrzebujesz pomocy medycznej!')
			return
		end
		
		if black then
			performHeal(false)
		else
			ESX.TriggerServerCallback('esx_core:onCheckMoney', function(hasEnoughMoney)
				if not hasEnoughMoney then
					ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (1.000$)')
					return
				end
				
				performHeal(false)
			end, 'localmedic')
		end
	end
end

local function localMedicInteraction(black, hospital)
	if cacheVehicle then
		ESX.ShowNotification('Aby skorzystać z pomocy medycznej nie możesz być w pojeździe.')
		return
	end
	
	if black then
		healMedic(true)
		return
	end
	
	if GlobalState.Counter['ambulance'] > Config.MedicToUse then
		ESX.ShowNotification('Nie możesz skorzystać z pomocy, ponieważ na służbie jest ponad dwóch medyków!')
		return
	end
	
	healMedic(false, hospital)
end

local function canInteractWithMedic()
	return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle)
end

local function onEnter(point)
	if point.entity then return end
	
	local model = lib.requestModel(`s_m_m_paramedic_01`)
	local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)
	
	TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_CLIPBOARD_FACILITY', 0, true)
	
	SetModelAsNoLongerNeeded(model)
	FreezeEntityPosition(entity, true)
	SetEntityInvincible(entity, true)
	SetBlockingOfNonTemporaryEvents(entity, true)

	ox_target:addLocalEntity(entity, {
		{
			icon = 'fa fa-laptop',
			label = point.label,
			canInteract = canInteractWithMedic,
			onSelect = function()
				localMedicInteraction(point.black, point.hospital)
			end,
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

Citizen.CreateThread(function ()
	for k, v in pairs(Config.localMedicSpawn) do
		peds[k] = lib.points.new({
			id = 25 + k,
			coords = v.coords,
			distance = 200,
			onEnter = onEnter,
			onExit = onExit,
			label = v.label,
			heading = v.heading,
			black = v.black,
			hospital = v.hospital or 0
		})
	end
end)