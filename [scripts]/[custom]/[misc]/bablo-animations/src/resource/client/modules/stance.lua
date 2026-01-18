local isProne = false
local isCrouched = false
local isCrawling = false
local inAction = false
local proneType = 'onfront'
local lastKeyPress = 0
local forceEndProne = false

local function CanPlayerCrouchCrawl(playerPed)
    if not IsPedOnFoot(playerPed) or IsPedJumping(playerPed) or IsPedFalling(playerPed) or IsPedInjured(playerPed) or IsPedInMeleeCombat(playerPed) or IsPedRagdoll(playerPed) then
        return false
    end

    return true
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

local function LoadClipSet(clipset)
    RequestClipSet(clipset)
    while not HasClipSetLoaded(clipset) do
        Wait(0)
    end
    Trace("Clipset loaded:", clipset)
end


local function IsPlayerAiming(player)
    return (IsPlayerFreeAiming(player) or IsAimCamActive() or IsAimCamThirdPersonActive()) and
        tonumber(GetSelectedPedWeapon(player)) ~= tonumber(GetHashKey("WEAPON_UNARMED"))
end

local function SetPlayerClipset(clipset)
    LoadClipSet(clipset)
    SetPedMovementClipset(PlayerPedId(), clipset, 0.5)
    RemoveClipSet(clipset)
end

local function IsPedAiming(ped)
    return GetPedConfigFlag(ped, 78, true) == 1 and true or false
end

local function PlayAnimOnce(ped, animDict, animName, blendInSpeed, blendOutSpeed, duration, startTime)
    LoadAnimDict(animDict)
    TaskPlayAnim(ped, animDict, animName, blendInSpeed or 2.0, blendOutSpeed or 2.0, duration or -1, 0, startTime or 0.0,
        false, false, false)
    RemoveAnimDict(animDict)
end

local function ChangeHeadingSmooth(ped, amount, time)
    local times = math.abs(amount)
    local test = amount / times
    local wait = time / times

    for _i = 1, times do
        Wait(wait)
        SetEntityHeading(ped, GetEntityHeading(ped) + test)
    end
end

local function DisableControlUntilReleased(padIndex, control)
    CreateThread(function()
        while IsDisabledControlPressed(padIndex, control) do
            DisableControlAction(padIndex, control, true)
            Wait(0)
        end
    end)
end

local function loadAnimSet(anim)
    if HasAnimSetLoaded(anim) then return end
    RequestAnimSet(anim)
    while not HasAnimSetLoaded(anim) do
        Wait(10)
    end
end

local function resetAnimSet()
    local ped = PlayerPedId()
    ResetPedMovementClipset(ped, 1.0)
    ResetPedWeaponMovementClipset(ped)
    ResetPedStrafeClipset(ped)

    Main:resetClipset()
end

if Config.Modules['Crouch'] then
    local isCrouched = false

    Main:registerKey('bstancecrouch', "Crouch", "LCONTROL", function()
        if IsPedSittingInAnyVehicle(cache.ped) or IsPedFalling(cache.ped) or IsPedSwimming(cache.ped) or IsPedSwimmingUnderWater(cache.ped) or IsPauseMenuActive() or LocalPlayer.state.invOpen then
            return
        end

        if isCrouched then
            ClearPedTasks(cache.ped)
            resetAnimSet()
            SetPedStealthMovement(cache.ped, false, 'DEFAULT_ACTION')
            isCrouched = false
        else
            ClearPedTasks(cache.ped)
            loadAnimSet('move_ped_crouched')
            SetPedMovementClipset(cache.ped, 'move_ped_crouched', 1.0)
            SetPedStrafeClipset(cache.ped, 'move_ped_crouched_strafing')
            isCrouched = true
        end
    end)
end

local function ShouldPlayerDiveToCrawl(playerPed)
    if IsPedRunning(playerPed) or IsPedSprinting(playerPed) then
        return true
    end

    return false
end

