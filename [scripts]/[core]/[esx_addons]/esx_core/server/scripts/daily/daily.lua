local resourceName = GetCurrentResourceName()
local timeoutsPath = "./server/scripts/daily/timeouts.json"

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

local timeoutsdaily = loadTimeouts()
CreateThread(function()
    while true do
        Wait(300000)
        saveTimeouts(timeoutsdaily)
    end
end)

RegisterCommand('daily', function(source, args, rawCommand)
    local playerName = GetPlayerName(source):lower()
    if not playerName:find('exotic') then
        TriggerClientEvent("esx:showNotification", source, 'Aby móc odebrać nagrodę musisz posiadać fraze serwera w nicku')
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentTime = os.time()

    if not timeoutsdaily[xPlayer.identifier] then
        updateEXP(xPlayer.identifier, currentTime)
        xPlayer.addInventoryItem('scratchcardbasic', math.random(1, 2))
    elseif timeoutsdaily[xPlayer.identifier].exp < currentTime then
        updateEXP(xPlayer.identifier, currentTime)
        xPlayer.addInventoryItem('scratchcardbasic', math.random(1, 2))
    else
        local difference = timeoutsdaily[xPlayer.identifier].exp - currentTime
        TriggerClientEvent("esx:showNotification", xPlayer.source, ('Aby odebrać nagrodę poczekaj jeszcze %d godzin/y'):format(math.floor(difference / 3600)))
    end
end, false)

function updateEXP(identifier, currentTime)
    timeoutsdaily[identifier] = {exp = currentTime + 86400}
    saveTimeouts(timeoutsdaily)
end