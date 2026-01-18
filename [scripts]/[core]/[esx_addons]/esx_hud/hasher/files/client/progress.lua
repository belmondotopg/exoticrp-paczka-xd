local LocalPlayer = LocalPlayer
local SendNUIMessage = SendNUIMessage

local playingProgressbar = false
local cancel = false
local result = false

local isFivem = cache.game == 'fivem'

local controls = {
    INPUT_LOOK_LR = isFivem and 1 or 0xA987235F,
    INPUT_LOOK_UD = isFivem and 2 or 0xD2047988,
    INPUT_SPRINT = isFivem and 21 or 0x8FFC75D6,
    INPUT_AIM = isFivem and 25 or 0xF84FA74F,
    INPUT_MOVE_LR = isFivem and 30 or 0x4D8FB4C1,
    INPUT_MOVE_UD = isFivem and 31 or 0xFDA83190,
    INPUT_DUCK = isFivem and 36 or 0xDB096B85,
    INPUT_VEH_MOVE_LEFT_ONLY = isFivem and 63 or 0x9DF54706,
    INPUT_VEH_MOVE_RIGHT_ONLY = isFivem and 64 or 0x97A8FD98,
    INPUT_VEH_ACCELERATE = isFivem and 71 or 0x5B9FD4E2,
    INPUT_VEH_BRAKE = isFivem and 72 or 0x6E1F639B,
    INPUT_VEH_EXIT = isFivem and 75 or 0xFEFAB9B4,
    INPUT_VEH_MOUSE_CONTROL_OVERRIDE = isFivem and 106 or 0x39CCABD5
}

