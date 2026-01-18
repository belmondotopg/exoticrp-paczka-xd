handsupDictonary = "random@mugging3"
handsupAnimation = "handsup_standing_base"
handsup = false

function hasHandsUp()
    return LocalPlayer.state.handsup or handsup
end

function isPedDead(Ped)
    return IsPedDeadOrDying(Ped, true)
end

function ToggleHands()
    local playerPed = PlayerPedId()
    if isHandcuffed then return end
    if GetVehiclePedIsEntering(playerPed) == 0 and not IsPedReloading(playerPed) then
        handsup = not handsup
    end

    if handsup then 
        Citizen.CreateThread(function()
            while handsup and not isHandcuffed do
                local playerPed = PlayerPedId()
                if IsPedRagdoll(playerPed) or GetEntityHealth(playerPed) <= 0 then 
                    handsup = false
                end

                lockActions(playerPed, true)
                if IsPedInAnyVehicle(playerPed, false) then DisableControlAction(0, 59, true) end

                if not IsEntityPlayingAnim(playerPed, handsupDictonary, handsupAnimation, 3) then
                    RequestAnimDict(handsupDictonary)
                    while not HasAnimDictLoaded(handsupDictonary) do
                        Wait(100)
                    end
                    TaskPlayAnim(PlayerPedId(), handsupDictonary, handsupAnimation, 8.0, 8.0, -1, 50, 0, false, false, false)
                end

                Wait(0)
            end
        end)
    else
        if IsEntityPlayingAnim(playerPed, handsupDictonary, handsupAnimation, 3) then
            lockActions(playerPed, false)
            ClearPedTasks(playerPed)
        end
    end
end

function lockActions(ped, state)
    DisableControlAction(0, 45, state)
    DisableControlAction(0, 25, state) 
    DisableControlAction(0, 24, state)
    DisableControlAction(0, 141, state)
    DisableControlAction(0, 37, state) 
    DisableControlAction(0, 142, state) 
    DisableControlAction(0, 140, state) 
    DisablePlayerFiring(ped, state)
end

-- Citizen.CreateThread(function()
--     if not Config.Rope.Enable then return end
--     RegisterKeyMapping('handsup', "Hands Up", 'keyboard', "GRAVE")
--     RegisterCommand('handsup', function() ToggleHands() end)
-- end)