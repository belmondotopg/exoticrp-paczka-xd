stolenDrugs = {}
playersEXP = {}

CreateThread(function()
    while Framework == nil do
        Wait(100)
    end
end)

if Config.LevelCommand then
    RegisterCommand(Config.LevelCommand, function(source)
        if not playersEXP[tostring(source)] then
            loadPlayerBySrc(source)
        end

        local lvl = levelFromExp(playersEXP[tostring(source)].exp)
        local boost = GetLevelBoost(lvl)

        TriggerClientEvent('esx_selldrugs:sendNotify', source, TranslateIt('level_command', lvl, boost .. "%"), "info", 5)
    end)
end

function getPlayerLevel(source)
    if not playersEXP[tostring(source)] then
        loadPlayerBySrc(source)
    end

    local currentExp = playersEXP[tostring(source)].exp
    local lvl = levelFromExp(currentExp)
    local requiredExp = lvl * Config.Leveling.LevelEXP

    return currentExp, requiredExp, lvl
end
exports('getPlayerLevel', getPlayerLevel)

RegisterNetEvent('esx_selldrugs:getBackDrugs', function()
    local drugsCf = stolenDrugs[tostring(source)]
    if drugsCf then
        local xPlayer = Fr.getPlayerFromId(source)
        if xPlayer then
            Fr.addItem(xPlayer, drugsCf.drugName, drugsCf.amount)
            stolenDrugs[tostring(source)] = nil
        end
    end
end)

RegisterNetEvent('esx_selldrugs:checkAndReturnDrugs', function()
    local drugsCf = stolenDrugs[tostring(source)]
    if drugsCf then
        local xPlayer = Fr.getPlayerFromId(source)
        if xPlayer then
            Fr.addItem(xPlayer, drugsCf.drugName, drugsCf.amount)
            stolenDrugs[tostring(source)] = nil
            TriggerClientEvent('esx_selldrugs:sendNotify', source, TranslateIt('notify_drugs_returned'), "success", 5)
        end
    end
end)

-- Helper:
local function adjustSellChanceByPrice(baseChance, pricePerGram, cfgDrug)
    local minP = cfgDrug.minimumPrice or 0
    local optP = cfgDrug.optimalPrice or pricePerGram or 0
    local maxP = cfgDrug.maximumPrice or (optP > 0 and optP * 2 or 100)

    local influence = (cfgDrug.priceInfluence or 30) * 0.5  

    if optP <= minP then minP = math.max(0, optP - 1) end
    if maxP <= optP then maxP = optP + 1 end

    local factor = 0.0
    if pricePerGram and pricePerGram < optP then
        factor = math.min(1.0, (optP - pricePerGram) / (optP - minP))
    elseif pricePerGram and pricePerGram > optP then
        factor = -math.min(1.0, (pricePerGram - optP) / (maxP - optP))
    else
        factor = 0.0
    end

    local adjusted = baseChance + (factor * influence)
    return math.max(0, math.min(100, adjusted))
end

Fr.RegisterServerCallback('esx_selldrugs:getlvl', function(source, cb)
    if not playersEXP[tostring(source)] then
        loadPlayerBySrc(source)
    end

    local lvl = levelFromExp(playersEXP[tostring(source)].exp)
    return cb(lvl)
end)

