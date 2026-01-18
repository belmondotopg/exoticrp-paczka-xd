if Config.Framework:upper() ~= 'ESX' then return end

ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(playerData)
    ESX.PlayerData = playerData
    createJobRadial() -- client/editable_functions.lua
end)

RegisterNetEvent('esx:setJob', function(job)
    ESX.PlayerData.job = job
    createJobRadial() -- client/editable_functions.lua
end)

Bridge = {
    getPlayerJob = function()
        local playerJob = ESX.PlayerData.job
        return {
            jobName = playerJob.name,
            jobLabel = playerJob.label,
            jobGrade = tonumber(playerJob.grade),
            jobGradeLabel = playerJob.grade_label
        }
    end,
    getPlayerSkin = function()
        local p = promise.new()
        TriggerEvent('skinchanger:getSkin', function(skin)
            p:resolve(skin)
        end)
        return Citizen.Await(p)
    end
}