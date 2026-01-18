local uiLoaded = false
local clientConfig = {}

local function debug(msg)
    if Config.DebugEnabled then
        print('^3[LC-MINIGAMES]^7 -', msg)
    end
end

CreateThread(function()
    repeat Wait(100) until uiLoaded
    TriggerServerEvent('lc-minigames:requestConfig')
    debug("Requested config from server after UI loaded.")
end)

-- CLIENT NUI CALLBACKS

RegisterNUICallback('uiLoaded', function(_, cb)
    uiLoaded = true
    debug("UI has loaded.")
    cb(1)
end)

RegisterNUICallback("saveConfig", function(data, cb)
    TriggerServerEvent("lc-minigames:updateConfig", data)
    debug("Sent updated config to server.")
    cb(1)
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    debug("Closed NUI focus.")
    cb(1)
end)

RegisterNUICallback("endmg", function(data, cb)
    SetNuiFocus(false, false)
    debug(("Minigame ended: %s"):format(data.name or "unknown"))
    cb(1)
end)

-- CLIENT EVENTS

RegisterNetEvent('lc-minigames:openEditor', function()
    SetNuiFocus(true, true)
    debug("Opening config editor.")
    SendNUIMessage({
        type = 'admin'
    })
end)

RegisterNetEvent('lc-minigames:testMinigame', function(minigame, profileKey)
    SetNuiFocus(true, true)

    local defaultConfig = type(clientConfig.Minigames[minigame]) == "string" and
    json.decode(clientConfig.Minigames[minigame]) or clientConfig.Minigames[minigame] or {}
    local profileData = profileKey and clientConfig.Profiles and clientConfig.Profiles[minigame] and
    clientConfig.Profiles[minigame][profileKey]
    local mergedConfig = defaultConfig

    if profileData and type(profileData) == "table" then
        for k, v in pairs(profileData) do
            mergedConfig[k] = v
        end
    end

    debug(("Testing minigame '%s' with profile '%s'"):format(minigame, profileKey or "none"))

    SendNUIMessage({
        type = "open",
        game = minigame,
        config = mergedConfig,
        profile = profileKey
    })
end)

RegisterNetEvent('lc-minigames:warnUsage', function(data)
    TriggerEvent('chat:addMessage', {
        args = {
            "Invalid minigame --- Press F8 to view minigame names",
        }
    })

    debug(("Invalid command usage: /%s [name]"):format(data.command))

    print("Usage: /" .. data.command .. " [name].")
    print("Available Minigames:")
    for name in pairs(data.minigames) do
        print("- " .. name)
    end
end)

RegisterNetEvent('lc-minigames:receiveConfig', function(config)
    clientConfig = config
    debug("Received minigame config from server.")
    SendNUIMessage({
        type = "updateConfig",
        config = clientConfig or Config or {}
    })
end)

-- EXPORT FUNCTION

local activePromise = nil
local activeCallback = nil

exports('StartMinigame', function(minigame, config, profileKey, cb)
    SetNuiFocus(true, true)

    local defaultConfig = type(clientConfig.Minigames[minigame]) == "string"
        and json.decode(clientConfig.Minigames[minigame])
        or clientConfig.Minigames[minigame] or {}

    local profileData = profileKey
        and clientConfig.Profiles
        and clientConfig.Profiles[minigame]
        and clientConfig.Profiles[minigame][profileKey] or {}

    local mergedConfig = {}

    for k, v in pairs(defaultConfig) do mergedConfig[k] = v end
    for k, v in pairs(profileData) do mergedConfig[k] = v end
    if config and type(config) == "table" then
        for k, v in pairs(config) do mergedConfig[k] = v end
    end

    debug(("Starting minigame '%s' with profile '%s' and custom config."):format(minigame, profileKey or "none"))

    SendNUIMessage({
        type = "open",
        game = minigame,
        config = mergedConfig,
        profile = profileKey
    })

    if cb then
        activeCallback = cb
        return
    end

    activePromise = promise.new()
    return Citizen.Await(activePromise)
end)

RegisterNUICallback("minigameComplete", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "close" })

    debug(("Minigame complete callback fired. Success: %s"):format(tostring(data.success)))

    if activeCallback then
        activeCallback(data)
        activeCallback = nil
    elseif activePromise then
        activePromise:resolve(data.success)
        activePromise = nil
    end

    cb('ok')
end)
