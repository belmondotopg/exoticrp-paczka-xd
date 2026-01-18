if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer) ESX.PlayerData = xPlayer end)
RegisterNetEvent('esx:setJob', function(job) ESX.PlayerData.job = job end)

Bridge = {
    getPlayerJob = function()
        return {
            jobName = ESX.PlayerData.job.name,
            jobLabel = ESX.PlayerData.job.label,
            jobGrade = ESX.PlayerData.job.grade,
            jobGradeLabel = ESX.PlayerData.job.grade_label
        }
    end,    
}

RegisterKeyMapping('dojmdt', 'Otwórz MDT Doj', 'keyboard', 'DELETE')