if not lib then return end

local Items = require 'modules.items.shared' --[[@as table<string, OxClientItem>]]

local function sendDisplayMetadata(data)
    SendNUIMessage({
		action = 'displayMetadata',
		data = data
	})
end

--- use array of single key value pairs to dictate order
---@param metadata string | table<string, string> | table<string, string>[]
---@param value? string
local function displayMetadata(metadata, value)
	local data = {}

	if type(metadata) == 'string' then
        if not value then return end

        data = { { metadata = metadata, value = value } }
	elseif table.type(metadata) == 'array' then
		for i = 1, #metadata do
			for k, v in pairs(metadata[i]) do
				data[i] = {
					metadata = k,
					value = v,
				}
			end
		end
	else
		for k, v in pairs(metadata) do
			data[#data + 1] = {
				metadata = k,
				value = v,
			}
		end
	end

    if client.uiLoaded then
        return sendDisplayMetadata(data)
    end

    CreateThread(function()
        repeat Wait(100) until client.uiLoaded

        sendDisplayMetadata(data)
    end)
end

exports('displayMetadata', displayMetadata)

---@param _ table?
---@param name string?
---@return table?
local function getItem(_, name)
    if not name then return Items end

	if type(name) ~= 'string' then return end

    name = name:lower()

    if name:sub(0, 7) == 'weapon_' then
        name = name:upper()
    end

    return Items[name]
end

setmetatable(Items --[[@as table]], {
	__call = getItem
})

---@cast Items +fun(itemName: string): OxClientItem
---@cast Items +fun(): table<string, OxClientItem>

local function Item(name, cb)
	local item = Items[name]
	if item then
		if not item.client?.export and not item.client?.event then
			item.effect = cb
		end
	end
end

local ox_inventory = exports[shared.resource]
-----------------------------------------------------------------------------------------------
-- Clientside item use functions
-----------------------------------------------------------------------------------------------

local ox_target = exports.ox_target
local options = {
	{
		name = 'ox_inventory:useSyringe',
		icon = 'fa-solid fa-syringe',
		label = 'Wstrzyknij strzykawkę',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then
				return false
			end

			if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end

			if distance > 2 then
				return false
			end

			local count = ox_inventory:Search('count', 'strzykawka')

			if count <= 0 then
				return false
			end

			if cache.vehicle then return false end

			if entity then
				if Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.IsDead then
					return true
				end
			end

			return false
		end,
		onSelect = function (data)
			if not data.entity then return end

			TriggerEvent('esx_ambulance:onSyringe', data.entity)
		end
	},
}

ox_target:addGlobalPlayer(options)

ox_target:addModel({`prop_champset`, `prop_yoga_mat_03`}, {
	{
		icon = 'fa-solid fa-hand-dots',
		label = 'Schowaj',
		canInteract = function(entity, distance, coords, name, bone)
			if LocalPlayer.state.IsHandcuffed then return false end
			if cache.vehicle then return false end

			return true
		end,
		onSelect = function (data)
			local esx_hud = exports.esx_hud

			if esx_hud:progressBar({
				duration = 2,
				label = 'Chowanie...',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = true,
					combat = true,
					mouse = false,
				},
				anim = {
					dict = 'amb@world_human_bum_wash@male@low@idle_a',
					clip = 'idle_a',
					flag = 1
				},
				prop = {},
			}) 
			then
				while not NetworkHasControlOfEntity(data.entity) do
					Citizen.Wait(1)
					NetworkRequestControlOfEntity(data.entity)
				end

				ESX.Game.DeleteObject(data.entity)
	
				lib.notify({ description = 'Schowano.' })
			else 
				ESX.ShowNotification('Anulowano.')
			end
		end,
		distance = 2.0
    },
})

Item('roza', function(data, slot)
	local cachePed = cache.ped
	ox_inventory:useItem(data, function(data)
		if data then
			local coords = GetEntityCoords(cachePed)
			local boneIndex = GetPedBoneIndex(cachePed, 57005)
			
			lib.requestAnimDict('amb@code_human_wander_drinking@beer@male@base')
			
			ESX.Game.SpawnObject('p_single_rose_s', {
				x = coords.x,
				y = coords.y,
				z = coords.z + 2
			}, function(object)
				AttachEntityToEntity(object, cachePed, boneIndex, 0.10, 0, -0.001, 80.0, 150.0, 200.0, true, true, false, true, 1, true)
				TaskPlayAnim(cachePed, "amb@code_human_wander_drinking@beer@male@base", "static", 3.5, -8, -1, 49, 0, 0, 0, 0)
			end)

			lib.notify({ description = 'Wyjęto z kieszeni pachnącą różę.' })
		end
	end)
end)

