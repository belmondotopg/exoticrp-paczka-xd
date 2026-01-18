local CreateThread = CreateThread
local Wait = Wait

local pedInSameVehicleLast = false
local lastVehicle
local vehicleClass
local fCollisionDamageMult = 0.0
local fDeformationDamageMult = 0.0
local fEngineDamageMult = 0.0
local fBrakeForce = 1.0
local isBrakingForward = false
local isBrakingReverse = false
local healthEngineLast = 1000.0
local healthEngineCurrent = 1000.0
local healthEngineNew = 1000.0
local healthEngineDelta = 0.0
local healthEngineDeltaScaled = 0.0
local healthBodyLast = 1000.0
local healthBodyCurrent = 1000.0
local healthBodyNew = 1000.0
local healthBodyDelta = 0.0
local healthBodyDeltaScaled = 0.0
local healthPetrolTankLast = 1000.0
local healthPetrolTankCurrent = 1000.0
local healthPetrolTankNew = 1000.0
local healthPetrolTankDelta = 0.0
local healthPetrolTankDeltaScaled = 0.0
local tireBurstLuckyNumber
local SetVehicleBodyHealth = SetVehicleBodyHealth
local SetVehiclePetrolTankHealth = SetVehiclePetrolTankHealth
local SetVehicleUndriveable = SetVehicleUndriveable
local GetVehicleHandlingFloat = GetVehicleHandlingFloat
local SetVehicleEngineHealth = SetVehicleEngineHealth
local SetVehicleHandlingFloat = SetVehicleHandlingFloat
local GetEntitySpeed = GetEntitySpeed
local DisableControlAction = DisableControlAction
local SetVehicleForwardSpeed = SetVehicleForwardSpeed
local SetVehicleBrakeLights = SetVehicleBrakeLights
local GetDisabledControlNormal = GetDisabledControlNormal
local SetVehicleEngineTorqueMultiplier = SetVehicleEngineTorqueMultiplier
local GetEntityRoll = GetEntityRoll
local GetVehicleEngineHealth = GetVehicleEngineHealth
local GetVehicleBodyHealth = GetVehicleBodyHealth
local GetVehiclePetrolTankHealth = GetVehiclePetrolTankHealth
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleClass = GetVehicleClass
local GetGameTimer = GetGameTimer
local GetVehicleTyresCanBurst = GetVehicleTyresCanBurst
local GetVehicleNumberOfWheels = GetVehicleNumberOfWheels
local SetVehicleTyreBurst = SetVehicleTyreBurst
local GetControlValue = GetControlValue
local GetEntitySpeedVector = GetEntitySpeedVector
local tireBurstMaxNumber = Config.VehicleDamage.randomTireBurstInterval * 1200
local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

if Config.VehicleDamage.randomTireBurstInterval ~= 0 then
    math.randomseed(GetGameTimer())
    tireBurstLuckyNumber = math.random(tireBurstMaxNumber)
end

local function isPedDrivingAVehicle()
    if not cacheVehicle then
        return false
    end
    
    if GetPedInVehicleSeat(cacheVehicle, -1) ~= cachePed then
        return false
    end
    
    local class = GetVehicleClass(cacheVehicle)
    return class ~= 15 and class ~= 16 and class ~= 21 and class ~= 13
end

local function fscale(inputValue, originalMin, originalMax, newBegin, newEnd, curve)
	if originalMin > originalMax then
		return 0
	end

	if curve > 10.0 then
		curve = 10.0
	elseif curve < -10.0 then
		curve = -10.0
	end

	curve = 10.0 ^ (curve * -0.1)

	if inputValue < originalMin then
		inputValue = originalMin
	elseif inputValue > originalMax then
		inputValue = originalMax
	end

	local originalRange = originalMax - originalMin
	local newRange = newEnd > newBegin and (newEnd - newBegin) or (newBegin - newEnd)
	local zeroRefCurVal = inputValue - originalMin
	local normalizedCurVal = zeroRefCurVal / originalRange
	local rangedValue = normalizedCurVal ^ curve

	if newEnd > newBegin then
		return (rangedValue * newRange) + newBegin
	else
		return newBegin - (rangedValue * newRange)
	end
