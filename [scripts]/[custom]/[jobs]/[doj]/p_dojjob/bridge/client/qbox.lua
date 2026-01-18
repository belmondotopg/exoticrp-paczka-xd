if Config.Framework:upper() ~= 'QBOX' then return end

RegisterNetEvent('QBCore:Player:SetPlayerData', function()
    createJobRadial() -- client/editable_functions.lua
end)

Bridge = {
    getPlayerJob = function()
        local playerData = exports['qbx_core']:GetPlayerData()
        if not playerData or not playerData.job then
            return {jobName = 'unemployed', jobLabel = 'Unemployed', jobGrade = 0, jobGradeLabel = 'Unemployed'}
        end
        
        return {
            jobName = playerData.job.name,
            jobLabel = playerData.job.label,
            jobGrade = playerData.job.grade.level,
            jobGradeLabel = playerData.job.grade.name
        }
    end,
    getPlayerSkin = function()
        local skin = lib.callback.await('p_dojjob/server/getPlayerSkin', false)
        return skin
    end
}