local ESX = exports['es_extended']:getSharedObject()
local Inventory = exports.ox_inventory

local PlayerDataCache = {}
local CACHE_EXPIRE_TIME = 300000

GlobalState.FishingEventRanking = ""
local FishingEventTime = 0
local FishingEventRanking = {}
local CaseOpeningCooldown = {}


local function getCachedPlayerData(identifier)
    local cached = PlayerDataCache[identifier]
    if cached and GetGameTimer() - cached.timestamp < CACHE_EXPIRE_TIME then
        return cached.data
    end
    return nil
end

local function setCachedPlayerData(identifier, data)
    PlayerDataCache[identifier] = {
        data = data,
        timestamp = GetGameTimer()
    }
end

local FishDataMap = {}
local RodTypeMap = {}
local PearlTypeMap = {}
local AllowedSellItems = {}
local AchievementMap = {}

CreateThread(function()
    for _, fish in ipairs(Config.Fish) do
        FishDataMap[fish.name] = fish
        AllowedSellItems[fish.name] = true
    end

    for _, rod in ipairs(Config.RodTypes) do
        RodTypeMap[rod.name] = rod
    end

    for _, pearl in ipairs(Config.PearlTypes) do
        PearlTypeMap[pearl.name] = pearl
        AllowedSellItems[pearl.name] = true
    end

    AllowedSellItems['clam'] = nil

    if Config.Achievements then
        for _, achievement in ipairs(Config.Achievements) do
            AchievementMap[achievement.id] = achievement
        end
        print(string.format("^2[exotic_rybak] Załadowano %d osiągnięć^0", #Config.Achievements))
    else
        print("^1[exotic_rybak] BŁĄD: Config.Achievements nie istnieje!^0")
    end
end)

local PlayerStates = {}

local function getPlayerState(src)
    if not PlayerStates[src] then
        PlayerStates[src] = {
            cooldowns = {},
            activeRod = nil,
            isFishing = false,
            fishingStartTime = nil,
            totalFishingTime = 0,
            lastFishingSession = nil
        }
    end
    return PlayerStates[src]
end

local function isOnCooldown(src, cooldownType)
    local state = getPlayerState(src)
    local cd = state.cooldowns[cooldownType]
    return cd and GetGameTimer() < cd
end

local function setCooldown(src, cooldownType, duration)
    local state = getPlayerState(src)
    state.cooldowns[cooldownType] = GetGameTimer() + duration
end

local function isNearAnyFisherman(playerCoords, maxDistance)
    maxDistance = maxDistance or 5.0
    
    if Config.FishingZones then
        for _, zone in ipairs(Config.FishingZones) do
            if zone.npc and zone.npc.coords then
                local npcCoords = vector3(zone.npc.coords.x, zone.npc.coords.y, zone.npc.coords.z)
                if #(playerCoords - npcCoords) <= maxDistance then
                    return true
                end
            end
        end
    end
    
    return false
end

local function formatDate(timestamp)
    if not timestamp then return '' end
    return os.date("%d/%m/%Y", timestamp)
end

local function getAchievementProgress(identifier, achievementId)
    local result = MySQL.single.await('SELECT current_progress, completed_tier FROM achievements_progress WHERE identifier = ? AND achievement_id = ?', {
        identifier, achievementId
    })
    if result then
        return result.current_progress or 0, result.completed_tier or 0
    end
    return 0, 0
end

local function setAchievementProgress(identifier, achievementId, progress, completedTier)
    MySQL.insert('INSERT INTO achievements_progress (identifier, achievement_id, current_progress, completed_tier) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE current_progress = ?, completed_tier = ?', {
        identifier, achievementId, progress, completedTier, progress, completedTier
    })
end

local function generateDailyMissions(identifier)
    local today = os.date('%Y-%m-%d')
    local missions = {}
    local generatedTypes = {}
    
    local availableTypes = Config.DailyMissions.Types
    local count = Config.DailyMissions.MissionsPerDay
    
    for i = 1, count do
        local attempt = 0
        local missionConfig = nil
        
        repeat
            missionConfig = availableTypes[math.random(#availableTypes)]
            attempt = attempt + 1
        until (not generatedTypes[missionConfig.type] or attempt > 10)
        
        generatedTypes[missionConfig.type] = true
        
        local goal = 0
        local reward_money = 0
        local reward_xp = 0
        local description = ""
        local extraData = {}
        
        if missionConfig.type == 'catch_specific' then
            goal = math.random(missionConfig.min_count, missionConfig.max_count)
            reward_money = goal * missionConfig.reward_money_per_item
            reward_xp = goal * missionConfig.reward_xp_per_item
            description = string.format(missionConfig.description_template, goal)
            extraData.fish = missionConfig.fish
            
        elseif missionConfig.type == 'catch_any' then
            goal = math.random(missionConfig.min_count, missionConfig.max_count)
            reward_money = goal * missionConfig.reward_money_per_item
            reward_xp = goal * missionConfig.reward_xp_per_item
            description = string.format(missionConfig.description_template, goal)
            
        elseif missionConfig.type == 'catch_rarity' then
            goal = math.random(missionConfig.min_count, missionConfig.max_count)
            reward_money = goal * missionConfig.reward_money_per_item
            reward_xp = goal * missionConfig.reward_xp_per_item
            description = string.format(missionConfig.description_template, goal)
            extraData.rarity = missionConfig.rarity
            
        elseif missionConfig.type == 'earn_money' then
            goal = math.random(missionConfig.min_amount, missionConfig.max_amount)
            goal = math.ceil(goal / 100) * 100
            reward_money = missionConfig.reward_money
            reward_xp = missionConfig.reward_xp
            description = string.format(missionConfig.description_template, goal)
        end
        
        MySQL.insert('INSERT INTO daily_missions (identifier, date, mission_index, mission_type, goal, reward_money, reward_xp, description, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
            identifier, today, i, missionConfig.type, goal, reward_money, reward_xp, description, json.encode(extraData)
        })
    end
end

local function getDailyMissions(identifier)
    local today = os.date('%Y-%m-%d')
    
    local missions = MySQL.query.await('SELECT * FROM daily_missions WHERE identifier = ? AND date = ?', { identifier, today })
    
    if not missions or #missions == 0 then
        generateDailyMissions(identifier)
        missions = MySQL.query.await('SELECT * FROM daily_missions WHERE identifier = ? AND date = ?', { identifier, today })
    end
    
    local clientMissions = {}
    for _, m in ipairs(missions) do
        table.insert(clientMissions, {
            id = m.id,
            description = m.description,
            progress = m.progress,
            goal = m.goal,
            reward_money = m.reward_money,
            reward_xp = m.reward_xp,
            completed = m.completed,
            type = m.mission_type,
            data = m.data and json.decode(m.data) or {}
        })
    end
    
    return clientMissions
end

local function getNextLevelXP(level, configTable)
    if level >= #configTable then return nil end
    local levelData = configTable[level + 1]
    return levelData and levelData.required_xp or nil
end

local function calculateTotalXP(playerLevel, currentXP)
    if not playerLevel or playerLevel < 1 then return currentXP or 0 end
    
    local totalXP = currentXP or 0
    
    for i = 1, playerLevel - 1 do
        local levelData = Config.PlayerLevels[i]
        if levelData and levelData.required_xp then
            totalXP = totalXP + levelData.required_xp
        end
    end
    
    return totalXP
end

local function getPlayerLevel(identifier, firstname, lastname)
    local cached = getCachedPlayerData(identifier)
    if cached then
        return cached.player_level or 1, cached.player_xp or 0
    end
    
    local row = MySQL.single.await('SELECT player_level, player_xp FROM gracze_rybacy WHERE identifier = ?', { identifier })
    if not row then
        MySQL.insert.await('INSERT INTO gracze_rybacy (identifier, firstname, lastname) VALUES (?, ?, ?)', { identifier, firstname or '', lastname or '' })
        setCachedPlayerData(identifier, { player_level = 1, player_xp = 0 })
        return 1, 0
    end
    
    setCachedPlayerData(identifier, row)
    return row.player_level or 1, row.player_xp or 0
end

local function addPlayerXP(identifier, gained, firstname, lastname)
    local level, xp = getPlayerLevel(identifier, firstname, lastname)
    local newXp = xp + gained
    local requiredXP = getNextLevelXP(level, Config.PlayerLevels)

    if requiredXP and newXp >= requiredXP then
        local remainingXp = newXp - requiredXP
        MySQL.update.await('UPDATE gracze_rybacy SET player_level = ?, player_xp = ?, firstname = ?, lastname = ? WHERE identifier = ?', { level + 1, remainingXp, firstname or '', lastname or '', identifier })
        setCachedPlayerData(identifier, { player_level = level + 1, player_xp = remainingXp })
        return level + 1, true
    else
        MySQL.update.await('UPDATE gracze_rybacy SET player_xp = ?, firstname = ?, lastname = ? WHERE identifier = ?', { newXp, firstname or '', lastname or '', identifier })
        setCachedPlayerData(identifier, { player_level = level, player_xp = newXp })
        return level, false
    end
end

local function updateMissionProgress(source, identifier, type, amount, extraData)
    local missions = getDailyMissions(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    for _, mission in ipairs(missions) do
        if not mission.completed and mission.type == type then
            local shouldUpdate = false
            
            if type == 'catch_specific' then
                if extraData and extraData.fish == mission.data.fish then
                    shouldUpdate = true
                end
            elseif type == 'catch_any' then
                shouldUpdate = true
            elseif type == 'catch_rarity' then
                if extraData and extraData.rarity == mission.data.rarity then
                    shouldUpdate = true
                end
            elseif type == 'earn_money' then
                shouldUpdate = true
            end
            
            if shouldUpdate then
                local newProgress = mission.progress + amount
                local completed = false
                
                if newProgress >= mission.goal then
                    newProgress = mission.goal
                    completed = true
                    
                    if xPlayer then
                        xPlayer.addMoney(mission.reward_money)
                        
                        if mission.reward_xp > 0 then
                            local firstname = xPlayer.get('firstName') or ''
                            local lastname = xPlayer.get('lastName') or ''
                            local newLevel, wasLevelUp = addPlayerXP(xPlayer.identifier, mission.reward_xp, firstname, lastname)
                            
                            if wasLevelUp then
                                xPlayer.showNotification(('Awansowałeś na ~g~%d~s~ poziom rybaka!'):format(newLevel))
                            end
                        end

                        xPlayer.showNotification(string.format('~g~Misja wykonana: %s\n+$%s | +%d XP', mission.description, mission.reward_money, mission.reward_xp))
                    end
                end
                
                MySQL.update('UPDATE daily_missions SET progress = ?, completed = ? WHERE id = ?', {
                    newProgress, completed, mission.id
                })
            end
        end
    end
end

local function checkAndRewardAchievement(source, identifier, achievementId, newProgress)
    local achievement = AchievementMap[achievementId]
    if not achievement then return false end

    local currentProgress, completedTier = getAchievementProgress(identifier, achievementId)
    
    if completedTier >= #achievement.tiers then
        return false
    end

    local nextTier = completedTier + 1
    local tierData = achievement.tiers[nextTier]
    
    if not tierData then return false end

    if newProgress >= tierData.requirement then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end

        xPlayer.addMoney(tierData.reward_money)
        
        setAchievementProgress(identifier, achievementId, newProgress, nextTier)
        
        local tierName = nextTier == 1 and "Brązowy" or (nextTier == 2 and "Srebrny" or "Złoty")
        xPlayer.showNotification(string.format('~y~Osiągnięcie odblokowało!~s~\n%s - %s\n~g~+$%s~s~ | ~p~+%.1f%% rzadkie | +%.1f%% waga', 
            achievement.name, tierName, tierData.reward_money, tierData.bonus_rare, tierData.bonus_weight), 'success')
        
        return true
    else
        if newProgress > currentProgress then
            setAchievementProgress(identifier, achievementId, newProgress, completedTier)
        end
    end
    
    return false
end

local function getAchievementBonuses(identifier)
    local bonuses = { rare = 0, weight = 0 }
    
    for _, achievement in ipairs(Config.Achievements) do
        local _, completedTier = getAchievementProgress(identifier, achievement.id)
        
        for i = 1, completedTier do
            local tierData = achievement.tiers[i]
            if tierData then
                bonuses.rare = bonuses.rare + tierData.bonus_rare
                bonuses.weight = bonuses.weight + tierData.bonus_weight
            end
        end
    end
    
    return bonuses
end

local function updateAchievementFishMaster(source, identifier)
    local playerData = MySQL.single.await('SELECT udane_lowienia FROM gracze_rybacy WHERE identifier = ?', { identifier })
    if playerData then
        checkAndRewardAchievement(source, identifier, 'fish_master', playerData.udane_lowienia)
    end
end

local function updateAchievementRareHunter(source, identifier, fishRarity)
    if fishRarity and (fishRarity == 'rare' or fishRarity == 'epic' or fishRarity == 'legendary') then
        local currentProgress, _ = getAchievementProgress(identifier, 'rare_hunter')
        checkAndRewardAchievement(source, identifier, 'rare_hunter', currentProgress + 1)
    end
end

local function updateAchievementLegendaryFisher(source, identifier, fishRarity)
    if fishRarity and fishRarity == 'legendary' then
        local currentProgress, _ = getAchievementProgress(identifier, 'legendary_fisher')
        checkAndRewardAchievement(source, identifier, 'legendary_fisher', currentProgress + 1)
    end
end

local function updateAchievementWeightCollector(source, identifier, weight)
    if weight then
        local currentProgress, _ = getAchievementProgress(identifier, 'weight_collector')
        local newProgress = currentProgress + math.floor(weight * 1000)
        checkAndRewardAchievement(source, identifier, 'weight_collector', newProgress)
    end
end

local function updateAchievementSpeciesExpert(source, identifier)
    local uniqueSpecies = MySQL.scalar.await([[
        SELECT COUNT(DISTINCT ryba_nazwa) 
        FROM top_ryby 
        WHERE identifier = ?
    ]], { identifier })
    
    if uniqueSpecies then
        checkAndRewardAchievement(source, identifier, 'species_expert', uniqueSpecies)
    end
end

local function updateAchievementMerchant(source, identifier, soldAmount)
    if soldAmount and soldAmount > 0 then
        local currentProgress, _ = getAchievementProgress(identifier, 'merchant')
        checkAndRewardAchievement(source, identifier, 'merchant', currentProgress + soldAmount)
    end
end

local function updateAchievementPearlSeeker(source, identifier)
    local currentProgress, _ = getAchievementProgress(identifier, 'pearl_seeker')
    checkAndRewardAchievement(source, identifier, 'pearl_seeker', currentProgress + 1)
end

local function updateAchievementDedicatedAngler(source, identifier, minutesSpent)
    if minutesSpent and minutesSpent > 0 then
        local currentProgress, _ = getAchievementProgress(identifier, 'dedicated_angler')
        checkAndRewardAchievement(source, identifier, 'dedicated_angler', currentProgress + minutesSpent)
    end
end

local function getRodFromInventoryBySlot(source, slotId)
    if not slotId then return nil end
    
    local inventory = Inventory:GetInventory(source)
    if not inventory then return nil end
    
    for _, item in pairs(inventory.items) do
        if item.slot == slotId then
            return item
        end
    end
    return nil
end

local function getActiveRod(src)
    local state = getPlayerState(src)
    if not state.activeRod or not state.activeRod.slot then
        return nil
    end
    
    local item = getRodFromInventoryBySlot(src, state.activeRod.slot)
    if not item or not RodTypeMap[item.name] then
        return nil
    end
    
    return item
end

local function getBonuses(level, configTable, identifier)
    local levelData = configTable[level]
    local baseBonuses = levelData or { rare_bonus = 0, weight_bonus = 0 }
    
    if identifier then
        local achievementBonuses = getAchievementBonuses(identifier)
        return {
            rare_bonus = baseBonuses.rare_bonus + achievementBonuses.rare,
            weight_bonus = baseBonuses.weight_bonus + achievementBonuses.weight
        }
    end
    
    return baseBonuses
end

local function getRodUpgradePrice(currentLevel)
    return Config.RodUpgradePrices[currentLevel] or 100000
end

local function getRodLabel(rodName)
    local rodType = RodTypeMap[rodName]
    return rodType and rodType.label or 'Wędka'
end

local function addRodXP(src, rodInfo, gained, level)
    if not rodInfo then return end
    
    local meta = rodInfo.metadata or {}
    meta.level = level
    meta.xp = (meta.xp or 0) + gained
    
    Inventory:SetMetadata(src, rodInfo.slot, meta)
end

local function getFishData(fishName)
    return FishDataMap[fishName]
end

local function getRodLevelByName(rodName)
    if not rodName then return nil end
    
    for i, rod in ipairs(Config.RodTypes) do
        if rod.name == rodName then
            return i
        end
    end
    return nil
end

local function updateStatistics(identifier, isSuccessful, fish, firstname, lastname)
    if isSuccessful then
        local fishData = getFishData(fish.name)
        if not fishData then return end

        local fishWeight = fish.weight

        local playerData = MySQL.single.await([[
            SELECT udane_lowienia, najwieksza_ryba_waga, najwieksza_ryba_rarity 
            FROM gracze_rybacy 
            WHERE identifier = ?
        ]], { identifier })

        local isNewRecord = not playerData or fishWeight > playerData.najwieksza_ryba_waga

        if isNewRecord then
            MySQL.execute([[
                UPDATE gracze_rybacy 
                SET udane_lowienia = udane_lowienia + 1,
                    najwieksza_ryba_waga = ?,
                    najwieksza_ryba_nazwa = ?,
                    najwieksza_ryba_rarity = ?,
                    firstname = ?,
                    lastname = ?
                WHERE identifier = ?
            ]], { fishWeight, fish.label, fishData.rarity, firstname or '', lastname or '', identifier })
        else
            MySQL.execute([[
                UPDATE gracze_rybacy 
                SET udane_lowienia = udane_lowienia + 1,
                    firstname = ?,
                    lastname = ?
                WHERE identifier = ?
            ]], { firstname or '', lastname or '', identifier })
        end

        CreateThread(function()
            MySQL.insert([[
                INSERT INTO top_ryby (identifier, firstname, lastname, ryba_nazwa, ryba_waga, rarity) 
                VALUES (?, ?, ?, ?, ?, ?)
            ]], { identifier, firstname or '', lastname or '', fish.label, fishWeight, fishData.rarity })
            
            MySQL.execute([[
                DELETE FROM top_ryby 
                WHERE id NOT IN (
                    SELECT id FROM (
                        SELECT id, 
                               ROW_NUMBER() OVER (ORDER BY ryba_waga DESC) as rn
                        FROM top_ryby
                    ) ranked 
                    WHERE rn <= 10
                )
            ]])
        end)
    else
        MySQL.execute([[
            INSERT INTO gracze_rybacy (identifier, firstname, lastname, nieudane_lowienia, udane_lowienia, najwieksza_ryba_waga) 
            VALUES (?, ?, ?, 1, 0, 0)
            ON DUPLICATE KEY UPDATE nieudane_lowienia = nieudane_lowienia + 1, firstname = ?, lastname = ?
        ]], { identifier, firstname or '', lastname or '', firstname or '', lastname or '' })
    end
end

local function getRandomPearl()
    local totalChance = 0
    for _, pearl in ipairs(Config.PearlTypes) do
        totalChance = totalChance + pearl.chance
    end

    local randomPoint = math.random(totalChance)
    for _, pearl in ipairs(Config.PearlTypes) do
        if randomPoint <= pearl.chance then
            return pearl
        end
        randomPoint = randomPoint - pearl.chance
    end
end

local function getRandomFish(rareBonus)
    local chances = {}
    local totalChance = 0

    for _, fish in ipairs(Config.Fish) do
        local chance = fish.chance
        if fish.rarity ~= 'common' then
            chance = chance * (1 + (rareBonus / 100))
        end
        chances[#chances+1] = { fish = fish, chance = chance }
        totalChance = totalChance + chance
    end

    local randomPoint = math.random() * totalChance
    for _, data in ipairs(chances) do
        if randomPoint < data.chance then
            return data.fish
        end
        randomPoint = randomPoint - data.chance
    end
end

local function roundToTwoDecimals(value)
    return math.floor(value * 100 + 0.5) / 100
end

local function computeCatchOutcome(fishData, totalWeightBonus)
    local minHundredths = math.floor((fishData.minWeight or 0) * 100)
    local maxHundredths = math.floor((fishData.maxWeight or 0) * 100)
    if maxHundredths < minHundredths then maxHundredths = minHundredths end

    local baseWeightKg = (math.random(minHundredths, maxHundredths) / 100)
    local adjustedWeightKg = baseWeightKg * (1 + (totalWeightBonus or 0) / 100)
    adjustedWeightKg = roundToTwoDecimals(adjustedWeightKg)

    local baseXp = fishData.base_xp or 0
    local xpPerKg = fishData.xp_multiplier or 0 
    local xpGained = math.max(0, math.floor(baseXp + (adjustedWeightKg * xpPerKg)))

    local weightGrams = math.floor(adjustedWeightKg * 1000 + 0.5)

    return adjustedWeightKg, weightGrams, xpGained
end

local function GetPlayerPlace(source) 
    local srcString = tostring(source)
    local CurrentPlace = 1

    for RankingSource, CurrentScore in pairs(FishingEventRanking) do 
        if RankingSource ~= srcString and CurrentScore > (FishingEventRanking[srcString] or 0) then 
            CurrentPlace = CurrentPlace + 1
        end
    end

    return CurrentPlace
end

local function UpdateRankingString()
    local SortedRanking = {}
    local RankingString = ""

    for srcString, score in pairs(FishingEventRanking) do 
        local src = tonumber(srcString)
        if src and GetPlayerName(src) then
            local place = GetPlayerPlace(src)
            SortedRanking[place] = {
                Source = src,
                Name = GetPlayerName(src),
                Score = score
            }
        end
    end

    for place, userData in pairs(SortedRanking) do 
        if place > 1 then
            RankingString = RankingString .. "\n"
        end
        RankingString = RankingString .. ("[%d] - %s - x%d"):format(place, userData.Name, userData.Score)
    end

    GlobalState.FishingEventRanking = RankingString
end

AddEventHandler('ox_inventory:itemRemoved', function(source, itemName, itemCount, slotId)
    local state = getPlayerState(source)
    if state.activeRod and state.activeRod.slot == slotId then
        state.activeRod = nil
        TriggerClientEvent('exotic_rybak:hideRod', source)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local identifiers = GetPlayerIdentifier(src, 0)
    
    PlayerStates[src] = nil
    
    if identifiers then
        PlayerDataCache[identifiers] = nil
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local identifier = xPlayer.identifier
    local firstname = xPlayer.get('firstName') or ''
    local lastname = xPlayer.get('lastName') or ''
    
    MySQL.execute('UPDATE gracze_rybacy SET firstname = ?, lastname = ? WHERE identifier = ?', { firstname, lastname, identifier })
end)

ESX.RegisterServerCallback('exotic_rybak:canStartFishing', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return cb(false, 'Błąd gracza')
    end

    if isOnCooldown(source, 'fishing') then
        return cb(false, 'Musisz chwilę odpocząć przed kolejnym połowem.')
    end

    local activeRod = getActiveRod(source)
    if not activeRod then
        return cb(false, 'Nie masz wędki w dłoni.')
    end

    local state = getPlayerState(source)
    state.isFishing = true
    state.fishingStartTime = GetGameTimer()
    setCooldown(source, 'fishing', 2000)
    cb(true)
end)

RegisterNetEvent('exotic_rybak:finishFishing', function(isSuccessful)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local firstname = xPlayer.get('firstName') or ''
    local lastname = xPlayer.get('lastName') or ''

    local state = getPlayerState(source)
    if not state.isFishing then
        print("^1[exotic_rybak] Player " .. source .. " attempted to cheat fishing!^0")
        return
    end

    if not state.fishingStartTime or (GetGameTimer() - state.fishingStartTime < 4000) then
        updateStatistics(xPlayer.identifier, false, nil, firstname, lastname)
        state.isFishing = false
        state.fishingStartTime = nil
        TriggerClientEvent('exotic_rybak:fishResult', source, nil)
        return
    end

    if state.fishingStartTime then
        local fishingDuration = GetGameTimer() - state.fishingStartTime
        state.totalFishingTime = (state.totalFishingTime or 0) + fishingDuration
        
        if state.totalFishingTime >= 300000 then
            local minutesSpent = math.floor(state.totalFishingTime / 60000)
            CreateThread(function()
                updateAchievementDedicatedAngler(source, xPlayer.identifier, minutesSpent)
            end)
            state.totalFishingTime = 0
        end
    end

    state.isFishing = false
    state.fishingStartTime = nil

    if not isSuccessful then
        updateStatistics(xPlayer.identifier, false, nil, firstname, lastname)
        return
    end

    local activeRodInfo = getActiveRod(source)
    if not activeRodInfo then
        xPlayer.showNotification('Nie masz wyposażonej wędki!')
        return 
    end
    
    local rodLevel = getRodLevelByName(activeRodInfo.name) or 1
    local rodBonuses = getBonuses(rodLevel, Config.RodLevels, nil)
    local playerLevel, _ = getPlayerLevel(xPlayer.identifier, firstname, lastname)
    local playerBonuses = getBonuses(playerLevel, Config.PlayerLevels, xPlayer.identifier)
    
    local totalRareBonus = rodBonuses.rare_bonus + playerBonuses.rare_bonus
    local totalWeightBonus = rodBonuses.weight_bonus + playerBonuses.weight_bonus
    
    local fishData = getRandomFish(totalRareBonus)
    if not fishData then
        updateStatistics(xPlayer.identifier, false, nil, firstname, lastname)
        xPlayer.showNotification('Niestety, ryba zerwała się z haczyka!')
        return
    end

    local weight_kg, weight_grams, xpGained = computeCatchOutcome(fishData, totalWeightBonus)

    addRodXP(source, activeRodInfo, xpGained, rodLevel)
    local newLevel, wasLevelUp = addPlayerXP(xPlayer.identifier, xpGained, firstname, lastname)
    updateStatistics(xPlayer.identifier, true, { label = fishData.label, weight = weight_kg, name = fishData.name }, firstname, lastname)

    Inventory:AddItem(source, fishData.name, 1, { weight = weight_grams })

    local logMessage = string.format(
        "Gracz %s [%s] złowił rybę:\n- Nazwa: %s\n- Waga: %.2f kg (%d g)\n- Rzadkość: %s\n- Zdobyte XP: %d",
        GetPlayerName(source) or "Nieznany",
        source,
        fishData.label,
        weight_kg,
        weight_grams,
        fishData.rarity or "common",
        xpGained
    )
    exports.esx_core:SendLog(source, "Złowienie ryby", logMessage, 'rybak-lowienie')
    
    CreateThread(function()
        updateAchievementFishMaster(source, xPlayer.identifier)
        updateAchievementRareHunter(source, xPlayer.identifier, fishData.rarity)
        updateAchievementLegendaryFisher(source, xPlayer.identifier, fishData.rarity)
        updateAchievementWeightCollector(source, xPlayer.identifier, weight_kg)
        updateAchievementSpeciesExpert(source, xPlayer.identifier)
        
        updateMissionProgress(source, xPlayer.identifier, 'catch_any', 1)
        updateMissionProgress(source, xPlayer.identifier, 'catch_specific', 1, { fish = fishData.name })
        updateMissionProgress(source, xPlayer.identifier, 'catch_rarity', 1, { rarity = fishData.rarity })
    end)
    
    if math.random(100) <= Config.ClamChance then
        Inventory:AddItem(source, 'clam', 1)
        xPlayer.showNotification('Przy okazji znalazłeś ~b~małżę~s~!')
    end

    if FishingEventTime > 0 and math.random(100) <= Config.RybakCaseChance then
        local srcString = tostring(source)
        FishingEventRanking[srcString] = (FishingEventRanking[srcString] or 0) + 1

        Inventory:AddItem(source, "fishing_case", 1)
        
        TriggerClientEvent("chat:sendNewAddonChatMessage", -1, "Rybak", {255, 222, 89}, 
            "Gracz " .. GetPlayerName(source) .. " wyłowił Skrzynie Rybacką! Gratulujemy i życzymy powodzenia w dalszym łowieniu.", 
            "fa-solid fa-fishing-rod", {255, 222, 89}, {255, 222, 89})
        UpdateRankingString()
    end

    if wasLevelUp then
        xPlayer.showNotification(('Awansowałeś na ~g~%d~s~ poziom rybaka!'):format(newLevel))
    end
    
    local resultData = {
        name = fishData.label,
        weight = weight_kg,
        xp = xpGained,
        rarity = fishData.rarity
    }
    
    if exports["esx_hud"] then
        exports["esx_hud"]:UpdateTaskProgress(source, "Fishing")
    end
    
    TriggerClientEvent('exotic_rybak:fishResult', source, resultData)
end)

RegisterNetEvent('exotic_rybak:setActiveRod', function(rodName, slotId)
    local state = getPlayerState(source)
    
    if not rodName or not slotId then
        state.activeRod = nil
        return
    end

    local item = getRodFromInventoryBySlot(source, slotId)
    if item and item.name == rodName and RodTypeMap[item.name] then
        state.activeRod = { name = rodName, slot = slotId }
    else
        state.activeRod = nil
    end
end)

ESX.RegisterServerCallback('exotic_rybak:getFishermanData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(nil) end

    local identifier = xPlayer.identifier
    local activeRod = getActiveRod(source)

    local dbStats = MySQL.single.await('SELECT * FROM gracze_rybacy WHERE identifier = ?', { identifier })
    local playerStats = dbStats or {
        udane_lowienia = 0, nieudane_lowienia = 0, najwieksza_ryba_nazwa = 'Brak',
        najwieksza_ryba_waga = 0, player_level = 1, player_xp = 0
    }

    local playerLevel = playerStats.player_level or 1
    local rodLevel, rodXP = 0, 0
    local rodLabel = 'Brak'

    if activeRod then
        local meta = activeRod.metadata or {}
        rodLevel = meta.level or 1
        rodXP = meta.xp or 0
        rodLabel = getRodLabel(activeRod.name)
        rodLevel = getRodLevelByName(activeRod.name) or rodLevel
    end

    local pBonuses = getBonuses(playerLevel, Config.PlayerLevels, identifier)
    local rBonuses = activeRod and getBonuses(rodLevel, Config.RodLevels, nil) or { rare_bonus = 0, weight_bonus = 0 }

    local stats = {
        firstname = playerStats.firstname or xPlayer.get('firstName') or '',
        lastname = playerStats.lastname or xPlayer.get('lastName') or '',
        rank = Config.PlayerRanks[playerLevel] or Config.PlayerRanks[#Config.PlayerRanks],
        rod_price = Config.RodPrice,
        rod_upgrade_price = getRodUpgradePrice(rodLevel),
        rod_level = rodLevel,
        rod_xp = rodXP,
        rod_nextxp = getNextLevelXP(rodLevel, Config.RodLevels) or 'MAX',
        rod_label = rodLabel,
        player_level = playerLevel,
        player_nextxp = getNextLevelXP(playerLevel, Config.PlayerLevels) or 'MAX',
        player_avatar = nil,
        has_rod_in_inventory = false,
        player_bonus_rare = pBonuses.rare_bonus or 0,
        player_bonus_weight = pBonuses.weight_bonus or 0,
        rod_bonus_rare = rBonuses.rare_bonus or 0,
        rod_bonus_weight = rBonuses.weight_bonus or 0,
        najwieksza_ryba_rarity = playerStats.najwieksza_ryba_rarity or 'common'
    }

    for k, v in pairs(playerStats) do
        if not stats[k] then
            stats[k] = v
        end
    end

    local inventory = Inventory:GetInventory(source)
    if inventory then
        for _, item in pairs(inventory.items) do
            if RodTypeMap[item.name] then
                stats.has_rod_in_inventory = true
                break
            end
        end
    end

    local topFishRanking = MySQL.query.await([[
        SELECT t.identifier, t.firstname, t.lastname, t.ryba_nazwa, t.ryba_waga, UNIX_TIMESTAMP(t.data_zlowienia) AS data_zlowienia, t.rarity
        FROM top_ryby t ORDER BY t.ryba_waga DESC LIMIT 10
    ]])
    
    for _, entry in ipairs(topFishRanking) do
        local playerName = 'Nieznany gracz'
        if entry.firstname and entry.lastname then
            playerName = entry.firstname .. ' ' .. entry.lastname
        elseif entry.firstname then
            playerName = entry.firstname
        end
        entry.name = playerName
        entry.date = formatDate(entry.data_zlowienia)
        entry.fish_name = entry.ryba_nazwa
        entry.fish_weight = entry.ryba_waga
    end

    local topPlayerRanking = MySQL.query.await([[
        SELECT g.identifier, g.firstname, g.lastname, g.player_level, g.player_xp
        FROM gracze_rybacy g
    ]])
    
    local playersWithTotalXP = {}
    for _, v in ipairs(topPlayerRanking) do
        local totalXP = calculateTotalXP(v.player_level or 1, v.player_xp or 0)
        table.insert(playersWithTotalXP, {
            identifier = v.identifier,
            firstname = v.firstname,
            lastname = v.lastname,
            player_level = v.player_level or 1,
            player_xp = v.player_xp or 0,
            total_xp = totalXP
        })
    end
    
    table.sort(playersWithTotalXP, function(a, b)
        if a.player_level ~= b.player_level then
            return a.player_level > b.player_level
        end
        return a.total_xp > b.total_xp
    end)
    
    local formattedTopPlayers = {}
    for i = 1, math.min(10, #playersWithTotalXP) do
        local v = playersWithTotalXP[i]
        local playerName = 'Nieznany gracz'
        if v.firstname and v.lastname then
            playerName = v.firstname .. ' ' .. v.lastname
        elseif v.firstname then
            playerName = v.firstname
        end
        table.insert(formattedTopPlayers, { name = playerName, level = v.player_level, xp = v.total_xp })
    end

    local achievements = {}
    if Config.Achievements and type(Config.Achievements) == 'table' then
        for _, achievement in ipairs(Config.Achievements) do
            local currentProgress, completedTier = getAchievementProgress(identifier, achievement.id)
            
            currentProgress = currentProgress or 0
            completedTier = completedTier or 0
            
            local tiers = {}
            if achievement.tiers then
                for i, tier in ipairs(achievement.tiers) do
                    table.insert(tiers, {
                        requirement = tier.requirement,
                        reward_money = tier.reward_money,
                        bonus_rare = tier.bonus_rare,
                        bonus_weight = tier.bonus_weight,
                        completed = i <= completedTier
                    })
                end
            end
            
            table.insert(achievements, {
                id = achievement.id,
                name = achievement.name,
                description = achievement.description,
                icon = achievement.icon,
                currentProgress = currentProgress,
                completedTier = completedTier,
                tiers = tiers
            })
        end
        
        if Config.Debug then
            print(string.format("[exotic_rybak] Wysyłanie %d osiągnięć dla gracza %s", #achievements, identifier))
        end
    else
        print("^1[exotic_rybak] BŁĄD: Config.Achievements nie jest tabelą!^0")
    end

    local rodLevelsData = {}
    for i, rodType in ipairs(Config.RodTypes) do
        local levelData = Config.RodLevels[i]
        table.insert(rodLevelsData, {
            level = i,
            name = rodType.label,
            bonusRare = levelData and levelData.rare_bonus or 0,
            bonusWeight = levelData and levelData.weight_bonus or 0,
            requiredXp = levelData and levelData.required_xp or 0
        })
    end

    local dailyMissions = getDailyMissions(identifier)

    cb({
        stats = stats,
        ranking = topFishRanking,
        rankingGracze = formattedTopPlayers,
        achievements = achievements,
        rodLevels = rodLevelsData,
        dailyMissions = dailyMissions
    })
end)

RegisterNetEvent('exotic_rybak:buyRod', function()
    local source = source
    if isOnCooldown(source, 'buyRod') then return end
    setCooldown(source, 'buyRod', 5000)

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if not isNearAnyFisherman(playerCoords, 5.0) then
        return xPlayer.showNotification('Musisz być bliżej rybaka, aby kupić wędkę.', 'error')
    end

    if getActiveRod(source) then
        return xPlayer.showNotification('Masz już wędkę!')
    end

    if Config.RodPrice <= 0 then
        return xPlayer.showNotification('Błąd konfiguracji ceny! Skontaktuj się z administracją.', 'error')
    end

    if xPlayer.getMoney() < Config.RodPrice then
        return xPlayer.showNotification(('Potrzebujesz ~g~$%s'):format(Config.RodPrice))
    end

    local firstRod = Config.RodTypes[1]
    if not firstRod then
        return xPlayer.showNotification('Błąd konfiguracji! Skontaktuj się z administracją.')
    end

    xPlayer.removeMoney(Config.RodPrice)
    Inventory:AddItem(source, firstRod.name, 1, {
        level = 1,
        xp = 0,
        nextxp = getNextLevelXP(1, Config.RodLevels)
    })
    xPlayer.showNotification('Kupiłeś nową wędkę!')
end)

RegisterNetEvent('exotic_rybak:upgradeRod', function()
    local src = source

    if isOnCooldown(src, 'upgradeRod') then return end
    setCooldown(src, 'upgradeRod', 5000)

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if not isNearAnyFisherman(playerCoords, 5.0) then
        return xPlayer.showNotification('Musisz być bliżej rybaka, aby ulepszyć wędkę.', 'error')
    end

    local activeRodInfo = getActiveRod(src)
    if not activeRodInfo then
        return xPlayer.showNotification('Musisz trzymać wędkę w dłoni, aby ją ulepszyć.', 'error')
    end

    local meta = activeRodInfo.metadata or {}
    local currentLevel = getRodLevelByName(activeRodInfo.name) or (meta.level or 1)
    local currentXp = meta.xp or 0

    local nextLevelData = Config.RodLevels[currentLevel + 1]
    if not nextLevelData then
        return xPlayer.showNotification('Osiągnąłeś maksymalny poziom wędki!', 'inform')
    end

    if currentXp < nextLevelData.required_xp then
        return xPlayer.showNotification('Nie masz wystarczająco dużo punktów doświadczenia, aby ulepszyć wędkę.', 'error')
    end

    local upgradePrice = getRodUpgradePrice(currentLevel)
    if not upgradePrice or upgradePrice <= 0 then
        return xPlayer.showNotification('Błąd ceny ulepszenia! Skontaktuj się z administracją.', 'error')
    end

    if xPlayer.getMoney() < upgradePrice then
        return xPlayer.showNotification(('Nie masz wystarczającej ilości gotówki (%s).'):format(upgradePrice), 'error')
    end

    local newRod = Config.RodTypes[currentLevel + 1]
    if not newRod then
        return xPlayer.showNotification('Błąd konfiguracji wędki! Skontaktuj się z administracją.', 'error')
    end

    xPlayer.removeMoney(upgradePrice)

    local newMeta = {
        level = currentLevel + 1,
        xp = currentXp - nextLevelData.required_xp
    }

    local success = Inventory:RemoveItem(src, activeRodInfo.name, 1, activeRodInfo.metadata, activeRodInfo.slot)
    if success then
        Inventory:AddItem(src, newRod.name, 1, newMeta)

        local newRodData = {
            label = newRod.label,
            level = newMeta.level
        }
        
        TriggerClientEvent('exotic_rybak:hideRod', src)
        TriggerClientEvent('exotic_rybak:rodUpgraded', src, newRodData)
        xPlayer.showNotification('Ulepszyłeś swoją wędkę na: ' .. newRod.label, 'success')
    else
        xPlayer.addMoney(upgradePrice)
        xPlayer.showNotification('Wystąpił błąd podczas ulepszania wędki.', 'error')
    end
end)


RegisterNetEvent('exotic_rybak:openClam', function()
    local source = source
    if isOnCooldown(source, 'clam') then return end
    setCooldown(source, 'clam', 2000)
    
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local clamCount = Inventory:GetItemCount(source, 'clam')
    if clamCount < 1 then
        xPlayer.showNotification('Nie masz małży.')
        return
    end

    Inventory:RemoveItem(source, 'clam', 1)
    
    CreateThread(function()
        updateAchievementPearlSeeker(source, xPlayer.identifier)
    end)
    
    if math.random(100) <= Config.PearlChance then
        local pearl = getRandomPearl()
        Inventory:AddItem(source, pearl.name, 1)
        xPlayer.showNotification(('Znalazłeś %s!'):format(pearl.label))
    else
        xPlayer.showNotification('Małża była pusta.')
    end
end)

local SellStashes = {}

local function getPearlPrice(itemName)
    local pearl = PearlTypeMap[itemName]
    return pearl and pearl.price
end

local function calculateFishSellPrice(item)
    local fishData = getFishData(item.name)
    if not fishData then return 0 end
    
    local pricePerKg = fishData.price or 0
    local weightGram = item.metadata and item.metadata.weight or 0
    if type(weightGram) ~= 'number' then return 0 end
    
    local minG = math.floor((fishData.minWeight or 0) * 1000)
    local maxG = math.floor((fishData.maxWeight or 0) * 1000)
    if maxG < minG then maxG = minG end
    
    weightGram = math.max(minG, math.min(maxG, weightGram))
    local weightKg = weightGram / 1000
    
    return math.floor(pricePerKg * weightKg)
end

ESX.RegisterServerCallback('exotic_rybak:openSell', function(source, cb)
    local src = source

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if not isNearAnyFisherman(playerCoords, 5.0) then
        xPlayer.showNotification('Musisz być bliżej rybaka, aby sprzedać ryby.', 'error')
        return
    end

    local invId = SellStashes[src]
    if not invId then
        invId = exports.ox_inventory:CreateTemporaryStash({
            label = 'Sprzedaż ryb',
            slots = 30,
            maxWeight = 200000,
            owner = src
        })
        SellStashes[src] = invId
    end
    cb(invId)
end)

CreateThread(function()
    while true do
        Wait(300000)
        local now = GetGameTimer()
        for identifier, cached in pairs(PlayerDataCache) do
            if not cached or (now - (cached.timestamp or 0)) > CACHE_EXPIRE_TIME then
                PlayerDataCache[identifier] = nil
            end
        end
    end
end)

AddEventHandler('ox_inventory:closedInventory', function(playerId, invId)
    local src = playerId
    local stashId = SellStashes[src]
    if not stashId or stashId ~= invId then return end

    local items = exports.ox_inventory:GetInventoryItems(stashId)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not items then return end

    local totalSell = 0
    local soldItems = {}
    for _, item in pairs(items) do
        local earned = 0
        if AllowedSellItems[item.name] then
            local pearlPrice = getPearlPrice(item.name)
            if pearlPrice then
                earned = pearlPrice * item.count
            else
                earned = calculateFishSellPrice(item) * item.count
            end
        end

        if earned > 0 then
            totalSell = totalSell + earned
            local itemLabel = item.label or item.name
            local itemWeight = item.metadata and item.metadata.weight or 0
            table.insert(soldItems, {
                name = itemLabel,
                count = item.count,
                price = earned,
                weight = itemWeight
            })
            exports.ox_inventory:RemoveItem(stashId, item.name, item.count, item.metadata, item.slot)
        else
            exports.ox_inventory:RemoveItem(stashId, item.name, item.count, item.metadata, item.slot)
            exports.ox_inventory:AddItem(src, item.name, item.count, item.metadata)
        end
    end

    if totalSell > 0 then
        xPlayer.addMoney(totalSell)
        xPlayer.showNotification(('Sprzedałeś przedmioty za ~g~$%s'):format(totalSell))

        local itemsList = {}
        for _, soldItem in ipairs(soldItems) do
            local weightText = ""
            if soldItem.weight and soldItem.weight > 0 then
                weightText = string.format(" (%.2f kg)", soldItem.weight / 1000)
            end
            table.insert(itemsList, string.format("- %s x%d%s - $%d", soldItem.name, soldItem.count, weightText, soldItem.price))
        end
        
        local logMessage = string.format(
            "Gracz %s [%s] sprzedał ryby:\n%s\n\nCałkowita kwota: $%d",
            GetPlayerName(src) or "Nieznany",
            src,
            table.concat(itemsList, "\n"),
            totalSell
        )
        exports.esx_core:SendLog(src, "Sprzedaż ryb", logMessage, 'rybak-sprzedaz')
        
        CreateThread(function()
            updateAchievementMerchant(src, xPlayer.identifier, totalSell)
            updateMissionProgress(src, xPlayer.identifier, 'earn_money', totalSell)
        end)
    end

    SellStashes[src] = nil
end)

local function GetRandomItem()
    local totalWeight = 0
    for _, itemData in ipairs(Config.RybakCase) do
        totalWeight = totalWeight + itemData.weight
    end
    
    local randomValue = math.random() * totalWeight
    
    local currentWeight = 0
    for _, itemData in ipairs(Config.RybakCase) do
        currentWeight = currentWeight + itemData.weight
        if randomValue <= currentWeight then
            local amount = math.random(itemData.minAmount, itemData.maxAmount)
            return {
                item = itemData.item,
                label = itemData.label,
                amount = amount
            }
        end
    end
    
    local firstItem = Config.RybakCase[1]
    return {
        item = firstItem.item,
        label = firstItem.label,
        amount = math.random(firstItem.minAmount, firstItem.maxAmount)
    }
end

RegisterNetEvent('exotic_rybak:openCase', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local currentTime = GetGameTimer()
    if CaseOpeningCooldown[src] and (currentTime - CaseOpeningCooldown[src]) < 3000 then
        return
    end
    CaseOpeningCooldown[src] = currentTime
    
    local caseCount = Inventory:GetItemCount(src, 'fishing_case')
    if caseCount < 1 then
        xPlayer.showNotification('Nie masz Skrzynki Rybaka.', 'error')
        return
    end
    
    Inventory:RemoveItem(src, 'fishing_case', 1)
    
    local reward = GetRandomItem()
    if not reward then 
        Inventory:AddItem(src, 'fishing_case', 1)
        return 
    end
    
    if reward.item == 'money' then
        xPlayer.addMoney(reward.amount)
        xPlayer.showNotification(('Otrzymałeś ~g~$%s~s~ ze Skrzynki Rybackiej!'):format(reward.amount))
    elseif reward.item == 'black_money' then
        xPlayer.addAccountMoney('black_money', reward.amount)
        xPlayer.showNotification(('Otrzymałeś ~r~$%s~s~ brudnej gotówki ze Skrzynki Rybackiej!'):format(reward.amount))
    else
        local success = Inventory:AddItem(src, reward.item, reward.amount)
        if success then
            xPlayer.showNotification(('Otrzymałeś x%s %s ze Skrzynki Rybackiej!'):format(reward.amount, reward.label))
        else
            xPlayer.showNotification('Nie masz miejsca w ekwipunku!', 'error')
            Inventory:AddItem(src, 'fishing_case', 1)
        end
    end
end)

local function StartFishingEvent(time, adminSource)
    FishingEventTime = time

    TriggerClientEvent("chat:sendNewAddonChatMessage", -1, "EVENT", {255, 222, 89}, 
        "Administrator " .. GetPlayerName(adminSource) .. " Rozpoczął Event Wędkarski na czas: " .. time .. " minut. Podczas eventu macie szanse na wyłowienie Skrzyni Rybaka!", 
        "fa-solid fa-fishing-rod", {255, 222, 89}, {255, 222, 89})
end

RegisterCommand("fishingevent", function(source, args)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer and xPlayer.group == "founder" then 
        local time = tonumber(args[1])
        if time and time > 0 then
            StartFishingEvent(time, src)
        end
    end
end)
CreateThread(function()
    while true do 
        Wait(10000)
        if FishingEventTime > 0 then 
            FishingEventTime = FishingEventTime - 1

            TriggerClientEvent("chat:sendNewAddonChatMessage", -1, "EVENT", {255, 222, 89}, 
                "Na serwerze trwa obecnie Event Rybacki, w trakcie którego macie szanse zdobyć Skrzynie Rybaka podczas łowienia!", 
                "fa-solid fa-fishing-rod", {255, 222, 89}, {255, 222, 89})
        end
    end
end)
