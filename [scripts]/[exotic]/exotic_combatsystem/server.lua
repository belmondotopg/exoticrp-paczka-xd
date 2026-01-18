ESX.RegisterServerCallback("CustomWeaponDamage", function(source, cb, effectType, weaponHash, attackerServerId)
    if attackerServerId and GetPlayerPed(attackerServerId) then
        cb(true)
    else
        cb(true)
    end
end)

RegisterNetEvent('TriggerKillEffect', function(targetServerId, killType)
    if targetServerId and GetPlayerPed(targetServerId) then
        TriggerClientEvent("KillEffect", targetServerId, killType)
    end
end)

RegisterNetEvent('TriggerHeadEffect', function(targetServerId)
    if targetServerId and GetPlayerPed(targetServerId) then
        TriggerClientEvent("HeadEffect", targetServerId)
    end
end)