Item('kocyk', function(data, slot)
	local cachePed = cache.ped
	local esx_hud = exports.esx_hud

	ox_inventory:useItem(data, function(data)
		if data then
			if esx_hud:progressBar({
				duration = 2,
				label = 'Rozkładanie...',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = true,
					combat = true,
					mouse = false,
				},
				anim = {
					dict = 'amb@world_human_bum_wash@male@low@idle_a',
					clip = 'idle_a',
					flag = 1
				},
				prop = {},
			}) 
			then
				local coords = GetEntityCoords(cachePed)

				ESX.Game.SpawnObject('prop_yoga_mat_03',  {
					x = coords.x,
					y = coords.y,
					z = coords.z - 1
				})
				
				ESX.Game.SpawnObject('prop_yoga_mat_03',  {
					x = coords.x,
					y = coords.y - 0.9,
					z = coords.z - 1
				})
				
				ESX.Game.SpawnObject('prop_yoga_mat_03',  {
					x = coords.x,
					y = coords.y + 0.9,
					z = coords.z - 1
				})
	
				lib.notify({ description = 'Rozłożono kocyk.' })
			else 
				ESX.ShowNotification('Anulowano.')
			end
		end
	end)
end)

Item('kocyk_zestaw', function(data, slot)
	local cachePed = cache.ped
	local esx_hud = exports.esx_hud

	ox_inventory:useItem(data, function(data)
		if data then
			if esx_hud:progressBar({
				duration = 2,
				label = 'Rozkładanie...',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = true,
					move = true,
					combat = true,
					mouse = false,
				},
				anim = {
					dict = 'amb@world_human_bum_wash@male@low@idle_a',
					clip = 'idle_a',
					flag = 1
				},
				prop = {},
			}) 
			then
				local coords = GetEntityCoords(cachePed)

				ESX.Game.SpawnObject('prop_yoga_mat_03',  {
					x = coords.x,
					y = coords.y,
					z = coords.z - 1
				})
				
				ESX.Game.SpawnObject('prop_yoga_mat_03',  {
					x = coords.x,
					y = coords.y - 0.9,
					z = coords.z - 1
				})
				
				ESX.Game.SpawnObject('prop_yoga_mat_03',  {
					x = coords.x,
					y = coords.y + 0.9,
					z = coords.z - 1
				})
	
				ESX.Game.SpawnObject('prop_champset',  {
					x = coords.x,
					y = coords.y,
					z = coords.z - 1
				})
	
				lib.notify({ description = 'Rozłożono kocyk i przygotowano kieliszki.' })
			else 
				ESX.ShowNotification('Anulowano.')
			end
		end
	end)
end)

Item('apteka_opatrunek', function(data, slot)
	local cachePed = cache.ped
	local esx_hud = exports.esx_hud
	local getHealth = GetEntityHealth(cachePed)

	if getHealth < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				if esx_hud:progressBar({
					duration = 2,
					label = 'Opatrywanie ran...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'amb@world_human_bum_wash@male@low@idle_a',
						clip = 'idle_a',
						flag = 1
					},
					prop = {},
				}) 
				then
					SetEntityHealth(cachePed, GetEntityHealth(cachePed) + 25)
					lib.notify({ description = 'Założono opatrunek.' })
				else 
					ESX.ShowNotification('Anulowano.')
				end
			end
		end)
	else
		lib.notify({ description = 'Jesteś w zbyt dobrym stanie, aby skorzystać z opatrunku.' })
	end
end)

