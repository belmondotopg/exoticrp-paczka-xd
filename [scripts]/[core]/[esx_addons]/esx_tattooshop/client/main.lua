local currentTattoos = {}
local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local InTattooMenu = false
local ShopOrigin = nil
local ShopZoneRadius = 6.0
local PreviewTattoo = nil

CreateThread(function()
	Wait(30000)
	ESX.TriggerServerCallback('esx_tattooshop:requestPlayerTattoos', function(tattooList)
		currentTattoos = tattooList or {}
		ClearPedDecorations(PlayerPedId())
		if currentTattoos and type(currentTattoos) == 'table' then
			for _,k in pairs(currentTattoos) do
				if k.category and tattoosList[k.category] then
					for i=1, #tattoosList[k.category] do
						if k.collection == tattoosList[k.category][i].collection and k.texture == tattoosList[k.category][i].number then
							ApplyPedOverlay(PlayerPedId(), GetHashKey(k.collection), GetHashKey(tattoosList[k.category][i].nameHash))
						end
					end
				end
			end
		end
	end)
end)

function OpenShopMenu()
	local elements = {}
	for _,k in pairs(tattoosCategories) do
		elements[#elements+1] = {label = k.name, value = k.value}
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tattoos_main', {
		title = _U('tattoos'),
		align = 'right',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'delete' then
			TriggerServerEvent('esx_tattooshop:delete')
		else
			local category = data.current.value
			local list = {{label = _U('go_back_to_menu'), value = nil}}

			for i=1, #tattoosList[category] do
				list[#list+1] = {
					label = _U('tattoo') .. ' #' .. i .. ' - ' .. _U('money_amount', tattoosList[category][i].price),
					value = tattoosList[category][i].number,
					collection = tattoosList[category][i].collection,
					price = tattoosList[category][i].price
				}
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'tattoos_list', {
				title = _U('tattoos'),
				align = 'right',
				elements = list
			}, function(data2, menu2)
				if data2.current.value then
					TriggerServerEvent('esx_tattooshop:save', currentTattoos, data2.current.price, {
						collection = data2.current.collection,
						texture = data2.current.value,
						category = category
					})
				else
					menu2.close()
					OpenShopMenu()
					redrawTattoos()
				end
			end, function(data2, menu2)
				menu2.close()
				redrawTattoos()
			end, function(data2, menu2)
				if data2.current.value then
					drawTattoo(data2.current.value, data2.current.collection, category)
				end
			end)
		end
	end, function(data, menu)
		menu.close()
		InTattooMenu = false
		ShopOrigin = nil
		setPedSkin()
	end)
end

function redrawTattoos()
	ClearPedDecorations(PlayerPedId())
	if currentTattoos and type(currentTattoos) == 'table' then
		for _,k in pairs(currentTattoos) do
			if k.category and tattoosList[k.category] then
				for i=1, #tattoosList[k.category] do
					if k.collection == tattoosList[k.category][i].collection and k.texture == tattoosList[k.category][i].number then
						ApplyPedOverlay(PlayerPedId(), GetHashKey(k.collection), GetHashKey(tattoosList[k.category][i].nameHash))
					end
				end
			end
		end
	end
	if PreviewTattoo then
		for i=1, #tattoosList[PreviewTattoo.category] do
			if PreviewTattoo.collection == tattoosList[PreviewTattoo.category][i].collection
			and PreviewTattoo.texture == tattoosList[PreviewTattoo.category][i].number then
				ApplyPedOverlay(PlayerPedId(), GetHashKey(PreviewTattoo.collection), GetHashKey(tattoosList[PreviewTattoo.category][i].nameHash))
				break
			end
		end
	end
end

function drawTattoo(current, collection, category)
	PreviewTattoo = {
		collection = collection,
		texture = current,
		category = category
	}
	redrawTattoos()
end

CreateThread(function()
	while true do
		Wait(10)
		local coords = GetEntityCoords(PlayerPedId())
		local isInMarker = false

		for k,v in pairs(Config.Zones) do
			local zoneCoords = Config.Target
				and vec3(v.MenuCoords.x, v.MenuCoords.y, v.MenuCoords.z)
				or vec3(v.x, v.y, v.z)

			if #(coords - zoneCoords) < Config.Size.x then
				isInMarker = true
				LastZone = k
			end
		end

		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			CurrentAction = 'tattoo_shop'
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			CurrentAction = nil
			ESX.UI.Menu.CloseAll()
		end
	end
end)

CreateThread(function()
	while true do
		Wait(200)
		if InTattooMenu and ShopOrigin then
			if #(GetEntityCoords(PlayerPedId()) - ShopOrigin) > ShopZoneRadius then
				InTattooMenu = false
				ShopOrigin = nil
				PreviewTattoo = nil
				ESX.UI.Menu.CloseAll()
				setPedSkin()
				ESX.ShowNotification('Oddaliłeś się za daleko od studia tatuażu')
			end
		end
	end
end)

CreateThread(function()
	for _,v in pairs(Config.Zones) do
		local blip = AddBlipForCoord(v.PedCoords.x, v.PedCoords.y, v.PedCoords.z)
		SetBlipSprite(blip, 75)
		SetBlipColour(blip, 1)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(_U('tattoo_shop'))
		EndTextCommandSetBlipName(blip)

		RequestModel(joaat(v.PedCoords.hash))
		while not HasModelLoaded(joaat(v.PedCoords.hash)) do Wait(0) end

		local ped = CreatePed(4, v.PedCoords.hash, v.PedCoords.x, v.PedCoords.y, v.PedCoords.z - 1.0, v.PedCoords.h, false, true)
		FreezeEntityPosition(ped, true)
		SetEntityInvincible(ped, true)
		SetBlockingOfNonTemporaryEvents(ped, true)

		exports.qtarget:AddTargetEntity(ped, {
			options = {{
				event = 'esx_tattooshop:target:openshop',
				icon = 'fas fa-bag-shopping',
				label = 'Skorzystaj z usług'
			}},
			distance = 2
		})
	end
end)

RegisterNetEvent('esx_tattooshop:target:openshop', function()
	if InTattooMenu then return end
	InTattooMenu = true
	ShopOrigin = GetEntityCoords(PlayerPedId())

	local ped = PlayerPedId()
	local sex = GetPedDrawableVariation(ped, 0)

	if sex == 0 then
		SetPedComponentVariation(ped, 8, 15, 0, 2)
		SetPedComponentVariation(ped, 11, 15, 0, 2)
		SetPedComponentVariation(ped, 3, 15, 0, 2)
		SetPedComponentVariation(ped, 4, 14, 0, 2)
	else
		SetPedComponentVariation(ped, 8, 15, 0, 2)
		SetPedComponentVariation(ped, 11, 15, 0, 2)
		SetPedComponentVariation(ped, 3, 15, 0, 2)
		SetPedComponentVariation(ped, 4, 15, 0, 2)
	end

	OpenShopMenu()
end)

function setPedSkin()
	ESX.TriggerServerCallback('exotic_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)

	Wait(500)
	PreviewTattoo = nil
	redrawTattoos()
end

RegisterNetEvent('esx_tattooshop:buySuccess', function(tattoo)
	currentTattoos[#currentTattoos+1] = {
		collection = tattoo.collection,
		texture = tattoo.texture,
		category = tattoo.category
	}
	PreviewTattoo = nil
	redrawTattoos()
end)
