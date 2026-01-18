local self = {}

local Config, Strings = table.unpack(require 'config.main')
local utils = require 'client.utils'

local TargetZones = {
    start = nil,
    glass = nil,
    paintings = {},
    smash = {},
}

local insideLoop = false
local busy = false
local progress = false

local function removeZoneSafe(id)
    if not id then return end
    exports.ox_target:removeZone(id)
end

local function removeInsideTargets()
    removeZoneSafe(TargetZones.glass)
    TargetZones.glass = nil

    for k, id in pairs(TargetZones.paintings) do
        removeZoneSafe(id)
        TargetZones.paintings[k] = nil
    end

    for k, id in pairs(TargetZones.smash) do
        removeZoneSafe(id)
        TargetZones.smash[k] = nil
    end
end

local function addStartHeistTarget()
    if TargetZones.start then return end

    TargetZones.start = exports.ox_target:addSphereZone({
        coords = Config['VangelicoHeist']['startHeist'].pos + vec3(0.0, 0.0, 0.75),
        radius = 1.6,
        options = {
            {
                name = 'vangelicoheist:start',
                icon = 'fa-solid fa-mask',
                label = Strings['start_heist'],
                distance = 2.0,
                canInteract = function()
                    return not progress
                end,
                onSelect = function()
                    if progress then return end
                    progress = true
                    self.VangelicoStart()
                    progress = false
                end
            }
        }
    })
end

local function addInsideTargets()
    if not TargetZones.glass then
        TargetZones.glass = exports.ox_target:addSphereZone({
            coords = Config['VangelicoInside']['glassCutting'].displayPos + vec3(0.0, 0.0, 0.25),
            radius = 0.7,
            options = {
                {
                    name = 'vangelicoheist:glass',
                    icon = 'fa-solid fa-scissors',
                    label = Strings['glass_cut'],
                    distance = 1.5,
                    canInteract = function()
                        return insideLoop
                            and not busy
                            and not progress
                            and not Config['VangelicoInside']['glassCutting']['loot']
                    end,
                    onSelect = function()
                        if busy or progress or Config['VangelicoInside']['glassCutting']['loot'] then return end
                        progress = true
                        self.OverheatScene()
                        progress = false
                    end
                }
            }
        })
    end

    for k, v in ipairs(Config['VangelicoInside']['painting']) do
        if not TargetZones.paintings[k] then
            TargetZones.paintings[k] = exports.ox_target:addSphereZone({
                coords = v.objectPos + vec3(0.0, 0.0, 0.25),
                radius = 1.2,
                options = {
                    {
                        name = ('vangelicoheist:painting:%s'):format(k),
                        icon = 'fa-solid fa-image',
                        label = Strings['start_stealing'],
                        distance = 1.5,
                        canInteract = function()
                            return insideLoop
                                and not busy
                                and not progress
                                and not v.loot
                        end,
                        onSelect = function()
                            if busy or progress or v.loot then return end
                            progress = true
                            self.PaintingScene(k)
                            progress = false
                        end
                    }
                }
            })
        end
    end

    for k, v in ipairs(Config['VangelicoInside']['smashScenes']) do
        if not TargetZones.smash[k] then
            TargetZones.smash[k] = exports.ox_target:addSphereZone({
                coords = v.objPos + vec3(0.0, 0.0, 0.15),
                radius = 1.0,
                options = {
                    {
                        name = ('vangelicoheist:smash:%s'):format(k),
                        icon = 'fa-solid fa-hammer',
                        label = Strings['smash'],
                        distance = 0.5,
                        canInteract = function()
                            print(insideLoop, busy, progress, v.loot, GetSelectedPedWeapon(PlayerPedId()), `WEAPON_UNARMED`)
                            return insideLoop
                                and not busy
                                and not progress
                                and not v.loot
                                and GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED")
                        end,
                        onSelect = function()
                            if busy or progress or v.loot then return end
                            progress = true
                            self.Smash(k)
                            progress = false
                        end
                    }
                }
            })
        end
    end
end


local VangelicoHeist = {
    ['startPeds'] = {},
    ['painting'] = {},
    ['gasMask'] = false,
    ['globalObject'] = nil,
}

local Overheat = {
    ['objects'] = {
        'hei_p_m_bag_var22_arm_s',
        'h4_prop_h4_cutter_01a',
    },
    ['animations'] = {
        { 'enter',             'enter_bag',             'enter_cutter',             'enter_glass_display' },
        { 'idle',              'idle_bag',              'idle_cutter',              'idle_glass_display' },
        { 'cutting_loop',      'cutting_loop_bag',      'cutting_loop_cutter',      'cutting_loop_glass_display' },
        { 'overheat_react_01', 'overheat_react_01_bag', 'overheat_react_01_cutter', 'overheat_react_01_glass_display' },
        { 'success',           'success_bag',           'success_cutter',           'success_glass_display_cut' },
    },
    ['scenes'] = {},
    ['sceneObjects'] = {},
}

