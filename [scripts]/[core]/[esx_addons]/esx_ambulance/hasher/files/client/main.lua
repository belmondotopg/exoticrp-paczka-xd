local esx_hud = exports.esx_hud

local Player = Player
local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local LocalPlayer = LocalPlayer
local restTimer = 300

LocalPlayer.state:set('AntiCL', nil, true)
LocalPlayer.state:set('BodyDamage', nil, true)

RegisterNetEvent("esx_ambulance:getRequest")
TriggerServerEvent("esx_ambulance:makeRequest")
AddEventHandler("esx_ambulance:getRequest", function(a, b, c, d, e, f, g)
    local Event1, Event2, Event3, Event4, Event5, Event6, Event7 = a, b, c, d, e, f, g

	local Keys = {
		["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
		["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
		["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
		["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 75, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
		["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
		["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
		["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
		["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
		["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
	}

	local cam = nil
	local angleY = 0.0
	local angleZ = 0.0
	local ox_inventory = exports.ox_inventory
	local TimerThreadId = nil
	local hasAlreadyEnteredMarker	= false
	local lastZone					= nil
	local CurrentAction				= nil
	local overwhelmed = false
	local CurrentActionMsg			= {}
	local CurrentActionData			= {}
	local CreateCamWithParams = CreateCamWithParams
	local GetGameplayCamFov = GetGameplayCamFov
	local SetCamActive = SetCamActive
	local RenderScriptCams = RenderScriptCams
	local ClearFocus = ClearFocus
	local DestroyCam = DestroyCam
	local GetDisabledControlNormal = GetDisabledControlNormal
	local GetShapeTestResult = GetShapeTestResult
	local GetPlayerServerId = GetPlayerServerId
	local GetPlayerPed = GetPlayerPed
	local GetIdOfThisThread = GetIdOfThisThread
	local GetCurrentResourceName = GetCurrentResourceName
	local SetPedArmour = SetPedArmour
	local GetEntityHealth = GetEntityHealth
	local IsControlPressed = IsControlPressed
	local DisableAllControlActions = DisableAllControlActions
	local EnableControlAction = EnableControlAction
	local ClearEntityLastDamageEntity = ClearEntityLastDamageEntity
	local HasAnimDictLoaded = HasAnimDictLoaded
	local IsEntityPlayingAnim = IsEntityPlayingAnim
	local ShakeGameplayCam = ShakeGameplayCam
	local IsEntityDead = IsEntityDead
	local RequestAnimDict = RequestAnimDict
	local IsPedInAnyVehicle = IsPedInAnyVehicle
	local GetPedCauseOfDeath = GetPedCauseOfDeath
	local GetPedSourceOfDeath = GetPedSourceOfDeath
	local HasEntityBeenDamagedByWeapon = HasEntityBeenDamagedByWeapon
	local TaskPlayAnim = TaskPlayAnim
	local SetEntityHealth = SetEntityHealth
	local GetPedMaxHealth = GetPedMaxHealth
	local TaskWarpPedIntoVehicle = TaskWarpPedIntoVehicle
	local SetVehicleNumberPlateText = SetVehicleNumberPlateText
	local ClearPedBloodDamage = ClearPedBloodDamage
	local SetEntityCoords = SetEntityCoords
	local SetEntityHeading = SetEntityHeading
	local SetGameplayCamRelativeHeading = SetGameplayCamRelativeHeading
	local GetEntityMaxHealth = GetEntityMaxHealth
	local SetPlayerInvincible = SetPlayerInvincible
	local NetworkResurrectLocalPlayer = NetworkResurrectLocalPlayer
	local DisableControlAction = DisableControlAction
	local IsDisabledControlPressed = IsDisabledControlPressed
	local SetVehicleExtra = SetVehicleExtra
	local SetVehicleLivery = SetVehicleLivery
	local DoesExtraExist = DoesExtraExist
	local IsVehicleExtraTurnedOn = IsVehicleExtraTurnedOn
	local SetEntityCanBeDamaged = SetEntityCanBeDamaged
	local SetPlayerCanUseCover = SetPlayerCanUseCover
	local SetEntityInvincible = SetEntityInvincible
	local StopAnimTask = StopAnimTask
	local RemoveAnimDict = RemoveAnimDict
	local EnableAllControlActions = EnableAllControlActions
	local GetGameTimer = GetGameTimer
	local IsControlJustReleased = IsControlJustReleased
	local ClearPedTasks = ClearPedTasks
	local AddBlipForCoord = AddBlipForCoord
	local SetBlipSprite = SetBlipSprite
	local SetBlipDisplay = SetBlipDisplay
	local SetBlipScale = SetBlipScale
	local SetBlipColour = SetBlipColour
	local SetBlipAsShortRange = SetBlipAsShortRange
	local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
	local AddTextComponentString = AddTextComponentString
	local EndTextCommandSetBlipName = EndTextCommandSetBlipName
	LocalPlayer.state:set('isCrawling', false, true)
	local hasBw = false
	local isProne = false
	local isCrawling = false
	local canCrawl = true
	local inAction = false
	local proneType = "onback"
	---Checks if the player should be able to crawl or not
	---@param playerPed number
	---@return boolean
	local function CanPlayerCrouchCrawl(playerPed)
		if IsPedJumping(playerPed) or IsPedFalling(playerPed) or IsPedInMeleeCombat(playerPed) or IsPedRagdoll(playerPed) or not hasBw or not canCrawl then
			return false
		end

		return true
	end

	---Load animation dictionary
	---@param dict string
	local function LoadAnimDict(dict)
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do
			Wait(0)
		end
	end

	
	local function startTimerThread()
		if timerThreadRunning then
			return
		end

		timerThreadRunning = true
		CreateThread(function()
			local timer = 300
			
			-- Wyślij początkową wartość od razu
			SendNUIMessage({
				action = "setTimer",
				value = timer
			})

			while hasBw or not canCrawl do
				Wait(1000)

				timer = timer - 1
				SendNUIMessage({
					action = "setTimer",
					value = timer
				})

				if timer == 0 then
					break
				end
			end

			timerThreadRunning = false
		end)
	end

	---Plays an animation on the ped. (Loads an unloads needed anim dict)
	---@param ped number
	---@param animDict string
	---@param animName string
	---@param blendInSpeed number|nil
	---@param blendOutSpeed number|nil
	---@param duration number|nil
	---@param startTime number|nil
	local function PlayAnimOnce(ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, startTime)
		LoadAnimDict(animDict)
		TaskPlayAnim(ped, animDict, animName, blendInSpeed or 2.0, blendOutSpeed or 2.0, duration or -1, 0, startTime or 0.0, false, false, false)
		RemoveAnimDict(animDict)
	end

	---Smoothly changes the ped's heading
	---@param ped number
	---@param amount number
	---@param time number ms
	local function ChangeHeadingSmooth(ped, amount, time)
		local times = math.abs(amount)
		local test = amount / times
		local wait = time / times

		for _i = 1, times do
			Wait(wait)
			SetEntityHeading(ped, GetEntityHeading(ped) + test)
		end
	end

	local haveTargets = false

	local function RefreshTargets()
		if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'ambulance' then
			if haveTargets then return end
			TriggerServerEvent('esx_ambulance:sync:addTargets')
			haveTargets = true
		end
	end
	
	local function DeleteTargets()
		TriggerServerEvent('esx_ambulance:sync:addTargets')
		haveTargets = false
	end
	
	local boatsBlips = {}

	local function addBoats()
		if #boatsBlips > 0 then
			for i = 1, #boatsBlips do
				RemoveBlip(boatsBlips[i])
			end
	
			boatsBlips = {}
		end

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
			for i = 1, #Config.Blips.Boats do
				local blip = AddBlipForCoord(Config.Blips.Boats[i].Pos)
		
				SetBlipSprite (blip, 404)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 0.7)
				SetBlipColour (blip, 38)
				SetBlipAsShortRange(blip, true)
		
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString("Port EMS")
				EndTextCommandSetBlipName(blip)
				table.insert(boatsBlips, blip)
			end
		end
	end

	local function removeBoats()
		if #boatsBlips > 0 then
			for i = 1, #boatsBlips do
				RemoveBlip(boatsBlips[i])
			end

			boatsBlips = {}
		end
	end

	RegisterNetEvent('esx:playerLoaded')
	AddEventHandler('esx:playerLoaded', function(xPlayer)
		ESX.PlayerData = xPlayer

		while not ESX.IsPlayerLoaded() do
			Citizen.Wait(200)
		end
	end)
	
	RegisterNetEvent('esx:setJob')
	AddEventHandler('esx:setJob', function(Job)
		ESX.PlayerData.job = Job

		if ESX.PlayerData.job.name == "ambulance" then
			Citizen.CreateThread(function()
				RefreshTargets()
				addBoats()
			end)
		else
			Citizen.CreateThread(function()
				DeleteTargets()
				removeBoats()
			end)
		end
	end)
	
	local libCache = lib.onCache
	local cachePed = cache.ped
	local cacheCoords = cache.coords
	local cachePlayerId = cache.playerId
	local cacheVehicle = cache.vehicle
	local timerThreadRunning = false
	
	libCache('ped', function(ped)
		cachePed = ped
	end)
	
	libCache('coords', function(coords)
		cacheCoords = coords
	end)
	
	libCache('playerId', function(playerId)
		cachePlayerId = playerId
	end)
	
	libCache('vehicle', function(vehicle)
		cacheVehicle = vehicle
	end)
	
	local function EndDeathCam()
		ClearFocus()
		RenderScriptCams(false, false, 0, true, false)
		DestroyCam(cam, false)
		cam = nil
	end

	local function RespawnPed(HospitalRespawn, isAdmin)
		LocalPlayer.state:set('IsDead', false, true)
		LocalPlayer.state:set('BodyDamage', nil, true)

		TriggerEvent('esx_hud:radio:addPlayerDead', false)

		SendNUIMessage({
			action = 'close',
		})

		hasBw = false
		canCrawl = true
		timerThreadRunning = false
		
		SetEntityCoords(cachePed, HospitalRespawn.x, HospitalRespawn.y, HospitalRespawn.z)
		SetEntityHeading(cachePed, GetEntityHeading(cachePed))
		SetGameplayCamRelativeHeading(GetEntityHeading(cachePed))
		
		if not isAdmin then
			SetEntityHealth(cachePed, 100)
		else
			SetEntityHealth(cachePed, GetEntityMaxHealth(cachePed))
		end

		NetworkResurrectLocalPlayer(HospitalRespawn.x, HospitalRespawn.y, HospitalRespawn.z, GetEntityHeading(cachePed), true, false)
		TriggerEvent('playerSpawned', HospitalRespawn.x, HospitalRespawn.y, HospitalRespawn.z, GetEntityHeading(cachePed))
		TriggerEvent('esx:onPlayerSpawn', HospitalRespawn.x, HospitalRespawn.y, HospitalRespawn.z)
		Citizen.Wait(100)
		SetPlayerInvincible(cachePlayerId, false)
		ClearPedBloodDamage(cachePed)

		if isAdmin then
			if IsPedCuffed(cachePed) then
				TriggerEvent('esx_police:HandcuffOnPlayer', cachePed)
				TriggerEvent('esx_police:unrestPlayerHandcuffs')
			end
		end

		LocalPlayer.state:set('AntiCL', nil, true)
		restTimer = 300

		EndDeathCam()
	end
	
	local function CleanPlayer()
		ClearPedBloodDamage(cachePed)
		ResetPedVisibleDamage(cachePed)
		ClearPedLastWeaponDamage(cachePed)
		ResetPedMovementClipset(cachePed, 0)
	end

	local function SetUniform(grade)
		CleanPlayer()

		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin.sex == 0 then
				if Config.Uniforms[grade].male ~= nil then
					TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[grade].male)
				else
					ESX.ShowNotification('Brak ubrań')
				end
			else
				if Config.Uniforms[grade].female ~= nil then
					TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[grade].female)
				else
					ESX.ShowNotification('Brak ubrań')
				end
			end
		end)
	end
	
	local function StartDeathCam()
		ClearFocus()
		local coords = GetEntityCoords(PlayerPedId())
		cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords, 0, 0, 0, GetGameplayCamFov())
		SetCamActive(cam, true)
		RenderScriptCams(true, true, 1000, true, false)
	end
	
	local function ProcessNewPosition()
		local mouseX = 0.0
		local mouseY = 0.0
		local coords = GetEntityCoords(PlayerPedId())
		
		if (IsInputDisabled(0)) then
			mouseX = GetDisabledControlNormal(1, 1) * 8.0
			mouseY = GetDisabledControlNormal(1, 2) * 8.0
		else
			mouseX = GetDisabledControlNormal(1, 1) * 1.5
			mouseY = GetDisabledControlNormal(1, 2) * 1.5
		end
	
		angleZ = angleZ - mouseX
		angleY = angleY + mouseY
		if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end
			
		local behindCam = {
			x = coords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (3.5 + 0.5),
			y = coords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (3.5 + 0.5),
			z = coords.z + ((Sin(angleY))) * (3.5 + 0.5)
		}
		local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, cachePed, 0)
		local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
		
		local maxRadius = 3.5
		if (hitBool and #(vec3(coords.x, coords.y, coords.z + 0.5) - vec3(hitCoords)) < 3.5 + 0.5) then
			maxRadius = #(vec3(coords.x, coords.y, coords.z + 0.5) - vec3(hitCoords))
		end
		
		local offset = {
			x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
			y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
			z = ((Sin(angleY))) * maxRadius
		}
		
		local pos = {
			x = coords.x + offset.x,
			y = coords.y + offset.y,
			z = coords.z + offset.z
		}
		return pos
	end
	
	local function ProcessCamControls()
		DisableFirstPersonCamThisFrame()
		local coords = GetEntityCoords(PlayerPedId())
		local newPos = ProcessNewPosition()
		SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
		SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
		
		PointCamAtCoord(cam, coords.x, coords.y, coords.z + 0.5)
	end
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1)
			if cam and LocalPlayer.state.IsDead then
				ProcessCamControls()
			else
				Citizen.Wait(2500)
			end
		end
	end)
	
	local function SendDistressSignal()	
		local playerCoords = GetEntityCoords(PlayerPedId())
		exports["lb-phone"]:SendCompanyMessage('ambulance', 'Ranny obywatel, potrzebna pomoc!', false)
		exports["lb-phone"]:SendCompanyCoords('ambulance', playerCoords, false)
		TriggerServerEvent('qf_mdt_ems/addDispatchAlertSV', playerCoords, 'Ranny obywatel!', 'Ranny obywatel, potrzebna pomoc!', '10-32', 'rgb(117, 28, 28)', '10')
	end
	
	local function StartDistressSignal()
		Citizen.CreateThread(function()
	
			local signal = 0
	
			while LocalPlayer.state.IsDead do
				Citizen.Wait(0)
	
				if overwhelmed then
					return
				else
					if signal < GetGameTimer() then
						if IsDisabledControlJustPressed(0, Keys['G']) and not LocalPlayer.state.IsHandcuffed then
							SendDistressSignal()
							signal = GetGameTimer() + 90000 * 4
							ESX.ShowNotification('Pomoc została wezwana!')
						end	
					end
				end
			end
		end)
	end
	
	local function StartDeathTimer()
		if TimerThreadId then
			TerminateThread(TimerThreadId)
		end
	
		local firstScreen = true
		Citizen.CreateThread(function()
			HasTimer = true
			Citizen.Wait(1000)
			HasTimer = false
			firstScreen = false
		end)
		Citizen.CreateThread(function()
			TimerThreadId = GetIdOfThisThread()
	
			while firstScreen do
				Citizen.Wait(0)
				if overwhelmed then
					return
				else
					hasBw = true
					
					startTimerThread()
			
					Wait(200)
			
					SendNUIMessage({
						action = 'setVisibleCrawling',
						crawling = true,
					})

					Wait(200)

					SendNUIMessage({
						action = 'open',
					})

					return
				end
			end
		end)
	end
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(2)
			if LocalPlayer.state.IsDead then
				while IsPauseMenuActive() do
					Citizen.Wait(500)
				end
				DisableAllControlActions(0)
				DisableAllControlActions(2)
				EnableControlAction(0, Keys['G'], true)
				EnableControlAction(0, Keys['T'], true)
				EnableControlAction(0, Keys['E'], true)
				EnableControlAction(0, Keys['F5'], true)
				EnableControlAction(0, Keys['N'], true)
				EnableControlAction(0, Keys['HOME'], true)
				EnableControlAction(0, Keys['DELETE'], true)
				EnableControlAction(0, Keys['H'], true)
				EnableControlAction(0, 21, true)
				EnableControlAction(0, Keys['Z'], true)
				EnableControlAction(0, 27, true)
				EnableControlAction(0, 173, true)

				if isProne then
					EnableControlAction(0, 32, true)
					EnableControlAction(0, 33, true)
					EnableControlAction(0, 34, true)
					EnableControlAction(0, 35, true)
				end
			else
				Citizen.Wait(700)
			end
		end
	end)

	local function DeathFunc()
		ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 2.0)
		TriggerEvent('ox_inventory:disarm')

		Citizen.CreateThread(function ()
			lib.requestAnimDict('dead')

			local weapon = GetPedCauseOfDeath(cachePed)
			local sourceofdeath = GetPedSourceOfDeath(cachePed)
			local damagedbycar = false

			if weapon == 0 and sourceofdeath == 0 and HasEntityBeenDamagedByWeapon(cachePed, `WEAPON_RUN_OVER_BY_CAR`, 0) then
				damagedbycar = true
			end

			if not IsPedInAnyVehicle(cachePed, false) then
				SetEntityCoords(cachePed, cacheCoords)
			end

			SetPlayerInvincible(cachePlayerId, true)
			SetPlayerCanUseCover(cachePlayerId, false)
	
			Citizen.Wait(500)
			
			NetworkResurrectLocalPlayer(cacheCoords.x, cacheCoords.y, cacheCoords.z, 0.0, true, false)

			if weapon == `WEAPON_UNARMED` or ((weapon == `WEAPON_RUN_OVER_BY_CAR` or damagedbycar) and sourceofdeath ~= cachePed) or weapon == `WEAPON_NIGHTSTICK` or weapon == `WEAPON_BAT` then
				overwhelmed = true

				SendNUIMessage({
					action = 'close',
				})

				hasBw = false

				TriggerServerEvent(Event3, 1)

				if overwhelmed then LocalPlayer.state:set('IsConcussed', true, true) end

				local bar = esx_hud:progressBar({
					duration = 10,
					label = 'Odzyskiwanie przytomności',
					useWhileDead = true,
					allowCuffed = true,
					canCancel = false,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'dead',
						clip = 'dead_a',
						flag = 1
					},
					prop = {},
				})
	
				if bar then 
					RespawnPed(cacheCoords)
					TriggerEvent('esx_ambulance:onTargetRevive')
					ClearPedTasks(cachePed)
					ESX.ShowNotification('Czujesz się lepiej.')
					LocalPlayer.state:set('IsConcussed', false, true)
					SetEntityHealth(cachePed, 50)
					SendNUIMessage({
						action = 'close',
					})
					timerThreadRunning = false
				else 
					ESX.ShowNotification('Anulowano.')
				end
			end

			while LocalPlayer.state.IsDead do
				SetPauseMenuActive(false)

				if not IsPedInAnyVehicle(cachePed, false) then
					if not IsEntityPlayingAnim(cachePed, 'dead', 'dead_a', 3) and not isProne and not LocalPlayer.state.isDeadDragging then
						TaskPlayAnim(cachePed, 'dead', 'dead_a', 1.0, 1.0, -1, 2, 0, 0, 0, 0)
					end

					-- DisableControlAction(0, 25, true)

					if not canCrawl then
						SetEntityInvincible(cachePed, true)
						SetEntityCanBeDamaged(cachePed, false)

						if IsEntityDead(cachePed) then
							SetPlayerInvincible(cachePlayerId, true)
							SetPlayerCanUseCover(cachePlayerId, false)
							SetEntityHealth(cachePed, 200)
							NetworkResurrectLocalPlayer(cacheCoords, 0.0, false, false)
						end
					end
				end
	
				Citizen.Wait(0)
			end

			canCrawl = true
			overwhelmed = false
			hasBw = false
			timerThreadRunning = false
			SetPlayerInvincible(cachePlayerId, false)
			SetPlayerCanUseCover(cachePlayerId, true)
			SetEntityInvincible(cachePed, false)
			SetEntityCanBeDamaged(cachePed, true)
			SetPauseMenuActive(false)
			StopAnimTask(cachePed, 'dead', 'dead_a', 4.0)
			RemoveAnimDict('dead')
			EnableAllControlActions(0)
		end)

		Citizen.CreateThread(function ()
			while LocalPlayer.state.IsDead do
				Citizen.Wait(1000)
				
				restTimer = restTimer - 1
				
				if restTimer >= 120 then
					if not LocalPlayer.state.AntiCL then
						LocalPlayer.state:set('AntiCL', true, true)
					end
				else
					if LocalPlayer.state.AntiCL then
						LocalPlayer.state:set('AntiCL', nil, true)
					end
				end
			end
		end)
	end
	
	local function OnPlayerDeath()
		canCrawl = true
		if not LocalPlayer.state.IsDead then
			LocalPlayer.state:set('IsDead', true, true)
			TriggerEvent('esx_hud:radio:addPlayerDead', true)
			StartDeathCam()
			ESX.UI.Menu.CloseAll()
			TriggerServerEvent(Event3, 1)
			
			timerThreadRunning = false
			hasBw = false
			
			StartDeathTimer()
			StartDistressSignal()
			DeathFunc()
			
			local propId = GetPedPropIndex(cachePed)
			
			if propId == 39 then
				ClearPedProp(cachePed)
				ESX.ShowNotification('Utracono kask z powodu obezwładnienia')
			end
			
			if GetPedArmour(cachePed) > 0 then
				SetPedComponentVariation(cachePed, 9, 0, 0, 0)
				ESX.ShowNotification('Utracono kamizelkę z powodu obezwładnienia')
			end
		else
			SetEntityHealth(cachePed, GetPedMaxHealth(cachePed))
		end	

		TriggerEvent("esx_hud/hideHud2", false)
	end
	
	AddEventHandler('esx:onPlayerDeath', function()
		OnPlayerDeath()
	end)

	RegisterNetEvent('esx:onPlayerIsDeath', function ()
		if LocalPlayer.state.IsDead then return end

		while not ESX.IsPlayerLoaded() do
			Citizen.Wait(200)
		end

		lib.callback("esx_ambulance:getStatus", false, function(has)
			if has then
				Citizen.Wait(3000)
				OnPlayerDeath()
			end
		end)
	end)
	
	local UniformsData = {}
	local PreviewAppearance = nil
	local PreviewTimer = nil

	local function CancelPreview()
		if PreviewTimer then
			ESX.ClearTimeout(PreviewTimer)
			PreviewTimer = nil
		end
		
		if PreviewAppearance then
			TriggerEvent('skinchanger:loadSkin', PreviewAppearance)
			PreviewAppearance = nil
			ESX.ShowNotification("Anulowano podgląd")
		end
	end

	local function PreviewUniform(name, category)
		if not UniformsData[category] or not UniformsData[category][name] then
			ESX.ShowNotification('Brak tego munduru w kategorii '..category)
			return
		end

		local uniform = UniformsData[category][name]

		lib.callback("qf_skinmenu/getPlayerAppearance", false, function(currentAppearance)
			if not currentAppearance then
				ESX.ShowNotification("Błąd przy pobieraniu wyglądu gracza")
				return
			end

			if not PreviewAppearance then
				PreviewAppearance = {}
				for k, v in pairs(currentAppearance) do
					PreviewAppearance[k] = v
				end
			end

			local isMale = currentAppearance.model == "mp_m_freemode_01"
			local uniformData = isMale and uniform.male or uniform.female

			if not uniformData or next(uniformData) == nil then
				ESX.ShowNotification(isMale and 'Brak ubrań dla mężczyzn' or 'Brak ubrań dla kobiet')
				return
			end

			local previewAppearance = {}
			for k, v in pairs(currentAppearance) do
				previewAppearance[k] = v
			end
			
			if uniformData.components then
				previewAppearance.components = {}
				for k, v in pairs(uniformData.components) do
					previewAppearance.components[k] = v
				end
			end
			
			if uniformData.props then
				previewAppearance.props = {}
				for k, v in pairs(uniformData.props) do
					previewAppearance.props[k] = v
				end
			end
			
			CleanPlayer()
			TriggerEvent('skinchanger:loadSkin', previewAppearance)
			ESX.ShowNotification("Podgląd munduru - naciśnij ESC aby anulować (anuluje się automatycznie za 15 sekund)")
			
			if PreviewTimer then
				ESX.ClearTimeout(PreviewTimer)
			end
			
			PreviewTimer = ESX.SetTimeout(15000, function()
				CancelPreview()
			end)
		end)
	end

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if PreviewAppearance then
				if IsControlJustPressed(0, 322) then
					CancelPreview()
				end
			else
				Citizen.Wait(500)
			end
		end
	end)

	local function SetUniform(name, category)
		CleanPlayer()

		if PreviewTimer then
			ESX.ClearTimeout(PreviewTimer)
			PreviewTimer = nil
		end
		PreviewAppearance = nil

		if not UniformsData[category] or not UniformsData[category][name] then
			ESX.ShowNotification('Brak tego munduru w kategorii '..category)
			return
		end

		local uniform = UniformsData[category][name]

		lib.callback("qf_skinmenu/getPlayerAppearance", false, function(currentAppearance)
			if not currentAppearance then
				ESX.ShowNotification("Błąd przy pobieraniu wyglądu gracza")
				return
			end

			local isMale = currentAppearance.model == "mp_m_freemode_01"
			local uniformData = isMale and uniform.male or uniform.female

			if not uniformData or next(uniformData) == nil then
				ESX.ShowNotification(isMale and 'Brak ubrań dla mężczyzn' or 'Brak ubrań dla kobiet')
				return
			end

			local newAppearance = {}
			for k, v in pairs(currentAppearance) do
				newAppearance[k] = v
			end
			
			if uniformData.components then
				newAppearance.components = {}
				for k, v in pairs(uniformData.components) do
					newAppearance.components[k] = v
				end
			end
			
			if uniformData.props then
				newAppearance.props = {}
				for k, v in pairs(uniformData.props) do
					newAppearance.props[k] = v
				end
			end

			TriggerEvent('skinchanger:loadSkin', newAppearance)
			
			Citizen.Wait(500)
			TriggerServerEvent("qf_skinmenu/saveAppearance", newAppearance)
			ESX.ShowNotification("Mundur został ubrany")
		end)
	end

	local function LoadUniformsFromServer()
		ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
			UniformsData = data or {}
		end)
	end

	local function OpenCloakroomMenu()
		ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
			UniformsData = data or {}
			
			local xPlayer = ESX.PlayerData
			local isAmbulance = xPlayer.job.name == "ambulance"
			local isManagement = isAmbulance and xPlayer.job.grade >= 10

			local categoryPriority = {
				["Służbowe"] = 1,
				["SMU"] = 2,
				["WSR"] = 3,
				["Dodatkowe"] = 4
			}

			local categories = {}
			local customCategories = {}
			
			for category, uniforms in pairs(UniformsData) do
				local catData = {
					label = category,
					value = category,
					priority = categoryPriority[category] or 999
				}
				
				if categoryPriority[category] then
					table.insert(categories, catData)
				else
					table.insert(customCategories, catData)
				end
			end

			table.sort(categories, function(a, b)
				return a.priority < b.priority
			end)

			table.sort(customCategories, function(a, b)
				return a.label < b.label
			end)

			local allCategories = {}
			for i=1, #categories, 1 do
				table.insert(allCategories, categories[i])
			end
			for i=1, #customCategories, 1 do
				table.insert(allCategories, customCategories[i])
			end

			if #allCategories == 0 and not isManagement then
				ESX.ShowNotification("Brak dostępnych ubrań w szatni")
				return
			end

			local options = {}
			for i=1, #allCategories, 1 do
				local el = allCategories[i]
				table.insert(options, {
					title = el.label,
					onSelect = function()
						local uniforms = UniformsData[el.value]
						if not uniforms then
							ESX.ShowNotification("Brak ubrań w kategorii: " .. el.label)
							return
						end
						
						local uniformOptions = {}
						for name, uniformData in pairs(uniforms) do
							local displayName = name
							if uniformData.min_grade and uniformData.min_grade > 0 then
								displayName = displayName .. " [Grade " .. uniformData.min_grade .. "+]"
							end
							
							local menuId = "uniform_" .. name .. "_" .. el.value
							menuId = menuId:gsub("[^%w_]", "_")
							
							local uniformSubOptions = {
								{
									title = "👁️ Podgląd",
									onSelect = function()
										PreviewUniform(name, el.value)
									end
								},
								{
									title = "✅ Ubierz",
									onSelect = function()
										SetUniform(name, el.value)
										PreviewAppearance = nil
									end
								}
							}
							
							lib.registerContext({
								id = menuId,
								title = name,
								menu = "uniforms_" .. el.value,
								options = uniformSubOptions
							})
							
							table.insert(uniformOptions, {
								title = displayName,
								description = "Kliknij aby zobaczyć opcje",
								menu = menuId,
								arrow = true
							})
						end
						
						if #uniformOptions == 0 then
							ESX.ShowNotification("Brak ubrań w kategorii: " .. el.label)
							return
						end
						lib.registerContext({id = "uniforms_"..el.value, title = el.label, options = uniformOptions})
						lib.showContext("uniforms_"..el.value)
					end
				})
			end

			if isManagement then
				table.insert(options, {
					title = "================",
					disabled = true,
					readOnly = true
				})
				table.insert(options, {
					title = "Zarządzanie ubraniami",
					onSelect = function()
						OpenManagementMenu()
					end
				})
			end

			lib.registerContext({id = "cloakroom", title = "Szatnia", options = options})
			lib.showContext("cloakroom")
		end)
	end

	function OpenManagementMenu()
		local options = {
			{title = "Dodaj mundur", onSelect = function() AddUniformMenu() end},
			{title = "Kopiuj mundur", onSelect = function() CopyUniformMenu() end},
			{title = "Zmień nazwę munduru", onSelect = function() RenameUniformMenu() end},
			{title = "Ustaw ograniczenia dostępu", onSelect = function() SetMinGradeMenu() end},
			{title = "Usuń mundur", onSelect = function() RemoveUniformMenu() end}
		}
		lib.registerContext({id = "management_menu", title = "Zarządzanie ubraniami", options = options})
		lib.showContext("management_menu")
	end

	function AddUniformMenu()
		ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(uniformsData)
			local existingCategories = {}
			local categorySet = {}
			
			if uniformsData then
				for category, _ in pairs(uniformsData) do
					if not categorySet[category] then
						table.insert(existingCategories, {value = category, label = category})
						categorySet[category] = true
					end
				end
			end
			
			local defaultCategories = {
				{value = "Służbowe", label = "Służbowe"},
				{value = "Dodatkowe", label = "Dodatkowe"},
				{value = "SMU", label = "SMU"},
				{value = "WSR", label = "WSR"}
			}
			
			for _, cat in ipairs(defaultCategories) do
				if not categorySet[cat.value] then
					table.insert(existingCategories, cat)
					categorySet[cat.value] = true
				end
			end
			
			table.insert(existingCategories, {value = "__NEW__", label = "➕ Nowa kategoria"})
			
			local categoryOptions = {}
			for _, cat in ipairs(existingCategories) do
				table.insert(categoryOptions, {value = cat.value, label = cat.label})
			end
			
			local input = lib.inputDialog('Dodaj mundur', {
				{type = 'input', label = 'Nazwa nowego munduru', required = true, minLength = 1},
				{type = 'select', label = 'Kategoria', options = categoryOptions, required = true},
				{type = 'number', label = 'Minimalny grade (0 = brak ograniczeń)', required = false, min = 0, max = 20, default = 0}
			})

			if not input or not input[1] or input[1] == '' or not input[2] then
				return
			end

			local uniformName = input[1]
			local selectedCategory = input[2]
			local finalCategory = selectedCategory
			local minGrade = input[3] and math.floor(input[3]) or 0

			if selectedCategory == "__NEW__" then
				local categoryInput = lib.inputDialog('Nowa kategoria', {
					{type = 'input', label = 'Nazwa nowej kategorii', required = true, minLength = 1}
				})
				
				if not categoryInput or not categoryInput[1] or categoryInput[1] == '' then
					return
				end
				
				finalCategory = categoryInput[1]
			end

			lib.callback("qf_skinmenu/getPlayerAppearance", false, function(currentAppearance)
				if not currentAppearance then
					ESX.ShowNotification("Błąd przy pobieraniu wyglądu gracza")
					return
				end

				local isMale = currentAppearance.model == "mp_m_freemode_01"
				
				local uniformData = {
					name = uniformName,
					category = finalCategory,
					male = isMale and currentAppearance or {},
					female = not isMale and currentAppearance or {},
					min_grade = minGrade
				}

				ESX.TriggerServerCallback('vwk/ambulance/addUniform', function(success)
					if success then
						ESX.ShowNotification("Dodano mundur: "..uniformName.." (kategoria: "..finalCategory..")")
						ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
							UniformsData = data or {}
							ESX.ShowNotification("Mundur został dodany i jest dostępny w szatni")
						end)
					else
						ESX.ShowNotification("Błąd przy dodawaniu munduru")
					end
				end, uniformData)
			end)
		end)
	end

	function RenameUniformMenu()
		ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
			UniformsData = data or {}
			
			local options = {}
			for category, uniforms in pairs(UniformsData) do
				for name, _ in pairs(uniforms) do
					table.insert(options, {
						title = name,
						description = "Kategoria: " .. category,
						onSelect = function()
							local input = lib.inputDialog('Zmień nazwę munduru', {
								{type = 'input', label = 'Nowa nazwa munduru', required = true, minLength = 1, default = name}
							})
							
							if not input or not input[1] or input[1] == '' then
								return
							end
							
							local newName = input[1]
							
							if newName == name then
								ESX.ShowNotification("Nowa nazwa jest taka sama jak obecna")
								return
							end
							
							ESX.TriggerServerCallback('vwk/ambulance/renameUniform', function(success)
								if success then
									ESX.ShowNotification("Zmieniono nazwę munduru z \""..name.."\" na \""..newName.."\"")
									ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
										UniformsData = data or {}
									end)
								else
									ESX.ShowNotification("Błąd przy zmianie nazwy munduru (możliwe że nazwa już istnieje)")
								end
							end, name, newName)
						end
					})
				end
			end
			
			if #options == 0 then
				ESX.ShowNotification("Brak mundurów do zmiany nazwy")
				return
			end
			
			lib.registerContext({id = "rename_uniforms", title = "Zmień nazwę munduru", options = options})
			lib.showContext("rename_uniforms")
		end)
	end

	function CopyUniformMenu()
		ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
			UniformsData = data or {}
			
			local options = {}
			for category, uniforms in pairs(UniformsData) do
				for name, _ in pairs(uniforms) do
					table.insert(options, {
						title = name,
						description = "Kategoria: " .. category,
						onSelect = function()
							local input = lib.inputDialog('Kopiuj mundur', {
								{type = 'input', label = 'Nazwa nowego munduru', required = true, minLength = 1},
								{type = 'input', label = 'Kategoria (opcjonalnie, zostaw puste aby użyć tej samej)', required = false}
							})
							
							if not input or not input[1] or input[1] == '' then
								return
							end
							
							local newName = input[1]
							local newCategory = input[2] and input[2] ~= '' and input[2] or category
							
							ESX.TriggerServerCallback('vwk/ambulance/copyUniform', function(success)
								if success then
									ESX.ShowNotification("Skopiowano mundur: "..name.." jako "..newName)
									ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
										UniformsData = data or {}
									end)
								else
									ESX.ShowNotification("Błąd przy kopiowaniu munduru (możliwe że nazwa już istnieje)")
								end
							end, name, newName, newCategory)
						end
					})
				end
			end
			
			if #options == 0 then
				ESX.ShowNotification("Brak mundurów do skopiowania")
				return
			end
			
			lib.registerContext({id = "copy_uniforms", title = "Kopiuj mundur", options = options})
			lib.showContext("copy_uniforms")
		end)
	end

	function SetMinGradeMenu()
		ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
			UniformsData = data or {}
			
			local options = {}
			for category, uniforms in pairs(UniformsData) do
				for name, uniformData in pairs(uniforms) do
					local minGrade = uniformData.min_grade or 0
					table.insert(options, {
						title = name,
						description = "Kategoria: " .. category .. " | Obecne ograniczenie: Grade " .. minGrade .. "+",
						onSelect = function()
							local input = lib.inputDialog('Ustaw minimalny grade', {
								{type = 'number', label = 'Minimalny grade (0 = brak ograniczeń)', required = true, min = 0, max = 20, default = minGrade}
							})
							
							if not input or not input[1] then
								return
							end
							
							local newMinGrade = math.floor(input[1])
							
							ESX.TriggerServerCallback('vwk/ambulance/setUniformMinGrade', function(success)
								if success then
									ESX.ShowNotification("Ustawiono minimalny grade: "..newMinGrade.." dla munduru: "..name)
									ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
										UniformsData = data or {}
										SetMinGradeMenu()
									end)
								else
									ESX.ShowNotification("Błąd przy ustawianiu ograniczenia")
								end
							end, name, newMinGrade)
						end
					})
				end
			end
			
			if #options == 0 then
				ESX.ShowNotification("Brak mundurów")
				return
			end
			
			lib.registerContext({id = "mingrade_uniforms", title = "Ustaw ograniczenia dostępu", options = options})
			lib.showContext("mingrade_uniforms")
		end)
	end

	function RemoveUniformMenu()
		local options = {}
		for category, uniforms in pairs(UniformsData) do
			for name, _ in pairs(uniforms) do
				table.insert(options, {title = name, onSelect = function()
					ESX.TriggerServerCallback('vwk/ambulance/removeUniform', function(success)
						if success then
							ESX.ShowNotification("Usunięto mundur: "..name)
							ESX.TriggerServerCallback('vwk/ambulance/getUniforms', function(data)
								UniformsData = data or {}
							end)
						else
							ESX.ShowNotification("Błąd przy usuwaniu munduru")
						end
					end, name)
				end})
			end
		end
		lib.registerContext({id = "remove_uniforms", title = "Usuń mundur", options = options})
		lib.showContext("remove_uniforms")
	end

	local function OpenCloakroomMenuPrivate()
		CleanPlayer()
		exports.qf_skinmenu:openClothingShop()
	end

	local function SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, extrason, extrasoff, bulletproof, tint, wheel, tuning, plate)
		local t = {
			modArmor        = 4,
			modTurbo        = true,
			modXenon        = true,
			windowTint      = 0,
			dirtLevel       = 0,
			color1			= 0,
			color2			= 0
		}
		
		if tuning then
			t.modEngine = 3
			t.modBrakes = 2
			t.modTransmission = 2
			t.modSuspension = 3
		end
	
		if offroad then
			t.wheelColor = 5
			t.wheels = 4
			t.modFrontWheels = 17
		end
	
		if wheelsxd then
			t.wheels = 1
			t.modFrontWheels = 5
		end
	
		if bulletproof then
			t.bulletProofTyre = true
		end
	
		if color then
			t.color1 = color
		end
	
		if tint then
			t.windowTint = 0
		end
	
		if wheel then
			t.wheelColor = wheel.color
			t.wheels = wheel.group
			t.modFrontWheels = wheel.type
		end
		
		ESX.Game.SetVehicleProperties(vehicle, t)
	
		if #extrason > 0 then
			for i = 1, #extrason do
				SetVehicleExtra(vehicle, extrason[i], false)
			end
		end
		
		if #extrasoff > 0 then
			for i = 1, #extrasoff do
				SetVehicleExtra(vehicle, extrasoff[i], true)
			end
		end
		  
		if livery then
			SetVehicleLivery(vehicle, livery)
		end
	end
	
	local function OpenDodatkiGarazMenu()
		local elements1 = {}
		
		for ExtraID = 0, 20 do
			if DoesExtraExist(cacheVehicle, ExtraID) then
				if IsVehicleExtraTurnedOn(cacheVehicle, ExtraID) == 1 then
					local tekstlabel = 'Dodatek '..tostring(ExtraID)..' - Zdemontuj'
					table.insert(elements1, {label = tekstlabel, posiada = true, value = ExtraID})
				elseif IsVehicleExtraTurnedOn(cacheVehicle, ExtraID) == false then
					local tekstlabel = 'Dodatek '..tostring(ExtraID)..' - Podgląd'
					table.insert(elements1, {label = tekstlabel, posiada = false, value = ExtraID})
				end
			end
		end

		if #elements1 == 0 then
			table.insert(elements1, {label = 'Ten pojazd nie posiada dodatków!', posiada = nil, value = nil})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sklep_dodatki_ambulance', {
			title    = 'Dodatki - Sklep',
			align    = 'center',
			elements = elements1
		}, function(data, menu)
			local dodatek2 = data.current.value
			if dodatek2 ~= nil then
				local dodatekTekst = 'extra'..dodatek2
				local posiada = data.current.posiada
				if posiada then
					menu.close()

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sklep_dodatki_ambulance_usun', {
						title    = 'Zdemontować dodatek?',
						align    = 'center',
						elements = {
							{label = "Tak", value = "tak"},
							{label = "Nie", value = "nie"},
						}
					}, function(data2, menu2)
						local vehicleProps  = ESX.Game.GetVehicleProperties(cacheVehicle)
						local tablica = vehicleProps.plate

						if data2.current.value == 'tak' then
							SetVehicleExtra(cacheVehicle, dodatek2, 1)
							TriggerServerEvent(Event7, tablica, dodatekTekst, false)
						elseif data2.current.value == 'nie' then
							SetVehicleExtra(cacheVehicle, dodatek2, 0)
						end

						menu2.close()
						Citizen.Wait(200)
						OpenDodatkiGarazMenu()
					end, function(data2, menu2)
						menu2.close()
					end)
					
				elseif posiada == false then
					SetVehicleExtra(cacheVehicle, dodatek2, 0)
					menu.close()

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sklep_dodatki_ambulance_kup', {
						title = 'Potwierdzić montaż?',
						align = 'center',
						elements = {
							{label = "Tak - Zamontuj", value = "tak"},
							{label = "Nie - Anuluj", value = "nie"},
						}
					}, function(data3, menu3)
						local vehicleProps  = ESX.Game.GetVehicleProperties(cacheVehicle)
						local tablica = vehicleProps.plate

						if data3.current.value == 'tak' then
							TriggerServerEvent(Event7, tablica, dodatekTekst, true)
						elseif data3.current.value == 'nie' then
							SetVehicleExtra(cacheVehicle, dodatek2, 1)
						end
						
						menu3.close()
						Citizen.Wait(200)
						OpenDodatkiGarazMenu()
					end, function(data3, menu3)
						menu3.close()
					end)
				end
			end
		end, function(data, menu)
			menu.close()
			CurrentAction = ''
			CurrentActionMsg = ""
			CurrentActionData = {}
		end)
	end
	
	local function CanPlayerUse(grade)
		return not grade or ESX.PlayerData.job.grade >= grade
	end
	
	local function OpenVehicleSpawnerMenu(partNum)
		local vehicles = Config.Ambulance.Cars.Vehicles
		local elements = {}
		local found = true

		for i, group in ipairs(Config.VehicleGroups) do
			local elements2 = {}

			for _, vehicle in ipairs(Config.AuthorizedVehicles) do
				local let = false
				for _, groupv in ipairs(vehicle.groups) do
					if groupv == i then
						let = true
						break
					end
				end

				if let then
					if vehicle.grade then
						if not CanPlayerUse(vehicle.grade) then
							let = false
						end
					elseif vehicle.grades and #vehicle.grades > 0 then
						let = false
						for _, grade in ipairs(vehicle.grades) do
							if ((vehicle.swat) or grade == ESX.PlayerData.job.grade) and (not vehicle.label:find('SEU')) then
								let = true
								break
							end
						end
					end

					if let then
						table.insert(elements2, { label = vehicle.label, model = vehicle.model, livery = vehicle.livery, extrason = vehicle.extrason, extrasoff = vehicle.extrasoff, offroad = vehicle.offroad, wheelsxd = vehicle.wheelsxd, color = vehicle.color, plate = vehicle.plate, tint = vehicle.tint, bulletproof = vehicle.bulletproof, wheel = vehicle.wheel, tuning = vehicle.tuning })
					end
				end
			end

			if (ESX.PlayerData.job.name == 'ambulance' and ESX.PlayerData.job.grade >= 12) then
				if #elements2 > 0 then
					table.insert(elements, {label = group, value = elements2, group = i})
				end
			else
				table.insert(elements, { label = group, value = elements2, group = i })
			end
		end


		local function showMainContext()
			local mainOptions = {}

			for i = 1, #elements do
				local el = elements[i]
				table.insert(mainOptions, {
					title = el.label,
					onSelect = function()
						if type(el.value) == "table" and #el.value > 0 then
							local subOptions = {
								{
									title = "⬅️ Wróć",
									onSelect = function()
										lib.showContext("vehicle_spawner")
									end
								}
							}
							for j = 1, #el.value do
								local sub = el.value[j]
								table.insert(subOptions, {
									title = sub.label,
									onSelect = function()
										local livery = sub.livery
										local extrason = sub.extrason
										local extrasoff = sub.extrasoff
										local offroad = sub.offroad
										local wheelsxd = sub.wheelsxd
										local color = sub.color
										local bulletproof = sub.bulletproof or false
										local tint = sub.tint
										local wheel = sub.wheel
										local tuning = sub.tuning

										local setPlate = true
										if sub.plate ~= nil and not sub.plate then
											setPlate = false
										end

										if not IsAnyVehicleNearPoint(vehicles[partNum].spawnPoint.x, vehicles[partNum].spawnPoint.y, vehicles[partNum].spawnPoint.z, 3.0) then
											local vehicle = GetClosestVehicle(vehicles[partNum].spawnPoint.x, vehicles[partNum].spawnPoint.y, vehicles[partNum].spawnPoint.z, 3.0, 0, 71)
											if not DoesEntityExist(vehicle) then
												ESX.Game.SpawnVehicle(sub.model, {
													x = vehicles[partNum].spawnPoint.x,
													y = vehicles[partNum].spawnPoint.y,
													z = vehicles[partNum].spawnPoint.z
												}, vehicles[partNum].heading, function(vehicle)
													SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, extrason, extrasoff, bulletproof, tint, wheel, tuning)

													if setPlate then
														local plate = ""
									if el.label == 'PATROL' then
										plate = math.random(1000, 9999) .. "EMS" .. math.random(1000, 9999)
									else
										plate = "EMS" .. math.random(1111, 9999)
									end
														SetVehicleNumberPlateText(vehicle, plate)
													end

													Entity(vehicle).state.fuel = 50
													TaskWarpPedIntoVehicle(cachePed, vehicle, -1)

													Citizen.Wait(500)

													local status = IsVehicleEngineOn(vehicle)

													lib.callback('esx_carkeys:ToggleEngine', false, function(data)
														if data then
															if not status then
																if data == "Key" then return ESX.ShowNotification("Znalazłeś kluczyki do pojazdu.") end
																SetVehicleEngineOn(vehicle, true, false, true)
																Entity(vehicle).state.engine = true
																ESX.ShowNotification("Silnik włączony.")
															else
																SetVehicleEngineOn(vehicle, false, false, true)
																Entity(vehicle).state.engine = false
																ESX.ShowNotification("Silnik wyłączony.")
															end
														else
															if status then
																Entity(vehicle).state.engine = false
																SetVehicleEngineOn(vehicle, false, false, true)
																ESX.ShowNotification("Silnik wyłączony.")
															else
																ESX.ShowNotification("Nie posiadasz kluczy do auta.")
															end
														end
													end, not status)
												end)
											else
												ESX.ShowNotification('Pojazd znajduje się w miejscu wyciągnięcia następnego')
											end
										else
											ESX.ShowNotification('Miejsce jest zajęte!')
										end
									end
								})
							end
							lib.registerContext({
								id = "vehicle_spawner_" .. (el.group or "sub"),
								title = el.label,
								options = subOptions
							})
							lib.showContext("vehicle_spawner_" .. (el.group or "sub"))
						else
							ESX.ShowNotification("Brak pojazdów dostępnych w tej kategorii dla twojego stopnia.")
						end
					end
				})
			end

			lib.registerContext({
				id = "vehicle_spawner",
				title = "Pojazdy",
				options = mainOptions
			})

			lib.showContext("vehicle_spawner")
		end

		showMainContext()
	end

	local function OpenHeliSpawnerMenu(zoneNumber)
		local helimodel = "polmav"
		if not IsAnyVehicleNearPoint(Config.Ambulance.Cars.Helicopters[zoneNumber].spawnPoint.x, Config.Ambulance.Cars.Helicopters[zoneNumber].spawnPoint.y, Config.Ambulance.Cars.Helicopters[zoneNumber].spawnPoint.z, 3.0) then
			ESX.Game.SpawnVehicle(helimodel, Config.Ambulance.Cars.Helicopters[zoneNumber].spawnPoint, Config.Ambulance.Cars.Helicopters[zoneNumber].spawnPoint.heading, function(vehicle)
				SetVehicleLivery(vehicle, 1)
				Entity(vehicle).state.fuel = 100
			end)
		else
			ESX.ShowNotification('Lądowisko jest zajęte!')
		end
	end
	
	local function OpenBoatSpawnerMenu(zoneNumber)
		local options = {}
		for i = 1, #Config.AuthorizedBoats do
			local boat = Config.AuthorizedBoats[i]
			table.insert(options, {
				title = boat.label,
				onSelect = function()
					ESX.Game.SpawnVehicle(
						boat.model,
						Config.Ambulance.Cars.Boats[zoneNumber].spawnPoint,
						Config.Ambulance.Cars.Boats[zoneNumber].heading,
						function(vehicle)
							local plate = "EMS " .. math.random(1000,9999)
							SetVehicleNumberPlateText(vehicle, plate)
							TaskWarpPedIntoVehicle(cachePed, vehicle, -1)
							Entity(vehicle).state.fuel = 100
						end
					)
				end
			})
		end

		lib.registerContext({
			id = "boat_spawner",
			title = "Garaż łodzi",
			options = options
		})

		lib.showContext("boat_spawner")
	end
	
	AddEventHandler('playerSpawned', function()
		if LocalPlayer.state.IsDead then
			EndDeathCam()
			TriggerEvent('esx_police:unrestPlayerHandcuffs')
			TriggerEvent('esx_basicneeds:resetStatus')
		end
	
		LocalPlayer.state:set('IsDead', false, true)
		LocalPlayer.state:set('BodyDamage', nil, true)
		TriggerEvent('esx_hud:radio:addPlayerDead', false)
		hasBw = false
		canCrawl = true
		timerThreadRunning = false
	end)

		local noWeaponAfterRevive = false

	RegisterNetEvent('esx_ambulance:onTargetRevive')
	AddEventHandler('esx_ambulance:onTargetRevive', function(isAdmin, hospitalCoords)
		Citizen.Wait(500)
		TriggerServerEvent(Event3, 0)
		
		local currentCoords
		if hospitalCoords then
			currentCoords = hospitalCoords
		else
			local pedCoords = GetEntityCoords(cachePed)
			currentCoords = {
				x = pedCoords.x,
				y = pedCoords.y,
				z = pedCoords.z
			}
		end
		
		local formattedCoords = {
			x = ESX.Math.Round(currentCoords.x, 1),
			y = ESX.Math.Round(currentCoords.y, 1),
			z = ESX.Math.Round(currentCoords.z, 1)
		}

		ESX.SetPlayerData('lastPosition', formattedCoords)
		ESX.SetPlayerData('loadout', {})

		TriggerEvent('esx_basicneeds:resetStatus')

		RespawnPed(formattedCoords)
		
		if isAdmin then
			if IsPedCuffed(cachePed) then
				TriggerEvent('esx_police:HandcuffOnPlayer', true)
				TriggerEvent('esx_police:unrestPlayerHandcuffs', true)
			end
		end

		SendNUIMessage({
			action = 'close',
		})

		hasBw = false
		canCrawl = true
		timerThreadRunning = false
		TriggerEvent("esx_hud/hideHud2", true)
		
		if isAdmin then
			noWeaponAfterRevive = false
		else
			noWeaponAfterRevive = true
			ESX.ShowNotification("Nie masz sił żeby wyciągnąć broni przez 5 minut")
			
			SetTimeout(5 * 60 * 1000, function()
				noWeaponAfterRevive = false
				ESX.ShowNotification("Odzyskałeś siły, możesz używać broni")
			end)
		end
	end)

	Citizen.CreateThread(function()
		local lastWeapon = `WEAPON_UNARMED`
		local lastNotificationTime = 0
		while true do
			Citizen.Wait(100)
			if noWeaponAfterRevive then
				local currentWeapon = GetSelectedPedWeapon(cachePed)
				if currentWeapon ~= `WEAPON_UNARMED` then
					local currentTime = GetGameTimer()
					if currentTime - lastNotificationTime > 3000 then
						ESX.ShowNotification("Nie odzyskałeś jeszcze sił, nie możesz używać broni")
						lastNotificationTime = currentTime
					end
					SetCurrentPedWeapon(cachePed, `WEAPON_UNARMED`, true)
					TriggerEvent('ox_inventory:disarm')
					lastWeapon = `WEAPON_UNARMED`
				else
					lastWeapon = currentWeapon
				end
			else
				lastWeapon = GetSelectedPedWeapon(cachePed)
				Citizen.Wait(1000)
			end
		end
	end)
	
	Citizen.CreateThread(function()
		local lastHealth = nil
		local lastArmour = nil
		while true do
			Citizen.Wait(1000)
			local health = GetEntityHealth(cachePed)
			local armour = GetPedArmour(cachePed)
			if HasEntityBeenDamagedByWeapon(cachePed, `WEAPON_RAMMED_BY_CAR`, 0) then
				ClearEntityLastDamageEntity(cachePed)
				if (health ~= lastHealth) then
					SetEntityHealth(cachePed, lastHealth)
				end
				if (armour ~= lastArmour) then
					SetPedArmour(cachePed, lastArmour)
				end
			end
			lastArmour = armour
			lastHealth = health
		end
	end)
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(2)
			if LocalPlayer.state.IsDead then
				DisableControlAction(0, 288, true)
				DisableControlAction(0, 170, true)
				DisableControlAction(0, 56, true)
				exports["pma-voice"]:SetMumbleProperty("radioEnabled", false)
			else
				Citizen.Wait(1000)
				exports["pma-voice"]:SetMumbleProperty("radioEnabled", true)
			end
		end
	end)
	
	AddEventHandler('esx_ambulance:hasEnteredMarker', function(zone, number)
		if zone == 'Vehicles' then
			CurrentAction		= 'vehicle_spawner_menu'
			CurrentActionMsg	= {text = 'Naciśnij', button = 'E', description = 'aby wyciągnąć pojazd.'}
			CurrentActionData	= {zoneNumber = number}
		elseif zone == 'Boats' then
			CurrentAction		= 'boat_spawner_menu'
			CurrentActionMsg	= {text = 'Naciśnij', button = 'E', description = 'aby wyciągnąć łódź.'}
			CurrentActionData	= {zoneNumber = number}
		elseif zone == 'Helicopters' then
			CurrentAction		= 'heli_spawner_menu'
			CurrentActionMsg	= {text = 'Naciśnij', button = 'E', description = 'aby wyciągnąć helikopter.'}
			CurrentActionData	= {zoneNumber = number}
		elseif zone == 'VehicleAddons' and cacheVehicle then
			CurrentAction = 'menu_dodatki'
			CurrentActionMsg = {text = 'Naciśnij', button = 'E', description = 'aby zmienić dodatki w pojeździe.'}
			CurrentActionData = {}
		elseif zone == 'VehicleFix' and cacheVehicle then
			CurrentAction = 'menu_fixing'
			CurrentActionMsg = {text = 'Naciśnij', button = 'E', description = 'aby naprawić pojazd.'}
			CurrentActionData = {}
		elseif zone == 'VehicleDeleters' and cacheVehicle then
			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = cacheCoords.x,
				y = cacheCoords.y,
				z = cacheCoords.z
			})
			if distance ~= -1 and distance <= 1.0 then
				CurrentAction	 = 'delete_vehicle'
				CurrentActionMsg  = {text = 'Naciśnij', button = 'E', description = 'aby schować pojazd.'}
				CurrentActionData = {vehicle = vehicle}
			end
		end
	end)
	
	AddEventHandler('esx_ambulance:hasExitedMarker', function()
		exports["esx_hud"]:hideHelpNotification()
		CurrentAction = nil
	end)
	
	Citizen.CreateThread(function()
		for i = 1, #Config.Blips do
			local blip = AddBlipForCoord(Config.Blips[i].Pos)
	
			SetBlipSprite (blip, Config.Blips[i].Sprite)
			SetBlipDisplay(blip, Config.Blips[i].Display)
			SetBlipScale  (blip, Config.Blips[i].Scale)
			SetBlipColour (blip, Config.Blips[i].Colour)
			SetBlipAsShortRange(blip, true)
	
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(Config.Blips[i].Label)
			EndTextCommandSetBlipName(blip)
		end
	end)
	
	Citizen.CreateThread(function()
		while ESX.PlayerData.job == nil do
			Citizen.Wait(1000)
		end
		
		while true do
			Citizen.Wait(0)
			if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'ambulance') then
				local found = false
				for k, v in pairs(Config.Ambulance.Cars) do
					for i = 1, #v do
						if k == 'VehicleDeleters' or k == 'VehicleAddons' or k == 'VehicleFix' then
							if cacheVehicle then
								local vehicleCoords = GetEntityCoords(cacheVehicle)
								if #(vehicleCoords - v[i].coords) < Config.DrawDistance and cacheVehicle ~= false then
									found = true
									if k == "VehicleDeleters" or k == "VehicleAddons" or k == "VehicleFix" then
										ESX.DrawBigMarker(v[i].coords)
									end
								end
							end
						else
							if #(cacheCoords - v[i].coords) < Config.DrawDistance then
								found = true
								ESX.DrawMarker(v[i].coords)
							end					
						end
					end
				end
				
				if not found then
					Citizen.Wait(2000)
				end
			else
				Citizen.Wait(2000)
			end
		end
	end)
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(100)
	
			local sleep		= true
			local isInMarker	= false
			local currentZone	= nil
			local zoneNumber 	= nil
			if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
				for k, v in pairs(Config.Ambulance.Cars) do
					for i = 1, #v do
						if k == 'VehicleDeleters' or k == 'VehicleAddons' or k == 'VehicleFix' then
							if cacheVehicle then
								local vehicleCoords = GetEntityCoords(cacheVehicle)
								if #(vehicleCoords - v[i].coords) < 3.0 then
									sleep = false
									isInMarker	= true
									currentZone = k
									zoneNumber = i
								end
							end
						end
						if k ~= 'VehicleDeleters' and k ~= 'VehicleAddons' and k ~= 'VehicleFix' then
							if #(cacheCoords - v[i].coords) < Config.MarkerSize.x then
								sleep = false
								isInMarker	= true
								currentZone = k
								zoneNumber = i
							end
						end
					end
				end		
				if isInMarker and not hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = true
					lastZone				= currentZone
					TriggerEvent('esx_ambulance:hasEnteredMarker', currentZone, zoneNumber)
				end
		
				if not isInMarker and hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = false
					TriggerEvent('esx_ambulance:hasExitedMarker', lastZone)
				end
				if sleep then
					Citizen.Wait(500)
				end
			else
				Wait(2000)
			end
		end
	end)
	
	local function OpenInventoryMenu(isHC)
		if isHC then
			ox_inventory:openInventory('stash', {id = 'ambulance_hc'})
		else
			ox_inventory:openInventory('stash', {id = 'ambulance'})
		end
	end
	
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if ESX.PlayerData.job ~= nil and (ESX.PlayerData.job.name == 'ambulance') then
				if CurrentAction ~= nil then
					-- esx_hud:helpNotification(CurrentActionMsg.text, CurrentActionMsg.button, CurrentActionMsg.description)
					if IsControlJustReleased(0, Keys['E']) then	
						if CurrentAction == 'vehicle_spawner_menu' then
							OpenVehicleSpawnerMenu(CurrentActionData.zoneNumber)
						elseif CurrentAction == 'heli_spawner_menu' then
							OpenHeliSpawnerMenu(CurrentActionData.zoneNumber)
						elseif CurrentAction == 'boat_spawner_menu' then
							OpenBoatSpawnerMenu(CurrentActionData.zoneNumber)
						elseif CurrentAction == 'menu_dodatki' then
							OpenDodatkiGarazMenu()
						elseif CurrentAction == 'menu_fixing' then
							if esx_core:CanRepairVehicle() then
								esx_core:RepairVehicle(true, true)
							end
						elseif CurrentAction == 'delete_vehicle' then
							local vehProperties = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
							TriggerServerEvent('esx_carkeys:deleteKeys', vehProperties.plate)
							
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
						end
					end
				else
					Citizen.Wait(200)
				end
			else
				Citizen.Wait(1000)
			end
		end
	end)
	
		local menuOpen = false
	local spawnLocations = {
		{ name = "Szpital Los Santos",    coords = vector3(1153.0330, -1521.5254, 34.8431) },
	}
	local function UseE()
		Citizen.CreateThread(function()
			while LocalPlayer.state.IsDead do
				Citizen.Wait(0)
	
				if overwhelmed then
					return
				else
					if IsControlPressed(0, Keys['E']) or IsDisabledControlPressed(0, Keys['E']) then
						if menuOpen then return end
							menuOpen = true

							ESX.UI.Menu.CloseAll()

							local elements = {}
							for i, loc in ipairs(spawnLocations) do
								table.insert(elements, {
									label = loc.name,
									value = i
								})
							end

							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'spawn_selector', {
								title    = 'Wybierz miejsce odrodzenia',
								align    = 'center',
								elements = elements
							}, function(data, menu)
								local chosen = spawnLocations[data.current.value]
								menu.close()
								DoScreenFadeOut(0)
								menuOpen = false

								local ped = PlayerPedId()
								SetEntityCoords(ped, chosen.coords.x, chosen.coords.y, chosen.coords.z, false, false, false, true)
								
								-- Poczekaj chwilę na zaktualizowanie współrzędnych, potem przekaż współrzędne szpitala
								Citizen.Wait(100)
								local hospitalCoords = {
									x = chosen.coords.x,
									y = chosen.coords.y,
									z = chosen.coords.z
								}
								TriggerEvent('esx_ambulance:onTargetRevive', false, hospitalCoords)
								TriggerEvent('esx_police:unrestPlayerHandcuffs',true)
								TriggerServerEvent('esx_core:SendLog', "Teleportacja na szpital", "Przeteleportował się do: " .. chosen.name, 'ems-hospital')
								Wait(500)
								DoScreenFadeIn(1000)
							end, function(data, menu)
								menu.close()
								menuOpen = false
							end)
						break
					end
				end
			end
		end)
	end
	

	RegisterNUICallback('respawnPlayer', function(data)
		UseE()

	end)
	RegisterNUICallback('catchNui', function(data)
		if data.action == 'esx_ambulance/canTeleport' then
			
		end
	end)
	
	local lastReviveEMS = 0
	local lastHealEMS = 0
	
	RegisterNetEvent('esx_ambulance:heal')
	AddEventHandler('esx_ambulance:heal', function(itemName)
		local health = GetEntityHealth(cachePed)
		local maxHealth = GetEntityMaxHealth(cachePed)
		local newHealth = math.min(maxHealth , math.floor(health + maxHealth/4))
	
		if itemName == 'small' then
			SetEntityHealth(cachePed, newHealth)
		elseif itemName == 'big' then
			SetEntityHealth(cachePed, maxHealth)
		elseif itemName == 'bandage' then
			SetEntityHealth(cachePed, math.min(maxHealth, math.floor(health + maxHealth / 16)))
		end
	end)
	
	RegisterNetEvent('esx_ambulance:onSyringe', function (entity)
		local closestPlayerPed = GetPlayerPed(entity)

		if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.IsDead or IsEntityPlayingAnim(closestPlayerPed, 'dead', 'dead_a', 3) then
			-- TriggerServerEvent(Event5, 'Udziela pomocy')
			if esx_hud:progressBar({
				duration = 25,
				label = 'Udzielanie pomocy',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = true,
					combat = true,
					mouse = false,
				},
				anim = {
					dict = 'mini@cpr@char_a@cpr_str',
					clip = 'cpr_pumpchest',
					flag = 1
				},
				prop = {},
			}) 
			then 
				TriggerServerEvent(Event2, 'strzykawka')
				Citizen.Wait(500)
				TriggerServerEvent(Event1, GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)), true, false)
				ESX.ShowNotification('Uleczono.')
			else 
				ESX.ShowNotification('Anulowano.')
			end
		else
			ESX.ShowNotification('Obywatel nie potrzebuje pomocy medycznej')
		end
	end)

	local options = {
		{
			name = 'esx_ambulance:onStatusCheck',
			icon = 'fa-solid fa-hand-holding-medical',
			label = 'Sprawdź obrażenia',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end

				if distance > 2 then
					return false
				end

				if cacheVehicle then return false end

				if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.IsDead or IsEntityPlayingAnim(entity, 'dead', 'dead_a', 3) then
					if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.BodyDamage ~= nil then
						if ESX.PlayerData.job.name == 'ambulance' then
							return true
						else
							return false
						end
					end
				end

				return false
			end,
			onSelect = function (data)
				if GetGameTimer() > lastReviveEMS then
					if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))).state.IsDead or IsEntityPlayingAnim(data.entity, 'dead', 'dead_a', 3) then
						if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))).state.BodyDamage ~= nil then
							-- TriggerServerEvent(Event6, 'Sprawdza obrażenia poszkodowanego', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
							if esx_hud:progressBar({
								duration = 5,
								label = 'Sprawdzanie obrażeń poszkodowanego...',
								useWhileDead = false,
								canCancel = true,
								disable = {
									car = true,
									move = true,
									combat = true,
									mouse = false,
								},
								anim = {
									dict = 'amb@medic@standing@tendtodead@base',
									clip = 'base',
									flag = 0
								},
								prop = {},
							}) 
							then
								lastReviveEMS = GetGameTimer() + 5000
								ESX.ShowNotification('Po wstępnej analizie wnioskujesz że poszkodowany/a posiada obrażenia: '..Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))).state.BodyDamage)
							else 
								ESX.ShowNotification('Anulowano.')
							end
						end
					end
				else
					ESX.ShowNotification('Przed następnym użyciem odczekaj 5 sekund!')
				end
			end
		},
		{
			name = 'esx_ambulance:onRevive',
			icon = 'fa-solid fa-hand-holding-medical',
			label = 'Ocuć (Nieprzytomny)',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end

				if distance > 2 then
					return false
				end

				local count = ox_inventory:Search('count', 'medikit')

				if count <= 0 then
					return false
				end

				if cacheVehicle then return false end

				if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.IsDead or IsEntityPlayingAnim(entity, 'dead', 'dead_a', 3) then
					if ESX.PlayerData.job.name == 'ambulance' then
						return true
					else
						return false
					end
				end

				return false
			end,
			onSelect = function (data)
				if GetGameTimer() > lastReviveEMS then
					if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))).state.IsDead or IsEntityPlayingAnim(data.entity, 'dead', 'dead_a', 3) then
						-- TriggerServerEvent(Event5, 'Udziela pomocy')
						Citizen.Wait(500)
						if esx_hud:progressBar({
							duration = 5,
							label = 'Udzielanie pomocy',
							useWhileDead = false,
							canCancel = true,
							disable = {
								car = true,
								move = true,
								combat = true,
								mouse = false,
							},
							anim = {
								dict = 'mini@cpr@char_a@cpr_str',
								clip = 'cpr_pumpchest',
								flag = 1
							},
							prop = {},
						}) 
						then
							lastReviveEMS = GetGameTimer() + 5000
							TriggerServerEvent(Event2, 'medikit')
							Citizen.Wait(500)
							TriggerServerEvent(Event1, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), false, true)
							ESX.ShowNotification('Uleczono.')
						else 
							ESX.ShowNotification('Anulowano.')
						end
					else
						ESX.ShowNotification('Obywatel nie potrzebuje pomocy medycznej')
					end
				else
					ESX.ShowNotification('Przed następnym użyciem odczekaj 5 sekund!')
				end
			end
		},
		{
			name = 'esx_ambulance:heal50',
			icon = 'fa-solid fa-bandage',
			label = 'Opatrz rany (50%)',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end

				if distance > 2 then
					return false
				end

				local count = ox_inventory:Search('count', 'bandage')

				if count <= 0 then
					return false
				end

				if cacheVehicle then return false end

				if (not Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.IsDead) or (not IsEntityPlayingAnim(entity, 'dead', 'dead_a', 3)) then
					if ESX.PlayerData.job.name == 'ambulance' then
						return true
					else
						return false
					end
				end

				return false
			end,
			onSelect = function (data)
				if GetGameTimer() > lastHealEMS then
					local health = GetEntityHealth(data.entity)
	
					if health > 0 then
						-- TriggerServerEvent(Event5, 'Udziela pomocy')
						Citizen.Wait(500)
						if esx_hud:progressBar({
							duration = 5,
							label = 'Udzielanie pomocy',
							useWhileDead = false,
							canCancel = true,
							disable = {
								car = true,
								move = true,
								combat = true,
								mouse = false,
							},
							anim = {
								dict = 'mini@cpr@char_a@cpr_str',
								clip = 'cpr_pumpchest',
								flag = 1
							},
							prop = {},
						}) 
						then
							lastHealEMS = GetGameTimer() + 5000
							TriggerServerEvent(Event2, 'bandage')
							Citizen.Wait(500)
							TriggerServerEvent(Event4, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), 'small', true, false)
							ESX.ShowNotification('Uleczono.')
						else 
							ESX.ShowNotification('Anulowano.')
						end
					else
						ESX.ShowNotification('Obywatel nie potrzebuje pomocy medycznej')
					end
				else
					ESX.ShowNotification('Przed następnym użyciem odczekaj 5 sekund!')
				end
			end
		},
		{
			name = 'esx_ambulance:heal100',
			icon = 'fa-solid fa-kit-medical',
			label = 'Opatrz rany (100%)',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end

				if distance > 2 then
					return false
				end

				local count = ox_inventory:Search('count', 'medikit')

				if count <= 0 then
					return false
				end

				if cacheVehicle then return false end

				if (not Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.IsDead) or (not IsEntityPlayingAnim(entity, 'dead', 'dead_a', 3)) then
					if ESX.PlayerData.job.name == 'ambulance' then
						return true
					else
						return false
					end
				end

				return false
			end,
			onSelect = function (data)
				if GetGameTimer() > lastHealEMS then
					local health = GetEntityHealth(data.entity)

					if health > 0 then
						-- TriggerServerEvent(Event5, 'Udziela pomocy')
						Citizen.Wait(500)
						if esx_hud:progressBar({
							duration = 5,
							label = 'Udzielanie pomocy',
							useWhileDead = false,
							canCancel = true,
							disable = {
								car = true,
								move = true,
								combat = true,
								mouse = false,
							},
							anim = {
								dict = 'mini@cpr@char_a@cpr_str',
								clip = 'cpr_pumpchest',
								flag = 1
							},
							prop = {},
						}) 
						then
							TriggerServerEvent(Event2, 'medikit')
							Citizen.Wait(500)
							TriggerServerEvent(Event4, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), 'big', false, true)
							ESX.ShowNotification('Uleczono.')
						else 
							ESX.ShowNotification('Anulowano.')
						end
					else
						ESX.ShowNotification('Obywatel nie potrzebuje pomocy medycznej')
					end
				else
					ESX.ShowNotification('Przed następnym użyciem odczekaj 5 sekund!')
				end
			end
		}
	}

	local function CanInteractBase(_, distance)
		return not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed and distance <= 2 and not cacheVehicle
	end

	local vehicleOptions = {
		{
			name = 'esx_ambulance:repair',
			icon = 'fa-solid fa-toolbox',
			label = 'Napraw (100%)',
			canInteract = function(_, distance)
				return CanInteractBase(_, distance) and (ESX.PlayerData.job.name == 'ambulance')
			end,
			onSelect = function(data)
				if not DoesEntityExist(data.entity) then
					ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
					return
				end
				local repairAnim = { dict = 'mini@repair', clip = 'fixing_a_player' }
				if esx_hud:progressBar({
					duration = 5,
					label = 'Naprawianie',
					useWhileDead = false,
					canCancel = true,
					disable = { car = true, move = true, combat = true, mouse = false },
					anim = repairAnim,
					prop = {}
				}) then
					SetVehicleFixed(data.entity)
					SetVehicleDeformationFixed(data.entity)
					SetVehicleUndriveable(data.entity, false)
					SetVehicleEngineOn(data.entity, true, true)
					SetVehicleEngineHealth(data.entity, 1000.0)
					ClearPedTasks(cachePed)
					ESX.ShowNotification('Pojazd naprawiony do 100%.')
				else
					ESX.ShowNotification('Anulowano.')
				end
			end
		},
	}

	---@param playerPed number
	---@param heading number|nil
	---@param blendInSpeed number|nil
	local function PlayIdleCrawlAnim(playerPed, heading, blendInSpeed)
		local playerCoords = GetEntityCoords(playerPed)
		TaskPlayAnimAdvanced(playerPed, "move_crawl", proneType.."_fwd", playerCoords.x, playerCoords.y, playerCoords.z, 0.0, 0.0, heading or GetEntityHeading(playerPed), blendInSpeed or 2.0, 2.0, -1, 2, 1.0, false, false)
	end

	---@param forceEnd boolean
	local function PlayExitCrawlAnims(forceEnd)
		if not forceEnd then
			inAction = true
			local playerPed = PlayerPedId()

			if proneType == "onfront" then
				PlayAnimOnce(playerPed, "get_up@directional@transition@prone_to_knees@crawl", "front", nil, nil, 780)
			else
				PlayAnimOnce(playerPed, "get_up@directional@transition@prone_to_seated@crawl", "back", 16.0, nil, 950)
			end
		end
	end

	---Crawls one "step" forward/backward
	---@param playerPed number
	---@param type string
	---@param direction string
	local function Crawl(playerPed, type, direction)
		isCrawling = true

		TaskPlayAnim(playerPed, "move_crawl", type.."_"..direction, 8.0, -8.0, -1, 2, 0.0, false, false, false)

		local time = {
			["onfront"] = {
				["fwd"] = 820,
				["bwd"] = 990
			},
			["onback"] = {
				["fwd"] = 1200,
				["bwd"] = 1200
			}
		}

		SetTimeout(time[type][direction], function()
			isCrawling = false
		end)
	end

	local function CrawlLoop()
		local forceEnd = false
		Wait(400)

		while isProne do
			local playerPed = PlayerPedId()

			if not CanPlayerCrouchCrawl(playerPed) or IsEntityInWater(playerPed) then
				ClearPedTasks(playerPed)
				isProne = false
				LocalPlayer.state:set('isCrawling', false, true)
				forceEnd = true
				break
			end

			DisableAllControlActions(0)

			EnableControlAction(0, 32, true)
			EnableControlAction(0, 33, true)
			EnableControlAction(0, 34, true)
			EnableControlAction(0, 35, true)

			local forward, backwards = IsControlPressed(0, 32), IsControlPressed(0, 33) -- INPUT_MOVE_UP_ONLY, INPUT_MOVE_DOWN_ONLY

			if not isCrawling then
				if forward then
					Crawl(playerPed, proneType, "fwd")
				elseif backwards then
					Crawl(playerPed, proneType, "bwd")
				end
			end

			if IsControlPressed(0, 34) then -- INPUT_MOVE_LEFT_ONLY
				if isCrawling then
					local headingDiff = forward and 1.0 or -1.0
					SetEntityHeading(playerPed, GetEntityHeading(playerPed) + headingDiff)
				else
					inAction = true
					PlayAnimOnce(playerPed, "get_up@directional_sweep@combat@pistol@left", "left_to_prone")
					ChangeHeadingSmooth(playerPed, 25.0, 400)
					PlayIdleCrawlAnim(playerPed)
					Wait(600)
					inAction = false
				end
			elseif IsControlPressed(0, 35) then -- INPUT_MOVE_RIGHT_ONLY
				if isCrawling then
					local headingDiff = backwards and 1.0 or -1.0
					SetEntityHeading(playerPed, GetEntityHeading(playerPed) + headingDiff)
				else
					inAction = true
					PlayAnimOnce(playerPed, "get_up@directional_sweep@combat@pistol@right", "right_to_prone")
					ChangeHeadingSmooth(playerPed, -25.0, 400)
					PlayIdleCrawlAnim(playerPed)
					Wait(600)
					inAction = false
				end
			end

			Wait(0)
		end

		PlayExitCrawlAnims(forceEnd)

		-- Reset variabels
		isCrawling = false
		inAction = false
		proneType = "onback"
		SetPedConfigFlag(PlayerPedId(), 48, false) -- CPED_CONFIG_FLAG_BlockWeaponSwitching

		-- Unload animation dictionaries
		RemoveAnimDict("move_crawl")
		RemoveAnimDict("move_crawlprone2crawlfront")
	end

	local function CrawlKeyPressed()
		if inAction then
			return
		end

		if IsPauseMenuActive() then
			return
		end

		if isProne then
			isProne = false
			LocalPlayer.state:set('isCrawling', false, true)
			return
		end

		if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk then
			return
		end

		local playerPed = PlayerPedId()

		if not CanPlayerCrouchCrawl(playerPed) or IsEntityInWater(playerPed) or not IsPedHuman(playerPed) then
			return
		end

		inAction = true

		if Pointing then
			Pointing = false
		end

		isProne = true
		LocalPlayer.state:set('isCrawling', true, true)
		SetPedConfigFlag(playerPed, 48, true) -- CPED_CONFIG_FLAG_BlockWeaponSwitching

		if GetPedStealthMovement(playerPed) == 1 then
			SetPedStealthMovement(playerPed, false, "DEFAULT_ACTION")
			Wait(100)
		end

		LoadAnimDict("move_crawl")
		LoadAnimDict("move_crawlprone2crawlfront")

		if CanPlayerCrouchCrawl(playerPed) and not IsEntityInWater(playerPed) then
			PlayIdleCrawlAnim(playerPed, nil, 3.0)
		end

		inAction = false
		CreateThread(CrawlLoop)
	end

	CreateThread(function()
		RegisterKeyMapping('+crawlbw', 'Czołganie podczas BW', "keyboard", 'J')
		RegisterCommand('+crawlbw', function() CrawlKeyPressed() end, false)
		RegisterCommand('-crawlbw', function() end, false)
		RegisterCommand('crawlbw', function() CrawlKeyPressed() end, false)
	end)

	local ox_target = exports.ox_target

	ox_target:addGlobalPlayer(options)
	ox_target:addGlobalVehicle(vehicleOptions)

	local ambulanceTargets = {}

	RegisterNetEvent('esx_ambulance:sync:removeTargets', function ()
		Citizen.CreateThread(function ()
			if haveTargets then haveTargets = false end
			
			for i = 1, #ambulanceTargets do
				ox_target:removeZone(ambulanceTargets[i])
			end
			
			ambulanceTargets = {}
		end)
	end)
	
	RegisterNetEvent('esx_ambulance:sync:addTargetsCL', function ()
		if ESX.IsPlayerLoaded() then
			if ESX.PlayerData.job.name == "ambulance" then
				Citizen.CreateThread(function()
					for k, v in pairs(Config.Ambulance) do
						for i = 1, #v do
							ambulanceTargets[#ambulanceTargets + 1] = ox_target:addBoxZone({
								coords = v[i].coords,
								size = v[i].size,
								rotation = v[i].rotation,
								debug = false,
								options = {
									{
										name = 'esx_ambulance:targets'..k,
										icon = v[i].icon,
										label = v[i].label,
										canInteract = function(entity, distance, coords, name)
											if LocalPlayer.state.IsDead then return false end
											if LocalPlayer.state.IsHandcuffed then return false end
											if distance > 1.50 then return false end
			
											if ESX.PlayerData.job.name == 'ambulance' then
												return true
											else 
												return false
											end
										end,
										onSelect = function ()
											if tostring(k) == 'Cloakrooms' then
												OpenCloakroomMenu()
											elseif tostring(k) == 'CloakroomsPrivate' then
												OpenCloakroomMenuPrivate()
											elseif tostring(k) == 'Inventories' then
												OpenInventoryMenu(false)
											elseif tostring(k) == 'InventoriesHC' then
												OpenInventoryMenu(true)
											elseif tostring(k) == 'BossActions' then
												if ESX.PlayerData.job.grade >= 10 then
													TriggerServerEvent('esx_society:openbosshub', 'fraction', false, true)
												else
													ESX.ShowNotification("Nie posiadasz dostępu do tego elementu!")
												end
											end
										end
									}
								}
							})
						end
					end
				end)
			end
		end
	end)

	AddEventHandler('gameEventTriggered', function (name, args)
		if name ~= 'CEventNetworkEntityDamage' then return end
		if overwhelmed then return end
		if not hasBw then return end
		if not IsEntityAPed(args[1]) or cachePed ~= args[1] or not IsEntityAPed(args[2]) or not LocalPlayer.state.IsDead or not canCrawl then return end

		ESX.ShowNotification("Zostałeś dobity, nie jesteś w stanie się czołgać.")
		
		canCrawl = false

		SendNUIMessage({
			action = 'close',
		})

		Wait(200)

		startTimerThread()

		Wait(200)

		SendNUIMessage({
			action = 'setVisibleCrawling',
			crawling = false,
		})

		Wait(200)

		SendNUIMessage({
			action = 'open',
		})

		if isCrawling then
			CrawlKeyPressed()
		end
	end)
	
	Citizen.CreateThread(function ()
		if ESX.PlayerLoaded then
			if ESX.PlayerData.job.name == "ambulance" then
				Citizen.CreateThread(function()
					RefreshTargets()
				end)
			else
				Citizen.CreateThread(function()
					DeleteTargets()
				end)
			end
		end
	end)
	
	-- exports.ox_target:addBoxZone({
	-- 	name = "SZAFKA_HC_AMBULANCE",
	-- 	coords = vec3(340.1, -595.35, 43.0),
	-- 	size = vec3(1.0, 2.5, 2.7),
	-- 	rotation = 160.0,
	-- 	options = {
	-- 		{
	-- 			name = 'szafka_hc',
	-- 			icon = 'fa-regular fa-vault',
	-- 			label = 'Szafka HC',
	-- 			canInteract = function(entity, distance, coords, name)
	-- 				if LocalPlayer.state.IsDead then return false end
	-- 				if LocalPlayer.state.IsHandcuffed then return false end
	-- 				if distance > 2.0 then return false end
	
	-- 				if ESX.PlayerData.job.name == 'ambulance' and ESX.PlayerData.job.grade >= 10 then return true end
	
	-- 				return false
	-- 			end,
	-- 			onSelect = function ()
	-- 				ox_inventory:openInventory('stash', {id = 'ambulance_hc_schowek'})
	-- 			end
	-- 		}
	-- 	}
	-- })

	exports('RespawnPed', RespawnPed)
end)