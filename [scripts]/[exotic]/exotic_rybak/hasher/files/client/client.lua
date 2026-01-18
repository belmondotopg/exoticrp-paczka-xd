local ESX = exports['es_extended']:getSharedObject()

local COOLDOWN_TIME = 2000
local HEADSHOT_TIMEOUT = 1000
local ANIMATION_DICT = "amb@world_human_stand_fishing@idle_a"
local ANIMATION_NAME = "idle_c"
local EQUIP_ANIM_DICT = "reaction@intimidation@1h"
local EQUIP_ANIM_NAME = "intro"
local EQUIP_ANIM_DURATION = 1000
local EQUIP_ATTACH_MS = 350

local ROD_ATTACH_BONE = 18905 
local ROD_ATTACH_POS = { x = 0.12, y = 0.04, z = 0.01 }
local ROD_ATTACH_ROT = { x = -90.0, y = -10.0, z = -20.0 }
local ROD_MODEL = `prop_fishing_rod_01`
local TOGGLE_ROD_COOLDOWN_MS = 1500

local PlayerState = {
    isFishing = false,
    isMenuOpen = false,
    lastFishingAttempt = 0,
    isRodEquipped = false,
    activeRod = { name = nil, slot = nil, metadata = nil },
    fishingRodProp = nil,
    currentHeadshotHandle = nil,
    autoFishingActive = false
}

local FishermanInteractions = {}

local MinigameState = {
    awaiting = false,
    result = false
}

local RodItemNames = {}
local RodLabels = {}

local ICON_TEX_DICT = 'ikonka'
local ICON_TEX_NAME = 'ikonka'
local ICON_Z_OFFSET = 0.45
local ICON_SIZE = 0.06 

local HEAD_BONE = 31086

local ToggleGuard = { inProgress = false, lastToggleTime = 0 }

local function canToggleRod()
    if ToggleGuard.inProgress then return false end
    local now = GetGameTimer()
    return (now - ToggleGuard.lastToggleTime) >= TOGGLE_ROD_COOLDOWN_MS
end

local function startToggleRod()
    ToggleGuard.inProgress = true
end

local function finishToggleRod()
    ToggleGuard.inProgress = false
    ToggleGuard.lastToggleTime = GetGameTimer()
end

local iconResolutionCache = nil
local function getIconResolution()
    if iconResolutionCache then return iconResolutionCache end
    local res = GetTextureResolution(ICON_TEX_DICT, ICON_TEX_NAME)
    if res and res.x and res.y and res.x > 0 and res.y > 0 then
        iconResolutionCache = res
    else
        iconResolutionCache = { x = 512.0, y = 512.0 }
    end
    return iconResolutionCache
end

local function loadIconTextureDict()
    if HasStreamedTextureDictLoaded(ICON_TEX_DICT) then return true end
    RequestStreamedTextureDict(ICON_TEX_DICT, false)
    local startTime = GetGameTimer()
    while not HasStreamedTextureDictLoaded(ICON_TEX_DICT) do
        if GetGameTimer() - startTime > 1500 then
            return false
        end
        Wait(0)
    end
    return true
end


local function blinkIconAboveHead(times, totalDurationMs)
    times = times or 3
    totalDurationMs = totalDurationMs or 2000
    if not loadIconTextureDict() then return end

    local playerPed = PlayerPedId()
    local perBlink = math.max(1, math.floor(totalDurationMs / times))
    local onMs = math.floor(perBlink * 0.6)
    local offMs = perBlink - onMs
    
    for i = 1, times do
        local drawUntil = GetGameTimer() + onMs
        while GetGameTimer() < drawUntil do
            if not PlayerState.isFishing then break end
            Wait(0)
            
            local headIndex = GetPedBoneIndex(playerPed, HEAD_BONE)
            local hx, hy, hz = table.unpack(GetWorldPositionOfEntityBone(playerPed, headIndex))
            local onScreen, sx, sy = World3dToScreen2d(hx, hy, hz + ICON_Z_OFFSET)
            
            if onScreen then
                local res = getIconResolution()
                local texAspect = res.x / res.y
                local screenAR = GetAspectRatio(false)
                local height = ICON_SIZE
                local width = height * (texAspect / screenAR)
                DrawSprite(ICON_TEX_DICT, ICON_TEX_NAME, sx, sy, width, height, 0.0, 255, 255, 255, 255)
            end
        end
        
        if not PlayerState.isFishing then break end
        Wait(offMs)
    end

    SetStreamedTextureDictAsNoLongerNeeded(ICON_TEX_DICT)
