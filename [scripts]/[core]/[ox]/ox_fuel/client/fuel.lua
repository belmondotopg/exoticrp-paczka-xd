local esx_hud = exports.esx_hud

local config = require 'config'
local state = require 'client.state'
local utils = require 'client.utils'
local fuel = {}

---@param vehState StateBag
---@param vehicle integer
---@param amount number
---@param replicate? boolean
function fuel.setFuel(vehState, vehicle, amount, replicate)
	if DoesEntityExist(vehicle) then
		amount = math.clamp(amount, 0, 100)

		SetVehicleFuelLevel(vehicle, amount)
		vehState:set('fuel', amount, replicate)
	end
end

function fuel.getPetrolCan(coords, refuel)
	TaskTurnPedToFaceCoord(cache.ped, coords.x, coords.y, coords.z, config.petrolCan.duration)
	Wait(500)

	if esx_hud:progressBar({
		duration = config.petrolCan.duration,
		label = 'Napełnianie kanistra...',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = false,
		},
		anim = {
			dict = 'timetable@gardener@filling_can',
			clip = 'gar_ig_5_filling_can',
			flags = 49,
		},
		prop = {},
		notHideWeapon = refuel,
	}) then
		if refuel and exports.ox_inventory:GetItemCount('WEAPON_PETROLCAN') then
			return TriggerServerEvent('ox_fuel:fuelCan', true, config.petrolCan.refillPrice)
		end

		TriggerServerEvent('ox_fuel:fuelCan', false, config.petrolCan.price)
	else
		ESX.ShowNotification('Przerwano napełnianie kanistra.')
	end

	ClearPedTasks(cache.ped)
end

function fuel.startFueling(vehicle, isPump)
	local vehState = Entity(vehicle).state
	local fuelAmount = vehState.fuel or GetVehicleFuelLevel(vehicle)
	local duration = math.ceil((100 - fuelAmount) / config.refillValue) * config.refillTick
	local price, moneyAmount
	local durability = 0

	if 100 - fuelAmount < config.refillValue then
		return lib.notify({ type = 'error', description = locale('tank_full') })
	end

	if isPump then
		price = 0
		moneyAmount = utils.getMoney()

		if config.priceTick > moneyAmount then
			return lib.notify({
				type = 'error',
				description = locale('not_enough_money', config.priceTick)
			})
		end
	elseif not state.petrolCan then
		return lib.notify({ type = 'error', description = locale('petrolcan_not_equipped') })
	elseif not state.petrolCan.metadata or not state.petrolCan.metadata.ammo or state.petrolCan.metadata.ammo <= config.durabilityTick then
		return lib.notify({
			type = 'error',
			description = locale('petrolcan_not_enough_fuel')
		})
	end

	state.isFueling = true

	TaskTurnPedToFaceEntity(cache.ped, vehicle, duration)
	Wait(500)

	CreateThread(function()
		local Success = esx_hud:progressBar({
			duration = duration / 1000,
			label = 'Tankowanie...',
			useWhileDead = false,
			canCancel = true,
			disable = {
				car = true,
				move = true,
				combat = true,
				mouse = false,
			},
			anim = {
				dict = isPump and 'timetable@gardener@filling_can' or 'weapon@w_sp_jerrycan',
				clip = isPump and 'gar_ig_5_filling_can' or 'fire',
			},
			prop = {},
			notHideWeapon = not isPump,
		})
		if (Success) then
			state.isFueling = false
		else
			state.isFueling = false
			ESX.ShowNotification('Przerwano tankowanie.')
		end
	end)

	while state.isFueling do
		if isPump then
			local currentMoney = utils.getMoney()
			
			if currentMoney < config.priceTick then
				state.isFueling = false
				esx_hud:cancelExportProgress()
				ESX.ShowNotification('Skończyły ci się pieniądze. Tankowanie przerwane.')
				break
			end
			
			price += config.priceTick

			if price + config.priceTick > currentMoney then
				state.isFueling = false
				esx_hud:cancelExportProgress()
				ESX.ShowNotification('Skończyły ci się pieniądze. Tankowanie przerwane.')
				break
			end
		else
			state.petrolCan = exports.ox_inventory:getCurrentWeapon()
			
			if not state.petrolCan or not state.petrolCan.metadata or not state.petrolCan.metadata.ammo then
				state.isFueling = false
				esx_hud:cancelExportProgress()
				ESX.ShowNotification('Kanister został schowany. Tankowanie przerwane.')
				break
			end
			
			durability += config.durabilityTick

			if durability >= state.petrolCan.metadata.ammo then
				state.isFueling = false
				esx_hud:cancelExportProgress()
				durability = state.petrolCan.metadata.ammo
				break
			end
		end

		fuelAmount += config.refillValue

		if fuelAmount >= 100 then
			state.isFueling = false
			fuelAmount = 100.0
		end

		Wait(config.refillTick)
	end

	ClearPedTasks(cache.ped)

	if isPump then
		TriggerServerEvent('ox_fuel:pay', price, fuelAmount, NetworkGetNetworkIdFromEntity(vehicle))
	else
		TriggerServerEvent('ox_fuel:updateFuelCan', durability, NetworkGetNetworkIdFromEntity(vehicle), fuelAmount)
	end
end

return fuel
