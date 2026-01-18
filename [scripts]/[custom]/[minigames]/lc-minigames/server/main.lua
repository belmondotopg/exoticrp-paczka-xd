local sharedConfig = nil

local function debug(msg)
    if Config.DebugEnabled then
        print("^3[LC-MINIGAMES]^7 - " .. msg)
    end
end

-- COMMANDS
for _, name in ipairs(Config.CommandNames.TestMinigame) do
    lib.addCommand(name, {
        help = 'Przetestuj minigrę',
        restricted = Config.Permission,
        params = {
            { name = 'minigame', help = 'Nazwa minigry do zagrania (np. AimLab, Lockpick)' },
            { name = 'profile',  help = 'Klucz profilu do użycia (opcjonalny)',                       optional = true }
        }
    }, function(source, args, raw)
        local minigame = args.minigame
        local profileKey = args.profile
        local key = minigame and minigame:lower()

        local availableMinigamesList = {
            'ArrowClicker', 'LockSpinner', 'RhythmClick', 'Lockpick',
            'AimLab', 'ArrowGridMaze', 'PipeConnect', 'FlappyBird',
            'CodeFind', 'ColorMemory', 'MineSweeper', 'KnobTurn',
            'PairMatch', 'PipeDodge', 'SymbolMemory', 'Balance',
            'LettersFall', 'PipeJigsaw', 'RhythmArrows', 'BreakerPuzzle',
            'MacrodataRefinement'
        }

        local availableMinigames = {}
        for _, mgName in ipairs(availableMinigamesList) do
            availableMinigames[mgName:lower()] = mgName
        end

        if not key or not availableMinigames[key] then
            TriggerClientEvent('lc-minigames:warnUsage', source, {
                command = name,
                minigames = availableMinigames
            })
            debug(("Invalid minigame command usage by player %s."):format(source))
            return
        end

        debug(("Player %s started test minigame '%s' with profile '%s'."):format(source, key, profileKey or "none"))
        TriggerClientEvent('lc-minigames:testMinigame', source, availableMinigames[key], profileKey)
    end)
end

for _, name in ipairs(Config.CommandNames.MinigameEditor) do
    lib.addCommand(name, {
        help = 'Otwórz Edytor Minigier',
        restricted = Config.Permission,
    }, function(source, args, raw)
        debug(("Player %s opened the editor."):format(source))
        TriggerClientEvent('lc-minigames:openEditor', source)
    end)
end

local function mergeMissingDefaults(target, source, prefix, missing)
    prefix = prefix or ""
    missing = missing or {}

    for k, v in pairs(source) do
        local fullKey = prefix .. k
        if target[k] == nil then
            target[k] = v
            table.insert(missing, fullKey)
        elseif type(v) == "table" and type(target[k]) == "table" then
            mergeMissingDefaults(target[k], v, fullKey .. ".", missing)
        end
    end

    return missing
end

-- CONFIG SETUP

local dbConfig = exports['lc-settings']:GetAllSettings('server_settings', 'name', 'minigames')
if not dbConfig then
    debug("No saved config found. Using fallback Config.")
    sharedConfig = Config
else
    debug("Loaded config from database.")
    sharedConfig = dbConfig
    if type(sharedConfig) == 'string' then sharedConfig = json.decode(sharedConfig) end
    if type(sharedConfig.Minigames) == 'string' then sharedConfig.Minigames = json.decode(sharedConfig.Minigames) end
    if type(sharedConfig.GlobalConfig) == 'string' then
        sharedConfig.GlobalConfig = json.decode(sharedConfig
            .GlobalConfig)
    end
    if type(sharedConfig.Profiles) == 'string' then sharedConfig.Profiles = json.decode(sharedConfig.Profiles) end
end

if Config.MergeMissingKeys then
    local missingKeys = mergeMissingDefaults(sharedConfig, Config)
    if #missingKeys > 0 then
        debug("Merged missing config keys into sharedConfig:")
        for _, key in ipairs(missingKeys) do
            print(" - " .. key)
        end
    end
end

exports['lc-settings']:EnsureSettingsRow('server_settings', 'name', 'minigames')
for minigame, cfg in pairs(sharedConfig) do
    exports['lc-settings']:SaveSettings('server_settings', 'name', 'minigames', minigame, cfg)
end

RegisterNetEvent('lc-minigames:requestConfig', function()
    local src = source
    debug(("Sending config to player %s"):format(src))
    TriggerClientEvent('lc-minigames:receiveConfig', src, sharedConfig)
end)

RegisterNetEvent('lc-minigames:updateConfig', function(data)
    if not data or (not data.config and not data.profile) then return end

    if data.minigame == 'ALL' then
        debug("Saving all minigame configs + global config.")
        for minigame, config in pairs(data.config) do
            sharedConfig.Minigames[minigame] = config
        end
        sharedConfig.GlobalConfig = data.globalConfig
        exports['lc-settings']:SaveSettings('server_settings', 'name', 'minigames', 'Minigames', sharedConfig.Minigames)
        exports['lc-settings']:SaveSettings('server_settings', 'name', 'minigames', 'GlobalConfig',
            sharedConfig.GlobalConfig)
    else
        local minigame = data.minigame
        if data.config then
            sharedConfig.Minigames[minigame] = data.config
            debug(("Saved config for minigame '%s'."):format(minigame))
            exports['lc-settings']:SaveSettings('server_settings', 'name', 'minigames', 'Minigames',
                sharedConfig.Minigames)
        end
        if data.profile then
            sharedConfig.Profiles = sharedConfig.Profiles or {}
            sharedConfig.Profiles[minigame] = sharedConfig.Profiles[minigame] or {}
            sharedConfig.Profiles[minigame][data.profile.key] = data.profile.data
            debug(("Saved profile '%s' for minigame '%s'."):format(data.profile.key, minigame))
            exports['lc-settings']:SaveSettings('server_settings', 'name', 'minigames', 'Profiles', sharedConfig
                .Profiles)
        end
    end

    TriggerClientEvent('lc-minigames:receiveConfig', -1, sharedConfig)
    debug("Broadcasted updated config to all players.")
end)
