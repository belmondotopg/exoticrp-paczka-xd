local Player = Player

local TriggerClientEvent = TriggerClientEvent
local RegisterServerEvent = RegisterServerEvent
local AddEventHandler = AddEventHandler
local GetEntityCoords = GetEntityCoords
local GetPlayerPed = GetPlayerPed
local GetPlayerName = GetPlayerName
local GetNumPlayerIdentifiers = GetNumPlayerIdentifiers
local GetPlayerIdentifier = GetPlayerIdentifier
local GetNumPlayerTokens = GetNumPlayerTokens
local GetPlayerToken = GetPlayerToken
local json = json
local os = os
local pairs = pairs
local type = type
local tonumber = tonumber

local LOGO_URL = "https://i.ibb.co/kVsZnt71/logo.png"
local BRAND_NAME = "ExoticRP"
local BRAND_URL = "https://exoticrp.eu/"
local DEFAULT_COLOR = 16744448
local DEFAULT_VALUE = "Brak"

local function SplitId(idString)
    if not idString then return nil end
    local output = nil
    for str in string.gmatch(idString, "([^:]+)") do
        output = str
    end
    return output or DEFAULT_VALUE
end

local function ExtractIdentifiers(src)
    local identifiers = {
        id = DEFAULT_VALUE,
        name = DEFAULT_VALUE,
        steamhex = DEFAULT_VALUE,
        steamid = DEFAULT_VALUE,
        discord = DEFAULT_VALUE,
        license = DEFAULT_VALUE,
        license2 = DEFAULT_VALUE,
        xbl = DEFAULT_VALUE,
        live = DEFAULT_VALUE,
        fivem = DEFAULT_VALUE,
        hwid = {}
    }

    if not src then
        return identifiers
    end

    identifiers.id = src
    local playerName = GetPlayerName(src)
    identifiers.name = playerName and (playerName .. " [" .. src .. "]") or DEFAULT_VALUE

    local numIdentifiers = GetNumPlayerIdentifiers(src)
    for i = 0, numIdentifiers - 1 do
        local id = GetPlayerIdentifier(src, i)
        if not id then goto continue end

        if id:find("steam") then
            local steamId = SplitId(id)
            identifiers.steamhex = steamId
            identifiers.steamid = tonumber(steamId, 16) or DEFAULT_VALUE
        elseif id:find("discord") then
            identifiers.discord = SplitId(id)
        elseif id:find("license2") then
            identifiers.license2 = SplitId(id)
        elseif id:sub(1, 8) == "license:" then
            identifiers.license = SplitId(id)
        elseif id:find("xbl") then
            identifiers.xbl = SplitId(id)
        elseif id:find("live") then
            identifiers.live = SplitId(id)
        elseif id:find("fivem") then
            identifiers.fivem = SplitId(id)
        end
        ::continue::
    end

    local numTokens = GetNumPlayerTokens(src)
    for i = 0, numTokens - 1 do
        local token = GetPlayerToken(src, i)
        if token then
            table.insert(identifiers.hwid, token)
        end
    end

    return identifiers
end

local function CreateEmbed(title, fields, color)
    local timestamp = os.date("%Y/%m/%d %X")
    return {
        {
            avatar_url = LOGO_URL,
            username = BRAND_NAME,
            author = {
                name = BRAND_NAME,
                url = BRAND_URL,
                icon_url = LOGO_URL
            },
            color = color or DEFAULT_COLOR,
            title = title,
            type = "rich",
            fields = fields,
            footer = {
                text = BRAND_NAME .. " [" .. timestamp .. "]",
                url = LOGO_URL,
                icon_url = LOGO_URL
            }
        }
    }
end

