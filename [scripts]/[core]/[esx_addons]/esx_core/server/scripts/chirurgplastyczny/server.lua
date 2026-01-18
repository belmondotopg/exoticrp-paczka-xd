local SurgeryConfig = {
    SurgeryPrice = 3000,
    SurgeonLocation = vector3(1126.3043, -1532.2391, 35.0330),
    CooldownTime = 30000,
    MaxDistance = 10.0
}

local cooldowns = {}

RegisterNetEvent('exoticrp:requestSurgery', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local currentTime = GetGameTimer()
    if cooldowns[src] and cooldowns[src] > currentTime then
        local remainingTime = math.ceil((cooldowns[src] - currentTime) / 1000)
        xPlayer.showNotification(string.format('~r~Poczekaj chwilę przed następną operacją!~w~ Pozostało: %d sekund', remainingTime))
        return
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local distance = #(coords - SurgeryConfig.SurgeonLocation)

    if distance > SurgeryConfig.MaxDistance then
        print(string.format("^1[ANTYCHEAT] %s (ID: %s) próba operacji z odległości: %.2f (max: %.2f)^0", 
            GetPlayerName(src), src, distance, SurgeryConfig.MaxDistance))
        xPlayer.showNotification('~r~Jesteś za daleko od chirurga!~w~ Zbliż się do niego.')
        return
    end

    if xPlayer.getMoney() >= SurgeryConfig.SurgeryPrice then
        xPlayer.removeMoney(SurgeryConfig.SurgeryPrice)
        cooldowns[src] = currentTime + SurgeryConfig.CooldownTime
        TriggerClientEvent('exoticrp:performSurgery', src)
    else
        xPlayer.showNotification(string.format('~r~Nie masz wystarczająco pieniędzy!~w~ Potrzebujesz $%d', SurgeryConfig.SurgeryPrice))
    end
end)

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)