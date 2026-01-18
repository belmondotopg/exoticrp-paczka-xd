if not lib then return end

local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'
local Shops = {}
local locations = shared.target and 'targets' or 'locations'

---@class OxShopItem
---@field slot number
---@field weight number

local function setupShopItems(id, shopType, shopName, groups)
	local shop = id and Shops[shopType][id] or Shops[shopType] --[[@as OxShop]]

	for i = 1, shop.slots do
		local slot = shop.items[i]

		if slot.grade and not groups then
			print(('^1attempted to restrict slot %s (%s) to grade %s, but %s has no job restriction^0'):format(id, slot.name, json.encode(slot.grade), shopName))
			slot.grade = nil
		end

		local Item = Items(slot.name)

		if Item then
			---@type OxShopItem
			slot = {
				name = Item.name,
				slot = i,
				weight = Item.weight,
				count = slot.count,
				price = slot.price or 0,
				metadata = slot.metadata,
				license = slot.license,
				currency = slot.currency,
				grade = slot.grade
			}

			if slot.metadata then
				slot.weight = Inventory.SlotWeight(Item, slot, true)
			end

			shop.items[i] = slot
		end
	end
end

---@param shopType string
---@param properties OxShop
local function registerShopType(shopType, properties)
	local shopLocations = properties[locations] or properties.locations

	if shopLocations then
		Shops[shopType] = properties
	else
		Shops[shopType] = {
			label = properties.name,
			id = shopType,
			groups = properties.groups or properties.jobs,
			items = properties.inventory,
			slots = #properties.inventory,
			type = 'shop',
		}

		setupShopItems(nil, shopType, properties.name, properties.groups or properties.jobs)
	end
end

---@param shopType string
---@param id number
local function createShop(shopType, id)
	local shop = Shops[shopType]

	if not shop then return end

	local store = (shop[locations] or shop.locations)?[id]

	if not store then return end

	local groups = shop.groups or shop.jobs
    local coords

    if shared.target then
        if store.length then
            local z = store.loc.z + math.abs(store.minZ - store.maxZ) / 2
            coords = vec3(store.loc.x, store.loc.y, z)
        else
            coords = store.coords or store.loc
        end
    else
        coords = store
    end

	---@type OxShop
	shop[id] = {
		label = shop.name,
		id = shopType..' '..id,
		groups = groups,
		items = table.clone(shop.inventory),
		slots = #shop.inventory,
		type = 'shop',
		coords = coords,
		distance = shared.target and shop.targets?[id]?.distance,
	}

	setupShopItems(id, shopType, shop.name, groups)

	return shop[id]
end

for shopType, shopDetails in pairs(lib.load('data.shops')) do
	registerShopType(shopType, shopDetails)
end

---@param shopType string
---@param shopDetails OxShop
exports('RegisterShop', function(shopType, shopDetails)
	registerShopType(shopType, shopDetails)
end)

lib.callback.register('ox_inventory:openShop', function(source, data)
	local left, shop = Inventory(source)

	if not left then return end

	if data then
		shop = Shops[data.type]

		if not shop then return end

		if not shop.items then
			shop = (data.id and shop[data.id] or createShop(data.type, data.id))

			if not shop then return end
		end

		---@cast shop OxShop

		if shop.groups then
			local group = server.hasGroup(left, shop.groups)
			if not group then return end
		end

		if type(shop.coords) == 'vector3' and #(GetEntityCoords(GetPlayerPed(source)) - shop.coords) > 10 then
			return
		end

		---@diagnostic disable-next-line: assign-type-mismatch
		left:openInventory(left)
		left.currentShop = shop.id
	end

	return { label = left.label, type = left.type, slots = left.slots, weight = left.weight, maxWeight = left.maxWeight }, shop
end)

