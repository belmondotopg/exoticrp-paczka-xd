CreateThread(function()
    local appId = '1394704062691151872'
    local maxPlayers = GetConvarInt('sv_maxclients', 300)

    while true do
        local pid = PlayerId()
        local id = GetPlayerServerId(pid)
        local name = GetPlayerName(pid)

        local players = GlobalState.playerCount

        SetDiscordAppId(appId)
        
        SetDiscordRichPresenceAsset('avatar-solo')
        SetDiscordRichPresenceAssetText('ExoticRP')
        SetDiscordRichPresenceAssetSmall('avatar-solo')
        SetDiscordRichPresenceAssetSmallText('ExoticRP')
        SetDiscordRichPresenceAction(0, 'Nasz Discord', 'https://discord.gg/exoticrp')
        SetDiscordRichPresenceAction(1, 'Dołącz do gry!', 'https://cfx.re/join/bj9xkd')
        SetRichPresence("ID: " .. id .. " | " .. name .. " | " .. players .. "/" .. maxPlayers)

        Wait(60000)
    end
end)