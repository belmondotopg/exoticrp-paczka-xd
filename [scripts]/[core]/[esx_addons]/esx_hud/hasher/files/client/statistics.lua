local cached = nil
local lastFetch = 0
local REFRESH_INTERVAL = 5000

local function fetchStatistics()
    if cached and (GetGameTimer() - lastFetch < REFRESH_INTERVAL) then
        return cached
    end
    
    local data = lib.callback.await("esx_hud/getPlayerStatistics", false)

    if (not data) then
        ESX.ShowNotification("Nie udało się załadować statystyk")
        return nil
    end

    cached = data
    lastFetch = GetGameTimer()
    
    return cached
end

exports("openStatisticsMenu", function()
    local data = fetchStatistics()
    if (not data) then
        ESX.ShowNotification("Nie udało się załadować statystyk")
    end

    SendNUIMessage({
        eventName = "openStatisticsMenu",
        statistics = data
    })

    SetNuiFocus(true, true)
end)

RegisterNUICallback("closeStatisticsMenu", function(data, cb)
    SetNuiFocus(false, false)
    print("closeStatisticsMenu")
    cb("ok")
end)