local function canAffordItem(inv, currency, price, shopType)
    local owned = Inventory.GetItemCount(inv, currency) -- ile w kiermanie
    local canAfford = price >= 0 and owned >= price

    if canAfford then
        return true
    else
        if currency == 'money' then
            if shopType == 'MechanikParts' then
                local xPlayer = ESX.GetPlayerFromId(inv.id)
                if xPlayer and xPlayer.job.name == 'mechanik' then
                    local societyMoney = 0
                    local accountReceived = false
                    
                    TriggerEvent('esx_addonaccount:getSharedAccount', 'mechanik', function(account)
                        if account then
                            societyMoney = account.money or 0
                        end
                        accountReceived = true
                    end)
                    
                    if societyMoney >= price then
                        return true
                    end
                    
                    local missing = price - societyMoney
                    return {
                        type = 'error',
                        description = locale('cannot_afford', ('%s%s'):format(locale('$'), math.groupdigits(missing)))
                    }
                end
            elseif shopType == 'ExoticCustomsParts' then
				local xPlayer = ESX.GetPlayerFromId(inv.id)
                if xPlayer and xPlayer.job.name == 'ec' then
                    local societyMoney = 0
                    local accountReceived = false
                    
                    TriggerEvent('esx_addonaccount:getSharedAccount', 'ec', function(account)
                        if account then
                            societyMoney = account.money or 0
                        end
                        accountReceived = true
                    end)
                    
                    if societyMoney >= price then
                        return true
                    end
                    
                    local missing = price - societyMoney
                    return {
                        type = 'error',
                        description = locale('cannot_afford', ('%s%s'):format(locale('$'), math.groupdigits(missing)))
                    }
                end
			end
            
            local xPlayer = ESX.GetPlayerFromId(inv.id)
            local bankBalance = xPlayer.getAccount('bank').money
            if bankBalance >= price then
                return true
            end
            -- oblicz ile brakuje 
            local totalOwned = owned + bankBalance
            local missing = price - totalOwned
            return {
                type = 'error',
                description = locale('cannot_afford', ('%s%s'):format(locale('$'), math.groupdigits(missing)))
            }
        else
            local missing = price - owned
            return {
                type = 'error',
                description = locale('cannot_afford', ('%s%s'):format(math.groupdigits(missing), ' '..Items(currency).label))
            }
        end
    end
end

local function removeCurrency(inv, currency, price, shopType)
    if currency ~= 'money' then
        Inventory.RemoveItem(inv, currency, price)
		return currency
    else
        if shopType == 'MechanikParts' then
            local xPlayer = ESX.GetPlayerFromId(inv.id)
            if xPlayer and xPlayer.job.name == 'mechanik' then
                local moneyRemoved = false
                
                TriggerEvent('esx_addonaccount:getSharedAccount', 'mechanik', function(account)
                    if account and account.money >= price then
                        account.removeMoney(price)
                        moneyRemoved = true
                    end
                end)

				exports.esx_society:AddTuneHistory('mechanik', os.time(), xPlayer.getName(), xPlayer.discordid, 'Kupił/a części mechaniczne za kwotę w wysokości '..price..'$', price, xPlayer.identifier)
                
                if moneyRemoved then
                    return 'Konto Frakcyjne'
                end
            end
		elseif shopType == 'ExoticCustomsParts' then
			local xPlayer = ESX.GetPlayerFromId(inv.id)
            if xPlayer and xPlayer.job.name == 'ec' then
                local moneyRemoved = false
                
                TriggerEvent('esx_addonaccount:getSharedAccount', 'ec', function(account)
                    if account and account.money >= price then
                        account.removeMoney(price)
                        moneyRemoved = true
                    end
                end)

				exports.esx_society:AddTuneHistory('ec', os.time(), xPlayer.getName(), xPlayer.discordid, 'Kupił/a części mechaniczne za kwotę w wysokości '..price..'$', price, xPlayer.identifier)
                
                if moneyRemoved then
                    return 'Konto Frakcyjne'
                end
            end
        end
        
        if Inventory.GetItem(inv, currency, false, true) >= price then
            Inventory.RemoveItem(inv, currency, price)
			return 'Gotówka'
        else
            local xPlayer = ESX.GetPlayerFromId(inv.id)
            xPlayer.removeAccountMoney('bank', price)
			return 'Bank'
        end
    end
end

local TriggerEventHooks = require 'modules.hooks.server'

local function isRequiredGrade(grade, rank)
	if type(grade) == "table" then
		for i=1, #grade do
			if grade[i] == rank then
				return true
			end
		end
		return false
	else
		return rank >= grade
	end
end