Fr.RegisterServerCallback('esx_selldrugs:sellDrug', function(source, cb, drugName, pricePerGram, pedType, cornerSelling)
    local xPlayer = Fr.getPlayerFromId(source)
    if not xPlayer then return cb(false) end

    if Player(source).state.ProtectionTime and Player(source).state.ProtectionTime > 0 then
        TriggerClientEvent('esx_selldrugs:sendNotify', source, 'Nie możesz sprzedawać narkotyków będąc na antytrollu!', "error", 5)
        return cb(false)
    end

    if Config.MinCops and Config.MinCops > 0 then
        local policeCount = GlobalState.Counter and GlobalState.Counter['police'] or 0
        if policeCount < Config.MinCops then
            TriggerClientEvent('esx_selldrugs:sendNotify', source, TranslateIt('notify_min_cops', Config.MinCops), "error", 5)
            return cb(false)
        end
    end

    if Config.JobBlacklist.Enable then
        local playerJob = xPlayer.job.name
        for _, blacklistedJob in ipairs(Config.JobBlacklist.Jobs) do
            if playerJob == blacklistedJob then
                TriggerClientEvent('esx_selldrugs:sendNotify', source, TranslateIt('notify_job_blacklisted'), "error", 5)
                return cb(false)
            end
        end
    end

    local hasItem = Fr.getItem(xPlayer, drugName)
    if not hasItem or not hasItem.amount or hasItem.amount <= 0 then
        debugPrint('[esx_selldrugs] Player doesn\'t have items in inventory:', drugName)
        return cb(false)
    end

    local cfgDrug = Config.DrugSelling.availableDrugs[drugName]
    if not cfgDrug then
        print('[esx_selldrugs] Missing drug config:', drugName)
        return cb(false)
    end

    local cfgPed = Config.PedTypes[pedType]
    if not cfgPed then
        print('[esx_selldrugs] Missing pedType config:', pedType)
        return cb(false)
    end

    local maxPerPed = cfgDrug.maxAmountPedTransaction or 1
    local maxCanSell = math.max(1, math.min(hasItem.amount, maxPerPed))
    local amountSell = math.random(1, maxCanSell)

    if not playersEXP[tostring(source)] then
        loadPlayerBySrc(source)
    end
    local playerLevel = levelFromExp(playersEXP[tostring(source)].exp)

    local multiplier = 1.0 + (GetLevelBoost(playerLevel) / 100.0)
    local finalPrice = math.floor((pricePerGram or 0) * amountSell * multiplier)

    local sellChance, stealChance, refuseChance

    if cornerSelling then
        sellChance  = 80
        stealChance = 20
        refuseChance = 0
    else
        local baseSell = math.max(0, math.min(100, cfgPed.buyChance or 0))
        sellChance  = adjustSellChanceByPrice(baseSell, pricePerGram or cfgDrug.optimalPrice, cfgDrug)
        stealChance = math.max(0, math.min(100, cfgPed.stealDrugChance or 0))
        refuseChance = math.max(0, 100 - (sellChance + stealChance))
    end

    local roll = math.random(1, 100)
    local stealBandEnd = stealChance
    local sellBandEnd  = stealBandEnd + sellChance

    if roll <= stealBandEnd then
        Fr.removeItem(xPlayer, drugName, amountSell)
        stolenDrugs[tostring(source)] = {
            amount = amountSell,
            drugName = drugName, 
        }
        return cb({ steal = true, amount = amountSell })
    elseif roll <= sellBandEnd then
        local label = (cfgDrug.label or drugName)

        local isRivalry = false
        local zoneOwner = false
        if Config.AdditionalScripts.op_Gangs then
            local turfId = exports['op-crime']:getPlayerTurfZone(source)
            if turfId then 
                isRivalry = exports['op-crime']:isTurfZoneInRivalry(turfId)
                zoneOwner = exports['op-crime']:isPlayerTurfOwner(source, turfId)
                TriggerEvent('op-crime:drugSold', source, turfId, finalPrice)

                if isRivalry then 
                    finalPrice = finalPrice / 2
                end

                if zoneOwner then 
                    finalPrice = finalPrice * 1.1
                end
            end
        end
        playersEXP[tostring(source)].exp = playersEXP[tostring(source)].exp + cfgPed.saleEXP 
        playersEXP[tostring(source)].changed = true
        local newLevel = levelFromExp(playersEXP[tostring(source)].exp)

        finalPrice = math.floor(finalPrice)

        Fr.removeItem(xPlayer, drugName, amountSell)
        Fr.ManageDirtyMoney(xPlayer, "add", finalPrice)

        exports.esx_core:SendLog(source, "Sprzedaż narko", "Sprzedał " .. amountSell .. " " .. drugName .. " za " .. finalPrice .. "$", "selldrugs")
        exports["esx_hud"]:UpdateTaskProgress(source, "Drugs")

        return cb({
            sold = true,
            label = label,
            amount = amountSell,
            price = finalPrice,
            newLevel = newLevel,
            isRivalry = isRivalry,
            zoneOwner = zoneOwner
        })
    else
        return cb({ refused = true })
    end
end)

function loadPlayerBySrc(source)
    local ident = Fr.GetIndentifier(source)
    if not ident then
        playersEXP[tostring(source)] = {
            exp = 0,
            changed = false
        }
        return playersEXP[tostring(source)]
    end
    
    local row = MySQL.single.await('SELECT expdrugs FROM ?? WHERE ?? = ?', {
        Fr.usersTable,
        Fr.identificatorTable,
        ident
    })
    
    local exp = row and row.expdrugs or 0
    playersEXP[tostring(source)] = {
        exp = exp,
        changed = false
    }
    return playersEXP[tostring(source)]
end

function SavePlayerXP(src)
    local srcNum = tonumber(src)
    if not srcNum then return end
    
    local ident = Fr.GetIndentifier(srcNum)
    if not ident then return end

    local st = playersEXP[tostring(src)]
    if not st then return end

    MySQL.update.await('UPDATE ?? SET expdrugs = ? WHERE ?? = ?', {
        Fr.usersTable,
        st.exp,
        Fr.identificatorTable,
        ident
    })

    playersEXP[tostring(src)].changed = false
end

CreateThread(function()
    while true do
        Wait(120000)
        for src, st in pairs(playersEXP) do
            if st.changed then 
                SavePlayerXP(src)
                debugPrint('Saved Player:', src)
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = tostring(source)
    if playersEXP[src] and playersEXP[src].changed then 
        SavePlayerXP(source)
        playersEXP[src] = nil
        debugPrint('Saved Player:', src)
    end
end)