local PlayerChannels = {}
local GetPlayerName = GetPlayerName

CreateThread(function()
    local columnExists = MySQL.single.await([[
        SELECT COUNT(*) as count 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'users' 
        AND COLUMN_NAME = 'radio_custom_name'
    ]])
    
    if not columnExists or columnExists.count == 0 then
        MySQL.query.await([[
            ALTER TABLE `users` 
            ADD COLUMN `radio_custom_name` VARCHAR(255) NULL DEFAULT NULL;
        ]])
        print("^2[pma-radio]^7 Dodano kolumnę radio_custom_name do tabeli users")
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer, isNew)
    if not xPlayer or not xPlayer.identifier then return end
    
    local result = MySQL.single.await('SELECT radio_custom_name FROM users WHERE identifier = ?', {xPlayer.identifier})
    
    if result and result.radio_custom_name and result.radio_custom_name ~= '' then
        Player(playerId).state.radioCustomName = result.radio_custom_name
    end
end)

RegisterCommand("radionick", function(src, args, raw) 
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not args[1] then return end
    local currentRadio = GetChannel(xPlayer.source)
    if not currentRadio then return end

    local nick = table.concat(args, " ")
    Player(xPlayer.source).state.radioCustomName = nick
    
    MySQL.update('UPDATE users SET radio_custom_name = ? WHERE identifier = ?', {nick, xPlayer.identifier})
    
    UnregisterInChannel(xPlayer.source)
    Wait(100)
    RegisterInChannel(xPlayer.source, currentRadio, tostring(xPlayer.source))
    xPlayer.showNotification("Zmieniłeś nick na: "..nick)
end, false)

function RegisterInChannel(id, channel, label) 

    TriggerClientEvent("pma-radio:stopRadioTalking", -1, id)

    for i = #PlayerChannels, 1, -1 do
        if PlayerChannels[i].id == id then
            table.remove(PlayerChannels, i)
        end    
    end    

    local xPlayer = ESX.GetPlayerFromId(id)
    local gangName = Player(id).state.gangName
    local radioPlayerNick = Player(xPlayer.source).state.radioCustomName or GetPlayerName(id)
    
    local name
    if channel < 101 then
        local firstName = xPlayer.get('firstName') or ''
        local lastName = xPlayer.get('lastName') or ''
        if firstName ~= '' and lastName ~= '' then
            name = firstName..' '..lastName
        else
            name = radioPlayerNick
        end
    else
        name = radioPlayerNick
    end

    if channel < 101 then
        local badge = xPlayer.get('badge')
        if badge then
            local decoded = json.decode(badge)
            if type(decoded) == "table" and decoded.id then
                badge = "["..decoded.id.."]"
            elseif type(decoded) == "number" then
                badge = "["..decoded.."]"
            end
        end

        table.insert(PlayerChannels, {
            id = id,
            channel = channel,
            label = name,
            nick = xPlayer.get('firstName')..' '..xPlayer.get('lastName'),
            playerNick = radioPlayerNick,
            badge = badge,
        })
    else
        table.insert(PlayerChannels, {
            id = id,
            channel = channel,
            label = name,
            nick = xPlayer.get('firstName')..' '..xPlayer.get('lastName'),
            playerNick = radioPlayerNick,
        })
    end

    for ii,vv in ipairs(PlayerChannels) do
        if not (vv.id == id) then
            if tonumber(vv.channel) < 6 then
                TriggerClientEvent("pma-radio:addRadioTalking1", id, vv.id, vv.label, vv.channel)
            end
        end    
    end   

    if tonumber(channel) < 6 then
        TriggerClientEvent("pma-radio:addRadioTalking1", -1, id, name, channel)
    end
    
    -- Zaktualizuj listę graczy dla wszystkich w tym samym kanale
    local playersInChannel = GetPlrsInChannel(channel)
    for i, player in ipairs(playersInChannel) do
        TriggerClientEvent("pma-radio:updateHudPlayerList", player.id, playersInChannel)
    end
end

function UnregisterInChannel(id) 
    -- Znajdź kanał gracza przed usunięciem
    local playerChannel = nil
    for i = #PlayerChannels, 1, -1 do
        if PlayerChannels[i].id == id then
            playerChannel = PlayerChannels[i].channel
            table.remove(PlayerChannels, i)
        end    
    end
    
    TriggerClientEvent("pma-radio:stopRadioTalking", -1, id)
    TriggerClientEvent("pma-radio:stopRadioTalking1", -1, id)
    
    -- Zaktualizuj listę graczy dla wszystkich w tym samym kanale
    if playerChannel then
        local playersInChannel = GetPlrsInChannel(playerChannel)
        for i, player in ipairs(playersInChannel) do
            TriggerClientEvent("pma-radio:updateHudPlayerList", player.id, playersInChannel)
        end
    end
end