local ArtHeist = {
    ['objects'] = {
        'hei_p_m_bag_var22_arm_s',
        'w_me_switchblade'
    },
    ['animations'] = {
        { "top_left_enter",               "top_left_enter_ch_prop_ch_sec_cabinet_02a",               "top_left_enter_ch_prop_vault_painting_01a",               "top_left_enter_hei_p_m_bag_var22_arm_s",               "top_left_enter_w_me_switchblade" },
        { "cutting_top_left_idle",        "cutting_top_left_idle_ch_prop_ch_sec_cabinet_02a",        "cutting_top_left_idle_ch_prop_vault_painting_01a",        "cutting_top_left_idle_hei_p_m_bag_var22_arm_s",        "cutting_top_left_idle_w_me_switchblade" },
        { "cutting_top_left_to_right",    "cutting_top_left_to_right_ch_prop_ch_sec_cabinet_02a",    "cutting_top_left_to_right_ch_prop_vault_painting_01a",    "cutting_top_left_to_right_hei_p_m_bag_var22_arm_s",    "cutting_top_left_to_right_w_me_switchblade" },
        { "cutting_top_right_idle",       "_cutting_top_right_idle_ch_prop_ch_sec_cabinet_02a",      "cutting_top_right_idle_ch_prop_vault_painting_01a",       "cutting_top_right_idle_hei_p_m_bag_var22_arm_s",       "cutting_top_right_idle_w_me_switchblade" },
        { "cutting_right_top_to_bottom",  "cutting_right_top_to_bottom_ch_prop_ch_sec_cabinet_02a",  "cutting_right_top_to_bottom_ch_prop_vault_painting_01a",  "cutting_right_top_to_bottom_hei_p_m_bag_var22_arm_s",  "cutting_right_top_to_bottom_w_me_switchblade" },
        { "cutting_bottom_right_idle",    "cutting_bottom_right_idle_ch_prop_ch_sec_cabinet_02a",    "cutting_bottom_right_idle_ch_prop_vault_painting_01a",    "cutting_bottom_right_idle_hei_p_m_bag_var22_arm_s",    "cutting_bottom_right_idle_w_me_switchblade" },
        { "cutting_bottom_right_to_left", "cutting_bottom_right_to_left_ch_prop_ch_sec_cabinet_02a", "cutting_bottom_right_to_left_ch_prop_vault_painting_01a", "cutting_bottom_right_to_left_hei_p_m_bag_var22_arm_s", "cutting_bottom_right_to_left_w_me_switchblade" },
        { "cutting_bottom_left_idle",     "cutting_bottom_left_idle_ch_prop_ch_sec_cabinet_02a",     "cutting_bottom_left_idle_ch_prop_vault_painting_01a",     "cutting_bottom_left_idle_hei_p_m_bag_var22_arm_s",     "cutting_bottom_left_idle_w_me_switchblade" },
        { "cutting_left_top_to_bottom",   "cutting_left_top_to_bottom_ch_prop_ch_sec_cabinet_02a",   "cutting_left_top_to_bottom_ch_prop_vault_painting_01a",   "cutting_left_top_to_bottom_hei_p_m_bag_var22_arm_s",   "cutting_left_top_to_bottom_w_me_switchblade" },
        { "with_painting_exit",           "with_painting_exit_ch_prop_ch_sec_cabinet_02a",           "with_painting_exit_ch_prop_vault_painting_01a",           "with_painting_exit_hei_p_m_bag_var22_arm_s",           "with_painting_exit_w_me_switchblade" },
    },
    ['scenes'] = {},
    ['sceneObjects'] = {}
}




CreateThread(function()
    for k, v in pairs(Config['VangelicoHeist']['startHeist']['peds']) do
        lib.requestModel(v['ped'])
        VangelicoHeist['startPeds'][k] = CreatePed(4, GetHashKey(v['ped']), v['pos']['x'], v['pos']['y'], v['pos']['z'] - 0.95, v['heading'], false, true)
        FreezeEntityPosition(VangelicoHeist['startPeds'][k], true)
        SetEntityInvincible(VangelicoHeist['startPeds'][k], true)
        SetBlockingOfNonTemporaryEvents(VangelicoHeist['startPeds'][k], true)
    end
end)

CreateThread(function()
    addStartHeistTarget()
end)

