RegisterServerEvent('esx_hud:radio:sync_server', function(players, current_players)
    for k,v in pairs(current_players) do
        TriggerClientEvent('esx_hud:syncRadioPlayers', v.playerId, players, current_players)
    end
end)


RegisterServerEvent('esx_hud:radio:syncPlayers', function(players)
    local src = source
    for k, v in pairs(players) do
        if v.id ~= src then
            TriggerClientEvent('esx_hud:radio:getSyncing', v.id)
        end
    end
end)