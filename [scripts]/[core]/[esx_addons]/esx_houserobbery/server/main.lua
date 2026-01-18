local MySQL = MySQL
local esx_core = exports.esx_core
local esx_hud = exports.esx_hud

local queue = {}
local queueLock = false

local function lockQueue()
	local timeout = 0
	while queueLock do
		Citizen.Wait(10)
		timeout = timeout + 10
		if timeout > 5000 then
			print('[esx_houserobbery] WARNING: lockQueue timeout after 5 seconds, forcing unlock')
			queueLock = false
			break
		end
	end
	queueLock = true
end

local function unlockQueue()
    queueLock = false
end

local function sortQueue()
    table.sort(queue, function(a, b)
        return a.position < b.position
    end)
end

local function updateQueuePositions(alreadyLocked)
	if not alreadyLocked then
		lockQueue()
	end
	for i, v in ipairs(queue) do
		v.position = i
	end
	sortQueue()
	if not alreadyLocked then
		unlockQueue()
	end
end

local function notifyPlayerByLicense(license, callback)
    local xPlayer = ESX.GetPlayerFromIdentifier(license)
    if xPlayer then
        callback(xPlayer)
    end
end

local function removeFromQueue(playerId, license)
    lockQueue()

    local identifier = nil

    if playerId then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            identifier = xPlayer.identifier
        end
    elseif license then
        identifier = license
    end

    if not identifier then
        unlockQueue()
        return
    end

	for i = #queue, 1, -1 do
		local v = queue[i]
		if v.license == identifier then
			table.remove(queue, i)
			notifyPlayerByLicense(v.license, function(xPlayer)
				if v.status == 'waiting' then
					xPlayer.showNotification('Zostałeś usunięty z kolejki!')
				end
				if v.status == 'working' then
					TriggerClientEvent('esx_houserobbery/client/stopMission', xPlayer.source, true)
				end
			end)
			break
		end
	end

	updateQueuePositions(true)

	for _, v in ipairs(queue) do
		if v.status == 'waiting' and v.position == 1 then
			v.status = 'working'
			notifyPlayerByLicense(v.license, function(xPlayer)
				TriggerEvent('esx_houserobbery/server/startMission', xPlayer.source)
				xPlayer.showNotification('Zostałeś przydzielony do zlecenia!')
			end)
			break
		end
	end

	unlockQueue()
end

local function startWorkingTimeout(playerId, license)
    local totalTime = 20 * 60 * 1000
    local elapsed = 0

    while elapsed < totalTime do
        Citizen.Wait(60 * 1000)
        elapsed = elapsed + 60 * 1000

        local remainingMinutes = math.ceil((totalTime - elapsed) / (60 * 1000))
        local xPlayer = ESX.GetPlayerFromIdentifier(license)

        if not xPlayer then
            removeFromQueue(playerId, license)
            return
        end

        local playerState = Player(playerId)
        if not playerState or not playerState.state.usingHouseRobbery then
            removeFromQueue(playerId, license)
            return
        end

        if remainingMinutes > 0 then
            xPlayer.showNotification('Pozostało ' .. remainingMinutes .. ' minut do usunięcia z kolejki i anulowania zlecenia')
        else
            xPlayer.showNotification('Minęło 20 minut, usunięto z kolejki i anulowano zlecenie!')
            removeFromQueue(playerId, license)
            return
        end
    end
end

local function sendQueuePositionUpdate(v, newPos)
    notifyPlayerByLicense(v.license, function(xPlayer)
        xPlayer.showNotification('Według moich informacji twoja pozycja w kolejce uległa zmianie, od teraz jesteś na pozycji ' .. newPos)
    end)
end