end

CreateThread(function()
    while not Config or not Config.RodTypes do
        Wait(100)
    end
    
    for _, rod in ipairs(Config.RodTypes) do
        RodItemNames[rod.name] = true
        RodLabels[rod.name] = rod.label
    end
end)

local function cleanupRodProp()
    if PlayerState.fishingRodProp and DoesEntityExist(PlayerState.fishingRodProp) then
        DetachEntity(PlayerState.fishingRodProp, false, false)
        DeleteEntity(PlayerState.fishingRodProp)
    end
    PlayerState.fishingRodProp = nil
end

local function resetPlayerState()
    PlayerState.activeRod = { name = nil, slot = nil, metadata = nil }
    PlayerState.isRodEquipped = false
    PlayerState.isFishing = false
    PlayerState.autoFishingActive = false
    cleanupRodProp()
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('exotic_rybak:setActiveRod', nil, nil)
end

local function stopFishing()
    if not PlayerState.isFishing then return end
    
    PlayerState.isFishing = false
    MinigameState.awaiting = false

    if exports['esx_hud']:progressActive() then exports['esx_hud']:cancelExportProgress() end

    if not PlayerState.isMenuOpen then
        SetNuiFocus(false, false)
    end
    SendNUIMessage({ type = 'closeMinigame' })

    local ped = PlayerPedId()
    for i = 1, 5 do
        if IsEntityPlayingAnim(ped, ANIMATION_DICT, ANIMATION_NAME, 3) then
            StopAnimTask(ped, ANIMATION_DICT, ANIMATION_NAME, 1.0)
        else
            break
        end
        Wait(0)
    end
    ClearPedSecondaryTask(ped)
    ClearPedTasksImmediately(ped)
end

local function cancelFishing()
    if not PlayerState.isFishing then return end
    
    stopFishing()
    PlayerState.autoFishingActive = false
    ESX.ShowNotification('Anulowano łowienie.')
end

local function isValidFishingLocation(coords)
    local x, y, z = table.unpack(coords)
    
    if #(coords - vec3(-1849.3638, -1244.2877, 8.6158)) <= 20.0 then
        return true
    end
    
    if Config and Config.FishingZones then
        for _, zone in ipairs(Config.FishingZones) do
            if zone.fishingCoords and zone.fishingRadius then
                local distance = #(coords - zone.fishingCoords)
                if distance <= zone.fishingRadius then
                    return true
                end
            end
        end
    end
    
    return false
end

local function canStartFishing()
    local playerPed = PlayerPedId()
    local currentTime = GetGameTimer()
    
    if not PlayerState.isRodEquipped then
        return false
    end
    
    if PlayerState.isFishing then
        stopFishing()
        return false
    end
    
    if currentTime - PlayerState.lastFishingAttempt < COOLDOWN_TIME then
        ESX.ShowNotification('Musisz chwilę poczekać...')
        return false
    end
    
    if IsPedInAnyVehicle(playerPed, false) then
        ESX.ShowNotification('Nie możesz łowić z pojazdu.')
        return false
    end
    
    if IsPedSwimming(playerPed) or IsPedSwimmingUnderWater(playerPed) then
        ESX.ShowNotification('Nie możesz łowić, będąc w wodzie!')
        return false
    end
    
    if not isValidFishingLocation(GetEntityCoords(playerPed)) then
        ESX.ShowNotification('Musisz być przy wodzie!')
        return false
    end
    
    if exports['esx_hud']:progressActive() then 
        return false 
    end
    
    return true
end

