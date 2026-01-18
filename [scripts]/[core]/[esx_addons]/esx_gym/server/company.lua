lib.callback.register('esx_gym/company/getGymAccess', function(source, gymName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    
    local gymResult = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymResult[1] then return nil end
    
    local gymData = gymResult[1]
    
    if gymData.equipment_upgraded == nil then
        gymData.equipment_upgraded = 0
    elseif gymData.equipment_upgraded == true then
        gymData.equipment_upgraded = 1
    elseif gymData.equipment_upgraded == false then
        gymData.equipment_upgraded = 0
    end
    
    local isOwned = gymData.owner_name and gymData.owner_name ~= '' and gymData.owner_identifier and gymData.owner_identifier ~= ''
    
    local isOwner = isOwned and gymData.owner_identifier == xPlayer.identifier
    
    local workerData = nil
    local accessLevel = 'none'
    local hasAccess = false
    
    if isOwner then
        accessLevel = 'owner'
        hasAccess = true
    else
        local workerResult = MySQL.query.await('SELECT * FROM `gym_workers` WHERE `gym_name` = ? AND `worker_identifier` = ?', { gymName, xPlayer.identifier })
        if workerResult[1] then
            workerData = workerResult[1]
            hasAccess = true
            local grade = workerData.worker_rank_grade
            
            if grade == 5 then
                accessLevel = 'owner'
            elseif grade == 4 then
                accessLevel = 'manager'
            elseif grade == 3 then
                accessLevel = 'deputy'
            elseif grade == 2 then
                accessLevel = 'supervisor'
            elseif grade == 1 then
                accessLevel = 'worker'
            elseif grade == 0 then
                accessLevel = 'trainee'
            end
        end
    end
    
    return {
        gymData = gymData,
        isOwned = isOwned,
        isowner = isOwner,
        hasAccess = hasAccess,
        accessLevel = accessLevel,
        workerData = workerData
    }
end)

lib.callback.register('esx_gym/company/getData', function(source, name)
    local result = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { name })
    if result[1] then
        if result[1].equipment_upgraded == nil then
            result[1].equipment_upgraded = 0
        elseif result[1].equipment_upgraded == true then
            result[1].equipment_upgraded = 1
        elseif result[1].equipment_upgraded == false then
            result[1].equipment_upgraded = 0
        end
    end
    return result[1]
end)

local function checkGymPermission(source, gymName, requiredLevel)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, nil end
    
    local gymResult = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymResult[1] then return false, nil end
    
    local gymData = gymResult[1]
    
    if gymData.owner_identifier and gymData.owner_identifier ~= '' and gymData.owner_identifier == xPlayer.identifier then
        return true, 5
    end
    
    local workerResult = MySQL.query.await('SELECT * FROM `gym_workers` WHERE `gym_name` = ? AND `worker_identifier` = ?', { gymName, xPlayer.identifier })
    if workerResult[1] then
        local grade = workerResult[1].worker_rank_grade
        if grade >= requiredLevel then
            return true, grade
        end
    end
    
    return false, nil
end


