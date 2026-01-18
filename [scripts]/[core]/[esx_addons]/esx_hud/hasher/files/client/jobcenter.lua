local function toggleJobCenterVisibility(state, jobs)
    if state then
        SendNUIMessage({
            eventName = "nui:data:update",
            dataId = "job-offers",
            data = jobs
        })
    end

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "job-center",
        visible = state
    })

    SetNuiFocus(state, state)
end

RegisterNUICallback("nui:visible:close", function(data, cb) 
    if (data["elementId"] == "job-center") then
        SetNuiFocus(false, false)
        cb(true)
    end 
end)

RegisterNUICallback('job-offers:apply', function (data, cb)
    exports.exotic_jobcenter:workApply(data)
    cb('ok')
end)

RegisterNUICallback('job-offers:set-waypoint', function (data, cb)
    exports.exotic_jobcenter:setWaypoint(data)
    cb('ok')
end)

RegisterNUICallback('job-center:close', function (data, cb)
    toggleJobCenterVisibility(false)
    cb('ok')
end)

exports('toggleJobCenterVisibility', toggleJobCenterVisibility)