LocalPlayer.state:set('InTrunk', false, true)

local cam = nil
local angleY = 0.0
local angleZ = 0.0
local inTrunk = nil
local cachePed = cache.ped
local cacheServerId = cache.serverId

lib.onCache('ped', function(ped)
	cachePed = ped
end)

lib.onCache('serverId', function(serverId)
	cacheServerId = serverId
end)

local function CheckTrunk(veh)
	return Config.DisabledTrunk[veh]
end

local function RotAnglesToVec(rot)
	local z = math.rad(rot.z)
	local x = math.rad(rot.x)
	local num = math.abs(math.cos(x))
	return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

local function GetVehicleInDirection()
	local pedCoords = GetEntityCoords(cachePed)
	local useCamera = false
	local maxDistance = 10.0
	
	local forwardVector
	local rayStart
	local rayEnd
	
	if useCamera then
		local camRot = GetGameplayCamRot(2)
		forwardVector = RotAnglesToVec(camRot)
		rayStart = pedCoords + vector3(0.0, 0.0, 0.5)
		rayEnd = rayStart + forwardVector * maxDistance
	else
		forwardVector = GetEntityForwardVector(cachePed)
		rayStart = pedCoords + vector3(0.0, 0.0, 0.5)
		rayEnd = rayStart + forwardVector * maxDistance
	end
	
	local rayHandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, -1, cachePed, 0)
	Wait(0)
	local _, hit, coords, _, entityHit = GetShapeTestResult(rayHandle)
	
	if hit == 1 and entityHit ~= 0 and IsEntityAVehicle(entityHit) then
		return entityHit, coords
	end
	
	local closestVehicle = ESX.Game.GetClosestVehicle(pedCoords)
	if closestVehicle and closestVehicle ~= 0 then
		local vehicleCoords = GetEntityCoords(closestVehicle)
		local distance = #(pedCoords - vehicleCoords)
		
		if distance <= maxDistance then
			local directionToVehicle = (vehicleCoords - pedCoords) / distance
			local dotProduct = forwardVector.x * directionToVehicle.x + forwardVector.y * directionToVehicle.y
			
			if dotProduct > 0.3 then
				return closestVehicle, vehicleCoords
			end
		end
	end
	
	return nil, nil
end

local function StartDeathCam()
	ClearFocus()
	local pedCoords = GetEntityCoords(cachePed)
	local pedHeading = GetEntityHeading(cachePed)
	
	angleZ = pedHeading
	angleY = -10.0
	
	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pedCoords.x, pedCoords.y, pedCoords.z + 0.5, 0.0, 0.0, pedHeading, GetGameplayCamFov())
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 1000, true, false)
end

local function EndDeathCam()
	ClearFocus()
	RenderScriptCams(false, false, 0, true, false)
	DestroyCam(cam, false)
	cam = nil
end

local function ProcessNewPosition()
	local inputDisabled = IsInputDisabled(0)
	local multiplier = inputDisabled and 8.0 or 1.5
	local mouseX = GetDisabledControlNormal(1, 1) * multiplier
	local mouseY = GetDisabledControlNormal(1, 2) * multiplier

	angleZ = angleZ - mouseX
	angleY = angleY + mouseY
	if angleY > 60.0 then
		angleY = 60.0
	elseif angleY < -60.0 then
		angleY = -60.0
	end

	local pedCoords = GetEntityCoords(cachePed)
	local cosY = Cos(angleY)
	local cosZ = Cos(angleZ)
	local sinY = Sin(angleY)
	local sinZ = Sin(angleZ)
	local xyMultiplier = cosZ * cosY
	local yzMultiplier = sinZ * cosY
	local radius = 2.5

	local rayStartZ = pedCoords.z + 0.3
	local rayEndX = pedCoords.x + xyMultiplier * radius
	local rayEndY = pedCoords.y + yzMultiplier * radius
	local rayEndZ = pedCoords.z + sinY * radius + 0.3
	
	local rayHandle = StartShapeTestRay(pedCoords.x, pedCoords.y, rayStartZ, rayEndX, rayEndY, rayEndZ, -1, cachePed, 0)
	local _, hitBool, hitCoords = GetShapeTestResult(rayHandle)

	if hitBool == 1 then
		local hitDist = #(vec3(pedCoords.x, pedCoords.y, rayStartZ) - vec3(hitCoords))
		if hitDist < radius then
			radius = math.max(hitDist - 0.1, 0.5)
		end
	end

	return {
		x = pedCoords.x + xyMultiplier * radius,
		y = pedCoords.y + yzMultiplier * radius,
		z = pedCoords.z + sinY * radius + 0.3
	}
