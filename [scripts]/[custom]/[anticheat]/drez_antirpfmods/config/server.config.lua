Config.BucketRange = {50, 1500} -- range of buckets that can be generated during test, recommended to set smaller difference and set buckets that you dont use. You can leave this by default 

Config.Log = true -- Enable debug logs, set to false to disable

Config.KickPlayer = true -- set to true if you want to kick player from server

Config.KickFunction = function(playerId, detectedMods)
    Wait(5000) -- Player will be kicked after finishing test, some servers requires to save your position first, so we wait more 5 seconds
    DropPlayer(playerId, "drez_antirpfmods: Detected RPF Mods\n" .. detectedMods)
end

Config.BanPlayer = false -- set to true if you want to ban player from server, if so, you need to implement your own ban function (using Events/exports whatever you using)

---@param playerId number
---@param outData table
Config.BanFunction = function(playerId, outData) -- if Config.BanPlayer set to true, this is a function that will be called when player got detected
    
end

Config.LogPlayer = true -- Enable discord webhook logging, set to false if you want to disable discord logging
Config.LogWebhook = "https://discord.com/api/webhooks/" -- if Config.LogPlayer set to true, this is a webhook url (like: https://discord.com/api/webhooks/123456789012345678/123456789012345678)
Config.LogMessage = "Player is using RPF Mods" -- if Config.LogPlayer set to true, this is a log message
