if Config.Framework:upper() ~= 'ESX' then return end

ESX = exports['es_extended']:getSharedObject()

Bridge = {
    getIdentifier = function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            return xPlayer.identifier
        end
    end,
    showNotify = function(playerId, message, type)
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = 'Notification',
            description = message,
            type = type or 'inform'
        })
    end,
    getOfflineName = function(identifier)
        local result = MySQL.single.await('SELECT firstname, lastname FROM users WHERE identifier = ?', {identifier})
        if result then
            return ('%s %s'):format(result.firstname, result.lastname)
        end

        return 'Unknown'
    end,
    getPlayerJob = function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer then
            return {
                jobName = xPlayer.job.name,
                jobLabel = xPlayer.job.label,
                jobGrade = tonumber(xPlayer.job.grade),
                jobGradeLabel = xPlayer.job.grade_label
            }
        end
    end,
}

lib.callback.register('p_dojjob/server/getPlayerSkin', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local row = MySQL.single.await('SELECT skin FROM users WHERE identifier = ?', {xPlayer.identifier})
    return row and json.decode(row.skin) or nil
end)