Item('apteka_bandaz', function(data, slot)
	local cachePed = cache.ped
	local esx_hud = exports.esx_hud
	local getHealth = GetEntityHealth(cachePed)
	
	if getHealth < 150 then
		ox_inventory:useItem(data, function(data)
			if data then
				if esx_hud:progressBar({
					duration = 2,
					label = 'Opatrywanie ran...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'amb@world_human_bum_wash@male@low@idle_a',
						clip = 'idle_a',
						flag = 1
					},
					prop = {},
				}) 
				then
					SetEntityHealth(cachePed, GetEntityHealth(cachePed) + 50)
					lib.notify({ description = 'Założono bandaż.' })
				else 
					ESX.ShowNotification('Anulowano.')
				end
			end
		end)
	else
		lib.notify({ description = 'Jesteś w zbyt dobrym stanie, aby skorzystać z bandażu.' })
	end
end)

Item('taco_burrito', function(data, slot)
	local cachePed = cache.ped
	local esx_hud = exports.esx_hud
	local getHealth = GetEntityHealth(cachePed)
	
	ox_inventory:useItem(data, function(data)
		if data then
			if esx_hud:progressBar({
				duration = 2,
				label = 'Zajadanie się burrito...',
				useWhileDead = false,
				canCancel = true,
				disable = {
					car = false,
					move = false,
					combat = false,
					mouse = false,
				},
				anim = {
					dict = 'mp_player_inteat@burger',
					clip = 'mp_player_int_eat_burger',
					flag = 50
				},
				prop = {},
			}) 
			then
				if getHealth < 200 then
					SetEntityHealth(cachePed, GetEntityHealth(cachePed) + 15)
				end

				TriggerEvent('esx_status:add', 'hunger', 100000)
				
				lib.notify({ description = 'Opierdolono poteżną porcję burrito...' })
			else 
				ESX.ShowNotification('Anulowano.')
			end
		end
	end)
end)

Item('lornetka', function(data, slot)
	local esx_core = exports.esx_core

	ox_inventory:useItem(data, function(data)
		if data then
			esx_core:useLornetka()
		end
	end)
end)

local showedGoPro = false

Item('gopro', function(data, slot)
	ox_inventory:useItem(data, function(data)
		if data then
			if not showedGoPro then
				TriggerServerEvent('esx_hud:updateGoPro')
			else
				TriggerEvent('esx_hud:gopro:hide')
			end

			showedGoPro = not showedGoPro
		end
	end)
end)

Item('lockpick', function(data, slot)
	ox_inventory:useItem(data, function(data)
		if data then
			TriggerEvent('esx_carkeys:lockpick:try')
		end
	end)
end)

Item('bodycam', function(data,slot)
	ox_inventory:useItem(data, function(data)
		if data then
			TriggerServerEvent('esx_hud:bodycam:start')
		end
	end)
end)

Item('armour50pd', function(data, slot)
	local cachePed = cache.ped
	if GetPedArmour(cachePed) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				SetPlayerMaxArmour(cachePed, 100)
				SetPedArmour(cachePed, 50)
				lib.notify({ description = 'Założono kamizelkę 50% LSPD.' })
			end
		end)
	end
end)

Item('armour100pd', function(data, slot)
	local cachePed = cache.ped
	if GetPedArmour(cachePed) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				SetPlayerMaxArmour(cachePed, 100)
				SetPedArmour(cachePed, 100)
				lib.notify({ description = 'Założono kamizelkę 100% LSPD.' })
			end
		end)
	end
end)

Item('armour50', function(data, slot)
	local cachePed = cache.ped
	if GetPedArmour(cachePed) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				TriggerEvent('skinchanger:getSkin', function(skin)
					if skin.sex == 0 then
						SetPedComponentVariation(cachePed, 9, 87, 0, 0)
					else
						SetPedComponentVariation(cachePed, 9, 27, 9, 0)
					end
				end)
				SetPlayerMaxArmour(cachePed, 100)
				SetPedArmour(cachePed, 50)
				lib.notify({ description = 'Założono kamizelkę 50%.' })
			end
		end)
	end
end)

