local function formatSpecialisationStats(opts)
    if (not opts) then 
        return nil 
    end

    return {
        label = opts.label,
        level = opts.tier or 1,
        current = opts.current or 0,
        required = opts.required or 0,
        unit = opts.unit or "MISJI",
        colorKey = opts.colorKey or "default",
    }
end

lib.callback.register("esx_hud/getPlayerStatistics", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local data = {}

    local gymStats = exports.esx_gym:getPlayerStats(source)
    for k, v in pairs(gymStats or {}) do
        table.insert(data, {
            label = Config.StatisticsLabels[k] or k,
            current = v,
            level = v,
            required = 100,
            unit = "%",
            colorKey = "default",
        })
    end

    local tCurrent, tRequired, tTier = exports.esx_tracker:getSpecialisation(source)

    table.insert(data, formatSpecialisationStats({
        label = "Tracker",
        current = tCurrent,
        required = tRequired,
        tier = tTier,
        unit = "MISJI",
        colorKey = "red",
    }))

    local hCurrent, hRequired, hTier = exports.esx_houserobbery:getSpecialisation(source)

    table.insert(data, formatSpecialisationStats({
        label = "Włamywacz",
        current = hCurrent,
        required = hRequired,
        tier = hTier,
        unit = "MISJI",
        colorKey = "red",
    }))

    local dCurrent, dRequired, dTier = exports.esx_selldrugs:getPlayerLevel(source)

    table.insert(data, formatSpecialisationStats({
        label = "Diler Narkotyków",
        current = dCurrent,
        required = dRequired,
        tier = dTier,
        unit = "EXP",
        colorKey = "red",
    }))

    return data
end)