local function equipRod(name, slotId, metadata)
    if not canToggleRod() then return end
    startToggleRod()
    local playerPed = PlayerPedId()

    if not lib.requestModel(ROD_MODEL, 500) then
        ESX.ShowNotification('Błąd ładowania modelu wędki.')
        finishToggleRod()
        return
    end
    
    cleanupRodProp()


    if lib.requestAnimDict(EQUIP_ANIM_DICT, 500) then
        exports['esx_hud']:progressBar({
            duration = EQUIP_ANIM_DURATION / 1000,
            label = 'Wyciąganie wędki... (X - anuluj)',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false
            },
            anim = {
                dict = EQUIP_ANIM_DICT,
                clip = EQUIP_ANIM_NAME,
                flag = 49
            },
            prop = {}
        })
        TaskPlayAnim(playerPed, EQUIP_ANIM_DICT, EQUIP_ANIM_NAME, 5.0, 5.0, EQUIP_ANIM_DURATION, 49, 0, false, false, false)

        Wait(EQUIP_ATTACH_MS)
        PlayerState.fishingRodProp = CreateObject(ROD_MODEL, 0.0, 0.0, 0.0, true, true, false)
        if DoesEntityExist(PlayerState.fishingRodProp) then
            AttachEntityToEntity(
                PlayerState.fishingRodProp,
                playerPed,
                GetPedBoneIndex(playerPed, ROD_ATTACH_BONE),
                ROD_ATTACH_POS.x, ROD_ATTACH_POS.y, ROD_ATTACH_POS.z,
                ROD_ATTACH_ROT.x, ROD_ATTACH_ROT.y, ROD_ATTACH_ROT.z,
                true, true, false, true, 1, true
            )
        end
        Wait(math.max(0, EQUIP_ANIM_DURATION - EQUIP_ATTACH_MS))
        ClearPedTasks(playerPed)
        if lib.requestAnimDict(ANIMATION_DICT, 500) then
            TaskPlayAnim(playerPed, ANIMATION_DICT, ANIMATION_NAME, 2.0, 2.0, 1200, 49, 0, false, false, false)
        end
    else
        PlayerState.fishingRodProp = CreateObject(ROD_MODEL, 0.0, 0.0, 0.0, true, true, false)
        if DoesEntityExist(PlayerState.fishingRodProp) then
            AttachEntityToEntity(
                PlayerState.fishingRodProp,
                playerPed,
                GetPedBoneIndex(playerPed, ROD_ATTACH_BONE),
                ROD_ATTACH_POS.x, ROD_ATTACH_POS.y, ROD_ATTACH_POS.z,
                ROD_ATTACH_ROT.x, ROD_ATTACH_ROT.y, ROD_ATTACH_ROT.z,
                true, true, false, true, 1, true
            )
        end
    end

    if DoesEntityExist(PlayerState.fishingRodProp) then
        PlayerState.activeRod = { name = name, slot = slotId, metadata = metadata }
        PlayerState.isRodEquipped = true
        ESX.ShowNotification(('Wyposażono: %s'):format(RodLabels[name] or name))
        TriggerServerEvent('exotic_rybak:setActiveRod', name, slotId)
    else
        ESX.ShowNotification('Błąd tworzenia wędki.')
    end
    
    SetModelAsNoLongerNeeded(ROD_MODEL)
    finishToggleRod()
end

local function unequipRod()
    if not canToggleRod() then return end
    startToggleRod()
    local playerPed = PlayerPedId()
    
    if lib.requestAnimDict(EQUIP_ANIM_DICT, 500) then
        exports['esx_hud']:progressBar({
            duration = 1,
            label = 'Chowanie wędki... (X - anuluj)',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
                mouse = false
            },
            anim = {
                dict = EQUIP_ANIM_DICT,
                clip = 'outro',
                flag = 49
            },
            prop = {}
        })
        TaskPlayAnim(playerPed, EQUIP_ANIM_DICT, 'outro', 5.0, 5.0, 1000, 49, 0, false, false, false)
        Wait(500)
        cleanupRodProp()
        Wait(500)
        ClearPedTasks(playerPed)
    else

        cleanupRodProp()

    end
    
    resetPlayerState()
    ESX.ShowNotification('Schowałeś wędkę.')
    finishToggleRod()
