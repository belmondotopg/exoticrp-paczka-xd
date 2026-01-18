if Config.Framework:upper() ~= 'QBOX' then return end

Bridge = {
    getIdentifier = function(playerId)
        local xPlayer = exports['qbx_core']:GetPlayer(playerId)
        if xPlayer then
            return xPlayer.PlayerData.citizenid
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
        local result = MySQL.single.await([[
            SELECT JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.firstname")) AS firstname, 
            JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.lastname")) AS lastname FROM players WHERE citizenid = ?
        ]], {identifier})
        if result then
            return ('%s %s'):format(result.firstname, result.lastname)
        end

        return 'Unknown'
    end,
    getPlayerJob = function(playerId)
        local player = exports['qbx_core']:GetPlayer(playerId)
        if player then
            return {
                jobName = player.PlayerData.job.name,
                jobLabel = player.PlayerData.job.label,
                jobGrade = tonumber(player.PlayerData.job.grade.level),
                jobGradeLabel = player.PlayerData.job.grade.name
            }
        end
    end,
}

lib.callback.register('p_dojjob/server/getPlayerSkin', function(source)
    local Player = exports['qbx_core']:GetPlayer(source)
    local result = MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
    return result and json.decode(result.skin) or nil
end)