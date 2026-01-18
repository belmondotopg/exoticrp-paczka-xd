functions.createPowerPanel = function(safeData, safeName)
    local powerKey = 'power_' .. safeName
    if targets[powerKey] then
        return
    end
    
    local onSelectCallback = function()
        if GlobalState.Counter['police'] < Config.MinCops then
            ESX.ShowNotification(('Minimalnie musi być %d policjantów, aby włamać się do sejfu!'):format(Config.MinCops), 'error')
            return
        end
        
        local canStart = lib.callback.await('vwk/safes/canStartHeist', false)
        if not canStart then
            ESX.ShowNotification("Nie możesz rozpocząć napadu! Trwa już inny napad lub globalny cooldown.", 'error')
            return
        end
        local onCooldown = lib.callback.await('vwk/safes/checkCooldown', false, safeData.powerCoords)
        if onCooldown then
            ESX.ShowNotification("Panel jest rozcięty! Podejdź później.", 'error')
            return
        end
        functions.doSomethingWithPower(safeData, powerKey, safeName)
    end
    
    targets[powerKey] = exports.ox_target:addSphereZone({
        coords = safeData.powerCoords,
        radius = 0.7,
        options = {
            {
                name = 'power_panel_' .. safeName,
                icon = 'fas fa-bolt',
                label = "Majstruj przy kabelkach",
                onSelect = onSelectCallback
            }
        }
    })
    
    exports["interactions"]:showInteraction(
        safeData.powerCoords,
        "fa-solid fa-bolt",
        "ALT",
        "Panel zasilania",
        "Naciśnij ALT aby majstrować przy kabelkach"
    )
end