RegisterServerEvent('esx_houserobbery/server/joinQueue', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local isVIP = ESX.AddonPlayerDiscordRoles(src, 'VIP') or ESX.AddonPlayerDiscordRoles(src, 'SVIP') or ESX.AddonPlayerDiscordRoles(src, 'ELITE')

    lockQueue()

    for _, v in ipairs(queue) do
        if v.license == xPlayer.identifier then
            unlockQueue()
            xPlayer.showNotification('Znajdujesz się już w kolejce a twoja pozycja to [' .. v.position .. ']!')
            return
        end
    end

    local newPosition = #queue + 1

    if #queue >= Config.MaxWorkingPositions then
        local vipPosition = Config.MaxWorkingPositions
        local vipCount = 0

        for _, v in ipairs(queue) do
            if v.vip then vipCount = vipCount + 1 end
        end

        if vipCount > 0 then
            vipPosition = vipPosition + vipCount
        end

        if isVIP then
            newPosition = vipPosition
            for _, v in ipairs(queue) do
                if v.vip and v.position >= vipPosition then
                    local oldPos = v.position
                    v.position = v.position + 1
                    if v.position > oldPos then
                        sendQueuePositionUpdate(v, v.position)
                    end
                end
            end
        end

        for _, v in ipairs(queue) do
            if not v.vip and v.status == 'waiting' and v.position >= newPosition then
                local oldPos = v.position
                v.position = v.position + 1
                if v.position > oldPos then
                    sendQueuePositionUpdate(v, v.position)
                end
            end
        end
    end

    table.insert(queue, {source = src, license = xPlayer.identifier, position = newPosition, status = 'waiting', vip = isVIP})

    for i, v in ipairs(queue) do
        if v.license == xPlayer.identifier then
            if v.position <= Config.MaxWorkingPositions then
                v.status = 'working'
                TriggerEvent('esx_houserobbery/server/startMission', src)
                xPlayer.showNotification('Dołączono do kolejki, ale z powodu wolnego miejsca otrzymano zlecenie')
                Citizen.CreateThread(function()
                    startWorkingTimeout(src, xPlayer.identifier)
                end)
            else
                xPlayer.showNotification('Dołączono do kolejki, aktualnie zajmujesz miejsce ' .. v.position)
            end

            break
        end
    end

	updateQueuePositions(true)
	unlockQueue()
end)

RegisterServerEvent('esx_houserobbery/server/removeQueue', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end

    removeFromQueue(src)

    local playerState = Player(src)
    if playerState then
        playerState.state.usingHouseRobbery = false
    end
end)

lib.callback.register('esx_houserobbery/server/getPlayerQueue', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local position = 0
    local totalPlayers = #queue

    for _, v in ipairs(queue) do
        if v.license == xPlayer.identifier then
            position = v.position
            break
        end
    end

    return position, totalPlayers
end)

AddEventHandler('playerDropped', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    for i = #queue, 1, -1 do
        local v = queue[i]
        if v.license == xPlayer.identifier then
            if v.status == 'working' then
                local players = esx_hud:Players()
                for _, playerData in pairs(players) do
                    if playerData.job == 'police' or playerData.job == 'sheriff' then
                        TriggerClientEvent('esx_houserobbery/client/removeCopBlip', playerData.id)
                    end
                end
            end

            removeFromQueue(src, xPlayer.identifier)
            break
        end
    end
end)

