local oldVehicle = nil
local oldDamage = 0
local injuredTime = 0
local isBlackedOut = false
local isInjured = false
local dzwonCalled = false
local beltCalled = false
local effect = false
local playerLoaded = false

local cachePed = cache.ped
local cacheCoords = cache.coords
local cachePlayerId = cache.playerId
local cacheVehicle = cache.vehicle

LocalPlayer.state:set("Belt", false, true)

lib.onCache('ped', function(ped) cachePed = ped end)
lib.onCache('coords', function(coords) cacheCoords = coords end)
lib.onCache('playerId', function(playerId) cachePlayerId = playerId end)
lib.onCache('vehicle', function(vehicle) cacheVehicle = vehicle end)

local function DisableDzwon() effect = true end
local function EnableDzwon() effect = false end

local carCheckCache = {}
local carCheckCacheTime = {}
local CACHE_DURATION = 1000

local function IsCar(v, ignoreBikes)
	if not v or v == 0 then return false end
	
	local cacheKey = v .. tostring(ignoreBikes)
	local now = GetGameTimer()
	local cachedTime = carCheckCacheTime[cacheKey]
	
	if carCheckCache[cacheKey] and cachedTime and (now - cachedTime) < CACHE_DURATION then
		return carCheckCache[cacheKey]
	end
	
	local model = GetEntityModel(v)
	if ignoreBikes and (IsThisModelABike(model) or IsThisModelAQuadbike(model) or IsThisModelAPlane(model) or IsThisModelAHeli(model) or IsThisModelAJetski(model) or IsThisModelABoat(model) or IsThisModelAnAmphibiousQuadbike(model)) then
		carCheckCache[cacheKey] = false
		carCheckCacheTime[cacheKey] = now
		return false
	end

	local vc = GetVehicleClass(v)
	local result = (vc >= 0 and vc <= 12) or vc == 17 or vc == 18 or vc == 20
	carCheckCache[cacheKey] = result
	carCheckCacheTime[cacheKey] = now
	return result
end

local function pasyState() return LocalPlayer.state.Belt end

RegisterNetEvent('esx:playerLoaded', function()
	playerLoaded = true
end)

CreateThread(function()
	while true do
		local inSpawnSelector = GetResourceState("op-multicharacter") == "started" and exports["op-multicharacter"]:IsInSpawnSelector() or false
		if playerLoaded and cacheVehicle and IsCar(cacheVehicle, true) and not LocalPlayer.state.Belt and not LocalPlayer.state.InKomis and not LocalPlayer.state.InBroker and not inSpawnSelector then
			TriggerServerEvent("interact-sound_SV:PlayOnSource", "pasy-beep", 0.25)
			Wait(1000)
		else
			Wait(2000)
		end
	end
end)

RegisterNetEvent('exotic_blackout/dzwon', function(damage)
	if type(damage) ~= "number" then return end
	damage = math.max(0, math.min(20, damage))
	
	isBlackedOut = true
	dzwonCalled = false
	
	CreateThread(function()
		SendNUIMessage({ transaction = 'play' })
		
		if not effect then
			StartScreenEffect('DeathFailOut', 0, true)
			SetTimecycleModifier("hud_def_blur")
		end
		
		for i = 1, 3 do
			ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
			Wait(250)
		end

		if not effect then StopScreenEffect('DeathFailOut') end
		
		isInjured = false
		injuredTime = damage
		isBlackedOut = false
	end)
end)

