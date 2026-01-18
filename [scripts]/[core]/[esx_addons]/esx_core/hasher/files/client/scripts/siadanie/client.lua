
local sitting = false
local currentScenario = nil
local disableControls = false
local currentObj = nil
local currentChairCoords = nil

CreateThread(function()
	local sitables = {}
	for _, modelName in pairs(Config.Interactables) do
		local model = GetHashKey(modelName)
		table.insert(sitables, model)
	end
	Wait(100)
	exports.ox_target:addModel(sitables, {
		{
			icon = Config.Visual.icon,
			label = Config.Visual.label,
			event = "ox_sit:sit",
			Distance = Config.MaxDistance
		},
	})
end)

CreateThread(function()
	while true do
		if disableControls then
			DisableControlAction(0, 37, true)
			Wait(0)
		else
			Wait(500)
		end
	end
end)

function GetNearChair()
	local coords = cache.coords
	local closestObject = nil
	local closestDistance = Config.MaxDistance

	for i = 1, #Config.Interactables do
		local modelHash = GetHashKey(Config.Interactables[i])
		local object = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, modelHash, false, false, false)
		
		if object and object ~= 0 then
			local objectCoords = GetEntityCoords(object)
			local distance = #(coords - objectCoords)
			
			if distance < closestDistance then
				closestObject = object
				closestDistance = distance
			end
		end
	end

	return closestObject, (closestObject and closestDistance) or nil
end

function SitDown(object, data)
	if not object or object == 0 then
		return
	end

	if not HasEntityClearLosToEntity(cache.ped, object, 17) then
		return
	end

	disableControls = true
	currentObj = object
	FreezeEntityPosition(object, true)
	PlaceObjectOnGroundProperly(object)

	local pos = GetEntityCoords(object)
	local playerPos = cache.coords
	local objectCoords = vec3(pos.x, pos.y, pos.z)

	if currentChairCoords and currentChairCoords == objectCoords then
		lib.notify({
			title = Config.Visual.error,
			type = 'error'
		})
		disableControls = false
		return
	end

	lib.callback('ox_sit:getPlace', false, function(occupied)
		if occupied then
			lib.notify({
				title = Config.Visual.notification,
				type = 'info'
			})
			disableControls = false
		else
			currentChairCoords = objectCoords
			TriggerServerEvent('ox_sit:takePlace', objectCoords, currentObj)
			currentScenario = data.scenario
			
			local heading = GetEntityHeading(object) + 180.0
			local zOffset = pos.z + (playerPos.z - pos.z) / 2
			
			TaskStartScenarioAtPosition(cache.ped, currentScenario, pos.x, pos.y, zOffset, heading, 0, true, false)
			Wait(2500)
			
			if GetEntitySpeed(cache.ped) > 0 then
				ClearPedTasks(cache.ped)
				TaskStartScenarioAtPosition(cache.ped, currentScenario, pos.x, pos.y, zOffset, heading, 0, true, true)
			end
			
			sitting = true
		end
	end, objectCoords)
end

function StandUp()
	if not sitting or not currentScenario then
		return
	end

	ClearPedTasks(cache.ped)
	
	if currentObj and currentObj ~= 0 then
		FreezeEntityPosition(currentObj, false)
	end
	FreezeEntityPosition(cache.ped, false)
	
	if currentChairCoords then
		TriggerServerEvent('ox_sit:leavePlace', currentChairCoords)
	end
	
	currentScenario = nil
	sitting = false
	disableControls = false
	currentObj = nil
	currentChairCoords = nil
end

RegisterNetEvent("ox_sit:sit")
AddEventHandler("ox_sit:sit", function()
	if sitting and currentScenario and not IsPedUsingScenario(cache.ped, currentScenario) then
		StandUp()
		return
	end
	
	if sitting then
		return
	end
	
	local object, distance = GetNearChair()
	if object and distance and distance < Config.MaxDistance then
		local hash = GetEntityModel(object)
		for modelName, data in pairs(Config.Sitable) do
			if GetHashKey(modelName) == hash then
				SitDown(object, data)
				break
			end
		end
	end
end)

RegisterCommand('standupfromchair', function()
	StandUp()
end, false)

RegisterKeyMapping('standupfromchair', 'Wstań z krzesła', 'keyboard', 'X')