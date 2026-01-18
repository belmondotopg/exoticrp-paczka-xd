local duiUrl = string.format("https://cfx-nui-%s/web/build/index.html", GetCurrentResourceName())
local screenWidth, screenHeight = 1920, 1080

local Interactions = {}
local PlayerData = ESX.GetPlayerData()

local DuiPool = {}
local MAX_VISIBLE_DUI = 8
local duiManagerStarted = false
local visibleInteractions = {} -- Przeniesione na poziom modułu dla dostępu z innych funkcji

-- Cache dla optymalizacji
local coordsKeyCache = {}
local CACHE_PRECISION = 0.1 -- Zaokrąglenie do 0.1m dla cache

CreateThread(function()
    while true do 
        Wait(10000)
        PlayerData = ESX.GetPlayerData()
    end
end)

local function coordsToKey(coords)
    -- Zaokrąglenie dla cache
    local x = math.floor(coords.x / CACHE_PRECISION) * CACHE_PRECISION
    local y = math.floor(coords.y / CACHE_PRECISION) * CACHE_PRECISION
    local z = math.floor(coords.z / CACHE_PRECISION) * CACHE_PRECISION
    
    local cacheKey = x .. "_" .. y .. "_" .. z
    if not coordsKeyCache[cacheKey] then
        coordsKeyCache[cacheKey] = string.format("%.2f_%.2f_%.2f", x, y, z)
    end
    return coordsKeyCache[cacheKey]
end

local function keyToCoords(key)
    local x, y, z = string.match(key, "([%d%-%.]+)_([%d%-%.]+)_([%d%-%.]+)")
    return vec3(tonumber(x), tonumber(y), tonumber(z))
end

local function initDuiPool()
    if #DuiPool > 0 then return end
    
    for i = 1, MAX_VISIBLE_DUI do
        local duiObject = CreateDui(duiUrl, screenWidth, screenHeight)
        if duiObject then
            local duiHandle = GetDuiHandle(duiObject)
            local txdName = 'dui_pool_' .. i
            local txd = CreateRuntimeTxd(txdName)
            CreateRuntimeTextureFromDuiHandle(txd, 'dui_render_' .. i, duiHandle)
            
            SendDuiMessage(duiObject, json.encode({
                action = "setVisible",
                visible = false
            }))
            
            DuiPool[i] = {
                duiObject = duiObject,
                txdName = txdName,
                textureName = 'dui_render_' .. i,
                assignedKey = nil,
                currentData = nil,
                inUse = false
            }
        end
    end
end

local function updatePoolDuiContent(poolIndex, dataInteraction)
    local poolDui = DuiPool[poolIndex]
    if not poolDui or not poolDui.duiObject then return end
    
    if poolDui.currentData and isDataEqual(poolDui.currentData, dataInteraction) then
        return
    end
    
    poolDui.currentData = dataInteraction
    
    SendDuiMessage(poolDui.duiObject, json.encode({
        action = "setInteraction",
        data = dataInteraction
    }))
    SendDuiMessage(poolDui.duiObject, json.encode({
        action = "setVisible",
        visible = true
    }))
end

local function hidePoolDui(poolIndex)
    local poolDui = DuiPool[poolIndex]
    if not poolDui or not poolDui.duiObject then return end
    
    poolDui.assignedKey = nil
    poolDui.currentData = nil
    poolDui.inUse = false
    
    SendDuiMessage(poolDui.duiObject, json.encode({
        action = "setVisible",
        visible = false
    }))
end

local function getPoolDuiForKey(key)
    for i, poolDui in ipairs(DuiPool) do
        if poolDui.assignedKey == key then
            return i
        end
    end
    
    for i, poolDui in ipairs(DuiPool) do
        if not poolDui.inUse then
            poolDui.assignedKey = key
            poolDui.inUse = true
            return i
        end
    end
    
    return nil
end

function removeAllDuis()
    Interactions = {}
    -- Czyszczenie widocznych interakcji
    if visibleInteractions then
        for key, poolIndex in pairs(visibleInteractions) do
            if poolIndex and DuiPool[poolIndex] then
                hidePoolDui(poolIndex)
            end
        end
        visibleInteractions = {}
    end
end

function removeDui(coords)
    if not coords then return false end
    local key = coordsToKey(coords)
    if not key then return false end
    
    if Interactions[key] then
        Interactions[key] = nil
        -- Czyszczenie z visibleInteractions jeśli istnieje
        if visibleInteractions and visibleInteractions[key] then
            local poolIndex = visibleInteractions[key]
            if poolIndex and DuiPool[poolIndex] then
                hidePoolDui(poolIndex)
            end
            visibleInteractions[key] = nil
        end
        return true
    end
    return false
end

function isDuiExists(coords)
    if not coords then return false end
    local key = coordsToKey(coords)
    if not key then return false end
    return Interactions[key] ~= nil
end

function getDuiCount()
    local count = 0
    for _ in pairs(Interactions) do
        count = count + 1
    end
    return count
end

