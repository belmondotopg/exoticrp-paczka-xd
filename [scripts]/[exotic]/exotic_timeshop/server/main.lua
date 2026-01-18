local players = {}
local steamIdentifiers = {}

---@param source integer
---@return string
local function getPlayerSteamIdentifier(source)
    local cached = steamIdentifiers[tostring(source)]
    
    if (cached) then
        return cached
    end
    
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if (string.sub(id, 1, 6) == "steam:") then
            steamIdentifiers[tostring(source)] = id
            return id
        end
    end
end

local function updatePlayerCoins()
    for playerId, lastTimestamp in pairs(players) do
        local diff = os.time() - lastTimestamp

        if (diff < Config.Interval) then
            return print("otrzyma kaske za " .. Config.Interval - diff .. " sekund")
        end

        local steamIdentifier = getPlayerSteamIdentifier(tonumber(playerId))
        MySQL.update.await("UPDATE timecoins SET coins = coins + ? WHERE identifier = ?", { 100, steamIdentifier })
    end
end

CreatThread(function()
    while true do
        Wait(3000)
        updatePlayerCoins()
    end
end)