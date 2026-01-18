local GetRegisteredCommands = GetRegisteredCommands
local IsPlayerAceAllowed = IsPlayerAceAllowed
local GetPlayerName = GetPlayerName

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:init')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:messageEntered')
RegisterNetEvent('chat:clear')

local initializedPlayers = {}

AddEventHandler('chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end

    local src = source
    if not src or src < 1 then
        return
    end

    TriggerEvent('chatMessage', src, author, message)
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local src = source
    
    if not src or src < 1 then
        return
    end

    local name = GetPlayerName(src)
    if not name then
        return
    end

    TriggerEvent('chatMessage', src, name, '/' .. command)
end)

local function refreshCommands(player)
    if not player or player < 1 then
        return
    end

    if not GetRegisteredCommands then
        return
    end

    local registeredCommands = GetRegisteredCommands()
    if not registeredCommands then
        return
    end

    local suggestions = {}

    for _, command in ipairs(registeredCommands) do
        if command and command.name then
            local hasPermission = IsPlayerAceAllowed(player, ('command.%s'):format(command.name))
            
            if hasPermission then
                suggestions[#suggestions + 1] = {
                    name = '/' .. command.name,
                    help = command.description or ''
                }
            end
        end
    end

    TriggerClientEvent('chat:addSuggestions', player, suggestions)
end

local function initializePlayerChat(playerId)
    if not playerId or playerId < 1 then return end
    if initializedPlayers[playerId] then return end
    
    initializedPlayers[playerId] = true
    TriggerEvent('__chat:requestSuggestions', playerId)
    refreshCommands(playerId)
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    SetTimeout(1000, function()
        initializePlayerChat(playerId)
    end)
end)

AddEventHandler('chat:init', function()
    local src = source
    if not src or src < 1 then
        return
    end
    
    SetTimeout(500, function()
        initializePlayerChat(src)
    end)
end)

AddEventHandler('playerConnecting', function()
    local src = source
    if not src or src < 1 then
        return
    end
    
    SetTimeout(2000, function()
        initializePlayerChat(src)
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if src then
        initializedPlayers[src] = nil
    end
end)