end

local function tireBurstLottery()
	if math.random(tireBurstMaxNumber) ~= tireBurstLuckyNumber then
		return
	end

	if not GetVehicleTyresCanBurst(cacheVehicle) then
		return
	end

	local numWheels = GetVehicleNumberOfWheels(cacheVehicle)
	local affectedTire

	if numWheels == 2 then
		affectedTire = (math.random(2) - 1) * 4
	elseif numWheels == 4 then
		affectedTire = math.random(4) - 1
		if affectedTire > 1 then
			affectedTire = affectedTire + 2
		end
	elseif numWheels == 6 then
		affectedTire = math.random(6) - 1
	else
		affectedTire = 0
	end

	SetVehicleTyreBurst(cacheVehicle, affectedTire, false, 1000.0)
	tireBurstLuckyNumber = math.random(tireBurstMaxNumber)
end

if Config.VehicleDamage.torqueMultiplierEnabled or Config.VehicleDamage.preventVehicleFlip or Config.VehicleDamage.limpMode then
	CreateThread(function()
		local torqueEnabled = Config.VehicleDamage.torqueMultiplierEnabled
		local sundayDriver = Config.VehicleDamage.sundayDriver
		local limpMode = Config.VehicleDamage.limpMode
		local preventFlip = Config.VehicleDamage.preventVehicleFlip
		local sundayAccelCurve = Config.VehicleDamage.sundayDriverAcceleratorCurve
		local sundayBrakeCurve = Config.VehicleDamage.sundayDriverBrakeCurve
		local engineSafeGuard = Config.VehicleDamage.engineSafeGuard

		while true do
			Wait(0)
			if torqueEnabled or sundayDriver or limpMode then
				if pedInSameVehicleLast then
					local factor = 1.0
					if torqueEnabled and healthEngineNew < 900 then
						factor = (healthEngineNew + 200.0) / 1100
					end
					if sundayDriver and vehicleClass ~= 14 then
						local accelerator = GetControlValue(2, 71)
						local brake = GetControlValue(2, 72)
						local speedVec = GetEntitySpeedVector(cacheVehicle, true)
						local speed = speedVec.y
						local brk = fBrakeForce
						if speed >= 1.0 then
							if accelerator > 127 then
								local acc = fscale(accelerator, 127.0, 254.0, 0.1, 1.0, 10.0 - (sundayAccelCurve * 2.0))
								factor = factor * acc
							end
							if brake > 127 then
								isBrakingForward = true
								brk = fscale(brake, 127.0, 254.0, 0.01, fBrakeForce, 10.0 - (sundayBrakeCurve * 2.0))
							end
						elseif speed <= -1.0 then
							if brake > 127 then
								local rev = fscale(brake, 127.0, 254.0, 0.1, 1.0, 10.0 - (sundayAccelCurve * 2.0))
								factor = factor * rev
							end
							if accelerator > 127 then
								isBrakingReverse = true
								brk = fscale(accelerator, 127.0, 254.0, 0.01, fBrakeForce, 10.0 - (sundayBrakeCurve * 2.0))
							end
						else
							local entitySpeed = GetEntitySpeed(cacheVehicle)
							if entitySpeed < 1 then
								if isBrakingForward then
									DisableControlAction(2, 72, true)
									SetVehicleForwardSpeed(cacheVehicle, speed * 0.98)
									SetVehicleBrakeLights(cacheVehicle, true)
									if GetDisabledControlNormal(2, 72) == 0 then
										isBrakingForward = false
									end
								end
								if isBrakingReverse then
									DisableControlAction(2, 71, true)
									SetVehicleForwardSpeed(cacheVehicle, speed * 0.98)
									SetVehicleBrakeLights(cacheVehicle, true)
									if GetDisabledControlNormal(2, 71) == 0 then
										isBrakingReverse = false
									end
								end
							end
						end
						if brk > fBrakeForce - 0.02 then
							brk = fBrakeForce
						end
						SetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fBrakeForce', brk)
					end
					if limpMode and healthEngineNew < engineSafeGuard + 5 then
						factor = Config.VehicleDamage.limpModeMultiplier
					end
					SetVehicleEngineTorqueMultiplier(cacheVehicle, factor)
				end
			end
			if preventFlip then
				local roll = GetEntityRoll(cacheVehicle)
				if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(cacheVehicle) < 2 then
					DisableControlAction(2, 59, true)
					DisableControlAction(2, 60, true)
				end
			end
			Wait(115)
		end
	end)
