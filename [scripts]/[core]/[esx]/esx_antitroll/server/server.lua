AddEventHandler("esx:playerLoaded", function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer then
        MySQL.scalar("SELECT protection FROM users WHERE identifier = ?", { xPlayer.identifier }, function(result)
            if result > 0 then
                TriggerClientEvent("esx_antitroll/startProtection", src, result)
            end
        end)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local time = Player(src).state.ProtectionTime

    if xPlayer then
        if time ~= nil then
            MySQL.update("UPDATE users SET protection = ? WHERE identifier = ?", { tonumber(time), xPlayer.identifier },
                function() end)
        end
    end
end)