Trace = function(...)
    if not Config.Debug then
        return
    end

    local logLine = ""
    local logString = { ... }

    if IsDuplicityVersion() then
        logLine = os.date('%Y-%m-%d %H:%M:%S', os.time())
    end

    logLine = logLine .. " [" .. (GetCurrentResourceName() or "LOG") .. "] "

    for i = 1, #logString do
        logLine = logLine .. tostring(logString[i]) .. " "
    end

    print(logLine)
end

Translate = function(key, args)
    if not Config.Locale then
        return key
    end

    local translation = Locales[Config.Locale][key]

    if not translation then
        return key
    else
        if args then
            for i = 1, #args do
                translation = translation:gsub("%%s", args[i], 1)
            end
        end
    end

    return translation
end

IsResourceStartedOrStarting = function(resource)
    local state = GetResourceState(resource)
    return state == "started" or state == "starting"
end

GenerateUniqueId = function()
    local id = ""

    for i = 1, 3 do
        id = id .. string.upper(string.gsub(string.format("%05d", math.random(0, 99999)), " ", "0"))
        if i < 3 then
            id = id .. "-"
        end
    end

    return id
end

if Config.Framework == "auto" then
    Trace("Detecting framework")
    if IsResourceStartedOrStarting("es_extended") then
        Config.Framework = "esx"
    elseif IsResourceStartedOrStarting("qbx_core") then
        Config.Framework = "qbox"
    elseif IsResourceStartedOrStarting("qb-core") then
        Config.Framework = "qbcore"
    else
        Config.Framework = "standalone"
    end
    Trace("Detected framework: " .. Config.Framework)
end