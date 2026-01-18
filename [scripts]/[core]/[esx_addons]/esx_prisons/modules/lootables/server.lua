Lootables = {}

function UpdateLootables(source)
    TriggerClientEvent("esx_prisons:setLootables", source, Lootables)
end

RegisterNetEvent("esx_prisons:collectLootable", function(index, lootID)
    local source = source
    if Lootables[index] and Lootables[index][lootID] then 
        local loot = Lootables[index][lootID]
        if (os.time() - loot.lastRedeem > loot.regenTime) then
            Lootables[index][lootID].lastRedeem = os.time()

            local actualTime = Player(source).state.IsJailed
            local newTime = 0

            if actualTime > 30 then
                newTime = actualTime - reward.amount
                Player(source).state.IsJailed = newTime
            else
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer then xPlayer.ShowNotification('Nie możesz już bardziej skrócić swojej odsiadki!') end
            end

            TriggerClientEvent("esx_prisons:lootStatus", -1, index, lootID, false)
            SetTimeout(1000 * loot.regenTime, function()
                TriggerClientEvent("esx_prisons:lootStatus", -1, index, lootID, true)
            end)
        end
    end
end)

for k,v in pairs(Config.Prisons) do
    Lootables[k] = v
    for i=1, #v.lootables do 
        Lootables[k][i] = {
            label = v.lootables[i].label,
            coords = v.lootables[i].coords,
            heading = v.lootables[i].heading,
            model = v.lootables[i].model,
            rewards = v.lootables[i].rewards,
            regenTime = v.lootables[i].regenTime,
            lastRedeem = 0
        }
    end
end