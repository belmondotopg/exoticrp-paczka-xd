local function createTables()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `car_market` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `owner` varchar(50) NOT NULL,
            `identifier` varchar(50) NOT NULL,
            `plate` varchar(20) NOT NULL,
            `model` varchar(50) NOT NULL,
            `vehicle` longtext NOT NULL,
            `price` int(11) NOT NULL,
            `inserted_at` int(11) NOT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `plate` (`plate`),
            KEY `identifier` (`identifier`),
            KEY `inserted_at` (`inserted_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]], {}, function(result)
    end)
    
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = DATABASE() AND table_name = "owned_vehicles"', {}, function(exists)
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    MySQL.ready(function()
        createTables()
    end)
end)