RegisterServerEvent('esx_gym/purchaseGym', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    
    if not gymName or type(gymName) ~= "string" then
        print(string.format("[esx_gym] Podejrzana próba zakupu siłowni - gracz %s (ID: %s) próbował użyć nieprawidłowego gymName", 
            xPlayer.identifier, src))
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ? AND `avaliable` = 1', { gymName })
    
    if not gymData[1] then
        xPlayer.showNotification('Ta siłownia nie jest już dostępna!')
        return
    end
    
    local gym = gymData[1]
    
    local recheckGymData = MySQL.query.await('SELECT `avaliable` FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not recheckGymData[1] or recheckGymData[1].avaliable ~= 1 then
        xPlayer.showNotification('Ta siłownia nie jest już dostępna!')
        return
    end
    
    local gymPrice = tonumber(gym.price)
    if not gymPrice or gymPrice <= 0 or gymPrice > 100000000 then
        print(string.format("[esx_gym] Podejrzana cena siłowni - gracz %s (ID: %s) próbował kupić siłownię z nieprawidłową ceną: %s", 
            xPlayer.identifier, src, tostring(gym.price)))
        return
    end
    
    if xPlayer.getMoney() < gymPrice then
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy!')
        return
    end
    
    xPlayer.removeMoney(gymPrice)
    
    MySQL.update.await('UPDATE `gym_companies` SET `avaliable` = 0, `active` = 1, `owner_name` = ?, `owner_identifier` = ? WHERE `name` = ?', {
        xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'), xPlayer.identifier, gymName
    })
    
    MySQL.insert.await('INSERT INTO `gym_workers` (`gym_name`, `worker_name`, `worker_identifier`, `worker_rank_label`, `worker_rank_grade`) VALUES (?, ?, ?, ?, ?)', {
        gymName, xPlayer.get('firstName') .. ' ' .. xPlayer.get('lastName'), xPlayer.identifier, 'Szef', 5
    })
    
    xPlayer.showNotification('Gratulacje! Kupiłeś siłownię ' .. gym.label)
    
    local updatedGymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if updatedGymData[1] then
        TriggerClientEvent('esx_gym/updateGymData', src, updatedGymData[1])
    end
    
    TriggerClientEvent('esx_gym/purchaseGymSuccess', src, true)
end)

RegisterServerEvent('esx_gym/gymAction', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local action = data.action
    local gymName = data.gymName
    
    if action == 'buySupplements' then
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if gymData[1] then
            local stock = json.decode(gymData[1].stock or '{}')
            local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
            
            if not stock or next(stock) == nil then
                stock = {
                    kreatyna = 0,
                    l_karnityna = 0,
                    bialko = 0
                }
            end
            
            if not prices or next(prices) == nil then
                prices = {
                    kreatyna = 100,
                    l_karnityna = 150,
                    bialko = 200
                }
            end
            
            TriggerClientEvent('esx_gym/showSupplements', src, {
                stock = stock,
                prices = prices,
                gymName = gymName
            })
        end
    elseif action == 'buyPass' then
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if gymData[1] then
            local membershipPrices = json.decode(gymData[1].pass_prices or '{"daily":50,"weekly":300,"monthly":1000}')
            TriggerClientEvent('esx_gym/showBuyPass', src, { 
                gymName = gymName,
                prices = membershipPrices
            })
        else
            TriggerClientEvent('esx_gym/showBuyPass', src, { gymName = gymName })
        end
    elseif action == 'addWorker' then
        local hasPermission = checkGymPermission(src, gymName, 3)
        if not hasPermission then
            xPlayer.showNotification('Nie masz uprawnień do zatrudniania pracowników!')
            return
        end
        
        local players = {}
        
        local existingWorkers = MySQL.query.await('SELECT `worker_identifier` FROM `gym_workers` WHERE `gym_name` = ?', { gymName })
        local existingIdentifiers = {}
        for _, worker in ipairs(existingWorkers) do
            existingIdentifiers[worker.worker_identifier] = true
        end
        
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if gymData[1] and gymData[1].owner_identifier then
            existingIdentifiers[gymData[1].owner_identifier] = true
        end
        
        for _, playerId in ipairs(GetPlayers()) do
            if playerId ~= src then
                local targetPlayer = ESX.GetPlayerFromId(playerId)
                if targetPlayer then
                    if not existingIdentifiers[targetPlayer.identifier] then
                        local targetCoords = GetEntityCoords(GetPlayerPed(playerId))
                        local ownerCoords = GetEntityCoords(GetPlayerPed(src))
                        local distance = #(targetCoords - ownerCoords)
                        
                        if distance <= 4.0 then
                            table.insert(players, {
                                id = playerId,
                                name = targetPlayer.get('firstName') .. ' ' .. targetPlayer.get('lastName'),
                                identifier = targetPlayer.identifier
                            })
                        end
                    end
                end
            end
        end
        
        if #players == 0 then
            xPlayer.showNotification('Brak graczy w pobliżu lub wszyscy są już zatrudnieni!')
            return
        end
        
        TriggerClientEvent('esx_gym/showWorkerHire', src, {
            players = players,
            gymName = gymName
        })
    elseif action == 'viewWorkers' then
        local hasPermission = checkGymPermission(src, gymName, 2)
        if not hasPermission then
            xPlayer.showNotification('Nie masz uprawnień do przeglądania listy pracowników!')
            return
        end
        
        local workers = MySQL.query.await('SELECT * FROM `gym_workers` WHERE `gym_name` = ? ORDER BY `worker_rank_grade` DESC', { gymName })
        
        for _, worker in ipairs(workers) do
            worker.worker_identifier = worker.worker_identifier
            worker.rank = worker.worker_rank_grade
            worker.name = worker.worker_name
            worker.id = worker.id
        end
        
        local ownerInList = false
        for _, worker in ipairs(workers) do
            if worker.worker_rank_grade == 5 then
                ownerInList = true
                worker.is_owner = true
                break
            end
        end
        
        if not ownerInList then
            local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
            if gymData[1] then
                local ownerData = {
                    id = 0,
                    gym_name = gymName,
                    worker_name = gymData[1].owner_name or 'Właściciel',
                    worker_identifier = gymData[1].owner_identifier or '',
                    worker_rank_label = 'Właściciel',
                    worker_rank_grade = 5,
                    is_owner = true,
                    rank = 5,
                    name = gymData[1].owner_name or 'Właściciel'
                }
                
                table.insert(workers, 1, ownerData)
            end
        end
        
        TriggerClientEvent('esx_gym/showWorkerManagement', src, {
            workers = workers,
            gymName = gymName,
            ownerIdentifier = xPlayer.identifier
        })
    elseif action == 'viewUpgrades' then
        local hasPermission = checkGymPermission(src, gymName, 4)
        if not hasPermission then
            xPlayer.showNotification('Nie masz uprawnień do przeglądania ulepszeń!')
            return
        end
        
        local gymResult = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if not gymResult[1] then
            xPlayer.showNotification('Nie znaleziono siłowni!')
            return
        end
        
        local gymData = gymResult[1]
        
        TriggerClientEvent('esx_gym/showUpgradeManagement', src, {
            gymName = gymName,
            equipmentUpgraded = gymData.equipment_upgraded == 1
        })
        
    elseif action == 'upgradeFacility' then
        xPlayer.showNotification('Funkcja ulepszania obiektu zostanie dodana wkrótce!')
    elseif action == 'upgradeSecurity' then
        xPlayer.showNotification('Funkcja ulepszania bezpieczeństwa zostanie dodana wkrótce!')
    elseif action == 'membership' then
        local currentTime = os.time() * 1000
        local currentMembership = MySQL.query.await('SELECT * FROM `gym_passes` WHERE `player_identifier` = ? AND `gym_name` = ? AND `expires_at` > ? ORDER BY `expires_at` DESC LIMIT 1', { 
            xPlayer.identifier, gymName, currentTime 
        })
        
        if currentMembership[1] then
            local membership = currentMembership[1]
            local timeLeft = membership.expires_at - currentTime
            
            local days = math.floor(timeLeft / (24 * 60 * 60 * 1000))
            local hours = math.floor((timeLeft % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000))
            local minutes = math.floor((timeLeft % (60 * 60 * 1000)) / (60 * 1000))
            
            local timeLeftText = ''
            if days > 0 then
                timeLeftText = days .. 'd ' .. hours .. 'h ' .. minutes .. 'm'
            elseif hours > 0 then
                timeLeftText = hours .. 'h ' .. minutes .. 'm'
            else
                timeLeftText = minutes .. 'm'
            end
            
            local passTypeLabels = {
                daily = 'Dzienne',
                weekly = 'Tygodniowe',
                monthly = 'Miesięczne'
            }
            
            TriggerClientEvent('esx_gym/showMembership', src, {
                gymName = gymName,
                hasMembership = true,
                membershipType = passTypeLabels[membership.pass_type] or membership.pass_type,
                timeLeft = timeLeftText,
                expiresAt = membership.expires_at,
                purchasedAt = membership.purchased_at
            })
        else
            local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
            local membershipPrices = { daily = 50, weekly = 300, monthly = 1000 }
            if gymData[1] then
                membershipPrices = json.decode(gymData[1].pass_prices or '{"daily":50,"weekly":300,"monthly":1000}')
            end
            TriggerClientEvent('esx_gym/showBuyMembership', src, { 
                gymName = gymName,
                prices = membershipPrices
            })
        end
    elseif action == 'manageMembershipPrices' then
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ? AND `owner_identifier` = ?', { gymName, xPlayer.identifier })
        if not gymData[1] then
            xPlayer.showNotification('Nie jesteś właścicielem tej siłowni!')
            return
        end
        
        local membershipPrices = json.decode(gymData[1].pass_prices or '{"daily":50,"weekly":300,"monthly":1000}')
        TriggerClientEvent('esx_gym/showMembershipPriceManagement', src, {
            prices = membershipPrices,
            gymName = gymName
        })
    elseif action == 'manageCompanyAccount' then
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ? AND `owner_identifier` = ?', { gymName, xPlayer.identifier })
        if not gymData[1] then
            xPlayer.showNotification('Nie jesteś właścicielem tej siłowni!')
            return
        end
        
        local companyAccount = gymData[1].company_account or 0
        TriggerClientEvent('esx_gym/showCompanyAccount', src, {
            gymName = gymName,
            balance = companyAccount
        })
    elseif action == 'viewMembershipClients' then
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ? AND `owner_identifier` = ?', { gymName, xPlayer.identifier })
        if not gymData[1] then
            xPlayer.showNotification('Nie jesteś właścicielem tej siłowni!')
            return
        end
        
        local clients = MySQL.query.await([[
            SELECT 
                gp.player_identifier,
                gp.pass_type,
                gp.expires_at,
                gp.purchased_at,
                u.firstname,
                u.lastname
            FROM gym_passes gp
            LEFT JOIN users u ON gp.player_identifier = u.identifier
            WHERE gp.gym_name = ?
            ORDER BY gp.expires_at DESC
        ]], { gymName })
        
        local currentTime = os.time() * 1000
        local processedClients = {}
        
        for _, client in ipairs(clients) do
            local isActive = client.expires_at > currentTime
            local timeLeft = client.expires_at - currentTime
            
            local days = math.floor(timeLeft / (24 * 60 * 60 * 1000))
            local hours = math.floor((timeLeft % (24 * 60 * 60 * 1000)) / (60 * 60 * 1000))
            local minutes = math.floor((timeLeft % (60 * 60 * 1000)) / (60 * 1000))
            
            local timeLeftText = ''
            if days > 0 then
                timeLeftText = days .. 'd ' .. hours .. 'h ' .. minutes .. 'm'
            elseif hours > 0 then
                timeLeftText = hours .. 'h ' .. minutes .. 'm'
            else
                timeLeftText = minutes .. 'm'
            end
            
            local passTypeLabels = {
                daily = 'Dzienna',
                weekly = 'Tygodniowa',
                monthly = 'Miesięczna'
            }
            
            table.insert(processedClients, {
                identifier = client.player_identifier,
                name = (client.firstname or 'Nieznane') .. ' ' .. (client.lastname or 'Imię'),
                passType = passTypeLabels[client.pass_type] or client.pass_type,
                timeLeft = timeLeftText,
                isActive = isActive,
                expiresAt = client.expires_at,
                purchasedAt = client.purchased_at
            })
        end
        
        TriggerClientEvent('esx_gym/showPassClients', src, {
            clients = processedClients,
            gymName = gymName
        })
    elseif action == 'managePrices' then
        local hasPermission, grade = checkGymPermission(src, gymName, 4)
        if not hasPermission then
            xPlayer.showNotification('Nie masz uprawnień do zarządzania cenami!')
            return
        end
        
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if gymData[1] then
            local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
            TriggerClientEvent('esx_gym/showPriceManagement', src, {
                prices = prices,
                gymName = gymName
            })
        end
    elseif action == 'viewInventory' then
        local hasPermission = checkGymPermission(src, gymName, 1)
        if not hasPermission then
            xPlayer.showNotification('Nie masz uprawnień do przeglądania magazynu!')
            return
        end
        
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if gymData[1] then
            local stock = json.decode(gymData[1].stock or '{}')
            
            local canBuyAll = false
            local canDeliver = false
            local totalMissing = 0
            
            for supplement, quantity in pairs(stock) do
                if quantity < Config.MaxStockPerItem then
                    canBuyAll = true
                    canDeliver = true
                    totalMissing = totalMissing + (Config.MaxStockPerItem - quantity)
                end
            end
            
            local basePrice = 100000
            local pricePerMissing = 500
            local totalPrice = basePrice + (totalMissing * pricePerMissing)
            
            TriggerClientEvent('esx_gym/showInventory', src, {
                stock = stock,
                gymName = gymName,
                canBuyAll = canBuyAll,
                canDeliver = canDeliver,
                totalPrice = totalPrice,
                totalMissing = totalMissing,
                maxStock = Config.MaxStockPerItem
            })
        end
    end
end)

RegisterServerEvent('esx_gym/purchaseSupplement', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local supplement = data.supplement
    local quantity = data.quantity or 1
    local paymentMethod = data.paymentMethod or 'cash'
    
    if not gymName or type(gymName) ~= "string" then
        print(string.format("[esx_gym] Podejrzana próba zakupu - gracz %s (ID: %s) próbował użyć nieprawidłowego gymName", 
            xPlayer.identifier, src))
        return
    end
    
    local ALLOWED_SUPPLEMENTS = { kreatyna = true, l_karnityna = true, bialko = true }
    if not supplement or type(supplement) ~= "string" or not ALLOWED_SUPPLEMENTS[supplement] then
        print(string.format("[esx_gym] Podejrzana próba zakupu - gracz %s (ID: %s) próbował kupić nieprawidłowy suplement: %s", 
            xPlayer.identifier, src, tostring(supplement)))
        return
    end
    
    quantity = tonumber(quantity)
    if not quantity or quantity <= 0 or quantity > 100 then
        print(string.format("[esx_gym] Podejrzana próba zakupu - gracz %s (ID: %s) próbował kupić nieprawidłową ilość: %s", 
            xPlayer.identifier, src, tostring(data.quantity)))
        return
    end
    
    if paymentMethod ~= 'cash' and paymentMethod ~= 'card' then
        print(string.format("[esx_gym] Podejrzana próba zakupu - gracz %s (ID: %s) próbował użyć nieprawidłowej metody płatności: %s", 
            xPlayer.identifier, src, tostring(paymentMethod)))
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] then return end
    
    local stock = json.decode(gymData[1].stock or '{}')
    local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
    
    if not stock[supplement] or stock[supplement] < quantity then
        xPlayer.showNotification('Brak wystarczającej ilości w magazynie!')
        return
    end
    
    if xPlayer.canCarryItem and not xPlayer.canCarryItem(supplement, quantity) then
        xPlayer.showNotification('Nie masz miejsca w ekwipunku!')
        return
    end
    
    local totalPrice = (prices[supplement] or 0) * quantity
    
    local hasEnoughMoney = false
    if paymentMethod == 'cash' then
        hasEnoughMoney = xPlayer.getMoney() >= totalPrice
        if hasEnoughMoney then
            xPlayer.removeMoney(totalPrice)
        end
    elseif paymentMethod == 'card' then
        hasEnoughMoney = xPlayer.getAccount('bank').money >= totalPrice
        if hasEnoughMoney then
            xPlayer.removeAccountMoney('bank', totalPrice)
        end
    end
    
    if not hasEnoughMoney then
        local paymentType = paymentMethod == 'cash' and 'gotówki' or 'na karcie'
        xPlayer.showNotification('Nie masz wystarczająco ' .. paymentType .. '!')
        return
    end
    
    stock[supplement] = stock[supplement] - quantity
    
    MySQL.update.await('UPDATE `gym_companies` SET `stock` = ? WHERE `name` = ?', {
        json.encode(stock), gymName
    })
    
    xPlayer.addInventoryItem(supplement, quantity)
    
    local supplementNames = {
        kreatyna = 'Kreatyna',
        l_karnityna = 'L-karnityna',
        bialko = 'Białko'
    }
    
    local currentAccount = gymData[1].company_account or 0
    local newAccountBalance = currentAccount + totalPrice
    MySQL.update.await('UPDATE `gym_companies` SET `company_account` = ? WHERE `name` = ?', {
        newAccountBalance, gymName
    })
    
    local paymentType = paymentMethod == 'cash' and 'gotówką' or 'kartą'
    xPlayer.showNotification('Kupiłeś ' .. quantity .. 'x ' .. (supplementNames[supplement] or supplement) .. ' za $' .. totalPrice .. ' (' .. paymentType .. ')')
    
    TriggerClientEvent('esx_gym/updateSupplementShop', src, {
        stock = stock,
        prices = prices,
        gymName = gymName
    })
    
    local updatedGymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if updatedGymData[1] then
        TriggerClientEvent('esx_gym/refreshGymData', src, gymName)
    end
end)

