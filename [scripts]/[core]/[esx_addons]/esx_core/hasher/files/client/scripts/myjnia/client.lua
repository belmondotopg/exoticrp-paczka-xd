local esx_hud = exports.esx_hud
local libCache = lib.onCache
local cacheVehicle = cache.vehicle

libCache('vehicle', function(vehicle)
	cacheVehicle = vehicle
end)

local function DrawText3D(x, y, z, text)
	local size = 0.35
	SetTextScale(size, size)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextCentre(1)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	local _, _x, _y = World3dToScreen2d(x, y, z)
	DrawText(_x, _y)
end

local vehicleWashStation = {
	vec3(26.5906, -1392.0261, 28.3634),
	vec3(-699.6325, -932.7043, 18.0139),
	vec3(1361.71, 3591.81, 34.02),
	vec3(2524.51, 4195.47, 39.05),
	vec3(1182.101, 2639.3433, 36.77),
	vec3(103.28, 6623.14, 30.9)
}

local BlipStatus = false
local Blips = {}

local function LoadBlips()
	for i = 1, #vehicleWashStation do
		local garageCoords = vehicleWashStation[i]
		local stationBlip = AddBlipForCoord(garageCoords)
		
		SetBlipSprite(stationBlip, 100)
		SetBlipColour(stationBlip, 11)
		SetBlipAsShortRange(stationBlip, true)
		SetBlipScale(stationBlip, 0.7)

		Blips[#Blips + 1] = stationBlip
	end
end

local function RemoveBlips()
	for i = 1, #Blips do
		RemoveBlip(Blips[i])
	end

	Blips = {}
end

lib.onCache("vehicle", function(value)
	if not BlipStatus and value then
		LoadBlips()
		BlipStatus = true
	elseif BlipStatus and not value then
		RemoveBlips()
		BlipStatus = false
	end
end)

Citizen.CreateThread(function()
	for k, v in pairs(vehicleWashStation) do
		local point = lib.points.new(v, 20)

		function point:nearby()
			if not cacheVehicle then
				return
			end

			if self.currentDistance < 6 then
				DrawText3D(self.coords.x, self.coords.y, self.coords.z + 0.5, 'Naciśnij ~r~[E] ~w~aby umyć swój pojazd')

				if self.currentDistance < 2 and IsControlJustReleased(0, 38) then
					ESX.TriggerServerCallback('esx_core:onCheckMoney', function(hasEnoughMoney)
						if not hasEnoughMoney then
							ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (1.000$)')
							return
						end

						if esx_hud:progressBar({
							duration = 10,
							label = 'Mycie pojazdu...',
							useWhileDead = false,
							canCancel = true,
							disable = {
								car = true,
								move = true,
								combat = true,
								mouse = false,
							},
							anim = {},
							prop = {},
						}) then
							FreezeEntityPosition(cacheVehicle, false)
							SetVehicleDirtLevel(cacheVehicle, 0.0)
							ESX.ShowNotification('Pojazd został umyty!')
						else
							ESX.ShowNotification('Anulowano!')
						end
					end, 'localmechanic')
				end
			end
		end
	end
end)