local gasBlip = nil
function self.VangelicoStart()
    ESX.TriggerServerCallback('vangelicoheist:server:checkPoliceCount', function(status)
        if status then
            ESX.TriggerServerCallback('vangelicoheist:server:checkTime', function(time)
                if time then
                    utils.notify(Strings['goto_vangelico'])
                    gasBlip = self.addBlip(vector3(-622.4311, -233.6548, 58.41259), 570, 1, Strings['throw_gas_blip'])
                    SetNewWaypoint(-622.43, -233.6548)
                    while true do
                        local ped = PlayerPedId()
                        local pedCo = GetEntityCoords(ped)
                        local dist = #(pedCo - vector3(-622.4311, -233.6548, 58.41259))
                        if dist <= 20.0 then
                            DrawMarker(2, -622.4311, -233.6548, 60.41259, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 1.0, 237, 197, 66, 255, true, false)
                            DrawMarker(2, -622.4311, -233.6548, 58.41259, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 1.0, 237, 197, 66, 255, true, false)
                            if IsProjectileTypeWithinDistance(-622.4311, -233.6548, 58.41259, GetHashKey('WEAPON_BZGAS'), 1.0, true) then
                                self.VangelicoSetup()
                                break
                            end
                        end
                        Wait(1)
                    end
                end
            end)
        end
    end)
end

function self.VangelicoSetup()
    utils.notify(Strings['good_shot'])
    Wait(5000)
    self.PlayCutscene('JH_2A_MCS_1')
    RemoveBlip(gasBlip)
    TriggerServerEvent('vangelicoheist:server:startGas')

    local random = math.random(1, 4)
    local glassConfig = Config['VangelicoInside']['glassCutting']
    lib.requestModel(glassConfig['rewards'][random]['object']['model'])
    lib.requestModel(glassConfig['rewards'][random]['displayObj']['model'])
    lib.requestModel('h4_prop_h4_glass_disp_01a')
    local glass = CreateObject(GetHashKey('h4_prop_h4_glass_disp_01a'), -617.4622, -227.4347, 37.057, 1, 1, 0)
    SetEntityHeading(glass, -53.06)
    local reward = CreateObject(GetHashKey(glassConfig['rewards'][random]['object']['model']), glassConfig['rewardPos'].xy, glassConfig['rewardPos'].z + 0.195, 1, 1, 0)
    SetEntityHeading(reward, glassConfig['rewards'][random]['object']['rot'])
    local rewardDisp = CreateObject(GetHashKey(glassConfig['rewards'][random]['displayObj']['model']), glassConfig['rewardPos'], 1, 1, 0)
    SetEntityRotation(rewardDisp, glassConfig['rewards'][random]['displayObj']['rot'])
    TriggerServerEvent('vangelicoheist:server:globalObject', glassConfig['rewards'][random]['object']['model'], random)

    for k, v in pairs(Config['VangelicoInside']['painting']) do
        lib.requestModel(v['object'])
        VangelicoHeist['painting'][k] = CreateObjectNoOffset(GetHashKey(v['object']), v['objectPos'], 1, 0, 0)
        SetEntityRotation(VangelicoHeist['painting'][k], 0, 0, v['objHeading'], 2, true)
    end

    TriggerServerEvent('vangelicoheist:server:insideLoop', utils.getNetIds(glass), utils.getNetIds(reward), utils.getNetIds(rewardDisp), utils.getNetIds(VangelicoHeist['painting']))
    TriggerServerEvent('qf_mdt/addDispatchAlertSV', cache.coords, 'Napad na Jubilera!', 'Zgłoszono włamanie na terenie Jubilera w podanej lokalizacji!', '10-73', 'rgb(156, 85, 37)', '10', 492, 3, 6)
end

RegisterNetEvent('vangelicoheist:client:globalObject')
AddEventHandler('vangelicoheist:client:globalObject', function(obj)
    VangelicoHeist['globalObject'] = obj
end)

local dicts = {
    "anim_heist@hs3f@ig11_steal_painting@male@",
    'anim@scripted@heist@ig16_glass_cut@male@',
    'missheist_jewel'
}
local models = {
    ArtHeist['objects'],
    Overheat['objects'],
    "h4_prop_h4_glass_disp_01b"
}
function self.loadAssets()
    CreateThread(function()
        print("starting loading assets")
        utils.loadAnimDicts(dicts)
        utils.loadModels(models)
        print("finished loading assets")
    end)
end

function self.unloadAssets()
    print("unloading assets")
    utils.unloadAnimDicts(dicts)
    utils.unloadModels(models)
    print("finished unloading assets")
end

