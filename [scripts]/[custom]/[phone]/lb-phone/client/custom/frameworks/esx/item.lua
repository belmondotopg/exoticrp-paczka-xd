if Config.Framework ~= "esx" then
    return
end

while not ESX do
    Wait(500)
    debugprint("Item: Waiting for ESX to load")
end

---@param itemName string
---@return boolean
function HasItem(itemName)
    if GetResourceState("ox_inventory") == "started" then
        return (exports.ox_inventory:Search("count", itemName) or 0) > 0
    elseif GetResourceState("qs-inventory") == "started" then
        return (exports["qs-inventory"]:Search(itemName) or 0) > 0
    end

    if ESX.SearchInventory then
        return (ESX.SearchInventory(itemName, 1) or 0) > 0
    end

    local inventory = ESX.GetPlayerData()?.inventory

    if not inventory then
        infoprint("warning", "Unsupported inventory, tell the inventory author to add support for it.")
        return false
    end

    debugprint("inventory", inventory)

    for i = 1, #inventory do
        local item = inventory[i]

        if item.name == itemName and item.count > 0 then
            return true
        end
    end

    return false
end

RegisterNetEvent("esx:removeInventoryItem", function(item, count)
    -- Extract item name if item is a table, otherwise use it directly
    local itemName = type(item) == "table" and item.name or (type(item) == "string" and item or nil)
    
    -- Extract count, ensuring it's always a number
    local itemCount = 0
    if type(item) == "table" then
        itemCount = type(item.count) == "number" and item.count or (type(count) == "number" and count or 0)
    elseif type(count) == "number" then
        itemCount = count
    end
    
    -- Ensure itemName is valid before comparing
    if not itemName or type(itemName) ~= "string" then
        return
    end
    
    if not Config.Item.Require or Config.Item.Unique or itemName ~= Config.Item.Name or itemCount > 0 then
        return
    end

    Wait(500)

    if not HasPhoneItem() then
        OnDeath()
    end
end)
