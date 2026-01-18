local Utils = require('server/functions/utils')

local ESX = exports.es_extended:getSharedObject()
local Inventory = Utils.GetInventory('auto')

if not ESX then
    return lib.print.error('Unable to load ESX framework, this script will not work!')
end

local CONSTANTS = {
    MAX_SIM_CARDS = 5,
    SIM_CARD_PRICE = 250,
    PHONE_PRICE = 2000,
    PRIVATE_SIM_PRICE = 100,
    CLONE_PRICE = 250,
    DEACTIVATE_PRICE = 100,
}

local simCardRemovalStates = {}

local function getPlayerIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end
    return xPlayer.getIdentifier()
end

local function updatePhoneLastPhone(identifier, newNumber)
    MySQL.insert.await(
        'INSERT INTO phone_last_phone (id, phone_number) VALUES (?, ?) ' ..
        'ON DUPLICATE KEY UPDATE phone_number = VALUES(phone_number)',
        { identifier, newNumber }
    )
end

local function updatePhoneNumberStatus(identifier, newNumber)
    MySQL.update.await('UPDATE phone_numbers SET isUsed = 0 WHERE owner = ?', { identifier })

    local numberExists = MySQL.single.await(
        'SELECT number FROM phone_numbers WHERE number = ?',
        { newNumber }
    )

    if numberExists then
        MySQL.update.await(
            'UPDATE phone_numbers SET owner = ?, isUsed = 1 WHERE number = ?',
            { identifier, newNumber }
        )
    else
        MySQL.insert.await(
            'INSERT INTO phone_numbers (owner, isUsed, number) VALUES (?, 1, ?)',
            { identifier, newNumber }
        )
    end
end

local function updateOrCreatePhone(identifier, newNumber)
    local existingPhone = MySQL.single.await(
        'SELECT id, phone_number FROM phone_phones WHERE owner_id = ?',
        { identifier }
    )

    if existingPhone then
        if existingPhone.phone_number == newNumber then
            return true
        end
        
        MySQL.query.await(
            'DELETE FROM phone_phones WHERE phone_number = ? AND owner_id != ?',
            { newNumber, identifier }
        )
        
        local rows = MySQL.update.await(
            'UPDATE phone_phones SET phone_number = ? WHERE owner_id = ?',
            { newNumber, identifier }
        )
        return rows ~= nil and rows > 0
    else
        MySQL.query.await(
            'DELETE FROM phone_phones WHERE phone_number = ?',
            { newNumber }
        )
        
        local insertId = MySQL.insert.await([[
            INSERT INTO phone_phones (id, owner_id, phone_number)
            VALUES (?, ?, ?)
        ]], {
            identifier,
            identifier,
            newNumber
        })
        
        if insertId then
            local verifyRecord = MySQL.single.await(
                'SELECT id FROM phone_phones WHERE owner_id = ? AND phone_number = ?',
                { identifier, newNumber }
            )
            return verifyRecord ~= nil
        end
        
        return false
    end
end

local function handleSimCardRemoval(source, number)
    if not simCardRemovalStates[number] then
        simCardRemovalStates[number] = false
    end

    if not simCardRemovalStates[number] then
        TriggerClientEvent('vwk/phone/notify', source, "KARTA SIM", "Wyjęto kartę sim z telefonu!", "Settings")
        simCardRemovalStates[number] = true
        TriggerClientEvent('vwk/phone/removeSim', source, number)
        return true
    else
        simCardRemovalStates[number] = false
        return false
    end
end

lib.callback.register("lbphonesim:hasActiveSim", function(source)
    local identifier = getPlayerIdentifier(source)
    if not identifier then
        return nil
    end

    local existingPhone = MySQL.single.await(
        'SELECT number FROM phone_numbers WHERE owner = ? AND isUsed = 1',
        { identifier }
    )

    return existingPhone and existingPhone.number or nil
end)

