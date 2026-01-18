local function GetWashingItem(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    for itemName, maxAmount in pairs(Config.WashingItems) do
        if xPlayer.getInventoryItem(itemName).count > 0 then
            return {itemName, maxAmount}
        end
    end

    return nil
end

RegisterServerEvent("exotic_pralnia:wash", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local washingItem = GetWashingItem(src)
    if not washingItem then
        xPlayer.showNotification("Aby przeprać brudną gotówke musisz posiadać przy sobie Bon na Pralnie!")
        return
    end

    local blackMoney = xPlayer.getInventoryItem("black_money").count
    local washAmount = math.min(blackMoney, washingItem[2])

    xPlayer.removeInventoryItem(washingItem[1], 1)
    xPlayer.removeInventoryItem("black_money", washAmount)
    xPlayer.addMoney(washAmount)
end)