local function SendLog(source, title, text, channel, color, first)
    local src = source
    local embed = {}

    if not src or not tonumber(src) or src <= 0 then
        local errorFields = {
            {
                name = "Timestamp",
                value = "<t:" .. os.time() .. ":F>",
                inline = false
            },
            {
                name = "Błąd",
                value = "```Brakuje source wywoływanego przez gracza. Sprawdź tego loga i go napraw!```",
                inline = false
            },
            {
                name = "Info",
                value = "```" .. (text or "") .. "```",
                inline = false
            }
        }
        embed = CreateEmbed(
            "⚠️ Błąd w systemie logów",
            errorFields,
            DEFAULT_COLOR
        )
    else
        local identifiers = ExtractIdentifiers(src)
        
        identifiers.license = identifiers.license or DEFAULT_VALUE
        identifiers.steamhex = identifiers.steamhex or DEFAULT_VALUE
        identifiers.discord = identifiers.discord or DEFAULT_VALUE
        identifiers.xbl = identifiers.xbl or DEFAULT_VALUE
        identifiers.live = identifiers.live or DEFAULT_VALUE

        local playerName = GetPlayerName(src) or DEFAULT_VALUE

        local identifiersText = string.format(
            "Server ID: %s\nDiscord ID: %s\nLicense ID: %s\nSteam ID: %s\nXBL ID: %s\nLive ID: %s",
            tostring(src),
            identifiers.discord ~= DEFAULT_VALUE and identifiers.discord or DEFAULT_VALUE,
            identifiers.license ~= DEFAULT_VALUE and identifiers.license or DEFAULT_VALUE,
            identifiers.steamhex ~= DEFAULT_VALUE and identifiers.steamhex or DEFAULT_VALUE,
            identifiers.xbl ~= DEFAULT_VALUE and identifiers.xbl or DEFAULT_VALUE,
            identifiers.live ~= DEFAULT_VALUE and identifiers.live or DEFAULT_VALUE
        )
        
        if channel == 'connect' then
            if identifiers.hwid and #identifiers.hwid > 0 then
                identifiersText = identifiersText .. "\n\nHWID Tokens:"
                for i, token in ipairs(identifiers.hwid) do
                    identifiersText = identifiersText .. "\n" .. token
                end
            else
                identifiersText = identifiersText .. "\n\nHWID Tokens: N/A"
            end
        end

        local fields = {
            {
                name = "Timestamp",
                value = "<t:" .. os.time() .. ":F>",
                inline = false
            },
            {
                name = "Nick gracza",
                value = playerName,
                inline = true
            },
            {
                name = "Discord",
                value = identifiers.discord ~= DEFAULT_VALUE and ('<@' .. identifiers.discord .. '>') or DEFAULT_VALUE,
                inline = true
            },
            {
                name = "Server ID",
                value = tostring(src),
                inline = true
            },
            {
                name = "Info",
                value = "```" .. (text or "") .. "```",
                inline = false
            },
            {
                name = "Identifiers",
                value = "```" .. identifiersText .. "```",
                inline = false
            }
        }
        embed = CreateEmbed(title, fields, color or DEFAULT_COLOR)
    end

    local webhookUrl = Config.Logs.Channels[channel] or Config.Logs.DefaultLink
    if webhookUrl and webhookUrl ~= "" then
        PerformHttpRequest(
            webhookUrl,
            function(err, text, headers) end,
            'POST',
            json.encode({
                username = BRAND_NAME,
                avatar_url = LOGO_URL,
                embeds = embed
            }),
            { ['Content-Type'] = 'application/json' }
        )
    end
end

RegisterServerEvent('esx_core:SendLog')
AddEventHandler('esx_core:SendLog', function(title, message, channel)
    local src = source
    SendLog(src, title, message, channel)
end)

exports('SendLog', SendLog)

AddEventHandler('playerConnecting', function()
    local src = source
    SendLog(src, "Łączenie z serwerem", "Gracz łączy się z serwerem", 'connect', 5793266, true)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source

    if not src or src <= 0 then
        return
    end

    local playerPed = GetPlayerPed(src)
    local crds = playerPed and GetEntityCoords(playerPed) or vector3(0.0, 0.0, 0.0)
    local name = GetPlayerName(src) or DEFAULT_VALUE

    local SSN = DEFAULT_VALUE
    local playerState = Player(src)
    if playerState then
        local permanentID = playerState.state.ssn
        if permanentID and permanentID ~= '' then
            SSN = permanentID
        end
    end

    TriggerClientEvent("esx_core:disconnectLogs", -1, src, crds, name, SSN, nil, reason or "Nieznany")

    local items = DEFAULT_VALUE
    local ox_inventory = exports.ox_inventory
    if ox_inventory then
        local getitems = ox_inventory:GetInventoryItems(src)
        if type(getitems) == 'table' and #getitems > 0 then
            local itemList = {}
            for k, v in pairs(getitems) do
                if v and v.label and v.name and v.count then
                    local countNum = tonumber(v.count)
                    local count = 0
                    if countNum and countNum == countNum and countNum ~= math.huge and countNum ~= -math.huge then
                        count = math.floor(countNum)
                    end
                    table.insert(itemList, string.format("%s [%s] - %dx", v.label, v.name, count))
                end
            end
            if #itemList > 0 then
                items = table.concat(itemList, " | ")
            end
        end
    end

    local disconnectMessage = string.format(
        "Gracz wychodzi z wyspy.\nPowód: %s\nInventory:\n%s",
        reason or "Nieznany",
        items
    )
    SendLog(src, "Wyjście z serwera", disconnectMessage, 'disconnect', 5793266)
end)

local function webhookrestart(text)
    embed = {
        {
			["author"] = {
				["name"] = BRAND_NAME,
				["url"] = BRAND_URL,
				["icon_url"] = LOGO_URL,
			},
            ["color"] = DEFAULT_COLOR,
            ["title"] = "Restart Serwera",
            ["description"] = text,
			["footer"] = {
				["text"] = os.date() .. " | ExoticRP - Automatyczne Restarty",
				["icon_url"] = LOGO_URL,
			},
        }
    }
    PerformHttpRequest(Config.Logs.Channels['restart'], function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

MySQL.ready(function()
	webhookrestart('**Zapraszamy do gry! Automatyczne Restarty o:** \n- 7:00\n- 17:00\n**Naciśnij F8 i połącz się za pomocą:** `connect exoticrp.pl`')
end)