ESX = exports['es_extended']:getSharedObject()

local MySQL = MySQL
local PlayerIdentifiers = {}
local jobCache = {}
local cooldowns = {}
local COOLDOWN_TIME = 5
local SYNC_DELAY = 200

local function EnsureJobsLoaded()
    local jobs = ESX.GetJobs()
    if jobs and next(jobs) ~= nil then
        return true
    end

    local retries = 0
    local maxRetries = 10
    
    while retries < maxRetries do
        Citizen.Wait(1000)
        jobs = ESX.GetJobs()
        if jobs and next(jobs) ~= nil then
            return true
        end
        retries = retries + 1
    end
    
    return false
end

MySQL.ready(function()
    MySQL.Async.execute([[
        ALTER TABLE `users`
        ADD COLUMN IF NOT EXISTS `multi_jobs` TEXT
    ]], {}, function()
        Citizen.Wait(1000)
        ESX.RefreshJobs()
        Citizen.Wait(2000)
        EnsureJobsLoaded()
    end)
end)

local function GetJobLabels(job, grade)
    if not job or type(job) ~= 'string' or #job == 0 then
        return nil, nil
    end
    
    if not grade or type(grade) ~= 'number' then
        return nil, nil
    end

    local jobLabel = ESX.GetJobLabelFromName(job)
    local gradeLabel = ESX.GetGradeLabel(job, grade)
    
    return jobLabel, gradeLabel
end

local function SaveJobData(identifier, multiJobs)
    if not identifier or not multiJobs then
        return
    end

    jobCache[identifier] = multiJobs
    
    local ok, jsonData = pcall(json.encode, multiJobs)
    if not ok or not jsonData then
        return
    end

    MySQL.Async.execute([[
        UPDATE `users`
        SET `multi_jobs` = ?
        WHERE `identifier` = ?
    ]], { jsonData, identifier }, function() end)
end

local function LoadJobData(identifier, cb)
    if not identifier or not cb then
        if cb then cb({}) end
        return
    end

    if jobCache[identifier] then
        cb(jobCache[identifier])
        return
    end

    MySQL.Async.fetchScalar([[
        SELECT `multi_jobs`
        FROM `users`
        WHERE `identifier` = ?
    ]], { identifier }, function(result)
        if result and type(result) == 'string' and #result > 0 then
            local ok, data = pcall(json.decode, result)
            if ok and type(data) == 'table' then
                jobCache[identifier] = data
                cb(data)
                return
            end
        end
        
        jobCache[identifier] = {}
        cb({})
    end)
end

local function checkCooldown(source, actionName)
    if not source or not actionName then
        return false
    end

    if not cooldowns[source] then
        cooldowns[source] = {}
    end

    local lastTime = cooldowns[source][actionName] or 0
    local currentTime = os.time()
    
    if (currentTime - lastTime) < COOLDOWN_TIME then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.showNotification('Odczekaj chwilę zanim ponownie wykonasz tę akcję.')
        end
        return false
    end

    cooldowns[source][actionName] = currentTime
    return true
end

local function SyncCurrentJob(xPlayer)
    if not xPlayer or not xPlayer.identifier then
        return
    end

    if not xPlayer.job or not xPlayer.job.name then
        return
    end

    local identifier = xPlayer.identifier
    local multiJobs = jobCache[identifier] or {}
    local currentJob = xPlayer.job.name

    for jobName, jobData in pairs(multiJobs) do
        if type(jobData) == 'table' then
            jobData.current = (jobName == currentJob)
        end
    end

    jobCache[identifier] = multiJobs
    xPlayer.set('multi_jobs', multiJobs)
    SaveJobData(identifier, multiJobs)
    TriggerClientEvent('esx_multijob/updateJobs', xPlayer.source, multiJobs)
end

local function SyncCurrentJobDelayed(xPlayer)
    if not xPlayer then
        return
    end
    Citizen.SetTimeout(SYNC_DELAY, function()
        SyncCurrentJob(xPlayer)
    end)
end

local function validateJobName(jobName)
    if not jobName then
        return false
    end
    jobName = tostring(jobName)
    return #jobName > 0
end

