local SendNUIMessage = SendNUIMessage
local currentRadio = {
    radioName = 'nothing',
    members = {}
}

local hide = false
local streamers = {}

RegisterNetEvent('esx_hud:updateStreamersRadio', function(data)
    streamers = data
end)

RegisterNetEvent('esx_hud:leaveRadio', function()
    hide = true
    currentRadio = {
        radioName = 'nothing',
        members = {}
    }

    SendNUIMessage({
        eventName = "nui:data:update",
        dataId = "radio-data",
        data = {
            channel = nil,
            channelNumber = nil,
            members = {}
        }
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "radio",
        visible = false
    })
end)

RegisterNetEvent('esx_hud:joinRadio', function(data)
    local radioType = 'pd'

    hide = false

    currentRadio = {
        channel = data.radioName,
        channelNumber = data.channel or nil,
        radioType = radioType,
        maxMembers = 50,
        members = {}
    }

    SendNUIMessage({
        eventName = 'nui:data:update',
        dataId = "radio-data",
        data = currentRadio
    })

    SendNUIMessage({
        eventName = "nui:visible:update",
        elementId = "radio",
        visible = not LocalPlayer.state.CamMode
    })
end)

RegisterNetEvent('esx_hud:radio:addPlayerDead', function(bol)
    local myPlayerId = GetPlayerServerId(PlayerId())
    local found = false
    
    for k, v in pairs(currentRadio.members) do
        if v.playerId == myPlayerId then
            v.isDead = bol
            found = true
            break
        end
    end
    
    if not found then return end
    
    TriggerServerEvent('esx_hud:radio:sync_server', currentRadio.members, currentRadio.members)
    
    if not bol and currentRadio.channelNumber then

        --TODOpl tu fixnac jak sie spierdoli
        TriggerServerEvent('pma-radio:getUsersInRadio', currentRadio.channelNumber)
    end
    
    if not hide and not LocalPlayer.state.CamMode then
        SendNUIMessage({
            eventName = 'nui:data:update',
            dataId = "radio-data",
            data = currentRadio
        })
    end
end)

RegisterNetEvent('esx_hud:radio:getSyncing', function()
    TriggerServerEvent('esx_hud:radio:sync_server', currentRadio.members, currentRadio.members)
end)

RegisterNetEvent('esx_hud:syncRadioPlayers', function(players, cp)
    local previousMembers = currentRadio.members
    
    -- Tworzymy mapę poprzednich członków dla zachowania stanu (isDead, isTalking)
    local previousMembersMap = {}
    for k, v in pairs(previousMembers) do
        if v.playerId then
            previousMembersMap[v.playerId] = v
        end
    end
    
    local members = {}
    local seenPlayerIds = {} -- Zapobiegamy duplikatom

    if #players > 0 and not cp then
        cp = players
    end

    local channelNumber = currentRadio.channelNumber
    
    -- Przetwarzamy graczy z serwera, eliminując duplikaty
    for k, v in pairs(players) do
        if not v.id then
            goto continue
        end
        
        -- Sprawdzamy czy już przetworzyliśmy tego gracza (zapobieganie duplikatom)
        if seenPlayerIds[v.id] then
            goto continue
        end
        seenPlayerIds[v.id] = true
        
        local isDead, isTalking = false, false
        
        -- Zachowujemy stan z poprzedniej listy jeśli gracz nadal jest w radiu
        if previousMembersMap[v.id] then
            isDead = previousMembersMap[v.id].isDead or false
            isTalking = previousMembersMap[v.id].isTalking or false
        end
        
        -- Aktualizujemy stan z cp jeśli jest dostępny
        if cp then
            for i, h in pairs(cp) do
                if v.id == h.playerId then
                    isDead = h.isDead or isDead
                    isTalking = h.isTalking or isTalking
                end
            end
        end
        
        local tag = v.id
        local name = v.playerNick
        if(v.channel and v.channel < 101) then
            name = v.label
            tag = v.badge
        end
        
        if channelNumber == nil and v.channel then
            channelNumber = v.channel
        end

        table.insert(members, {
            tag = tag,
            name = name,
            playerId = v.id,
            isTalking = isTalking,
            playerStream = streamers[v.id],
            isDead = isDead,
        })
        
        ::continue::
    end
    
    -- NIE dodajemy z powrotem graczy, którzy opuścili radio/serwer
    -- Jeśli gracz nie jest w nowej liście, oznacza to że opuścił radio
    
    currentRadio.members = members
    currentRadio.channelNumber = channelNumber

    if hide or LocalPlayer.state.CamMode then return end

    SendNUIMessage({
        eventName = 'nui:data:update',
        dataId = "radio-data",
        data = {
            channel = currentRadio.channel,
            channelNumber = currentRadio.channelNumber,
            radioType = currentRadio.radioType,
            maxMembers = currentRadio.maxMembers,
            members = currentRadio.members
        }
    })
end)

RegisterNetEvent('esx_hud:addPlayerTalking', function(id)
    for k, v in pairs(currentRadio.members) do
        if v.playerId == id then
            v.isTalking = true
            break
        end
    end
    
    if not hide and not LocalPlayer.state.CamMode then
        SendNUIMessage({
            eventName = 'nui:data:update',
            dataId = "radio-data",
            data = currentRadio
        })
    end
end)

RegisterNetEvent('esx_hud:removePlayerTalking', function(id)
    for k, v in pairs(currentRadio.members) do
        if v.playerId == id then
            v.isTalking = false
            break
        end
    end

    if not hide and not LocalPlayer.state.CamMode then
        SendNUIMessage({
            eventName = 'nui:data:update',
            dataId = "radio-data",
            data = currentRadio
        })
    end
end)

-- Thread do ukrywania radia w trybie kamery
CreateThread(function()
    local lastCamMode = false
    while true do
        Wait(100)
        local currentCamMode = LocalPlayer.state.CamMode or false
        
        if currentCamMode ~= lastCamMode then
            lastCamMode = currentCamMode
            
            SendNUIMessage({
                eventName = "nui:visible:update",
                elementId = "radio",
                visible = not currentCamMode
            })
        end
        
        -- Jeśli tryb kamery jest włączony, ciągle ukrywaj radio
        if currentCamMode then
            SendNUIMessage({
                eventName = "nui:visible:update",
                elementId = "radio",
                visible = false
            })
        end
    end
end)