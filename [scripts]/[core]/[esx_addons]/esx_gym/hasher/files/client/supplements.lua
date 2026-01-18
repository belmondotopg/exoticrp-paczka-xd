local stats = { strength = 0, stamina = 0 }

local function clamp(v)
    if v < 0 then return 0 end
    if v > 100 then return 100 end
    return v
end

local function applyDelta(key, delta)
    local before = stats[key] or 0
    local after = clamp(before + delta)
    stats[key] = after
    return after - before
end

local function fxPulse()
    StartScreenEffect('SuccessMichael', 3000, false)
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    SetTimeout(3000, function()
        StopScreenEffect('SuccessMichael')
    end)
end

local function applyBoost(item)
    local ped = PlayerPedId()
    fxPulse()

    if item.name == 'kreatyna' then
        ESX.ShowNotification('Czujesz przypływ siły')
        local added = applyDelta('strength', 20)
        SetTimeout(10 * 60 * 1000, function()
            if added ~= 0 then applyDelta('strength', -added) end
            ESX.ShowNotification('Działanie ' .. (item.label or 'kreatyny') .. ' ustało')
        end)

    elseif item.name == 'l_karnityna' then
        ESX.ShowNotification('Twoja kondycja rośnie')
        local added = applyDelta('stamina', 20)
        SetTimeout(10 * 60 * 1000, function()
            if added ~= 0 then applyDelta('stamina', -added) end
            ESX.ShowNotification('Działanie ' .. (item.label or 'L-karnityny') .. ' ustało')
        end)

    elseif item.name == 'bialko' then
        ESX.ShowNotification('Lekki boost do wszystkiego')
        local addedStr = applyDelta('strength', 10)
        local addedSta = applyDelta('stamina', 10)
        local health = GetEntityHealth(ped)
        SetEntityHealth(ped, math.min(200, health + 5))
        SetTimeout(10 * 60 * 1000, function()
            if addedStr ~= 0 then applyDelta('strength', -addedStr) end
            if addedSta ~= 0 then applyDelta('stamina', -addedSta) end
            ESX.ShowNotification('Działanie ' .. (item.label or 'Białka') .. ' ustało')
        end)
    end
end

exports('useItem', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then applyBoost(data) end
    end)
end)