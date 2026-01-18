RegisterNetEvent('esx_core:tackle:sendTackledPlayers', function(players, forwardVector) 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local plrCoords = GetEntityCoords(GetPlayerPed(src))
    for _,v in ipairs(players) do
        local ped = GetPlayerPed(v)
        if ped then
            local tackledCoords = GetEntityCoords(ped)
            if #(tackledCoords - plrCoords) < 5 then
                TriggerClientEvent('esx_core:tackle:receiveTackled', v, forwardVector)
            end
        end
    end
end)