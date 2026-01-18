local ox_inventory = exports.ox_inventory

local function getIdentifierFromSSN(ssn)
	return MySQL.scalar.await('SELECT `identifier` FROM `users` WHERE `id` = ?', {ssn})
end

lib.callback.register('esx_police/registerStashBySSN', function(source, ssn)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	local tPlayerIdentifier = getIdentifierFromSSN(ssn)
	local stash = {
		owner = tPlayerIdentifier,
		id = 'schowekwiezienny_'..ssn,
		label = 'Schowek więzienny #'..ssn,
		slots = 50,
		weight = 100 * 1000
	}
	ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, stash.owner)
	return true
end)

lib.callback.register('esx_police/getItemsStashBySSN', function(source)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end
	local stashId = 'schowekwiezienny_'..Player(src).state.ssn
	local inventory = ox_inventory:GetInventory(stashId)
	if inventory and inventory.items then
		for i = 1, #inventory.items do
			local item = inventory.items[i]
			ox_inventory:AddItem(src, item.name, item.count, item.metadata, item.slot)
			ox_inventory:RemoveItem(stashId, item.name, item.count, item.metadata, item.slot)
		end
	end
	return inventory and inventory.items and #inventory.items > 0
end)