if Config.CustomInventory ~= "ox" then return end

MySQL.ready(function()
    TriggerEvent("__cfx_export_ox_inventory_Items", function(ref)
        if ref then
            ESX.Items = ref()
        end
    end)

    AddEventHandler("ox_inventory:itemList", function(items)
        ESX.Items = items
    end)
end)

---@diagnostic disable-next-line: duplicate-set-field
ESX.GetItemLabel = function(item)
    item = exports.ox_inventory:Items(item)
    if item then
        return item.label
    end
end

function setPlayerInventory(playerId, xPlayer, inventory, isNew)
    exports.ox_inventory:setPlayerInventory(xPlayer, inventory)
end
