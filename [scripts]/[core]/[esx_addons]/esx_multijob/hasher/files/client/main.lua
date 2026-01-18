ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

local function CloseJobMenuNUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'setVisible', data = false })
end

local function tableCount(t)
    if not t or type(t) ~= 'table' then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

local function normalizeMultiJobs(multiJobs)
    if type(multiJobs) == 'string' then
        local ok, decoded = pcall(json.decode, multiJobs)
        if ok and type(decoded) == 'table' then
            return decoded
        end
        return {}
    end
    return type(multiJobs) == 'table' and multiJobs or {}
end

local function buildNuiJobs(multiJobs)
    if not multiJobs or tableCount(multiJobs) == 0 then
        return {}
    end

    local currentJob = (ESX.PlayerData.job and ESX.PlayerData.job.name) or nil
    local nuiJobs = {}

    for jobName, data in pairs(multiJobs) do
        if type(data) == 'table' then
            local grade = data.grade or 0
            local gradeLabel = (data.gradeLabel and #data.gradeLabel > 0) and data.gradeLabel or ('Stopień ' .. tostring(grade))
            
            nuiJobs[#nuiJobs + 1] = {
                icon = '',
                jobLabel = data.label or tostring(jobName),
                gradeLabel = gradeLabel,
                jobName = tostring(jobName),
                jobGrade = tostring(grade),
                current = jobName == currentJob
            }
        end
    end

    return nuiJobs
end

local function OpenJobMenu()
    if not ESX.PlayerData then
        ESX.ShowNotification('Błąd: Dane gracza nie są załadowane.')
        return
    end

    local multiJobs = normalizeMultiJobs(ESX.PlayerData.multi_jobs)
    
    if tableCount(multiJobs) == 0 then
        ESX.ShowNotification('Nie masz żadnych prac.')
        return
    end

    local nuiJobs = buildNuiJobs(multiJobs)
    
    if #nuiJobs == 0 then
        ESX.ShowNotification('Nie masz żadnych prac.')
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'setLegalJobs', data = nuiJobs })
    SendNUIMessage({ action = 'setVisible', data = true })
end

RegisterNetEvent('esx_multijob/updateJobs', function(multiJobs)
    if not ESX.PlayerData then
        ESX.PlayerData = {}
    end

    ESX.PlayerData.multi_jobs = normalizeMultiJobs(multiJobs)
    local nuiJobs = buildNuiJobs(ESX.PlayerData.multi_jobs)
    
    SendNUIMessage({ action = 'setLegalJobs', data = nuiJobs })
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
    if Job then
        ESX.PlayerData.job = Job
        TriggerServerEvent('esx_multijob:requestUpdateJobs')
    end
end)

exports('OpenJobMenu', OpenJobMenu)
RegisterNetEvent('esx_multijob:openJobMenu', OpenJobMenu)

RegisterNUICallback('confirmJob', function(data, cb)
    if data and data.jobName then
        TriggerServerEvent('esx_multijob/switchJob', data.jobName)
        CloseJobMenuNUI()
    end
    cb('ok')
end)

RegisterNUICallback('leaveJob', function(data, cb)
    if data and data.jobName then
        local multiJobs = normalizeMultiJobs(ESX.PlayerData.multi_jobs)
        local jobData = multiJobs[data.jobName]
        local jobLabel = jobData and jobData.label or data.jobName
        
        local result = lib.alertDialog({
            header = 'Usuwanie pracy',
            content = 'Czy na pewno chcesz całkowicie opuścić pracę **' .. jobLabel .. '**? Możesz to przegapić!',
            centered = true,
            cancel = true,
            labels = {
                confirm = 'Tak, opuść',
                cancel = 'Anuluj'
            }
        })
        
        if result == 'confirm' then
            TriggerServerEvent('esx_multijob/removeJob', data.jobName)
        end
    end
    cb('ok')
end)

RegisterNUICallback('leaveCurrentJob', function(data, cb)
    if data and data.jobName then
        TriggerServerEvent('esx_multijob/leaveCurrentJob', data.jobName)
        CloseJobMenuNUI()
    end
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(_, cb)
    CloseJobMenuNUI()
    cb('ok')
end)