functions.init = function()
    for k, v in pairs(Config.Safes) do
        functions.createPowerPanel(v, k)
    end

    if Config.Debug then
        for k, v in pairs(Config.Safes) do
            functions.addSafe(v)
        end
        print("^2[SHOPHEIST DEBUG]^7 Wszystkie sejfy są teraz widoczne!")
        
        CreateThread(function()
            while Config.Debug do
                Wait(0)
                local playerCoords = GetEntityCoords(PlayerPedId())
                
                for k, v in pairs(Config.Safes) do
                    local safeCoords = vector3(v.coords.x, v.coords.y, v.coords.z)
                    local powerCoords = vector3(v.powerCoords.x, v.powerCoords.y, v.powerCoords.z)
                    local distance = #(playerCoords - safeCoords)
                    local powerDistance = #(playerCoords - powerCoords)
                    
                    if distance < 20.0 then
                        DrawMarker(1, safeCoords.x, safeCoords.y, safeCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                        DrawText3D(safeCoords.x, safeCoords.y, safeCoords.z + 0.5, "~g~SEJF~w~\n" .. k)
                    end
                    
                    if powerDistance < 20.0 then
                        DrawMarker(1, powerCoords.x, powerCoords.y, powerCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 165, 0, 100, false, true, 2, false, nil, nil, false)
                        DrawText3D(powerCoords.x, powerCoords.y, powerCoords.z + 0.5, "~o~PANEL ZASILANIA~w~\n" .. k)
                    end
                end
            end
        end)
    else
        local unlockedSafes = lib.callback.await('vwk/safes/getUnlockedSafes', false)
        for k, v in pairs(Config.Safes) do
            if unlockedSafes[functions.getSafeKey(v.coords)] then
                functions.addSafe(v)
            end
        end
    end
end

functions.DrawText3D = function(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local camCoords = GetGameplayCamCoord()
    local distance = #(camCoords - vector3(x, y, z))
    
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

DrawText3D = functions.DrawText3D

functions.getItemLabel = function(itemName)
    local items = exports.ox_inventory:Items()
    return items[itemName] and items[itemName].label or itemName
end

functions.doSomethingWithPower = function(safeData, powerKey, safeKey)
    if GlobalState.Counter['police'] < Config.MinCops then
        ESX.ShowNotification(('Minimalnie musi być %d policjantów, aby włamać się do sejfu!'):format(Config.MinCops), 'error')
        return
    end
    
    local canStart = lib.callback.await('vwk/safes/canStartHeist', false)
    if not canStart then
        ESX.ShowNotification("Nie możesz rozpocząć napadu! Trwa globalny cooldown.", 'error')
        return
    end
    
    local requiredItem = Config.GlobalSafes.requiredItems.powerCut
    local hasItem = lib.callback.await('vwk/safes/checkItem', false, requiredItem, 1)
    if not hasItem then
        ESX.ShowNotification("Nie masz " .. functions.getItemLabel(requiredItem) .. " aby majstrować przy kabelkach!", 'error')
        return
    end
    
    if not exports['lc-minigames']:StartMinigame('PipeJigsaw') then
        ESX.ShowNotification("Nie udało się przeciąć kabli!", 'error')
        return
    end

    local animDict = "missheist_agency3aig_23"
    RequestAnimDict(animDict)
    local timeout = 5000
    local start = GetGameTimer()
    while not HasAnimDictLoaded(animDict) do
        Wait(100)
        if GetGameTimer() - start > timeout then
            return
        end
    end

    TaskPlayAnim(PlayerPedId(), animDict, "urinal_sink_loop", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    local progressCancelled = false
    CreateThread(function()
        Wait(100)
        while not progressCancelled do
            Wait(100)
            local ped = PlayerPedId()
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                progressCancelled = true
                exports.esx_hud.cancelExportProgress()
                functions.cancelRobbing()
                break
            end
        end
    end)
    
    local progressSuccess = exports.esx_hud:progressBar({
        duration = 5,
        label = "Majstrujesz przy kabelkach...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })
    
    if progressCancelled then
        ClearPedTasks(PlayerPedId())
        return
    end
    
    if progressSuccess then
        if not lib.callback.await('vwk/safes/removeItem', false, requiredItem, 1) then
            ESX.ShowNotification("Nie udało się użyć przedmiotu!", 'error')
            ClearPedTasks(PlayerPedId())
            return
        end
        
        TriggerServerEvent('vwk/safes/cooldown', safeData)
        TriggerServerEvent('vwk/safes/powerCut', safeData)
        
        if targets[powerKey] then
            pcall(function()
                exports.ox_target:removeZone(targets[powerKey])
            end)
            targets[powerKey] = nil
        end
        
        pcall(function()
            exports["interactions"]:removeInteraction(safeData.powerCoords)
        end)
        
        ESX.ShowNotification("Udało Ci się odciąć zasilanie sejfu!", 'success')
    else
        ESX.ShowNotification("Przerwałeś majstrowanie przy kabelkach.", 'error')
    end
    
    ClearPedTasks(PlayerPedId())
end

functions.addSafe = function(safeData)
    if not safeData or not safeData.coords then
        return
    end
    local safeKey = 'safe_' .. functions.getSafeKey(safeData.coords)
    if targets[safeKey] then
        return
    end
    
    targets[safeKey] = exports.ox_target:addSphereZone({
        coords = safeData.coords,
        radius = 0.7,
        options = {
            {
                name = 'safe_open_' .. safeData.coords.x,
                icon = 'fas fa-box-open',
                label = "Spróbuj otworzyć sejf",
                onSelect = function()
                    functions.openSafe(safeData, safeKey)
                end
            }
        }
    })
    
    exports["interactions"]:showInteraction(
        safeData.coords,
        "fa-solid fa-box-open",
        "ALT",
        "Sejf",
        "Naciśnij ALT aby spróbować otworzyć sejf"
    )
end

CreateThread(functions.init)

functions.openSafe = function(safe, safeKey)
    local requiredItem = Config.GlobalSafes.requiredItems.safeOpen
    if not lib.callback.await('vwk/safes/checkItem', false, requiredItem, 1) then
        ESX.ShowNotification("Nie masz " .. functions.getItemLabel(requiredItem) .. " aby wyłamać zamek!", 'error')
        return
    end
    
    LocalPlayer.state:set('isRobbing', true, true)
    functions.crackingAnim()
    
    if not exports['lc-minigames']:StartMinigame('LockSpinner') then
        ESX.ShowNotification("Nie udało się wyłamać zamka!", 'error')
        LocalPlayer.state:set('isRobbing', nil, true)
        return
    end
    
    if not lib.callback.await('vwk/safes/removeItem', false, requiredItem, 1) then
        ESX.ShowNotification("Nie udało się użyć przedmiotu!", 'error')
        LocalPlayer.state:set('isRobbing', nil, true)
        return
    end
    
    exports["interactions"]:removeInteraction(safe.coords)
    exports.ox_target:removeZone(targets[safeKey])
    
    TriggerServerEvent('vwk/safes/notifyPolice', safe)
    
    local progressDuration = math.random(90, 120)
    local progressCancelled = false
    
    CreateThread(function()
        Wait(100)
        while not progressCancelled do
            Wait(100)
            local ped = PlayerPedId()
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                progressCancelled = true
                exports.esx_hud.cancelExportProgress()
                functions.cancelRobbing()
                break
            end
        end
    end)
    
    local progressSuccess = exports.esx_hud:progressBar({
        duration = progressDuration,
        label = "Wyrywanie zamka...",
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })
    
    if progressCancelled then
        return
    end
    
    if progressSuccess then
        TriggerServerEvent('vwk/safes/openSafe', safe)
        SetTimeout(1000, function()
            LocalPlayer.state:set('isRobbing', nil, true)
            Wait(1000)
            ClearPedTasks(PlayerPedId())
        end)
    else
        ESX.ShowNotification("Przerwałeś wyrywanie zamka.", 'error')
        LocalPlayer.state:set('isRobbing', nil, true)
    end
end


RegisterNetEvent('vwk/safes/addSafe', function(safeData)
    if not safeData then
        return
    end
    functions.addSafe(safeData)
end)

RegisterNetEvent('vwk/safes/removeSafe', function(coords)
    local safeKey = 'safe_' .. functions.getSafeKey(coords)
    if targets[safeKey] then
        pcall(function()
            exports["interactions"]:removeInteraction(coords)
        end)
        pcall(function()
            exports.ox_target:removeZone(targets[safeKey])
        end)
        targets[safeKey] = nil
    end
end)

functions.getSafeKey = function(coords)
    return coords.x .. '_' .. coords.y
end

RegisterNetEvent('vwk/safes/restorePower', function(safeData)
    local dataKey = functions.getSafeKey(safeData.coords)
    for k, v in pairs(Config.Safes) do
        if functions.getSafeKey(v.coords) == dataKey then
            functions.createPowerPanel(v, k)
            break
        end
    end
end)

RegisterNetEvent('vwk/safes/restorePlayerPower', function(safeData)
    if not safeData or not safeData.coords then 
        return 
    end
    
    local dataKey = functions.getSafeKey(safeData.coords)
    for k, v in pairs(Config.Safes) do
        if functions.getSafeKey(v.coords) == dataKey then
            local powerKey = 'power_' .. k
            if targets[powerKey] then
                pcall(function()
                    exports.ox_target:removeZone(targets[powerKey])
                end)
                targets[powerKey] = nil
            end
            
            pcall(function()
                exports["interactions"]:removeInteraction(v.powerCoords)
            end)
            
            Wait(100)
            functions.createPowerPanel(v, k)
            break
        end
    end
end)

functions.crackingAnim = function()
    local animDict = "mini@safe_cracking"
    local animName = "idle_base"

    RequestAnimDict(animDict)
    local timeout = 5000
    local start = GetGameTimer()
    while not HasAnimDictLoaded(animDict) do
        Wait(0)
        if GetGameTimer() - start > timeout then
            return
        end
    end

    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, -1, 49, 0, false, false, false)

    CreateThread(function()
        while LocalPlayer.state.isRobbing do
            Wait(0)
            if not IsEntityPlayingAnim(PlayerPedId(), animDict, animName, 49) then
                TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, -1, 49, 0, false, false, false)
            end
        end
    end)
end

functions.cancelRobbing = function()
    if LocalPlayer.state.isRobbing then
        LocalPlayer.state:set('isRobbing', nil, true)
        ClearPedTasks(PlayerPedId())
        ESX.ShowNotification("Napad został anulowany", 'error')
        TriggerServerEvent('vwk/safes/cancelRobbing')
    end
end

CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.isRobbing then
            local ped = PlayerPedId()
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                functions.cancelRobbing()
            end
        end
    end
end)


