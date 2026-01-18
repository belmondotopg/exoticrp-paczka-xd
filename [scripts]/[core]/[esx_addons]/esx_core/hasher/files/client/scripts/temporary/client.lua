local esx_hud = exports.esx_hud
local TriggerServerEvent = TriggerServerEvent
local LocalPlayer = LocalPlayer
local ox_inventory = exports.ox_inventory
local ox_target = exports.ox_target

-- Legalny lombard - widoczny na mapie, daje normalną gotówkę
local LombardMain = {
	obraz = 2000,
	bizuteria = 4000,
	figurka = 3000,
	zegarek = 1500,
	konsola = 1500,
	malalufa = 150,
	malyszkielet = 50,
	spust = 250,
	metal = 100,
	tasma = 50,
	handcuffs = 300,
	WEAPON_CROWBAR = 500,
}

-- Nielegalne lombardy - nieznana lokalizacja, dają brudną gotówkę
local LombardItemsSecond = {
	-- Klamy - niskie ceny
	figurka = 150,
	bizuteria = 200,
	zegarek = 250,
	
	-- Podstawowa elektronika
	phone = 300,
	lornetka = 350,
	clean_pendrive = 250,
	
	-- Średnia elektronika
	konsola = 1100,
	gopro = 1000,
	clean_disk = 650,
	mastercard = 800,
	
	-- Podstawowa biżuteria
	ring = 650,
	necklace = 800,
	
	-- Cenna biżuteria
	goldwatch = 1600,
	gold = 1300,
	
	-- Premium biżuteria - najcenniejsze
	rolex = 2600,
	diamond_ring = 2400,
	diamond = 1800,
	
	-- Sztuka i kolekcjonerskie - bardzo cenne
	obraz = 3200,
	artskull = 3000,
	artegg = 2700,
	panther = 4200,
}

local LombardItemsThird = {
	gold = 500,
	diamond = 1250,
}

local LombardItemsFourth = {
	diamond = 500,
	goldwatch = 1000,
	ring = 1000,
	necklace = 1000,
}

local RestrictedJobs = {
	police = true,
	offpolice = true,
	ambulance = true,
	offambulance = true,
}

local function canInteract()
	return not (LocalPlayer.state.IsHandcuffed or LocalPlayer.state.InTrunk or cache.vehicle)
end

local function canInteractMoney()
	if not canInteract() then return false end
	return not RestrictedJobs[ESX.PlayerData.job.name]
end

local function createProgressBar(duration)
	return esx_hud:progressBar({
		duration = duration,
		label = 'Rozmawianie',
		useWhileDead = false,
		canCancel = true,
		disable = {
			car = true,
			move = true,
			combat = true,
			mouse = false,
		},
		anim = {
			dict = 'oddjobs@taxi@',
			clip = 'idle_a'
		},
		prop = {},
	})
end

local function buildLombardMenu(items, eventName, menuTitle)
	local elements = {}
	local hasItems = false

	for _, v in pairs(ESX.GetPlayerData().inventory) do
		local price = items[v.name]
		if price and v.count > 0 then
			table.insert(elements, {
				label = ('%s - <span style="color:green;">$%s</span>'):format(v.label, ESX.Math.GroupDigits(price)),
				name = v.name,
				price = price,
				type = 'slider',
				value = 1,
				min = 1,
				max = v.count
			})
			hasItems = true
		end
	end

	if not hasItems then
		ESX.ShowNotification('Nie masz nic co by mnie interesowało')
		return
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'scrap_trader', {
		title = menuTitle,
		align = 'center',
		elements = elements
	}, function(data, menu)
		menu.close()
		Citizen.Wait(500)
		TriggerServerEvent(eventName, data.current.name, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(point.model)
		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z - 1.0, point.heading, false, true)

		TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_SMOKING', 0, true)
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)
		
		local menuConfig = {
			lombard_menu_main = {
				icon = 'fa fa-laptop',
				label = 'Zacznij rozmowę',
				items = LombardMain,
				event = 'esx_core:lombardShop',
				title = 'Lombard'
			},
			lombard_menu_houses = {
				icon = 'fa fa-laptop',
				label = 'Zacznij rozmowę',
				items = LombardItemsSecond,
				event = 'esx_core:lombardShopSecond',
				title = 'Nieznajomy'
			},
			lombard_menu_containers = {
				icon = 'fa fa-laptop',
				label = 'Zacznij rozmowę',
				items = LombardItemsThird,
				event = 'esx_core:lombardShopThird',
				title = 'Nieznajomy'
			},
			lombard_menu_vangelico = {
				icon = 'fa fa-laptop',
				label = 'Zacznij rozmowę',
				items = LombardItemsFourth,
				event = 'esx_core:lombardShopFourth',
				title = 'Nieznajomy'
			}
		}

		for menuType, config in pairs(menuConfig) do
			if point[menuType] then
				ox_target:addLocalEntity(entity, {
					{
						icon = config.icon,
						label = config.label,
						canInteract = canInteract,
						onSelect = function()
							if createProgressBar(3) then
								ESX.UI.Menu.CloseAll()
								buildLombardMenu(config.items, config.event, config.title)
							else
								ESX.ShowNotification('Anulowano.')
							end
						end,
						distance = 2.0
					}
				})
				break
			end
		end

		if point.money_menu then
			ox_target:addLocalEntity(entity, {
				{
					icon = 'fas fa-business-time',
					label = 'Wymień mi tą gotówkę!',
					canInteract = canInteractMoney,
					onSelect = function()
						local count = ox_inventory:Search('count', 'black_money')

						if count == 0 then
							ESX.ShowNotification('Nie masz nic co mogłoby mnie zainteresować!')
							return
						end

						if count < 5000 then
							ESX.ShowNotification('Masz tego za mało, spadaj ode mnie!')
							return
						end

						if createProgressBar(30) then
							Citizen.Wait(500)
							TriggerServerEvent("esx_core:useAtBusiness", ESX.GetClientKey(LocalPlayer.state.playerIndex), count)
						else
							ESX.ShowNotification('Anulowano.')
						end
					end,
					distance = 2.0
				}
			})
		end

		point.entity = entity
	end
end

local function onExit(point)
	local entity = point.entity
	if not entity then return end

	ox_target:removeLocalEntity(entity, point.label)

	if DoesEntityExist(entity) then
		SetEntityAsMissionEntity(entity, false, true)
		DeleteEntity(entity)
	end

	point.entity = nil
end

local peds = {}
local blips = {}

local function createLombardBlip(coords, name)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blip, 280)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.8)
	SetBlipColour(blip, 2)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
	return blip
end

Citizen.CreateThread(function()
	for k, v in pairs(Config.PedHeistSpawns) do
		if v.lombard_menu_main then
			blips[k] = createLombardBlip(v.coords, 'Lombard')
		end

		peds[k] = lib.points.new({
			id = 40 + k,
			coords = v.coords,
			distance = 200,
			onEnter = onEnter,
			onExit = onExit,
			heading = v.heading,
			model = v.model,
			lombard_menu_houses = v.lombard_menu_houses,
			lombard_menu_main = v.lombard_menu_main,
			lombard_menu_containers = v.lombard_menu_containers,
			lombard_menu_vangelico = v.lombard_menu_vangelico,
			money_menu = v.money_menu,
		})
	end
end)