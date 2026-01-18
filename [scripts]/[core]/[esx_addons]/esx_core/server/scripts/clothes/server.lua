local function createItemDescription(skin1, skin2)
	return 'Numer [' .. skin1 .. '] Wariant [' .. skin2 .. ']'
end

local function createItemMetadata(skin1, skin2)
	return {
		accessories = skin1,
		accessories2 = skin2,
		description = createItemDescription(skin1, skin2)
	}
end

local validClothingTypes = {
	jeans = true,
	shoes = true,
	mask = true,
	helmet = true,
	glasses = true,
	arms = true,
	bagcloth = true,
	vest = true,
	chain = true,
	bracelet = true,
	watchcloth = true,
	ears = true,
	tshirt = true
}

RegisterServerEvent('esx_core:remove:clothes', function(skin1, skin2, type)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	xPlayer.removeInventoryItem(type, 1, createItemMetadata(skin1, skin2))
end)

RegisterServerEvent('esx_core:add:clothes', function(skin1, skin2, type)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	if validClothingTypes[type] then
		xPlayer.addInventoryItem(type, 1, createItemMetadata(skin1, skin2))
	end
end)

RegisterServerEvent('esx_core:add:clothestorso', function(skin1, skin2, skin3, skin4, skin5, skin6)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	if skin1 ~= 15 then
		xPlayer.addInventoryItem('torso', 1, createItemMetadata(skin1, skin2))
	end

	if skin3 ~= 15 then
		xPlayer.addInventoryItem('arms', 1, createItemMetadata(skin3, skin4))
	end

	if skin5 ~= -1 then
		xPlayer.addInventoryItem('tshirt', 1, createItemMetadata(skin5, skin6))
	end
end)

RegisterServerEvent('esx_core:add:clothestshirt', function(skin1, skin2)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if not xPlayer then return end

	if skin1 ~= -1 then
		xPlayer.addInventoryItem('tshirt', 1, createItemMetadata(skin1, skin2))
	end
end)