local function checkAndRegisterSimCardsInInventory(source)
    local inventory = exports.ox_inventory:GetInventory(source)
    if not inventory or not inventory.items then
        return
    end
    
    for slot, item in pairs(inventory.items) do
        if item and item.name == Config.SimCard.ItemName then
            if not item.metadata or not item.metadata.lbPhoneNumber then
                registerSimCardWithoutMetadata(source, slot)
            end
        end
    end
end

if Inventory.RegisterItemCB then
    Inventory.RegisterItemCB(function(source, newNumber, slot)
        local identifier = getPlayerIdentifier(source)

        if not identifier then
            TriggerClientEvent('vwk/phone/notify', source, T('SERVER.NOTIFICATIONS.ERROR.TITLE'), T('SERVER.NOTIFICATIONS.ERROR.MISSING_IDENTIFIER'), "Settings")
            return
        end

        local currentNumber = exports['lb-phone']:GetEquippedPhoneNumber(source)

        if not newNumber then
            local result = MySQL.query.await([[
                SELECT COUNT(*) AS count 
                FROM phone_numbers 
                WHERE owner = ? 
                AND (isPrivate = 0 OR isPrivate IS NULL)
                AND (isBlocked = 0 OR isBlocked IS NULL)
            ]], { identifier })
            
            local simCount = result and result[1] and result[1].count or 0
            
            if simCount >= CONSTANTS.MAX_SIM_CARDS then
                TriggerClientEvent('vwk/phone/notify', source, T('SERVER.NOTIFICATIONS.ERROR.TITLE'), ('Nie możesz posiadać więcej niż %d kart SIM!'):format(CONSTANTS.MAX_SIM_CARDS), "Settings")
                return
            end
            
            newNumber = Utils.GenerateNewNumber()
            if not newNumber then
                TriggerClientEvent('vwk/phone/notify', source, T('SERVER.NOTIFICATIONS.ERROR.TITLE'), T('SERVER.NOTIFICATIONS.ERROR.GENERATE_NUMBER_FAILED'), "Settings")
                return
            end
            
            MySQL.insert.await(
                'INSERT INTO phone_numbers (owner, isUsed, number, isPrivate) VALUES (?, 0, ?, 0)',
                { identifier, newNumber }
            )
            
            Inventory.UpdateSimCardNumber(source, slot, newNumber)
        end

        if currentNumber == newNumber then
            if handleSimCardRemoval(source, newNumber) then
                return
            end
        end

        if Config.SimCard.ReplaceSimCardNumber then
            Inventory.UpdateSimCardNumber(source, slot, currentNumber)
        end

        local success = updateOrCreatePhone(identifier, newNumber)
        if not success then
            return
        end

        updatePhoneNumberStatus(identifier, newNumber)

        local phoneRecord = MySQL.single.await(
            'SELECT phone_number FROM phone_phones WHERE owner_id = ? AND phone_number = ?',
            { identifier, newNumber }
        )

        if not phoneRecord then
            local retrySuccess = updateOrCreatePhone(identifier, newNumber)
            if not retrySuccess then
                return
            end
        end

        updatePhoneLastPhone(identifier, newNumber)

        lib.callback('lbphonesim:changingsimcard', source, function(response)
            if response == true then
                TriggerClientEvent('vwk/phone/update', source, newNumber)
                
                if Config.SimCard.DeleteSimCard then
                    Inventory.RemoveItem(source, slot)
                end
            end
        end, newNumber)
    end)
end

