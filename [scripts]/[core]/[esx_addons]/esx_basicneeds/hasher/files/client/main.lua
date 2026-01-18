local esx_core = exports.esx_core
local esx_hud = exports.esx_hud

local ped = PlayerPedId()
local cache = {
	ped = ped,
	coords = ped ~= 0 and GetEntityCoords(ped) or vector3(0, 0, 0),
	playerId = PlayerId()
}

LocalPlayer.state:set('OnKawa', false, true)
LocalPlayer.state:set('IsDrunk', false, false)

local playerNotified = {
	thirst = false,
	hunger = false
}

local DrunkTriggered = false
local DrunkLevel = -1
local kawaTimer = nil

local FirstPersonZones = {
	vec3(-880.6823, 7624.5420, 41.8813),
}

lib.onCache('ped', function(ped)
	cache.ped = ped
end)

lib.onCache('coords', function(coords)
	cache.coords = coords
end)

lib.onCache('playerId', function(playerId)
	cache.playerId = playerId
end)

local function IsFirstPersonZone(coords)
	if not coords then return false end
	for i = 1, #FirstPersonZones do
		if #(FirstPersonZones[i] - coords) <= 200.0 then
			return true
		end
	end
	return false
end

local function GetStatusFromData(data, name)
	for i = 1, #data do
		if data[i].name == name then
			return data[i]
		end
	end
	return nil
end

AddEventHandler('esx_basicneeds:resetStatus', function()
	TriggerEvent('esx_status:set', 'hunger', 500000)
	TriggerEvent('esx_status:set', 'thirst', 500000)
	TriggerEvent('esx_status:set', 'drunk', 0)
end)

RegisterNetEvent('esx_basicneeds:healPlayer', function()
	SetEntityHealth(cache.ped, 200)
	TriggerEvent('esx_status:set', 'hunger', 500000)
	TriggerEvent('esx_status:set', 'thirst', 500000)
	TriggerEvent('esx_status:set', 'drunk', 0)
end)

AddEventHandler('esx_status:loaded', function()
	TriggerEvent('esx_status:registerStatus', 'hunger', 1000000, {255, 210, 0}, true, function(status)
		if not LocalPlayer.state.IsDead and not IsFirstPersonZone(cache.coords) then
			status.remove(222)
		end
	end)

	TriggerEvent('esx_status:registerStatus', 'thirst', 1000000, {0, 198, 255}, true, function(status)
		if not LocalPlayer.state.IsDead and not IsFirstPersonZone(cache.coords) then
			status.remove(222)
		end
	end)

	TriggerEvent('esx_status:registerStatus', 'drunk', 0, {255, 0, 246}, false, function(status)
		if not LocalPlayer.state.IsDead then
			status.remove(20000)
		end
	end)
end)

AddEventHandler('esx_status:onTick', function(data)
	if LocalPlayer.state.IsDead then return end
	
	local hungerStatus = GetStatusFromData(data, 'hunger')
	local thirstStatus = GetStatusFromData(data, 'thirst')
	local drunkStatus = GetStatusFromData(data, 'drunk')
	
	if not hungerStatus or not thirstStatus then return end
	
	local prevHealth = GetEntityHealth(cache.ped)
	local health = prevHealth
	
	local hungerPercent = hungerStatus.percent or (hungerStatus.val / 10000)
	local thirstPercent = thirstStatus.percent or (thirstStatus.val / 10000)
	
	if hungerStatus.val == 0 then
		if prevHealth <= 50 then
			health = health - 8
		elseif prevHealth <= 150 then
			health = health - 5
		else
			health = health - 2
		end
	end
	
	if hungerPercent <= 10 and not playerNotified.hunger then
		playerNotified.hunger = true
		ESX.ShowNotification("Odczuwasz coraz większy głód, zjedz coś")
		SetTimeout(120000, function()
			playerNotified.hunger = false
		end)
	end
	
	if thirstStatus.val == 0 then
		if prevHealth <= 50 then
			health = health - 8
		elseif prevHealth <= 150 then
			health = health - 5
		else
			health = health - 2
		end
	end
	
	if thirstPercent <= 10 and not playerNotified.thirst then
		playerNotified.thirst = true
		ESX.ShowNotification("Odczuwasz coraz większe pragnienie, wypij coś")
		SetTimeout(120000, function()
			playerNotified.thirst = false
		end)
	end
	
	if hungerPercent >= 30 and thirstPercent >= 30 and health < 100 then
		local regenAmount
		if hungerPercent >= 70 and thirstPercent >= 70 then
			regenAmount = 1
		elseif hungerPercent >= 50 and thirstPercent >= 50 then
			regenAmount = 0.5
		else
			regenAmount = 0.25
		end
		health = math.min(100, health + regenAmount)
	end
	
	if health ~= prevHealth then
		local finalHealth = health <= 0 and 0 or math.floor(health)
		SetEntityHealth(cache.ped, finalHealth)
		
		if finalHealth <= 0 then
			SetEntityHealth(cache.ped, 0)
			ApplyDamageToPed(cache.ped, 999, false)
		end
	end
	
	if drunkStatus then
		ProcessDrunkStatus(drunkStatus.val)
	end
end)