local robber = false
CreateThread(function()
    local inside = false
    while true do
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)
        local dist = #(pedCo - vec(-622.4311, -233.6548, 58.41259))
        if dist <= 250.0 then
            if not inside then
                inside = true
                local state = lib.callback.await('vangelicoheist:server:getHeistState', false)
                if state then
                    TriggerEvent('vangelicoheist:client:insideLoop')
                    TriggerEvent('vangelicoheist:client:startGas')
                    if state.lootSync then
                        for _type, indexes in pairs(state.lootSync) do
                            if type(indexes) ~= "table" then
                                Config['VangelicoInside'][_type]['loot'] = true
                            else
                                for index, _ in ipairs(indexes) do
                                    Config['VangelicoInside'][_type][index]['loot'] = true
                                end
                            end
                        end
                    end
                    if state.globalObject then
                        TriggerEvent('vangelicoheist:client:globalObject', state.globalObject.obj, state.globalObject.random)
                    end
                    if state.smashSync then
                        for index, _ in pairs(state.smashSync) do
                            TriggerEvent('vangelicoheist:client:smashSync', index)
                        end
                    end
                end
            end
        else
            if inside then
                inside = false
                self.unloadAssets()
                TriggerServerEvent('vangelicoheist:server:unSubscribe')
                TriggerEvent('vangelicoheist:client:resetHeist')
                TriggerServerEvent('vangelicoheist:server:robberLeftZone')
                if robber then
                    self.Outside()
                end
            end
        end
        Wait(1000)
    end
end)

RegisterNetEvent('vangelicoheist:client:insideLoop')
AddEventHandler('vangelicoheist:client:insideLoop', function()
    self.loadAssets()
    insideLoop = true
    addInsideTargets()
end)

