local mapping = Config.SQLTables[Config.Framework]

if not mapping then return end

local playerTable = mapping.playerTable
local playerColumn = mapping.playerColumn
local vehicleTable = mapping.vehicleTable
local vehicleColumn = mapping.vehicleColumn

function GetPlayerSettings(identifier, key)
    return GetSettings(playerTable, playerColumn, identifier, key)
end

function SavePlayerSettings(identifier, key, value)
    return SaveSettings(playerTable, playerColumn, identifier, key, value)
end

function GetSettings(table, idKey, idValue, key)
    EnsureSettingsTable(table, idKey)
    local result = MySQL.scalar.await(
        ('SELECT JSON_UNQUOTE(JSON_EXTRACT(settings, ?)) FROM %s WHERE %s = ?'):format(table, idKey),
        { '$.' .. key, idValue }
    )

    if result then
        return json.decode(result)
    end
end

function SaveSettings(table, idKey, idValue, key, value)
    EnsureSettingsTable(table, idKey)
    local encoded = type(value) == 'string' and value or json.encode(value)
    MySQL.update(
        ('UPDATE %s SET settings = JSON_SET(COALESCE(settings, JSON_OBJECT()), ?, ?) WHERE %s = ?'):format(table, idKey),
        { '$.' .. key, encoded, idValue }
    )
end

function GetAllSettings(table, idKey, idValue)
    EnsureSettingsTable(table, idKey)
    local result = MySQL.scalar.await(
        ('SELECT settings FROM %s WHERE %s = ?'):format(table, idKey),
        { idValue }
    )

    if result then
        return json.decode(result)
    end
end

function EnsureSettingsRow(tableName, keyField, keyValue)
    EnsureSettingsTable(tableName, keyField)

    MySQL.update.await(
        ('INSERT INTO %s (%s, settings) SELECT ?, JSON_OBJECT() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM %s WHERE %s = ?)')
        :format(tableName, keyField, tableName, keyField),
        { keyValue, keyValue }
    )
end

function EnsureSettingsTable(tableName, keyField)
    if not tableName or not keyField then
        error('EnsureSettingsTable requires both tableName and keyField arguments.')
    end

    -- CHECK TABLE EXISTS
    local tableExists = MySQL.scalar.await([[
        SELECT COUNT(*)
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = ?
    ]], { tableName })

    -- CREATE IF NOT EXISTS
    if tableExists == 0 then
        print('[lc-settings] Creating settings table: ' .. tableName)

        MySQL.query.await(([[
            CREATE TABLE %s (
                id INT AUTO_INCREMENT PRIMARY KEY,
                %s VARCHAR(100) NOT NULL UNIQUE,
                settings JSON DEFAULT NULL
            )
        ]]):format(tableName, keyField))

        print('[lc-settings] Table created successfully: ' .. tableName)
    else
        -- IF EXISTS ENSURE KEY FIELD AND SETTINGS EXISTS
        local columns = MySQL.query.await([[
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?
        ]], { tableName })

        local hasKey = false
        local hasSettings = false

        for _, col in ipairs(columns) do
            if col.COLUMN_NAME == keyField then hasKey = true end
            if col.COLUMN_NAME == 'settings' then hasSettings = true end
        end

        if not hasKey then
            print('[lc-settings] Adding key column `' .. keyField .. '` to `' .. tableName .. '`')
            MySQL.query.await(('ALTER TABLE %s ADD COLUMN %s VARCHAR(100) NOT NULL UNIQUE'):format(tableName, keyField))
        end

        if not hasSettings then
            print('[lc-settings] Adding `settings` JSON column to `' .. tableName .. '`')
            MySQL.query.await(('ALTER TABLE %s ADD COLUMN settings LONGTEXT DEFAULT NULL'):format(tableName))
        end
    end
end

exports('GetSettings', GetSettings)
exports('SaveSettings', SaveSettings)
exports('GetPlayerSettings', GetPlayerSettings)
exports('SavePlayerSettings', SavePlayerSettings)
exports('GetAllSettings', GetAllSettings)
exports('EnsureSettingsTable', EnsureSettingsTable)
exports('EnsureSettingsRow', EnsureSettingsRow)
