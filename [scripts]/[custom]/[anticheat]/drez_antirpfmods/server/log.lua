if Config.LogPlayer then
    local LOG_WEBHOOK <const> = tostring(Config.LogWebhook)
    local LOG_MESSAGE <const> = tostring(Config.LogMessage)

    local function GetIdentifiers(playerId)
        local data = {}
        for _, identifier in pairs(GetPlayerIdentifiers(playerId)) do
            if identifier:sub(1, 2) ~= "ip" then
                table.insert(data, identifier)
            end
        end
    
        return table.concat(data, "\n")
    end

    function LogWebhook(playerId, message)
        if (not playerId) then
            return
        end

        local identifiers <const> = GetIdentifiers(playerId)
        local player <const> = ("[" .. tostring(playerId) .. "] " .. GetPlayerName(playerId))
        
        
        local embeds = {
            {
                ["title"] = "RPF MODS DETECTED",
                ["type"] = "rich",
                ["color"] = "15801616",
                ["description"] = "**Player:** " .. player .. "\n**Identifiers: **```" .. identifiers .. "```\n" .. LOG_MESSAGE .. "\n" .. message,
                ["footer"] = {
                    ["text"]= os.date("%Y/%m/%d %X") .. " - drez_antirpfmods",
                },
            }
        }

        PerformHttpRequest(LOG_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = "drez_antirpfmods", embeds = embeds}), { ['Content-Type'] = 'application/json' })
    end
end
