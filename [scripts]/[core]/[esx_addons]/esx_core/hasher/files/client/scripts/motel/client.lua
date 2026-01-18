local ESX = ESX
local Citizen = Citizen
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local IsControlJustPressed = IsControlJustPressed
local RegisterNetEvent = RegisterNetEvent

local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target
local LocalPlayer = LocalPlayer

local cloakroomTarget, enterTarget, exitTarget = 0, 0, 0
local bucket = 0

local pending = false
local pending_time = 30
local haveTargets = false

LocalPlayer.state:set('InMotel', false, true)

local function ManageMotel()
	local options = {}
	local menu = nil

	options[0] = {
		title = 'Zwiększ pojemność skrytki',
		onSelect = function()
			ESX.TriggerServerCallback('esx_core:getStorageLevel', function(getStorageKilograms)
				if getStorageKilograms >= 100 then
					ESX.ShowNotification('Skrytka została ulepszona już maksymalnie!')
					return
				end

				lib.hideMenu(menu)

				local input = lib.inputDialog('Zarządzanie (1kg = 1000$)', {
					{ type = 'slider', label = 'Pojemność', description = 'Zwiększanie pojemności skrytki', required = true, min = 1, max = (100 - getStorageKilograms) },
				})

				if input then
					if input[1] then
						if input[1] <= 100 then
							local price = input[1] * 1000

							ESX.TriggerServerCallback('esx_core:onCheckMoney', function(hasEnoughMoney)
								if hasEnoughMoney then
									TriggerServerEvent('esx_core:upgradeStorage', input[1])
								else
									ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (' ..
										ESX.Math.GroupDigits(price) .. '$)')
								end
							end, nil, price)
						end
					end
				end
			end)
		end
	}

	options[1] = {
		title = 'Zaproś do środka',
		onSelect = function()
			ESX.TriggerServerCallback('esx_core:getOutsidePlayers', function(getPlayers)
				lib.hideMenu(menu)
				local players = getPlayers
				local options = {}

				options[0] = {
					title = 'Wybierz osobę którą chcesz zaprosić do środka',
					disabled = true,
				}

				for k, v in pairs(players) do
					options[k] = {
						title = v.id .. ' | ' .. v.name,
						onSelect = function()
							TriggerServerEvent('esx_core:inviteToMotel', v.id)
						end
					}
				end

				lib.registerContext({
					id = 'esx_core:invitePlayerList',
					title = 'Zaproś do środka',
					options = options
				})

				lib.showContext('esx_core:invitePlayerList')
			end)
		end
	}

	menu = lib.registerContext({
		id = 'esx_core:manageMotel',
		title = 'Zarządzaj',
		options = options
	})

	lib.showContext('esx_core:manageMotel')
end

local function ExitMotel()
	DoScreenFadeOut(2000)
	Wait(2000)
	TriggerServerEvent('esx_core:exitFromMotel')
	Wait(1000)
	DoScreenFadeIn(1000)
end

local function EnterMotel(bucket)
	if not bucket then return end
	DoScreenFadeOut(2000)
	Wait(2000)
	TriggerServerEvent('esx_core:getInToMotel', bucket)
	Wait(1000)
	DoScreenFadeIn(1000)
end

local function OpenCloakroom()
	ESX.UI.Menu.CloseAll()

	exports.qf_skinmenu:openClothingShopMenuHousing()
end

local function OpenInventory()
	ESX.UI.Menu.CloseAll()

	if ox_inventory:openInventory('stash', { id = 'hotel_' .. ESX.PlayerData.identifier }) == false then
		TriggerServerEvent('esx_core:createInventory')
		ox_inventory:openInventory('stash', { id = 'hotel_' .. ESX.PlayerData.identifier })
	end
end

Citizen.CreateThread(function()
	enterTarget = ox_target:addBoxZone({
		coords = vec3(-736.4, -2275.5, 13.6),
		size = vec3(5.8, 1, 3.3),
		rotation = 315.0,
		debug = false,
		options = {
			{
				name = 'enter_motel',
				icon = 'fa-solid fa-house-chimney',
				label = 'Wejdź do środka',
				onSelect = function()
					lib.callback("esx_core:getMotelBuyed", false, function(buyed, houseBucket)
						if not buyed then
							ESX.TriggerServerCallback('esx_core:onCheckMoney', function(hasEnoughMoney)
								if hasEnoughMoney then
									ESX.ShowNotification('Otrzymano kluczyki do pokoju, jest teraz twój!')
								else
									ESX.ShowNotification('Nie posiadasz wystarczająco pieniędzy (25.000$)')
								end
							end, 'apartment')
						else
							bucket = houseBucket
							EnterMotel(bucket)
						end
					end)
				end
			},
		},
	})
end)

