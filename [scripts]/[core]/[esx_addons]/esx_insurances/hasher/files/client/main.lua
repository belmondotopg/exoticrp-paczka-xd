RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	ESX.PlayerData.job = Job
end)

local function canManageInsurance()
	local job = ESX.PlayerData.job
	return (job.name == 'mechanik' and (job.grade_name == 'boss' or job.grade_name == 'chief')) or (job.name == 'ambulance' and job.grade_name == 'boss')
end

local function MenuManageInsurance()
	if canManageInsurance() then
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'insurance_menu2',
		{
			title    = "Ubezpieczenia firm",
			align    = 'center',
			elements = {
				{label = "Zarządzenie", value = 'manage'},
				{label = "Dodaj firmę do listy", value = 'add'},
			}
		}, function(data2, menu2)
			menu2.close()
			if data2.current.value == 'manage' then
				ESX.TriggerServerCallback('esx_insurances:getLicenses', function(licenses)
					if licenses then
						local elements = {
							head = {'Firma', 'OC', 'NNW', 'Akcje'},
							rows = {}
						}
						for i = 1, #licenses do
							local license = licenses[i]
							table.insert(elements.rows, {
								data = license,
								cols = {
									license.job_label,
									license.oc == 1 and '✔️' or '❌',
									license.nnw == 1 and '✔️' or '❌',
									'{{Nadaj ubezpieczenie|set}} {{Zabierz|remove}}'
								}
							})
						end
						ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'insurancesManage', elements, function(data, menu)
							local jobName = ESX.PlayerData.job.name
							local insuranceType = jobName == 'mechanik' and 'oc' or 'nnw'
							local insuranceLabel = jobName == 'mechanik' and 'OC' or 'NNW'
							local hasInsurance = jobName == 'mechanik' and data.data.oc == 1 or data.data.nnw == 1
							local notHasInsurance = jobName == 'mechanik' and data.data.oc == 0 or data.data.nnw == 0

							if data.value == 'set' then
								if hasInsurance then
									ESX.ShowNotification('Ta firma posiada już ubezpieczenie ' .. insuranceLabel)
								else
									TriggerServerEvent('esx_insurances:setInsurance', 'SET', insuranceType, data.data.name)
									ESX.ShowNotification("Pomyślnie nadano ubezpieczenie " .. insuranceLabel .. " firmie " .. data.data.job_label)
								end
							elseif data.value == 'remove' then
								if notHasInsurance then
									ESX.ShowNotification('Ta firma nie posiada ubezpieczenia ' .. insuranceLabel)
								else
									TriggerServerEvent('esx_insurances:setInsurance', 'REMOVE', insuranceType, data.data.name)
									ESX.ShowNotification("Pomyślnie zabrano ubezpieczenie " .. insuranceLabel .. " firmie " .. data.data.job_label)
								end
							end
							menu.close()
						end, function(data, menu)
							menu.close()
						end)
					else
						ESX.ShowNotification("Lista jest pusta, musisz dodać nową pracę do listy!")
					end
				end)
			elseif data2.current.value == 'add' then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'job_name', {
					title = 'Wprowadź nazwę pracy (np. police)'
				}, function(data3, menu3)
					menu3.close()
					if not data3.value then
						ESX.ShowNotification('Podana nazwa pracy jest niepoprawna!')
						return
					end
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'job_label', {
						title = 'Wprowadź nazwę firmy (np. LSPD)'
					}, function(data4, menu4)
						menu4.close()
						if data4.value then
							TriggerServerEvent('esx_insurances:addInsurance', data3.value, data4.value)
						else
							ESX.ShowNotification("Podana nazawa firmy jest niepoprawna!")
						end
					end, function(data4, menu4)
						menu4.close()
					end)
				end, function(data3, menu3)
					menu3.close()
				end)
			end
		end, function(data2, menu2)
			menu2.close()
		end)
	else
		ESX.ShowNotification("Nie masz dostępu do tego menu!")
	end
end

local insurancePackages = {
	{days = 1, price = 5000},
	{days = 3, price = 13000},
	{days = 7, price = 28000},
	{days = 14, price = 52000},
	{days = 30, price = 110000},
}

