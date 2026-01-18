local ESX = ESX
local Citizen = Citizen
local RegisterNetEvent = RegisterNetEvent
local AddEventHandler = AddEventHandler
local TriggerServerEvent = TriggerServerEvent
local TriggerEvent = TriggerEvent
local LocalPlayer = LocalPlayer
local GetPlayerServerId = GetPlayerServerId
local GetActivePlayers = GetActivePlayers
local GetEntityHeading = GetEntityHeading
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetObjectOffsetFromCoords = GetObjectOffsetFromCoords
local DrawText = DrawText
local GetCurrentResourceName = GetCurrentResourceName
local IsEntityVisible = IsEntityVisible
local World3dToScreen2d = World3dToScreen2d
local GetGameplayCamCoord = GetGameplayCamCoord
local GetGameplayCamFov = GetGameplayCamFov
local SetTextScale = SetTextScale
local SetTextFont = SetTextFont
local SetTextProportional = SetTextProportional
local SetTextColour = SetTextColour
local SetTextDropshadow = SetTextDropshadow
local SetTextDropShadow = SetTextDropShadow
local SetTextEdge = SetTextEdge
local SetTextCentre = SetTextCentre
local BeginTextCommandWidth = BeginTextCommandWidth
local AddTextComponentString = AddTextComponentString
local GetTextScaleHeight = GetTextScaleHeight
local EndTextCommandGetWidth = EndTextCommandGetWidth
local SetTextEntry = SetTextEntry
local EndTextCommandDisplayText = EndTextCommandDisplayText
local DrawRect = DrawRect
local GetPlayerFromServerId = GetPlayerFromServerId
local GetPlayerPed = GetPlayerPed
local GetEntityCoords = GetEntityCoords

local FONT = 4
local DISPLAY_TIME = 6000
local MAX_DISPLAYING = 1
local DISPLAY_OFFSET = -0.1
local MAX_DISTANCE = 19.99
local SCENE_DISTANCE = 10.0
local CLOSE_SCENE_DISTANCE = 1.0

local PlayersDescriptions = {}
local scenes = {}
local hidden = false
local ID = false
local nbrDisplaying = 1

local libCache = lib.onCache
local cacheCoords = cache.coords
local cachePlayerId = cache.playerId
local cacheServerId = cache.serverId
local cacheVehicle = cache.vehicle

libCache('coords', function(coords)
    cacheCoords = coords
end)

libCache('playerId', function(playerId)
    cachePlayerId = playerId
end)

libCache('serverId', function(serverId)
    cacheServerId = serverId
end)

libCache('vehicle', function(vehicle)
    cacheVehicle = vehicle
end)

local function isPlayerInRange(pid)
    if pid == cachePlayerId then
        return true
    end
    
    local ped = GetPlayerPed(pid)
    return #(cacheCoords - GetEntityCoords(ped, true)) <= MAX_DISTANCE
end

local function DrawText3D(x, y, z, text, color)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = #(vec3(px, py, pz) - vec3(x, y, z))
    local scale = (1/dist) * 1.7
    local fov = (1/GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen and dist < 25.0 then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(FONT)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextCentre(true)
        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)

        local height = GetTextScaleHeight(0.55*scale, FONT)
        local width = EndTextCommandGetWidth(FONT)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
        DrawRect(_x+0.0011, _y+scale/50, width*1.1, height*1.2, color.r, color.g, color.b, 100)
    end
end

local function DrawText3DPlayersDescription(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    
    if onScreen then
        local size = 0.35
        SetTextScale(size, size)
        SetTextFont(FONT)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextCentre(1)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function Display(mePlayer, text, offset, color)
    local displaying = true

    Citizen.CreateThread(function()
        Citizen.Wait(DISPLAY_TIME)
        displaying = false
    end)

    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1

        while displaying do
            Citizen.Wait(0)
            local ped = GetPlayerPed(mePlayer)
            local coordsMe = GetEntityCoords(ped, false)
            
            if #(cacheCoords - coordsMe) < MAX_DISTANCE then
                if IsEntityVisible(ped) then
                    DrawText3D(coordsMe.x, coordsMe.y, coordsMe.z + 0.75 + offset, text, color)
                end
            end
        end

        nbrDisplaying = nbrDisplaying - 1
    end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(200)
    end

    ESX.TriggerServerCallback('esx_chat:getPlayersDescriptionBeforeQuit', function(PlayersDescription)
        PlayersDescriptions = PlayersDescription
    end)

    TriggerServerEvent('esx_chat:secondDescriptionfetch')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(Job)
    ESX.PlayerData.job = Job
end)

