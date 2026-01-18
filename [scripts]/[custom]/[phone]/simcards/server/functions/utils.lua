local Utils = {}

-- Constants
local DEFAULT_SERIAL_LENGTH = 6
local CHARSET = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'

-- Helper Functions
local function generateRandomDigits(length)
    local digits = {}
    for i = 1, length do
        digits[i] = tostring(math.random(0, 9))
    end
    return table.concat(digits)
end

-- Public Functions
function Utils.GenerateNewNumber()
    local NumberConfig = exports["lb-phone"]:GetConfig().PhoneNumber
    local validNumber = false
    local attempts = 0
    local maxAttempts = 100 -- Prevent infinite loop

    while not validNumber and attempts < maxAttempts do
        attempts = attempts + 1
        local number = generateRandomDigits(NumberConfig.Length)
        local prefix = NumberConfig.Prefixes[math.random(1, #NumberConfig.Prefixes)]
        local fullNumber = prefix .. number

        local existing = MySQL.single.await(
            'SELECT `id` FROM `phone_phones` WHERE `phone_number` = ?',
            { fullNumber }
        )

        if not existing then
            validNumber = fullNumber
        end
    end

    if not validNumber then
        lib.print.error('Failed to generate phone number after', maxAttempts, 'attempts')
        return nil
    end

    return validNumber
end

function Utils.GenerateSerialNumber(length)
    length = type(length) == 'number' and length > 0 and length or DEFAULT_SERIAL_LENGTH

    local chars = {}
    for i = 1, length do
        local randomIndex = math.random(1, #CHARSET)
        chars[i] = CHARSET:sub(randomIndex, randomIndex)
    end

    return table.concat(chars)
end

-- Framework Detection (Simplified for ESX only)
function Utils.GetFramework(rawEntry)
    -- Since user only uses ESX, always return ESX framework
    local status, obj = pcall(function()
        return require('server/frameworks/esx')
    end)

    if not status then
        lib.print.error('Unable to load ESX framework. Make sure ESX is installed and running.')
        return false
    end

    return obj
end

-- Inventory Detection
local inventories = {
    'ox_inventory'
}

local function IsInventoryCompatible(invName)
    local status, obj = pcall(function()
        return require(('server/inventories/%s'):format(invName))
    end)

    return status, obj
end

function Utils.GetInventory(rawEntry)
    if rawEntry ~= 'auto' then
        local status, obj = IsInventoryCompatible(rawEntry)

        if not status then
            lib.print.error(('The configured inventory (%s) is not supported by this script, please add it.'):format(rawEntry))
            return false
        end

        return obj
    end

    -- Auto-detect inventory
    for _, inv in ipairs(inventories) do
        local status, obj = IsInventoryCompatible(inv)
        if status then
            return obj
        end
    end

    lib.print.warn('No compatible inventory system found. Using default behavior.')
    return false
end

return Utils
