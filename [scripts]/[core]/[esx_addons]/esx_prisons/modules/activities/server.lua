local ActivityPlayers = {}

function GetActivityStatus(source)
    return ActivityPlayers[source]
end

function StopActivity(source, sendEvent)
    local status = GetActivityStatus(source)
    ActivityPlayers[source] = nil
    if sendEvent then
        ShowNotification(source, _L("activity_stopped"))
        TriggerClientEvent("esx_prisons:stopActivity", source, status)
    end
end

function StartNextSection(source, index, activityIndex, lastSection)
    local prison = Config.Prisons[index]
    local activity = prison.activities[activityIndex]
    local activityCfg = Config.Activities[activity.name]

    if lastSection and activityCfg.sections[activity.sections[lastSection].name].rewards and activityCfg.sections[activity.sections[lastSection].name].rewards.amount then
        local newTime = 0
        local xPlayer = ESX.GetPlayerFromId(source)

        if Prisoners[source].time > 30 then
            newTime = Prisoners[source].time - activityCfg.sections[activity.sections[lastSection].name].rewards.amount
            Prisoners[source].time = newTime
            if xPlayer then xPlayer.showNotification('Skrócono czas odsiadki o '..activityCfg.sections[activity.sections[lastSection].name].rewards.amount..'!') end
        else
            local xPlayer = ESX.GetPlayerFromId(source)
            if xPlayer then xPlayer.showNotification('Nie możesz już bardziej skrócić swojej odsiadki!') end
        end
    end

    local section = lastSection
    
    if activity.randomSection then 
        if #activity.sections > 1 then
            repeat 
                section = math.random(1, #activity.sections)
            until section ~= lastSection
        else
            section = 1
        end
    elseif not section or section + 1 > #activity.sections then
        section = 1
    else
        section = section + 1
    end

    return  {
        index = index,
        activityIndex = activityIndex,
        section = section
    }
end 

RegisterCallback("esx_prisons:startActivity", function(source, cb, index, activityIndex) 
    local status = GetActivityStatus(source)
    local needStop = (status and true or false)
    
    if status then 
        StopActivity(source)
    end

    ShowNotification(source, _L("activity_started"))

    ActivityPlayers[source] = StartNextSection(source, index, activityIndex)
    cb(ActivityPlayers[source], needStop)
end)

RegisterCallback("esx_prisons:startNextSection", function(source, cb) 
    local status = GetActivityStatus(source)
    if not status then return end
    ActivityPlayers[source] = StartNextSection(source, status.index, status.activityIndex, status.section)
    cb(ActivityPlayers[source])
end)

RegisterNetEvent("esx_prisons:stopActivity", function() 
    local source = source
    StopActivity(source, true)
end)