RegisterServerEvent('esx_gym/updateSupplementPrices', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local prices = data.prices
    
    if not gymName or type(gymName) ~= "string" then
        print(string.format("[esx_gym] Podejrzana próba zmiany cen - gracz %s (ID: %s) próbował użyć nieprawidłowego gymName", 
            xPlayer.identifier, src))
        return
    end
    
    if not prices or type(prices) ~= "table" then
        print(string.format("[esx_gym] Podejrzana próba zmiany cen - gracz %s (ID: %s) próbował użyć nieprawidłowych cen", 
            xPlayer.identifier, src))
        return
    end
    
    local hasPermission = checkGymPermission(src, gymName, 4)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do zmiany cen!')
        return
    end
    
    local ALLOWED_SUPPLEMENTS = { kreatyna = true, l_karnityna = true, bialko = true }
    local validPrices = {}
    
    for supplement, price in pairs(prices) do
        if ALLOWED_SUPPLEMENTS[supplement] then
            price = tonumber(price)
            if price and price >= 1 and price <= 100000 then
                validPrices[supplement] = price
            else
                print(string.format("[esx_gym] Podejrzana próba zmiany cen - gracz %s (ID: %s) próbował ustawić nieprawidłową cenę %s dla %s", 
                    xPlayer.identifier, src, tostring(price), supplement))
                xPlayer.showNotification('Nieprawidłowa cena dla ' .. supplement .. '! (1-100000)')
                return
            end
        end
    end
    
    MySQL.update.await('UPDATE `gym_companies` SET `supplement_prices` = ? WHERE `name` = ?', {
        json.encode(validPrices), gymName
    })
    
    xPlayer.showNotification('Ceny suplementów zostały zaktualizowane!')
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/buyAllSupplies', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then 
        return 
    end
    
    local gymName = data.gymName
    
    if not gymName then
        xPlayer.showNotification('Błąd: brak nazwy siłowni!')
        return
    end
    
    local hasPermission = checkGymPermission(src, gymName, 4)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do kupowania dostaw!')
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] then
        xPlayer.showNotification('Błąd: nie znaleziono siłowni!')
        return
    end
    
    local stock = json.decode(gymData[1].stock or '{"kreatyna":0,"l_karnityna":0,"bialko":0}')
    local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
    
    local supplements = {'kreatyna', 'l_karnityna', 'bialko'}
    local totalCost = 0
    local totalMissing = 0
    local newStock = {}
    
    for _, supplement in ipairs(supplements) do
        local currentStock = stock[supplement] or 0
        local maxStock = Config.MaxStockPerItem or 200
        local missing = maxStock - currentStock
        local price = prices[supplement] or 100
        
        if missing > 0 then
            totalCost = totalCost + (missing * price)
            totalMissing = totalMissing + missing
        end
        
        newStock[supplement] = maxStock
    end
    
    if totalMissing == 0 then
        xPlayer.showNotification('Magazyn jest już pełny!')
        return
    end
    
    if xPlayer.getMoney() < totalCost then
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy! Potrzebujesz $' .. totalCost)
        return
    end
    
    xPlayer.removeMoney(totalCost)
    
    local success = MySQL.update.await('UPDATE `gym_companies` SET `stock` = ? WHERE `name` = ?', {
        json.encode(newStock), gymName
    })
    
    if success then
        xPlayer.showNotification('Uzupełniono wszystkie zapasy za $' .. totalCost .. '! (Dodano ' .. totalMissing .. ' szt.)')
        
        local updatedGymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        
        if updatedGymData[1] then
            TriggerClientEvent('esx_gym/updateGymData', src, updatedGymData[1])
        end
    else
        xPlayer.showNotification('Błąd podczas aktualizacji magazynu!')
        xPlayer.addMoney(totalCost)
    end
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/buySelectedSupplies', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then 
        return 
    end
    
    local gymName = data.gymName
    local quantities = data.quantities
    
    if not gymName then
        xPlayer.showNotification('Błąd: brak nazwy siłowni!')
        return
    end
    
    if not quantities or type(quantities) ~= 'table' then
        xPlayer.showNotification('Błąd: nieprawidłowe dane!')
        return
    end
    
    local hasPermission = checkGymPermission(src, gymName, 4)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do kupowania dostaw!')
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] then
        xPlayer.showNotification('Błąd: nie znaleziono siłowni!')
        return
    end
    
    local stock = json.decode(gymData[1].stock or '{"kreatyna":0,"l_karnityna":0,"bialko":0}')
    local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
    
    local supplements = {'kreatyna', 'l_karnityna', 'bialko'}
    local totalCost = 0
    local totalAdded = 0
    local newStock = {}
    
    for k, v in pairs(stock) do
        newStock[k] = v
    end
    
    for _, supplement in ipairs(supplements) do
        local quantityToBuy = tonumber(quantities[supplement]) or 0
        if quantityToBuy > 0 then
            local currentStock = stock[supplement] or 0
            local maxStock = Config.MaxStockPerItem or 200
            local availableSpace = maxStock - currentStock
            
            if quantityToBuy > availableSpace then
                 quantityToBuy = availableSpace
            end
            
            if quantityToBuy > 0 then
                local price = prices[supplement] or 100
                totalCost = totalCost + (quantityToBuy * price)
                totalAdded = totalAdded + quantityToBuy
                newStock[supplement] = currentStock + quantityToBuy
            end
        else
            if not newStock[supplement] then
                 newStock[supplement] = stock[supplement] or 0
            end
        end
    end
    
    if totalAdded == 0 then
        xPlayer.showNotification('Nie wybrano żadnych produktów lub magazyn jest pełny!')
        return
    end
    
    if xPlayer.getMoney() < totalCost then
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy! Potrzebujesz $' .. totalCost)
        return
    end
    
    xPlayer.removeMoney(totalCost)
    
    local success = MySQL.update.await('UPDATE `gym_companies` SET `stock` = ? WHERE `name` = ?', {
        json.encode(newStock), gymName
    })
    
    if success then
        xPlayer.showNotification('Kupiono wybrane zapasy za $' .. totalCost .. '! (Dodano ' .. totalAdded .. ' szt.)')
        
        local updatedGymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        
        if updatedGymData[1] then
            TriggerClientEvent('esx_gym/updateGymData', src, updatedGymData[1])
            
            local updatedStock = json.decode(updatedGymData[1].stock or '{}')
            TriggerClientEvent('esx_gym/showInventory', src, {
                stock = updatedStock,
                gymName = gymName,
                canBuyAll = false,
                canDeliver = false,
                totalPrice = 0,
                totalMissing = 0,
                maxStock = Config.MaxStockPerItem
            })
        end
    else
        xPlayer.showNotification('Błąd podczas aktualizacji magazynu!')
        xPlayer.addMoney(totalCost)
    end
