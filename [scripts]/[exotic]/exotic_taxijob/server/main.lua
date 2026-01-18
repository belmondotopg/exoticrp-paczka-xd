local Workers = {}

local banCooldown = {}

local startCooldown = function(source)
    CreateThread(function()
        banCooldown[source] = true
        Wait(15000)
        banCooldown[source] = false
    end)
end

RegisterNetEvent('taxijob:addSkin', function(name, skin, sex)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job and xPlayer.job.name == 'taxi' and xPlayer.job.grade >= Config.addClothesGrade then
        MySQL.insert.await(
            'INSERT INTO `taxi_clothes` (name, skin, sex) VALUES (?, ?, ?)',
            {name, json.encode(skin), sex})
    end
end)

local lastRequestTime = {}

lib.callback.register('taxijob:getClothes', function(source, sex)
    local now = os.time()

    if lastRequestTime[source] and now - lastRequestTime[source] < 5 then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Spróbuj ponownie za 5 sekund.'
        })
        return nil
    end

    lastRequestTime[source] = now

    local response = MySQL.query.await(
        'SELECT `id`,`skin`, `name` FROM `taxi_clothes` WHERE `sex` = ?',
        {sex}
    )

    return response
end)

local function getDistance3D(startPos, endPos)
    local dx = endPos.x - startPos.x
    local dy = endPos.y - startPos.y
    local dz = endPos.z - startPos.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end