lib.callback.register('ox_inventory:buyItem', function(source, data)
	if data.toType == 'player' then
		if data.count == nil then data.count = 1 end

		local playerInv = Inventory(source)

		if not playerInv or not playerInv.currentShop then return end

		local shopType, shopId = playerInv.currentShop:match('^(.-) (%d-)$')

		if not shopType then shopType = playerInv.currentShop end

		if shopId then shopId = tonumber(shopId) end

		local shop = shopId and Shops[shopType][shopId] or Shops[shopType]
		local fromData = shop.items[data.fromSlot]
		local toData = playerInv.items[data.toSlot]

		if fromData then
			if fromData.count then
				if fromData.count == 0 then
					return false, false, { type = 'error', description = locale('shop_nostock') }
				elseif data.count > fromData.count then
					data.count = fromData.count
				end
			end

			if fromData.license and server.hasLicense and not server.hasLicense(playerInv, fromData.license) then
				return false, false, { type = 'error', description = locale('item_unlicensed') }
			end

			if fromData.grade then
				local _, rank = server.hasGroup(playerInv, shop.groups)
				if not isRequiredGrade(fromData.grade, rank) then
					return false, false, { type = 'error', description = locale('stash_lowgrade') }
				end
			end

			if fromData.metadata then
				if fromData.metadata.job then
					local _, rank = server.hasGroup(playerInv, {
						[fromData.metadata.job] = 0
					})
	
					if not rank then
						return false, false, { type = 'error', description = 'Ten przedmiot nie jest przeznaczony dla Ciebie' }
					end
				end
			end

			if fromData.metadata then
				if fromData.metadata.expiration then
					local expirationDate = os.time() + fromData.metadata.expiration
					fromData.metadata.expiration = expirationDate
					fromData.metadata.description = "Termin przydatności: "..os.date('%Y-%m-%d %H:%M:%S', expirationDate)
				end
			end

			local currency = fromData.currency or 'money'
			local fromItem = Items(fromData.name)

			local result = fromItem.cb and fromItem.cb('buying', fromItem, playerInv, data.fromSlot, shop)
			if result == false then return false end

			local toItem = toData and Items(toData.name)

			local metadata, count = Items.Metadata(playerInv, fromItem, fromData.metadata and table.clone(fromData.metadata) or {}, data.count)
			local price = count * fromData.price

			if toData == nil or (fromItem.name == toItem?.name and fromItem.stack and table.matches(toData.metadata, metadata)) then
				local newWeight = playerInv.weight + (fromItem.weight + (metadata?.weight or 0)) * count

				if newWeight > playerInv.maxWeight then
					return false, false, { type = 'error', description = locale('cannot_carry') }
				end

				local canAfford = canAffordItem(playerInv, currency, price, shopType)

				if canAfford ~= true then
					return false, false, canAfford
				end

				if not TriggerEventHooks('buyItem', {
					source = source,
					shopType = shopType,
					shopId = shopId,
					toInventory = playerInv.id,
					toSlot = data.toSlot,
					fromSlot = fromData,
					itemName = fromData.name,
					metadata = metadata,
					count = count,
					price = fromData.price,
					totalPrice = price,
					currency = currency,
				}) then return false end

				Inventory.SetSlot(playerInv, fromItem, count, metadata, data.toSlot)
				playerInv.weight = newWeight
				local payBy = removeCurrency(playerInv, currency, price, shopType)
				exports["esx_hud"]:UpdateTaskProgress(source, "Money", price)

				if fromData.count then
					shop.items[data.fromSlot].count = fromData.count - count
				end

				if server.syncInventory then server.syncInventory(playerInv) end

				local message = locale('purchased_for', count, metadata?.label or fromItem.label, (currency == 'money' and locale('$') or math.groupdigits(price)), (currency == 'money' and math.groupdigits(price) or ' '..Items(currency).label), payBy)
				
				local message = message:lower()
				local playerInvLabel = playerInv.label
				local playerInvOwner = playerInv.owner
				local shopLabel = shop.label
				local esx_core = exports.esx_core

				esx_core:SendLog(source, "Sklep", "Zakupił w sklepie\nItem: "..message.."\nEkwipunek: "..playerInvLabel.."\nID: "..playerInvOwner.."\nSklep nazwa: "..shopLabel.."", 'sklep')

				return true, {data.toSlot, playerInv.items[data.toSlot], shop.items[data.fromSlot].count and shop.items[data.fromSlot], playerInv.weight}, { type = 'success', description = message }
			end

			return false, false, { type = 'error', description = locale('unable_stack_items') }
		end
	end
end)

server.shops = Shops