end)

RegisterServerEvent('esx_gym/startDelivery', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    if not gymName then
        xPlayer.showNotification('Błąd: brak nazwy siłowni!')
        return
    end
    
    local hasPermission = checkGymPermission(src, gymName, 3)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do rozpoczęcia dostawy!')
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] then
        xPlayer.showNotification('Błąd: nie znaleziono siłowni!')
        return
    end
    
    local stock = json.decode(gymData[1].stock or '{"kreatyna":0,"l_karnityna":0,"bialko":0}')
    local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
    
    local supplements = {'kreatyna', 'l_karnityna', 'bialko'}
    local totalCost = 0
    local totalMissing = 0
    
    for _, supplement in ipairs(supplements) do
        local currentStock = stock[supplement] or 0
        local maxStock = Config.MaxStockPerItem or 200
        local missing = maxStock - currentStock
        local price = prices[supplement] or 100
        
        if missing > 0 then
            totalCost = totalCost + (missing * price)
            totalMissing = totalMissing + missing
        end
    end
    
    if totalMissing == 0 then
        xPlayer.showNotification('Magazyn jest już pełny!')
        TriggerClientEvent('esx_gym/closeNui', src)
        return
    end
    
    local deliveryCost = math.floor(totalCost * (Config.Mission.delivery.discount or 0.7))
    
    if xPlayer.getMoney() < deliveryCost then
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy! Potrzebujesz: $' .. deliveryCost)
        return
    end
    
    xPlayer.removeMoney(deliveryCost)
    xPlayer.showNotification('Zapłacono $' .. deliveryCost .. ' za dostawę. Rozpocznij misję!')
    
    TriggerClientEvent('esx_gym/startDeliveryMission', src, gymName)
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/closeNui', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/hireWorker', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local workerId = data.workerId
    local workerName = data.workerName
    local workerIdentifier = data.workerIdentifier
    
    if not gymName or not workerId or not workerName or not workerIdentifier then
        xPlayer.showNotification('Błąd: brak danych pracownika!')
        return
    end
    
    local hasPermission = checkGymPermission(src, gymName, 3)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do zatrudniania pracowników!')
        return
    end
    
    local existingWorker = MySQL.query.await('SELECT * FROM `gym_workers` WHERE `gym_name` = ? AND `worker_identifier` = ?', { gymName, workerIdentifier })
    if existingWorker[1] then
        xPlayer.showNotification('Ten gracz jest już zatrudniony w tej siłowni!')
        return
    end
    
    MySQL.insert.await('INSERT INTO `gym_workers` (`gym_name`, `worker_name`, `worker_identifier`, `worker_rank_label`, `worker_rank_grade`) VALUES (?, ?, ?, ?, ?)', {
        gymName, workerName, workerIdentifier, 'Stażysta', 0
    })
    
    xPlayer.showNotification('Zatrudniono pracownika: ' .. workerName)
    
    local targetPlayer = ESX.GetPlayerFromId(workerId)
    if targetPlayer then
        targetPlayer.showNotification('Zostałeś zatrudniony w siłowni!')
    end
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/fireWorker', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local workerIdentifier = data.workerIdentifier
    local workerName = data.workerName
    
    if not gymName or not workerIdentifier then
        xPlayer.showNotification('Błąd: brak danych pracownika!')
        return
    end
    
    local hasPermission = checkGymPermission(src, gymName, 3)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do zwalniania pracowników!')
        return
    end
    
    if workerIdentifier == xPlayer.identifier then
        xPlayer.showNotification('Nie możesz zwolnić samego siebie!')
        return
    end
    
    MySQL.update.await('DELETE FROM `gym_workers` WHERE `gym_name` = ? AND `worker_identifier` = ?', { gymName, workerIdentifier })
    
    xPlayer.showNotification('Zwolniono pracownika: ' .. (workerName or 'Nieznany'))
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/promoteWorker', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local workerIdentifier = data.workerIdentifier
    local workerName = data.workerName
    local newGrade = data.newGrade
    
    if not gymName or not workerIdentifier or not newGrade then
        xPlayer.showNotification('Błąd: brak danych pracownika!')
        return
    end
    
    local hasPermission, currentGrade = checkGymPermission(src, gymName, 4)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do awansowania pracowników!')
        return
    end
    
    if newGrade >= currentGrade then
        xPlayer.showNotification('Nie możesz awansować pracownika na poziom równy lub wyższy od Twojego!')
        return
    end
    
    if workerIdentifier == xPlayer.identifier then
        xPlayer.showNotification('Nie możesz awansować samego siebie!')
        return
    end
    
    if newGrade < 0 or newGrade > 4 then
        xPlayer.showNotification('Nieprawidłowy stopień!')
        return
    end
    
    local rankLabels = {
        [0] = 'Stopień: Stażysta',
        [1] = 'Stopień: Pracownik',
        [2] = 'Stopień: Kierownik',
        [3] = 'Stopień: Zastępca',
        [4] = 'Stopień: Menedżer'
    }
    
    local rankLabel = rankLabels[newGrade] or 'Stażysta'
    
    MySQL.update.await('UPDATE `gym_workers` SET `worker_rank_grade` = ?, `worker_rank_label` = ? WHERE `gym_name` = ? AND `worker_identifier` = ?', {
        newGrade, rankLabel, gymName, workerIdentifier
    })
    
    xPlayer.showNotification('Awansowano pracownika: ' .. (workerName or 'Nieznany') .. ' na ' .. rankLabel)
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/demoteWorker', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local workerIdentifier = data.workerIdentifier
    local workerName = data.workerName
    local newGrade = data.newGrade
    
    if not gymName or not workerIdentifier or not newGrade then
        xPlayer.showNotification('Błąd: brak danych pracownika!')
        return
    end
    
    local hasPermission, currentGrade = checkGymPermission(src, gymName, 4)
    if not hasPermission then
        xPlayer.showNotification('Nie masz uprawnień do degradowania pracowników!')
        return
    end
    
    if newGrade >= currentGrade then
        xPlayer.showNotification('Nie możesz degradować pracownika na poziom równy lub wyższy od Twojego!')
        return
    end
    
    if workerIdentifier == xPlayer.identifier then
        xPlayer.showNotification('Nie możesz degradować samego siebie!')
        return
    end
    
    if newGrade < 0 or newGrade > 4 then
        xPlayer.showNotification('Nieprawidłowy stopień!')
        return
    end
    
    local rankLabels = {
        [0] = 'Stopień: Stażysta',
        [1] = 'Stopień: Pracownik',
        [2] = 'Stopień: Kierownik',
        [3] = 'Stopień: Zastępca',
        [4] = 'Stopień: Menedżer'
    }
    
    local rankLabel = rankLabels[newGrade] or 'Stażysta'
    
    MySQL.update.await('UPDATE `gym_workers` SET `worker_rank_grade` = ?, `worker_rank_label` = ? WHERE `gym_name` = ? AND `worker_identifier` = ?', {
        newGrade, rankLabel, gymName, workerIdentifier
    })
    
    xPlayer.showNotification('Zdegradowano pracownika: ' .. (workerName or 'Nieznany') .. ' na ' .. rankLabel)
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/purchaseMembership', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local membershipType = data.membershipType
    
    if not gymName or type(gymName) ~= "string" then
        print(string.format("[esx_gym] Podejrzana próba zakupu członkostwa - gracz %s (ID: %s) próbował użyć nieprawidłowego gymName", 
            xPlayer.identifier, src))
        return
    end
    
    local ALLOWED_MEMBERSHIP_TYPES = { daily = true, weekly = true, monthly = true }
    if not membershipType or type(membershipType) ~= "string" or not ALLOWED_MEMBERSHIP_TYPES[membershipType] then
        print(string.format("[esx_gym] Podejrzana próba zakupu członkostwa - gracz %s (ID: %s) próbował użyć nieprawidłowego typu: %s", 
            xPlayer.identifier, src, tostring(membershipType)))
        return
    end
    
    local membershipConfig = Config.GymPass[membershipType]
    if not membershipConfig then
        xPlayer.showNotification('Nieprawidłowy typ członkostwa!')
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] then
        xPlayer.showNotification('Błąd: nie znaleziono siłowni!')
        return
    end
    
    local membershipPrices = json.decode(gymData[1].pass_prices or '{"daily":50,"weekly":300,"monthly":1000}')
    local currentPrice = membershipPrices[membershipType] or membershipConfig.defaultPrice
    
    if xPlayer.getMoney() < currentPrice then
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy! Potrzebujesz $' .. currentPrice)
        return
    end
    
    local currentTime = os.time() * 1000
    local existingMembership = MySQL.query.await('SELECT * FROM `gym_passes` WHERE `player_identifier` = ? AND `gym_name` = ? AND `expires_at` > ?', { 
        xPlayer.identifier, gymName, currentTime 
    })
    
    local expiresAt
    if existingMembership[1] then
        expiresAt = existingMembership[1].expires_at + membershipConfig.duration
        xPlayer.showNotification('Przedłużono członkostwo ' .. membershipConfig.description .. ' za $' .. currentPrice .. '!')
    else
        expiresAt = currentTime + membershipConfig.duration
        xPlayer.showNotification('Kupiłeś członkostwo ' .. membershipConfig.description .. ' za $' .. currentPrice .. '!')
    end
    
    xPlayer.removeMoney(currentPrice)
    
    MySQL.query.await('DELETE FROM `gym_passes` WHERE `player_identifier` = ? AND `gym_name` = ?', { xPlayer.identifier, gymName })
    
    MySQL.insert.await('INSERT INTO `gym_passes` (`player_identifier`, `gym_name`, `pass_type`, `expires_at`, `purchased_at`) VALUES (?, ?, ?, ?, ?)', {
        xPlayer.identifier, gymName, membershipType, expiresAt, currentTime
    })
    
    local currentAccount = gymData[1].company_account or 0
    local newAccountBalance = currentAccount + currentPrice
    MySQL.update.await('UPDATE `gym_companies` SET `company_account` = ? WHERE `name` = ?', {
        newAccountBalance, gymName
    })
    
    TriggerClientEvent('esx_gym/refreshMembership', src, gymName)
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/updatePassPrices', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local prices = data.prices
    
    if not gymName or type(gymName) ~= "string" then
        print(string.format("[esx_gym] Podejrzana próba zmiany cen przepustek - gracz %s (ID: %s) próbował użyć nieprawidłowego gymName", 
            xPlayer.identifier, src))
        return
    end
    
    if not prices or type(prices) ~= "table" then
        print(string.format("[esx_gym] Podejrzana próba zmiany cen przepustek - gracz %s (ID: %s) próbował użyć nieprawidłowych cen", 
            xPlayer.identifier, src))
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ? AND `owner_identifier` = ?', { gymName, xPlayer.identifier })
    if not gymData[1] then
        xPlayer.showNotification('Nie jesteś właścicielem tej siłowni!')
        return
    end
    
    local ALLOWED_PASS_TYPES = { daily = true, weekly = true, monthly = true }
    local validPrices = {}
    
    for passType, price in pairs(prices) do
        if ALLOWED_PASS_TYPES[passType] then
            price = tonumber(price)
            if price and price >= 1 and price <= 1000000 then
                validPrices[passType] = price
            else
                print(string.format("[esx_gym] Podejrzana próba zmiany cen przepustek - gracz %s (ID: %s) próbował ustawić nieprawidłową cenę %s dla %s", 
                    xPlayer.identifier, src, tostring(price), passType))
                xPlayer.showNotification('Nieprawidłowa cena dla ' .. passType .. '! (1-1000000)')
                return
            end
        end
    end
    
    prices = validPrices
    
    MySQL.update.await('UPDATE `gym_companies` SET `pass_prices` = ? WHERE `name` = ?', {
        json.encode(prices), gymName
    })
    
    xPlayer.showNotification('Ceny przepustek zostały zaktualizowane!')
    
    local updatedGymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if updatedGymData[1] then
        TriggerClientEvent('esx_gym/updateGymData', src, updatedGymData[1])
    end
    
    TriggerClientEvent('esx_gym/closeNui', src)
