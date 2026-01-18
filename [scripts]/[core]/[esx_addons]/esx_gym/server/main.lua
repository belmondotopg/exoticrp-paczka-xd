local canGym = {}
local skillUpdateCooldown = {}
local SKILL_UPDATE_COOLDOWN = 30000
local MAX_AMOUNT_PER_UPDATE = 5
local ALLOWED_SKILL_TYPES = { stamina = true, strength = true, lung = true }

CreateThread(function()
    MySQL.query.await([[
        ALTER TABLE `users` ADD COLUMN IF NOT EXISTS `streakGym` INT NOT NULL DEFAULT 0;
    ]])
    
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `gym_companies` (
          `id` INT NOT NULL AUTO_INCREMENT,
          `name` VARCHAR(50) NOT NULL,
          `label` VARCHAR(50) DEFAULT NULL,
          `price` INT NOT NULL DEFAULT 100000,
          `owner_name` VARCHAR(50) DEFAULT NULL,
          `owner_identifier` VARCHAR(50) DEFAULT NULL,
          `avaliable` INT NOT NULL DEFAULT 1,
          `active` INT NOT NULL DEFAULT 0,
          `stock` VARCHAR(50) NOT NULL DEFAULT '{}',
          PRIMARY KEY (`id`),
          UNIQUE KEY `uq_gym_companies_name` (`name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `gym_workers` (
          `id` INT NOT NULL AUTO_INCREMENT,
          `gym_name` VARCHAR(50) NOT NULL,
          `worker_name` VARCHAR(50) DEFAULT NULL,
          `worker_identifier` VARCHAR(50) DEFAULT NULL,
          `worker_rank_label` VARCHAR(50) NOT NULL DEFAULT 'Stażysta',
          `worker_rank_grade` INT NOT NULL DEFAULT 0,
          PRIMARY KEY (`id`),
          KEY `idx_gym_workers_gym_name` (`gym_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]])

    MySQL.query.await([[
        ALTER TABLE `gym_workers` MODIFY COLUMN `gym_name` VARCHAR(50) NOT NULL;
    ]])
    
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `gym_passes` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `player_identifier` VARCHAR(50) NOT NULL,
            `gym_name` VARCHAR(50) NOT NULL,
            `pass_type` VARCHAR(50) NOT NULL,
            `expires_at` BIGINT NOT NULL,
            `purchased_at` BIGINT NOT NULL,
            PRIMARY KEY (`id`),
            KEY `idx_gym_passes_player_gym` (`player_identifier`, `gym_name`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]])
    
    MySQL.query.await([[
        ALTER TABLE `gym_companies` ADD COLUMN IF NOT EXISTS `equipment_upgraded` TINYINT(1) NOT NULL DEFAULT 0;
    ]])
    
    MySQL.query.await([[
        ALTER TABLE `gym_companies` ADD COLUMN IF NOT EXISTS `pass_prices` VARCHAR(255) NOT NULL DEFAULT '{"daily":50,"weekly":300,"monthly":1000}' AFTER `equipment_upgraded`;
    ]])

    MySQL.query.await([[
        ALTER TABLE `gym_companies` ADD COLUMN IF NOT EXISTS `supplement_prices` VARCHAR(255) NOT NULL DEFAULT '{"kreatyna":100,"l_karnityna":150,"bialko":200}' AFTER `stock`;
    ]])

    MySQL.query.await([[
        ALTER TABLE `gym_companies` ADD COLUMN IF NOT EXISTS `company_account` INT NOT NULL DEFAULT 0;
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `gym_player_stats` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `player_identifier` VARCHAR(50) NOT NULL,
            `stamina` INT NOT NULL DEFAULT 0,
            `strength` INT NOT NULL DEFAULT 0,
            `lung` INT NOT NULL DEFAULT 0,
            `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `idx_player_identifier` (`player_identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]])
    
    MySQL.query.await([[
        ALTER TABLE `gym_player_stats` 
        ADD COLUMN IF NOT EXISTS `last_stamina_update` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
        ADD COLUMN IF NOT EXISTS `last_strength_update` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
        ADD COLUMN IF NOT EXISTS `last_lung_update` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP;
    ]])
    
    local existingGyms = MySQL.query.await('SELECT COUNT(*) as count FROM `gym_companies`')
    
    if existingGyms and existingGyms[1] and existingGyms[1].count == 0 then
        
        MySQL.insert.await([[
            INSERT INTO `gym_companies` (`name`, `label`, `price`, `avaliable`, `active`, `stock`, `equipment_upgraded`, `pass_prices`, `supplement_prices`, `company_account`) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            'beach_gym',
            'Siłownia plażowa',
            100000,
            1,
            0,
            '{"kreatyna":0,"l_karnityna":0,"bialko":0}',
            0,
            '{"daily":50,"weekly":300,"monthly":1000}',
            '{"kreatyna":100,"l_karnityna":150,"bialko":200}',
            0
        })
        
    end
    
    MySQL.update.await([[
        UPDATE `gym_companies` 
        SET `owner_name` = NULL, `owner_identifier` = NULL 
        WHERE `owner_name` = '' OR `owner_identifier` = '' OR `owner_name` = 'NULL' OR `owner_identifier` = 'NULL'
    ]])
    
end)

