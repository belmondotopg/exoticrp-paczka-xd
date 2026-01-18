LocalPlayer.state:set('ProtectionTime', 0, true)

RegisterNetEvent("esx_antitroll/startProtection", function(time)
    while not ESX.IsPlayerLoaded() do 
        Citizen.Wait(500)
    end

    while (LocalPlayer.state.inWoundedSelector or LocalPlayer.state.inSpawnSelector) do
        Citizen.Wait(500)
    end

    LocalPlayer.state:set('ProtectionTime', time, true)

    SendNUIMessage({
        action = "setVisible",
        data = true,
    })

    SendNUIMessage({
        action = "OpenTimer",
        timer = time,
    })

    if time > 0 then
        Citizen.CreateThread(function()
            while LocalPlayer.state.ProtectionTime > 0 do
                Citizen.Wait(60 * 1000)
                local currentTime = LocalPlayer.state.ProtectionTime
                if not currentTime or currentTime <= 1 then
                    LocalPlayer.state:set('ProtectionTime', 0, true)
                    SendNUIMessage({
                        action = "setVisible",
                        data = false,
                    })
                    break
                else
                    LocalPlayer.state:set('ProtectionTime', currentTime - 1, true)
                end
            end
        end)

        Citizen.CreateThread(function()
            local cachePed = PlayerPedId()
            while LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 do
                Citizen.Wait(1)
                DisableControlAction(2, 24, true)
                DisableControlAction(2, 257, true)
                DisableControlAction(2, 25, true)
                DisableControlAction(2, 263, true)
                DisableControlAction(0, 37, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 92, true)
                NetworkSetFriendlyFireOption(false)
                SetCanAttackFriendly(cachePed, true, false)
                SetLocalPlayerAsGhost(true)
            end

            NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(cachePed, false, false)
            SetLocalPlayerAsGhost(false)
        end)
    else
        SendNUIMessage({
            action = "setVisible",
            data = false,
        })
        
        LocalPlayer.state:set('ProtectionTime', 0, true)
        ESX.ShowNotification('Utraciłeś ochronę przed zagrożeniami!')

        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(PlayerPedId(), false, false)
        SetLocalPlayerAsGhost(false)
    end
end)

AddEventHandler('esx:pauseMenuActive', function(isActive) 
    if not LocalPlayer.state.ProtectionTime or LocalPlayer.state.ProtectionTime <= 0 then return end

    if isActive then
        SendNUIMessage({
            action = "setVisible",
            data = false,
        })
    else
        SendNUIMessage({
            action = "setVisible",
            data = true,
        })
    end
end)