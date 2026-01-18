local ox_inventory = exports.ox_inventory

local CompanyVehiclesByIdentifier = {}
local CompanyVehiclesBySource = {}

local function getEntityFromNetId(netId)
    if type(netId) ~= "number" or netId <= 0 then return 0 end
    local entity = NetworkGetEntityFromNetworkId(netId)
    return (entity ~= 0 and DoesEntityExist(entity)) and entity or 0
end

function Init()
    local sqlData = MySQL.query.await('SELECT * FROM `businesses`')
    local formatedSqlData = {}

    for _, v in ipairs(sqlData) do
        formatedSqlData[v.name] = v
    end

    local queries = {}

    for jobName, businessData in pairs(Config.Businesses) do
        if not formatedSqlData[jobName] then
            table.insert(queries, { 'INSERT INTO `businesses` (name, label, upgrades, priceLists) VALUES (?, ?, ?, ?)', { jobName, businessData.label, "{}", "{}" } })
        end

        local businessSql = formatedSqlData[jobName]
        Businesses[jobName] = CreateBusiness(jobName, businessData.label, businessSql and businessSql.upgrades or "{}", businessSql and businessSql.priceLists or "{}")
    end

    if #queries > 0 then
        MySQL.transaction.await(queries)
    end
end

function OpenPersonalStash()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local jobName = xPlayer.job.name
    local business = Businesses[jobName]

    if not business then return end

    local upgradeLevel = business.getUpgradeLevel("personalStash")
    local upgradeData = Config.Upgrades.personalStash
    local slots = upgradeData.defaultSlots + (upgradeData.increaseSlots * upgradeLevel)
    local weight = upgradeData.defaultWeight + (upgradeData.increaseWeight * upgradeLevel)

    ox_inventory:RegisterStash("business_" .. jobName, "Prywatna szafka", slots, weight, xPlayer.identifier)
end

function OpenGlobalStash()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]

    if not business then return end

    local businessConfig = Config.Businesses[jobName]
    if xPlayer.job.grade < (businessConfig.globalStash.minGrade or 0) then return end

    local upgradeLevel = business.getUpgradeLevel("globalStash")
    local upgradeData = Config.Upgrades.globalStash
    local slots = upgradeData.defaultSlots + (upgradeData.increaseSlots * upgradeLevel)
    local weight = upgradeData.defaultWeight + (upgradeData.increaseWeight * upgradeLevel)

    ox_inventory:RegisterStash("global_business_" .. jobName, "Szafka firmowa", slots, weight)
end