local function startInviteCount(ownerId)
	pending_time = 30
	pending = true

	Citizen.CreateThread(function()
		while pending do
			pending_time = pending_time - 1
			if pending_time <= 0 then
				pending = false
				pending_time = 0
				ESX.ShowNotification('Zaproszenie wygasło')
			end
			Citizen.Wait(1000)
		end
	end)

	Citizen.CreateThread(function()
		while pending do
			if IsControlJustPressed(0, 47) then
				TriggerServerEvent('esx_core:acceptedInvite', ownerId)
				pending = false
				pending_time = 30
			end
			Citizen.Wait(0)
		end
	end)
end

RegisterNetEvent('esx_core:inviteRequestToMotel', function(ownerName, ownerId)
	pending = false
	pending_time = 0
	ESX.ShowNotification('Otrzymałeś zaproszenie do środka od ' ..
		ownerName .. ', aby zaakceptować kliknij [G] (30 sekund)')
	startInviteCount(ownerId)
end)

RegisterNetEvent('esx_core:initZones', function(guest)
	if haveTargets then return end

	if not guest then
		exitTarget = ox_target:addBoxZone({
			coords = vec3(151.4, -1008.35, -99.0),
			size = vec3(0.25, 1.2, 2.55),
			rotation = 90.0,
			debug = false,
			options = {
				{
					name = 'exit_motel',
					icon = 'fa-solid fa-house-chimney',
					label = 'Wyjdź na zewnątrz',
					onSelect = function()
						ExitMotel()
					end
				},
				{
					name = 'manage_motel',
					icon = 'fa-solid fa-house-laptop',
					label = 'Zarządzaj',
					onSelect = function()
						ManageMotel()
					end
				},
			},
		})

		cloakroomTarget = ox_target:addBoxZone({
			coords = vec3(150.9, -1001.5, -99.0),
			size = vec3(1.05, 1.8, 2.05),
			rotation = 90.0,
			debug = false,
			options = {
				{
					name = 'cloakroom_target',
					icon = 'fa-solid fa-shirt',
					label = 'Otwórz szafę',
					onSelect = function()
						OpenCloakroom()
					end
				},
				{
					name = 'inventory_target',
					icon = 'fa-solid fa-house-chimney',
					label = 'Otwórz skrytkę',
					onSelect = function()
						OpenInventory()
					end
				},
			},
		})
	else
		exitTarget = ox_target:addBoxZone({
			coords = vec3(151.4, -1008.35, -99.0),
			size = vec3(0.25, 1.2, 2.55),
			rotation = 90.0,
			debug = false,
			options = {
				{
					name = 'exit_motel',
					icon = 'fa-solid fa-house-chimney',
					label = 'Wyjdź na zewnątrz',
					onSelect = function()
						ExitMotel()
					end
				},
			},
		})

		cloakroomTarget = ox_target:addBoxZone({
			coords = vec3(150.9, -1001.5, -99.0),
			size = vec3(1.05, 1.8, 2.05),
			rotation = 90.0,
			debug = false,
			options = {
				{
					name = 'cloakroom_target',
					icon = 'fa-solid fa-shirt',
					label = 'Otwórz szafę',
					onSelect = function()
						OpenCloakroom()
					end
				},
			},
		})
	end

	haveTargets = true
end)

RegisterNetEvent('esx_core:remZones', function()
	if haveTargets then haveTargets = false end
	exports['ox_target']:removeZone(exitTarget)
	exports['ox_target']:removeZone(cloakroomTarget)
end)

AddEventHandler("onResourceStop", function(resource)
	if resource == GetCurrentResourceName() then
		ox_target:removeZone(enterTarget)
		ox_target:removeZone(exitTarget)
		ox_target:removeZone(cloakroomTarget)
	end
end)
