RegisterNuiCallback('hideFrame', function(_, cb)
    endCam()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "setDrugSellingVisible",
        data = false
    })

    if dealingPed then 
        TaskClearLookAt(dealingPed)
        ClearPedTasks(dealingPed)
        SetBlockingOfNonTemporaryEvents(dealingPed, false)
        TaskWanderStandard(dealingPed, 10.0, 10)
    end
    ClearPedTasks(PlayerPedId())

    if isDrugDealing then
        local randomWait = math.random(Config.CornerDealing.SellTimeoutMin, Config.CornerDealing.SellTimeoutMax)
        SetTimeout(randomWait * 1000, function()
            if isDrugDealing then
                getNextDealing()
            end
        end)
    end

    cb(true)
end)

RegisterNUICallback('languageConfirmation', function(_, cb)
    cb(true)
    isUiLanguageLoaded = true
    if Config.Debug then
        debugPrint("[DEBUG] UI language confirmed")
    end
end)

RegisterNUICallback('drugSell', function(data, cb)
    if Config.Debug then
        debugPrint("[DEBUG] drugSell callback - drug:", data.name, "price:", data.price)
    end
    
    cb(true)
    sellDrugForPedFinalize(data.name, data.price)
end)