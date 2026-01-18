ServerConfig = {}
ServerConfig.LogsWebhook = "https://discord.com/api/webhooks/1450971841136033802/5Yjf_D-gQhb_zmYRyh-prIvuTQivvXA9rooOhw1fnrfkLHCERXymTxwtVi9u_a_DJd9u" -- Discord webhook.

ServerConfig.EnableDiscordRanks = false --GetResourceState("op-bot") ~= "missing"

ServerConfig.DisableAutoSql = false -- Enable/Disable auto sql injection for slots data!

ServerConfig.Commands = {
    logout = {
        enable = true, 
        command = "logout",
        allowed = "user"
    },
    setslots = {
        enable = false, 
        command = "setslots",
        allowed = "admin"
    },
}

ServerConfig.LogsData = {
    ['character_loaded'] = {
        color = 706333,
        header = "Gracz połączony",
        desc = "**Imię postaci:** `%s`\n**ID postaci:** `%s`\n**Identyfikatory gracza:** ```%s```"
    },
    ['character_created'] = {
        color = 706333,
        header = "Postać utworzona",
        desc = "**Imię:** `%s`\n**ID:** `%s`\n**Narodowość:** `%s`\n**Data urodzenia:** `%s`\n**Płeć:** `%s`\n**Wzrost:** `%s`\n**Identyfikatory gracza:** ```%s```\n**Początkowe przedmioty:** ```%s```"
    },
    ['character_unloaded'] = {
        color = 13044234,
        header = "Wylogowanie postaci",
        desc = "**Imię postaci:** `%s`\n**ID postaci:** `%s`\n**Identyfikatory gracza:** ```%s```"
    },
    ['slotsadded'] = {
        color = 706333,
        header = "Dodano sloty",
        desc = "**Administrator:** `%s`\n**Licencja:** `%s`\n**Ilość:** `%s`"
    },
}

-- ──────────────────────────────────────────────────────────────────────────────
-- (Information) ► Formats webhook message based on LogsData entry and sends it.
-- (Information) ► Usage example:
--                 ServerConfig.formatWebHook("character_created", arg1, arg2, ...)
-- ──────────────────────────────────────────────────────────────────────────────
---@param logType string   -- key in ServerConfig.LogsData
---@param ... any          -- formatting params for desc
---@return table           -- { title = "", color = 0, message = "" }
ServerConfig.formatWebHook = function(logType, ...)
    local log = ServerConfig.LogsData[logType]
    if not log then
        print("^1[OP-MULTICHARACTER] Invalid logType: " .. tostring(logType))
        return false
    end

    local formattedDesc = string.format(log.desc, ...)

    local embed = {{
        ["color"] = log.color,
        ["title"] = log.header,
        ["description"] = formattedDesc,
        ["footer"] = { text = os.date("%c") .. " (Server Time)." }
    }}

    PerformHttpRequest(ServerConfig.LogsWebhook,
        function(err, text, headers) end,
        "POST",
        json.encode({ username = "ExoticRP - Multicharacter", embeds = embed }),
        { ["Content-Type"] = "application/json" }
    )
end