local ESX = ESX
local Citizen = Citizen
local TriggerEvent = TriggerEvent

local ClearPedTasks = ClearPedTasks
local fov_max = 80.0
local fov_min = 5.0 
local zoomspeed = 3.0
local speed_lr = 4.0
local speed_ud = 4.0
local toggle_lock_on = 22
local maxtargetdistance = 1000
local speed_measure = "Km/h"
local target_vehicle = nil
local vehicle_display = 0 
local helicam = false
local fov = (fov_max+fov_min)*0.5
local vehicles = {}
local NetworkIsSessionStarted = NetworkIsSessionStarted
local DecorRegister = DecorRegister
local GetDisabledControlNormal = GetDisabledControlNormal
local GetCamRot = GetCamRot
local SetCamRot = SetCamRot
local DisableControlAction = DisableControlAction
local IsControlJustPressed = IsControlJustPressed
local SetCamFov = SetCamFov
local GetCamCoord = GetCamCoord
local StartShapeTestRay = StartShapeTestRay
local GetShapeTestResult = GetShapeTestResult
local IsEntityAVehicle = IsEntityAVehicle
local GetDisplayNameFromVehicleModel = GetDisplayNameFromVehicleModel
local GetEntityModel = GetEntityModel
local DoesEntityExist = DoesEntityExist
local GetVehicleNumberPlateText = GetVehicleNumberPlateText
local GetLabelText = GetLabelText
local GetEntitySpeed = GetEntitySpeed
local GetEntityCoords = GetEntityCoords
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local SetTextFont = SetTextFont
local SetScaleformMovieAsNoLongerNeeded = SetScaleformMovieAsNoLongerNeeded
local SetSeethrough = SetSeethrough
local SetTextProportional = SetTextProportional
local SetTextScale = SetTextScale
local SetTextColour = SetTextColour
local SetTextDropshadow = SetTextDropshadow
local SetTextEdge = SetTextEdge
local SetTextDropShadow = SetTextDropShadow
local SetTextOutline = SetTextOutline
local AddTextComponentString = AddTextComponentString
local DrawText = DrawText
local SetTextEntry = SetTextEntry
local GetPedInVehicleSeat = GetPedInVehicleSeat
local PlaySoundFrontend = PlaySoundFrontend
local SetPedCanRagdoll = SetPedCanRagdoll
local TaskRappelFromHeli = TaskRappelFromHeli
local HasScaleformMovieLoaded = HasScaleformMovieLoaded
local AttachCamToEntity = AttachCamToEntity
local CreateCam = CreateCam
local GetEntityHeading = GetEntityHeading
local RenderScriptCams = RenderScriptCams
local PushScaleformMovieFunction = PushScaleformMovieFunction
local PushScaleformMovieFunctionParameterInt = PushScaleformMovieFunctionParameterInt
local PopScaleformMovieFunctionVoid = PopScaleformMovieFunctionVoid
local DecorExistOn = DecorExistOn
local PointCamAtEntity = PointCamAtEntity
local DestroyCam = DestroyCam
local PushScaleformMovieFunctionParameterFloat = PushScaleformMovieFunctionParameterFloat
local DrawScaleformMovieFullscreen = DrawScaleformMovieFullscreen
local ClearTimecycleModifier = ClearTimecycleModifier
local GetVehicleClass = GetVehicleClass
local HasEntityClearLosToEntity = HasEntityClearLosToEntity
local SetTimecycleModifier = SetTimecycleModifier
local SetTimecycleModifierStrength = SetTimecycleModifierStrength
local RequestScaleformMovie = RequestScaleformMovie
local GetCamFov = GetCamFov
local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

Citizen.CreateThread(function() 
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			DecorRegister("SpotvectorX", 3) 
			DecorRegister("SpotvectorY", 3)
			DecorRegister("SpotvectorZ", 3)
			break
		end
	end
end)


local function RotAnglesToVec(rot)
	local z = math.rad(rot.z)
	local x = math.rad(rot.x)
	local num = math.abs(math.cos(x))
	return vector3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))
end

local function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		local new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		local new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

local function HandleZoom(cam)
	DisableControlAction(2, 85, true)

	if IsControlJustPressed(0,241) then
		fov = math.max(fov - zoomspeed, fov_min)
	end

	if IsControlJustPressed(0,242) then
		fov = math.min(fov + zoomspeed, fov_max)
	end

	local current_fov = GetCamFov(cam)
	if math.abs(fov-current_fov) < 0.1 then
		fov = current_fov
	end

	SetCamFov(cam, current_fov + (fov - current_fov)*0.05) 