end

local function waitForBite()
    local totalDelay = math.random(8000, 15000)
    local preBlinkMs = 2000
    local idleMs = math.max(0, totalDelay - preBlinkMs)
    local endAt = GetGameTimer() + idleMs

    local playerPed = PlayerPedId()
    while PlayerState.isFishing and GetGameTimer() < endAt do
        Wait(0)
        DisableControlAction(0, 20, true)
        DisableControlAction(0, 30, true) -- Move Left/Right
        DisableControlAction(0, 31, true) -- Move Forward/Backward
        DisableControlAction(0, 32, true) -- Move Up/Down
        
        if IsControlJustPressed(0, 73) then
            cancelFishing()
            return false
        end
        
        if not IsEntityPlayingAnim(playerPed, ANIMATION_DICT, ANIMATION_NAME, 3) then
            TaskPlayAnim(playerPed, ANIMATION_DICT, ANIMATION_NAME, 3.0, 3.0, -1, 49, 0, false, false, false)
        end
    end

    if not PlayerState.isFishing then return false end

    blinkIconAboveHead(3, preBlinkMs)
    return PlayerState.isFishing
end

local function startFishing()
    local playerPed = PlayerPedId()
    
    if not lib.requestAnimDict(ANIMATION_DICT, 500) then
        ESX.ShowNotification('Błąd ładowania animacji.')
        return
    end
    
    TaskPlayAnim(playerPed, ANIMATION_DICT, ANIMATION_NAME, 3.0, 3.0, -1, 49, 0, false, false, false)
    
    PlayerState.lastFishingAttempt = GetGameTimer()
    PlayerState.isFishing = true
    ESX.ShowNotification('Zarzuciłeś wędkę. Czekaj na branie...')
    
    if not waitForBite() then 
        stopFishing()
        return 
    end
    
    ESX.ShowNotification('Branie! Ciągnij!')

    MinigameState.awaiting = true
    MinigameState.result = false
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openMinigame',
        minigame = {
            durationMs = 7000,
            holdTimeMs = 3000,
            zoneWidth = 0.22,
            cursorSpeed = 0.7,
            zoneSpeed = 0.35,
        }
    })

    while MinigameState.awaiting do
        Wait(0)
        DisableControlAction(0, 30, true) -- Move Left/Right
        DisableControlAction(0, 31, true) -- Move Forward/Backward
        DisableControlAction(0, 32, true) -- Move Up/Down
        
        if not PlayerState.isFishing then
            break
        end
        
        if IsControlJustPressed(0, 73) then
            cancelFishing()
            break
        end
    end
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'closeMinigame' })

    TriggerServerEvent('exotic_rybak:finishFishing', MinigameState.result)
    
    if MinigameState.result then
         exports['esx_hud']:progressBar({
            duration = 2,
            label = 'Wyciąganie ryby... (X - anuluj)',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = false,
                move = true,
                combat = true,
                mouse = false
            },
            anim = {
                dict = ANIMATION_DICT,
                clip = ANIMATION_NAME,
                flag = 49
            },
            prop = {}
        })
           
        
    else
        ESX.ShowNotification('Ryba uciekła...')
    end
    
    stopFishing()
    
    if PlayerState.autoFishingActive then
        CreateThread(function()
            Wait(2500)
            if PlayerState.isRodEquipped and not PlayerState.isFishing and PlayerState.autoFishingActive then
                if canStartFishing() then
                    ESX.TriggerServerCallback('exotic_rybak:canStartFishing', function(canFish, reason)
                        if canFish then
                            startFishing()
                        else
                            ESX.ShowNotification(reason)
                            PlayerState.autoFishingActive = false
                        end
                    end)
                end
            end
        end)
    else
        ESX.ShowNotification('Naciśnij ~g~E~s~ aby kontynuować łowienie lub ~r~X~s~ aby schować wędkę.')
    end
end

