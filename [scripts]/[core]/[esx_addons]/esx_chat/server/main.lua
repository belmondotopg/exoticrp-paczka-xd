local Player = Player
local ox_inventory = exports.ox_inventory
local esx_core = exports.esx_core
local GetPlayerName = GetPlayerName
local CancelEvent = CancelEvent
local GetPlayerIdentifiers = GetPlayerIdentifiers
local math_random = math.random
local os_time = os.time
local string_lower = string.lower
local string_sub = string.sub
local string_len = string.len
local table_concat = table.concat

local PlayersDescriptions = {}
local ActiveReports = {}
local nextReportId = 1
local blocked_dms = {}
local darkwebDisabled = {}
local reportsDisabled = {}
local twitterDisabled = {}
local scenes = {}
local MAX_SCENES = 100
local ReportsTakenCount = {}

local adminPlayers = {}

MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `esx_chat_reports_taken` (
            `identifier` VARCHAR(60) NOT NULL,
            `name` VARCHAR(255) DEFAULT NULL,
            `count` INT(11) NOT NULL DEFAULT 0,
            `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`),
            INDEX `count` (`count`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]], {}, function()
        print('[^2INFO^0] [^5esx_chat^0] Tabela esx_chat_reports_taken została sprawdzona/utworzona.')
        
        MySQL.query('SELECT * FROM `esx_chat_reports_taken`', {}, function(results)
            if results then
                for _, row in ipairs(results) do
                    ReportsTakenCount[row.identifier] = {
                        count = row.count or 0,
                        name = row.name or 'Nieznany'
                    }
                end
                print('[^2INFO^0] [^5esx_chat^0] Wczytano ' .. #results .. ' rekordów reportów z bazy danych.')
            end
        end)
    end)
end)

local MAX_EMOJIS = 2
local MAX_CHARS = 300
local NEWS_COOLDOWN = 60 * 2
local function StringSplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    local i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local function validateText(text)
    local emojiPattern = "[\xF0-\xF7][\x80-\xBF][\x80-\xBF][\x80-\xBF]"
    local emojisCount = 0

    if #text > MAX_CHARS then
        return false
    end

    for _ in text:gmatch(emojiPattern) do
        emojisCount = emojisCount + 1
        if emojisCount > MAX_EMOJIS then
            return false
        end
    end

    local blockedEmojis = {
        "❤️", "💖", "💘", "💓", "💕", "💗", "💞", "😍"
    }

    for _, emoji in ipairs(blockedEmojis) do
        if string.find(text, emoji) then
            return false
        end
    end

    return true
end

local function processMessage(message)
    if type(message) ~= "string" then
        return false, ""
    end
    
    local finalmessage = string_lower(message):gsub(".", Config.Substitution):gsub("(.)%1+", "%1")
    local send = true

    for _, value in ipairs(Config.Blacklist) do
        if finalmessage:find(value) then
            send = false
            break
        end
    end

    return send, finalmessage
end

local function sendChatMessage(src, message, chatType, color, logType)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local ident = xPlayer.identifier
    local prefix = Config.privatePrefix[ident] or ""
    local color = Config.privateColor[ident] or color

    TriggerClientEvent("esx_chat:sendAddonChatMessage", -1, GetPlayerName(src), src, xPlayer.group, message, prefix, color)
    esx_core:SendLog(src, "Wiadomość w czacie", logType .. ": " .. message, 'chat', '9807270')
end

local function sendActionMessage(src, message, eventName, color, logType)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    TriggerClientEvent(eventName, -1, src, src, message)
    esx_core:SendLog(src, "Wiadomość w czacie", logType .. ": " .. message, 'chat', '15158332')
    TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, message, src, color)
end

AddEventHandler("chatMessage", function(source, name, message)
    local src = source
    CancelEvent()

    local send, finalmessage = processMessage(message)
    
    if send and string_sub(message, 1, string_len("/")) ~= "/" then
        sendChatMessage(src, message, "LOOC", {}, "LOOC")
    end
end)

local function registerChatCommand(command, eventName, color, logType, requiresValidation)
    RegisterCommand(command, function(source, args, message)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        
        CancelEvent()
        
        local send, finalmessage = processMessage(message)
        
        if send then
            if requiresValidation then
                local isTextCorrect = validateText(finalmessage)
                if not isTextCorrect then 
                    xPlayer.showNotification('Użyłeś/aś za dużo emotek lub znaków w tekście!')
                    return 
                end
            end
            
            local messageText = table_concat(args, " ")
            sendActionMessage(src, messageText, eventName, color, logType)
        end
    end, false)
