if Config.Framework:upper() ~= 'QB' then return end

QBCore = exports['qb-core']:GetCoreObject()

Bridge = {
    getIdentifier = function(playerId)
        local xPlayer = QBCore.Functions.GetPlayer(playerId)
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
        local player = QBCore.Functions.GetPlayer(playerId)
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
    local Player = QBCore.Functions.GetPlayer(source)
    local result = MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
    return result and json.decode(result.skin) or nil
end)