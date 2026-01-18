local config = require 'config'
local state = require 'client.state'
local utils = require 'client.utils'
local stations = lib.load 'data.stations'

local BlipStatus = true

-- local PlayerData = {["BlipStatus"] = true, ["Ped"] = PlayerPedId(), ["Coords"] = vec3(0,0,0), ["IsInVehicle"] = false}

-- CreateThread(function()
-- 	while (true) do 
-- 		Wait(10000)
-- 		PlayerData["Ped"] = PlayerPedId()
-- 		PlayerData["Coords"] = GetEntityCoords(PlayerData["Ped"])
-- 		PlayerData["IsInVehicle"] = IsPedInAnyVehicle(PlayerData["Ped"])

-- 		if (not PlayerData["BlipStatus"] and PlayerData["IsInVehicle"]) then 
-- 			PlayerData["BlipStatus"] = true
-- 			for station in pairs(stations) do utils.createBlip(station) end
-- 		end

-- 		if (PlayerData["BlipStatus"] and not PlayerData["IsInVehicle"]) then 
-- 			utils.removeBlips()
-- 			PlayerData["BlipStatus"] = false
-- 		end
-- 	end
-- end)

lib.onCache("vehicle", function(value, oldValue)

	if (not BlipStatus and value) then 
		for station in pairs(stations) do utils.createBlip(station) end
		BlipStatus = true
	end

	if (BlipStatus and not value) then 
		utils.removeBlips()
		BlipStatus = false
	end
end)

if config.ox_target and config.showBlips ~= 1 then return end


---@param point CPoint
local function onEnterStation(point)
	if config.showBlips == 1 and not point.blip then
		point.blip = utils.createBlip(point.coords)
	end
end

---@param point CPoint
local function nearbyStation(point)
	if point.currentDistance > 15 then return end

	local pumps = point.pumps
	local pumpDistance

	for i = 1, #pumps do
		local pump = pumps[i]
		pumpDistance = #(cache.coords - pump)

		if pumpDistance <= 3 then
			state.nearestPump = pump

			repeat
				local playerCoords = GetEntityCoords(cache.ped)
				pumpDistance = #(GetEntityCoords(cache.ped) - pump)

				if not state.isFueling then
					local vehicleInRange = state.lastVehicle ~= 0 and #(GetEntityCoords(state.lastVehicle) - playerCoords) <= 3
				end

				Wait(0)
			until pumpDistance > 3

			state.nearestPump = nil

			return
		end
	end
end

---@param point CPoint
local function onExitStation(point)
	if point.blip then
		point.blip = RemoveBlip(point.blip)
	end
end

for station, pumps in pairs(stations) do
	lib.points.new({
		coords = station,
		distance = 60,
		onEnter = onEnterStation,
		onExit = onExitStation,
		nearby = nearbyStation,
		pumps = pumps,
	})
end
