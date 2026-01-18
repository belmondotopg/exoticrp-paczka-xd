if not Config.LungTraining or not Config.LungTraining.enabled then
    return
end

local lungTraining = {
    isUnderwater = false,
    isSwimming = false,
    isRunning = false,
    underwaterTime = 0,
    swimmingTime = 0,
    runningTime = 0,
    underwaterGainedThisSession = 0,
    swimmingGainedThisSession = 0,
    runningGainedThisSession = 0,
    underwaterCooldownEnd = 0,
    swimmingCooldownEnd = 0,
    runningCooldownEnd = 0,
    activeThreads = {},
}

local function isCooldownActive(cooldownEnd)
    return GetGameTimer() < cooldownEnd
end

local function setCooldown(activityType, duration)
    local cooldownEnd = GetGameTimer() + duration
    
    if activityType == 'underwater' then
        lungTraining.underwaterCooldownEnd = cooldownEnd
    elseif activityType == 'swimming' then
        lungTraining.swimmingCooldownEnd = cooldownEnd
    elseif activityType == 'running' then
        lungTraining.runningCooldownEnd = cooldownEnd
    end
end

local function applyPlayerStats(stats)
    if not stats then return end
    
    if stats.stamina then
        local staminaValue = math.floor(stats.stamina * 1.0)
        StatSetInt(`MP0_STAMINA`, staminaValue, true)
        StatSetInt(`MP1_STAMINA`, staminaValue, true)
    end
    
    if stats.strength then
        local strengthValue = math.floor(stats.strength * 1.0)
        StatSetInt(`MP0_STRENGTH`, strengthValue, true)
        StatSetInt(`MP1_STRENGTH`, strengthValue, true)
    end
    
    if stats.lung then
        local lungValue = math.floor(stats.lung * 1.0)
        StatSetInt(`MP0_LUNG_CAPACITY`, lungValue, true)
        StatSetInt(`MP1_LUNG_CAPACITY`, lungValue, true)
    end
end

local function updateLungSkill(amount, activityName)
    if amount <= 0 then return end
    
    lib.callback('esx_gym/getPlayerStats', false, function(stats)
        if stats and stats.lung < Config.LungTraining.maxSkillLevel then
            local newValue = math.min(stats.lung + amount, Config.LungTraining.maxSkillLevel)
            
            lib.callback('esx_gym/updatePlayerSkill', false, function(success)
                if success then
                    local updatedStats = {
                        stamina = stats.stamina or 0,
                        strength = stats.strength or 0,
                        lung = newValue
                    }
                    
                    applyPlayerStats(updatedStats)
                    
                    SendNUIMessage({
                        action = 'setPlayerStats',
                        data = updatedStats
                    })
                end
            end, 'lung', amount)
        end
    end)
end

local function startUnderwaterTracking()
    if lungTraining.activeThreads.underwater then return end
    
    lungTraining.activeThreads.underwater = true
    
    CreateThread(function()
        while Config.LungTraining.underwater.enabled do
            Wait(1000)
            
            local ped = PlayerPedId()
            local isCurrentlyUnderwater = IsPedSwimmingUnderWater(ped)
            
            if isCurrentlyUnderwater and not lungTraining.isUnderwater then
                lungTraining.isUnderwater = true
                lungTraining.underwaterTime = 0
                lungTraining.underwaterGainedThisSession = 0
            end
            
            if isCurrentlyUnderwater and lungTraining.isUnderwater then
                lungTraining.underwaterTime = lungTraining.underwaterTime + 1
                
                if lungTraining.underwaterTime >= Config.LungTraining.underwater.minTimeUnderwater then
                    if not isCooldownActive(lungTraining.underwaterCooldownEnd) then
                        if lungTraining.underwaterGainedThisSession < Config.LungTraining.underwater.maxGainPerSession then
                            local gain = Config.LungTraining.underwater.skillGainPerCheck
                            lungTraining.underwaterGainedThisSession = lungTraining.underwaterGainedThisSession + gain
                            
                            updateLungSkill(gain, 'Nurkowanie')
                            
                            lungTraining.underwaterTime = 0
                        else
                            setCooldown('underwater', Config.LungTraining.underwater.cooldown)
                            lungTraining.underwaterGainedThisSession = 0
                            lungTraining.underwaterTime = 0
                        end
                    end
                end
            end
            
            if not isCurrentlyUnderwater and lungTraining.isUnderwater then
                lungTraining.isUnderwater = false
                lungTraining.underwaterTime = 0
            end
        end
        
        lungTraining.activeThreads.underwater = false
    end)
end