RegisterServerEvent('esx_houserobbery/server/startMission', function(src)
    local src = src or source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local result = MySQL.single.await('SELECT `missionTier` FROM `esx_houserobbery` WHERE `identifier` = ?', {xPlayer.identifier})

    if not result then
        MySQL.insert.await('INSERT INTO `esx_houserobbery` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 0, 1})
        result = { missionTier = 1 }
    elseif not result.missionTier then
        return
    end

    local playerState = Player(src)
    if playerState then
        playerState.state.usingHouseRobbery = true
    end

    exports["esx_hud"]:UpdateTaskProgress(src, "HouseRobbery")
    TriggerClientEvent("esx_houserobbery/client/startMission", src, result.missionTier or 1)
end)

lib.callback.register('esx_houserobbery/server/getFreeRobSpot', function(source, missionTier)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return nil, nil end

    missionTier = (missionTier and missionTier > 0) and missionTier or 1
    local freeQueue = {}

	for k, v in pairs(Config.Houses[missionTier]) do
		if v.locked == false then
			table.insert(freeQueue, {index = k, data = v})
		end
	end

	if #freeQueue > 0 then
		local randomIndex = math.random(1, #freeQueue)
		local selected = freeQueue[randomIndex]
		return selected.data, missionTier, selected.index
	else
		local firstHouse = Config.Houses[missionTier][1]
		return firstHouse, missionTier, 1
	end
end)

RegisterServerEvent('esx_houserobbery/server/releaseRobSpot', function(mission)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local missionTier = mission.tier or 1
    local missionNumber = mission.number or 1

	if Config.Houses[missionTier] and Config.Houses[missionTier][missionNumber] then
		Config.Houses[missionTier][missionNumber].locked = false
	end

    removeFromQueue(src)

    local playerState = Player(src)
    if playerState then
        playerState.state.usingHouseRobbery = false
    end
end)

function getSpecialisation(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then 
        return 0, 0, 0, 0 
    end

    local result = MySQL.single.await('SELECT `missionsCompleted`, `missionTier` FROM `esx_houserobbery` WHERE `identifier` = ?', {xPlayer.identifier})
    
    if not result then
        MySQL.insert.await('INSERT INTO `esx_houserobbery` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 0, 1})
        result = { missionsCompleted = 0, missionTier = 1 }
    elseif not result.missionsCompleted or not result.missionTier then
        return 0, 0, 0, 0
    end

    local missionsCompleted = result.missionsCompleted
    local missionTier = result.missionTier
    local requiredCount = 0
    local maxCount = 250

    if missionsCompleted < 50 then
        requiredCount = 50
    elseif missionsCompleted < 150 then
        requiredCount = 150
    else
        requiredCount = 250
    end

    return missionsCompleted, requiredCount, missionTier, maxCount
end

lib.callback.register('esx_houserobbery/server/getSpecialisation', function(source)
    return getSpecialisation(source)
end)

exports("getSpecialisation", getSpecialisation)

RegisterServerEvent('esx_houserobbery/server/upgradeLevel', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end

    local result = MySQL.single.await('SELECT `missionsCompleted`, `missionTier` FROM `esx_houserobbery` WHERE `identifier` = ?', {xPlayer.identifier})

    if not result then
        MySQL.insert.await('INSERT INTO `esx_houserobbery` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 0, 1})
        result = { missionsCompleted = 0, missionTier = 1 }
    elseif not result.missionsCompleted or not result.missionTier then
        return
    end

    local missionsCompleted = result.missionsCompleted
    local missionTier = result.missionTier

    if missionTier >= 3 then
        xPlayer.showNotification('Osiągnąłeś już maksymalny poziom specjalizacji!')
        return
    end

    local requiredCount = 250
    if missionsCompleted < 50 then
        requiredCount = 50
    elseif missionsCompleted < 150 then
        requiredCount = 150
    end

    if missionsCompleted >= requiredCount then
        local newTier = missionTier + 1
        MySQL.update.await('UPDATE `esx_houserobbery` SET `missionTier` = ? WHERE `identifier` = ?', {newTier, xPlayer.identifier})
        xPlayer.showNotification('Zwiększono poziom specjalizacji od teraz wynosi on [' .. newTier .. ']')
    end
end)

RegisterServerEvent('esx_houserobbery/server/finishMission', function(mission)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    local missionTier = mission and mission.tier or 1
    local missionNumber = mission and mission.number or 1

    local playerState = Player(src)

    if not playerState or not playerState.state.usingHouseRobbery then return end

    removeFromQueue(src)

	if Config.Houses[missionTier] and Config.Houses[missionTier][missionNumber] then
		Config.Houses[missionTier][missionNumber].locked = false
	end

    playerState.state.usingHouseRobbery = false

    local result = MySQL.single.await('SELECT `missionsCompleted`, `missionTier` FROM `esx_houserobbery` WHERE `identifier` = ?', {xPlayer.identifier})

    local missionsCompleted = 0
    local missionTier = 1
    if result and result.missionsCompleted then
        missionsCompleted = result.missionsCompleted
        missionTier = result.missionTier or 1
        missionsCompleted = missionsCompleted + 1
        MySQL.update.await('UPDATE `esx_houserobbery` SET `missionsCompleted` = ? WHERE `identifier` = ?', {missionsCompleted, xPlayer.identifier})
    else
        MySQL.insert.await('INSERT INTO `esx_houserobbery` (`identifier`, `missionsCompleted`, `missionTier`) VALUES (?, ?, ?)', {xPlayer.identifier, 1, missionTier})
        missionsCompleted = 1
    end

    local requiredCount = 250
    if missionsCompleted < 50 then
        requiredCount = 50
    elseif missionsCompleted < 150 then
        requiredCount = 150
    end

    if missionsCompleted >= requiredCount and missionTier < 3 then
        local newTier = missionTier + 1
        MySQL.update.await('UPDATE `esx_houserobbery` SET `missionTier` = ? WHERE `identifier` = ?', {newTier, xPlayer.identifier})
        xPlayer.showNotification('Zwiększono poziom specjalizacji od teraz wynosi on [' .. newTier .. ']')
    end
end)

RegisterServerEvent('esx_houserobbery/server/onEnterHouse', function (k)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer then
		SetPlayerRoutingBucket(src, k + 250)
		
		if xPlayer.job.name ~= "police" and xPlayer.job.name ~= "ambulance" then
			esx_core:SendLog(src, "Napady na domy", "Rozpoczął `napad na dom` wchodząc do niego\nSkrypt wykonujący: `"..GetCurrentResourceName().."`", "houserobbery")
		end

		MySQL.update.await('UPDATE `users` SET `houseRobbery` = ?, `houseRobberyBucket` = ? WHERE `identifier` = ?', {1, k + 250, xPlayer.identifier})
	end
end)

RegisterServerEvent('esx_houserobbery/server/onExitHouse', function ()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	SetPlayerRoutingBucket(src, 0)

	MySQL.update.await('UPDATE `users` SET `houseRobbery` = ?, `houseRobberyBucket` = ? WHERE `identifier` = ?', {0, 0, xPlayer.identifier})
end)

RegisterServerEvent('esx_houserobbery/server/takeItems', function (houseLevel, playerIndex)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local item = Config.ItemsData[houseLevel][math.random(1, #Config.ItemsData[houseLevel])]
	local random = math.random(1, 100)

    if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
        return
    else
        Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math.random(5, 20))..'-'..math.random(10000,99999))
    end

	if random <= item.chance then
		local itemCount = item.count
		if type(itemCount) == "table" then
			itemCount = math.random(itemCount[1], itemCount[2])
		end
		
		local ox_inventory = exports.ox_inventory
		local itemData = ox_inventory:Items(item.id)
		local itemLabel = (itemData and itemData.label) or item.id
		
		if ox_inventory:AddItem(src, item.id, itemCount) then
			xPlayer.showNotification('Znalazłeś/aś '..itemLabel)
			esx_core:SendLog(src, "Napady na domy", "Otrzymał przedmiot ".. item.id .. " ".. itemCount .. " z `rabunku na dom`\nSkrypt wykonujący: `"..GetCurrentResourceName().."`", "houserobbery")
		end
	else
		xPlayer.showNotification('Nic nie znalazłeś/aś')
	end
end)

RegisterServerEvent('esx_houserobbery/server/addTargets', function (robbingHouse, houseLevel, val)
	local src = source

	Player(src).state.usingHouseRobbery = true

	TriggerClientEvent('esx_houserobbery/client/addTargets', src, robbingHouse, houseLevel)
end)

RegisterServerEvent('esx_houserobbery/server/removeTargets', function ()
    local src = source

	Player(src).state.usingHouseRobbery = false
    TriggerClientEvent('esx_houserobbery/client/removeTargets', src)
end)

RegisterServerEvent("esx_houserobbery/server/onRemoveDurability", function(item)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if not xPlayer then return end
	
	local ox_inventory = exports.ox_inventory
	local search = ox_inventory:Search(src, 'slots', item)

	if search and #search > 0 then
		for k, v in ipairs(search) do
			if v.metadata and v.metadata.durability then
				if v.metadata.durability <= 10 then
					xPlayer.showNotification('Twój przedmiot się zepsuł!')
					ox_inventory:RemoveItem(src, item, 1)
					break
				else
					if k and v.slot then
						ox_inventory:SetDurability(src, v.slot, v.metadata.durability - 10.0)
						break
					end
				end
			end
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local src = playerId
    local identifier = xPlayer.identifier
    local result = MySQL.single.await('SELECT `houseRobbery`, `houseRobberyBucket` FROM `users` WHERE `identifier` = ?', {identifier})

    if result and result.houseRobbery == 1 and result.houseRobberyBucket and result.houseRobberyBucket > 0 then
        SetPlayerRoutingBucket(src, result.houseRobberyBucket)
        TriggerClientEvent('esx:showNotification', src, 'Wróciłeś do rabunku!')
    end
end)

local function HasItemsToSell(source)
    local ox_inventory = exports.ox_inventory

    for ItemName in pairs(Config.Items) do 
        local search = ox_inventory:Search(source, 'slots', ItemName)
        if search and #search > 0 then
            local totalCount = 0
            for _, v in ipairs(search) do
                if v and v.count then
                    totalCount = totalCount + v.count
                end
            end
            if totalCount >= 1 then 
                return true
            end
        end
    end

    return false
end

local function SellItems(source)
    local ox_inventory = exports.ox_inventory
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Najpierw zbierz wszystkie przedmioty do sprzedania
    local itemsToSell = {}
    local FinalPrice = 0
    
    for ItemName, ItemPrice in pairs(Config.Items) do 
        local search = ox_inventory:Search(source, 'slots', ItemName)
        if search and #search > 0 then
            local totalCount = 0
            for _, v in ipairs(search) do
                if v and v.count then
                    totalCount = totalCount + v.count
                end
            end
            if totalCount >= 1 then
                local itemPrice = ItemPrice * totalCount
                table.insert(itemsToSell, {
                    name = ItemName,
                    count = totalCount,
                    price = itemPrice
                })
                FinalPrice = FinalPrice + itemPrice
            end
        end
    end

    if #itemsToSell == 0 or FinalPrice == 0 then
        xPlayer.showNotification('Nie posiadasz żadnych przedmiotów do sprzedania', 'error')
        return
    end

    -- Teraz usuń wszystkie przedmioty
    local removedCount = 0
    local removedPrice = 0
    for _, itemData in ipairs(itemsToSell) do
        local removed = ox_inventory:RemoveItem(source, itemData.name, itemData.count)
        if removed then
            removedCount = removedCount + itemData.count
            removedPrice = removedPrice + itemData.price
        else
            -- Jeśli nie udało się usunąć, nie dodawaj do ceny
            print(string.format('[esx_houserobbery] Nie udało się usunąć przedmiotu %s x%d', itemData.name, itemData.count))
        end
    end

    -- Dodaj brudną gotówkę tylko jeśli udało się usunąć przynajmniej jeden przedmiot
    if removedPrice > 0 then
        local added = ox_inventory:AddItem(source, "black_money", removedPrice)
        if added then
            xPlayer.showNotification(('Sprzedałeś %dx przedmiotów za ~g~$%s~s~ (brudna gotówka)'):format(removedCount, removedPrice))
        else
            xPlayer.showNotification('~r~Błąd: Nie udało się dodać brudnej gotówki! Przedmioty zostały usunięte.', 'error')
            print(string.format('[esx_houserobbery] BŁĄD: Nie udało się dodać black_money (%d) dla gracza %s', removedPrice, source))
        end
    else
        xPlayer.showNotification('~r~Błąd: Nie udało się usunąć przedmiotów!', 'error')
    end
end

lib.callback.register('esx_houserobbery/server/hasItemsToSell', function(source)
	return HasItemsToSell(source)
end)

lib.callback.register('esx_houserobbery/server/getItemsToSell', function(source)
    local ox_inventory = exports.ox_inventory
    local itemsList = {}
    
    for ItemName, ItemPrice in pairs(Config.Items) do 
        local search = ox_inventory:Search(source, 'slots', ItemName)
        if search and #search > 0 then
            local totalCount = 0
            for _, v in ipairs(search) do
                if v and v.count then
                    totalCount = totalCount + v.count
                end
            end
            if totalCount >= 1 then
                local itemData = ox_inventory:Items(ItemName)
                local itemLabel = (itemData and itemData.label) or ItemName
                local totalPrice = ItemPrice * totalCount
                
                table.insert(itemsList, {
                    name = ItemName,
                    label = itemLabel,
                    count = totalCount,
                    price = ItemPrice,
                    totalPrice = totalPrice
                })
            end
        end
    end
    
    return itemsList
end)

local function SellSelectedItems(source, selectedItems)
    local ox_inventory = exports.ox_inventory
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if not selectedItems or #selectedItems == 0 then
        xPlayer.showNotification('Nie wybrano żadnych przedmiotów do sprzedania', 'error')
        return
    end

    local itemsToSell = {}
    local FinalPrice = 0
    
    -- Sprawdź czy gracz ma wszystkie wybrane przedmioty
    for _, itemName in ipairs(selectedItems) do
        if Config.Items[itemName] then
            local search = ox_inventory:Search(source, 'slots', itemName)
            if search and #search > 0 then
                local totalCount = 0
                for _, v in ipairs(search) do
                    if v and v.count then
                        totalCount = totalCount + v.count
                    end
                end
                if totalCount >= 1 then
                    local itemPrice = Config.Items[itemName] * totalCount
                    table.insert(itemsToSell, {
                        name = itemName,
                        count = totalCount,
                        price = itemPrice
                    })
                    FinalPrice = FinalPrice + itemPrice
                end
            end
        end
    end

    if #itemsToSell == 0 or FinalPrice == 0 then
        xPlayer.showNotification('Nie posiadasz wybranych przedmiotów do sprzedania', 'error')
        return
    end

    -- Usuń wybrane przedmioty
    local removedCount = 0
    local removedPrice = 0
    for _, itemData in ipairs(itemsToSell) do
        local removed = ox_inventory:RemoveItem(source, itemData.name, itemData.count)
        if removed then
            removedCount = removedCount + itemData.count
            removedPrice = removedPrice + itemData.price
        else
            print(string.format('[esx_houserobbery] Nie udało się usunąć przedmiotu %s x%d', itemData.name, itemData.count))
        end
    end

    -- Dodaj brudną gotówkę
    if removedPrice > 0 then
        local added = ox_inventory:AddItem(source, "black_money", removedPrice)
        if added then
            xPlayer.showNotification(('Sprzedałeś %dx przedmiotów za ~g~$%s~s~ (brudna gotówka)'):format(removedCount, removedPrice))
        else
            xPlayer.showNotification('~r~Błąd: Nie udało się dodać brudnej gotówki! Przedmioty zostały usunięte.', 'error')
            print(string.format('[esx_houserobbery] BŁĄD: Nie udało się dodać black_money (%d) dla gracza %s', removedPrice, source))
        end
    else
        xPlayer.showNotification('~r~Błąd: Nie udało się usunąć przedmiotów!', 'error')
    end
end

RegisterServerEvent("esx_houserobbery:SellItems", function(selectedItems)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then return end

    -- Jeśli selectedItems jest nil lub pusta tablica, sprzedaj wszystko (stary sposób)
    if selectedItems == nil or (type(selectedItems) == 'table' and #selectedItems == 0) then
        if not HasItemsToSell(src) then 
            xPlayer.showNotification("Nie posiadasz żadnych przedmiotów do sprzedania")
            return
        end
        SellItems(src)
        return
    end

    -- Sprzedaj wybrane przedmioty
    if type(selectedItems) == 'table' and #selectedItems > 0 then
        SellSelectedItems(src, selectedItems)
    else
        xPlayer.showNotification('Błąd: Nieprawidłowe dane wybranych przedmiotów', 'error')
    end
end)