local function handleChatMessage(name, id, group, message, eventName, defaultColor)
    local pid = GetPlayerFromServerId(id)
    
    if pid == -1 or not isPlayerInRange(pid) then
        return
    end
    
    local color = defaultColor or {227, 230, 228}
    if Config.group[group] then
        if ESX.IsPlayerAdminClient() then
            color = Config.group[group]
        elseif ESX.PlayerData.vip then
            color = Config.group["vip"]
        elseif ESX.PlayerData.svip then
            color = Config.group["svip"]
        elseif ESX.PlayerData.elite then
            color = Config.group["elite"]
        end
    end
    
    -- Sprawdź czy kolor nie jest czarny (0,0,0) lub bardzo ciemny
    if color and (color[1] == 0 and color[2] == 0 and color[3] == 0) then
        color = {227, 230, 228} -- Domyślny kolor dla użytkowników
    end
    
    -- Upewnij się, że kolor nie jest nil
    if not color then
        color = {227, 230, 228}
    end
    
    TriggerEvent(eventName, "[" .. id .. "] "..name, {26, 26, 26}, " "..message, "fas fa-comment-dots", color)
end

RegisterNetEvent('esx_chat:sendAddonChatMessage', function(name, id, group, message)
    handleChatMessage(name, id, group, message, 'chat:sendNewAddonChatMessage', {26, 26, 26})
end)

RegisterNetEvent("esx_chat:addOOC", function(id, name, color, message, icon) 
    if ESX.IsPlayerAdminClient() then
        TriggerEvent('chat:sendNewAddonChatMessage', "["..id.."] ^*"..name, color, " "..message, icon)
    else
        TriggerEvent('chat:sendNewAddonChatMessage', "^*"..name, color, " "..message, icon)
    end
end)

RegisterNetEvent("esx_chat:addCrimeOOC", function(id, name, color, message, icon)
    if ESX.PlayerData.job.name ~= 'unemployed' and ESX.PlayerData.job.name ~= nil then
        if ESX.IsPlayerAdminClient() then
            TriggerEvent('chat:sendNewAddonChatMessage', "["..id.."] ^*Crime "..name, color, " "..message, icon)
        else
            TriggerEvent('chat:sendNewAddonChatMessage', "^*Crime "..name, color, " "..message, icon)
        end
    end
end)

RegisterNetEvent("esx_chat:onSendAdminChat", function(id, name, color, message, group)
    if ESX.IsPlayerAdminClient() then
        TriggerEvent('chat:sendNewAddonChatMessage','[ADMINCHAT] [' ..id.. ']' .. " ["..group.."] ^*"..name, color, " "..message, 'fas fa-comment-dots')
    end
end)

RegisterNetEvent('esx_chat:onCheckChatDisplay')
AddEventHandler('esx_chat:onCheckChatDisplay', function(text, source, color)
    local player = GetPlayerFromServerId(source)
    
    if player ~= -1 then
        local offset = 0 + (nbrDisplaying*0.14)
        Display(GetPlayerFromServerId(source), text, offset, color)
    end
end)

local function handleActionMessage(id, name, message, eventName, color)
    local pid = GetPlayerFromServerId(id)
    
    if pid == -1 or not isPlayerInRange(pid) then
        return
    end
    
    local ped = GetPlayerPed(pid)
    if IsEntityVisible(ped) then
        TriggerEvent(eventName, "^*["..name.."]", color, " " .. message, "fas fa-comment-dots", {255, 255, 255})
    end
end

RegisterNetEvent('esx_chat:sendAddonChatMessageMe')
AddEventHandler('esx_chat:sendAddonChatMessageMe', function(id, name, message)
    handleActionMessage(id, name, message, 'chat:sendNewAddonChatMessage', {201, 14, 189})
end)

RegisterNetEvent('esx_chat:sendAddonChatMessageMed')
AddEventHandler('esx_chat:sendAddonChatMessageMed', function(id, name, message)
    handleActionMessage(id, name, message, 'chat:sendNewAddonChatMessage', {255, 26, 26})
end)

RegisterNetEvent('esx_chat:sendAddonChatMessageDo')
AddEventHandler('esx_chat:sendAddonChatMessageDo', function(id, name, message)
    handleActionMessage(id, name, message, 'chat:sendNewAddonChatMessage', {224, 148, 219})
end)

