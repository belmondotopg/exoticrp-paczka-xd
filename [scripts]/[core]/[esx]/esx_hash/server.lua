PlayerAction = function(_source)
    if (Globals["AUTO_KICK"].enabled) then
        DropPlayer(_source, string.format(Globals["AUTO_KICK"].message, "SHIELD", ("100")))
    end
end

ScriptLogger = function(resourceName, msg, to, color)
    local colorApplet = {
        ["black"] = 30,
        ["red"] = 31,
        ["green"] = 32,
        ["yellow"] = 33,
        ["blue"] = 34,
        ["magenta"] = 35,
        ["cyan"] = 36,
        ['white'] = 37
    }

    msg = tostring(msg)
    color = colorApplet[color]
    if color == nil then
        color = 0
    end

    if to == 0 then
        print("\27["..color.."m["..resourceName.."]\27[0m "..msg)
    elseif to == 1 then
        local currentFileName = 'log_'..GenerateDate(false, true)
        local frameworkLogs = LoadResourceFile(GetCurrentResourceName(), ("hasher/logs/"..currentFileName..".log"))

        if frameworkLogs == nil then
            local newFileString = ("["..GenerateDate(true, false)..'] '..resourceName..': '..msg)
            SaveResourceFile(GetCurrentResourceName(), ("hasher/logs/"..currentFileName..".log"), newFileString, -1)
        else
            local newFileString = ("\n["..GenerateDate(true, false)..'] '..resourceName..': '..msg)
            frameworkLogs = frameworkLogs..newFileString
            SaveResourceFile(GetCurrentResourceName(), ("hasher/logs/"..currentFileName..".log"), frameworkLogs, -1)
        end
    elseif to == 2 then
        local currentFileName = 'log_'..GenerateDate(false, true)
        local frameworkLogs = LoadResourceFile(GetCurrentResourceName(), ("logs/"..currentFileName..".log"))
    
        if frameworkLogs == nil then
            local newFileString = ("["..GenerateDate(true, false)..'] '..resourceName..': '..msg)
            SaveResourceFile(GetCurrentResourceName(), ("hasher/logs/"..currentFileName..".log"), newFileString, -1)
        else
            local newFileString = ("\n["..GenerateDate(true, false)..'] '..resourceName..': '..msg)
            frameworkLogs = frameworkLogs..newFileString
            SaveResourceFile(GetCurrentResourceName(), ("hasher/logs/"..currentFileName..".log"), frameworkLogs, -1)
        end
        print("\27["..color.."m["..resourceName.."]\27[0m "..msg)
    end
end

GenerateDate = function(withTime, folderFormat)
    local now = os.date("*t", os.time())

    if withTime then
        return (now.year..'/'..now.month..'/'..now.day..' '..now.hour..':'..now.min..':'..now.sec)
    else
        if folderFormat then
            return (now.year..'.'..now.month..'.'..now.day)
        else
            return (now.year..'/'..now.month..'/'..now.day)
        end
    end
end

exports("ScriptLogger", ScriptLogger)
exports("PlayerAction", PlayerAction)
exports("GetOBF", function()
    return OBF
end)