local function openInsuranceMenu(station, isExtension, daysLeft)
	local options = {}

	if isExtension then
		table.insert(options, {
			title = "Twoje ubezpieczenie " .. station .. " jest ważne",
			description = daysLeft and ("Pozostało dni: " .. daysLeft) or "Aktualne ubezpieczenie",
			disabled = true,
			icon = 'fa-solid fa-info-circle'
		})
	end

	for _, pkg in ipairs(insurancePackages) do
		local prefix = isExtension and "Przedłuż o " or ""
		local suffix = isExtension and "" or "Wykup ubezpieczenie na "
		table.insert(options, {
			title = prefix .. pkg.days .. " dni (" .. pkg.price .. "$)",
			description = suffix .. pkg.days .. " dni",
			icon = isExtension and 'fa-solid fa-clock' or 'fa-solid fa-dollar-sign',
			onSelect = function()
				local alert = lib.alertDialog({
					header = 'Czy jesteś pewny?',
					content = (isExtension and "Przedłużenie" or "Kupując") .. " ubezpieczenia na " .. pkg.days .. " dni",
					centered = true,
					cancel = true
				})

				if alert then
					TriggerServerEvent('esx_insurances:sell', station, pkg.days, isExtension)
				end
			end
		})
	end

	local menuId = isExtension and "extendInsuranceMenu" or "openMenuInsurance"
	lib.registerContext({
		id = menuId,
		title = (isExtension and "Przedłużenie ubezpieczenia " or "Zakup ubezpieczenia ") .. station,
		options = options
	})

	lib.showContext(menuId)
end

local function MenuInsurance(station)
	if station ~= 'NNW' and station ~= 'OC' then
		if canManageInsurance() then
			MenuManageInsurance()
		else
			ESX.ShowNotification('Nie posiadasz dostępu do tego menu!')
		end
		return
	end

	ESX.UI.Menu.CloseAll()
	ESX.TriggerServerCallback('esx_insurances:check', function(data)
		openInsuranceMenu(station, data ~= nil, data and data.daysLeft or nil)
	end, station)
end

local ox_target = exports.ox_target

local function canInteract()
	return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle)
end

local function onEnter(point)
	if point.entity then return end

	local model = lib.requestModel(`s_m_m_highsec_01`)
	local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)

	TaskStartScenarioInPlace(entity, point.anim, 0, true)
	SetModelAsNoLongerNeeded(model)
	FreezeEntityPosition(entity, true)
	SetEntityInvincible(entity, true)
	SetBlockingOfNonTemporaryEvents(entity, true)

	local station = point.mechanik and 'OC' or 'NNW'
	local distance = point.mechanik and 3.0 or 2.0
	local manageCheck = point.mechanik and 
		(ESX.PlayerData.job.name == 'mechanik' and ESX.PlayerData.job.grade_name == 'boss') or
		(not point.mechanik and ESX.PlayerData.job.name == 'ambulance' and ESX.PlayerData.job.grade_name == 'boss')

	ox_target:addLocalEntity(entity, {
		{
			icon = 'fa-solid fa-chalkboard-user',
			label = point.label,
			canInteract = canInteract,
			onSelect = function()
				MenuInsurance(station)
			end,
			distance = distance
		},
		{
			icon = 'fa-solid fa-building-columns',
			label = 'Zarządzaj',
			canInteract = function()
				return canInteract() and manageCheck
			end,
			onSelect = function()
				MenuInsurance()
			end,
			distance = distance
		}
	})

	point.entity = entity
end
 
local function onExit(point)
	if not point.entity then return end

	ox_target:removeLocalEntity(point.entity, point.label)
	
	if DoesEntityExist(point.entity) then
		SetEntityAsMissionEntity(point.entity, false, true)
		DeleteEntity(point.entity)
	end

	point.entity = nil
end

local localPedsSpawn = {
	{coords = vec3(874.9579, -2100.2285, 30.4797), heading = 178.3076, mechanik = true, anim = 'WORLD_HUMAN_GUARD_STAND_CASINO', label = 'Przeglądaj ubezpieczenia'},
	{coords = vec3(1139.3458, -1539.7021, 39.5036), heading = 356.8668, mechanik = false, anim = 'WORLD_HUMAN_GUARD_STAND_CASINO', label = 'Przeglądaj ubezpieczenia'},
	{coords = vec3(1144.4509, -1545.0334, 35.0332), heading = 270.9554, mechanik = false, anim = 'WORLD_HUMAN_GUARD_STAND_CASINO', label = 'Przeglądaj ubezpieczenia'},
}

Citizen.CreateThread(function()
	for k, v in pairs(localPedsSpawn) do
		lib.points.new({
			id = 145 + k,
			coords = v.coords,
			distance = 50,
			onEnter = onEnter,
			onExit = onExit,
			label = v.label,
			heading = v.heading,
			mechanik = v.mechanik,
			anim = v.anim
		})
	end
end)