RegisterNetEvent('esx_chat:sendAddonChatMessageCzy')
AddEventHandler('esx_chat:sendAddonChatMessageCzy', function(id, name, message, czy)
    local pid = GetPlayerFromServerId(id)
    
    if pid == -1 or not isPlayerInRange(pid) then
        return
    end
    
    local ped = GetPlayerPed(pid)
    if IsEntityVisible(ped) then
        local color = czy == 1 and {23, 191, 31} or {178, 15, 52}
        local result = czy == 1 and " Udane" or " Nieudane"
        TriggerEvent('chat:sendNewAddonChatMessage', "^*["..name.."]", color, result, "fas fa-dice", {255, 255, 255})
    end
end)

RegisterNetEvent('esx_chat:PlayersDescription')
AddEventHandler('esx_chat:PlayersDescription', function(player, PlayersDescription)
    PlayersDescriptions[player] = PlayersDescription
end)

RegisterNetEvent('esx_chat:PlayersDescriptionOtherPlayers')
AddEventHandler('esx_chat:PlayersDescriptionOtherPlayers', function()
    local MojPlayersDescription = PlayersDescriptions[cacheServerId]
    TriggerServerEvent('esx_chat:PlayersDescriptionOtherPlayersServer', cacheServerId, MojPlayersDescription)
end)

RegisterNetEvent('esx_chat:secondDescriptionsend', function(sent)
    scenes = sent
end)

local function ClosestScene()
    local closestscene = 1000.0
    for i = 1, #scenes do
        local distance = #(scenes[i].coords - cacheCoords)
        if distance < closestscene then
            closestscene = distance
        end
    end
    return closestscene
end

local function ClosestSceneLooking()
    local closestscene = 1000.0
    local scanid = nil
    for i = 1, #scenes do
        local distance = #(scenes[i].coords - cacheCoords)
        if distance < closestscene and distance < CLOSE_SCENE_DISTANCE then
            scanid = i
            closestscene = distance
        end
    end
    return scanid
end


local function Open_Main_Menu()
    ESX.UI.Menu.CloseAll()

    local elements = {
        {label = "Ustaw Opis", value = "setopis"},
        {label = "Usuń Opis", value = "deleteopis"},
        {label = "Ukryj Opisy", value = "hideopis"},
        {label = "Usuń cudzy opis2", value = "deleteotheropis"},
    }

    if ESX.IsPlayerAdminClient() then
        table.insert(elements, {label = "[ ADMIN PANEL ]", value = nil})
        table.insert(elements, {label = "Wyświetl ID opisów", value = 'ID'})
        table.insert(elements, {label = "Usuń wszystkie opisy", value = 'deleteopisy'})
        table.insert(elements, {label = "Usuń opis2", value = 'deleteopis2'})
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'opis_2',
        {
            title = 'Opis',
            align = 'center',
            elements = elements
        },
        function(data, menu)
            if data.current.value == "setopis" then
                ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'opis_2_text',
                {
                    title = "Wpisz Tekst"
                },
                function(data2, menu2)
                    local text = data2.value

                    if text == nil or text == "" then
                        TriggerEvent('esx:showNotification', 'Wiadomość nie może być pusta!')
                        return
                    end
                    
                    local trimmedText = text:gsub("^%s*(.-)%s*$", "%1")
                    if #trimmedText == 0 then
                        TriggerEvent('esx:showNotification', 'Wiadomość nie może być pusta!')
                        return
                    end
                    
                    if #text > 200 then
                        TriggerEvent('esx:showNotification', 'Maksymalna długość opisu2 to 200 znaków!')
                        return
                    end

                    menu2.close()
                    menu.close()
                    local message = data2.value

                    if ClosestScene() > 1.2 then
                        TriggerServerEvent('esx_chat:secondDescriptionadd', cacheCoords, message, ESX.GetClientKey(LocalPlayer.state.playerIndex))
                    else
                        TriggerEvent('esx:showNotification', 'Jesteś zbyt blisko innego opisu!')
                    end
                end,
                function(data2, menu2)
                    menu2.close()
                end)
            end
            
            if data.current.value == "deleteopis" then
                local scene = ClosestSceneLooking()
                if scene ~= nil then
                    TriggerServerEvent('esx_chat:secondDescriptiondelete', scene, ESX.GetClientKey(LocalPlayer.state.playerIndex))
                end
            end

            if data.current.value == "deleteopisy" then
                TriggerServerEvent('esx_chat:secondDescriptionadmindelete2', ESX.GetClientKey(LocalPlayer.state.playerIndex))
            end

            if data.current.value == "deleteopis2" then
                local scene = ClosestSceneLooking()
                if scene ~= nil then
                    TriggerServerEvent('esx_chat:secondDescriptionadmindelete', scene, ESX.GetClientKey(LocalPlayer.state.playerIndex))
                end
            end

            if data.current.value == "deleteotheropis" then
                local scene = ClosestSceneLooking()
                if scene ~= nil then
                    TriggerServerEvent('esx_chat:secondDescriptiondeleteOther', scene, ESX.GetClientKey(LocalPlayer.state.playerIndex))
                else
                    TriggerEvent('esx:showNotification', 'Musisz być blisko opisu, który chcesz usunąć!')
                end
            end

            if data.current.value == "hideopis" then
                hidden = not hidden
                TriggerEvent('esx:showNotification', hidden and 'Wyłączono wyświetlanie opis2' or 'Włączono wyświetlanie opis2')
            end

            if data.current.value == "ID" then
                ID = not ID
                TriggerEvent('esx:showNotification', ID and 'Wyłączono wyświetlanie ID w opis2' or 'Włączono wyświetlanie ID w opis2')
            end
        end,
        function(data, menu)
            menu.close()
        end
    )