CreateThread(function()
	while true do
		local sleep = true
		
		if cacheVehicle then
			local exists = DoesEntityExist(cacheVehicle)
			local driver = exists and GetPedInVehicleSeat(cacheVehicle, -1) or nil

			if (exists and (not driver or driver == 0 or driver == cachePed)) or (not exists and oldVehicle and DoesEntityExist(oldVehicle)) then
				local fall = not exists
				if exists then oldVehicle = cacheVehicle end

				if not GetPlayerInvincible(cachePlayerId) and not dzwonCalled and IsCar(oldVehicle, false) then
					local currentDamage = GetVehicleEngineHealth(oldVehicle)
					if not isBlackedOut then
						local speed = math.floor(GetEntitySpeed(oldVehicle) * 3.6 + 0.5)
						local vehicleClass = GetVehicleClass(oldVehicle)
						if (currentDamage < oldDamage and (oldDamage - currentDamage) >= 250) or (fall and speed > (vehicleClass == 8 and 50 or 250)) then
							local damage = fall and math.floor(speed / 10 + 0.5) or math.floor((oldDamage - currentDamage) / 20 + 0.5)

							local list = {}
							if oldVehicle == cacheVehicle and driver == cachePed then
								for i = -1, GetVehicleNumberOfPassengers(oldVehicle) do
									local ped = GetPedInVehicleSeat(oldVehicle, i)
									if ped and ped ~= 0 then
										local playerIndex = NetworkGetPlayerIndexFromPed(ped)
										if playerIndex and playerIndex ~= -1 then
											list[#list+1] = GetPlayerServerId(playerIndex)
										end
									end
								end
							end

							dzwonCalled = true
						end
					end

					if not fall then oldDamage = currentDamage end
				end

				if fall then
					oldVehicle = nil
					oldDamage = 0
				end
			else
				oldDamage = 0
			end
		else
			oldDamage = 0
		end

		if isBlackedOut then sleep = false end

		if injuredTime > 0 and not isInjured then
			sleep = false
			isInjured = true
			CreateThread(function()
				if not effect then ShakeGameplayCam("DRUNK_SHAKE", 2.0) end
				
				local reset = false
				repeat
					injuredTime = injuredTime - 1

					if not effect then
						reset = true
						SetPedMovementClipset(cachePed, "move_m@injured", 1.0)
						SetTimecycleModifier("hud_def_blur")
					end
					
					Wait(200)
				until injuredTime == 0
				
				if not effect then
					StopGameplayCamShaking(true)
					if reset then ClearTimecycleModifier() end
					ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 1.0)
					ResetPedMovementClipset(cachePed, 0.0)
				end

				SendNUIMessage({ transaction = 'fade', time = 500 })
				isInjured = false
			end)
		end
		
		Wait(sleep and 250 or 50)
	end
end)

CreateThread(function()
	while true do
		local needsControl = false
		
		if isBlackedOut then
			needsControl = true
			DisableControlAction(0, 71, true)
			DisableControlAction(0, 72, true)
			DisableControlAction(0, 63, true)
			DisableControlAction(0, 64, true)
			DisableControlAction(0, 288, true)
			DisableControlAction(0, 75, true)
		end
		
		if cacheVehicle and LocalPlayer.state.Belt then
			needsControl = true
			DisableControlAction(0, 75, true)
			DisableControlAction(27, 75, true)
		end
		
		Wait(needsControl and 0 or 500)
	end
end)

RegisterNetEvent('exotic_blackout/impact', function(speedBuffer, velocityBuffer)
	if type(speedBuffer) ~= "table" or type(velocityBuffer) ~= "table" or not speedBuffer[2] or not velocityBuffer[2] then
		beltCalled = false
		return
	end
	
	local vehicle = cacheVehicle or cache.vehicle
	local ped = cachePed or cache.ped
	local coords = cacheCoords or cache.coords
	
	CreateThread(function()
		if vehicle and not LocalPlayer.state.Belt then
			local pass = GetEntityHealth(ped)
			
			if pass then
				local hr = GetEntityHeading(vehicle) + 90.0
				if hr < 0.0 then hr = 360.0 + hr end

				hr = hr * 0.0174533
				local forward = { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }

				SetEntityCoords(ped, coords.x + forward.x, coords.y + forward.y, coords.z - 0.47, true, true, true)
				
				if type(velocityBuffer[2]) == "table" then
					SetEntityVelocity(ped, velocityBuffer[2].x, velocityBuffer[2].y, velocityBuffer[2].z)
				end
				Wait(0)

				SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
				local speed = math.floor(speedBuffer[2] * 3.6 + 0.5)
				if speed > 120 then
					Wait(500)
					Citizen.InvokeNative(0x6B76DC1F3AE6E6A3, ped, math.floor(math.max(99, (pass - (speed - 100))) + 0.5))
				end
			end
		end

		beltCalled = false
	end)
end)

