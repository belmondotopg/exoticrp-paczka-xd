local SendNUIMessage = SendNUIMessage

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
	ESX.PlayerData.job = Job

    TriggerServerEvent('esx_hud:updateBodycam')
end)

RegisterNetEvent('esx_hud:showBodycam', function(data)
    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "bodycam-data",
        data = data
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "bodycam",
        visible = true
    })
end)

RegisterNetEvent('esx_hud:hideBodycam', function()
    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "bodycam",
        visible = false
    })
end)