function GetUpgradesLevels(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return cb({}) end
    
    local business = Businesses[xPlayer.job.name]
    cb(business and business.upgrades or {})
end

function GetUpgradePrices(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return cb({}) end
    
    local business = Businesses[xPlayer.job.name]
    if not business then return cb({}) end

    local prices = {}
    for upgradeName in pairs(Config.Upgrades) do
        prices[upgradeName] = business.getUpgradePrice(upgradeName)
    end

    cb(prices)
end

function CanSpawnCompanyVehicle(playerId, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or (jobName and jobName ~= xPlayer.job.name) then
        return cb(false)
    end

    local identifier = xPlayer.identifier
    local record = CompanyVehiclesByIdentifier[identifier]
    if record and record.netId and getEntityFromNetId(record.netId) ~= 0 then
        return cb(false)
    end
    
    if record then
        CompanyVehiclesByIdentifier[identifier] = nil
    end

    cb(true)
end

function RegisterCompanyVehicle(netId, jobName)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or (jobName and jobName ~= xPlayer.job.name) then return end

    if type(netId) ~= "number" or netId <= 0 then return end

    local entity = getEntityFromNetId(netId)
    if entity == 0 then return end

    local playerPed = GetPlayerPed(playerId)
    if playerPed and playerPed ~= 0 then
        local playerCoords = GetEntityCoords(playerPed)
        local vehicleCoords = GetEntityCoords(entity)
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)
        if playerVehicle ~= entity and #(playerCoords - vehicleCoords) > 10.0 then
            return
        end
    end

    local identifier = xPlayer.identifier
    local existing = CompanyVehiclesByIdentifier[identifier]
    if existing and existing.netId and getEntityFromNetId(existing.netId) ~= 0 then
        if entity ~= 0 then
            DeleteEntity(entity)
        end
        xPlayer.showNotification("Masz już wyciągnięty pojazd firmowy.")
        return
    end

    CompanyVehiclesByIdentifier[identifier] = { netId = netId, job = xPlayer.job.name }
    CompanyVehiclesBySource[playerId] = identifier
end

function CleanupCompanyVehicle(playerId)
    local identifier = CompanyVehiclesBySource[playerId]
    if not identifier then return end

    local record = CompanyVehiclesByIdentifier[identifier]
    if record and record.netId then
        local entity = getEntityFromNetId(record.netId)
        if entity ~= 0 then
            DeleteEntity(entity)
        end
    end

    CompanyVehiclesByIdentifier[identifier] = nil
    CompanyVehiclesBySource[playerId] = nil
end

function DeleteCompanyVehicle()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local identifier = xPlayer.identifier
    local record = CompanyVehiclesByIdentifier[identifier]
    if record and record.netId then
        local entity = getEntityFromNetId(record.netId)
        if entity ~= 0 then
            DeleteEntity(entity)
        end
        CompanyVehiclesByIdentifier[identifier] = nil
        if CompanyVehiclesBySource[playerId] == identifier then
            CompanyVehiclesBySource[playerId] = nil
        end
    end
end

function GetEmployeeLimit(jobName)
    if not Config.Businesses[jobName] then
        return nil
    end
    
    local business = Businesses[jobName]
    if not business then
        return Config.Upgrades.employeeLimit.defaultLimit
    end
    
    local upgradeLevel = business.getUpgradeLevel("employeeLimit")
    local upgradeData = Config.Upgrades.employeeLimit
    return upgradeData.defaultLimit + (upgradeData.increaseLimit * upgradeLevel)
end

function GetCurrentEmployeeCount(jobName)
    if not Config.Businesses[jobName] then
        return nil
    end
    
    local employees = MySQL.query.await([[
        SELECT COUNT(*) as count
        FROM users
        WHERE (job IS NOT NULL AND JSON_VALID(job) = 1 AND JSON_UNQUOTE(JSON_EXTRACT(job, '$.name')) = ?)
           OR (multi_jobs IS NOT NULL AND JSON_VALID(multi_jobs) = 1 AND JSON_CONTAINS_PATH(multi_jobs, 'one', CONCAT('$."', ?, '"')) = 1)
    ]], {jobName, jobName})
    
    return employees and employees[1] and employees[1].count or 0
end

exports('GetEmployeeLimit', GetEmployeeLimit)
exports('GetCurrentEmployeeCount', GetCurrentEmployeeCount)

function Upgrade(upgradeName)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    if type(upgradeName) ~= "string" or not Config.Upgrades[upgradeName] then
        return xPlayer.showNotification("Nieprawidłowe ulepszenie.")
    end

    local businessConfig = Config.Businesses[jobName]
    if xPlayer.job.grade < (businessConfig.bossMenu.minGrade or 0) then return end

    business.upgrade(upgradeName, xPlayer.showNotification)
end

function OrderIngredients(deliveryType, ingredients)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    local businessConfig = Config.Businesses[jobName]
    if xPlayer.job.grade < (businessConfig.orderingIngredients.minGrade or 0) then return end

    if business.duringDelivery then
        return xPlayer.showNotification("Dostawa jest już zlecona.")
    end

    if deliveryType ~= "fast" and deliveryType ~= "normal" then
        return xPlayer.showNotification("Nieprawidłowy typ dostawy.")
    end

    if type(ingredients) ~= "table" then
        return xPlayer.showNotification("Nieprawidłowe dane zamówienia.")
    end

    local validIngredients = {}
    local allowedIngredients = businessConfig.orderingIngredients.ingredients
    local allowedSet = {}
    for _, ing in ipairs(allowedIngredients) do
        allowedSet[ing] = true
    end

    for itemName, count in pairs(ingredients) do
        if type(itemName) == "string" and type(count) == "number" and allowedSet[itemName] then
            count = math.floor(count)
            if count > 0 and count <= 100 then
                validIngredients[itemName] = count
            end
        end
    end

    if not next(validIngredients) then
        return xPlayer.showNotification("Nie wybrano żadnych składników.")
    end

    business.duringDelivery = true
    business.orderIngredients(playerId, validIngredients, deliveryType, xPlayer.showNotification)
end


function Cook(playerId, cb, dishName)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or type(dishName) ~= "string" then
        return cb(false)
    end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then
        return cb(false)
    end

    local businessConfig = Config.Businesses[jobName]
    local cookingData = businessConfig and businessConfig.cooking
    
    if not cookingData or not cookingData.dishes or not cookingData.dishes[dishName] then
        return cb(false)
    end

    if xPlayer.job.grade < (cookingData.minGrade or 0) then
        return cb(false)
    end

    if not business.activeCourses[playerId] then
        business.activeCourses[playerId] = {
            productsMade = 0,
            startTime = os.time(),
            productsDelivered = false
        }
    end

    local course = business.activeCourses[playerId]
    
    if not course.productsDelivered then
        xPlayer.showNotification("Najpierw musisz dostarczyć produkty do kuchni.")
        return cb(false)
    end
    if course.productsMade >= 5 then
        xPlayer.showNotification("Ukończyłeś już kurs! Zakończ go, aby otrzymać wynagrodzenie.")
        return cb(false)
    end

    business.cook(playerId, dishName)
    cb(true)
end

function SuccessCook()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    local businessConfig = Config.Businesses[jobName]
    local cookingData = businessConfig.cooking
    if xPlayer.job.grade < (cookingData.minGrade or 0) then return end

    local currentDish = business.cookingPlayers[playerId]
    if not currentDish then return end

    local dish = cookingData.dishes[currentDish]
    if not dish then return end

    local course = business.activeCourses[playerId]
    if not course then
        business.cook(playerId, nil)
        return
    end
    
    if course.productsMade >= 5 then
        business.cook(playerId, nil)
        return xPlayer.showNotification("Ukończyłeś już kurs! Zakończ go, aby otrzymać wynagrodzenie.")
    end
    
    local stashName = "business_" .. jobName .. "_dishes"
    ox_inventory:RegisterStash(stashName, "Szafka na gotowe dania", 40, 400000)
    ox_inventory:AddItem(stashName, currentDish, 1)

    course.productsMade = course.productsMade + 1
    MySQL.update.await('UPDATE users SET rankFoodProduced = rankFoodProduced + 1 WHERE identifier = ?', {xPlayer.identifier})

    if course.productsMade >= 5 then
        CompleteCourse(playerId)
    else
        xPlayer.showNotification(("Wytworzono produkt! Postęp kursu: %d/5"):format(course.productsMade))
    end

    business.cook(playerId, nil)
end

function GetCourseProgress(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return cb(nil) end

    local business = Businesses[xPlayer.job.name]
    if not business then return cb(nil) end

    local course = business.activeCourses[playerId]
    if not course then return cb(nil) end

    cb({
        productsMade = course.productsMade,
        totalRequired = 5
    })
end

function CompleteCourse(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    local course = business.activeCourses[playerId]
    if not course then return end

    local businessConfig = Config.Businesses[jobName]
    local grade = xPlayer.job.grade or 0
    local reward = 9000 + (grade * math.random(100, 200))
    local playerReward = reward
    local companyReward = math.floor(reward * 0.35)
    
    xPlayer.addMoney(playerReward)
    
    local account = exports["esx_addonaccount"]:GetSharedAccount(businessConfig.account)
    if account then
        account.addMoney(companyReward)
    end
    
    TriggerClientEvent("exotic_businesses:courseCompleted", playerId)
    xPlayer.showNotification(("Kurs ukończony! Otrzymujesz $%s. Firma otrzymała $%s."):format(playerReward, companyReward))
    
    -- Usuń kurs - gracz nie może dalej produkować bez nowych produktów
    -- Gdy dostarczy nowe produkty, zostanie utworzony nowy kurs z productsDelivered = true
    business.activeCourses[playerId] = nil
    business.cookingPlayers[playerId] = nil
end

function OpenDishesStash()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local jobName = xPlayer.job.name

    if not Businesses[jobName] then
        return
    end

    ox_inventory:RegisterStash("business_" .. jobName .. "_dishes", "Szafka na gotowe dania", 40, 400000)
end

function OpenTray()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local jobName = xPlayer.job.name

    if not Businesses[jobName] then
        return
    end

    ox_inventory:RegisterStash("business_" .. jobName .. "_tray", "Tacka", 40, 100000)
end

function IssueAnInvoice(price, description)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    local businessConfig = Config.Businesses[jobName]
    if xPlayer.job.grade < (businessConfig.tray.minGrade or 0) then return end

    if business.activeBill.price then
        return xPlayer.showNotification("Jest już wystawiony rachunek.")
    end

    if type(price) ~= "number" or price < 1 or price > 20000 then
        return xPlayer.showNotification("Nieprawidłowa kwota rachunku.")
    end

    if type(description) ~= "string" then
        description = ""
    end

    if #description > 500 then
        description = string.sub(description, 1, 500)
    end

    business.issueAnInvoice(playerId, math.floor(price), description)
    xPlayer.showNotification("Pomyślnie wystawiono rachunek.")
end

function ShowTheBill(playerId, cb, jobName)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or type(jobName) ~= "string" or not Businesses[jobName] then
        return cb(false)
    end

    if jobName == xPlayer.job.name then
        return cb(false)
    end

    local business = Businesses[jobName]
    if not business.activeBill.price then
        xPlayer.showNotification("Nie ma żadnego rachunku do opłacenia.")
        return cb(false)
    end

    cb(business.activeBill)
end

function TakeTheBill(jobName, payMethod)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or type(jobName) ~= "string" or not Businesses[jobName] then
        return
    end

    if jobName == xPlayer.job.name then
        return xPlayer.showNotification("Nie możesz opłacić rachunku w swojej własnej firmie.")
    end

    if payMethod ~= "money" and payMethod ~= "bank" then
        return xPlayer.showNotification("Nieprawidłowa metoda płatności.")
    end

    local business = Businesses[jobName]
    if not business.activeBill.price then
        return xPlayer.showNotification("Nie ma żadnego rachunku do opłacenia.")
    end

    local priceForEmployee = business.activeBill.price * 0.65
    local priceForSociety = business.activeBill.price * 0.35

    local account = xPlayer.getAccount(payMethod)
    if not account or account.money < business.activeBill.price then
        return xPlayer.showNotification(account and "Nie masz wystarczająco pieniędzy." or "Nieprawidłowa metoda płatności.")
    end

    xPlayer.removeAccountMoney(payMethod, business.activeBill.price)

    local businessConfig = Config.Businesses[jobName]
    local societyAccount = exports["esx_addonaccount"]:GetSharedAccount(businessConfig.account)
    local xEmployee = ESX.GetPlayerFromId(business.activeBill.playerId)

    if xEmployee then
        xEmployee.addMoney(priceForEmployee)
        xEmployee.showNotification(("Klient [ID: %s] opłacił rachunek. Otrzymujesz $%s prowizji."):format(playerId, priceForEmployee))
    end

    societyAccount.addMoney(priceForSociety)

    local items = ox_inventory:GetInventoryItems("business_" .. jobName .. "_tray")
    business.clearTheBill()

    if type(items) == "table" then
        for _, v in ipairs(items) do
            if v.name and v.count and v.count > 0 then
                ox_inventory:RemoveItem("business_" .. jobName .. "_tray", v.name, v.count)
                ox_inventory:AddItem(playerId, v.name, v.count)
            end
        end
    end

    xPlayer.showNotification(("Pomyślnie opłacono rachunek za $%s."):format(business.activeBill.price))
end

function UseItem(playerId, cb, durability)
    if type(durability) ~= "number" or durability <= 0 then
        return cb(0)
    end
    
    local currentTime = os.time()
    if durability <= currentTime then
        return cb(0)
    end
    
    cb(math.max(0, (durability - currentTime) / 86400))
end

function GetDishesStashCount(playerId, cb, dishName)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or type(dishName) ~= "string" then
        return cb(0)
    end

    local jobName = xPlayer.job.name
    if not Businesses[jobName] then
        return cb(0)
    end

    local stashName = "business_" .. jobName .. "_dishes"
    local items = ox_inventory:GetInventoryItems(stashName)
    
    local count = 0
    if type(items) == "table" then
        for _, item in ipairs(items) do
            if item.name == dishName and item.count and item.count > 0 then
                count = count + item.count
            end
        end
    end

    cb(count)
end

function GetPriceLists(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return cb({}) end
    
    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return cb({}) end

    cb(business.priceLists)
end

function PlacePriceList(text, coords)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    if type(text) ~= "string" or #text < 1 or #text > 2000 then
        return xPlayer.showNotification("Nieprawidłowy tekst cennika.")
    end

    if type(coords) ~= "table" or type(coords.x) ~= "number" or type(coords.y) ~= "number" or type(coords.z) ~= "number" then
        return xPlayer.showNotification("Nieprawidłowe współrzędne.")
    end

    if math.abs(coords.x) > 10000 or math.abs(coords.y) > 10000 or math.abs(coords.z) > 10000 then
        return xPlayer.showNotification("Nieprawidłowe współrzędne.")
    end

    if #business.priceLists >= 2 then
        return xPlayer.showNotification("Nie możesz postawić więcej cenników.")
    end

    business.placePriceList(text, coords, xPlayer.showNotification)
end

function DeletePriceList(text, coords)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    if type(text) ~= "string" or #text < 1 or #text > 2000 then
        return xPlayer.showNotification("Nieprawidłowy tekst cennika.")
    end

    if type(coords) ~= "table" or type(coords.x) ~= "number" or type(coords.y) ~= "number" or type(coords.z) ~= "number" then
        return xPlayer.showNotification("Nieprawidłowe współrzędne.")
    end

    if math.abs(coords.x) > 10000 or math.abs(coords.y) > 10000 or math.abs(coords.z) > 10000 then
        return xPlayer.showNotification("Nieprawidłowe współrzędne.")
    end

    business.deletePriceList(text, coords, xPlayer.showNotification)
end

function UpdatePriceList(text, coords, newText)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]
    if not business then return end

    if type(text) ~= "string" or #text < 1 or #text > 2000 then
        return xPlayer.showNotification("Nieprawidłowy tekst cennika.")
    end

    if type(newText) ~= "string" or #newText < 1 or #newText > 2000 then
        return xPlayer.showNotification("Nieprawidłowy nowy tekst cennika.")
    end

    business.updatePriceList(text, coords, newText, xPlayer.showNotification)
end

function LoadPriceLists(playerId, cb)
    local priceLists = {}
    for name, business in pairs(Businesses) do
        priceLists[name] = business.priceLists
    end
    cb(priceLists)
end

function CollectProducts()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]

    if not business then return end

    local businessConfig = Config.Businesses[jobName]
    if not businessConfig or not businessConfig.collectProducts then return end

    if business.collectedProducts then
        return xPlayer.showNotification("Produkty zostały już zebrane.")
    end

    business.collectedProducts = true
    xPlayer.showNotification("Produkty zostały zebrane. Udaj się do punktu dostarczania.")
end

function CheckProductsStatus(playerId, cb)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return cb(false, false)
    end

    local business = Businesses[xPlayer.job.name]
    if not business then
        return cb(false, false)
    end

    local course = business.activeCourses[playerId]
    local productsDelivered = course and course.productsDelivered or false
    
    cb(business.collectedProducts or false, productsDelivered)
end

function DeliverProducts()
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end

    local jobName = xPlayer.job.name
    local business = Businesses[jobName]

    if not business then return end

    local businessConfig = Config.Businesses[jobName]
    if not businessConfig or not businessConfig.deliverProducts then return end

    if not business.collectedProducts then
        return xPlayer.showNotification("Najpierw musisz zebrać produkty.")
    end

    business.collectedProducts = false
    
    -- Ustaw flagę productsDelivered dla tego gracza w jego kursie
    if not business.activeCourses[playerId] then
        business.activeCourses[playerId] = {
            productsMade = 0,
            startTime = os.time(),
            productsDelivered = true
        }
    else
        business.activeCourses[playerId].productsDelivered = true
    end
    
    xPlayer.showNotification("Produkty zostały dostarczone. Możesz teraz udać się do kuchni.")
end

function GetCompanyOutfits(playerId, cb, businessName, sex)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return cb({}) end
    
    local jobName = xPlayer.job.name
    if businessName and businessName ~= jobName then
        return cb({})
    end
    
    local response = MySQL.query.await(
        'SELECT `id`, `skin`, `name` FROM `business_clothes` WHERE `business` = ? AND `sex` = ?',
        {jobName, sex}
    )
    
    cb(response or {})
end

function AddCompanyOutfit(name, skin, sex)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    local jobName = xPlayer.job.name
    local businessConfig = Config.Businesses[jobName]
    if not businessConfig then return end
    
    local minGrade = businessConfig.wardrobe.addClothesGrade or businessConfig.bossMenu.minGrade or 5
    if xPlayer.job.grade < minGrade then
        return xPlayer.showNotification("Nie masz uprawnień do dodawania strojów.")
    end
    
    MySQL.insert.await(
        'INSERT INTO `business_clothes` (business, name, skin, sex) VALUES (?, ?, ?, ?)',
        {jobName, name, json.encode(skin), sex}
    )
    
    xPlayer.showNotification(("Pomyślnie dodano strój: %s"):format(name))
end

function DeleteCompanyOutfit(outfitId)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    local jobName = xPlayer.job.name
    local businessConfig = Config.Businesses[jobName]
    if not businessConfig then return end
    
    local minGrade = businessConfig.wardrobe.addClothesGrade or businessConfig.bossMenu.minGrade or 5
    if xPlayer.job.grade < minGrade then
        return xPlayer.showNotification("Nie masz uprawnień do usuwania strojów.")
    end
    
    local outfit = MySQL.single.await('SELECT business FROM `business_clothes` WHERE `id` = ?', {outfitId})
    if not outfit or outfit.business ~= jobName then
        return xPlayer.showNotification("Nie znaleziono stroju.")
    end
    
    MySQL.query.await('DELETE FROM `business_clothes` WHERE `id` = ?', {outfitId})
    xPlayer.showNotification("Pomyślnie usunięto strój.")
end