local function validatePlayerAndJob(source, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil, false
    end
    
    if not validateJobName(jobName) then
        xPlayer.showNotification('Niepoprawna nazwa pracy!')
        return xPlayer, false
    end
    
    return xPlayer, true
end

ESX.RegisterCommand('setjob', { 'founder', 'developer', 'managment', 'headadmin', 'admin' }, function(xPlayer, args, showError)
    local targetId = args.id
    local job = tostring(args.job or '')
    local grade = tonumber(args.grade)
    
    local target = ESX.GetPlayerFromId(targetId)
    if not target then
        if showError then
            showError('Gracz o takim ID nie istnieje.')
        end
        return
    end
    
    if not validateJobName(job) then
        if showError then
            showError('Niepoprawna nazwa pracy.')
        end
        return
    end
    
    if not grade then
        if showError then
            showError('Niepoprawny stopień pracy.')
        end
        return
    end
    
    local jobLabel, gradeLabel = GetJobLabels(job, grade)
    if not jobLabel or not gradeLabel then
        if showError then
            showError('Niepoprawny stopień pracy.')
        end
        return
    end
    
    target.setJob(job, grade)
    
    local identifier = target.identifier
    local multiJobs = jobCache[identifier] or {}
    multiJobs[job] = {
        grade = grade,
        label = jobLabel,
        gradeLabel = gradeLabel
    }
    jobCache[identifier] = multiJobs
    
    SyncCurrentJobDelayed(target)
    target.showNotification('Praca ustawiona: ' .. jobLabel .. ' (' .. gradeLabel .. ')')
end, true, {
    help = "Ustawianie pracy gracza",
    validate = true,
    arguments = {
        { name = "id", help = "ID gracza", type = "playerId" },
        { name = "job", help = "Nazwa pracy", type = "string" },
        { name = "grade", help = "Stopień pracy", type = "number" }
    }
})

RegisterServerEvent('esx_multijob/switchJob', function(jobName)
    local src = source
    local xPlayer, isValid = validatePlayerAndJob(src, jobName)
    if not isValid then
        return
    end
    
    if not checkCooldown(src, 'switchJob') then
        return
    end
    
    local multiJobs = jobCache[xPlayer.identifier] or {}
    local jobData = multiJobs[jobName]
    
    if not jobData or type(jobData) ~= 'table' then
        xPlayer.showNotification('Nie posiadasz tej pracy!')
        return
    end
    
    xPlayer.setJob(jobName, jobData.grade or 0)
    SyncCurrentJobDelayed(xPlayer)
    xPlayer.showNotification('Zmieniono pracę na ' .. (jobData.label or jobName) .. ' - ' .. (jobData.gradeLabel or ''))
end)

RegisterServerEvent('esx_multijob/addJob', function(jobName, gradeRaw)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        return
    end
    
    local grade = tonumber(gradeRaw)
    if not validateJobName(jobName) or not grade then
        xPlayer.showNotification('Niepoprawne dane pracy!')
        return
    end
    
    if not checkCooldown(src, 'addJob') then
        return
    end
    
    local multiJobs = jobCache[xPlayer.identifier] or {}
    if multiJobs[jobName] then
        xPlayer.showNotification('Posiadasz już tę pracę!')
        return
    end
    
    local jobLabel, gradeLabel = GetJobLabels(jobName, grade)
    if not jobLabel or not gradeLabel then
        xPlayer.showNotification('Niepoprawne dane pracy!')
        return
    end
    
    multiJobs[jobName] = {
        grade = grade,
        label = jobLabel,
        gradeLabel = gradeLabel
    }
    jobCache[xPlayer.identifier] = multiJobs
    
    SyncCurrentJobDelayed(xPlayer)
    xPlayer.showNotification('Dodano pracę: ' .. jobLabel .. ' - ' .. gradeLabel)
end)

RegisterServerEvent('esx_multijob/removeJob', function(jobName)
    local src = source
    local xPlayer, isValid = validatePlayerAndJob(src, jobName)
    if not isValid then
        return
    end
    
    if not checkCooldown(src, 'removeJob') then
        return
    end
    
    local multiJobs = jobCache[xPlayer.identifier] or {}
    if not multiJobs[jobName] then
        xPlayer.showNotification('Nie posiadasz tej pracy!')
        return
    end
    
    multiJobs[jobName] = nil
    jobCache[xPlayer.identifier] = multiJobs
    
    SyncCurrentJobDelayed(xPlayer)
    xPlayer.showNotification('Usunięto pracę: ' .. tostring(jobName))
end)

RegisterServerEvent('esx_multijob/leaveCurrentJob', function(jobName)
    local src = source
    local xPlayer, isValid = validatePlayerAndJob(src, jobName)
    if not isValid then
        return
    end
    
    local multiJobs = jobCache[xPlayer.identifier] or {}
    if not multiJobs[jobName] then
        xPlayer.showNotification('Nie posiadasz tej pracy!')
        return
    end
    
    if multiJobs['unemployed'] then
        xPlayer.setJob('unemployed', multiJobs['unemployed'].grade or 0)
        SyncCurrentJobDelayed(xPlayer)
        xPlayer.showNotification('Praca została zwolniona. Jesteś bezrobotny.')
        return
    end
    
    local found = false
    for jobKey, jobData in pairs(multiJobs) do
        if jobKey ~= jobName and type(jobData) == 'table' then
            xPlayer.setJob(jobKey, jobData.grade or 0)
            found = true
            break
        end
    end
    
    if found then
        SyncCurrentJobDelayed(xPlayer)
        xPlayer.showNotification('Praca została zwolniona.')
    else
        xPlayer.showNotification('Brak innej pracy do ustawienia.')
    end
end)

AddEventHandler('esx:playerLoaded', function(source, xPlayer)
    if not xPlayer or not xPlayer.identifier then
        return
    end

    PlayerIdentifiers[source] = xPlayer.identifier
    
    LoadJobData(xPlayer.identifier, function(multiJobs)
        if multiJobs then
            jobCache[xPlayer.identifier] = multiJobs
            SyncCurrentJobDelayed(xPlayer)
        end
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifier = PlayerIdentifiers[src]
    
    if identifier then
        local multiJobs = jobCache[identifier] or {}
        SaveJobData(identifier, multiJobs)
        jobCache[identifier] = nil
        PlayerIdentifiers[src] = nil
    end
    
    cooldowns[src] = nil
end)

exports('SaveJobData', SaveJobData)

RegisterNetEvent('esx_multijob:requestUpdateJobs', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then
        return
    end
    
    TriggerClientEvent('esx_multijob/updateJobs', src, jobCache[xPlayer.identifier] or {})
end)