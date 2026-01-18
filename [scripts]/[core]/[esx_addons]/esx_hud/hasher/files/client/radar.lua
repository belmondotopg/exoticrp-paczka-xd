local SendNUIMessage = SendNUIMessage

RegisterNetEvent('esx_hud:updateRadarInfo', function(position, model, plate, speed)
    if model == nil then return end

    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "police-radar-data",
        data = {
            plate = plate,
            model = model,
            speed = speed,
            owner = ""
        }
    })
end)

RegisterNetEvent('esx_hud:freezeRadar', function(status)
    SendNUIMessage({
        eventName = "nui:police-radar:freeze",
        freeze = status
    })
end)

local lastStatus = false

RegisterNetEvent('esx_hud:showRadar', function(status)
    if lastStatus == status then return end

    lastStatus = status

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "police-radar",
        visible = status
    })
end)