RegisterNetEvent('vangelicoheist:client:lootSync')
AddEventHandler('vangelicoheist:client:lootSync', function(type, index)
    if index then
        Config['VangelicoInside'][type][index]['loot'] = true
    else
        Config['VangelicoInside'][type]['loot'] = true
    end
end)
DoScreenFadeIn(0)
function self.PaintingScene(sceneId)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)
    if weapon ~= GetHashKey('WEAPON_SWITCHBLADE') then
        utils.notify(Strings['need_switchblade'])
        return
    end
    -- ESX.TriggerServerCallback('heists:server:hasItem', function(hasItem, itemName)
    --     if hasItem then
    local pedCo = GetEntityCoords(ped)
    local scenes = { false, false, false, false }
    local animDict = "anim_heist@hs3f@ig11_steal_painting@male@"
    local scene = Config['VangelicoInside']['painting'][sceneId]
    local sceneObject = GetClosestObjectOfType(scene['objectPos'], 1.0, GetHashKey(scene['object']), 0, 0, 0)
    if not DoesEntityExist(sceneObject) then
        return print("objects missing [vangelico_1]")
    end
    local allow = lib.callback.await('vangelicoheist:server:lootSync', 500, 'painting', sceneId)
    if not allow then return end
    robber = true
    busy = true

    local scenePos = scene['scenePos']
    local sceneRot = scene['sceneRot']
    lib.requestAnimDict(animDict)

    for k, v in pairs(ArtHeist['objects']) do
        lib.requestModel(v)
        ArtHeist['sceneObjects'][k] = CreateObject(GetHashKey(v), pedCo + vec(0, 0, -5), 1, 1, 0)
    end

    local function createScene(i)
        ArtHeist['scenes'][i] = NetworkCreateSynchronisedScene(scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 2, true, false, 1065353216, 0, 1065353216)
        NetworkAddPedToSynchronisedScene(ped, ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][1], 4.0, -4.0, 1|4|64|1024|2048, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(sceneObject, ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][3], 1.0, -1.0, 4)
        NetworkAddEntityToSynchronisedScene(ArtHeist['sceneObjects'][1], ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][4], 1.0, -1.0, 4)
        NetworkAddEntityToSynchronisedScene(ArtHeist['sceneObjects'][2], ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][5], 1.0, -1.0, 4)
    end

    ArtHeist['cuting'] = true
    -- FreezeEntityPosition(ped, true)
    createScene(1)
    createScene(2)

    utils.prepForScene(scenePos, sceneObject)

    local cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, 0, 3000, 1, 0)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][1])
    PlayCamAnim(cam, 'ver_01_top_left_enter_cam_ble', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    Wait(3000)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][2])
    PlayCamAnim(cam, 'ver_01_cutting_top_left_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    utils.helpNotify(table.unpack(Strings['cute_right']))
    repeat
        if IsDisabledControlJustPressed(0, 38) then
            scenes[1] = true
        end
        Wait(1)
    until scenes[1] == true
    createScene(3)
    createScene(4)
    Wait(500)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][3])
    PlayCamAnim(cam, 'ver_01_cutting_top_left_to_right_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    Wait(3000)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][4])
    PlayCamAnim(cam, 'ver_01_cutting_top_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    utils.hideHelpNotify()
    Citizen.Wait(0)
    
    utils.helpNotify(table.unpack(Strings['cute_down']))
    repeat
        if IsDisabledControlJustPressed(0, 38) then
            scenes[2] = true
        end
        Wait(1)
    until scenes[2] == true
    createScene(5)
    createScene(6)
    Wait(500)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][5])
    PlayCamAnim(cam, 'ver_01_cutting_right_top_to_bottom_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    Wait(3000)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][6])
    PlayCamAnim(cam, 'ver_01_cutting_bottom_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)

    utils.hideHelpNotify()
    Citizen.Wait(0)

    utils.helpNotify(table.unpack(Strings['cute_left']))
    repeat
        if IsDisabledControlJustPressed(0, 38) then
            scenes[3] = true
        end
        Wait(1)
    until scenes[3] == true
    createScene(7)
    Wait(500)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][7])
    PlayCamAnim(cam, 'ver_01_cutting_bottom_right_to_left_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    Wait(3000)

    utils.hideHelpNotify()
    Citizen.Wait(0)

    utils.helpNotify(table.unpack(Strings['cute_down']))
    repeat
        if IsDisabledControlJustPressed(0, 38) then
            scenes[4] = true
        end
        Wait(1)
    until scenes[4] == true
    createScene(9)
    createScene(10)
    Wait(500)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][9])
    PlayCamAnim(cam, 'ver_01_cutting_left_top_to_bottom_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    Wait(1500)
    NetworkStartSynchronisedScene(ArtHeist['scenes'][10])
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    Wait(7500)
    TriggerServerEvent('vangelicoheist:server:rewardItem', 'painting', sceneId)
    PlayCamAnim(cam, 'ver_01_cutting_top_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
    utils.hideHelpNotify()
    ClearPedTasks(ped)
    -- FreezeEntityPosition(ped, false)
    RemoveAnimDict(animDict)
    for k, v in pairs(ArtHeist['sceneObjects']) do
        DeleteObject(v)
    end
    DeleteEntity(sceneObject)
    for k, v in pairs(ArtHeist['scenes']) do
        NetworkStopSynchronisedScene(v)
    end

    utils.resetScenePrep()

    ArtHeist['sceneObjects'] = {}
    ArtHeist['scenes'] = {}
    scenes = { false, false, false, false }
    busy = false
    --     else
    --         utils.notify(Strings['need_this'] .. ESX.GetItemLabel(itemName))
    --     end
    -- end, Config['VangelicoHeist']['requiredItems'][2])
    Wait(1)
end

function self.OverheatScene()
    -- ESX.TriggerServerCallback('heists:server:hasItem', function(hasItem, itemName)
    --     if hasItem then
    local ped = PlayerPedId()
    local pedCo = GetEntityCoords(ped)
    local animDict = 'anim@scripted@heist@ig16_glass_cut@male@'
    local sceneObject = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01a'), 0, 0, 0)
    if not DoesEntityExist(sceneObject) then
        return print("objects missing [vangelico_2]")
    end
    local allow = lib.callback.await('vangelicoheist:server:lootSync', 500, 'glassCutting')
    if not allow then return end
    robber = true
    busy = true
    local scenePos = GetEntityCoords(sceneObject)
    local sceneRot = GetEntityRotation(sceneObject)
    local globalObj = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 5.0, GetHashKey(VangelicoHeist['globalObject']), 0, 0, 0)
    lib.requestAnimDict(animDict)
    RequestScriptAudioBank('DLC_HEI4/DLCHEI4_GENERIC_01', -1)

    for k, v in pairs(Overheat['objects']) do
        lib.requestModel(v)
        Overheat['sceneObjects'][k] = CreateObject(GetHashKey(v), pedCo + vec(0, 0, -5), 1, 1, 0)
    end

    lib.requestModel('h4_prop_h4_glass_disp_01b')

    local newObj = CreateObject(GetHashKey('h4_prop_h4_glass_disp_01b'), GetEntityCoords(sceneObject) + vec(0, 0, -5), 1, 1, 0)
    SetEntityHeading(newObj, GetEntityHeading(sceneObject))

    local function createScene(i)
        Overheat['scenes'][i] = NetworkCreateSynchronisedScene(scenePos, sceneRot, 2, true, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, Overheat['scenes'][i], animDict, Overheat['animations'][i][1], 4.0, -4.0, 1|4|64|1024|2048, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(Overheat['sceneObjects'][1], Overheat['scenes'][i], animDict, Overheat['animations'][i][2], 1.0, -1.0, 4)
        NetworkAddEntityToSynchronisedScene(Overheat['sceneObjects'][2], Overheat['scenes'][i], animDict, Overheat['animations'][i][3], 1.0, -1.0, 4)
        if i ~= 5 then
            NetworkAddEntityToSynchronisedScene(sceneObject, Overheat['scenes'][i], animDict, Overheat['animations'][i][4], 1.0, -1.0, 4)
        else
            NetworkAddEntityToSynchronisedScene(newObj, Overheat['scenes'][i], animDict, Overheat['animations'][i][4], 1.0, -1.0, 4)
        end
    end

    local sound1 = GetSoundId()
    local sound2 = GetSoundId()

    createScene(1)
    createScene(2)
    createScene(3)
    createScene(4)
    createScene(5)

    utils.prepForScene(scenePos, sceneObject)

    local cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, 0, 3000, 1, 0)
    NetworkStartSynchronisedScene(Overheat['scenes'][1])
    PlayCamAnim(cam, 'enter_cam', animDict, scenePos, sceneRot, 0, 2)
    Wait(GetAnimDuration(animDict, 'enter') * 1000)

    NetworkStartSynchronisedScene(Overheat['scenes'][2])
    PlayCamAnim(cam, 'idle_cam', animDict, scenePos, sceneRot, 0, 2)
    Wait(GetAnimDuration(animDict, 'idle') * 1000)

    NetworkStartSynchronisedScene(Overheat['scenes'][3])
    PlaySoundFromEntity(sound1, "StartCutting", Overheat['sceneObjects'][2], 'DLC_H4_anims_glass_cutter_Sounds', true, 80)
    lib.requestNamedPtfxAsset('scr_ih_fin')
    UseParticleFxAssetNextCall('scr_ih_fin')
    local fire1 = StartParticleFxLoopedOnEntity('scr_ih_fin_glass_cutter_cut', Overheat['sceneObjects'][2], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1065353216, 0.0, 0.0, 0.0, 1065353216, 1065353216, 1065353216,
        0)
    PlayCamAnim(cam, 'cutting_loop_cam', animDict, scenePos, sceneRot, 0, 2)
    Wait(GetAnimDuration(animDict, 'cutting_loop') * 1000)
    StopSound(sound1)
    StopParticleFxLooped(fire1)

    NetworkStartSynchronisedScene(Overheat['scenes'][4])
    PlaySoundFromEntity(sound2, "Overheated", Overheat['sceneObjects'][2], 'DLC_H4_anims_glass_cutter_Sounds', true, 80)
    UseParticleFxAssetNextCall('scr_ih_fin')
    local fire2 = StartParticleFxLoopedOnEntity('scr_ih_fin_glass_cutter_overheat', Overheat['sceneObjects'][2], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1065353216, 0.0, 0.0, 0.0)
    PlayCamAnim(cam, 'overheat_react_01_cam', animDict, scenePos, sceneRot, 0, 2)
    Wait(GetAnimDuration(animDict, 'overheat_react_01') * 1000)
    StopSound(sound2)
    StopParticleFxLooped(fire2)

    DeleteObject(sceneObject)
    NetworkStartSynchronisedScene(Overheat['scenes'][5])
    Wait(2000)
    DeleteObject(globalObj)
    TriggerServerEvent('vangelicoheist:server:rewardItem', 'glassCutting')
    PlayCamAnim(cam, 'success_cam', animDict, scenePos, sceneRot, 0, 2)
    Wait(GetAnimDuration(animDict, 'success') * 1000 - 2000)
    DeleteObject(Overheat['sceneObjects'][1])
    DeleteObject(Overheat['sceneObjects'][2])
    for k, v in pairs(Overheat['scenes']) do
        NetworkStopSynchronisedScene(v)
    end

    utils.resetScenePrep()

    ClearPedTasks(ped)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    busy = false
    --     else
    --         utils.notify(Strings['need_this'] .. ESX.GetItemLabel(itemName))
    --     end
    -- end, Config['VangelicoHeist']['requiredItems'][1])
    Wait(1)
