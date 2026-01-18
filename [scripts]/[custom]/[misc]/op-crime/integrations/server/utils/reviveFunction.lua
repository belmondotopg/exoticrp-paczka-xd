-- ──────────────────────────────────────────────────────────────────────────────
-- revivePlayer                                                                
-- (Information) ► Revives a player using the appropriate medical system for the
--        active framework (ESX / QBCore / QBox).
-- (Information) ► This is a server-side helper meant to be called from other systems
--        (e.g. medic NPCs, tablet actions, admin tools, missions).
-- [ADV]  Do not change event names unless you know how your medical script works.
-- ──────────────────────────────────────────────────────────────────────────────

---@param source number -- Server ID of the player to revive
function revivePlayer(source)
    while Framework == nil do Wait(5) end

    if ESX then
        local xPlayer = Fr.getPlayerFromId(source)
        TriggerClientEvent('esx_ambulance:onTargetRevive', xPlayer.source)
    elseif QBCore then
        local Player   = Fr.getPlayerFromId(source)
        local playerId = Fr.GetSourceFromPlayerObject(Player)

        TriggerClientEvent('hospital:client:Revive', playerId)
	    TriggerClientEvent("hospital:client:HealInjuries", playerId, "full")
    elseif QBox then
        local Player   = Fr.getPlayerFromId(source)
        local playerId = Fr.GetSourceFromPlayerObject(Player)

        TriggerClientEvent('qbx_medical:client:playerRevived', playerId)
    end
end
