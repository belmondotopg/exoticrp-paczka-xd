RegisterNetEvent("esx_prisons:storeTransaction", function(index, storeIndex, itemIndex)
    local store = Config.Prisons[index].stores[storeIndex]
    local item = store.catalog[itemIndex]
    local required = item.required
    local rewards = item.rewards or {}
    local success, missingItems = CheckRequired(source, required)
    if not success then 
        for i=1, #missingItems do 
            ShowNotification(source, _L("missing_item", missingItems[i].name, missingItems[i].count))
        end
        return
    end
    rewards[#rewards + 1] = {
        type = "item",
        name = item.name,
        amount = item.amount
    }
    
    TakeRequired(source, required)

    local actualTime = Player(source).state.IsJailed
    local newTime = 0

    if actualTime > 30 then
        newTime = actualTime - reward.amount
        Player(source).state.IsJailed = newTime
    else
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then xPlayer.ShowNotification('Nie możesz już bardziej skrócić swojej odsiadki!') end
    end
end)