end

registerChatCommand('me', "esx_chat:sendAddonChatMessageMe", {r = 255, g = 152, b = 247, alpha = 255}, "ME", true)
registerChatCommand('med', "esx_chat:sendAddonChatMessageMed", {r = 255, g = 26, b = 26, alpha = 255}, "MED", true)
registerChatCommand('do', "esx_chat:sendAddonChatMessageDo", {r = 255, g = 202, b = 247, alpha = 255}, "DO", true)

RegisterCommand('try', function(source, args, message)
    local src = source
    CancelEvent()

    if not args[1] then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.showNotification('Musisz podać treść akcji!')
        end
        return
    end

    local send, finalmessage = processMessage(message)
    
    if send then
        local random = math_random(1, 2)
        local text = ''
        local color = {r = 255, g = 202, b = 247, alpha = 255}

        TriggerClientEvent("esx_chat:sendAddonChatMessageCzy", -1, src, src, table_concat(args, " "), random)

        if random == 1 then
            text = 'Udane'
            color = {r = 23, g = 191, b = 31, alpha = 255}
        else
            text = 'Nieudane'
            color = {r = 178, g = 15, b = 52, alpha = 255}
        end

        for i = 1, #args do
            text = text .. ' ' .. args[i]
        end

        esx_core:SendLog(src, "Wiadomość w czacie", "TRY: " .. text, 'chat', '3066993')
        TriggerClientEvent('esx_chat:onCheckChatDisplay', -1, text, src, color)
    end
end, false)

local function registerOOCCommand(command, eventName, logType)
    RegisterCommand(command, function(source, args, message)
        local src = source
        CancelEvent()

        local send, finalmessage = processMessage(message)
        
        if send then
            local xPlayer = ESX.GetPlayerFromId(src)
            local userColor = Config.group[xPlayer.group]
            
            if xPlayer.group ~= nil and xPlayer.group ~= 'user' and xPlayer.group ~= 'helper' and xPlayer.group ~= 'support' and xPlayer.group ~= 'moderator' then
                TriggerClientEvent(eventName, -1, src, GetPlayerName(src), userColor, table_concat(args, " "), "fas fa-shield-alt")
                esx_core:SendLog(src, "Wiadomość w czacie", logType .. ": " .. table_concat(args, " "), 'chat')
            end
        end
    end, false)
end

registerOOCCommand('ooc', "esx_chat:addOOC", "OOC")
registerOOCCommand('ooccrime', "esx_chat:addCrimeOOC", "OOC CRIME")

ESX.RegisterServerCallback('esx_chat:getPlayersDescriptionBeforeQuit', function(source, cb)
    cb(PlayersDescriptions)
end)

AddEventHandler('playerDropped', function()
    local src = source
    
    if PlayersDescriptions[src] then
        PlayersDescriptions[src] = nil
    end
    
    if twitterCooldown and twitterCooldown[src] then
        twitterCooldown[src] = nil
    end
    
    if dwCooldown and dwCooldown[src] then
        dwCooldown[src] = nil
    end
    
    if blocked_dms[src] then
        blocked_dms[src] = nil
    end
    
    if darkwebDisabled[src] then
        darkwebDisabled[src] = nil
    end
    
    if reportsDisabled[src] then
        reportsDisabled[src] = nil
    end
    
    if lastReport and lastReport[src] then
        lastReport[src] = nil
        lastReportMessage[src] = nil
    end
end)

RegisterCommand('opis', function(source, args, message)
    local src = source
    CancelEvent()

    if args[1] ~= nil then
        local text = table_concat(args, " ")
        local trimmedText = text:gsub("^%s*(.-)%s*$", "%1")
        
        if #trimmedText == 0 then
            TriggerClientEvent('esx:showNotification', src, 'Opis nie może być pusty!')
            return
        end
        
        if #text > 90 then
            TriggerClientEvent('esx:showNotification', src, 'Maksymalna długość opisu to 90 znaków!')
            return
        end
        
        local send, finalmessage = processMessage(text)
        
        if not send then
            TriggerClientEvent('esx:showNotification', src, 'Opis zawiera niedozwolone słowa!')
            return
        end
        
        local isTextCorrect = validateText(text)
        if not isTextCorrect then
            TriggerClientEvent('esx:showNotification', src, 'Użyłeś/aś za dużo emotek lub znaków w opisie!')
            return
        end
        
        TriggerClientEvent('esx_chat:PlayersDescription', -1, src, text)
        esx_core:SendLog(src, "Stworzenie opisu", "STWORZYŁ OPIS [1]: `" .. text .. "`", 'opis-first', '15844367')
        PlayersDescriptions[src] = text
    else
        TriggerClientEvent('esx_chat:PlayersDescription', -1, src, '')
        PlayersDescriptions[src] = nil
    end
end, false)

