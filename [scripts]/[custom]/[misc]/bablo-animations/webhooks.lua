-- Here you can configure the webhooks here is all the diffrent types of webhooks if you only would like some and not all you can either set it as false or leave it as ''.
-- The webhooks are used to log diffrent actions in the server to discord.

while not eventName do Wait(0) end

Webhooks = {
    ['PLACED_ANIMATION'] = {
        title = 'Placed Animation',
        template = '%s placed animation %s',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
    ['PLAYED_ANIMATION'] = {
        title = 'Played Animation',
        template = '%s played animation %s',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
    ['JOINED_GROUP'] = {
        title = 'Joined Group',
        template = '%s joined %s group',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
    ['LEFT_GROUP'] = {
        title = 'Left Group',
        template = '%s left %s group',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
    ['SET_WALKINGSTYLE'] = {
        title = 'Set Walking Style',
        template = '%s set walking style to %s',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
    ['SET_EXPRESSION'] = {
        title = 'Set Expression',
        template = '%s set expression to %s',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
    ['SET_WEAPON_STYLE'] = {
        title = 'Set Weapon Style',
        template = '%s set weapon style to %s',
        webhook = 'https://discord.com/api/webhooks/1404908235064082442/Sg5KA_ljc4_lq_wi0VjOOZVGLfUZ0aZXP2mB_mQ66BoKhbqfvT3f_5C4rvfR4O5Fhe9p'
    },
}

function sendWebhook(source, name, messageData)
    if not Config.Logs then return end

    if not Webhooks[name] or not Webhooks[name].webhook or Webhooks[name].webhook == '' then 
        Trace('Webhook error: Webhook URL not set for', name)
        return 
    end

    local playerName
    if Config.Framework == 'standalone' then
        playerName = GetPlayerName(source)
    else
        playerName = GetPlayerName(source) .. ' (' .. source .. ') ' .. Framework:getPlayerName(source)
    end

    local message = Webhooks[name].template and string.format(Webhooks[name].template, playerName, tostring(messageData)) or "ERROR: No template found"

    local payload = {
        embeds = {
            {
                title = Webhooks[name].title or "Webhook",
                description = message,
                color = 8039935,
                footer = {
                    text = 'Bablo Animations | ' .. os.date("%Y-%m-%d %H:%M:%S")
                }
            }
        }
    }

    PerformHttpRequest(Webhooks[name].webhook, function(err, text, headers)         
        if err == 401 then
            Trace("ERROR: Unauthorized - The webhook URL might be invalid or expired.")
        elseif err == 429 then
            Trace("ERROR: Rate limited - Too many requests. Wait and try again later.")
        elseif err ~= 200 and err ~= 204 then
            Trace("Webhook failed! HTTP Error:", err, "Response:", text)
        end
    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
    
end


RegisterNetEvent(eventName .. 'server:sendWebhook')
AddEventHandler(eventName .. 'server:sendWebhook', function(name, data)
    Trace('Sending webhook', name, json.encode(data))

    sendWebhook(source, name, data)
end)