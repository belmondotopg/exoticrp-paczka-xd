local weaponDamageConfig = {
    [`WEAPON_PISTOL`] = {
        modifier = 0.01,
        headshotsToKill = 2,
        bodyshotsToKill = 5
    },
    [`WEAPON_VINTAGEPISTOL`] = {
        modifier = 0.01,
        headshotsToKill = 1,
        bodyshotsToKill = 5
    },
    [`WEAPON_HEAVYPISTOL`] = {
        modifier = 0.01,
        headshotsToKill = 6,
        bodyshotsToKill = 5
    }
}

local defaultConfig = {
    modifier = 0.01,
    headshotsToKill = 2,
    bodyshotsToKill = 5
}

local customHealth = 200
local isDead = false

local meleeWeapons = {
    [`WEAPON_UNARMED`] = true,
    [`WEAPON_KNIFE`] = true,
    [`WEAPON_NIGHTSTICK`] = true,
    [`WEAPON_HAMMER`] = true,
    [`WEAPON_BAT`] = true,
    [`WEAPON_GOLFCLUB`] = true,
    [`WEAPON_CROWBAR`] = true,
    [`WEAPON_BOTTLE`] = true,
    [`WEAPON_DAGGER`] = true,
    [`WEAPON_HATCHET`] = true,
    [`WEAPON_KNUCKLE`] = true,
    [`WEAPON_MACHETE`] = true,
    [`WEAPON_FLASHLIGHT`] = true,
    [`WEAPON_SWITCHBLADE`] = true,
    [`WEAPON_POOLCUE`] = true,
    [`WEAPON_WRENCH`] = true,
    [`WEAPON_BATTLEAXE`] = true
}

local weaponTypes = {
    tazer = {
        [`WEAPON_STUNGUN`] = true,
        [`WEAPON_STUNGUN_MP`] = true
    },
    melee = meleeWeapons,
    snow = {
        [`WEAPON_SNOWBALL`] = true
    }
}

local headBones = {
    [31086] = true,
    [39317] = true,
    [57597] = true,
    [20781] = true,
    [12844] = true,
    [25260] = true,
    [17188] = true,
    [46240] = true,
    [43536] = true,
    [58331] = true,
    [57717] = true
}

local isApplyingDamage = false

CreateThread(function()
    while true do
        Wait(500)
        local ped = PlayerPedId()
        if not DoesEntityExist(ped) then goto continue end
        
        local entityDead = IsEntityDead(ped)
        local currentHealth = GetEntityHealth(ped)
        
        if entityDead and not isDead then
            isDead = true
            customHealth = 100
        elseif not entityDead and isDead then
            isDead = false
            customHealth = 200
            SetEntityHealth(ped, 200)
        elseif not isDead and not isApplyingDamage then
            local healthDiff = math.abs(currentHealth - customHealth)
            if healthDiff > 5 and currentHealth >= 100 and currentHealth <= 200 then
                customHealth = currentHealth
            elseif currentHealth < 100 and not entityDead then
                customHealth = math.max(101, currentHealth)
            end
        end
        
        ::continue::
    end
end)

AddEventHandler('esx:onPlayerSpawn', function()
    customHealth = 200
    isDead = false
    SetEntityHealth(PlayerPedId(), 200)
end)

AddEventHandler('esx:onPlayerDeath', function()
    customHealth = 100
    isDead = true
end)

CreateThread(function()
    for weaponHash, config in pairs(weaponDamageConfig) do
        SetWeaponDamageModifier(weaponHash, config.modifier)
    end
end)

local function GetClosestPlayer(maxDistance)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local closestPlayer = nil
    local closestDistance = maxDistance or 3.0
    local playerId = PlayerId()
    
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= playerId then
            local targetPed = GetPlayerPed(player)
            if DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
                local distance = #(pedCoords - GetEntityCoords(targetPed))
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = targetPed
                end
            end
        end
    end
    
    return closestPlayer, closestDistance
end

local cachedClosestPlayer = nil
local cachedClosestPlayerTime = 0
local CLOSEST_PLAYER_CACHE_TIME = 100

local function GetClosestPlayerCached(maxDistance)
    local currentTime = GetGameTimer()
    if currentTime - cachedClosestPlayerTime < CLOSEST_PLAYER_CACHE_TIME and cachedClosestPlayer then
        return cachedClosestPlayer
    end
    
    cachedClosestPlayer = GetClosestPlayer(maxDistance)
    cachedClosestPlayerTime = currentTime
    return cachedClosestPlayer
end

CreateThread(function()
    local hasMeleeWeapon = false
    local lastLockonSet = false
    
    while true do
        local ped = PlayerPedId()
        
        if not IsEntityDead(ped) then
            local _, currentWeapon = GetCurrentPedWeapon(ped, true)
            hasMeleeWeapon = meleeWeapons[currentWeapon] == true
            
            if hasMeleeWeapon then
                local playerId = PlayerId()
                
                if not lastLockonSet then
                    SetPlayerLockon(playerId, true)
                    SetPlayerLockonRangeOverride(playerId, 5.0)
                    lastLockonSet = true
                end
                
                if IsControlPressed(0, 24) or IsControlPressed(0, 257) then
                    local closestPed = GetClosestPlayerCached(3.5)
                    
                    if closestPed then
                        local targetCoords = GetEntityCoords(closestPed)
                        local pedCoords = GetEntityCoords(ped)
                        local heading = GetHeadingFromVector_2d(targetCoords.x - pedCoords.x, targetCoords.y - pedCoords.y)
                        
                        SetPedDesiredHeading(ped, heading)
                        SetEntityHeading(ped, heading)
                    end
                    Wait(0)
                else
                    Wait(50)
                end
            else
                if lastLockonSet then
                    SetPlayerLockon(PlayerId(), false)
                    lastLockonSet = false
                end
                cachedClosestPlayer = nil
                Wait(500)
            end
        else
            hasMeleeWeapon = false
            if lastLockonSet then
                SetPlayerLockon(PlayerId(), false)
                lastLockonSet = false
            end
            Wait(500)
        end
    end
end)