local function cleanupHeadshot()
    if PlayerState.currentHeadshotHandle then
        UnregisterPedheadshot(PlayerState.currentHeadshotHandle)
        PlayerState.currentHeadshotHandle = nil
    end
end

local function updatePlayerAvatarInNUI()
    CreateThread(function()
        cleanupHeadshot()
        
        PlayerState.currentHeadshotHandle = RegisterPedheadshotTransparent(PlayerPedId())
        local startTime = GetGameTimer()
        
        while not IsPedheadshotReady(PlayerState.currentHeadshotHandle) do
            if GetGameTimer() - startTime > HEADSHOT_TIMEOUT then
                cleanupHeadshot()
                return
            end
            Wait(10)
        end
        
        if IsPedheadshotReady(PlayerState.currentHeadshotHandle) then
            local avatarTxd = GetPedheadshotTxdString(PlayerState.currentHeadshotHandle)
            if avatarTxd then
                SendNUIMessage({
                    type = 'updateAvatar',
                    avatar = ('https://nui-img/%s/%s?t=%s'):format(avatarTxd, avatarTxd, GetGameTimer())
                })
            end
        end
    end)
end

AddEventHandler('ox_inventory:usedItem', function(name, slotId, metadata)
    if not RodItemNames[name] then return end
    
    if PlayerState.activeRod.name then
        if PlayerState.activeRod.slot == slotId or PlayerState.activeRod.name == name then
            if PlayerState.isFishing then
                cancelFishing()
            end
            unequipRod()
        else
            ESX.ShowNotification('Musisz najpierw schować aktualnie używaną wędkę.')
        end
    else
        equipRod(name, slotId, metadata)
        ESX.ShowNotification('Naciśnij ~g~E~s~ aby rozpocząć łowienie lub ~r~X~s~ aby schować wędkę.')
    end
end)

RegisterNetEvent('exotic_rybak:hideRod', function()
    resetPlayerState()
end)

RegisterNetEvent('exotic_rybak:rodUpgraded', function(newRodData)
    SendNUIMessage({
        type = 'rodUpgraded',
        newRod = newRodData
    })
end)

RegisterNetEvent('exotic_rybak:fishResult', function(fishData)
    if not fishData or not fishData.name then
        ESX.ShowNotification('Ryba uciekła!')
        return
    end
    
    local rarityColors = {
        common = '~b~',
        rare = '~g~',
        epic = '~p~',
        legendary = '~o~'
    }
    
    local rarityColor = rarityColors[fishData.rarity] or '~b~'
    local fishMessage = ('Złowiłeś %s%s~s~ (%.2f kg) i zdobyłeś ~g~%d XP~s~.'):format(
        rarityColor, fishData.name, fishData.weight, fishData.xp
    )
    
    ESX.ShowNotification(fishMessage)
    
    if PlayerState.autoFishingActive then
        CreateThread(function()
            Wait(1000)
            if PlayerState.isRodEquipped and not PlayerState.isFishing and PlayerState.autoFishingActive then
                if canStartFishing() then
                    ESX.TriggerServerCallback('exotic_rybak:canStartFishing', function(canFish, reason)
                        if canFish then
                            startFishing()
                        else
                            ESX.ShowNotification(reason)
                            PlayerState.autoFishingActive = false
                        end
                    end)
                end
            end
        end)
    else
        ESX.ShowNotification('Naciśnij ~g~E~s~ aby kontynuować łowienie lub ~r~X~s~ aby schować wędkę.')
    end
end)

AddEventHandler('esx:onPlayerDeath', function()
    resetPlayerState()
    stopFishing()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        cleanupRodProp()
        cleanupHeadshot()
        stopFishing()
        
        if GetResourceState('interactions') == 'started' then
            for _, coords in ipairs(FishermanInteractions) do
                exports["interactions"]:removeInteraction(coords)
            end
            FishermanInteractions = {}
        end
    end
end)