RegisterServerEvent('esx_chat:PlayersDescriptionOtherPlayersServer')
AddEventHandler('esx_chat:PlayersDescriptionOtherPlayersServer', function(id, PlayersDescription)
    TriggerClientEvent('esx_chat:PlayersDescription', -1, id, PlayersDescription)
end)

RegisterCommand('w', function(source, args, message, cm)
    local src = source
    CancelEvent()

    local send, finalmessage = processMessage(message)
    
    if send and args[1] ~= nil then
        cm = StringSplit(message, " ")
        local targetId = tonumber(args[1])
        if not targetId then return end
        
        local names2 = GetPlayerName(targetId)
        
        if names2 then
            local names3 = GetPlayerName(src)
            local textmsg = ""
            
            for i = 1, #cm do
                if i ~= 1 and i ~= 2 then
                    textmsg = textmsg .. " " .. tostring(cm[i])
                end
            end

            local new_source = ESX.GetPlayerFromId(targetId)
            if not new_source then return end
            
            if not blocked_dms[targetId] then
                TriggerClientEvent('chat:sendNewAddonChatMessage', targetId, "Wiadomość od ["..src.." |  "..names3.."]", {0, 0, 0}, textmsg)
                TriggerClientEvent('chat:sendNewAddonChatMessage', src, "Wiadomość wysłana do  ["..targetId.." |  "..names2.."]", {0, 0, 0}, textmsg)
                esx_core:SendLog(src, "Wiadomość w czacie", "WIADOMOŚĆ DO "..GetPlayerName(targetId)..": " .. textmsg, 'chat', '2123412')
            else
                TriggerClientEvent('chat:sendNewAddonChatMessage', src, "Wiadomość ", {0, 0, 0}, "Nie wysłano, ponieważ gracz ma wyłączone prywatne wiadomości!")
            end
        else
            TriggerClientEvent('chat:sendNewAddonChatMessage', src, "Wiadomość ", {0, 0, 0}, "Nie wysłano, ponieważ gracz jest offline!")
        end
    end
end, false)

RegisterCommand('blockdm', function(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if blocked_dms[src] then
        blocked_dms[src] = false
        xPlayer.showNotification('Wyłączyłeś blokowanie prywatnych wiadomości')
    else
        blocked_dms[src] = true
        xPlayer.showNotification('Włączyłeś blokowanie prywatnych wiadomości')
    end
end, false)

RegisterNetEvent('esx_chat:secondDescriptionfetch', function()
    local src = source
    if src then
        TriggerClientEvent('esx_chat:secondDescriptionsend', src, scenes)
    end
end)

local function validatePlayerIndex(src, playerIndex)
    if Player(src).state.playerIndex then
        if playerIndex ~= ESX.GetServerKey(Player(src).state.playerIndex) then
            esx_core:SendLog(src, "Aktywność nadużycia", "Wykryto próbę wywołania TriggerServerEvent z użyciem nieodpowiedniego tokenu! Skrypt w którym wykryto niepożądane działanie: "..GetCurrentResourceName(), "ac")
            DropPlayer(src, "["..GetCurrentResourceName().."] wykryto podejrzane działanie, jeśli uważasz że kick jest niesłuszny skontaktuj się niezwłocznie z administracją")
            return false
        else
            Player(src).state.playerIndex = ESX.SendServerKey(ESX.GetRandomString(math_random(5, 20))..'-'..math_random(10000,99999))
        end
    end
    return true
end

RegisterNetEvent('esx_chat:secondDescriptionadd', function(coords, message, playerIndex)
    local src = source

    if not validatePlayerIndex(src, playerIndex) then return end

    if not src then return end
    
    if not message or message == "" or type(message) ~= "string" then
        TriggerClientEvent('esx:showNotification', src, 'Wiadomość nie może być pusta!')
        return
    end
    
    local trimmedMessage = message:gsub("^%s*(.-)%s*$", "%1")
    if #trimmedMessage == 0 then
        TriggerClientEvent('esx:showNotification', src, 'Wiadomość nie może być pusta!')
        return
    end
    
    if #message > 200 then
        TriggerClientEvent('esx:showNotification', src, 'Maksymalna długość opisu2 to 200 znaków!')
        return
    end
    
    local send, finalmessage = processMessage(message)
    if not send then
        TriggerClientEvent('esx:showNotification', src, 'Opis zawiera niedozwolone słowa!')
        return
    end
    
    if GetPlayerRoutingBucket(src) ~= 0 then
        TriggerClientEvent('esx:showNotification', src, 'Nie możesz tego zrobić')
        return
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - coords)
    if distance > 5 then 
        TriggerClientEvent('esx:showNotification', src, 'Jesteś zbyt daleko od miejsca, w którym chcesz umieścić opis!')
        return 
    end
    
    if not scenes then
        scenes = {}
    end
    
    if #scenes >= MAX_SCENES then
        table.remove(scenes, 1)
    end
    
    table.insert(scenes, {
        message = message,
        coords = coords,
        owner = src,
        showid = "~g~["..src.."]"
    })
    
    local coordsStr = string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z)
    esx_core:SendLog(src, "Stworzenie opisu", "STWORZYŁ OPIS [2]: `" .. message .. "`\nKoordynaty: `"..coordsStr.."`", 'opis-second', '15844367')
    TriggerClientEvent('esx_chat:secondDescriptionsend', -1, scenes)
