isDrugDealing = false
dealingPed = nil
isPedAtPoint = false
cam = nil
pedCamCoords = nil
isInCam = nil
isUiLanguageLoaded = false
pedType = "normal"
stolenTarget = nil

local playerLVL = nil

local isOnCooldown = false
local movementDisabled = false
local soldPedsList = {}
local areaSalesCount = 0
local areaMaxSales = 0
local areaStartPosition = nil
local exhaustedAreas = {}
local transactionInProgress = false
local transactionPed = nil
local hasStolenDrugs = false
local maleNames = {
    "Michael", "James", "John", "Robert", "David",
    "William", "Joseph", "Thomas", "Charles", "Daniel",
    "Matthew", "Anthony", "Mark", "Paul", "Steven"
}
local femaleNames = {
    "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth",
    "Barbara", "Susan", "Jessica", "Sarah", "Karen",
    "Nancy", "Lisa", "Margaret", "Sandra", "Ashley"
}

CreateThread(function()
    local attempts = 0
    local maxAttempts = 100
    
    while not isUiLanguageLoaded and attempts < maxAttempts do
        Wait(100)
        attempts = attempts + 1
    end
    
    if not isUiLanguageLoaded then
        debugPrint("[WARNING] UI Language confirmation not received, sending anyway...")
    end
    
    local loc = string.lower(Config.Locale)
    if not Locales[loc] then
        debugPrint("[ERROR] Locale not found:", loc, "falling back to 'en'")
        loc = "en"
    end
    
    SendNUIMessage({
        action = "setLanguage",
        data = {locale = Locales[loc] or {}}
    })
    
    SendNUIMessage({
        action = "setCurrency",
        data = {
            currency = Config.CurrencySettings.currency,
            style = Config.CurrencySettings.style,
            format = Config.CurrencySettings.format,
        }
    })
    
    if Config.Debug then
        debugPrint("[DEBUG] UI initialized, locale:", loc)
    end
end)

CreateThread(function()
    while Framework == nil do
        Wait(100)
    end
end)

if Config.LevelCommand then
    TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.LevelCommand), TranslateIt('level_command_helper'), {})
end

----
-- FUNKCJA SPRAWDZAJĄCA ZABLOKOWANE OBSZARY:
----

