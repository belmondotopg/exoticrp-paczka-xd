local esx_hud = exports.esx_hud
local ox_target = exports.ox_target
local libCache = lib.onCache
local cache = {}

libCache('ped', function(ped)
    cache.ped = ped
end)

libCache('coords', function(coords)
    cache.coords = coords
end)

local function openSellerMenu()
    lib.callback('esx_drops/server/getMarketInfo', false, function(stock, nextRestock)
        lib.registerContext({
            id = "openSellerMenu",
            title = "Nieznajomy",
            options = {
                {
                    title = "Nieoznakowana flara",
                    description = stock > 0 and "Pozostało sztuk: " .. stock .. "." or "Wyczerpano zapasy następna dostawa odbędzie się " .. nextRestock .. ".",
                    disabled = stock < 1,
                    onSelect = function()
                        if stock > 0 then
                            TriggerServerEvent('esx_drops/server/buyFlare')
                            lib.hideContext("openSellerMenu")
                        else
                            ESX.ShowNotification('No chyba mówię, że nie mam!?')
                        end
                    end,
                }
            }
        })

        lib.showContext("openSellerMenu")
    end)
end

local function onEnter(point)
	if not point.entity then
		local model = lib.requestModel(`a_m_m_og_boss_01`)

		Citizen.Wait(1000)

		local entity = CreatePed(0, model, point.coords.x, point.coords.y, point.coords.z, point.heading, false, true)
	
		TaskStartScenarioInPlace(entity, 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT_CLUBHOUSE', 0, true)
	
		SetModelAsNoLongerNeeded(model)
		FreezeEntityPosition(entity, true)
		SetEntityInvincible(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)

        ox_target:addLocalEntity(entity, {
            {
                icon = 'fa fa-laptop',
                label = point.label,
                canInteract = function()
                    if LocalPlayer.state.IsDead or LocalPlayer.state.IsHandcuffed then return false end
                    if LocalPlayer.state.ProtectionTime ~= nil and LocalPlayer.state.ProtectionTime > 0 then return false end
                    return true
                    -- return Config.AllowedJobs[exports['op-crime']:getPlayerOrganisation().id]
                end,
                onSelect = function()
                    openSellerMenu()
                end,
                distance = 2.0
            }
        })

		point.entity = entity
	end
end

local function onExit(point)
	local entity = point.entity

	if not entity then return end

	ox_target:removeLocalEntity(entity, point.label)
	
	if DoesEntityExist(entity) then
		SetEntityAsMissionEntity(entity, false, true)
		DeleteEntity(entity)
	end

	point.entity = nil
end

Citizen.CreateThread(function ()
    for k, v in pairs(Config.Peds) do
        lib.points.new({
            id = v.id,
            distance = v.distance,
            coords = v.coords,
            heading = v.heading,
            label = v.label,
            onEnter = onEnter,
            onExit = onExit,
        })
    end
end)

local dropBlip = nil

local function getGroundZ(x, y, z)
    local found, ground = GetGroundZFor_3dCoord(x, y, z + 1.0, 0)
    return found and ground or z
end

local function clearLocalDrop()
    if Global.particle then StopParticleFxLooped(Global.particle, 0) Global.particle = nil end
    if Global.objects.box then DeleteEntity(Global.objects.box) Global.objects.box = nil end
    if Global.objects.flare then DeleteObject(Global.objects.flare) Global.objects.flare = nil end
    if dropBlip then RemoveBlip(dropBlip) end
end

local function getLoot(id)
    ESX.ShowNotification("Otwierasz skrzynkę!")

    if esx_hud:progressBar({
        duration = 10,
        label = 'Zbieranie zrzutu',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        },
        anim = {
            dict = 'mini@repair',
            clip = 'fixing_a_player'
        },
        prop = {},
    })
    then
        lib.callback('esx_drops/server/getLootReward', false, function(r)
            if not r then return end
            local m = "Otrzymałeś nagrodę: "
            if r.items then for _, v in ipairs(r.items) do m = m .. (v.count .. "x " .. v.name .. ", ") end end
            if r.money and r.money > 0 then m = m .. r.money .. " " .. (r.money_type or "gotówki") end
            ESX.ShowNotification(m)
        end, id, {x = cache.coords.x, y = cache.coords.y, z = cache.coords.z})
    else 
        ESX.ShowNotification('Anulowano.')
    end

    clearLocalDrop()
    Global.DropBoxes[id] = nil
    TriggerServerEvent('esx_drops/server/clearDrop', id)