end)

RegisterServerEvent('esx_gym/withdrawCompanyAccount', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local gymName = data.gymName
    local amount = tonumber(data.amount)
    
    if not gymName or type(gymName) ~= "string" then
        print(string.format("[esx_gym] Podejrzana próba wypłaty - gracz %s (ID: %s) próbował użyć nieprawidłowego gymName", 
            xPlayer.identifier, src))
        return
    end
    
    if not amount or amount <= 0 or amount > 10000000 then
        print(string.format("[esx_gym] Podejrzana próba wypłaty - gracz %s (ID: %s) próbował wypłacić nieprawidłową kwotę: %s", 
            xPlayer.identifier, src, tostring(data.amount)))
        xPlayer.showNotification('Nieprawidłowa kwota!')
        return
    end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ? AND `owner_identifier` = ?', { gymName, xPlayer.identifier })
    if not gymData[1] then
        xPlayer.showNotification('Nie jesteś właścicielem tej siłowni!')
        return
    end
    
    local currentAccount = gymData[1].company_account or 0
    
    if amount > currentAccount then
        xPlayer.showNotification('Nie masz wystarczająco środków na koncie firmowym! Dostępne: $' .. currentAccount)
        return
    end
    
    local newAccountBalance = currentAccount - amount
    MySQL.update.await('UPDATE `gym_companies` SET `company_account` = ? WHERE `name` = ?', {
        newAccountBalance, gymName
    })
    
    xPlayer.addMoney(amount)
    xPlayer.showNotification('Wypłacono $' .. amount .. ' z konta firmowego. Pozostało: $' .. newAccountBalance)
    
    TriggerClientEvent('esx_gym/showCompanyAccount', src, {
        gymName = gymName,
        balance = newAccountBalance
    })
end)

