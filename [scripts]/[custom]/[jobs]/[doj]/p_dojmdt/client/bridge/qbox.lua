if GetResourceState('qbx_core') ~= 'started' then return end

Bridge = {
    getPlayerJob = function()
        local playerData = exports['qbx_core']:GetPlayerData()
        return {
            jobName = playerData.job.name,
            jobLabel = playerData.job.label,
            jobGrade = playerData.job.grade.level,
            jobGradeLabel = playerData.job.grade.name
        }
    end,    
}