RegisterNetEvent('vwk/phone/buy', function(what)
    local src = source
    local identifier = getPlayerIdentifier(src)

    if not identifier then
        TriggerClientEvent('esx:showNotification', src, 'Błąd: nie udało się pobrać identyfikatora gracza.')
        return
    end

    if what == "simka" then
        local result = MySQL.query.await([[
            SELECT COUNT(*) AS count 
            FROM phone_numbers 
            WHERE owner = ? 
            AND (isPrivate = 0 OR isPrivate IS NULL)
            AND (isBlocked = 0 OR isBlocked IS NULL)
        ]], { identifier })

        local simCount = result and result[1] and result[1].count or 0

        if simCount >= CONSTANTS.MAX_SIM_CARDS then
            TriggerClientEvent('esx:showNotification', src, ('Nie możesz posiadać więcej niż %d kart SIM!'):format(CONSTANTS.MAX_SIM_CARDS))
            return
        end

        local pay = exports.ox_inventory:RemoveItem(src, 'money', CONSTANTS.SIM_CARD_PRICE)
        if not pay then
            TriggerClientEvent('esx:showNotification', src, ('Nie posiadasz %d$ na kartę SIM'):format(CONSTANTS.SIM_CARD_PRICE))
            return
        end

        local number = Utils.GenerateNewNumber()
        if not number then
            TriggerClientEvent('esx:showNotification', src, 'Nie udało się wygenerować numeru.')
            return
        end

        local formatted = exports['lb-phone']:FormatNumber(number)
        local metadata = {
            lbPhoneNumber = number,
            lbFormattedNumber = formatted,
            description = 'Numer: ' .. formatted
        }

        MySQL.insert.await(
            'INSERT INTO phone_numbers (owner, isUsed, number, isPrivate) VALUES (?, 0, ?, 0)',
            { identifier, number }
        )

        exports.ox_inventory:AddItem(src, "simcard", 1, metadata)
        TriggerClientEvent('vwk/phone/notify', src, 'Operator Exotic5G', ("Dziękujemy za zakup karty SIM: %s aby ją aktywować włóż ją do telefonu!"):format(formatted), "Settings")

    elseif what == "fonik" then
        local pay = exports.ox_inventory:RemoveItem(src, 'money', CONSTANTS.PHONE_PRICE)
        if not pay then
            TriggerClientEvent('esx:showNotification', src, ('Nie posiadasz %d$ na telefon'):format(CONSTANTS.PHONE_PRICE))
            return
        end

        exports.ox_inventory:AddItem(src, 'phone', 1)
        TriggerClientEvent('esx:showNotification', src, ('Zakupiłeś telefon za %d$'):format(CONSTANTS.PHONE_PRICE))

    elseif what == "opsec" then
        local pay = exports.ox_inventory:RemoveItem(src, 'money', CONSTANTS.PRIVATE_SIM_PRICE)
        if not pay then
            TriggerClientEvent('esx:showNotification', src, 'Nie posiadasz 100$ na kartę SIM NIEZAREJESTROWANĄ')
            return
        end

        local number = Utils.GenerateNewNumber()
        if not number then
            TriggerClientEvent('esx:showNotification', src, 'Nie udało się wygenerować numeru.')
            return
        end

        local formatted = exports['lb-phone']:FormatNumber(number)
        local metadata = {
            lbPhoneNumber = number,
            lbFormattedNumber = formatted,
            description = 'Numer: ' .. formatted .. " [NIEZAREJSTROWANY]"
        }

        MySQL.insert.await(
            'INSERT INTO phone_numbers (owner, isUsed, number, isPrivate) VALUES (?, 0, ?, 1)',
            { identifier, number }
        )

        exports.ox_inventory:AddItem(src, Config.SimCard.ItemName, 1, metadata)
        TriggerClientEvent('esx:showNotification', src, ('Zakupiłeś niezarejestrowaną kartę SIM: %s'):format(formatted))
    else
        TriggerClientEvent('esx:showNotification', src, 'daj spokuj.')
    end
end)

local function registerSimCardWithoutMetadata(source, slot)
    local identifier = getPlayerIdentifier(source)
    if not identifier then
        return false
    end
    
    local result = MySQL.query.await([[
        SELECT COUNT(*) AS count 
        FROM phone_numbers 
        WHERE owner = ? 
        AND (isPrivate = 0 OR isPrivate IS NULL)
        AND (isBlocked = 0 OR isBlocked IS NULL)
    ]], { identifier })
    
    local simCount = result and result[1] and result[1].count or 0
    
    if simCount >= CONSTANTS.MAX_SIM_CARDS then
        return false
    end
    
    local number = Utils.GenerateNewNumber()
    if not number then
        return false
    end
    
    local formatted = exports['lb-phone']:FormatNumber(number)
    local metadata = {
        lbPhoneNumber = number,
        lbFormattedNumber = formatted,
        description = 'Numer: ' .. formatted
    }
    
    MySQL.insert.await(
        'INSERT INTO phone_numbers (owner, isUsed, number, isPrivate) VALUES (?, 0, ?, 0)',
        { identifier, number }
    )
    
    if slot then
        exports.ox_inventory:SetMetadata(source, slot, metadata)
    end
    
    return true
