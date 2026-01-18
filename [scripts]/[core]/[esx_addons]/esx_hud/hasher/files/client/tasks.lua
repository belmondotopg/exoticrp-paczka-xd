RegisterNetEvent("esx:playerLoaded", function()
    TriggerServerEvent("esx_hud:loadPlayerTasks")
end)

RegisterNUICallback("nui:visible:close", function(data, cb) 
    if (data["elementId"] == "tasks") then
        SetNuiFocus(false, false)
        cb(true)
    end 
end)

RegisterNetEvent("esx_hud:showTasksNUI", function(NUIData)
    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "tasks",
        data = NUIData
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "tasks",
        visible = true
    })
    
    SetNuiFocus(true, true)
    TriggerEvent("chat:toggleChat", false)
end)

