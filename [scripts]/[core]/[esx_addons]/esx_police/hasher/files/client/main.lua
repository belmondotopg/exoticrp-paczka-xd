local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local LocalPlayer = LocalPlayer

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 75, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["centerSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["centerCTRL"] = 36, ["centerALT"] = 19, ["SPACE"] = 22, ["centerCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["center"] = 174, ["center"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

RegisterNetEvent("esx_police:getRequest")
TriggerServerEvent("esx_police:makeRequest")
AddEventHandler("esx_police:getRequest", function(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
    local Event1, Event2, Event3, Event4, Event5, Event6, Event7, Event8, Event9, Event10, Event11, Event12, Event13, Event14 = a, b, c, d, e, f, g, h, i, j, k, l, m, n

	LocalPlayer.state:set('IsDraggingSomeone', false, true)
	LocalPlayer.state:set('DraggingById', nil, true)
	LocalPlayer.state:set('DraggingId', nil, true)
	LocalPlayer.state:set('IsHandcuffed', false, true)
	LocalPlayer.state:set('InsideVehicle', false, true)
	LocalPlayer.state:set('DraggedEntity', nil, true)

	local esx_core = exports.esx_core
	local ox_inventory = exports.ox_inventory
	local RequestCollisionAtCoord = RequestCollisionAtCoord
	local GetEntityHealth = GetEntityHealth
	local plate = nil 
	local HasAlreadyEnteredMarker = false
	local LastStation             = nil
	local LastPartNum             = nil
	local CurrentAction = nil
	local CurrentActionMsg  = {}
	local CurrentActionData = {}
	local IsDragged 					= false
	local HandcuffTimer = nil
	local CopPlayer 					= nil
	local Dragging 						= nil
	local GetPlayerPed = GetPlayerPed
	local IsControlJustReleased = IsControlJustReleased
	local IsPedInAnyPoliceVehicle = IsPedInAnyPoliceVehicle
	local DoesExtraExist = DoesExtraExist
	local IsVehicleExtraTurnedOn = IsVehicleExtraTurnedOn
	local DisableControlAction = DisableControlAction
	local SetBlipAlpha = SetBlipAlpha
	local SetBlipCategory = SetBlipCategory
	local PlaySoundFrontend = PlaySoundFrontend
	local GetClosestObjectOfType = GetClosestObjectOfType
	local SetCurrentPedWeapon = SetCurrentPedWeapon
	local IsPlayerDead = IsPlayerDead
	local GetStreetNaAtCoord = GetStreetNameAtCoord
	local GetStreetNameFromHashKey = GetStreetNameFromHashKey
	local DisablePlayerFiring = DisablePlayerFiring
	local SetEntityCoords = SetEntityCoords
	local SetEntityHeading = SetEntityHeading
	local SetEnableHandcuffs = SetEnableHandcuffs
	local SetPedCanPlayGestureAnims = SetPedCanPlayGestureAnims
	local GetEntityCoords = GetEntityCoords
	local GetPlayerServerId = GetPlayerServerId
	local SetVehicleLivery = SetVehicleLivery
	local SetVehicleExtra = SetVehicleExtra
	local ClearPedBloodDamage = ClearPedBloodDamage
	local ResetPedVisibleDamage = ResetPedVisibleDamage
	local ClearPedLastWeaponDamage = ClearPedLastWeaponDamage
	local ResetPedMovementClipset = ResetPedMovementClipset
	local GetCurrentResourceName = GetCurrentResourceName
	local HasAnimDictLoaded = HasAnimDictLoaded
	local IsPedSittingInAnyVehicle = IsPedSittingInAnyVehicle
	local TaskLeaveVehicle = TaskLeaveVehicle
	local FreezeEntityPosition = FreezeEntityPosition
	local GetClosestVehicle = GetClosestVehicle
	local IsAnyVehicleNearPoint = IsAnyVehicleNearPoint
	local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
	local TaskWarpPedIntoVehicle = TaskWarpPedIntoVehicle
	local IsVehicleSeatFree = IsVehicleSeatFree
	local IsEntityPlayingAnim = IsEntityPlayingAnim
	local TaskPlayAnim = TaskPlayAnim
	local IsPedCuffed = IsPedCuffed
	local DetachEntity = DetachEntity
	local DoesEntityExist = DoesEntityExist
	local AttachEntityToEntity = AttachEntityToEntity
	local GetEntityHeading = GetEntityHeading
	local GetEntityForwardVector = GetEntityForwardVector
	local PlaySound = PlaySound
	local AddBlipForCoord = AddBlipForCoord
	local RemoveBlip = RemoveBlip
	local SetBlipSprite = SetBlipSprite
	local SetBlipDisplay = SetBlipDisplay
	local SetBlipScale = SetBlipScale
	local SetBlipColour = SetBlipColour
	local SetBlipAsShortRange = SetBlipAsShortRange
	local BeginTextCommandSetBlipName = BeginTextCommandSetBlipName
	local AddTextComponentString = AddTextComponentString
	local EndTextCommandSetBlipName = EndTextCommandSetBlipName
	local VehToNet = VehToNet
	local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId
	
	local boatsBlips = {}

	local function addBoats()
		if boatsBlips[1] ~= nil then
			for i=1, #boatsBlips, 1 do
				RemoveBlip(boatsBlips[i])
			end
	
			boatsBlips = {}
		end

		if Config.PoliceStations.Cars.Boats then
			for i=1, #Config.PoliceStations.Cars.Boats, 1 do
				local blip = AddBlipForCoord(Config.PoliceStations.Cars.Boats[i].coords)
	
				SetBlipSprite (blip, 404)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 0.7)
				SetBlipColour (blip, 38)
				SetBlipAsShortRange(blip, true)
	
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString("Port LSPD")
				EndTextCommandSetBlipName(blip)
				table.insert(boatsBlips, blip)
			end
		end
	end

	local function removeBoats()
		if boatsBlips[1] ~= nil then
			for i=1, #boatsBlips, 1 do
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

		if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
			Citizen.CreateThread(function()
				addBoats()
			end)
		else
			Citizen.CreateThread(function()
				removeBoats()
			end)
		end
	end)

	local libCache = lib.onCache
	local cachePed = cache.ped
	local cacheCoords = cache.coords
	local cachePlayerId = cache.playerId
	local cacheServerId = cache.serverId
	local cacheVehicle = cache.vehicle
	local esx_hud = exports.esx_hud

	libCache('ped', function(ped)
		cachePed = ped
	end)

	libCache('coords', function(coords)
		cacheCoords = coords
	end)

	libCache('playerId', function(playerId)
		cachePlayerId = playerId
	end)

	libCache('serverId', function(serverId)
		cacheServerId = serverId
	end)

	libCache('vehicle', function(vehicle)
		cacheVehicle = vehicle
	end)

	local function SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, extrason, extrasoff, bulletproof, tint, wheel, tuning, plate)
		local color1, color2 = 0, 111
		if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff" then
			color1 = 0
			color2 = 10
		end
		
		local t = {
			modArmor        = 4,
			modTurbo        = true,
			modXenon        = true,
			bulletProofTyre = false,
			windowTint      = 0,
			dirtLevel       = 0,
			color1			= color1,
			color2			= color2,
			modEngine		= 3,
			modBrakes		= 2,
			modTransmission	= 2,
			modSuspension 	= -1,
		}
		
		if tuning then
			t.modEngine = 3
			t.modBrakes = 2
			t.modTransmission = 2
			t.modSuspension = -1
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
			if not (ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff") then
				t.color1 = 0
			end
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
			for i=1, #extrason do
				SetVehicleExtra(vehicle, extrason[i], false)
			end
		end
		
		if #extrasoff > 0 then
			for i=1, #extrasoff do
				SetVehicleExtra(vehicle, extrasoff[i], true)
			end
		end

		if livery then
			if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff" then
				SetVehicleLivery(vehicle, livery + 1)
			else
				SetVehicleLivery(vehicle, livery)
			end
		end
	end

	local function TakeOtherClothes(target)
		TriggerEvent('qf_skinmenu:takeClothes', cachePed, target)
	end

	local function CanCuff(src) 
		local gracz = src

		if not gracz then 
			return 
		end

		local can = false

		local playerIndex = NetworkGetPlayerIndexFromPed(gracz)
		if playerIndex ~= -1 then
			local sid = GetPlayerServerId(playerIndex)
			if sid and Player(sid).state.IsDead then
				can = true
				return can
			end
		end

		if IsPedDeadOrDying(gracz, true) and not IsEntityDead(gracz) then
			can = true
			return can
		end

		if IsPlayerDead(gracz) or GetEntityHealth(gracz) == 0 or IsEntityPlayingAnim(gracz, "random@mugging3", "handsup_standing_base", 3) or IsEntityPlayingAnim(gracz, 'dead', 'dead_a', 3) or IsEntityPlayingAnim(gracz, 'mp_arresting', 'idle', 3) or IsEntityPlayingAnim(gracz, "random@arrests@busted", "enter", 3) or IsPedBeingStunned(gracz) then
			can = true
		end

		if IsEntityDead(gracz) then
			can = false
		end
		
		return can
	end

	local function CanPlayerUse(grade)
		return not grade or ESX.PlayerData.job.grade >= grade
	end

	local function CanPlayerUseHidden(grade)
		return not grade or ESX.PlayerData.job.grade >= grade
	end

	local function StartHandcuffTimer()
		if Config.EnableHandcuffTimer and HandcuffTimer then
			ESX.ClearTimeout(HandcuffTimer)
		end
		
		HandcuffTimer = ESX.SetTimeout(Config.HandcuffTimer, function()
			ESX.ShowNotification("Czujesz jak twoje kajdanki luzują się...")
			TriggerEvent('esx_police:unrestPlayerHandcuffs')
			TriggerServerEvent("interact-sound_SV:PlayWithinDistance", 3, "uncuff", 0.3)
		end)
	end

	local function OpenSWATArmoryMenu()
		local options = {
			{
				title = "Zbrojownia #1",
				onSelect = function()
					ox_inventory:openInventory('stash', {id = 'policeswat1'})
				end
			},
			{
				title = "Zbrojownia #2",
				onSelect = function()
					ox_inventory:openInventory('stash', {id = 'policeswat2'})
				end
			}
		}

		lib.registerContext({
			id = "OpenSWATArmoryMenu",
			title = "Zbrojownie S.W.A.T.",
			options = options
		})

		lib.showContext("OpenSWATArmoryMenu")
	end

	local function OpenHCArmoryMenu()
		local options = {
			{
				title = "Kontrabanda",
				onSelect = function()
					ox_inventory:openInventory('stash', {id = 'policehc1'})
				end
			},
			{
				title = "Narkotyki",
				onSelect = function()
					ox_inventory:openInventory('stash', {id = 'policehc2'})
				end
			}
		}

		lib.registerContext({
			id = "OpenHCArmoryMenu",
			title = "Zbrojownie HC",
			options = options
		})

		lib.showContext("OpenHCArmoryMenu")
	end

	local function CreateOrResetPoliceStash()
		local input = lib.inputDialog('Schowek prywatny', {
			{type = 'input', label = 'Podaj unikalny ID (min 4 znaki)', required = true, min = 4, max = 20},
			{type = 'input', label = 'Ustaw PIN (min 4 cyfry)', password = true, required = true, min = 4, max = 8},
			{type = 'input', label = 'Powtórz PIN', password = true, required = true, min = 4, max = 8}
		})

		if not input or not input[1] or not input[2] or not input[3] then return end
		local id, pin, pin2 = input[1], input[2], input[3]

		if #id < 4 or #id > 20 then
			ESX.ShowNotification('ID schowka musi mieć od 4 do 20 znaków')
			return
		end

		if #pin < 4 or #pin > 8 then
			ESX.ShowNotification('PIN musi mieć od 4 do 8 cyfr')
			return
		end

		if pin ~= pin2 then
			ESX.ShowNotification('PIN-y nie są identyczne!')
			return
		end

		TriggerServerEvent('esx_police:createOrResetStash', id, pin)
	end

	local function OpenPoliceStashByID()
		local input = lib.inputDialog('Otwórz prywatny schowek', {
			{type = 'input', label = 'Podaj ID szafki', required = true, min = 4, max = 20},
			{type = 'input', label = 'PIN', password = true, required = true, min = 4, max = 8}
		})

		if not input or not input[1] or not input[2] then return end

		local id, pin = input[1], input[2]
		TriggerServerEvent('esx_police:openStashByID', id, pin)
	end

	RegisterNetEvent('esx_police:openStash', function(stashId)
		ox_inventory:openInventory('stash', {id = stashId})
	end)

	local function OpenPharmacyMenuSchowek()
		local options = {
			{title = "Kontrabanda", onSelect = function() ox_inventory:openInventory('stash', {id = ESX.PlayerData.job.name .. 'schowek1'}) end},
			{title = "Narkotyki",   onSelect = function() ox_inventory:openInventory('stash', {id = ESX.PlayerData.job.name .. 'schowek2'}) end},
			{title = "Stwórz / zresetuj prywatny schowek", onSelect = CreateOrResetPoliceStash},
			{title = "Otwórz prywatny schowek", onSelect = OpenPoliceStashByID}
		}

		lib.registerContext({id = "OpenPharmacyMenuSchowek", title = "Schowki", options = options})
		lib.showContext("OpenPharmacyMenuSchowek")
	end

	local function CleanPlayer()
		ClearPedBloodDamage(cachePed)
		ResetPedVisibleDamage(cachePed)
		ClearPedLastWeaponDamage(cachePed)
		ResetPedMovementClipset(cachePed, 0)
	end
	
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
		ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
			UniformsData = data or {}
		end)
	end

	local function OpenCloakroomMenu()
		ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
			UniformsData = data or {}
			
			local xPlayer = ESX.PlayerData
			local isPolice = xPlayer.job.name == "police" or xPlayer.job.name == "sheriff"
			local isManagement = isPolice and xPlayer.job.grade >= 11

			local categoryPriority = {
				["Służbowe"] = 1,
				["SWAT"] = 2,
				["AIAD"] = 3,
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
		ESX.TriggerServerCallback('vwk/police/getUniforms', function(uniformsData)
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
				{value = "SWAT", label = "S.W.A.T."},
				{value = "AIAD", label = "A.I.A.D."}
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

				ESX.TriggerServerCallback('vwk/police/addUniform', function(success)
					if success then
						ESX.ShowNotification("Dodano mundur: "..uniformName.." (kategoria: "..finalCategory..")")
						ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
		ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
							
							ESX.TriggerServerCallback('vwk/police/renameUniform', function(success)
								if success then
									ESX.ShowNotification("Zmieniono nazwę munduru z \""..name.."\" na \""..newName.."\"")
									ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
		ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
							
							ESX.TriggerServerCallback('vwk/police/copyUniform', function(success)
								if success then
									ESX.ShowNotification("Skopiowano mundur: "..name.." jako "..newName)
									ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
		ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
							
							ESX.TriggerServerCallback('vwk/police/setUniformMinGrade', function(success)
								if success then
									ESX.ShowNotification("Ustawiono minimalny grade: "..newMinGrade.." dla munduru: "..name)
									ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
					ESX.TriggerServerCallback('vwk/police/removeUniform', function(success)
						if success then
							ESX.ShowNotification("Usunięto mundur: "..name)
							ESX.TriggerServerCallback('vwk/police/getUniforms', function(data)
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
	
	local function OpenVehicleSpawnerMenu(partNum)
		local vehicles = Config.PoliceStations.Cars.Vehicles
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
						if vehicle.hidden == true then
							if i ~= 7 then
								if not CanPlayerUseHidden(vehicle.grade) then
									let = false
								end
							else
								if not CanPlayerUseHidden(vehicle.grade) and not CanPlayerUse(vehicle.grade) then
									let = false
								end
							end
						else
							if not CanPlayerUse(vehicle.grade) then
								let = false
							end
						end
					elseif vehicle.grades and #vehicle.grades > 0 then
						let = false
						for _, grade in ipairs(vehicle.grades) do
							if ((vehicle.swat) or grade <= ESX.PlayerData.job.grade) and (not vehicle.label:find('SEU')) then
								let = true
								break
							end
						end
					end

					if let or ((ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") and ESX.PlayerData.job.grade >= 10) then
						table.insert(elements2, { label = vehicle.label, model = vehicle.model, livery = vehicle.livery, extrason = vehicle.extrason, extrasoff = vehicle.extrasoff, offroad = vehicle.offroad, wheelsxd = vehicle.wheelsxd, color = vehicle.color, plate = vehicle.plate, tint = vehicle.tint, bulletproof = vehicle.bulletproof, wheel = vehicle.wheel, tuning = vehicle.tuning })
					end
				end
			end

			if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") and ESX.PlayerData.job.grade >= 10 then
				if #elements2 > 0 then
					table.insert(elements, { label = group, value = elements2, group = i })				
				end
			else
				if i == 5 then
					found = false
					if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
							if hasWeaponLicense then
								table.insert(elements, { label = group, value = elements2, group = i })
							end

							found = true
						end, cacheServerId, 'dtu')
					end
				elseif i == 6 then
					found = false
					if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
							if hasWeaponLicense then
								table.insert(elements, { label = group, value = elements2, group = i })
							end

							found = true
						end, cacheServerId, 'seu')
					end
				elseif i == 7 then
					found = false
					if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
							if hasWeaponLicense then
								table.insert(elements, { label = group, value = elements2, group = i })
							end

							found = true
						end, cacheServerId, 'swat')
					end
				elseif i == 8 then
					found = false
					if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
						ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
							if hasWeaponLicense then
								table.insert(elements, { label = group, value = elements2, group = i })
							end

							found = true
						end, cacheServerId, 'hp')
					end
				else
					if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
						table.insert(elements, { label = group, value = elements2, group = i })
					end
				end
			end
		end

		while not found do
			Citizen.Wait(100)
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
											ESX.TriggerServerCallback('esx_police:getBadge', function(badgeString)
													local badgeNumber = nil
													if badgeString then
														badgeNumber = tonumber(badgeString:match("%[(%d+)%]"))
													end
													
													ESX.Game.SpawnVehicle(sub.model, {
														x = vehicles[partNum].spawnPoint.x,
														y = vehicles[partNum].spawnPoint.y,
														z = vehicles[partNum].spawnPoint.z
													}, vehicles[partNum].heading, function(vehicle)
														SetVehicleMaxMods(vehicle, livery, offroad, wheelsxd, color, sub.extrason, sub.extrasoff, bulletproof, tint, wheel, tuning)

														if badgeNumber then
															local formattedBadge = string.format("%03d", badgeNumber)
															local leftDigit = tonumber(formattedBadge:sub(1, 1))
															local middleDigit = tonumber(formattedBadge:sub(2, 2))
															local rightDigit = tonumber(formattedBadge:sub(3, 3))
															SetVehicleMod(vehicle, 8, leftDigit, false)
															SetVehicleMod(vehicle, 9, middleDigit, false)
															SetVehicleMod(vehicle, 10, rightDigit, false)
														end

														if setPlate then
															local plate = ""
															local platePrefix = "LSPD"
															if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff" then
																platePrefix = "SASD"
															end
															if el.group == 5 then
																plate = "UM" .. math.random(1111, 9999)
															else
																if badgeNumber then
																	plate = platePrefix .. badgeNumber
																else
																	plate = platePrefix .. math.random(1111, 9999)
																end
															end
															SetVehicleNumberPlateText(vehicle, plate)
															Citizen.Wait(100)
															TriggerServerEvent("esx_carkeys:getKeys", plate)
														end
															Entity(vehicle).state.fuel = 50
															TaskWarpPedIntoVehicle(cachePed, vehicle, -1)
															Citizen.Wait(500)
															local status = IsVehicleEngineOn(vehicle)
															lib.callback('esx_carkeys:ToggleEngine', false, function(data)
																if data then
																	if not status then 
																		if data == "Key" then 
																			return ESX.ShowNotification("Znalazłeś kluczyki do pojazdu.") 
																		end
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
														end, not status, true)
													end)
												end, GetPlayerServerId(PlayerId()))
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
							ESX.ShowNotification("Brak pojazdów w tej kategorii")
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

	local function OpenBoatsSpawnerMenu(partNum)
		local Boats = Config.PoliceStations.Cars.Boats
		local elements = {}
		for i, group in ipairs(Config.BoatsGroups) do
			if (i ~= 10 and i ~= 6) or i == 10 then
				local elements2 = {}
				for _, lodz in ipairs(Config.AuthorizedBoats) do
					local let = false
					for _, groupv in ipairs(lodz.groups) do
						if groupv == i then
							let = true
							break
						end
					end

				if let then
					if lodz.grade then
						if not CanPlayerUse(lodz.grade) or (lodz.label:find('SEU')) then
							let = false
						end
					elseif lodz.grades and #lodz.grades > 0 then
						let = false
						for _, grade in ipairs(lodz.grades) do
							if ((lodz.swat) or grade <= ESX.PlayerData.job.grade) and (not lodz.label:find('SEU')) then
								let = true
								break
							end
						end
					end

						if let or ((ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") and ESX.PlayerData.job.grade >= 10) then
							table.insert(elements2, { label = lodz.label, model = lodz.model, livery = lodz.livery, offroad = lodz.offroad, wheelsxd = lodz.wheelsxd, color = lodz.color, extrason = lodz.extrason, extrasoff = lodz.extrasoff, plate = lodz.plate, tint = lodz.tint, bulletproof = lodz.bulletproof, wheel = lodz.wheel, tuning = lodz.tuning })
						end
					end
				end

				if #elements2 > 0 then
					table.insert(elements, { label = group, value = elements2, group = i })
				end
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
										lib.showContext("Boats_spawner")
									end
								}
							}
							for j = 1, #el.value do
								local sub = el.value[j]
								table.insert(subOptions, {
									title = sub.label,
									onSelect = function()
										local livery = sub.livery
										local offroad = sub.offroad
										local wheelsxd = sub.wheelsxd
										local color = sub.color
										local extrason = sub.extrason
										local extrasoff = sub.extrasoff
										local bulletproof = sub.bulletproof or false
										local tint = sub.tint
										local wheel = sub.wheel
										local tuning = sub.tuning

										local setPlate = true
										if sub.plate ~= nil and not sub.plate then
											setPlate = false
										end

										local lodz = GetClosestVehicle(Boats[partNum].spawnPoint.x,  Boats[partNum].spawnPoint.y,  Boats[partNum].spawnPoint.z, 3.0, 0, 71)
										if not DoesEntityExist(lodz) then
											ESX.Game.SpawnVehicle(sub.model, {
												x = Boats[partNum].spawnPoint.x,
												y = Boats[partNum].spawnPoint.y,
												z = Boats[partNum].spawnPoint.z
											}, Boats[partNum].heading, function(lodz)
												SetVehicleMaxMods(lodz, livery, offroad, wheelsxd, color, extrason, extrasoff, bulletproof, tint, wheel, tuning)
												if setPlate then
													local plate = ""
													local platePrefix = "LSPD"
													if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff" then
														platePrefix = "SASD"
													end
													if el.group == 5 then
														plate = "UM" .. math.random(1111, 9999)
													else
														plate = platePrefix .. math.random(1111, 9999)
													end
													SetVehicleNumberPlateText(lodz, plate)
													Citizen.Wait(100)
													TriggerServerEvent("esx_carkeys:getKeys", plate)
												end
												Entity(lodz).state.fuel = 100
												TaskWarpPedIntoVehicle(cachePed, lodz, -1)
											end)
										else
											ESX.ShowNotification('Pojazd znaduje się w miejscu wyciągnięcia następnego')
										end
									end
								})
							end
							lib.registerContext({
								id = "Boats_spawner_" .. (el.group or "sub"),
								title = el.label,
								options = subOptions
							})
							lib.showContext("Boats_spawner_" .. (el.group or "sub"))
						end
					end
				})
			end

			lib.registerContext({
				id = "Boats_spawner",
				title = "Łodzie",
				options = mainOptions
			})

			lib.showContext("Boats_spawner")
		end

		showMainContext()
	end

	local function OpenBodySearchMenu(src)
		ESX.UI.Menu.CloseAll()
		TriggerServerEvent(Event12, 'Przeszukuje')
		ox_inventory:openInventory('player', src)
	end

	local function StartBar(time, search, text)
		if search == nil then search = false end

		if search then
			lib.requestAnimDict('anim@gangops@facility@servers@bodysearch@')
			TaskPlayAnim(cachePed, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
		else
			lib.requestAnimDict('mp_arrest_paired')
			TaskPlayAnim(cachePed, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
		end

		Citizen.Wait(1000)
		ClearPedTasks(cachePed)
	end

	RegisterNetEvent('esx_police:getarrested')
	AddEventHandler('esx_police:getarrested', function(playerheading, playercoords, playerlocation)
		LocalPlayer.state:set('IsHandcuffed', not LocalPlayer.state.IsHandcuffed, true)
		local x, y, z   = table.unpack(playercoords + playerlocation * 1.0)

		SetEntityCoords(cachePed, x, y, z)
		SetEntityHeading(cachePed, playerheading)
		Citizen.Wait(250)
		TriggerServerEvent("interact-sound_SV:PlayWithinDistance", 5, "Cuff", 0.25)
		lib.requestAnimDict('mp_arrest_paired')
		TaskPlayAnim(cachePed, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750 , 2, 0, 0, 0, 0)
		Citizen.Wait(3760)
		lib.requestAnimDict('mp_arresting')
		TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
		
		Citizen.CreateThread(function()
			if LocalPlayer.state.IsHandcuffed then
				if not LocalPlayer.state.IsDead then
					local success = lib.skillCheck({'hard'}, {'e'})

					if not success then
						if not LocalPlayer.state.InTrunk then
							lib.requestAnimDict('mp_arresting')
							while not HasAnimDictLoaded('mp_arresting') do
								Citizen.Wait(0)
							end
			
							if not IsEntityPlayingAnim(cachePed, 'mp_arresting', 'idle', 3) then
								TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
							end
						end
						
						ESX.UI.Menu.CloseAll()
						SetCurrentPedWeapon(cachePed, `WEAPON_UNARMED`, true)
						DisablePlayerFiring(cachePed, true)
						SetEnableHandcuffs(cachePed, true)
						SetPedCanPlayGestureAnims(cachePed, false)
						StartHandcuffTimer()
					else
						ESX.ShowNotification('Udało ci się wyrwać!')
						ClearPedTasks(cachePed)
						if Config.EnableHandcuffTimer and HandcuffTimer then
							ESX.ClearTimeout(HandcuffTimer)
						end
						SetEnableHandcuffs(cachePed, false)
						DisablePlayerFiring(cachePed, false)
						SetPedCanPlayGestureAnims(cachePed, true)
						FreezeEntityPosition(cachePed, false)
						LocalPlayer.state:set('IsHandcuffed', false, true)
					end
				else
					if not LocalPlayer.state.InTrunk then
						lib.requestAnimDict('mp_arresting')
						while not HasAnimDictLoaded('mp_arresting') do
							Citizen.Wait(0)
						end
		
						if not IsEntityPlayingAnim(cachePed, 'mp_arresting', 'idle', 3) then
							TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
						end
					end
					
					ESX.UI.Menu.CloseAll()
					SetCurrentPedWeapon(cachePed, `WEAPON_UNARMED`, true)
					DisablePlayerFiring(cachePed, true)
					SetEnableHandcuffs(cachePed, true)
					SetPedCanPlayGestureAnims(cachePed, false)
					StartHandcuffTimer()
				end
			else
				TriggerServerEvent("interact-sound_SV:PlayWithinDistance", 5, "uncuff", 0.25)
				ClearPedTasks(cachePed)
				if Config.EnableHandcuffTimer and HandcuffTimer then
					ESX.ClearTimeout(HandcuffTimer)
				end
				SetEnableHandcuffs(cachePed, false)
				DisablePlayerFiring(cachePed, false)
				SetPedCanPlayGestureAnims(cachePed, true)
				FreezeEntityPosition(cachePed, false)
				if LocalPlayer.state.InTrunk then
					TaskPlayAnim(cachePed, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
				end
			end
		end)
	end)


	RegisterNetEvent('esx_police:doarrested')
	AddEventHandler('esx_police:doarrested', function()
		lib.requestAnimDict('mp_arrest_paired')
		TaskPlayAnim(cachePed, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8,3750, 2, 0, 0, 0, 0)
		Citizen.Wait(3000)
	end) 

	
	AddEventHandler('esx_police:hasEnteredMarker', function(station, partNum)
		if station == 'Vehicles' then
			CurrentAction     = 'menu_vehicle_spawner'
			CurrentActionMsg  = {text = 'Naciśnij', button = 'E', description = 'aby wyciągnąć pojazd.'}
			CurrentActionData = {partNum = partNum}
		elseif station == 'Boats' then
			CurrentAction     = 'menu_Boats_spawner'
			CurrentActionMsg  = {text = 'Naciśnij', button = 'E', description = 'aby wyciągnąć łódź.'}
			CurrentActionData = {partNum = partNum}
		elseif station == 'Helicopters' then
			CurrentAction = 'menu_helicopter_spawner'
			CurrentActionMsg = {text = 'Naciśnij', button = 'E', description = 'aby wyciągnąć helikopter.'}
			CurrentActionData = {partNum = partNum}
		elseif station == 'VehicleAddons' and cacheVehicle then
			CurrentAction = 'menu_dodatki'
			CurrentActionMsg = {text = 'Naciśnij', button = 'E', description = 'aby zmienić dodatki w pojeździe.'}
			CurrentActionData = {}
		elseif station == 'VehicleFix' and cacheVehicle then
			CurrentAction = 'menu_fixing'
			CurrentActionMsg = {text = 'Naciśnij', button = 'E', description = 'aby naprawić pojazd.'}
			CurrentActionData = {}
		elseif station == 'VehicleDeleters' and cacheVehicle then
			local vehicle, distance = ESX.Game.GetClosestVehicle({
				x = cacheCoords.x,
				y = cacheCoords.y,
				z = cacheCoords.z
			})

			CurrentAction     = 'delete_vehicle'
			CurrentActionMsg  = {text = 'Naciśnij', button = 'E', description = 'aby schować pojazd.'}
			CurrentActionData = {vehicle = vehicle}
		end
	end)
	
	AddEventHandler('esx_police:hasExitedMarker', function()
		exports["esx_hud"]:hideHelpNotification()
		CurrentAction = nil
	end)

	RegisterNetEvent('esx_police:HandcuffOnPlayer')
	AddEventHandler('esx_police:HandcuffOnPlayer', function(afterMedic)
		LocalPlayer.state:set('IsHandcuffed', not LocalPlayer.state.IsHandcuffed, true)

		Citizen.CreateThread(function()
			if afterMedic then
				if LocalPlayer.state.IsHandcuffed then
					ESX.UI.Menu.CloseAll()
					SetCurrentPedWeapon(cachePed, `WEAPON_UNARMED`, true)
					DisablePlayerFiring(cachePed, true)
					SetEnableHandcuffs(cachePed, true)
					SetPedCanPlayGestureAnims(cachePed, false)
					StartHandcuffTimer()
				else
					ClearPedTasks(cachePed)

					if Config.EnableHandcuffTimer and HandcuffTimer then
						ESX.ClearTimeout(HandcuffTimer)
					end

					SetEnableHandcuffs(cachePed, false)
					DisablePlayerFiring(cachePed, false)
					SetPedCanPlayGestureAnims(cachePed, true)
					FreezeEntityPosition(cachePed, false)
				end
			else
				if LocalPlayer.state.IsHandcuffed then
					TriggerServerEvent("interact-sound_SV:PlayWithinDistance", 5, "Cuff", 0.25)

					if not LocalPlayer.state.IsDead then
						local success = lib.skillCheck({'hard'}, {'e'})

						if not success then
							if not LocalPlayer.state.InTrunk then
								lib.requestAnimDict('mp_arresting')
			
								if not IsEntityPlayingAnim(cachePed, 'mp_arresting', 'idle', 3) then
									TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
								end
							end
							
							ESX.UI.Menu.CloseAll()
							SetCurrentPedWeapon(cachePed, `WEAPON_UNARMED`, true)
							DisablePlayerFiring(cachePed, true)
							SetEnableHandcuffs(cachePed, true)
							SetPedCanPlayGestureAnims(cachePed, false)
							StartHandcuffTimer()
						else
							ESX.ShowNotification('Udało ci się wyrwać!')
							ClearPedTasks(cachePed)
							if Config.EnableHandcuffTimer and HandcuffTimer then
								ESX.ClearTimeout(HandcuffTimer)
							end
							SetEnableHandcuffs(cachePed, false)
							DisablePlayerFiring(cachePed, false)
							SetPedCanPlayGestureAnims(cachePed, true)
							FreezeEntityPosition(cachePed, false)
							LocalPlayer.state:set('IsHandcuffed', false, true)
						end
					else
						if not LocalPlayer.state.InTrunk then
							lib.requestAnimDict('mp_arresting')
		
							if not IsEntityPlayingAnim(cachePed, 'mp_arresting', 'idle', 3) then
								TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
							end
						end
						
						ESX.UI.Menu.CloseAll()
						SetCurrentPedWeapon(cachePed, `WEAPON_UNARMED`, true)
						DisablePlayerFiring(cachePed, true)
						SetEnableHandcuffs(cachePed, true)
						SetPedCanPlayGestureAnims(cachePed, false)
						StartHandcuffTimer()
					end
				else
					TriggerServerEvent("interact-sound_SV:PlayWithinDistance", 5, "uncuff", 0.25)
	
					ClearPedTasks(cachePed)
					if Config.EnableHandcuffTimer and HandcuffTimer then
						ESX.ClearTimeout(HandcuffTimer)
					end
					SetEnableHandcuffs(cachePed, false)
					DisablePlayerFiring(cachePed, false)
					SetPedCanPlayGestureAnims(cachePed, true)
					FreezeEntityPosition(cachePed, false)
					
					if LocalPlayer.state.InTrunk then
						TaskPlayAnim(cachePed, "fin_ext_p1-7", "cs_devin_dual-7", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
					end
				end
			end
		end)
	end)
		
	RegisterNetEvent('esx_police:unrestPlayerHandcuffs')
	AddEventHandler('esx_police:unrestPlayerHandcuffs', function(afterMedic)
		if afterMedic then
			if LocalPlayer.state.IsHandcuffed then
				LocalPlayer.state:set('IsHandcuffed', false, true)

				ClearPedTasks(cachePed)
				if Config.EnableHandcuffTimer and HandcuffTimer then
					ESX.ClearTimeout(HandcuffTimer)
				end
	
				SetEnableHandcuffs(cachePed, false)
				DisablePlayerFiring(cachePed, false)
				SetPedCanPlayGestureAnims(cachePed, true)
				FreezeEntityPosition(cachePed, false)
			end
		else
			if LocalPlayer.state.IsHandcuffed then
				LocalPlayer.state:set('IsHandcuffed', false, true)
				TriggerServerEvent('interact-sound_SV:PlayWithinDistance', 4.5, 'uncuff', 0.2)
				ClearPedTasks(cachePed)
				if Config.EnableHandcuffTimer and HandcuffTimer then
					ESX.ClearTimeout(HandcuffTimer)
				end
	
				SetEnableHandcuffs(cachePed, false)
				DisablePlayerFiring(cachePed, false)
				SetPedCanPlayGestureAnims(cachePed, true)
				FreezeEntityPosition(cachePed, false)
			end
		end
	end)

	RegisterNetEvent('esx_police:drag')
	AddEventHandler('esx_police:drag', function(cop)
		if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead then
			IsDragged = not IsDragged
			CopPlayer = tonumber(cop)
			LocalPlayer.state:set('DraggingById', CopPlayer, true)
		end
	end)

	RegisterNetEvent('esx_police:dragging')
	AddEventHandler('esx_police:dragging', function(target, dropped)
		if dropped then
			if Dragging ~= nil then
				Dragging = nil
				LocalPlayer.state:set('canUseWeapons', true, false)
			end
		else
			if Dragging ~= target then
				Dragging = target
				LocalPlayer.state:set('canUseWeapons', false, false)
			end
		end
	end)

	local function stopDragging(notifyServer)
		if CopPlayer then
			if DoesEntityExist(cachePed) then
				DetachEntity(cachePed, true, false)
				FreezeEntityPosition(cachePed, false)
			end
			
			if notifyServer then
				TriggerServerEvent(Event3, CopPlayer, nil)
			end
			
			CopPlayer = nil
		end
		
		if cacheCoords then
			RequestCollisionAtCoord(cacheCoords.x, cacheCoords.y, cacheCoords.z)
		end
		
		IsDragged = false
		LocalPlayer.state:set('DraggingById', nil, true)
	end

	Citizen.CreateThread(function()
		local attached = false
		
		while true do
			local waitTime = 500
			local isRestrained = LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead
			
			if isRestrained then
				if IsDragged and CopPlayer then
					if DoesEntityExist(cachePed) then
						if not attached then
							local copServerId = CopPlayer
							local copPlayerId = GetPlayerFromServerId(copServerId)
							
							if copPlayerId ~= -1 then
								local copPed = GetPlayerPed(copPlayerId)

								if DoesEntityExist(copPed) then
									attached = true
									FreezeEntityPosition(cachePed, true)
									AttachEntityToEntity(
										cachePed, 
										copPed, 
										11816, -- bone index
										0.54, 0.15, 0.0, -- offset
										0.0, 0.0, 0.0, -- rotation
										false, true, false, true, 2, true
									)
								end
							end
						end
						waitTime = 0
					else
						waitTime = 100
					end
				elseif CopPlayer then
					if attached then
						attached = false
					end
					stopDragging(true)
					waitTime = 0
				else
					waitTime = 100
				end
			else
				if IsDragged then
					if attached then
						attached = false
					end
					stopDragging(true)
				end
				waitTime = 500
			end
			
			Citizen.Wait(waitTime)
		end
	end)

	Citizen.CreateThread(function()
		local isDraggingAnim = false
		local animDict = 'random@atmrobberygen'
		local animName = 'b_atm_mugging'
		
		while true do
			local sleep = 500
			
			if Dragging then
				sleep = 0
				local targetPed = GetPlayerPed(GetPlayerFromServerId(Dragging))
				local targetPlayer = Player(Dragging)
				local isActuallyDragging = targetPlayer and targetPlayer.state.DraggingById == cacheServerId
				local isTargetDead = targetPlayer and targetPlayer.state.IsDead ~= nil and targetPlayer.state.IsDead == true
				
				if DoesEntityExist(targetPed) and isActuallyDragging and not IsPedInAnyVehicle(cachePed, false) then
					if not isTargetDead then
						if not isDraggingAnim then
							lib.requestAnimDict(animDict)
							if HasAnimDictLoaded(animDict) then
								TaskPlayAnim(cachePed, animDict, animName, 8.0, -8.0, -1, 49, 0.0, false, false, false)
								isDraggingAnim = true
							end
						end
					else
						if isDraggingAnim then
							ClearPedTasks(cachePed)
							isDraggingAnim = false
						end
					end
				else
					if isDraggingAnim then
						ClearPedTasks(cachePed)
						isDraggingAnim = false
					end
				end
			else
				if isDraggingAnim then
					ClearPedTasks(cachePed)
					isDraggingAnim = false
				end
			end
			
			Citizen.Wait(sleep)
		end
	end)

	RegisterNetEvent('esx_police:putInTrunk')
	AddEventHandler('esx_police:putInTrunk', function(vehicleNetId)
		if LocalPlayer.state.IsHandcuffed then
			if vehicleNetId then
				local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
				
				if vehicle and DoesEntityExist(vehicle) then
					TriggerEvent('esx_core:forceInTrunk', vehicle)
				else
					ESX.ShowNotification('Nie znaleziono pojazdu!')
				end
			else
				local vehicle, distance = ESX.Game.GetClosestVehicle()
				if vehicle and distance < 5 then
					TriggerEvent('esx_core:forceInTrunk', vehicle)
				else
					ESX.ShowNotification('Nie znaleziono pojazdu w pobliżu!')
				end
			end
		end
	end)

	RegisterNetEvent('esx_police:OutTrunk')
	AddEventHandler('esx_police:OutTrunk', function()
		if LocalPlayer.state.IsHandcuffed then
			lib.requestAnimDict('mp_arresting')
			TriggerEvent('esx_core:forceOutTrunk')
			TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		else
			TriggerEvent('esx_core:forceOutTrunk')
		end
	end)

	RegisterNetEvent('esx_police:putInVehicle')
	AddEventHandler('esx_police:putInVehicle', function()
		if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead then
			LocalPlayer.state:set('InsideVehicle', true, true)
			local vehicle, distance = ESX.Game.GetClosestVehicle()
		
			if vehicle and distance < 5 then
				local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
		
				for i = maxSeats - 1, 0, -1 do
					if IsVehicleSeatFree(vehicle, i) then
						freeSeat = i
						break
					end
				end
		
				if freeSeat then
					TaskWarpPedIntoVehicle(cachePed, vehicle, freeSeat)
				end
			end
		end
	end)
	
	RegisterNetEvent('esx_police:OutVehicle')
	AddEventHandler('esx_police:OutVehicle', function()
		if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead then
			if IsPedSittingInAnyVehicle(cachePed) then
				LocalPlayer.state:set('InsideVehicle', false, true)
				TaskLeaveVehicle(cachePed, cacheVehicle, 64)
				ClearPedTasks(cachePed)
			end
		end
	end)

	Citizen.CreateThread(function()
		lib.requestAnimDict('mp_arresting')

		while true do
			local sleep = 1000
			if LocalPlayer.state.IsHandcuffed then	
				sleep = 0
				DisableControlAction(2, 24, true)
				DisableControlAction(2, 257, true) 
				DisableControlAction(2, 25, true)
				DisableControlAction(2, 263, true)
				DisableControlAction(2, Keys["R"], true)
				DisableControlAction(2, Keys["TOP"], true) 
				DisableControlAction(2, Keys["SPACE"], true) 
				DisableControlAction(2, Keys["Q"], true) 
				DisableControlAction(2, Keys["~"], true) 
				DisableControlAction(2, Keys["Y"], true) 
				DisableControlAction(2, Keys["B"], true)
				DisableControlAction(2, Keys["TAB"], true) 
				DisableControlAction(2, Keys["F1"], true)
				DisableControlAction(2, Keys["F2"], true) 
				DisableControlAction(2, Keys["F3"], true) 
				DisableControlAction(2, Keys["F6"], true)
				DisableControlAction(2, 75, true)
				DisableControlAction(2, Keys["centerSHIFT"], true)
				DisableControlAction(2, Keys["V"], true) 
				DisableControlAction(2, Keys["P"], true) 
				DisableControlAction(2, 59, true) 
				DisableControlAction(2, Keys["centerCTRL"], true) 
				DisableControlAction(0, 47, true) 
				DisableControlAction(0, 264, true) 
				DisableControlAction(0, 257, true) 
				DisableControlAction(0, 140, true) 
				DisableControlAction(0, 141, true) 
				DisableControlAction(0, 142, true) 
				DisableControlAction(0, 143, true)
				DisableControlAction(0, 56, true)
				DisableControlAction(0, 75, true)
				DisableControlAction(27, 75, true)
				DisableControlAction(0, Keys["F"], true)

				if IsPedInAnyVehicle(cachePed, false) then
					DisableControlAction(0, 75, true)
					DisableControlAction(27, 75, true)
					DisableControlAction(0, Keys["F"], true)
				end

				if IsPedInAnyPoliceVehicle(cachePed) then
					DisableControlAction(0, 75, true) 
					DisableControlAction(27, 75, true)
				end

				if not IsEntityPlayingAnim(cachePed, 'mp_arresting', 'idle', 3) and not LocalPlayer.state.InTrunk then
					TaskPlayAnim(cachePed, 'mp_arresting', 'idle', 8.0, 1.0, -1, 49, 1.0, 0, 0, 0)
				end
			end
			Citizen.Wait(sleep)
		end
	end)

	Citizen.CreateThread(function()
		for i=1, #Config.Blips, 1 do
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
			Citizen.Wait(100)
		end
		while true do
			Citizen.Wait(0)
			local found = false
			if ESX.PlayerData.job ~= nil and ((ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff")) then
				for k,v in pairs(Config.PoliceStations.Cars) do
					for i=1, #v, 1 do
						if (k == "VehicleDeleters" or k == "VehicleAddons" or k == "VehicleFix") then
							if cacheVehicle then
								local vehicleCoords = GetEntityCoords(cacheVehicle)
								if #(vehicleCoords - v[i].coords) < Config.DrawDistance then
									found = true
									ESX.DrawBigMarker(v[i].coords)
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
			Citizen.Wait(0)
			if ESX.PlayerData.job ~= nil and ((ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff")) then
				local isInMarker     = false
				local found = false
				local currentStation = nil
				local currentPartNum = nil

				for k,v in pairs(Config.PoliceStations.Cars) do
					for i=1, #v, 1 do
						if k == "VehicleDeleters" or k == 'VehicleAddons' or k == 'VehicleFix' then
							if cacheVehicle then
								local vehicleCoords = GetEntityCoords(cacheVehicle)
								if #(vehicleCoords - v[i].coords) < 3.0 then
									found = true
									isInMarker     = true
									currentStation = k
									currentPartNum = i
								end
							end
						end
						
						if k ~= "VehicleDeleters" and k ~= 'VehicleAddons' and k ~= 'VehicleFix' then
							if #(cacheCoords - v[i].coords) < Config.MarkerSize.x then
								found = true
								isInMarker     = true
								currentStation = k
								currentPartNum = i
							end
						end
					end
				end

				local hasExited = false

				if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPartNum ~= currentPartNum)) then

					if (LastStation ~= nil and LastPartNum ~= nil) and (LastStation ~= currentStation or LastPartNum ~= currentPartNum) then
						TriggerEvent('esx_police:hasExitedMarker')
						hasExited = true
					end

					HasAlreadyEnteredMarker = true
					LastStation             = currentStation
					LastPartNum             = currentPartNum
		
					TriggerEvent('esx_police:hasEnteredMarker', currentStation, currentPartNum)
				end

				if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
					HasAlreadyEnteredMarker = false
					TriggerEvent('esx_police:hasExitedMarker')
				end
			
				if not found then
					Citizen.Wait(1000)
				end
			else
				Citizen.Wait(2000)
			end
		end
	end)

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

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sklep_dodatki_policja', {
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

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sklep_dodatki_policja_usun', {
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
							TriggerServerEvent(Event8, tablica, dodatekTekst, false)
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

					ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sklep_dodatki_policja_kup', {
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
							TriggerServerEvent(Event8, tablica, dodatekTekst, true)
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
		
	local function SpawnHelicopter(partNum)
		local helicopters = Config.PoliceStations.Cars.Helicopters
		local helimodel = "polmav"
		
		if not IsAnyVehicleNearPoint(helicopters[partNum].spawnPoint.x, helicopters[partNum].spawnPoint.y, helicopters[partNum].spawnPoint.z, 3.0) then
			ESX.TriggerServerCallback('esx_police:getBadge', function(badgeString)
				local badgeNumber = nil
				if badgeString then
					badgeNumber = tonumber(badgeString:match("%[(%d+)%]"))
				end
				
				ESX.Game.SpawnVehicle(helimodel, helicopters[partNum].spawnPoint, helicopters[partNum].heading, function(vehicle)
					if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff" then
						SetVehicleLivery(vehicle, 1)
						SetVehicleColours(vehicle, 0, 10)
					else
						SetVehicleLivery(vehicle, 0)
						SetVehicleColours(vehicle, 0, 111)
					end
					Entity(vehicle).state.fuel = 100
					local plate = ""
					local platePrefix = "LSPD"
					if ESX.PlayerData and ESX.PlayerData.job and ESX.PlayerData.job.name == "sheriff" then
						platePrefix = "SASD"
					end
					if badgeNumber then
						plate = platePrefix .. badgeNumber
					else
						plate = platePrefix .. math.random(1111, 9999)
					end
					SetVehicleNumberPlateText(vehicle, plate)
					Citizen.Wait(100)
					TriggerServerEvent("esx_carkeys:getKeys", plate)
				end)
			end)
		else
			ESX.ShowNotification('Lądowisko jest zajęte!')
		end
	end

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if ESX.PlayerData.job ~= nil and ((ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff")) then
				if CurrentAction ~= nil then
					exports["esx_hud"]:helpNotification(CurrentActionMsg.text, CurrentActionMsg.button, CurrentActionMsg.description)
					if IsControlJustReleased(0, Keys["E"]) then
						if CurrentAction == 'delete_vehicle' then
							local vehProperties = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
							TriggerServerEvent('esx_carkeys:deleteKeys', vehProperties.plate)
							ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
						elseif CurrentAction == 'menu_vehicle_spawner' then
							OpenVehicleSpawnerMenu(CurrentActionData.partNum)
						elseif CurrentAction == 'menu_Boats_spawner' then
							OpenBoatsSpawnerMenu(CurrentActionData.partNum)
						elseif CurrentAction == 'menu_helicopter_spawner' then
							ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
								if hasWeaponLicense then
									SpawnHelicopter(CurrentActionData.partNum)
								else
									ESX.ShowNotification("Nie posiadasz dostępu do tego elementu!")
								end
							end, cacheServerId, 'heli')
						elseif CurrentAction == 'menu_dodatki' then
							OpenDodatkiGarazMenu()
						elseif CurrentAction == 'menu_fixing' then
							if esx_core:CanRepairVehicle() then
								esx_core:RepairVehicle(true, true)
							end
						end
					end
				else
					Citizen.Wait(500)
				end
			else
				Citizen.Wait(1000)
			end
		end
	end)

	RegisterNetEvent('esx_police:removedGPS')
	AddEventHandler('esx_police:removedGPS', function(data)
		local playerName = data.name
		if data.firstName and data.lastName and data.firstName ~= "" and data.lastName ~= "" then
			playerName = data.firstName .. " " .. data.lastName
		end

		TriggerServerEvent('qf_mdt:addDispatchAlertSV', data.coords, 'Utracono połączenie z nadajnikiem!', 'Nadajnik [' .. playerName .. '] przestał wysyłać aktywny sygnał, sprawdźcie jego lokalizacje!', '10-74', 'rgb(192, 222, 0)', '10', 484, 63, 63)
		
		TriggerEvent('chat:sendNewAddonChatMessage', '^*^1[CENTRALA] ', {0, 0, 0}, " ^*^7Utracono połączenie z nadajnikiem ^*^1"..playerName.. " ^*^7!", "fas fa-laptop", {255, 255, 255})

		local alpha = 250
		local gpsBlip = AddBlipForCoord(data.coords)

		SetBlipSprite(gpsBlip, 280)
		SetBlipColour(gpsBlip, 1)
		SetBlipAlpha(gpsBlip, alpha)
		SetBlipScale(gpsBlip, 0.7)
		SetBlipAsShortRange(gpsBlip, false)
		SetBlipCategory(gpsBlip, 15)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("# Ostatnia lokalizacja " .. playerName)
		EndTextCommandSetBlipName(gpsBlip)
		
		for i=1, 25, 1 do
			PlaySound(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0, 0, 1)
			Citizen.Wait(300)
			PlaySound(-1, "OOB_Cancel", "GTAO_FM_Events_Soundset", 0, 0, 1)
			Citizen.Wait(300)
		end
		
		while alpha ~= 0 do
			Citizen.Wait(180 * 4)
			alpha = alpha - 1
			SetBlipAlpha(gpsBlip, alpha)
			if alpha == 0 then
				RemoveBlip(gpsBlip)
				return
			end
		end
	end)
	
	AddEventHandler('onResourceStop', function(resource)
		if resource == GetCurrentResourceName() then
			TriggerEvent('esx_police:unrestPlayerHandcuffs')

			if Config.EnableHandcuffTimer and HandcuffTimer then
				ESX.ClearTimeout(HandcuffTimer)
			end
		end
	end)
	
	local last1013Use = 0
	local COOLDOWN_1013 = 30000

	local function sendPanicButton(type)
		if not (exports.ox_inventory:GetItemCount('panic') > 0) then
			ESX.ShowNotification("Aby wezwać pomoc potrzebujesz Panic Buttona", "error")
			return
		end

		local currentTime = GetGameTimer()
		if currentTime - last1013Use < COOLDOWN_1013 then
			local remainingTime = math.ceil((COOLDOWN_1013 - (currentTime - last1013Use)) / 1000)
			ESX.ShowNotification("Możesz użyć komendy /10-13 za " .. remainingTime .. " sekund")
			return
		end
		
		last1013Use = currentTime
		local radioData = exports["pma-radio"]:GetRadioData()
		local radioChannel = 'Nieznane'

		if radioData[2] > 0 and radioData[2] < 10 then
			radioChannel = radioData[2]
		end
		local Officer = {}
		Officer.Player = cachePlayerId
		Officer.Ped = cachePed
		Officer.Coords = cacheCoords
		Officer.Location = {}
		Officer.Location.Street, Officer.Location.CrossStreet = GetStreetNameAtCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
		Officer.Location.Street = GetStreetNameFromHashKey(Officer.Location.Street)
		if Officer.Location.CrossStreet ~= 0 then
			Officer.Location.CrossStreet = GetStreetNameFromHashKey(Officer.Location.CrossStreet)
			Officer.Location = Officer.Location.Street .. " X " .. Officer.Location.CrossStreet
		else
			Officer.Location = Officer.Location.Street
		end
		TriggerServerEvent(Event10, Officer, radioChannel, type)
	end

	RegisterCommand("10-13", function()
		sendPanicButton("")
	end, false)

	RegisterCommand("10-13a", function()
		sendPanicButton("a")
	end, false)

	RegisterCommand("10-13b", function()
		sendPanicButton("b")
	end, false)

	RegisterNetEvent("esx_police:get1013Alert")
	AddEventHandler("esx_police:get1013Alert", function(Officer, name, jobTxt, radioChannel)
		if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "sheriff" and ESX.PlayerData.job.name ~= "ambulance" and ESX.PlayerData.job.name ~= "doj" then return end
		if not Officer or not Officer.Coords or not Officer.Location then
			return
		end

		CreateThread(function ()
			for i=1, 18, 1 do
				PlaySound(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
				Wait(300)
				PlaySound(-1, "MEDAL_GOLD", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
				Wait(300)
			end
		end)

		TriggerEvent('chat:sendNewAddonChatMessage', '^*^1[10-13] ', {0, 0, 0}, " ^*^7" .. jobTxt .. " ^*^1"..name.. " ^*^7na ulicy ^*^1".. Officer.Location, "fas fa-laptop", {255, 255, 255})

		Citizen.CreateThread(function()
			local Blip = AddBlipForCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
			SetBlipSprite (Blip, 303)
			SetBlipDisplay(Blip, 4)
			SetBlipScale  (Blip, 1.0)
			SetBlipColour (Blip, 3)
			SetBlipAsShortRange(Blip, false)
			SetBlipCategory(Blip, 14)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("[10-13] " .. name)
			EndTextCommandSetBlipName(Blip)
			Citizen.Wait(60000)
			RemoveBlip(Blip)
			Blip = nil
		end)
	end)

	RegisterNetEvent('esx_police:getCoords')
	AddEventHandler('esx_police:getCoords', function()
		local Officer = {}
		
		Officer.Player = cachePlayerId
		Officer.Ped = cachePed
		Officer.Coords = cacheCoords
		Officer.Location = {}
		Officer.Location.Street, Officer.Location.CrossStreet = GetStreetNameAtCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
		Officer.Location.Street = GetStreetNameFromHashKey(Officer.Location.Street)

		if Officer.Location.CrossStreet ~= 0 then
			Officer.Location.CrossStreet = GetStreetNameFromHashKey(Officer.Location.CrossStreet)
			Officer.Location = Officer.Location.Street .. " X " .. Officer.Location.CrossStreet
		else
			Officer.Location = Officer.Location.Street
		end
		
		TriggerServerEvent(Event11, Officer)
	end)

	RegisterNetEvent('esx_police:getCoordsForShooting')
	AddEventHandler('esx_police:getCoordsForShooting', function()
		local Officer = {}
		
		Officer.Player = cachePlayerId
		Officer.Ped = cachePed
		Officer.Coords = cacheCoords
		Officer.Location = {}
		Officer.Location.Street, Officer.Location.CrossStreet = GetStreetNameAtCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
		Officer.Location.Street = GetStreetNameFromHashKey(Officer.Location.Street)

		if Officer.Location.CrossStreet ~= 0 then
			Officer.Location.CrossStreet = GetStreetNameFromHashKey(Officer.Location.CrossStreet)
			Officer.Location = Officer.Location.Street .. " X " .. Officer.Location.CrossStreet
		else
			Officer.Location = Officer.Location.Street
		end
		
		TriggerServerEvent(Event12, Officer)
	end)

	RegisterNetEvent("esx_police:TriggerPanicButton")
	AddEventHandler("esx_police:TriggerPanicButton", function(Officer, name)
		if not Officer or not Officer.Coords then
			return
		end
		TriggerServerEvent('interact-sound_SV:PlayWithinDistance', 1.0, 'panic2', 0.1)

		Citizen.CreateThread(function()
			SetNewWaypoint(Officer.Coords.x, Officer.Coords.y)
			local Blip = AddBlipForCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
			SetBlipSprite (Blip, 378)
			SetBlipDisplay(Blip, 4)
			SetBlipScale  (Blip, 1.0)
			SetBlipColour (Blip, 3)
			SetBlipAsShortRange(Blip, false)
			SetBlipCategory(Blip, 14)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("[CODE 0] " .. name)
			EndTextCommandSetBlipName(Blip)
			Citizen.Wait(90000)
			RemoveBlip(Blip)
			Blip = nil
		end)
	end)

	RegisterNetEvent("esx_police:TriggerShootingAlert")
	AddEventHandler("esx_police:TriggerShootingAlert", function(Officer, name)
		if not Officer or not Officer.Coords then
			return
		end
		TriggerServerEvent('interact-sound_SV:PlayWithinDistance', 1.0, 'panic2', 0.1)

		Citizen.CreateThread(function()
			SetNewWaypoint(Officer.Coords.x, Officer.Coords.y)
			local Blip = AddBlipForCoord(Officer.Coords.x, Officer.Coords.y, Officer.Coords.z)
			SetBlipSprite (Blip, 432)
			SetBlipDisplay(Blip, 4)
			SetBlipScale  (Blip, 1.0)
			SetBlipColour (Blip, 1)
			SetBlipAsShortRange(Blip, false)
			SetBlipCategory(Blip, 14)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("[STRZELANINA] " .. name)
			EndTextCommandSetBlipName(Blip)
			Citizen.Wait(90000)
			RemoveBlip(Blip)
			Blip = nil
		end)
	end)

	local options = {
		{
			name = 'esx_police:cuffUnCuff',
			icon = 'fa-solid fa-handcuffs',
			label = 'Zakuj / odkuj',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				if LocalPlayer.state.IsDraggingSomeone then
					return false
				end
	
				return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				if not IsPedCuffed(data.entity) then
					if not CanCuff(data.entity) then
						ESX.ShowNotification("Osoba którą próbujesz zakuć/odkuć nie ma rąk w górze")
						return
					end
				end
	
				ClearPedTasks(data.entity)
				StartBar(cooldown)
	
				local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
				TriggerServerEvent(Event1, serverId)
				ESX.ShowNotification('Zakułeś/Odkułeś [' .. serverId ..']')
			end
		},
		{
			name = 'esx_police:cuffAgressive',
			icon = 'fa-solid fa-handcuffs',
			label = 'Zakuj / odkuj agresywnie',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "sheriff" then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				if LocalPlayer.state.IsDraggingSomeone then
					return false
				end
	
				return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
	
				if not IsPedCuffed(data.entity) then
					local playerheading = GetEntityHeading(cachePed)
					local playerlocation = GetEntityForwardVector(cachePed)
					TriggerServerEvent(Event9, serverId, playerheading, cacheCoords, playerlocation)
					ESX.ShowNotification('Zakułeś/Odkułeś [' .. serverId ..']')
				else
					TriggerServerEvent(Event1, serverId)
				end
			end
		},
		{
			name = 'esx_police:movePlayer',
			icon = 'fa-solid fa-hand',
			label = 'Przenieś',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
			
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
			
				if distance > 2 or cacheVehicle then
					return false
				end
			
				if not entity then
					return false
				end
			
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
			
				if Player(sid).state.InTrunk then
					return false
				end
			
				if Player(sid).state.IsConcussed == true then
					return false
				end
			
				local isDowned = IsPedDeadOrDying(entity, true) and not IsEntityDead(entity)
				if isDowned then
					return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
				end
			
				if Player(sid).state.IsDead then
					return true
				end
			
				if Player(sid).state.IsHandcuffed then
					return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
				end
			
				return false
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local isDowned = IsPedDeadOrDying(data.entity, true) and not IsEntityDead(data.entity)
				if not IsPedCuffed(data.entity) and not isDowned then
					ESX.ShowNotification("Osoba którą próbujesz przenieść nie jest zakuta!")
					return
				end
	
				local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
				if Player(serverId).state.DraggingById == cache.serverId then
					LocalPlayer.state:set('DraggedEntity', nil, true)
				else
					LocalPlayer.state:set('DraggedEntity', data.entity, true)
				end
	
				TriggerServerEvent(Event2, serverId)
			end
		},
		{
			name = 'esx_police:cuffLegs',
			icon = 'fa-solid fa-handshake-angle',
			label = 'Zwiąż/rozwiąż nogi',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if ox_inventory:Search('count', 'rope') <= 0 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				if not Player(sid).state.LegsCuffed then
					if not Player(sid).state.IsHandcuffed and not Player(sid).state.IsDead then
						return false
					end
				end
	
				return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				lib.requestAnimDict('mp_arrest_paired')
				TaskPlayAnim(cachePed, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, 1.0, -1, 49, 0.0, 0, 0, 0)
				Citizen.Wait(1000)
				ClearPedTasks(cachePed)
	
				TriggerServerEvent('esx_police:cuffLegs', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
			end
		},
		{
			name = 'esx_police:searchPlayer',
			icon = 'fa-solid fa-handshake-angle',
			label = 'Przeszukaj',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				if not Player(sid).state.IsHandcuffed then
					return false
				end
	
				return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				if not IsPedCuffed(data.entity) then
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta!')
					return
				end
	
				local hasAnim1 = IsEntityPlayingAnim(data.entity, "missminuteman_1ig_2", "handsup_enter", 3)
				local hasAnim2 = IsEntityPlayingAnim(data.entity, "random@arrests@busted", "enter", 3)
	
				if IsPedCuffed(data.entity) or hasAnim1 or hasAnim2 and not IsPlayerDead(data.entity) then
					local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
					StartBar(cooldown, true, "Przeszukiwanie")
					TriggerServerEvent('esx_core:SendLog', "Przeszukiwanie gracza", "Przeszukiwanie gracza od ID: " .. serverId, 'hancuffs-search', '3066993')
					OpenBodySearchMenu(serverId)
				end
			end
		},
		{
			name = 'esx_police:takeClothes',
			icon = 'fa-solid fa-handshake-angle',
			label = 'Zabierz ubrania',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				if not Player(sid).state.IsHandcuffed then
					return false
				end
	
				return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
			end,
			onSelect = function(data)
				if not data or not data.entity then
					return
				end
	
				if IsPedCuffed(data.entity) then
					TakeOtherClothes(data.entity)
				else
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta!')
				end
			end
		},
		{
			name = 'esx_police:takeId',
			icon = 'fa-solid fa-handshake-angle',
			label = 'Sprawdź dowód',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				if not Player(sid).state.IsHandcuffed then
					return false
				end
	
				return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				if IsPedCuffed(data.entity) then
					TriggerServerEvent("esx_hud:requestOtherPlayerCard", GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), "document-id")
				else
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta!')
				end
			end
		},
		{
			name = 'esx_police:manageLicenses',
			icon = 'fa-solid fa-id-badge',
			label = 'Zarządzaj licencjami',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "sheriff" then
					return false
				end
	
				if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") and ESX.PlayerData.job.grade < 10 then
					return false
				end
	
				if not entity then
					return true
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsConcussed == true then
					return false
				end
	
				return true
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				ESX.TriggerServerCallback('esx:getOtherPlayerData', function(data)
					if not data then return end
	
					local elements = {}
	
					if data.licenses ~= nil then
						for i = 1, #data.licenses do
							if data.licenses[i].label ~= nil and data.licenses[i].type == "weapon" then
								table.insert(elements, {label = data.licenses[i].label, value = data.licenses[i].type})
							end
						end
					end
	
					if #elements == 0 then
						table.insert(elements, {label = 'Brak pozwoleń', value = nil})
					end
	
					local options = {}
	
					for i = 1, #elements do
						local el = elements[i]
						table.insert(options, {
							title = el.label,
							onSelect = function()
								if el.value == "weapon" then
									TriggerServerEvent('esx_police:takePlayerLicense', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
								end
							end
						})
					end
	
					lib.registerContext({
						id = "license_manage",
						title = "Unieważnij pozwolenie",
						options = options
					})
	
					lib.showContext("license_manage")
				end, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
			end
		},
		{
			name = 'esx_police:applyWorek',
			icon = 'fas fa-masks-theater',
			label = 'Założ/zdejmij worek z głowy',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 or cacheVehicle then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
				local count = ox_inventory:Search('count', 'worek')
				local hasHeadbag = Player(sid).state.HasHeadbag
	
				if not hasHeadbag and count <= 0 then
					return false
				end
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				local isHandcuffed = Player(sid).state.IsHandcuffed
				local isDead = Player(sid).state.IsDead
				local isConcussed = Player(sid).state.IsConcussed
	
				if isHandcuffed or isDead or isConcussed == true then
					if isHandcuffed then
						return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
					else
						return true
					end
				end
	
				return false
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
				local hasHeadbagAlready = Player(sid).state.HasHeadbag
				local hasAnim1 = IsEntityPlayingAnim(data.entity, "missminuteman_1ig_2", "handsup_enter", 3)
				local hasAnim2 = IsEntityPlayingAnim(data.entity, "random@arrests@busted", "enter", 3)
				local isDead = Player(sid).state.IsDead
				local isCuffed = IsPedCuffed(data.entity)
				local isConcussed = Player(sid).state.IsConcussed
	
				if isCuffed or isDead or isConcussed == true then
					if isCuffed or hasAnim1 or hasAnim2 or isDead or isConcussed == true then
						if data.entity then
							local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
							TriggerServerEvent('esx_core:SendLog', "Worek na głowe", (hasHeadbagAlready == true and "Zdejmowanie" or "Zakładanie").." worka graczowi o ID: " .. serverId, 'hancuffs-search', '3066993')
							TriggerServerEvent(Event14, sid)
						end
					end
				else
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta ani na BW!')
				end
			end
		},
		{
			name = 'esx_police:inCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Włóż do pojazdu',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
				local targetIsDead = Player(sid).state.IsDead
				local targetIsHandcuffed = Player(sid).state.IsHandcuffed
	
				if targetIsHandcuffed and not targetIsDead then
					if ox_inventory:Search('count', 'handcuffs') <= 0 then
						return false
					end
				end
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if targetIsHandcuffed or targetIsDead then
					return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
				end
	
				return false
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
				local targetIsDead = Player(serverId).state.IsDead
				local targetIsHandcuffed = Player(serverId).state.IsHandcuffed or IsPedCuffed(data.entity)
				
				if not targetIsHandcuffed and not targetIsDead then
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta ani na BW!')
					return
				end
	
				
				local menuOptions = {
					{
						title = 'Włóż do pojazdu (bez pasów)',
						icon = 'fa-solid fa-car',
						onSelect = function()
							StartBar(cooldown)
							LocalPlayer.state:set('DraggedEntity', nil, true)
							
							if Player(serverId).state.DraggingById ~= nil then
								TriggerServerEvent(Event2, serverId)
							end
							
							TriggerServerEvent(Event4, serverId, false)
						end
					},
					{
						title = 'Włóż do pojazdu i zapnij pasy',
						icon = 'fa-solid fa-seatbelt',
						onSelect = function()
							StartBar(cooldown)
							LocalPlayer.state:set('DraggedEntity', nil, true)
							
							if Player(serverId).state.DraggingById ~= nil then
								TriggerServerEvent(Event2, serverId)
							end
							
							TriggerServerEvent(Event4, serverId, true)
						end
					}
				}
				
				lib.registerContext({
					id = 'esx_police:putInVehicleMenu',
					title = 'Włóż do pojazdu',
					options = menuOptions
				})
				
				lib.showContext('esx_police:putInVehicleMenu')
			end
		},
		{
			name = 'esx_police:outCarBag',
			icon = 'fa-solid fa-person-walking-luggage',
			label = 'Włóż do bagażnika',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsHandcuffed or Player(sid).state.IsDead then
					return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
				end
	
				return false
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
				local isTargetCuffed = Player(targetServerId).state.IsHandcuffed or IsPedCuffed(data.entity)
	
				if not isTargetCuffed then
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta!')
					return
				end
	
				local vehicle, distance = ESX.Game.GetClosestVehicle()
	
				if not vehicle or distance > 5 then
					ESX.ShowNotification('Nie ma pojazdu w pobliżu!')
					return
				end
	
				local vehNetId = VehToNet(vehicle)
	
				StartBar(cooldown)
				LocalPlayer.state:set('DraggedEntity', nil, true)
	
				if Player(targetServerId).state.DraggingById ~= nil then
					TriggerServerEvent(Event2, targetServerId)
				end
	
				TriggerServerEvent(Event6, targetServerId, vehNetId)
			end
		},
		{
			name = 'esx_police:updatePhoto',
			icon = 'fa-solid fa-camera',
			label = 'Aktualizuj zdjęcie w dokumentach',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if ESX.PlayerData.job.name ~= "police" and ESX.PlayerData.job.name ~= "sheriff" then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				if not entity then
					return false
				end
	
				local sid = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
	
				if Player(sid).state.InTrunk then
					return false
				end
	
				if Player(sid).state.IsHandcuffed or Player(sid).state.IsDead then
					return Player(sid).state.DraggingById == cache.serverId or Player(sid).state.DraggingById == nil
				end
	
				return false
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				if not IsPedCuffed(data.entity) then
					ESX.ShowNotification('Osoba na której próbujesz to zrobić nie jest zakuta!')
					return
				end
	
				StartBar(cooldown)
				ESX.ShowNotification('Aktualizowanie zdjęcia wybranej osoby! (5 sekund)')
				TriggerServerEvent('esx_hud:updateMugshotImage', exports.esx_menu:GetMugShotBase64(data.entity, true), true, GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
			end
		},
	}
	
	local ox_target = exports.ox_target
	ox_target:addGlobalPlayer(options)
	
	local optionsVehs = {
		{
			name = 'esx_police:outCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Wyjmij z pojazdu (kierowca)',
			canInteract = function(entity, distance, coords, name, bone)
				if GetPedInVehicleSeat(entity, -1) == 0 then
					return false
				end
	
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				return ox_inventory:Search('count', 'handcuffs') > 0
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local area = ESX.Game.GetPlayersInArea(data.coords, 5.0)
				local target = GetPedInVehicleSeat(data.entity, -1)
				local player = 0
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
	
					if ped == target then
						player = v
						break
					end
				end
	
				if player ~= 0 then
					StartBar(cooldown)
					TriggerServerEvent(Event5, GetPlayerServerId(player))
				end
			end
		},
		{
			name = 'esx_police:outCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Wyjmij z pojazdu (pasażer)',
			canInteract = function(entity, distance, coords, name, bone)
				if GetPedInVehicleSeat(entity, 0) == 0 then
					return false
				end
	
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				if ox_inventory:Search('count', 'handcuffs') <= 0 then
					return false
				end
	
				local area = ESX.Game.GetPlayersInArea(coords, 5.0)
				local target = GetPedInVehicleSeat(entity, 0)
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
					if ped == target then
						local sid = GetPlayerServerId(v)
						if Player(sid).state.InTrunk then
							return false
						end
						break
					end
				end
	
				return true
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local area = ESX.Game.GetPlayersInArea(data.coords, 5.0)
				local target = GetPedInVehicleSeat(data.entity, 0)
				local player = 0
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
	
					if ped == target then
						player = v
						break
					end
				end
	
				if player ~= 0 then
					StartBar(cooldown)
					TriggerServerEvent(Event5, GetPlayerServerId(player))
				end
			end
		},
		{
			name = 'esx_police:odholujcwela',
			icon = 'fa-solid fa-car',
			label = 'Odholuj pojazd',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				return ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff"
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				ExecuteCommand('me Wzywa jednostkę odholowującą pojazd.')
				RequestAnimDict("mini@repair")
				while not HasAnimDictLoaded("mini@repair") do
					Wait(10)
				end
				TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
				if exports.esx_hud:progressBar({
					duration = 10,
					label = 'Odholowywanie pojazdu',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
						car = true,
						combat = true,
					},
				}) then
					ExecuteCommand('do Pojazd został odholowany.')
					local vehProperties = ESX.Game.GetVehicleProperties(data.entity)
					TriggerServerEvent('esx_carkeys:deleteKeys', vehProperties.plate)
					if ESX.Game.DeleteVehicle then
						ESX.Game.DeleteVehicle(data.entity)
					else
						DeleteEntity(data.entity)
					end
					ClearPedTasks(PlayerPedId())
				else
					ClearPedTasks(PlayerPedId())
				end
			end
		},
		{
			name = 'esx_police:forceVehicle',
			icon = 'fa-solid fa-unlock',
			label = 'Forsuj pojazd',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
				if distance > 2 then
					return false
				end
	
				return ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff"
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local vehicle = data.entity
				local playerPed = PlayerPedId()
	
				if vehicle and vehicle ~= 0 then
					if IsVehicleAlarmSet(vehicle) and GetRandomIntInRange(1, 100) <= 33 then
						local id = NetworkGetNetworkIdFromEntity(vehicle)
						SetNetworkIdCanMigrate(id, false)
	
						local tries = 0
						while not NetworkHasControlOfNetworkId(id) and tries < 10 do
							tries = tries + 1
							NetworkRequestControlOfNetworkId(id)
							Citizen.Wait(100)
						end
	
						StartVehicleAlarm(vehicle)
						SetNetworkIdCanMigrate(id, true)
					end
	
					RequestAnimDict("amb@world_human_welding@male@idle_a")
					while not HasAnimDictLoaded("amb@world_human_welding@male@idle_a") do
						Wait(10)
					end
					TaskPlayAnim(playerPed, "amb@world_human_welding@male@idle_a", "idle_a", 8.0, -8.0, -1, 1, 0, false, false, false)
	
					local progressResult = exports.esx_hud:progressBar({
						duration = 5,
						label = "Trwa Odblokowywanie...",
						useWhileDead = false,
						canCancel = true,
						disable = {
							move = true,
						},
					})
	
					if progressResult == true then
						if GetRandomIntInRange(1, 100) <= 66 then
							local id = NetworkGetNetworkIdFromEntity(vehicle)
							SetNetworkIdCanMigrate(id, false)
							local tries = 0
							while not NetworkHasControlOfNetworkId(id) and tries < 10 do
								tries = tries + 1
								NetworkRequestControlOfNetworkId(id)
								Citizen.Wait(100)
							end
							SetVehicleDoorsLocked(vehicle, 1)
							SetVehicleDoorsLockedForAllPlayers(vehicle, false)
							Citizen.Wait(0)
							SetNetworkIdCanMigrate(id, true)
							ESX.ShowNotification('Pojazd został odblokowany')
							ClearPedTasks(playerPed)
							ClearPedSecondaryTask(playerPed)
						else
							ESX.ShowNotification('Nie udało się odblokować pojazdu')
							ClearPedTasks(playerPed)
							ClearPedSecondaryTask(playerPed)
						end
					elseif progressResult == false then
						ESX.ShowNotification('~r~Anulowano odblokowywanie')
						ClearPedTasks(playerPed)
						ClearPedSecondaryTask(playerPed)
					end
				end
			end
		},
		{
			name = 'esx_police:outCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Wyjmij z pojazdu (z tyłu prawo)',
			canInteract = function(entity, distance, coords, name, bone)
				if GetPedInVehicleSeat(entity, 1) == 0 then
					return false
				end
	
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
			if distance > 2 then
				return false
			end

			return true
		end,
		onSelect = function(data)
			if not data.entity then return end

			local area = ESX.Game.GetPlayersInArea(data.coords, 5.0)
			local target = GetPedInVehicleSeat(data.entity, 1)
			local player = 0
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
	
					if ped == target then
						player = v
						break
					end
				end
	
				if player ~= 0 then
					StartBar(cooldown)
					TriggerServerEvent(Event5, GetPlayerServerId(player))
				end
			end
		},
		{
			name = 'esx_police:outCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Wyjmij z pojazdu (z tyłu lewo)',
			canInteract = function(entity, distance, coords, name, bone)
				if GetPedInVehicleSeat(entity, 2) == 0 then
					return false
				end
	
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
			if distance > 2 then
				return false
			end

			return true
		end,
		onSelect = function(data)
			if not data.entity then return end

			local area = ESX.Game.GetPlayersInArea(data.coords, 5.0)
			local target = GetPedInVehicleSeat(data.entity, 2)
			local player = 0
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
	
					if ped == target then
						player = v
						break
					end
				end
	
				if player ~= 0 then
					StartBar(cooldown)
					TriggerServerEvent(Event5, GetPlayerServerId(player))
				end
			end
		},
		{
			name = 'esx_police:outCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Wyjmij z pojazdu (miejsce 4)',
			canInteract = function(entity, distance, coords, name, bone)
				if GetPedInVehicleSeat(entity, 3) == 0 then
					return false
				end
	
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
			if distance > 2 then
				return false
			end

			return true
		end,
		onSelect = function(data)
			if not data.entity then return end

			local area = ESX.Game.GetPlayersInArea(data.coords, 5.0)
			local target = GetPedInVehicleSeat(data.entity, 3)
			local player = 0
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
	
					if ped == target then
						player = v
						break
					end
				end
	
				if player ~= 0 then
					StartBar(cooldown)
					TriggerServerEvent(Event5, GetPlayerServerId(player))
				end
			end
		},
		{
			name = 'esx_police:outCar',
			icon = 'fa-solid fa-car-rear',
			label = 'Wyjmij z pojazdu (miejsce 5)',
			canInteract = function(entity, distance, coords, name, bone)
				if GetPedInVehicleSeat(entity, 4) == 0 then
					return false
				end
	
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
			if distance > 2 then
				return false
			end

			return true
		end,
		onSelect = function(data)
			if not data.entity then return end

			local area = ESX.Game.GetPlayersInArea(data.coords, 5.0)
			local target = GetPedInVehicleSeat(data.entity, 4)
			local player = 0
	
				for k, v in pairs(area) do
					local ped = GetPlayerPed(v)
	
					if ped == target then
						player = v
						break
					end
				end
	
				if player ~= 0 then
					StartBar(cooldown)
					TriggerServerEvent(Event5, GetPlayerServerId(player))
				end
			end
		},
		{
			name = 'esx_police:outCarBag',
			icon = 'fa-solid fa-person-walking-luggage',
			label = 'Wyjmij z bagażnika',
			canInteract = function(entity, distance, coords, name, bone)
				if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
					return false
				end
	
				if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
					return false
				end
	
			if distance > 5 then
				return false
			end

			local players = ESX.Game.GetPlayersInArea(coords, 5.0)
				for _, player in ipairs(players) do
					local sid = GetPlayerServerId(player)
					if Player(sid).state.InTrunk then
						return true
					end
				end
	
				return false
			end,
			onSelect = function(data)
				if not data.entity then return end
	
				local vehicleCoords = GetEntityCoords(data.entity)
				local players = ESX.Game.GetPlayersInArea(vehicleCoords, 5.0)
	
				for _, player in ipairs(players) do
					local sid = GetPlayerServerId(player)
					if Player(sid).state.InTrunk then
						StartBar(cooldown)
						TriggerServerEvent(Event7, sid)
						ESX.ShowNotification('Wyciągam z bagażnika...')
						return
					end
				end
	
				ESX.ShowNotification('Nikt nie jest w bagażniku!')
			end
		}
	}
	
	ox_target:addGlobalVehicle(optionsVehs)

	lib.addKeybind({
		name = 'fastcuff',
		description = 'Szybkie zakucie',
		keyboard = 'keyboard',
		defaultKey = 'Q',
		onPressed = function()
			if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
				if IsControlPressed(0, Keys["centerSHIFT"]) then
					if not cacheVehicle and not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer ~= -1 and closestDistance <= 1.25 and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
							local count = ox_inventory:Search('count', 'handcuffs')

							if count > 0 then
								if not CanCuff(closestPlayer) then
									ESX.ShowNotification("Osoba którą próbujesz zakuć/odkuć nie ma rąk w górze")
									return
								end

								TriggerServerEvent(Event1, GetPlayerServerId(closestPlayer), false)
								ESX.ShowNotification('Zakułeś/Odkułeś [' .. GetPlayerServerId(closestPlayer) ..']')
							else
								ESX.ShowNotification("Nie masz przy sobie kajdanek!")
							end
						end
					end
				end
			end
		end
	})

	lib.addKeybind({
		name = 'fastdrag',
		description = 'Szybkie przeniesienie',
		keyboard = 'keyboard',
		defaultKey = 'E',
		onPressed = function()
			if (ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff") then
				if IsControlPressed(0, Keys["centerSHIFT"]) then
					if not cacheVehicle and not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer ~= -1 and closestDistance <= 1.25 then
							local count = ox_inventory:Search('count', 'handcuffs')

							if count > 0 then
								if not IsPedCuffed(GetPlayerPed(closestPlayer)) then
									ESX.ShowNotification("Osoba którą próbujesz przenieść nie jest zakuta!")
									return
								end

								if Player(GetPlayerServerId(closestPlayer)).state.DraggingById == cache.serverId then
									LocalPlayer.state:set('DraggedEntity', nil, true)
								else
									LocalPlayer.state:set('DraggedEntity', GetPlayerPed(closestPlayer), true)
								end

								TriggerServerEvent(Event2, GetPlayerServerId(closestPlayer))
							else
								ESX.ShowNotification("Nie masz przy sobie kajdanek!")
							end
						end
					end
				end
			end
		end
	})

	RegisterNetEvent("esx_police:refreshHeadbag", function(newState) 
		local haveHeadbag = newState
		if haveHeadbag == nil then
			haveHeadbag = LocalPlayer.state.HasHeadbag
		end
		if haveHeadbag then
			exports.esx_core.showHeadbag()
		else 
			exports.esx_core.hideHeadbag()
		end
	end)

	local InteractionsState = false

	CreateThread(function ()
		while not ESX.PlayerLoaded do
			Wait(500)
		end

		for category, zones in pairs(Config.PoliceStations) do
			for _, zone in ipairs(zones) do
				InteractionsState = true
				if (Config.Interactions[category]) then 
					exports["interactions"]:showInteraction(
						zone.coords, 
						zone.icon, 
						"ALT", 
						Config.Interactions[category][1], 
						Config.Interactions[category][2],
						false,
						{["police"] = true, ["sheriff"] = true}
					)
				end
				exports.ox_target:addSphereZone({
					coords = zone.coords,
					radius = 0.8,
					-- size = zone.size or vec3(2, 2, 2),
					-- rotation = zone.rotation or 45,
					debug = false,
					options = {
						{
							name = 'esx_police:targets'..category,
							icon = zone.icon,
							label = zone.label,
							canInteract = function(entity, distance, coords, name)
								if LocalPlayer.state.IsDead then return false end
								if LocalPlayer.state.IsHandcuffed then return false end
								if distance > 2.50 then return false end
	
								if ESX.PlayerData.job.name == "police" or ESX.PlayerData.job.name == "sheriff" then
									return true
								else 
									return false
								end
							end,
								onSelect = function()
									if category == 'BossActions' then
										if ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'sheriff' then
											if ESX.PlayerData.job.grade > 11 then
												TriggerServerEvent('esx_society:openbosshub', 'fraction', false, true)
											else
												ESX.ShowNotification("Nie posiadasz dostępu do tego elementu!")
											end
										end
									elseif category == 'PharmacySchowki' then
										OpenPharmacyMenuSchowek()
									elseif category == 'Cloakrooms' then
										OpenCloakroomMenu()
									elseif category == 'CloakroomsPrivate' then
										OpenCloakroomMenuPrivate()
									elseif category == 'SWATArmory' then
										if ESX.PlayerData.job.grade >= 14 then
											OpenSWATArmoryMenu()
										elseif ESX.PlayerData.job.grade >= 1 then
											ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
												if hasWeaponLicense then
													OpenSWATArmoryMenu()
												else
													ESX.ShowNotification("Nie posiadasz dostępu do zbrojowni SWAT! Wymagana licencja SWAT.")
												end
											end, cacheServerId, 'swat')
										else
											ESX.ShowNotification("Nie posiadasz dostępu!")
										end
									elseif category == 'HCArmory' then
										if ESX.PlayerData.job.grade >= 14 then
											OpenHCArmoryMenu()
										elseif ESX.PlayerData.job.grade >= 1 then
											ESX.TriggerServerCallback('esx_license:checkLicense', function(hasWeaponLicense)
												if hasWeaponLicense then
													OpenHCArmoryMenu()
												else
													ESX.ShowNotification("Nie posiadasz dostępu do zbrojowni HC! Wymagana licencja CB.")
												end
											end, cacheServerId, 'cb')
										else
											ESX.ShowNotification("Nie posiadasz dostępu!")
										end
									elseif category == 'Kosz' then
										TriggerServerEvent('esx_police:openKosz')
									end
								end
							}
						}
					})
				end
			end
	end)
end)

local legsCuffedClipset = "move_m@injured"
CreateThread(function()
	lib.requestAnimDict(legsCuffedClipset)
	while true do
		Wait(0)
		if LocalPlayer.state.LegsCuffed then
			if LocalPlayer.state.DraggingById ~= nil then
				DisableControlAction(0, 21, true) -- Sprint
				DisableControlAction(0, 22, true) -- Jump
				DisableControlAction(0, 24, true) -- Attack
				DisableControlAction(0, 25, true) -- Aim
				DisableControlAction(0, 44, true) -- Cover
				DisableControlAction(0, 37, true) -- Select Weapon
				DisableControlAction(0, 30, true) -- Move Left/Right
				DisableControlAction(0, 31, true) -- Move Up/Down
				DisableControlAction(0, 32, true) -- W
				DisableControlAction(0, 33, true) -- S
				DisableControlAction(0, 34, true) -- A
				DisableControlAction(0, 35, true) -- D
				DisableControlAction(2, 32, true) -- W
				DisableControlAction(2, 33, true) -- S
				DisableControlAction(2, 34, true) -- A
				DisableControlAction(2, 35, true) -- D
			else
				DisableControlAction(0, 21, true) -- Sprint
				DisableControlAction(0, 22, true) -- Jump
				DisableControlAction(0, 24, true) -- Attack
				DisableControlAction(0, 25, true) -- Aim
				DisableControlAction(0, 44, true) -- Cover
				DisableControlAction(0, 37, true) -- Select Weapon

				DisableControlAction(0, 30, true) -- Move Left/Right
				DisableControlAction(0, 31, true) -- Move Up/Down
				DisableControlAction(0, 32, true) -- W
				DisableControlAction(0, 33, true) -- S
				DisableControlAction(0, 34, true) -- A
				DisableControlAction(0, 35, true) -- D
				DisableControlAction(2, 32, true) -- W
				DisableControlAction(2, 33, true) -- S
				DisableControlAction(2, 34, true) -- A
				DisableControlAction(2, 35, true) -- D

				if not IsPedUsingScenario(cachePed) and not IsEntityPlayingAnim(cachePed, 'mp_arresting', 'idle', 3) then
					if not IsPedInAnyVehicle(cachePed, false) and not LocalPlayer.state.InTrunk then
						RequestAnimSet(legsCuffedClipset)
						if HasAnimSetLoaded(legsCuffedClipset) then
							SetPedMovementClipset(cachePed, legsCuffedClipset, 0.5)
						end
					end
				end

				SetPedMaxMoveBlendRatio(cachePed, 1.0)
			end
		else
			Wait(500)
		end
	end
end)

AddStateBagChangeHandler('LegsCuffed', nil, function(bagName, key, value)
	local playerId = GetPlayerFromStateBagName(bagName)
	if playerId == PlayerId() then
		if not value then
			ResetPedMovementClipset(cachePed, 0.0)
			SetPedMaxMoveBlendRatio(cachePed, 1.0)
		end
	end
end)

Citizen.CreateThread(function()
    local npc = Config.Bracelet.npc
    RequestModel(npc.model)
    while not HasModelLoaded(npc.model) do Wait(10) end
    local ped = CreatePed(4, npc.model, npc.coords.x, npc.coords.y, npc.coords.z - 1, npc.coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'remove_bracelet_npc',
            icon = 'fas fa-unlock',
            label = 'Zdejmij opaskę ($'..Config.Bracelet.remove_price..')',
            onSelect = function()
                TriggerServerEvent('vwk/bracelet:removeAtNPC')
            end,
        }
    })
end)

RegisterNetEvent('vwk/bracelet:startAnimation', function(target)
    local playerPed = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

    RequestAnimDict("missheist_agency3aig_23") 
    while not HasAnimDictLoaded("missheist_agency3aig_23") do
        Wait(100)
    end

    TaskPlayAnim(playerPed, "missheist_agency3aig_23", "urinal_sink_loop", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    if exports.esx_hud:progressBar({
		duration = 5,
		label = 'Zakładanie opaski monitorującej',
		useWhileDead = false,
		canCancel = true,
		disable = {
			move = true,
			car = true,
			combat = true,
		},
	}) then
		ClearPedTasks(playerPed)
		TriggerServerEvent('vwk/bracelet:give', target)
	end

end)