Item('meth_packaged', function(data, slot)
	local cachePed = cache.ped
	if GetPedArmour(cachePed) < 25 then
		ox_inventory:useItem(data, function(data)
			if data then
				local esx_hud = exports.esx_hud
				if esx_hud:progressBar({
					duration = 3,
					label = 'Wciąganie kreski...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'anim@amb@nightclub@peds@',
						clip = 'missfbi3_party_snort_coke_b_male3',
						flag = 1
					},
					prop = {},
				}) 
				then
					lib.notify({ description = 'Wciągnąłeś/aś kreskę mety.' })
					SetPlayerMaxArmour(cachePed, 100)
					SetPedArmour(cachePed, 25)			
					TriggerEvent('esx_drugs:drugEffect', 'meth')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			end
		end)
	else
		lib.notify({ description = 'Już wystarczająco jesteś mocny/a...' })
	end
end)

Item('codeine', function(data, slot)
	local cachePed = cache.ped
	if GetPedArmour(cachePed) < 25 then
		ox_inventory:useItem(data, function(data)
			if data then
				local esx_hud = exports.esx_hud
				if esx_hud:progressBar({
					duration = 2,
					label = 'Łykanie kodeiny...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'mp_suicide',
						clip = 'pill',
						flag = 48
					},
					prop = {},
				}) 
				then
					lib.notify({ description = 'Łyknąłeś/aś pigułkę kodeiny.' })
					TriggerEvent('esx_basicneeds:onDrink', "prop_orang_can_01", "codeine")
					TriggerEvent('esx_drugs:drugEffect', 'codeine')
				else 
					ESX.ShowNotification('Anulowano.')
				end
			end
		end)
	else
		lib.notify({ description = 'Już wystarczająco jesteś mocny/a...' })
	end
end)

Item('bagniak_packaged', function(data, slot)
	if cache.vehicle then return end

	local count = ox_inventory:Search('count', 'lighter')

	if count > 0 then
		ox_inventory:useItem(data, function(data)
			if data then
				local esx_hud = exports.esx_hud
				if esx_hud:progressBar({
					duration = 4,
					label = 'Jaranie bagniaka...',
					useWhileDead = false,
					canCancel = true,
					disable = {
						car = true,
						move = true,
						combat = true,
						mouse = false,
					},
					anim = {
						dict = 'amb@world_human_smoking@male@male_a@enter',
						clip = 'enter',
						flag = 0
					},
					prop = {
						model = `prop_cigar_01`,
						bone = 47419,
						pos = vec3(0.01, 0.0, 0.0),
						rot = vec3(59.0, 0.0, -80.0)
					},
				}) 
				then
					TriggerServerEvent("esx_core:deleteOldItem", 'bagniak_packaged')
					lib.notify({ description = 'Zjarałeś/aś bagniaka.' })
					ClearPedTasks(cache.ped)
					TriggerEvent('esx_core:DoAcid', 120000)
				else 
					ESX.ShowNotification('Anulowano.')
				end
			end
		end)
	else
		ESX.ShowNotification('Nie posiadasz zapalniczki.')
	end
end)

Item('armour100', function(data, slot)
	local cachePed = cache.ped
	if GetPedArmour(cachePed) < 100 then
		ox_inventory:useItem(data, function(data)
			if data then
				TriggerEvent('skinchanger:getSkin', function(skin)
					if skin.sex == 0 then
						SetPedComponentVariation(cachePed, 9, 15, 0, 0)
					else
						SetPedComponentVariation(cachePed, 9, 30, 9, 0)
					end
				end)
				SetPlayerMaxArmour(cachePed, 100)
				SetPedArmour(cachePed, 100)
				lib.notify({ description = 'Założono kamizelkę 100%.' })
			end
		end)
	end
end)

client.parachute = false
Item('parachute', function(data, slot)
	local cachePed = cache.ped
	if not client.parachute then
		ox_inventory:useItem(data, function(data)
			if data then
				local chute = `GADGET_PARACHUTE`
				SetPlayerParachuteTintIndex(cachePed, -1)
				GiveWeaponToPed(cachePed, chute, 0, true, false)
				SetPedGadget(cachePed, chute, true)
				lib.requestModel(1269906701)
				client.parachute = {CreateParachuteBagObject(cache.ped, true, true), slot?.metadata?.type or -1}
				if slot.metadata.type then
					SetPlayerParachuteTintIndex(cachePed, slot.metadata.type)
				end
			end
		end)
	end
end)

-----------------------------------------------------------------------------------------------

exports('Items', function(item) return getItem(nil, item) end)
exports('ItemList', function(item) return getItem(nil, item) end)

return Items