local function stopPlayerProne(force)
    isProne = false
    forceEndProne = force
end

local function PlayIdleCrawlAnim(playerPed, heading, blendInSpeed)
    local playerCoords = GetEntityCoords(playerPed)
    TaskPlayAnimAdvanced(playerPed, 'move_crawl', proneType .. '_fwd', playerCoords.x, playerCoords.y, playerCoords.z,
        0.0, 0.0, heading or GetEntityHeading(playerPed), blendInSpeed or 2.0, 2.0, -1, 2, 1.0, false, false)
end

local function PlayExitCrawlAnims(forceEnd)
    if not forceEnd then
        inAction = true
        local playerPed = PlayerPedId()

        if proneType == 'onfront' then
            PlayAnimOnce(playerPed, 'get_up@directional@transition@prone_to_knees@crawl', 'front', nil, nil, 780)

            if not isCrouched then
                Wait(780)
                PlayAnimOnce(playerPed, 'get_up@directional@movement@from_knees@standard', 'getup_l_0', nil, nil, 1300)
            end
        else
            PlayAnimOnce(playerPed, 'get_up@directional@transition@prone_to_seated@crawl', 'back', 16.0, nil, 950)

            if not isCrouched then
                Wait(950)
                PlayAnimOnce(playerPed, 'get_up@directional@movement@from_seated@standard', 'get_up_l_0', nil, nil, 1300)
            end
        end
    end
end

local function Crawl(playerPed, type, direction)
    isCrawling = true

    TaskPlayAnim(playerPed, 'move_crawl', type .. '_' .. direction, 8.0, -8.0, -1, 2, 0.0, false, false, false)

    local time = {
        ['onfront'] = {
            ['fwd'] = 820,
            ['bwd'] = 990
        },
        ['onback'] = {
            ['fwd'] = 1200,
            ['bwd'] = 1200
        }
    }

    SetTimeout(time[type][direction], function()
        isCrawling = false
    end)
end

local function CrawlFlip(playerPed)
    inAction = true
    local heading = GetEntityHeading(playerPed)

    if proneType == 'onfront' then
        proneType = 'onback'

        PlayAnimOnce(playerPed, 'get_up@directional_sweep@combat@pistol@front', 'front_to_prone', 2.0)
        ChangeHeadingSmooth(playerPed, -18.0, 3600)
    else
        proneType = 'onfront'

        PlayAnimOnce(playerPed, 'move_crawlprone2crawlfront', 'back', 2.0, nil, -1)
        ChangeHeadingSmooth(playerPed, 12.0, 1700)
    end

    PlayIdleCrawlAnim(playerPed, heading + 180.0)
    Wait(400)
    inAction = false
end

