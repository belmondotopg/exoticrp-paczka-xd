local Config = require('config.main')
local HeistConfig = Config.Heist

---@param coords vector4
---@param notifyPolice boolean
---@param startedBy number
return function(coords, notifyPolice, startedBy)
    if notifyPolice then
        local dispatchConfig = HeistConfig.dispatch
        if dispatchConfig then
            TriggerClientEvent('qf-mdt/addDispatchAlert', -1,
                coords, dispatchConfig.title or 'Napad na Kontener',
                dispatchConfig.subtitle or '', dispatchConfig.code or '10-90',
                dispatchConfig.color, dispatchConfig.maxReactions or 0)
        end
    end


    local playerList = {}

    local xPlayers = ESX.GetExtendedPlayers()
    for i = 1, #xPlayers do
        local xPlayer = xPlayers[i]
        if exports['op-crime']:getPlayerOrganisation(xPlayer.identifier) then
            playerList[#playerList + 1] = xPlayer.source
        end
    end

    lib.triggerClientEvent('exotic-containers:heistStarted', playerList, coords, startedBy)
end