end

local function createDropBox(id, coords, heading, openTimestamp)
    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Wait(10) end
    UseParticleFxAssetNextCall('core')
    Global.particle = StartParticleFxLoopedAtCoord(Config.FlareParticle, coords.x, coords.y, coords.z + 0.5, 0.0, 0.0, heading, 1.0, false, false, false, false)

    RequestModel(Config.DropBoxModel)
    while not HasModelLoaded(Config.DropBoxModel) do Wait(10) end
    RequestModel(Config.DropParachuteModel)
    while not HasModelLoaded(Config.DropParachuteModel) do Wait(10) end

    Global.openTimestamp = openTimestamp

    local startZ = coords.z + 30.0
    local targetZ = getGroundZ(coords.x, coords.y, startZ)
    Global.objects.box = CreateObject(Config.DropBoxModel, coords.x, coords.y, startZ, true, true, false)
    SetEntityRotation(Global.objects.box, 0, 0, heading, 2, true)
    local parachuteObj = CreateObject(Config.DropParachuteModel, coords.x, coords.y, startZ + Config.ParachuteOffset, true, true, false)
    local startTime = GetGameTimer()
    
    dropBlip = AddBlipForCoord(coords.x, coords.y, startZ)
    SetBlipSprite(dropBlip, 94)
    SetBlipColour(dropBlip, 50)
    SetBlipScale(dropBlip, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("# Zrzut")
    EndTextCommandSetBlipName(dropBlip)

    while true do
        local now = GetGameTimer()
        local progress = math.min(1.0, (now - startTime) / Config.FallTime)
        local currentZ = startZ - (startZ - targetZ) * progress
        SetEntityCoords(Global.objects.box, coords.x, coords.y, currentZ, false, false, false, false)
        SetEntityCoords(parachuteObj, coords.x, coords.y, currentZ + Config.ParachuteOffset, false, false, false, false)
        if progress >= 1.0 then break end
        Wait(0)
    end

    SetEntityCoords(Global.objects.box, coords.x, coords.y, targetZ, false, false, false, false)
    PlaceObjectOnGroundProperly(Global.objects.box)
    SetEntityCoords(parachuteObj, coords.x, coords.y, targetZ + Config.ParachuteOffset, false, false, false, false)
    Wait(1000)
    DeleteEntity(parachuteObj)

    Citizen.CreateThread(function ()
        Wait(Global.duiTimestamp*60*1000)
        removeDui(Global.objects.box)
        exports.ox_target:addLocalEntity(Global.objects.box, {
            {
                label = "Otwórz skrzynkę",
                icon = "fa-solid fa-box-open",
                onSelect = function() getLoot(id) end
            }
        })
    end)
    Citizen.CreateThread(function ()
        createDUI(Global.objects.box)
    end)

    Global.DropBoxes[id] = Global.objects.box

    CreateThread(function()
        Wait(1800000)
        TriggerServerEvent('esx_drops/server/clearDrop', id)
        clearLocalDrop()
        Global.DropBoxes[id] = nil
    end)
end

RegisterNetEvent('esx_drops/client/spawnDrop', function(id, coords, heading, openTimestamp)
    createDropBox(id, coords, heading, openTimestamp)
end)

RegisterNetEvent('esx_drops/client/clearDrop', function()
    clearLocalDrop()
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    clearLocalDrop()
end)

local lastFlareUse = 0

local function isDropAllowed(coords)
    local endPos = vector3(coords.x, coords.y, coords.z - 50.0)
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, endPos.x, endPos.y, endPos.z, 1, cache.ped, 0)
    local _, hit, hitCoords, _, material = GetShapeTestResultEx(rayHandle)

    if not hit then
        ESX.ShowNotification('Nie możesz rzucić flary w tym miejscu, znajdź inne!')
        return false
    end

    local roofMaterials = {
        [282940568] = true,
        [951832588] = true,
        [-461750719] = true,
        [2128369009] = true,
        [-840216541] = true,
        [-1885547121] = true,
        [-1286696947] = true,
        [1333033863] = true,
        [-1084640111] = true,
        [510490462] = true,
        [765206029] = true,
    }

    if roofMaterials[material] then
        local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
        if found then
            local unix = GetCloudTimeAsInt()
            local offset = 2
            local hour = (math.floor(unix / 3600) + offset) % 24
            local isHourAllowed = (hour >= 10 or hour < 3)

            if not isHourAllowed then
                ESX.ShowNotification('Zrzuty są możliwe tylko w godzinach 10:00–03:00!')
                return false
            end

            if GlobalState.Counter['players'] < Config.MinimumPlayers then
                ESX.ShowNotification('Na serwerze musi być co najmniej ' .. Config.MinimumPlayers .. ' graczy, aby użyć flary!')
                return false
            end

            return true
        end
    end

    ESX.ShowNotification('Nie możesz rzucić flary w tym miejscu, znajdź inne!')
    return false