end

local function ProcessCamControls()
	DisableFirstPersonCamThisFrame()
	local newPos = ProcessNewPosition()
	SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
	SetCamCoord(cam, newPos.x, newPos.y, newPos.z)

	local pedCoords = GetEntityCoords(cachePed)
	PointCamAtCoord(cam, pedCoords.x, pedCoords.y, pedCoords.z + 0.5)
end

RegisterNetEvent("esx_core:forceInTrunk", function(forcedVehicle)
	if not inTrunk then
		if LocalPlayer.state.IsJailed <= 0 then
			local targetVehicle = forcedVehicle or GetVehicleInDirection()
			
			if targetVehicle then
				local model = GetEntityModel(targetVehicle)

				if IsThisModelACar(model) and not CheckTrunk(model) then
					lib.requestAnimDict('fin_ext_p1-7')
				
					local getInSeat = GetPedInVehicleSeat(targetVehicle, -1)

					if not DoesEntityExist(getInSeat) or IsPedAPlayer(getInSeat) then
						SetVehicleDoorOpen(targetVehicle, 5, false)
					end

					local id = NetworkGetNetworkIdFromEntity(targetVehicle)
					SetNetworkIdCanMigrate(id, true)
					SetEntityAsMissionEntity(targetVehicle, true, false)
					SetVehicleHasBeenOwnedByPlayer(targetVehicle,  true)

					ClearPedTasks(cachePed)
					
					TaskPlayAnim(cachePed, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)

					local d1, d2 = GetModelDimensions(model)
					AttachEntityToEntity(cachePed, targetVehicle, 0, -0.1, d1.y + 0.85, d2.z - 0.87, 0, 0, 40.0, 1, 1, 1, 1, 1, 1)
					TriggerServerEvent('es_extended:useDecorUpdate', 'INT', id, 'trunk', cacheServerId)
					inTrunk = targetVehicle
					LocalPlayer.state:set('InTrunk', true, true)
					StartDeathCam()
				end
			end
		end
	end
end)

RegisterNetEvent("esx_core:forceOutTrunk", function()
	if inTrunk then
		ClearPedTasks(cachePed)
		DetachEntity(cachePed)

		local pedCoords = GetEntityCoords(cachePed)
		SetEntityCoords(cachePed, pedCoords.x + 1.5, pedCoords.y + 1.5, pedCoords.z)

		TriggerServerEvent('es_extended:useDecorUpdate', 'DEL', NetworkGetNetworkIdFromEntity(inTrunk), 'trunk')

		inTrunk = nil
		LocalPlayer.state:set('InTrunk', false, true)

		if not LocalPlayer.state.IsDead then
			EndDeathCam()
		end
	end
end)

AddEventHandler('playerDropped', function()
	if inTrunk then
		TriggerServerEvent('es_extended:useDecorUpdate', 'DEL', NetworkGetNetworkIdFromEntity(inTrunk), 'trunk')
	end
end)

