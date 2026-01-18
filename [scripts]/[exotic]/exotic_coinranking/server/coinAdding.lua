functions.timeToAddCoins = function()
    for _, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent("esx:showNotification", playerId, "Otrzymałeś monetę za czas gry!")
        functions.addCoins(playerId, 1)
    end
end

CreateThread(function()
    while true do
        Wait(3600000)
        functions.timeToAddCoins()
    end
end)