function isPositionInBlockedArea(coords)
    if not Config.BlockedAreas or not Config.BlockedAreas.Enable then
        if Config.Debug then
            debugPrint("[DEBUG] isPositionInBlockedArea: BlockedAreas disabled or not found")
        end
        return false
    end
    
    if not Config.BlockedAreas.Areas or #Config.BlockedAreas.Areas == 0 then
        if Config.Debug then
            debugPrint("[DEBUG] isPositionInBlockedArea: No areas configured")
        end
        return false
    end
    
    if Config.Debug then
        debugPrint(string.format("[DEBUG] isPositionInBlockedArea: Checking position %.2f, %.2f, %.2f against %d areas", coords.x, coords.y, coords.z, #Config.BlockedAreas.Areas))
    end
    
    for _, area in ipairs(Config.BlockedAreas.Areas) do
        if area.type == "circle" then
            if area.center and area.radius then
                -- Oblicz odległość 3D (X, Y, Z)
                local distance = #(coords - area.center)
                if Config.Debug then
                    debugPrint(string.format("[DEBUG] Checking circle area: center=(%.2f, %.2f, %.2f), distance=%.2f, radius=%.2f, inArea=%s", 
                        area.center.x, area.center.y, area.center.z, distance, area.radius, tostring(distance <= area.radius)))
                end
                if distance <= area.radius then
                    if Config.Debug then
                        debugPrint("[DEBUG] isPositionInBlockedArea: FOUND BLOCKED AREA!")
                    end
                    return true
                end
            end
        elseif area.type == "box" then
            if area.min and area.max then
                if coords.x >= area.min.x and coords.x <= area.max.x and
                   coords.y >= area.min.y and coords.y <= area.max.y and
                   coords.z >= area.min.z and coords.z <= area.max.z then
                    return true
                end
            end
        end
    end
    
    return false
end

function isPedInBlockedArea(entity)
    if not DoesEntityExist(entity) then return false end
    local pedCoords = GetEntityCoords(entity)
    return isPositionInBlockedArea(pedCoords)
end

----
-- DEBUG: WIZUALIZACJA ZABLOKOWANYCH OBSZARÓW
----

CreateThread(function()
    while true do
        if Config.Debug and Config.BlockedAreas and Config.BlockedAreas.Enable and Config.BlockedAreas.Areas then
            Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, area in ipairs(Config.BlockedAreas.Areas) do
                if area.type == "circle" and area.center and area.radius then
                    -- Oblicz odległość 3D (X, Y, Z), tak samo jak w funkcji sprawdzającej
                    local distance = #(playerCoords - area.center)
                    -- Rysuj tylko jeśli gracz jest w pobliżu (max 200m)
                    if distance <= 200.0 then
                        -- Rysuj marker kuli (typ 28)
                        -- Uwaga: W DrawMarker typ 28 parametry rozmiaru to PROMIEŃ, nie średnica
                        DrawMarker(
                            28, -- typ markera (kula)
                            area.center.x, area.center.y, area.center.z, -- pozycja
                            0.0, 0.0, 0.0, -- rotacja
                            0.0, 0.0, 0.0, -- rotacja 2
                            area.radius, area.radius, area.radius, -- rozmiar (promień)
                            255, 0, 0, 100, -- kolor (czerwony, półprzezroczysty)
                            false, false, 2, false, nil, nil, false
                        )
                        
                        -- Rysuj linię od gracza do centrum jeśli jest blisko
                        if distance <= 50.0 then
                            DrawLine(
                                playerCoords.x, playerCoords.y, playerCoords.z + 1.0,
                                area.center.x, area.center.y, area.center.z,
                                255, 0, 0, 150
                            )
                            
                            -- Tekst z informacją o obszarze
                            local onScreen, _x, _y = World3dToScreen2d(area.center.x, area.center.y, area.center.z + 2.0)
                            if onScreen then
                                SetTextScale(0.4, 0.4)
                                SetTextFont(4)
                                SetTextProportional(1)
                                SetTextColour(255, 0, 0, 255)
                                SetTextDropshadow(0, 0, 0, 0, 255)
                                SetTextEdge(2, 0, 0, 0, 255)
                                SetTextDropShadow()
                                SetTextOutline()
                                SetTextEntry("STRING")
                                SetTextCentre(1)
                                AddTextComponentString(string.format("ZABLOKOWANY OBSZAR (%.1fm)", area.radius))
                                DrawText(_x, _y)
                            end
                        end
                    end
                elseif area.type == "box" and area.min and area.max then
                    local center = vector3(
                        (area.min.x + area.max.x) / 2,
                        (area.min.y + area.max.y) / 2,
                        (area.min.z + area.max.z) / 2
                    )
                    local distance = #(playerCoords - center)
                    
                    -- Rysuj tylko jeśli gracz jest w pobliżu (max 200m)
                    if distance <= 200.0 then
                        local size = vector3(
                            area.max.x - area.min.x,
                            area.max.y - area.min.y,
                            area.max.z - area.min.z
                        )
                        
                        -- Rysuj wszystkie krawędzie prostopadłościanu
                        local corners = {
                            {x = area.min.x, y = area.min.y, z = area.min.z}, -- 1
                            {x = area.max.x, y = area.min.y, z = area.min.z}, -- 2
                            {x = area.max.x, y = area.max.y, z = area.min.z}, -- 3
                            {x = area.min.x, y = area.max.y, z = area.min.z}, -- 4
                            {x = area.min.x, y = area.min.y, z = area.max.z}, -- 5
                            {x = area.max.x, y = area.min.y, z = area.max.z}, -- 6
                            {x = area.max.x, y = area.max.y, z = area.max.z}, -- 7
                            {x = area.min.x, y = area.max.y, z = area.max.z}, -- 8
                        }
                        
                        -- Dolna podstawa
                        DrawLine(corners[1].x, corners[1].y, corners[1].z, corners[2].x, corners[2].y, corners[2].z, 255, 0, 0, 200)
                        DrawLine(corners[2].x, corners[2].y, corners[2].z, corners[3].x, corners[3].y, corners[3].z, 255, 0, 0, 200)
                        DrawLine(corners[3].x, corners[3].y, corners[3].z, corners[4].x, corners[4].y, corners[4].z, 255, 0, 0, 200)
                        DrawLine(corners[4].x, corners[4].y, corners[4].z, corners[1].x, corners[1].y, corners[1].z, 255, 0, 0, 200)
                        
                        -- Górna podstawa
                        DrawLine(corners[5].x, corners[5].y, corners[5].z, corners[6].x, corners[6].y, corners[6].z, 255, 0, 0, 200)
                        DrawLine(corners[6].x, corners[6].y, corners[6].z, corners[7].x, corners[7].y, corners[7].z, 255, 0, 0, 200)
                        DrawLine(corners[7].x, corners[7].y, corners[7].z, corners[8].x, corners[8].y, corners[8].z, 255, 0, 0, 200)
                        DrawLine(corners[8].x, corners[8].y, corners[8].z, corners[5].x, corners[5].y, corners[5].z, 255, 0, 0, 200)
                        
                        -- Pionowe krawędzie
                        DrawLine(corners[1].x, corners[1].y, corners[1].z, corners[5].x, corners[5].y, corners[5].z, 255, 0, 0, 200)
                        DrawLine(corners[2].x, corners[2].y, corners[2].z, corners[6].x, corners[6].y, corners[6].z, 255, 0, 0, 200)
                        DrawLine(corners[3].x, corners[3].y, corners[3].z, corners[7].x, corners[7].y, corners[7].z, 255, 0, 0, 200)
                        DrawLine(corners[4].x, corners[4].y, corners[4].z, corners[8].x, corners[8].y, corners[8].z, 255, 0, 0, 200)
                        
                        -- Tekst z informacją o obszarze
                        if distance <= 50.0 then
                            local onScreen, _x, _y = World3dToScreen2d(center.x, center.y, center.z)
                            if onScreen then
                                SetTextScale(0.4, 0.4)
                                SetTextFont(4)
                                SetTextProportional(1)
                                SetTextColour(255, 0, 0, 255)
                                SetTextDropshadow(0, 0, 0, 0, 255)
                                SetTextEdge(2, 0, 0, 0, 255)
                                SetTextDropShadow()
                                SetTextOutline()
                                SetTextEntry("STRING")
                                SetTextCentre(1)
                                AddTextComponentString("ZABLOKOWANY OBSZAR (BOX)")
                                DrawText(_x, _y)
                            end
                        end
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

local isInCityZone = false

local function onSafeZoneEnter()
    isInCityZone = true
    if Config.Debug then
        debugPrint("[DEBUG] Entered City zone")
    end
end

local function onSafeZoneExit()
    isInCityZone = false
    if Config.Debug then
        debugPrint("[DEBUG] Exited City zone")
    end
end

function isPositionInCityZone(coords)
    return isInCityZone
end

local zonesCreated = false

if not zonesCreated then
    for i, zone in ipairs(Config.City) do
        lib.zones.poly({
            points = zone.points,
            thickness = zone.thickness,
            onEnter = onSafeZoneEnter,
            onExit = onSafeZoneExit
        })
    end
    zonesCreated = true
end

----
-- ADDING GLOBAL TARGETS:
----

addGlobalPeds("global_peds_drugselling", 1.7, TranslateIt('target_selldrug_icon'), TranslateIt('target_selldrug'), function(entity)
    dealingPed = entity
    sellDrugMenu(entity)
end, function(entity) 
    if not DoesEntityExist(entity) then return false end
    
    if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
        return false
    end
    
    if isDrugDealing and dealingPed ~= entity then return false end
    local pedModel = GetEntityModel(entity)
    if Config.BlackListPeds[pedModel] then return end
    if Config.JobBlacklist.Enable then
        local playerData = Fr.GetPlayerData()
        if playerData and playerData.job then
            local playerJob = playerData.job.name
            for _, blacklistedJob in ipairs(Config.JobBlacklist.Jobs) do
                if playerJob == blacklistedJob then
                    return false
                end
            end
        end
    end
    -- Sprawdzenie czy gracz jest w zablokowanym obszarze
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    if isPositionInBlockedArea(playerPos) then
        if Config.Debug then
            debugPrint(string.format("[DEBUG] canInteract: Player in blocked area at %.2f, %.2f, %.2f", playerPos.x, playerPos.y, playerPos.z))
        end
        return false
    end
    if isPedInBlockedArea(entity) then
        return false
    end
    local inventoryItems = ScriptFunctions.GetInventoryDrugs()
    if #inventoryItems < 1 then return false end
    if soldPedsList[entity] then return false end
    if (not isDrugDealing or dealingPed ~= entity) then
        if IsEntityAMissionEntity(entity) and (IsEntityPositionFrozen(entity) or IsEntityInvincible(entity)) then
            return false
        end
    end
    return IsEntityAPed(entity) and not IsPedAPlayer(entity) and not IsPedInAnyVehicle(entity, false) and not IsPedDeadOrDying(entity, true) and not IsPedInCombat(entity, PlayerPedId())
end)

----
-- SELL DRUGS MENU:
----

function getLVL(cb)
    if not playerLVL then 
        Fr.TriggerServerCallback('esx_selldrugs:getlvl', function(reslvl)
            playerLVL = reslvl
            cb(reslvl)
        end)
    else 
        cb(playerLVL) 
    end
end

function sellDrugMenu(entity)
    if Config.Debug then
        debugPrint("[DEBUG] sellDrugMenu called for entity:", entity)
    end
    
    -- Sprawdź czy gracz jest na antytrollu
    if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
        return sendNotify('Nie możesz sprzedawać narkotyków będąc na antytrollu!', "error", 5)
    end
    
    if (not isDrugDealing or dealingPed ~= entity) then
        if IsEntityAMissionEntity(entity) and (IsEntityPositionFrozen(entity) or IsEntityInvincible(entity)) then
            if Config.Debug then
                debugPrint("[DEBUG] sellDrugMenu: Blocked - ped is script-created (mission entity + frozen/invincible)")
            end
            return sendNotify("Nie możesz sprzedać narkotyków temu NPC", "error", 5)
        end
    end

    local playerPed = PlayerPedId()
    local currentPos = GetEntityCoords(playerPed)
    if not isPositionInCityZone(currentPos) then
        return sendNotify(TranslateIt('notify_not_in_city'), "error", 5)
    end
    
    -- Sprawdź minimalną liczbę policjantów
    if Config.MinCops and Config.MinCops > 0 then
        local policeCount = GlobalState.Counter and GlobalState.Counter['police'] or 0
        if policeCount < Config.MinCops then
            return sendNotify(TranslateIt('notify_min_cops', Config.MinCops), "error", 5)
        end
    end
    
    if Config.JobBlacklist.Enable then
        local playerData = Fr.GetPlayerData()
        if playerData and playerData.job then
            local playerJob = playerData.job.name
            for _, blacklistedJob in ipairs(Config.JobBlacklist.Jobs) do
                if playerJob == blacklistedJob then
                    sendNotify(TranslateIt('notify_job_blacklisted'), "error", 5)
                    return
                end
            end
        end
    end

    local playerPed = PlayerPedId()
    local currentPos = GetEntityCoords(playerPed)
    
    -- Sprawdzenie czy gracz jest w zablokowanym obszarze
    if Config.Debug then
        debugPrint(string.format("[DEBUG] sellDrugMenu: Checking blocked area for position %.2f, %.2f, %.2f", currentPos.x, currentPos.y, currentPos.z))
    end
    local isBlocked = isPositionInBlockedArea(currentPos)
    if Config.Debug then
        debugPrint(string.format("[DEBUG] sellDrugMenu: isBlocked = %s", tostring(isBlocked)))
    end
    if isBlocked then
        if Config.Debug then
            debugPrint(string.format("[DEBUG] sellDrugMenu: BLOCKING - Player in blocked area at %.2f, %.2f, %.2f", currentPos.x, currentPos.y, currentPos.z))
        end
        return sendNotify(TranslateIt('notify_blocked_area'), "error", 5)
    end

    soldPedsList[entity] = true
    local pedModel = GetEntityModel(entity)
    pedType = "normal"

    if Config.PedsList[pedModel] then
        pedType = Config.PedsList[pedModel]
    end
    local pedCfg = Config.PedTypes[pedType]

    if math.random(100) <= pedCfg.refuseChance then
        if Config.dispatchScript ~= "none" and pedCfg.dispatchCall then
            sendDispatchAlert(TranslateIt('drugdeal_dispatch_title'), TranslateIt('drugdeal_dispatch_message'), Config.DrugSelling.blipData)
        end

        stopDealFunc()
        if isDrugDealing then
            local randomWait = math.random(Config.CornerDealing.SellTimeoutMin, Config.CornerDealing.SellTimeoutMax)
            SetTimeout(randomWait * 1000, function()
                if isDrugDealing then
                    getNextDealing()
                end
            end)
        end

        return sendNotify(TranslateIt('notify_refuse_2'), "error", 5)
    end

    getLVL(function(lvl)
        local inventoryItems = ScriptFunctions.GetInventoryDrugs()
        
        if not pedCfg then 
            debugPrint("[ERROR] Config for Ped Type not found! pedType:", pedType)
            return print('Config for Ped Type not found!', pedType) 
        end
        
        if Config.Debug then
            debugPrint("[DEBUG] Opening drug menu - Level:", lvl, "Drugs:", #inventoryItems, "PedType:", pedCfg.label)
        end

        local pedGenderObj = IsPedMale(entity) and maleNames or femaleNames
        local pedName = pedGenderObj[math.random(1, #pedGenderObj)]
        local nuiData = {
            pedType = pedCfg.label,
            pedBorder = pedCfg.colors.border,
            pedBg = pedCfg.colors.background,
            playerLevel = lvl,
            playerBoost = GetLevelBoost(lvl),
            playerDrugs = inventoryItems,
            pedName = pedName
        }

        local dict = "missfbi3_party_b"
        if not LoadAnimDict(dict) then
            return debugPrint("Unable to load anim dict:", dict)
        end

        ClearPedTasks(entity)
        SetBlockingOfNonTemporaryEvents(entity, true)
        hardStopPed(entity) 
        faceEachOtherHard(playerPed, entity)

        TaskStandStill(entity, -1)
        TaskPlayAnim(entity, dict, "talk_inside_loop_male1", 8.0, -8.0, -1, 49, 0.0, false, false, false)
        TaskPlayAnim(playerPed, dict, "talk_inside_loop_male1", 8.0, -8.0, -1, 49, 0.0, false, false, false)

        if not DoesEntityExist(entity) or IsPedDeadOrDying(entity, true) then
            debugPrint("[DEBUG] Ped died before opening menu")
            return
        end
        
        startcam(entity)
        SetNuiFocus(true, true)
        
        if Config.Debug then
            debugPrint("[DEBUG] Sending drug dealing data to NUI - Drugs:", #inventoryItems, "Level:", lvl)
        end
        
        SendNUIMessage({ action = "setDrugDealingData", data = nuiData })
        SendNUIMessage({ action = "setDrugSellingVisible", data = true })
        
        CreateThread(function()
            while isDrugDealing and dealingPed == entity do
                Wait(500)
                
                if not DoesEntityExist(entity) or IsPedDeadOrDying(entity, true) then
                    debugPrint("[DEBUG] Ped died while menu is open")
                    endCam()
                    SetNuiFocus(false, false)
                    SendNUIMessage({
                        action = "setDrugSellingVisible",
                        data = false
                    })
                    cancelCornerDealing(TranslateIt('notify_ped_died'))
                    break
                end
            end
        end)
    end)
end

----
-- Function Triggered by NUI:
----

function sellDrugForPedFinalize(drug_name, price)
    if Config.Debug then
        debugPrint("[DEBUG] sellDrugForPedFinalize - drug:", drug_name, "price:", price)
    end
    
    local isdead = Fr.isDead()
    if isdead then 
        isDrugDealing = false
        return stopDealFunc()
    end

    endCam()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "setDrugSellingVisible",
        data = false
    })
    
    local drugCfg = Config.DrugSelling.availableDrugs[drug_name]
    if not drugCfg then 
        debugPrint("[ERROR] Missing drug config:", drug_name)
        return print('[esx_selldrugs] Missing drug config:', drug_name) 
    end

    -- Rozpocznij śledzenie transakcji
    transactionInProgress = true
    transactionPed = dealingPed

    -- Monitoruj czy NPC umrze podczas transakcji
    CreateThread(function()
        while transactionInProgress and transactionPed do
            Wait(500)
            if not DoesEntityExist(transactionPed) or IsPedDeadOrDying(transactionPed, true) then
                debugPrint("[DEBUG] NPC died during transaction, checking for items to return")
                -- Sprawdź czy są przedmioty do zwrócenia
                TriggerServerEvent('esx_selldrugs:checkAndReturnDrugs')
                transactionInProgress = false
                transactionPed = nil
                break
            end
        end
    end)

    Fr.TriggerServerCallback('esx_selldrugs:sellDrug', function(sold)
        if not sold then 
            return print('An server-side error occured. Check txAdmin Console.')
        end

        local pedCfg = Config.PedTypes[pedType]
        if math.random(100) <= Config.DrugSelling.dispatchCallChance then
            if Config.dispatchScript ~= "none" and pedCfg.dispatchCall then
                sendDispatchAlert(TranslateIt('drugdeal_dispatch_title'), TranslateIt('drugdeal_dispatch_message'), Config.DrugSelling.blipData)
            end
        end

        -- Zakończ śledzenie transakcji
        transactionInProgress = false
        transactionPed = nil

        if sold.sold then
            soldPedsList[dealingPed] = true
            if isDrugDealing then
                areaSalesCount = areaSalesCount + 1
            end
            movementDisabled = true
            local movementControls = {30, 31, 32, 33, 34, 35, 21, 22, 36}
            CreateThread(function()
                while movementDisabled do
                    for _, control in ipairs(movementControls) do
                        DisableControlAction(0, control, true)
                    end
                    Wait(0)
                end
            end)

            playerLVL = sold.newLevel
            
            if not DoesEntityExist(dealingPed) or IsPedDeadOrDying(dealingPed, true) then
                debugPrint("[DEBUG] Dealing ped died during transaction")
                cancelCornerDealing(TranslateIt('notify_ped_died'))
                return
            end
            
            FaceEachOtherAndPlayGive(dealingPed, drugCfg.handPropName)
            if not sold.isRivalry then 
                --sendNotify(TranslateIt('notify_success', sold.amount, sold.label, sold.price), "success", 5)
            else
                --sendNotify(TranslateIt('notify_success_2', sold.amount, sold.label, sold.price), "success", 5)
            end

            if sold.zoneOwner then 
                --sendNotify(TranslateIt('notify_zoneowner'), "info", 5)
            end
            
            movementDisabled = false

            local dumpPed = dealingPed
            SetTimeout(25000, function()
                if DoesEntityExist(dumpPed) then
                    DeletePed(dumpPed)
                end
            end)
        elseif sold.steal then
            ClearPedTasks(PlayerPedId())
            hasStolenDrugs = true

            if dealingPed and DoesEntityExist(dealingPed) and not IsPedDeadOrDying(dealingPed, true) then
                addTargetTypedEntity("ped_drug_stolen", 2.0, TranslateIt('target_getdrugs_icon'), TranslateIt('target_getdrugs'), function(deleteData)
                    TriggerServerEvent('esx_selldrugs:getBackDrugs')
                    hasStolenDrugs = false
                    removeTargetEntity(deleteData)
                end, dealingPed)

                MakePedRunAway()
                
                CreateThread(function()
                    local checkPed = dealingPed
                    while DoesEntityExist(checkPed) and not IsPedDeadOrDying(checkPed, true) do
                        Wait(100)
                    end
                    if hasStolenDrugs and (IsPedDeadOrDying(checkPed, true) or not DoesEntityExist(checkPed)) then
                        debugPrint("[DEBUG] NPC died after stealing drugs, returning items automatically")
                        TriggerServerEvent('esx_selldrugs:getBackDrugs')
                        hasStolenDrugs = false
                        sendNotify(TranslateIt('notify_drugs_returned'), "success", 5)
                    end
                end)
            else
                if isDrugDealing then
                    cancelCornerDealing(TranslateIt('notify_ped_died'))
                end
                TriggerServerEvent('esx_selldrugs:getBackDrugs')
                hasStolenDrugs = false
                sendNotify(TranslateIt('notify_drugs_returned'), "success", 5)
            end
            
            sendNotify(TranslateIt('notify_steal'), "error", 5)
        elseif sold.refused then
            local dumpPed = dealingPed
            stopDealFunc()
            sendNotify(TranslateIt('notify_refuse'), "error", 5)
            SetTimeout(25000, function()
                if DoesEntityExist(dumpPed) then
                    DeletePed(dumpPed)
                end
            end)
        end

        if isDrugDealing then
            local randomWait = math.random(Config.CornerDealing.SellTimeoutMin, Config.CornerDealing.SellTimeoutMax)
            SetTimeout(randomWait * 1000, function()
                if isDrugDealing then
                    getNextDealing()
                end
            end)
        end
    end, drug_name, price, pedType, isDrugDealing)
end

----
-- Corner Selling Command:
----

if Config.CornerDealing.Enable then
    debugPrint("Registering drug selling command:", Config.CornerDealing.Command)

    RegisterNetEvent('esx_selldrugs:startDealingCorner', function()
        if not Config.CornerDealing.Enable then return end
        
        -- Sprawdź czy gracz jest na antytrollu
        if LocalPlayer.state.ProtectionTime and LocalPlayer.state.ProtectionTime > 0 then
            return sendNotify('Nie możesz handlować narkotykami będąc na antytrollu!', "error", 5)
        end
        
        if Config.JobBlacklist.Enable then
            local playerData = Fr.GetPlayerData()
            if playerData and playerData.job then
                local playerJob = playerData.job.name
                for _, blacklistedJob in ipairs(Config.JobBlacklist.Jobs) do
                    if playerJob == blacklistedJob then
                        return sendNotify(TranslateIt('notify_job_blacklisted'), "error", 5)
                    end
                end
            end
        end

        -- Sprawdź minimalną liczbę policjantów
        if Config.MinCops and Config.MinCops > 0 then
            local policeCount = GlobalState.Counter and GlobalState.Counter['police'] or 0
            if policeCount < Config.MinCops then
                return sendNotify(TranslateIt('notify_min_cops', Config.MinCops), "error", 5)
            end
        end

        if isOnCooldown then
            return sendNotify(TranslateIt('drugDealing_wait'), "error", 5)
        end

        local playerPed = PlayerPedId()
        local currentPos = GetEntityCoords(playerPed)

        if not isPositionInCityZone(currentPos) then
            return sendNotify(TranslateIt('notify_not_in_city'), "error", 5)
        end
        
        -- Sprawdzenie czy gracz jest w zablokowanym obszarze
        if isPositionInBlockedArea(currentPos) then
            return sendNotify(TranslateIt('notify_blocked_area'), "error", 5)
        end
        
        local isExhausted, remainingMinutes = isAreaExhausted(currentPos)
        if isExhausted then
            return sendNotify(TranslateIt('notify_area_on_cooldown', remainingMinutes), "error", 8)
        end

        if not isDrugDealing then
            isDrugDealing = true
            areaSalesCount = 0
            areaMaxSales = math.random(Config.CornerDealing.MaxSalesPerArea.Min, Config.CornerDealing.MaxSalesPerArea.Max)
            areaStartPosition = currentPos
            sendNotify(TranslateIt('drugdeal_started_notify'), "info", 5)
            getNextDealing()
            startDistanceCheck()
        else
            isDrugDealing = false
            
            -- Jeśli NPC miał skradzione zioła, zwróć je przed usunięciem
            if hasStolenDrugs then
                TriggerServerEvent('esx_selldrugs:getBackDrugs')
                hasStolenDrugs = false
                sendNotify(TranslateIt('notify_drugs_returned'), "success", 5)
            end
            
            stopDealFunc()
            if dealingPed then
                DeletePed(dealingPed)
            end

            dealingPed = nil
            areaSalesCount = 0
            areaMaxSales = 0
            areaStartPosition = nil
            sendNotify(TranslateIt('ended_drugdealing'), "info", 5)
            isOnCooldown = true
            
            local timeouttime = math.random(Config.CornerDealing.SellTimeoutMin, Config.CornerDealing.SellTimeoutMax) * 1000
            SetTimeout(timeouttime + 2000, function()
                isOnCooldown = false
            end)
        end
    end)

    TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.CornerDealing.Command), TranslateIt('drugsell_command_help'), {})

    RegisterCommand(Config.CornerDealing.Command, function()
        TriggerEvent('esx_selldrugs:startDealingCorner')
    end)

    function cancelCornerDealing(reason)
        if not isDrugDealing then return end
        
        -- Jeśli NPC miał skradzione zioła, zwróć je przed usunięciem
        if hasStolenDrugs then
            TriggerServerEvent('esx_selldrugs:getBackDrugs')
            hasStolenDrugs = false
            sendNotify(TranslateIt('notify_drugs_returned'), "success", 5)
        end
        
        isDrugDealing = false
        stopDealFunc()
        if dealingPed then
            DeletePed(dealingPed)
            dealingPed = nil
        end
        areaSalesCount = 0
        areaMaxSales = 0
        areaStartPosition = nil
        
        if reason then
            sendNotify(reason, "error", 5)
        else
            sendNotify(TranslateIt('ended_drugdealing'), "info", 5)
        end
    end

    function startDistanceCheck()
        CreateThread(function()
            while isDrugDealing and areaStartPosition do
                Wait(1000)
                
                if not isDrugDealing then break end
                
                local playerPed = PlayerPedId()
                if not DoesEntityExist(playerPed) then break end
                
                if dealingPed and (not DoesEntityExist(dealingPed) or IsPedDeadOrDying(dealingPed, true)) then
                    debugPrint("[DEBUG] Dealing ped died, canceling corner dealing")
                    -- Jeśli NPC miał skradzione zioła, zwróć je przed usunięciem
                    if hasStolenDrugs then
                        TriggerServerEvent('esx_selldrugs:getBackDrugs')
                        hasStolenDrugs = false
                        sendNotify(TranslateIt('notify_drugs_returned'), "success", 5)
                    end
                    cancelCornerDealing(TranslateIt('notify_ped_died'))
                    break
                end
                
                local currentPos = GetEntityCoords(playerPed)

                if not isPositionInCityZone(currentPos) then
                    cancelCornerDealing(TranslateIt('notify_not_in_city'))
                    break
                end
                
                -- Sprawdzenie czy gracz wszedł w zablokowany obszar
                if isPositionInBlockedArea(currentPos) then
                    cancelCornerDealing(TranslateIt('notify_blocked_area'))
                    break
                end
                
                local distance = #(currentPos - areaStartPosition)
                local maxDistance = Config.CornerDealing.MaxDistance
                
                if distance > maxDistance then
                    cancelCornerDealing(TranslateIt('notify_too_far_away'))
                    break
                end
            end
        end)
    end

    function isAreaExhausted(coords)
        local currentTime = GetGameTimer()
        local areaRadius = Config.CornerDealing.AreaRadius
        
        for areaId, areaData in pairs(exhaustedAreas) do
            if currentTime < areaData.expireTime then
                local distance = #(coords - areaData.position)
                if distance <= areaRadius then
                    local remainingMinutes = math.ceil((areaData.expireTime - currentTime) / 60000)
                    return true, remainingMinutes
                end
            else
                exhaustedAreas[areaId] = nil
            end
        end
        return false, 0
    end

    function addExhaustedArea(coords)
        local areaId = string.format("%.0f_%.0f_%.0f", coords.x, coords.y, coords.z)
        local cooldownTime = Config.CornerDealing.AreaCooldownTime * 60 * 1000
        local expireTime = GetGameTimer() + cooldownTime
        
        exhaustedAreas[areaId] = {
            position = coords,
            expireTime = expireTime
        }
        
        if Config.Debug then
            debugPrint("Area exhausted at:", areaId, "Radius:", Config.CornerDealing.AreaRadius, "m, Cooldown:", Config.CornerDealing.AreaCooldownTime, "minutes")
        end
    end

    CreateThread(function()
        while true do
            Wait(60000)
            local currentTime = GetGameTimer()
            local areasToRemove = {}
            
            for areaId, areaData in pairs(exhaustedAreas) do
                if currentTime >= areaData.expireTime then
                    areasToRemove[#areasToRemove + 1] = areaId
                end
            end
            
            for _, areaId in ipairs(areasToRemove) do
                exhaustedAreas[areaId] = nil
                if Config.Debug then
                    debugPrint("Area cooldown expired:", areaId)
                end
            end
        end
    end)

    CreateThread(function()
        while true do
            if Config.Debug and isDrugDealing and dealingPed and DoesEntityExist(dealingPed) then
                Wait(0)
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local pedCoords = GetEntityCoords(dealingPed)
                
                DrawLine(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, pedCoords.x, pedCoords.y, pedCoords.z + 1.0, 0, 255, 0, 255)
                
                local distance = #(playerCoords - pedCoords)
                local onScreen, _x, _y = World3dToScreen2d(pedCoords.x, pedCoords.y, pedCoords.z + 2.5)
                if onScreen then
                    SetTextScale(0.35, 0.35)
                    SetTextFont(4)
                    SetTextProportional(1)
                    SetTextColour(0, 255, 0, 255)
                    SetTextDropshadow(0, 0, 0, 0, 255)
                    SetTextEdge(2, 0, 0, 0, 255)
                    SetTextDropShadow()
                    SetTextOutline()
                    SetTextEntry("STRING")
                    SetTextCentre(1)
                    AddTextComponentString(string.format("KLIENT (%.1fm)", distance))
                    DrawText(_x, _y)
                end
            else
                Wait(500)
            end
        end
    end)

    function getNextDealing()
        if not isDrugDealing then return end
        
        -- Jeśli poprzedni NPC jeszcze istnieje i ma skradzione zioła, zwróć je przed stworzeniem nowego NPC
        if dealingPed and DoesEntityExist(dealingPed) and hasStolenDrugs then
            TriggerServerEvent('esx_selldrugs:getBackDrugs')
            hasStolenDrugs = false
            sendNotify(TranslateIt('notify_drugs_returned'), "success", 5)
        end
        
        if areaSalesCount >= areaMaxSales then
            local playerPed = PlayerPedId()
            local currentPos = GetEntityCoords(playerPed)
            
            if areaStartPosition then
                addExhaustedArea(areaStartPosition)
            end
            
            local isExhausted, remainingMinutes = isAreaExhausted(currentPos)
            if isExhausted then
                sendNotify(TranslateIt('notify_area_on_cooldown', remainingMinutes), "error", 8)
                cancelCornerDealing()
                return
            end
            
            areaSalesCount = 0
            areaMaxSales = math.random(Config.CornerDealing.MaxSalesPerArea.Min, Config.CornerDealing.MaxSalesPerArea.Max)
            areaStartPosition = currentPos
            sendNotify(TranslateIt('notify_new_area'), "success", 5)
        end
        
        isPedAtPoint = false
        dealingPed = SpawnRandomPedAndApproach(40.0, 80.0, 1.0, 1.45)
        
        if not dealingPed then
            debugPrint("[DEBUG] Failed to spawn ped, retrying...")
            SetTimeout(5000, function()
                if isDrugDealing then
                    getNextDealing()
                end
            end)
            return
        end
        
        sendNotify(TranslateIt('ped_heading_notify'), "success", 5)
        
        CreateThread(function()
            while isDrugDealing and dealingPed do
                Wait(2000)
                
                if not isDrugDealing then break end
                
                if not DoesEntityExist(dealingPed) or IsPedDeadOrDying(dealingPed, true) then
                    debugPrint("[DEBUG] Spawned ped died before reaching player")
                    if isDrugDealing then
                        local randomWait = math.random(Config.CornerDealing.SellTimeoutMin, Config.CornerDealing.SellTimeoutMax)
                        SetTimeout(randomWait * 1000, function()
                            if isDrugDealing then
                                getNextDealing()
                            end
                        end)
                    end
                    break
                end
            end
        end)
    end
end

----
-- Run with Drugs Function:
----

function MakePedRunAway()
    local playerPed = PlayerPedId()
    local ped = dealingPed
    if not DoesEntityExist(ped) or IsEntityDead(ped) then return end

    SetEntityAsMissionEntity(ped, true, false)       
    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)
    TaskSetBlockingOfNonTemporaryEvents(ped, false) 
    SetBlockingOfNonTemporaryEvents(ped, false)

    SetPedCombatAttributes(ped, 46, false)           
    SetPedFleeAttributes(ped, 0, false)             
    SetPedSeeingRange(ped, 80.0)
    SetPedHearingRange(ped, 80.0)
    SetPedAlertness(ped, 3)

    SetPedKeepTask(ped, true)
    SetPedMaxMoveBlendRatio(ped, 3.0)                
    SetPedDesiredMoveBlendRatio(ped, 3.0)

    TaskReactAndFleePed(ped, playerPed)
    SetTimeout(500, function()
        if DoesEntityExist(ped) then
            TaskSmartFleePed(ped, playerPed, 120.0, -1, true, false)
        end
    end)
end

----
-- Stop Dealing Function:
----

function stopDealFunc()
    if dealingPed then 
        FreezeEntityPosition(dealingPed, false)
        TaskClearLookAt(dealingPed)
        ClearPedTasksImmediately(dealingPed)
        SetBlockingOfNonTemporaryEvents(dealingPed, false)
        TaskWanderStandard(dealingPed, 10.0, 10)
    end
    ClearPedTasks(PlayerPedId())
end

----
-- Give Drugs Animation:
----

function FaceEachOtherAndPlayGive(targetPed, propName)
    if not DoesEntityExist(targetPed) then
        return debugPrint("FaceEachOtherAndPlayGive: targetPed does not exist")
    end

    local playerDuration = 2000
    local npcDuration = 2000
    local playerPed = PlayerPedId()
    local dict = "mp_common"

    if not LoadAnimDict(dict) then
        return debugPrint("Unable to load anim dict:", dict)
    end
    TaskPlayAnim(targetPed, dict, "givetake2_a", 8.0, -8.0, npcDuration, 49, 0.0, false, false, false)
    TaskPlayAnim(playerPed, dict, "givetake1_b", 8.0, -8.0, playerDuration, 49, 0.0, false, false, false)

    local ok, propHash = LoadModel(propName)
    if not ok then
        return debugPrint("Couldn't load prop:", propName)
    end

    local prop = CreateObject(propHash, 0.0, 0.0, 0.0, true, true, false)
    SetEntityCollision(prop, false, true)
    attachPropToRightHand(playerPed, prop)

    local half = math.floor(math.min(playerDuration, npcDuration) / 2)
    CreateThread(function()
        Wait(half)
        if DoesEntityExist(prop) and DoesEntityExist(targetPed) then
            attachPropToRightHand(targetPed, prop)
        end
    end)
    SetModelAsNoLongerNeeded(propHash)
    
    Wait(2300)
    DeleteEntity(prop)
    PlayPedAmbientSpeechNative(targetPed, "GENERIC_THANKS", "SPEECH_PARAMS_FORCE")
    TaskClearLookAt(targetPed)
    ClearPedTasks(targetPed)
    SetBlockingOfNonTemporaryEvents(targetPed, false)
    TaskWanderStandard(targetPed, 10.0, 10)
end

----
-- Ped Spawning In Corner Mode:
----

local function randFloat(min, max)
    return min + math.random() * (max - min)
end

local function isPositionHiddenFromPlayer(playerPed, pos)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - pos)
    
    if distance > 100.0 then
        return true
    end
    
    local playerHeading = GetEntityHeading(playerPed)
    local headingRad = math.rad(playerHeading)
    local forwardVector = vector3(math.sin(-headingRad), math.cos(-headingRad), 0.0)
    
    local toPosition = vector3(pos.x - playerCoords.x, pos.y - playerCoords.y, 0.0)
    local normalizedToPos = vector3(toPosition.x / distance, toPosition.y / distance, 0.0)
    local dotProduct = forwardVector.x * normalizedToPos.x + forwardVector.y * normalizedToPos.y
    
    if dotProduct < 0.3 then
        return true
    end
    
    local shapeTest = StartShapeTestLosProbe(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, pos.x, pos.y, pos.z + 1.0, -1, playerPed, 0)
    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTest)
    
    if hit then
        local hitDistance = #(endCoords - playerCoords)
        if hitDistance < distance - 5.0 then
            return true
        end
    end
    
    return false
end

local function isPositionOnRoof(pos)
    local found, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, false)
    if not found then
        return true
    end
    
    local heightDiff = pos.z - groundZ
    if heightDiff > 3.0 then
        return true
    end
    
    return false