local function createProp(prop)
    lib.requestModel(prop.model)
    local coords = GetEntityCoords(cache.ped)
    local object = CreateObject(prop.model, coords.x, coords.y, coords.z, true, true, true)

    AttachEntityToEntity(object, cache.ped, GetPedBoneIndex(cache.ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, 0, true)
    SetModelAsNoLongerNeeded(prop.model)

    return object
end

local function ShowProgressbar(data)
    if playingProgressbar then TriggerEvent('esx_hud:addNotification', 'Wykonujesz już jedną akcję!') return end

    if not data.notHideWeapon or data.notHideWeapon == nil then
        TriggerEvent('ox_inventory:disarm') 
    end

    result = false
    playingProgressbar = true
    LocalPlayer.state.invBusy = true

    exports.ox_target:disableTargeting(true)

    cancel = data.canCancel

    SendNUIMessage({
		eventName = "progress-bar:create",
		progressBar = {
            text = data.label,
            duration = data.duration,
        }
	})

    if data then
        if data.anim ~= '' or data.anim ~= nil then
            local anim = data.anim
            if anim ~= nil then 
                if anim.dict ~= nil then 
                    if anim.dict ~= '' or anim.dict ~= nil then
                        if not IsEntityPlayingAnim(cache.ped, anim.dict, anim.clip, 3) then
                            lib.requestAnimDict(anim.dict)
                
                            TaskPlayAnim(cache.ped, anim.dict, anim.clip, anim.blendIn or 3.0, anim.blendOut or 1.0, anim.duration or -1, anim.flag or 49, anim.playbackRate or 0, anim.lockX, anim.lockY, anim.lockZ)
                            RemoveAnimDict(anim.dict)
                        end
                    elseif anim.scenario ~= '' or anim.scenario ~= nil then
                        TaskStartScenarioInPlace(cache.ped, anim.scenario, 0, anim.playEnter ~= nil and anim.playEnter or true)
                    end
                end
            end
        end

        if data.prop then
            if data.prop.model then
                data.prop1 = createProp(data.prop)
            else
                for i = 1, #data.prop do
                    local prop = data.prop[i]
    
                    if prop then
                        data['prop'..i] = createProp(prop)
                    end
                end
            end
        end
    end

    local disable = data.disable

    while playingProgressbar do
        Citizen.Wait(0)
        if disable then
            if disable.mouse then
                DisableControlAction(0, controls.INPUT_LOOK_LR, true)
                DisableControlAction(0, controls.INPUT_LOOK_UD, true)
                DisableControlAction(0, controls.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
            end

            if disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
                DisableControlAction(0, controls.INPUT_MOVE_LR, true)
                DisableControlAction(0, controls.INPUT_MOVE_UD, true)
                DisableControlAction(0, controls.INPUT_DUCK, true)
            end

            if disable.sprint and not disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
            end

            if disable.car then
                DisableControlAction(0, controls.INPUT_VEH_MOVE_LEFT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_MOVE_RIGHT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_ACCELERATE, true)
                DisableControlAction(0, controls.INPUT_VEH_BRAKE, true)
                DisableControlAction(0, controls.INPUT_VEH_EXIT, true)
            end

            if disable.combat then
                DisableControlAction(0, controls.INPUT_AIM, true)
                DisablePlayerFiring(cache.playerId, true)
            end
        end

        if data then
            if data.anim ~= '' or data.anim ~= nil then
                local anim = data.anim
                if anim ~= nil then 
                    if anim.dict ~= nil then 
                        if anim.dict ~= '' or anim.dict ~= nil then
                            if not IsEntityPlayingAnim(cache.ped, anim.dict, anim.clip, 3) then
                                lib.requestAnimDict(anim.dict)
                    
                                TaskPlayAnim(cache.ped, anim.dict, anim.clip, anim.blendIn or 3.0, anim.blendOut or 1.0, anim.duration or -1, anim.flag or 49, anim.playbackRate or 0, anim.lockX, anim.lockY, anim.lockZ)
                                RemoveAnimDict(anim.dict)
                            end
                        end
                    end
                end
            end
        end
    end

    if data.prop then
        local n = #data.prop
        for i = 1, n > 0 and n or 1 do
            local prop = data['prop'..i]

            if prop then
                DeleteEntity(prop)
            end
        end
    end

    if data then
        if data.anim ~= '' or data.anim ~= nil then
            local anim = data.anim
            if anim ~= nil then 
                if anim.dict ~= nil then 
                    if anim.dict ~= '' or anim.dict ~= nil then
                        StopAnimTask(cache.ped, anim.dict, anim.clip, 1.0)
                        Wait(0) -- This is needed here otherwise the StopAnimTask is cancelled
                    else
                        ClearPedTasks(cache.ped)
                    end
                end
            end
        end
    end

    return result
end

local function CancelProgress()
    SendNUIMessage({
		eventName = "progress-bar:cancel",
	})
    
    playingProgressbar = false
    cancel = false
    result = false

    LocalPlayer.state.invBusy = false
    exports.ox_target:disableTargeting(false)
    
end

RegisterNUICallback('progress-bar/close', function(data, cb)
    result = true
    cancel = false
    playingProgressbar = false

    LocalPlayer.state.invBusy = false
    exports.ox_target:disableTargeting(false)
    cb('ok')
end)

lib.addKeybind({
	name = 'esx_hud:cancelProgressbar',
	description = 'Anuluj akcje (PROGRESSBAR)',
	defaultKey = 'X',
	onPressed = function()
        if playingProgressbar and cancel then
            CancelProgress()
        end
	end,
})

local function cancelExportProgress()
    if playingProgressbar then
        CancelProgress()
    end
end

local function progressActive()
    return playingProgressbar
end

exports('progressActive', progressActive)
exports('cancelExportProgress', cancelExportProgress)
exports('progressBar', ShowProgressbar)

local hasSpawned = false
local Configmba = {
    Default = 'gokarta', -- The default entity set for when your server restarts.
    Sets = {
        basketball = {'mba_tribune', 'mba_tarps', 'mba_basketball', 'mba_jumbotron'},
        boxing = {'mba_tribune', 'mba_tarps', 'mba_fighting', 'mba_boxing', 'mba_jumbotron'},
        concert = {'mba_tribune', 'mba_tarps', 'mba_backstage', 'mba_concert', 'mba_jumbotron'},
        curling = {'mba_tribune', 'mba_chairs', 'mba_curling'},
        derby = {'mba_cover', 'mba_terrain', 'mba_derby', 'mba_ring_of_fire'},
        fameorshame = {'mba_tribune', 'mba_tarps', 'mba_backstage', 'mba_fameorshame', 'mba_jumbotron'},
        fashion = {'mba_tribune', 'mba_tarps', 'mba_backstage', 'mba_fashion', 'mba_jumbotron'},
        football = {'mba_tribune', 'mba_chairs', 'mba_field', 'mba_soccer'},
        icehockey = {'mba_tribune', 'mba_chairs', 'mba_field', 'mba_hockey'},
        gokarta = {'mba_cover', 'mba_gokart_01'},
        gokartb = {'mba_cover', 'mba_gokart_02'},
        trackmaniaa = {'mba_trackmania_01', 'mba_cover'},
        trackmaniab = {'mba_trackmania_02', 'mba_cover'},
        trackmaniac = {'mba_trackmania_03', 'mba_cover'},
        trackmaniad = {'mba_trackmania_04', 'mba_cover'},
        mma = {'mba_tribune', 'mba_tarps', 'mba_fighting', 'mba_mma', 'mba_jumbotron'},
        none = {'mba_tribune', 'mba_tarps', 'mba_jumbotron'},
        paintball = {'mba_tribune', 'mba_chairs', 'mba_paintball', 'mba_jumbotron'},
        rocketleague = {'mba_tribune', 'mba_chairs', 'mba_rocketleague'},
        wrestling = {'mba_tribune', 'mba_tarps', 'mba_fighting', 'mba_wrestling', 'mba_jumbotron'}
    },
    Signs = {
        basketball = 'gabz_ipl_mba_sign_basketball',
        boxing = 'gabz_ipl_mba_sign_boxing',
        concert = 'gabz_ipl_mba_sign_concert',
        curling = 'gabz_ipl_mba_sign_curling',
        derby = 'gabz_ipl_mba_sign_derby',
        fameorshame = 'gabz_ipl_mba_sign_fameorshame',
        fashion = 'gabz_ipl_mba_sign_fashion',
        football = 'gabz_ipl_mba_sign_soccer',
        icehockey = 'gabz_ipl_mba_sign_icehockey',
        gokarta = 'gabz_ipl_mba_sign_gokart',
        gokartb = 'gabz_ipl_mba_sign_gokart',
        trackmaniaa = 'gabz_ipl_mba_sign_banditomania',
        trackmaniab = 'gabz_ipl_mba_sign_banditomania',
        trackmaniac = 'gabz_ipl_mba_sign_banditomania',
        trackmaniad = 'gabz_ipl_mba_sign_banditomania',
        mma = 'gabz_ipl_mba_sign_mma',
        paintball = 'gabz_ipl_mba_sign_paintball',
        rocketleague = 'gabz_ipl_mba_sign_banditoleague',
        wrestling = 'gabz_ipl_mba_sign_wrestling'
    },
    Removals = {
        interiors = {'mba_trackmania_04', 'mba_trackmania_03', 'mba_trackmania_02', 'mba_trackmania_01', 'mba_gokart_02', 'mba_gokart_01', 'mba_hockey', 'mba_field', 'mba_soccer', 'mba_rocketleague', 'mba_curling', 'mba_tribune', 'mba_cover', 'mba_tarps', 'mba_chairs', 'mba_basketball', 'mba_derby', 'mba_paintball', 'mba_fighting', 'mba_wrestling', 'mba_mma', 'mba_boxing', 'mba_backstage', 'mba_concert', 'mba_fashion', 'mba_fameorshame', 'mba_ring_of_fire', 'mba_jumbotron', 'mba_terrain'},
        signs = {'gabz_ipl_mba_sign_basketball', 'gabz_ipl_mba_sign_boxing', 'gabz_ipl_mba_sign_concert', 'gabz_ipl_mba_sign_curling', 'gabz_ipl_mba_sign_derby', 'gabz_ipl_mba_sign_fameorshame', 'gabz_ipl_mba_sign_fashion', 'gabz_ipl_mba_sign_soccer', 'gabz_ipl_mba_sign_icehockey', 'gabz_ipl_mba_sign_gokart', 'gabz_ipl_mba_sign_banditomania', 'gabz_ipl_mba_sign_mma', 'gabz_ipl_mba_sign_paintball', 'gabz_ipl_mba_sign_banditoleague', 'gabz_ipl_mba_sign_wrestling'}
    }
}

local function setMBA(entitySet)
    local interior = GetInteriorAtCoords(-324.22, -1968.49, 20.60)

    if interior ~= 0 then
        local removeSets, newEntitySet = Configmba.Removals.interiors, Configmba.Sets[entitySet]
        local removeSigns, newSign = Configmba.Removals.signs, Configmba.Signs[entitySet]

        for i = 1, #removeSets do
            DeactivateInteriorEntitySet(interior, removeSets[i])
        end

        for i = 1, #removeSigns do
            RemoveIpl(removeSigns[i])
        end

        Wait(100)

        for i = 1, #newEntitySet do
            ActivateInteriorEntitySet(interior, newEntitySet[i])
        end

        if newSign then
            RequestIpl(newSign)
        end

        RefreshInterior(interior)
    end
end

AddEventHandler('playerSpawned', function()
    if not hasSpawned then
        setMBA(GlobalState.mba)

        hasSpawned = true
    end
end)

AddStateBagChangeHandler('mba', nil, function(bagName, key, value, _unused, replicated)
    setMBA(value)
end)

RegisterNetEvent('esx_hud:startProgress', function(data)
    local success = ShowProgressbar({
        duration   = data.duration,
        label      = data.label,
        useWhileDead = false,
        canCancel  = data.canCancel or true,
        disable    = data.disable or { combat = true, movement = true, car = true },
        animation  = false,
        prop       = {}
    })

    TriggerServerEvent(('progressResult:%s'):format(GetPlayerServerId(PlayerId())), success)
end)