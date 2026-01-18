function CreateBusiness(name, label, upgrades, priceLists)
    local self = {}

    self.name = name
    self.label = label
    self.upgrades = json.decode(upgrades)
    self.priceLists = json.decode(priceLists)

    self.duringDelivery = false
    self.cookingPlayers = {}
    self.activeBill = {}
    self.collectedProducts = false
    self.productsDelivered = false
    self.activeCourses = {}

    self.getUpgradeLevel = function(upgradeName)
        return self.upgrades[upgradeName] or 0
    end

    self.upgrade = function(upgradeName, showNotification)
        local upgradeConfig = Config.Upgrades[upgradeName]
        if not upgradeConfig then
            return showNotification("Wystąpił nieoczkiwany błąd!")
        end

        local currentLevel = self.upgrades[upgradeName] or 0
        if currentLevel >= upgradeConfig.maxLevel then
            return showNotification("Firma posiada maksymalny level tego ulepszenia.")
        end

        local price = self.getUpgradePrice(upgradeName)
        local account = exports["esx_addonaccount"]:GetSharedAccount(Config.Businesses[self.name].account)

        if account.money < price then
            return showNotification(("Na koncie firmowym nie ma wystarczająco środków. Wymagane: $%s"):format(price))
        end

        account.removeMoney(price)
        self.upgrades[upgradeName] = currentLevel + 1

        local affectedRows = MySQL.update.await('UPDATE businesses SET upgrades = ? WHERE name = ?', {
            json.encode(self.upgrades), self.name
        })

        if affectedRows == 0 then
            return showNotification("Wystąpił nieoczkiwany błąd!")
        end

        showNotification(("Pomyślnie zakupiono ulepszenie! Poziom: %d/%d"):format(self.upgrades[upgradeName], upgradeConfig.maxLevel))
    end
    
    self.getUpgradePrice = function(upgradeName)
        local upgradeConfig = Config.Upgrades[upgradeName]
        if not upgradeConfig then return 0 end
        
        local currentLevel = self.upgrades[upgradeName] or 0
        if currentLevel >= upgradeConfig.maxLevel then return 0 end
        
        local price = upgradeConfig.basePrice
        for i = 1, currentLevel do
            price = math.floor(price * 1.3)
        end
        
        return price
    end

    self.orderIngredients = function(playerId, ingredients, deliveryType, showNotification)
        if type(ingredients) ~= "table" then
            return showNotification("Nieprawidłowe dane zamówienia.")
        end

        local account = exports["esx_addonaccount"]:GetSharedAccount(Config.Businesses[self.name].account)
        local orderingIngredients = Config.Businesses[self.name].orderingIngredients
        local totalIngredientsCount = 0

        for _, v in pairs(ingredients) do
            if type(v) == "number" and v > 0 then
                totalIngredientsCount = totalIngredientsCount + v
            end
        end

        if totalIngredientsCount == 0 then
            return showNotification("Nie wybrano żadnych składników.")
        end

        local defaultPrice = totalIngredientsCount * orderingIngredients.priceForOneIngredient
        local ingredientsPrice = deliveryType == "fast" and math.floor(defaultPrice * 1.25) or defaultPrice

        if account.money < ingredientsPrice then
            return showNotification(("Na koncie firmowym nie ma wystarczająco środków. Brakuje $%s."):format(ingredientsPrice - account.money))
        end

        local upgradeLevel = self.getUpgradeLevel("globalStash")
        local upgradeData = Config.Upgrades.globalStash
        local stashName = "global_business_" .. self.name

        exports.ox_inventory:RegisterStash(stashName, "Magazyn firmowy", upgradeData.defaultSlots + (upgradeData.increaseSlots * upgradeLevel), upgradeData.defaultWeight + (upgradeData.increaseWeight * upgradeLevel))

        for itemName, itemCount in pairs(ingredients) do
            if itemCount > 0 and not exports.ox_inventory:CanCarryItem(stashName, itemName, itemCount) then
                return showNotification("W magazynie nie ma wystarczająco miejsca.")
            end
        end

        account.removeMoney(ingredientsPrice)
        
        if deliveryType == "fast" then
            showNotification("Dostawa została zlecona! Kurier dostarczy ją do 30 minut.")

            CreateThread(function()
                Wait(Config.Debug and 1 or math.random(10000, 30000))

                for itemName, itemCount in pairs(ingredients) do
                    if itemCount > 0 then
                        exports.ox_inventory:AddItem(stashName, itemName, itemCount)
                    end
                end

                showNotification("Kurier przywiózł dostawe!")
                self.duringDelivery = false
            end)
        else
            local deliveryStashName = "delivery_point_business_" .. self.name
            exports.ox_inventory:RegisterStash(deliveryStashName, "Magazyn", 200, 500000)

            for itemName, itemCount in pairs(ingredients) do
                if itemCount > 0 then
                    exports.ox_inventory:AddItem(deliveryStashName, itemName, itemCount)
                end
            end

            showNotification("Produkty czekają w hurtowni.")
            self.duringDelivery = false
        end
    end

    self.cook = function(playerId, dish)
        self.cookingPlayers[playerId] = dish
    end

    self.issueAnInvoice = function(playerId, price, description)
        if self.activeBill.price then return end

        self.activeBill = { playerId = playerId, price = price, description = description, timestamp = os.time() }

        CreateThread(function()
            Wait(60000)

            local xPlayer = ESX.GetPlayerFromId(playerId)
            if not xPlayer then
                if self.activeBill.playerId == playerId then
                    self.activeBill = {}
                end
                return
            end

            if self.activeBill.playerId == playerId and self.activeBill.price == price and self.activeBill.description == description then
                self.activeBill = {}
                xPlayer.showNotification("Rachunek nie został opłacony przez 60 sekund. Zamówienie anulowane, zabierz jedzenie z tacki.")
            end
        end)
    end

    self.clearTheBill = function()
        self.activeBill = {}
    end

    self.endDelivery = function()
        self.duringDelivery = false
    end

    self.placePriceList = function(text, coords, showNotification)
        table.insert(self.priceLists, { coords = coords, text = text })

        local affectedRows = MySQL.update.await('UPDATE businesses SET priceLists = ? WHERE name = ?', {
            json.encode(self.priceLists), self.name
        })

        if affectedRows == 0 then
            return showNotification("Wystąpił nieoczkiwany błąd!")
        end

        TriggerClientEvent("exotic_businesses:loadPriceLists", -1, self.name, self.priceLists)

        showNotification("Pomyślnie postawiono cennik.")
    end

    self.updatePriceList = function(text, coords, newText, showNotification)
        local coordsVec = vec3(coords.x, coords.y, coords.z)

        for i, v in ipairs(self.priceLists) do
            if v.text == text and #(vec3(v.coords.x, v.coords.y, v.coords.z) - coordsVec) < 1.0 then
                self.priceLists[i].text = newText

                local affectedRows = MySQL.update.await('UPDATE businesses SET priceLists = ? WHERE name = ?', {
                    json.encode(self.priceLists), self.name
                })

                if affectedRows == 0 then
                    return showNotification("Wystąpił nieoczkiwany błąd!")
                end

                TriggerClientEvent("exotic_businesses:loadPriceLists", -1, self.name, self.priceLists)
                showNotification("Zmieniono cennik.")
                return
            end
        end

        showNotification("Wystąpił nieoczkiwany błąd!")
    end

    self.deletePriceList = function(text, coords, showNotification)
        local coordsVec = vec3(coords.x, coords.y, coords.z)

        for i = #self.priceLists, 1, -1 do
            local v = self.priceLists[i]
            if v and v.text == text and #(vec3(v.coords.x, v.coords.y, v.coords.z) - coordsVec) < 1.0 then
                table.remove(self.priceLists, i)

                local affectedRows = MySQL.update.await('UPDATE businesses SET priceLists = ? WHERE name = ?', {
                    json.encode(self.priceLists), self.name
                })

                if affectedRows == 0 then
                    return showNotification("Wystąpił nieoczkiwany błąd!")
                end

                TriggerClientEvent("exotic_businesses:loadPriceLists", -1, self.name, self.priceLists)
                showNotification("Usunięto cennik.")
                return
            end
        end

        showNotification("Wystąpił nieoczkiwany błąd!")
    end

    return self
end
