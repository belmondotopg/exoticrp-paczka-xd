local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local GetVehiclePedIsUsing = GetVehiclePedIsUsing
local DoScreenFadeOut = DoScreenFadeOut
local SetEntityHeading = SetEntityHeading
local DoScreenFadeIn = DoScreenFadeIn
local SetGameplayCamRelativeHeading = SetGameplayCamRelativeHeading
local RequestCollisionAtCoord = RequestCollisionAtCoord
local HasCollisionLoadedAroundEntity = HasCollisionLoadedAroundEntity
local SetEntityCoordsNoOffset = SetEntityCoordsNoOffset
local IsScreenFadingIn = IsScreenFadingIn
local IsControlJustPressed = IsControlJustPressed
local GetPedInVehicleSeat = GetPedInVehicleSeat
local esx_hud = exports.esx_hud

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
    ESX.PlayerData.job = Job
end)

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

local function TeleportFadeEffect(entity, coords, heading)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or cacheVehicle then
		ESX.ShowNotification('Nie możesz teraz tego użyć!')
		return
	end
	
	Citizen.CreateThread(function()
        DoScreenFadeOut(100)
		Citizen.Wait(300)
		ESX.Game.Teleport(entity, coords, function()
			Citizen.Wait(100)
			if heading then
				SetEntityHeading(entity, heading)
			end
			DoScreenFadeIn(100)
			SetGameplayCamRelativeHeading(0.0)
			TriggerServerEvent('esx_core:SendLog', "Teleportacja bez pojazdu", "Przeteleportował się bez pojazdu używając teleportu na koordynaty "..coords, 'teleports')
		end)
		Citizen.Wait(500)
		DoScreenFadeIn(100)
	end)
end

local function TeleportCarFadeEffect(vehicle, coords, heading)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
		ESX.ShowNotification('Nie możesz teraz tego użyć!')
		return
	end

	Citizen.CreateThread(function()
		DoScreenFadeOut(800)
		Citizen.Wait(300)
		RequestCollisionAtCoord(coords)
		while not HasCollisionLoadedAroundEntity(cachePed) do
			Citizen.Wait(0)
		end

		SetEntityCoordsNoOffset(vehicle, vec3(coords.x, coords.y, coords.z + 0.5), 0, 0, 0)

		Citizen.Wait(600)

		if heading then
			SetEntityHeading(vehicle, heading)
		end

		SetGameplayCamRelativeHeading(0.0)

		DoScreenFadeIn(800)
		
		while IsScreenFadingIn() do
			Citizen.Wait(0)
		end

		BusyspinnerOff()
		TriggerServerEvent('esx_core:SendLog', "Teleportacja z pojazdem", "Przeteleportował się z pojazdem używając teleportu na koordynaty "..coords, 'teleports')
	end)
end

local function UseLift(coords, heading)
	if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed or cacheVehicle then
		ESX.ShowNotification('Nie możesz teraz tego użyć!')
		return
	end
	
	local x, y, z = coords.x, coords.y, coords.z
	z = z-0.9
	coords = vec3(x,y,z)
	TeleportFadeEffect(cachePed, coords, heading)
end

local function OpenLiftMenu(zone, currentFloor)
	ESX.UI.Menu.CloseAll()
	local elements = {}
	for i=1, #Config.Lifts[zone], 1 do
		local nextFloor = Config.Lifts[zone][i]
		if i ~= currentFloor then
			table.insert(elements, {label = nextFloor.Label, value = nextFloor.Coords, heading = nextFloor.Heading})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'lift_menu',
	{
		title    = "Teleport",
		align    = 'center',
		elements = elements
	}, function(data, menu)			
		menu.close()
		UseLift(data.current.value, data.current.heading)
	end, function(data, menu)
		menu.close()
	end)
end

local function CarTravel(coords, heading)
	local vehicle = GetVehiclePedIsUsing(cachePed)
	TeleportCarFadeEffect(vehicle, coords, heading)
end

local function FastTravel(coords, heading)
	TeleportFadeEffect(cachePed, coords, heading)
end

