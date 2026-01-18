local ESX = ESX
local Citizen = Citizen
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local Licenses          = {}
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local AddBlipForCoord = AddBlipForCoord
local SetBlipSprite = SetBlipSprite
local SetBlipDisplay = SetBlipDisplay
local SetBlipScale = SetBlipScale
local SetBlipAsShortRange = SetBlipAsShortRange
local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
local EndTextCommandSetBlipName = EndTextCommandSetBlipName
local zdaje
local CurrentTest = false
local CurrentCheckPoint = 0
local LastCheckPoint = -1
local CurrentVehicle = nil
local CurrentBlip = nil
local DamageControl = 0
local SpeedControl = 0
local Lives = 3
local ox_target = exports.ox_target

local function decrypt(key)
	local result = ""

	for i = 1, #key do
		local char = string.byte(key, i)
		char = char - 3
		result = result .. string.char(char)
	end

	return result
end

local function OpenDMVSchoolMenu()
	local ownedLicenses = {}

	for i=1, #Licenses, 1 do
		ownedLicenses[Licenses[i].type] = true
	end

	if not ownedLicenses['dmv'] then
		lib.registerContext({
			id = 'drive_school',
			title = 'Ośrodek egzaminacyjny',
			options = {
				{
					title = 'Egzamin teoretyczny (2.000$)',
					description = 'Podejdź do egzaminu teoretycznego, aby móc podejść do egzaminów praktycznych',
					icon = 'fa-car',
					onSelect = function()
						if not ownedLicenses['dmv'] then
							ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
								if haveMoney then
									exports['esx_hud']:startDMVTest()
								else
									ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (2.000$)')
								end
							end, 'dmv')
						end
					end,
				},
			}
		})

		lib.showContext('drive_school')
	end

	if ownedLicenses['dmv'] then
		lib.registerContext({
			id = 'drive_school_start',
			title = 'Ośrodek egzaminacyjny',
			options = {
				{
					title = 'Egzamin praktyczny kat. A (3.000$)',
					description = 'Otrzymaj prawo jazdy kat. A',
					icon = 'fa-car',
					onSelect = function()
						if ownedLicenses['drive_bike'] then ESX.ShowNotification('Posiadasz już prawo jazdy kat. A!') return end
						ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
							if haveMoney then
								StartDriveTest("a")
								zdaje = "drive_bike"
							else
								ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (3.000$)')
							end
						end, 'drive_bike')
					end,
				},
				{
					title = 'Egzamin praktyczny kat. B (2.500$)',
					description = 'Otrzymaj prawo jazdy kat. B',
					icon = 'fa-car',
					onSelect = function()
						if ownedLicenses['drive'] then ESX.ShowNotification('Posiadasz już prawo jazdy kat. B!') return end
						ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
							if haveMoney then
								StartDriveTest("b")
								zdaje = "drive"
							else									
								ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (2.500$)')
							end
						end, 'drive')
					end,
				},
				{
					title = 'Egzamin praktyczny kat. C (5.000$)',
					description = 'Otrzymaj prawo jazdy kat. C',
					icon = 'fa-car',
					onSelect = function()
						if ownedLicenses['drive_truck'] then ESX.ShowNotification('Posiadasz już prawo jazdy kat. C!') return end
						ESX.TriggerServerCallback('esx_dmvschool:canYouPay', function(haveMoney)
							if haveMoney then
								StartDriveTest("c")
								zdaje = "drive_truck"
							else
								ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (5.000$)')
							end
						end, 'drive_truck')
					end,
				},
			}
		})
		
		lib.showContext('drive_school_start')
	end
end


RegisterNetEvent('esx_dmvschool:loadLicenses')
AddEventHandler('esx_dmvschool:loadLicenses', function(licenses)
	Licenses = licenses
end)

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)

	SetBlipSprite (blip, 545)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 0.7)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName('Szkoła jazdy')
	EndTextCommandSetBlipName(blip)
end)

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`s_m_m_strpreach_01`)

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
				canInteract = function ()
					if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle then return false end
					
					return true
				end,
				onSelect = function()
					OpenDMVSchoolMenu()
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

local peds = {}

Citizen.CreateThread(function ()
    peds[1] = lib.points.new({
        id = 140,
        distance = 15,
		coords = vec3(-915.4091, -2038.1460, 9.4050 - 1.0),
        heading = 212.6693,
		label = 'Zacznij rozmowę',
        onEnter = onEnter,
        onExit = onExit,
    })
end)



local function DrawMissionText(msg, time)
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, true)
end

local function ShowNotification(msg)
	ESX.ShowNotification(msg)
end

local DriveTestPoints = {
	{ x = -905.1473, y = -2057.7878, z = 9.2990 },
	{ x = -929.61486816406, y = -2081.724609375, z = 9.2990102767944 },
	{ x = -954.75323486328, y = -2106.8837890625, z = 9.2992734909058 },
	{ x = -937.02795410156, y = -2129.5764160156, z = 9.331521987915 },
	{ x = -823.70025634766, y = -2016.4403076172, z = 9.5359449386597 },
	{ x = -590.67974853516, y = -2040.3979492188, z = 6.3262076377869 },
	{ x = -507.09228515625, y = -2145.89453125, z = 9.0535955429077 },
	{ x = -747.08319091797, y = -2360.0864257812, z = 14.806161880493 },
	{ x = -754.39892578125, y = -2295.3005371094, z = 12.858248710632 },
	{ x = -850.17663574219, y = -2261.412109375, z = 7.4448990821838 },
	{ x = -777.36041259766, y = -2156.5134277344, z = 8.8479633331299 },
	{ x = -774.02514648438, y = -2032.9411621094, z = 8.8832511901855 },
	{ x = -888.072265625, y = -2075.7321777344, z = 8.935230255127 },
	{ x = -944.03485107422, y = -2121.5559082031, z = 9.2994155883789 },
	{x=-951.9342, y=-2089.1379, z=9.2993}
	
}