end)

RegisterNetEvent('esx_chat:secondDescriptiondelete', function(keySecond, playerIndex)
    local src = source

    if not validatePlayerIndex(src, playerIndex) then return end

    if not src then return end
    
    if not scenes or not scenes[keySecond] then
        TriggerClientEvent('esx:showNotification', src, 'Ten opis nie istnieje!')
        return
    end
    
    if src == scenes[keySecond].owner then
        table.remove(scenes, keySecond)
        TriggerClientEvent('esx_chat:secondDescriptionsend', -1, scenes)
        esx_core:SendLog(src, "Usunięcie opisu", "Usunął opis2", "opis-second")
    else
        TriggerClientEvent('esx:showNotification', src, 'To nie twój opis.')
    end
end)

RegisterNetEvent('esx_chat:secondDescriptionadmindelete', function(keySecond, playerIndex)
    local src = source

    if not validatePlayerIndex(src, playerIndex) then return end

    if not ESX.IsPlayerAdmin(src) then return end
    
    if not scenes or not scenes[keySecond] then
        TriggerClientEvent('esx:showNotification', src, 'Ten opis nie istnieje!')
        return
    end
    
    table.remove(scenes, keySecond)
    TriggerClientEvent('esx_chat:secondDescriptionsend', -1, scenes)
    esx_core:SendLog(src, "Usunięcie opisu", "**[ADMIN]: "..GetPlayerName(src).."** usunął opis2", "opis-second")
end)

RegisterNetEvent('esx_chat:secondDescriptionadmindelete2', function(playerIndex)
    local src = source

    if not validatePlayerIndex(src, playerIndex) then return end

    if not ESX.IsPlayerAdmin(src) then return end
    
    if not scenes then
        scenes = {}
    end
    
    scenes = {}
    TriggerClientEvent('esx_chat:secondDescriptionsend', -1, {})
    esx_core:SendLog(src, "Usunięcie opisu", "**[ADMIN]: "..GetPlayerName(src).."** usunął opisy2", "opis-second")
end)

RegisterNetEvent('esx_chat:secondDescriptiondeleteOther', function(keySecond, playerIndex)
    local src = source

    if not validatePlayerIndex(src, playerIndex) then return end

    if not src then return end
    
    if not scenes or not scenes[keySecond] then
        TriggerClientEvent('esx:showNotification', src, 'Ten opis nie istnieje!')
        return
    end
    
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    
    local search = ox_inventory:Search(src, 'count', Config.RemoveDescriptionItem)
    local hasItem = search and search > 0
    
    if not hasItem then
        TriggerClientEvent('esx:showNotification', src, 'Nie posiadasz wymaganego przedmiotu do usunięcia cudzego opisu!')
        return
    end
    
    if src == scenes[keySecond].owner then
        TriggerClientEvent('esx:showNotification', src, 'To jest Twój opis! Użyj opcji "Usuń Opis" aby go usunąć.')
        return
    end
    
    ox_inventory:RemoveItem(src, Config.RemoveDescriptionItem, 1)
    
    local ownerId = scenes[keySecond].owner
    local ownerName = GetPlayerName(ownerId) or "Nieznany"
    table.remove(scenes, keySecond)
    TriggerClientEvent('esx_chat:secondDescriptionsend', -1, scenes)
    
    TriggerClientEvent('esx:showNotification', src, 'Usunąłeś/aś cudzy opis2!')
    
    esx_core:SendLog(src, "Usunięcie opisu", "Gracz "..GetPlayerName(src).." ["..src.."] usunął opis2 gracza "..ownerName.." ["..ownerId.."] używając przedmiotu "..Config.RemoveDescriptionItem, "opis-second")
end)