local function TrunkFirst()
	if not DecorIsRegisteredAsType('trunk', 3) then
		DecorRegister('trunk', 3)
	end

	local disabledControls = {
		{2, 24}, {2, 257}, {2, 25}, {2, 263}, {2, Config.Keys["R"]}, {2, Config.Keys["TOP"]},
		{2, Config.Keys["SPACE"]}, {2, Config.Keys["Q"]}, {2, Config.Keys["~"]}, {2, Config.Keys["B"]},
		{2, Config.Keys["TAB"]}, {2, Config.Keys["F"]}, {2, Config.Keys["F3"]}, {2, Config.Keys["LEFTSHIFT"]},
		{2, Config.Keys["V"]}, {2, 59}, {2, Config.Keys["LEFTCTRL"]}, {0, 47}, {0, 264}, {0, 257},
		{0, 140}, {0, 141}, {0, 142}, {0, 143}, {0, 75}, {27, 75}, {0, 73}, {0, 11}
	}

	while true do
		if inTrunk then
			Wait(0)
			local attached = IsEntityAttachedToAnyVehicle(cachePed)
			local shouldExit = false
			local makeVisible = false

			if DoesEntityExist(inTrunk) and attached then
				if IsEntityVisible(inTrunk) then
					if not LocalPlayer.state.IsDead then
						ProcessCamControls()

						for i = 1, #disabledControls do
							DisableControlAction(disabledControls[i][1], disabledControls[i][2], true)
						end

						lib.requestAnimDict('fin_ext_p1-7')
						TaskPlayAnim(cachePed, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
					else
						shouldExit = true
						makeVisible = true
					end
				else
					shouldExit = true
					makeVisible = true
				end
			else
				shouldExit = true
			end

			if shouldExit then
				TriggerEvent('esx_core:forceOutTrunk')
				if makeVisible then
					SetEntityVisible(cachePed, true)
				end
			elseif not DecorExistOn(inTrunk, 'trunk') then
				TriggerServerEvent('es_extended:useDecorUpdate', 'INT', NetworkGetNetworkIdFromEntity(inTrunk), 'trunk', cacheServerId)
			end
		else
			Wait(500)
		end
	end
end

CreateThread(TrunkFirst)

local function TrunkSecond()
	while true do
		if inTrunk and DoesEntityExist(inTrunk) and not LocalPlayer.state.IsDead and LocalPlayer.state.IsJailed <= 0 then
			Wait(0)
			local doorAngle = GetVehicleDoorAngleRatio(inTrunk, 5)
			local doorLockStatus = GetVehicleDoorLockStatus(inTrunk)

			if IsControlJustReleased(0, Config.Keys["H"]) and doorLockStatus < 2 then
				local getInSeat = GetPedInVehicleSeat(inTrunk, -1)
				if not DoesEntityExist(getInSeat) or IsPedAPlayer(getInSeat) then
					if doorAngle > 0 then
						SetVehicleDoorShut(inTrunk, 5, false)
					else
						SetVehicleDoorOpen(inTrunk, 5, false, false)
					end
				end
			end

			if IsControlJustReleased(0, Config.Keys["Y"]) and doorAngle > 0.0 then
				if not LocalPlayer.state.IsHandcuffed then
					TriggerEvent('esx_core:forceOutTrunk')
				end
			end
		else
			Wait(500)
		end
	end
end

CreateThread(TrunkSecond)

AddEventHandler('esx:onPlayerSpawn', function()
	if inTrunk then
		TriggerEvent('esx_core:forceOutTrunk')
	end
end)

lib.addKeybind({
	name = 'carmenu',
	description = 'Otwórz menu pojazdu',
	defaultKey = 'H',
	onPressed = function()
		if IsPedInAnyVehicle(PlayerPedId(), true) and not LocalPlayer.state.InTrunk then
			return
		end
		
		local vehicle, coords = GetVehicleInDirection()
		if vehicle and GetVehicleDoorLockStatus(vehicle) < 2 then
			local resourceName = GetCurrentResourceName()
			if ESX.UI.Menu.IsOpen('default', resourceName, 'car_menu') then
				ESX.UI.Menu.Close('default', resourceName, 'car_menu')
			end

			if ESX.UI.Menu.IsOpen('default', resourceName, 'car_doors_menu') then
				ESX.UI.Menu.Close('default', resourceName, 'car_doors_menu')
			end

			local elements = {}

			if not LocalPlayer.state.IsHandcuffed then
				if LocalPlayer.state.InTrunk then
					table.insert(elements, {label = 'Wyjdź z bagażnika', value = 'outhide'})
				else
					table.insert(elements, {label = 'Wejdź do bagażnika', value = 'hide'})
				end
			end

			ESX.UI.Menu.Open('default', resourceName, 'car_menu', {
				title = 'Pojazd',
				align = 'center',
				elements = elements
			}, function(data, menu)
				if data.current.value == 'hide' then
					menu.close()
					TriggerEvent('esx_core:forceInTrunk')
				elseif data.current.value == 'outhide' then
					menu.close()
					TriggerEvent('esx_core:forceOutTrunk')
				end
			end, function(data, menu)
				menu.close()
			end)
		end
	end
})