function StartDriveTest(type)
	ESX.Game.SpawnVehicle(Config.VehicleModels[type], vector3(-905.1473, -2057.7878, 9.2990), 135.2140, function(vehicle)
		if CurrentBlip then
			RemoveBlip(CurrentBlip)
			CurrentBlip = nil
		end
		
		CurrentTest = true
		LocalPlayer.state:set('InDrivingTest', true, true)
		CurrentCheckPoint = 0
		LastCheckPoint = #DriveTestPoints
		CurrentVehicle = vehicle
		DamageControl = GetVehicleBodyHealth(vehicle)
		Lives = 3
		SpeedControl = 0
		local playerPed = PlayerPedId()
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		SetVehicleFuelLevel(vehicle, 100.0)
		DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
		SetLocalPlayerAsGhost(true)
		ShowNotification('Rozpoczynasz egzamin praktyczny. Podążaj za znacznikami!')

		Citizen.CreateThread(function()
			while CurrentTest do
				Citizen.Wait(0)
				local playerPed = PlayerPedId()

				if CurrentCheckPoint <= LastCheckPoint then
					local coords = GetEntityCoords(playerPed)
					local nextCheckPoint = DriveTestPoints[CurrentCheckPoint + 1]

					if not nextCheckPoint then
						nextCheckPoint = DriveTestPoints[CurrentCheckPoint]
					end

					local distance = GetDistanceBetweenCoords(coords, nextCheckPoint.x, nextCheckPoint.y, nextCheckPoint.z, true)

					DrawMarker(1, nextCheckPoint.x, nextCheckPoint.y, nextCheckPoint.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)

					if not CurrentBlip then
						CurrentBlip = AddBlipForCoord(nextCheckPoint.x, nextCheckPoint.y, nextCheckPoint.z)
						SetBlipSprite(CurrentBlip, 1)
						SetBlipColour(CurrentBlip, 5)
						SetBlipRoute(CurrentBlip, true)
						SetBlipRouteColour(CurrentBlip, 5)
					end

					local speed = GetEntitySpeed(CurrentVehicle) * 3.6

					if speed > 80 then
						local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
						SpeedControl = SpeedControl + 1
						local currentVelocity = GetEntityVelocity(vehicle)
						local slowdownFactor = 0.5
						SetEntityVelocity(vehicle, currentVelocity.x * slowdownFactor, currentVelocity.y * slowdownFactor, currentVelocity.z * slowdownFactor)
						ESX.ShowNotification('Przekroczono predkość, '..SpeedControl.."/4")
						if SpeedControl >= 4 then
							FailTest('Przekroczyłeś dozwoloną prędkość zbyt wiele razy!')
						end
					end

					local health = GetVehicleBodyHealth(CurrentVehicle)
					if health < DamageControl - 5 then
						Lives = Lives - 1
						DamageControl = health
						if Lives <= 0 then
							FailTest('Uszkodziłeś pojazd zbyt wiele razy!')
						else
							ShowNotification('Uwaga! Pozostało ci ' .. Lives .. ' żyć!')
						end
					end

					if distance <= 3.0 then
						if CurrentCheckPoint == LastCheckPoint then
							if CurrentBlip then
								RemoveBlip(CurrentBlip)
								CurrentBlip = nil
							end
							FinishTest(true)
						else
							if CurrentBlip then
								RemoveBlip(CurrentBlip)
								CurrentBlip = nil
							end
							CurrentCheckPoint = CurrentCheckPoint + 1
							ShowNotification('Dobra robota! Jedź do następnego punktu!')
						end
					end
				end
			end
		end)
	end)
end

function FinishTest(success)
	if success then
		ShowNotification('Gratulacje! Zdałeś egzamin!')
		TriggerServerEvent('esx_dmvschool:addLicense', zdaje, decrypt(LocalPlayer.state.playerIndex))
		TriggerServerEvent('esx_dmvschool:reloadLicense')
	end

	CurrentTest = false
	LocalPlayer.state:set('InDrivingTest', false, true)
	zdaje = nil
	if CurrentBlip then
		RemoveBlip(CurrentBlip)
		CurrentBlip = nil
	end
	if DoesEntityExist(CurrentVehicle) then
		DeleteVehicle(CurrentVehicle)
	end
	SetEntityCoords(PlayerPedId(),-914.7662, -2045.4609, 9.3970)
	SetLocalPlayerAsGhost(false)
end

function FailTest(reason)
	ShowNotification(reason)
	CurrentTest = false
	LocalPlayer.state:set('InDrivingTest', false, true)
	zdaje = nil
	if CurrentBlip then
		RemoveBlip(CurrentBlip)
		CurrentBlip = nil
	end
	if DoesEntityExist(CurrentVehicle) then
		DeleteVehicle(CurrentVehicle)
	end
	SetEntityCoords(PlayerPedId(),-914.7662, -2045.4609, 9.3970)
	SetLocalPlayerAsGhost(false)
end