end

local prevAnim = ''
function self.Smash(index)
    local ped = PlayerPedId()
    if GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_UNARMED") then
        utils.notify(Strings['need_weapon'])
        return
    end
    -- ESX.TriggerServerCallback('heists:server:hasItem', function(hasItem, itemName)
    --     if hasItem then
    local allow = lib.callback.await('vangelicoheist:server:lootSync', 500, 'smashScenes', index)
    if not allow then return end
    robber = true
    busy = true
    local animDict = 'missheist_jewel'
    local ptfxAsset = "scr_jewelheist"
    local particleFx = "scr_jewel_cab_smash"
    lib.requestAnimDict(animDict)
    lib.requestNamedPtfxAsset(ptfxAsset)
    local sceneConfig = Config['VangelicoInside']['smashScenes'][index]
    SetEntityCoords(ped, sceneConfig['scenePos'])
    local anims = {
        { 'smash_case_necklace', 300 },
        { 'smash_case_d',        300 },
        { 'smash_case_e',        300 },
        { 'smash_case_f',        300 }
    }
    local selected = ''
    repeat
        selected = anims[math.random(1, #anims)]
    until selected ~= prevAnim
    prevAnim = selected

    if index == 4 or index == 10 or index == 14 or index == 8 then
        selected = { 'smash_case_necklace_skull', 300 }
    end

    local scene = NetworkCreateSynchronisedScene(sceneConfig['scenePos'], sceneConfig['sceneRot'], 2, true, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene, animDict, selected[1], 2.0, 4.0, 1|4|64|2048, 0, 1148846080, 0)

    utils.prepForScene(sceneConfig['scenePos'])

    local cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, 0, 0, 0, 0)
    NetworkStartSynchronisedScene(scene)
    PlayCamAnim(cam, 'cam_' .. selected[1], animDict, sceneConfig['scenePos'], sceneConfig['sceneRot'], 0, 2)

    Wait(300)

    TriggerServerEvent('vangelicoheist:server:smashSync', index)
    for i = 1, 5 do
        PlaySoundFromCoord(-1, "Glass_Smash", sceneConfig['objPos'], 0, 0, 0)
    end
    SetPtfxAssetNextCall(ptfxAsset)
    StartNetworkedParticleFxNonLoopedAtCoord(particleFx, sceneConfig['objPos'], 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
    Wait(GetAnimDuration(animDict, selected[1]) * 1000 - 1000)
    local random = math.random(1, #Config['VangelicoHeist']['smashRewards'])
    TriggerServerEvent('vangelicoheist:server:rewardItem', 'smashScenes', index)
    NetworkStopSynchronisedScene(scene)

    utils.resetScenePrep()

    ClearPedTasks(PlayerPedId())
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    busy = false
    --     else
    --         utils.notify(Strings['need_this'] .. ESX.GetItemLabel(itemName))
    --     end
    -- end, Config['VangelicoHeist']['requiredItems'][2])
    Wait(1)
end

RegisterNetEvent('vangelicoheist:client:smashSync')
AddEventHandler('vangelicoheist:client:smashSync', function(index)
    local sceneConfig = Config['VangelicoInside']['smashScenes'][index]
    CreateModelSwap(sceneConfig['objPos'], 0.3, GetHashKey(sceneConfig['oldModel']), GetHashKey(sceneConfig['newModel']), 1)
end)

--Thanks to d0p3t
function self.PlayCutscene(cut, coords)
    while not HasThisCutsceneLoaded(cut) do
        RequestCutscene(cut, 8)
        Wait(0)
    end
    self.CreateCutscene(false, coords)
    self.Finish(coords)
    RemoveCutscene()
    DoScreenFadeIn(500)
end

function self.CreateCutscene(change, coords)
    local ped = PlayerPedId()

    local clone = ClonePedEx(ped, 0.0, false, true, 1)
    local clone2 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone3 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone4 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone5 = ClonePedEx(ped, 0.0, false, true, 1)

    SetBlockingOfNonTemporaryEvents(clone, true)
    SetEntityVisible(clone, false, false)
    SetEntityInvincible(clone, true)
    SetEntityCollision(clone, false, false)
    FreezeEntityPosition(clone, true)
    SetPedHelmet(clone, false)
    RemovePedHelmet(clone, true)

    if change then
        SetCutsceneEntityStreamingFlags('MP_2', 0, 1)
        RegisterEntityForCutscene(ped, 'MP_2', 0, GetEntityModel(ped), 64)

        SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
        RegisterEntityForCutscene(clone2, 'MP_1', 0, GetEntityModel(clone2), 64)
    else
        SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
        RegisterEntityForCutscene(ped, 'MP_1', 0, GetEntityModel(ped), 64)

        SetCutsceneEntityStreamingFlags('MP_2', 0, 1)
        RegisterEntityForCutscene(clone2, 'MP_2', 0, GetEntityModel(clone2), 64)
    end

    SetCutsceneEntityStreamingFlags('MP_3', 0, 1)
    RegisterEntityForCutscene(clone3, 'MP_3', 0, GetEntityModel(clone3), 64)

    SetCutsceneEntityStreamingFlags('MP_4', 0, 1)
    RegisterEntityForCutscene(clone4, 'MP_4', 0, GetEntityModel(clone4), 64)

    SetCutsceneEntityStreamingFlags('MP_5', 0, 1)
    RegisterEntityForCutscene(clone5, 'MP_5', 0, GetEntityModel(clone5), 64)

    Wait(10)
    if coords then
        StartCutsceneAtCoords(coords, 0)
    else
        StartCutscene(0)
    end
    Wait(10)
    ClonePedToTarget(clone, ped)
    Wait(10)
    DeleteEntity(clone)
    DeleteEntity(clone2)
    DeleteEntity(clone3)
    DeleteEntity(clone4)
    DeleteEntity(clone5)
    Wait(50)
    DoScreenFadeIn(250)
end

function self.Finish(coords)
    if coords then
        local tripped = false
        repeat
            Wait(0)
            if (timer and (GetCutsceneTime() > timer)) then
                DoScreenFadeOut(250)
                tripped = true
            end
            if (GetCutsceneTotalDuration() - GetCutsceneTime() <= 250) then
                DoScreenFadeOut(250)
                tripped = true
            end
        until not IsCutscenePlaying()
        if (not tripped) then
            DoScreenFadeOut(100)
            Wait(150)
        end
        return
    else
        Wait(18500)
        StopCutsceneImmediately()
    end
end

local ptfx = nil
local gasLoop = false
RegisterNetEvent('vangelicoheist:client:startGas')
AddEventHandler('vangelicoheist:client:startGas', function()
    local ptfxAsset = "scr_jewelheist"
    local particleFx = "scr_jewel_fog_volume"

    lib.requestNamedPtfxAsset(ptfxAsset)

    SetPtfxAssetNextCall(ptfxAsset)
    ptfx = StartParticleFxLoopedAtCoord(particleFx, -622.0, -231.0, 38.0, 0.0, 0.0, 0.0, 0.5, false, false, false, false)
    gasLoop = true
    CreateThread(function()
        while gasLoop do
            local ped = PlayerPedId()
            local pedCo = GetEntityCoords(ped)
            local cu = vector3(-622.30, -230.82, 38.0570)
            local dist = #(pedCo - cu)

            if dist <= 10.0 and not VangelicoHeist['gasMask'] then
                ApplyDamageToPed(ped, 3, false)
                utils.notify("Jeśli nie założysz maski gazowej umrzesz")
                Wait(1000)
            end
            Wait(1)
        end
    end)
end)

local maskTickRunning = false

local function startMaskDurabilityTick()
    if maskTickRunning then return end
    maskTickRunning = true

    CreateThread(function()
        while VangelicoHeist['gasMask'] do
            Wait(math.random(30, 60) * 1000)

            if not VangelicoHeist['gasMask'] then
                break
            end

            local slotData = exports.ox_inventory:GetSlotWithItem(
                Config['VangelicoHeist']['gasMask']['itemName'],
                nil,
                false
            )

            if not slotData or not slotData.slot then
                VangelicoHeist['gasMask'] = false
                SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1)
                break
            end

            TriggerServerEvent('vangelicoheist:server:degradeMask', slotData.slot)
        end

        maskTickRunning = false
    end)
end

RegisterNetEvent('vangelicoheist:client:wearMask', function()
    VangelicoHeist['gasMask'] = not VangelicoHeist['gasMask']

    lib.requestAnimDict('mp_masks@standard_car@ds@')
    TaskPlayAnim(PlayerPedId(), 'mp_masks@standard_car@ds@', 'put_on_mask', 8.0, 8.0, 800, 16, 0, false, false, false)

    if VangelicoHeist['gasMask'] then
        SetPedComponentVariation(PlayerPedId(), 1, Config['VangelicoHeist']['gasMask']['clothNumber'], 0, 1)
        startMaskDurabilityTick()
    else
        SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1)
    end
end)

RegisterNetEvent('vangelicoheist:client:resetHeist')
AddEventHandler('vangelicoheist:client:resetHeist', function()
    removeInsideTargets()
    insideLoop = false
    gasLoop = false
    for k, v in pairs(Config['VangelicoInside']['smashScenes']) do
        v['loot'] = false
        CreateModelSwap(v['objPos'], 0.3, GetHashKey(v['newModel']), GetHashKey(v['oldModel']), 1)
    end
    for k, v in pairs(Config['VangelicoInside']['painting']) do
        v['loot'] = false
    end
    Config['VangelicoInside']['glassCutting']['loot'] = false
    local glassObjectDel = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01b'), 0, 0, 0)
    DeleteObject(glassObjectDel)
    StopParticleFxLooped(ptfx, 1)
end)

local outsideloop = false
function self.Outside()
    if not outsideloop then
        outsideloop = true
        utils.notify(Strings['deliver_to_buyer'])
        lib.requestModel('baller')
        local coords = Config['VangelicoHeist']['finishHeist']['buyerPos']
        SetNewWaypoint(coords.x, coords.y)
        local buyerBlip = self.addBlip(coords, 500, 0, Strings['buyer_blip'])
        local buyerVehicle = CreateVehicle(GetHashKey('baller'), Config['VangelicoHeist']['finishHeist']['buyerPos'].xy + 3.0, Config['VangelicoHeist']['finishHeist']['buyerPos'].z, 269.4, 0, 0)
        CreateThread(function()
            while true do
                local ped = PlayerPedId()
                local pedCo = GetEntityCoords(ped)
                local dist = #(pedCo - Config['VangelicoHeist']['finishHeist']['buyerPos'])

                if dist <= 15.0 and GetEntitySpeed(ped) < 2.0 then
                    self.PlayCutscene('hs3f_all_drp3', Config['VangelicoHeist']['finishHeist']['buyerPos'])
                    DeleteVehicle(buyerVehicle)
                    RemoveBlip(buyerBlip)
                    TriggerServerEvent('vangelicoheist:server:sellRewardItems')
                    outsideloop = false
                    break
                end
                Wait(1)
            end
        end)
    end
end

function self.addBlip(coords, sprite, colour, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end