function ProcessDrunkStatus(drunkVal)
	if drunkVal > 0 then
		local newDrunkLevel
		if drunkVal <= 100000 then
			newDrunkLevel = 0
		elseif drunkVal <= 200000 then
			newDrunkLevel = 1
		else
			newDrunkLevel = 2
		end
		
		if newDrunkLevel ~= DrunkLevel then
			DrunkLevel = newDrunkLevel
			
			if DrunkLevel == 0 then
				SetPedMovementClipset(cache.ped, "move_m@drunk@slightlydrunk", true)
			elseif DrunkLevel == 1 then
				SetPedMovementClipset(cache.ped, "move_m@drunk@moderatedrunk", true)
			elseif DrunkLevel == 2 then
				SetPedMovementClipset(cache.ped, "move_m@drunk@verydrunk", true)
			end
			
			if not LocalPlayer.state.IsDrunk then
				LocalPlayer.state:set('IsDrunk', true, false)
				SetTimecycleModifier("spectator5")
				SetPedMotionBlur(cache.ped, true)
				SetPedIsDrunk(cache.ped, true)
			end
		end
		
		if DrunkLevel == 2 and not DrunkTriggered then
			DrunkTriggered = true
			local chance = math.random(1, 100)
			local progressConfig = {
				duration = 5,
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = false,
					combat = true,
					mouse = false,
				},
				prop = {},
			}

			if chance > 60 then
				progressConfig.label = 'Wymiotowanie...'
				progressConfig.anim = {
					dict = 'timetable@tracy@ig_7@idle_a',
					clip = 'idle_a',
					flag = 1
				}
			else
				progressConfig.label = 'Zgon...'
				progressConfig.anim = {
					dict = 'missarmenian2',
					clip = 'drunk_loop',
					flag = 1
				}
			end

			if esx_hud:progressBar(progressConfig) then
				TriggerEvent('esx_status:set', 'drunk', 1200000)
			else
				ESX.ShowNotification('Anulowano.')
			end

			SetTimeout(120000, function()
				DrunkTriggered = false
			end)
		end
	elseif DrunkLevel ~= -1 then
		DrunkLevel = -1
		LocalPlayer.state:set('IsDrunk', false, false)
		ClearTimecycleModifier()
		ResetPedMovementClipset(cache.ped, 0)
		SetPedIsDrunk(cache.ped, false)
		SetPedMotionBlur(cache.ped, false)
	end
end

local function StartEnergyEffect(duration)
	if kawaTimer then
		kawaTimer = nil
	end
	
	LocalPlayer.state:set('OnKawa', true, true)
	SetRunSprintMultiplierForPlayer(cache.playerId, 1.2)
	
	kawaTimer = SetTimeout(duration, function()
		SetRunSprintMultiplierForPlayer(cache.playerId, 1.0)
		LocalPlayer.state:set('OnKawa', false, true)
		kawaTimer = nil
	end)
	
	CreateThread(function()
		while LocalPlayer.state.OnKawa do
			ResetPlayerStamina(cache.playerId)
			Wait(5000)
		end
	end)
end

RegisterNetEvent('esx_basicneeds:onEat', function(prop_name, addon, duration)
	if addon then return end
	
	CreateThread(function()
		local coords = cache.coords
		local prop = CreateObject(joaat(prop_name), coords.x, coords.y, coords.z + 0.2, true, true, true)
		local boneIndex = GetPedBoneIndex(cache.ped, 18905)
		AttachEntityToEntity(prop, cache.ped, boneIndex, 0.135, 0.02, 0.05, -30.0, -120.0, -60.0, 1, 1, 0, 1, 1, 1)

		local dict = 'mp_player_inteat@burger'
		lib.requestAnimDict(dict)
		TaskPlayAnim(cache.ped, dict, "mp_player_int_eat_burger", 18.0, 10.0, -1, 50, 0, false, false, false)
		
		-- Jeśli przekazano duration, animacja trwa przez cały czas progress bara
		local waitTime = duration and (duration * 1000) or 3000
		Wait(waitTime)
		
		ClearPedSecondaryTask(cache.ped)
		DeleteObject(prop)
		RemoveAnimDict(dict)
	end)
end)

