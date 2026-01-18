-- THIS FILE IS ONLY SERVER SIDE!

Config.Logs = {}
Config.Logs.Enabled = true -- true / false
Config.Logs.Webhook = '' -- Webhook URL only for Discord!

-- Go to fivemanage.com > create an account > create token for MEDIA > copy token and paste it here :)
Config.Logs.ApiKey = ''

Config.Logs.SendLog = function(playerId, message)
    Citizen.CreateThread(function()
        if not Config.Logs.Enabled then return end
        local steamName, steamHex, discordId = 'Unknown', 'Unknown', 'Unknown'
        if playerId then
            steamName = GetPlayerName(playerId)
            local identifiers = GetPlayerIdentifiers(playerId)
            for i = 1, #identifiers do
                if string.find(identifiers[i], 'steam:') then
                    steamHex = identifiers[i]
                elseif string.find(identifiers[i], 'discord:') then
                    discordId = string.gsub(identifiers[i], 'discord:', '')
                end
            end
        end
    
        message = message..'\nID: '..(playerId or 'Server')..'\nSteam Name: '..steamName..'\nSteam HEX: '..steamHex..'\nDiscord: <@'..discordId..'>'
        local embedData = { {
            ['title'] = 'Doj MDT',
            ['color'] = 14423100,
            ['footer'] = {
                ['text'] = "Doj MDT | pScripts | " .. os.date(),
                ['icon_url'] = "https://r2.fivemanage.com/xlufCGKYLtGfU8IBmjOL9/LOGO3.png"
            },
            ['description'] = message,
            ['author'] = {
                ['name'] = "pScripts",
                ['icon_url'] = "https://r2.fivemanage.com/xlufCGKYLtGfU8IBmjOL9/LOGO3.png"
            }
        } }
        PerformHttpRequest(Config.Logs.Webhook, nil, 'POST', json.encode({
            username = 'pScripts',
            embeds = embedData
        }), {
            ['Content-Type'] = 'application/json'
        })
    end)
end