end

exports.ox_inventory:registerHook('swapItems', function(payload)
    if not payload or not payload.source then
        return
    end

    if payload.fromType == 'player' and payload.fromInventory ~= payload.source then
        local targetSrc = payload.fromInventory
        if type(targetSrc) == 'number' then
            local targetState = Player(targetSrc).state
            if targetState and targetState.IsHandcuffed then
                local item = payload.fromSlot
                if item.name == Config.SimCard.ItemName then
                    TriggerClientEvent('esx:showNotification', payload.source, 'Nie możesz zabrać karty SIM, gdy osoba jest zakuta!')
                    return false
                end
            end
        end
    end
    
    if payload.toType == 'player' and payload.source and payload.toSlot then
        local slot = type(payload.toSlot) == 'number' and payload.toSlot or payload.toSlot.slot
        if slot then
            local inventory = exports.ox_inventory:GetInventory(payload.source)
            local toItem = inventory and inventory.items and inventory.items[slot]
            if toItem and toItem.name == Config.SimCard.ItemName then
                if not toItem.metadata or not toItem.metadata.lbPhoneNumber then
                    CreateThread(function()
                        Wait(100)
                        registerSimCardWithoutMetadata(payload.source, slot)
                    end)
                end
            end
        end
    end
    
    if payload.action ~= 'move' and payload.action ~= 'remove' then
        return
    end
    if payload.fromType ~= 'player' then
        return
    end

    local playerId = payload.source
    if payload.fromInventory == payload.toInventory then
        return
    end

    local item = payload.fromSlot
    
    if item.name == "simcard" and item.metadata and item.metadata.lbPhoneNumber then
        simCardRemovalStates[item.metadata.lbPhoneNumber] = true
        TriggerClientEvent('vwk/phone/removeSim', playerId, item.metadata.lbPhoneNumber)
        return
    end
    
    if item.name == "phone" then
        local identifier = getPlayerIdentifier(playerId)
        if not identifier then
            return
        end
        
        local phoneNumber = nil
        if item.metadata and item.metadata.lbPhoneNumber then
            phoneNumber = item.metadata.lbPhoneNumber
        else
            phoneNumber = exports['lb-phone']:GetEquippedPhoneNumber(playerId)
        end
        
        if phoneNumber then
            MySQL.update.await(
                'UPDATE phone_numbers SET isUsed = 0 WHERE owner = ? AND number = ?',
                { identifier, phoneNumber }
            )
            
            simCardRemovalStates[phoneNumber] = true
            TriggerClientEvent('vwk/phone/removeSim', playerId, phoneNumber)
        end
    end
end)