RegisterNetEvent('esx_basicneeds:onDrink', function(prop_name, addon, duration)
	addon = addon or false
	prop_name = prop_name or 'prop_ld_flow_bottle'

	if not addon then
		CreateThread(function()
			local coords = cache.coords
			local prop = CreateObject(joaat(prop_name), coords.x, coords.y, coords.z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(cache.ped, 18905)
			AttachEntityToEntity(prop, cache.ped, boneIndex, 0.09, -0.065, 0.045, -100.0, 0.0, -25.0, 1, 1, 0, 1, 1, 1)

			local dict = 'mp_player_intdrink'
			lib.requestAnimDict(dict)
			TaskPlayAnim(cache.ped, dict, "loop_bottle", 18.0, 10.0, -1, 50, 0, false, false, false)
			
			-- Jeśli przekazano duration, animacja trwa przez cały czas progress bara
			local waitTime = duration and (duration * 1000) or 3000
			Wait(waitTime)
			
			ClearPedSecondaryTask(cache.ped)
			DeleteObject(prop)
			RemoveAnimDict(dict)
		end)
	elseif addon == "kawa" then
		local boneIndex = GetPedBoneIndex(cache.ped, 18905)
		ESX.Game.SpawnObject('prop_orang_can_01', {
			x = cache.coords.x,
			y = cache.coords.y,
			z = cache.coords.z - 3
		}, function(object)
			TriggerEvent('interact-sound_CL:PlayOnOne', 'redbull', 0.15)
			AttachEntityToEntity(object, cache.ped, boneIndex, 0.13, 0.030, 0.030, -100.0, 30.0, -25.0, 1, 1, 0, 1, 1, 1)
			
			local dict = 'mp_player_intdrink'
			lib.requestAnimDict(dict)
			TaskPlayAnim(cache.ped, dict, "loop_bottle", 18.0, 10.0, -1, 50, 0, false, false, false)
			
			-- Jeśli przekazano duration, animacja trwa przez cały czas progress bara
			local waitTime = duration and (duration * 1000) or 3000
			Wait(waitTime)
			
			ClearPedSecondaryTask(cache.ped)
			DeleteEntity(object)
			RemoveAnimDict(dict)
		end)
	elseif addon == "snus" then
		local dict = 'amb@code_human_wander_eating_donut@male@idle_a'
		lib.requestAnimDict(dict)
		TaskPlayAnim(cache.ped, dict, "idle_a", 18.0, 10.0, -1, 50, 0, false, false, false)
		
		-- Jeśli przekazano duration, animacja trwa przez cały czas progress bara
		local waitTime = duration and (duration * 1000) or 3000
		Wait(waitTime)
		
		ClearPedSecondaryTask(cache.ped)
		RemoveAnimDict(dict)
	elseif addon == "codeine" then
		ClearPedSecondaryTask(cache.ped)
		StartEnergyEffect(600000)
	end
end)

RegisterNetEvent('esx_basicneeds:clearAnimation', function()
	ClearPedSecondaryTask(cache.ped)
	ClearPedTasks(cache.ped)
end)

RegisterNetEvent('esx_basicneeds:startEnergyEffect', function(duration)
	StartEnergyEffect(duration or 600000)
end)

RegisterNetEvent('esx_basicneeds:takeSmoke', function(method, name)
	ESX.ShowNotification('Zapaliłeś/aś '..name..'.')
	if method then
		TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_SMOKING_POT", 0, true)
		SetTimeout(10000, function()
			ClearPedTasks(cache.ped)
		end)
		esx_core:DoBagniak(120000)
	else
		TaskStartScenarioInPlace(cache.ped, "WORLD_HUMAN_SMOKING", 0, true)
	end
end)

AddEventHandler('esx:onPlayerLogout', function()
	if kawaTimer then
		kawaTimer = nil
	end
	LocalPlayer.state:set('OnKawa', false, true)
	LocalPlayer.state:set('IsDrunk', false, false)
	DrunkLevel = -1
	DrunkTriggered = false
	playerNotified.hunger = false
	playerNotified.thirst = false
end)
