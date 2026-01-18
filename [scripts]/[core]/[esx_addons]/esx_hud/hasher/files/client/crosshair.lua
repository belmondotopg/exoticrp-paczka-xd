local SendNUIMessage = SendNUIMessage

RegisterNetEvent('esx_hud:showCrosshair', function(state)
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "crosshair",
        visible = state
    })
end)