local function CrawlLoop()
    Wait(400)

    while isProne do
        local playerPed = PlayerPedId()

        if not CanPlayerCrouchCrawl(playerPed) or IsEntityInWater(playerPed) then
            ClearPedTasks(playerPed)
            stopPlayerProne(true)
            break
        end

        local forward, backwards = IsControlPressed(0, 32), IsControlPressed(0, 33)
        if not isCrawling then
            if forward then
                Crawl(playerPed, proneType, 'fwd')
            elseif backwards then
                Crawl(playerPed, proneType, 'bwd')
            end
        end

        if IsControlPressed(0, 34) then
            if isCrawling then
                local headingDiff = forward and 1.0 or -1.0
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) + headingDiff)
            else
                inAction = true
                if proneType == 'onfront' then
                    local playerCoords = GetEntityCoords(playerPed)
                    TaskPlayAnimAdvanced(playerPed, 'move_crawlprone2crawlfront', 'left', playerCoords.x, playerCoords.y,
                        playerCoords.z, 0.0, 0.0, GetEntityHeading(playerPed), 2.0, 2.0, -1, 2, 0.1, false, false)
                    ChangeHeadingSmooth(playerPed, -10.0, 300)
                    Wait(700)
                else
                    PlayAnimOnce(playerPed, 'get_up@directional_sweep@combat@pistol@left', 'left_to_prone')
                    ChangeHeadingSmooth(playerPed, 25.0, 400)
                    PlayIdleCrawlAnim(playerPed)
                    Wait(600)
                end
                inAction = false
            end
        elseif IsControlPressed(0, 35) then
            if isCrawling then
                local headingDiff = backwards and 1.0 or -1.0
                SetEntityHeading(playerPed, GetEntityHeading(playerPed) + headingDiff)
            else
                inAction = true
                if proneType == 'onfront' then
                    local playerCoords = GetEntityCoords(playerPed)
                    TaskPlayAnimAdvanced(playerPed, 'move_crawlprone2crawlfront', 'right', playerCoords.x, playerCoords
                        .y, playerCoords.z, 0.0, 0.0, GetEntityHeading(playerPed), 2.0, 2.0, -1, 2, 0.1, false, false)
                    ChangeHeadingSmooth(playerPed, 10.0, 300)
                    Wait(700)
                else
                    PlayAnimOnce(playerPed, 'get_up@directional_sweep@combat@pistol@right', 'right_to_prone')
                    ChangeHeadingSmooth(playerPed, -25.0, 400)
                    PlayIdleCrawlAnim(playerPed)
                    Wait(600)
                end
                inAction = false
            end
        end

        if not isCrawling then
            if IsControlPressed(0, 22) then
                CrawlFlip(playerPed)
            end
        end

        Wait(0)
    end

    PlayExitCrawlAnims(forceEndProne)

    isCrawling = false
    inAction = false
    forceEndProne = false
    proneType = 'onfront'
    SetPedConfigFlag(PlayerPedId(), 48, false)

    RemoveAnimDict('move_crawl')
    RemoveAnimDict('move_crawlprone2crawlfront')
end

local function CrawlKeyPressed()
    if inAction then
        return
    end

    if IsPauseMenuActive() or IsNuiFocused() then
        return
    end

    if isProne then
        isProne = false
        return
    end

    local wasCrouched = false
    if isCrouched then
        isCrouched = false
        wasCrouched = true
    end

    local playerPed = PlayerPedId()

    if not CanPlayerCrouchCrawl(playerPed) or IsEntityInWater(playerPed) or not IsPedHuman(playerPed) then
        return
    end
    inAction = true

    if Pointing then
        Pointing = false
    end

    isProne = true
    SetPedConfigFlag(playerPed, 48, true)

    if GetPedStealthMovement(playerPed) == 1 then
        SetPedStealthMovement(playerPed, false, 'DEFAULT_ACTION')
        Wait(100)
    end

    LoadAnimDict('move_crawl')
    LoadAnimDict('move_crawlprone2crawlfront')

    if ShouldPlayerDiveToCrawl(playerPed) then
        PlayAnimOnce(playerPed, 'explosions', 'react_blown_forwards', nil, 3.0)
        Wait(1100)
    elseif wasCrouched then
        PlayAnimOnce(playerPed, 'amb@world_human_sunbathe@male@front@enter', 'enter', nil, nil, -1, 0.3)
        Wait(1500)
    else
        PlayAnimOnce(playerPed, 'amb@world_human_sunbathe@male@front@enter', 'enter')
        Wait(3000)
    end

    if CanPlayerCrouchCrawl(playerPed) and not IsEntityInWater(playerPed) then
        PlayIdleCrawlAnim(playerPed, nil, 3.0)
    end

    inAction = false
    CreateThread(CrawlLoop)
end

if Config.Modules['Crawl'] then
    RegisterKeyMapping('+stancecrawl', "Crawl", 'keyboard', "RCONTROL")
    RegisterCommand('+stancecrawl', function() CrawlKeyPressed() end, false)
    RegisterCommand('-stancecrawl', function() end, false)
end

exports('isProne', function()
    return isProne
end)

exports('isCrouched', function()
    return isCrouched
end)