local function getRandomRoute(usedRoutes, playerGrade)
    local startIndex, endIndex
    repeat
        startIndex = math.random(1, #Config.JobLocations)
        endIndex = math.random(1, #Config.JobLocations)
    until startIndex ~= endIndex and
        not usedRoutes[startIndex .. "-" .. endIndex]

    usedRoutes[startIndex .. "-" .. endIndex] = true

    local startPos = Config.JobLocations[startIndex]
    local finishPos = Config.JobLocations[endIndex]

    local name = Config.Names[math.random(1, #Config.Names)]
    local stars = math.random(2, 10) / 2
    local distance = getDistance3D(startPos, finishPos)

    local vip = false
    if playerGrade and playerGrade >= 2 then vip = math.random(1, 100) <= 10 end

    return {
        start = startPos,
        finish = finishPos,
        name = name,
        stars = stars,
        distance = distance,
        vip = vip,
        key = startIndex .. "-" .. endIndex
    }
end

local function generateRoutes(n, grade)
    local routes = {}
    local usedRoutes = {}
    for i = 1, n do table.insert(routes, getRandomRoute(usedRoutes, grade)) end
    return routes
end

local function addRoute(routes)
    local usedRoutes = {}
    for _, route in ipairs(routes) do usedRoutes[route.key] = true end
    table.insert(routes, getRandomRoute(usedRoutes))
end

local function removeRoute(routes, index)
    if routes[index] then table.remove(routes, index) end
end

RegisterNetEvent('taxiJob:startJob', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.job and xPlayer.job.name == 'taxi' then
        Workers[_source] = {
            currentRoadId = nil,
            onJob = true,
            clients = generateRoutes(6, xPlayer.job.grade)
        }
    end
end)

RegisterNetEvent('taxiJob:stopJob', function()
    local _source = source
    if Workers[_source] then Workers[_source] = nil end
end)

RegisterNetEvent('taxiJob:startRoute', function(routeId, playerStartPos)
    local _source = source
    if Workers[_source] then
        local worker = Workers[_source]
        if worker.clients[routeId] then
            worker.currentRoadId = routeId
            -- Zapisujemy timestamp i pozycję gracza przy starcie kursu
            worker.clients[routeId].startTime = os.time()
            worker.clients[routeId].playerStartPos = playerStartPos or nil
            startCooldown(_source)

            local client = worker.clients[routeId]
            local logMessage = string.format(
                "Gracz %s [%s] rozpoczął kurs:\n- Klient: %s\n- Gwiazdki: %.1f★\n- VIP: %s",
                GetPlayerName(_source) or "Nieznany",
                _source,
                client.name,
                client.stars or 0,
                client.vip and "Tak" or "Nie"
            )
            exports.esx_core:SendLog(_source, "Rozpoczęcie kursu Taxi", logMessage, 'taxi')

            TriggerClientEvent('taxiJob:startRoute', _source, routeId)
            TriggerClientEvent('esx:showNotification', _source,
                               'Rozpocząłeś kurs dla ~y~' ..
                                   worker.clients[routeId].name ..
                                   '~s~, odwieź ją do celu ~g~' ..
                                   worker.clients[routeId].stars .. '★')
        end
    end
end)
RegisterNetEvent('taxiJob:finishRoute', function(routeId)
    local _source = source
    if banCooldown[_source] then
        -- ban
        return
    end
    if Workers[_source] then
        local worker = Workers[_source]
        if worker.clients[routeId] and worker.currentRoadId == routeId then
            local playerPed = GetPlayerPed(_source)
            local playerPos = GetEntityCoords(playerPed)
            local startPos = worker.clients[routeId].start
            local finishPos = worker.clients[routeId].finish
            local distance = #(playerPos - finishPos)

            if distance > 50 then
                print('Cheater id: ' .. _source, ' distance: ' .. distance)
                -- ban
                return
            end

            local client = worker.clients[routeId]

            removeRoute(worker.clients, routeId)
            addRoute(worker.clients)
            
            -- Obliczamy odległości w kilometrach
            local distanceToClient = 0 -- Odległość do klienta
            local distanceToFinish = #(startPos - finishPos) / 1000 -- Odległość do celu w km
            
            -- Obliczamy odległość do klienta na podstawie pozycji gracza przy starcie kursu
            if client.playerStartPos then
                local playerStartVec3 = vector3(client.playerStartPos.x, client.playerStartPos.y, client.playerStartPos.z)
                distanceToClient = #(playerStartVec3 - startPos) / 1000 -- Odległość w km
            else
                -- Fallback: jeśli nie mamy pozycji gracza, zakładamy że dojazd do klienta to ~20% całkowitej odległości
                distanceToClient = distanceToFinish * 0.2
            end
            
            -- Obliczamy czas pracy w minutach
            -- 1.5km = 1 min jazdy w śniegu
            local timeToClient = distanceToClient / Config.Economy.kmPerMinute -- Czas dojazdu do klienta (min)
            local timeToFinish = distanceToFinish / Config.Economy.kmPerMinute -- Czas dojazdu do celu (min)
            local totalTime = timeToClient + timeToFinish -- Całkowity czas pracy (min)
            
            -- Obliczamy płatność na podstawie czasu pracy
            local pay = totalTime * Config.Economy.payPerMinute
            
            -- Mnożnik gwiazdek (opcjonalny bonus)
            local starsMultiplier = 1.0
            if client.stars then
                if client.stars <= 1.5 then
                    starsMultiplier = 0.9
                elseif client.stars <= 2.5 then
                    starsMultiplier = 0.95
                elseif client.stars <= 3.5 then
                    starsMultiplier = 1.0
                elseif client.stars <= 4.5 then
                    starsMultiplier = 1.1
                else
                    starsMultiplier = 1.2
                end
            end
            pay = pay * starsMultiplier

            -- Bonus VIP
            if client.vip then
                pay = pay * 1.3
            end

            -- Zastosuj min/max płatność
            pay = math.max(Config.Economy.minPayment, math.min(Config.Economy.maxPayment, math.floor(pay)))

            local xPlayer = ESX.GetPlayerFromId(_source)
            
            local societyPercentage = Config.SocietyPercentage or 30
            local societyAmount = math.floor(pay * (societyPercentage / 100))
            local playerAmount = pay - societyAmount
            
            xPlayer.addMoney(playerAmount)
            
            if societyAmount > 0 then
                TriggerEvent('esx_addonaccount:getSharedAccount', 'taxi', function(account)
                    if account then
                        account.addMoney(societyAmount)
                    end
                end)
            end
            
            local result = MySQL.single.await('SELECT rankLegalCourses FROM users WHERE identifier = ?', {xPlayer.identifier})
            local currentKursy = result and result.rankLegalCourses or 0
            local newKursy = currentKursy + 1
            MySQL.update.await('UPDATE users SET rankLegalCourses = ? WHERE identifier = ?', {newKursy, xPlayer.identifier})
            
            exports["esx_hud"]:UpdateTaskProgress(_source, "Taxi")
            
            if exports.esx_society then
                pcall(function()
                    if exports.esx_society.UpdatePlayerKursy then
                        exports.esx_society:UpdatePlayerKursy(xPlayer.identifier, 'taxi', newKursy)
                    end
                end)
            end

            TriggerClientEvent('esx:showNotification', _source, 'Zakończyłeś kurs dla ~y~' .. client.name .. '~s~, otrzymałeś ~g~$' .. playerAmount)

            local logMessage = string.format(
                "Gracz %s [%s] zakończył kurs:\n- Klient: %s\n- Gwiazdki: %.1f★\n- VIP: %s\n- Odległość do klienta: %.2f km\n- Odległość do celu: %.2f km\n- Czas pracy: %.2f min\n- Płatność całkowita: $%d\n- Płatność gracza: $%d\n- Płatność społeczeństwa: $%d\n- Całkowita liczba kursów: %d",
                GetPlayerName(_source) or "Nieznany",
                _source,
                client.name,
                client.stars or 0,
                client.vip and "Tak" or "Nie",
                distanceToClient,
                distanceToFinish,
                totalTime,
                pay,
                playerAmount,
                societyAmount,
                newKursy
            )
            exports.esx_core:SendLog(_source, "Zakończenie kursu Taxi", logMessage, 'taxi')
        end
    end
end)

lib.callback.register('taxiJob:getRoutes', function(source)
    if Workers[source] then
        return Workers[source].clients
    else
        return {}
    end
end)

RegisterNetEvent('taxijob:abandonRoute', function()
    local _source = source
    if Workers[_source] then
        local worker = Workers[_source]
        if worker.currentRoadId then
            removeRoute(worker.clients, worker.currentRoadId)
            addRoute(worker.clients)
            worker.currentRoadId = nil
            -- Odśwież trasy dla klienta
            TriggerClientEvent('esx:showNotification', _source,
                               'Porzuciłeś kurs')
            -- Wyślij zaktualizowane trasy
            Wait(100)
            TriggerClientEvent('taxiJob:routesUpdated', _source)
        end
    end
end)

RegisterNetEvent('taxijob:deleteSkin', function(id)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job and xPlayer.job.name == 'taxi' and xPlayer.job.grade >= Config.addClothesGrade then
        MySQL.query.await('DELETE FROM `taxi_clothes` WHERE `id` = ?', {id})
    end
end)

AddEventHandler('onServerResourceStart', function(resourceName)
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        exports.ox_inventory:RegisterStash('taxi_zarzad', 'Szafka Zarządu Taxi', 50, 100000, false, {["taxi"] = 5}) -- Kierownik i wyżej (grade 5+)
        exports.ox_inventory:RegisterStash('taxi_public', 'Publiczna Szafka Taxi', 50, 100000, false, {["taxi"] = 2})
        exports.ox_inventory:RegisterStash('taxi_private', 'Prywatna Szafka Taxi', 50, 100000, true, {["taxi"] = 0})
    end
end)