end

CreateThread(function()
	local damageFactorEngine = Config.VehicleDamage.damageFactorEngine
	local damageFactorBody = Config.VehicleDamage.damageFactorBody
	local damageFactorPetrolTank = Config.VehicleDamage.damageFactorPetrolTank
	local classDamageMultiplier = Config.VehicleDamage.classDamageMultiplier
	local engineSafeGuard = Config.VehicleDamage.engineSafeGuard
	local limpMode = Config.VehicleDamage.limpMode
	local compatibilityMode = Config.VehicleDamage.compatibilityMode
	local cascadingFailureThreshold = Config.VehicleDamage.cascadingFailureThreshold
	local degradingFailureThreshold = Config.VehicleDamage.degradingFailureThreshold
	local degradingHealthSpeedFactor = Config.VehicleDamage.degradingHealthSpeedFactor
	local cascadingFailureSpeedFactor = Config.VehicleDamage.cascadingFailureSpeedFactor
	local deformationExponent = Config.VehicleDamage.deformationExponent
	local deformationMultiplier = Config.VehicleDamage.deformationMultiplier
	local weaponsDamageMultiplier = Config.VehicleDamage.weaponsDamageMultiplier
	local collisionDamageExponent = Config.VehicleDamage.collisionDamageExponent
	local engineDamageExponent = Config.VehicleDamage.engineDamageExponent
	local randomTireBurstInterval = Config.VehicleDamage.randomTireBurstInterval

	while true do
		Wait(250)
		if isPedDrivingAVehicle() then
			vehicleClass = GetVehicleClass(cacheVehicle)
			local classMult = classDamageMultiplier[vehicleClass]

			healthEngineCurrent = GetVehicleEngineHealth(cacheVehicle)
			if healthEngineCurrent == 1000 then
				healthEngineLast = 1000.0
			end
			healthEngineNew = healthEngineCurrent
			healthEngineDelta = healthEngineLast - healthEngineCurrent
			healthEngineDeltaScaled = healthEngineDelta * damageFactorEngine * classMult

			healthBodyCurrent = GetVehicleBodyHealth(cacheVehicle)
			if healthBodyCurrent == 1000 then
				healthBodyLast = 1000.0
			end
			healthBodyNew = healthBodyCurrent
			healthBodyDelta = healthBodyLast - healthBodyCurrent
			healthBodyDeltaScaled = healthBodyDelta * damageFactorBody * classMult

			healthPetrolTankCurrent = GetVehiclePetrolTankHealth(cacheVehicle)
			if compatibilityMode and healthPetrolTankCurrent < 1 then
				healthPetrolTankLast = healthPetrolTankCurrent
			end
			if healthPetrolTankCurrent == 1000 then
				healthPetrolTankLast = 1000.0
			end
			healthPetrolTankNew = healthPetrolTankCurrent
			healthPetrolTankDelta = healthPetrolTankLast - healthPetrolTankCurrent
			healthPetrolTankDeltaScaled = healthPetrolTankDelta * damageFactorPetrolTank * classMult

			if healthEngineCurrent > engineSafeGuard + 1 then
				SetVehicleUndriveable(cacheVehicle, false)
			elseif not limpMode then
				SetVehicleUndriveable(cacheVehicle, true)
			end

			if cacheVehicle ~= lastVehicle then
				pedInSameVehicleLast = false
			end

			if pedInSameVehicleLast then
				if healthEngineCurrent ~= 1000.0 or healthBodyCurrent ~= 1000.0 or healthPetrolTankCurrent ~= 1000.0 then
					local healthEngineCombinedDelta = math.max(healthEngineDeltaScaled, healthBodyDeltaScaled, healthPetrolTankDeltaScaled)

					if healthEngineCombinedDelta > (healthEngineCurrent - engineSafeGuard) then
						healthEngineCombinedDelta = healthEngineCombinedDelta * 0.7
					end

					if healthEngineCombinedDelta > healthEngineCurrent then
						healthEngineCombinedDelta = healthEngineCurrent - (cascadingFailureThreshold / 5)
					end

					healthEngineNew = healthEngineLast - healthEngineCombinedDelta

					if healthEngineNew > (cascadingFailureThreshold + 5) and healthEngineNew < degradingFailureThreshold then
						healthEngineNew = healthEngineNew - (0.038 * degradingHealthSpeedFactor)
					end

					if healthEngineNew < cascadingFailureThreshold then
						healthEngineNew = healthEngineNew - (0.1 * cascadingFailureSpeedFactor)
					end

					if healthEngineNew < engineSafeGuard then
						healthEngineNew = engineSafeGuard
					end

					if not compatibilityMode and healthPetrolTankCurrent < 750 then
						healthPetrolTankNew = 750.0
					end

					if healthBodyNew < 0 then
						healthBodyNew = 0.0
					end
				end
			else
				fDeformationDamageMult = GetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fDeformationDamageMult')
				fBrakeForce = GetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fBrakeForce')
				local newFDeformationDamageMult = fDeformationDamageMult ^ deformationExponent
				if deformationMultiplier ~= -1 then
					SetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fDeformationDamageMult', newFDeformationDamageMult * deformationMultiplier)
				end
				if weaponsDamageMultiplier ~= -1 then
					SetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fWeaponDamageMult', weaponsDamageMultiplier / damageFactorBody)
				end

				fCollisionDamageMult = GetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fCollisionDamageMult')
				local newFCollisionDamageMultiplier = fCollisionDamageMult ^ collisionDamageExponent
				SetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fCollisionDamageMult', newFCollisionDamageMultiplier)

				fEngineDamageMult = GetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fEngineDamageMult')
				local newFEngineDamageMult = fEngineDamageMult ^ engineDamageExponent
				SetVehicleHandlingFloat(cacheVehicle, 'CHandlingData', 'fEngineDamageMult', newFEngineDamageMult)

				if healthBodyCurrent < cascadingFailureThreshold then
					healthBodyNew = cascadingFailureThreshold
				end
				pedInSameVehicleLast = true
			end

			if healthEngineNew ~= healthEngineCurrent then
				SetVehicleEngineHealth(cacheVehicle, healthEngineNew)
			end

			if healthBodyNew ~= healthBodyCurrent then
				SetVehicleBodyHealth(cacheVehicle, healthBodyNew)
			end
			if healthPetrolTankNew ~= healthPetrolTankCurrent then
				SetVehiclePetrolTankHealth(cacheVehicle, healthPetrolTankNew)
			end

			healthEngineLast = healthEngineNew
			healthBodyLast = healthBodyNew
			healthPetrolTankLast = healthPetrolTankNew
			lastVehicle = cacheVehicle
			if randomTireBurstInterval ~= 0 and GetEntitySpeed(cacheVehicle) > 10 then
				tireBurstLottery()
			end
		else
			if pedInSameVehicleLast then
				lastVehicle = cacheVehicle
				if deformationMultiplier ~= -1 then
					SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fDeformationDamageMult', fDeformationDamageMult)
				end
				SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fBrakeForce', fBrakeForce)
				if weaponsDamageMultiplier ~= -1 then
					SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fWeaponDamageMult', weaponsDamageMultiplier)
				end
				SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fCollisionDamageMult', fCollisionDamageMult)
				SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fEngineDamageMult', fEngineDamageMult)
			end
			pedInSameVehicleLast = false
			Wait(500)
		end
	end
end)