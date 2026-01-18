local esx_hud = exports.esx_hud
local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

local HasAlreadyEnteredMarker, LastZone = false, nil
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, {}, {}
local NPCOnJob, NPCTargetTowableZone, NPCTargetDeleterZone = false, nil, false
local NPCHasSpawnedTowable, NPCLastCancel, NPCHasBeenNextToTowable = false, GetGameTimer() - 300000, false
local haveTargets = false
local mechanikTargets = {}

local cachePed = cache.ped
local cacheCoords = cache.coords
local cacheVehicle = cache.vehicle

lib.onCache('ped', function(ped) cachePed = ped end)
lib.onCache('coords', function(coords) cacheCoords = coords end)
lib.onCache('vehicle', function(vehicle) cacheVehicle = vehicle end)

local function RefreshTargets()
	if ESX.PlayerData.job and (ESX.PlayerData.job.name == 'mechanik' or ESX.PlayerData.job.name == 'ec') and not haveTargets then
		TriggerServerEvent('esx_mechanik:sync:addTargets')
		haveTargets = true
	end
end

local function DeleteTargets()
	TriggerServerEvent('esx_mechanik:sync:addTargets')
	haveTargets = false
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
		ESX.ShowNotification('Brak tego stroju w kategorii '..category)
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
		ESX.ShowNotification("Podgląd stroju - naciśnij ESC aby anulować (anuluje się automatycznie za 15 sekund)")
		
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
		ESX.ShowNotification('Brak tego stroju w kategorii '..category)
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
		ESX.ShowNotification("Strój został ubrany")
	end)
end

local function LoadUniformsFromServer()
	ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
		UniformsData = data or {}
	end)
end

local function OpenCloakroomMenu()
	ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
		UniformsData = data or {}
		
		local xPlayer = ESX.PlayerData
		local isMechanik = xPlayer.job.name == "mechanik" or xPlayer.job.name == "ec"
		local isManagement = isMechanik and xPlayer.job.grade >= 7

		local categoryPriority = {
			["Służbowe"] = 1,
			["Dodatkowe"] = 2
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
		{title = "Dodaj strój", onSelect = function() AddUniformMenu() end},
		{title = "Kopiuj strój", onSelect = function() CopyUniformMenu() end},
		{title = "Zmień nazwę stróju", onSelect = function() RenameUniformMenu() end},
		{title = "Ustaw ograniczenia dostępu", onSelect = function() SetMinGradeMenu() end},
		{title = "Usuń strój", onSelect = function() RemoveUniformMenu() end}
	}
	lib.registerContext({id = "management_menu", title = "Zarządzanie strojami", options = options})
	lib.showContext("management_menu")
end

function AddUniformMenu()
	ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(uniformsData)
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
		
		local input = lib.inputDialog('Dodaj strój', {
			{type = 'input', label = 'Nazwa nowego stroju', required = true, minLength = 1},
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

			ESX.TriggerServerCallback('vwk/mechanik/addUniform', function(success)
				if success then
					ESX.ShowNotification("Dodano strój: "..uniformName.." (kategoria: "..finalCategory..")")
					ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
						UniformsData = data or {}
						ESX.ShowNotification("Strój został dodany i jest dostępny w szatni")
					end)
				else
					ESX.ShowNotification("Błąd przy dodawaniu stroju")
				end
			end, uniformData)
		end)
	end)
end

function RenameUniformMenu()
	ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
		UniformsData = data or {}
		
		local options = {}
		for category, uniforms in pairs(UniformsData) do
			for name, _ in pairs(uniforms) do
				table.insert(options, {
					title = name,
					description = "Kategoria: " .. category,
					onSelect = function()
						local input = lib.inputDialog('Zmień nazwę stróju', {
							{type = 'input', label = 'Nowa nazwa stróju', required = true, minLength = 1, default = name}
						})
						
						if not input or not input[1] or input[1] == '' then
							return
						end
						
						local newName = input[1]
						
						if newName == name then
							ESX.ShowNotification("Nowa nazwa jest taka sama jak obecna")
							return
						end
						
						ESX.TriggerServerCallback('vwk/mechanik/renameUniform', function(success)
							if success then
								ESX.ShowNotification("Zmieniono nazwę stróju z \""..name.."\" na \""..newName.."\"")
								ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
									UniformsData = data or {}
								end)
							else
								ESX.ShowNotification("Błąd przy zmianie nazwy stroju (możliwe że nazwa już istnieje)")
							end
						end, name, newName)
					end
				})
			end
		end
		
		if #options == 0 then
			ESX.ShowNotification("Brak strojów do zmiany nazwy")
			return
		end
		
		lib.registerContext({id = "rename_uniforms", title = "Zmień nazwę stroju", options = options})
		lib.showContext("rename_uniforms")
	end)