local function startSwimmingTracking()
    if lungTraining.activeThreads.swimming then return end
    
    lungTraining.activeThreads.swimming = true
    
    CreateThread(function()
        while Config.LungTraining.swimming.enabled do
            Wait(1000)
            
            local ped = PlayerPedId()
            local isCurrentlySwimming = IsPedSwimming(ped) and not IsPedSwimmingUnderWater(ped)
            
            if isCurrentlySwimming and not lungTraining.isSwimming then
                lungTraining.isSwimming = true
                lungTraining.swimmingTime = 0
                lungTraining.swimmingGainedThisSession = 0
            end
            
            if isCurrentlySwimming and lungTraining.isSwimming then
                lungTraining.swimmingTime = lungTraining.swimmingTime + 1
                
                if lungTraining.swimmingTime >= Config.LungTraining.swimming.minTimeSwimming then
                    if not isCooldownActive(lungTraining.swimmingCooldownEnd) then
                        if lungTraining.swimmingGainedThisSession < Config.LungTraining.swimming.maxGainPerSession then
                            local gain = Config.LungTraining.swimming.skillGainPerCheck
                            lungTraining.swimmingGainedThisSession = lungTraining.swimmingGainedThisSession + gain
                            
                            updateLungSkill(gain, 'Pływanie')
                            
                            lungTraining.swimmingTime = 0
                        else
                            setCooldown('swimming', Config.LungTraining.swimming.cooldown)
                            lungTraining.swimmingGainedThisSession = 0
                            lungTraining.swimmingTime = 0
                        end
                    end
                end
            end
            
            if not isCurrentlySwimming and lungTraining.isSwimming then
                lungTraining.isSwimming = false
                lungTraining.swimmingTime = 0
            end
        end
        
        lungTraining.activeThreads.swimming = false
    end)
end

local function startRunningTracking()
    if lungTraining.activeThreads.running then return end
    
    lungTraining.activeThreads.running = true
    
    CreateThread(function()
        while Config.LungTraining.running.enabled do
            Wait(1000)
            
            local ped = PlayerPedId()
            local isCurrentlyRunning = IsPedRunning(ped) or IsPedSprinting(ped)
            local isOnFoot = not IsPedInAnyVehicle(ped, false) and not IsPedSwimming(ped)
            
            if isCurrentlyRunning and isOnFoot and not lungTraining.isRunning then
                lungTraining.isRunning = true
                lungTraining.runningTime = 0
                lungTraining.runningGainedThisSession = 0
            end
            
            if isCurrentlyRunning and isOnFoot and lungTraining.isRunning then
                lungTraining.runningTime = lungTraining.runningTime + 1
                
                if lungTraining.runningTime >= Config.LungTraining.running.minTimeRunning then
                    if not isCooldownActive(lungTraining.runningCooldownEnd) then
                        if lungTraining.runningGainedThisSession < Config.LungTraining.running.maxGainPerSession then
                            local gain = Config.LungTraining.running.skillGainPerCheck
                            lungTraining.runningGainedThisSession = lungTraining.runningGainedThisSession + gain
                            
                            updateLungSkill(gain, 'Bieganie')
                            
                            lungTraining.runningTime = 0
                        else
                            setCooldown('running', Config.LungTraining.running.cooldown)
                            lungTraining.runningGainedThisSession = 0
                            lungTraining.runningTime = 0
                        end
                    end
                end
            end
            
            if (not isCurrentlyRunning or not isOnFoot) and lungTraining.isRunning then
                lungTraining.isRunning = false
                lungTraining.runningTime = 0
            end
        end
        
        lungTraining.activeThreads.running = false
    end)
end

CreateThread(function()
    while not ESX do
        Wait(100)
    end
    
    Wait(2000)
    
    if Config.LungTraining.underwater.enabled then
        startUnderwaterTracking()
    end
    
    if Config.LungTraining.swimming.enabled then
        startSwimmingTracking()
    end
    
    if Config.LungTraining.running.enabled then
        startRunningTracking()
    end
end)
exports('getLungTrainingStatus', function()
    return {
        underwater = {
            active = lungTraining.isUnderwater,
            time = lungTraining.underwaterTime,
            gained = lungTraining.underwaterGainedThisSession,
            cooldown = isCooldownActive(lungTraining.underwaterCooldownEnd)
        },
        swimming = {
            active = lungTraining.isSwimming,
            time = lungTraining.swimmingTime,
            gained = lungTraining.swimmingGainedThisSession,
            cooldown = isCooldownActive(lungTraining.swimmingCooldownEnd)
        },
        running = {
            active = lungTraining.isRunning,
            time = lungTraining.runningTime,
            gained = lungTraining.runningGainedThisSession,
            cooldown = isCooldownActive(lungTraining.runningCooldownEnd)
        }
    }
end)