end

RegisterCommand('opis2', function(source, args, rawCommand)
    Open_Main_Menu()
end, false)

local function DrawScene(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    if onScreen then
        local size = 0.35
        local px, py, pz = table.unpack(GetGameplayCamCoords())
        local dist = #(vec3(px, py, pz) - vec3(coords.x, coords.y, coords.z))
        local scale = (1 / dist) * 2
        local fov = (1 / GetGameplayCamFov()) * 100
        scale = scale * fov
        
        SetTextScale(size, size)
        SetTextFont(FONT)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextCentre(1)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local playersInRangeCache = {}

local seatOffsets = {
    [-1] = {-0.45, 0.5, 0.5},
    [0] = {0.45, 0.5, 0.5},
    [1] = {-0.45, -0.3, 0.5},
    [2] = {0.45, -0.3, 0.5},
    [3] = {-0.45, 0.5, 0.5},
    [4] = {0.45, 0.5, 0.5},
    [5] = {-0.45, -0.3, 0.5},
    [6] = {0.45, -0.3, 0.5}
}

Citizen.CreateThread(function()
    while true do
        local tempList = {}
        
        for _, player in ipairs(GetActivePlayers()) do
            local id = GetPlayerServerId(player)
            if PlayersDescriptions[id] and tostring(PlayersDescriptions[id]) ~= '' then
                local ped = GetPlayerPed(player)
                local targetCoords = GetEntityCoords(ped, true)
                local distance2 = #(cacheCoords - targetCoords)
                
                if distance2 < 20 and IsEntityVisible(ped) then
                    table.insert(tempList, {
                        player = player,
                        id = id,
                        ped = ped,
                        tekst = tostring(PlayersDescriptions[id])
                    })
                end
            end
        end
        
        playersInRangeCache = tempList
        Citizen.Wait(500)
    end
end)

local scenesInRangeCache = {}

Citizen.CreateThread(function()
    while true do
        if #scenes > 0 and not hidden then
            local tempList = {}
            
            for i = 1, #scenes do
                local v = scenes[i]
                local distance = #(cacheCoords - v.coords)
                if distance <= SCENE_DISTANCE then
                    tempList[#tempList + 1] = {
                        coords = v.coords,
                        message = (ID and v.showid.."~s~ " or "")..v.message
                    }
                end
            end
            
            scenesInRangeCache = tempList
            Citizen.Wait(500)
        else
            scenesInRangeCache = {}
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        local hasPlayers = #playersInRangeCache > 0
        local hasScenes = #scenesInRangeCache > 0 and not hidden
        
        if hasPlayers then
            local veh = cacheVehicle
            
            for i = 1, #playersInRangeCache do
                local data = playersInRangeCache[i]
                local ped = data.ped
                
                if DoesEntityExist(ped) then
                    local targetCoords = GetEntityCoords(ped, true)
                    local x, y, z = targetCoords.x, targetCoords.y, targetCoords.z
                    
                    if veh and veh ~= 0 then
                        local targetheading = GetEntityHeading(ped)
                        for j = -1, 6 do
                            local PedInVeh = GetPedInVehicleSeat(veh, j)
                            if PedInVeh == ped and seatOffsets[j] then
                                local cord = GetObjectOffsetFromCoords(x, y, z, targetheading, seatOffsets[j][1], seatOffsets[j][2], seatOffsets[j][3])
                                if cord then
                                    x, y, z = cord.x, cord.y, cord.z
                                end
                                break
                            end
                        end
                    end
                    
                    DrawText3DPlayersDescription(x, y, z + DISPLAY_OFFSET, data.tekst)
                end
            end
        end
        
        if hasScenes then
            for i = 1, #scenesInRangeCache do
                DrawScene(scenesInRangeCache[i].coords, scenesInRangeCache[i].message)
            end
        end
    end
end)