end

local function GetVehicleInView(cam, cacheVehicle)
	local coords = GetCamCoord(cam)
	local forward_vector = RotAnglesToVec(GetCamRot(cam, 2))
	local rayhandle = StartShapeTestRay(coords, coords+(forward_vector*200.0), 2, cacheVehicle, 0)
	local result, hit, entityCoords, surfaceVector, entityHit = GetShapeTestResult(rayhandle)
	if hit and IsEntityAVehicle(entityHit) then
		return entityHit
	end
end

local function RenderVehicleInfo(vehicle)	
	if DoesEntityExist(vehicle) then
		local name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
		if name ~= 'CARNOTFOUND' then				
			local found = false
			
			for _, veh in ipairs(vehicles) do
				if (veh.game == name) or veh.model == fmodel then
					fmodel = veh.name
					found = true
					break
				end
			end

			if not found then
				local label = GetLabelText(name)
				if label ~= "NULL" then
					name = label
				end
			end
		end

		local licenseplate = GetVehicleNumberPlateText(vehicle)
		local vehspeed = GetEntitySpeed(vehicle)*3.6

		local coords = GetEntityCoords(vehicle, true)
		local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
		local street1, street2 = GetStreetNameFromHashKey(s1), GetStreetNameFromHashKey(s2)

		SetTextFont(0)
		SetTextProportional(1)

		if vehicle_display == 0 then
			SetTextScale(0.0, 0.34)
		elseif vehicle_display == 1 then
			SetTextScale(0.0, 0.4)
		end

		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()

		SetTextEntry("STRING")
		if vehicle_display == 0 then
			AddTextComponentString("Prędkość: " .. math.floor(vehspeed + 0.5) .. " " .. speed_measure .. "\nPojazd: " .. name .. "\nNr rej.: " .. licenseplate .. "\n" .. street1 .. (street2 ~= "" and " / " .. street2 or ""))
		elseif vehicle_display == 1 then
			AddTextComponentString("Pojazd: " .. name .. "\nNr rej.: " .. licenseplate .. "\n" .. street1 .. (street2 ~= "" and " / " .. street2 or ""))
		end

		DrawText(0.75, 0.9)
	end
end