RegisterCommand('interactions_debug', function()
    local inUseCount = 0
    for _, poolDui in ipairs(DuiPool) do
        if poolDui.inUse then inUseCount = inUseCount + 1 end
    end
    print("^3[INTERACTIONS]^7 Zarejestrowane interakcje: " .. getDuiCount())
    print("^3[INTERACTIONS]^7 DUI w puli: " .. #DuiPool .. " (w użyciu: " .. inUseCount .. ")")
end, false)

function isDataEqual(data1, data2)
    if not data1 or not data2 then return false end
    if data1 == data2 then return true end -- Referencja do tego samego obiektu
    
    -- Szybkie porównanie kluczowych pól
    if data1.icon ~= data2.icon or data1.key ~= data2.key or 
       data1.title ~= data2.title or data1.description ~= data2.description then
        return false
    end
    
    -- Porównanie jobBlacklist/jobWhitelist tylko jeśli istnieją
    if (data1.jobBlacklist ~= nil) ~= (data2.jobBlacklist ~= nil) then return false end
    if (data1.jobWhitelist ~= nil) ~= (data2.jobWhitelist ~= nil) then return false end
    
    return true
end

function isDuiExistsWithData(coords, dataInteraction)
    if not coords or not dataInteraction then return false end
    local key = coordsToKey(coords)
    if not key then return false end
    local interaction = Interactions[key]
    if interaction and interaction.data then
        return isDataEqual(interaction.data, dataInteraction)
    end
    return false
end

function createDUI(coords, dataInteraction)
    if not coords or not dataInteraction then return false end
    local key = coordsToKey(coords)

    if Interactions[key] then
        if isDataEqual(Interactions[key].data, dataInteraction) then
            return false
        end
    end

    Interactions[key] = {
        coords = coords,
        data = dataInteraction,
        jobBlacklist = dataInteraction.jobBlacklist,
        jobWhitelist = dataInteraction.jobWhitelist
    }

    startDuiManagerIfNeeded()
    return true
end

function startDuiManagerIfNeeded()
    if duiManagerStarted then return end
    duiManagerStarted = true
    
    initDuiPool()

    CreateThread(function()
        local playerJob = nil
        local lastJobCheck = 0
        local lastSortTime = 0
        local sortedNearby = {}
        local needsResort = true
        
        while true do
            local sleep = 200
            
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local camCoord = GetGameplayCamCoord()
            local currentTime = GetGameTimer()
            
            -- Aktualizacja job tylko co 2 sekundy
            if currentTime - lastJobCheck > 2000 then
                playerJob = PlayerData.job and PlayerData.job.name or nil
                lastJobCheck = currentTime
                needsResort = true
            end
            
            -- Filtrowanie i sortowanie tylko gdy potrzeba
            if needsResort or currentTime - lastSortTime > 500 then
                sortedNearby = {}
                
                for key, interaction in pairs(Interactions) do
                    local dist = #(playerCoords - interaction.coords)
                    
                    if dist < 8.0 then
                        local canShow = true
                        if interaction.jobBlacklist then
                            canShow = not interaction.jobBlacklist[playerJob]
                        elseif interaction.jobWhitelist then
                            canShow = interaction.jobWhitelist[playerJob] or false
                        end
                        
                        if canShow then
                            table.insert(sortedNearby, {
                                key = key,
                                interaction = interaction,
                                dist = dist
                            })
                        end
                    end
                end
                
                -- Sortowanie tylko gdy mamy interakcje
                if #sortedNearby > 0 then
                    table.sort(sortedNearby, function(a, b) return a.dist < b.dist end)
                end
                
                lastSortTime = currentTime
                needsResort = false
            end
            
            local activeKeys = {}
            local keysToShow = {}
            
            -- Ograniczenie do MAX_VISIBLE_DUI
            for i = 1, math.min(#sortedNearby, MAX_VISIBLE_DUI) do
                local item = sortedNearby[i]
                if item and item.dist < 6.0 then
                    activeKeys[item.key] = true
                    table.insert(keysToShow, item)
                end
            end
            
            -- Czyszczenie niewidocznych interakcji
            for key, poolIndex in pairs(visibleInteractions) do
                if not activeKeys[key] then
                    hidePoolDui(poolIndex)
                    visibleInteractions[key] = nil
                end
            end
            
            local hasVisible = false
            local screenCoordCache = {}
            
            -- Renderowanie widocznych interakcji
            for _, item in ipairs(keysToShow) do
                local key = item.key
                local interaction = item.interaction
                local dist = item.dist
                
                if dist < 6.0 then
                    -- Cache dla GetScreenCoordFromWorldCoord (sprawdzenie co 100ms)
                    local cacheKey = key .. "_screen"
                    local cached = screenCoordCache[cacheKey]
                    local onScreen, screenX, screenY
                    
                    if cached and (currentTime - cached.time) < 100 then
                        onScreen, screenX, screenY = cached.onScreen, cached.x, cached.y
                    else
                        onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                            interaction.coords.x, 
                            interaction.coords.y, 
                            interaction.coords.z
                        )
                        screenCoordCache[cacheKey] = {
                            onScreen = onScreen,
                            x = screenX,
                            y = screenY,
                            time = currentTime
                        }
                    end
                    
                    if onScreen then
                        local poolIndex = visibleInteractions[key]
                        if not poolIndex then
                            poolIndex = getPoolDuiForKey(key)
                            if poolIndex then
                                visibleInteractions[key] = poolIndex
                            end
                        end
                        
                        if poolIndex and DuiPool[poolIndex] then
                            hasVisible = true
                            
                            updatePoolDuiContent(poolIndex, interaction.data)
                            
                            local camDistance = #(interaction.coords - camCoord)
                            local scale = math.max(0.1, 4.0 / math.max(camDistance, 0.01))
                            
                            DrawSprite(
                                DuiPool[poolIndex].txdName, 
                                DuiPool[poolIndex].textureName, 
                                screenX, screenY, 
                                scale, scale, 
                                0.0, 255, 255, 255, 255
                            )
                        end
                    end
                end
            end
            
            if currentTime % 500 < 50 then
                for k, v in pairs(screenCoordCache) do
                    if (currentTime - v.time) > 500 then
                        screenCoordCache[k] = nil
                    end
                end
            end
            
            if hasVisible then
                sleep = 0
            elseif #sortedNearby > 0 then
                sleep = 50
            else
                sleep = 200
            end
            
            Wait(sleep)
        end
    end)
end