RegisterNetEvent('exotic_blackout/belt', function(status)
	if cacheVehicle and not LocalPlayer.state.IsHandcuffed then
		LocalPlayer.state:set("Belt", status, true)
		TriggerServerEvent("interact-sound_SV:PlayOnSource", status and 'belton' or 'beltoff', 0.1)
	end
end)

-- Obsługa eventu z esx_core dla kompatybilności
RegisterNetEvent('esx_core:esx_blackout:belt', function(status)
	-- Czekamy chwilę, aby upewnić się, że pojazd jest dostępny (np. po włożeniu do pojazdu)
	CreateThread(function()
		local attempts = 0
		while attempts < 10 do
			local vehicle = cacheVehicle or GetVehiclePedIsIn(cachePed, false)
			if vehicle and vehicle ~= 0 then
				LocalPlayer.state:set("Belt", status, true)
				TriggerServerEvent("interact-sound_SV:PlayOnSource", status and 'belton' or 'beltoff', 0.1)
				break
			end
			Wait(100)
			attempts = attempts + 1
		end
	end)
end)

lib.addKeybind({
	name = 'pasy',
	description = 'Pasy',
	defaultKey = 'B',
	onPressed = function()
		if LocalPlayer.state.IsHandcuffed then
			return
		end
		if cacheVehicle and IsCar(cacheVehicle, true) then
			TriggerEvent('exotic_blackout/belt', not LocalPlayer.state.Belt)
		end
	end
})

CreateThread(function()	
	local speedBuffer = {}
	local velocityBuffer = {}
	
	while true do
		local sleep = true
		
		if cacheVehicle and IsCar(cacheVehicle, true) then
			sleep = false
			if GetPedInVehicleSeat(cacheVehicle, -1) == cachePed then
				speedBuffer[2] = speedBuffer[1]
				speedBuffer[1] = GetEntitySpeed(cacheVehicle)
				velocityBuffer[2] = velocityBuffer[1]
				velocityBuffer[1] = GetEntityVelocity(cacheVehicle)
				
				if speedBuffer[2] and velocityBuffer[2] and not beltCalled and speedBuffer[2] > 27.77 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.30) and not GetPlayerInvincible(cachePlayerId) and GetEntitySpeedVector(cacheVehicle, true).y > 1.0 then
					local list = {}
					for i = -1, GetVehicleNumberOfPassengers(cacheVehicle) do
						local ped = GetPedInVehicleSeat(cacheVehicle, i)
						if ped and ped ~= 0 then
							local playerIndex = NetworkGetPlayerIndexFromPed(ped)
							if playerIndex and playerIndex ~= -1 then
								list[#list+1] = GetPlayerServerId(playerIndex)
							end
						end
					end
				
					dzwonCalled = true
					beltCalled = true

					TriggerServerEvent('exotic_blackout/dzwon', list, 10)
					TriggerServerEvent('exotic_blackout/impact', list, speedBuffer, velocityBuffer)
				end
			else
				speedBuffer[1], speedBuffer[2], velocityBuffer[1], velocityBuffer[2] = 0.0, nil, nil, nil
			end
		else
			if not cacheVehicle then LocalPlayer.state:set("Belt", false, true) end
			speedBuffer[1], speedBuffer[2], velocityBuffer[1], velocityBuffer[2] = 0.0, nil, nil, nil
		end

		Wait(sleep and 500 or 100)
	end
end)

local function IsAffected() return isBlackedOut or isInjured end

exports('pasyState', pasyState)
exports('IsAffected', IsAffected)
exports('EnableDzwon', EnableDzwon)
exports('DisableDzwon', DisableDzwon)