end

function CopyUniformMenu()
	ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
		UniformsData = data or {}
		
		local options = {}
		for category, uniforms in pairs(UniformsData) do
			for name, _ in pairs(uniforms) do
				table.insert(options, {
					title = name,
					description = "Kategoria: " .. category,
					onSelect = function()
						local input = lib.inputDialog('Kopiuj strój', {
							{type = 'input', label = 'Nazwa nowego stróju', required = true, minLength = 1},
							{type = 'input', label = 'Kategoria (opcjonalnie, zostaw puste aby użyć tej samej)', required = false}
						})
						
						if not input or not input[1] or input[1] == '' then
							return
						end
						
						local newName = input[1]
						local newCategory = input[2] and input[2] ~= '' and input[2] or category
						
						ESX.TriggerServerCallback('vwk/mechanik/copyUniform', function(success)
							if success then
								ESX.ShowNotification("Skopiowano strój: "..name.." jako "..newName)
								ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
									UniformsData = data or {}
								end)
							else
								ESX.ShowNotification("Błąd przy kopiowaniu stroju (możliwe że nazwa już istnieje)")
							end
						end, name, newName, newCategory)
					end
				})
			end
		end
		
		if #options == 0 then
			ESX.ShowNotification("Brak strojów do skopiowania")
			return
		end
		
		lib.registerContext({id = "copy_uniforms", title = "Kopiuj strój", options = options})
		lib.showContext("copy_uniforms")
	end)
end

function SetMinGradeMenu()
	ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
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
						
						ESX.TriggerServerCallback('vwk/mechanik/setUniformMinGrade', function(success)
							if success then
								ESX.ShowNotification("Ustawiono minimalny grade: "..newMinGrade.." dla stroju: "..name)
								ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
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
			ESX.ShowNotification("Brak strojów")
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
				ESX.TriggerServerCallback('vwk/mechanik/removeUniform', function(success)
					if success then
						ESX.ShowNotification("Usunięto strój: "..name)
						ESX.TriggerServerCallback('vwk/mechanik/getUniforms', function(data)
							UniformsData = data or {}
						end)
					else
						ESX.ShowNotification("Błąd przy usuwaniu stroju")
					end
				end, name)
			end})
		end
	end
	lib.registerContext({id = "remove_uniforms", title = "Usuń strój", options = options})
	lib.showContext("remove_uniforms")
end

local function SelectRandomTowable()
	local index = GetRandomIntInRange(1, #Config.Towables)
	for k, v in pairs(Config.TowZones) do
		if v.Pos.x == Config.Towables[index].x and v.Pos.y == Config.Towables[index].y and v.Pos.z == Config.Towables[index].z then
			return k
		end
	end
end

local function SpawnMechanicVehicle(model, coords, heading)
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
		ESX.ShowNotification('Miejsce jest zajęte!')
		return
	end
	
	ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
		SetVehicleNumberPlateText(vehicle, "MECH" .. math.random(111, 9999))
		TaskWarpPedIntoVehicle(cachePed, vehicle, -1)
		Entity(vehicle).state.fuel = 50
		Wait(500)
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
end

local function OpenMechanicVehicleSpawner(coords, heading)
	local vehicles = {
		{ title = "Laweta", model = 'flatbed' },
		{ title = "Dodge Charger", model = 'lsc_charger18' },
		{ title = "Ford Raptor", model = 'lsc_raptor' }
	}
	
	local options = {}
	for _, v in ipairs(vehicles) do
		options[#options + 1] = {
			title = v.title,
			onSelect = function() SpawnMechanicVehicle(v.model, coords, heading) end
		}
	end

	lib.registerContext({ id = "spawn_vehicle", title = "Pojazdy", options = options })
	lib.showContext("spawn_vehicle")
end

local function OpenMechanicActionsMenu()
	lib.registerContext({
		id = "mechanic_actions",
		title = "LSC",
		options = {
			{ title = "Szatnia prywatna", onSelect = function() exports.qf_skinmenu:openClothingShop() end },
			{ title = "Ubranie służbowe", onSelect = function() OpenCloakroomMenu() end },
			{ title = "Schowek", onSelect = function() 
				local stashId = ESX.PlayerData.job.name == "ec" and "ec" or "mechanik"
				ox_inventory:openInventory('stash', { id = stashId }) 
			end }
		}
	})
	lib.showContext("mechanic_actions")
end

RegisterNetEvent('esx:playerLoaded', function(playerData)
	ESX.PlayerData = playerData
	while not ESX.IsPlayerLoaded() do Wait(200) end
	if ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "ec" then RefreshTargets() end
end)

RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job
	if job.name == "mechanik" or job.name == "ec" then
		RefreshTargets()
	else
		DeleteTargets()
	end
end)

