Businesses = {}

CreateThread(function()
    local columnExists = MySQL.single.await([[
        SELECT COUNT(*) as count 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'users' 
        AND COLUMN_NAME = 'rankFoodProduced'
    ]])
    
    if not columnExists or columnExists.count == 0 then
        MySQL.query.await([[
            ALTER TABLE `users` 
            ADD COLUMN `rankFoodProduced` INT NOT NULL DEFAULT 0;
        ]])
    end
    
    local tableExists = MySQL.single.await([[
        SELECT COUNT(*) as count 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'business_clothes'
    ]])
    
    if not tableExists or tableExists.count == 0 then
        MySQL.query.await([[
            CREATE TABLE IF NOT EXISTS `business_clothes` (
                `id` INT(11) NOT NULL AUTO_INCREMENT,
                `business` VARCHAR(50) NOT NULL,
                `name` VARCHAR(255) NOT NULL,
                `skin` TEXT NOT NULL,
                `sex` VARCHAR(10) NOT NULL,
                PRIMARY KEY (`id`),
                INDEX `business_sex` (`business`, `sex`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]])
    end
end)

MySQL.ready(Init)

RegisterNetEvent("exotic_businesses:openPersonalStash", OpenPersonalStash)
RegisterNetEvent("exotic_businesses:openGlobalStash", OpenGlobalStash)
RegisterNetEvent("exotic_businesses:upgrade", Upgrade)
RegisterNetEvent("exotic_businesses:orderIngredients", OrderIngredients)
RegisterNetEvent("exotic_businesses:successCook", SuccessCook)
RegisterNetEvent("exotic_businesses:openDishesStash", OpenDishesStash)
RegisterNetEvent("exotic_businesses:openTray", OpenTray)
RegisterNetEvent("exotic_businesses:issueAnInvoice", IssueAnInvoice)
RegisterNetEvent("exotic_businesses:takeTheBill", TakeTheBill)
RegisterNetEvent("exotic_businesses:placePriceList", PlacePriceList)
RegisterNetEvent("exotic_businesses:deletePriceList", DeletePriceList)
RegisterNetEvent("exotic_businesses:updatePriceList", UpdatePriceList)
RegisterNetEvent("exotic_businesses:collectProducts", CollectProducts)
RegisterNetEvent("exotic_businesses:deliverProducts", DeliverProducts)
RegisterNetEvent("exotic_businesses:addCompanyOutfit", AddCompanyOutfit)
RegisterNetEvent("exotic_businesses:deleteCompanyOutfit", DeleteCompanyOutfit)
RegisterNetEvent("exotic_businesses:registerCompanyVehicle", RegisterCompanyVehicle)
RegisterNetEvent("exotic_businesses:deleteCompanyVehicle", DeleteCompanyVehicle)

ESX.RegisterServerCallback("exotic_businesses:checkProductsStatus", CheckProductsStatus)
ESX.RegisterServerCallback("exotic_businesses:getCourseProgress", GetCourseProgress)
ESX.RegisterServerCallback("exotic_businesses:getUpgradesLevels", GetUpgradesLevels)
ESX.RegisterServerCallback("exotic_businesses:getUpgradePrices", GetUpgradePrices)
ESX.RegisterServerCallback("exotic_businesses:cook", Cook)
ESX.RegisterServerCallback("exotic_businesses:getCompanyOutfits", GetCompanyOutfits)
ESX.RegisterServerCallback("exotic_businesses:canSpawnCompanyVehicle", CanSpawnCompanyVehicle)
ESX.RegisterServerCallback("exotic_businesses:showTheBill", ShowTheBill)
ESX.RegisterServerCallback("exotic_businesses:useItem", UseItem)
ESX.RegisterServerCallback("exotic_businesses:getPriceLists", GetPriceLists)
ESX.RegisterServerCallback("exotic_businesses:loadPriceLists", LoadPriceLists)
ESX.RegisterServerCallback("exotic_businesses:getDishesStashCount", GetDishesStashCount)

AddEventHandler("playerDropped", function()
    local playerId = source
    CleanupCompanyVehicle(playerId)
    
    for _, business in pairs(Businesses) do
        if business.activeCourses then
            business.activeCourses[playerId] = nil
        end
        if business.cookingPlayers then
            business.cookingPlayers[playerId] = nil
        end
    end
end)
