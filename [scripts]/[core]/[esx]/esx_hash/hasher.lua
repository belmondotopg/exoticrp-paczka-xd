if IsDuplicityVersion() then
    local OBF = exports.esx_hash:GetOBF()

    local function HashFile(keys, string)
        local buffer = OBF.ENCODE(keys[1], keys[2], string)
        return buffer
    end

    local function GenerateKeys()
        return {
            [1] = math.random(1000000000, 9999999999),
            [2] = math.random(10000, 99999)
        }
    end

    --// Server Main
    local Hasher_AuthorizedUsers = {}
    local Hasher_ClientSide = {}
    local Hasher_ClientReady = false

    local Loaded_Hasher_Config = LoadResourceFile(GetCurrentResourceName(), "hasher/hasher_config.lua")

    if (Loaded_Hasher_Config ~= nil) then
        local Hasher_Config = json.decode(Loaded_Hasher_Config)
        local errr = ''
        for i=1, #Hasher_Config.files, 1 do
            local source = LoadResourceFile(GetCurrentResourceName(), ("hasher/files/"..Hasher_Config.files[i]))
            if (source ~= nil) then    
                local keys = GenerateKeys()
                table.insert(Hasher_ClientSide, {
                    fileName = Hasher_Config.files[i],
                    fileKeys = keys,
                    fileHash = HashFile(keys, source)
                })
            else
                errr = ("Error at hashing: "..Hasher_Config.files[i].." doesn't exist!")
                break
            end
        end

        if (errr == '') then
            exports.esx_hash:ScriptLogger(GetCurrentResourceName(), "All files got hashed with their own encryption key!", 2, "cyan")
            Hasher_ClientReady = true
        else
            exports.esx_hash:ScriptLogger(GetCurrentResourceName(), errr, 2, "red")
        end
    else
        local cfgTemplate = [[
        {
            "files": [
                "script_file_name.lua",  
                "script_file_name2.lua" 
            ]
        }
        ]]
        exports.esx_hash:ScriptLogger(GetCurrentResourceName(), "Config doesn't exist, creating one...!", 2, "yellow")
        SaveResourceFile(GetCurrentResourceName(), "hasher/hasher_config.lua", cfgTemplate, -1)
        SaveResourceFile(GetCurrentResourceName(), "hasher/files/insert_client_script_here.txt", "And add to hasher_config.cfg!", -1)
        exports.esx_hash:ScriptLogger(GetCurrentResourceName(), "Config has been created, script must be restared!", 2, "yellow")
    end

    --// Auth
    RegisterServerEvent((GetCurrentResourceName()..':downloadClient'))
    AddEventHandler((GetCurrentResourceName()..':downloadClient'), function(_eventName)
        local _source = source
        local _sourceIdentifier = GetPlayerIdentifier(_source, 0)
        
        while (not Hasher_ClientReady) do
            Citizen.Wait(10)
        end
        
        if (Hasher_AuthorizedUsers[_sourceIdentifier:lower()] == nil) then
            Hasher_AuthorizedUsers[_sourceIdentifier:lower()] = _eventName
            TriggerClientEvent(Hasher_AuthorizedUsers[_sourceIdentifier:lower()], _source, Hasher_ClientSide)
        else
            exports.esx_hash:ScriptLogger(GetCurrentResourceName(), GetPlayerName(_source).." (".._sourceIdentifier..") tried to request new hashed files!", 2, "red")
            exports.esx_hash:PlayerAction(_source)
        end
    end)

    RegisterServerEvent((GetCurrentResourceName()..':autoBan'))
    AddEventHandler((GetCurrentResourceName()..':autoBan'), function()
        exports.esx_hash:PlayerAction(source)
    end)

    AddEventHandler('playerDropped', function(reason)
        local _source = source
        local _sourceIdentifier = GetPlayerIdentifier(_source, 0)

        if (Hasher_AuthorizedUsers[_sourceIdentifier:lower()] ~= nil) then
            Hasher_AuthorizedUsers[_sourceIdentifier:lower()] = nil
        end
    end)
else
    Citizen.CreateThread(function()
        math.randomseed(GetGameTimer())

        local clientLoaded = false
        local eventName = (GetCurrentResourceName()..':'..math.random(1000,9999)..'-'..math.random(1000,9999))

        local OBF = exports.esx_hash:GetOBF()
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, function(scripts)
            if (clientLoaded == false) then
                if (OBF ~= nil) then
                    clientLoaded = true
                    for i=1, #scripts, 1 do
                        load(OBF.DECODE(scripts[i].fileKeys[1], scripts[i].fileKeys[2], scripts[i].fileHash))()
                        scripts[i] = nil
                    end
                    scripts = nil
                end
            else
                -- TriggerServerEvent((GetCurrentResourceName()..':autoBan'))
            end
        end)

        TriggerServerEvent((GetCurrentResourceName()..':downloadClient'), eventName)
    end)
end