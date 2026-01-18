if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val) QBCore.PlayerData = val end)

Bridge = {
    getPlayerJob = function()
        return {
            jobName = QBCore.PlayerData.job.name,
            jobLabel = QBCore.PlayerData.job.label,
            jobGrade = QBCore.PlayerData.job.grade.level,
            jobGradeLabel = QBCore.PlayerData.job.grade.name
        }
    end,    
}