RegisterCommand('adminchat', function(source, args, message)
    local src = source
    CancelEvent()

    local send, finalmessage = processMessage(message)
    
    if send then
        local xPlayer = ESX.GetPlayerFromId(src)
        if ESX.IsPlayerAdmin(src) then
            TriggerClientEvent('esx_chat:onSendAdminChat', -1, src, GetPlayerName(src), {171, 0, 28}, table_concat(args, " "), tostring(xPlayer.group):upper())
            esx_core:SendLog(src, "Wiadomość w czacie", "Admin-Chat: " .. table_concat(args, " "), 'chat')
        end
    end
end, false)

local colors = {
    ['police'] = {6, 47, 143},
    ['sheriff'] = {6, 47, 143},
    ['ambulance'] = {117, 0, 4},
    ['mechanik'] = {56, 13, 166},
    ['cardealer'] = {61, 161, 147},
}

local newsCooldown = 0

RegisterCommand('news', function(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local search = ox_inventory:Search(src, 'count', 'phone')
    local found = search or Player(src).state.phoneOpen

    if found then
        if os_time() < newsCooldown then
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Poczekaj chwilę, aż wszyscy odczytają najnowszego newsa!')
            return
        end
    
        local allowedJobs = { police=true, sheriff=true, uwucafe=true, ambulance=true, mechanik=true, doj=true, whitewidow=true, bahama_mamas=true, taxi=true }
        
        local jobName = xPlayer.job.name
        local jobGrade = xPlayer.job.grade
        
        if allowedJobs[jobName] and jobGrade >= 4 then
            local message = table_concat(args, ' ')
            newsCooldown = os_time() + NEWS_COOLDOWN

            TriggerClientEvent('chat:sendNewAddonChatMessage', -1, xPlayer.job.label, colors[xPlayer.job.name] or {255, 206, 10}, ' '..message, "fas fa-newspaper")
            esx_core:SendLog(source, "Wiadomość w czacie", "NEWS: [" .. xPlayer.job.label .. "]: " .. message, 'chat')
        else
            xPlayer.showNotification('Nie posiadasz odpowiedniej pracy, aby wysyłać news!')
        end
    else
        xPlayer.showNotification('Nie posiadasz telefonu lub nie masz podłączonej karty SIM!')
    end
end, false)

local lastReport = {}
local lastReportMessage = {}

local function handleReport(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    CancelEvent()
    
    local message = table_concat(args, " ")
    
    if not message or message == "" then
        xPlayer.showNotification("Wpisz treść reporta!", 'error')
        return
    end
    
    local send, finalmessage = processMessage(message)
    if not send then
        xPlayer.showNotification("Nieprawidłowa treść reporta!", 'error')
        return
    end

    local currentTime = os_time()
    if lastReport[source] and currentTime - lastReport[source] < 60 then
        local remaining = 60 - (currentTime - lastReport[source])
        xPlayer.showNotification("Musisz odczekać "..remaining.." sekund przed kolejnym reportem!", 'error')
        return
    end

    if lastReportMessage[source] and lastReportMessage[source] == message then
        xPlayer.showNotification("Nie możesz wysłać identycznego reporta!", 'error')
        return
    end

    lastReport[source] = currentTime
    lastReportMessage[source] = message
    
    local reportId = nextReportId
    nextReportId = nextReportId + 1
    local playerName = GetPlayerName(source)

    ActiveReports[reportId] = {
        id = reportId,
        source = source,
        message = message,
        time = currentTime,
        playerName = playerName
    }

    local adminCount = 0
    
    -- if Config.AdminGroups then
    --     for _, playerId in ipairs(ESX.GetPlayers()) do
    --         local adminPlayer = ESX.GetPlayerFromId(playerId)
    --         if adminPlayer and adminPlayer.isAdmin() and not reportsDisabled[playerId] then
    --             adminCount = adminCount + 1
    --             TriggerClientEvent('chat:sendNewAddonChatMessage', playerId, "Nowy report #"..reportId, {255, 20, 20}, " Gracz "..playerName.." ["..source.."] wysłał reporta o treści: "..message.."!", "fas fa-check")
    --         end
    --     end
    -- end

    local playerList = {}
    for _, playerId in ipairs(adminPlayers) do
        if not reportsDisabled[playerId] then
            playerList[#playerList + 1] = playerId
            adminCount = adminCount + 1
        end
    end
    lib.triggerClientEvent('chat:sendNewAddonChatMessage', playerList, "Nowy report #"..reportId, {255, 20, 20}, " Gracz "..playerName.." ["..source.."] wysłał reporta o treści: "..message.."!", "fas fa-check")

    TriggerClientEvent('chat:sendNewAddonChatMessage', source, "Report #"..reportId, {255, 20, 20}, " Wysłano reporta do "..adminCount.." administratorów!", "fas fa-check")
    esx_core:SendLog(source, "Report", "Gracz "..playerName.." ["..source.."] wysłał reporta: "..message.." (ID: "..reportId..")", 'admin-report', '16711680')
end

RegisterCommand("report", function(source, args, rawCommand)
    handleReport(source, args)
end, false)

RegisterCommand("zglos", function(source, args, rawCommand)
    handleReport(source, args)
end, false)

RegisterCommand("cl", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if not xPlayer.isAdmin() then
        xPlayer.showNotification("Nie jesteś administratorem!", 'error')
        return
    end

    local reportId = tonumber(args[1])
    if not reportId then
        xPlayer.showNotification("Podaj poprawne ID reportu!", 'error')
        return
    end

    local report = ActiveReports[reportId]
    if not report then
        xPlayer.showNotification("Report o podanym ID nie istnieje lub został już rozwiązany!", 'error')
        return
    end

    local adminName = GetPlayerName(source)
    
    local targetPlayer = ESX.GetPlayerFromId(report.source)
    if targetPlayer then
        TriggerClientEvent('chat:sendNewAddonChatMessage', report.source, "Report #"..reportId, {20, 255, 20}, " Twój report został rozwiązany przez administratora "..adminName.."!", "fas fa-check")
        targetPlayer.showNotification("Twój report #"..reportId.." został rozwiązany!", 'success')
    end

    lib.triggerClientEvent('chat:sendNewAddonChatMessage', adminPlayers, "Report #"..reportId, {20, 255, 20}, " Administrator "..adminName.." rozwiązał report #"..reportId.." gracza "..report.playerName.."!", "fas fa-check")

    local adminIdentifier = xPlayer.identifier
    if not ReportsTakenCount[adminIdentifier] then
        ReportsTakenCount[adminIdentifier] = {
            count = 0,
            name = adminName
        }
    end
    ReportsTakenCount[adminIdentifier].count = ReportsTakenCount[adminIdentifier].count + 1
    ReportsTakenCount[adminIdentifier].name = adminName

    MySQL.update([[
        INSERT INTO `esx_chat_reports_taken` (`identifier`, `name`, `count`) 
        VALUES (?, ?, 1)
        ON DUPLICATE KEY UPDATE 
            `count` = `count` + 1,
            `name` = VALUES(`name`)
    ]], {adminIdentifier, adminName})

    esx_core:SendLog(source, "Report", "Administrator "..adminName.." rozwiązał report #"..reportId.." gracza "..report.playerName, 'admin-report', '65280')
    ActiveReports[reportId] = nil
end, false)

RegisterCommand("acc", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    CancelEvent()
    
    if not xPlayer.isAdmin() then
        xPlayer.showNotification("Nie jesteś administratorem!", 'error')
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        xPlayer.showNotification("Podaj poprawne ID gracza!", 'error')
        return
    end
    
    local targetName = GetPlayerName(targetId)
    if not targetName then
        xPlayer.showNotification("Gracz o podanym ID nie jest online!", 'error')
        return
    end

    local adminName = GetPlayerName(source)
    TriggerClientEvent('chat:sendNewAddonChatMessage', targetId, "Report", {20, 255, 20}, " Administrator "..adminName.." zaakceptował Twój report!", "fas fa-check")
    
    lib.triggerClientEvent('chat:sendNewAddonChatMessage', adminPlayers, "Report", {20, 255, 20}, " Administrator "..adminName.." zaakceptował report gracza "..targetName.." ["..targetId.."]!", "fas fa-check")
    
    xPlayer.showNotification("Report gracza ["..targetId.."] został zaakceptowany!", 'success')
    esx_core:SendLog(source, "Report", "Administrator "..adminName.." zaakceptował report gracza "..targetName.." ["..targetId.."]", 'admin-report', '65280')
end, false)

local twitterCooldown = {}
local TWITTER_COOLDOWN_TIME = 10

local function postTwitterTweet(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local currentTime = os_time()
    if twitterCooldown[src] and currentTime < twitterCooldown[src] then
        local remaining = twitterCooldown[src] - currentTime
        xPlayer.showNotification('Musisz odczekać ' .. remaining .. ' sekund przed wysłaniem kolejnego tweeta!', 'error')
        return
    end
    
    if not args[1] then
        xPlayer.showNotification('Podaj treść tweeta!', 'error')
        return
    end
    
    local message = table_concat(args, " ")
    
    if #message > 280 then
        xPlayer.showNotification('Tweet może mieć maksymalnie 280 znaków!', 'error')
        return
    end
    
    local send = processMessage(message)
    
    if not send then
        xPlayer.showNotification('Nieprawidłowa treść tweeta!', 'error')
        return
    end
    
    local search = ox_inventory:Search(src, 'count', 'phone')
    local hasPhone = (search and search > 0) or Player(src).state.phoneOpen
    
    if not hasPhone then
        xPlayer.showNotification('Nie posiadasz telefonu!', 'error')
        return
    end
    
    local firstName = xPlayer.get('firstName') or ''
    local lastName = xPlayer.get('lastName') or ''
    local twitterUsername = (firstName ~= '' and lastName ~= '') and (firstName .. ' ' .. lastName) or GetPlayerName(src)
    
    twitterCooldown[src] = currentTime + TWITTER_COOLDOWN_TIME
    
    local chatMessage = " @" .. twitterUsername .. ": " .. message

    local chatTitle = "Twitter"
    TriggerClientEvent("chat:sendNewAddonChatMessage", -1, chatTitle, {29, 161, 242}, chatMessage, "fab fa-twitter", nil, nil, "twitter", src)
    
    esx_core:SendLog(src, "Tweet", "Tweet: @" .. twitterUsername .. ": " .. message, 'twitter', '3447003')
    xPlayer.showNotification('Tweet został opublikowany!', 'success')
end

local dwCooldown = {}
local DW_COOLDOWN_TIME = 15

local darkwebAccess = {}
local function postdw(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if darkwebDisabled[src] then
        xPlayer.showNotification('Masz wyłączony Darkweb! Użyj /togdw aby go włączyć.', 'error')
        return
    end
    
    if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' or xPlayer.job.name == 'ambulance' then
        xPlayer.showNotification('Policja nie może pisać na Darkweb!', 'error')
        return
    end
    
    local currentTime = os_time()
    if dwCooldown[src] and currentTime < dwCooldown[src] then
        local remaining = dwCooldown[src] - currentTime
        xPlayer.showNotification('Musisz odczekać ' .. remaining .. ' sekund przed wysłaniem kolejnego Darkweba!', 'error')
        return
    end
    
    if not args[1] then
        xPlayer.showNotification('Podaj treść Darkweba!', 'error')
        return
    end
    
    local message = table_concat(args, " ")
    
    if #message > 280 then
        xPlayer.showNotification('Darkweb może mieć maksymalnie 280 znaków!', 'error')
        return
    end
    
    local send = processMessage(message)
    
    if not send then
        xPlayer.showNotification('Nieprawidłowa treść Darkweba!', 'error')
        return
    end
    
    local search = ox_inventory:Search(src, 'count', 'phone')
    local hasPhone = (search and search > 0) or Player(src).state.phoneOpen
    
    if not hasPhone then
        xPlayer.showNotification('Nie posiadasz telefonu!', 'error')
        return
    end
    
    dwCooldown[src] = currentTime + DW_COOLDOWN_TIME
    
    lib.triggerClientEvent("chat:sendNewAddonChatMessage", darkwebAccess, "DarkWeb", {139, 0, 0}, " "..message, "fas fa-skull-crossbones", nil, nil, "darkweb", src)
    
    esx_core:SendLog(src, "darkweb", "DARKWEB: " .. message, 'darkweb', '3447003')
    xPlayer.showNotification('Darkweb został opublikowany!', 'success')
end

RegisterCommand('twt', function(source, args, rawCommand)
    postTwitterTweet(source, args)
end, false)

RegisterCommand('twetter', function(source, args, rawCommand)
    postTwitterTweet(source, args)
end, false)

RegisterCommand('dw', function(source, args, rawCommand)
    postdw(source, args)
end, false)

RegisterCommand('togdw', function(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if darkwebDisabled[src] then
        darkwebDisabled[src] = nil
        xPlayer.showNotification('Włączyłeś/aś Darkweb!', 'success')
    else
        darkwebDisabled[src] = true
        xPlayer.showNotification('Wyłączyłeś/aś Darkweb!', 'success')
    end
end, false)

RegisterCommand('togrep', function(source, args)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    if not xPlayer.isAdmin() then
        xPlayer.showNotification('Nie jesteś administratorem!', 'error')
        return
    end
    
    if reportsDisabled[src] then
        reportsDisabled[src] = nil
        xPlayer.showNotification('Włączyłeś/aś otrzymywanie reportów!', 'success')
    else
        reportsDisabled[src] = true
        xPlayer.showNotification('Wyłączyłeś/aś otrzymywanie reportów!', 'success')
    end
end, false)

local function sendReportsTopToWebhook()
    if not Config.ReportsTopWebhook or Config.ReportsTopWebhook == "" then
        return
    end

    MySQL.query([[
        SELECT `identifier`, `name`, `count` 
        FROM `esx_chat_reports_taken` 
        ORDER BY `count` DESC 
        LIMIT 10
    ]], {}, function(results)
        if not results or #results == 0 then
            return
        end

        local topCount = #results
        local description = "**Top " .. topCount .. " administratorów z największą liczbą przejętych reportów:**\n\n"
        
        for i = 1, topCount do
            local admin = results[i]
            local place = ""
            if i == 1 then
                place = "🥇"
            elseif i == 2 then
                place = "🥈"
            elseif i == 3 then
                place = "🥉"
            else
                place = "**" .. i .. ".**"
            end
            local adminName = admin.name or 'Nieznany'
            local adminCount = admin.count or 0
            description = description .. place .. " **" .. adminName .. "** - `" .. adminCount .. "` reportów\n"
        end

        local embed = {
            {
                ["title"] = "📊 Topka Administratorów - Przejęte Reporty",
                ["description"] = description,
                ["color"] = 3066993,
                ["footer"] = {
                    ["text"] = "Topka reportów | " .. os.date("%Y/%m/%d %H:%M:%S")
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }

        PerformHttpRequest(
            Config.ReportsTopWebhook,
            function(err, text, headers) end,
            'POST',
            json.encode({
                username = "ExoticRP - Topka Reportów",
                embeds = embed
            }),
            { ['Content-Type'] = 'application/json' }
        )
    end)
end

if Config.ReportsTopAutoSendInterval and Config.ReportsTopAutoSendInterval > 0 and Config.ReportsTopWebhook and Config.ReportsTopWebhook ~= "" then
    CreateThread(function()
        while true do
            local waitTime = Config.ReportsTopAutoSendInterval * 3600 * 1000
            Wait(waitTime)
            sendReportsTopToWebhook()
        end
    end)
end

local blockedJobs = {
    ['mechanik'] = true,
    ['police'] = true,
    ['sheriff'] = true,
    ['ambulance'] = true
}

RegisterNetEvent('esx:playerLoaded', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        if xPlayer.isAdmin() then
            table.insert(adminPlayers, src)
        end
        if not blockedJobs[xPlayer.job.name] then
            table.insert(darkwebAccess, src)
        end
    end
end)

local function findIndex(val, isDarkweb)
    for i, v in ipairs(isDarkweb and darkwebAccess or adminPlayers) do
        if v == val then
            return i
        end
    end
    return nil
end

RegisterNetEvent('esx:playerDropped', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if xPlayer.isAdmin() then
        local index = findIndex(source)
        local index2 = findIndex(source, true)
        
        if index then
            table.remove(adminPlayers, index)
        end

        if index2 then
            table.remove(darkwebAccess, index2)
        end
    end
end)

AddEventHandler('esx:setGroup', function(source)
    local player = ESX.GetPlayerFromId(source)
    local index = findIndex(source)

    if player.isAdmin() and not index then
        table.insert(adminPlayers, source)
    elseif index then
        table.remove(adminPlayers, index)
    end
end)

CreateThread(function()
    local players = ESX.GetExtendedPlayers()

    for _, xPlayer in ipairs(players) do
        if xPlayer.isAdmin() then
            table.insert(adminPlayers, xPlayer.source)
        end

        if not blockedJobs[xPlayer.job.name] then
            table.insert(darkwebAccess, xPlayer.source)
        end
    end
end)

AddEventHandler('esx:setJob', function(source, job)
    if not blockedJobs[job.name] then
        table.insert(darkwebAccess, source)
    end

    if blockedJobs[job.name] then
        local index2 = findIndex(source, true)
        if index2 then
            table.remove(darkwebAccess, index2)
        end
    end
end)