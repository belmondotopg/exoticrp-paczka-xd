ESX.RegisterServerCallback('vwk/exoticrp/getLeaderboard', function(source, cb)
    local results = MySQL.query.await('SELECT name, coins FROM timecoins ORDER BY coins DESC LIMIT 10', {})
    local leaderboard = {}
    for i = 1, #results do
        leaderboard[i] = {
            id = i,
            name = results[i].name or "vowki",
            coins = results[i].coins or 0
        }
    end
    cb(leaderboard)
end)
