if not Config.Modules['Handsup'] then return end

local ShouldHold = true -- false = toggle mode; true = hold-to-raise

local Triggered = false

local function LoadAnimation(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

local function HandsUpStop()
    local player = cache.ped
    ClearPedTasks(player)

    if Main.expression then
        Main:playAnimation(player, Main.expression or nil, false, true)
    else
        SetFacialIdleAnimOverride(player, 'pose_normal_1', 0)
    end
end

local function HandsUpStart()
    local player = cache.ped
    LoadAnimation('random@mugging3')
    SetFacialIdleAnimOverride(player, 'mood_stressed_1', 0)

    if not IsPedInAnyVehicle(player, false) then
        SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)

        TaskPlayAnim(
            player,
            'random@mugging3',
            'handsup_standing_base',
            8.0, -8.0,
            -1,
            49,
            0.0,
            false, false, false
        )
    end
end

local function ToggleHandsUp()
    if Main.isBusy then return end

    Triggered = not Triggered
    LocalPlayer.state:set('handsup', Triggered, true)

    if not Triggered then
        HandsUpStop()
        return
    end

    HandsUpStart()
end

CreateThread(function()
    local cmd = 'handsup'

        RegisterCommand('+' .. cmd, function()
        if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead or LocalPlayer.state.Crosshair then return end
        
        if ShouldHold then
            if Main.isBusy then return end
            if not Triggered then
                Triggered = true
                HandsUpStart()
            end
        else
            ToggleHandsUp()
        end
    end, false)

    RegisterCommand('-' .. cmd, function()
        if LocalPlayer.state.IsHandcuffed or LocalPlayer.state.IsDead or LocalPlayer.state.Crosshair then return end

        if ShouldHold then
            if Main.isBusy then return end
            if Triggered then
                Triggered = false
                HandsUpStop()
            end
        end
    end, false)

    RegisterKeyMapping('+' .. cmd, 'Podnieś ręce', 'keyboard', 'OEM_3')

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', '/handsup')
        TriggerEvent('chat:removeSuggestion', '/+handsup')
        TriggerEvent('chat:removeSuggestion', '/-handsup')
    end)
end)