end

RegisterCommand('showmat', function()
    local endPos = vector3(cache.coords.x, cache.coords.y, cache.coords.z - 50.0)
    local rayHandle = StartShapeTestRay(cache.coords.x, cache.coords.y, cache.coords.z, endPos.x, endPos.y, endPos.z, 1, cache.ped, 0)
    local _, hit, hitCoords, _, material = GetShapeTestResultEx(rayHandle)
    print('Material: ', material)
end)

local function useDropFlare()
    if isDropAllowed(cache.coords and cache.coords or GetEntityCoords(cache.ped)) then
        local now = GetGameTimer()
        if now - lastFlareUse < 5000 then return end
        lastFlareUse = now

        lib.callback('esx_drops:canUseFlare', false, function(canUse)
            if not canUse then return end

            RequestAnimDict('amb@world_human_bum_wash@male@low@base')
            while not HasAnimDictLoaded('amb@world_human_bum_wash@male@low@base') do Wait(10) end
            TaskPlayAnim(cache.ped, 'amb@world_human_bum_wash@male@low@base', 'base', 8.0, -8.0, 800, 1, 0, false, false, false)
            Wait(1000)

            local flareModel = `prop_flare_01`
            RequestModel(flareModel)
            while not HasModelLoaded(flareModel) do Wait(10) end

            Global.objects.flare = CreateObject(flareModel, cache.coords.x, cache.coords.y, cache.coords.z + 0.2, true, true, true)
            AttachEntityToEntity(Global.objects.flare, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.12, 0.02, -0.02, 60.0, 140.0, 20.0, true, true, false, true, 1, true)
            Wait(700)

            DetachEntity(Global.objects.flare, true, true)
            local velocity = GetEntityForwardVector(cache.ped) * 5.0
            ApplyForceToEntity(Global.objects.flare, 1, velocity.x, velocity.y, 1.5, 0.0, 0.0, 0.0, 0, false, true, true, false, true)

            Wait(5000)

            local coords = GetEntityCoords(Global.objects.flare)
            local heading = GetEntityHeading(cache.ped)
            local id = math.random(100000, 999999)
            TriggerServerEvent('esx_drops/server/broadcastDrop', id, vec3(coords.x, coords.y, coords.z - 0.5), heading)
        end)
    end
end

exports('useDropFlare', useDropFlare)