CreateThread(function()
    Wait(1000)
    
    local playerPed = PlayerPedId()
    
    if IsEntityPlayingAnim(playerPed, ANIMATION_DICT, ANIMATION_NAME, 3) then
        ClearPedTasks(playerPed)
    end
    
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyObjects = GetGamePool('CObject')
    
    for i = 1, #nearbyObjects do
        local obj = nearbyObjects[i]
        if DoesEntityExist(obj) and GetEntityModel(obj) == ROD_MODEL then
            local objCoords = GetEntityCoords(obj)
            if #(playerCoords - objCoords) < 10.0 then 
                if IsEntityAttachedToEntity(obj, playerPed) then
                    DetachEntity(obj, false, false)
                end
                DeleteEntity(obj)
            end
        end
    end
    
    PlayerState = {
        isFishing = false,
        isMenuOpen = false,
        lastFishingAttempt = 0,
        isRodEquipped = false,
        activeRod = { name = nil, slot = nil, metadata = nil },
        fishingRodProp = nil,
        currentHeadshotHandle = nil,
        autoFishingActive = false
    }
    
    TriggerServerEvent('exotic_rybak:setActiveRod', nil, nil)
end)

CreateThread(function()
    local lastHadRod = true
    while true do
        Wait(750)
        if PlayerState.isRodEquipped and PlayerState.activeRod and PlayerState.activeRod.name and PlayerState.activeRod.slot then
            local found = false
            local items = exports.ox_inventory:Search('slots', PlayerState.activeRod.name)
            if type(items) == 'table' then
                for _, item in pairs(items) do
                    if item and item.slot == PlayerState.activeRod.slot then
                        found = true
                        break
                    end
                end
            end
            if not found then
                resetPlayerState()
                lastHadRod = false
            else
                lastHadRod = true
            end
        else
            lastHadRod = false
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if PlayerState.isFishing then
            DisableControlAction(0, 30, true) -- Move Left/Right
            DisableControlAction(0, 31, true) -- Move Forward/Backward
            DisableControlAction(0, 32, true) -- Move Up/Down
            DisableControlAction(0, 21, true) -- Sprint
            DisableControlAction(0, 22, true) -- Jump
        else
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        
        if PlayerState.isRodEquipped and not PlayerState.isFishing and not PlayerState.isMenuOpen then
            if IsControlJustPressed(0, 38) then
                if canStartFishing() then
                    ESX.TriggerServerCallback('exotic_rybak:canStartFishing', function(canFish, reason)
                        if canFish then
                            PlayerState.autoFishingActive = true
                            startFishing()
                        else
                            ESX.ShowNotification(reason)
                        end
                    end)
                end
            end
            
            if IsControlJustPressed(0, 73) then
                if PlayerState.isFishing then
                    cancelFishing()
                end
                PlayerState.autoFishingActive = false
                unequipRod()
            end
        else
            Wait(500)
        end
    end
end)


exports('openClam', function()
    if exports['esx_hud']:progressActive() then return end
    
    local success = exports['esx_hud']:progressBar({
        duration = 2.5,
        label = 'Otwieranie małży... (X - anuluj)',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {},
        prop = {}
    })
    local success = true

    if success then
        TriggerServerEvent('exotic_rybak:openClam')
    end
end)

exports('openCase', function()
    if exports['esx_hud']:progressActive() then return end
    
    local success = exports['esx_hud']:progressBar({
        duration = 2.5,
        label = 'Otwieranie skrzynki... (X - anuluj)',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {},
        prop = {}
    })

    if success then
        TriggerServerEvent('exotic_rybak:openCase')
    end
end)

