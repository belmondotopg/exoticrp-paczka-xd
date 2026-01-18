local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent

local esx_vehicleshop = exports.esx_vehicleshop
local GetVehicleNumberPlateText = GetVehicleNumberPlateText
local IsEntityAVehicle = IsEntityAVehicle
local GetEntitySpeed = GetEntitySpeed
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local StartShapeTestCapsule = StartShapeTestCapsule
local GetShapeTestResult = GetShapeTestResult
local GetDisplayNameFromVehicleModel = GetDisplayNameFromVehicleModel
local GetEntityModel = GetEntityModel
local GetLabelText = GetLabelText
local GetHashKey = GetHashKey
local IsPedInAnyPoliceVehicle = IsPedInAnyPoliceVehicle
local IsPedInAnyHeli = IsPedInAnyHeli
local e, j, fmodel, bmodel
local found = false
local libCache = lib.onCache
local cachePed = cache.ped
local cacheVehicle = cache.vehicle
local radar = {
	shown = false,
	freeze = false,
	info = "Radar gotowy do działania! Naciśnij [Num8] aby zamrozić",
	info2 = "Radar gotowy do działania! Naciśnij [Num8] aby zamrozić",
	plate = "",
	model = "",
	plate2 = "",
	model2 = "",
}

libCache('ped', function(ped)
    cachePed = ped
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

local function RadarFirst()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(300)
			if radar.shown then
				local coordA = GetOffsetFromEntityInWorldCoords(cacheVehicle, 0.0, 1.0, 1.0)
				local coordB = GetOffsetFromEntityInWorldCoords(cacheVehicle, 0.0, 105.0, 0.0)
				local frontcar = StartShapeTestCapsule(coordA, coordB, 3.0, 10, cacheVehicle, 7)
				_, _, _, _, e = GetShapeTestResult(frontcar)
				if IsEntityAVehicle(e) then
					fmodel = GetDisplayNameFromVehicleModel(GetEntityModel(e))
					if not found then
						local label = GetLabelText(fmodel)
						if label ~= "NULL" then
							fmodel = label
						end
					end

					if fmodel ~= 'CARNOTFOUND' then
						local VehTable = esx_vehicleshop.getVehicles()
						local VehModel = GetEntityModel(e)
						for j=1, #VehTable, 1 do    
							if VehModel == GetHashKey(VehTable[j].model) then
								fmodel = VehTable[j].name
								found = true
								break
							end
						end
					end
				end

				local bcoordB = GetOffsetFromEntityInWorldCoords(cacheVehicle, 0.0, -105.0, 0.0)
				local rearcar = StartShapeTestCapsule(coordA, bcoordB, 3.0, 10, cacheVehicle, 7)
				_, _, _, _, j  = GetShapeTestResult(rearcar)
				if IsEntityAVehicle(j) then
					bmodel = GetDisplayNameFromVehicleModel(GetEntityModel(j))
					if not found then
						local label = GetLabelText(bmodel)
						if label ~= "NULL" then
							bmodel = label
						end
					end

					if bmodel ~= 'CARNOTFOUND' then
						local VehTable3 = esx_vehicleshop.getVehicles()
						local VehModel3 = GetEntityModel(j)
						for i=1, #VehTable3, 1 do
							if VehModel3 == GetHashKey(VehTable3[i].model) then
								bmodel = VehTable3[i].name
								found = true
								break
							end
						end
					end
				end
			else
				Citizen.Wait(1000)
			end
		end
	end)
end

local function RadarSecond()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(100)
			local sleep = true
			
			if radar.shown then
				sleep = false
				if not radar.freeze then
					if IsEntityAVehicle(e) then
						local vehState = Entity(e).state.BlachyPrzebite
						radar.plate = GetVehicleNumberPlateText(e)
						if vehState ~= nil and vehState == true then
							radar.plate = "-"
						end
						
						radar.model = fmodel
						TriggerEvent('esx_hud:updateRadarInfo', 'front', fmodel, radar.plate, math.floor(GetEntitySpeed(e) * 3.6 + 0.5))
					end

					if IsEntityAVehicle(j) then
						local vehState2 = Entity(j).state.BlachyPrzebite
						radar.plate2 = GetVehicleNumberPlateText(j)
						if vehState2 ~= nil and vehState2 == true then
							radar.plate2 = "-"
						end
						radar.model2 = bmodel
						TriggerEvent('esx_hud:updateRadarInfo', 'rear', bmodel, radar.plate2, math.floor(GetEntitySpeed(j) * 3.6 + 0.5))		
					end
				end
			end

			if not cacheVehicle then
				radar.shown = false
				radar.freeze = false
				radar.model = nil
				radar.model2 = nil
				radar.plate = nil
				radar.plate2 = nil
				TriggerEvent('esx_hud:showRadar', false)
			end

			if sleep then
				Citizen.Wait(1500)
			end
		end
	end)
end

lib.addKeybind({
	name = 'radarlspd1',
	description = 'Radar [LSPD/LSSD]',
	defaultKey = 'NUMPAD5',
	onPressed = function()
		if IsPedInAnyPoliceVehicle(cachePed) and not IsPedInAnyHeli(cachePed) then
			if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff') then
				radar.shown = not radar.shown
				TriggerEvent('esx_hud:showRadar', radar.shown)
			end
		end
	end
})

lib.addKeybind({
	name = 'radarlspd2',
	description = 'Zatrzymaj Radar [LSPD/LSSD]',
	defaultKey = 'NUMPAD8',
	onPressed = function()
		if IsPedInAnyPoliceVehicle(cachePed) and not IsPedInAnyHeli(cachePed) then
			if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff') then
				radar.freeze = not radar.freeze
				TriggerEvent('esx_hud:freezeRadar', radar.freeze)
			end
		end
	end
})

lib.addKeybind({
	name = 'blachalspdprzod',
	description = 'Sprawdź blache [PRZÓD]',
	defaultKey = 'NUMPAD4',
	onPressed = function()
		if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff') then
			if IsPedInAnyPoliceVehicle(cachePed) and not IsPedInAnyHeli(cachePed) and radar.shown then
				if radar.plate then
					TriggerEvent('esx_core:carPlates', radar.plate:gsub("%s$", ""), radar.model)
				else
					ESX.ShowNotification('Brak rejestracji pojazdu z przodu')
				end
			end
		end
	end
})

lib.addKeybind({
	name = 'blachalspdtyl',
	description = 'Sprawdź blache [TYŁ]',
	defaultKey = 'NUMPAD6',
	onPressed = function()
		if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff') then
			if IsPedInAnyPoliceVehicle(cachePed) and not IsPedInAnyHeli(cachePed) and radar.shown then
				if radar.plate2 then
					TriggerEvent('esx_core:carPlates', radar.plate2:gsub("%s$", ""), radar.model2)
				else
					ESX.ShowNotification('Brak rejestracji pojazdu z tyłu')
				end
			end
		end
	end
})

RegisterNetEvent('esx_core:carPlates')
AddEventHandler('esx_core:carPlates', function(plate, model)
	ESX.ShowNotification('Wyszukiwanie właściciela pojazdu')
	TriggerServerEvent('esx_core:checkPlates', plate)
end)

Citizen.CreateThread(function ()
    RadarFirst()
    RadarSecond()
end)