AddEventHandler('esx_mechanik:hasEnteredMarker', function(zone)
	local vehicle, distance = ESX.Game.GetClosestVehicle({ x = cacheCoords.x, y = cacheCoords.y, z = cacheCoords.z })

	if zone == 'VehicleDeleter' and cacheVehicle then
		if distance ~= -1 and distance <= 1.0 then
			CurrentAction = 'delete_vehicle'
			CurrentActionMsg = { text = 'Naciśnij', button = 'E', description = 'aby schować pojazd.' }
			CurrentActionData = { vehicle = vehicle }
		end
	elseif zone == 'VehicleDelivery' and cacheVehicle and NPCOnJob then
		NPCTargetDeleterZone = true
		if distance ~= -1 and distance <= 1.0 then
			CurrentAction = 'vehicle_delivery'
			CurrentActionMsg = { text = 'Użyj w menu', button = 'F1', description = 'zakładki LSC aby odczepić pojazd' }
			CurrentActionData = { vehicle = vehicle }
		end
	end
end)

AddEventHandler('esx_mechanik:hasExitedMarker', function(zone)
	if zone == 'VehicleDelivery' then NPCTargetDeleterZone = false end
	esx_hud:hideHelpNotification()
	CurrentAction = nil
end)

CreateThread(function()
	for _, v in pairs(Config.Blips) do
		local blip = AddBlipForCoord(v.Pos)
		SetBlipSprite(blip, v.Sprite)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.7)
		SetBlipColour(blip, v.Color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(v.Label)
		EndTextCommandSetBlipName(blip)
	end
end)

