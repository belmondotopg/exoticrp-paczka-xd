local resourceName = GetCurrentResourceName()
local timeoutsPath = "./server/scripts/daily/timeouts_dailypremium.json"

local function loadTimeouts()
    local file = LoadResourceFile(resourceName, timeoutsPath)
    if file then
        return json.decode(file) or {}
    else
        return {}
    end
end

local function saveTimeouts(timeouts)
    SaveResourceFile(resourceName, timeoutsPath, json.encode(timeouts), -1)
end

local timeout = loadTimeouts()
CreateThread(function()
    while true do
        Wait(300000)
        saveTimeouts(timeout)
    end
end)

RegisterCommand('dailypremium', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentTime = os.time()
    local hasRank = xPlayer.vip or xPlayer.svip or xPlayer.elite or xPlayer.group == 'founder'

    if not hasRank then
        TriggerClientEvent("esx:showNotification", source, 'Aby móc odebrać nagrodę musisz posiadać rolę VIP / SVIP / ELITE!')
        return
    end

    if not timeout[xPlayer.identifier] or timeout[xPlayer.identifier].exp < currentTime then
        updateEXPRank(xPlayer.identifier, currentTime)
        xPlayer.addInventoryItem('scratchcardpremium', math.random(1, 4))
    else
        local difference = timeout[xPlayer.identifier].exp - currentTime
        TriggerClientEvent("esx:showNotification", xPlayer.source, ('Aby odebrać nagrodę poczekaj jeszcze %d godzin/y'):format(math.floor(difference / 3600)))
    end
end, false)

function updateEXPRank(identifier, currentTime)
    timeout[identifier] = {exp = currentTime + 86400}
    saveTimeouts(timeout)
end