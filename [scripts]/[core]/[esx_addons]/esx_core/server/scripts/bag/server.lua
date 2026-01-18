local registeredStashes = {}
local ox_inventory = exports.ox_inventory

local function GenerateText(num)
	local str
	repeat
		local chars = {}
		for i = 1, num do
			chars[i] = string.char(math.random(65, 90))
		end
		str = table.concat(chars)
	until str ~= 'POL' and str ~= 'EMS'
	return str
end

local function GenerateSerial(text)
	if text and #text > 3 then
		return text
	end
	local textPart = text or GenerateText(3)
	return ('%s%s%s'):format(math.random(100000, 999999), textPart, math.random(100000, 999999))
end

RegisterServerEvent('esx_core:openBag')
AddEventHandler('esx_core:openBag', function(identifier)
	if not registeredStashes[identifier] then
		ox_inventory:RegisterStash('bag_'..identifier, 'Torba', Config.BackpackStorage.slots, Config.BackpackStorage.weight, false)
		registeredStashes[identifier] = true
	end
end)

lib.callback.register('esx_core:getNewIdentifier', function(source, slot)
	local newId = GenerateSerial()
	ox_inventory:SetMetadata(source, slot, {identifier = newId})
	ox_inventory:RegisterStash('bag_'..newId, 'Torba', Config.BackpackStorage.slots, Config.BackpackStorage.weight, false)
	registeredStashes[newId] = true
	return newId
end)

CreateThread(function()
	while GetResourceState('ox_inventory') ~= 'started' do
		Wait(500)
	end
	
	local swapHook = ox_inventory:registerHook('swapItems', function(payload)
		local destination = payload.toInventory
		local moveType = payload.toType
		local countBackpacks = ox_inventory:GetItem(payload.source, 'bag', nil, true)
		
		if string.find(destination, 'bag_', 1, true) then
			TriggerClientEvent('ox_lib:notify', payload.source, {type = 'error', title = "", description = Strings.backpack_in_backpack})
			return false
		end
		
		if Config.OneBagInInventory then
			if countBackpacks > 0 and moveType == 'player' and destination ~= payload.fromInventory then
				TriggerClientEvent('ox_lib:notify', payload.source, {type = 'error', title = "", description = Strings.one_backpack_only})
				return false
			end
		end
		
		return true
	end, {
		print = false,
		itemFilter = {
			bag = true
		}
	})
	
	local createHook
	if Config.OneBagInInventory then
		createHook = ox_inventory:registerHook('createItem', function(payload)
			local countBackpacks = ox_inventory:GetItem(payload.inventoryId, 'bag', nil, true)
			
			if countBackpacks > 0 then
				local playerItems = ox_inventory:GetInventoryItems(payload.inventoryId)
				local keepSlot = nil
				
				for _, item in pairs(playerItems) do
					if item.name == 'bag' then
						keepSlot = item.slot
						break
					end
				end
				
				CreateThread(function()
					local inventoryId = payload.inventoryId
					Wait(1000)
					
					local items = ox_inventory:GetInventoryItems(inventoryId)
					for _, item in pairs(items) do
						if item.name == 'bag' and keepSlot and item.slot ~= keepSlot then
							local success = ox_inventory:RemoveItem(inventoryId, 'bag', 1, nil, item.slot)
							if success then
								TriggerClientEvent('ox_lib:notify', inventoryId, {type = 'error', title = "", description = Strings.one_backpack_only})
							end
							break
						end
					end
				end)
			end
		end, {
			print = false,
			itemFilter = {
				bag = true
			}
		})
	end
	
	AddEventHandler('onResourceStop', function()
		ox_inventory:removeHooks(swapHook)
		if Config.OneBagInInventory and createHook then
			ox_inventory:removeHooks(createHook)
		end
	end)
end)

RegisterNetEvent("esx_core:sv:bag:renameBag", function(slotId, newName)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then
		return
	end
	
	local nameLength = #newName
	if nameLength == 0 or nameLength > 15 then
		xPlayer.showNotification("Nazwa torby jest nieprawidłowa")
		return
	end
	
	local slot = ox_inventory:GetSlot(src, slotId)
	if not slot or slot.name ~= 'bag' then
		return
	end
	
	local success = ox_inventory:RemoveItem(src, 'bag', 1, slot.metadata, slot.slot)
	if success then
		local newMetadata = slot.metadata
		newMetadata.description = newName
		ox_inventory:AddItem(src, 'bag', 1, newMetadata, slot.slot, function(addSuccess)
			if addSuccess then
				xPlayer.showNotification("Nazwa torby została zmieniona")
			end
		end)
	end
end)