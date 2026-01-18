RegisterCommand("printIdentifiers", function(source,args,rawCommand)
	if source == 0 and args[1] then -- only let Console run this command
		local id = tonumber(args[1])
		print(json.encode(CachedPlayers[id].identifiers)) -- puke all identifiers into console
	end
end,false)

RegisterCommand("spectate", function(source, args, rawCommand)
    if source == 0 then
        Citizen.Trace(GetLocalisedText("badidea")) -- Maybe should be it's own string saying something like "only players can do this" or something
    end
    
    PrintDebugMessage("Player "..getName(source,true).." Requested Spectate on "..getName(args[1],true), 3)
    
    if args[1] and tonumber(args[1]) and DoesPlayerHavePermission(source, "player.spectate") then
        if getName(args[1]) then
            TriggerClientEvent("EasyAdmin:requestSpectate", source, args[1])
        else
            TriggerClientEvent("EasyAdmin:showNotification", source, GetLocalisedText("playernotfound"))
        end
    end
end, false)

RegisterCommand("slap", function(source, args, rawCommand)
    if args[1] and args[2] and DoesPlayerHavePermission(source, "player.slap") then
        local preferredWebhook = detailNotification ~= "false" and detailNotification or moderationNotification
        SendWebhookMessage(preferredWebhook,string.format(GetLocalisedText("adminslappedplayer"), getName(source, false, true), getName(args[1], true, true), args[2]), "slap", 16711680)
        PrintDebugMessage("Player "..getName(source,true).." slapped "..getName(args[1],true).." for "..args[2].." HP", 3)
        TriggerClientEvent("EasyAdmin:SlapPlayer", args[1], args[2])
    end
end, false)	