CreateThread(function()
    while not Config or not Config.FishingZones do
        Wait(100)
    end
    
    for _, zone in ipairs(Config.FishingZones) do
        local menuCoords = nil
        if zone.npc and zone.npc.coords then
            menuCoords = zone.npc.coords
        elseif zone.fishingCoords then
            menuCoords = zone.fishingCoords
        end
        
        if menuCoords then
            local interactionCoords = vec3(menuCoords.x, menuCoords.y, menuCoords.z)
            

            if GetResourceState('interactions') == 'started' then
                exports["interactions"]:showInteraction(
                    interactionCoords,
                    "fa-solid fa-fish",
                    "ALT",
                    "Rybak",
                    "Naciśnij ALT aby porozmawiać z rybakiem"
                )
                table.insert(FishermanInteractions, interactionCoords)
            end
            
            exports.ox_target:addSphereZone({
                coords = interactionCoords,
                radius = 2.0,
                options = {
                    {
                        icon = 'fa-solid fa-fish',
                        label = 'Porozmawiaj z rybakiem',
                        onSelect = function()
                            if PlayerState.isMenuOpen then return end
                            
                            if PlayerState.isFishing then
                                ESX.ShowNotification('Nie możesz otworzyć menu podczas łowienia!')
                                return
                            end
                            
                            ESX.TriggerServerCallback('exotic_rybak:getFishermanData', function(data)
                                if not data then return end
                                
                                SetNuiFocus(true, true)
                                SendNUIMessage({
                                    type = 'openRybak',
                                    stats = data.stats,
                                    ranking = data.ranking,
                                    rankingGracze = data.rankingGracze,
                                    achievements = data.achievements,
                                    dailyMissions = data.dailyMissions
                                })
                                PlayerState.isMenuOpen = true
                                updatePlayerAvatarInNUI()
                            end)
                        end,
                        distance = 2.0
                    },
                    {
                        icon = 'fa-solid fa-dollar-sign',
                        label = 'Sprzedaj ryby / perły',
                        onSelect = function()
                            ESX.TriggerServerCallback('exotic_rybak:openSell', function(stashId)
                                if stashId then
                                    exports.ox_inventory:openInventory('stash', stashId)
                                end
                            end)
                        end,
                        distance = 2.0
                    }
                }
            })
        end
        
        if zone.blip and zone.blip.enabled then
            local coords = zone.npc and zone.npc.coords or zone.fishingCoords
            if coords then
                local x, y, z = coords.x, coords.y, coords.z
                
                local blip = AddBlipForCoord(x, y, z)
                SetBlipSprite(blip, zone.blip.sprite)
                SetBlipColour(blip, zone.blip.colour)
                SetBlipScale(blip, zone.blip.scale)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(zone.blip.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)

CreateThread(function()
    while not Config or not Config.FishingZones do
        Wait(100)
    end
    
    for _, zone in ipairs(Config.FishingZones) do
        if zone.npc and zone.npc.coords then
            local npcCoords = zone.npc.coords
            local model = type(zone.npc.model) == 'string' and joaat(zone.npc.model) or zone.npc.model
            
            if not IsModelInCdimage(model) then
                print(("^3[exotic_rybak]^0 Warning: Model %s (hash: %d) not found, skipping NPC spawn for zone: %s"):format(
                    tostring(zone.npc.model), model, zone.name or "Unknown"
                ))
            else
                if lib.requestModel(model, 10000) then
                    local fisherman = CreatePed(0, model, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcCoords.w, false, false)
                    
                    if DoesEntityExist(fisherman) then
                        SetEntityInvincible(fisherman, true)
                        SetBlockingOfNonTemporaryEvents(fisherman, true)
                        FreezeEntityPosition(fisherman, true)
                        SetModelAsNoLongerNeeded(model)
                    end
                else
                    print(("^1[exotic_rybak]^0 Error: Failed to load model %s (hash: %d) after 10 seconds timeout for zone: %s"):format(
                        tostring(zone.npc.model), model, zone.name or "Unknown"
                    ))
                end
            end
        end
    end
end)

RegisterNUICallback('finishMinigame', function(data, cb)
    MinigameState.result = data and data.success == true
    MinigameState.awaiting = false
    cb({ ok = true })
end)

RegisterNUICallback('closeRanking', function(_, cb)
    cleanupHeadshot()
    PlayerState.isMenuOpen = false

    if not PlayerState.isFishing and not MinigameState.awaiting then
        SetNuiFocus(false, false)
    end
    
    cb('ok')
end)

RegisterNUICallback('buyRod', function(_, cb)
    TriggerServerEvent('exotic_rybak:buyRod')
    cb('ok')
end)

RegisterNUICallback('upgradeRod', function(_, cb)
    TriggerServerEvent('exotic_rybak:upgradeRod')
    cb('ok')
end)