CreateThread(function()
	while not ESX.PlayerData.job do Wait(100) end
	
	while true do
		local sleep = 500
		if ESX.PlayerData.job and (ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "ec") then
			if NPCTargetTowableZone and not NPCHasSpawnedTowable then
				sleep = 0
				local zone = Config.TowZones[NPCTargetTowableZone]
				if #(cacheCoords - vec3(zone.Pos.x, zone.Pos.y, zone.Pos.z)) < Config.NPCSpawnDistance then
					local model = Config.Vehicles[GetRandomIntInRange(1, #Config.Vehicles)]
					ESX.Game.SpawnVehicle(model, zone.Pos, 0, function(vehicle)
						SetVehicleHasBeenOwnedByPlayer(vehicle, true)
						SetVehicleUndriveable(vehicle, false)
						SetVehicleEngineOn(vehicle, true, true)
						SetVehicleEngineHealth(vehicle, 200.0)
						NPCTargetTowable = vehicle
						Entity(vehicle).state.fuel = 50
					end)
					NPCHasSpawnedTowable = true
				end
			end

			if NPCTargetTowableZone and NPCHasSpawnedTowable and not NPCHasBeenNextToTowable then
				sleep = 0
				local zone = Config.TowZones[NPCTargetTowableZone]
				if #(cacheCoords - vec3(zone.Pos.x, zone.Pos.y, zone.Pos.z)) < Config.NPCNextToDistance then
					ESX.ShowNotification('Proszę odholować pojazd')
					NPCHasBeenNextToTowable = true
				end
			end
		else
			sleep = 1000
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while true do
		local sleep = 1000
		if ESX.PlayerData.job and Config.Zones[ESX.PlayerData.job.name] then
			for _, v in pairs(Config.Zones.Vehicles) do
				if v.type ~= -1 and #(cacheCoords - v.coords) < Config.DrawDistance then
					if cacheVehicle then
						if v.type == 28 or (v.type == 29 and NPCOnJob) then
							ESX.DrawBigMarker(v.coords)
						end
					end
					sleep = 0
				end
			end
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while true do
		local sleep = 2000
		if ESX.PlayerData.job and Config.Zones[ESX.PlayerData.job.name] then
			sleep = 500
			local isInMarker, currentZone = false, nil
			
			for k, v in pairs(Config.Zones.Vehicles) do
				if #(cacheCoords - v.coords) < 3.0 then
					isInMarker, currentZone = true, k
					break
				end
			end

			if isInMarker and (not HasAlreadyEnteredMarker or LastZone ~= currentZone) then
				HasAlreadyEnteredMarker, LastZone = true, currentZone
				TriggerEvent('esx_mechanik:hasEnteredMarker', currentZone)
			elseif not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_mechanik:hasExitedMarker', LastZone)
			end
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while not ESX.PlayerData.job do Wait(100) end
	
	while true do
		local sleep = 1000
		if ESX.PlayerData.job and Config.Zones[ESX.PlayerData.job.name] and not cache.vehicle then
			sleep = 200
			local found = false
			for _, prop in ipairs({ 'prop_roadcone01b', 'prop_toolchest_02', 'prop_barrier_work01b' }) do
				local object = GetClosestObjectOfType(cacheCoords.x, cacheCoords.y, cacheCoords.z, 2.0, GetHashKey(prop), false, false, false)
				if DoesEntityExist(object) then
					CurrentAction = 'remove_entity'
					CurrentActionMsg = { text = 'Naciśnij', button = 'E', description = 'aby usunąć obiekt.' }
					CurrentActionData = { entity = object }
					found = true
					break
				end
			end
			if not found and CurrentAction == 'remove_entity' then
				CurrentAction = nil
				esx_hud:hideHelpNotification()
			end
		end
		Wait(sleep)
	end
end)

CreateThread(function()
	while not ESX.PlayerData.job do Wait(100) end
	
	while true do
		local sleep = 1000
		if ESX.PlayerData.job and (ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "ec") then
			if CurrentAction then
				sleep = 0
				esx_hud:helpNotification(CurrentActionMsg.text, CurrentActionMsg.button, CurrentActionMsg.description)
				if IsControlJustReleased(0, 38) and Config.Zones[ESX.PlayerData.job.name] then
					if CurrentAction == 'delete_vehicle' then
						ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
					elseif CurrentAction == 'remove_entity' then
						ESX.Game.DeleteObject(CurrentActionData.entity)
					end
				end
			else
				sleep = 500
			end
		end
		Wait(sleep)
	end
end)

local function CanInteractBase(entity, distance)
	return not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed and distance <= 2 and not cacheVehicle
end

local function CreateProgressBar(label, duration, anim)
	return esx_hud:progressBar({
		duration = duration,
		label = label,
		useWhileDead = false,
		canCancel = true,
		disable = { car = true, move = true, combat = true, mouse = false },
		anim = anim,
		prop = {}
	})
end

local repairAnim = { dict = 'mini@repair', clip = 'fixing_a_player' }

local vehicleOptions = {
	{
		name = 'esx_mechanik:changePos',
		icon = 'fa-solid fa-wand-magic-sparkles',
		label = 'Obróć',
		canInteract = function(_, distance) return CanInteractBase(nil, distance) end,
		onSelect = function(data)
			if not DoesEntityExist(data.entity) then
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
				return
			end
			if CreateProgressBar('Obracanie', 5, repairAnim) then
				local carCoords = GetEntityRotation(data.entity, 2)
				SetEntityRotation(data.entity, carCoords[1], 0, carCoords[3], 2, true)
				SetVehicleOnGroundProperly(data.entity)
				ClearPedTasks(cachePed)
				ESX.ShowNotification('Pojazd został obrócony!')
			else
				ESX.ShowNotification('Anulowano.')
			end
		end
	},
	{
		name = 'esx_mechanik:repair',
		icon = 'fa-solid fa-toolbox',
		label = 'Napraw (100%)',
		canInteract = function(_, distance)
			return CanInteractBase(nil, distance) and (ESX.PlayerData.job.name == 'mechanik' or ESX.PlayerData.job.name == 'ec')
		end,
		onSelect = function(data)
			if not DoesEntityExist(data.entity) then
				ESX.ShowNotification('W pobliżu nie ma żadnego pojazdu!')
				return
			end
			TriggerServerEvent('esx_core:komunikat', 'Wykonuje prace naprawcze przy pojeździe i usuwa wszystkie usterki')
			if CreateProgressBar('Naprawianie', 5, repairAnim) then
				TriggerServerEvent("esx_core:deleteOldItem", 'advancedrepairkit')
				SetVehicleFixed(data.entity)
				SetVehicleDeformationFixed(data.entity)
				SetVehicleUndriveable(data.entity, false)
				SetVehicleEngineOn(data.entity, true, true)
				SetVehicleEngineHealth(data.entity, 1000.0)
				ClearPedTasks(cachePed)
				ESX.ShowNotification('Pojazd naprawiony do 100%.')
				TriggerServerEvent("esx_mechanik:UpdateTaskProgress", "Mechanic")
			else
				ESX.ShowNotification('Anulowano.')
			end
		end
	},
	{
		name = 'esx_mechanik:clean',
		icon = 'fa-solid fa-hands-bubbles',
		label = 'Umyj',
		canInteract = function(_, distance)
			return CanInteractBase(nil, distance) and ox_inventory:Search('count', 'cleaningkit') > 0
		end,
		onSelect = function(data)
			if cacheVehicle then
				ESX.ShowNotification('Nie możesz tego wykonać w środku pojazdu!')
				return
			end
			if not DoesEntityExist(data.entity) then
				ESX.ShowNotification('Nie znaleziono pojazdu, utracono przedmiot.')
				return
			end
			TriggerServerEvent('esx_core:komunikat', 'Starannie czyści powierzchnie pojazdu')
			if CreateProgressBar('Mycie...', 5, { dict = 'switch@franklin@cleaning_car', clip = '001946_01_gc_fras_v2_ig_5_base' }) then
				SetVehicleDirtLevel(data.entity, 0)
				ClearPedTasks(cachePed)
				ESX.ShowNotification('Pojazd umyty.')
				TriggerServerEvent("esx_core:deleteOldItem", 'cleaningkit')
			else
				ESX.ShowNotification('Anulowano.')
			end
		end
	},
	{
		name = 'esx_mechanik:tow',
		icon = 'fa-solid fa-truck-tow',
		label = 'Odholuj',
		canInteract = function(_, distance)
			return CanInteractBase(nil, distance) and (ESX.PlayerData.job.name == 'mechanik' or ESX.PlayerData.job.name == 'ec')
		end,
		onSelect = function(data)
			local vehicle = ESX.Game.GetClosestVehicle(cacheCoords)
			if DoesEntityExist(vehicle) then
				ESX.ShowNotification('Odholowujesz pojazd...')
				TaskStartScenarioInPlace(cachePed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
				if CreateProgressBar('Odholowywanie...', 5, { dict = 'mini@repair', clip = 'fixing_a_player' }) then
					ESX.Game.DeleteVehicle(vehicle)
					ESX.ShowNotification('Pojazd odholowany.')
				else
					ESX.ShowNotification('Anulowano.')
				end
				ClearPedTasks(cachePed)
			end
		end
	},
}

ox_target:addGlobalVehicle(vehicleOptions)

RegisterNetEvent('esx_mechanik:sync:removeTargets', function()
	if haveTargets then haveTargets = false end
	for i = 1, #mechanikTargets do
		ox_target:removeZone(mechanikTargets[i])
	end
	mechanikTargets = {}
end)

RegisterNetEvent('esx_mechanik:sync:addTargetsCL', function()
	if not ESX.IsPlayerLoaded() or (ESX.PlayerData.job.name ~= "mechanik" and ESX.PlayerData.job.name ~= "ec") then return end
	
	for k, v in pairs(Config.Zones[ESX.PlayerData.job.name]) do
		mechanikTargets[#mechanikTargets + 1] = ox_target:addBoxZone({
			coords = vec3(v.coords.x, v.coords.y, v.coords.z),
			size = v.size,
			rotation = v.rotation,
			debug = false,
			options = {
				{
					name = 'esx_mechanik:targets' .. k,
					icon = v.icon,
					label = v.label,
					canInteract = function(_, distance)
						return not LocalPlayer.state.IsDead and not LocalPlayer.state.IsHandcuffed and distance <= 1.50 and (ESX.PlayerData.job.name == 'mechanik' or ESX.PlayerData.job.name == 'ec')
					end,
					onSelect = function()
						if k == 'BossMenu' then
							if ESX.PlayerData.job.grade >= 7 then
								TriggerServerEvent('esx_society:openbosshub', 'fraction', false, true)
							else
								ESX.ShowNotification("Nie posiadasz dostępu!")
							end
						elseif k == 'MechanicActions' then
							OpenMechanicActionsMenu()
						elseif k == 'VehicleSpawner' then
							local spawnCoords = v.coords
							local heading = v.rotation or 77.3587
							OpenMechanicVehicleSpawner(spawnCoords, heading)
						end
					end
				}
			}
		})
	end
end)

CreateThread(function()
	if ESX.PlayerLoaded then
		if ESX.PlayerData.job.name == "mechanik" or ESX.PlayerData.job.name == "ec" then
			RefreshTargets()
		else
			DeleteTargets()
		end
	end
end)
