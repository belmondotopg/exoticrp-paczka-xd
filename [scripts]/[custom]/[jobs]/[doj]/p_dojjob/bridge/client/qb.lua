if Config.Framework:upper() ~= 'QB' then return end

QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Player:SetPlayerData', function(playerData)
    QBCore.PlayerData = playerData
    createJobRadial() -- client/editable_functions.lua
end)

Bridge = {
    getPlayerJob = function()
        local playerJob = QBCore.PlayerData.job
        if not playerJob then
            return {
                jobName = 'unemployed',
                jobLabel = 'Unemployed',
                jobGrade = 0,
                jobGradeLabel = 'Unemployed'
            }
        end
        
        return {
            jobName = playerJob.name,
            jobLabel = playerJob.label,
            jobGrade = tonumber(playerJob.grade.level),
            jobGradeLabel = playerJob.grade.name
        }
    end,
    getPlayerSkin = function()
        local skin = lib.callback.await('p_dojjob/server/getPlayerSkin', false)
        return skin
    end
}