AddEventHandler('playerDropped', function (reason)
    local src = source
    UnregisterInChannel(src)
end)

function GetChannel(id)
    for i,v in ipairs(PlayerChannels) do
        if v.id == id then
            return v.channel
        end
    end
end

function SendStartTalking(label, id, channel) 
    for i,v in ipairs(PlayerChannels) do
        if v.channel == channel then
            TriggerClientEvent("pma-radio:addRadioTalking", v.id, label, id)
        end    
    end  
end

function SendstopRadioTalking(id, channel) 
    for i,v in ipairs(PlayerChannels) do
        if v.channel == channel then
            TriggerClientEvent("pma-radio:stopRadioTalking", v.id, id)
        end    
    end  
end

function GetPlrsInChannel(channel) 
    local plrs = {}
    local seenIds = {} -- Zapobiegamy duplikatom
    for i,v in ipairs(PlayerChannels) do
        if v.channel == channel and not seenIds[v.id] then
            seenIds[v.id] = true
            table.insert(plrs, v)
        end    
    end
    return plrs
end

RegisterServerEvent("pma-radio:moveInRadioChannel", function(id,channel) 
    local src = source
    
    if ESX.IsPlayerAdmin(src) then
        TriggerClientEvent("pma-radio:movePlayerToChannel", id, channel)
    end
end)

RegisterServerEvent("pma-radio:kickFromRadio", function(id) 
    TriggerClientEvent("pma-radio:kickedFromRadio", id)
end)

RegisterServerEvent("pma-radio:registerRadioChannel", function(chnl) 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.source ~= 0 then
        -- RegisterInChannel sama określi odpowiednią nazwę na podstawie częstotliwości
        RegisterInChannel(src, chnl, tostring(src))
    end 
end)

RegisterServerEvent("pma-radio:unregisterRadioChannel", function() 
    local src = source
    UnregisterInChannel(src)
end)

RegisterServerEvent("pma-radio:openRadioListServer", function(r)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer and xPlayer.source ~= nil and xPlayer.source ~= 0 then
        if r == "all" then
            TriggerClientEvent("pma-radio:openCrimeRadio", src, PlayerChannels)
        else
            TriggerClientEvent("pma-radio:openCrimeRadio", src, GetPlrsInChannel(r))
        end    
    end    
end)

RegisterServerEvent("pma-radio:openRadioListServerFrakcja", function(r)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer and xPlayer.source ~= nil and xPlayer.source ~= 0 then
        local hasPermission = false
        if xPlayer.job and xPlayer.job.grade >= 8 then
            hasPermission = true
        else
            local gangRankName = Player(src).state.gangRankName
            if gangRankName and (string.find(gangRankName:lower(), "leader") or string.find(gangRankName:lower(), "boss") or string.find(gangRankName:lower(), "owner")) then
                hasPermission = true
            end
        end
        
        if hasPermission then
            TriggerClientEvent("pma-radio:openFrakcjaRadioListZarzad", src, GetPlrsInChannel(r))
        else
            TriggerClientEvent("pma-radio:openFrakcjaRadioList", src, GetPlrsInChannel(r))
        end
    end    
end)

RegisterServerEvent("pma-radio:addRadioTalking", function() 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer.source ~= 0 and GetChannel(src) then
        local channel = tonumber(GetChannel(src))
        if not channel then return end
        
        if channel < 101 then
            local firstName = xPlayer.get('firstName') or ''
            local lastName = xPlayer.get('lastName') or ''
            local fullName
            if firstName ~= '' and lastName ~= '' then
                fullName = firstName..' '..lastName
            else
                fullName = Player(src).state.radioCustomName or GetPlayerName(src)
            end
            SendStartTalking(fullName, src, channel)
        else
            local radioPlayerNick = Player(src).state.radioCustomName or GetPlayerName(src)
            SendStartTalking(radioPlayerNick, src, channel)
        end    
    end    
end)

RegisterServerEvent("pma-radio:stopRadioTalking", function() 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.source ~= 0 then
        local radio = GetChannel(src)
        if radio then
            local channel = tonumber(radio)
            if not channel then return end
            SendstopRadioTalking(src, channel)  
        end
    end    
end)

RegisterServerEvent("pma-radio:searchOrgs", function()
    local src = source
    
    local orgsList = exports['op-crime']:getOrganisationsList()
    local orgs = {}
    
    if orgsList then
        for identifier, orgData in pairs(orgsList) do
            table.insert(orgs, {
                id = identifier,
                label = orgData.label or "Unknown"
            })
        end
    end
    
    TriggerClientEvent("pma-radio:returnOrgs", src, orgs)
end)


RegisterServerEvent('pma-radio:getUsersInRadio', function(radio)
    local src = source
    local players = GetPlrsInChannel(radio)
    TriggerClientEvent("pma-radio:updateHudPlayerList", src, players)
end)