ESX.RegisterServerCallback('esx_gym:canGym', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if canGym[xPlayer.identifier] then
            cb(false)
        else
            canGym[xPlayer.identifier] = true
            cb(true)
        end
    end
end)

AddEventHandler('onServerResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        canGym = {}
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	
    if xPlayer then
        local streakGym = tonumber(Player(src).state.streakGym)

        if streakGym then
            MySQL.update('UPDATE users SET streakGym = ? WHERE identifier = ?', {streakGym, xPlayer.identifier})
        end
        
        if skillUpdateCooldown then
            for key, _ in pairs(skillUpdateCooldown) do
                if string.find(key, xPlayer.identifier) == 1 then
                    skillUpdateCooldown[key] = nil
                end
            end
        end
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    if xPlayer then
		MySQL.query('SELECT streakGym FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
			if result[1] then
                local goGym = tonumber(result[1].streakGym)

                if goGym == 20 then
                    Player(playerId).state.streakGym = 0
                else
                    Player(playerId).state.streakGym = tonumber(result[1].streakGym)
                end
			end
		end)
	end
end)

lib.callback.register('esx_gym/getPlayerStats', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { stamina = 0, strength = 0, lung = 0 } end
    
    local result = MySQL.query.await('SELECT stamina, strength, lung FROM `gym_player_stats` WHERE `player_identifier` = ?', { xPlayer.identifier })
    if result[1] then
        return {
            stamina = result[1].stamina or 0,
            strength = result[1].strength or 0,
            lung = result[1].lung or 0
        }
    else
        MySQL.insert.await('INSERT INTO `gym_player_stats` (`player_identifier`, `stamina`, `strength`, `lung`) VALUES (?, 0, 0, 0)', { xPlayer.identifier })
        return { stamina = 0, strength = 0, lung = 0 }
    end
end)

exports("getPlayerStats", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { stamina = 0, strength = 0, lung = 0 } end
    
    local result = MySQL.query.await('SELECT stamina, strength, lung FROM `gym_player_stats` WHERE `player_identifier` = ?', { xPlayer.identifier })
    if result[1] then
        return {
            stamina = result[1].stamina or 0,
            strength = result[1].strength or 0,
            lung = result[1].lung or 0
        }
    else
        MySQL.insert.await('INSERT INTO `gym_player_stats` (`player_identifier`, `stamina`, `strength`, `lung`) VALUES (?, 0, 0, 0)', { xPlayer.identifier })
        return { stamina = 0, strength = 0, lung = 0 }
    end
end)

