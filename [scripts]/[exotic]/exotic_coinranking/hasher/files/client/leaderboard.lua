functions.startLeaderboardUpdate = function()
    CreateThread(function()
        Wait(1000)
        while true do
            ESX.TriggerServerCallback('vwk/exoticrp/getLeaderboard', function(leaderboard)
                SendNUIMessage({
                    eventName = "exoticrp/request/leaderboard",
                    payload = {
                        leaderboard = leaderboard
                    }
                })
            end)
            Wait(60000)
        end
    end)
end