end

local function findSafeSpawnNear(px, py, pz, minDist, maxDist, attempts)
    attempts = attempts or 20
    local playerPed = PlayerPedId()
    local playerHeading = GetEntityHeading(playerPed)
    
    for i = 1, attempts do
        local baseAngle = math.rad(playerHeading) + math.pi
        local angleVariation = (math.random() - 0.5) * math.pi * 1.5
        local angle = baseAngle + angleVariation
        
        local dist = randFloat(minDist, maxDist)
        if math.random() < 0.7 then
            dist = randFloat(minDist + (maxDist - minDist) * 0.4, maxDist)
        end
        
        local tx = px + math.cos(angle) * dist
        local ty = py + math.sin(angle) * dist
        local tz = pz
        
        local found, safePos = GetSafeCoordForPed(tx, ty, tz, true, 16)
        if found and safePos then
            if not isPositionOnRoof(safePos) and isPositionHiddenFromPlayer(playerPed, safePos) then
                return safePos.x, safePos.y, safePos.z
            end
        end
    end
    
    for i = 1, 10 do
        local angle = math.random() * math.pi * 2
        local dist = randFloat(minDist, maxDist)
        local tx = px + math.cos(angle) * dist
        local ty = py + math.sin(angle) * dist
        local tz = pz
        local found, safePos = GetSafeCoordForPed(tx, ty, tz, true, 16)
        if found and safePos and not isPositionOnRoof(safePos) then
            return safePos.x, safePos.y, safePos.z
        end
    end
    
    local angle = math.random() * math.pi * 2
    local dist = randFloat(minDist, maxDist)
    return px + math.cos(angle) * dist, py + math.sin(angle) * dist, pz