ESX.RegisterServerCallback('vwk/phone/getPublicNumbers', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({})
        return
    end

    local identifier = xPlayer.getIdentifier()
    MySQL.query(
        'SELECT owner, number, isPrivate, isBlocked FROM phone_numbers WHERE owner = ? AND (isPrivate = 0 OR isPrivate IS NULL) AND (isBlocked = 0 OR isBlocked IS NULL)',
        { identifier },
        function(result)
            cb(result and #result > 0 and result or {})
        end
    )
end)

RegisterNetEvent('vwk/phone/clone', function(simData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    local identifier = xPlayer.getIdentifier()
    if not simData or not simData.number then
        TriggerClientEvent('esx:showNotification', src, 'Nieprawidłowe dane karty SIM.')
        return
    end

    MySQL.query('SELECT * FROM phone_numbers WHERE number = ? AND owner = ?', { simData.number, identifier }, function(result)
        if not result or #result == 0 then
            TriggerClientEvent('esx:showNotification', src, 'Ta karta SIM nie należy do Ciebie!')
            return
        end

        local simInfo = result[1]
        if simInfo.isPrivate == 1 then
            TriggerClientEvent('esx:showNotification', src, 'Nie możesz sklonować prywatnej karty SIM!')
            return
        end

        local pay = exports.ox_inventory:RemoveItem(src, 'money', CONSTANTS.CLONE_PRICE)
        if not pay then
            TriggerClientEvent('esx:showNotification', src, ('Nie posiadasz %d$ na klonowanie karty SIM.'):format(CONSTANTS.CLONE_PRICE))
            return
        end

        local formatted = exports['lb-phone']:FormatNumber(simInfo.number)
        local metadata = {
            lbPhoneNumber = simInfo.number,
            lbFormattedNumber = formatted,
            description = 'Numer: ' .. formatted
        }

        exports.ox_inventory:AddItem(src, Config.SimCard.ItemName, 1, metadata)
        TriggerClientEvent('vwk/phone/notify', src, 'Operator Exotic5G', ('Sklonowano kartę SIM: %s'):format(formatted), "Settings")
    end)
end)

RegisterNetEvent('vwk/phone/delete', function(simData)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return
    end

    local identifier = xPlayer.getIdentifier()
    if not simData or not simData.number then
        TriggerClientEvent('esx:showNotification', src, 'Nieprawidłowe dane karty SIM.')
        return
    end

    MySQL.query('SELECT * FROM phone_numbers WHERE number = ? AND owner = ?', { simData.number, identifier }, function(result)
        if not result or #result == 0 then
            TriggerClientEvent('esx:showNotification', src, 'Ta karta SIM nie należy do Ciebie!')
            return
        end

        local simInfo = result[1]
        if simInfo.isPrivate == 1 then
            TriggerClientEvent('esx:showNotification', src, 'Nie możesz usunąć prywatnej karty SIM!')
            return
        end
        if simInfo.isBlocked == 1 then
            TriggerClientEvent('esx:showNotification', src, 'Ta karta SIM jest już zablokowana.')
            return
        end

        local pay = exports.ox_inventory:RemoveItem(src, 'money', CONSTANTS.DEACTIVATE_PRICE)
        if not pay then
            TriggerClientEvent('esx:showNotification', src, ('Nie posiadasz %d$ na dezaktywację karty SIM.'):format(CONSTANTS.DEACTIVATE_PRICE))
            return
        end

        MySQL.update('UPDATE phone_numbers SET isBlocked = 1 WHERE number = ? AND owner = ?', { simData.number, identifier }, function(affectedRows)
            if affectedRows and affectedRows > 0 then
                local formatted = exports['lb-phone']:FormatNumber(simInfo.number)
                TriggerClientEvent('vwk/phone/notify', src, 'Operator Exotic5G', ('Karta SIM %s została dezaktywowana.'):format(formatted), "Settings")
                exports.ox_inventory:RemoveItem(src, Config.SimCard.ItemName, 1, { lbPhoneNumber = tostring(simInfo.number) })
                simCardRemovalStates[simInfo.number] = true
                TriggerClientEvent('vwk/phone/removeSim', src, simInfo.number)
            else
                TriggerClientEvent('esx:showNotification', src, 'Wystąpił błąd przy dezaktywacji karty SIM.')
            end
        end)
    end)
end)

ESX.RegisterServerCallback('vwk/phone/isSimDeactivated', function(source, cb, number)
    if not number then
        cb(false, 'Brak numeru.')
        return
    end

    MySQL.query('SELECT isBlocked FROM phone_numbers WHERE number = ?', { number }, function(result)
        if not result or #result == 0 then
            cb(false)
            return
        end

        local sim = result[1]
        cb(tonumber(sim.isBlocked) == 1)
    end)
end)