lib.callback.register('esx_gym/updatePlayerSkill', function(source, skillType, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if not skillType or type(skillType) ~= "string" or not ALLOWED_SKILL_TYPES[skillType] then
        print(string.format("[esx_gym] Podejrzana próba aktualizacji statystyki - gracz %s (ID: %s) próbował użyć nieprawidłowego skillType: %s", 
            xPlayer.identifier, source, tostring(skillType)))
        return false
    end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 or amount > MAX_AMOUNT_PER_UPDATE then
        print(string.format("[esx_gym] Podejrzana próba aktualizacji statystyki - gracz %s (ID: %s) próbował użyć nieprawidłowego amount: %s (skillType: %s)", 
            xPlayer.identifier, source, tostring(amount), skillType))
        return false
    end
    
    local playerKey = xPlayer.identifier .. "_" .. skillType
    local lastUpdate = skillUpdateCooldown[playerKey]
    local currentTime = os.time() * 1000
    
    if lastUpdate and (currentTime - lastUpdate) < SKILL_UPDATE_COOLDOWN then
        local timeLeft = math.ceil((SKILL_UPDATE_COOLDOWN - (currentTime - lastUpdate)) / 1000)
        print(string.format("[esx_gym] Rate limit wykryty - gracz %s (ID: %s) próbował zaktualizować %s zbyt szybko (cooldown: %s sekund)", 
            xPlayer.identifier, source, skillType, timeLeft))
        return false
    end
    
    local currentStats = MySQL.query.await('SELECT * FROM `gym_player_stats` WHERE `player_identifier` = ?', { xPlayer.identifier })
    
    if currentStats[1] then
        local currentValue = currentStats[1][skillType] or 0
        local newValue = math.min(100, math.max(0, currentValue + amount))
        
        if newValue <= currentValue and amount > 0 then
            print(string.format("[esx_gym] Podejrzana próba manipulacji - gracz %s (ID: %s) próbował zaktualizować %s (wartość nie wzrosła)", 
                xPlayer.identifier, source, skillType))
            return false
        end
        
        local updateQuery = string.format('UPDATE `gym_player_stats` SET `%s` = ?, `last_%s_update` = CURRENT_TIMESTAMP WHERE `player_identifier` = ?', 
            skillType, skillType)
        MySQL.update.await(updateQuery, { newValue, xPlayer.identifier })
        
        skillUpdateCooldown[playerKey] = currentTime
        
        return true
    else
        local newValue = math.min(100, math.max(0, amount))
        local insertQuery = string.format('INSERT INTO `gym_player_stats` (`player_identifier`, `%s`, `last_%s_update`) VALUES (?, ?, CURRENT_TIMESTAMP)', 
            skillType, skillType)
        MySQL.insert.await(insertQuery, { xPlayer.identifier, newValue })
        
        skillUpdateCooldown[playerKey] = currentTime
        
        return true
    end
end)

lib.callback.register('esx_gym/getMembershipData', function(source, gymName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    
    local passQuery = MySQL.query.await([[
        SELECT * FROM `gym_passes` 
        WHERE `player_identifier` = ? AND `gym_name` = ? 
        ORDER BY `expires_at` DESC LIMIT 1
    ]], { xPlayer.identifier, gymName })
    
    local hasPass = false
    local isPassValid = false
    local validUntil = 'Brak danych'
    
    if passQuery[1] then
        hasPass = true
        local expiresAt = passQuery[1].expires_at
        local currentTime = os.time() * 1000
        
        if expiresAt > currentTime then
            isPassValid = true
            validUntil = os.date('%d.%m.%Y %H:%M', expiresAt / 1000)
        else
            isPassValid = false
            validUntil = os.date('%d.%m.%Y %H:%M', expiresAt / 1000) .. ' (Wygasła)'
        end
    end
    
    return {
        firstName = xPlayer.variables.firstName or xPlayer.getName():split(' ')[1] or 'Nieznane',
        lastName = xPlayer.variables.lastName or xPlayer.getName():split(' ')[2] or 'Nieznane',
        hasPass = hasPass,
        isPassValid = isPassValid,
        validUntil = validUntil
    }
end)

lib.callback.register('esx_gym/upgradeEquipment', function(source, gymName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        return false, nil 
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] or gymData[1].owner_identifier ~= xPlayer.identifier then
        return false, nil
    end
    
    if gymData[1].equipment_upgraded == 1 or gymData[1].equipment_upgraded == true then
        return false, nil
    end
    
    local upgradePrice = 100000
    
    if xPlayer.getMoney() < upgradePrice then
        return false, nil
    end
    
    xPlayer.removeMoney(upgradePrice)
    MySQL.update.await('UPDATE `gym_companies` SET `equipment_upgraded` = 1 WHERE `name` = ?', { gymName })
    
    local updatedGymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    
    if updatedGymData[1] then
        return true, {
            name = updatedGymData[1].name,
            label = updatedGymData[1].label or updatedGymData[1].name,
            price = updatedGymData[1].price,
            owner_name = updatedGymData[1].owner_name,
            owner_identifier = updatedGymData[1].owner_identifier,
            avaliable = updatedGymData[1].avaliable,
            active = updatedGymData[1].active,
            stock = updatedGymData[1].stock,
            supplement_prices = updatedGymData[1].supplement_prices or '{}',
            isowner = updatedGymData[1].owner_identifier == xPlayer.identifier,
            equipment_upgraded = updatedGymData[1].equipment_upgraded
        }
    end
    
    return false, nil
end)

lib.callback.register('esx_gym/hasValidPass', function(source, gymName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local passQuery = MySQL.query.await([[
        SELECT * FROM `gym_passes` 
        WHERE `player_identifier` = ? AND `gym_name` = ? AND `expires_at` > ?
        ORDER BY `expires_at` DESC LIMIT 1
    ]], { xPlayer.identifier, gymName, os.time() * 1000 })
    
    return passQuery[1] ~= nil
end)

RegisterCommand('setgymowner', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.group ~= 'founder' then xPlayer.showNotification('Nie masz do tego permisji!') return end

    local targetId = tonumber(args[1])
    local gymName = args[2] or 'beach_gym'

    if not targetId then
        if source ~= 0 then xPlayer.showNotification('Użycie: /setgymowner [id] [opcjonalnie: nazwa_silowni]') end
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        if source ~= 0 then xPlayer.showNotification('Gracz nie jest online!') end
        return
    end

    local fullName = targetPlayer.get('firstName') .. ' ' .. targetPlayer.get('lastName')
    
    MySQL.update('UPDATE gym_companies SET owner_identifier = ?, owner_name = ?, avaliable = 0, active = 1 WHERE name = ?', {
        targetPlayer.identifier, fullName, gymName
    }, function(affectedRows)
        if affectedRows > 0 then
             MySQL.query('DELETE FROM gym_workers WHERE gym_name = ? AND worker_identifier = ?', {gymName, targetPlayer.identifier})

             MySQL.insert('INSERT INTO gym_workers (gym_name, worker_name, worker_identifier, worker_rank_label, worker_rank_grade) VALUES (?, ?, ?, ?, ?)', {
                gymName, fullName, targetPlayer.identifier, 'Właściciel', 5
             })

             if source ~= 0 then xPlayer.showNotification('Nadano właściciela siłowni ' .. gymName .. ' graczowi ' .. fullName) end
             targetPlayer.showNotification('Zostałeś właścicielem siłowni ' .. gymName)
        else
            if source ~= 0 then xPlayer.showNotification('Nie znaleziono siłowni o nazwie ' .. gymName) end
        end
    end)
end, false)

local function checkAndDecayStats(playerId, identifier)
    if not Config.StatsDecay or not Config.StatsDecay.enabled then return end
    
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    local inactivityTime = Config.StatsDecay.inactivityTime / 1000
    local decayInterval = Config.StatsDecay.decayInterval / 1000
    local decayAmount = Config.StatsDecay.decayAmount
    local minStats = Config.StatsDecay.minStats or 0
    
    local statTypes = {'stamina', 'strength', 'lung'}
    
    for _, statType in ipairs(statTypes) do
        local result = MySQL.query.await([[
            SELECT 
                `]] .. statType .. [[`,
                TIMESTAMPDIFF(SECOND, `last_]] .. statType .. [[_update`, NOW()) as seconds_since_update
            FROM `gym_player_stats` 
            WHERE `player_identifier` = ?
        ]], { identifier })
        
        if result and result[1] then
            local currentValue = result[1][statType] or 0
            local timeSinceUpdate = result[1].seconds_since_update or 0
            
            if currentValue > minStats and timeSinceUpdate >= inactivityTime then
                local decayPeriods = math.floor((timeSinceUpdate - inactivityTime) / decayInterval)
                
                if decayPeriods > 0 then
                    local totalDecay = decayAmount * decayPeriods
                    local newValue = math.max(minStats, currentValue - totalDecay)
                    
                    if newValue < currentValue then
                        MySQL.update.await('UPDATE `gym_player_stats` SET `' .. statType .. '` = ? WHERE `player_identifier` = ?', { newValue, identifier })
                        
                        if Config.StatsDecay.notification then
                            local statNames = {
                                stamina = 'kondycja',
                                strength = 'siła',
                                lung = 'płuca'
                            }
                            xPlayer.showNotification('Twoja ' .. (statNames[statType] or statType) .. ' spadła o ' .. (currentValue - newValue) .. ' z powodu braku treningu!')
                        end
                    end
                end
            end
        end
    end
end

CreateThread(function()
    while true do
        Wait(Config.StatsDecay and Config.StatsDecay.checkInterval or 3600000)
        
        if Config.StatsDecay and Config.StatsDecay.enabled then
            local players = GetPlayers()
            
            for _, playerId in ipairs(players) do
                local xPlayer = ESX.GetPlayerFromId(tonumber(playerId))
                if xPlayer then
                    checkAndDecayStats(tonumber(playerId), xPlayer.identifier)
                end
            end
        end
    end
end)