Citizen.CreateThread(function()
	while ESX.PlayerData.job == nil do
		Citizen.Wait(100)
	end
	while true do
		Citizen.Wait(0)
		local found = false
		for i=1, #Config.TeleportsLegs, 1 do
			local distance = #(cacheCoords - Config.TeleportsLegs[i].From)
			if distance < Config.DrawDistance then
				found = true
				if not Config.TeleportsLegs[i].Visible then
					DrawMarker(Config.MarkerLegs.type, Config.TeleportsLegs[i].From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerLegs.x, Config.MarkerLegs.y, Config.MarkerLegs.z, Config.MarkerLegs.r, Config.MarkerLegs.g, Config.MarkerLegs.b, Config.MarkerLegs.a, false, true, 2, Config.MarkerLegs.rotate, nil, nil, false)
					if distance < Config.MarkerLegs.x+0.5 then
						if IsControlJustPressed(0, 38) then
							FastTravel(Config.TeleportsLegs[i].To, Config.TeleportsLegs[i].Heading)
						end
					end
				else
					for j=1, #Config.TeleportsLegs[i].Visible, 1 do
						if ESX.PlayerData.job.name == Config.TeleportsLegs[i].Visible[j] then
							DrawMarker(Config.MarkerLegs.type, Config.TeleportsLegs[i].From, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerLegs.x, Config.MarkerLegs.y, Config.MarkerLegs.z, Config.MarkerLegs.r, Config.MarkerLegs.g, Config.MarkerLegs.b, Config.MarkerLegs.a, false, true, 2, Config.MarkerLegs.rotate, nil, nil, false)
							if distance < Config.MarkerLegs.x+0.5 then
								FastTravel(Config.TeleportsLegs[i].To, Config.TeleportsLegs[i].Heading)
							end
						end
					end
				end
			end
		end

		if not found then
			Citizen.Wait(2000)
		end
	end
end)

CreateThread(function()
	while ESX.PlayerData.job == nil do
		Wait(100)
	end
	local isShowingNotification = false
	while true do
		Wait(0)
		local sleep = true
		local inRange = false
		for i=1, #Config.Lifts, 1 do
			for j=1, #Config.Lifts[i], 1 do
				local lift = Config.Lifts[i][j]
				if #(lift.Coords - cacheCoords) < 8.0 then
					if not lift.Allow then
						sleep = false
						DrawMarker(Config.MarkerLift.type, lift.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerLegs.x, Config.MarkerLegs.y, Config.MarkerLegs.z, Config.MarkerLegs.r, Config.MarkerLegs.g, Config.MarkerLegs.b, Config.MarkerLegs.a, false, true, 2, Config.MarkerLegs.rotate, nil, nil, false)
						if #(lift.Coords - cacheCoords) < 1.0 then
							inRange = true
							exports["esx_hud"]:helpNotification('Naciśnij', 'E', 'aby wejść w interakcje')
							if IsControlJustPressed(0, 38) then
								OpenLiftMenu(i, j)
							end
						end
					else
						if lift.Allow[ESX.PlayerData.job.name] then
							sleep = false
							DrawMarker(Config.MarkerLift.type, lift.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerLegs.x, Config.MarkerLegs.y, Config.MarkerLegs.z, Config.MarkerLegs.r, Config.MarkerLegs.g, Config.MarkerLegs.b, Config.MarkerLegs.a, false, true, 2, Config.MarkerLegs.rotate, nil, nil, false)
							if #(lift.Coords - cacheCoords) < 1.0 then
								inRange = true
								exports["esx_hud"]:helpNotification('Naciśnij', 'E', 'aby wejść w interakcje')
								if IsControlJustPressed(0, 38) then
									OpenLiftMenu(i, j)
								end
							end
						end
					end
				end
			end
		end
		if not inRange and isShowingNotification then
			exports["esx_hud"]:hideHelpNotification()
			isShowingNotification = false
		elseif inRange then
			isShowingNotification = true
		end
		if sleep then
			if ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'lift_menu') then
				ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'lift_menu')
			end
			Wait(500)
		end
	end
end)