lib.addKeybind({
	name = 'lspdrappel',
	description = 'Lina w helikopterze (LSPD/LSSD)',
	defaultKey = 'X',
	onPressed = function()
		if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' then
			if helicam then
				if GetPedInVehicleSeat(cacheVehicle, 1) == cachePed or GetPedInVehicleSeat(cacheVehicle, 2) == cachePed then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					SetPedCanRagdoll(cachePed, false)
					TaskRappelFromHeli(cachePed, 1)
					Citizen.Wait(30000)
					SetPedCanRagdoll(cachePed, true)
				else
					PlaySoundFrontend(-1, "5_Second_Timer", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", false) 
				end
			end
		end
	end
})

lib.addKeybind({
	name = 'lspdcamera',
	description = 'Kamera w helikopterze (LSPD/LSSD)',
	defaultKey = 'E',
	onPressed = function()
		if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' then
			if (GetPedInVehicleSeat(cacheVehicle, -1) == cachePed or GetPedInVehicleSeat(cacheVehicle, 0) == cachePed) and (GetVehicleClass(cacheVehicle) == 15) then
				PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
				helicam = not helicam
			end
		end
	end
})

local function useLornetka()
	helicam = not helicam
end

Citizen.CreateThread(function()
	Citizen.Wait(5000)
	TriggerEvent('esx_vehicleshop:getVehicles', function(base)
		vehicles = base
	end)

	Citizen.CreateThread(function()
		local ticks = 0
		while true do
			Citizen.Wait(100)
			if cacheVehicle and target_vehicle and not HasEntityClearLosToEntity(cacheVehicle, target_vehicle, 17) then
				ticks = ticks + 1
				if ticks == 10 then 
					target_vehicle = nil
					ticks = 0
				end
			else
				ticks = 0
			end
		end
	end)

	while true do
        Citizen.Wait(0)
		
		local sleep = true
		local model = GetEntityModel(cacheVehicle)

		if model == `polmav` then
			sleep = false

			if target_vehicle and (GetPedInVehicleSeat(cacheVehicle, -1) == cachePed or GetPedInVehicleSeat(cacheVehicle, 0) == cachePed) then
				local coords1 = GetEntityCoords(cacheVehicle)
				local coords2 = GetEntityCoords(target_vehicle)

				local target_distance = #(coords1 - coords2)
				if IsControlJustPressed(0, toggle_lock_on) or target_distance > maxtargetdistance then
					target_vehicle = nil					
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
				end
			end
		end

		if helicam then
			sleep = false

			if not cacheVehicle then
				Citizen.CreateThread(function()
					TaskStartScenarioInPlace(cachePed, "WORLD_HUMAN_BINOCULARS", 0, 1)
					PlayAmbientSpeech1(cachePed, "GENERIC_CURSE_MED", "SPEECH_PARAMS_FORCE")
				end)
			end

			SetTimecycleModifier("heliGunCam")
			SetTimecycleModifierStrength(0.3)

			local scaleform = RequestScaleformMovie("HELI_CAM")
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end

			local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
			AttachCamToEntity(cam, cachePed, 0.0,0.0,1.0, true)
			SetCamRot(cam, 0.0,0.0, GetEntityHeading(cachePed))
			SetCamFov(cam, fov)
			RenderScriptCams(true, false, 0, 1, 0)
			PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
			PushScaleformMovieFunctionParameterInt(0)
			PopScaleformMovieFunctionVoid()

			local locked_on_vehicle = nil
			while helicam and not LocalPlayer.state.IsDead do
                local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)

				if IsControlJustPressed(0, 177) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					ClearPedTasks(cachePed)
					helicam = false
				end

				if locked_on_vehicle then
					if DoesEntityExist(locked_on_vehicle) then
						PointCamAtEntity(cam, locked_on_vehicle, 0.0, 0.0, 0.0, true)
						RenderVehicleInfo(locked_on_vehicle)
						local coords1 = GetEntityCoords(cacheVehicle)
						local coords2 = GetEntityCoords(locked_on_vehicle)

						local target_distance = #(coords1 - coords2)
						if IsControlJustPressed(0, toggle_lock_on) or target_distance > maxtargetdistance then
							PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
							target_vehicle = nil
							locked_on_vehicle = nil
							local rot = GetCamRot(cam, 2)
							local fov = GetCamFov(cam)
							local old_cam = cam
							DestroyCam(old_cam, false)
							cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
							AttachCamToEntity(cam, cacheVehicle, 0.0,0.0,-1.5, true)
							SetCamRot(cam, rot, 2)
							SetCamFov(cam, fov)
							RenderScriptCams(true, false, 0, 1, 0)
						end
					else
						locked_on_vehicle = nil
						target_vehicle = nil
					end
				else
					CheckInputRotation(cam, zoomvalue)
					local vehicle_detected = GetVehicleInView(cam, cacheVehicle)
					if DoesEntityExist(vehicle_detected) then
						RenderVehicleInfo(vehicle_detected)
						if IsControlJustPressed(0, toggle_lock_on) then
							PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
							locked_on_vehicle = vehicle_detected
							target_vehicle = vehicle_detected
						end
					end
				end

				HandleZoom(cam)
				PushScaleformMovieFunction(scaleform, "SET_ALT_FOV_HEADING")
				PushScaleformMovieFunctionParameterFloat(GetEntityCoords(cacheVehicle).z)
				PushScaleformMovieFunctionParameterFloat(zoomvalue)
				PushScaleformMovieFunctionParameterFloat(GetCamRot(cam, 2).z)
				PopScaleformMovieFunctionVoid()
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
				Citizen.Wait(0)
			end

			helicam = false
			ClearTimecycleModifier()

			fov = (fov_max+fov_min)*0.5
			RenderScriptCams(false, false, 0, 1, 0)
			SetScaleformMovieAsNoLongerNeeded(scaleform)
			DestroyCam(cam, false)
			SetSeethrough(false)
		end

		if (model == `polmav`) and target_vehicle and not helicam and vehicle_display ~= 2 then
			RenderVehicleInfo(target_vehicle)
			sleep = false
		end
		
		if sleep then
			Citizen.Wait(500)
		end
	end
end)

exports('useLornetka', useLornetka)