local helmetIdsMale = {
    -- Przykład: [1] = true, [2] = true, [3] = true,
    -- Dodaj tutaj numery hełmów/czapek dla mężczyzn które mają dawać ochronę
}

local helmetIdsFemale = {
    -- Przykład: [1] = true, [2] = true, [3] = true,
    -- Dodaj tutaj numery hełmów/czapek dla kobiet które mają dawać ochronę
}

local function hasHelmet(ped)
    local helmetIndex = GetPedPropIndex(ped, 0)
    if helmetIndex == -1 or helmetIndex == 0 then
        return false
    end
    
    local isMale = IsPedMale(ped)
    local helmetIds = isMale and helmetIdsMale or helmetIdsFemale
    
    return helmetIds[helmetIndex] == true
end

local function isWeaponType(weapon, weaponType)
    return weaponTypes[weaponType] and weaponTypes[weaponType][weapon] == true
end

local dogModels = {
    [`a_c_chop`] = true,
    [`a_c_pug`] = true,
    [`a_c_rottweiler`] = true
}

local function isDogPed(ped)
    if not DoesEntityExist(ped) then
        return false
    end
    local model = GetEntityModel(ped)
    return dogModels[model] == true
end

AddEventHandler('gameEventTriggered', function(name, data)
    if name ~= 'CEventNetworkEntityDamage' then
        return
    end
    
    local victim = data[1]
    local attacker = data[2]
    local weaponHash = data[5]
    
    if victim == -1 or attacker == -1 then
        return
    end
    
    local isVictimPlayer = IsPedAPlayer(victim)
    local isAttackerPlayer = IsPedAPlayer(attacker)
    local isAttackerDog = isDogPed(attacker)
    
    -- Allow damage if: (both are players) OR (victim is player and attacker is dog)
    if not isVictimPlayer or (not isAttackerPlayer and not isAttackerDog) then
        return
    end
    
    local ped = PlayerPedId()
    if victim ~= ped or isDead then
        return
    end

    if not weaponHash or weaponHash == 0 then
        local _, currentWeapon = GetCurrentPedWeapon(attacker, true)
        weaponHash = (currentWeapon and currentWeapon ~= 0) and currentWeapon or GetSelectedPedWeapon(attacker)
        if weaponHash == 0 then
            weaponHash = `WEAPON_UNARMED`
        end
    end

    local _, bone = GetPedLastDamageBone(victim)
    local isHeadshot = headBones[bone] == true

    if IsPedInAnyVehicle(attacker, false) and not IsPedInAnyVehicle(victim, false) then
        return
    end

    if isAttackerDog then
        weaponHash = `WEAPON_UNARMED`
    elseif isWeaponType(weaponHash, 'tazer') or isWeaponType(weaponHash, 'melee') or isWeaponType(weaponHash, 'snow') or weaponHash == `WEAPON_UNARMED` then
        return
    end

    local dogBiteConfig = {
        modifier = 0.01,
        headshotsToKill = 5,
        bodyshotsToKill = 5
    }
    
    local weaponConfig = isAttackerDog and dogBiteConfig or (weaponDamageConfig[weaponHash] or defaultConfig)
    local damageToApply = 0
    local effectType = "body"
    local wasAlive = customHealth > 100

    if isHeadshot then
        if hasHelmet(ped) then
            damageToApply = 100 / weaponConfig.bodyshotsToKill
            effectType = "helmet"
        else
            damageToApply = 100 / weaponConfig.headshotsToKill
            effectType = "head"
        end
    else
        damageToApply = 100 / weaponConfig.bodyshotsToKill
    end
    
    local attackerServerId = nil
    if isAttackerPlayer then
        attackerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
    end

    isApplyingDamage = true
    
    local currentArmour = GetPedArmour(ped)
    
    if currentArmour > 0 then
        if currentArmour >= damageToApply then
            local newArmour = currentArmour - damageToApply
            SetPedArmour(ped, newArmour)
        else
            SetPedArmour(ped, 0)
            local remainingDamage = damageToApply - currentArmour
            customHealth = customHealth - remainingDamage
        end
    else
        customHealth = customHealth - damageToApply
    end
    
    if customHealth < 100 then
        customHealth = 100
    elseif customHealth > 200 then
        customHealth = 200
    end
    
    if customHealth < 101 then
        SetEntityHealth(ped, 0)
        customHealth = 100
        isDead = true
        
        if wasAlive and (effectType == "head" or effectType == "body") and attackerServerId then
            TriggerServerEvent("TriggerKillEffect", attackerServerId, effectType)
        end
    else
        SetEntityHealth(ped, math.floor(customHealth))
    end
    
    isApplyingDamage = false

    ClearPedLastDamageBone(ped)
    ClearEntityLastDamageEntity(ped)
    
    if attackerServerId then
        ESX.TriggerServerCallback("CustomWeaponDamage", function(result)
        end, effectType, weaponHash, attackerServerId)
    end
end)

RegisterNetEvent('KillEffect', function()
    SetTimecycleModifier("hud_def_desat_cold_kill")
    Wait(300)
    ClearTimecycleModifier()
end)

RegisterNetEvent('HeadEffect', function()
    SetTimecycleModifier("hud_def_desat_cold_kill")
    Wait(300)
    ClearTimecycleModifier()
end)