end

function SpawnRandomPedAndApproach(minDist, maxDist, walkSpeed, stopRange)
    local models = {"a_f_m_fatwhite_01", "a_f_m_soucentmc_01", "a_m_m_afriamer_01", "a_m_m_bevhills_02", "a_m_m_eastsa_01", "a_m_m_polynesian_01", "a_m_m_trampbeac_01", "a_m_y_beachvesp_01", "a_m_y_clubcust_01", "a_m_y_epsilon_02", "a_m_y_vinewood_01", "a_m_y_vinewood_02", "cs_dom", "cs_manuel"}
    minDist = minDist or 40.0
    maxDist = maxDist or 80.0
    walkSpeed = walkSpeed or 1.0
    stopRange = stopRange or 1.45
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local px, py, pz = playerCoords.x, playerCoords.y, playerCoords.z
    
    local sx, sy, sz = findSafeSpawnNear(px, py, pz, minDist, maxDist, 20)
    
    local found, groundZ = GetGroundZFor_3dCoord(sx, sy, sz + 10.0, false)
    if found then
        local heightDiff = sz - groundZ
        if heightDiff > 3.0 then
            sz = groundZ + 0.5
        else
            sz = groundZ
        end
    end
    
    if isPositionOnRoof(vector3(sx, sy, sz)) then
        debugPrint("Spawn position is on roof, adjusting...")
        local foundGround, groundZ = GetGroundZFor_3dCoord(sx, sy, sz, false)
        if foundGround then
            sz = groundZ + 0.5
        end
    end

    local modelName = models[math.random(1, #models)]
    local model = GetHashKey(modelName)

    if not IsModelInCdimage(model) then
        return debugPrint(("Model %s does not exist in cdimage"):format(modelName))
    end

    RequestModel(model)
    local t = GetGameTimer() + 7000
    while not HasModelLoaded(model) and GetGameTimer() < t do
        Wait(10)
    end
    if not HasModelLoaded(model) then
        return debugPrint("Error during model load", modelName)
    end

    local ped = CreatePed(4, model, sx, sy, sz, 0.0, true, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedSeeingRange(ped, 0.0)
    SetPedHearingRange(ped, 0.0)
    
    local dx = px - sx
    local dy = py - sy
    local headingToPlayer = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(ped, headingToPlayer)
    
    if not isDrugDealing or not DoesEntityExist(playerPed) then
        DeletePed(ped)
        return nil
    end
    
    CreateThread(function()
        Wait(500)
        
        if not isDrugDealing or not DoesEntityExist(playerPed) or not DoesEntityExist(ped) then
            if DoesEntityExist(ped) then
                DeletePed(ped)
            end
            return
        end
        
        TaskFollowToOffsetOfEntity(ped, playerPed, 0.0, 0.0, 0.0, walkSpeed, -1, stopRange, true)
        TaskLookAtEntity(ped, playerPed, 10000, 2048, 3)
    end)
    
    CreateThread(function()
        local arrived = false
        local lastReissue = 0
        while DoesEntityExist(ped) and not arrived do
            local pcoords = GetEntityCoords(playerPed)
            local ecoords = GetEntityCoords(ped)
            local dist = #(pcoords - ecoords)

            if not arrived then
                if dist > (stopRange + 0.5) then
                    if GetGameTimer() - lastReissue > 2000 then
                        TaskFollowToOffsetOfEntity(ped, playerPed, 0.0, 0.0, 0.0, walkSpeed, -1, stopRange, true)
                        lastReissue = GetGameTimer()
                    end
                else
                    arrived = true
                    isPedAtPoint = true
                    ClearPedTasks(ped)
                    TaskStandStill(ped, -1)                           
                    TaskTurnPedToFaceEntity(ped, playerPed, 800)      
                    TaskLookAtEntity(ped, playerPed, -1, 2048, 3)
                end
            end
            Wait(300)
        end
    end)
    SetModelAsNoLongerNeeded(model)
    return ped
end