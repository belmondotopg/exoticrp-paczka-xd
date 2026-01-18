local INV = {}

local Utils = require('server/functions/utils')

local ox_inv = exports.ox_inventory
local ESX = exports.es_extended:getSharedObject()

local MIN_CUSTOM_NUMBER_LENGTH = 3

local function createSimCardMetadata(number)
    local formatted = exports['lb-phone']:FormatNumber(number)
    return {
        lbPhoneNumber = number,
        lbFormattedNumber = formatted,
        description = 'Numer: ' .. formatted
    }
end

local function validateCustomNumber(customNumber)
    if not customNumber:match('^%d+$') then
        return false, "Numer może zawierać tylko cyfry!"
    end

    if #customNumber < MIN_CUSTOM_NUMBER_LENGTH then
        return false, ("Numer musi mieć minimum %d znaki!"):format(MIN_CUSTOM_NUMBER_LENGTH)
    end

    local existingNumber = MySQL.single.await(
        'SELECT `id` FROM `phone_phones` WHERE `phone_number` = ?',
        { customNumber }
    )

    if existingNumber then
        return false, ("Numer %s jest już używany!"):format(customNumber)
    end

    return true, customNumber
end

function INV.RegisterItemCB(cb)
    exports('simcard', function(event, item, inventory, slot)
        if event == 'usingItem' then
            local metadata = inventory.items[slot] and inventory.items[slot].metadata
            local phoneNumber = metadata and metadata.lbPhoneNumber or nil
            cb(inventory.id, phoneNumber, slot)
        end
    end)
end

function INV.UpdateSimCardNumber(source, slot, number)
    local formatted = exports['lb-phone']:FormatNumber(number)
    local metadata = {
        lbPhoneNumber = number,
        lbFormattedNumber = formatted,
        description = 'Numer: ' .. formatted
    }
    ox_inv:SetMetadata(source, slot, metadata)
end

function INV.RemoveItem(source, slot)
    ox_inv:RemoveItem(source, Config.SimCard.ItemName, 1, false, slot)
end

function INV.HasSimCardWithNumber(source, phoneNumber)
    local items = ox_inv:GetInventory(source)
    if not items or not items.items then
        return false
    end

    for _, item in pairs(items.items) do
        if item.name == Config.SimCard.ItemName and item.metadata and item.metadata.lbPhoneNumber == phoneNumber then
            return true
        end
    end

    return false
end

local function hasFounderRank(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end
    
    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
    return group == 'founder' or group == 'developer' or group == 'management'
end

RegisterCommand('givesim', function(source, args)
    if not hasFounderRank(source) then
        TriggerClientEvent('esx:showNotification', source, 'Nie masz uprawnień do użycia tej komendy!')
        return
    end

    local number = nil
    
    if args[1] and args[1] ~= '' then
        local isValid, result = validateCustomNumber(args[1])
        if not isValid then
            TriggerClientEvent('vwk/phone/notify', source, T('SERVER.NOTIFICATIONS.ERROR.TITLE'), result, "Settings")
            return
        end
        number = result
    end

    if not number then
        number = Utils.GenerateNewNumber()
        if not number then
            lib.print.error('Nie udało się wygenerować nowego numeru dla source:', source)
            TriggerClientEvent('vwk/phone/notify', source, T('SERVER.NOTIFICATIONS.ERROR.TITLE'), T('SERVER.NOTIFICATIONS.ERROR.GENERATE_NUMBER_FAILED'), "Settings")
            return
        end
    end

    local metadata = createSimCardMetadata(number)

    if Config.Debug then
        lib.print.info(T('SERVER.DEBUG.GIVESIM'), json.encode(metadata))
    end

    exports.ox_inventory:AddItem(source, Config.SimCard.ItemName, 1, metadata)
    TriggerClientEvent('vwk/phone/notify', source, T('SERVER.NOTIFICATIONS.SUCCESS.TITLE'), ("Dodano kartę SIM z numerem: %s"):format(metadata.lbFormattedNumber), "Settings")
end)

return INV
