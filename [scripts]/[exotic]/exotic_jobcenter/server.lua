local cooldowns = {}

local blJobs = { "ambulance", "bahama_mamas", "beanmachine", "doj", "ec", "mechanik", "mexicana", "pearl", "pizza", "police", "psycholog", "sheriff", "uwucafe", "taxi", "whitewidow" }

lib.callback.register('exotic_jobcenter/workApply', function(source, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentTime = os.time()

    if cooldowns[source] and currentTime - cooldowns[source] < 2 then
        return false
    end

    cooldowns[source] = currentTime

    if not xPlayer then return false end
    if xPlayer.job.name == jobName then return false end

    for _, blacklistedJob in pairs(blJobs) do
        if blacklistedJob == jobName then
            local reason = 'Tried to get a job Blacklisted job'
            exports["ElectronAC"]:banPlayer(source, tostring(reason))
            return
        end
    end

    for k, v in pairs(Config.Peds) do
        if #(GetEntityCoords(GetPlayerPed(source)) - v.coords) < 5 then
            local multiJobs = xPlayer.get('multi_jobs') or {}

            xPlayer.showNotification('Zatrudniłeś/aś się pomyślnie!')

            if multiJobs[jobName] then return true end

            local grade = 0

            multiJobs[jobName] = {
                grade = grade,
                label = ESX.GetJobLabelFromName(jobName),
                gradeLabel = ESX.GetGradeLabel(jobName, grade)
            }

            xPlayer.setJob(jobName, grade)
            xPlayer.set('multi_jobs', multiJobs)

            exports['esx_multijob']:SaveJobData(xPlayer.identifier, multiJobs)
            TriggerClientEvent('esx_multijob/updateJobs', xPlayer.source, multiJobs)

            return true
        end
	end

    return false
end)