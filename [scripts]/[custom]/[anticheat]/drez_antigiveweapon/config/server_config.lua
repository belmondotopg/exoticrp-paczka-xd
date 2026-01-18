
Config.Log = true -- Enable debug logs, set to false to disable

Config.KickPlayer = false -- set to true if you want to kick player from server
Config.KickMessage = "Weapon Spawn Detected" -- if Config.KickPlayer set to true, this is a reason
Config.BanPlayer = false -- set to true if you want to ban player from server, if so, you need to implement your own ban function (using Events/exports whatever you using)


---@param playerId number
---@param spawnedWeapon string
---@param spawnMethod string
Config.BanFunction = function(playerId, spawnedWeapon, spawnMethod) -- if Config.BanPlayer set to true, this is a function that will be called when player got detected
    -- exports["ac_name"]:fg_BanPlayer(playerId, 'Tried to spawn weapon: ' .. spawnedWeapon.. ' by '..spawnMethod, true)
end

Config.LogPlayer = true -- Enable discord webhook logging, set to false if you want to disable discord logging
Config.LogWebhook = "https://discord.com/api/webhooks/" -- if Config.LogPlayer set to true, this is a webhook url (like: https://discord.com/api/webhooks/123456789012345678/123456789012345678)
Config.LogMessage = "Player spawned a weapon" -- if Config.LogPlayer set to true, this is a log message


---@diagnostic disable-next-line: duplicate-set-field
Config.BypassException = function() -- Bypass function for your own compatibility, but server sided
    return true
end