lib.callback.register('esx_gym/getPlayerMoney', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    
    return xPlayer.getMoney()
end)

lib.callback.register('esx_gym/gymAction', function(source, action, gymName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    if action == 'upgradeEquipment' then
        local hasPermission = checkGymPermission(source, gymName, 5)
        if not hasPermission then
            xPlayer.showNotification('Tylko właściciel może kupować ulepszenia!')
            return false
        end
        
        local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
        if not gymData[1] then
            xPlayer.showNotification('Błąd podczas ładowania danych siłowni!')
            return false
        end
        
        if gymData[1].equipment_upgraded == 1 then
            xPlayer.showNotification('Sprzęt w tej siłowni jest już ulepszony!')
            return false
        end
        
        local upgradePrice = Config.Upgrades.equipment.price
        if xPlayer.getMoney() < upgradePrice then
            xPlayer.showNotification('Nie masz wystarczająco pieniędzy! Potrzebujesz $' .. upgradePrice)
            return false
        end
        
        xPlayer.removeMoney(upgradePrice)
        MySQL.update.await('UPDATE `gym_companies` SET `equipment_upgraded` = 1 WHERE `name` = ?', { gymName })
        xPlayer.showNotification('Pomyślnie ulepszono sprzęt w siłowni za $' .. upgradePrice .. '!')
        
        TriggerClientEvent('esx_gym/refreshGymData', source, gymName)
        
        return true
    end
    
    return false
end)

lib.callback.register('esx_gym/getSupplementBoosts', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { stamina = 1.0, strength = 1.0, lung = 1.0 } end
    
    local boosts = {
        stamina = 1.0,
        strength = 1.0,
        lung = 1.0
    }
    
    local kreatyna = xPlayer.getInventoryItem('kreatyna')
    if kreatyna and kreatyna.count > 0 then
        boosts.strength = 1.5
    end
    
    local l_karnityna = xPlayer.getInventoryItem('l_karnityna')
    if l_karnityna and l_karnityna.count > 0 then
        boosts.stamina = 1.5
    end
    
    local bialko = xPlayer.getInventoryItem('bialko')
    if bialko and bialko.count > 0 then
        boosts.lung = 1.5
    end
    
    return boosts
end)

lib.callback.register('esx_gym/getDeliveryPrices', function(source, gymName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { kreatyna = 100, l_karnityna = 150, bialko = 200 } end
    
    local gymData = MySQL.query.await('SELECT * FROM `gym_companies` WHERE `name` = ?', { gymName })
    if not gymData[1] then
        return { kreatyna = 100, l_karnityna = 150, bialko = 200 }
    end
    
    local prices = json.decode(gymData[1].supplement_prices or '{"kreatyna":100,"l_karnityna":150,"bialko":200}')
    return prices
end)

RegisterServerEvent('esx_gym/useSupplement', function(supplementType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local itemName = ''
    local skillType = ''
    
    if supplementType == 'kreatyna' then
        itemName = 'kreatyna'
        skillType = 'strength'
    elseif supplementType == 'l_karnityna' then
        itemName = 'l_karnityna'
        skillType = 'stamina'
    elseif supplementType == 'bialko' then
        itemName = 'bialko'
        skillType = 'lung'
    else
        return
    end
    
    local item = xPlayer.getInventoryItem(itemName)
    if item and item.count > 0 then
        xPlayer.removeInventoryItem(itemName, 1)
        xPlayer.showNotification('Zużyto ' .. itemName .. ' - boost do ' .. skillType .. ' aktywowany!')
    end
end)